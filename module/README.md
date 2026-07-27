# tf-ntnx-nkp

## Table of Contents

## Overview

A description of the module goes here.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_nutanix"></a> [nutanix](#requirement\_nutanix) | >= 2.4.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_nutanix"></a> [nutanix](#provider\_nutanix) | 2.4.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [nutanix_clusters_v2.this](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/clusters_v2) | data source |
| [nutanix_storage_containers_v2.this](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/storage_containers_v2) | data source |
| [nutanix_subnets_v2.this](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/subnets_v2) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_ssh_keys"></a> [bastion\_ssh\_keys](#input\_bastion\_ssh\_keys) | List of SSH public keys for Bastion host access | `list(string)` | `[]` | no |
| <a name="input_bundle_paths"></a> [bundle\_paths](#input\_bundle\_paths) | List of local tarball bundle paths for air-gapped deployment | `list(string)` | `[]` | no |
| <a name="input_ca_certificates"></a> [ca\_certificates](#input\_ca\_certificates) | List of PEM-encoded CA certificates to inject into the Bastion host trust store | `list(string)` | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the NKP management cluster | `string` | n/a | yes |
| <a name="input_control_plane_subnet"></a> [control\_plane\_subnet](#input\_control\_plane\_subnet) | Nutanix subnet name/UUID for control plane nodes | `string` | n/a | yes |
| <a name="input_control_plane_vip"></a> [control\_plane\_vip](#input\_control\_plane\_vip) | Static VIP for Kubernetes control plane | `string` | n/a | yes |
| <a name="input_control_plane_vm_image"></a> [control\_plane\_vm\_image](#input\_control\_plane\_vm\_image) | Nutanix OS VM Image name for control plane nodes | `string` | n/a | yes |
| <a name="input_csi_storage_container"></a> [csi\_storage\_container](#input\_csi\_storage\_container) | Nutanix Storage Container name for CSI persistent volumes | `string` | n/a | yes |
| <a name="input_load_balancer_ip_range"></a> [load\_balancer\_ip\_range](#input\_load\_balancer\_ip\_range) | MetalLB IP range (e.g. 192.168.82.20-192.168.82.39) | `string` | n/a | yes |
| <a name="input_nutanix_password"></a> [nutanix\_password](#input\_nutanix\_password) | Nutanix Prism Central Password | `string` | `null` | no |
| <a name="input_nutanix_username"></a> [nutanix\_username](#input\_nutanix\_username) | Nutanix Prism Central Username | `string` | `null` | no |
| <a name="input_pod_cidr"></a> [pod\_cidr](#input\_pod\_cidr) | Kubernetes Pod Network CIDR (must match 172.20.0.0/16) | `string` | `"172.20.0.0/16"` | no |
| <a name="input_prism_central_endpoint"></a> [prism\_central\_endpoint](#input\_prism\_central\_endpoint) | Prism Central FQDN or IP address | `string` | n/a | yes |
| <a name="input_prism_element_cluster"></a> [prism\_element\_cluster](#input\_prism\_element\_cluster) | Name of the target Prism Element cluster | `string` | n/a | yes |
| <a name="input_profile"></a> [profile](#input\_profile) | Environment profile ('small' for lab 3-worker footprint, 'full' for 4-worker Ultimate footprint) | `string` | `"small"` | no |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | Kubernetes Service Network CIDR | `string` | `"10.96.0.0/12"` | no |
| <a name="input_worker_subnet"></a> [worker\_subnet](#input\_worker\_subnet) | Nutanix subnet name/UUID for worker nodes | `string` | n/a | yes |
| <a name="input_worker_vm_image"></a> [worker\_vm\_image](#input\_worker\_vm\_image) | Nutanix OS VM Image name for worker nodes | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_cloud_init"></a> [bastion\_cloud\_init](#output\_bastion\_cloud\_init) | Rendered Bastion VM cloud-init user-data YAML string |
| <a name="output_bootstrap_script"></a> [bootstrap\_script](#output\_bootstrap\_script) | Rendered nkp create cluster nutanix shell script |
| <a name="output_nkp_summary"></a> [nkp\_summary](#output\_nkp\_summary) | Summary of NKP cluster configuration. |
| <a name="output_outputs"></a> [outputs](#output\_outputs) | Aggregate of all module outputs (spec §7.6 contract, consumed by the landing zone as module.<x>.outputs). |
| <a name="output_prerequisites"></a> [prerequisites](#output\_prerequisites) | Map of validated Nutanix cluster, subnet, and container prerequisites. |
| <a name="output_upgrade_script"></a> [upgrade\_script](#output\_upgrade\_script) | Rendered 6-step nkp upgrade shell script |
<!-- END_TF_DOCS -->
