##################################################
# Nutanix Infrastructure Data Sources
##################################################

data "nutanix_clusters_v2" "this" {
  count  = local.enable_data_lookups ? 1 : 0
  filter = "name eq '${var.prism_element_cluster}'"
}

data "nutanix_subnets_v2" "this" {
  count  = local.enable_data_lookups ? 1 : 0
  filter = "name eq '${var.control_plane_subnet}' or name eq '${var.worker_subnet}'"
}

data "nutanix_storage_containers_v2" "this" {
  count  = local.enable_data_lookups ? 1 : 0
  filter = "name eq '${var.csi_storage_container}'"
}
