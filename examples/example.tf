##################################################
# tf-ntnx-nkp — example usage
##################################################

terraform {
  required_version = ">= 1.9.0"
}

# NKP: no provider support — parked (decision 551).
#
# There is no supported usage for this module yet. The nutanix/nutanix provider
# ships zero nkp_* resources or data sources (verified through 2.4.3-beta1), so
# the module creates nothing: it only declares typed clusters/node_pools/
# registries variables guarded by check blocks that force them to stay empty,
# plus an nkp_summary output with status = "PENDING_PROVIDER_SUPPORT". Defining
# any NKP object today fails those checks by design.
#
# Once the provider ships real nkp_* resources, usage will look roughly like the
# sketch below (attribute names are illustrative and will track the eventual
# provider schema, not the placeholder variables):
#
# module "nkp" {
#   source = "github.com/bingamon-lab-tf-modules/tf-ntnx-nkp/module"
#
#   clusters = {
#     example = {
#       name               = "example"
#       kubernetes_version = "1.29.0"
#       control_plane = {
#         num_instances              = 3
#         cpu                        = 4
#         memory_mib                 = 8192
#         disk_gib                   = 120
#         network_uuid               = "<subnet-uuid>"
#         prism_element_cluster_uuid = "<prism-element-uuid>"
#       }
#     }
#   }
# }
#
# Revisit trigger (decision 551): re-check the provider schema for nkp_*
# resources on every nutanix/nutanix provider minor release.
