provider "nutanix" {
  username     = "dummy"
  password     = "dummy"
  endpoint     = "dummy.local"
  port         = 9440
  insecure     = true
  wait_timeout = 1
}

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
  # Required: air-gapped KIND cannot pull konvoy-bootstrap from Docker Hub.
  bootstrap_cluster_image = "./nkp-v2.18.0/konvoy-bootstrap-image-v2.18.0.tar"
}

run "nkp_summary_valid" {
  command = plan

  assert {
    condition     = output.nkp_summary.cluster_name == "nkp-mgmt-01"
    error_message = "Expected top-level nkp_summary.cluster_name to be nkp-mgmt-01"
  }

  assert {
    condition     = output.nkp_summary.profile == "small"
    error_message = "Expected top-level nkp_summary.profile to be small"
  }

  assert {
    condition     = output.nkp_summary.pod_cidr == "172.20.0.0/16"
    error_message = "Expected top-level nkp_summary.pod_cidr to be default 172.20.0.0/16"
  }

  assert {
    condition     = output.nkp_summary.service_cidr == "10.96.0.0/12"
    error_message = "Expected top-level nkp_summary.service_cidr to be default 10.96.0.0/12"
  }

  assert {
    condition     = output.outputs.nkp_summary == output.nkp_summary
    error_message = "Expected aggregate output.outputs.nkp_summary to match top-level nkp_summary"
  }

  assert {
    condition     = output.prerequisites.prism_central_endpoint == "pc.lab.local"
    error_message = "Expected top-level prerequisites FQDN endpoint to match pc.lab.local"
  }

  assert {
    condition     = output.prerequisites.prism_element_cluster.name == "pe-cluster-01"
    error_message = "Expected top-level prerequisites Prism Element cluster name to match"
  }

  assert {
    condition     = output.prerequisites.prism_element_cluster.uuid == "pe-cluster-01"
    error_message = "Expected top-level prerequisites Prism Element cluster UUID to match fallback name"
  }

  assert {
    condition     = output.prerequisites.control_plane_subnet.name == "vlan82-cp"
    error_message = "Expected top-level prerequisites control plane subnet name to match"
  }

  assert {
    condition     = output.prerequisites.control_plane_subnet.uuid == "vlan82-cp"
    error_message = "Expected top-level prerequisites control plane subnet UUID to match fallback name"
  }

  assert {
    condition     = output.prerequisites.worker_subnet.name == "vlan82-worker"
    error_message = "Expected top-level prerequisites worker subnet name to match"
  }

  assert {
    condition     = output.prerequisites.worker_subnet.uuid == "vlan82-worker"
    error_message = "Expected top-level prerequisites worker subnet UUID to match fallback name"
  }

  assert {
    condition     = output.prerequisites.csi_storage_container.name == "csi-container-01"
    error_message = "Expected top-level prerequisites storage container name to match"
  }

  assert {
    condition     = output.prerequisites.csi_storage_container.uuid == "csi-container-01"
    error_message = "Expected top-level prerequisites storage container UUID to match fallback name"
  }

  assert {
    condition     = output.outputs.prerequisites == output.prerequisites
    error_message = "Expected aggregate output.outputs.prerequisites to match top-level prerequisites"
  }
}

