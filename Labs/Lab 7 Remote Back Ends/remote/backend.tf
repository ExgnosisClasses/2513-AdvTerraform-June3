resource "azurerm_resource_group" "tf_backend_rg" {
  name     = "<your unique name>"
  location = "eastus"
}

resource "azurerm_storage_account" "tf_backend_sa" {
  name                     = "<globally unique name>" # must be globally unique
  resource_group_name      = azurerm_resource_group.tf_backend_rg.name
  location                 = azurerm_resource_group.tf_backend_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tf_backend_container" {
  name                  = "<blob-name>"
  storage_account_name  = azurerm_storage_account.tf_backend_sa.id
  container_access_type = "private"
}