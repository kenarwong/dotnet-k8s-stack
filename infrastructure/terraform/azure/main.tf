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
# Azure Public Resources
# ---------------------------------------------------------------------------------------------------------------------

module "public" {
  source = "./modules/public"

  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  cluster_name              = var.cluster_name
  domain_name               = var.domain_name
  cert_manager_sp_object_id = var.cert_manager_sp_object_id
  environment               = var.environment
}

# ---------------------------------------------------------------------------------------------------------------------
# Azure Kubernetes Service
# ---------------------------------------------------------------------------------------------------------------------

module "aks" {
  source = "./modules/aks"

  resource_group_name   = azurerm_resource_group.rg.name
  resource_group_id     = azurerm_resource_group.rg.id
  location              = azurerm_resource_group.rg.location
  cluster_name          = var.cluster_name
  node_count            = var.node_count
  aks_sp_client_id      = var.aks_sp_client_id
  aks_sp_client_secret  = var.aks_sp_client_secret
  vnet_sp_object_id     = var.vnet_sp_object_id
  public_ip_id          = "${module.public.public_ip_id}"
  environment           = var.environment
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
  value = "${module.public.ip_address}"
}

output "name_servers" {
  value = "${module.public.name_servers}"
}

output "acr_login_server" {
  value = "${module.acr.login_server}"
}

output "resource_group_name" {
  value = var.resource_group_name
}

output "cluster_name" {
  value = var.cluster_name
}

output "aks_cluster_group" {
  value = "${module.aks.cluster_resource_group}"
}
