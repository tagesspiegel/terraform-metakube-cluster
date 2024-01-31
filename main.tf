// get the cluster version from the metakube API
data "metakube_k8s_version" "cluster" {
  major = var.k8s_version.major
  minor = var.k8s_version.minor
}

// define and create the cluster
resource "metakube_cluster" "this" {
  name       = var.cluster_name
  dc_name    = var.dc_name
  project_id = var.metakube_project_id

  spec {
    enable_ssh_agent = false
    version          = data.metakube_k8s_version.cluster.version
    cloud {
      openstack {
        application_credentials {
          id     = var.openstack_application_credential_id
          secret = var.openstack_application_credential_secret
        }
        network     = var.openstack_network_config.network_id != null && var.openstack_network_config.subnet_id != null ? var.openstack_network_config.network_id : null
        subnet_id   = var.openstack_network_config.network_id != null && var.openstack_network_config.subnet_id != null ? var.openstack_network_config.subnet_id : null
        subnet_cidr = (var.openstack_network_config.network_id == null && var.openstack_network_config.subnet_id == null) && var.openstack_network_config.cidr != null ? var.openstack_network_config.cidr : null
      }
    }
    // configure OIDC authentication
    syseleven_auth {
      realm = var.syseleven_auth_realm
    }
    dynamic "update_window" {
      for_each = var.cluster_update_window != null ? ["enabled"] : []
      content {
        start  = var.cluster_update_window.start
        length = var.cluster_update_window.length
      }
    }
    services_cidr = var.cidr_ranges.services_cidr
    pods_cidr     = var.cidr_ranges.pods_cidr
  }
}

resource "metakube_node_deployment" "this" {
  depends_on = [
    metakube_cluster.this
  ]

  for_each = var.node_pools

  name       = each.key
  cluster_id = metakube_cluster.this.id
  spec {
    min_replicas = each.value.replicas.min
    max_replicas = each.value.replicas.max
    template {
      versions {
        kubelet = data.metakube_k8s_version.cluster.version
      }
      labels = each.value.labels == null ? {} : each.value.labels
      operating_system {
        flatcar {
          disable_auto_update = !each.value.os_config.auto_update
        }
      }
      cloud {
        openstack {
          flavor          = each.value.node_config.flavor
          image           = each.value.os_config.image
          use_floating_ip = each.value.node_config.use_floating_ip
        }
      }
      dynamic "taints" {
        for_each = each.value.taints == null ? [] : each.value.taints

        content {
          key    = taints.value.key
          value  = taints.value.value
          effect = taints.value.effect
        }
      }
    }
  }

}

resource "metakube_cluster_role_binding" "this" {
  depends_on = [
    metakube_cluster.this
  ]

  for_each = var.cluster_rbac

  project_id = var.metakube_project_id
  cluster_id = metakube_cluster.this.id

  cluster_role_name = each.key

  dynamic "subject" {
    for_each = each.value

    content {
      kind = subject.value.kind
      name = subject.value.name
    }
  }
}

// define kubernetes configurations
locals {
  kube_config = yamldecode(metakube_cluster.this.kube_config)

  cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster["certificate-authority-data"])
  cluster_host           = local.kube_config.clusters[0].cluster.server
  cluster_username       = local.kube_config.users[0].name
  cluster_token          = local.kube_config.users[0].user.token
}

// initialize the Kubernetes provider
provider "kubernetes" {
  cluster_ca_certificate = local.cluster_ca_certificate
  host                   = local.cluster_host
  token                  = local.cluster_token
}

// create the ArgoCD daemon namespace the service account will be created in
resource "kubernetes_namespace" "argod" {
  depends_on = [
    metakube_cluster.this,
    metakube_node_deployment.this,
    metakube_cluster_role_binding.this,
  ]
  count = var.argocd_daemon_enabled ? 1 : 0
  metadata {
    name = var.argocd_daemon_name
  }
}

// create the ArgoCD daemon service account
resource "kubernetes_service_account_v1" "argod" {
  depends_on = [
    metakube_cluster.this,
    metakube_node_deployment.this,
    metakube_cluster_role_binding.this,
  ]
  count = var.argocd_daemon_enabled ? 1 : 0
  metadata {
    name      = "argo-daemon"
    namespace = kubernetes_namespace.argod[0].metadata[0].name
  }
}

// create the ArgoCD daemon service account token
resource "kubernetes_secret_v1" "argod" {
  depends_on = [
    kubernetes_service_account_v1.argod,
  ]
  count = var.argocd_daemon_enabled ? 1 : 0
  metadata {
    name      = var.argocd_daemon_name
    namespace = kubernetes_namespace.argod[0].metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.argod[0].metadata[0].name
    }
  }
  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

// create the ArgoCD daemon cluster role
resource "kubernetes_cluster_role_v1" "argod" {
  depends_on = [
    metakube_cluster.this,
    metakube_node_deployment.this,
    metakube_cluster_role_binding.this,
  ]
  count = var.argocd_daemon_enabled ? 1 : 0
  metadata {
    name = var.argocd_daemon_name
  }
  aggregation_rule {
    cluster_role_selectors {
      match_labels = {
        "rbac.tagesspiegel.cloud/permissions" = "argod"
      }
    }
  }
  // TODO(@urbanmedia/platform): we might want to restrict this in the future.
  // For now the service account has cluster-admin rights
  rule {
    resources  = ["*"]
    api_groups = ["*"]
    verbs      = ["*"]
  }
}

// create the ArgoCD daemon cluster role binding
resource "kubernetes_cluster_role_binding_v1" "argod" {
  depends_on = [
    kubernetes_cluster_role_v1.argod,
    kubernetes_service_account_v1.argod,
    kubernetes_namespace.argod,
  ]
  count = var.argocd_daemon_enabled ? 1 : 0
  metadata {
    name = var.argocd_daemon_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.argod[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    namespace = kubernetes_namespace.argod[0].metadata[0].name
    name      = kubernetes_service_account_v1.argod[0].metadata[0].name
  }
}

// receive the ArgoCD daemon service account token from the secret
data "kubernetes_secret_v1" "argod" {
  depends_on = [
    kubernetes_service_account_v1.argod,
    kubernetes_secret_v1.argod,
  ]
  count = var.argocd_daemon_enabled ? 1 : 0
  metadata {
    name      = kubernetes_secret_v1.argod[0].metadata[0].name
    namespace = kubernetes_namespace.argod[0].metadata[0].name
  }
}

// additional priority classes
locals {
  default_priority_classes = var.default_priority_classes_enabled ? {
    "ingress-critical"    = 100000000
    "monitoring-critical" = 99900000
    "logging-critical"    = 99800000
    "platform-critical"   = 99700000
  } : {}
}

resource "kubernetes_priority_class_v1" "this" {
  depends_on = [
    metakube_cluster.this,
  ]
  for_each = merge(local.default_priority_classes, var.additional_priority_classes)
  metadata {
    name = each.key
  }
  value = each.value
}
