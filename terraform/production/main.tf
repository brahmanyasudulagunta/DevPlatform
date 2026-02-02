terraform {

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }
  }

  backend "local" {
    path = "terraform-production.tfstate"
  }
}

provider "kubernetes" {
  # Uses ~/.kube/config by default, or KUBECONFIG env var
}

module "production_namespace" {
  source = "../modules/namespace"
  name   = "production"
}
