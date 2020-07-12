output "ip_address" {
  value = azurerm_public_ip.public-ip.ip_address
}

output "name_servers" {
  value = azurerm_dns_zone.dns.name_servers
}

output "vnet_subnet_id" {
  value = azurerm_subnet.subnet.id
}
