// Image
source "lxd" "main" {
  image        = "${var.source.image}"
  output_image = "${var.source.name}"
  publish_properties = {
    description = "${var.source.description}"
  }
}

// Build
build {
  sources = ["source.lxd.main"]

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

  // Install Grafana
  provisioner "shell" {
    inline = [
      "curl -so - https://packages.grafana.com/gpg.key | apt-key add -",
      "echo \"deb https://packages.grafana.com/oss/deb stable main\" | sudo tee -a /etc/apt/sources.list.d/grafana.list",
      "apt-get update -qq",
      "DEBIAN_FRONTEND=noninteractive apt-get install -qq grafana=${var.grafana_version} nginx < /dev/null > /dev/null"
    ]
  }
  // Add Grafana provisioning config
  provisioner "file" {
    source      = "files/etc/grafana/provisioning"
    destination = "/etc/grafana/"
  }

  provisioner "file" {
    source      = "files/var/lib/grafana/dashboards"
    destination = "/var/lib/grafana/"
  }

  // Add Grafana Nginx config
  provisioner "file" {
    source      = "files/etc/nginx/sites-available"
    destination = "/etc/nginx/"
  }

  // Enable Grafana Nginx config
  provisioner "shell" {
    inline = [
      "ln -s /etc/nginx/sites-available/grafana /etc/nginx/sites-enabled/grafana"
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
