# NKP Architecture Design

How Nutanix Kubernetes Platform is deployed and operated across the bingamon estate, and
which repository owns which part.

**Status:** agreed design, not yet implemented
**Target:** NKP v2.18 · Ultimate licence · air-gapped · Nutanix AHV
**Companion:** [Landing Zone](landing_zone.md) — the Nutanix-side prerequisites
**Last reviewed:** 2026-07-26

## What this document is

The **design**. It records what we are building, why, and the boundaries between the four
repositories. Every decision here was argued through and is listed in the
[decision register](#decision-register).

It deliberately does **not** restate the Nutanix prerequisites — those live in
[`landing_zone.md`](landing_zone.md).

Sources are cited two ways: the official NKP v2.18 doc set by **document + section heading**
(the files are regenerated, so line numbers are unstable), and
[CAREN](https://github.com/nutanix-cloud-native/cluster-api-runtime-extensions-nutanix) by
repo-relative path.

## The two constraints that shape everything

**1. NKP has no Terraform surface.** Verified against the provider source, not the docs: a
case-insensitive search of `nutanix/terraform-provider-nutanix` for `nkp`, `konvoy`,
`kommander` and `capx` returns **zero hits**. 184 data sources and 129 resources are
registered; none is NKP. There
is no NKP client in the v4 SDK. The `nutanix_karbon_*` resources are real but target legacy
NKE on `/v1/k8s/clusters` and have been frozen since January 2025.

**So the `nkp` CLI is the only way to create a cluster.** That is not a preference; it is the
whole shape of the problem.

**2. In 2.18 the declarative object is `NKPCluster`, and the webhook enforces it.**

> The admission webhook rejects any direct modification to the `spec.topology` field of a
> managed CAPICluster, **regardless of whether the request originates from kubectl, another
> controller, or a GitOps tool such as Flux.** Only the NKPCluster controller can update the
> topology.

Committing raw CAPI `Cluster` objects — the pattern every field example uses — is actively
blocked. `NKPCluster` (`clusters.nkp.nutanix.com/v1alpha1`) wraps the CAPI topology and the
`KommanderCluster` into one resource and is "the single source of truth for cluster lifecycle
operations."

## Personas and the seam between them

| Persona                  | Owns                                                             | Tools                     |
| ------------------------ | ---------------------------------------------------------------- | ------------------------- |
| **Infrastructure**       | The Nutanix estate, and bootstrapping the NKP management cluster | OpenTofu, `lz-cli`, hooks |
| **Platform engineering** | The fleet: workload clusters, platform apps, fleet-wide config   | Git, Flux, Kustomize      |

**The handoff is a single, nameable event: the moment the management cluster's GitOps source
is pointed at `nkp-platform`.** Before it, Terraform and the hook. After it, git.

That handoff must be declarative. Do **not** use the NKP UI flow that first-party examples
demonstrate (_Projects → Continuous Deployment → GitOps Sources_) — it puts unversioned
click-ops at the root of the entire GitOps tree.

## The four repositories

| Repo             | Persona              | Contains                                                                          |
| ---------------- | -------------------- | --------------------------------------------------------------------------------- |
| **lz-paas**      | Infrastructure       | Foundation, PE, PC, all Nutanix landing zones, the bastion VM, the NKP hook       |
| **tf-ntnx-nkp**  | Infrastructure       | Child module: resolves and validates prerequisites, renders the CLI invocation    |
| **nkp-platform** | Platform engineering | `NKPCluster` definitions, components menu, management apps, SOE, vendored schemas |
| **nkp-images**   | Platform engineering | CI pipeline building CPU and GPU node images with NIB                             |

`nkp-mgmt` and `nkp-soe` from the original plan are **merged into `nkp-platform`**. With
Kommander propagation (see [SOE delivery](#soe-delivery)), Flux only ever reconciles against
the management cluster — so they are one reconcile domain. Two repos would mean two
`GitRepository` objects, two credential sets and duplicated schemas for content landing in the
same place.

## Day 1 — bootstrapping the management cluster

### Terraform renders; the hook executes

The CLI takes **no values file**. There is no `--values`, `-f` or `--config` on
`nkp create cluster nutanix` — it is flags only, with nine required:

```text
--cluster-name --endpoint --control-plane-endpoint-ip
--control-plane-prism-element-cluster --control-plane-subnets
--worker-prism-element-cluster --worker-subnets
--csi-storage-container --kubernetes-service-load-balancer-ip-range
```

plus **at least one** of `--vm-image` / `--control-plane-vm-image` / `--worker-vm-image`. The binary
enforces this as a cobra flag group and its error is explicit:

```text
at least one of the flags in the group [vm-image control-plane-vm-image worker-vm-image] is required
```

> **Not "exactly one".** Passing `--control-plane-vm-image` _and_ `--worker-vm-image` together is the
> documented invocation (`08-custom-installation-and-tools.md` § "Creating the … Management Cluster
> using CLI"). Any validation asserting mutual exclusion would reject Nutanix's own worked example.

So Terraform's job is to **resolve and validate**, then render. It does not execute:

- `tf-ntnx-nkp` resolves the subnet name, PE cluster name, storage container, VIP, LB range
  and image reference from landing-zone state, validates them, and renders a versioned
  invocation.
- An `lz-cli` hook (`tasks/nkp_*.py`) executes it on the bastion — the same idiom lz-paas
  already uses for LCM, the PE password rotation and the Data Services IP.

**Why not a `null_resource` wrapper.** Cluster creation is a 30–45 minute operation
(`--timeout` defaults to `30m0s`) with no idempotency story in any published example: no
existence probe, no retry, no partial-failure recovery. Wrapping it in Terraform buys almost
none of Terraform's value while inheriting tainted state, destroy-ordering hazards and
secrets in state. Keeping it in a hook makes it resumable, logged, and outside state.

### The bastion is cattle

The CLI needs a host inside the air gap with reach to Prism Central on 9440 and the node
subnet, holding the bundle, registry CA trust and the kubeconfig, surviving a long
backgrounded operation. Sized 8 vCPU / 16 GB / 80 GB.

Field implementations treat this as a pet. It does not have to be, because **Caddy already
solves asset distribution** — the bundle lives on Caddy and the bastion fetches it at run
time.

| State                    | Why it is not pet-state                                  |
| ------------------------ | -------------------------------------------------------- |
| ~15 GB air-gapped bundle | fetched from Caddy on demand                             |
| `nkp` CLI binary         | ships inside that bundle                                 |
| Registry CA trust        | rendered by cloud-init from Terraform                    |
| **Kubeconfig**           | **SOPS-encrypted in git**, fetched and decrypted on boot |
| Logs                     | shipped, or accepted as lost on rebuild                  |

Declared in lz-paas as `compute_databases.virtual_machines` → `tf-ntnx-vm`, which supports
`guest_customization_cloud_init_user_data`.

**The acceptance test is blunt:** destroy the bastion, re-apply, and the next NKP operation
must succeed with **zero** manual steps. If it does not, state has been smuggled onto it.

### Day-2 upgrades

Upgrade is not one command. The surface is six ordered commands plus a CLI binary swap:

```text
nkp upgrade capi-components
nkp upgrade cluster nutanix --vm-image <new>
nkp upgrade kommander
nkp upgrade workspace <name>
nkp upgrade addons
nkp upgrade catalogapp
```

So you cannot "upgrade via Terraform" as a resource update. Terraform holds `nkp_version` and
the image reference as inputs, detects the change, and triggers an ordered hook — the same
model as Day 1. **The admin edits YAML; the admin does not SSH.** SSH stays break-glass.

Note `nkp upgrade cluster nutanix` on the management cluster also performs "Updating
ClusterClass resources" — the ClusterClass is a product artefact, installed and updated by the
CLI, never by us.

## Air-gap — non-negotiable

**`--airgapped=true` on every `nkp create cluster` invocation. No exceptions, in any
environment.**

This is not a lab-versus-production toggle. The lab's VLAN 82 has **Allow Internet Access**
enabled on the UDM, so a cluster built without the flag will come up perfectly — pulling from
Docker Hub — and the same command will fail in a real enclave. **The lab cannot detect this
class of defect.** Forcing the flag is the only thing that makes lab success meaningful.

The renderer in `tf-ntnx-nkp` therefore hard-codes it rather than exposing it as a variable.
There is no legitimate reason for a bingamon cluster to be built any other way.

### The registry flags that go with it

Images come from the **internal registry mirror** (NCR), seeded from bundle tarballs on the
bastion at cluster-create time:

```bash
export BUNDLE_FLAGS=" --bundle ./nkp-<ver>/container-images/kommander-image-bundle-<ver>.tar,\
./nkp-<ver>/container-images/konvoy-image-bundle-<ver>.tar"
```

> **Important: Do not use both BUNDLE_FLAG and REGISTRY_MIRROR_FLAG simultaneously.**

So `${BUNDLE_FLAGS}` **or** `${REGISTRY_MIRROR_FLAGS}`, never both. We use the former; no
Harbor is required. Per-cluster caching is then handled by the `addons.registry` CNCF
Distribution addon (see [Networking](#networking)).

### Two failure modes to design out

**Extract the bundle with `-p`.** Without it a restrictive umask strips read permissions and
the deployment hangs at _"Waiting for bundles to be pushed to internal registry"_ with a
permission-denied error:

```bash
tar -xzvpf nkp-air-gapped-bundle_<ver>_linux_amd64.tar.gz
```

**Prove builds are offline, don't assume it.** The `nkp-images` pipeline and the bastion
cloud-init must be verifiably offline-capable. The reference implementation we studied
claimed to be air-gapped while its bastion pulled ten tools from `dl.k8s.io`, `github.com`
and `raw.githubusercontent.com` at boot, several resolving `latest` at run time. Pin
everything, source it from Caddy, and treat any egress during a build as a defect.

## nkp-platform — the GitOps repo

### Layout

```text
nkp-platform/
├── clusters/                    # the "form": one directory per cluster
│   ├── mgmt/
│   │   ├── kustomization.yaml
│   │   └── cluster.yaml         # ~15 scalars. THIS is the values file
│   └── wkld-dev-01/
├── bases/nkpcluster/            # fleet invariants, edited rarely
│   ├── nkpcluster.yaml          # skeleton + clusterConfig defaults
│   └── replacements.yaml        # cluster-context fan-out
├── components/
│   ├── pools/                   # machine profiles: cpu-standard, cpu-small, gpu-h100
│   └── features/                # registry-cache, no-service-lb, fips
├── management/                  # apps on the management cluster itself
├── soe/                         # AppDeployments targeting workload clusters
├── schemas/v2.18.0/             # vendored CAREN CRDs + captured NKPCluster CRD
└── secrets/                     # SOPS (bootstrap) and ExternalSecret (steady state)
```

### The three layers

| Layer          | Holds                                                                         | Changes when                               |
| -------------- | ----------------------------------------------------------------------------- | ------------------------------------------ |
| **base**       | `NKPCluster` skeleton, fleet-wide `clusterConfig` defaults, hardening posture | fleet policy or the NKP version changes    |
| **components** | machine profiles and optional features — the menu                             | a new machine shape or capability is added |
| **overlay**    | the ~15 per-cluster scalars, plus which components apply                      | every new cluster                          |

### Kustomize, not Helm

Kustomize is the single structural tool. `HelmRelease` appears only as a **resource type**
when wrapping an upstream chart — never as a templating engine anyone operates.

This matches the NKP catalog's own shape: Kustomize as the structural layer (66 ×
`kustomize.config.k8s.io` + 37 × Flux `kustomize.toolkit.fluxcd.io` Kustomizations) with
`OCIRepository` + `HelmRelease` as payload (27 each). One mental model across clusters and
apps.

Accepted trade-off: Kustomize is weaker at structural variation. A variable number of node
pools is a component per pool rather than a `range` loop. At a handful of clusters this is a
non-issue.

### Node pools — components carry shape, replacements carry context

The DRY problem is that `image`, `subnets`, `cluster` and `storageContainer` appear in the
control plane **and** in every worker pool. Splitting the two concerns solves it:

**Components define shape only.** Adding a GPU pool to a cluster is one line in its
`kustomization.yaml`:

```yaml
# components/pools/gpu-h100/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1alpha1
kind: Component
patches:
  - target: {kind: NKPCluster}
    patch: |
      - op: add
        path: /spec/capiCluster/topology/workers/machineDeployments/-
        value:
          class: default-worker
          name: gpu-h100
          replicas: 1
          metadata:
            annotations:
              cluster.x-k8s.io/cluster-api-autoscaler-node-group-min-size: "1"
              cluster.x-k8s.io/cluster-api-autoscaler-node-group-max-size: "4"
          variables:
            overrides:
              - name: workerConfig
                value:
                  nutanix:
                    machineDetails:
                      vcpuSockets: 8
                      vcpusPerSocket: 1
                      memorySize: 32Gi
                      systemDiskSize: 120Gi
                      bootType: uefi
                      gpus:
                        - { type: name, name: H100 }
```

The `gpus` shape is from
`api/v1alpha1/crds/caren.nutanix.com_nutanixworkernodeconfigs.yaml`: `type` is an enum of
`[deviceID, name]`, `maxItems: 32`.

**Replacements fan cluster context into every pool at once.** The `*` wildcard is what makes
this scale:

```yaml
replacements:
  - source:
      kind: NKPCluster
      fieldPath: spec.capiCluster.topology.variables.0.value.image
    targets:
      - select: {kind: NKPCluster}
        fieldPaths:
          - spec.capiCluster.topology.variables.0.value.controlPlane.nutanix.machineDetails.image.name
          - spec.capiCluster.topology.workers.machineDeployments.*.variables.overrides.0.value.nutanix.machineDetails.image.name
```

Repeated for `subnet`, `prismElementCluster` and `storageContainer`.

### Use `imageLookup`, not `image`

NIB image names carry a build timestamp, so pinning an exact name means every rebuild churns
every cluster. `imageLookup` takes a glob instead:

```yaml
imageLookup:
  baseOS: rocky-9.6
  format: nkp-{{.BaseOS}}-release-{{.K8sVersion}}-*
```

`format` substitutes `{{.BaseOS}}` and `{{.K8sVersion}}` and supports `*`. A Kubernetes
upgrade therefore looks for the matching image automatically. A CEL rule enforces exactly one
of `image` / `imageLookup`.

> **Unresolved:** if the glob matches two images, the tie-break is not documented. Image
> naming discipline still matters.

### Why `replacements` and not Flux `postBuild.substituteFrom`

This is load-bearing for validation. With `postBuild`, `kustomize build` still emits
`${VAR}` literals, so offline schema validation checks **placeholders, not values** — an
integer field holding a string would pass. With `replacements`, `kustomize build` produces the
**final manifest**, so validation checks what will actually be applied.

## Validation — shift left, offline

`nkp create cluster --dry-run` **cannot** be the PR gate. Tested empirically: it validates
flags client-side, then contacts the network. For a workload cluster it needs the management
cluster kubeconfig —

> `err="error validating license requirements: error creating kubernetes client for management cluster…"`

— and `--self-managed --dry-run` dials Prism Central (it hung 90 s against a blackhole
address). **`--skip-preflight-checks=all` does not bypass the licence check**; it runs first.

The answer is vendored schemas. CAREN commits the variable schemas as consumable CRD YAML,
and those exact files are the runtime source of truth via `go:embed`:

```text
api/v1alpha1/crds/caren.nutanix.com_nutanixclusterconfigs.yaml     (1311 lines)
api/v1alpha1/crds/caren.nutanix.com_nutanixworkernodeconfigs.yaml   (520 lines)
```

Extract `.spec.versions[0].schema.openAPIV3Schema.properties.spec` — CAREN uses that subtree
verbatim as the ClusterClass variable schema.

| Layer | Where           | Cluster? | Catches                                                         |
| ----- | --------------- | -------- | --------------------------------------------------------------- |
| 0     | pre-commit + CI | no       | wrong or mistyped fields in the values file                     |
| 1     | CI              | no       | template errors, invalid YAML (`kustomize build`)               |
| 2     | CI              | no       | rendered `NKPCluster` violating the CRD schema (`kubeconform`)  |
| 3     | CI              | no       | bad `clusterConfig`/`workerConfig` vs the vendored CAREN schema |
| 4     | bastion runner  | **yes**  | admission webhook, CEL, cross-field rules                       |
| 5     | post-merge      | n/a      | reality — quota, IP conflict, missing image                     |

Layers 0–3 run on GitHub-hosted runners with no cluster access. Layer 4 needs the bastion,
which already holds the kubeconfig.

**Schema churn fails closed.** Measured across five CAREN tag ranges: all changes were
additive, no renames, removals or type changes; `v0.48.0 → v0.49.0` was zero-churn. A stale
vendored schema therefore rejects valid YAML rather than accepting invalid YAML — loud and
safe. Re-vendor on NKP upgrade, exported by the upgrade hook as a reviewable PR.

**Known blind spot: CEL.** `x-kubernetes-validations` rules are preserved into the schema but
JSON Schema validators do not evaluate them. The most likely authoring mistake is invisible
offline:

```yaml
rule: "has(self.image) != has(self.imageLookup)"
```

Layer 4 is the only gate that catches it.

**Post-merge is irreducible.** Flux is pull-based. Mitigate with notification-controller
`Alert`/`Provider` objects and health checks on each `Kustomization`, so a stalled cluster
surfaces as a failed reconcile rather than silence.

## SOE delivery

Fleet-wide configuration is declared **once on the management cluster** and propagated by
Kommander:

```yaml
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
spec:
  appRef: {kind: App, name: kai-scheduler-0.15.2}
  clusterSelector:
    matchExpressions:
      - {
          key: kommander.d2iq.io/cluster-name,
          operator: In,
          values: [wkld-dev-01],
        }
  configOverrides: {name: kai-scheduler-overrides}
```

Catalogs attach declaratively — a labelled `OCIRepository`, no click-ops:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: OCIRepository
metadata:
  labels:
    catalog.nkp.nutanix.com/catalog-source-artifact: "true"
spec:
  url: oci://<internal-registry>/nkp-ai-applications-catalog/collection
  ref: {digest: sha256:…} # pin a digest, not the mutable tag
```

**Pin digests.** Collection tags such as `2.18` are mutable, so "what is deployed" would
otherwise be answered by a registry digest rather than a git SHA — a real provenance
regression in an audited environment.

The deprecation warning about GitRepository-based catalogs does **not** apply here: that
concerns the _old_ catalog source mechanism (`nkp create catalog --url <git-url>`). OCI
collections are the replacement.

**Do not build our own catalog.** It would make the closed-source `nkp` CLI a build
dependency and move the source of truth from a git SHA to an OCI tag. Use plain Flux for
everything we own; consume Nutanix's catalogs as above.

## Networking

VLAN 82 is confirmed on the UDM: `192.168.82.0/24`, gateway `.254`, trunked to the blades,
DHCP scope `.100–.200` with Auto Default Gateway and Auto DNS Server enabled. The
control-plane VIP (`.10`) and the MetalLB range (`.20–.39`) sit outside that scope, as NKP
requires. Full plan in [Landing Zone §4.3](landing_zone.md#43-address-plan).

| Concern                 | Decision                                                                             |
| ----------------------- | ------------------------------------------------------------------------------------ |
| Node addressing         | **External DHCP** (UDM), not Nutanix IPAM. VLAN 82 stays VLAN-only                   |
| Pod CIDR                | **`172.20.0.0/16`** — the default `192.168.0.0/16` collides with the entire lab      |
| Service CIDR            | `10.96.0.0/12` default — no collision                                                |
| Control-plane VIP       | static, in-CIDR, **outside** the DHCP scope                                          |
| Service LB (mgmt)       | **MetalLB** — `--kubernetes-service-load-balancer-ip-range` is required at bootstrap |
| Service LB (workload)   | free choice — see below                                                              |
| Per-cluster image cache | `addons.registry`, `provider: CNCF Distribution`                                     |

**Pod CIDR is irreversible.** "Do not change the IPAM mode, Pod CIDR, or Service CIDR of an
existing, running NKP cluster." The documented remedy is to build a new cluster and migrate.

**F5 BIG-IP is available on workload clusters.** `addons.serviceLoadBalancer` is **optional**
— it appears in no `required` list, and its own description says "Not required in
infrastructures where the CCM acts as the provider." Its `provider` enum is `[MetalLB]` only,
so _if_ you use the NKP-managed addon you get MetalLB. Omit it and F5 CIS serves
`Service type=LoadBalancer` directly, or keep MetalLB and route specific Services to F5 by
`spec.loadBalancerClass` — the pattern CAREN itself documents for AWS.

Because we render `NKPCluster` rather than invoking the CLI, the CLI's required-flag list
does not bind workload clusters. The YAML has no such requirement.

## Images — nkp-images

**One pipeline, one release process.** NIB builds every image, CPU and GPU. NIB is embedded
in the CLI (`nkp version` reports `imagebuilder: v2.18.0`), so there is no separate tool to
adopt — it is `nkp create image nutanix`.

Rocky Linux on Day 1. RHEL later, when FIPS enters scope.

### One BaseOS, three outputs

```text
Hardened BaseOS  (Rocky 9.6 now, RHEL later — one accreditation)
   ├─ + NIB          → node image, CPU      ┐
   ├─ + NIB          → node image, GPU      ├─ nkp-images
   └─ + cloud-init   → bastion              ┘  lz-paas
```

The bastion **shares the BaseOS lineage but not the NIB output**. The NIB output is a
Kubernetes node image (kubelet, containerd, kubeadm); the bastion needs Docker or Podman 4.0+
for the KIND bootstrap cluster. For an accreditation the thing to minimise is the number of
OS images to accredit — hence one base, three role outputs.

### Two distinct air-gap inputs

Easy to conflate, and both are needed:

| Flag                    | Contains                                           | Produced by                                               |
| ----------------------- | -------------------------------------------------- | --------------------------------------------------------- |
| `--artifacts-directory` | **OS packages**                                    | `nkp create package-bundle` on an internet-connected host |
| `--bundle`              | **container images** to pre-load into the OS image | shipped in the air-gapped bundle                          |

The air-gapped bundle deliberately excludes distro packages — "NKP Kubernetes packages,
Python packages, Containerd tarball" only.

### Build gotchas to encode in the pipeline

- **BaseOS root filesystem must be under 80 GiB.** Nodes default to 80 GiB; a larger base
  fails the install.
- **CIS/STIG partitioning puts `noexec` on `/tmp`**, which breaks the NIB build and the
  NVIDIA runfile. Set `PKR_VAR_remote_folder`, and `--tmpdir` for the driver install.
- **You cannot use a portal image or a previous NIB image as a BaseOS.**
- **The image is tied to the Kubernetes version** — a new image per NKP/K8s upgrade.
- **Air-gapped GPU builds bake the NVIDIA driver into the BaseOS**; `--gpu-name` is an
  internet-connected path. Tag with `--extra-build-name`.

## Secrets

ESO against a vault, with SOPS retained where ESO cannot reach. Both are natively supported:
`external-secrets` v2.3.0 ships as a platform application (not deployed by default), and the
Kommander installer config exposes `ageEncryptionSecretName: sops-age`.

**ESO cannot cover bootstrap.** It runs _on_ a cluster; some secrets are needed before any
cluster exists.

| Tier  | Secret                                                         | Source                                     |
| ----- | -------------------------------------------------------------- | ------------------------------------------ |
| **0** | `NUTANIX_USER`/`PASSWORD`, registry credentials                | **secretspec/SOPS** via `lz-cli` — not ESO |
| **1** | the four `<cluster>-*-credentials` on the mgmt cluster         | created by the CLI from Tier 0             |
| **2** | the same four per workload cluster, in its workspace namespace | **ESO**, ordered by Flux `dependsOn`       |
| **3** | app secrets, vGPU token, LDAP bind                             | **ESO**                                    |

Plus the kubeconfig on SOPS, so a bastion or cluster rebuild never depends on the vault.

`ClusterSecretStore` is the environment seam — `ExternalSecret` objects are identical in lab
and production:

|            | Vault                                          |
| ---------- | ---------------------------------------------- |
| Lab        | Vault or Infisical as a Helm chart, in-cluster |
| Production | enterprise HashiCorp Vault, external           |

**Prefer Vault Kubernetes auth** — the cluster's ServiceAccount JWT authenticates, so there is
no static credential to store anywhere.

> **In-cluster vault creates a bounded circularity.** ESO on the management cluster depending
> on a vault _in_ that cluster only bites on cold start and rebuild. Order it with
> `dependsOn` — cluster → vault → ESO → everything else — and keep Tier 0 on SOPS. Note that
> a cluster rebuild then becomes a vault _restore_; acceptable in a lab, do not let it
> migrate to production.

## Identity

Dex is built in — "NKP user interface comes with a pre-configured authentication Dex identity
broker and provider" — shipping alongside `kube-oidc-proxy` and `traefik-forward-auth`.

```text
Ping Identity ──(OIDC, SAML fallback)──> Dex (management cluster)
                                          ├─ kube-oidc-proxy      → kubectl to workload clusters
                                          └─ traefik-forward-auth → NKP UI
```

**Per-cluster apiserver OIDC is not reachable.** CAREN exposes no apiserver `extraArgs` and no
OIDC variable for Nutanix; the only apiserver-adjacent variable is `extraAPIServerCertSANs`.
Combined with _"You cannot perform this procedure for Nutanix AHV NKP clusters"_ for the
KCP-patch route, direct per-cluster OIDC would require forking the ClusterClass. Identity
therefore federates through Dex.

**OIDC first, SAML 2.0 as fallback.** The fallback is cheap — both are Dex connector
configurations against the same broker, so switching changes a config block, not the
architecture.

> **Verify on the shipped version.** The platform-app table lists **Dex 2.14.5** (chart
> 2.14.0) while the connector-maturity table is attributed to **"Dex 2.22.0, the version used
> by NKP"**. Those disagree, and the maturity table marks OIDC `beta` and SAML 2.0 `stable`.
> If OIDC misbehaves, suspect this discrepancy first.

Two authorisation layers must stay in sync: Dex/OIDC group mapping, **and** email
whitelisting in `traefik-forward-auth-mgmt` — without the latter a valid user gets no UI
access.

## Self-service

**The values file is the API.** Anything that can open a pull request is a valid front door —
Nutanix Self Service, Backstage, a form, or a purpose-built CLI:

```text
human:        edit cluster.yaml + components list → PR → review → merge → Flux
self-service: form → same cluster.yaml            → PR → merge          → Flux
```

Git stays the single source of truth and the audit trail; review remains a gate; humans and
machines use identical machinery. The front-door choice is deferred; the values schema is
designed so any of them can target it.

## Compliance posture

FIPS is **out of scope for Day 1**. These findings still apply.

**Kubernetes-layer CIS and STIG hardening is always on**, independent of image choice and of
FIPS. CAREN applies both patch sets unconditionally at ClusterClass build time
(`hack/examples/overlays/clusterclasses/nutanix/kustomization.yaml.tmpl`): apiserver
`profiling=false`, `service-account-lookup=true`, `NodeRestriction`, `EventRateLimit`,
`DenyServiceExternalIPs`; STIG TLS cipher suites and `VersionTLS12`; kubelet
`readOnlyPort: 0`, `podPidsLimit: 4096`, `0600` file permissions; etcd `auto-tls: false` with
TLS 1.2. NKP Insights also runs **kube-bench `cis-1.15` every 35 minutes by default** — free
continuous CIS evidence.

**Five things are off by default and must be set in `base`:**

| Setting                                      | Default                       | Set to                                                                               |
| -------------------------------------------- | ----------------------------- | ------------------------------------------------------------------------------------ |
| `encryptionAtRest`                           | absent — **etcd unencrypted** | `aescbc` (no KMS available, `maxItems: 1`, never rotated, secrets + configmaps only) |
| `podSecurityAdmission`                       | `privileged` — **a no-op**    | `enforce: restricted`                                                                |
| `kubeletConfiguration.protectKernelDefaults` | **no default**                | `true`                                                                               |
| `kubeletConfiguration.seccompDefault`        | `false`                       | `true`                                                                               |
| `ntp`                                        | off                           | set — audit correlation depends on it                                                |

**Three findings to carry into an accreditation:**

- **Audit logs die locally.** The policy is embedded and unconfigurable; logs land on
  control-plane hostPath at `maxage 30` / `maxsize 100`, then are gone. No forwarder exists in
  CAREN. Shipping to a SIEM is ours.
- **Two always-on containerd settings will fail a STIG review**, with no CAREN opt-out:
  `address = "0.0.0.0:1338"` (unauthenticated metrics on every node) and
  `enable_unprivileged_ports = true` / `enable_unprivileged_icmp = true`.
- **The documented CIS remediation route is blocked on AHV** — _"You cannot perform this
  procedure for Nutanix AHV NKP clusters."_ Remediation goes through CAREN variables or a
  ClusterClass fork.

By design and not fixable: `--anonymous-auth` stays true (kubeadm join needs it),
`--kubelet-certificate-authority` stays unset (breaks CAPI node join), and there is **no BYO
cluster CA** — DoD PKI for the cluster's own CA is outside NKP.

## Open questions

| Question                         | Why it matters                                                                                                                                                                          |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Audit-log shipping**           | No forwarder in NKP. Non-negotiable for an ATO; ours to build                                                                                                                           |
| **`NKPCluster` envelope**        | Closed-source — not in CAREN. Must be captured from a real cluster to finalise `bases/nkpcluster.yaml`                                                                                  |
| **`imageLookup` glob tie-break** | Undocumented when two images match                                                                                                                                                      |
| **RHSM in an air gap**           | No Satellite story in the docs. Prove before committing to the RHEL/FIPS path                                                                                                           |
| **"Ubuntu Pro" image**           | Claims CIS + STIG + FIPS together; **one** mention in the release notes, nothing else. Ask Nutanix                                                                                      |
| **FIPS 140-2 vs 140-3**          | The cited certificate `140sp3702` is 140-2; the product claims 140-3. Get the CMVP number in writing                                                                                    |
| **Kommander static admin**       | Cannot be deleted, only rotated. Document as accepted break-glass — the "no inbuilt accounts" requirement cannot be fully met                                                           |
| **`nkp serve bundle`**           | Embedded mindthegap can serve an OCI registry from bundles — a possible simplification we have not evaluated                                                                            |
| **NKP built-in Git host**        | `nkp experimental gitops clone` — worth testing, deliberately not gating                                                                                                                |
| **Catalog registry rewrite**     | Whether `nkp push bundle` rewrites `OCIRepository.spec.url` to the internal registry happens inside the closed CLI. Test early; it decides air-gap viability for third-party-chart apps |

## Decision register

| #   | Area             | Decision                                                                                                                       |
| --- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| 1   | Fleet UI         | Rancher **dropped** → Kommander. Removes the Fleet-vs-Flux question                                                            |
| 2   | Terraform's role | Renders inputs and validates prerequisites; `lz-cli` hook executes the CLI                                                     |
| 3   | Bastion          | **Cattle** — Terraform-built, assets from Caddy, rebuildable on demand                                                         |
| 4   | Cluster access   | Kubeconfig SOPS-encrypted in git                                                                                               |
| 5   | Git artefact     | Values + renderer; `NKPCluster` rendered in-cluster                                                                            |
| 6   | Tooling          | **Kustomize everywhere**; `HelmRelease` only as a payload kind                                                                 |
| 7   | Layout           | base / components / overlay, with `replacements` fan-out                                                                       |
| 8   | Service LB       | MetalLB on management (forced); workload clusters may omit the addon and use F5 CIS                                            |
| 9   | Registry cache   | Enable `addons.registry` CNCF Distribution per cluster                                                                         |
| 10  | Catalogs         | Consumed declaratively via labelled `OCIRepository` + `AppDeployment`; **digests pinned**                                      |
| 11  | SOE delivery     | Kommander `AppDeployment` + `clusterSelector`                                                                                  |
| 12  | Repos            | **Four**: `lz-paas`, `tf-ntnx-nkp`, `nkp-platform`, `nkp-images`                                                               |
| 13  | Images           | NIB for CPU **and** GPU — one pipeline, one release process                                                                    |
| 14  | OS               | Rocky Day 1; RHEL later. No FIPS Day 1                                                                                         |
| 15  | Secrets          | ESO + vault; SOPS retained for Tier 0 and the kubeconfig                                                                       |
| 16  | Self-service     | The PR flow is the API; front door deferred                                                                                    |
| 17  | Identity         | Dex (built in) ← Ping via OIDC, SAML fallback                                                                                  |
| 18  | Git host         | GitHub SaaS (lab) / GHE (production); NKP built-in to be evaluated                                                             |
| 19  | Pod CIDR         | `172.20.0.0/16` — irreversible after creation                                                                                  |
| 20  | Node addressing  | External DHCP, not Nutanix IPAM                                                                                                |
| 21  | Validation       | Offline layers 0–3 via vendored CAREN CRDs; layer 4 on the bastion runner                                                      |
| 22  | Hardening        | `base` sets `encryptionAtRest`, `podSecurityAdmission: restricted`, `protectKernelDefaults`, `seccompDefault`, `ntp`           |
| 23  | Air-gap          | **`--airgapped=true` always**, hard-coded in the renderer. `${BUNDLE_FLAGS}` (NCR), never alongside `${REGISTRY_MIRROR_FLAGS}` |

## ADR 0003 disposition

ADR 0003 in lz-paas parked NKP because the provider has no NKP resources. **That premise still
holds** — `terraform` appears zero times across all 14 NKP v2.18 documents, and the provider
audit confirms zero NKP resources.

What changed is the decision, not the fact. This design takes the CLI-driven path ADR 0003
declined, but in a narrower form than that ADR contemplated: **Terraform never executes the
CLI.** It resolves and validates inputs; a hook executes. That distinction is why the park can
be resolved without the fragility ADR 0003 was guarding against.

This document is the design that supersedes the park. A new ADR should record it in lz-paas.

## References

Official NKP v2.18 documentation is vendored at [`../nutanix/`](../nutanix/) and cited by
document plus section heading throughout, because those files are regenerated and their line
numbering is not stable.

| Source                                      | Used for                                                                |
| ------------------------------------------- | ----------------------------------------------------------------------- |
| `01-release-notes.md`                       | Compatibility, component versions, known issues, `NKPCluster` migration |
| `03-downloading-and-getting-started.md`     | Bundles, licences, cluster types, registry concepts                     |
| `05-image-builder.md`                       | Prebuilt vs custom images, NIB, air-gapped package bundles              |
| `07-cluster-operations.md`                  | Rook Ceph, CNI, MetalLB, identity, catalogs, Insights                   |
| `08-custom-installation-and-tools.md`       | The Nutanix install path, air-gap, sizing, PC roles                     |
| `09-kommander-and-konvoy-configurations.md` | Registry seeding, Small Environment, FIPS, Dex                          |
| `10-upgrade-guide.md`                       | Upgrade sequence, `NKPCluster` CRD, ClusterClass updates                |
| CAREN `api/v1alpha1/crds/`                  | The `clusterConfig` / `workerConfig` variable schemas                   |
| CAREN `hack/examples/patches/{cis,stig}/`   | The always-on hardening arg sets                                        |
| CAREN `pkg/handlers/`                       | Registry mirrors, etcd, audit policy, encryption at rest                |

Related: [Landing Zone](landing_zone.md) — the Nutanix prerequisites this design assumes.
