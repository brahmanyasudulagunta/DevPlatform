
# Self-Service Platform Engineering & SRE Lab  
## Architecture Overview (Cloud-Free)


## 1. Purpose

This project implements a **cloud-free, production-grade Internal Developer Platform (IDP)** using Platform Engineering and SRE principles.

The platform enables:
- Git-based self-service requests
- Controlled automation through CI
- GitOps-based continuous delivery
- Secure, observable, and reproducible infrastructure
- Zero dependency on public cloud providers

---

## 2. Design Principles

The platform is built on the following principles:

- **Git as the Single Source of Truth**
- **Separation of Concerns**
- **Least Privilege & Strong Governance**
- **Automation with Guardrails**
- **Self-Healing & Observability by Default**
- **Cloud-Free & Cost-Free Operation**

---

## 3. High-Level Architecture

```

Developer
|
v
Git Repository (platform-engineering-lab)
|
v
Jenkins (CI / Validation / Approval)
|
v
Git (approved state)
|
v
Argo CD (GitOps Controller)
|
v
Kubernetes (k3s)
|
v
Applications & Platform Resources

```

---

## 4. Core Components

### 4.1 Git Repository

Git acts as the **control plane** of the platform.

Responsibilities:
- Platform configuration
- Environment definitions
- Infrastructure declarations
- Application manifests
- Self-service requests

No manual changes are allowed directly on the cluster.

---

### 4.2 Jenkins (CI Layer)

Jenkins is responsible for **controlled automation**, not deployment.

Responsibilities:
- Validate YAML and configuration files
- Enforce policies and guardrails
- Run Terraform and Ansible (future phases)
- Require manual approval for sensitive changes

Jenkins **does NOT deploy to Kubernetes**.

---

### 4.3 Argo CD (GitOps CD Layer)

Argo CD continuously reconciles Git state with the Kubernetes cluster.

Responsibilities:
- Watch Git repository
- Detect configuration drift
- Apply Kubernetes manifests
- Self-heal deleted or modified resources

Argo CD is the **only component allowed to modify Kubernetes resources**.

---

### 4.4 Kubernetes (Runtime Layer)

Kubernetes provides the execution environment.

Responsibilities:
- Run platform services
- Run application workloads
- Enforce namespace isolation
- Provide service discovery and networking

Environment separation is enforced using:
- Namespaces (`dev`, `staging`, `prod`)
- RBAC
- Resource boundaries

---

## 5. Environment Strategy

The platform supports multiple environments:

| Environment | Purpose |
|------------|--------|
| dev | Development & experimentation |
| staging | Pre-production validation |
| prod | Production workloads |

Each environment:
- Uses the same Git repository
- Has separate namespaces
- Can have independent policies and controls

---

## 6. Security Model

Security is built into the platform:

- RBAC for access control
- Namespace isolation
- Git-based approvals
- No secrets stored in Git (Vault planned)
- No direct cluster access for developers

---

## 7. Observability & SRE (Planned)

The platform will include:
- Prometheus for metrics
- Grafana for visualization
- Loki for logs
- Alerting based on SLIs/SLOs
- Failure testing and self-healing validation

---

## 8. Toolchain Summary

| Layer | Tool |
|----|----|
Infrastructure | Terraform (local backend) |
Configuration | Ansible |
CI | Jenkins |
CD | Argo CD |
Runtime | Kubernetes (k3s) |
Secrets | Vault |
Observability | Prometheus, Grafana, Loki |

---

## 9. What This Platform Is NOT

- Not a cloud-managed solution
- Not click-driven
- Not manually operated
- Not application-specific

This is a **platform**, not a single application.

---

## 10. Outcome

This platform demonstrates:
- Real-world Platform Engineering practices
- Enterprise-grade GitOps workflows
- SRE reliability concepts
- Zero cloud dependency
- Production-ready architecture

It closely mirrors how modern internal platforms are built in large organizations.

