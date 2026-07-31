##################################################
# tf-ntnx-nkp — inputs
#
# This module RENDERS an execution contract for the `nkp` CLI. It provisions
# nothing and executes nothing (lz-paas ADR 0018). An lz-cli hook runs the
# contract on a bastion over SSH, outside the OpenTofu state lifecycle.
#
# SCOPE: ONE self-managed NKP MANAGEMENT cluster, on NUTANIX, AIR-GAPPED.
# Callers with several clusters use for_each. Workload clusters are created
# through GitOps/Kommander and are deliberately not expressible here.
# vSphere / AWS / Azure / EKS / AKS / GKE are unsupported — see README.
#
# MODULE-OWNED FLAGS (deliberately absent from this interface, and refused if
# passed through extra_args):
#
#   --self-managed --airgapped        the contract this module exists to render
#   --dry-run --output --output-directory --wait --verbose --show-managed-fields
#   --kubeconfig --namespace          owned by the hook, not the caller
#   --with-aws-bootstrap-credentials --with-gcp-bootstrap-credentials
#   --aws-service-endpoints           meaningless on Nutanix
#   --skip-preflight-checks           never, silently
#
# SECRETS ARE NOT INPUTS. Passwords and private keys are named, not valued —
# the hook reads them from SOPS at run time. Nothing secret may reach state.
##################################################

variable "cluster_name" {
  type        = string
  description = "Name of the NKP management cluster. Prefixes every created Nutanix resource."

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.cluster_name))
    error_message = "cluster_name must be a lowercase RFC 1123 label: alphanumerics and hyphens, starting and ending alphanumeric, max 63 characters."
  }
}

##################################################
# Bastion — where the hook runs `nkp`
##################################################

# A plain address, NOT a reference to a Terraform resource. NKP automation must
# work in clickops estates where the bastion was built by hand, so this module
# takes no inputs from other landing zones (ADR 0018 Revision, rule 5). This
# module never connects to the bastion; the value is passed through to the
# contract so the hook knows where to go.
variable "bastion" {
  type = object({
    host         = string
    user         = optional(string, "linadmin")
    work_dir     = optional(string, "/var/tmp")
    min_free_gib = optional(number, 60)
  })
  description = "Bastion the lz-cli hook connects to. host is a DNS name or IP typed by the operator."

  validation {
    condition     = length(trimspace(var.bastion.host)) > 0
    error_message = "bastion.host must be set: a DNS name or IP address for the host that runs the nkp CLI."
  }

  validation {
    condition     = var.bastion.min_free_gib >= 60
    error_message = "bastion.min_free_gib must be at least 60. The air-gapped bundle is ~27 GiB compressed and roughly doubles once extracted, before KIND pulls anything."
  }
}

##################################################
# Version contract
##################################################

# These must agree with the node image and the bundle paths. nkp-images owns the
# release train that keeps them aligned; this module refuses a mismatch rather
# than discovering it 40 minutes into a bootstrap.
variable "version_contract" {
  type = object({
    nkp        = string
    kubernetes = string
  })
  description = "NKP and Kubernetes versions. Must match the node image and bundle filenames."

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.version_contract.nkp))
    error_message = "version_contract.nkp must be a bare semver such as 2.18.0 (no leading v)."
  }

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.version_contract.kubernetes))
    error_message = "version_contract.kubernetes must be a bare semver such as 1.35.2 (no leading v)."
  }
}

##################################################
# Prism Central
##################################################

