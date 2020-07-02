terraform {
  ## Azure state backend
  backend "azurerm" {
    features {}
  }
}

## Azure resource provider ##
provider "azurerm" {
  version = "=2.16.0"
  features {}
}

## Azure resource group for the kubernetes cluster ##
resource "azurerm_resource_group" "azure-k8s" {
  name     = var.resource_group_name
  location = var.location
}

## AKS kubernetes cluster ##
resource "azurerm_kubernetes_cluster" "azure-k8s" {
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.azure-k8s.name
  location            = azurerm_resource_group.azure-k8s.location
  dns_prefix          = "${var.cluster_name}-${azurerm_resource_group.azure-k8s.name}"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  tags = {
    Environment = var.environment
  }
}
