#packer build -var-file="vm-image.pkrvars.hcl" .
packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}
variable "client_id" {
  type      = string
  sensitive = true
}
variable "client_secret" {
  type      = string
  sensitive = true
}
variable "subscription_id" {
  type      = string
  sensitive = true
}
variable "tenant_id" {
  type      = string
  sensitive = true
}
variable "resource_group" {
  type = string
}
variable "image_name" {
  type = string
}
variable "location" {
  type = string
}
#Set a local variable to the current datetime in a readable format
locals {
  current_date = formatdate("YYYYMMDDhhmm", timestamp())
}

source "azure-arm" "ubuntu" {
  azure_tags = {
    installed_agents = "Vault Agent"
  }
  client_id                         = "${var.client_id}"
  client_secret                     = "${var.client_secret}"
  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_publisher                   = "canonical"
  image_sku                         = "22_04-lts-gen2"
  location                          = "${var.location}"
  managed_image_name                = "${var.image_name}-${local.current_date}"
  managed_image_resource_group_name = "${var.resource_group}"
  os_type                           = "linux"
  subscription_id                   = "${var.subscription_id}"
  tenant_id                         = "${var.tenant_id}"
  vm_size                           = "Standard_DS2_v2"
}

build {
  name    = "ubuntu-child-vault-agent"
  sources = ["source.azure-arm.ubuntu"]
  #Register metadata in HCP Packer
  hcp_packer_registry {
    bucket_name = "secure-infra-workflow"
    description = "Ubuntu 22.04 child image with Vault Agent"
    bucket_labels = {
      "installed_agents" = "Vault Agent",
      "os"               = "Ubuntu"
    }
    build_labels = {
      "ubuntu-version" = "Jammy 22.04 LTS Gen2"
      "build-time"     = timestamp()
      "vault-version"  = "1.15.x"
    }
  }
  #Stage Vault
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg",
      "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
      "apt update && sudo apt install vault"
    ]
    inline_shebang = "/bin/sh -x"
  }
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["mkdir /vault"]
  }
  provisioner "file" {
    destination = "/tmp/agent-config.hcl"
    source      = "./agent-config.hcl"
  }
  provisioner "file" {
    destination = "/tmp/app-secret.ctmpl"
    source      = "./app-secret.ctmpl"
  }
  provisioner "file" {
    destination = "/tmp/vault.service"
    source      = "./vault.service"
  }
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["mv /tmp/agent-config.hcl /etc/vault.d"]
  }
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["mv /tmp/app-secret.ctmpl /etc/vault.d"]
  }
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["mv /tmp/vault.service /usr/lib/systemd/system"]
  }
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["systemctl enable vault.service"]
  }
}