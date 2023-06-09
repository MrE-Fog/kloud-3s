variable "api_key" {}

variable "hosts" {
  default = 0
}

variable "hostname_format" {
  type = string
}

variable "region" {
  type = string
}

variable "plan" {
  type = string
}

variable "os" {
  type = string
}

variable "ssh_keys" {
  type = list(any)
}

variable "vpc_cidr" {
  default = "10.115.0.0/24"
}

resource "time_static" "id" {}

terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "~> 1.5.0"
    }
  }
}

provider "vultr" {
  api_key     = var.api_key
  rate_limit  = 700
  retry_limit = 3
}

variable "apt_packages" {
  type    = list(any)
  default = []
}

variable "ssh_key_path" {
  type = string
}

variable "ssh_pubkey_path" {
  type = string
}

data "vultr_region" "region" {
  filter {
    name   = "name"
    values = [var.region]
  }
}

data "vultr_plan" "plan" {
  filter {
    name   = "name"
    values = [var.plan]
  }
}

data "vultr_os" "os" {
  filter {
    name   = "name"
    values = [var.os]
  }
}


resource "vultr_ssh_key" "tf-kube" {
  name    = "tf-kube-${time_static.id.unix}"
  ssh_key = file(var.ssh_pubkey_path)
  lifecycle {
    ignore_changes = [
      ssh_key
    ]
  }
}

resource "vultr_server" "host" {
  hostname               = format(var.hostname_format, count.index + 1)
  label                  = format(var.hostname_format, count.index + 1)
  region_id              = data.vultr_region.region.id
  os_id                  = data.vultr_os.os.id
  plan_id                = data.vultr_plan.plan.id
  ssh_key_ids            = [vultr_ssh_key.tf-kube.id]
  network_ids            = [vultr_network.kube-vpc.id]
  enable_private_network = true

  count = var.hosts

  connection {
    user        = "root"
    type        = "ssh"
    timeout     = "2m"
    host        = self.main_ip
    agent       = false
    private_key = file(var.ssh_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "while fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1; do sleep 1; done",
      "hostnamectl set-hostname ${self.label}",
      "apt-get update",
      "apt-get install -yq net-tools jq ufw wireguard-tools wireguard open-iscsi nfs-common ${join(" ", var.apt_packages)}",
    ]
  }

  # Set up private interface
  provisioner "remote-exec" {
    inline = [<<EOT
INSTANCE_METADATA=$(curl --silent http://169.254.169.254/v1.json);
PRIVATE_IP=$(curl --silent http://169.254.169.254/v1.json | jq -r .interfaces[1].ipv4.address);
PUBLIC_MAC=$(curl --silent http://169.254.169.254/v1.json | jq -r '.interfaces[] | select(.["network-type"]=="public") | .mac');
PRIVATE_MAC=$(curl --silent http://169.254.169.254/v1.json | jq -r '.interfaces[] | select(.["network-type"]=="private") | .mac');
cat <<-EOF > /etc/systemd/network/public.network
  [Match]
  MACAddress=$PUBLIC_MAC
  [Network]
  DHCP=yes
EOF
cat <<-EOF > /etc/systemd/network/private.network
  [Match]
  MACAddress=$PRIVATE_MAC
  [Network]
  Address=$PRIVATE_IP/24
EOF
systemctl restart systemd-networkd systemd-resolved;
ip -o addr show scope global | awk '{split($4, a, "/"); print $2" : "a[1]}';
    EOT
    ]
  }

}
/*
data "external" "network_interfaces" {
  count   = var.hosts > 0 ? 1 : 0
  program = [
  "ssh", 
  "-i", "${abspath(var.ssh_key_path)}", 
  "-o", "IdentitiesOnly=yes",
  "-o", "StrictHostKeyChecking=no", 
  "-o", "UserKnownHostsFile=/dev/null", 
  "root@${vultr_server.host[0].main_ip}",
  "IFACE=$(ip -json addr show scope global | jq -r '.|tostring'); jq -n --arg iface $IFACE '{\"iface\":$iface}';"
  ]

}
*/
output "hostnames" {
  value = vultr_server.host.*.label
}

output "public_ips" {
  value = vultr_server.host.*.main_ip
}

output "private_ips" {
  value = vultr_server.host.*.internal_ip
}
/*
output "network_interfaces" {
  value = var.hosts > 0 ? lookup(data.external.network_interfaces[0].result, "iface") : ""
}
*/
output "public_network_interface" {
  value = "ens3"
}

output "private_network_interface" {
  value = "ens7"
}

output "vultr_servers" {
  value = vultr_server.host
}

output "region" {
  value = data.vultr_region.region.regioncode
}

output "nodes" {

  value = [for index, server in vultr_server.host : {
    hostname   = server.hostname
    public_ip  = server.main_ip,
    private_ip = server.internal_ip,
  }]

}