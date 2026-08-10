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
# Licence
##################################################

run "license_is_off_by_default" {
  command = plan

  assert {
    condition     = output.contract.license.enabled == false
    error_message = "Licence application must be opt-in; an estate may apply it out of band."
  }
}

run "an_enabled_license_names_its_secret" {
  command = plan

  variables {
    license = { enabled = true }
  }

  # The hook creates this Secret and the License CR references it, so the
  # default has to be a usable name rather than empty.
  #
  # `nutanix-license` SPECIFICALLY, because that is what licensing a cluster
  # through the Kommander UI creates. Matching it means the hook updates that
  # object in place rather than creating a second Secret and repointing the CR,
  # which would leave the UI's orphaned. Verified against a real cluster on
  # 2026-08-10; this assertion is what stops the two drifting apart again.
  assert {
    condition     = output.contract.license.secret_name == "nutanix-license"
    error_message = "An enabled licence must carry the Secret name the hook creates."
  }
}

run "an_enabled_license_with_no_secret_name_is_refused" {
  command = plan

  variables {
    license = { enabled = true, secret_name = "  " }
  }

  expect_failures = [var.license]
}

run "the_license_contract_carries_no_key" {
  command = plan

  variables {
    license = { enabled = true, secret_name = "nkp-license" }
  }

  # The contract is written to disk at 0644. The licence key is a credential
  # and lives in SOPS; only the Secret's NAME may appear here.
  assert {
    condition = length(setsubtract(
      keys(output.contract.license),
      ["enabled", "secret_name"],
    )) == 0
    error_message = "contract.license must carry names only: ${join(",", keys(output.contract.license))}"
  }
}

##################################################
# platform — the seam to nkp-platform
#
# Three sub-blocks applied in a required order: workspaces, then registryops
# (the MENU), then gitops (the ORDER). Each has its own `enabled`, each
# defaults off, and the first two render argv while gitops renders none.
#
# The argv assertions pin flag ORDER as well as presence, because the argv IS
# the interface: a wrong flag surfaces as a catalog that never appears in
# Kommander rather than as an error.
#
# ON expect_failures DEPTH. `expect_failures` addresses a VARIABLE, and all
# twelve validation {} blocks below live on var.platform -- so no assertion can
# name which rule fired. The discipline that replaces it: every refusal run
# changes ONE thing away from an otherwise-valid configuration, so exactly one
# rule can plausibly be the one that fires. Anything provable through the
# rendered contract is asserted there instead, where it is exact.
##################################################

##################################################
# platform.workspaces
##################################################

run "platform_is_off_by_default" {
  command = plan

  assert {
    condition = alltrue([
      output.contract.platform.workspaces.enabled == false,
      output.contract.platform.registryops.enabled == false,
      output.contract.platform.gitops.enabled == false,
    ])
    error_message = "All three platform sub-blocks must default to off so every existing cluster file stays valid."
  }

  assert {
    condition = alltrue([
      length(output.contract.platform.workspaces.entries) == 0,
      length(output.contract.platform.registryops.registrations) == 0,
    ])
    error_message = "A disabled platform block must render nothing."
  }
}

run "a_workspace_renders_the_expected_argv" {
  command = plan

  variables {
    platform = {
      workspaces = {
        enabled = true
        entries = [
          { name = "platform-workspace" },
          { name = "tenant-a", display_name = "Tenant A" },
        ]
      }
    }
  }

  # -n IS NOT OPTIONAL. Without it Kommander generates a suffixed namespace and
  # every nkp-platform manifest targets a namespace that never exists.
  assert {
    condition = output.contract.platform.workspaces.entries["platform-workspace"].argv == [
      "nkp", "create", "workspace", "platform-workspace", "-n", "platform-workspace",
    ]
    error_message = "Unexpected workspace argv: ${join(" ", output.contract.platform.workspaces.entries["platform-workspace"].argv)}"
  }

  assert {
    condition = output.contract.platform.workspaces.entries["tenant-a"].argv == [
      "nkp", "create", "workspace", "tenant-a", "-n", "tenant-a", "--display-name", "Tenant A",
    ]
    error_message = "display_name must render --display-name after the pinned namespace."
  }

  # The contract publishes the namespace so the hook never recomputes it.
  assert {
    condition = alltrue([
      for name, w in output.contract.platform.workspaces.entries : w.namespace == name
    ])
    error_message = "Every workspace namespace must equal its name -- the argv pins it, so a contract that disagreed would mislead the hook."
  }
}

