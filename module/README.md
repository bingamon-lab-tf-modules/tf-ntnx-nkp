# tf-ntnx-nkp

## Table of Contents

## Overview

A description of the module goes here.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_nutanix"></a> [nutanix](#requirement\_nutanix) | ~> 2.4.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_nutanix"></a> [nutanix](#provider\_nutanix) | 2.4.2 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [terraform_data.validation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [nutanix_clusters_v2.this](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/clusters_v2) | data source |
| [nutanix_images_v2.this](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/images_v2) | data source |
| [nutanix_storage_containers_v2.this](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/storage_containers_v2) | data source |
| [nutanix_subnets_v2.this](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/subnets_v2) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_airgap"></a> [airgap](#input\_airgap) | Air-gap artefact paths on the bastion. Both are mandatory: this module only renders air-gapped installs. Entries may be absolute, or relative to ${cache\_dir} — see below. | <pre>object({<br/>    bundles                 = list(string)<br/>    bootstrap_cluster_image = string<br/>  })</pre> | n/a | yes |
| <a name="input_bastion"></a> [bastion](#input\_bastion) | Bastion the lz-cli hook connects to. host is a DNS name or IP typed by the operator. cache\_root and run\_root are generic per-host roots; this module namespaces itself underneath them. | <pre>object({<br/>    host         = string<br/>    user         = optional(string, "linadmin")<br/>    cache_root   = optional(string, "/var/tmp/lz-cli/cache")<br/>    run_root     = optional(string, "/run/lz-cli")<br/>    min_free_gib = optional(number, 60)<br/>  })</pre> | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the NKP management cluster. Prefixes every created Nutanix resource. | `string` | n/a | yes |
| <a name="input_control_plane"></a> [control\_plane](#input\_control\_plane) | Control-plane pool. prism\_element\_cluster/subnets/vm\_image fall back to var.placement when null. | <pre>object({<br/>    endpoint_ip               = string<br/>    replicas                  = optional(number, 3)<br/>    vcpus                     = optional(number, 4)<br/>    cores_per_vcpu            = optional(number, 1)<br/>    memory_gib                = optional(number, 16)<br/>    disk_size_gib             = optional(number, 80)<br/>    endpoint_port             = optional(number, 6443)<br/>    external_endpoint         = optional(string, null)<br/>    renew_certificates_before = optional(number, 180)<br/>    prism_element_cluster     = optional(string, null)<br/>    subnets                   = optional(list(string), null)<br/>    vm_image                  = optional(string, null)<br/>    pc_categories             = optional(list(string), [])<br/>    pc_project                = optional(string, null)<br/>  })</pre> | n/a | yes |
| <a name="input_csi"></a> [csi](#input\_csi) | Nutanix CSI settings for the default storage class. | <pre>object({<br/>    storage_container           = string<br/>    file_system                 = optional(string, "ext4")<br/>    reclaim_policy              = optional(string, "Delete")<br/>    hypervisor_attached_volumes = optional(bool, true)<br/>    flash_mode                  = optional(bool, false)<br/>  })</pre> | n/a | yes |
| <a name="input_enable_data_lookups"></a> [enable\_data\_lookups](#input\_enable\_data\_lookups) | Resolve the Prism Element cluster, subnets, storage container and node image at plan time. | `bool` | `true` | no |
| <a name="input_enforce_validation"></a> [enforce\_validation](#input\_enforce\_validation) | Fail the plan when validation errors exist. Test seam only — leave true in every real configuration. | `bool` | `true` | no |
| <a name="input_extra_args"></a> [extra\_args](#input\_extra\_args) | Additional raw nkp flags. Module-owned flags are refused. | `list(string)` | `[]` | no |
| <a name="input_gitops"></a> [gitops](#input\_gitops) | GitOps handoff to nkp-platform. Deferred: setting enabled = true is refused until the mechanism is verified. | <pre>object({<br/>    enabled = optional(bool, false)<br/>    url     = optional(string, null)<br/>    branch  = optional(string, "main")<br/>    path    = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Ingress TLS. Paths are on the bastion; the private key is injected by the hook, never an input. | <pre>object({<br/>    ca          = optional(string, null)<br/>    certificate = optional(string, null)<br/>    acme_email  = optional(string, null)<br/>    acme_server = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_misc"></a> [misc](#input\_misc) | Assorted cluster settings that map 1:1 onto nkp flags. | <pre>object({<br/>    ntp_servers                              = optional(list(string), [])<br/>    fips                                     = optional(bool, false)<br/>    extra_sans                               = optional(list(string), [])<br/>    cluster_hostname                         = optional(string, null)<br/>    onboard_to_prism_central                 = optional(bool, true)<br/>    timeout                                  = optional(string, "60m")<br/>    capi_additional_sync_machine_labels      = optional(string, null)<br/>    capi_additional_sync_machine_annotations = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_networking"></a> [networking](#input\_networking) | Pod/service CIDRs and the MetalLB range. Overlaps are checked at plan (see checks in main.tf). | <pre>object({<br/>    load_balancer_ip_range = string<br/>    pod_cidr               = optional(string, "172.20.0.0/16")<br/>    service_cidr           = optional(string, "172.21.0.0/16")<br/>  })</pre> | n/a | yes |
| <a name="input_placement"></a> [placement](#input\_placement) | Default Nutanix placement for both node pools. Names, not UUIDs — resolved and validated at plan. | <pre>object({<br/>    prism_element_cluster = string<br/>    subnets               = list(string)<br/>    vm_image              = string<br/>  })</pre> | n/a | yes |
| <a name="input_prism_central"></a> [prism\_central](#input\_prism\_central) | Prism Central connection. `user` NAMES the account (nkp-capx per lz-paas ADR 0020); its password is injected by the hook, never held here. | <pre>object({<br/>    endpoint                = string<br/>    user                    = string<br/>    port                    = optional(number, 9440)<br/>    insecure                = optional(bool, true)<br/>    additional_trust_bundle = optional(string, null)<br/>  })</pre> | n/a | yes |
| <a name="input_proxy"></a> [proxy](#input\_proxy) | Egress proxy for CAPI controllers and nodes. Normally unset in a true air gap. | <pre>object({<br/>    http     = optional(string, null)<br/>    https    = optional(string, null)<br/>    no_proxy = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_registry"></a> [registry](#input\_registry) | Container registry / mirror. Passwords are never inputs; they are named in the contract's secret\_env. | <pre>object({<br/>    url           = optional(string, null)<br/>    username      = optional(string, null)<br/>    cacert        = optional(string, null)<br/>    mirror_url    = optional(string, null)<br/>    mirror_cacert = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_ssh"></a> [ssh](#input\_ssh) | Node SSH access. The public key's location ON THE BASTION is derived from bastion.run\_root, not configured here. | <pre>object({<br/>    username = optional(string, "konvoy")<br/>  })</pre> | `{}` | no |
| <a name="input_version_contract"></a> [version\_contract](#input\_version\_contract) | NKP and Kubernetes versions. Must match the node image and bundle filenames. | <pre>object({<br/>    nkp        = string<br/>    kubernetes = string<br/>  })</pre> | n/a | yes |
| <a name="input_workers"></a> [workers](#input\_workers) | Worker pool. prism\_element\_cluster/subnets/vm\_image fall back to var.placement when null. | <pre>object({<br/>    replicas              = optional(number, 3)<br/>    vcpus                 = optional(number, 8)<br/>    cores_per_vcpu        = optional(number, 1)<br/>    memory_gib            = optional(number, 32)<br/>    disk_size_gib         = optional(number, 80)<br/>    prism_element_cluster = optional(string, null)<br/>    subnets               = optional(list(string), null)<br/>    vm_image              = optional(string, null)<br/>    pc_categories         = optional(list(string), [])<br/>    pc_project            = optional(string, null)<br/>    vm_profile            = optional(string, null)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_command_human"></a> [command\_human](#output\_command\_human) | The create command rendered as a copy-pasteable shell string, for docs and manual reproduction. Credentials appear only as environment variables the operator exports, never inline. |
| <a name="output_contract"></a> [contract](#output\_contract) | Execution contract for the lz-cli hooks: argv for create and delete, the<br/>non-secret environment, the names of required secret environment variables,<br/>the bastion to run on, and what ensure\_ready() must verify first.<br/><br/>The caller writes this to .lz/<env>/nkp-contract.json. Contains no secrets. |
| <a name="output_outputs"></a> [outputs](#output\_outputs) | Aggregate of all module outputs, consumed by the landing zone as module.<x>.outputs. |
| <a name="output_prerequisites"></a> [prerequisites](#output\_prerequisites) | Resolved Nutanix ext\_ids for the referenced clusters, subnets, storage container and node images. Empty when enable\_data\_lookups is false. |
| <a name="output_summary"></a> [summary](#output\_summary) | Compact summary of what this cluster will be. |
| <a name="output_validation_errors"></a> [validation\_errors](#output\_validation\_errors) | Every configuration error found, aggregated. Empty on a valid configuration; a non-empty list fails the plan via the precondition in main.tf. Exposed so it can be asserted directly in tests. |
<!-- END_TF_DOCS -->
