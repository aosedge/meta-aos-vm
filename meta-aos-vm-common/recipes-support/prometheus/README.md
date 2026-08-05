# Prometheus monitoring stack (aos-vm)

Exporters and VictoriaMetrics run on the VM; Grafana runs on the host
(`meta-aos-vm/tools/grafana`):

```
VM:
  node_exporter              :9100 ─┐
  process-exporter           :9256 ─┼─ VictoriaMetrics :8428
  push_profiling_annotations ───────┘   (scrape / import + store + query)
                                              │
Host:                                         ▼
  Grafana (tools/grafana)  ←── queries :8428
```

Only collectors needed by the dashboards are enabled. Exporters may expose
additional metrics produced by those collectors, but VictoriaMetrics stores
only the metrics queried by the dashboards (plus pushed annotation points).
Limiting is done entirely inside the exporter service flags and the
VictoriaMetrics scrape config — there is no extra proxy/filter process.
Annotation markers are written directly via
`/api/v1/import/prometheus` by `push_profiling_annotations.py`.

## Components

| Recipe | Binary | Port / path | Role |
|--------|--------|-------------|------|
| `node-exporter_1.8.2.bb` | `node_exporter` | 9100 | Host CPU / memory metrics |
| `process-exporter_0.8.5.bb` | `process-exporter` | 9256 | Per-app CPU / memory for `aos_*` apps |
| `victoria-metrics_1.102.0.bb` | `victoria-metrics` | 8428 | Scrape, store (1 day), query |
| `push-profiling-annotations.bb` | `push_profiling_annotations.py` | POST `:8428/api/v1/import/prometheus` | Push journal profiling markers as point metrics |

## How collection is limited

- **node_exporter** — `--collector.disable-defaults` plus only `--collector.cpu`
  and `--collector.meminfo`. No filesystem, network, disk, load, or other
  collectors run. `--web.disable-exporter-metrics` disables most exporter
  self-metrics.
- **process-exporter** — `aos-apps.yaml` matches only the three `aos_*` apps;
  `--threads=false` disables per-thread (`threadname`) collection to reduce
  `/proc` scanning. PSS collection remains enabled because the RAM panel needs
  `proportionalResident`.
- **VictoriaMetrics** — `-selfScrapeInterval=0` disables self-monitoring
  (`vm_*` / `go_*`), `-promscrape.noStaleMarkers` avoids stale-marker series,
  and `scrape.yml` `metric_relabel_configs` keep only the dashboard metrics
  (and, for CPU, only `mode="idle"`). Annotation metrics are not scraped; they
  are imported by `push_profiling_annotations.py`.
- **`push_profiling_annotations.py`** — reads journal profiling lines and POSTs
  point samples (`value=1`) named `aos_annotations` (default `--metric`) with
  labels `module`, `text`, `unit`, `hostname`. Grafana also queries `app_event`
  for dashboard annotations (same point-metric style; push with
  `--metric=app_event` if used).

## Metric name vs series

A **metric name** is `__name__` (e.g. `namedprocess_namegroup_cpu_seconds_total`).
A **series** is one unique combination of metric name + labels.

Examples of the counts used below:

- `namedprocess_namegroup_cpu_seconds_total` **(6)** =
  3 apps (`aos_cm_app`, `aos_sm_app`, `aos_iam_app`) × 2 modes (`user`, `system`)
- `namedprocess_namegroup_memory_bytes` **(3)** =
  3 apps × 1 memtype (`proportionalResident`)
- **`up` + `scrape_*` (7)** = per scrape target, VictoriaMetrics always adds:
  `up`, `scrape_duration_seconds`, `scrape_samples_scraped`,
  `scrape_samples_post_metric_relabeling`, `scrape_series_added`,
  `scrape_timeout_seconds`, `scrape_response_size_bytes`
- **`aos_annotations` series** = one series per unique label set
  (`module`/`text`/`unit`/`hostname`); count grows with distinct journal events
  pushed (live example after one push: 10 series)

## Remaining metrics and responsible collector

Each exporter section lists every metric it still exposes on its raw endpoint,
which collector produces it, and whether Grafana uses it. It also explains why
the unused metrics cannot be turned off, and which dedicated metric the
dashboards actually consume.

### node_exporter (job `node`) — raw `:9100`

**Why the unused metrics stay:** the enabled collectors are all-or-nothing.
`--collector.meminfo` always emits every `/proc/meminfo` field and
`--collector.cpu` always emits every CPU mode — node_exporter has no per-field
or per-mode switch. `--web.disable-exporter-metrics` already removes the Go /
process self-metrics, but the build/scrape bookkeeping stays. Everything not
needed by Grafana is dropped by `scrape.yml` before storage.

