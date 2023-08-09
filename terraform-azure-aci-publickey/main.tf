variable "azure_client_id" {
}

variable "azure_client_secret" {
}

variable "azure_tenant_id" {
}

variable "azure_subscription_id" {
}

variable "public_key" {
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}

  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

resource "azurerm_resource_group" "main" {
  name     = "sshd-ubuntu-terraform-resource-group"
  location = "East US 2"
}

resource "azurerm_container_group" "main" {
  name                = "sshd-ubuntu-terraform-containergroup"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_address_type     = "Public"
  os_type             = "Linux"

  container {
    name   = "sshd-container"
    image  = "andreygoran/sshd-ubuntu"
    cpu    = "1.0"
    memory = "1.0"

    ports {
      port     = 22
      protocol = "TCP"
    }

    environment_variables = {
      PUBLIC_KEY = var.public_key
    }
  }
}

output "sshd_ip_address" {
  description = "IP address of SSH server"
  value       = azurerm_container_group.main.ip_address
}
