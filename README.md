# Packer LXD - Grafana

### Requirements
* packer 1.6.6 (or earlier supporting hcl2)
* a working lxd installation

### Build
```bash
packer build .
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| grafana\_home | n/a | `string` | `"/var/lib/grafana"` | no |
| grafana\_user | n/a | `string` | `"grafana"` | no |
| grafana\_version | n/a | `string` | `"7.3.6"` | no |
| source | n/a | `map(string)` | <pre>{<br>  "description": "Grafana - Ubuntu 20.04",<br>  "image": "base-ubuntu-focal",<br>  "name": "grafana-ubuntu-focal"<br>}</pre> | no |
