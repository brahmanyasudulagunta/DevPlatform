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
  config_path = "/var/lib/jenkins/.kube/config"
}

module "production_namespace" {
  source = "../modules/namespace"
  name   = "production"
}
