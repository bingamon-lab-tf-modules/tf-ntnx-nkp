# TODO: Add validation checks when NKP resources are available in the provider.

check "nkp_provider_support" {
  assert {
    condition     = length(var.clusters) == 0
    error_message = "NKP resources are not yet supported in the nutanix provider. Do not define NKP clusters until provider support is added."
  }
}

check "nkp_node_pools_support" {
  assert {
    condition     = length(var.node_pools) == 0
    error_message = "NKP node pool resources are not yet supported in the nutanix provider. Do not define NKP node pools until provider support is added."
  }
}

check "nkp_registries_support" {
  assert {
    condition     = length(var.registries) == 0
    error_message = "NKP registry resources are not yet supported in the nutanix provider. Do not define NKP registries until provider support is added."
  }
}

# Future validation checks to add when provider support is available:
# - Validate Kubernetes version is supported
# - Validate control plane has odd number of instances (HA requirement)
# - Validate resource sizes (CPU, memory, disk) meet minimum requirements
# - Validate network UUIDs exist
# - Validate cluster references in node pools are valid
# - Validate registry URLs are properly formatted
