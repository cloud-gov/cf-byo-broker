resource "azurerm_resource_group" "terraformstate_rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}