**Dedicated metrics Grafana uses:** `node_cpu_seconds_total{mode="idle"}` (CPU
panel), `node_memory_MemTotal_bytes` + `node_memory_MemFree_bytes` (RAM panel),
`node_memory_SwapTotal_bytes` + `node_memory_SwapFree_bytes` (Swap panel).

| Metric | Collector | Used in Grafana |
|--------|-----------|-----------------|
| `node_cpu_seconds_total` | `cpu` | yes — only `mode="idle"` (CPU panel) |
| `node_cpu_guest_seconds_total` | `cpu` | no |
| `node_memory_Active_anon_bytes` | `meminfo` | no |
| `node_memory_Active_bytes` | `meminfo` | no |
| `node_memory_Active_file_bytes` | `meminfo` | no |
| `node_memory_AnonPages_bytes` | `meminfo` | no |
| `node_memory_Bounce_bytes` | `meminfo` | no |
| `node_memory_Buffers_bytes` | `meminfo` | no |
| `node_memory_Cached_bytes` | `meminfo` | no |
| `node_memory_CommitLimit_bytes` | `meminfo` | no |
| `node_memory_Committed_AS_bytes` | `meminfo` | no |
| `node_memory_DirectMap1G_bytes` | `meminfo` | no |
| `node_memory_DirectMap2M_bytes` | `meminfo` | no |
| `node_memory_DirectMap4k_bytes` | `meminfo` | no |
| `node_memory_Dirty_bytes` | `meminfo` | no |
| `node_memory_Inactive_anon_bytes` | `meminfo` | no |
| `node_memory_Inactive_bytes` | `meminfo` | no |
| `node_memory_Inactive_file_bytes` | `meminfo` | no |
| `node_memory_KReclaimable_bytes` | `meminfo` | no |
| `node_memory_KernelStack_bytes` | `meminfo` | no |
| `node_memory_Mapped_bytes` | `meminfo` | no |
| `node_memory_MemAvailable_bytes` | `meminfo` | no |
| `node_memory_MemFree_bytes` | `meminfo` | **yes (RAM panel)** |
| `node_memory_MemTotal_bytes` | `meminfo` | **yes (RAM panel)** |
| `node_memory_Mlocked_bytes` | `meminfo` | no |
| `node_memory_NFS_Unstable_bytes` | `meminfo` | no |
| `node_memory_PageTables_bytes` | `meminfo` | no |
| `node_memory_Percpu_bytes` | `meminfo` | no |
| `node_memory_SReclaimable_bytes` | `meminfo` | no |
| `node_memory_SUnreclaim_bytes` | `meminfo` | no |
| `node_memory_SecPageTables_bytes` | `meminfo` | no |
| `node_memory_Shmem_bytes` | `meminfo` | no |
| `node_memory_Slab_bytes` | `meminfo` | no |
| `node_memory_SwapCached_bytes` | `meminfo` | no |
| `node_memory_SwapFree_bytes` | `meminfo` | **yes (Swap panel)** |
| `node_memory_SwapTotal_bytes` | `meminfo` | **yes (Swap panel)** |
| `node_memory_Unevictable_bytes` | `meminfo` | no |
| `node_memory_VmallocChunk_bytes` | `meminfo` | no |
| `node_memory_VmallocTotal_bytes` | `meminfo` | no |
| `node_memory_VmallocUsed_bytes` | `meminfo` | no |
| `node_memory_WritebackTmp_bytes` | `meminfo` | no |
| `node_memory_Writeback_bytes` | `meminfo` | no |
| `node_exporter_build_info` | exporter bookkeeping | no |
| `node_scrape_collector_duration_seconds` | exporter bookkeeping | no |
| `node_scrape_collector_success` | exporter bookkeeping | no |

### process-exporter (job `process`) — raw `:9256`

process-exporter has no named collectors like node_exporter; the **Collector**
column below is the logical source / subsystem.

