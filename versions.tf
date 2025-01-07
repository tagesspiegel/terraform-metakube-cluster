terraform {
  required_providers {
    metakube = {
      source  = "syseleven/metakube"
      version = "5.4.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.33.0"
    }
  }
}
