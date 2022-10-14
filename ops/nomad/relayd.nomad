job "relayd" {
  datacenters = ["us-east-1"]

  group "app" {
    count = 2

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

    service {
      name     = "relayd-epmd"
      provider = "nomad"
      port     = "epmd"
      address  = "${attr.unique.platform.aws.public-ipv4}"
    }

    task "app" {
      driver = "docker"

      config {
        image = "mnomitch/relayd:0.0.3"
        ports = ["http", "epmd"]

        command = "elixir"
        args = [
          "--name", "relayd@${attr.unique.platform.aws.public-ipv4}",
          "-kernel", "inet_dist_listen_min", "9001",
          "-kernel", "inet_dist_listen_max", "9001",
          "-S",
          "mix",
          "phx.server",
        ]
      }

      env {
        PORT            = "${NOMAD_PORT_http}"
        DATABASE_URL    = "postgresql://postgres:postgres@host.docker.internal/relayd_dev"
        SECRET_KEY_BASE = "9bhPzyt2a7QLFKecq0o8YTlKtpMk77Q4Sg1FxOZzGCao/+HZ4Eos637DGK0M4m2K"
      }

      template {
        data = <<EOF

{{- with nomadVar "nomad/jobs/relayd" -}}
NOMAD_ADDR=.address
NOMAD_TOKEN=.token
{{- end -}}
EOF

        destination = "secrets/file.env"
        change_mode = "restart"
        env         = true
      }
    }
  }
}
