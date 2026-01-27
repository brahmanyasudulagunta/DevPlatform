- alert: PodAvailabilityLow
  expr: |
    (
      sum(kube_pod_status_ready{namespace="develop",condition="true"})
      /
      sum(kube_pod_status_ready{namespace="develop"})
    ) < 0.99
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Pod availability below SLO in dev"
    description: "Availability dropped below 99% for 5 minutes"
