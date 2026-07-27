##################################################
# NKP Outputs
##################################################

output "nkp_summary" {
  description = "Summary of NKP cluster configuration."
  value = {
    cluster_name = var.cluster_name
    profile      = var.profile
    pod_cidr     = var.pod_cidr
    service_cidr = var.service_cidr
  }
}

output "prerequisites" {
  description = "Map of validated Nutanix cluster, subnet, and container prerequisites."
  value       = local.prerequisites
}

output "bootstrap_script" {
  description = "Rendered nkp create cluster nutanix shell script"
  value       = local.bootstrap_script
}

##################################################
# Aggregate Output (spec §7.6 contract)
##################################################

output "outputs" {
  description = "Aggregate of all module outputs (spec §7.6 contract, consumed by the landing zone as module.<x>.outputs)."
  value = {
    nkp_summary = {
      cluster_name = var.cluster_name
      profile      = var.profile
      pod_cidr     = var.pod_cidr
      service_cidr = var.service_cidr
    }
    prerequisites    = local.prerequisites
    bootstrap_script = local.bootstrap_script
  }
}
