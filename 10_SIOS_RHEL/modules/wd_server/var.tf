variable "environment" {
  description = "Enviroment Prod or non-prod"
  default     = "Production"
}

variable "sid" {
  description = "SAP SID"
  default     = "W3Z"
}

variable "location" {
  description = "Azure Regions"
  default     = "WESTUS2"
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

variable "wd_vm_type" {
  default = ""
}

variable "wd_server_hostnamelist" {
  description = "list of Ethernets"
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

variable "backup" {
  default = "false"
}

variable "tags_map" {
  description = "Map of tags and values"
  type        = "map"
  default     = {}
}
