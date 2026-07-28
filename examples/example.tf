##################################################
# tf-ntnx-nkp — example usage
##################################################

terraform {
  required_version = ">= 1.9.0"
}

module "nkp_management_cluster" {
  source = "../module"

  cluster_name           = "nkp-mgmt"
  profile                = "small"
  prism_central_endpoint = "pc.lab.internal"
  prism_element_cluster  = "pe-cluster-01"
  control_plane_vip      = "192.168.82.10"
  control_plane_subnet   = "vlan82-cp-subnet"
  worker_subnet          = "vlan82-worker-subnet"
  csi_storage_container  = "nkp-container"
  load_balancer_ip_range = "192.168.82.20-192.168.82.39"
  control_plane_vm_image = "centos-7.9-nkp-v2.18"
  worker_vm_image        = "centos-7.9-nkp-v2.18"

  pod_cidr     = "172.20.0.0/16"
  service_cidr = "10.96.0.0/12"

  bundle_paths     = ["/opt/bundles/kommander-image-bundle-v2.18.0.tar"]
  ca_certificates  = ["-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----"]
  bastion_ssh_keys = ["ssh-ed25519 ssh-key-placeholder"]
}
