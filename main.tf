terraform {
  required_version = "~> 0.15.0"
  required_providers {
    azurerm = "~> 2.56.0"
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "bargerweb"
    workspaces {
      name = "IoT-Dev"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "iot" {
  name     = "iot"
  location = "East US"
}

resource "azurerm_storage_account" "iot" {
  name                     = "bargeriotstorage"
  resource_group_name      = azurerm_resource_group.iot.name
  location                 = azurerm_resource_group.iot.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "iot" {
  name                  = "iot-container"
  storage_account_name  = azurerm_storage_account.iot.name
  container_access_type = "private"
}