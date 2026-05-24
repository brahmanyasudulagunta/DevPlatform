# Platform-Infrastructure

The core infrastructure provisioning and security baseline tier of the platform. This repository provisions secure, isolated Kubernetes environments, configures resource limits, and sets up strict security networks via a self-service GitOps approach.

[![Jenkins](https://img.shields.io/badge/CI-Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white)](https://jenkins.io)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io)
[![Ansible](https://img.shields.io/badge/Config-Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)](https://ansible.com)
[![Kubernetes](https://img.shields.io/badge/Runtime-Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io)

---

## 3-Repo GitOps Architecture Role

This repository serves as the **infrastructure foundation layer** in our decoupled, three-tier GitOps model:

| Repository | Purpose | Primary Operator / Owner |
| :--- | :--- | :--- |
| **`Platform-Infrastructure`** (this) | Provisions namespaces, limits, RBAC, and network security policies. | Platform / DevOps Team |
| **`Application-Code`** | Contains the FastAPI, React, and PostgreSQL application source code. | Software Development Team |
| **`Gitops-Manifests`** | Stores environment-specific K8s manifests, watched by ArgoCD. | GitOps Deployment Engine |

```
Platform-Infrastructure creates namespaces  →  Gitops-Manifests deploys apps into them via ArgoCD
```

---

## How It Works (Namespace Self-Service)

```
Developer submits PR  →  Jenkins validates & applies  →  Namespace ready ✅
(requests/team.yaml)     (Terraform + RBAC + NetPol)     (secure & isolated)
```

Teams request an isolated environment by contributing a simple configuration file. Jenkins automatically processes the file and executes Terraform configurations to stand up the namespace.

---

## Supported Environments

Each namespace is provisioned with a secure, standard profile tailored to the environment:

| Environment | CPU Limit | Memory Limit | Pod Limit | Developer Access |
| :--- | :--- | :--- | :--- | :--- |
| **develop** | 4 cores | 8Gi | 20 | Full CRUD (Read/Write) |
| **production** | 8 cores | 16Gi | 30 | Read-Only |

*Every namespace automatically gets an isolated ResourceQuota, a LimitRange to set container defaults, standard RBAC bindings, and a default-deny NetworkPolicy.*

---

## Self-Service Namespace Request Workflow

**1.** A development team adds their configuration file in the `requests/` directory:

```yaml
# requests/my-team.yaml
kind: NamespaceRequest
metadata:
  name: my-team
spec:
  environment: develop
  owner: my-team
```

**2.** Open a Pull Request.  
**3.** Upon merge, Jenkins triggers the infrastructure pipeline to provision the namespace automatically.

---

## CI/CD Platform Pipeline (Jenkinsfile)

The automated Jenkins pipeline coordinates infrastructure updates and applies guardrails:

| Stage | Action |
| :--- | :--- |
| **Validate YAML** | Lints all YAML requests to guarantee structural compliance. |
| **Policy Guardrails** | Scans code to block destructive actions (e.g., manual deletions). |
| **Ansible Config** | Standardizes and configures the base target system packages. |
| **Terraform - Develop** | Auto-provisions and updates development namespaces. |
| **🔒 Approve Production** | Holds the pipeline for manual senior engineering sign-off. |
| **Terraform - Production**| Auto-provisions the production namespace once approved. |
| **Self-Service Requests** | Scans and creates newly requested team spaces dynamically. |
| **Apply RBAC + NetPol** | Hardens and isolates namespaces with RBAC roles and NetworkPolicies. |

---

## Security & Reliability Design

* **Zero Trust Network Isolation:** Default-deny policy rejects all ingress traffic from external namespaces, allowing only explicitly verified internal pods to communicate.
* **Resource Guardrails:** Hard resource quotas block cluster-wide resource exhaustion from runaway pods.
* **Strict Audit Trail:** Every single infrastructure creation, modification, or removal is registered as a Git commit history.

---

## Project Structure

```
Platform-Infrastructure/
├── terraform/
│   ├── modules/namespace/    # Reusable: namespace + quota + limits
│   ├── develop/main.tf       # Develop cluster specifications
│   └── production/main.tf    # Production cluster specifications
├── rbac/                     # RBAC roles & bindings (dev vs. prod)
├── network-policies/         # Default-deny + allow-internal network settings
├── scripts/                  # Ansible playbooks & self-service processing
├── requests/                 # Active namespace allocation requests
├── Jenkinsfile               # The platform CI orchestrator
└── README.md
```
