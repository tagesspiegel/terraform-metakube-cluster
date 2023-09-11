output "metakube_cluster_id" {
  value       = metakube_cluster.cluster.id
  description = "The ID of the metakube cluster"
}

output "kube_config" {
  value       = metakube_cluster.cluster.kube_config
  description = "The kubeconfig for the metakube cluster (admin config)."
  sensitive   = true
}

output "kube_config_ca_certificate" {
  value       = local.cluster_ca_certificate
  description = "The Kubernetes cluster CA data"
  sensitive   = true
}

output "kube_config_host" {
  value       = local.cluster_host
  description = "The Kubernetes cluster server address"
  sensitive   = true
}

output "kube_config_username" {
  value       = local.cluster_username
  description = "The Kubernetes cluster user name"
  sensitive   = true
}

output "kube_config_token" {
  value       = local.cluster_token
  description = "The Kubernetes cluster user token"
  sensitive   = true
}

output "argo_daemon_service_account_token" {
  description = "The ArgoCD daemon service account token"
  sensitive   = true
  value       = var.enable_argocd_service_account ? data.kubernetes_secret_v1.argod[0].data["token"] : ""
}
