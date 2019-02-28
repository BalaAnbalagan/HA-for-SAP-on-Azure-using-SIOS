data "azurerm_resource_group" "rg" {
  name = "${var.sid}"
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

resource "azurerm_network_interface" "wd_server_nic" {
  count               = "${length(var.wd_ipmap)}"
  name                = "NIC_APP-${element(var.wd_server_hostnamelist, count.index)}"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"

  enable_accelerated_networking = "true"

  ip_configuration {
    name                          = "PVT_IP-${element(var.wd_server_niclist, count.index)}"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "static"
    primary                       = true
    private_ip_address            = "${lookup(var.wd_ipmap, element(var.wd_server_hostnamelist, count.index))}"
  }

  # tags = "${merge(var.tags_map, map("Name", element(var.wd_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "SCS"), map("Backup", var.backup))}"
}

resource "azurerm_availability_set" "av-set" {
  name                         = "AV-SET-WD"
  location                     = "${data.azurerm_resource_group.rg.location}"
  resource_group_name          = "${data.azurerm_resource_group.rg.name}"
  managed                      = true
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2

  #tags                = "${merge(var.tags_map, map("Name", element(var.db_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "SAP Database"), map("Backup", var.backup))}"
}

resource "azurerm_virtual_machine" "wd_server" {
  count                            = "${length(var.wd_server_hostnamelist)}"
  name                             = "${element(var.wd_server_hostnamelist, count.index)}"
  location                         = "${data.azurerm_resource_group.rg.location}"
  resource_group_name              = "${data.azurerm_resource_group.rg.name}"
  primary_network_interface_id     = "${element(azurerm_network_interface.wd_server_nic.*.id,count.index)}"
  network_interface_ids            = ["${element(azurerm_network_interface.wd_server_nic.*.id,count.index)}"]
  vm_size                          = "${var.wd_vm_type}"
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
    name              = "OS_DISK-${element(var.wd_server_hostnamelist, count.index)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  # Optional data disks

  storage_data_disk {
    name              = "usrsap-${element(var.wd_server_hostnamelist, count.index)}"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "32"
  }
  storage_data_disk {
    name              = "usrsap_sed-${element(var.wd_server_hostnamelist, count.index)}"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 1
    disk_size_gb      = "32"
  }
  os_profile {
    computer_name  = "${element(var.wd_server_hostnamelist, count.index)}"
    admin_username = "cloud-user"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = "${merge(var.tags_map, map("Name", element(var.wd_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "Web-Dispatcher"), map("Backup", var.backup))}"
}
