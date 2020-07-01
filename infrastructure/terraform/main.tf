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
resource "azurerm_resource_group" "dotnet-k8s-stack" {
  name     = var.resource_group_name
  location = var.location
}
