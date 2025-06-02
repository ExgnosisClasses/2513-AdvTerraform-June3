terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

terraform {
  backend "azurerm" {
      resource_group_name  = "<your backend rg name>"
       storage_account_name = "<your backend storage name>"
       container_name       = "<your backend container name>"
       key                  = "proj1"
  }
}



provider "azurerm" {
  features {}
  subscription_id = "<your subscription>"
}
