terraform {
  required_providers {
    metakube = {
      source  = "syseleven/metakube"
      version = "5.2.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.30.0"
    }
  }
}
