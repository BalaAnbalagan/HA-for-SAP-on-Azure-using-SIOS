resource "azurerm_resource_group" "rg" {
  count    = "${length(var.rg)}"
  name     = "${element(var.rg, count.index)}"
  location = "${var.location}"
  tags     = "${merge(var.tags_map, map("Name", "Network Layer"), map("Environment", "Proof of Concept"), map("Component", "Network-Layer"), map("Backup", "false"))}"
}
