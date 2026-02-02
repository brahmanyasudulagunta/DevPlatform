# DevPlatform

A cloud-free Internal Developer Platform (IDP) implementing GitOps, self-service infrastructure, and SRE best practices.

[![Jenkins](https://img.shields.io/badge/CI-Jenkins-D24939?logo=jenkins&logoColor=white)](https://jenkins.io)
[![Argo CD](https://img.shields.io/badge/CD-Argo%20CD-EF7B4D?logo=argo&logoColor=white)](https://argoproj.github.io/cd/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)](https://terraform.io)
[![Kubernetes](https://img.shields.io/badge/Runtime-Kubernetes-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io)

---

## Overview

DevPlatform enables developer self-service through Git-based workflows. Developers request resources via pull requests, changes are validated and approved through CI, and infrastructure is provisioned automatically—all without direct cluster access.

```
Developer → Git PR → Jenkins (validate/approve) → Terraform → Argo CD → Kubernetes
```

---

## Features

| Feature | Description |
|---------|-------------|
| **Self-Service Namespaces** | Request namespaces via YAML—no tickets, no waiting |
| **GitOps Deployment** | Argo CD auto-syncs with self-healing enabled |
| **Policy Guardrails** | Blocks destructive operations (`kubectl delete`, `helm uninstall`) |
| **Multi-Environment** | Isolated `develop`, `staging`, and `production` environments |
| **Zero-Trust Networking** | Default-deny network policies per namespace |
| **RBAC Enforcement** | Role-based access with least-privilege principles |

---

## Project Structure

```
DevPlatform/
├── clusters/                    # Environment-specific configurations
│   ├── develop/
│   │   ├── platform-app.yaml    # Argo CD Application
│   │   ├── network-policy.yaml  # Default-deny policy
│   │   ├── intra-namespace.yaml # Allow internal pod traffic
│   │   └── requests/            # Self-service namespace requests
│   ├── staging/
│   └── production/
├── terraform/
│   ├── modules/namespace/       # Reusable namespace module
│   ├── develop/                 # Dev environment state
│   ├── staging/
│   └── production/
├── rbac/                        # Kubernetes RBAC policies
│   ├── developer.yaml           # Developer role (develop namespace)
│   ├── platform-admin.yaml      # Cluster admin binding
│   ├── jenkins-clusterrole.yaml # Jenkins service account
│   └── production-readonly.yaml # Read-only prod access
├── namespaces/                  # Namespace definitions
├── scripts/
│   ├── ansible/                 # Configuration management
│   └── process-namespace-requests.sh
├── bootstrap/                   # Initial cluster resources
├── docs/                        # Documentation
└── Jenkinsfile                  # CI pipeline definition
```

---

## Quick Start

### Prerequisites

- Kubernetes cluster (k3s/Kind/minikube)
- Jenkins with kubectl access
- Argo CD installed
- Terraform ≥ 1.0
- Tools: `yq`, `yamllint`

### 1. Bootstrap the Platform

```bash
# Apply base resources
kubectl apply -f bootstrap/base-resources.yaml

# Apply RBAC policies
kubectl apply -f rbac/

# Apply namespace definitions
kubectl apply -f namespaces/
```

### 2. Deploy Argo CD Applications

```bash
# Deploy for each environment
kubectl apply -f clusters/develop/platform-app.yaml
kubectl apply -f clusters/staging/platform-app.yaml
kubectl apply -f clusters/production/platform-app.yaml
```

### 3. Initialize Terraform

```bash
cd terraform/develop
terraform init
terraform apply
```

---

## Self-Service Workflow

### Requesting a New Namespace

1. Create a request file in `clusters/develop/requests/`:

```yaml
# clusters/develop/requests/my-team-namespace.yaml
kind: NamespaceRequest
metadata:
  name: my-team
spec:
  environment: develop
  owner: my-team
```

2. Submit a pull request
3. Jenkins validates and requests approval
4. On merge, Terraform provisions the namespace automatically

---

## CI/CD Pipeline

### Jenkins Stages

| Stage | Purpose |
|-------|---------|
| **Validate YAML** | Lints all YAML files with `yamllint` |
| **Validate K8s Access** | Confirms cluster connectivity |
| **Policy Guardrails** | Blocks destructive commands |
| **Manual Approval** | Requires human sign-off |
| **Ansible Config** | Runs configuration playbooks |
| **Process Requests** | Provisions self-service namespaces |

### GitOps with Argo CD

Argo CD continuously reconciles the cluster state with Git:

- **Auto-sync**: Changes in Git are automatically applied
- **Self-heal**: Manual drift is automatically corrected
- **Prune**: Removed resources are cleaned up

---

## Security

### Network Policies

Each namespace enforces network isolation:

```yaml
# Default: deny all traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes: [Ingress, Egress]
```

### RBAC Roles

| Role | Scope | Access Level |
|------|-------|--------------|
| `developer` | develop | CRUD on pods, services, deployments |
| `platform-admin` | cluster | Full admin access |
| `jenkins-platform-role` | cluster | Create/Update (no delete) |
| `production-readonly` | prod | Read-only |

### CI Guardrails

The pipeline blocks dangerous patterns:
- `kubectl delete` commands
- `helm uninstall` commands

---

## Environments

| Environment | Namespace | Purpose |
|-------------|-----------|---------|
| Development | `develop` | Feature development, experimentation |
| Staging | `staging` | Pre-production validation |
| Production | `prod` | Live workloads |

Each environment has:
- Isolated Argo CD Application
- Independent Terraform state
- Separate network policies
- Environment-specific RBAC

---

## Toolchain

| Layer | Tool | Purpose |
|-------|------|---------|
| CI | Jenkins | Validation, approvals, automation |
| CD | Argo CD | GitOps continuous delivery |
| IaC | Terraform | Infrastructure provisioning |
| Config | Ansible | System configuration |
| Runtime | Kubernetes | Container orchestration |

---

## Roadmap

- [ ] Prometheus + Grafana observability stack
- [ ] HashiCorp Vault for secrets management
- [ ] Loki for centralized logging
- [ ] SLI/SLO-based alerting
- [ ] Cost tracking and resource quotas

---

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request
4. Wait for CI validation and approval

All changes must pass through the Jenkins pipeline—no direct cluster modifications.

---

## License

This project is for educational and demonstration purposes.
