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
}

run "invalid_cluster_name" {
  command = plan

  variables {
    cluster_name = "Invalid_Name!"
  }

  expect_failures = [
    var.cluster_name,
  ]
}

run "invalid_profile" {
  command = plan

  variables {
    profile = "invalid"
  }

  expect_failures = [
    var.profile,
  ]
}

run "invalid_pod_cidr" {
  command = plan

  variables {
    pod_cidr = "192.168.0.0/16"
  }

  expect_failures = [
    var.pod_cidr,
  ]
}
