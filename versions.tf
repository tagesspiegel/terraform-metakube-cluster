terraform {
  required_providers {
    metakube = {
      source  = "syseleven/metakube"
      version = "5.3.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
  }
}
