provider "nutanix" {
  username     = "dummy"
  password     = "dummy"
  endpoint     = "dummy.local"
  port         = 9440
  insecure     = true
  wait_timeout = 1
}

run "nkp_summary_valid" {
  command = plan

  variables {
    cluster_name           = "nkp-mgmt-01"
    profile                = "small"
    prism_central_endpoint = "pc.lab.local"
    control_plane_vip      = "192.168.82.10"
    prism_element_cluster  = "pe-cluster-01"
    control_plane_subnet   = "vlan82-cp"
    worker_subnet          = "vlan82-worker"
    csi_storage_container  = "csi-container-01"
    load_balancer_ip_range = "192.168.82.20-192.168.82.39"
    control_plane_vm_image = "rocky-9.4-kube-v1.30.5"
    worker_vm_image        = "rocky-9.4-kube-v1.30.5"
  }

  assert {
    condition     = output.outputs.nkp_summary.cluster_name == "nkp-mgmt-01"
    error_message = "Expected cluster_name to be nkp-mgmt-01"
  }

  assert {
    condition     = output.outputs.nkp_summary.profile == "small"
    error_message = "Expected profile to be small"
  }

  assert {
    condition     = output.outputs.prerequisites.prism_element_cluster.name == "pe-cluster-01"
    error_message = "Expected Prism Element cluster name to match"
  }

  assert {
    condition     = output.outputs.prerequisites.control_plane_subnet.name == "vlan82-cp"
    error_message = "Expected control plane subnet name to match"
  }

  assert {
    condition     = output.outputs.prerequisites.worker_subnet.name == "vlan82-worker"
    error_message = "Expected worker subnet name to match"
  }

  assert {
    condition     = output.outputs.prerequisites.csi_storage_container.name == "csi-container-01"
    error_message = "Expected storage container name to match"
  }
}

