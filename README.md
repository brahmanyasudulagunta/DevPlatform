# DevPlatform

A self-service infrastructure platform that provisions secure Kubernetes namespaces through Git — powered by Terraform, Jenkins, and GitOps.

[![Jenkins](https://img.shields.io/badge/CI-Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white)](https://jenkins.io)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io)
[![Ansible](https://img.shields.io/badge/Config-Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)](https://ansible.com)
[![Kubernetes](https://img.shields.io/badge/Runtime-Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)](https://argoproj.github.io/cd/)

---

## How It Works

```
Developer submits PR  →  Jenkins validates & applies  →  Namespace ready ✅
(requests/team.yaml)     (Terraform + RBAC + NetPol)     (secure & isolated)
```

Teams request a namespace by adding a YAML file and opening a PR. Jenkins runs Terraform to provision the namespace with **resource quotas, RBAC, and network policies** — automatically.

---

## Architecture (3-Repo GitOps)

| Repository | Purpose |
|------------|---------|
| **DevPlatform** (this) | Infrastructure — namespaces, RBAC, network policies |
| [gitops](https://github.com/brahmanyasudulagunta/gitops) | App source code, Docker, CI |
| [gitops-prod](https://github.com/brahmanyasudulagunta/gitops-prod) | K8s manifests, ArgoCD deployments |

```
DevPlatform creates infra  →  gitops-prod deploys apps into it via ArgoCD
```

---

## Environments

| Environment | CPU | Memory | Pods | Developer Access |
|-------------|-----|--------|------|-----------------|
| develop | 4 cores | 8Gi | 20 | Full CRUD |
| production | 8 cores | 16Gi | 30 | Read-only |

Each namespace automatically gets: ResourceQuota, LimitRange, RBAC, and NetworkPolicy.

---

## Self-Service: Request a Namespace

**1.** Add a request file:

```yaml
# requests/my-team.yaml
kind: NamespaceRequest
metadata:
  name: my-team
spec:
  environment: develop
  owner: my-team
```

**2.** Open a PR → **3.** On merge, Jenkins provisions it via Terraform.

---

## CI Pipeline (Jenkinsfile)

| Stage | What It Does |
|-------|-------------|
| Validate YAML | Lints all YAML files |
| Policy Guardrails | Blocks destructive commands |
| Ansible Config | Installs base system packages |
| Terraform - Develop | Auto-provisions develop namespace |
| 🔒 Approve Production | Manual approval gate |
| Terraform - Production | Provisions production (after approval) |
| Self-Service Requests | Creates namespaces from `requests/` |
| Apply RBAC + NetPol | Applies security policies |

---

## Security

- **RBAC** — Least-privilege per environment (full in dev, read-only in prod)
- **NetworkPolicy** — Default-deny, allow only intra-namespace traffic
- **ResourceQuota** — Prevents resource exhaustion
- **Policy Guardrails** — CI blocks destructive commands
- **Approval Gate** — Production changes require manual approval
- **Git Audit Trail** — Every change is a commit

---

## Project Structure

```
DevPlatform/
├── terraform/
│   ├── modules/namespace/    # Reusable: namespace + quota + limits
│   ├── develop/main.tf
│   └── production/main.tf
├── rbac/                     # RBAC roles & bindings
├── network-policies/         # Default-deny + allow-internal
├── scripts/                  # Ansible, namespace provisioning, validation
├── requests/                 # Self-service namespace requests
├── Jenkinsfile               # CI pipeline
└── README.md
```

---

## Roadmap

- [x] Multi-environment Terraform provisioning
- [x] RBAC + NetworkPolicy + ResourceQuotas
- [x] CI pipeline with guardrails & approval gates
- [x] Self-service namespace requests via Git
- [ ] Frontend portal for namespace creation & app health
- [ ] Backend API (GitOps engine)
- [ ] ArgoCD self-healing & drift detection
