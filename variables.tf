variable "k8s_version" {
  description = "Version of the created K8s Cluster (see available version in Metakube)"
  type = object({
    major = number
    minor = number
    patch = optional(number)
  })
  default = {
    major = 1
    minor = 28
  }
}

variable "cluster_name" {
  description = "Name of the created cluster (must be unique per Metakube project)"
  type        = string
}

variable "dc_name" {
  description = "Datacenter name at SysEleven (DBl, ...)"
  type        = string
  default     = "syseleven-dbl1"
}

variable "metakube_project_id" {
  description = "The ID of the metakube project"
  type        = string
  sensitive   = true
}

variable "openstack_application_credential_id" {
  description = "The OpenStack application credential ID to use for the metakube cluster"
  type        = string
  sensitive   = true
}

variable "openstack_application_credential_secret" {
  description = "The OpenStack application credential to use for the metakube cluster"
  type        = string
  sensitive   = true
}

variable "openstack_network_config" {
  type = object({
    network_name = optional(string)
    subnet_id    = optional(string)
    subnet_cidr  = optional(string)
  })
  nullable    = true
  description = "The network configuration for the metakube cluster. Either network_name or subnet_id or subnet_cidr must be set."
  validation {
    condition     = ((var.openstack_network_config.network_name == null && var.openstack_network_config.subnet_id == null) && var.openstack_network_config.subnet_cidr != null) || ((var.openstack_network_config.network_name != null && var.openstack_network_config.subnet_id != null) && var.openstack_network_config.subnet_cidr == null)
    error_message = "Either network_name and subnet_id or subnet_cidr must be set."
  }
  validation {
    condition     = var.openstack_network_config.subnet_cidr != null ? can(regex("^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4}/([1|2]+\\d|8|9)$", var.openstack_network_config.subnet_cidr)) : true
    error_message = "No valid IP range in CIDR given in field openstack_network_config.subnet_cidr"
  }
}

variable "syseleven_auth_realm" {
  type        = string
  description = "The realm to use for the syseleven auth"
}

variable "cluster_update_window" {
  type = object({
    start  = string
    length = string
  })
  description = "The update window for the cluster. If set to null, no update window will be set."
  default     = null
}

variable "cidr_ranges" {
  description = "All different CIDR ranges for the different needed IP ranges for a cluster"
  type = object({
    services_cidr = string
    pods_cidr     = string
  })
  validation {
    condition     = can(regex("^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4}/([1|2]+\\d|8|9)$", var.cidr_ranges.services_cidr))
    error_message = "No valid IP range in CIDR given in field cidr_ranges.services_cidr"
  }
  validation {
    condition     = can(regex("^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4}/([1|2]+\\d|8|9)$", var.cidr_ranges.pods_cidr))
    error_message = "No valid IP range in CIDR given in field cidr_ranges.pods_cidr"
  }
  default = {
    services_cidr = "10.240.0.0/16"
    pods_cidr     = "10.0.0.0/16"
  }
}

variable "node_pools" {
  description = "List all node pools that should be created in the cluster"
  type = map(object({
    replicas = object({
      min = number
      max = number
    })
    labels = optional(map(string))
    os_config = object({
      image       = string
      auto_update = bool
    })
    node_config = object({
      flavor          = string
      use_floating_ip = bool
    })
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))
  }))
}

variable "cluster_rbac" {
  type = map(list(object({
    kind = string
    name = string
  })))
  description = "The RBAC configuration for the cluster. The key is the name of the cluster role and the value is a list of subjects."
}

variable "argocd_daemon_enabled" {
  description = "Create a dedicated ArgoCD daemon namespace and service account for the cluster."
  type        = bool
  default     = false
}

variable "argocd_daemon_name" {
  description = "Name of the ArgoCD daemon namespace."
  type        = string
  default     = "argo-daemon"
}

variable "default_priority_classes_enabled" {
  type        = bool
  description = "Enable the creation of the default priority classes. If set to false, the default priority classes will not be created. Default priority classes are: ingress-critical (100000000), monitoring-critical (99900000), logging-critical (99800000), platform-critical (99700000)"
  default     = true
}

variable "additional_priority_classes" {
  type        = map(number)
  description = "Additional priority classes to create. In form name -> value"
  default     = {}
}
