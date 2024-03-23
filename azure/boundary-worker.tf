resource "azurerm_subnet" "cg" {
  name                 = "container-group-subnet"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.3.0/24"]
  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }

}

resource "azurerm_container_group" "container" {
  name                = "boundary-worker-group"
  location            = var.az_location
  resource_group_name = var.resource_group
  #ip_address_type     = "Public"
  ip_address_type = "Private"
  subnet_ids      = [azurerm_subnet.cg.id]
  os_type         = "Linux"
  restart_policy  = "Never"

  container {
    name   = "boundary-worker"
    image  = "hashicorp/boundary-enterprise"
    cpu    = 1
    memory = 2

    ports {
      port     = 9202
      protocol = "TCP"
    }
    environment_variables = { "HCP_BOUNDARY_CLUSTER_ID" = var.hcp_boundary_cluster_id }
    volume {
      name       = "boundary-config"
      mount_path = "/boundary"
      git_repo {
        url = "https://github.com/bfbarkhouse/hashistack-secure-infra-workflow"
      }
    }
    commands = [
      "/bin/sh", "-c", "mv /boundary/hashistack-secure-infra-workflow/azure/boundary-worker-config.hcl /boundary/config.hcl; rm -rf /boundary/hashistack-secure-infra-workflow; /usr/local/bin/docker-entrypoint.sh server -config /boundary/config.hcl"
    ]
  }
}