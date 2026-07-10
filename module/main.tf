##################################################
# NKP Clusters
##################################################

# TODO: nutanix_nkp_cluster resource is not yet available in the nutanix provider.
# Uncomment and implement when provider support is added.
#
# resource "nutanix_nkp_cluster" "cluster" {
#   for_each = var.clusters
#   name     = each.value.name
#   description = each.value.description
#   kubernetes_version = each.value.kubernetes_version
#
#   control_plane {
#     num_instances = each.value.control_plane.num_instances
#     cpu = each.value.control_plane.cpu
#     memory_mib = each.value.control_plane.memory_mib
#     disk_gib = each.value.control_plane.disk_gib
#     network_uuid = each.value.control_plane.network_uuid
#     prism_element_cluster_uuid = each.value.control_plane.prism_element_cluster_uuid
#   }
# }

##################################################
# NKP Node Pools
##################################################

# TODO: nutanix_nkp_node_pool resource is not yet available in the nutanix provider.
#
# resource "nutanix_nkp_node_pool" "node_pool" {
#   for_each = var.node_pools
#   name = each.value.name
#   cluster_id = nutanix_nkp_cluster.cluster[each.value.cluster_key].id
#   num_instances = each.value.num_instances
#   cpu = each.value.cpu
#   memory_mib = each.value.memory_mib
#   disk_gib = each.value.disk_gib
#   network_uuid = each.value.network_uuid
#   prism_element_cluster_uuid = each.value.prism_element_cluster_uuid
#   labels = each.value.labels
# }

##################################################
# NKP Registries
##################################################

# TODO: nutanix_nkp_registry resource is not yet available in the nutanix provider.
#
# resource "nutanix_nkp_registry" "registry" {
#   for_each = var.registries
#   name = each.value.name
#   url = each.value.url
#   port = each.value.port
#   username = each.value.username
#   password = each.value.password
#   cert = each.value.cert
# }
