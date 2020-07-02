output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "cluster_resource_group" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}
