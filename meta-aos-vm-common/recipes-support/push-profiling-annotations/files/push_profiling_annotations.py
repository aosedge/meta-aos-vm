#!/usr/bin/env python3
"""Collect journal lines matching configured patterns and push them to
VictoriaMetrics as annotation point metrics.

Version: 9

VictoriaMetrics stores sample timestamps at millisecond resolution. AOS
profiling bursts often share the same journal millisecond; use --spread-ms
if you need visually separated markers on wide Grafana time ranges.

Labels: module, text, unit, hostname

Note: Instant MetricsQL queries put the *evaluation* time in value[0].
Use /api/v1/export to inspect stored sample timestamps.
"""

from __future__ import annotations

import argparse
import base64
import json
import re
import subprocess
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Iterator, List, Optional, Pattern, Sequence, Tuple

SCRIPT_VERSION = 9

DEFAULT_TAG = "[profiling]"
DEFAULT_URL = "http://10.0.0.100:8428/api/v1/import/prometheus"
DEFAULT_EXCLUDE_UNITS = ("victoria-metrics.service",)

MODULE_PREFIX_RE = re.compile(r"^\((?P<module>[^)]+)\)")


@dataclass(frozen=True)
class AnnotationEvent:
    timestamp_us: int
    module: str
    text: str
    unit: str
    hostname: str

    @property
    def timestamp_ms(self) -> int:
        return self.timestamp_us // 1000


@dataclass(frozen=True)
class MatchRule:
    source: str
    regex: Optional[Pattern[str]] = None
    literal: Optional[str] = None

    def match(self, message: str) -> Optional[re.Match[str]]:
        if self.literal is not None:
            if self.literal not in message:
                return None
            return re.search(re.escape(self.literal), message)
        assert self.regex is not None
        return self.regex.search(message)


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Find journal log lines for the current boot (by tag and/or regex "
            "patterns) and push annotation metrics to VictoriaMetrics."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Patterns:\n"
            "  --tag is a literal substring (default: [profiling]).\n"
            "  --pattern may be repeated; each value is a Python regex.\n"
            "  --pattern-file loads one regex per line (# comments allowed).\n"
            "  A line matches if the tag matches OR any pattern matches.\n"
            "  Use --tag '' to disable the default literal tag.\n"
            "  Optional named group (?P<module>...) fills the module label.\n"
            "\n"
            "Timestamps:\n"
            "  Taken from journald __REALTIME_TIMESTAMP (microseconds),\n"
            "  converted to milliseconds for VictoriaMetrics.\n"
            "  --spread-ms N forces at least N ms between consecutive events\n"
            "  (useful on wide Grafana ranges; profiling bursts are often <1ms).\n"
        ),
    )
    parser.add_argument(
        "--url",
        default=DEFAULT_URL,
        help="VictoriaMetrics Prometheus import endpoint",
    )
    parser.add_argument(
        "--user",
        default="root",
        help="HTTP basic auth username (empty to disable auth)",
    )
    parser.add_argument(
        "--password",
        default="Password1",
        help="HTTP basic auth password",
    )
    parser.add_argument(
        "--tag",
        default=DEFAULT_TAG,
        help=(
            f"Literal substring matcher (default: {DEFAULT_TAG}). "
            "Pass empty string to disable."
        ),
    )
    parser.add_argument(
        "--pattern",
        action="append",
        default=[],
        metavar="REGEX",
        help="Additional Python regex to match MESSAGE (repeatable)",
    )
    parser.add_argument(
        "--pattern-file",
        action="append",
        default=[],
        metavar="PATH",
        help="File with one regex per line (# starts a comment; repeatable)",
    )
    parser.add_argument(
        "--metric",
        default="aos_annotations",
        help="Metric name for point annotations (value=1 at event time)",
    )
    parser.add_argument(
        "--spread-ms",
        type=int,
        default=0,
        metavar="N",
        help=(
            "Minimum milliseconds between consecutive annotation timestamps "
            "(0 = raw journal ms; try 1000 to separate markers on Grafana)"
        ),
    )
    parser.add_argument(
        "--extra-label",
        action="append",
        default=[],
        metavar="KEY=VALUE",
        help="Extra label attached to every sample (repeatable)",
    )
    parser.add_argument(
        "--unit",
        default="",
        help="Optional systemd unit filter passed to journalctl -u",
    )
    parser.add_argument(
        "--boot",
        default="0",
        help="Boot offset for journalctl -b (default: 0 = current)",
    )
    parser.add_argument(
        "--journalctl",
        default="journalctl",
        help="Path to journalctl binary",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=30.0,
        help="HTTP timeout in seconds",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print Prometheus payload instead of pushing",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Print journalctl command and match stats to stderr",
    )
    return parser.parse_args(argv)


