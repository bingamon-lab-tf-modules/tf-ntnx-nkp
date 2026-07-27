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

output "upgrade_script" {
  description = "Rendered 6-step nkp upgrade shell script"
  value       = local.upgrade_script
}

output "bastion_cloud_init" {
  description = "Rendered Bastion VM cloud-init user-data YAML string"
  value       = local.bastion_cloud_init
}

##################################################
# Aggregate Output (spec §4 contract)
##################################################

output "outputs" {
  description = "Aggregate of all module outputs (spec §4 contract, consumed by the landing zone as module.<x>.outputs)."
  value = {
    nkp_summary = {
      cluster_name = var.cluster_name
      profile      = var.profile
      pod_cidr     = var.pod_cidr
      service_cidr = var.service_cidr
    }
    prerequisites      = local.prerequisites
    bootstrap_script   = local.bootstrap_script
    upgrade_script     = local.upgrade_script
    bastion_cloud_init = local.bastion_cloud_init
  }
}
