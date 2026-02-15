terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }
  }

  backend "local" {
    path = "terraform-develop.tfstate"
  }
}

provider "kubernetes" {
  config_path = "/var/lib/jenkins/.kube/config"
}

#################################
# EXISTING, FIXED NAMESPACES
#################################

module "develop_namespace" {
  source       = "../modules/namespace"
  name         = "develop"
  cpu_limit    = "4"
  memory_limit = "8Gi"
  max_pods     = 20
}

module "test_namespace" {
  source = "../modules/namespace"
  name   = "test-jenkins"
}

#################################
# SELF-SERVICE NAMESPACES (ADD-ONLY)
#################################

variable "requested_namespaces" {
  description = "Namespaces requested via self-service"
  type        = set(string)
  default     = []
}

module "requested_namespaces" {
  for_each = var.requested_namespaces
  source   = "../modules/namespace"
  name     = each.value
}
