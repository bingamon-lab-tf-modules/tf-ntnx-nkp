##################################################
# Nutanix prerequisite lookups
#
# These make a typo'd subnet or an un-uploaded node image fail at PLAN instead
# of 40 minutes into a create. They are the only reason this module needs the
# nutanix provider at all — nothing here is ever written to.
#
# All are gated on var.enable_data_lookups: resolving them needs working Prism
# Central credentials at plan time, which unit tests and offline plans lack. The
# static validations in locals.tf never depend on this.
#
# Deliberately UNFILTERED, unlike the previous flat interface. A server-side
# OData $filter has to be escaped and kept in step with the names, and it breaks
# as soon as a pool overrides placement (two clusters, N subnets). These
# collections are small; matching client-side in locals.tf also lets an error
# message report what WAS found.
##################################################

data "nutanix_clusters_v2" "this" {
  count = var.enable_data_lookups ? 1 : 0

  # 100 is the Nutanix v4 API maximum for $limit (default 50); larger values are
  # rejected at runtime. A fleet beyond 100 would need page iteration.
  limit = 100
}

data "nutanix_subnets_v2" "this" {
  count = var.enable_data_lookups ? 1 : 0

  limit = 100
}

data "nutanix_storage_containers_v2" "this" {
  count = var.enable_data_lookups ? 1 : 0

  limit = 100
}

data "nutanix_images_v2" "this" {
  count = var.enable_data_lookups ? 1 : 0

  limit = 100
}
