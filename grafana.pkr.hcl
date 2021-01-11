// Variables
variable "packages" {
  type    = list(string)
  default = [
    "apt-transport-https",
    "curl",
    "nginx",
    "software-properties-common",
    "unzip"
  ]
}

variable "node_exporter_version" {
  type    = string
  default = "1.0.1"
}

variable "grafana_home" {
  type    = string
  default = "/var/lib/grafana"
}

variable "grafana_version" {
  type    = string
  default = "7.3.6"
}

variable "grafana_user" {
  type    = string
  default = "grafana"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

// Image
source "lxd" "grafana-ubuntu-focal" {
  image        = "images:ubuntu/focal"
  output_image = "grafana-ubuntu-focal"
  publish_properties = {
    description = "Hashicorp Grafana - Ubuntu Focal"
  }
}

// Build
build {
  sources = ["source.lxd.grafana-ubuntu-focal"]

  // Update and install packages
  provisioner "shell" {
    inline = [
      "apt-get update -qq",
      "DEBIAN_FRONTEND=noninteractive apt-get install -qq ${join(" ", var.packages)} < /dev/null > /dev/null"
    ]
  }

  // Install node_exporter
  provisioner "shell" {
    inline = [
      "curl -sLo - https://github.com/prometheus/node_exporter/releases/download/v${var.node_exporter_version}/node_exporter-${var.node_exporter_version}.linux-amd64.tar.gz | \n",
      "tar -zxf - --strip-component=1 -C /usr/local/bin/ node_exporter-${var.node_exporter_version}.linux-amd64/node_exporter"
    ]
  }

  // Create directories for Grafana
  provisioner "shell" {
    inline = [
      "mkdir -p /etc/nginx/tls ${var.grafana_home}"
    ]
  }

  // Create Grafana system user
  provisioner "shell" {
    inline = [
      "useradd --system --home ${var.grafana_home} --shell /bin/false ${var.grafana_user}"
    ]
  }

  // Create self-signed certificate
  provisioner "shell" {
    inline = [
      "openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout /etc/grafana/tls/server.key -out /etc/grafana/tls/server.crt -subj \"/CN=grafana\""
    ]
  }

  // Install Grafana
  provisioner "shell" {
    inline = [
      "curl -so - https://packages.grafana.com/gpg.key | apt-key add -",
      "echo \"deb https://packages.grafana.com/oss/deb stable main\" | sudo tee -a /etc/apt/sources.list.d/grafana.list",
      "apt-get update -qq",
      "DEBIAN_FRONTEND=noninteractive apt-get install -qq grafana=${var.grafana_version} < /dev/null > /dev/null"
    ]
  }

  // Set file ownership and enable the service
  provisioner "shell" {
    inline = [
      "chown -R ${var.grafana_user} ${var.grafana_home}",
      "systemctl enable grafana-server"
    ]
  }
}
