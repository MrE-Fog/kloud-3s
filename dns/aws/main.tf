variable "node_count" {}

variable "access_key" {}

variable "secret_key" {}

variable "region" {}

variable "domain" {}

variable "hostnames" {
  type = list(any)
}

variable "public_ips" {
  type = list(any)
}

variable "trform_domain" {
  type        = bool
  default     = false
  description = "Manage the root and wildcard domain using this module."
}

# Configure the AWS Provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

data "aws_route53_zone" "selected_domain" {
  name = "${var.domain}."
}

resource "aws_route53_record" "hosts" {
  count = var.node_count

  zone_id = data.aws_route53_zone.selected_domain.zone_id
  name    = "${element(var.hostnames, count.index)}.${data.aws_route53_zone.selected_domain.name}"
  type    = "A"
  ttl     = "300"
  records = [element(var.public_ips, count.index)]
}

resource "aws_route53_record" "domain" {
  count   = var.trform_domain && var.node_count > 0 ? 1 : 0
  zone_id = data.aws_route53_zone.selected_domain.zone_id

  name    = data.aws_route53_zone.selected_domain.name
  type    = "A"
  ttl     = "300"
  records = [element(var.public_ips, 0)]
}

resource "aws_route53_record" "wildcard" {
  depends_on = ["aws_route53_record.domain"]

  count   = var.trform_domain && var.node_count > 0 ? 1 : 0
  zone_id = data.aws_route53_zone.selected_domain.zone_id
  name    = "*"
  type    = "CNAME"
  ttl     = "300"
  records = [data.aws_route53_zone.selected_domain.name]
}

output "domains" {
  value = aws_route53_record.hosts.*.name
}

output "dns_auth" {
  sensitive = true
  value = {
    provider   = "aws"
    domain     = var.domain
    access_key = var.access_key
    secret_key = var.secret_key
    region     = var.region
  }
}
