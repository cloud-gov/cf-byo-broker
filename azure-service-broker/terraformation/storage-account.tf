resource "azurerm_storage_account" "terraformstate_sa" {
  name                     = "${var.storage_account_name}"
  location                 = "${var.location}"
  account_tier             = "${var.account_tier}"
  resource_group_name      = "${azurerm_resource_group.terraformstate_rg.name}"
  account_replication_type = "${var.storage_account_replication_type}"

  lifecycle {
    prevent_destroy = true
  }
}