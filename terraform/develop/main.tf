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
  # Uses ~/.kube/config by default, or KUBECONFIG env var
}

#################################
# EXISTING, FIXED NAMESPACES
#################################

module "develop_namespace" {
  source = "../modules/namespace"
  name   = "develop"
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
