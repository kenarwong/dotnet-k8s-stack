## Public IP ##
resource "azurerm_public_ip" "public-ip" {
  name                = "${var.cluster_name}-public-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"

  tags = {
    Environment = var.environment
  }
}

## DNS Zone ##
resource "azurerm_dns_zone" "dns" {
  name                = var.domain_name
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
  }
}

## A Record ##
resource "azurerm_dns_a_record" "a-record" {
  name                = "@"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.public-ip.id
}

## CNAME Record ##
resource "azurerm_dns_cname_record" "api-cname-record" {
  name                = "api"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = var.domain_name
}

## CNAME Record ##
resource "azurerm_dns_cname_record" "all-cname-record" {
  name                = "*"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = var.domain_name
}
