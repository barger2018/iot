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