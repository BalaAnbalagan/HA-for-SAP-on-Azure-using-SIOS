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

resource "azurerm_network_interface" "nfs_server_nic" {
  count               = "${length(var.nfs_ipmap)}"
  name                = "NIC_APP-${element(var.nfs_server_hostnamelist, count.index)}"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"

  enable_accelerated_networking = "true"

  ip_configuration {
    name                          = "PVT_IP-${element(var.nfs_server_niclist, count.index)}"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "static"
    primary                       = true
    private_ip_address            = "${lookup(var.nfs_ipmap, element(var.nfs_server_hostnamelist, count.index))}"
  }

  tags = "${merge(var.tags_map, map("Name", element(var.nfs_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "nfs"), map("Backup", var.backup))}"
}

resource "azurerm_availability_set" "av-set" {
  name                         = "AV-SET-nfs"
  location                     = "${data.azurerm_resource_group.rg.location}"
  resource_group_name          = "${data.azurerm_resource_group.rg.name}"
  managed                      = true
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2

  tags                = "${merge(var.tags_map, map("Name", element(var.nfs_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "SAP Database"), map("Backup", var.backup))}"
}

resource "azurerm_virtual_machine" "nfs_server" {
  count                            = "${length(var.nfs_server_hostnamelist)}"
  name                             = "${element(var.nfs_server_hostnamelist, count.index)}"
  location                         = "${data.azurerm_resource_group.rg.location}"
  resource_group_name              = "${data.azurerm_resource_group.rg.name}"
  primary_network_interface_id     = "${element(azurerm_network_interface.nfs_server_nic.*.id,count.index)}"
  network_interface_ids            = ["${element(azurerm_network_interface.nfs_server_nic.*.id,count.index)}"]
  vm_size                          = "${var.nfs_vm_type}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  availability_set_id              = "${azurerm_availability_set.av-set.id}"

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL-SAP"
    sku       = "7.4"
    version   = "7.4.2018031222"
  }

  storage_os_disk {
    name              = "OS_DISK-${element(var.nfs_server_hostnamelist, count.index)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  # Optional data disks

  storage_data_disk {
    name              = "usrsap_data-${element(var.nfs_server_hostnamelist, count.index)}"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "4095"
  }

  os_profile {
    computer_name  = "${element(var.nfs_server_hostnamelist, count.index)}"
    admin_username = "cloud-user"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = "${merge(var.tags_map, map("Name", element(var.nfs_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "nfs"), map("Backup", var.backup))}"
}



resource "azurerm_virtual_machine_extension" "nfs_server_ext" {
  count                = "${length(var.nfs_server_hostnamelist)}"
  name                 = "EXT-${element(var.nfs_server_hostnamelist, count.index)}"
  location             = "${data.azurerm_resource_group.rg.location}"
  resource_group_name  = "${data.azurerm_resource_group.rg.name}"
  virtual_machine_name = "${element(azurerm_virtual_machine.nfs_server.*.name, count.index)}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"

  settings = <<SETTINGS
    {

      "commandToExecute": "yum -y install uuidd bzip2 iproute iputils mktemp patch redhat-lsb libtool-ltdl compat-sap-c++-6"

    }
SETTINGS
#  tags = "${merge(var.tags_map, map("Name", element(var.nfs_server_hostnamelist, count.index)), map("Environment", var.environment), map("Component", "nfs"), map("Backup", var.backup))}"
#      "fileUris":["https://ftawestus2.blob.core.windows.net/scripts/test.sh"], 
}