variable "prism_central" {
  type = object({
    endpoint                = string
    user                    = string
    port                    = optional(number, 9440)
    insecure                = optional(bool, true)
    additional_trust_bundle = optional(string, null)
  })
  description = "Prism Central connection. `user` NAMES the account (nkp-capx per lz-paas ADR 0020); its password is injected by the hook, never held here."

  validation {
    condition     = length(trimspace(var.prism_central.endpoint)) > 0
    error_message = "prism_central.endpoint must be set (FQDN or IP, without scheme or port)."
  }

  validation {
    condition     = !can(regex("^https?://", var.prism_central.endpoint))
    error_message = "prism_central.endpoint must not include a scheme; the module builds https://<endpoint>:<port>."
  }

  validation {
    condition     = var.prism_central.port > 0 && var.prism_central.port <= 65535
    error_message = "prism_central.port must be a valid TCP port."
  }

  validation {
    condition     = length(trimspace(var.prism_central.user)) > 0
    error_message = "prism_central.user must name a Prism Central account (e.g. nkp-capx)."
  }
}

##################################################
# Air-gap artefacts — paths ON THE BASTION
##################################################

# bootstrap_cluster_image is required by BOTH create and delete. `nkp create`
# otherwise pulls docker.io/mesosphere/konvoy-bootstrap, which cannot succeed
# air-gapped and fails with an error pointing at Docker Hub rather than at the
# air gap. `nkp delete --self-managed` needs it too: deleting a self-managed
# cluster builds a fresh bootstrap cluster and reverse-pivots CAPI into it.
variable "airgap" {
  type = object({
    bundles                 = list(string)
    bootstrap_cluster_image = string
  })
  description = "Air-gap artefact paths on the bastion. Both are mandatory: this module only renders air-gapped installs."

  validation {
    condition     = length(var.airgap.bundles) > 0
    error_message = "airgap.bundles must list at least the konvoy and kommander image bundles."
  }

  validation {
    condition     = alltrue([for b in var.airgap.bundles : startswith(b, "/")])
    error_message = "airgap.bundles entries must be absolute paths on the bastion."
  }

  validation {
    condition     = length(trimspace(var.airgap.bootstrap_cluster_image)) > 0 && startswith(var.airgap.bootstrap_cluster_image, "/")
    error_message = "airgap.bootstrap_cluster_image must be an absolute path on the bastion to konvoy-bootstrap-image-<version>.tar."
  }
}

##################################################
# Nutanix placement
##################################################

variable "placement" {
  type = object({
    prism_element_cluster = string
    subnets               = list(string)
    vm_image              = string
  })
  description = "Default Nutanix placement for both node pools. Names, not UUIDs — resolved and validated at plan."

  validation {
    condition     = length(trimspace(var.placement.prism_element_cluster)) > 0
    error_message = "placement.prism_element_cluster must name a Prism Element cluster."
  }

  validation {
    condition     = length(var.placement.subnets) > 0
    error_message = "placement.subnets must list at least one subnet name."
  }

  validation {
    condition     = length(trimspace(var.placement.vm_image)) > 0
    error_message = "placement.vm_image must name an NKP node image already uploaded to Prism Central."
  }
}

##################################################
# Node pools
##################################################

variable "control_plane" {
  type = object({
    endpoint_ip               = string
    replicas                  = optional(number, 3)
    vcpus                     = optional(number, 4)
    cores_per_vcpu            = optional(number, 1)
    memory_gib                = optional(number, 16)
    disk_size_gib             = optional(number, 80)
    endpoint_port             = optional(number, 6443)
    external_endpoint         = optional(string, null)
    renew_certificates_before = optional(number, 180)
    prism_element_cluster     = optional(string, null)
    subnets                   = optional(list(string), null)
    vm_image                  = optional(string, null)
    pc_categories             = optional(list(string), [])
    pc_project                = optional(string, null)
  })
  description = "Control-plane pool. prism_element_cluster/subnets/vm_image fall back to var.placement when null."

  validation {
    condition     = can(cidrhost("${var.control_plane.endpoint_ip}/32", 0))
    error_message = "control_plane.endpoint_ip must be a valid IPv4 address."
  }

  validation {
    condition     = contains([1, 3, 5], var.control_plane.replicas)
    error_message = "control_plane.replicas must be 1, 3 or 5. etcd needs an odd quorum; 1 is lab-only and has no fault tolerance."
  }

  validation {
    condition     = var.control_plane.vcpus >= 4 && var.control_plane.memory_gib >= 16
    error_message = "control_plane needs at least 4 vCPUs and 16 GiB. NKP 2.18's documented control-plane minimum."
  }

  validation {
    condition     = var.control_plane.disk_size_gib >= 80
    error_message = "control_plane.disk_size_gib must be at least 80."
  }

  validation {
    condition     = var.control_plane.endpoint_port > 0 && var.control_plane.endpoint_port <= 65535
    error_message = "control_plane.endpoint_port must be a valid TCP port."
  }

  # 0 disables renewal; otherwise nkp itself enforces 7..360.
  validation {
    condition = (
      var.control_plane.renew_certificates_before == 0 ||
      (var.control_plane.renew_certificates_before >= 7 && var.control_plane.renew_certificates_before <= 360)
    )
    error_message = "control_plane.renew_certificates_before must be 0 (disabled) or between 7 and 360 days."
  }
}

