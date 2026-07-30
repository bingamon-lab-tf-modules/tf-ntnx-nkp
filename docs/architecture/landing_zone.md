# NKP Readiness

Preparing the bingamon Prism Element and Prism Central estate for Nutanix Kubernetes
Platform (NKP).

**Status:** research / not yet implemented
**Target:** NKP v2.18
**Environment:** `bingamon` (air-gapped)
**Licence:** NKP Ultimate
**Last reviewed:** 2026-07-26

## What this document is

This is the **preparation** contract. It describes what must already be true of the
bingamon Nutanix estate before an NKP **management cluster** can be deployed, and which
of those prerequisites this repository owns.

It is deliberately **not**:

- the architecture — how NKP is deployed and operated, and which repository owns what, is in
  [Design](design.md);
- a guide to deploying NKP — that is the job of the `tf-ntnx-nkp` child module, developed
  separately;
- a re-litigation of [ADR 0003](decisions/0003-nkp-parked.md) (see
  [ADR 0003 disposition](#adr-0003-disposition)).

Everything below is drawn from the official NKP v2.18 documentation set. Because that set
is a PDF-to-Markdown conversion whose line numbering is unstable, citations name the
**document and section heading** rather than line numbers.

> **Terminology.** NKP has no concept of a "management server". The product term is
> **management cluster**: a self-managed Kubernetes cluster of AHV VMs, not a single
> appliance VM. At Ultimate that is **seven VMs** (3 control-plane + 4 workers), plus a
> transient bootstrap cluster that runs in Docker on a bastion and is deleted afterwards.
> Plan accordingly.

## Readiness at a glance

| #   | Prerequisite                    | Status                | Owner               |
| --- | ------------------------------- | --------------------- | ------------------- |
| 0   | PE registered to PC             | verify first          | this repo (Day-2)   |
| 1   | AOS / PC version floor          | satisfied             | n/a                 |
| 2   | Physical capacity               | satisfied             | n/a                 |
| 3   | Licence (Ultimate)              | held                  | n/a                 |
| 4   | VLAN 82 addressing + DHCP scope | **satisfied**         | UDM (confirmed)     |
| 5   | Control-plane VIP               | decided, to reserve   | decision + NKP CLI  |
| 6   | MetalLB service range           | decided, to reserve   | decision + NKP CLI  |
| 7   | Pod CIDR override               | decided, not yet used | NKP CLI             |
| 8   | Storage container               | **missing**           | this repo           |
| 9   | PC account for NKP              | **missing**           | this repo           |
| 10  | Node OS image in PC             | **missing**           | this repo or manual |
| 11  | Air-gapped bundle               | **missing**           | manual              |
| 12  | Bastion host                    | **missing**           | outside this repo   |
| 13  | DNS record for the cluster      | **missing**           | outside this repo   |
| 14  | Data Services IP (NDK only)     | satisfied             | this repo (hook)    |

The two repo defects that previously blocked items 4 and 9 are **fixed** — see
[Repo defects](#repo-defects-that-block-this-work).

## 0. Prerequisite zero — Prism Element registered to Prism Central

NKP never talks to Prism Element. CAPX (the CAPI infrastructure provider), the Nutanix CSI
driver and the Cloud Controller Manager all authenticate to **Prism Central**; the PE
cluster is named only as a placement target.

Everything else in this document depends on it. This repo resolves `cluster_ext_id` from
`data.nutanix_clusters_v2` — the PC's view of its registered clusters
([`module/data.tf`](../module/data.tf), [`module/locals.tf`](../module/locals.tf)). If the
PE is not registered, that map is empty, and the storage and network landing zones hard-fail
their preconditions regardless of any feature flag.

Registration is Day-2 and repo-owned: `nutanix_pc_registration_v2` in
[`module/landing_zones/prism_element/lz.tf`](../module/landing_zones/prism_element/lz.tf),
fed by `prism_central.registrations."ntnx-pe.bingamon.lab"` in
[`module/config/bingamon/prism_central.yaml`](../module/config/bingamon/prism_central.yaml).
See [ADR 0013](decisions/0013-pe-pc-onboarding-process.md).

**Verify before anything else:** `ntnx-pe.bingamon.lab` appears in Prism Central's cluster
list.

## 1. Platform versions

NKP v2.18 Release Notes, _Prism Central and AOS Version Compatibility_, Table 1, states the
whole matrix in one row:

> pc.7.5 or later 7.5 or later

| Component     | bingamon    | NKP 2.18 requires   | Verdict         |
| ------------- | ----------- | ------------------- | --------------- |
| Prism Central | pc.7.5.1.8  | pc.7.5 or later     | pass            |
| AOS           | 7.5.1.2     | 7.5 or later        | pass            |
| AHV           | 11.0.1.1-33 | _nothing published_ | pass by absence |

**No platform upgrade is required.** Two caveats:

- The floor **tightened** between releases — NKP 2.16 required only pc.2024.2 / AOS 6.10.
  bingamon clears 2.18 by a single minor version, so re-check on every NKP release rather
  than assuming.
- NKP publishes **no AHV version requirement at all**. Compatibility is expressed only
  against AOS and PC.

> The comment at `prism_central.deploy.prism_central.version` in
> [`prism_central.yaml`](../module/config/bingamon/prism_central.yaml) points the operator
> at the **Terraform provider** compatibility matrix. That governs provider↔PC. A second,
> stricter floor now applies (NKP 2.18 ⇒ pc.7.5+/AOS 7.5+) and is recorded nowhere else in
> the repo.

### Not required, contrary to expectation

- **CMSP / Prism Central Microservices Infrastructure.** Zero occurrences across the entire
  v2.18 doc set. The Karbon-era assumption does not carry over.
- **Nutanix Marketplace** is required _only_ for the Marketplace UI deploy path, not the CLI.

## 2. Capacity

Bingamon holds an **Ultimate** licence, so the Ultimate row — not Starter — is what to plan
against.

|                                           | vCPU      | RAM         | Disk               |
| ----------------------------------------- | --------- | ----------- | ------------------ |
| Physical (4× e920: 28 cores, 768 GB each) | 112 cores | 3072 GB     | NVMe, unquantified |
| Committed: PC SMALL + HA (3 PCVMs)        | ~18       | ~78 GB      | ~1500 GiB          |
| NKP management cluster — Starter          | 14        | 40 GiB      | 400 GiB            |
| **NKP management cluster — Ultimate**     | **44**    | **176 GiB** | **560 GiB**        |
| Bastion host                              | 8         | 16 GB       | 80 GB              |

Ultimate layout (NKP 2.18 guide, _Pro/Ultimate … Cluster Minimum Requirements_): 3
control-plane × (4 vCPU, 16 GiB) + 4 workers × (8 vCPU, 32 GiB), each node needing roughly
80 GiB for `/var/lib/kubelet` and `/var/lib/containerd`. That is **7 VMs**, not five.

**RAM is a non-issue** — even at Pro tier this is under 10% of the estate. **Storage is the
only dimension that can bind**, and cluster raw capacity is recorded nowhere in this repo.
Measure it before committing.

> Three figures in that table are estimates, not measurements. The PC SMALL per-VM sizing
> (6 vCPU / 26 GB / 500 GiB, ×3 for HA) is community-sourced — first-party Nutanix material
> publishes only X-Small. CVM vCPU and RAM reservations are unrecorded (`cvm_gb_ram` is null
> in the foundation config, so Foundation's default applies), and cluster raw NVMe capacity
> is unknown. None of this changes the RAM verdict, but vCPU is less comfortable than
> 112 cores suggests once CVMs are counted, and it only clears because AHV oversubscribes.

Two capacity traps:

- **Applying the Ultimate key auto-deploys extra platform applications.** The docs warn that
  it "adds modifications to your environment that can exhaust a small environment's
  resources", and specifically that Ultimate deploys `rook-ceph`, `rook-ceph-cluster` and
  `velero` — with the instruction to disable them "**immediately after applying the Ultimate
  License**" if they are not wanted. It is also a one-way door: "You cannot downgrade a
  license after you register it for a cluster." Size the workers _before_ applying the key.
- **Rook Ceph drives the worker-node floor.** It is deployed by default and wants
  4 × 40 GiB PVs, ~2500m CPU and 8 GiB RAM, and "You need four worker nodes to support the
  upgrades to rook-ceph platform application… If you disable rook-ceph platform application,
  you need only three worker nodes." On Nutanix it runs in **PVC mode** and needs **no extra
  raw disks** on the workers — the host-device instructions in the docs are pre-provisioned-only
  and must not be copied.

For a lab, consider the documented **Small Environment** Kommander configuration, which
disables `rook-ceph`, `rook-ceph-cluster`, `velero`, `kube-prometheus-stack` and the logging
stack outright, removing the Ceph floor entirely.

### Control-plane placement

NKP states no minimum AHV host count and no anti-affinity requirement. On a 4-node RF2
cluster nothing prevents all three control-plane VMs landing on one blade — the difference
between a blade reboot and a lost etcd quorum. This repo already exposes
`compute_databases.vm_anti_affinity_policies`, which is category-driven, and CAPX stamps
categories on node VMs. _Binding the two has not been verified against a Nutanix source —
treat as a lead, not a recipe._

## 3. Licence

**Bingamon holds NKP Ultimate.** Note that a new cluster does not start there: on AHV, NKP
self-assigns a Starter key — "The default key is either a Starter for AHV installations or a
Pro for all other infrastructure providers" — and the Ultimate key is applied afterwards, via
the NKP UI under **Settings > Licensing**, or by `kubectl` if the UI rejects it.

What Ultimate unlocks that Starter does not:

| Capability                                 | Starter | Ultimate |
| ------------------------------------------ | ------- | -------- |
| NKP on Nutanix AHV                         | yes     | yes      |
| Air-gapped deployment                      | yes     | yes      |
| Nutanix-provided Rocky Linux image         | yes     | yes      |
| Nutanix-provided Ubuntu image              | no      | **yes**  |
| Custom images / Nutanix Image Builder      | no      | **yes**  |
| NDK (Nutanix Data Services for Kubernetes) | no      | **yes**  |
| Attached clusters, FluxCD, Projects        | no      | **yes**  |

Three consequences for this document, all of which widen the prep rather than narrow it:

- **Image strategy becomes a real choice** rather than a forced one — see §7.
- **NDK is reachable**, which puts the iSCSI Data Services IP back in scope — see §5.3.
- **The resource floor roughly triples**, and applying the key deploys more apps — see §2.

Licences are sold by worker-node vCPU core count, and the tier cannot be downgraded once
registered.

> The per-tier feature matrix in the source PDF has lost its column alignment in conversion;
> rows carry bare `X` marks that cannot be reliably attributed. The rows above were each
> corroborated by separate prose statements elsewhere in the docs.

## 4. Networking

This is the largest body of work, and the section with the one genuinely irreversible
decision in the whole document.

### 4.1 Pod CIDR — collides with the entire lab

**NKP's default pod network is `192.168.0.0/16`. Every bingamon VLAN (80–85,
`192.168.80.x`–`192.168.85.x`) sits inside it.**

The guide is unambiguous that this cannot be repaired later:

> The Kubernetes pods network and Kubernetes services network must not overlap with each
> other, or with your control plane and worker nodes subnets. After cluster creation, you
> cannot change the pods and services subnets.

and, under _IPAM Configuration Change Limitation_:

> **Warning:** Do not change the IPAM mode, Pod classless inter-domain routing (CIDR), or
> Service CIDR of an existing, running NKP cluster.

The documented remedy is to build a new cluster and migrate workloads.

**Decided:** `--kubernetes-pod-network-cidr=172.20.0.0/16`. The default service CIDR
`10.96.0.0/12` does not collide with anything in the lab and stands as-is.

### 4.2 VLAN 82 needs addressing

VLAN 82 `Kubernetes` exists in
[`prism_element/bingamon.yaml`](../module/config/bingamon/prism_element/bingamon.yaml) as a
name and a tag — no CIDR, gateway, mask or pool.

NKP requires **one** automatic address source, and is explicit that either will do:

> Configure either Nutanix IP address management (IPAM) or dynamic host configuration
> protocol (DHCP) on the subnet to automatically assign IP addresses to control plane nodes
> and worker nodes.

So VLAN 82 does **not** have to become an IPAM-managed subnet. VLAN-only plus a DHCP server
on that VLAN is supported. What is _not_ supported is neither — there is no static-per-node
option anywhere in the Nutanix flag surface.

**Decided: external DHCP, not Nutanix IPAM.** The lab's UDM already serves DHCP, so VLAN 82
stays VLAN-only in
[`prism_element/bingamon.yaml`](../module/config/bingamon/prism_element/bingamon.yaml) and
needs no `ip_config` block.

Two consequences of that choice:

- **The DHCP scope becomes the prerequisite**, and it lives on the UDM, not in this repo.
  Confirm the UDM serves VLAN 82, and note where its scope starts and ends — the VIP and the
  MetalLB range must both sit outside it.
- **The repo's CIDR-overlap validator stays dormant** for this subnet. It only compares
  subnets that declare `ip_config.ipv4.ip_subnet`, so a VLAN-only subnet is invisible to it.
  Nothing will catch a VLAN 82 range that collides with another lab subnet; that check is
  now a human one.

### 4.3 Address plan

Required addresses (NKP guide, _Nutanix Infrastructure Requirements_):

- one per node — **7** for the Ultimate layout of 3 control-plane + 4 workers;
- **one control-plane endpoint VIP**, in-CIDR but **outside** the pool;
- **one ingress address**, taken as the _first_ address of the MetalLB range;
- a **contiguous MetalLB range** for `type: LoadBalancer` services, also outside the pool.

Both the VIP and the LB range carry the same rule, stated identically in two places:

> A static IP that is not part of a dynamic host configuration protocol (DHCP) or IP address
> management (IPAM) pool

**Confirmed against the UDM.** VLAN 82 is trunked to the blades, the subnet and gateway are as
below, and the DHCP scope is set with Auto Default Gateway and Auto DNS Server enabled — so
nodes receive gateway and resolver automatically.

| Purpose           | Value                           | Status                                                  |
| ----------------- | ------------------------------- | ------------------------------------------------------- |
| VLAN 82 CIDR      | `192.168.82.0/24`               | **confirmed** — UDM network "Kubernetes"                |
| Gateway           | `192.168.82.254`                | **confirmed**                                           |
| UDM DHCP scope    | `192.168.82.100–192.168.82.200` | **confirmed** — 101 addresses, node IPs come here       |
| Control-plane VIP | `192.168.82.10`                 | **to reserve** — outside the scope, unused              |
| MetalLB range     | `192.168.82.20–192.168.82.39`   | **to reserve** — outside the scope; `.20` is the NKP UI |

Free space after the above: `.1–.9`, `.11–.19`, `.40–.99`, `.201–.253`. The VIP and the
MetalLB range both sit outside the DHCP scope as NKP requires.

Node addresses are assigned dynamically, so a replaced node gets a new IP. That is fine —
the control-plane VIP and the MetalLB range are the stable endpoints, which is exactly why
they must not come from the pool.

> The NKP guide's own worked example places the MetalLB range _inside_ the pool, contradicting
> its own normative rule. Follow the rule, not the example.
>
> **The lab air gap is a simulation.** VLAN 82 has **Allow Internet Access** enabled on the
> UDM. Air-gapped behaviour must therefore be _forced_ — `--airgapped=true`, an explicit
> registry mirror — never assumed. A build that quietly reaches the internet will succeed in
> the lab and fail in a real enclave, masking the defect until it matters.

### 4.4 Reachability, DNS and NTP

- **PC**: nodes and bastion must reach `https://192.168.83.220:9440`.
- **DNS**: `192.168.85.11` must be reachable and resolve from VLAN 82. NKP requires only
  that "the DNS servers configured on the Prism Central instance are reachable". No reverse
  DNS or node-hostname resolution requirement is documented.
- **NTP is mandatory air-gapped**: "Configure Network Time Protocol (NTP) on NKP clusters to
  synchronize system time is mandatory across all the nodes in an air-gapped environment."
  Supplied via `--ntp-servers`. Note bingamon's configured NTP servers are internet pools
  (`time.cloudflare.com`, `time.google.com`) — an air-gapped cluster needs a reachable
  internal source.
- **A DNS A record** for the cluster hostname pointing at the first MetalLB address
  (e.g. `nkp.bingamon.lab` → `192.168.82.20`). No repo artefact creates DNS records; this is
  manual on whatever serves `192.168.85.11`.
- **VLAN 82 must be trunked** from the MikroTik to the blade uplinks with an L3 gateway.
  The hardware runbook describes the blade uplink as reaching `192.168.85.0/24`; if it is an
  access port, no tagged VLAN reaches the hosts. Verify on the MikroTik — no automation in
  this repo touches it.
- **MTU**: NKP publishes no requirement (zero hits across the doc set). Blades have a single
  1 GbE Intel I210; stay at 1500.

## 5. Storage

### 5.1 Storage container — required, and a hard preflight failure

> Nutanix Storage container must be pre-created in Prism Central.

It is passed as `--csi-storage-container=<name>` and checked before anything is built: "If
you configure Container Storage Interface (CSI), NKP verifies that the storage containers
specified in the configuration exist in Prism Central."

`storage.storage_containers` in the PE YAML is currently `{}`. This is a genuine gap.

The container must live on the PE cluster hosting the nodes. Declaring it in the PE file
pins it automatically via `cluster_ext_id`. Choose a distinct name (`nkp`), leave
`replication_factor` null to inherit the cluster's RF2, and leave erasure coding off.

### 5.2 CSI

NKP installs the Nutanix CSI driver and its default StorageClass itself — do **not**
pre-provision them. v2.18 ships `nutanix-csi-driver` 3.7.1 with default StorageClass
`nutanix-volume`. The driver authenticates to **Prism Central**, not Prism Element.

### 5.3 The iSCSI Data Services IP — needed only for NDK, which Ultimate unlocks

bingamon sets `data_services_ip: 192.168.81.229`, and it is easy to assume this is a hard
CSI prerequisite. **Against the v2.18 docs, it is not.**

The only occurrence of "iSCSI Data Services" in the entire doc set is inside the _Nutanix
Data Services for Kubernetes (NDK) on NKP Prerequisites_ list. The reason base NKP does not
need it is stated plainly:

> Hypervisor attached Volumes: The hypervisor attached Nutanix Volume uses the hypervisor
> internal network for data traffic instead of external iSCSI connections. Enabled by default.

So it is required only if NDK is deployed, or if `--csi-hypervisor-attached-volumes=false`
is set.

**Because bingamon holds Ultimate, NDK is reachable** — it needs a Pro/Ultimate/NKPFS
licence — so this is a live option rather than a closed one. Happily, no action is needed
either way: the value is already set at `192.168.81.229`, is genuinely required for the PC
deploy, and costs nothing to keep.

If NDK _is_ adopted later, its other prerequisites come with it and are not satisfied today:
a PC virtual IP on scale-out PC deployments, `iscsi-initiator-utils` present on the worker
nodes, and CSI 3.3.8 or later.

## 6. Identity

NKP needs a Prism Central username and password — `NUTANIX_USER` and `NUTANIX_PASSWORD`.
Username/password only; no API key, certificate or token auth is documented.

One credential is consumed by three components, and lands in seven Kubernetes secrets — plan
rotation around all of them:

- **CAPX** — listing subnets, creating node VMs;
- **CSI** — persistent volume provisioning;
- **CCM** — node metadata discovery.

`identity_access` on the PC plane is entirely `{}` today, so the account itself still has to
be declared — but the repo can now express all of it. `tf-ntnx-iam` v0.2.2 already supported
`user_passwords` and `authorization_policies`; the landing zone simply never passed them
through. That wiring is now in place (see [Repo defects](#repo-defects-that-block-this-work)),
so creating the NKP account is ordinary config work:

- `identity_access.users.nkp-admin` — the user, `user_type: LOCAL`;
- `identity_access.authorization_policies.<key>` — the role binding, without which the user
  has no permissions at all;
- the password as a SOPS leaf at `identity_access.users.nkp-admin.password` in
  `prism_central.sops.json`. It is deliberately SOPS-only — the JSON schema forbids a
  `password` key on a user, so a plaintext password in `prism_central.yaml` is a mistake
  rather than a supported fallback.

**Required PC role.** The docs enumerate a minimum permission set: AHV VM (create, delete,
power on, view, update custom attributes); Category (create, delete, delete value, view);
Cluster (view, view PGPU/VGPU profiles); Host (view); Image (create, delete, view); Domain
Manager (view); Project (view); Subnet (view); Volume Group (detach from AHV VM); VPC (view).
Plus: "**You must apply the required CSI permissions**" — and that table is _not_ in the
public doc set. It sits behind the login-gated CSI Volume Driver Guide.

Either a local PC user or a directory user works. If the authorisation policy is scoped
rather than granted Full Access, Domain Manager, Cluster and Category must each still be set
to **All**.

> Note the shape mismatch when writing the policy: `authorization_policies.<key>.role` takes
> a role **ext_id (UUID)**, and `identities`/`entities` take provider filter-expression
> strings, not friendly names. A least-privilege custom role likewise takes operation
> ext_ids, so it needs a `data.nutanix_operations_v2` lookup to resolve names to UUIDs.
> Binding the built-in **Prism Central Admin** role avoids that entirely and is the pragmatic
> first move.

**Prism Central is not an identity provider for NKP.** The NKP UI uses its own Dex broker
with static break-glass admin credentials. Air-gapped, LDAP is effectively the only viable
external IdP — the GitHub/Google/Microsoft connectors all need internet.

## 7. Node OS image

**Nutanix publishes prebuilt AHV images, so image building is not required:**

> Nutanix provides pre-built OS images with the tools and configurations required for NKP
> Kubernetes cluster deployment… eliminate the need to build custom images.

**Ultimate makes this a genuine choice**, since custom images and Nutanix Image Builder are
unlocked, as is Ubuntu. **This decision is still open** — the two paths differ sharply in
air-gapped cost (see [Still open](#still-open)):

|                   | Prebuilt (Rocky or Ubuntu)  | Custom via NIB                                                                                         |
| ----------------- | --------------------------- | ------------------------------------------------------------------------------------------------------ |
| Air-gapped effort | download → import to PC     | package bundle built on an internet-connected host, carried in, plus a base image in PC and a build VM |
| CIS hardening     | included                    | not supported                                                                                          |
| FIPS              | not supported               | RHEL 8.10 / 9.6 only                                                                                   |
| Per-upgrade cost  | download the matching image | rebuild the whole chain                                                                                |

For a first build the prebuilt path is markedly cheaper; NIB earns its keep only if custom
packages or FIPS are actually needed.

Prebuilt prep is: download from the Nutanix Support Portal → carry in → import to Prism
Central → pass the name to `--control-plane-vm-image` / `--worker-vm-image`.

Two rules that bite either way:

1. **Do not rename the image.** A preflight check parses the Kubernetes version out of the
   image _name_: "Verifies that the Kubernetes cluster version is part of the VM image name."
2. **The image is tied to the Kubernetes version** — a new image is needed per NKP/K8s
   upgrade.

> **Verify at run time:** the support matrix lists Rocky Linux **9.7** while the prebuilt
> variants and every worked example say Rocky **9.6**. Check `nkp create image nutanix --help`
> against the real binary.

The image can be declared in this repo via `compute_databases.images` **if** it is reachable
over HTTP(S) from Prism Central — and Caddy can legitimately serve the qcow2 for that, even
though it can never serve as the container registry.

## 8. Air-gap and the container registry

This was the central open question: **does the offline bundle mean NKP brings its own
registry?**

**On Nutanix/AHV, yes — an external registry such as Harbor is not required.**

NKP defines two mutually exclusive air-gapped registry methods:

> **Local Registry Mirror**: … populated by pulling images from public registries and storing
> them locally.
>
> **Internal Registry Mirror**: An internal registry mirror is a container image repository
> **hosted on an NKP cluster managed by NKP**. The internal registry mirror is populated using
> an air-gapped bundle…

The internal mirror is the **default when you supply neither**: "If you do not provide details
for either field, the system deploys an internal registry mirror to complete the cluster
deployment." The deployed registry is the **Nutanix Container Registry (NCR)**, Harbor-based.

The mechanism is a cluster-create flag, not an image-build step. `BUNDLE_FLAGS` is defined as
`--bundle …/kommander-image-bundle-<ver>.tar,…/konvoy-image-bundle-<ver>.tar` and interpolated
directly into the `nkp create cluster nutanix` invocation, with:

> **Important:** Do not use both BUNDLE_FLAG and REGISTRY_MIRROR_FLAG simultaneously.

That the CLI reads those tarballs from bastion disk _at deploy time_ is corroborated by the
extraction warning: omit `tar -xzvp`'s `-p` flag and "the deployment hangs at the **Waiting for
bundles to be pushed to internal registry** step with a permission denied error."

Correspondingly, the _Preparing a Local Registry Mirror_ and _Pushing Images to the Registry_
procedures both open with: "This procedure is required for an air-gapped environment **that does
not use an internal registry mirror**."

### Caveats

- **This is Nutanix-only.** No other provider has a `--bundle` flag on cluster create; they all
  seed an external registry with `nkp push bundle --to-registry`.
- **Stale text elsewhere in the same docs contradicts this** — the general requirements page
  still says "Ensure that you have an existing local container registry to seed the air-gapped
  environment." That is legacy provider-generic text; the Nutanix chapter and the 2.18 concept
  pages supersede it. Corroborated by: "This procedure is optional and not mandatory for clusters
  created from NKP 2.16 onwards."
- **NCR is HTTPS with a self-signed certificate** by default. Fine for the management cluster;
  any future workload cluster must be configured to trust it.
- **The docs never explicitly bless "prebuilt image + `--bundle`" in one sentence.** They present
  the two as independent, freely-composable steps. The reasoning is structural and strong, but
  worth an early smoke test rather than discovering it late.

### Caddy is not reusable

The existing LCM darksite server and an NKP registry are **unrelated mechanisms**. Every NKP
artefact transport is an OCI registry push, a local `docker load`, a bundle baked into an image,
or a tarball passed by path. A plain HTTP file server serves none of those roles — with the one
exception noted in §7, hosting the node qcow2 for image import.

### Artefacts

- `nkp-air-gapped-bundle_<version>_linux_amd64.tar.gz` from the Nutanix Support Portal
  (account required). Extract **with `-p`**.
- The node OS image — prebuilt Rocky or Ubuntu, or a NIB-built one (§7).
- No file sizes are stated anywhere in the doc set.
- The bundle does **not** contain distro OS packages — only NKP Kubernetes packages, Python
  packages and a containerd tarball. Under Ultimate this matters: choosing the NIB path means
  separately running `nkp create package-bundle` on an internet-connected host and carrying
  those artefacts in too.

## 9. The bastion host

An easily-missed prerequisite: `nkp create cluster` does not run from nowhere. It runs on a
Linux host that builds a **KIND bootstrap cluster in a local container runtime**, pivots CAPI
resources into the new cluster, then deletes itself.

- Docker 27.4.0 **or** Podman 4.0+; `kubectl` 1.35.x; x86_64 Linux or macOS, cgroups v2.
- Sized at 8 vCPU / 16 GB / 80 GB, with ≥ 2 CPU and 4 GB free for the bootstrap cluster.
- Must reach Prism Central on 9440 **and** the node subnet, and hold the air-gapped bundle.
- `nkp push bundle` needs scratch space in `TMPDIR`.

This VM is not modelled anywhere in this repo. It could be declared under
`compute_databases.virtual_machines`, but that is a scope decision, not a given.

## Repo changes required

| #   | File                          | Key path                                                                                                      | Landing zone → module              |
| --- | ----------------------------- | ------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| 1   | `prism_element/bingamon.yaml` | `network_topology.subnets.kubernetes` — keep VLAN-only; confirm the VLAN tag                                  | `network_topology` → `tf-ntnx-net` |
| 2   | `prism_element/bingamon.yaml` | `storage.storage_containers.nkp`                                                                              | `storage` → `tf-ntnx-storage`      |
| 3   | `prism_central.yaml`          | `identity_access.users.nkp-admin`                                                                             | `identity_access` → `tf-ntnx-iam`  |
| 4   | `prism_central.yaml`          | `identity_access.authorization_policies.<key>` — the role binding                                             | `identity_access` → `tf-ntnx-iam`  |
| 5   | `prism_central.sops.json`     | `identity_access.users.nkp-admin.password`                                                                    | `identity_access` → `tf-ntnx-iam`  |
| 6   | `prism_central.yaml`          | `compute_databases.images.<nkp-image>`                                                                        | `compute_databases` → `tf-ntnx-vm` |
| 7   | `module/terraform.tfvars`     | `lz_enable_network_topology`, `lz_enable_storage`, `lz_enable_identity_access`, `lz_enable_compute_databases` | —                                  |
| 8   | `secretspec.toml`             | NKP PC credential under `[profiles.bingamon]`                                                                 | —                                  |

Choosing external DHCP removes what would otherwise have been the largest config change: no
`ip_config.ipv4` or `dhcp_options` block is needed on the Kubernetes subnet, since address
assignment, DNS and NTP for the nodes all come from the UDM scope instead.

Everything Day-2 is currently gated off except `lz_enable_prism_element`. Per
[ADR 0009](decisions/0009-feature-gating-model.md) these `lz_enable_*` flags are
developer-owned tfvars, distinct from the YAML per-service `enabled` gates.

Also worth doing in the same change: there is no worked example of a populated storage
container or an authorization policy anywhere in the repo — `module/config/example/` shows
these maps as `{}`, and the only valid test fixture leaves them empty.

## Repo defects that block this work

Two latent defects were found while writing this document. Neither had ever surfaced,
because the owning landing zones are switched off. **Both are now fixed.**

### 1. Subnets use `vlan_id`; the module only accepted `network_id` — fixed

`tf-ntnx-net` had **no `vlan_id` input**. Its `var.subnets` declared
`network_id = optional(number, null)` and validated "VLAN subnets require a 'network_id'".
All four PE subnets in
[`prism_element/bingamon.yaml`](../module/config/bingamon/prism_element/bingamon.yaml) use
`vlan_id`, and
[`network_topology/locals.tf`](../module/landing_zones/network_topology/locals.tf) passes
`subnet_config` through untouched, adding only `cluster_reference`. Nothing translated the
key, so **every VLAN subnet would have failed module validation** — including the one NKP
needs. The JSON schema permits both spellings, so it did not catch this either.

**Fixed in `tf-ntnx-net`** (branch `fix/vlan_id`) by accepting `vlan_id` as a first-class
alias: both spellings resolve to the provider's `network_id`, disagreeing values are
rejected rather than silently resolved, and existing `network_id` callers are unaffected —
a backwards-compatible minor bump. Covered by four new module tests.

Released as **v0.2.3** and pinned in
[`network_topology/lz.tf`](../module/landing_zones/network_topology/lz.tf). The bingamon PE
YAML therefore works as written, with `vlan_id` on all four subnets.

### 2. `identity_access` could not set a user password or a role binding — fixed

A local PC user needs a password, and CAPX authenticates with basic auth. The gap was **not**
in `tf-ntnx-iam` — v0.2.2 already had `user_passwords`, `authorization_policies`, `user_keys`
and `roles`, and already split secrets out of the main `users` map for exactly this reason.
The landing zone simply never passed them through, and the JSON schema had no way to express
a role binding. **No module change or release was needed.**

**Fixed in this repo:**

- `module/locals.tf` builds `identity_access_user_passwords` from SOPS, keyed by user key,
  mirroring the existing `prism_central_registrations` pattern;
- the identity-access landing zone takes a sensitive `user_passwords` variable and forwards
  it, alongside `authorization_policies`, to `tf-ntnx-iam`;
- `module/schemas/prism_central.schema.json` gains an `authorization_policy` definition and
  an `identity_access.authorization_policies` property.

Passwords are kept out of the merged config object deliberately: folding them in would taint
every non-secret user attribute as sensitive and make plan output unreadable — the same split
`tf-ntnx-iam` makes internally.

## Decisions

### Settled

The full architectural decision register lives in [Design](design.md#decision-register). The
subset that bears on the Nutanix prerequisites:

| Decision            | Outcome                                                                                                                                                                                              |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Licence tier        | **Ultimate**                                                                                                                                                                                         |
| Architecture        | **Pure OpenTofu Renderer + `lz-cli` Python Hook** on an ephemeral bastion                                                                                                                            |
| Environment Profile | ⚠️ **See correction below** — the flags this rests on are undocumented                                                                                                                               |
| Node addressing     | **External DHCP** (UDM), not Nutanix IPAM                                                                                                                                                            |
| Pod CIDR            | **`172.20.0.0/16`** — validated by regex; irreversible after cluster creation                                                                                                                        |
| Service CIDR        | Default `10.96.0.0/12` — no collision                                                                                                                                                                |
| Registry            | ⚠️ **Superseded** — NCR via `--bundle` seeds NKP's own images only; the fleet additionally runs **Harbor** on the management cluster for catalogue artefacts, charts and mirrored third-party images |
| Per-cluster cache   | `addons.registry`, `provider: CNCF Distribution` — enabled                                                                                                                                           |
| Node OS             | ⚠️ **Superseded 2026-07-29** — **Ubuntu 24.04**, not Rocky. Rocky has no NVIDIA GPU support in the NKP matrix. No FIPS: the matrix shows FIPS only on RHEL 8.10/9.6                                  |
| Node images         | ⚠️ **Superseded** — **vendor appliances** from the Nutanix Portal, not NIB-built, for the first few months. Air-gapped GPU is supported only with precompiled drivers, i.e. the portal `-gpu-` build |
| Bastion             | ⚠️ **Superseded** — **not NixOS, and not RHEL.** An ephemeral VM from a release-versioned **Ubuntu 24.04** image built by `nkp-images` with Packer, created on demand and destroyed after use        |
| Service LB          | MetalLB on management; workload clusters may use F5 CIS                                                                                                                                              |

### Corrections — 2026-07-28 architecture review

Verified against the NKP v2.18 documentation set. See the `lz-paas` decision log
(ADRs 0018–0021) and `lz-paas` → `docs/architecture/nkp_remediation.md` for the full set.

- **Kubernetes version.** NKP v2.18 ships Kubernetes **1.35.2** and supports 1.35.x / 1.34.x.
  Any `1.31.x` reference in this estate is wrong. The single version contract now lives in
  `nkp-images`; no other repository pins it.
- **`profile = "small"` rests on flags that do not exist.** `--app-options` and
  `--disable-apps` have **zero occurrences** across the v2.18 documentation set. The
  documented way to slim Kommander is the **Small Environment installer configuration**, not
  CLI flags. The profile mechanism needs rebuilding on that.
- **The fleet OS is Ubuntu 24.04 (2026-07-29).** Rocky shows `-` in the GPU, GPU-air-gapped
  and vGPU columns of the NKP support matrix, so it cannot host NVIDIA workloads at all. Node
  images now come from the Nutanix Portal as vendor appliances; `nkp-images` builds only the
  bastion/runner image. Note the matrix does **not** support the wider claim that RHEL cannot
  do GPU — RHEL 8.10/9.6 carry GPU, vGPU and FIPS — but Ubuntu is the accepted decision.
  Consequence: **no FIPS on Ubuntu** per the matrix, and **NKP does not support AMD GPUs** at
  all, so any ROCm plan is void.
- **Bastion is Ubuntu 24.04, not NixOS and not RHEL.** It shares the node images' OS family,
  and carries the same `nkp` CLI and bundles as the release that pins the node image — so
  bootstrap and node content stay in step even though the node images are no longer built here.
  It serves a second role as the bootstrap CI runner; see
  [`lz-paas` ADR 0021](https://github.com/bingamon-lab/lz-paas/blob/trunk/docs/decisions/0021-ephemeral-bastion-vm.md)
  as amended — one image, two lifecycles.
  Note the naming collision: NIB's own `--bastion-host` / `--bastion-username` /
  `--bastion-private-key-file` flags refer to a _different_ host used during air-gapped image
  builds.
- **`--source-image` is optional in the CLI but mandatory in practice air-gapped** — "if the
  image name is not provided then upstream base image for the OS will be downloaded", and there
  is no upstream inside the enclave. It applies to the bastion build; node images no longer use
  NIB.
- **Prism Central credentials must not be one account bound to Prism Central Admin.** CSI and
  CCM run on workload clusters, so that credential would sit within reach of any tenant with
  secret-read in a platform namespace, granting estate-wide VM and image deletion. Split into
  `nkp-capx` (management cluster only), `nkp-csi` and `nkp-ccm`.
- **Dangling references.** This document cites a `design.md` and a local
  `decisions/0003-*.md`; neither exists in this repository. The decision log is in `lz-paas`.

### Still open

1. **Is NDK in scope?** Ultimate makes it available. If adopted, its own prerequisites apply
   (§5.3).

## Open questions

- **CSI permission set** — not in the public docs; behind the login-gated CSI Volume Driver
  Guide. Needed for a least-privilege role.
- **Cluster raw storage capacity** — unrecorded anywhere in this repo; the only dimension
  that could actually bind.
- **Air-gapped bundle size** — not stated in any Nutanix source. Affects sneakernet planning.
- **Rocky 9.6 vs 9.7** — the docs disagree with themselves.
- **Reverse path from VLAN 82.** Trunking and DHCP are confirmed, but the node subnet still
  needs verified reachability to Prism Central on `192.168.83.220:9440` and to DNS on
  `192.168.85.11`. Inter-VLAN routing on the UDM is the thing to check.
- **Does PC present a self-signed certificate?** Determines `--additional-trust-bundle` vs
  `--insecure`. Note the repo's provider currently defaults to `insecure = true`.

## Teardown warning

NKP node VMs and CSI volumes are invisible to Terraform. Nutanix CSI persistent volumes are
`pvc-*` volume groups — the same shape that already required
[`tasks/nutanix_pc_teardown_hook.py`](../tasks/nutanix_pc_teardown_hook.py) to detach volume
groups before deleting PC VMs, because `acli vm.delete` refuses and still exits 0.

**Do not destroy the Day-2 landing-zone state while an NKP cluster is live.** The blast radius
has not been analysed.

## ADR 0003 disposition

[ADR 0003](decisions/0003-nkp-parked.md) parked NKP because the `nutanix/nutanix` provider has
no NKP resources. **That premise still holds** — `terraform` appears zero times across all 14
NKP v2.18 documents. NKP is a CLI-driven product with no Terraform surface.

What has changed is the decision, not the fact: a management-server module is now being built
in `tf-ntnx-nkp`, which is the CLI-wrapper path ADR 0003 declined. That work should land its
own ADR superseding 0003 — this document is the prerequisite analysis it builds on, not the
decision record.

Note that `tf-ntnx-nkp` v0.2.2 is still a zero-resource placeholder whose `clusters` /
`node_pools` / `registries` variables describe `nutanix_nkp_*` resources that do not exist.
That interface will not survive contact with an `nkp`-CLI-driven deploy: the real input surface
is the one in this document — PC endpoint and credential, PE cluster name, subnet name, storage
container name, image name, VIP, LB range, pod CIDR, and bundle paths.

## References

Official NKP v2.18 documentation, pulled into the `tf-ntnx-nkp` repository under
`docs/nutanix/`. Cited by document and section heading throughout, because the converted files
are re-generated and their line numbering is not stable.

| Document                                    | Used for                                                      |
| ------------------------------------------- | ------------------------------------------------------------- |
| `01-release-notes.md`                       | PC/AOS compatibility, component versions, ports, known issues |
| `02-overview.md`                            | Supported operating systems, architecture                     |
| `03-downloading-and-getting-started.md`     | Bundles, licences, cluster types, storage defaults            |
| `04-requirements.md`                        | Operator host, Konvoy and Kommander requirements              |
| `05-image-builder.md`                       | Prebuilt and custom images                                    |
| `07-cluster-operations.md`                  | Rook Ceph, CNI, MetalLB, Velero, identity, Pulse              |
| `08-custom-installation-and-tools.md`       | The Nutanix install path, air-gap, sizing, PC roles           |
| `09-kommander-and-konvoy-configurations.md` | Registry seeding, Small Environment, FIPS                     |
| `10-upgrade-guide.md`                       | Image/Kubernetes version coupling                             |

Related repo documents: [Specification](architecture/spec.md),
[Configuration](architecture/configuration.md),
[Landing Zones](architecture/landing_zones.md),
[Prism Element](architecture/prism_element.md), [Decisions](decisions/README.md).