run "nkp_bootstrap_script_valid" {
  command = plan

  variables {
    cluster_name           = "nkp-mgmt-01"
    profile                = "small"
    prism_central_endpoint = "pc.lab.local"
    control_plane_vip      = "192.168.82.10"
    prism_element_cluster  = "pe-cluster-01"
    control_plane_subnet   = "vlan82-cp"
    worker_subnet          = "vlan82-worker"
    csi_storage_container  = "csi-container-01"
    load_balancer_ip_range = "192.168.82.20-192.168.82.39"
    control_plane_vm_image = "rocky-9.4-kube-v1.30.5"
    worker_vm_image        = "rocky-9.4-kube-v1.30.5"
  }

  assert {
    condition     = can(regex("--airgapped=true", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain --airgapped=true"
  }

  assert {
    condition     = can(regex("--kubernetes-pod-network-cidr=.*172\\.20\\.0\\.0/16", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain --kubernetes-pod-network-cidr=172.20.0.0/16"
  }

  assert {
    condition     = can(regex("--cluster-name=.*nkp-mgmt-01", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain --cluster-name=nkp-mgmt-01"
  }
}

run "bootstrap_script_profile_small" {
  command = plan

  variables {
    cluster_name           = "nkp-mgmt-01"
    profile                = "small"
    prism_central_endpoint = "pc.lab.local"
    control_plane_vip      = "192.168.82.10"
    prism_element_cluster  = "pe-cluster-01"
    control_plane_subnet   = "vlan82-cp"
    worker_subnet          = "vlan82-worker"
    csi_storage_container  = "csi-container-01"
    load_balancer_ip_range = "192.168.82.20-192.168.82.39"
    control_plane_vm_image = "rocky-9.4-kube-v1.30.5"
    worker_vm_image        = "rocky-9.4-kube-v1.30.5"
    bundle_paths           = ["/tmp/kommander.tar", "/tmp/konvoy.tar"]
  }

  assert {
    condition     = can(regex("--airgapped=true", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain hardcoded --airgapped=true"
  }

  assert {
    condition     = can(regex("--kubernetes-pod-network-cidr=.*172\\.20\\.0\\.0/16", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain pod network CIDR 172.20.0.0/16"
  }

  assert {
    condition     = can(regex("--kubernetes-service-cidr=.*10\\.96\\.0\\.0/12", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain service CIDR 10.96.0.0/12"
  }

  assert {
    condition     = can(regex("--worker-replicas=3", output.bootstrap_script))
    error_message = "Expected profile small to render --worker-replicas=3"
  }

  assert {
    condition     = can(regex("--bundle=/tmp/kommander.tar,/tmp/konvoy.tar", output.bootstrap_script))
    error_message = "Expected bootstrap_script to render bundle paths"
  }

  assert {
    condition     = output.outputs.bootstrap_script == output.bootstrap_script
    error_message = "Expected aggregate output.outputs.bootstrap_script to match top-level output"
  }
}

run "bootstrap_script_profile_full" {
  command = plan

  variables {
    cluster_name           = "nkp-mgmt-01"
    profile                = "full"
    prism_central_endpoint = "pc.lab.local"
    control_plane_vip      = "192.168.82.10"
    prism_element_cluster  = "pe-cluster-01"
    control_plane_subnet   = "vlan82-cp"
    worker_subnet          = "vlan82-worker"
    csi_storage_container  = "csi-container-01"
    load_balancer_ip_range = "192.168.82.20-192.168.82.39"
    control_plane_vm_image = "rocky-9.4-kube-v1.30.5"
    worker_vm_image        = "rocky-9.4-kube-v1.30.5"
  }

  assert {
    condition     = can(regex("--worker-replicas=4", output.bootstrap_script))
    error_message = "Expected profile full to render --worker-replicas=4"
  }
}

run "upgrade_script_valid" {
  command = plan

  variables {
    cluster_name           = "nkp-mgmt-01"
    profile                = "small"
    prism_central_endpoint = "pc.lab.local"
    control_plane_vip      = "192.168.82.10"
    prism_element_cluster  = "pe-cluster-01"
    control_plane_subnet   = "vlan82-cp"
    worker_subnet          = "vlan82-worker"
    csi_storage_container  = "csi-container-01"
    load_balancer_ip_range = "192.168.82.20-192.168.82.39"
    control_plane_vm_image = "rocky-9.4-kube-v1.30.5"
    worker_vm_image        = "rocky-9.4-kube-v1.30.5"
  }

  assert {
    condition     = can(regex("nkp upgrade capi-components", output.upgrade_script))
    error_message = "Expected upgrade_script to contain step 1: nkp upgrade capi-components"
  }

  assert {
    condition     = can(regex("nkp upgrade cluster nutanix --vm-image=\"rocky-9.4-kube-v1.30.5\"", output.upgrade_script))
    error_message = "Expected upgrade_script to contain step 2: nkp upgrade cluster nutanix with --vm-image"
  }

  assert {
    condition     = can(regex("nkp upgrade kommander", output.upgrade_script))
    error_message = "Expected upgrade_script to contain step 3: nkp upgrade kommander"
  }

  assert {
    condition     = can(regex("nkp upgrade workspace \"nkp-mgmt-01\"", output.upgrade_script))
    error_message = "Expected upgrade_script to contain step 4: nkp upgrade workspace"
  }

  assert {
    condition     = can(regex("nkp upgrade addons", output.upgrade_script))
    error_message = "Expected upgrade_script to contain step 5: nkp upgrade addons"
  }

  assert {
    condition     = can(regex("nkp upgrade catalogapp", output.upgrade_script))
    error_message = "Expected upgrade_script to contain step 6: nkp upgrade catalogapp"
  }

  assert {
    condition     = can(regex("(?s)nkp upgrade capi-components.*nkp upgrade cluster nutanix.*nkp upgrade kommander.*nkp upgrade workspace.*nkp upgrade addons.*nkp upgrade catalogapp", output.upgrade_script))
    error_message = "Expected 6 upgrade commands in exact sequential order"
  }

  assert {
    condition     = output.outputs.upgrade_script == output.upgrade_script
    error_message = "Expected aggregate output.outputs.upgrade_script to match top-level output"
  }
}

run "bastion_cloud_init_valid" {
  command = plan

  variables {
    cluster_name           = "nkp-mgmt-01"
    profile                = "small"
    prism_central_endpoint = "pc.lab.local"
    control_plane_vip      = "192.168.82.10"
    prism_element_cluster  = "pe-cluster-01"
    control_plane_subnet   = "vlan82-cp"
    worker_subnet          = "vlan82-worker"
    csi_storage_container  = "csi-container-01"
    load_balancer_ip_range = "192.168.82.20-192.168.82.39"
    control_plane_vm_image = "rocky-9.4-kube-v1.30.5"
    worker_vm_image        = "rocky-9.4-kube-v1.30.5"
    ca_certificates        = ["-----BEGIN CERTIFICATE-----\nMIIC...\n-----END CERTIFICATE-----"]
    bastion_ssh_keys       = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ... admin@lab"]
  }

  assert {
    condition     = can(regex("^#cloud-config", output.bastion_cloud_init))
    error_message = "Expected bastion_cloud_init to start with #cloud-config header"
  }

  assert {
    condition     = can(regex("hostname: nkp-mgmt-01-bastion", output.bastion_cloud_init))
    error_message = "Expected bastion_cloud_init to set hostname"
  }

  assert {
    condition     = can(regex("ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ\\.\\.\\. admin@lab", output.bastion_cloud_init))
    error_message = "Expected bastion_cloud_init to include provided SSH key"
  }

  assert {
    condition     = can(regex("/etc/pki/ca-trust/source/anchors/internal-ca\\.crt", output.bastion_cloud_init))
    error_message = "Expected bastion_cloud_init to write internal CA certificate file"
  }

  assert {
    condition     = can(regex("/usr/local/bin/unpack-airgap-bundles\\.sh", output.bastion_cloud_init))
    error_message = "Expected bastion_cloud_init to write air-gapped bundle unpacking script"
  }

  assert {
    condition     = can(regex("/etc/profile\\.d/sops-env\\.sh", output.bastion_cloud_init))
    error_message = "Expected bastion_cloud_init to stage SOPS environment configuration script"
  }

  assert {
    condition     = can(regex("export SOPS_AGE_KEY_FILE=", output.bastion_cloud_init))
    error_message = "Expected bastion_cloud_init to contain SOPS age key env variable"
  }

  assert {
    condition     = can(regex("- sops", output.bastion_cloud_init))
    error_message = "Expected bastion_cloud_init to declare sops package"
  }

  assert {
    condition     = output.outputs.bastion_cloud_init == output.bastion_cloud_init
    error_message = "Expected aggregate output.outputs.bastion_cloud_init to match top-level output"
  }
}
