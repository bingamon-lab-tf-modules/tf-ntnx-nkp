##################################################
# Nutanix v2 data lookup coverage
# cspell:words dedup
#
# Exercises enable_data_lookups = true offline using OpenTofu's mock_provider,
# validating the nutanix_clusters_v2, nutanix_subnets_v2,
# nutanix_storage_containers_v2, and nutanix_images_v2 provider schemas as well
# as local.existence_errors and local.prerequisites in locals.tf.
##################################################

mock_provider "nutanix" {}

variables {
  enable_data_lookups = true
  enforce_validation  = false

  cluster_name = "nkp-mgmt"

  bastion = {
    host = "nkp-bastion.example.test"
  }

  version_contract = {
    nkp        = "2.18.0"
    kubernetes = "1.35.2"
  }

  prism_central = {
    endpoint = "pc.example.test"
    user     = "nkp-capx"
  }

  airgap = {
    bundles = [
      "$${cache_dir}/container-images/konvoy-image-bundle-v$${nkp_version}.tar",
      "$${cache_dir}/container-images/kommander-image-bundle-v$${nkp_version}.tar",
    ]
    bootstrap_cluster_image = "$${cache_dir}/konvoy-bootstrap-image-v$${nkp_version}.tar"
  }

  placement = {
    prism_element_cluster = "pe-cluster-01"
    subnets               = ["vlan84-k8s"]
    vm_image              = "nkp-ubuntu-24.04-release-cis-1.35.2-20260626141256"
  }

  control_plane = {
    endpoint_ip = "192.0.2.150"
  }

  workers = {
    prism_element_cluster = "pe-cluster-02"
    subnets               = ["vlan85-workers"]
    vm_image              = "nkp-ubuntu-24.04-worker-cis-1.35.2-20260626141256"
  }

  networking = {
    load_balancer_ip_range = "192.0.2.151-192.0.2.170"
  }

  csi = {
    storage_container = "k8s-persistent"
  }

  ssh = {
    username = "konvoy"
  }
}

run "data_lookups_resolve_all_prerequisites" {
  command = plan

  variables {
    enforce_validation = true
  }

  override_data {
    target = data.nutanix_clusters_v2.this[0]
    values = {
      cluster_entities = [
        for item in [
          { name = "pe-cluster-01", ext_id = "00000000-0000-4000-8000-000000000001" },
          { name = "pe-cluster-02", ext_id = "00000000-0000-4000-8000-000000000002" },
          { name = "pe-unreferenced", ext_id = "00000000-0000-4000-8000-000000000099" },
          ] : {
          name                     = item.name
          ext_id                   = item.ext_id
          backup_eligibility_score = null
          categories               = null
          cluster_profile_ext_id   = null
          config                   = null
          container_name           = null
          expand                   = null
          inefficient_vm_count     = null
          links                    = null
          network                  = null
          nodes                    = null
          tenant_id                = null
          upgrade_status           = null
          vm_count                 = null
        }
      ]
    }
  }

  override_data {
    target = data.nutanix_subnets_v2.this[0]
    values = {
      subnets = [
        for item in [
          { name = "vlan84-k8s", ext_id = "00000000-0000-4000-8000-000000000011" },
          { name = "vlan85-workers", ext_id = "00000000-0000-4000-8000-000000000012" },
          { name = "vlan99-unused", ext_id = "00000000-0000-4000-8000-000000000019" },
          ] : {
          name                             = item.name
          ext_id                           = item.ext_id
          bridge_name                      = null
          cluster_name                     = null
          cluster_reference                = null
          description                      = null
          dhcp_options                     = null
          dynamic_ip_addresses             = null
          hypervisor_type                  = null
          ip_config                        = null
          ip_prefix                        = null
          ip_usage                         = null
          is_advanced_networking           = null
          is_connected                     = null
          is_external                      = null
          is_nat_enabled                   = null
          links                            = null
          metadata                         = null
          migration_state                  = null
          network_function_chain_reference = null
          network_id                       = null
          project_ext_id                   = null
          reserved_ip_addresses            = null
          shared_with_projects             = null
          subnet_type                      = null
          virtual_switch                   = null
          virtual_switch_reference         = null
          vpc                              = null
          vpc_reference                    = null
        }
      ]
    }
  }

  override_data {
    target = data.nutanix_storage_containers_v2.this[0]
    values = {
      storage_containers = [
        for item in [
          { name = "k8s-persistent", container_ext_id = "00000000-0000-4000-8000-000000000021" },
          { name = "default-container", container_ext_id = "00000000-0000-4000-8000-000000000029" },
          ] : {
          name                                     = item.name
          container_ext_id                         = item.container_ext_id
          affinity_host_ext_id                     = null
          cache_deduplication                      = null
          cluster_ext_id                           = null
          cluster_name                             = null
          compression_delay_secs                   = null
          erasure_code                             = null
          erasure_code_delay_secs                  = null
          ext_id                                   = null
          has_higher_ec_fault_domain_preference    = null
          is_compression_enabled                   = null
          is_encrypted                             = null
          is_inline_ec_enabled                     = null
          is_internal                              = null
          is_marked_for_removal                    = null
          is_nfs_whitelist_inherited               = null
          is_software_encryption_enabled           = null
          links                                    = null
          logical_advertised_capacity_bytes        = null
          logical_explicit_reserved_capacity_bytes = null
          logical_implicit_reserved_capacity_bytes = null
          max_capacity_bytes                       = null
          nfs_whitelist_addresses                  = null
          on_disk_dedup                            = null
          owner_ext_id                             = null
          replication_factor                       = null
          storage_pool_ext_id                      = null
          tenant_id                                = null
        }
      ]
    }
  }

  override_data {
    target = data.nutanix_images_v2.this[0]
    values = {
      images = [
        for item in [
          { name = "nkp-ubuntu-24.04-release-cis-1.35.2-20260626141256", ext_id = "00000000-0000-4000-8000-000000000031" },
          { name = "nkp-ubuntu-24.04-worker-cis-1.35.2-20260626141256", ext_id = "00000000-0000-4000-8000-000000000032" },
          { name = "other-image", ext_id = "00000000-0000-4000-8000-000000000039" },
          ] : {
          name                     = item.name
          ext_id                   = item.ext_id
          category_ext_ids         = null
          checksum                 = null
          cluster_location_ext_ids = null
          create_time              = null
          description              = null
          last_update_time         = null
          owner_ext_id             = null
          placement_policy_status  = null
          project_ext_id           = null
          share_with_all_projects  = null
          size_bytes               = null
          source                   = null
          type                     = null
        }
      ]
    }
  }

  assert {
    condition     = length(output.validation_errors) == 0
    error_message = "Expected zero validation errors when all objects exist, got: ${join("; ", output.validation_errors)}"
  }

  assert {
    condition = output.prerequisites.prism_element_clusters == tomap({
      "pe-cluster-01" = "00000000-0000-4000-8000-000000000001"
      "pe-cluster-02" = "00000000-0000-4000-8000-000000000002"
    })
    error_message = "Unexpected resolved prism_element_clusters map."
  }

  assert {
    condition = output.prerequisites.subnets == tomap({
      "vlan84-k8s"     = "00000000-0000-4000-8000-000000000011"
      "vlan85-workers" = "00000000-0000-4000-8000-000000000012"
    })
    error_message = "Unexpected resolved subnets map."
  }

  assert {
    condition = output.prerequisites.storage_containers == tomap({
      "k8s-persistent" = "00000000-0000-4000-8000-000000000021"
    })
    error_message = "Unexpected resolved storage_containers map."
  }

  assert {
    condition = output.prerequisites.vm_images == tomap({
      "nkp-ubuntu-24.04-release-cis-1.35.2-20260626141256" = "00000000-0000-4000-8000-000000000031"
      "nkp-ubuntu-24.04-worker-cis-1.35.2-20260626141256"  = "00000000-0000-4000-8000-000000000032"
    })
    error_message = "Unexpected resolved vm_images map."
  }
}

