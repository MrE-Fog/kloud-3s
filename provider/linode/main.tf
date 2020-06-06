variable "token" {}

variable "hosts" {
  default = 0
}

variable "hostname_format" {
  type = string
}

variable "location" {
  type = string
}

variable "type" {
  type = string
}

variable "image" {
  type = string
}

variable "ssh_keys" {
  type = list
}

provider "linode" {
  token = var.token
}

variable "apt_packages" {
  type    = list
  default = []
}

variable "ssh_key_path" {
  type = string
}

variable "ssh_pubkey_path" {
  type = string
}

resource "linode_sshkey" "tf-kube" {
    count      = fileexists("${var.ssh_pubkey_path}") ? 1 : 0
    label      = "tf-kube"
    #ssh_key    = file("${var.ssh_pubkey_path}")
    ssh_key    = chomp(file(var.ssh_pubkey_path))
}

resource "linode_instance" "host" {
  label           = format(var.hostname_format, count.index + 1)
  region          = var.location
  image           = var.image
  type            = var.type
  authorized_keys = linode_sshkey.tf-kube.*.ssh_key
  private_ip      = true
  swap_size       = 2048
  
  count = var.hosts

  connection {
    user = "root"
    type = "ssh"
    timeout = "2m"
    host = self.ip_address
    agent = false
    private_key = file("${var.ssh_key_path}")
  }

  provisioner "remote-exec" {
    inline = [
      "while fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1; do sleep 1; done",
      "apt-get update",
      "apt-get install -yq jq ufw ${join(" ", var.apt_packages)}",
    ]
  }
}

data "external" "network_interfaces" {

  program = [
  "ssh", 
  "-i", "${abspath(var.ssh_key_path)}", 
  "-o", "IdentitiesOnly=yes",
  "-o", "StrictHostKeyChecking=no", 
  "-o", "UserKnownHostsFile=/dev/null", 
  "root@${linode_instance.host[0].ip_address}",
  "IFACE=$(ip -json addr show scope global | jq -r '.|tostring'); jq -n --arg iface $IFACE '{\"iface\":$iface}';"
  ]

}

output "hostnames" {
  value = "${linode_instance.host.*.label}"
}

output "public_ips" {
  value = "${linode_instance.host.*.ip_address}"
}

output "private_ips" {
  value = "${linode_instance.host.*.private_ip_address}"
}


output "network_interfaces" {
  value = jsondecode(lookup(data.external.network_interfaces.result, "iface"))
}

output "public_network_interface" {
  value = "eth0"
}

output "private_network_interface" {
  value = "eth0"
}

output "linode_servers" {
  value = "${linode_instance.host}"
}