
resource "azurerm_resource_group" "resgrp" {
  name     = var.RGName
  location = "eastus"
  tags = {
      Sourcing = "Module Generated"
    }
}