variable "workers" {
  type = object({
    replicas              = optional(number, 3)
    vcpus                 = optional(number, 8)
    cores_per_vcpu        = optional(number, 1)
    memory_gib            = optional(number, 32)
    disk_size_gib         = optional(number, 80)
    prism_element_cluster = optional(string, null)
    subnets               = optional(list(string), null)
    vm_image              = optional(string, null)
    pc_categories         = optional(list(string), [])
    pc_project            = optional(string, null)
    vm_profile            = optional(string, null)
  })
  default     = {}
  description = "Worker pool. prism_element_cluster/subnets/vm_image fall back to var.placement when null."

  validation {
    condition     = var.workers.replicas >= 1
    error_message = "workers.replicas must be at least 1."
  }

  # Kommander's platform applications do not fit in less than this. A cluster
  # that boots and then cannot schedule Kommander is the expensive failure.
  validation {
    condition     = var.workers.vcpus >= 8 && var.workers.memory_gib >= 32
    error_message = "workers need at least 8 vCPUs and 32 GiB to host the Kommander platform applications."
  }

  validation {
    condition     = var.workers.disk_size_gib >= 80
    error_message = "workers.disk_size_gib must be at least 80."
  }
}

##################################################
# Kubernetes networking
##################################################

variable "networking" {
  type = object({
    load_balancer_ip_range = string
    pod_cidr               = optional(string, "172.20.0.0/16")
    service_cidr           = optional(string, "172.21.0.0/16")
  })
  description = "Pod/service CIDRs and the MetalLB range. Overlaps are checked at plan (see checks in main.tf)."

  validation {
    condition     = can(cidrnetmask(var.networking.pod_cidr))
    error_message = "networking.pod_cidr must be a valid IPv4 CIDR."
  }

  validation {
    condition     = can(cidrnetmask(var.networking.service_cidr))
    error_message = "networking.service_cidr must be a valid IPv4 CIDR."
  }

  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}-(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.networking.load_balancer_ip_range))
    error_message = "networking.load_balancer_ip_range must be start_ip-end_ip, e.g. 192.168.84.151-192.168.84.170."
  }
}

##################################################
# CSI
##################################################

variable "csi" {
  type = object({
    storage_container           = string
    file_system                 = optional(string, "ext4")
    reclaim_policy              = optional(string, "Delete")
    hypervisor_attached_volumes = optional(bool, true)
    flash_mode                  = optional(bool, false)
  })
  description = "Nutanix CSI settings for the default storage class."

  validation {
    condition     = length(trimspace(var.csi.storage_container)) > 0
    error_message = "csi.storage_container must name a Prism Central storage container."
  }

  # Allowed values are fixed by the CLI: ["ext4" "xfs"].
  validation {
    condition     = contains(["ext4", "xfs"], var.csi.file_system)
    error_message = "csi.file_system must be ext4 or xfs."
  }

  # Allowed values are fixed by the CLI: ["Delete" "Retain"].
  validation {
    condition     = contains(["Delete", "Retain"], var.csi.reclaim_policy)
    error_message = "csi.reclaim_policy must be Delete or Retain."
  }
}

