resource "azurerm_storage_container" "terraformstate_container" {
  name                 = "${var.prefix}-terraformstate-${var.environment}"
  resource_group_name  = "${azurerm_resource_group.terraformstate_rg.name}"
  storage_account_name = "${azurerm_storage_account.terraformstate_sa.name}"

  lifecycle {
    prevent_destroy = true
  }
}