/* general */
variable "node_count" {
  default = 3
}

/* etcd_node_count must be <= node_count; odd numbers provide quorum */
variable "etcd_node_count" {
  default = 3
}

variable "domain" {
  default = "kloud3s.io"
}

variable "hostname_format" {
  default = "kube%d"
}

variable "ssh_key_path" {
  default = "../../.ssh/tf-kube"
}

variable "ssh_pubkey_path" {
  default = "../../.ssh/tf-kube.pub"
}

variable "ssh_keys_dir" {
  default = "../../.ssh"
}

variable "k3s_version" {
  default = "latest"
}

variable "kubeconfig_path" {
  default = "../../.kubeconfig"
}

variable "create_zone" {
  default = false
}

variable "cni" {
  default     = "cilium"
  description = "Choice of CNI to install e.g. flannel, weave, cilium, calico"
}

variable "overlay_cidr" {
  default     = "10.42.0.0/16"
  description = "Cluster pod cidr"
}

variable "service_cidr" {
  default     = "10.43.0.0/16"
  description = "Cluster service cidr"
}

variable "ha_cluster" {
  default     = false
  description = "Create highly available cluster. Currently experimental and requires node_count >= 3"
}

variable "trform_domain" {
  type        = bool
  default     = false
  description = "Manage this domain and it's wildcard domain using terraform."
}

variable "test-traefik" {
  type        = bool
  default     = true
  description = "Deploy traefik test."
}

variable "create_certs" {
  type        = bool
  default     = false
  description = "Option to create letsencrypt certs. Only enable if certain that your deployment is reachable."
}

variable "longhorn_replicas" {
  default     = 3
  description = "Number of longhorn replicas"
}

variable "install_app" {
  description = "Additional apps to Install"
  type        = map
  default = {
    kubernetes_dashboard = true
    kube_prometheus      = false
    k8dash               = false
    elastic_cloud        = false
    longhorn             = false
  }
}

variable "additional_rules" {
  type        = list(string)
  default     = []
  description = "add custom firewall rules during provisioning e.g. allow 1194/udp, allow ftp"
}

variable "auth_user" {
  default     = "kloud-3s"
  description = "Traefik basic auth username"
}

variable "auth_password" {
  default     = ""
  description = "Traefik basic auth password"
}

variable "registry_user" {
  default     = "kloud-3s"
  description = "Trow Registry username"
}

variable "registry_password" {
  default     = ""
  description = "Trow Registry password"
}

variable "apt_packages" {
  type        = list
  default     = []
  description = "Additional packages to install"
}

variable "oidc_config" {
  type        = list(map(string))
  description = "OIDC Configuration for protecting private resources. Used by Pomerium IAP & Vault."
  default     = []
}

variable "mail_config" {
  type        = map(string)
  description = "SMTP Configuration for email services."
  default     = {}
}

/* google */

variable "google_region_zone" {
  default = "us-central1-a"
}

variable "google_size" {
  default = "g1-small"
}

variable "google_image" {
  default = "ubuntu-os-cloud/ubuntu-2004-focal-v20201111"
}

/* digitalocean dns */
variable "digitalocean_token" {
  default = ""
}

/* aws dns */
variable "aws_access_key" {
  default = ""
}

variable "aws_secret_key" {
  default = ""
}

variable "aws_region" {
  default = "eu-west-1"
}

/* cloudflare dns */
variable "cloudflare_email" {
  default = ""
}

variable "cloudflare_api_token" {
  default = ""
}

/* google dns */
variable "google_project" {
  default = ""
}

variable "google_region" {
  default = "us-central1"
}

variable "google_managed_zone" {
  default = ""
}

variable "google_credentials_file" {
  default = ""
}
