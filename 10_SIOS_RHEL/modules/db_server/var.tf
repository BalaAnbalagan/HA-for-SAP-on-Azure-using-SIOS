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
variable "sid" {}

variable "environment" {
  default = "Non-Prod"
}

variable "location" {
  description = "List of locations"
  default     = ""
}

variable "db_location" {
  description = "List of locations"
  default     = ""
}

variable "db_vm_type" {
  default = ""
}

variable "db_server_hostnamelist" {
  description = "List of hostnames"
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

variable "backup" {
  default = "false"
}

variable "tags_map" {
  description = "Map of tags and values"
  type        = "map"
  default     = {}
}
