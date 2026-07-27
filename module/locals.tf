locals {
  # Enable data lookups only when Nutanix credentials are provided and non-dummy (e.g. not offline test)
  enable_data_lookups = var.nutanix_username != null && var.nutanix_password != null && var.nutanix_username != "" && var.nutanix_username != "dummy"

  # Helper lookup maps from Nutanix v2 data sources
  cluster_uuids_by_name = {
    for c in try(data.nutanix_clusters_v2.this[0].cluster_entities, []) :
    c.name => c.ext_id
  }

  subnet_uuids_by_name = {
    for s in try(data.nutanix_subnets_v2.this[0].subnets, []) :
    s.name => s.ext_id
  }

  storage_container_uuids_by_name = {
    for sc in try(data.nutanix_storage_containers_v2.this[0].storage_containers, []) :
    sc.name => try(sc.container_ext_id, sc.ext_id)
  }

  # Resolved Nutanix UUIDs (falling back to variable inputs in plan-only/offline mode or if already UUIDs)
  prism_element_cluster_uuid = try(
    local.cluster_uuids_by_name[var.prism_element_cluster],
    var.prism_element_cluster
  )

  control_plane_subnet_uuid = try(
    local.subnet_uuids_by_name[var.control_plane_subnet],
    var.control_plane_subnet
  )

  worker_subnet_uuid = try(
    local.subnet_uuids_by_name[var.worker_subnet],
    var.worker_subnet
  )

  csi_storage_container_uuid = try(
    local.storage_container_uuids_by_name[var.csi_storage_container],
    var.csi_storage_container
  )

  # Infrastructure prerequisites summary map
  prerequisites = {
    prism_central_endpoint = var.prism_central_endpoint
    prism_element_cluster = {
      name = var.prism_element_cluster
      uuid = local.prism_element_cluster_uuid
    }
    control_plane_subnet = {
      name = var.control_plane_subnet
      uuid = local.control_plane_subnet_uuid
    }
    worker_subnet = {
      name = var.worker_subnet
      uuid = local.worker_subnet_uuid
    }
    csi_storage_container = {
      name = var.csi_storage_container
      uuid = local.csi_storage_container_uuid
    }
  }
  # Profile-based sizing & application configuration
  worker_replicas = var.profile == "small" ? 3 : 4
  app_flags       = var.profile == "small" ? "--app-options=\"rook-ceph.enabled=false,velero.enabled=false,logging-operator.enabled=false,kube-prometheus-stack.enabled=false\" --disable-apps=\"rook-ceph,velero,logging,monitoring\"" : ""
  bundle_flags    = length(var.bundle_paths) > 0 ? "--bundle=${join(",", var.bundle_paths)}" : ""

  # Rendered nkp create cluster nutanix bootstrap script
  bootstrap_script = trimspace(<<-EOF
    #!/usr/bin/env bash
    set -euo pipefail

    nkp create cluster nutanix \
      --cluster-name="${var.cluster_name}" \
      --endpoint="${var.prism_central_endpoint}" \
      --control-plane-endpoint-ip="${var.control_plane_vip}" \
      --control-plane-prism-element-cluster="${var.prism_element_cluster}" \
      --control-plane-subnets="${var.control_plane_subnet}" \
      --control-plane-vm-image="${var.control_plane_vm_image}" \
      --worker-prism-element-cluster="${var.prism_element_cluster}" \
      --worker-subnets="${var.worker_subnet}" \
      --worker-vm-image="${var.worker_vm_image}" \
      --worker-replicas=${local.worker_replicas} \
      --csi-storage-container="${var.csi_storage_container}" \
      --kubernetes-service-load-balancer-ip-range="${var.load_balancer_ip_range}" \
      --kubernetes-pod-network-cidr="${var.pod_cidr}" \
      --kubernetes-service-cidr="${var.service_cidr}" \
      --airgapped=true${local.bundle_flags != "" ? " \\\n  ${local.bundle_flags}" : ""}${local.app_flags != "" ? " \\\n  ${local.app_flags}" : ""}
  EOF
  )
}