##################################################
# Registry
##################################################

# Empty mirror_url means the in-cluster registry populated by --bundle, which is
# the lab's air-gapped path. Usernames are values; PASSWORDS ARE NOT — they are
# named in secret_env and injected by the hook. The *-cacert fields are paths to
# files ON THE BASTION, which the hook materialises from SOPS onto tmpfs.
variable "registry" {
  type = object({
    url           = optional(string, null)
    username      = optional(string, null)
    cacert        = optional(string, null)
    mirror_url    = optional(string, null)
    mirror_cacert = optional(string, null)
  })
  default     = {}
  description = "Container registry / mirror. Passwords are never inputs; they are named in the contract's secret_env."

  validation {
    condition = (
      var.registry.url == null ||
      can(regex("^https?://", var.registry.url))
    )
    error_message = "registry.url must include a scheme (http:// or https://)."
  }

  validation {
    condition = (
      var.registry.mirror_url == null ||
      can(regex("^https?://", var.registry.mirror_url))
    )
    error_message = "registry.mirror_url must include a scheme (http:// or https://)."
  }
}

##################################################
# Proxy
##################################################

variable "proxy" {
  type = object({
    http     = optional(string, null)
    https    = optional(string, null)
    no_proxy = optional(list(string), [])
  })
  default     = {}
  description = "Egress proxy for CAPI controllers and nodes. Normally unset in a true air gap."
}

##################################################
# Ingress
##################################################

# ca / certificate are paths to files on the bastion. The private key is NOT an
# input: it lives in nkp.sops.json and the hook writes it to tmpfs before the run.
variable "ingress" {
  type = object({
    ca          = optional(string, null)
    certificate = optional(string, null)
    acme_email  = optional(string, null)
    acme_server = optional(string, null)
  })
  default     = {}
  description = "Ingress TLS. Paths are on the bastion; the private key is injected by the hook, never an input."

  validation {
    condition = (
      (var.ingress.certificate == null) == (var.ingress.ca == null)
    )
    error_message = "ingress.ca and ingress.certificate must be set together, or neither."
  }
}

##################################################
# SSH into the nodes
##################################################

# Baked into every node VM at create time and unchangeable afterwards without
# redeploying them. The path is on the BASTION; the hook places the key there
# from the operator's on-disk keypair (lz-paas ssh.keys pattern).
variable "ssh" {
  type = object({
    username        = optional(string, "konvoy")
    public_key_path = string
  })
  description = "Node SSH access. public_key_path is where the hook will have placed the public key on the bastion."

  validation {
    condition     = length(trimspace(var.ssh.public_key_path)) > 0
    error_message = "ssh.public_key_path must be set."
  }

  validation {
    condition     = length(trimspace(var.ssh.username)) > 0
    error_message = "ssh.username must be set (NKP's default is konvoy)."
  }
}

##################################################
# Everything else
##################################################

variable "misc" {
  type = object({
    ntp_servers                              = optional(list(string), [])
    fips                                     = optional(bool, false)
    extra_sans                               = optional(list(string), [])
    cluster_hostname                         = optional(string, null)
    onboard_to_prism_central                 = optional(bool, true)
    timeout                                  = optional(string, "60m")
    capi_additional_sync_machine_labels      = optional(string, null)
    capi_additional_sync_machine_annotations = optional(string, null)
  })
  default     = {}
  description = "Assorted cluster settings that map 1:1 onto nkp flags."

  validation {
    condition     = can(regex("^[0-9]+(s|m|h)$", var.misc.timeout))
    error_message = "misc.timeout must be a Go duration such as 60m, 90m or 2h."
  }
}

