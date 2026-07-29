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
      --bootstrap-cluster-image="${var.bootstrap_cluster_image}" \
      --self-managed \
      --airgapped=true${local.bundle_flags != "" ? " \\\n  ${local.bundle_flags}" : ""}${local.app_flags != "" ? " \\\n  ${local.app_flags}" : ""}
  EOF
  )
  # Rendered 6-step nkp upgrade shell script
  upgrade_script = trimspace(<<-EOF
    #!/usr/bin/env bash
    set -euo pipefail

    nkp upgrade capi-components
    nkp upgrade cluster nutanix --vm-image="${var.worker_vm_image}"
    nkp upgrade kommander
    nkp upgrade workspace "${var.cluster_name}"
    nkp upgrade addons
    nkp upgrade catalogapp
  EOF
  )

  # Rendered Bastion VM cloud-init user-data YAML string
  bastion_cloud_init = trimspace(<<-EOF
    #cloud-config
    hostname: ${var.cluster_name}-bastion
    ${length(var.bastion_ssh_keys) > 0 ? "ssh_authorized_keys:\n${join("\n", [for key in var.bastion_ssh_keys : "  - ${key}"])}" : "# ssh_authorized_keys: none configured"}
    write_files:
      - path: /etc/pki/ca-trust/source/anchors/internal-ca.crt
        permissions: '0644'
        content: |
          ${indent(10, length(var.ca_certificates) > 0 ? join("\n", var.ca_certificates) : "# Internal CA Certificate Trust Bundle\n# Placeholder / No custom CA certificates supplied")}
      - path: /usr/local/bin/unpack-airgap-bundles.sh
        permissions: '0755'
        content: |
          #!/usr/bin/env bash
          set -euo pipefail
          echo "Initializing air-gapped bundle unpacking for NKP management cluster ${var.cluster_name}..."
          BUNDLE_DIR="/var/tmp/nkp-bundles"
          mkdir -p "$${BUNDLE_DIR}"
          for bundle in "$${BUNDLE_DIR}"/*.tar "$${BUNDLE_DIR}"/*.tar.gz /tmp/*.tar; do
            if [ -f "$${bundle}" ]; then
              echo "Unpacking air-gapped bundle: $${bundle}"
              tar -xvf "$${bundle}" -C "$${BUNDLE_DIR}/" || true
            fi
          done
          echo "Bundle unpacking completed."
      - path: /etc/profile.d/sops-env.sh
        permissions: '0644'
        content: |
          # SOPS Decryption Tools & Environment Configuration
          export SOPS_AGE_KEY_FILE="$${HOME}/.config/sops/age/keys.txt"
          export SOPS_DECRYPT_TOOL="sops"
          export NKP_CLUSTER_NAME="${var.cluster_name}"
          export PRISM_CENTRAL_ENDPOINT="${var.prism_central_endpoint}"
    packages:
      - sops
      - age
      - ca-certificates
      - tar
      - gzip
    runcmd:
      - update-ca-trust || update-ca-certificates || true
      - chmod +x /usr/local/bin/unpack-airgap-bundles.sh
      - /usr/local/bin/unpack-airgap-bundles.sh
  EOF
  )
}