def parse_extra_labels(items: Sequence[str]) -> List[Tuple[str, str]]:
    labels: List[Tuple[str, str]] = []
    for item in items:
        if "=" not in item:
            raise SystemExit(f"invalid --extra-label {item!r}, expected KEY=VALUE")
        key, value = item.split("=", 1)
        key = key.strip()
        if not key:
            raise SystemExit(f"invalid --extra-label {item!r}, empty key")
        labels.append((key, value))
    return labels


def load_patterns_from_files(paths: Sequence[str]) -> List[str]:
    patterns: List[str] = []
    for path in paths:
        try:
            with open(path, encoding="utf-8") as handle:
                for raw in handle:
                    line = raw.strip()
                    if not line or line.startswith("#"):
                        continue
                    patterns.append(line)
        except OSError as exc:
            raise SystemExit(f"failed to read --pattern-file {path}: {exc}") from exc
    return patterns


def compile_rules(tag: str, patterns: Sequence[str]) -> List[MatchRule]:
    rules: List[MatchRule] = []
    if tag:
        rules.append(MatchRule(source=f"tag:{tag}", literal=tag))

    for pattern in patterns:
        try:
            compiled = re.compile(pattern)
        except re.error as exc:
            raise SystemExit(f"invalid regex {pattern!r}: {exc}") from exc
        rules.append(MatchRule(source=pattern, regex=compiled))

    if not rules:
        raise SystemExit(
            "no matchers configured: provide --tag and/or --pattern/--pattern-file"
        )
    return rules


def escape_label_value(value: str) -> str:
    return value.replace("\\", "\\\\").replace("\n", "\\n").replace('"', '\\"')


def format_labels(labels: Sequence[Tuple[str, str]]) -> str:
    return ",".join(f'{k}="{escape_label_value(v)}"' for k, v in labels)


def normalize_message(message: object) -> str:
    if isinstance(message, list):
        return bytes(message).decode("utf-8", errors="replace")
    if isinstance(message, bytes):
        return message.decode("utf-8", errors="replace")
    return str(message)


def _iter_json_lines(text: str) -> Iterator[dict]:
    for line in text.splitlines():
        if line.strip():
            yield json.loads(line)


def first_matching_rule(
    message: str, rules: Sequence[MatchRule]
) -> Optional[Tuple[MatchRule, re.Match[str]]]:
    for rule in rules:
        match = rule.match(message)
        if match is not None:
            return rule, match
    return None


def extract_module(message: str, regex_match: re.Match[str]) -> str:
    groupdict = regex_match.groupdict()
    if groupdict.get("module"):
        return groupdict["module"]
    prefix = MODULE_PREFIX_RE.match(message)
    if prefix:
        return prefix.group("module")
    return "unknown"


def journal_entries(
    journalctl: str,
    rules: Sequence[MatchRule],
    unit: str,
    boot: str,
    verbose: bool = False,
) -> Iterator[Tuple[dict, re.Match[str]]]:
    """Read current-boot journal JSON and filter in Python (no --grep / PCRE2)."""
    cmd = [journalctl, "-b", boot, "--output=json", "--no-pager"]
    if unit:
        cmd.extend(["-u", unit])

    if verbose:
        print(f"journalctl cmd: {' '.join(cmd)}", file=sys.stderr)
        print(
            "matchers: "
            + ", ".join(
                (f"literal:{r.literal!r}" if r.literal is not None else f"regex:{r.source!r}")
                for r in rules
            ),
            file=sys.stderr,
        )

    try:
        proc = subprocess.run(cmd, check=False, capture_output=True, text=True)
    except FileNotFoundError as exc:
        raise SystemExit(f"failed to run journalctl: {exc}") from exc

    stderr = (proc.stderr or "").strip()
    if proc.returncode not in (0, 1):
        raise SystemExit(f"journalctl failed ({proc.returncode}): {stderr}")

    scanned = 0
    matched = 0
    for entry in _iter_json_lines(proc.stdout):
        scanned += 1
        message = normalize_message(entry.get("MESSAGE", ""))
        hit = first_matching_rule(message, rules)
        if hit is None:
            continue
        matched += 1
        yield entry, hit[1]

    if verbose:
        print(f"scanned {scanned} journal line(s), matched {matched}", file=sys.stderr)


def parse_event(entry: dict, regex_match: re.Match[str]) -> Optional[AnnotationEvent]:
    message = normalize_message(entry.get("MESSAGE", ""))
    try:
        timestamp_us = int(entry["__REALTIME_TIMESTAMP"])
    except (KeyError, TypeError, ValueError):
        return None

    return AnnotationEvent(
        timestamp_us=timestamp_us,
        module=extract_module(message, regex_match),
        text=message,
        unit=str(entry.get("_SYSTEMD_UNIT") or entry.get("UNIT") or ""),
        hostname=str(entry.get("_HOSTNAME") or ""),
    )


