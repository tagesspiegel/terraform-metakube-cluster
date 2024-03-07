# Terraform Metakube Cluster

This module creates a Kubernetes cluster on [Metakube](https://metakube.syseleven.de/). It uses the [metakube-provider](https://registry.terraform.io/providers/syseleven/metakube/latest/docs) to create the cluster.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.25.0 |
| <a name="requirement_metakube"></a> [metakube](#requirement\_metakube) | 5.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.25.0 |
| <a name="provider_metakube"></a> [metakube](#provider\_metakube) | 5.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_cluster_role_binding_v1.argod](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.0/docs/resources/cluster_role_binding_v1) | resource |
| [kubernetes_cluster_role_v1.argod](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.0/docs/resources/cluster_role_v1) | resource |
| [kubernetes_namespace.argod](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.0/docs/resources/namespace) | resource |
| [kubernetes_priority_class_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.0/docs/resources/priority_class_v1) | resource |
| [kubernetes_secret_v1.argod](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.0/docs/resources/secret_v1) | resource |
| [kubernetes_service_account_v1.argod](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.0/docs/resources/service_account_v1) | resource |
| [metakube_cluster.this](https://registry.terraform.io/providers/syseleven/metakube/5.2.1/docs/resources/cluster) | resource |
| [metakube_cluster_role_binding.this](https://registry.terraform.io/providers/syseleven/metakube/5.2.1/docs/resources/cluster_role_binding) | resource |
| [metakube_node_deployment.this](https://registry.terraform.io/providers/syseleven/metakube/5.2.1/docs/resources/node_deployment) | resource |
| [kubernetes_secret_v1.argod](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.0/docs/data-sources/secret_v1) | data source |
| [metakube_k8s_version.cluster](https://registry.terraform.io/providers/syseleven/metakube/5.2.1/docs/data-sources/k8s_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_priority_classes"></a> [additional\_priority\_classes](#input\_additional\_priority\_classes) | Additional priority classes to create. In form name -> value | `map(number)` | `{}` | no |
| <a name="input_argocd_daemon_enabled"></a> [argocd\_daemon\_enabled](#input\_argocd\_daemon\_enabled) | Create a dedicated ArgoCD daemon namespace and service account for the cluster. | `bool` | `false` | no |
| <a name="input_argocd_daemon_name"></a> [argocd\_daemon\_name](#input\_argocd\_daemon\_name) | Name of the ArgoCD daemon namespace. | `string` | `"argo-daemon"` | no |
| <a name="input_cidr_ranges"></a> [cidr\_ranges](#input\_cidr\_ranges) | All different CIDR ranges for the different needed IP ranges for a cluster | <pre>object({<br>    services_cidr = string<br>    pods_cidr     = string<br>  })</pre> | <pre>{<br>  "pods_cidr": "10.0.0.0/16",<br>  "services_cidr": "10.240.0.0/16"<br>}</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the created cluster (must be unique per Metakube project) | `string` | n/a | yes |
| <a name="input_cluster_rbac"></a> [cluster\_rbac](#input\_cluster\_rbac) | The RBAC configuration for the cluster. The key is the name of the cluster role and the value is a list of subjects. | <pre>map(list(object({<br>    kind = string<br>    name = string<br>  })))</pre> | n/a | yes |
| <a name="input_cluster_update_window"></a> [cluster\_update\_window](#input\_cluster\_update\_window) | The update window for the cluster. If set to null, no update window will be set. | <pre>object({<br>    start  = string<br>    length = string<br>  })</pre> | `null` | no |
| <a name="input_dc_name"></a> [dc\_name](#input\_dc\_name) | Datacenter name at SysEleven (DBl, ...) | `string` | `"syseleven-dbl1"` | no |
| <a name="input_default_priority_classes_enabled"></a> [default\_priority\_classes\_enabled](#input\_default\_priority\_classes\_enabled) | Enable the creation of the default priority classes. If set to false, the default priority classes will not be created. Default priority classes are: ingress-critical (100000000), monitoring-critical (99900000), logging-critical (99800000), platform-critical (99700000) | `bool` | `true` | no |
| <a name="input_k8s_version"></a> [k8s\_version](#input\_k8s\_version) | Version of the created K8s Cluster (see available version in Metakube) | <pre>object({<br>    major = number<br>    minor = number<br>    patch = optional(number)<br>  })</pre> | <pre>{<br>  "major": 1,<br>  "minor": 28<br>}</pre> | no |
| <a name="input_metakube_project_id"></a> [metakube\_project\_id](#input\_metakube\_project\_id) | The ID of the metakube project | `string` | n/a | yes |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | List all node pools that should be created in the cluster | <pre>map(object({<br>    replicas = object({<br>      min = number<br>      max = number<br>    })<br>    labels = optional(map(string))<br>    os_config = object({<br>      image       = string<br>      auto_update = bool<br>    })<br>    node_config = object({<br>      flavor          = string<br>      use_floating_ip = bool<br>    })<br>    taints = optional(list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_openstack_application_credential_id"></a> [openstack\_application\_credential\_id](#input\_openstack\_application\_credential\_id) | The OpenStack application credential ID to use for the metakube cluster | `string` | n/a | yes |
| <a name="input_openstack_application_credential_secret"></a> [openstack\_application\_credential\_secret](#input\_openstack\_application\_credential\_secret) | The OpenStack application credential to use for the metakube cluster | `string` | n/a | yes |
| <a name="input_openstack_network_config"></a> [openstack\_network\_config](#input\_openstack\_network\_config) | The network configuration for the metakube cluster. Either network\_name or subnet\_id or subnet\_cidr must be set. | <pre>object({<br>    network_name = optional(string)<br>    subnet_id    = optional(string)<br>    subnet_cidr  = optional(string)<br>  })</pre> | n/a | yes |
| <a name="input_syseleven_auth_realm"></a> [syseleven\_auth\_realm](#input\_syseleven\_auth\_realm) | The realm to use for the syseleven auth | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argo_daemon_service_account_token"></a> [argo\_daemon\_service\_account\_token](#output\_argo\_daemon\_service\_account\_token) | The ArgoCD daemon service account token |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | The kubeconfig for the metakube cluster (admin config). |
| <a name="output_kube_config_ca_certificate"></a> [kube\_config\_ca\_certificate](#output\_kube\_config\_ca\_certificate) | The Kubernetes cluster CA data |
| <a name="output_kube_config_host"></a> [kube\_config\_host](#output\_kube\_config\_host) | The Kubernetes cluster server address |
| <a name="output_kube_config_token"></a> [kube\_config\_token](#output\_kube\_config\_token) | The Kubernetes cluster user token |
| <a name="output_kube_config_username"></a> [kube\_config\_username](#output\_kube\_config\_username) | The Kubernetes cluster user name |
| <a name="output_metakube_cluster_id"></a> [metakube\_cluster\_id](#output\_metakube\_cluster\_id) | The ID of the metakube cluster |
<!-- END_TF_DOCS -->