#Create SSH keypair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
#Store All SSH keys in Vault KV
resource "vault_kv_secret_v2" "example" {
  mount               = "kv"
  name                = "${var.vm_name}-ssh"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      public_key_openssh = tls_private_key.ssh_key.public_key_openssh,
      private_key_openssh = tls_private_key.ssh_key.private_key_openssh,
      public_key_pem = tls_private_key.ssh_key.public_key_pem,
      private_key_pem = tls_private_key.ssh_key.private_key_pem
      username = var.vm_admin
    }
  )
}
# Locate the Packer built image
data "hcp_packer_artifact" "secure-infra-workflow" {
  bucket_name   = var.packer_bucket_name
  channel_name  = var.packer_channel_name
  platform      = var.packer_platform
  region        = "eastus"
}

#Create a VM
resource "azurerm_virtual_network" "example" {
  name                = "${var.vm_name}-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.az_location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "example" {
  name                 = "${var.vm_name}-internal"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "example" {
  name                = "${var.vm_name}-sg01"
  location            = var.az_location
  resource_group_name = var.resource_group

  security_rule {
    #name                       = "internet"
    name = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# resource "azurerm_public_ip" "example2" {
#   name                = "${var.vm_name}-public-ip-01"
#   resource_group_name = var.resource_group
#   location            = var.az_location
#   allocation_method   = "Static"
# }

resource "azurerm_network_interface" "example" {
  name                = "${var.vm_name}-nic"
  location            = var.az_location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "${var.vm_name}-internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id = azurerm_public_ip.example2.id
  }
}
resource "azurerm_linux_virtual_machine" "example" {
  name                = var.vm_name
  resource_group_name = var.resource_group
  location            = var.az_location
  size                = "Standard_F2s_v2"
  source_image_id = data.hcp_packer_artifact.secure-infra-workflow.external_identifier
  admin_username      = var.vm_admin
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]
    identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

#Create HCP credential store
data "boundary_scope" "project" {
  name     = "ssh-project-2"
  scope_id = "o_GtJWfHgyA6"
}

resource "vault_token" "example" {
  policies = ["tfc-vault"]
  no_parent = true
  renewable = true
  period = "24h"
  metadata = {
    "purpose" = "boundary credential store token"
  }
}
resource "boundary_credential_store_vault" "example" {
  name        = "HCP Vault"
  description = "HCP Vault Credential Store"
  address     = var.vault_addr
  namespace = "admin"
  #token       = var.boundary_vault_token
  token = vault_token.example.client_token
  scope_id    = data.boundary_scope.project.id
}

#Create credential libary for the SSH keys
resource "boundary_credential_library_vault" "example" {
  name = "${var.vm_name}-sshkeys"
  description = "VM SSH keys"
  credential_store_id = boundary_credential_store_vault.example.id
  path = vault_kv_secret_v2.example.path
  http_method = "GET"
  credential_type = "ssh_private_key"
  credential_mapping_overrides = {
    private_key_attribute = "private_key_pem"
  }
}

#Add the VM to Boundary
resource "boundary_host_catalog_static" "example" {
  name        = "azure-vm-catalog"
  description = "Azure VM Host Catalog"
  scope_id    = data.boundary_scope.project.id
}
resource "boundary_host_static" "example" {
  name            = "${var.vm_name}"
  host_catalog_id = boundary_host_catalog_static.example.id
  #address         = azurerm_public_ip.example2.ip_address
  address = azurerm_linux_virtual_machine.example.private_ip_address
}

resource "boundary_host_set_static" "example" {
  name = "azure-vm-host-set"
  host_catalog_id = boundary_host_catalog_static.example.id
  host_ids = [
    boundary_host_static.example.id
  ]
  
}
resource "boundary_target" "example" {
  name         = "${var.vm_name}-ssh"
  description  = "${var.vm_name}-SSH"
  type         = "ssh"
  default_port = "22"
  scope_id     = data.boundary_scope.project.id
  host_source_ids = [
    boundary_host_set_static.example.id
  ]
  injected_application_credential_source_ids = [
    boundary_credential_library_vault.example.id
  ]
  egress_worker_filter = "\"azure\" in \"/tags/type\""
  enable_session_recording = true
  storage_bucket_id        = "sb_AJmZf2yShY"
}

#Read the SSH keys in Vault
# vault kv get kv/${var.vm_name}-ssh
#Prove the SSH key is on the VM, use Azure run command
# cat /home/adminuser/.ssh/authorized_keys
#Connect SSH session in Boundary and read the secret placed by Vault Agent
#cat /opt/vault/data/app-secret.txt
#Read the app secret in Vault
#vault kv/app1