##################################################
# GitOps — DEFERRED, schema only
##################################################

# The seam to nkp-platform: a deploy-key secret, a Flux GitRepository and one
# root Kustomization. NOT IMPLEMENTED — NKP 2.18 also runs its own internal
# GitOps host (git-operator), and which resources Kommander expects alongside it
# is unconfirmed. Keys exist so enabling it later is not a breaking change.
variable "gitops" {
  type = object({
    enabled = optional(bool, false)
    url     = optional(string, null)
    branch  = optional(string, "main")
    path    = optional(string, null)
  })
  default     = {}
  description = "GitOps handoff to nkp-platform. Deferred: setting enabled = true is refused until the mechanism is verified."

  validation {
    condition     = !try(var.gitops.enabled, false)
    error_message = "gitops.enabled is not implemented yet and must stay false. The attach mechanism needs verification against a live cluster before it can be rendered (ADR 0018 Revision, 'Deferred')."
  }
}

##################################################
# Escape hatch
##################################################

# Lets a new NKP release's flags be used before this module models them. The
# deny-list is the point: without it a caller could pass --airgapped=false or
# --skip-preflight-checks and quietly void the contract this module exists to
# guarantee. Prefer adding a first-class field.
variable "extra_args" {
  type        = list(string)
  default     = []
  description = "Additional raw nkp flags. Module-owned flags are refused."

  validation {
    condition = alltrue([
      for a in var.extra_args : !contains([
        "--self-managed",
        "--airgapped",
        "--dry-run",
        "--output",
        "-o",
        "--output-directory",
        "--wait",
        "--verbose",
        "-v",
        "--show-managed-fields",
        "--kubeconfig",
        "--namespace",
        "-n",
        "--skip-preflight-checks",
        "--with-aws-bootstrap-credentials",
        "--with-gcp-bootstrap-credentials",
        "--aws-service-endpoints",
        "--help",
        "-h",
      ], split("=", a)[0])
    ])
    error_message = "extra_args contains a module-owned flag. --self-managed/--airgapped define the contract, --dry-run/--output/--wait/--verbose/--kubeconfig/--namespace belong to the hook, --skip-preflight-checks is never silently allowed, and the AWS/GCP flags are meaningless on Nutanix."
  }

  # Only the FIRST element is required to be a flag. Values legitimately do not
  # start with '-' — ["--worker-vm-profile", "custom"] is the normal shape — so
  # requiring it of every element would reject correct input. This catches the
  # real mistake: a bare value list with no flag at all.
  validation {
    condition     = length(var.extra_args) == 0 || startswith(var.extra_args[0], "-")
    error_message = "extra_args must begin with a flag. Pass a flag and its value as separate list elements ([\"--worker-vm-profile\", \"custom\"]) or as a single --flag=value element."
  }
}

##################################################
# Plan-time lookups
##################################################

# Existence checks resolve real Nutanix objects and therefore need working
# Prism Central credentials at plan time. Turn them off for unit tests and for
# plans run where PC is unreachable; the static validations still apply.
variable "enable_data_lookups" {
  type        = bool
  default     = true
  description = "Resolve the Prism Element cluster, subnets, storage container and node image at plan time."
}

# TEST SEAM. The precondition in main.tf aborts the plan on the first validation
# error, which means a test can never inspect WHICH error was raised — the plan
# fails before any output is readable. Setting this false keeps the error list
# populated in output.validation_errors while letting the plan succeed, so each
# rule can be asserted precisely.
#
# NEVER set this false outside tests. It disables every cross-variable check:
# the CIDR maths, the version contract and the air-gap invariants all become
# advisory. Callers in lz-paas leave it at the default and the landing zone does
# not expose it.
variable "enforce_validation" {
  type        = bool
  default     = true
  description = "Fail the plan when validation errors exist. Test seam only — leave true in every real configuration."
}
