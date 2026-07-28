# tf-ntnx-nkp

## Overview

OpenTofu module for Nutanix Kubernetes Platform (NKP) management cluster configuration, prerequisite validation, and execution contract rendering in air-gapped Nutanix AHV environments.

## Architecture

This module manages the configuration contract for an NKP management cluster on Nutanix AHV:

- **Zero In-State VM Provisioning**: The module resolves and validates Nutanix infrastructure prerequisites (Prism Element clusters, subnets, storage containers) via Nutanix OpenTofu data sources and renders execution shell scripts and cloud-init contracts. VM lifecycle management and CLI execution are performed post-apply by the landing zone automation framework (`lz-cli`).
- **Single Management Cluster CLI Contract**: Renders the complete `nkp create cluster nutanix` bootstrap script (`bootstrap_script`) with required flags, including `--airgapped=true`, air-gapped container image bundles (`bundle_paths`), and network CIDR configurations.
- **Environment Footprint Profiles**: Supports `profile = "small"` (3 worker nodes for lab environments with optional heavy platform services disabled) and `profile = "full"` (4 worker nodes for full Ultimate platform footprint).
- **Day-2 Lifecycle Management**: Renders a versioned 6-step `nkp upgrade` shell script (`upgrade_script`) for automated platform maintenance.
- **Bastion Host Cloud-Init**: Renders Bastion VM `cloud-init` user-data (`bastion_cloud_init`) with injected SSH public keys (`bastion_ssh_keys`) and internal CA certificate trust bundles (`ca_certificates`).

## Usage

```hcl
module "nkp_management_cluster" {
  source = "github.com/bingamon-lab-tf-modules/tf-ntnx-nkp//module?ref=v1.0.0"

  cluster_name            = "nkp-mgmt"
  profile                 = "small"
  prism_central_endpoint  = "pc.lab.internal"
  prism_element_cluster   = "pe-cluster-01"
  control_plane_vip       = "192.168.82.10"
  control_plane_subnet    = "vlan82-cp-subnet"
  worker_subnet           = "vlan82-worker-subnet"
  csi_storage_container   = "nkp-container"
  load_balancer_ip_range  = "192.168.82.20-192.168.82.39"
  control_plane_vm_image  = "centos-7.9-nkp-v2.18"
  worker_vm_image         = "centos-7.9-nkp-v2.18"

  pod_cidr     = "172.20.0.0/16"
  service_cidr = "10.96.0.0/12"

  bundle_paths     = ["/opt/bundles/kommander-image-bundle-v2.18.0.tar"]
  ca_certificates  = [file("${path.module}/certs/internal-ca.crt")]
  bastion_ssh_keys = ["ssh-ed25519 ssh-key-placeholder"]
}
```

## Inputs

| Name                     | Description                                                                                      | Type           | Default           | Required |
| ------------------------ | ------------------------------------------------------------------------------------------------ | -------------- | ----------------- | :------: |
| `cluster_name`           | Name of the NKP management cluster                                                               | `string`       | n/a               |   yes    |
| `profile`                | Environment profile ('small' for lab 3-worker footprint, 'full' for 4-worker Ultimate footprint) | `string`       | `"small"`         |    no    |
| `prism_central_endpoint` | Prism Central FQDN or IP address                                                                 | `string`       | n/a               |   yes    |
| `control_plane_vip`      | Static VIP for Kubernetes control plane                                                          | `string`       | n/a               |   yes    |
| `prism_element_cluster`  | Name of the target Prism Element cluster                                                         | `string`       | n/a               |   yes    |
| `control_plane_subnet`   | Nutanix subnet name/UUID for control plane nodes                                                 | `string`       | n/a               |   yes    |
| `worker_subnet`          | Nutanix subnet name/UUID for worker nodes                                                        | `string`       | n/a               |   yes    |
| `csi_storage_container`  | Nutanix Storage Container name for CSI persistent volumes                                        | `string`       | n/a               |   yes    |
| `load_balancer_ip_range` | MetalLB IP range (e.g. 192.168.82.20-192.168.82.39)                                              | `string`       | n/a               |   yes    |
| `control_plane_vm_image` | Nutanix OS VM Image name for control plane nodes                                                 | `string`       | n/a               |   yes    |
| `worker_vm_image`        | Nutanix OS VM Image name for worker nodes                                                        | `string`       | n/a               |   yes    |
| `pod_cidr`               | Kubernetes Pod Network CIDR (must match 172.20.0.0/16)                                           | `string`       | `"172.20.0.0/16"` |    no    |
| `service_cidr`           | Kubernetes Service Network CIDR                                                                  | `string`       | `"10.96.0.0/12"`  |    no    |
| `bundle_paths`           | List of local tarball bundle paths for air-gapped deployment                                     | `list(string)` | `[]`              |    no    |
| `ca_certificates`        | List of PEM-encoded CA certificates to inject into Bastion host trust store                      | `list(string)` | `[]`              |    no    |
| `bastion_ssh_keys`       | List of SSH public keys for Bastion host access                                                  | `list(string)` | `[]`              |    no    |
| `nutanix_username`       | Nutanix Prism Central Username                                                                   | `string`       | `null`            |    no    |
| `nutanix_password`       | Nutanix Prism Central Password                                                                   | `string`       | `null`            |    no    |

## Outputs

| Name                 | Description                                                                                       |
| -------------------- | ------------------------------------------------------------------------------------------------- |
| `nkp_summary`        | Summary map of NKP cluster configuration (`cluster_name`, `profile`, `pod_cidr`, `service_cidr`). |
| `prerequisites`      | Map of resolved and validated Nutanix cluster, subnet, and container UUIDs.                       |
| `bootstrap_script`   | Rendered `nkp create cluster nutanix` shell script.                                               |
| `upgrade_script`     | Rendered 6-step `nkp upgrade` shell script.                                                       |
| `bastion_cloud_init` | Rendered Bastion VM `cloud-init` user-data YAML string.                                           |
| `outputs`            | Aggregate map of all module outputs (spec §4 contract).                                           |

## Documentation

- [Architecture Specification](docs/architecture/spec.md)
- [Module Reference](module/README.md)
