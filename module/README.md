# tf-ntnx-nkp

## Table of Contents

## Overview

A description of the module goes here.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_nutanix"></a> [nutanix](#requirement\_nutanix) | >= 2.4.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_clusters"></a> [clusters](#input\_clusters) | Map of NKP clusters to create. Each cluster supports Nutanix Kubernetes Platform configurations. | <pre>map(object({<br/>    name               = string<br/>    description        = optional(string, "")<br/>    kubernetes_version = string<br/>    control_plane = object({<br/>      num_instances              = number<br/>      cpu                        = number<br/>      memory_mib                 = number<br/>      disk_gib                   = number<br/>      network_uuid               = string<br/>      prism_element_cluster_uuid = string<br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | Map of NKP node pools to create. Each node pool is associated with a cluster. | <pre>map(object({<br/>    name                       = string<br/>    cluster_key                = string<br/>    num_instances              = number<br/>    cpu                        = number<br/>    memory_mib                 = number<br/>    disk_gib                   = number<br/>    network_uuid               = string<br/>    prism_element_cluster_uuid = string<br/>    labels                     = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_registries"></a> [registries](#input\_registries) | Map of NKP container registries to configure. Registries allow NKP clusters to pull images from private repositories. | <pre>map(object({<br/>    name     = string<br/>    url      = string<br/>    port     = optional(number, 443)<br/>    username = optional(string, "")<br/>    password = optional(string, "")<br/>    cert     = optional(string, "")<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nkp_summary"></a> [nkp\_summary](#output\_nkp\_summary) | Summary of NKP resources (pending provider support). |
<!-- END_TF_DOCS -->
