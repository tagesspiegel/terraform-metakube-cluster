terraform {
  required_providers {
    metakube = {
      source  = "syseleven/metakube"
      version = "5.0.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
  }
}
