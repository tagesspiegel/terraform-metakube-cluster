terraform {
  required_providers {
    metakube = {
      source  = "syseleven/metakube"
      version = "5.2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
  }
}
