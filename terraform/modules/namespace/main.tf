resource "kubernetes_namespace" "this" {
  metadata {
    name = var.name

    labels = {
      "managed-by" = "devplatform"
      "environment" = var.name
    }
  }
}

resource "kubernetes_resource_quota" "this" {
  metadata {
    name      = "${var.name}-quota"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    hard = {
      "limits.cpu"    = var.cpu_limit
      "limits.memory" = var.memory_limit
      pods            = var.max_pods
    }
  }
}

resource "kubernetes_limit_range" "this" {
  metadata {
    name      = "${var.name}-limits"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    limit {
      type = "Container"

      default = {
        cpu    = "500m"
        memory = "512Mi"
      }

      default_request = {
        cpu    = "100m"
        memory = "128Mi"
      }
    }
  }
}
