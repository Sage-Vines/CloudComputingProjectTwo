#these outputs save us from typing kubectl describe every five seconds
#copy/paste them straight into terminals during demos

output "namespace" {
  description = "Namespace where the application is deployed."
  value       = kubernetes_namespace.app.metadata[0].name
}

output "service_name" {
  description = "Name of ClusterIP service."
  value       = kubernetes_service.app.metadata[0].name
}

#copy & paste friendly command
output "port_forward_command" {
  description = "Convenience command to access service via kubectl port-forward."
  value       = "kubectl port-forward -n ${kubernetes_namespace.app.metadata[0].name} svc/${kubernetes_service.app.metadata[0].name} 8080:80"
}

