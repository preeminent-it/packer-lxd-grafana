variable "source" {
  type = map(string)
  default = {
    description = "Grafana - Ubuntu 20.04"
    image       = "base-ubuntu-focal"
    name        = "grafana-ubuntu-focal"
  }
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
