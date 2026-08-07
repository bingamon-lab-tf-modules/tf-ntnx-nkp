# tf-ntnx-nkp

OpenTofu module that **validates** the Nutanix prerequisites for a Nutanix Kubernetes
Platform (NKP) management cluster and **renders an execution contract** for the `nkp` CLI.

It provisions nothing and executes nothing.

## Why it works this way

NKP is a CLI-driven product with no Terraform surface: the `nutanix/nutanix` provider ships
no `nkp_*` resources, and `terraform` appears nowhere in the NKP 2.18 documentation set.

`nkp create cluster` is a 30–45 minute imperative command with no values file, no idempotency
and no state tracking. Wrapping that in a `null_resource` or `local-exec` provisioner would
put credentials in state, hold the state lock for the whole run, and leave destroy-time
provisioners that break as soon as the bastion is gone.

So the work is split. This module computes and checks; an `lz-cli` hook executes over SSH,
outside the state lifecycle. See lz-paas ADR 0018.

## Scope

**Supported:** one **self-managed management cluster**, on **Nutanix**, **air-gapped**.

**Not supported.** vSphere, AWS, Azure, GCP, EKS, AKS, GKE and pre-provisioned infrastructure
are out of scope and backlogged — `nkp` supports them, this module deliberately does not. The
AWS/GCP flags that appear in `nkp create cluster nutanix --help` come from NKP's shared global
flag set and are refused here.

**Workload clusters are also out of scope.** They are created through GitOps/Kommander on the
management cluster this module bootstraps. Modelling them in Terraform would mean owning
resources OpenTofu cannot see or reconcile.

## Usage

One module instance per management cluster; callers with several use `for_each`.

```hcl
module "nkp" {
  source = "github.com/bingamon-lab-tf-modules/tf-ntnx-nkp//module?ref=v1.0.0"

  cluster_name = "nkp-mgmt"

  # A plain address. This module takes NO inputs from other landing zones, so it
  # works in clickops estates where the bastion was built by hand.
  bastion = { host = "nkp-bastion.example.lab" }

  version_contract = {
    nkp        = "2.18.0"
    kubernetes = "1.35.2"
  }

  # `user` NAMES a Prism Central account; its password is injected by the hook.
  prism_central = {
    endpoint = "pc.example.lab"
    user     = "nkp-capx"
  }

  # Absolute paths ON THE BASTION.
  airgap = {
    bundles = [
      "/var/tmp/nkp-v2.18.0/container-images/konvoy-image-bundle-v2.18.0.tar",
      "/var/tmp/nkp-v2.18.0/container-images/kommander-image-bundle-v2.18.0.tar",
    ]
    bootstrap_cluster_image = "/var/tmp/nkp-v2.18.0/konvoy-bootstrap-image-v2.18.0.tar"
  }

  placement = {
    prism_element_cluster = "pe-cluster-01"
    subnets               = ["Kubernetes Management"]
    vm_image              = "nkp-ubuntu-24.04-release-cis-1.35.2-20260626141256"
  }

  control_plane = { endpoint_ip = "192.168.84.150" }
  networking    = { load_balancer_ip_range = "192.168.84.151-192.168.84.170" }
  csi           = { storage_container = "k8s-persistent" }
  ssh           = { public_key_path = "/run/nkp/nkp-mgmt/id.pub" }
}
```

Sizing, CSI, registry, proxy, ingress and misc settings default to NKP's own values; see
`module/variables.tf`, which documents every input inline.

## The contract

`output "contract"` is what the hook consumes:

```json
{
  "cluster_name": "nkp-mgmt",
  "bastion": {"host": "...", "user": "...", "work_dir": "/var/tmp"},
  "env": {"NO_COLOR": "1"},
  "secret_env": ["NUTANIX_USER", "NUTANIX_PASSWORD"],
  "preflight": {"bundles": ["..."], "min_free_gib": 60},
  "create": {"argv": ["nkp", "create", "cluster", "nutanix", "..."]},
  "delete": {"argv": ["nkp", "delete", "cluster", "..."]}
}
```

Two properties matter.

**`argv` is a list, not a shell string.** The hook `exec`s it directly, so there is no quoting
to get wrong — a Prism Central password containing `!` broke a hand-run command during
development, and an argv list cannot have that class of bug.

**`secret_env` carries NAMES, never values.** The hook resolves each from SOPS at run time.
Nothing secret reaches OpenTofu state or `tofu output`, which is also why `contract` is not
marked `sensitive`: you should be able to read the exact command before committing to a
45-minute run.

## Flag coverage

Of the 82 flags on `nkp create cluster nutanix`:

- **~55 are first-class validated inputs.**
- **~14 are module-owned** and cannot be set. `--self-managed` and `--airgapped` define the
  contract this module exists to render; `--dry-run`, `--output`, `--output-directory`,
  `--wait`, `--verbose`, `--show-managed-fields`, `--kubeconfig` and `--namespace` belong to
  the executing hook; `--skip-preflight-checks` is never silently allowed; the AWS/GCP ones
  are meaningless here.
- **`extra_args`** carries anything not yet modelled, validated against a deny-list of that
  module-owned set so the air-gap contract cannot be voided through it.

## Validation

Everything fails at **plan**, because each of these otherwise costs a 30–45 minute create to
discover. Failures are aggregated, so one plan reports every problem rather than one per run.

| Class                    | Examples                                                                                                     | Needs credentials |
| ------------------------ | ------------------------------------------------------------------------------------------------------------ | ----------------- |
| Static IP/CIDR math      | VIP inside the load-balancer range; reversed or tiny range; pod/service CIDR overlap; VIP inside either CIDR | no                |
| Version contract         | node image's Kubernetes version vs `version_contract`; bundle filenames vs the NKP version                   | no                |
| Air-gap invariants       | registry pointing at a public host; relative artefact paths; a credential with no registry                   | no                |
| Nutanix object existence | PE cluster, subnets, storage container and node images resolve by name                                       | **yes**           |

Set `enable_data_lookups = false` to skip the last class for offline plans and unit tests.

`enforce_validation` is a **test seam only** — it exists so tests can read
`output.validation_errors` instead of dying on the precondition. Never set it false in a real
configuration; it makes every cross-variable check advisory.

## Notes from the field

- **Teardown needs the bundle too.** `nkp delete cluster --self-managed` builds a _fresh_
  bootstrap cluster and reverse-pivots CAPI into it, so `bootstrap_cluster_image` is required
  for delete as well as create.
- **`nkp delete` orphans every PVC-backed volume group.** `--delete-kubernetes-resources` is
  scoped, by its own help text, to "Services with type LoadBalancer". Sweeping them is the
  delete hook's job, and the PV → volume-group mapping must be captured _before_ teardown.
- **`nkp delete` has no `--dry-run`.**

## Development

```bash
tofu fmt -recursive .
tofu validate
tofu test          # 22 runs, fully offline
```

Tests live in `module/tests/validation.tftest.hcl`; every validation rule has a failing case.