run "enabling_workspaces_with_no_entries_is_refused" {
  command = plan

  variables {
    platform = {
      workspaces = { enabled = true }
    }
  }

  expect_failures = [var.platform]
}

run "a_workspace_name_that_is_not_a_dns_label_is_refused" {
  command = plan

  variables {
    platform = {
      workspaces = {
        enabled = true
        entries = [{ name = "Tenant_A" }]
      }
    }
  }

  # It becomes a namespace name. Caught here, or 30-45 minutes into a create.
  expect_failures = [var.platform]
}

##################################################
# platform.registryops
##################################################

run "a_tag_entry_renders_the_expected_argv" {
  command = plan

  variables {
    platform = {
      registryops = {
        enabled = true
        entries = {
          nkp-platform = {
            url        = "oci://registry.example.com/nkp-platform/collection"
            version    = { tag = "v1.0.0" }
            workspaces = ["kommander-workspace"]
          }
        }
      }
    }
  }

  # Keyed "<entry>/<workspace>": the hook needs the pair, because it places a
  # pull secret in each workspace's namespace before registering into it.
  assert {
    condition = output.contract.platform.registryops.registrations["nkp-platform/kommander-workspace"].argv == [
      "nkp", "create", "catalog-application",
      "--url", "oci://registry.example.com/nkp-platform/collection",
      "--tag", "v1.0.0",
      "--workspace", "kommander-workspace",
      "--interval", "6h", "--timeout", "1m",
    ]
    error_message = "Unexpected registration argv: ${join(" ", output.contract.platform.registryops.registrations["nkp-platform/kommander-workspace"].argv)}"
  }

  # The key is the only thing that names both halves in a failure message, so
  # the identity fields behind it are pinned too.
  assert {
    condition = alltrue([
      output.contract.platform.registryops.registrations["nkp-platform/kommander-workspace"].name == "nkp-platform",
      output.contract.platform.registryops.registrations["nkp-platform/kommander-workspace"].workspace == "kommander-workspace",
      output.contract.platform.registryops.registrations["nkp-platform/kommander-workspace"].url == "oci://registry.example.com/nkp-platform/collection",
    ])
    error_message = "A registration must carry the entry name, workspace and url alongside its argv."
  }
}

run "one_entry_fans_out_to_one_registration_per_workspace" {
  command = plan

  variables {
    platform = {
      registryops = {
        enabled = true
        entries = {
          tenant-apps = {
            url        = "oci://r.example.com/nkp-tenant-apps"
            version    = { tag = "v2" }
            workspaces = ["tenant-a", "tenant-b"]
          }
        }
      }
    }
  }

  # The reason workspaces is a LIST: repeating the entry per workspace would
  # repeat the version pin, which is the one thing that must not drift.
  assert {
    condition = toset(keys(output.contract.platform.registryops.registrations)) == toset([
      "tenant-apps/tenant-a",
      "tenant-apps/tenant-b",
    ])
    error_message = "Each (entry, workspace) pair must produce its own registration: ${join(",", keys(output.contract.platform.registryops.registrations))}"
  }

  assert {
    condition = alltrue([
      contains(output.contract.platform.registryops.registrations["tenant-apps/tenant-a"].argv, "tenant-a"),
      contains(output.contract.platform.registryops.registrations["tenant-apps/tenant-b"].argv, "tenant-b"),
    ])
    error_message = "Each registration must target its own workspace."
  }
}

run "semver_renders_instead_of_tag" {
  command = plan

  variables {
    platform = {
      registryops = {
        enabled = true
        entries = {
          p = {
            url        = "oci://r.example.com/nkp-platform/collection"
            version    = { semver = ">=1.0.0 <2.0.0", semver_filter = "^v.*" }
            workspaces = ["kommander-workspace"]
          }
        }
      }
    }
  }

  # RegistryOps: a new tag inside the range rolls out with no Terraform run.
  assert {
    condition     = contains(output.contract.platform.registryops.registrations["p/kommander-workspace"].argv, "--semver")
    error_message = "A semver entry must render --semver."
  }

  assert {
    condition     = !contains(output.contract.platform.registryops.registrations["p/kommander-workspace"].argv, "--tag")
    error_message = "A semver entry must not also render --tag."
  }
}

