module "ssh" {
  source          = "./ssh"
  ssh_key_path    = var.ssh_key_path
  ssh_pubkey_path = var.ssh_pubkey_path
  ssh_keys_dir    = var.ssh_keys_dir
}

module "provider" {
  source = "./provider/digitalocean"

  token           = var.digitalocean_token
  ssh_keys        = var.digitalocean_ssh_keys
  region          = var.digitalocean_region
  size            = var.digitalocean_size
  image           = var.digitalocean_image
  hosts           = var.node_count
  hostname_format = var.hostname_format
  ssh_key_path    = module.ssh.private_key #var.ssh_key_path Override to use predefined key
  ssh_pubkey_path = module.ssh.public_key  #var.ssh_pubkey_path Override to use predefined key
}

module "swap" {
  source = "./service/swap"

  node_count   = var.node_count
  connections  = module.provider.public_ips
  ssh_key_path = module.ssh.private_key
}


module "dns" {
  source     = "./dns/digitalocean"

  node_count = var.node_count
  token      = var.digitalocean_token
  domain     = var.domain
  public_ips = module.provider.public_ips
  hostnames  = module.provider.hostnames
}

module "wireguard" {
  source = "./security/wireguard"

  node_count   = var.node_count
  connections  = module.provider.public_ips
  private_ips  = module.provider.private_ips
  hostnames    = module.provider.hostnames
  overlay_cidr = module.k3s.overlay_cidr
  ssh_key_path = module.ssh.private_key
}

module "firewall" {
  source = "./security/ufw"

  node_count           = var.node_count
  connections          = module.provider.public_ips
  private_interface    = module.provider.private_network_interface
  vpn_interface        = module.wireguard.vpn_interface
  vpn_port             = module.wireguard.vpn_port
  kubernetes_interface = module.k3s.overlay_interface
  ssh_key_path         = module.ssh.private_key
}

module "k3s" {
  source = "./service/k3s"

  node_count        = var.node_count
  connections       = module.provider.public_ips
  cluster_name      = var.domain
  vpn_interface     = module.wireguard.vpn_interface
  vpn_ips           = module.wireguard.vpn_ips
  hostname_format   = var.hostname_format
  ssh_key_path      = module.ssh.private_key
  k3s_version       = var.k3s_version
  overlay_interface = "tun10"
  overlay_cidr      = "10.42.0.0/15"
  kubeconfig_path   = var.kubeconfig_path
}
