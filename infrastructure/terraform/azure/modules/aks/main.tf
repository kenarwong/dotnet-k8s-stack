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

## AKS cluster ##
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = "${var.cluster_name}-${var.resource_group_name}"

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = "Standard_DS2_v2"
    vnet_subnet_id  = azurerm_subnet.subnet.id
  }

  service_principal {
    client_id     = var.aks_sp_client_id
    client_secret = var.aks_sp_client_secret
  }

  network_profile {
    network_plugin = "kubenet"
    network_policy = "calico"
    load_balancer_sku = "Standard"
    load_balancer_profile {
      outbound_ip_address_ids = [ var.public_ip_id ]
    }
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }
  }

  tags = {
    Environment = var.environment
  }
}
