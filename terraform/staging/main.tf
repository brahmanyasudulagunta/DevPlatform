terraform {
  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }
  }

  backend "local" {
    path = "terraform-staging.tfstate"
  }
}

provider "kubernetes" {
  config_path = "/home/brahmanya/.kube/config"  
}

module "staging_namespace" {
  source = "../modules/namespace"
  name   = "staging"
}
