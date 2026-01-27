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
  config_path = "/home/brahmanya/.kube/config"
}

module "develop_namespace" {
  source = "../modules/namespace"
  name   = var.name
}

 module "test_namespace" {
  source = "../modules/namespace"
  name   = "test-jenkins"
}

variable "name" {
  description = "Namespace name from self-service request"
  type        = string
}
