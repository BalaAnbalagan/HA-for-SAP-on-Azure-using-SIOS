data "azurerm_resource_group" "rg" {
  name = "${var.rg}"
}

data "azurerm_resource_group" "network_rg" {
  name = "${var.network_rg}"
}

data "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet}"
  resource_group_name = "${data.azurerm_resource_group.network_rg.name}"
}

data "azurerm_subnet" "subnet" {
  name                 = "${var.subnet}"
  virtual_network_name = "${data.azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${data.azurerm_resource_group.network_rg.name}"
}

resource "azurerm_public_ip" "public_ip" {
  name                         = "PUB_IP-${element(var.jump_server_hostnamelist, count.index)}"
  location                     = "${var.location}"
  resource_group_name          = "${data.azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "jump_server_nic" {
  name                = "NIC-${element(var.jump_server_hostnamelist, count.index)}"
  location            = "${var.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"

  #enable_accelerated_networking = "true"

  ip_configuration {
    name                          = "PVT_IP${element(var.jump_server_niclist,count.index)}"
    subnet_id                     = "${element(data.azurerm_subnet.subnet.*.id,count.index)}"
    private_ip_address_allocation = "static"
    primary                       = true
    private_ip_address            = "${element(var.jump_server_niclist, count.index)}"
    public_ip_address_id          = "${element(azurerm_public_ip.public_ip.*.id, count.index)}"
  }

  #tags = "${merge(var.tags_map, map("Name", element(var.jump_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "ASCS"), map("Backup", var.backup))}"
}

resource "azurerm_virtual_machine" "jump_server" {
  count               = "${length(var.jump_server_hostnamelist)}"
  name                = "${element(var.jump_server_hostnamelist, count.index)}"
  location            = "${element(data.azurerm_resource_group.rg.*.location, count.index)}"
  resource_group_name = "${element(data.azurerm_resource_group.rg.*.name, count.index)}"

  #primary_network_interface_id     = "${element(azurerm_network_interface.jump_server_nic.*.id,count.index)}"
  network_interface_ids            = ["${element(azurerm_network_interface.jump_server_nic.*.id,count.index)}"]
  vm_size                          = "Standard_D8s_v3"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "OS_DISK-${element(var.jump_server_hostnamelist, count.index)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  # Optional data disks

  storage_data_disk {
    name              = "DATA_DISK-${element(var.jump_server_hostnamelist, count.index)}"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "4095"
  }
  os_profile {
    computer_name  = "${element(var.jump_server_hostnamelist, count.index)}"
    admin_username = "cloud-user"
    admin_password = "Password1234!"
  }
  os_profile_windows_config {
    enable_automatic_upgrades = false
    provision_vm_agent        = true
  }
}
