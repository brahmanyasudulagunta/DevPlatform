# Monitoring & Observability

This platform relies on a **shared `monitoring` namespace**
that provides:

- Prometheus
- Alertmanager
- Node Exporter
- kube-state-metrics
- Loki + Promtail

This repository does NOT install observability components.
It only defines:
- SLIs
- SLOs
- Alerting logic
- Reliability practices
