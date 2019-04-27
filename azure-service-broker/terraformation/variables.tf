variable "prefix" {
  default = "ci"
}

variable "environment" {
  default = "dev"
}

variable "location" {
  default = "eastus"
}

variable "resource_group_name" {
  default = "18F"
}

variable "account_tier" {
  default = "standard"
}

variable "storage_account_replication_type" {
  default = "LRS"
}

variable "storage_account_name" {
  default = "tfstate"
}