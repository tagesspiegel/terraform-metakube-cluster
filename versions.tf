terraform {
  required_providers {
    metakube = {
      source  = "syseleven/metakube"
      version = "5.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
  }
}
