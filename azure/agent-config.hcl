pid_file = "/opt/vault/data/pidfile"

vault {
  #address read from /etc/vault.d/vault.env
}

auto_auth {
  method {
    type = "azure"
    namespace = "admin"
    config = {
      authenticate_from_environment = true
      role = "vault-role"
      resource = "https://management.azure.com/"
    }
  }

  sink {
    type = "file"
    wrap_ttl = "30m"
    config = {
      path = "/opt/vault/data/vault-sink"
    }
  }
}

listener "tcp" {
  address = "127.0.0.1:8100"
  tls_disable = true
}

template_config {
  static_secret_render_interval = "10m"
}

template {
  source      = "/etc/vault.d/app-secret.ctmpl"
  destination = "/opt/vault/data/app-secret.txt"
}

