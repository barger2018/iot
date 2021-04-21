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
  allow_blob_public_access = true
}

resource "azurerm_storage_container" "iot" {
  name                  = "iot-container"
  storage_account_name  = azurerm_storage_account.iot.name
  container_access_type = "blob"
}


resource "azurerm_iothub" "example" {
  name                = "bargeriothub"
  resource_group_name = azurerm_resource_group.iot.name
  location            = azurerm_resource_group.iot.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  endpoint {
    type                       = "AzureIotHub.StorageContainer"
    connection_string          = azurerm_storage_account.iot.primary_blob_connection_string
    name                       = "export"
    batch_frequency_in_seconds = 60
    max_chunk_size_in_bytes    = 10485760
    container_name             = azurerm_storage_container.iot.name
    encoding                   = "Avro"
    file_name_format           = "{iothub}/{partition}_{YYYY}_{MM}_{DD}_{HH}_{mm}"
  }

  route {
    name           = "export"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["export"]
    enabled        = true
  }
}

resource "azurerm_container_registry" "acr" {
  name                     = "iotcontainers"
  resource_group_name      = azurerm_resource_group.iot.name
  location                 = azurerm_resource_group.iot.location
  sku                      = "Premium"
  admin_enabled            = false
  georeplication_locations = ["East US", "West Europe"]
}