# DevPlatform

A CI-driven platform that provisions secure, isolated Kubernetes environments for developer teams through Git-based self-service.

[![Jenkins](https://img.shields.io/badge/CI-Jenkins-D24939?logo=jenkins&logoColor=white)](https://jenkins.io)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)](https://terraform.io)
[![Kubernetes](https://img.shields.io/badge/Runtime-Kubernetes-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io)

---

## What This Does

When a new team needs a Kubernetes namespace, they don't wait for an admin. They submit a request through Git → Jenkins validates and approves → Terraform provisions the namespace with RBAC, network policies, and resource quotas — ready to use in minutes.

```
Developer PR → Jenkins (validate/approve) → Terraform → Secure Namespace Ready
```

---

## Project Structure

```
DevPlatform/
├── terraform/
│   ├── modules/namespace/       # Reusable module (namespace + quota + limits)
│   ├── develop/main.tf          # Dev environment
│   ├── staging/main.tf          # Staging environment
│   └── production/main.tf       # Production environment
├── rbac/                        # Kubernetes RBAC policies
│   ├── developer.yaml           # Developer role (develop)
│   ├── staging-developer.yaml   # Developer role (staging)
│   ├── production-readonly.yaml # Read-only role (production)
│   ├── platform-admin.yaml      # Cluster admin
│   ├── jenkins-clusterrole.yaml # Jenkins service account
│   └── *-binding.yaml           # Role bindings
├── network-policies/            # Network isolation per namespace
│   ├── develop-default-deny.yaml
│   ├── develop-allow-internal.yaml
│   ├── staging-default-deny.yaml
│   └── production-default-deny.yaml
├── scripts/
│   ├── ansible/                 # System configuration
│   ├── process-namespace-requests.sh
│   └── validate-cluster.sh
├── docs/
├── Jenkinsfile                  # CI pipeline
└── README.md
```

---

## What Each Namespace Gets

Every namespace provisioned by this platform comes with:

| Resource | Purpose |
|----------|---------|
| **Namespace** | Isolated environment |
| **ResourceQuota** | CPU, memory, and pod limits |
| **LimitRange** | Default container resource limits |
| **RBAC Role + Binding** | Who can do what |
| **NetworkPolicy** | Default-deny, allow only internal traffic |
| **Labels** | `managed-by: devplatform` for tracking |

---

## Resource Limits

| Environment | CPU | Memory | Max Pods |
|-------------|-----|--------|----------|
| develop | 4 cores | 8Gi | 20 |
| staging | 4 cores | 8Gi | 15 |
| production | 8 cores | 16Gi | 30 |

---

## Jenkins Pipeline

The Jenkinsfile runs 11 stages in order:

| # | Stage | Purpose |
|---|-------|---------|
| 1 | Checkout | Pull latest code |
| 2 | Validate YAML | Lint all YAML files |
| 3 | Validate K8s Access | Confirm cluster connectivity |
| 4 | Policy Guardrails | Block destructive commands |
| 5 | Manual Approval | Human sign-off required |
| 6 | Ansible Configuration | Install required tools |
| 7 | Terraform - Develop | Provision dev namespaces + quotas |
| 8 | Terraform - Staging | Provision staging namespaces + quotas |
| 9 | Terraform - Production | Provision production namespaces + quotas |
| 10 | Self-Service Requests | Process new namespace requests |
| 11 | Apply RBAC | Apply role-based access control |
| 12 | Apply Network Policies | Apply network isolation rules |

---

## Self-Service Workflow

### Requesting a New Namespace

1. Create a request file:

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
4. On merge, Terraform provisions the namespace with quotas and limits

---

## RBAC Model

| Role | Scope | Access |
|------|-------|--------|
| `developer` | develop, staging | CRUD on pods, services, deployments |
| `readonly` | production | Read-only |
| `platform-admin` | cluster | Full admin |
| `jenkins-platform-role` | cluster | Create/Update (no delete) |

---

## Security

- **Default-deny** network policies on all namespaces
- **RBAC** with least-privilege per environment
- **Policy guardrails** block `kubectl delete` and `helm uninstall`
- **Manual approval** required before any infrastructure changes
- **Resource quotas** prevent resource exhaustion

---

## Toolchain

| Tool | Purpose |
|------|---------|
| Terraform | Infrastructure provisioning |
| Jenkins | CI pipeline with guardrails |
| Ansible | System configuration |
| Kubernetes | Container orchestration |

---

## Related Repositories

| Repo | Purpose |
|------|---------|
| `DevPlatform` (this) | Infrastructure provisioning |
| `gitops` | Application deployment (Argo CD) |
| `gitops-prod` | Production deployment (Argo CD) |
