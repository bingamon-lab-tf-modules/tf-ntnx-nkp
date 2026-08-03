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

  # Placeholder form, which is what callers should use: it keeps the
  # directory-naming convention inside this module. Resolution is asserted in
  # airgap_placeholders_resolve_against_the_cache_dir below.
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

  networking = {
    load_balancer_ip_range = "192.0.2.151-192.0.2.170"
  }

  csi = {
    storage_container = "k8s-persistent"
  }

  # No public_key_path: the location ON THE BASTION is derived from
  # bastion.run_root, not configured. See variables.tf.
  ssh = {
    username = "konvoy"
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
# 0. Bastion filesystem layout
#
# The contract's paths ARE the interface: the hook stages files at them and the
# rendered argv points `nkp` at them. If they drift apart, the failure surfaces
# 40 minutes into a create as a missing bundle or an unusable SSH key, so they
# are asserted literally rather than by reconstruction.
##################################################

run "bastion_paths_are_namespaced_and_derived" {
  command = plan

  assert {
    condition     = output.contract.bastion.cache_dir == "/var/tmp/lz-cli/cache/nkp/v2.18.0"
    error_message = "cache_dir must be <cache_root>/nkp/v<version>, got ${output.contract.bastion.cache_dir}."
  }

  assert {
    condition     = output.contract.bastion.run_dir == "/run/lz-cli/nkp/nkp-mgmt"
    error_message = "run_dir must be <run_root>/nkp/<cluster>, got ${output.contract.bastion.run_dir}."
  }

  # The hook creates run_root with the flow's single privileged command, so it
  # must be the SHARED root and not nkp's subdirectory of it.
  assert {
    condition     = output.contract.bastion.run_root == "/run/lz-cli"
    error_message = "run_root must be the generic per-host root, got ${output.contract.bastion.run_root}."
  }

  # The kubeconfig lands in the directory that gets destroyed, not beside the
  # bundle that does not. This is the whole point of splitting the roots.
  assert {
    condition     = startswith(output.contract.bastion.kubeconfig, output.contract.bastion.run_dir)
    error_message = "kubeconfig must live inside run_dir, got ${output.contract.bastion.kubeconfig}."
  }

  # preflight tells the hook where to STAGE the key; argv tells nkp where to
  # READ it. A mismatch is silent until CAPX rejects the node.
  assert {
    condition = anytrue([
      for i, a in output.contract.create.argv :
      a == "--ssh-public-key-file" && output.contract.create.argv[i + 1] == output.contract.preflight.ssh_public_key_path
    ])
    error_message = "--ssh-public-key-file must be the same path the hook is told to stage the key at (${output.contract.preflight.ssh_public_key_path})."
  }

  assert {
    condition     = output.contract.preflight.ssh_public_key_path == "/run/lz-cli/nkp/nkp-mgmt/id.pub"
    error_message = "The node public key belongs in run_dir, got ${output.contract.preflight.ssh_public_key_path}."
  }
}

run "airgap_placeholders_resolve_against_the_cache_dir" {
  command = plan

  assert {
    condition = output.contract.preflight.bundles == [
      "/var/tmp/lz-cli/cache/nkp/v2.18.0/container-images/konvoy-image-bundle-v2.18.0.tar",
      "/var/tmp/lz-cli/cache/nkp/v2.18.0/container-images/kommander-image-bundle-v2.18.0.tar",
    ]
    error_message = "$${cache_dir}/$${nkp_version} did not resolve: ${join(", ", output.contract.preflight.bundles)}."
  }

  assert {
    condition     = output.contract.preflight.bootstrap_cluster_image == "/var/tmp/lz-cli/cache/nkp/v2.18.0/konvoy-bootstrap-image-v2.18.0.tar"
    error_message = "bootstrap_cluster_image did not resolve: ${output.contract.preflight.bootstrap_cluster_image}."
  }

  # An unresolved placeholder reaching the bastion is a `cd` into a directory
  # named literally "$${cache_dir}", which reads as a download failure.
  assert {
    condition = alltrue([
      for b in concat(output.contract.preflight.bundles, [output.contract.preflight.bootstrap_cluster_image]) :
      startswith(b, "/")
    ])
    error_message = "An air-gap path is not absolute after substitution."
  }
}

run "absolute_airgap_paths_still_pass_through" {
  command = plan

  variables {
    airgap = {
      bundles                 = ["/srv/nkp/v2.18.0/konvoy-image-bundle-v2.18.0.tar"]
      bootstrap_cluster_image = "/srv/nkp/v2.18.0/konvoy-bootstrap-image-v2.18.0.tar"
    }
  }

  assert {
    condition     = output.contract.preflight.bundles[0] == "/srv/nkp/v2.18.0/konvoy-image-bundle-v2.18.0.tar"
    error_message = "An absolute air-gap path must pass through untouched, for a bastion stocked by other means."
  }
}

run "cache_root_and_run_root_may_not_be_the_same" {
  command = plan

  variables {
    bastion = {
      host       = "nkp-bastion.example.test"
      cache_root = "/var/tmp/lz-cli"
      run_root   = "/var/tmp/lz-cli/"
    }
  }

  expect_failures = [var.bastion]
}

run "roots_must_be_absolute" {
  command = plan

  variables {
    bastion = {
      host     = "nkp-bastion.example.test"
      run_root = "run/lz-cli"
    }
  }

  expect_failures = [var.bastion]
}

##################################################
# 1. Static IP / CIDR math
##################################################

run "vip_inside_load_balancer_range_is_rejected" {
  command = plan

  variables {
    # MetalLB would hand the control-plane VIP out to a Service.
    control_plane = {
      endpoint_ip = "192.0.2.155"
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
      load_balancer_ip_range = "192.0.2.170-192.0.2.151"
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
      load_balancer_ip_range = "192.0.2.151-192.0.2.152"
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
      load_balancer_ip_range = "192.0.2.151-192.0.2.170"
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
      endpoint_ip = "192.0.2.150"
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
      endpoint = "https://pc.example.test"
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
# Catalog — the seam to nkp-platform
#
# Registration is one Flux OCIRepository per entry, created by
# `nkp create catalog-application`. These pin the argv, because the argv IS the
# interface: a wrong flag surfaces as a catalog that never appears in Kommander
# rather than as an error.
##################################################

run "catalog_is_off_by_default" {
  command = plan

  assert {
    condition     = output.contract.catalog.enabled == false
    error_message = "Catalog must default to off so every existing cluster file stays valid."
  }

  assert {
    condition     = length(output.contract.catalog.entries) == 0
    error_message = "A disabled catalog must register nothing."
  }
}

run "a_tag_entry_renders_the_expected_argv" {
  command = plan

  variables {
    catalog = {
      enabled = true
      entries = {
        nkp-platform = {
          url     = "oci://registry.example.com/nkp-platform/collection"
          version = { tag = "v1.0.0" }
        }
      }
    }
  }

  assert {
    condition = output.contract.catalog.entries["nkp-platform"].argv == [
      "nkp", "create", "catalog-application",
      "--url", "oci://registry.example.com/nkp-platform/collection",
      "--tag", "v1.0.0",
      "--workspace", "kommander-workspace",
      "--interval", "6h", "--timeout", "1m",
    ]
    error_message = "Unexpected catalog argv: ${join(" ", output.contract.catalog.entries["nkp-platform"].argv)}"
  }
}

run "semver_renders_instead_of_tag" {
  command = plan

  variables {
    catalog = {
      enabled = true
      entries = {
        p = {
          url     = "oci://r.example.com/nkp-platform/collection"
          version = { semver = ">=1.0.0 <2.0.0" }
        }
      }
    }
  }

  # RegistryOps: a new tag inside the range rolls out with no Terraform run.
  assert {
    condition     = contains(output.contract.catalog.entries["p"].argv, "--semver")
    error_message = "A semver entry must render --semver."
  }

  assert {
    condition     = !contains(output.contract.catalog.entries["p"].argv, "--tag")
    error_message = "A semver entry must not also render --tag."
  }
}

run "registry_overrides_reach_the_argv" {
  command = plan

  variables {
    catalog = {
      enabled   = true
      workspace = "platform-workspace"
      registry  = { username = "robot$platform", secret_ref = "harbor-pull", insecure = true }
      entries = {
        p = {
          url     = "oci://r.example.com/nkp-platform/collection"
          version = { tag = "v1" }
          project = "platform"
        }
      }
    }
  }

  assert {
    condition     = contains(output.contract.catalog.entries["p"].argv, "--secret-ref")
    error_message = "registry.secret_ref must reach the argv."
  }

  assert {
    condition     = contains(output.contract.catalog.entries["p"].argv, "--insecure")
    error_message = "registry.insecure must reach the argv."
  }

  # --project is meaningless to nkp without --workspace, so both must appear.
  assert {
    condition = alltrue([
      contains(output.contract.catalog.entries["p"].argv, "--project"),
      contains(output.contract.catalog.entries["p"].argv, "platform-workspace"),
    ])
    error_message = "A project entry must carry both --project and the resolved --workspace."
  }
}

run "a_username_without_a_secret_ref_is_refused" {
  command = plan

  variables {
    catalog = {
      enabled  = true
      registry = { username = "someone" }
      entries = {
        p = {
          url     = "oci://r.example.com/x/y"
          version = { tag = "v1" }
        }
      }
    }
  }

  # It would be collected and never used: the hook only builds a pull secret
  # when it has somewhere to put it.
  expect_failures = [var.catalog]
}

run "a_secret_ref_without_a_username_is_refused" {
  command = plan

  variables {
    catalog = {
      enabled  = true
      registry = { secret_ref = "ghcr-pull" }
      entries = {
        p = {
          url     = "oci://r.example.com/x/y"
          version = { tag = "v1" }
        }
      }
    }
  }

  # The hook would build a dockerconfigjson with no login in it.
  expect_failures = [var.catalog]
}

run "the_registry_username_reaches_the_contract_but_no_password_does" {
  command = plan

  variables {
    catalog = {
      enabled  = true
      registry = { username = "bingamon-lab", secret_ref = "ghcr-nkp-platform" }
      entries = {
        p = {
          url     = "oci://ghcr.io/bingamon-lab/nkp-platform/nkp-mgmt-1"
          version = { tag = "development" }
        }
      }
    }
  }

  assert {
    condition     = output.contract.catalog.registry.username == "bingamon-lab"
    error_message = "The hook needs the username to build the pull secret."
  }

  # The contract is written to disk at 0644. A password reaching it would be a
  # leak, so the whole block is asserted to be names only.
  assert {
    condition = length(setsubtract(
      keys(output.contract.catalog.registry),
      ["username", "secret_ref", "insecure"],
    )) == 0
    error_message = "contract.catalog.registry must carry names only, never a credential: ${join(",", keys(output.contract.catalog.registry))}"
  }
}

run "an_entry_with_no_version_is_refused" {
  command = plan

  variables {
    catalog = {
      enabled = true
      entries = {
        p = {
          url     = "oci://r.example.com/x/y"
          version = {}
        }
      }
    }
  }

  # Flux would silently follow `latest`, and two clusters built a week apart
  # from identical config would get different platform versions.
  expect_failures = [var.catalog]
}

run "an_entry_with_two_versions_is_refused" {
  command = plan

  variables {
    catalog = {
      enabled = true
      entries = {
        p = {
          url     = "oci://r.example.com/x/y"
          version = { tag = "v1", semver = ">=1.0.0" }
        }
      }
    }
  }

  expect_failures = [var.catalog]
}

run "a_git_url_is_refused" {
  command = plan

  variables {
    catalog = {
      enabled = true
      entries = {
        p = {
          url     = "https://github.com/example/nkp-platform.git"
          version = { tag = "v1" }
        }
      }
    }
  }

  # The whole point of the spike: NKP 2.18 has no external-git attach point.
  expect_failures = [var.catalog]
}

run "semver_filter_without_semver_is_refused" {
  command = plan

  variables {
    catalog = {
      enabled = true
      entries = {
        p = {
          url     = "oci://r.example.com/x/y"
          version = { tag = "v1", semver_filter = "^v.*" }
        }
      }
    }
  }

  expect_failures = [var.catalog]
}

run "enabling_with_no_entries_is_refused" {
  command = plan

  variables {
    catalog = { enabled = true }
  }

  expect_failures = [var.catalog]
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
      endpoint_ip = "192.0.2.155" # inside the load-balancer range
    }
  }

  expect_failures = [terraform_data.validation]
}
