terraform {
  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }
  }

  backend "local" {
    path = "terraform-dev.tfstate"
  }
}

provider "kubernetes" {
  config_path = "/home/brahmanya/.kube/config"
}

module "dev_namespace" {
  source = "../modules/namespace"
  name   = "develop"
}

module "test_namespace" {
  source = "../modules/namespace"
  name   = "test-jenkins"
}
