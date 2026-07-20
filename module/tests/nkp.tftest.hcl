provider "nutanix" {
  username     = "dummy"
  password     = "dummy"
  endpoint     = "dummy.local"
  port         = 9440
  insecure     = true
  wait_timeout = 1
}

run "nkp_summary_valid" {
  command = plan

  variables {
    clusters   = {}
    node_pools = {}
    registries = {}
  }

  assert {
    condition     = output.outputs.nkp_summary.status == "PENDING_PROVIDER_SUPPORT"
    error_message = "Expected nkp_summary status to be PENDING_PROVIDER_SUPPORT"
  }
}
