# D10 - Monitoring (Prometheus + Grafana)

## What is Monitoring?
Monitoring is the practice of continuously collecting and observing metrics from servers and services so you know the health of your infrastructure at all time. Prometheus collects and stores metrics, evaluates alert rules, and fires alerts when something goes wrong. Grafana reads from Prometheus and displays everything visually as dashboards. Together they form the standard open-source monitoring stack used across the industry.

---

## Why Monitoring?
- Visibility - know exactly what your servers are doing at any point in time
- Alerting - get notified the moment something breaks, not 30 minutes later when a user complains
- Troubleshooting - historical metrics help you trace exactly when and why something went wrong
- Standard DevOps tool - Prometheus + Grafana is widely used in Europe/Denamrk job listings alongside Kubernetes and Terraform

---

## Key Concepts

| Term | Meaning |
|---|---|
| Prometheus | Collects and stores time-series metrics, evaluates alert rules |
| Node Exporter | Agent installed on a server that exposes system metrics (CPU, memory, disk, network) to Prometheus |
| Grafana | Visualisation tool — reads from Prometheus and displays metrics as graphs and dashboards |
| Alertmanager | Receives fired alerts from Prometheus and routes them to Slack, email, PagerDuty, etc. |
| PromQL | Prometheus Query Language — used to query metrics and write alert rule expressions |
| Scraping | How Prometheus collects metrics — it pulls data from targets on a regular interval |
| `up` metric | Built-in Prometheus metric — 1 means target is reachable, 0 means target is down |
| Alert Rule | A PromQL condition that Prometheus evaluates — when true for a set duration, the alert fires |
| `for: 1m` | Alert must stay true for 1 minute before firing — prevents false alarms from brief spikes |
| Inactive | Alert condition is not met — everything is healthy |
| Pending | Alert condition is met — waiting out the `for:` duration |
| Firing | Condition held past the duration — alert is active |
| Resolved | Target recovered — alert cleared automatically |

---

## Core Commands

```bash
# Check service status
systemctl status prometheus
systemctl status node_exporter
systemctl status grafana-server

# Restart Prometheus after config changes
sudo systemctl restart prometheus

## Check loaded alert rules
curl http://localhost:9090/api/v1/rules

## Check currently firing alerts
curl http://localhost:9090/api/v1/alerts

## Stop/start Node Exporter (Used to trigger alert in lab)
sudo systemctl stop node_exporter
sudo systemctl start node_exporter
```

---

## Alert Rule Structure

```yaml
groups:
  - name: basic_alerts
    rules:
      - alert: InstanceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Instance is down"
          description: "A monitored target has been unreachable for more than 1 minute."
```

- `expr` - the PromQL condition Prometheus evaluates
- `for:1m` - must stay true for 1 minute before firing 
- `labels` - metadata attached to the alert, used by Alertmanager for routing
- `annotations` - human-readable description shown in the alert UI and notifications

---

## How Production Alerting Works

```
Prometheus detects condition → fires alert → Alertmanager receives it
        ↓
Alertmanager routes to Slack / Email / PagerDuty
        ↓
Engineer gets notified in #alerts channel and investigates
```

Alertmanager config points to a Slack webhook URL. When an alert fires, Alertmanager sends a formatted message to the configured channel automatically - no one needs to manualy check the Prometheus UI.

---

## Lab Summary

### Lab 1 - Install Prometheus & Node Exporter
- Download and installed Prometheus and Node Exporter binaries
- Created dedicated system users and directories for each service
- Configured both as systemd services so they start automatically on boot
- Verified both running with `systemctl status`

### Lab 2 - Explore Prometheus UI & PromQL Basics
- Accessed Prometheus UI at `localhost:9090`
- Ran basic PromQL queries to explore available metrics
- Understood how Prometheus scrapes targets and stores time-series data

### Lab 3 - Install & Configure Grafana
- Installed Grafana and started it as a systemd service
- Accessed Grafana UI at `localhost:3000`
- Added Prometheus as a data source via Grafana API using curl

# Lab 4 - Import a Pre-built Dashboard
- Downloaded Node Exporter Full dashboard (ID: 1860) from Grafana community library
- Imported it via a Python script using the Grafana API (curl argument too long for direct import)
- Viewed real-time CPU, memory, disk, and network metrics populated on the dashboard

### Lab 5 - Create a Simple Alert Rule
- Created `/etc/prometheus/alert_rules.yml` with an `InstanceDown` rule
- Registered the file in `prometheus.yml` under `rule_files`
- Restarted Prometheus and verified rule loaded via API
- Trigged alert by stopping Node Exporter - watched state go `inactive` -> `pending` -> `firing` 
- Started Node Exporter back up - alert resolved automatically

---

## Files Modified

| File | Purpose |
|---|---|
| `/etc/prometheus/prometheus.yml` | Main Prometheus config — added `rule_files` entry |
| `/etc/prometheus/alert_rules.yml` | Alert rule definition — created in Lab 5 |

---

## Result

```
InstanceDown alert fired successfully:

{
  "alertname": "InstanceDown",
  "instance": "localhost:9100",
  "job": "node_exporter",
  "severity": "critical",
  "state": "firing"
}

Alert resolved automatically when Node Exporter was restarted.
```

---

## Troubleshooting 

- **Dashboard import via curl failed** - `{"message":"Dashboard must be set"}`. The URL-based import method did not work. Fix - downloaded the dashboard JSON first with `wget`, then imported it using a Python script via the Grafana API. Worked successfully.
- **curl argument too long** - the downloaded dashboard JSON (667KB) was too large to pass as a direct command line argument. Fix - used python `urllib` to read the file and POST it to the Grafana API instead. 

---

## Skills Gained

- Understanding the Prometheus + Grafana monitoring stack how the components work together. 
- Installing and configuring Prometheus, Node Exporter, and Grafana as sytsemd services on Ubuntu
- Writing PromQL queries to explore and filter metrics
- Adding a Prometheus data source to Grafana via API
- importing community dashboards and reading real-time server metrics visually
- Writing Prometheus alert rules in YAML using PromQL expressions
- Understanding the full alert lifecycle - Inactive -> Pending -> Firing -> Resolved
- Triggering and verifying alerts manually by stopping and starting services
- Understanding how Alertmanager routes fired alerts to Slack and other notification channels

---

## Environment Used

| Component | Detail |
|---|---|
| Host Machine | Kali Linux |
| Monitoring Node | Ubuntu 24.04 VM on VirtualBox (CLI only) |
| Prometheus Version | 2.x |
| Grafana Version | 10.x |
| Node Exporter | 1.x |
| Dashboard | Node Exporter Full (ID: 1860) |