run "a_digest_entry_renders_digest_only" {
  command = plan

  variables {
    platform = {
      registryops = {
        enabled = true
        entries = {
          p = {
            url        = "oci://r.example.com/nkp-platform/collection"
            version    = { digest = "sha256:0000000000000000000000000000000000000000000000000000000000000000" }
            workspaces = ["kommander-workspace"]
          }
        }
      }
    }
  }

  # The strictest pin available, and the one an audited estate ends up on.
  assert {
    condition = alltrue([
      contains(output.contract.platform.registryops.registrations["p/kommander-workspace"].argv, "--digest"),
      !contains(output.contract.platform.registryops.registrations["p/kommander-workspace"].argv, "--semver"),
      !contains(output.contract.platform.registryops.registrations["p/kommander-workspace"].argv, "--tag"),
    ])
    error_message = "A digest entry must render --digest and nothing else."
  }
}

run "registry_overrides_reach_the_argv" {
  command = plan

  variables {
    platform = {
      registryops = {
        enabled  = true
        registry = { username = "robot-platform", secret_ref = "harbor-pull", insecure = true }
        entries = {
          p = {
            url        = "oci://r.example.com/nkp-platform/collection"
            version    = { tag = "v1" }
            workspaces = ["platform-workspace"]
            project    = "platform"
            interval   = "30m"
            timeout    = "2m"
          }
        }
      }
    }
  }

  # Naming a secret implies --skip-oci-registry-patches inside nkp, so the
  # whole tail is pinned in order rather than asserted flag by flag.
  assert {
    condition = output.contract.platform.registryops.registrations["p/platform-workspace"].argv == [
      "nkp", "create", "catalog-application",
      "--url", "oci://r.example.com/nkp-platform/collection",
      "--tag", "v1",
      "--workspace", "platform-workspace",
      "--project", "platform",
      "--secret-ref", "harbor-pull",
      "--insecure",
      "--interval", "30m", "--timeout", "2m",
    ]
    error_message = "Unexpected registration argv: ${join(" ", output.contract.platform.registryops.registrations["p/platform-workspace"].argv)}"
  }
}

run "a_username_without_a_secret_ref_is_refused" {
  command = plan

  variables {
    platform = {
      registryops = {
        enabled  = true
        registry = { username = "someone" }
        entries = {
          p = {
            url        = "oci://r.example.com/x/y"
            version    = { tag = "v1" }
            workspaces = ["kommander-workspace"]
          }
        }
      }
    }
  }

  # It would be collected and never used: the hook only builds a pull secret
  # when it has somewhere to put it.
  expect_failures = [var.platform]
}

run "a_secret_ref_without_a_username_is_refused" {
  command = plan

  variables {
    platform = {
      registryops = {
        enabled  = true
        registry = { secret_ref = "ghcr-pull" }
        entries = {
          p = {
            url        = "oci://r.example.com/x/y"
            version    = { tag = "v1" }
            workspaces = ["kommander-workspace"]
          }
        }
      }
    }
  }

  # The hook would build a dockerconfigjson with no login in it.
  expect_failures = [var.platform]
}

run "the_registry_username_reaches_the_contract_but_no_password_does" {
  command = plan

  variables {
    platform = {
      registryops = {
        enabled  = true
        registry = { username = "bingamon-lab", secret_ref = "ghcr-nkp-platform" }
        entries = {
          p = {
            url        = "oci://ghcr.io/bingamon-lab/nkp-platform/nkp-mgmt-1"
            version    = { tag = "development" }
            workspaces = ["kommander-workspace"]
          }
        }
      }
    }
  }

  assert {
    condition     = output.contract.platform.registryops.registry.username == "bingamon-lab"
    error_message = "The hook needs the username to build the pull secret."
  }

  # The contract is written to disk at 0644. A password reaching it would be a
  # leak, so the whole block is asserted to be names only.
  assert {
    condition = length(setsubtract(
      keys(output.contract.platform.registryops.registry),
      ["username", "secret_ref", "insecure"],
    )) == 0
    error_message = "contract.platform.registryops.registry must carry names only, never a credential: ${join(",", keys(output.contract.platform.registryops.registry))}"
  }
}

