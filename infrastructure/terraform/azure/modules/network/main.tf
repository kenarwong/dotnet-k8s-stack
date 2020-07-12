## Virtual network ##
resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/8"]
}

## Subnet ##
resource "azurerm_subnet" "subnet" {
  name                  = "aks-subnet"
  virtual_network_name  = azurerm_virtual_network.vnet.name
  resource_group_name   = var.resource_group_name
  address_prefixes      = ["10.240.0.0/16"]
}

## Virtual Network Custom Role ##
resource "azurerm_role_definition" "vnet-custom-role" {
  name               = "vnet-custom-role-definition"
  scope              = azurerm_subnet.subnet.id

  permissions {
    actions     = [
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/read"
    ]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_subnet.subnet.id,
  ]
}

## Create Virtual Network Role Assignment ##
resource "azurerm_role_assignment" "vnet-role" {
  scope               = azurerm_subnet.subnet.id
  role_definition_id  = azurerm_role_definition.vnet-custom-role.id
  principal_id        = var.vnet_sp_object_id
}

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

## Create DNS Zone Role Assignment ##
resource "azurerm_role_assignment" "cert-manager-dns-zone-role" {
  scope                = azurerm_dns_zone.dns.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = var.cert_manager_sp_object_id
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
