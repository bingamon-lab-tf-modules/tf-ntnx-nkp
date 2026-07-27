# NKP Infrastructure Architecture — tf-ntnx-nkp

High-level overview of the `tf-ntnx-nkp` OpenTofu module, its scope, responsibilities, and integration within the broader Nutanix Kubernetes Platform (NKP) estate architecture.

**Target Environment:** NKP v2.18 · Ultimate Licence · Air-Gapped · Nutanix AHV  
**Persona:** Infrastructure Engineering  
**Scope:** Landing zone validation, Bastion VM customisation, and Day 1 / Day 2 management cluster bootstrapping via CLI hook.

---

## Executive Summary

The `tf-ntnx-nkp` repository is an Infrastructure-as-Code (IaC) OpenTofu child module. Its sole responsibility is **Day 1 bootstrapping and Day 2 upgrades of the NKP Bastion and Management Cluster**, enforcing Nutanix landing zone prerequisites.

Any ongoing declarative management *inside* the NKP Management Cluster (such as managing workload clusters, platform applications, and fleet-wide GitOps configurations) is **out of scope** for this repository and belongs to [`nkp-platform`](../../../../nkp-platform). Building Kubernetes node OS images is owned by [`nkp-images`](../../../../nkp-images).

---

## Core Constraints & Architectural Principles

### 1. NKP Has No Native Terraform Provider Surface
A thorough audit of `nutanix/terraform-provider-nutanix` confirms **zero** resources or data sources for NKP, Konvoy, Kommander, or CAPX. Legacy `nutanix_karbon_*` resources apply only to deprecated NKE and have been frozen since January 2025. 

Consequently, the **`nkp` CLI binary is the only mechanism** to create and upgrade NKP clusters on Nutanix AHV.

### 2. Terraform Renders; Hook Executes
Because `nkp create cluster nutanix` is a 30–45 minute imperative command with no declarative `values.yaml` file and no native idempotency or state tracking, wrapping it inside a Terraform `null_resource` or `local-exec` creates destroy hazards, state-locking issues, and secret exposure in state.

Instead:
* **`tf-ntnx-nkp`** resolves Nutanix prerequisites (subnets, Prism Element clusters, storage containers, VIPs), validates them, and renders a fully qualified, versioned CLI invocation script.
* **`lz-cli` hook** (`tasks/nkp_*.py`) executes the rendered script on the air-gapped Bastion VM outside the Terraform state lifecycle.

### 3. The Bastion is Cattle
The Bastion VM runs in the air-gapped subnet to execute cluster operations. To ensure zero configuration drift:
* **Air-gapped bundle (~15 GB)** lives on an internal HTTP server (Caddy) and is fetched on demand.
* **`nkp` CLI binary** is unpacked from the bundle at runtime.
* **CA Trust & Host Customisation** are rendered via `cloud-init` from OpenTofu.
* **Kubeconfig** is stored SOPS-encrypted in Git.

---

## Repositories & Boundaries

| Repository | Persona | Responsibilities & Scope |
| :--- | :--- | :--- |
| **`tf-ntnx-nkp`** *(this repo)* | Infrastructure | Bastion VM, landing zone prerequisite validation, NKP CLI bootstrap/upgrade script rendering. |
| **`nkp-platform`** | Platform Engineering | Fleet GitOps repository (Flux + Kustomize), `NKPCluster` CAPI definitions, workload clusters, SOE applications, Dex identity. |
| **`nkp-images`** | Platform Engineering | Image Builder (NIB) pipelines building CPU and GPU node OS images via GitHub Actions for Nutanix. |

### The Handoff Seam
The handoff between Infrastructure (`tf-ntnx-nkp`) and Platform Engineering (`nkp-platform`) is a single event: **the moment the NKP Management Cluster's GitOps source (Flux) is pointed at `nkp-platform`.** Before this handoff: Terraform and the hook. After this handoff: GitOps and Flux.

---

## Document Map

* **[Spec](spec.md)** — Detailed specification for AI agents and engineers building and modifying this module.
* **[Landing Zone](landing_zone.md)** — Comprehensive Nutanix infrastructure prerequisites, address plans, capacity, storage, and readiness matrix.
