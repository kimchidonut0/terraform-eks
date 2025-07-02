output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "kubeconfig" {
  value     = module.eks.kubeconfig
  sensitive = true
}

output "service_external_hostname" {
  value       = kubernetes_service.hello.status[0].load_balancer[0].hostname
  description = "External DNS name (ELB) for your app"
}