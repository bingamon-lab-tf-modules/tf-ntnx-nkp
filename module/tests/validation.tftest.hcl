##################################################
# Validation coverage
#
# Every rule that can stop a plan gets a failing case here. Cross-variable rules
# land in local.validation_errors and are asserted through the output;
# single-variable rules raise from their validation {} block and are asserted
# with expect_failures.
#
# enable_data_lookups = false throughout: existence checks need real Prism
# Central credentials, and these tests must run offline.
##################################################

provider "nutanix" {
  username     = "dummy"
  password     = "dummy"
  endpoint     = "dummy.local"
  port         = 9440
  insecure     = true
  wait_timeout = 1
}

variables {
  enable_data_lookups = false

  # See variables.tf: lets these runs read output.validation_errors instead of
  # dying on the precondition, so each rule is asserted precisely.
  # enforce_validation_fires_the_precondition below proves the real gate works.
  enforce_validation = false

  cluster_name = "nkp-mgmt"

  bastion = {
    host = "nkp-bastion.lab.local"
  }

  version_contract = {
    nkp        = "2.18.0"
    kubernetes = "1.35.2"
  }

  prism_central = {
    endpoint = "pc.lab.local"
    user     = "nkp-capx"
  }

  airgap = {
    bundles = [
      "/var/tmp/nkp-v2.18.0/container-images/konvoy-image-bundle-v2.18.0.tar",
      "/var/tmp/nkp-v2.18.0/container-images/kommander-image-bundle-v2.18.0.tar",
    ]
    bootstrap_cluster_image = "/var/tmp/nkp-v2.18.0/konvoy-bootstrap-image-v2.18.0.tar"
  }

  placement = {
    prism_element_cluster = "pe-cluster-01"
    subnets               = ["vlan84-k8s"]
    vm_image              = "nkp-ubuntu-24.04-release-cis-1.35.2-20260626141256"
  }

  control_plane = {
    endpoint_ip = "192.168.84.150"
  }

  networking = {
    load_balancer_ip_range = "192.168.84.151-192.168.84.170"
  }

  csi = {
    storage_container = "k8s-persistent"
  }

  ssh = {
    public_key_path = "/run/nkp/id_ed25519.pub"
  }
}

##################################################
# Baseline
##################################################

run "valid_configuration_has_no_errors" {
  command = plan

  assert {
    condition     = length(output.validation_errors) == 0
    error_message = "A known-good configuration produced validation errors: ${join("; ", output.validation_errors)}"
  }
}

##################################################
# 1. Static IP / CIDR math
##################################################

run "vip_inside_load_balancer_range_is_rejected" {
  command = plan

  variables {
    # MetalLB would hand the control-plane VIP out to a Service.
    control_plane = {
      endpoint_ip = "192.168.84.155"
    }
  }

  assert {
    condition     = length([for e in output.validation_errors : e if strcontains(e, "falls inside networking.load_balancer_ip_range")]) == 1
    error_message = "A VIP inside the load-balancer range should be rejected."
  }
}

run "reversed_load_balancer_range_is_rejected" {
  command = plan

  variables {
    networking = {
      load_balancer_ip_range = "192.168.84.170-192.168.84.151"
    }
  }

  assert {
    condition     = length([for e in output.validation_errors : e if strcontains(e, "is reversed")]) == 1
    error_message = "A reversed load-balancer range should be rejected."
  }
}

run "tiny_load_balancer_range_is_rejected" {
  command = plan

  variables {
    networking = {
      load_balancer_ip_range = "192.168.84.151-192.168.84.152"
    }
  }

  assert {
    condition     = length([for e in output.validation_errors : e if strcontains(e, "address(es)")]) == 1
    error_message = "A load-balancer range with fewer than 4 addresses should be rejected."
  }
}

run "overlapping_pod_and_service_cidrs_are_rejected" {
  command = plan

  variables {
    networking = {
      load_balancer_ip_range = "192.168.84.151-192.168.84.170"
      pod_cidr               = "172.20.0.0/16"
      service_cidr           = "172.20.128.0/17"
    }
  }

  assert {
    condition     = length([for e in output.validation_errors : e if strcontains(e, "overlap")]) == 1
    error_message = "Overlapping pod and service CIDRs should be rejected."
  }
}

run "vip_inside_pod_cidr_is_rejected" {
  command = plan

  variables {
    control_plane = {
      endpoint_ip = "172.20.0.5"
    }
  }

  assert {
    condition     = length([for e in output.validation_errors : e if strcontains(e, "falls inside networking.pod_cidr")]) == 1
    error_message = "A VIP inside the pod CIDR should be rejected."
  }
}

##################################################
# 2. Version contract
##################################################

run "node_image_for_another_kubernetes_version_is_rejected" {
  command = plan

  variables {
    placement = {
      prism_element_cluster = "pe-cluster-01"
      subnets               = ["vlan84-k8s"]
      # A 1.34.1 image against a 1.35.2 contract.
      vm_image = "nkp-ubuntu-24.04-release-cis-1.34.1-20260101000000"
    }
  }

  assert {
    condition     = length([for e in output.validation_errors : e if strcontains(e, "does not carry version_contract.kubernetes")]) == 1
    error_message = "A node image built for a different Kubernetes version should be rejected."
  }
}

