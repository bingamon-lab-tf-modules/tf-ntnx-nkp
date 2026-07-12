##################################################
# NKP Outputs
##################################################

# TODO: Uncomment when NKP resources are available in the provider.

# output "clusters" {
#   description = "Map of NKP clusters with their details."
#   value = {
#     for k, v in nutanix_nkp_cluster.cluster : k => {
#       id                 = v.id
#       name               = v.name
#       kubernetes_version = v.kubernetes_version
#       status             = v.status
#       endpoint           = v.endpoint
#     }
#   }
# }

# output "node_pools" {
#   description = "Map of NKP node pools with their details."
#   value = {
#     for k, v in nutanix_nkp_node_pool.node_pool : k => {
#       id          = v.id
#       name        = v.name
#       cluster_id  = v.cluster_id
#       num_instances = v.num_instances
#       status      = v.status
#     }
#   }
# }

# output "registries" {
#   description = "Map of NKP registries with their details."
#   value = {
#     for k, v in nutanix_nkp_registry.registry : k => {
#       id   = v.id
#       name = v.name
#       url  = v.url
#       port = v.port
#     }
#   }
#   sensitive = true
# }

output "nkp_summary" {
  description = "Summary of NKP resources (pending provider support)."
  value = {
    status           = "PENDING_PROVIDER_SUPPORT"
    total_clusters   = length(var.clusters)
    total_node_pools = length(var.node_pools)
    total_registries = length(var.registries)
  }
  sensitive = true
}

##################################################
# Aggregate Output (spec §7.6 contract)
##################################################

output "outputs" {
  description = "Aggregate of all module outputs (spec §7.6 contract, consumed by the landing zone as module.<x>.outputs)."
  value = {
    nkp_summary = {
      status           = "PENDING_PROVIDER_SUPPORT"
      total_clusters   = length(var.clusters)
      total_node_pools = length(var.node_pools)
      total_registries = length(var.registries)
    }
  }
  sensitive = true
}
