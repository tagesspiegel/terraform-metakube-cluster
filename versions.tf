terraform {
  required_providers {
    metakube = {
      source  = "syseleven/metakube"
      version = "5.2.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.26.0"
    }
  }
}
