## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_rules | add custom firewall rules during provisioning e.g. allow 1194/udp, allow ftp | `list(string)` | `[]` | no |
| apt\_packages | Additional packages to install | `list(any)` | `[]` | no |
| auth\_password | Traefik basic auth password | `string` | `""` | no |
| auth\_user | Traefik basic auth username | `string` | `"kloud-3s"` | no |
| aws\_access\_key | n/a | `string` | `""` | no |
| aws\_region | n/a | `string` | `"eu-west-1"` | no |
| aws\_secret\_key | n/a | `string` | `""` | no |
| azure\_image | n/a | `string` | `"20.04-LTS"` | no |
| azure\_region | n/a | `string` | `"West Europe"` | no |
| azure\_size | n/a | `string` | `"Standard_B1ms"` | no |
| client\_id | n/a | `string` | `""` | no |
| client\_secret | n/a | `string` | `""` | no |
| cloudflare\_api\_token | n/a | `string` | `""` | no |
| cloudflare\_email | n/a | `string` | `""` | no |
| cni | Choice of CNI to install e.g. flannel, weave, cilium, calico | `string` | `"cilium"` | no |
| create\_certs | Option to create letsencrypt certs. Only enable if certain that your deployment is reachable. | `bool` | `false` | no |
| create\_zone | n/a | `bool` | `false` | no |
| digitalocean\_token | n/a | `string` | `""` | no |
| domain | n/a | `string` | `"kloud3s.io"` | no |
| enable\_floatingip | Whether to use a floating ip or not | `bool` | `false` | no |
| enable\_volumes | Whether to use volumes or not | `bool` | `false` | no |
| etcd\_node\_count | n/a | `number` | `3` | no |
| google\_credentials\_file | n/a | `string` | `""` | no |
| google\_managed\_zone | n/a | `string` | `""` | no |
| google\_project | n/a | `string` | `""` | no |
| google\_region | n/a | `string` | `""` | no |
| ha\_cluster | Create highly available cluster. Currently experimental and requires node\_count >= 3 | `bool` | `false` | no |
| ha\_nodes | Number of controller nodes for HA cluster. Must be greater than 3 and odd-numbered. | `number` | `3` | no |
| hostname\_format | n/a | `string` | `"kube%d"` | no |
| install\_app | Additional apps to Install | `map(any)` | <pre>{<br>  "elastic_cloud": false,<br>  "k8dash": false,<br>  "kube_prometheus": false,<br>  "kubernetes_dashboard": true,<br>  "longhorn": false<br>}</pre> | no |
| k3s\_version | n/a | `string` | `"latest"` | no |
| kubeconfig\_path | n/a | `string` | `"../../.kubeconfig"` | no |
| loadbalancer | How LoadBalancer IPs are assigned. Options are metallb(default), traefik, ccm, kube-vip & akrobateo | `string` | `"metallb"` | no |
| mail\_config | SMTP Configuration for email services. | `map(string)` | `{}` | no |
| node\_count | n/a | `number` | `3` | no |
| oidc\_config | OIDC Configuration for protecting private resources. Used by Pomerium IAP & Vault. | `list(map(string))` | `[]` | no |
| overlay\_cidr | Cluster pod cidr | `string` | `"10.42.0.0/16"` | no |
| registry\_password | Trow Registry password | `string` | `""` | no |
| registry\_user | Trow Registry username | `string` | `"kloud-3s"` | no |
| service\_cidr | Cluster service cidr | `string` | `"10.43.0.0/16"` | no |
| ssh\_key\_path | n/a | `string` | `"../../.ssh/tf-kube"` | no |
| ssh\_keys\_dir | n/a | `string` | `"../../.ssh"` | no |
| ssh\_pubkey\_path | n/a | `string` | `"../../.ssh/tf-kube.pub"` | no |
| subscription\_id | n/a | `string` | `""` | no |
| tenant\_id | n/a | `string` | `""` | no |
| test-traefik | Deploy traefik test. | `bool` | `true` | no |
| trform\_domain | Manage this domain and it's wildcard domain using terraform. | `bool` | `false` | no |
| volume\_size | Volume size in GB | `number` | `10` | no |
| vpc\_cidr | CIDR for nodes provider vpc if available | `string` | `"10.115.0.0/24"` | no |
| vpn\_iprange | CIDR for nodes wireguard vpn | `string` | `"10.0.1.0/24"` | no |

## Outputs

| Name | Description |
|------|-------------|
| default\_password | n/a |
| floating\_ip | n/a |
| instances | n/a |
| kubeconfig | n/a |
| private\_key | n/a |
| public\_key | n/a |
| ssh-master | n/a |
| test | n/a |