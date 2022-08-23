job "relayd" {
  datacenters = ["us-east-1"]

  group "phoenix" {
    count = 1

    network {
      port "http" {
        static = 4000
        to     = 4000
      }

      port "epmd" {
        static = 4369
        to     = 4369
      }
    }

    service {
      name     = "relayd"
      provider = "nomad"
      port     = "http"
      address  = "${attr.unique.platform.aws.public-ipv4}"
    }

    task "app" {
      driver = "docker"

      config {
        image = "mnomitch/relayd"
        ports = ["http", "epmd"]
      }

      env {
        PORT            = "${NOMAD_PORT_http}"
        DATABASE_URL    = "postgresql://postgres:postgres@host.docker.internal/relayd_dev"
        SECRET_KEY_BASE = "9bhPzyt2a7QLFKecq0o8YTlKtpMk77Q4Sg1FxOZzGCao/+HZ4Eos637DGK0M4m2K"
      }
    }
  }
}
