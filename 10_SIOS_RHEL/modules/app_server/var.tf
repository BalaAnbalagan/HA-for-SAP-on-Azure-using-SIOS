variable "location" {
  description = "List of locations"
  default     = ""
}

variable "sid" {}

variable "environment" {
  default = "Non-Prod"
}

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

variable "rg" {
  description = "resource group"
  default     = ""
}

variable "network_rg" {
  description = "resource group"
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

variable "app_server_ipmap" {
  description = "Map of hostname and IP address for application servers"
  type        = "map"
  default     = {}
}

variable "backup" {
  default = "false"
}

variable "tags_map" {
  description = "Map of tags and values"
  type        = "map"
  default     = {}
}
