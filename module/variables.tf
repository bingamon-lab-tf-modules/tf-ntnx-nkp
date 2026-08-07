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
#
# TWO ROOTS, NOT ONE WORK DIRECTORY
# ---------------------------------
# `work_dir` used to mean two incompatible things at once: where the ~27 GiB
# air-gap bundle is cached, and the process cwd `nkp` writes its kubeconfig
# into. Those want opposite lifetimes — the bundle should survive every run so a
# teardown months later is not gated on a 20-minute download, and the kubeconfig
# is a live cluster-admin credential that should not outlive the run at all.
# Conflating them meant the credential inherited the bundle's lifetime.
#
# So: a CACHE root that persists and a RUN root that does not.
#
# Both are GENERIC roots shared by every tool that stages material on this
# bastion, not NKP's own directories. This module appends its own `nkp/`
# namespace (local.tool_*), so a future tool gets `<root>/<its-name>/` without
# anyone renegotiating the layout. That is why the defaults end at `lz-cli` and
# not at `nkp`.
#
# run_root defaults into /run because it is tmpfs: secrets staged there are
# memory-backed and cannot be recovered from the disk image, whereas `shred` on
# an ext4 root filesystem is not a guarantee. It costs one `install -d` at
# run time (or a systemd-tmpfiles rule in the bastion image) because /run itself
# is root-owned.
variable "bastion" {
  type = object({
    host         = string
    user         = optional(string, "linadmin")
    cache_root   = optional(string, "/var/tmp/lz-cli/cache")
    run_root     = optional(string, "/run/lz-cli")
    min_free_gib = optional(number, 60)
  })
  description = "Bastion the lz-cli hook connects to. host is a DNS name or IP typed by the operator. cache_root and run_root are generic per-host roots; this module namespaces itself underneath them."

  validation {
    condition     = length(trimspace(var.bastion.host)) > 0
    error_message = "bastion.host must be set: a DNS name or IP address for the host that runs the nkp CLI."
  }

  validation {
    condition     = startswith(var.bastion.cache_root, "/") && startswith(var.bastion.run_root, "/")
    error_message = "bastion.cache_root and bastion.run_root must be absolute paths on the bastion."
  }

  # Sharing one root would give the bundle and the kubeconfig the same lifetime
  # again, which is the whole reason they were split.
  validation {
    condition     = trimsuffix(var.bastion.cache_root, "/") != trimsuffix(var.bastion.run_root, "/")
    error_message = "bastion.cache_root and bastion.run_root must differ: the cache persists between runs and the run directory is destroyed after every run."
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
  description = "Air-gap artefact paths on the bastion. Both are mandatory: this module only renders air-gapped installs. Entries may be absolute, or relative to $${cache_dir} — see below."

  validation {
    condition     = length(var.airgap.bundles) > 0
    error_message = "airgap.bundles must list at least the konvoy and kommander image bundles."
  }

  # THE PLACEHOLDER FORM IS THE ONE TO USE.
  #
  # `${cache_dir}` expands to <bastion.cache_root>/nkp/v<version_contract.nkp>,
  # and `${nkp_version}` to the version itself, both resolved in locals.tf. The
  # caller used to do this substitution itself, which meant the directory-naming
  # convention was written down in two repositories and could drift: a caller
  # computing the old `<work_dir>/nkp-v<ver>` while this module looked in
  # `<cache_root>/nkp/v<ver>` produces a "bundle missing" error naming a path
  # that is, from the caller's point of view, obviously present.
  #
  # Absolute paths are still accepted for a bastion whose bundles were placed by
  # something other than the hook.
  validation {
    condition = alltrue([
      for b in var.airgap.bundles :
      startswith(b, "/") || startswith(b, "$${cache_dir}")
    ])
    error_message = "airgap.bundles entries must be absolute paths on the bastion, or begin with the $${cache_dir} placeholder."
  }

  validation {
    condition = (
      length(trimspace(var.airgap.bootstrap_cluster_image)) > 0 &&
      (startswith(var.airgap.bootstrap_cluster_image, "/") || startswith(var.airgap.bootstrap_cluster_image, "$${cache_dir}"))
    )
    error_message = "airgap.bootstrap_cluster_image must point at konvoy-bootstrap-image-<version>.tar, as an absolute path on the bastion or beginning with the $${cache_dir} placeholder."
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
#
# public_key_path IS NOT AN INPUT.
# --------------------------------
# It used to be, and every caller passed the same derived value: the directory
# this module already dictates, plus a filename the hook already hardcodes. That
# made a path this module owns look configurable, and put the run-directory
# layout in the caller's hands — where it drifted the moment the layout changed.
#
# It is now local.node_public_key_path, derived from bastion.run_root, and
# published through the contract so the hook stages the key exactly where the
# rendered argv looks for it. The operator still chooses the key itself; that is
# a path on THEIR machine (nkp/<cluster>.yaml ssh.keys.public) and is none of
# this module's business.
variable "ssh" {
  type = object({
    username = optional(string, "konvoy")
  })
  default     = {}
  description = "Node SSH access. The public key's location ON THE BASTION is derived from bastion.run_root, not configured here."

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
# Licence
##################################################

# APPLIED AUTOMATICALLY, BECAUSE THE DEFAULT IS NOT MERELY COSMETIC.
#
# An unlicensed cluster reports dkpLevel: Starter, and Starter gates most of
# what a management cluster is for: workspace management, projects, attaching
# workload clusters, and FluxCD as an application. Catalog applications
# themselves declare `licensing: [Pro, Ultimate]` in their metadata. So a
# cluster that comes up unlicensed is not a working cluster with a nag banner --
# it is one that cannot do the next step.
#
# There is no `nkp` verb for this; the documented route is a Secret holding the
# key plus a License CR referencing it by name, both applied with kubectl. The
# hook does exactly that, so the key travels from SOPS to the cluster without
# passing through argv, this variable, the contract or the state.
variable "license" {
  type = object({
    enabled = optional(bool, false)

    # The Kubernetes Secret the hook creates and the License CR points at. A
    # NAME; the key itself lives in nkp/<cluster>.sops.json at license.key.
    secret_name = optional(string, "nkp-license")
  })
  default     = {}
  description = "NKP licence application. The key is read from SOPS by the hook; only its Secret's name appears here."

  validation {
    condition     = !try(var.license.enabled, false) || trimspace(try(var.license.secret_name, "")) != ""
    error_message = "license.secret_name must be set when license.enabled is true: it names the Secret the hook creates and the License CR references."
  }
}

##################################################
# Catalog — the GitOps/RegistryOps seam to nkp-platform
##################################################

# HOW nkp-platform ACTUALLY REACHES THE CLUSTER, established by spiking a live
# NKP 2.18 cluster (ADR 0018 Revision 2026-08-03, revised again 2026-08-05).
#
# THE SEAM. lz-paas provisions the management cluster and hands over. This
# variable is the handover, and it has three parts applied in a REQUIRED ORDER
# the hook enforces in code rather than in lz.yaml, so reordering cannot break
# it:
#
#   workspaces   admin scope only, usually empty -- tenants are day-2, via Flux
#   registryops  the MENU: OCI catalogs, what exists and at what version
#   gitops       the ORDER: Flux against `deployed`, what is deployed where
#
# The licence comes before all three. Starter gates workspace management,
# projects and catalog applications, so an unlicensed cluster cannot do any of
# this.
#
# WHY `gitops` IS BACK, HAVING BEEN DELETED. The 2026-08-03 revision removed a
# `gitops` variable, on two findings that still stand:
#
#   1. `nkp create cluster` has NO gitops flags, so this was never create-time
#      argv -- and it still is not: gitops renders no argv at all.
#   2. NKP 2.18 offers no supported way to attach a SECOND SOURCE TO ITS OWN
#      git-operator. No CRD, no CLI flag, and `nkp experimental gitops clone`
#      only clones the internal repo.
#
# Neither finding forbids applying OUR OWN Flux GitRepository + Kustomization
# with kubectl, which is what this does -- the same route the licence Secret and
# the catalog pull secret already take. The deleted variable assumed the first
# thing; this one does the second. They are not the same design, and the earlier
# ADR explicitly left this open.
#
# WHAT THIS MODULE DOES NOT DO. It registers and it points; it does not build,
# push, or model what is inside. That boundary is ADR 0018's "everything inside
# the cluster after Flux".
variable "platform" {
  type = object({
    # ADMIN-SCOPE WORKSPACES ONLY, and normally EMPTY.
    #
    # kommander-workspace is created by the NKP install, and TENANT workspaces
    # are day-2: the tenant list is not known on day 1, and onboarding tenant 26
    # must not require an lz-paas run. Those come from nkp-platform over Flux.
    #
    # namespaceName IS PINNED TO THE NAME, ALWAYS -- the argv below always passes
    # -n. `nkp create workspace tenant-a` without it GENERATES a suffixed
    # namespace, observed as `tenant-a-2r6tk` on 2026-08-04, and nkp-platform
    # renders every manifest against the workspace NAME. Unpinned, each one
    # targets a namespace that never exists, and no offline check catches it.
    workspaces = optional(object({
      enabled = optional(bool, false)
      entries = optional(list(object({
        name         = string
        display_name = optional(string, null)
      })), [])
    }), {})

    # THE MENU. Each entry becomes one Flux OCIRepository per workspace,
    # carrying NKP's catalog label.
    registryops = optional(object({
      enabled = optional(bool, false)

      # How the cluster authenticates to the registry.
      #
      # secret_ref null is the AIR-GAP DEFAULT and the common case: `nkp`
      # patches the OCIRepository with the CAPI cluster's own registry-mirror
      # credentials, which in an air-gapped estate already point at the right
      # registry. Naming a secret (type kubernetes.io/dockerconfigjson)
      # overrides that, for a catalog registry that differs from the mirror.
      #
      # A NAME, never a value: no credential belongs in this plane or in state.
      registry = optional(object({
        # The USERNAME only. Its password lives in nkp/<cluster>.sops.json at
        # platform.registryops.password, and the hook builds the pull secret
        # from the two -- so a credential never enters this plane, the contract
        # or state.
        username   = optional(string, null)
        secret_ref = optional(string, null)
        insecure   = optional(bool, false)
      }), {})

      # Keyed by name, like the clusters map one level up: a validation error
      # then names the offending entry, and adding a second catalog is additive.
      entries = optional(map(object({
        url = string

        # EXACTLY ONE of these, enforced below.
        version = object({
          tag           = optional(string, null)
          semver        = optional(string, null)
          semver_filter = optional(string, null)
          digest        = optional(string, null)
        })

        # A LIST, not a scalar. One catalog is commonly wanted in several places
        # -- nkp-tenant-apps has to appear in every tenant's UI -- and repeating
        # the whole entry per workspace would repeat the version pin too, which
        # is the one thing that must not drift between them. Each element
        # produces its own registration argv.
        workspaces = list(string)

        project  = optional(string, null)
        interval = optional(string, "6h")
        timeout  = optional(string, "1m")
        suspend  = optional(bool, false)

        # Cosign signature verification. Optional, and off by default: nothing
        # in this estate signs artefacts yet. Present so adopting it later is
        # not a breaking change to this file's shape.
        verify = optional(object({
          provider   = optional(string, "cosign")
          secret_ref = optional(string, null)
          match_oidc_identity = optional(list(object({
            issuer  = string
            subject = string
          })), null)
        }), null)
      })), {})
    }), {})

    # THE ORDER. Renders NO ARGV -- the hook applies a GitRepository and a
    # Kustomization with kubectl, so everything here is carried through to the
    # contract as configuration rather than as a command.
    gitops = optional(object({
      enabled = optional(bool, false)

      # ONE OF THE FEW VALUES THAT CHANGES ON SITE: the GitHub Enterprise host,
      # which also serves the OCI catalogs and so breaks the chicken-and-egg of
      # Harbor not existing until the clusters that host it do.
      url = optional(string, null)

      # EXACTLY ONE of branch / tag / commit, enforced below. `deployed` is
      # force-pushed every run, so a branch ref is the normal choice; a commit
      # ref pins a cluster to exactly one render.
      ref = optional(object({
        branch = optional(string, null)
        tag    = optional(string, null)
        commit = optional(string, null)
      }), {})

      # Defaults to ./<cluster name> in locals. nkp-platform's CI writes
      # .render/<fleet>/ to the root of `deployed`, and a fleet is named after
      # its management cluster.
      path = optional(string, null)

      # A NAME. The hook builds this Secret from the deploy key and known_hosts
      # in nkp/<cluster>.sops.json.
      secret_ref = optional(string, null)

      # UNVERIFIED against a live cluster as of 2026-08-05: NKP runs
      # kommander-flux for its own platform applications, and whether it
      # reconciles CRs placed here is the first thing to confirm.
      namespace = optional(string, "kommander-flux")

      interval = optional(string, "10m")
      timeout  = optional(string, null)

      # Deleting a cluster file in nkp-platform deletes the cluster. The guard
      # against accident lives in nkp-platform, which refuses a render that
      # removes a cluster without an explicit decommission -- not here, because
      # by the time Flux sees it the decision was made two repos ago.
      prune = optional(bool, true)

      # Null means the kustomize-controller's own identity, the normal case.
      service_account = optional(string, null)

      suspend = optional(bool, false)
    }), {})
  })
  default     = {}
  description = "The seam to nkp-platform: admin workspaces, OCI catalog registrations, and the Flux source pointed at the rendered platform branch."

  ##################################################
  # workspaces
  ##################################################

  validation {
    condition     = !try(var.platform.workspaces.enabled, false) || length(try(var.platform.workspaces.entries, [])) > 0
    error_message = "platform.workspaces.enabled is true but entries is empty. Enabling it creates nothing -- set enabled = false, or add an entry. Note tenant workspaces are day-2 and come from nkp-platform over Flux; this block is for admin-scope workspaces only."
  }

  # A workspace name becomes a NAMESPACE name, because the argv always pins -n.
  # A name that is not a valid DNS label would fail at apply on the cluster,
  # which is a 45-minute round trip to learn a typo.
  validation {
    condition = alltrue([
      for w in try(var.platform.workspaces.entries, []) :
      can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", w.name))
    ])
    error_message = "Every platform.workspaces entry name must be a valid Kubernetes namespace name (lowercase alphanumeric and hyphens, starting and ending alphanumeric): it becomes the namespace as well as the workspace, because the namespace is always pinned to the name."
  }

  ##################################################
  # registryops
  ##################################################

  validation {
    condition     = !try(var.platform.registryops.enabled, false) || length(try(var.platform.registryops.entries, {})) > 0
    error_message = "platform.registryops.enabled is true but entries is empty. Enabling it registers nothing, which is almost certainly not what was meant -- set enabled = false, or add an entry."
  }

  validation {
    condition = alltrue([
      for name, e in try(var.platform.registryops.entries, {}) : startswith(e.url, "oci://")
    ])
    error_message = "Every platform.registryops entry url must be an OCI reference beginning oci://. A catalog is an OCI artefact, not a git repository -- see this variable's comment for why."
  }

  # EXACTLY ONE REF, REQUIRED.
  #
  # Flux defaults an OCIRepository with no ref to the `latest` tag. In an
  # air-gapped platform repo that is how a cluster becomes unreproducible: two
  # clusters built a week apart from identical config get different platform
  # versions, and nothing in the config records which. Requiring one forbids it.
  validation {
    condition = alltrue([
      for name, e in try(var.platform.registryops.entries, {}) :
      length([
        for v in [e.version.tag, e.version.semver, e.version.digest] : v if v != null
      ]) == 1
    ])
    error_message = "Each platform.registryops entry needs EXACTLY ONE of version.tag, version.semver or version.digest. None means Flux would silently follow the `latest` tag, which makes a cluster unreproducible; more than one is ambiguous (Flux resolves digest > semver > tag)."
  }

  # semver_filter is a regex applied WITHIN a semver range, so it is meaningless
  # on its own and silently ignored beside a tag or digest.
  validation {
    condition = alltrue([
      for name, e in try(var.platform.registryops.entries, {}) :
      e.version.semver_filter == null || e.version.semver != null
    ])
    error_message = "A platform.registryops entry sets version.semver_filter without version.semver. The filter narrows tags within a semver range and does nothing on its own."
  }

  # An entry with no workspace registers nowhere. The type makes the field
  # required but not non-empty, and `workspaces = []` would render zero argv and
  # look like a success.
  validation {
    condition = alltrue([
      for name, e in try(var.platform.registryops.entries, {}) : length(e.workspaces) > 0
    ])
    error_message = "Every platform.registryops entry needs at least one workspace. An empty list renders no registration at all and would report success having done nothing."
  }

  # The hook creates the pull secret from registry.username plus the password in
  # SOPS, and then passes --secret-ref. A username with no secret_ref would be
  # collected and never used; a secret_ref with no username would have the hook
  # build a dockerconfigjson with no login in it.
  validation {
    condition = (
      try(var.platform.registryops.registry.username, null) == null
      ) == (
      try(var.platform.registryops.registry.secret_ref, null) == null
    )
    error_message = "platform.registryops.registry.username and .secret_ref must be set together: the hook builds the pull secret named by secret_ref from that username and the password in nkp/<cluster>.sops.json. Set neither to inherit the cluster's own registry credentials, which is the air-gapped default."
  }

  ##################################################
  # gitops
  ##################################################

  validation {
    condition     = !try(var.platform.gitops.enabled, false) || try(var.platform.gitops.url, null) != null
    error_message = "platform.gitops.enabled is true but no url is set. There is no default: the repository is estate-specific and guessing one would point a cluster at somebody else's platform."
  }

  validation {
    condition = (
      !try(var.platform.gitops.enabled, false)
      || can(regex("^(ssh://|https://)", try(var.platform.gitops.url, "")))
    )
    error_message = "platform.gitops.url must begin ssh:// or https://. ssh:// with a read-only deploy key is the estate default; scp-style git@host:org/repo is NOT accepted by Flux."
  }

  # Exactly one ref, same reasoning as the catalog version pin: no ref at all
  # leaves Flux to pick, and more than one is ambiguous.
  validation {
    condition = (
      !try(var.platform.gitops.enabled, false)
      || length([
        for v in [
          try(var.platform.gitops.ref.branch, null),
          try(var.platform.gitops.ref.tag, null),
          try(var.platform.gitops.ref.commit, null),
        ] : v if v != null
      ]) == 1
    )
    error_message = "platform.gitops.ref needs EXACTLY ONE of branch, tag or commit. `deployed` is force-pushed every run, so branch = \"deployed\" is the normal choice; a commit pins a cluster to one render."
  }

  # The hook builds this Secret from the deploy key in SOPS. Without a name
  # there is nothing for the GitRepository to reference, and Flux would attempt
  # an anonymous clone that fails on a private repository.
  validation {
    condition     = !try(var.platform.gitops.enabled, false) || try(var.platform.gitops.secret_ref, null) != null
    error_message = "platform.gitops.enabled is true but secret_ref is null. The hook builds that Secret from platform.gitops.ssh_key and known_hosts in nkp/<cluster>.sops.json; without a name, Flux would attempt an anonymous clone."
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
