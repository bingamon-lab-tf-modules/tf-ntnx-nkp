##################################################
# tf-ntnx-nkp — outputs
#
# NOTHING HERE MAY BE SECRET. Outputs land in OpenTofu state and in
# `tofu output`; the contract carries the NAMES of the credentials it needs and
# the hook resolves the values from SOPS at run time (lz-paas ADR 0018).
##################################################

output "contract" {
  description = <<-EOT
    Execution contract for the lz-cli hooks: argv for create and delete, the
    non-secret environment, the names of required secret environment variables,
    the bastion to run on, and what ensure_ready() must verify first.

    The caller writes this to .lz/<env>/nkp-contract.json. Contains no secrets.
  EOT
  value       = local.contract
}

output "prerequisites" {
  description = "Resolved Nutanix ext_ids for the referenced clusters, subnets, storage container and node images. Empty when enable_data_lookups is false."
  value       = local.prerequisites
}

output "validation_errors" {
  description = "Every configuration error found, aggregated. Empty on a valid configuration; a non-empty list fails the plan via the precondition in main.tf. Exposed so it can be asserted directly in tests."
  value       = local.validation_errors
}

output "command_human" {
  description = "The create command rendered as a copy-pasteable shell string, for docs and manual reproduction. Credentials appear only as environment variables the operator exports, never inline."
  value       = local.command_human
}

output "summary" {
  description = "Compact summary of what this cluster will be."
  value = {
    cluster_name       = var.cluster_name
    nkp_version        = var.version_contract.nkp
    kubernetes_version = var.version_contract.kubernetes
    control_plane = {
      replicas   = var.control_plane.replicas
      vcpus      = var.control_plane.vcpus
      memory_gib = var.control_plane.memory_gib
      vip        = var.control_plane.endpoint_ip
    }
    workers = {
      replicas   = var.workers.replicas
      vcpus      = var.workers.vcpus
      memory_gib = var.workers.memory_gib
    }
    networking = {
      pod_cidr               = var.networking.pod_cidr
      service_cidr           = var.networking.service_cidr
      load_balancer_ip_range = var.networking.load_balancer_ip_range
    }
    placement = {
      prism_element_cluster = local.cp_prism_element
      subnets               = local.referenced_subnets
      vm_image              = local.cp_vm_image
      storage_container     = var.csi.storage_container
    }
    airgapped    = true
    self_managed = true
  }
}

##################################################
# Aggregate (landing-zone contract)
##################################################

# The landing zone consumes module.<x>.outputs.<key>, matching the convention
# every other tf-ntnx-* module in this estate follows.
output "outputs" {
  description = "Aggregate of all module outputs, consumed by the landing zone as module.<x>.outputs."
  value = {
    contract          = local.contract
    prerequisites     = local.prerequisites
    validation_errors = local.validation_errors
    command_human     = local.command_human
    summary = {
      cluster_name       = var.cluster_name
      nkp_version        = var.version_contract.nkp
      kubernetes_version = var.version_contract.kubernetes
    }
  }
}
