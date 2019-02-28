# Database Instance Server Installation file
# IP
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

resource "azurerm_availability_set" "av-set" {
  name                         = "AV-SET-DB"
  location                     = "${data.azurerm_resource_group.rg.location}"
  resource_group_name          = "${data.azurerm_resource_group.rg.name}"
  managed                      = true
  platform_fault_domain_count  = 2
  platform_update_domain_count = 3
  tags = "${merge(var.tags_map, map("Name", element(var.db_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "SAP Database"), map("Backup", var.backup))}"
}

resource "azurerm_network_interface" "db_server_nic" {
  count                         = "${length(var.db_server_niclist)}"
  name                          = "NIC_APP-${element(var.db_server_hostnamelist, count.index)}"
  location                      = "${data.azurerm_resource_group.rg.location}"
  resource_group_name           = "${data.azurerm_resource_group.rg.name}"
  enable_accelerated_networking = "true"

  ip_configuration {
    name                          = "PVT_IP-${element(var.db_server_niclist, count.index)}"
    subnet_id                     = "${element(data.azurerm_subnet.subnet.*.id,count.index)}"
    private_ip_address_allocation = "static"
    primary                       = true
    private_ip_address            = "${element(var.db_server_niclist, count.index)}"
  }

  tags = "${merge(var.tags_map, map("Name", element(var.db_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "SAP Database"), map("Backup", var.backup))}"
}

resource "azurerm_virtual_machine" "db_server" {
  count                            = "${length(var.db_server_hostnamelist)}"
  name                             = "${element(var.db_server_hostnamelist, count.index)}"
  location                         = "${element(data.azurerm_resource_group.rg.*.location, count.index)}"
  resource_group_name              = "${element(data.azurerm_resource_group.rg.*.name, count.index)}"
  primary_network_interface_id     = "${element(azurerm_network_interface.db_server_nic.*.id,count.index)}"
  network_interface_ids            = ["${element(azurerm_network_interface.db_server_nic.*.id,count.index)}"]
  vm_size                          = "${var.db_vm_type}"
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
    name              = "OS-disk-${element(var.db_server_hostnamelist, count.index)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  # Optional data disks

  storage_data_disk {
    name              = "usrsap-${element(var.db_server_hostnamelist, count.index)}"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "64"
  }

  storage_data_disk {
    name              = "hanashared-${element(var.db_server_hostnamelist, count.index)}"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 1
    disk_size_gb      = "128"
  }
  storage_data_disk {
    name              = "hanadata1-${element(var.db_server_hostnamelist, count.index)}"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 2
    disk_size_gb      = "1024"
  }
  storage_data_disk {
    name                      = "hanalog1-${element(var.db_server_hostnamelist, count.index)}"
    managed_disk_type         = "Premium_LRS"
    create_option             = "Empty"
    lun                       = 3
    disk_size_gb              = "512"
    write_accelerator_enabled = true
  }

  storage_data_disk {
    name              = "backup1-${element(var.db_server_hostnamelist, count.index)}"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 4
    disk_size_gb      = "1024"
  }

  os_profile {
    computer_name  = "${element(var.db_server_hostnamelist, count.index)}"
    admin_username = "cloud-user"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = "${merge(var.tags_map, map("Name", element(var.db_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "SAP HANA Database"), map("Backup", var.backup))}"
}
/*
resource "azurerm_virtual_machine_extension" "db_server_ext" {
  count                = "${length(var.db_server_hostnamelist)}"
  name                 = "EXT-${element(var.db_server_hostnamelist, count.index)}"
  location             = "${data.azurerm_resource_group.rg.location}"
  resource_group_name  = "${data.azurerm_resource_group.rg.name}"
  virtual_machine_name = "${element(azurerm_virtual_machine.db_server.*.name, count.index)}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
      "fileUris":["https://siosscripts.file.core.windows.net/post/ps_db.bash"]
    }
SETTINGS
protected_settings = <<PROTECTED_SETTINGS
{
  "commandToExecute": "bash ps_db.bash.txt",
        "storageAccountName": "siosscripts",
      "storageAccountKey": "7OPrxXQqujj5vsZzar7z2rJnktnZpx+mdwMovpZNGhVZUaP46nA7RqFFX0N3ohl3aTGoCN4DlCc57HcBY3+NAg=="
}
PROTECTED_SETTINGS

  tags = "${merge(var.tags_map, map("Name", element(var.db_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "db"), map("Backup", var.backup))}"
}
*/