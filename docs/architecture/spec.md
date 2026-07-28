# NKP Infrastructure Module Specification — tf-ntnx-nkp

Detailed specification for AI agents and infrastructure engineers implementing and maintaining the `tf-ntnx-nkp` OpenTofu module.

**Target Environment:** NKP v2.18 · Ultimate Licence · Air-Gapped · Nutanix AHV
**Tooling:** OpenTofu v1.9+
**Scope:** OpenTofu module interfaces, input validation, CLI flag rendering, Bastion VM customisation, and hook execution contracts.

---

## 1. Responsibilities & Non-Goals

### Responsibilities

1. Resolve and validate Nutanix infrastructure prerequisites (Subnet UUIDs, Prism Element Cluster names, Storage Container names, IP pools, VIPs).
2. Enforce air-gap and security constraints on all generated CLI invocations.
3. Render versioned `nkp create cluster nutanix` (`bootstrap_script`) and 6-step `nkp upgrade` (`upgrade_script`) shell scripts for execution by `lz-cli` hooks.
4. Define and output Bastion VM `cloud-init` configurations (`bastion_cloud_init`) including internal CA bundle trust, SSH keys, and SOPS secret decryption tooling.

### Non-Goals

- Managing resources inside the management cluster post-bootstrap (owned by `nkp-platform`).
- Executing `nkp create cluster` directly inside OpenTofu via `local-exec`, `remote-exec`, or `null_resource`.
- Provisioning the Bastion VM resource directly in OpenTofu state (owned by parent landing zone `lz-paas`).
- Building or packaging Kubernetes node images (owned by `nkp-images`).

---

## 2. CLI Invocations & Required Flags

The `nkp` CLI binary does not accept configuration or values files (`--values`, `-f`, or `--config` are not supported). All parameters must be passed as command-line flags.

### 2.1 Management Cluster Creation Flag Contract

Every rendered `nkp create cluster nutanix` script **MUST** include all 9 required CLI flags plus image specifications and mandatory security/air-gap flags:

```bash
nkp create cluster nutanix \
  --cluster-name="${var.cluster_name}" \
  --endpoint="${var.prism_central_endpoint}" \
  --control-plane-endpoint-ip="${var.control_plane_vip}" \
  --control-plane-prism-element-cluster="${var.prism_element_cluster}" \
  --control-plane-subnets="${var.control_plane_subnet}" \
  --control-plane-vm-image="${var.control_plane_vm_image}" \
  --worker-prism-element-cluster="${var.prism_element_cluster}" \
  --worker-subnets="${var.worker_subnet}" \
  --worker-vm-image="${var.worker_vm_image}" \
  --worker-replicas=${local.worker_replicas} \
  --csi-storage-container="${var.csi_storage_container}" \
  --kubernetes-service-load-balancer-ip-range="${var.load_balancer_ip_range}" \
  --kubernetes-pod-network-cidr="${var.pod_cidr}" \
  --kubernetes-service-cidr="${var.service_cidr}" \
  --airgapped=true \
  ${BUNDLE_FLAGS} \
  ${APP_FLAGS}
```

### 2.2 Profile Sizing & Application Flags

- **`var.profile = "small"` (Default):**
  - Configures 3 worker nodes.
  - Disables resource-heavy platform applications (Rook Ceph, Velero, logging/monitoring) to optimize lab resource footprints and eliminate the 4-worker/190GB storage floor.
- **`var.profile = "full"`:**
  - Configures 4 worker nodes.
  - Enables the complete Ultimate platform application suite.

### 2.3 Mandatory Air-Gap Flag Enforcement

- **`--airgapped=true` MUST be hardcoded** in the script renderer. It must not be exposed as a configurable boolean variable.
- **Image Bundles (`${BUNDLE_FLAGS}`):** Must use local air-gapped bundle tarballs:

  ```bash
  export BUNDLE_FLAGS="--bundle ./nkp-${NKP_VERSION}/container-images/kommander-image-bundle-${NKP_VERSION}.tar,./nkp-${NKP_VERSION}/container-images/konvoy-image-bundle-${NKP_VERSION}.tar"
  ```

- **Mutual Exclusion Rule:** Do **NOT** pass `--registry-mirror-url` / `${REGISTRY_MIRROR_FLAGS}` simultaneously with `${BUNDLE_FLAGS}`.

---

## 3. Network & Address Specifications

| Parameter               | Required Value / Constraints                                                 | OpenTofu Validation Rule        |
| :---------------------- | :--------------------------------------------------------------------------- | :------------------------------ |
| **Pod CIDR**            | `172.20.0.0/16` _(Default 192.168.0.0/16 collides with lab network)_         | Must match `^172\.20\.0\.0/16$` |
| **Service CIDR**        | `10.96.0.0/12`                                                               | Valid IPv4 CIDR                 |
| **Control Plane VIP**   | Static IP on VLAN 82 (`192.168.82.10`), outside DHCP scope (`.100-.200`)     | Valid IPv4 address              |
| **Load Balancer Range** | MetalLB range on VLAN 82 (`192.168.82.20-192.168.82.39`), outside DHCP scope | Valid IP range syntax           |
| **Node Addressing**     | External DHCP (UDM Router), Nutanix IPAM disabled                            | VLAN-only subnet reference      |

---

## 4. Module Interface & Inputs

