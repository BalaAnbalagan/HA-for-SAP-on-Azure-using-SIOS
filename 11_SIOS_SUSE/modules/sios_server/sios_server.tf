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

resource "azurerm_network_interface" "sios_server_nic" {
  count               = "${length(var.sios_ipmap)}"
  name                = "NIC_APP-${element(var.sios_server_hostnamelist, count.index)}"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"

  #enable_accelerated_networking = "true"

  ip_configuration {
    name                          = "PVT_IP-${element(var.sios_server_niclist, count.index)}"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "static"
    primary                       = true
    private_ip_address            = "${lookup(var.sios_ipmap, element(var.sios_server_hostnamelist, count.index))}"
  }

  tags = "${merge(var.tags_map, map("Name", element(var.sios_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "sios"), map("Backup", var.backup))}"
}

resource "azurerm_availability_set" "av-set" {
  name                         = "AV-SET-sios"
  location                     = "${data.azurerm_resource_group.rg.location}"
  resource_group_name          = "${data.azurerm_resource_group.rg.name}"
  managed                      = true
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2

  tags                = "${merge(var.tags_map, map("Name", element(var.sios_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "SAP Database"), map("Backup", var.backup))}"
}

resource "azurerm_virtual_machine" "sios_server" {
  count                            = "${length(var.sios_server_hostnamelist)}"
  name                             = "${element(var.sios_server_hostnamelist, count.index)}"
  location                         = "${data.azurerm_resource_group.rg.location}"
  resource_group_name              = "${data.azurerm_resource_group.rg.name}"
  primary_network_interface_id     = "${element(azurerm_network_interface.sios_server_nic.*.id,count.index)}"
  network_interface_ids            = ["${element(azurerm_network_interface.sios_server_nic.*.id,count.index)}"]
  vm_size                          = "${var.sios_vm_type}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  availability_set_id              = "${azurerm_availability_set.av-set.id}"

  storage_image_reference {
    publisher = "SUSE"
    offer     = "SLES-SAP"
    sku       = "12-SP3"
    version   = "latest"
  }

  storage_os_disk {
    name              = "OS_DISK-${element(var.sios_server_hostnamelist, count.index)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
       disk_size_gb      = "128"
  }

  # Optional data disks



  os_profile {
    computer_name  = "${element(var.sios_server_hostnamelist, count.index)}"
    admin_username = "cloud-user"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = "${merge(var.tags_map, map("Name", element(var.sios_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "sios"), map("Backup", var.backup))}"
}

/*

resource "azurerm_virtual_machine_extension" "sios_server_ext" {
  count                = "${length(var.sios_server_hostnamelist)}"
  name                 = "EXT-${element(var.sios_server_hostnamelist, count.index)}"
  location             = "${data.azurerm_resource_group.rg.location}"
  resource_group_name  = "${data.azurerm_resource_group.rg.name}"
  virtual_machine_name = "${element(azurerm_virtual_machine.sios_server.*.name, count.index)}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"

  settings = <<SETTINGS
    {

      "commandToExecute": "yum -y install uuidd"
    }
SETTINGS
#  tags = "${merge(var.tags_map, map("Name", element(var.sios_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "sios"), map("Backup", var.backup))}"
#      "fileUris":["https://ftawestus2.blob.core.windows.net/scripts/test.sh"], 
}


*/