variable "environment" {
  description = "Enviroment Prod or non-prod"
  default     = "Production"
}

variable "sid" {
  description = "SAP SID"
  default     = ""
}

variable "rg" {
  description = "resource group"
  default     = ""
}

variable "network_rg" {
  description = "Network resource group"
  default     = ""
}

variable "vnet" {
  description = "Name of the vnet"
  default     = "SPOKE"
}

variable "subnet" {
  description = "Name of the subnet"
  default     = "Subnet"
}
variable "vnet_name" {
  description = "Name of the vnet"
  default     = "SPOKE"
}

variable "location" {
  description = "Azure Regions"
  default     = "WESTUS2"
}

#########################################
# SCS
variable "scs_vm_type" {
  default = ""
}

variable "scs_server_hostnamelist" {
  description = "list of hostname"
  type        = "list"
  default     = []
}

variable "scs_server_niclist" {
  description = "list of Ethernets"
  type        = "list"
  default     = []
}

variable "scs_ipmap" {
  description = "hostname vs ip address"
  type        = "map"
  default     = {}
}

#########################################
# Web Dispatcher

variable "wd_vm_type" {
  default = ""
}

variable "wd_server_hostnamelist" {
  description = "list of hostname"
  type        = "list"
  default     = []
}

variable "wd_server_niclist" {
  description = "list of Ethernets"
  type        = "list"
  default     = []
}

variable "wd_ipmap" {
  description = "hostname vs ip address"
  type        = "map"
  default     = {}
}

#########################################
# sios
variable "sios_vm_type" {
  default = ""
}

variable "sios_server_hostnamelist" {
  description = "list of hostname"
  type        = "list"
  default     = []
}

variable "sios_server_niclist" {
  description = "list of Ethernets"
  type        = "list"
  default     = []
}

variable "sios_ipmap" {
  description = "hostname vs ip address"
  type        = "map"
  default     = {}
}

##################
# App Server
variable "app_vm_type" {
  default = ""
}

variable "app_server_hostnamelist" {
  description = "list of hostname"
  type        = "list"
  default     = []
}

variable "app_server_niclist" {
  description = "list of Ethernets"
  type        = "list"
  default     = []
}

variable "app_server_ipmap" {
  description = "Map of hostname and IP address for application servers"
  type        = "map"
  default     = {}
}

##############################################################
# DB Server
variable "db_vm_type" {
  default = ""
}

variable "db_location" {
  description = "List of locations"
  default     = "WESTUS"
}

variable "db_server_hostnamelist" {
  description = "list of hostname"
  type        = "list"
  default     = []
}

variable "db_server_niclist" {
  description = "list of Ethernets"
  type        = "list"
  default     = []
}

variable "db_server_ipmap" {
  description = "Map of hostname and IP address for application servers"
  type        = "map"
  default     = {}
}
#####################################################################

variable "jumpserver_hostnamelist" {
  description = "list of hostnames to be created"
  type        = "list"
  default     = []
}

variable "jumpserver_niclist" {
  description = "list of nic to be created"
  type        = "list"
  default     = []
}

variable "jumpserver_hostname_map" {
  description = "location and hostname map"
  type        = "map"
  default     = {}
}

variable "jumpserver_nic_map" {
  description = "hostname and ip map"
  type        = "map"
  default     = {}
}

########################################################################
variable "backup" {
  default = "false"
}

variable "tags_map" {
  description = "Map of tags and values"
  type        = "map"
  default     = {}
}
#############################################################
