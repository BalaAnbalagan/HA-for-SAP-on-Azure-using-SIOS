# Variable Declaration
variable "environment" {
  description = "Environment Type"
  default     = "Proof of Concept"
}

variable "rg" {
  description = "resource group"
  default     = ""
}

#Location 
variable "location" {
  description = "List of locations"
  type        = "list"
  default     = []
}

# Virtual Network names
variable "vnet" {
  description = "Name of virtual networks"
  type        = "list"
  default     = []
}

# Virtual Network Address space
variable "vnet_cidr" {
  description = "CIDR address Space"
  type        = "list"
  default     = []
}

# Virtual Network Address space map
variable "vnet_cidrmap" {
  description = "CIDR address Space"
  type        = "map"
  default     = {}
}

variable "subnets_hub_names" {
  description = "HUB subnet names"
  type        = "list"
}

variable "subnet_hub_cidr" {
  description = "HUB ip address space"
  type        = "list"
}

variable "subnet_hub_cidrmap" {
  description = "subnet name vs ip address space map"
  type        = "map"
}

variable "subnets_spoke_names" {
  description = "Spoke subnet names"
  type        = "list"
}

variable "subnet_spoke_cidr" {
  description = "spoke ip address space"
  type        = "list"
}

variable "subnet_spoke_cidrmap" {
  description = "subnet name vs ip address space map"
  type        = "map"
}

# below variables for TAGS
variable "tags_map" {
  description = "Map of tags and values"
  type        = "map"
  default     = {}
}
