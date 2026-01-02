terraform {

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }
  }

  backend "local" {
    path = "terraform-prod.tfstate"
  }
}

provider "kubernetes" {
  config_path = "/home/brahmanya/.kube/config"
}

module "prod_namespace" {
  source = "../modules/namespace"
  name   = "production"
}
