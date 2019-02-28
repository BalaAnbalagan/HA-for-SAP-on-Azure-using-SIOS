variable "location" {
  description = "List of locations"

  default = ""
}
variable "rg" {
  description = "List of Resource Groups"

  default = []
}

variable "tags_map" {
  description = "Map of tags and values"
  type        = "map"
  default     = {}
}