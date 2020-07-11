## AKS cluster ##
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = "${var.cluster_name}-${var.resource_group_name}"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
  }

  service_principal {
    client_id     = var.aks_sp_client_id
    client_secret = var.aks_sp_client_secret
  }

  #network_profile {
  #  network_plugin = "kubenet"
  #  network_policy = "calico"
  #}

  addon_profile {
    kube_dashboard {
      enabled = true
    }
  }

  tags = {
    Environment = var.environment
  }
}
