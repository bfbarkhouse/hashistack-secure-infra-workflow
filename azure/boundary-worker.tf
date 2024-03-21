resource "azurerm_container_group" "container" {
  name                = "boundary-worker-group"
  location            = var.az_location
  resource_group_name = var.resource_group
  ip_address_type     = "Public"
  os_type             = "Linux"
  restart_policy      = "Never"

  container {
    name   = "boundary-worker"
    image  = "hashicorp/boundary-enterprise"
    cpu    = 1
    memory = 2

    ports {
      port     = 9202
      protocol = "TCP"
    }
    volume {
      name = "boundary-config"
      mount_path = "/tmp/boundary-config"
      git_repo {
        url = "https://github.com/bfbarkhouse/hashistack-secure-infra-workflow"
      }
    }
    commands = [
        "mv /tmp/boundary-config/hashistack-secure-infra-workflow/azure/boundary-worker.hcl /boundary/config.hcl",
        "rm -rf /tmp/boundary-config",
        "boundary-enterprise"
        ] 
  }
}