run "an_entry_with_no_version_is_refused" {
  command = plan

  variables {
    platform = {
      registryops = {
        enabled = true
        entries = {
          p = {
            url        = "oci://r.example.com/x/y"
            version    = {}
            workspaces = ["kommander-workspace"]
          }
        }
      }
    }
  }

  # Flux would silently follow `latest`, and two clusters built a week apart
  # from identical config would get different platform versions.
  expect_failures = [var.platform]
}

run "an_entry_with_two_versions_is_refused" {
  command = plan

  variables {
    platform = {
      registryops = {
        enabled = true
        entries = {
          p = {
            url        = "oci://r.example.com/x/y"
            version    = { tag = "v1", semver = ">=1.0.0" }
            workspaces = ["kommander-workspace"]
          }
        }
      }
    }
  }

  expect_failures = [var.platform]
}

run "a_git_url_is_refused" {
  command = plan

  variables {
    platform = {
      registryops = {
        enabled = true
        entries = {
          p = {
            url        = "https://github.com/example/nkp-platform.git"
            version    = { tag = "v1" }
            workspaces = ["kommander-workspace"]
          }
        }
      }
    }
  }

  # The whole point of the spike: NKP 2.18 has no external-git attach point.
  expect_failures = [var.platform]
}

run "semver_filter_without_semver_is_refused" {
  command = plan

  variables {
    platform = {
      registryops = {
        enabled = true
        entries = {
          p = {
            url        = "oci://r.example.com/x/y"
            version    = { tag = "v1", semver_filter = "^v.*" }
            workspaces = ["kommander-workspace"]
          }
        }
      }
    }
  }

  expect_failures = [var.platform]
}

run "an_entry_with_no_workspaces_is_refused" {
  command = plan

  variables {
    platform = {
      registryops = {
        enabled = true
        entries = {
          p = {
            url        = "oci://r.example.com/x/y"
            version    = { tag = "v1" }
            workspaces = []
          }
        }
      }
    }
  }

  # It would render zero argv and report success having registered nowhere.
  expect_failures = [var.platform]
}

run "enabling_registryops_with_no_entries_is_refused" {
  command = plan

  variables {
    platform = {
      registryops = { enabled = true }
    }
  }

  expect_failures = [var.platform]
}

##################################################
# platform.gitops
#
# Renders NO ARGV: the hook applies a GitRepository and a Kustomization with
# kubectl, so everything here is carried through as configuration. That is also
# why the deleted 2026-08-03 `gitops` variable is not this one.
##################################################

run "gitops_defaults_are_resolved_in_the_contract" {
  command = plan

  variables {
    platform = {
      gitops = {
        enabled    = true
        url        = "ssh://git@github.example.test/bingamon-lab/nkp-platform.git"
        ref        = { branch = "deployed" }
        secret_ref = "nkp-platform-deploy-key"
      }
    }
  }

  # Resolved HERE, not in the hook: nkp-platform names each fleet after its
  # management cluster, so the default is a fact about the other repo's layout.
  assert {
    condition     = output.contract.platform.gitops.path == "./nkp-mgmt"
    error_message = "gitops.path must default to ./<cluster_name>, got ${output.contract.platform.gitops.path}."
  }

  assert {
    condition = alltrue([
      output.contract.platform.gitops.namespace == "kommander-flux",
      output.contract.platform.gitops.interval == "10m",
      output.contract.platform.gitops.prune == true,
      output.contract.platform.gitops.suspend == false,
      output.contract.platform.gitops.timeout == null,
      output.contract.platform.gitops.service_account == null,
    ])
    error_message = "gitops defaults must reach the contract fully resolved so the hook never re-derives one."
  }

  assert {
    condition = alltrue([
      output.contract.platform.gitops.url == "ssh://git@github.example.test/bingamon-lab/nkp-platform.git",
      output.contract.platform.gitops.ref.branch == "deployed",
      output.contract.platform.gitops.ref.tag == null,
      output.contract.platform.gitops.ref.commit == null,
      output.contract.platform.gitops.secret_ref == "nkp-platform-deploy-key",
    ])
    error_message = "gitops url, ref and secret_ref must be carried through verbatim."
  }

  # gitops has no `nkp` verb. If any of it leaked into create-time argv, this
  # module would be rendering a command NKP 2.18 cannot accept.
  assert {
    condition = length([
      for a in output.contract.create.argv : a if strcontains(a, "nkp-platform") || strcontains(a, "deployed")
    ]) == 0
    error_message = "gitops must render no argv: ${join(" ", output.contract.create.argv)}"
  }
}

