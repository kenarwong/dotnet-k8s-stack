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

  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  cluster_name          = var.cluster_name
  node_count            = var.node_count
  aks_sp_client_id      = var.aks_sp_client_id
  aks_sp_client_secret  = var.aks_sp_client_secret
  vnet_sp_object_id     = var.vnet_sp_object_id
  environment           = var.environment
}

# ---------------------------------------------------------------------------------------------------------------------
# Azure Public Resources
# ---------------------------------------------------------------------------------------------------------------------

module "public" {
  source = "./modules/public"

  resource_group_name       = "${module.aks.cluster_resource_group}"
  location                  = azurerm_resource_group.rg.location
  cluster_name              = var.cluster_name
  domain_name               = var.domain_name
  cert_manager_sp_object_id = var.cert_manager_sp_object_id
  environment               = var.environment
}

# ---------------------------------------------------------------------------------------------------------------------
# Azure Container Registry
# ---------------------------------------------------------------------------------------------------------------------

module "acr" {
  source = "./modules/acr"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  acr_name            = var.acr_name
  acr_sp_object_id    = var.acr_sp_object_id
  environment         = var.environment
}

# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------

output "kube_config" {
  value     = "${module.aks.kube_config}"
  sensitive  = true
}

output "ip_address" {
  value = "${module.network.ip_address}"
}

output "name_servers" {
  value = "${module.network.name_servers}"
}

output "acr_login_server" {
  value = "${module.acr.login_server}"
}

output "aks_resource_group" {
  value = "${module.aks.cluster_resource_group}"
}
