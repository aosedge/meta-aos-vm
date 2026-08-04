# Grafana (VictoriaMetrics) — provisioning-based

Shared settings live in Git (provisioning + dashboards).
Plotly is installed automatically with the Grafana container (`GF_INSTALL_PLUGINS`).
A Docker volume keeps local runtime state (sessions / prefs / downloaded plugins).

## Layout

| Path | Shared? | Purpose |
|------|---------|---------|
| `docker-compose.yml` | yes | Grafana service + plugin install |
| `provisioning/datasources/` | yes | VictoriaMetrics datasource |
| `provisioning/dashboards/` | yes | Load JSON dashboards |
| `dashboards/*.json` | yes | Dashboard definitions |
| Docker volume `aos-grafana-data` | no | Local Grafana state only |

## First time

```sh
cd tools/grafana

# remove old containers (standalone docker run / previous compose)
docker rm -f grafana grafana-init 2>/dev/null || true

# remove custom/local Grafana storage (Compose volume + leftover dirs)
docker compose down -v
docker volume rm aos-grafana-data 2>/dev/null || true
rm -rf ./storage ./grafana-storage.tgz ./plugins

docker compose up -d
```

Open http://localhost:3000 — login **admin** / **Password1**.

You should see datasource **prometheus** → `http://10.0.0.100:8428` and dashboard **victoria metrics**.

## Daily use

```sh
cd tools/grafana

docker compose start    # start
docker compose stop     # stop
docker compose logs -f  # logs
```

## Update shared settings

1. Change the dashboard (or datasource) in the Grafana UI.
2. Export a dashboard from UI into the repo:

```sh
curl -u admin:Password1 \
  http://127.0.0.1:3000/api/dashboards/uid/<UID> \
  | python3 -c 'import json,sys; json.dump(json.load(sys.stdin)["dashboard"], open("dashboards/NAME.json","w"), indent=2); print()'
```

3. `git commit` / `git pull` on other machines.
4. `docker compose restart grafana` (or wait for provisioning reload).

## Reset local state only

Same as first-time storage cleanup, then start again:

```sh
docker compose down -v
docker volume rm aos-grafana-data 2>/dev/null || true
docker compose up -d
```
