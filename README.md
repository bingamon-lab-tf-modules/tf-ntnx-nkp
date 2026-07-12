# tf-ntnx-nkp

## Overview

Terraform module for the Nutanix Kubernetes Platform (NKP).

**NKP: no provider support — parked (decision 551).**

The `nutanix/nutanix` provider ships zero `nkp_*` resources or data sources
through 2.4.3-beta1. Verified against 2.4.2 (129 resources / 184 data sources):
the only Kubernetes surface is legacy Karbon/NKE (`nutanix_karbon_*`), which the
`tf-ntnx-karbon` module already owns. This module therefore creates nothing
today: it declares typed `clusters`, `node_pools` and `registries` variables
guarded by `check` blocks that force those maps to stay empty, and emits a single
`nkp_summary` output whose `status` is `PENDING_PROVIDER_SUPPORT`.

## Decision (551): park until provider support

- **Option chosen: C — park.** Keep the typed placeholder exactly as-is (the
  empty-forcing `check` blocks plus the `PENDING_PROVIDER_SUPPORT` summary) until
  the provider ships real `nkp_*` resources.
- **Rationale:** Option A (wrap the `nkp` CLI or Cluster API via
  `null_resource`/`external`) and Option B (a separate non-terraform pipeline)
  both add an imperative surface that cannot be mock-tested, and so violate the
  platform's declarative, `mock_provider`-tested module standard — for no
  operational demand, since no NKP cluster is planned before provider support
  lands. Parking is cheaply reversible (C to A/B later is trivial), whereas a
  `null_resource` wrapper would make A to anything a state-surgery exercise.
- **Fallback:** escalate to Option B (a non-terraform pipeline) if concrete NKP
  demand materialises before the provider ships resources.
- **Revisit trigger:** re-evaluate this decision on every `nutanix/nutanix`
  provider minor release — dump the provider schema, check for `nkp_*` resources
  and data sources, and adopt them here if/when they ship.

## Usage

There is no supported usage yet — see `examples/example.tf`. Defining any NKP
cluster, node pool or registry today fails the module's `check` blocks by design.

The [Terraform Module](module/README.md) documentation contains the available
variables and outputs.
