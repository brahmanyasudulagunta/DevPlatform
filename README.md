# DevPlatform

A CI-driven platform that provisions secure, isolated Kubernetes environments for developer teams through Git-based self-service.

[![Jenkins](https://img.shields.io/badge/CI-Jenkins-D24939?logo=jenkins&logoColor=white)](https://jenkins.io)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)](https://terraform.io)
[![Ansible](https://img.shields.io/badge/Config-Ansible-EE0000?logo=ansible&logoColor=white)](https://ansible.com)
[![Kubernetes](https://img.shields.io/badge/Runtime-Kubernetes-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io)

---

## Role in the Platform

This is the **infrastructure layer** of a three-repo architecture:

| Repository | Role | Tools |
|------------|------|-------|
| **DevPlatform** (this) | Infrastructure provisioning & security | Terraform, Ansible, RBAC, NetworkPolicy |
| [gitops](https://github.com/brahmanyasudulagunta/gitops) | Application development & CI | Node.js, Docker, Jenkins |
| [gitops-prod](https://github.com/brahmanyasudulagunta/gitops-prod) | Deployment manifests (GitOps) | Kubernetes manifests, ArgoCD |

```
DevPlatform provisions the namespaces → gitops-prod deploys the app into them via ArgoCD
```

---

## What This Does

When a new team needs a Kubernetes namespace, they submit a request through Git → Jenkins validates and approves → Terraform provisions the namespace with RBAC, network policies, and resource quotas — ready to use in minutes.

```
Developer PR → Jenkins (validate/approve) → Terraform → Secure Namespace Ready
```

---

## Project Structure

```
DevPlatform/
├── terraform/
│   ├── modules/namespace/       # Reusable module (namespace + quota + limits)
│   ├── develop/main.tf          # Develop environment
│   ├── staging/main.tf          # Staging environment
│   └── production/main.tf       # Production environment
├── rbac/                        # Kubernetes RBAC policies
│   ├── developer.yaml           # Developer role (develop namespace)
│   ├── staging-developer.yaml   # Developer role (staging namespace)
│   ├── production-readonly.yaml # Read-only role (production namespace)
│   ├── platform-admin.yaml      # Cluster-wide admin
│   ├── jenkins-clusterrole.yaml # Jenkins service account role
│   └── *-binding.yaml           # Role bindings
├── network-policies/            # Network isolation per namespace
│   ├── develop-default-deny.yaml
│   ├── develop-allow-internal.yaml
│   ├── staging-default-deny.yaml
│   └── production-default-deny.yaml
├── scripts/
│   ├── ansible/                 # System configuration (base packages)
│   ├── process-namespace-requests.sh  # Self-service namespace provisioning
│   └── validate-cluster.sh      # Cluster health checks
├── requests/                    # Self-service namespace requests
│   └── team-alpha.yaml          # Example request
├── docs/                        # Documentation
├── Jenkinsfile                  # CI pipeline
└── README.md
```

---

## Environments

Each environment is provisioned as a Kubernetes namespace with resource quotas and limit ranges:

| Environment | Namespace | CPU Limit | Memory Limit | Max Pods |
|-------------|-----------|-----------|--------------|----------|
| Develop | `develop` | 4 cores | 8Gi | 20 |
| Staging | `staging` | 4 cores | 8Gi | 15 |
| Production | `production` | 8 cores | 16Gi | 30 |

Every namespace gets:

| Resource | Purpose |
|----------|---------|
| **Namespace** | Isolated environment |
| **ResourceQuota** | CPU, memory, and pod limits |
| **LimitRange** | Default container resource limits (500m CPU / 512Mi) |
| **RBAC Role + Binding** | Who can do what |
| **NetworkPolicy** | Default-deny, allow only internal traffic |
| **Labels** | `managed-by: devplatform` for tracking |

---

## Jenkins Pipeline

The Jenkinsfile runs these stages in order:

| # | Stage | Purpose |
|---|-------|---------|
| 1 | Checkout | Pull latest code |
| 2 | Validate YAML | Lint all YAML files with yamllint |
| 3 | Validate K8s Access | Confirm cluster connectivity |
| 4 | Policy Guardrails | Block destructive commands (`kubectl delete`, `helm uninstall`) |
| 5 | Ansible Configuration | Install base system packages |
| 6 | Terraform - Develop | Provision develop namespace + quotas (auto-apply) |
| 7 | Terraform - Staging | Provision staging namespace + quotas (auto-apply) |
| 8 | Approve Production | Manual approval gate |
| 9 | Terraform - Production | Provision production namespace + quotas (after approval) |
| 10 | Self-Service Requests | Process new namespace requests from `requests/` |
| 11 | Apply RBAC | Apply role-based access control policies |
| 12 | Apply Network Policies | Apply network isolation rules |

---

## Self-Service Workflow

### Requesting a New Namespace

1. Create a request file in `requests/`:

```yaml
# requests/my-team.yaml
kind: NamespaceRequest
metadata:
  name: my-team
spec:
  environment: develop
  owner: my-team
```

2. Submit a pull request
3. Jenkins validates and requests approval
4. On merge, Terraform provisions the namespace with quotas and limits

---

## RBAC Model

| Role | Namespace Scope | Access Level |
|------|-----------------|--------------|
| `developer` | develop | CRUD on pods, services, deployments |
| `staging-developer` | staging | CRUD on pods, services, deployments |
| `production-readonly` | production | Read-only |
| `platform-admin` | cluster-wide | Full admin |
| `jenkins-platform-role` | cluster-wide | Create/Update (no delete) |

---

## Security

- **Default-deny** network policies on all namespaces
- **RBAC** with least-privilege access per environment
- **Policy guardrails** block destructive commands in CI
- **Manual approval** required before production infrastructure changes
- **Resource quotas** prevent resource exhaustion
- **No delete verbs** for Jenkins service account