**Why the unused metrics stay:** v0.8.5 has no per-metric / per-collector
switches ([issue #327](https://github.com/ncabatoff/process-exporter/issues/327))
and no `--web.disable-exporter-metrics`
([issue #248](https://github.com/ncabatoff/process-exporter/issues/248)), so
matching a process always emits the full `namedprocess_namegroup_*` set plus the
`go_*` / `process_*` / `promhttp_*` self-metrics. What we *can* limit is already
limited: `--threads=false` removes per-thread `thread_*` series and
`aos-apps.yaml` restricts collection to the three `aos_*` apps. `--gather-smaps`
must stay on because the RAM panel needs `proportionalResident`. The `go_*` /
`process_*` overhead is small (exporter's own process); the costly part is the
`namedprocess` `/proc` scan, already narrowed to three apps and no threads.
Unused series are dropped by `scrape.yml` before storage.

**Dedicated metrics Grafana uses:** `namedprocess_namegroup_cpu_seconds_total`
(per-app CPU panel) and
`namedprocess_namegroup_memory_bytes{memtype="proportionalResident"}` (per-app
RAM panel), both filtered to `groupname=~"aos_cm_app|aos_sm_app|aos_iam_app"`.

| Metric | Collector | Used in Grafana |
|--------|-----------|-----------------|
| `namedprocess_namegroup_context_switches_total` | `namedprocess` (`/proc/<pid>/status`) | no |
| `namedprocess_namegroup_cpu_seconds_total` | `namedprocess` (`/proc/<pid>/stat`) | **yes (per-app CPU)** |
| `namedprocess_namegroup_major_page_faults_total` | `namedprocess` (`/proc/<pid>/stat`) | no |
| `namedprocess_namegroup_memory_bytes` | `namedprocess` (`/proc/<pid>/smaps_rollup`, `--gather-smaps`) | **yes — only `memtype="proportionalResident"` (per-app RAM)** |
| `namedprocess_namegroup_minor_page_faults_total` | `namedprocess` (`/proc/<pid>/stat`) | no |
| `namedprocess_namegroup_num_procs` | `namedprocess` | no |
| `namedprocess_namegroup_num_threads` | `namedprocess` | no |
| `namedprocess_namegroup_oldest_start_time_seconds` | `namedprocess` | no |
| `namedprocess_namegroup_open_filedesc` | `namedprocess` | no |
| `namedprocess_namegroup_read_bytes_total` | `namedprocess` (`/proc/<pid>/io`) | no |
| `namedprocess_namegroup_states` | `namedprocess` | no |
| `namedprocess_namegroup_threads_wchan` | `namedprocess` | no |
| `namedprocess_namegroup_worst_fd_ratio` | `namedprocess` | no |
| `namedprocess_namegroup_write_bytes_total` | `namedprocess` (`/proc/<pid>/io`) | no |
| `namedprocess_scrape_errors` | `namedprocess` | no |
| `namedprocess_scrape_partial_errors` | `namedprocess` | no |
| `namedprocess_scrape_procread_errors` | `namedprocess` | no |
| `go_gc_duration_seconds` | `go` | no |
| `go_gc_duration_seconds_count` | `go` | no |
| `go_gc_duration_seconds_sum` | `go` | no |
| `go_goroutines` | `go` | no |
| `go_info` | `go` | no |
| `go_memstats_*` | `go` | no |
| `go_threads` | `go` (exporter self, Prometheus Go client) | no |
| `process_cpu_seconds_total` | `process` (exporter self, Prometheus process client — **not** `aos_*` apps) | no |
| `process_exporter_build_info` | `process` (exporter self) | no |
| `process_max_fds` | `process` (exporter self) | no |
| `process_open_fds` | `process` (exporter self) | no |
| `process_resident_memory_bytes` | `process` (exporter self) | no |
| `process_start_time_seconds` | `process` (exporter self) | no |
| `process_virtual_memory_bytes` | `process` (exporter self) | no |
| `process_virtual_memory_max_bytes` | `process` (exporter self) | no |
| `promhttp_metric_handler_requests_in_flight` | `promhttp` (exporter self) | no |
| `promhttp_metric_handler_requests_total` | `promhttp` (exporter self) | no |

The `process` / `go` / `promhttp` rows above are self-metrics of the
process-exporter binary. They are unused by Grafana and cannot be disabled in
v0.8.5; they are dropped by `scrape.yml`. Do not confuse them with
`namedprocess_*`, which tracks the `aos_*` apps.

### victoria-metrics (storage / import)

**Why the unused metrics stay:** VictoriaMetrics always exposes its own
`/metrics` page (~292 names) for debugging; there is no flag to trim it. With
`-selfScrapeInterval=0` and no `victoria-metrics` scrape job, none of that self
page is scraped or stored. What *is* stored comes from:
1. the `node` and `process` scrape jobs after `scrape.yml` keep/drop, and
2. direct imports from `push_profiling_annotations.py`
   (`POST /api/v1/import/prometheus`).

The `up` / `scrape_*` helpers are added by the scraper for every scrape job and
cannot be turned off. Imported annotation samples do not get those scrape
helpers.

**Dedicated metrics Grafana uses from this path:** `aos_annotations` (RAM/CPU
panel markers; default `--metric` of the push script) and `app_event` (Grafana
annotation query in the dashboard). Example push:

```text
./push_profiling_annotations.py
# -> aos_annotations{module,text,unit,hostname} 1 <timestamp_ms>
# -> POST http://10.0.0.100:8428/api/v1/import/prometheus
```

| Exporter | Group / collector | Metric names (examples) | Used in Grafana | Stored |
|----------|-------------------|-------------------------|-----------------|--------|
| `node_exporter` | `cpu` | `node_cpu_seconds_total{mode="idle"}` | yes (CPU panel) | yes (1 series) |
| `node_exporter` | `meminfo` | `node_memory_MemTotal_bytes`, `node_memory_MemFree_bytes` | yes (RAM panel) | yes (2 series) |
| `node_exporter` | `meminfo` | `node_memory_SwapTotal_bytes`, `node_memory_SwapFree_bytes` | yes (Swap panel) | yes (2 series) |
| `process-exporter` | `namedprocess` (`/proc/<pid>/stat`) | `namedprocess_namegroup_cpu_seconds_total` | yes (per-app CPU) | yes (6 series: 3 apps × user/system) |
| `process-exporter` | `namedprocess` (`/proc/<pid>/smaps_rollup`) | `namedprocess_namegroup_memory_bytes{memtype="proportionalResident"}` | yes (per-app RAM) | yes (3 series: 3 apps) |
| `push_profiling_annotations.py` | journal import (`--metric`, default `aos_annotations`) | `aos_annotations{module,text,unit,hostname}` | yes (panel markers) | yes (N series; one per distinct label set — e.g. 10 after one push) |
| `push_profiling_annotations.py` | journal import (`--metric=app_event`) | `app_event{…}` | yes (Grafana annotation query) | yes when pushed |
| victoria-metrics scraper | scraper helpers | `up`, `scrape_duration_seconds`, `scrape_samples_scraped`, `scrape_samples_post_metric_relabeling`, `scrape_series_added`, `scrape_timeout_seconds`, `scrape_response_size_bytes` | no | yes (7 per scraped target) |
| victoria-metrics self (`:8428/metrics`) | `flag` | `flag` (build/runtime flags) | no | no |
| victoria-metrics self (`:8428/metrics`) | `go` | `go_goroutines`, `go_threads`, `go_info`, `go_gc_*`, `go_memstats_*`, `go_sched_*`, … | no | no |
| victoria-metrics self (`:8428/metrics`) | `process` | `process_cpu_seconds_total`, `process_resident_memory_bytes`, `process_open_fds`, `process_io_*`, … | no | no |
| victoria-metrics self (`:8428/metrics`) | `vm` (storage) | `vm_rows`, `vm_parts`, `vm_data_size_bytes`, `vm_free_disk_space_bytes`, `vm_cache_*`, `vm_merges_*`, … | no | no |
| victoria-metrics self (`:8428/metrics`) | `vm` (HTTP / insert / select) | `vm_http_requests_total`, `vm_request_duration_seconds`, `vminsert_*`, `vmselect_*`, … | no | no |
| victoria-metrics self (`:8428/metrics`) | `vm` (promscrape) | `vm_promscrape_scrapes_total`, `vm_promscrape_targets`, `vm_promscrape_scrape_duration_seconds_*`, … | no | no |

**Stored-series summary** (scraped jobs after keep/drop + imported annotations):

| Source | Dashboard metric names | Dashboard series | Scraper series (`up` + `scrape_*`) | Total |
|--------|------------------------|------------------|------------------------------------|-------|
| job `node` | 5 | 5 | 7 | 12 |
| job `process` | 2 | 9 | 7 | 16 |
| import `aos_annotations` | 1 | N (e.g. 10) | 0 | N |
| import `app_event` | 1 when used | N | 0 | N |
| `victoria-metrics` self-scrape | 0 | 0 | 0 | 0 |
| **Baseline (no annotations)** | **7** | **14** | **14** | **28** |

## Notes

- To add a metric to a dashboard, extend the matching `keep` regex in
  `files/scrape.yml` (and enable the relevant node_exporter collector if needed).
