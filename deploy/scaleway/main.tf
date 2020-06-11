module "ssh" {
  source          = "../../ssh"
  ssh_key_path    = var.ssh_key_path
  ssh_pubkey_path = var.ssh_pubkey_path
  ssh_keys_dir    = var.ssh_keys_dir
}

module "provider" {
  source = "../../provider/scaleway"

  organization_id = var.scaleway_organization_id
  access_key      = var.scaleway_access_key
  secret_key      = var.scaleway_secret_key
  zone            = var.scaleway_zone
  type            = var.scaleway_type
  image           = var.scaleway_image
  hosts           = var.node_count
  hostname_format = var.hostname_format
  ssh_key_path    = module.ssh.private_key #var.ssh_key_path Override to use predefined key
  ssh_pubkey_path = module.ssh.public_key  #var.ssh_pubkey_path Override to use predefined key
}

module "swap" {
  source = "../../service/swap"

  node_count   = var.node_count
  connections  = module.provider.public_ips
  ssh_key_path = module.ssh.private_key
}

## Comment out if you do not have a domain ###
module "dns" {
  source     = "../../dns/digitalocean"

  node_count  = var.node_count
  token       = var.digitalocean_token
  domain      = var.domain
  public_ips  = module.provider.public_ips
  hostnames   = module.provider.hostnames
  create_zone = var.create_zone
}

module "wireguard" {
  source = "../../security/wireguard"

  node_count   = var.node_count
  connections  = module.provider.public_ips
  private_ips  = module.provider.private_ips
  hostnames    = module.provider.hostnames
  overlay_cidr = module.k3s.overlay_cidr
  ssh_key_path = module.ssh.private_key
}

module "firewall" {
  source = "../../security/ufw"

  node_count           = var.node_count
  connections          = module.provider.public_ips
  private_interface    = module.provider.private_network_interface
  vpn_interface        = module.wireguard.vpn_interface
  vpn_port             = module.wireguard.vpn_port
  overlay_interface    = module.k3s.overlay_interface
  overlay_cidr         = module.k3s.overlay_cidr
  ssh_key_path         = module.ssh.private_key
}

module "k3s" {
  source = "../../service/k3s"

  node_count        = var.node_count
  connections       = module.provider.public_ips
  cluster_name      = var.domain
  vpn_interface     = module.wireguard.vpn_interface #module.provider.private_network_interface
  vpn_ips           = module.wireguard.vpn_ips #module.provider.private_ips
  hostname_format   = var.hostname_format
  ssh_key_path      = module.ssh.private_key
  k3s_version       = var.k3s_version
  cni               = var.cni
  overlay_cidr      = var.overlay_cidr
  kubeconfig_path   = var.kubeconfig_path
  private_ips       = module.provider.private_ips
  private_interface = module.provider.private_network_interface
  domain            = var.domain
  var.ha_cluster    = var.ha_cluster
}

output "private_key" {
  value = abspath(module.ssh.private_key)
}

output "public_key" {
  value = abspath(module.ssh.public_key)
}

output "ssh-master" {
  value = "ssh -i ${abspath(module.ssh.private_key)} -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${try(module.provider.public_ips[0],"localhost")}"
}

output "instances" {
  value = module.provider.nodes
}

output "kubeconfig" {
  value = module.k3s.kubeconfig
}