run "custom_service_cidr" {
  command = plan

  variables {
    service_cidr = "10.100.0.0/16"
  }

  assert {
    condition     = output.nkp_summary.service_cidr == "10.100.0.0/16"
    error_message = "Expected top-level nkp_summary.service_cidr to match custom service_cidr"
  }

  assert {
    condition     = can(regex("--kubernetes-service-cidr=.*10\\.100\\.0\\.0/16", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain custom service CIDR 10.100.0.0/16"
  }
}

run "nkp_bootstrap_script_valid" {
  command = plan

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

  assert {
    condition     = can(regex("--endpoint=.*pc\\.lab\\.local", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain --endpoint=pc.lab.local"
  }

  assert {
    condition     = can(regex("--control-plane-endpoint-ip=.*192\\.168\\.82\\.10", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain --control-plane-endpoint-ip=192.168.82.10"
  }

  assert {
    condition     = can(regex("--control-plane-prism-element-cluster=.*pe-cluster-01", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain --control-plane-prism-element-cluster=pe-cluster-01"
  }

  assert {
    condition     = can(regex("--control-plane-subnets=.*vlan82-cp", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain --control-plane-subnets=vlan82-cp"
  }

  assert {
    condition     = can(regex("--control-plane-vm-image=.*rocky-9\\.4-kube-v1\\.30\\.5", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain --control-plane-vm-image=rocky-9.4-kube-v1.30.5"
  }

  assert {
    condition     = can(regex("--worker-prism-element-cluster=.*pe-cluster-01", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain --worker-prism-element-cluster=pe-cluster-01"
  }

  assert {
    condition     = can(regex("--worker-subnets=.*vlan82-worker", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain --worker-subnets=vlan82-worker"
  }

  assert {
    condition     = can(regex("--worker-vm-image=.*rocky-9\\.4-kube-v1\\.30\\.5", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain --worker-vm-image=rocky-9.4-kube-v1.30.5"
  }

  assert {
    condition     = can(regex("--csi-storage-container=.*csi-container-01", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain --csi-storage-container=csi-container-01"
  }

  assert {
    condition     = can(regex("--kubernetes-service-load-balancer-ip-range=.*192\\.168\\.82\\.20-192\\.168\\.82\\.39", output.bootstrap_script))
    error_message = "Expected bootstrap_script to contain --kubernetes-service-load-balancer-ip-range=192.168.82.20-192.168.82.39"
  }
}

run "bootstrap_script_profile_small" {
  command = plan

  variables {
    bundle_paths = ["/tmp/kommander.tar", "/tmp/konvoy.tar"]
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
    condition     = can(regex("--app-options=\"rook-ceph\\.enabled=false,velero\\.enabled=false,logging-operator\\.enabled=false,kube-prometheus-stack\\.enabled=false\"", output.bootstrap_script))
    error_message = "Expected profile small to render disabled app-options"
  }

  assert {
    condition     = can(regex("--disable-apps=\"rook-ceph,velero,logging,monitoring\"", output.bootstrap_script))
    error_message = "Expected profile small to render disable-apps flag"
  }

  assert {
    condition     = output.outputs.bootstrap_script == output.bootstrap_script
    error_message = "Expected aggregate output.outputs.bootstrap_script to match top-level output"
  }
}

run "bootstrap_script_profile_full" {
  command = plan

  variables {
    profile = "full"
  }

  assert {
    condition     = can(regex("--worker-replicas=4", output.bootstrap_script))
    error_message = "Expected profile full to render --worker-replicas=4"
  }

  assert {
    condition     = !can(regex("--app-options", output.bootstrap_script))
    error_message = "Expected profile full to not include --app-options flag"
  }

  assert {
    condition     = !can(regex("--disable-apps", output.bootstrap_script))
    error_message = "Expected profile full to not include --disable-apps flag"
  }
}

run "upgrade_script_valid" {
  command = plan

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

run "bastion_cloud_init_defaults" {
  command = plan

  assert {
    condition     = can(regex("# ssh_authorized_keys: none configured", output.bastion_cloud_init))
    error_message = "Expected default fallback comment for empty bastion_ssh_keys"
  }

  assert {
    condition     = can(regex("# Placeholder / No custom CA certificates supplied", output.bastion_cloud_init))
    error_message = "Expected default fallback comment for empty ca_certificates"
  }
}

run "bastion_cloud_init_valid" {
  command = plan

  variables {
    ca_certificates  = ["-----BEGIN CERTIFICATE-----\nMIIC...\n-----END CERTIFICATE-----"]
    bastion_ssh_keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ... admin@lab"]
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
