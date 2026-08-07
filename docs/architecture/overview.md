# NKP Infrastructure Architecture — tf-ntnx-nkp

High-level overview of the `tf-ntnx-nkp` OpenTofu module, its scope, responsibilities, and integration within the broader Nutanix Kubernetes Platform (NKP) estate architecture.

**Target Environment:** NKP v2.18 · Ultimate Licence · Air-Gapped · Nutanix AHV
**Persona:** Infrastructure Engineering
**Scope:** Landing zone prerequisite resolution and validation, NKP CLI bootstrap/upgrade script rendering, and Bastion host `cloud-init` configuration generation.

---

## Executive Summary

The `tf-ntnx-nkp` repository is an Infrastructure-as-Code (IaC) OpenTofu child module. Its sole responsibility is **resolving and validating Nutanix landing zone prerequisites and rendering versioned CLI bootstrap/upgrade scripts and Bastion configurations for the NKP Management Cluster**.

Any ongoing declarative management _inside_ the NKP Management Cluster (such as managing workload clusters, platform applications, and fleet-wide GitOps configurations) is **out of scope** for this repository and belongs to [`nkp-platform`](../../../../nkp-platform). Building Kubernetes node OS images is owned by [`nkp-images`](../../../../nkp-images).

---

## Core Constraints & Architectural Principles

### 1. NKP Has No Native Terraform Provider Surface

A thorough audit of `nutanix/terraform-provider-nutanix` confirms **zero** resources or data sources for NKP, Konvoy, Kommander, or CAPX. Legacy `nutanix_karbon_*` resources apply only to deprecated NKE and have been frozen since January 2025.

Consequently, the **`nkp` CLI binary is the only mechanism** to create and upgrade NKP clusters on Nutanix AHV.

### 2. Terraform Renders; Hook Executes

Because `nkp create cluster nutanix` is a 30–45 minute imperative command with no declarative `values.yaml` file and no native idempotency or state tracking, wrapping it inside a Terraform `null_resource` or `local-exec` creates destroy hazards, state-locking issues, and secret exposure in state.

Instead:

- **`tf-ntnx-nkp`** resolves Nutanix prerequisites (subnets, Prism Element clusters, storage containers, VIPs), validates them, and renders deterministic script outputs (`bootstrap_script`, `upgrade_script`, `bastion_cloud_init`). Zero VM provisioning or state-bound execution occurs in OpenTofu.
- **`lz-cli` hook** (`tasks/nkp_*.py`) connects to the air-gapped Bastion VM over SSH, executes the rendered script outside the OpenTofu state lifecycle, streams execution logs, and retrieves the generated `kubeconfig`.
- **SOPS Encryption**: Kubeconfig is fetched from the Bastion host post-bootstrap by the `lz-cli` hook and saved SOPS-encrypted directly into Git (`nkp-platform` / secret store), completely avoiding secret leakage in OpenTofu state.

### 3. The Bastion is Cattle (Break-Glass NixOS Host)

The Bastion host runs in the air-gapped subnet to execute cluster operations:

- **Stateless NixOS Image**: Built outside this repository as a NixOS `qcow2` image and provisioned on Nutanix AHV by the parent landing zone (`lz-paas`).
- **Break-Glass Usage**: The Bastion is used strictly for bootstrapping, upgrading, and break-glass administrative operations.
- **Air-gapped bundle**: Local tarball bundles (`kommander-image-bundle-*.tar`, `konvoy-image-bundle-*.tar`) are staged on Bastion disk or fetched on demand.
- **`nkp` CLI binary**: Unpacked from the bundle at runtime.
- **Host Customisation**: Rendered via `bastion_cloud_init` output from OpenTofu (including internal CA trust bundles).

### 4. Configurable Environment Profiles

- **`var.profile` (`"small"` vs `"full"`, default `"small"`)**: Toggles resource sizing and platform application footprints.
  - `"small"`: Optimized for lab environments (3 worker nodes, minimal platform app footprint, omitting heavy Rook Ceph storage floors).
  - `"full"`: Sized for production Ultimate layout (4 worker nodes, full platform app suite).

---

## Repositories & Boundaries

| Repository                      | Persona              | Responsibilities & Scope                                                                                                      |
| :------------------------------ | :------------------- | :---------------------------------------------------------------------------------------------------------------------------- |
| **`tf-ntnx-nkp`** _(this repo)_ | Infrastructure       | Landing zone prerequisite validation, NKP CLI bootstrap/upgrade script rendering, Bastion `cloud-init` user-data rendering.   |
| **`nkp-platform`**              | Platform Engineering | Fleet GitOps repository (Flux + Kustomize), `NKPCluster` CAPI definitions, workload clusters, SOE applications, Dex identity. |
| **`nkp-images`**                | Platform Engineering | Image Builder (NIB) pipelines building CPU and GPU node OS images via GitHub Actions for Nutanix.                             |

### The Handoff Seam

The handoff between Infrastructure (`tf-ntnx-nkp`) and Platform Engineering (`nkp-platform`) is a single event: **the moment the NKP Management Cluster's GitOps source (Flux) is pointed at `nkp-platform`.** Before this handoff: Terraform rendering and `lz-cli` hook execution. After this handoff: GitOps and Flux.

---

## Document Map

- **[Spec](spec.md)** — Detailed specification for AI agents and engineers building and modifying this module.
- **[Landing Zone](landing_zone.md)** — Comprehensive Nutanix infrastructure prerequisites, address plans, capacity, storage, and readiness matrix.