### Variables

```hcl
variable "cluster_name" {
  type        = string
  description = "Name of the NKP management cluster"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cluster_name))
    error_message = "Cluster name must contain only lowercase alphanumeric characters and hyphens."
  }
}

variable "profile" {
  type        = string
  description = "Environment profile ('small' for lab 3-worker footprint, 'full' for 4-worker Ultimate footprint)"
  default     = "small"
  validation {
    condition     = contains(["small", "full"], var.profile)
    error_message = "Profile must be either 'small' or 'full'."
  }
}

variable "prism_central_endpoint" {
  type        = string
  description = "Prism Central FQDN or IP address"
}

variable "control_plane_vip" {
  type        = string
  description = "Static VIP for Kubernetes control plane"

  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.control_plane_vip))
    error_message = "Control plane VIP must be a valid IPv4 address."
  }
}

variable "prism_element_cluster" {
  type        = string
  description = "Name of the target Prism Element cluster"
}

variable "control_plane_subnet" {
  type        = string
  description = "Nutanix subnet name/UUID for control plane nodes"
}

variable "worker_subnet" {
  type        = string
  description = "Nutanix subnet name/UUID for worker nodes"
}

variable "csi_storage_container" {
  type        = string
  description = "Nutanix Storage Container name for CSI persistent volumes"
}

variable "load_balancer_ip_range" {
  type        = string
  description = "MetalLB IP range (e.g. 192.168.82.20-192.168.82.39)"

  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}-(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.load_balancer_ip_range))
    error_message = "Load balancer IP range must be in start_ip-end_ip format."
  }
}

variable "control_plane_vm_image" {
  type        = string
  description = "Nutanix OS VM Image name for control plane nodes"
}

variable "worker_vm_image" {
  type        = string
  description = "Nutanix OS VM Image name for worker nodes"
}

variable "pod_cidr" {
  type        = string
  description = "Kubernetes Pod Network CIDR (must match 172.20.0.0/16)"
  default     = "172.20.0.0/16"
  validation {
    condition     = can(regex("^172\\.20\\.0\\.0/16$", var.pod_cidr))
    error_message = "Pod CIDR must be 172.20.0.0/16 to avoid collision with lab network."
  }
}

variable "service_cidr" {
  type        = string
  description = "Kubernetes Service Network CIDR"
  default     = "10.96.0.0/12"

  validation {
    condition     = can(cidrnetmask(var.service_cidr))
    error_message = "Service CIDR must be a valid IPv4 CIDR prefix."
  }
}

variable "bundle_paths" {
  type        = list(string)
  description = "List of local tarball bundle paths for air-gapped deployment"
  default     = []
}

variable "ca_certificates" {
  type        = list(string)
  description = "List of PEM-encoded CA certificates to inject into the Bastion host trust store"
  default     = []
}

variable "bastion_ssh_keys" {
  type        = list(string)
  description = "List of SSH public keys for Bastion host access"
  default     = []
}

variable "nutanix_username" {
  type        = string
  description = "Nutanix Prism Central Username"
  sensitive   = true
  default     = null
}

variable "nutanix_password" {
  type        = string
  description = "Nutanix Prism Central Password"
  sensitive   = true
  default     = null
}
```

### Module Outputs

```hcl
output "nkp_summary" {
  type        = map(string)
  description = "Summary of NKP cluster configuration"
}

output "bootstrap_script" {
  type        = string
  description = "Rendered nkp create cluster nutanix shell script"
}

output "upgrade_script" {
  type        = string
  description = "Rendered 6-step nkp upgrade shell script"
}

output "bastion_cloud_init" {
  type        = string
  description = "Rendered Bastion VM cloud-init user-data YAML string"
}

output "prerequisites" {
  type        = map(any)
  description = "Map of validated Nutanix cluster, subnet, and container prerequisites"
}

output "outputs" {
  type        = map(any)
  description = "Aggregate of all module outputs (consumed by the landing zone as module.<x>.outputs)"
}
```

---

## 5. Day-2 Upgrade Execution Contract

Upgrades are executed by the `lz-cli` hook in six ordered steps:

```bash
# Step 1: Upgrade CAPI components
nkp upgrade capi-components

# Step 2: Upgrade Nutanix cluster machines & ClusterClass
nkp upgrade cluster nutanix --vm-image <new-image-name>

# Step 3: Upgrade Kommander platform
nkp upgrade kommander

# Step 4: Upgrade Workspace resources
nkp upgrade workspace <workspace-name>

# Step 5: Upgrade Addons
nkp upgrade addons

# Step 6: Upgrade Catalog Applications
nkp upgrade catalogapp
```

---

## 6. Tier 0 Secrets & Credentials

- **Nutanix Credentials:** `NUTANIX_USER` and `NUTANIX_PASSWORD` are retrieved from Tier 0 SOPS (`secretspec/SOPS`) via `lz-cli` prior to rendering script execution.
- **No Secrets in State:** OpenTofu outputs must mark sensitive credentials as `sensitive = true` or omit them entirely by delegating credential resolution to the hook.
- **Kubeconfig Retrieval:** Kubeconfig is fetched from the Bastion host post-bootstrap by the `lz-cli` hook and saved SOPS-encrypted directly into Git (`nkp-platform` / secret store), completely avoiding secret leakage in OpenTofu state.