run "an_explicit_gitops_path_overrides_the_default" {
  command = plan

  variables {
    platform = {
      gitops = {
        enabled    = true
        url        = "https://github.example.test/bingamon-lab/nkp-platform.git"
        ref        = { commit = "0123456789abcdef0123456789abcdef01234567" }
        path       = "./.render/fleet-a"
        secret_ref = "nkp-platform-deploy-key"
      }
    }
  }

  assert {
    condition     = output.contract.platform.gitops.path == "./.render/fleet-a"
    error_message = "An explicit gitops.path must win over the ./<cluster_name> default."
  }

  # A commit ref pins a cluster to exactly one render.
  assert {
    condition = alltrue([
      output.contract.platform.gitops.ref.commit == "0123456789abcdef0123456789abcdef01234567",
      output.contract.platform.gitops.ref.branch == null,
    ])
    error_message = "A commit ref must reach the contract alone."
  }
}

run "enabling_gitops_with_no_url_is_refused" {
  command = plan

  variables {
    platform = {
      gitops = {
        enabled    = true
        ref        = { branch = "deployed" }
        secret_ref = "nkp-platform-deploy-key"
      }
    }
  }

  # There is no default: guessing one points a cluster at somebody else's
  # platform.
  expect_failures = [var.platform]
}

run "an_scp_style_gitops_url_is_refused" {
  command = plan

  variables {
    platform = {
      gitops = {
        enabled    = true
        url        = "git@github.example.test:bingamon-lab/nkp-platform.git"
        ref        = { branch = "deployed" }
        secret_ref = "nkp-platform-deploy-key"
      }
    }
  }

  # Flux does not accept scp-style. It fails inside the cluster, silently.
  expect_failures = [var.platform]
}

run "gitops_with_no_ref_is_refused" {
  command = plan

  variables {
    platform = {
      gitops = {
        enabled    = true
        url        = "ssh://git@github.example.test/bingamon-lab/nkp-platform.git"
        secret_ref = "nkp-platform-deploy-key"
      }
    }
  }

  expect_failures = [var.platform]
}

run "gitops_with_two_refs_is_refused" {
  command = plan

  variables {
    platform = {
      gitops = {
        enabled    = true
        url        = "ssh://git@github.example.test/bingamon-lab/nkp-platform.git"
        ref        = { branch = "deployed", tag = "v1.0.0" }
        secret_ref = "nkp-platform-deploy-key"
      }
    }
  }

  expect_failures = [var.platform]
}

run "gitops_without_a_secret_ref_is_refused" {
  command = plan

  variables {
    platform = {
      gitops = {
        enabled = true
        url     = "ssh://git@github.example.test/bingamon-lab/nkp-platform.git"
        ref     = { branch = "deployed" }
      }
    }
  }

  # Without a name there is nothing for the GitRepository to reference, and
  # Flux would attempt an anonymous clone that fails on a private repository.
  expect_failures = [var.platform]
}

# A disabled gitops block is NOT validated -- every rule above is guarded by
# `enabled`. That is deliberate: a half-filled block someone is still writing
# must not fail a plan. This pins it, so the guard cannot be dropped by
# accident.
run "an_incomplete_gitops_block_is_ignored_while_disabled" {
  command = plan

  variables {
    platform = {
      gitops = {
        enabled = false
        url     = "not-a-url"
      }
    }
  }

  assert {
    condition     = output.contract.platform.gitops.enabled == false
    error_message = "A disabled gitops block must stay disabled in the contract."
  }

  assert {
    condition     = length(output.validation_errors) == 0
    error_message = "A disabled gitops block must not contribute a validation error."
  }
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
