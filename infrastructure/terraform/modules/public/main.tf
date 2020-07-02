## Public IP ##
resource "azurerm_public_ip" "public" {
  name                = "${var.cluster_name}-public-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"

  tags = {
    Environment = var.environment
  }
}

## DNS Zone ##
resource "azurerm_dns_zone" "public" {
  name                = var.domain_name
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
  }
}

## A Record ##
resource "azurerm_dns_a_record" "public" {
  name                = "@"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_public_ip.public.id
}

## CNAME Record ##
resource "azurerm_dns_cname_record" "public" {
  name                = "api"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = var.resource_group_name
  record              = var.domain_name
}

## CNAME Record ##
resource "azurerm_dns_cname_record" "public" {
  name                = "*"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = var.resource_group_name
  record              = var.domain_name
}
