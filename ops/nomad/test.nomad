job "inner" {
  datacenters = ["dc1"]

  group "service" {
    count = 1

    network {
      port "http" {}
    }

    service {
      name     = "relayd"
      provider = "nomad"
      port     = "http"
    }

    task "env-reader" {
      driver = "docker"

      config {
        image = "mnomitch/env-reader"
        ports = ["http"]
      }

      env {
        PORT  = "${NOMAD_PORT_http}"
        VAR_A = "Hello,"
        VAR_B = "Traefik & Nomad Fans!"
      }
    }
  }
}
