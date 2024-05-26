terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "/home/gory/.kube/config"
}

# Terraform provisionne uniquement le cluster Kubernetes ici
# Les déploiements et services Kubernetes seront gérés par Ansible

output "kube_config" {
  value = file("/home/gory/.kube/config")
  sensitive = true
}
