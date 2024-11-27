terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.102.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.2.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.15"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.88.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

provider "vault" {}

provider "boundary" {
  addr                   = var.boundary_addr
  auth_method_id         = var.boundary_authmethod
  auth_method_login_name = var.boundary_user
  auth_method_password   = var.boundary_password
}
provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
}