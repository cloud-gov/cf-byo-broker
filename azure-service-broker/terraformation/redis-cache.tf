resource "azurerm_redis_cache" "18f_osba_rc" {
  name                = "cf-osba-cache"
  location            = "${azurerm_resource_group.terraformstate_rg.location}"
  resource_group_name = "${azurerm_resource_group.terraformstate_rg.name}"
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  
  redis_configuration {
    maxmemory_reserved = 50
    maxmemory_delta    = 50
    maxmemory_policy   = "allkeys-lru"
  }
}