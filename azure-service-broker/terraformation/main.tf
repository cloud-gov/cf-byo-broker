terraform {
  backend "azurerm" {
    storage_account_name  = "18fci"
    container_name        = "terraformstate"
    key                   = "terraform.tfstate"
  }
  required_version = "~> 0.11.13"
}