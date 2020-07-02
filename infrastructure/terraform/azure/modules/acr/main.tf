## Azure Container Registry ##
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  tags = {
    Environment = var.environment
  }
}

## Create ACR Role Assignment
resource "azurerm_role_assignment" "acr-role" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "acrPull"
  principal_id         = var.service_principal
}