run "bundle_for_another_nkp_version_is_rejected" {
  command = plan

  variables {
    airgap = {
      bundles = [
        "/var/tmp/nkp-v2.17.0/container-images/konvoy-image-bundle-v2.17.0.tar",
      ]
      bootstrap_cluster_image = "/var/tmp/nkp-v2.18.0/konvoy-bootstrap-image-v2.18.0.tar"
    }
  }

  assert {
    condition     = length([for e in output.validation_errors : e if strcontains(e, "does not carry version_contract.nkp")]) == 1
    error_message = "A bundle from a different NKP version should be rejected."
  }
}

##################################################
# 3. Air-gap invariants
##################################################

run "public_registry_mirror_is_rejected" {
  command = plan

  variables {
    registry = {
      mirror_url = "https://registry-1.docker.io"
    }
  }

  assert {
    condition     = length([for e in output.validation_errors : e if strcontains(e, "points at a public registry")]) == 1
    error_message = "A public registry mirror should be rejected in an air-gapped module."
  }
}

run "registry_username_without_a_registry_is_rejected" {
  command = plan

  variables {
    registry = {
      username = "someone"
    }
  }

  assert {
    condition     = length([for e in output.validation_errors : e if strcontains(e, "would not be used")]) == 1
    error_message = "A registry username with no registry URL should be rejected."
  }
}

run "relative_bundle_path_is_rejected" {
  command = plan

  variables {
    airgap = {
      # Paths are on the bastion, and nkp runs from a cwd the hook chooses, so a
      # relative path silently resolves somewhere else.
      bundles                 = ["./nkp-v2.18.0/container-images/konvoy-image-bundle-v2.18.0.tar"]
      bootstrap_cluster_image = "/var/tmp/nkp-v2.18.0/konvoy-bootstrap-image-v2.18.0.tar"
    }
  }

  expect_failures = [var.airgap]
}

##################################################
# Single-variable rules
##################################################

run "invalid_cluster_name_is_rejected" {
  command = plan

  variables {
    cluster_name = "Invalid_Name!"
  }

  expect_failures = [var.cluster_name]
}

run "even_control_plane_replicas_are_rejected" {
  command = plan

  variables {
    control_plane = {
      endpoint_ip = "192.168.84.150"
      replicas    = 2
    }
  }

  expect_failures = [var.control_plane]
}

run "undersized_workers_are_rejected" {
  command = plan

  variables {
    workers = {
      vcpus      = 4
      memory_gib = 8
    }
  }

  expect_failures = [var.workers]
}

run "bad_csi_file_system_is_rejected" {
  command = plan

  variables {
    csi = {
      storage_container = "k8s-persistent"
      file_system       = "btrfs"
    }
  }

  expect_failures = [var.csi]
}

run "prism_central_endpoint_with_scheme_is_rejected" {
  command = plan

  variables {
    prism_central = {
      endpoint = "https://pc.lab.local"
      user     = "nkp-capx"
    }
  }

  expect_failures = [var.prism_central]
}

##################################################
# extra_args deny-list — the air-gap contract's last line of defence
##################################################

run "extra_args_cannot_disable_airgapped" {
  command = plan

  variables {
    extra_args = ["--airgapped=false"]
  }

  expect_failures = [var.extra_args]
}

run "extra_args_cannot_skip_preflight_checks" {
  command = plan

  variables {
    extra_args = ["--skip-preflight-checks"]
  }

  expect_failures = [var.extra_args]
}

run "extra_args_cannot_hijack_the_kubeconfig" {
  command = plan

  variables {
    extra_args = ["--kubeconfig", "/tmp/elsewhere.conf"]
  }

  expect_failures = [var.extra_args]
}

run "extra_args_accepts_an_unmodelled_flag" {
  command = plan

  variables {
    extra_args = ["--worker-vm-profile", "custom"]
  }

  assert {
    condition     = length(output.validation_errors) == 0
    error_message = "A flag that is not module-owned should be accepted."
  }
}

##################################################
# GitOps is deferred and must stay off
##################################################

run "gitops_cannot_be_enabled_yet" {
  command = plan

  variables {
    gitops = {
      enabled = true
      url     = "ssh://git@example/repo.git"
    }
  }

  expect_failures = [var.gitops]
}

##################################################
# The precondition itself
##################################################

# Every run above sets enforce_validation = false so it can inspect the error
# list. This one leaves it at its real default to prove the gate actually stops
# a plan -- otherwise the whole suite could pass against a module that never
# fails anything.
run "enforce_validation_fires_the_precondition" {
  command = plan

  variables {
    enforce_validation = true

    control_plane = {
      endpoint_ip = "192.168.84.155" # inside the load-balancer range
    }
  }

  expect_failures = [terraform_data.validation]
}