run "data_lookups_report_all_missing_objects" {
  command = plan

  variables {
    workers = {}
  }

  override_data {
    target = data.nutanix_clusters_v2.this[0]
    values = {
      cluster_entities = []
    }
  }

  override_data {
    target = data.nutanix_subnets_v2.this[0]
    values = {
      subnets = []
    }
  }

  override_data {
    target = data.nutanix_storage_containers_v2.this[0]
    values = {
      storage_containers = []
    }
  }

  override_data {
    target = data.nutanix_images_v2.this[0]
    values = {
      images = []
    }
  }

  assert {
    condition     = length(output.validation_errors) == 4
    error_message = "Expected 4 existence errors when every lookup collection is empty, got ${length(output.validation_errors)}: ${join("; ", output.validation_errors)}"
  }

  assert {
    condition     = contains(output.validation_errors, "Prism Element cluster 'pe-cluster-01' was not found on pc.example.test.")
    error_message = "Missing expected cluster existence error."
  }

  assert {
    condition     = contains(output.validation_errors, "Subnet 'vlan84-k8s' was not found on pc.example.test.")
    error_message = "Missing expected subnet existence error."
  }

  assert {
    condition     = contains(output.validation_errors, "VM image 'nkp-ubuntu-24.04-release-cis-1.35.2-20260626141256' was not found on pc.example.test. Upload the NKP node image before creating the cluster.")
    error_message = "Missing expected VM image existence error."
  }

  assert {
    condition     = contains(output.validation_errors, "Storage container 'k8s-persistent' was not found on pc.example.test.")
    error_message = "Missing expected storage container existence error."
  }
}

run "data_lookups_fail_precondition_when_enforced" {
  command = plan

  variables {
    enforce_validation = true
    workers            = {}
  }

  override_data {
    target = data.nutanix_clusters_v2.this[0]
    values = {
      cluster_entities = []
    }
  }

  override_data {
    target = data.nutanix_subnets_v2.this[0]
    values = {
      subnets = []
    }
  }

  override_data {
    target = data.nutanix_storage_containers_v2.this[0]
    values = {
      storage_containers = []
    }
  }

  override_data {
    target = data.nutanix_images_v2.this[0]
    values = {
      images = []
    }
  }

  expect_failures = [
    terraform_data.validation,
  ]
}
