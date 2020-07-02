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

# ---------------------------------------------------------------------------------------------------------------------
# Azure Resource Group
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# ---------------------------------------------------------------------------------------------------------------------
# Azure Kubernetes Service
# ---------------------------------------------------------------------------------------------------------------------

module "aks" {
  source = "./modules/aks"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  cluster_name        = var.cluster_name
  node_count          = var.node_count
  client_id           = var.client_id
  client_secret       = var.client_secret
  environment         = var.environment
}

# ---------------------------------------------------------------------------------------------------------------------
# Azure Public IP and DNS
# ---------------------------------------------------------------------------------------------------------------------

module "public" {
  source = "./modules/public"

  resource_group_name = "${module.aks.cluster_resource_group}"
  location            = azurerm_resource_group.rg.location
  cluster_name        = var.cluster_name
  domain_name         = var.domain_name
  environment         = var.environment
}

# ---------------------------------------------------------------------------------------------------------------------
# Azure Container Registry
# ---------------------------------------------------------------------------------------------------------------------

module "acr" {
  source = "./modules/acr"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_principal   = var.client_id
  environment         = var.environment
}

output "kube_config" {
  value = "${module.aks.kube_config}"
}

output "name_servers" {
  value = "${module.public.name_servers}"
}

output "login_server" {
  value = "${module.acr.login_server}"
}