def collect_events(
    journalctl: str,
    rules: Sequence[MatchRule],
    unit: str,
    boot: str,
    verbose: bool = False,
) -> List[AnnotationEvent]:
    events: List[AnnotationEvent] = []
    for entry, regex_match in journal_entries(
        journalctl, rules, unit, boot, verbose=verbose
    ):
        event = parse_event(entry, regex_match)
        if event is not None:
            events.append(event)
    events.sort(key=lambda item: item.timestamp_us)
    return events


def assign_timestamps_ms(
    events: Sequence[AnnotationEvent], spread_ms: int
) -> List[int]:
    """Map journal µs times to VictoriaMetrics millisecond timestamps.

    Ensures timestamps are strictly increasing. If spread_ms > 0, consecutive
    events are at least spread_ms apart (starting from each event's journal ms,
    or the previous assigned time + spread_ms — whichever is later).
    """
    if spread_ms < 0:
        raise SystemExit("--spread-ms must be >= 0")

    assigned: List[int] = []
    prev: Optional[int] = None
    for event in events:
        ts = event.timestamp_ms
        if prev is not None:
            min_next = prev + max(1, spread_ms) if spread_ms > 0 else prev + 1
            if ts <= prev:
                ts = min_next
            elif spread_ms > 0 and ts < prev + spread_ms:
                ts = prev + spread_ms
        assigned.append(ts)
        prev = ts
    return assigned


def build_prometheus_payload(
    events: Sequence[AnnotationEvent],
    timestamps_ms: Sequence[int],
    metric: str,
    extra_labels: Sequence[Tuple[str, str]],
) -> str:
    lines: List[str] = []
    for event, ts_ms in zip(events, timestamps_ms):
        labels = [
            ("module", event.module),
            ("text", event.text),
            ("unit", event.unit),
            ("hostname", event.hostname),
            *extra_labels,
        ]
        lines.append(f"{metric}{{{format_labels(labels)}}} 1 {ts_ms}")
    return "\n".join(lines) + ("\n" if lines else "")


def push_payload(
    url: str, payload: str, timeout: float, user: str, password: str
) -> None:
    headers = {"Content-Type": "text/plain; charset=utf-8"}
    if user:
        token = base64.b64encode(f"{user}:{password}".encode("utf-8")).decode("ascii")
        headers["Authorization"] = f"Basic {token}"

    request = urllib.request.Request(
        url=url,
        data=payload.encode("utf-8"),
        method="POST",
        headers=headers,
    )
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            body = response.read().decode("utf-8", errors="replace")
            if response.status not in (200, 204):
                raise SystemExit(
                    f"VictoriaMetrics returned HTTP {response.status}: {body}"
                )
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise SystemExit(f"VictoriaMetrics HTTP {exc.code}: {detail}") from exc
    except urllib.error.URLError as exc:
        raise SystemExit(f"failed to reach VictoriaMetrics at {url}: {exc}") from exc


def format_local(ts_ms: int) -> str:
    return datetime.fromtimestamp(ts_ms / 1000.0, tz=timezone.utc).astimezone().isoformat(
        timespec="milliseconds"
    )


def main(argv: Optional[Sequence[str]] = None) -> int:
    args = parse_args(argv)
    extra_labels = parse_extra_labels(args.extra_label)
    file_patterns = load_patterns_from_files(args.pattern_file)
    rules = compile_rules(args.tag, [*args.pattern, *file_patterns])

    print(f"push_profiling_annotations.py version {SCRIPT_VERSION}", file=sys.stderr)

    events = collect_events(
        args.journalctl, rules, args.unit, args.boot, verbose=args.verbose
    )
    events = [e for e in events if e.unit not in DEFAULT_EXCLUDE_UNITS]
    timestamps_ms = assign_timestamps_ms(events, args.spread_ms)
    payload = build_prometheus_payload(events, timestamps_ms, args.metric, extra_labels)

    print(f"found {len(events)} matching log(s)", file=sys.stderr)
    if events:
        print(
            f"journal time span: {events[0].timestamp_us} .. {events[-1].timestamp_us} "
            f"us ({(events[-1].timestamp_us - events[0].timestamp_us)} us)",
            file=sys.stderr,
        )
        print(
            f"stored ms span:    {timestamps_ms[0]} .. {timestamps_ms[-1]} "
            f"({format_local(timestamps_ms[0])} .. {format_local(timestamps_ms[-1])})",
            file=sys.stderr,
        )
    if args.verbose:
        for event, ts_ms in zip(events, timestamps_ms):
            print(
                f"  journal_us={event.timestamp_us} -> ms={ts_ms} ({format_local(ts_ms)}) "
                f"text={event.text!r}",
                file=sys.stderr,
            )

    if not payload:
        print("nothing to push", file=sys.stderr)
        return 0

    if args.dry_run:
        sys.stdout.write(payload)
        return 0

    push_payload(args.url, payload, args.timeout, args.user, args.password)
    print(f"pushed to {args.url}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
