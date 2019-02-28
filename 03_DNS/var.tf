variable "environment" {
  description = "Enviroment Prod or non-prod"
  default     = "Production"
}

variable "rg" {
  description = "Resource Group"
  default     = "PG"
}

variable "network_rg" {
  description = "Network_rg"
  default     = ""
}

variable "location" {
  description = "Azure Regions"
  default     = "WESTUS2"
}


variable "vnet" {
  description = "Name of the vnet"
  default     = "SPOKE"
}

variable "subnet" {
  description = "Name of the vnet"
  default     = "SUBNET"
}
variable "dns_server_hostnamelist" {
  description = "list of Ethernets"
  type        = "list"
  default     = []
}

variable "dns_server_niclist" {
  description = "list of Ethernets"
  type        = "list"
  default     = []
}

variable "dns_ipmap" {
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
