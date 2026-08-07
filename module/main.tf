##################################################
# tf-ntnx-nkp — validation anchor
#
# This module renders an execution contract for the `nkp` CLI and NOTHING else.
# There is no VM, no cluster and no provisioner here: `nkp create cluster` is a
# 30-45 minute imperative command with no values file, no idempotency and no
# state tracking, so wrapping it in a provisioner would put secrets in state,
# hold the state lock for the duration, and create destroy hazards
# (lz-paas ADR 0018). An lz-cli hook executes the contract over SSH.
#
# terraform_data is a built-in null-style resource on OpenTofu >= 1.9. It takes
# no input and exists purely to host the precondition below, evaluated at plan.
##################################################

resource "terraform_data" "validation" {

  lifecycle {

    # ONE aggregate precondition rather than one per category, so a plan reports
    # every problem at once instead of making the operator re-plan per typo.
    # The categories are computed separately in locals.tf:
    #
    #   1. static IP/CIDR math       lb_range_errors, cidr_overlap_errors,
    #                                vip_cidr_errors
    #   2. version contract          version_errors
    #   3. air-gap invariants        airgap_errors
    #   4. Nutanix object existence  existence_errors  (needs credentials;
    #                                gated by var.enable_data_lookups)
    #
    # var.enforce_validation is a TEST SEAM and defaults to true; see its
    # description in variables.tf. Tests set it false so they can assert which
    # error was raised, because a failed precondition makes every output
    # unreadable.
    precondition {
      condition     = !var.enforce_validation || length(local.validation_errors) == 0
      error_message = "NKP cluster '${var.cluster_name}' has ${length(local.validation_errors)} configuration error(s):\n  - ${join("\n  - ", local.validation_errors)}"
    }
  }
}
