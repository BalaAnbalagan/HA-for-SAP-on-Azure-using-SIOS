
# Resource Group# Resource Group
data "azurerm_resource_group" "rg" {
  name = "${var.rg}"
}

# VNet
resource "azurerm_virtual_network" "vnet" {
  count               = "${length(var.vnet)}"
  name                = "${element(var.vnet,count.index)}"
  address_space       = ["${element(var.vnet_cidr,count.index)}"]
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
  tags                = "${merge(var.tags_map, map("Name", "Network Layer"), map("Environment", "Proof of Concept"), map("Component", "Network-Layer"), map("Backup", "false"))}"
}

resource "azurerm_virtual_network_peering" "VNET-P1" {
  count                     = "${length(var.vnet)}"
  name                      = "${element(var.vnet, 0)}"
  resource_group_name       = "${data.azurerm_resource_group.rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.0.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.vnet.1.id}"
}

resource "azurerm_virtual_network_peering" "VNET-P2" {
  count                     = "${length(var.vnet)}"
  name                      = "${element(var.vnet, 1)}"
  resource_group_name       = "${data.azurerm_resource_group.rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.1.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.vnet.0.id}"
}

# Network Security Group 
resource "azurerm_network_security_group" "nsg_hub" {
  count               = "${length(var.subnet_hub_cidrmap)}"
  name                = "NSG-HUB-${element(var.subnets_hub_names, count.index)}"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "internet_login"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = "${merge(var.tags_map, map("Name", "Network Layer"), map("Environment", "Proof of Concept"), map("Component", "Network-Layer"), map("Backup", "false"))}"
}

# HUB Subnets
resource "azurerm_subnet" "subnet_hub" {
  count               = "${length(var.subnet_hub_cidrmap)}"
  name                = "HUB-${element(var.subnets_hub_names, count.index)}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"

  virtual_network_name = "HUB"

  #virtual_network_name      = "${element(azurerm_virtual_network.vnet.*.name, count.index)}"
  address_prefix            = "${lookup(var.subnet_hub_cidrmap, element(var.subnets_hub_names, count.index))}"
  network_security_group_id = "${element(azurerm_network_security_group.nsg_hub.*.id, count.index)}"
}

resource "azurerm_network_security_group" "nsg_spoke" {
  count               = "${length(var.subnet_spoke_cidrmap)}"
  name                = "NSG-SPOKE-${element(var.subnets_spoke_names, count.index)}"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "internet_login"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = "${merge(var.tags_map, map("Name", "Network Layer"), map("Environment", "Proof of Concept"), map("Component", "Network-Layer"), map("Backup", "false"))}"
}

# Spoke Subnet 
resource "azurerm_subnet" "subnet_spoke" {
  count               = "${length(var.subnet_spoke_cidrmap)}"
  name                = "SPOKE-${element(var.subnets_spoke_names, count.index)}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"

  virtual_network_name = "SPOKE"

  #virtual_network_name      = "${element(azurerm_virtual_network.vnet.*.name, count.index)}"
  address_prefix            = "${lookup(var.subnet_spoke_cidrmap, element(var.subnets_spoke_names, count.index))}"
  network_security_group_id = "${element(azurerm_network_security_group.nsg_spoke.*.id, count.index)}"
}
