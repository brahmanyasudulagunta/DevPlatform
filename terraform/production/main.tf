terraform {

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }
  }

  backend "local" {
    path = "terraform-produciton.tfstate"
  }
}

provider "kubernetes" {
  config_path = "/home/brahmanya/.kube/config"
}

module "production_namespace" {
  source = "../modules/namespace"
  name   = "production"
}
