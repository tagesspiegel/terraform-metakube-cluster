terraform {
  required_providers {
    metakube = {
      source  = "syseleven/metakube"
      version = "5.0.8"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
  }
}
