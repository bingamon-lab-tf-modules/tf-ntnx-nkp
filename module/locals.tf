##################################################
# tf-ntnx-nkp — contract rendering and validation
#
# Everything here is pure computation. No resource is created, no command is
# run, nothing is written outside this module's own outputs (lz-paas ADR 0018).
##################################################

locals {

  enable_data_lookups = var.enable_data_lookups

  ##################################################
  # Bastion filesystem layout
  #
  # Two roots with deliberately opposite lifetimes (see variables.tf "bastion"),
  # each namespaced by TOOL so one bastion can serve several of them without the
  # layout being renegotiated:
  #
  #   <cache_root>/nkp/v<version>/     survives every run; ~27 GiB of bundle
  #   <run_root>/nkp/<cluster>/        destroyed after every run; tmpfs
  #
  # The `nkp` component is this module's own name and is therefore hardcoded
  # here rather than passed in — a caller that could choose it could also make
  # two tools collide on one directory, which is precisely what the namespace
  # exists to prevent.
  #
  # The cache is keyed by VERSION and the run directory by CLUSTER, matching
  # what each actually varies with: two clusters on the same NKP version share
  # one bundle, and the same cluster re-run twice reuses one run directory.
  ##################################################

  tool = "nkp"

  tool_cache_root = "${trimsuffix(var.bastion.cache_root, "/")}/${local.tool}"
  tool_run_root   = "${trimsuffix(var.bastion.run_root, "/")}/${local.tool}"

  # Where the bundle is extracted to. `v<version>` rather than `nkp-v<version>`:
  # the `nkp` is already the parent directory, and repeating it produced
  # /var/tmp/nkp/nkp-v2.18.0.
  cache_dir = "${local.tool_cache_root}/v${var.version_contract.nkp}"

  # Everything this run stages, and the cwd `nkp` itself is invoked in — so the
  # kubeconfig it writes by default lands inside the directory that gets
  # destroyed, instead of beside a bundle that does not.
  run_dir = "${local.tool_run_root}/${var.cluster_name}"

  # Derived, never configured. The hook stages the operator's public key here
  # and the rendered argv points at it; one local keeps those two in step.
  node_public_key_path = "${local.run_dir}/id.pub"

  # `nkp` writes this into its cwd on create and reads it on delete. Named in
  # the contract so the hook stops rebuilding the same string from work_dir.
  kubeconfig_path = "${local.run_dir}/${var.cluster_name}.conf"

  # Resolved air-gap paths. The caller may write these with ${cache_dir} and
  # ${nkp_version} placeholders so the directory convention lives ONLY here;
  # absolute paths pass through untouched for a bastion stocked by other means.
  airgap_bundles = [
    for b in var.airgap.bundles :
    replace(replace(b, "$${cache_dir}", local.cache_dir), "$${nkp_version}", var.version_contract.nkp)
  ]

  airgap_bootstrap_cluster_image = replace(
    replace(var.airgap.bootstrap_cluster_image, "$${cache_dir}", local.cache_dir),
    "$${nkp_version}", var.version_contract.nkp,
  )

  ##################################################
  # Resolved placement
  ##################################################

  # Each pool falls back to var.placement unless it overrides. Resolved once so
  # the argv builders and the data-source lookups agree by construction.
  cp_prism_element     = coalesce(var.control_plane.prism_element_cluster, var.placement.prism_element_cluster)
  cp_subnets           = coalesce(var.control_plane.subnets, var.placement.subnets)
  cp_vm_image          = coalesce(var.control_plane.vm_image, var.placement.vm_image)
  worker_prism_element = coalesce(var.workers.prism_element_cluster, var.placement.prism_element_cluster)
  worker_subnets       = coalesce(var.workers.subnets, var.placement.subnets)
  worker_vm_image      = coalesce(var.workers.vm_image, var.placement.vm_image)

  # Every distinct name the plan should resolve against Prism Central.
  referenced_subnets   = distinct(concat(local.cp_subnets, local.worker_subnets))
  referenced_clusters  = distinct([local.cp_prism_element, local.worker_prism_element])
  referenced_vm_images = distinct([local.cp_vm_image, local.worker_vm_image])

  # nkp takes repeated names as one comma-separated value.
  cp_subnets_arg     = join(",", local.cp_subnets)
  worker_subnets_arg = join(",", local.worker_subnets)

  pc_url = "https://${var.prism_central.endpoint}:${var.prism_central.port}"

  ##################################################
  # Validation 1 — static IP / CIDR math
  ##################################################

  # Catches the errors that would otherwise waste a 45-minute create. Pure
  # arithmetic: no API call, no credentials, always evaluated.

  lb_parts = split("-", var.networking.load_balancer_ip_range)
  lb_start = trimspace(local.lb_parts[0])
  lb_end   = trimspace(local.lb_parts[1])

  # IPv4 dotted-quad -> integer, so ranges can be compared and counted.
  lb_start_int = sum([
    for i, o in split(".", local.lb_start) : tonumber(o) * pow(256, 3 - i)
  ])
  lb_end_int = sum([
    for i, o in split(".", local.lb_end) : tonumber(o) * pow(256, 3 - i)
  ])
  cp_vip_int = sum([
    for i, o in split(".", var.control_plane.endpoint_ip) : tonumber(o) * pow(256, 3 - i)
  ])

  lb_range_size = local.lb_end_int - local.lb_start_int + 1

  # MetalLB hands one address to kommander-traefik on the management cluster;
  # fewer than a handful leaves no room for platform services.
  lb_range_errors = concat(
    local.lb_end_int < local.lb_start_int ? [
      "networking.load_balancer_ip_range is reversed: ${local.lb_start} is above ${local.lb_end}."
    ] : [],
    (local.lb_end_int >= local.lb_start_int && local.lb_range_size < 4) ? [
      "networking.load_balancer_ip_range holds only ${local.lb_range_size} address(es). Allow at least 4 for the management cluster's platform services."
    ] : [],
    (local.cp_vip_int >= local.lb_start_int && local.cp_vip_int <= local.lb_end_int) ? [
      "control_plane.endpoint_ip ${var.control_plane.endpoint_ip} falls inside networking.load_balancer_ip_range ${var.networking.load_balancer_ip_range}. MetalLB would hand the control-plane VIP to a Service."
    ] : [],
  )

  # Pod and service CIDRs must not overlap. Checked both directions, since
  # containment is not symmetric.
  cidr_overlap_errors = (
    cidrcontains(var.networking.pod_cidr, cidrhost(var.networking.service_cidr, 0))
    || cidrcontains(var.networking.service_cidr, cidrhost(var.networking.pod_cidr, 0))
    ) ? [
    "networking.pod_cidr (${var.networking.pod_cidr}) and networking.service_cidr (${var.networking.service_cidr}) overlap."
  ] : []

  # The control-plane VIP must not sit inside either Kubernetes CIDR.
  vip_cidr_errors = concat(
    cidrcontains(var.networking.pod_cidr, var.control_plane.endpoint_ip) ? [
      "control_plane.endpoint_ip ${var.control_plane.endpoint_ip} falls inside networking.pod_cidr ${var.networking.pod_cidr}."
    ] : [],
    cidrcontains(var.networking.service_cidr, var.control_plane.endpoint_ip) ? [
      "control_plane.endpoint_ip ${var.control_plane.endpoint_ip} falls inside networking.service_cidr ${var.networking.service_cidr}."
    ] : [],
  )

  ##################################################
  # Validation 2 — version contract consistency
  ##################################################

  # Regex-escape the dots so 2.18.0 cannot match 2a18b0.
  nkp_version_re = replace(var.version_contract.nkp, ".", "\\.")
  k8s_version_re = replace(var.version_contract.kubernetes, ".", "\\.")

  # A 1.35.2 node image with a 2.18.0 bundle is the mismatch class nkp-images'
  # release train exists to prevent; catch it here, not 40 minutes in.
  version_errors = concat(
    [
      for b in local.airgap_bundles :
      "airgap.bundles entry '${b}' does not carry version_contract.nkp (${var.version_contract.nkp}). Bundle filenames are versioned; a mismatched bundle fails after the bootstrap cluster is already up."
      if !can(regex(local.nkp_version_re, b))
    ],
    !can(regex(local.nkp_version_re, local.airgap_bootstrap_cluster_image)) ? [
      "airgap.bootstrap_cluster_image '${local.airgap_bootstrap_cluster_image}' does not carry version_contract.nkp (${var.version_contract.nkp})."
    ] : [],
    # Node images are named ...-<k8s-version>-<timestamp>; the release train
    # guarantees the substring, so its absence means the wrong image.
    [
      for img in local.referenced_vm_images :
      "vm_image '${img}' does not carry version_contract.kubernetes (${var.version_contract.kubernetes}). A node image built for a different Kubernetes version will not join the cluster."
      if !can(regex(local.k8s_version_re, img))
    ],
  )

  ##################################################
  # Validation 3 — air-gap invariants
  ##################################################

  # A registry mirror pointing at the internet is not an air gap. Checked by
  # host, since reachability is not something this module can test.
  public_registry_re = "docker\\.io|ghcr\\.io|quay\\.io|gcr\\.io|registry\\.k8s\\.io"

  airgap_errors = concat(
    (var.registry.mirror_url != null && can(regex(local.public_registry_re, coalesce(var.registry.mirror_url, "")))) ? [
      "registry.mirror_url '${var.registry.mirror_url}' points at a public registry. This module renders air-gapped installs only."
    ] : [],
    (var.registry.url != null && can(regex(local.public_registry_re, coalesce(var.registry.url, "")))) ? [
      "registry.url '${var.registry.url}' points at a public registry. This module renders air-gapped installs only."
    ] : [],
    # A mirror without a username is legitimate (anonymous pull); a username
    # without a mirror or registry URL means the credential goes nowhere.
    (var.registry.username != null && var.registry.url == null && var.registry.mirror_url == null) ? [
      "registry.username is set but neither registry.url nor registry.mirror_url is. The credential would not be used."
    ] : [],
  )

  ##################################################
  # Validation 4 — Nutanix object existence
  ##################################################

  # Names resolved live. Gated by enable_data_lookups because plan then needs
  # working Prism Central credentials; the static validations never do.
  found_cluster_names = local.enable_data_lookups ? try([
    for c in data.nutanix_clusters_v2.this[0].cluster_entities : c.name
  ], []) : []

  found_subnet_names = local.enable_data_lookups ? try([
    for s in data.nutanix_subnets_v2.this[0].subnets : s.name
  ], []) : []

  found_container_names = local.enable_data_lookups ? try([
    for c in data.nutanix_storage_containers_v2.this[0].storage_containers : c.name
  ], []) : []

  found_image_names = local.enable_data_lookups ? try([
    for i in data.nutanix_images_v2.this[0].images : i.name
  ], []) : []

  existence_errors = local.enable_data_lookups ? concat(
    [
      for name in local.referenced_clusters :
      "Prism Element cluster '${name}' was not found on ${var.prism_central.endpoint}."
      if !contains(local.found_cluster_names, name)
    ],
    [
      for name in local.referenced_subnets :
      "Subnet '${name}' was not found on ${var.prism_central.endpoint}."
      if !contains(local.found_subnet_names, name)
    ],
    [
      for name in local.referenced_vm_images :
      "VM image '${name}' was not found on ${var.prism_central.endpoint}. Upload the NKP node image before creating the cluster."
      if !contains(local.found_image_names, name)
    ],
    !contains(local.found_container_names, var.csi.storage_container) ? [
      "Storage container '${var.csi.storage_container}' was not found on ${var.prism_central.endpoint}."
    ] : [],
  ) : []

  # Aggregated so one precondition reports every problem in a single run, rather
  # than making the operator re-plan once per typo.
  validation_errors = concat(
    local.lb_range_errors,
    local.cidr_overlap_errors,
    local.vip_cidr_errors,
    local.version_errors,
    local.airgap_errors,
    local.existence_errors,
  )

  # Resolved ext_ids, surfaced for the caller and for debugging. Not used to
  # build argv: nkp takes names, and passing a UUID where it wants a name fails
  # in a way that is hard to read.
  prerequisites = {
    prism_element_clusters = local.enable_data_lookups ? {
      for c in try(data.nutanix_clusters_v2.this[0].cluster_entities, []) :
      c.name => c.ext_id if contains(local.referenced_clusters, c.name)
    } : {}
    subnets = local.enable_data_lookups ? {
      for s in try(data.nutanix_subnets_v2.this[0].subnets, []) :
      s.name => s.ext_id if contains(local.referenced_subnets, s.name)
    } : {}
    storage_containers = local.enable_data_lookups ? {
      for c in try(data.nutanix_storage_containers_v2.this[0].storage_containers, []) :
      c.name => try(c.container_ext_id, c.ext_id) if c.name == var.csi.storage_container
    } : {}
    vm_images = local.enable_data_lookups ? {
      for i in try(data.nutanix_images_v2.this[0].images, []) :
      i.name => i.ext_id if contains(local.referenced_vm_images, i.name)
    } : {}
  }

  ##################################################
  # Secret names
  ##################################################

  # NAMES ONLY. The hook resolves each from SOPS and injects it into the child
  # process environment. No value may be rendered here: outputs land in state.
  secret_env = concat(
    ["NUTANIX_USER", "NUTANIX_PASSWORD"],
    var.registry.username != null ? ["NKP_REGISTRY_PASSWORD"] : [],
    var.registry.mirror_url != null ? ["NKP_REGISTRY_MIRROR_PASSWORD"] : [],
  )

  ##################################################
  # argv — create
  ##################################################

  # Ordered to mirror the hand-run command that bootstrapped nkp-mgmt on
  # 2026-07-31, so a diff against that oracle reads cleanly.
  #
  # Booleans render as --flag=true/false rather than bare --flag: pflag treats a
  # bare boolean as true, so the explicit form is the only way to express false
  # and is unambiguous for both.
  argv_create_base = [
    "nkp", "create", "cluster", "nutanix",
    "--cluster-name", var.cluster_name,

    # Module-owned. Not settable by the caller, refused in extra_args.
    "--self-managed",
    "--airgapped",

    "--bundle", join(",", local.airgap_bundles),
    "--bootstrap-cluster-image", local.airgap_bootstrap_cluster_image,
    "--endpoint", local.pc_url,
  ]

  argv_create_pc = concat(
    var.prism_central.insecure ? ["--insecure"] : [],
    var.prism_central.additional_trust_bundle != null ? ["--additional-trust-bundle", var.prism_central.additional_trust_bundle] : [],
  )

  argv_create_networking = concat(
    [
      "--control-plane-endpoint-ip", var.control_plane.endpoint_ip,
      "--control-plane-endpoint-port", tostring(var.control_plane.endpoint_port),
      "--kubernetes-service-load-balancer-ip-range", var.networking.load_balancer_ip_range,
      "--kubernetes-pod-network-cidr", var.networking.pod_cidr,
      "--kubernetes-service-cidr", var.networking.service_cidr,
      "--kubernetes-version", var.version_contract.kubernetes,
    ],
    var.control_plane.external_endpoint != null ? ["--control-plane-external-endpoint", var.control_plane.external_endpoint] : [],
  )

  argv_create_control_plane = concat(
    [
      "--control-plane-replicas", tostring(var.control_plane.replicas),
      "--control-plane-vcpus", tostring(var.control_plane.vcpus),
      "--control-plane-cores-per-vcpu", tostring(var.control_plane.cores_per_vcpu),
      "--control-plane-memory", tostring(var.control_plane.memory_gib),
      "--control-plane-disk-size", tostring(var.control_plane.disk_size_gib),
      "--control-plane-prism-element-cluster", local.cp_prism_element,
      "--control-plane-subnets", local.cp_subnets_arg,
      "--control-plane-vm-image", local.cp_vm_image,
    ],
    length(var.control_plane.pc_categories) > 0 ? ["--control-plane-pc-categories", join(",", var.control_plane.pc_categories)] : [],
    var.control_plane.pc_project != null ? ["--control-plane-pc-project", var.control_plane.pc_project] : [],
    # Only emitted when it differs from the CLI's own default of 180, to keep
    # the rendered command close to the hand-run oracle.
    var.control_plane.renew_certificates_before != 180 ? ["--control-plane-renew-certificates-before", tostring(var.control_plane.renew_certificates_before)] : [],
  )

  argv_create_workers = concat(
    [
      "--worker-replicas", tostring(var.workers.replicas),
      "--worker-vcpus", tostring(var.workers.vcpus),
      "--worker-cores-per-vcpu", tostring(var.workers.cores_per_vcpu),
      "--worker-memory", tostring(var.workers.memory_gib),
      "--worker-disk-size", tostring(var.workers.disk_size_gib),
      "--worker-prism-element-cluster", local.worker_prism_element,
      "--worker-subnets", local.worker_subnets_arg,
      "--worker-vm-image", local.worker_vm_image,
    ],
    length(var.workers.pc_categories) > 0 ? ["--worker-pc-categories", join(",", var.workers.pc_categories)] : [],
    var.workers.pc_project != null ? ["--worker-pc-project", var.workers.pc_project] : [],
    var.workers.vm_profile != null ? ["--worker-vm-profile", var.workers.vm_profile] : [],
  )

  argv_create_csi = concat(
    [
      "--csi-storage-container", var.csi.storage_container,
      "--csi-file-system", var.csi.file_system,
      "--csi-reclaim-policy", var.csi.reclaim_policy,
      "--csi-hypervisor-attached-volumes=${var.csi.hypervisor_attached_volumes}",
    ],
    # Default is false; emit only when enabled, matching the oracle.
    var.csi.flash_mode ? ["--csi-flash-mode=true"] : [],
  )

  argv_create_registry = concat(
    var.registry.url != null ? ["--registry-url", var.registry.url] : [],
    var.registry.username != null ? ["--registry-username", var.registry.username] : [],
    var.registry.cacert != null ? ["--registry-cacert", var.registry.cacert] : [],
    var.registry.mirror_url != null ? ["--registry-mirror-url", var.registry.mirror_url] : [],
    var.registry.mirror_cacert != null ? ["--registry-mirror-cacert", var.registry.mirror_cacert] : [],
  )

  argv_create_proxy = concat(
    var.proxy.http != null ? ["--http-proxy", var.proxy.http] : [],
    var.proxy.https != null ? ["--https-proxy", var.proxy.https] : [],
    length(var.proxy.no_proxy) > 0 ? ["--no-proxy", join(",", var.proxy.no_proxy)] : [],
  )

  argv_create_ingress = concat(
    var.ingress.ca != null ? ["--ingress-ca", var.ingress.ca] : [],
    var.ingress.certificate != null ? ["--ingress-certificate", var.ingress.certificate] : [],
    var.ingress.acme_email != null ? ["--acme-email", var.ingress.acme_email] : [],
    var.ingress.acme_server != null ? ["--acme-server", var.ingress.acme_server] : [],
  )

  argv_create_misc = concat(
    [
      "--ssh-public-key-file", local.node_public_key_path,
      "--ssh-username", var.ssh.username,
    ],
    length(var.misc.ntp_servers) > 0 ? ["--ntp-servers", join(",", var.misc.ntp_servers)] : [],
    length(var.misc.extra_sans) > 0 ? ["--extra-sans", join(",", var.misc.extra_sans)] : [],
    var.misc.cluster_hostname != null ? ["--cluster-hostname", var.misc.cluster_hostname] : [],
    var.misc.fips ? ["--fips=true"] : [],
    var.misc.capi_additional_sync_machine_labels != null ? ["--capi-additional-sync-machine-labels", var.misc.capi_additional_sync_machine_labels] : [],
    var.misc.capi_additional_sync_machine_annotations != null ? ["--capi-additional-sync-machine-annotations", var.misc.capi_additional_sync_machine_annotations] : [],
    [
      "--onboard-to-prism-central=${var.misc.onboard_to_prism_central}",
      "--timeout", var.misc.timeout,
    ],
  )

  argv_create = concat(
    local.argv_create_base,
    local.argv_create_pc,
    local.argv_create_networking,
    local.argv_create_control_plane,
    local.argv_create_workers,
    local.argv_create_csi,
    local.argv_create_registry,
    local.argv_create_proxy,
    local.argv_create_ingress,
    local.argv_create_misc,
    var.extra_args,
  )

  ##################################################
  # argv — delete
  ##################################################

  # Deleting a self-managed cluster builds a fresh bootstrap cluster and
  # reverse-pivots CAPI into it, so the bundle is needed here too (verified
  # live 2026-07-31). --kubeconfig is module-owned: the hook appends the path it
  # wrote from break-glass. nkp delete has NO --dry-run; the hook implements its
  # own, and the volume-group sweep is entirely the hook's job.
  argv_delete = [
    "nkp", "delete", "cluster",
    "--cluster-name", var.cluster_name,
    "--self-managed",
    "--bootstrap-cluster-image", local.airgap_bootstrap_cluster_image,
    "--delete-kubernetes-resources",
    "--timeout", var.misc.timeout,
  ]

  ##################################################
  # Workspace argv, one per admin-scope workspace
  #
  # `-n` IS NOT OPTIONAL. Without it Kommander GENERATES a suffixed namespace --
  # `nkp create workspace tenant-a` produced `tenant-a-2r6tk` on 2026-08-04 --
  # while nkp-platform renders every manifest against the workspace NAME. The
  # flag is rendered unconditionally rather than exposed, because there is no
  # case in this estate where an unpinned namespace is correct and the failure
  # is invisible until manifests silently target a namespace that never exists.
  ##################################################

  workspace_argv = {
    for w in try(var.platform.workspaces.entries, []) : w.name => concat(
      ["nkp", "create", "workspace", w.name, "-n", w.name],
      w.display_name != null ? ["--display-name", w.display_name] : [],
    )
  }

  ##################################################
  # Catalog argv, one per (entry, workspace)
  #
  # `nkp create catalog-application` rather than hand-rolled YAML: the CLI
  # patches the OCIRepository with the cluster's own registry credentials, and
  # owns the catalog label Kommander looks for. Rendering the CR ourselves would
  # reimplement both and drift the day NKP changes either.
  #
  # `catalog-collection` is an ALIAS of this verb -- its own --help says so, and
  # both emit an identical OCIRepository differing only in name and URL -- so
  # one code path covers a single app and a whole collection.
  #
  # FLATTENED OVER WORKSPACES, because a registration is per workspace and one
  # catalog is commonly wanted in several. Keyed "<entry>/<workspace>" so a
  # failure names both halves; the hook needs the pair anyway, since it places a
  # pull secret in each workspace's namespace before registering into it.
  ##################################################

  registrations = {
    for r in flatten([
      for name, entry in try(var.platform.registryops.entries, {}) : [
        for ws in entry.workspaces : {
          key       = "${name}/${ws}"
          name      = name
          workspace = ws
          url       = entry.url
          argv = concat(
            ["nkp", "create", "catalog-application", "--url", entry.url],

            # Exactly one is non-null; the variable's validation guarantees it.
            entry.version.digest != null ? ["--digest", entry.version.digest] : [],
            entry.version.semver != null ? ["--semver", entry.version.semver] : [],
            entry.version.tag != null ? ["--tag", entry.version.tag] : [],

            ["--workspace", ws],
            entry.project != null ? ["--project", entry.project] : [],

            # Naming a secret implies --skip-oci-registry-patches inside nkp, so
            # the two are never both needed.
            try(var.platform.registryops.registry.secret_ref, null) != null ? ["--secret-ref", var.platform.registryops.registry.secret_ref] : [],
            try(var.platform.registryops.registry.insecure, false) ? ["--insecure"] : [],

            ["--interval", entry.interval, "--timeout", entry.timeout],
          )
        }
      ]
    ]) : r.key => r
  }

  ##################################################
  # The contract
  ##################################################

  contract = {
    cluster_name = var.cluster_name
    nkp_version  = var.version_contract.nkp

    # Both generic roots and both resolved directories are published.
    #
    # The ROOTS are here because the hook has to create run_root before it can
    # create anything beneath it, and on a stock host /run is root-owned — so
    # that one `install -d` is the only privileged step in the whole flow, and
    # it must target the shared root rather than nkp's subdirectory, or every
    # tool would need its own.
    #
    # The RESOLVED directories are here so the hook never rebuilds a path the
    # rendered argv already contains. `nkp` is told these exact strings; a hook
    # that recomputed them could look in a directory the CLI never uses.
    bastion = {
      host         = var.bastion.host
      user         = var.bastion.user
      min_free_gib = var.bastion.min_free_gib

      cache_root = trimsuffix(var.bastion.cache_root, "/")
      run_root   = trimsuffix(var.bastion.run_root, "/")

      cache_dir  = local.cache_dir
      run_dir    = local.run_dir
      kubeconfig = local.kubeconfig_path
    }

    # Non-secret process environment. NO_COLOR keeps a 45-minute log readable
    # when the hook mirrors it to a file and to /dev/tty.
    env = {
      NO_COLOR = "1"
    }

    # Names the hook must resolve from SOPS and inject. Never values.
    secret_env = local.secret_env

    # The account to authenticate as. The hook looks its password up on the
    # Prism Central plane (lz-paas ADR 0020) and exports it as NUTANIX_PASSWORD
    # alongside NUTANIX_USER.
    prism_central = {
      endpoint = var.prism_central.endpoint
      port     = var.prism_central.port
      url      = local.pc_url
      user     = var.prism_central.user
      insecure = var.prism_central.insecure
    }

    # What ensure_ready() must guarantee before either verb runs.
    preflight = {
      bundles                 = local.airgap_bundles
      bootstrap_cluster_image = local.airgap_bootstrap_cluster_image
      nkp_version             = var.version_contract.nkp
      min_free_gib            = var.bastion.min_free_gib
      ssh_public_key_path     = local.node_public_key_path
    }

    create = {
      argv    = local.argv_create
      timeout = var.misc.timeout
    }

    delete = {
      argv    = local.argv_delete
      timeout = var.misc.timeout
    }

    # Applied BEFORE everything in `platform`: catalog applications declare
    # `licensing: [Pro, Ultimate]`, and Starter also gates workspace management
    # itself -- so an unlicensed cluster can do none of what follows.
    license = {
      enabled     = try(var.license.enabled, false)
      secret_name = try(var.license.secret_name, "nkp-license")
    }

    # THE SEAM TO nkp-platform, in the order the hook applies it.
    #
    # Carries no credential. secret_ref names a Kubernetes secret, and the
    # gitops block names one too; the values are decrypted from SOPS by the hook
    # at run time, so this stays safe on disk at 0644 like the rest.
    platform = {
      # Admin scope only, normally empty. Tenant workspaces are day-2 and come
      # from nkp-platform over Flux.
      workspaces = {
        enabled = try(var.platform.workspaces.enabled, false)
        entries = {
          for name, argv in local.workspace_argv : name => {
            argv = argv
            # The namespace the workspace will own. Always equal to the name --
            # see workspace_argv for why that is not a preference.
            namespace = name
          }
        }
      }

      # One rendered argv per (entry, workspace), for the hook to run on the
      # bastion.
      registryops = {
        enabled = try(var.platform.registryops.enabled, false)

        # For the hook, which creates the pull secret named by secret_ref from
        # this username and the password it decrypts from SOPS. Names only.
        registry = {
          username   = try(var.platform.registryops.registry.username, null)
          secret_ref = try(var.platform.registryops.registry.secret_ref, null)
          insecure   = try(var.platform.registryops.registry.insecure, false)
        }
        registrations = local.registrations
      }

      # NO ARGV. The hook applies a GitRepository and a Kustomization with
      # kubectl, so this is configuration rather than a command -- which is also
      # why it needs no `nkp` verb and was never create-time argv.
      gitops = {
        enabled = try(var.platform.gitops.enabled, false)
        url     = try(var.platform.gitops.url, null)
        ref = {
          branch = try(var.platform.gitops.ref.branch, null)
          tag    = try(var.platform.gitops.ref.tag, null)
          commit = try(var.platform.gitops.ref.commit, null)
        }
        # Resolved HERE, not in the hook. nkp-platform names each fleet after
        # its management cluster and writes .render/<fleet>/ to the root of
        # `deployed`, so the default is a fact about the other repo's layout and
        # belongs with the rest of the contract rather than in Python.
        path            = coalesce(try(var.platform.gitops.path, null), "./${var.cluster_name}")
        secret_ref      = try(var.platform.gitops.secret_ref, null)
        namespace       = try(var.platform.gitops.namespace, "kommander-flux")
        interval        = try(var.platform.gitops.interval, "10m")
        timeout         = try(var.platform.gitops.timeout, null)
        prune           = try(var.platform.gitops.prune, true)
        service_account = try(var.platform.gitops.service_account, null)
        suspend         = try(var.platform.gitops.suspend, false)
      }
    }
  }

  ##################################################
  # Human-readable rendering
  ##################################################

  # For docs, review and manual reproduction. Contains no secret: credentials
  # are environment variables the operator exports, never argv.
  command_human = join(" \\\n    ", concat(
    ["nkp create cluster nutanix"],
    [
      for pair in chunklist(slice(local.argv_create, 4, length(local.argv_create)), 2) :
      length(pair) == 2 && !startswith(pair[1], "-") ? join(" ", pair) : join(" \\\n    ", pair)
    ],
  ))
}
