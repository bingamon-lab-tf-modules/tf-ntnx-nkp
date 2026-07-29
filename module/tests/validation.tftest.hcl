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

run "invalid_control_plane_vip" {
  command = plan

  variables {
    control_plane_vip = "invalid-ip"
  }

  expect_failures = [
    var.control_plane_vip,
  ]
}

run "invalid_load_balancer_ip_range" {
  command = plan

  variables {
    load_balancer_ip_range = "invalid-range"
  }

  expect_failures = [
    var.load_balancer_ip_range,
  ]
}

run "invalid_service_cidr" {
  command = plan

  variables {
    service_cidr = "invalid-cidr"
  }

  expect_failures = [
    var.service_cidr,
  ]
}
