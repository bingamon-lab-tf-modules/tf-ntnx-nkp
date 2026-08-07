# Nutanix Kubernetes Platform (NKP) v2.18 Release Notes

Nutanix Kubernetes® Platform 2.18 Release Notes

Nutanix Kubernetes Platform 2.18 July 16, 2026

## Contents

## NKP Release Notes

## Nutanix Kubernetes® Platform (NKP) 2.18 Release Notes

This document describes release-specific new or updated features, resolved
issues, and known issues for Nutanix Kubernetes® Platform (NKP).

New Features and Enhancements

Kubernetes 1.35 Support NCN-110590 NKP 2.18 supports Kubernetes version 1.35.2.

Rocky Linux 9.7 Support NCN-112144 NKP 2.18 supports Rocky Linux version 9.7.

Flatcar LTS Version Support NCN-105851

NKP 2.18 adds support for the 4081.3.8 Flatcar LTS version across AWS,
vSphere, and preprovisioned infrastructure providers that already support
Flatcar. Earlier Flatcar versions are deprecated in this release and are
planned for removal in a future release.

Containerd v2 Support NCN-107625 NKP 2.18 upgrades the container runtime to
containerd v2 across supported infrastructure providers.

Cluster API v1.12 and v1beta2 Provider Support NCN-111722 NKP 2.18 keeps
Cluster API (CAPI) on the latest v1.12 release
and migrates infrastructure providers to the v1beta2 API. Cluster API Runtime
Extensions for Nutanix (CAREN) supports a
mix of v1beta1 and v1beta2 infrastructure providers, and Konvoy upgrades
infrastructure providers as v1beta2 becomes
available. Cluster API Provider for Nutanix Cloud Infrastructure (CAPX) and
the Cluster API Preprovisioned
Infrastructure Provider (CAPPP) are migrated to v1beta2.

NKPCluster Is the Authoritative API for Cluster Management NCN-113041 NKP 2.18
makes the NKPCluster resource the authoritative API for managing clusters.
Update the NKPCluster directly and use its name in nkp cluster commands and
GitOps workflows, instead of editing the CAPI Cluster or KommanderCluster.

Preflight Checks on Cluster Update NCN-107282 NKP 2.18 runs preflight checks
during cluster updates to prevent misconfiguration of existing clusters,
including during cluster upgrades. Additional preflight checks are introduced
for clusters running on Nutanix infrastructure.

GPU and FIPS Image Creation in Air-gapped Environments NCN-112121 NKP 2.18
supports creating images with vGPU, GPU passthrough, and FIPS enabled together
in air-gapped environments for RHEL on Nutanix infrastructure.

Default Air-gapped Bundle for Nutanix Product Catalog NCN-111392 NKP 2.18
includes Nutanix Data Services for Kubernetes (NDK) in the default air-gapped
bundle, so new air-gapped installations populate the NKP catalog with NDK
automatically. Existing air-gapped clusters and any NDK installations from
earlier releases continue to work unchanged after upgrade. You can still
install NDK manually from the Nutanix Portal air-gapped bundle.

Istio Ambient Mode Migration from Helm-based Solution NCN-111822 NKP 2.18
supports migrating Istio deployments from the Helm-based solution to ambient
mode.

Grafana Loki Upgrade to Version 3 NCN-109868

NKP 2.18 upgrades Grafana Loki from version 2.9.x to version 3.0.x and
migrates from the loki- distributed Helm chart to the loki chart.

If Grafana Loki is heavily customized, the automatic v2 to v3 migration might
fail during upgrade. For troubleshooting steps, see the LoggingStack
GrafanaLokiV3Deployed Failure section in Troubleshoot Management Cluster
Upgrades.

NKP Default Onboarding in Prism Central NCN-109556 As part of the deployment
and upgrade process, NKP automates the installation and registration of NKP
clusters to Prism Central.

Support for FIPS 140-3 Compliant Clusters NCN-108182NCN-111100

NKP 2.18 supports Federal Information Processing Standards (FIPS)
140-3-compliant clusters. It includes a new Ubuntu Pro operating system image
hardened for CIS, STIG, and FIPS compliance for cluster provisioning.

NKP MCP Server for AI Navigator Cluster Context NCN-109024

NKP 2.18 introduces the NKP Model Context Protocol (MCP) Server for AI
Navigator. The MCP Server supports AI Navigator to retrieve and reason over
cluster information. It queries live and historical data sources in parallel,
refines queries dynamically, and correlates data for context- aware root cause
analysis. The MCP Server is an optional companion to AI Navigator that you
must enable explicitly.

Management Cluster Node Pool Namespace Alignment NCN-113871

Starting in NKP 2.18, new management clusters run in the kommander namespace
instead of the default namespace used in NKP 2.17 and earlier. Management
clusters upgraded from earlier NKP versions keep their existing namespace,
which is typically default.

The nkp get nodepool, nkp scale nodepool, nkp update nodepool, and nkp delete
nodepool commands targeting a new management cluster now require the -n
kommander flag. Update any scripts or automation that run node pool operations
on a new management cluster to include this flag.

Prism Central Project Selection and Enforcement for Clusters NCN-109515 NKP
2.18 changes how the Prism Central project for a cluster is selected and
enforced. Nutanix recommends that you create NKP clusters only on the default
Prism Central project (\_internal). Prism Central 7.5 does not enforce this
recommendation. For details, see Nutanix Prism Central Projects with NKP in
the NKP documentation.

Resolved Issues

NFD DaemonSet Skipped Tainted GPU Nodes NCN-113559 Resolved an issue where the
node-feature-discovery (NFD) DaemonSet did not label tainted GPU nodes, which
prevented GPU workloads from being scheduled; NFD now tolerates all taints and
labels every node.

cert-manager ACME Challenges Failed on Gateway API Resources NCN-112584

Resolved an issue where cert-manager failed to complete Automated Certificate
Management Environment (ACME) HTTP-01 challenges for Gateway API resources;
cert-manager now supports Gateway API.

Istio Ambient Mode Failed Sidecar-to-Ambient Traffic NCN-113462 Resolved an
issue where Istio sidecar-to-ambient communication failed with HTTP 503
Service Unavailable and Connection refused on port 15008, breaking the mixed-
mode traffic required for brownfield migrations.

Preprovisioned Machine Provisioning Failed on Hosts Without cloud-init
NCN-113411 Resolved an issue where preprovisioned machine provisioning jobs
failed on hosts that did not have cloud-init installed. Nutanix Image Builder
ran Ansible tasks that enable cloud-init services, which the earlier Konvoy
Image Builder workflow skipped. Nutanix Image Builder now skips those tasks
for preprovisioned environments.

CAPX VM Power-on Failed Due to ETag Mismatch NCN-113394 Resolved an issue
where CAPX failed to power on VMs in Prism Central environments with anti-
affinity rules enabled. The failures were caused by unhandled optimistic-
locking retries and returned errors such as If-Match header value passed
'MSww' because it doesn't match the current value in the server 'Miww'.

Cluster API Provider AWS Webhook Conversion Errors NCN-113332 Resolved an
issue where the capa-controller-manager flooded API server logs with errors
when converting AWS provider resources between v1beta1 and v1beta2.

Nutanix Data Services for Kubernetes AppDeployment with appID Did Not
Reconcile NCN-113262 Resolved an issue where an AppDeployment that referenced
an application by appRef.appID was never reconciled to the workload cluster,
leaving the application undeployed.

Gateway API CRDs Catalog Entry Overrides Did Not Apply NCN-113249 Resolved an
issue where customizations of the gateway-api-crds catalog entry, such as
enabling gatewayAPIExperimental, were ignored because the gateway-api-crds
HelmRelease did not consume the generated overrides ConfigMap.

CAPX Retried Failed Requests Without Resetting the Body NCN-113210 Resolved an
issue where the capx-controller pod became stuck in CreateError because prism-
go-client retried failed requests without resetting the request body.

Git Operator Controller Manager Crashed with OOMKilled NCN-113044 Resolved an
issue where the git-operator-controller-manager pod was terminated with
OOMKilled and entered CrashLoopBackOff; the memory limit is now increased and
persists across upgrades.

Kommander PlatformAppDeploymentsReady Stuck on Disabled Applications
NCN-112984 Resolved an issue where the PlatformAppDeploymentsReady condition
on attached clusters stayed in InProgress because the controller waited on
applications that were disabled for the cluster.

Automated Certificate Management Environment Feature in NKP Installer Was
Broken NCN-112704 Resolved an issue where the Automated Certificate Management
Environment (ACME) feature in the NKP installer failed. The kommander-acme-
issuer ClusterIssuer used an incorrect ingress.class value, and the Traefik
global HTTPS redirect intercepted HTTP-01 challenge traffic.

Application Configuration Overrides Did Not Persist in Kommander UI NCN-112624
Resolved an issue where changes to Cluster Application Configuration Overrides
under Cluster > Enabled Applications were silently discarded and disappeared
after reopening the edit screen.

Preprovisioned Clusters Reported Unknown Certificate Status NCN-112497
Resolved an issue where preprovisioned clusters reported Certificate Status:
Unknown on the cluster dashboard because control plane certificate renewal and
expiry dates were unavailable.

Worker Nodes Entered Disk-pressure Due to Image Accumulation NCN-112483
Resolved an issue where worker nodes repeatedly entered the SchedulingDisabled
state due to disk pressure from accumulated container images; NKP now
configures the kubelet image garbage collection to run consistently across
node replacements.

traefik-forward-auth Crashed When clusterStorage Was Enabled NCN-112264
Resolved an issue where the traefik-forward-auth pod crashed intermittently
with fatal error: concurrent map writes when clusterStorage was enabled.

Konnector Agent Webhook Blocked Cluster Deletion NCN-112205 Resolved an issue
where Konnector Agent topology and validating webhooks timed out on workload
clusters with misconfigured networking, blocking Cluster updates and
preventing cluster deletion.

commonName Was Missing in the Kommander ACME Certificate NCN-112134 Resolved
an issue where the generated Kommander Certificate did not include the
commonName key, breaking private PKI integrations; commonName is now populated
from the KommanderCluster hostname.

Marketplace Deployment Ignored Pod and Service CIDR Values NCN-111960 Resolved
an issue where NKP marketplace deployment from Prism Central failed because
user- provided Kubernetes service CIDR and pod network CIDR values were not
passed to nkp create cluster.

Kommander Re-reconciled Deprecated HelmRepository Files on Upgrade NCN-111823
Resolved an issue where long lived cluster upgrades to NKP 2.17.0 and later
were blocked because Kommander re-reconciled HelmRepository files from NKP
2.5.x that used an outdated apiVersion.

Existing Clusters Were Not Enabled for New Default Applications on Upgrade
NCN-111750 Resolved an issue where workspace upgrades did not populate
spec.clusterSelector for existing clusters, so new default AppDeployment
resources were not created for those clusters.

Kommander FluxCD CRD Storage Version Mismatch on Upgrade NCN-111732 Resolved
an issue where upgrades from NKP 2.7.x or earlier failed during the kommander-
flux Helm upgrade because stored objects in deprecated FluxCD Custom Resource
Definition (CRD) versions blocked their removal.

Nutanix Image Builder AWS ami_regions Flag Did Not Accept Multiple Regions
NCN-111708 Resolved an issue where the --ami-regions flag for nkp create image
aws failed with The value for ami_regions is not compatible with the
variable's type constraint: string required.

Cluster API Runtime Extensions for Nutanix Containerd Configuration Broke
Local Registry Mirrors NCN-111603 Resolved an issue where local registry
mirror solutions such as Spegel did not work because CAREN omitted the
[plugins."io.containerd.grpc.v1.cri".registry] section from the containerd
configuration; CAREN now generates this section unconditionally.

Project Grafana Logging Metrics Endpoint Was Unreachable NCN-106903 Resolved
an issue where Prometheus reported the project /dkp/logging/grafana/metrics
endpoint as down with dial tcp [::1]:3000: connect: connection refused.

Known Issues

Pre-2.18 Cluster Deletion Failure with the 2.18 CLI NCN-113770

Clusters that were provisioned with NKP 2.17 or earlier cannot be deleted with
the 2.18 CLI because the required clusterctl provider objects are no longer
present in the target cluster. The deletion fails with unable to pivot to the
to-cluster: failed to check providers in target cluster.

```yaml
Workaround: Delete pre-2.18 clusters with the earlier CLI version that matches the cluster, or
remove the providers manually before running the 2.18 CLI.
```

2.18 CLI Commands Not Compatible with Pre-2.18 Management Clusters NCN-115429

Certain 2.18 CLI commands are not compatible with management clusters running
NKP 2.17 or earlier. Affected commands return This command is not compatible
with the version of the management cluster. Use a CLI that matches the
management cluster's version. Read-only commands such as nkp get clusters, nkp
get kubeconfig, nkp get workspaces, and nkp get projects continue to work. The
error affects the following commands:

- nkp update bootstrap
- nkp create cluster
- nkp delete cluster
- nkp describe cluster
- nkp update controlplane
- nkp create nodepool
- nkp delete nodepool
- nkp get nodepool
- nkp scale nodepool
- nkp update nodepool

Workaround: Use the matching earlier NKP CLI version on pre-2.18 management
clusters.

Paused NKPCluster Sync When Cluster Deletion Fails on Unready Resources
NCN-115427

If resources on the cluster are not ready, cluster deletion fails and
NKPCluster sync is paused. Subsequent nkp delete nodepool commands also fail.

```yaml
Workaround: If you receive an error message when NKP moves resources from the management
cluster to a bootstrap cluster during deletion, follow these steps:
```

1. Unpause the NKPCluster by removing the clusters.nkp.nutanix.com/paused
   annotation on the NKPCluster resource. 2. Check the cluster for resources
   that are not ready.

Wait for them to become ready, or delete them on the self-managed cluster. 3.
Delete the bootstrap cluster. 4. Retry the deletion.

Intermittent LDAP Login Failures After Upgrade NCN-112916

After upgrading NKP to a version that includes Dex 2.15.2 or later, LDAP-based
logins fail intermittently. Dex advertises the post-quantum key-share group
X25519MLKEM768 in the TLS ClientHello, which some firewalls and TLS-inspecting
middle-boxes cannot process. The TLS handshake then fails.

```yaml
Workaround: Configure the network device performing TLS inspection to allow or bypass the
X25519MLKEM768 hybrid key-exchange group. NCN-112934
```

Application Pod Crashes from Low Default pod-max-pids Value

Workloads that spawn a large number of threads, such as Trino, might enter
CrashLoopBackOff because the CIS-hardened default --pod-max-pids=4096 kubelet
flag is too low.

```yaml
Workaround: Override the kubelet configuration to raise the podPidsLimit value for affected node
pools.
```

Grafana Loki v2 to v3 Override ConfigMap Conversion Failure During Upgrade
NCN-114334

When you upgrade to NKP 2.18, the logging stack controller migrates Grafana
Loki from v2 to v3 and converts existing override ConfigMaps to the v3 format.
If the controller cannot convert one or more override ConfigMaps, the
LoggingStack GrafanaLokiV3Deployed condition reports status: False with a
message that lists each failing workspace, project, or per-cluster override.
The migration remains blocked until you resolve the failure manually.

```yaml
Workaround: Prepare valid Grafana Loki v3 override values for each failing scope, redeploy
Grafana Loki from the NKP UI, and trigger a reconciliation. For step-by-step instructions, see
Troubleshooting LoggingStack GrafanaLokiV3Deployed Failure.
```

| LoggingStack | GrafanaLokiV3Deployed |
| ------------ | --------------------- |

grafana-loki-v3-post-install Job Failure Due to Maximum Active Stream Limit
NCN-112562

During Kommander installation with Grafana and Loki, the grafana-loki-v3-post-
install job fails with error: timed out waiting for the condition. The
corresponding kustomization never reaches the Ready state, even though the
Loki HelmRelease appears ready.

```yaml
Workaround: Override the Loki configuration to raise the max_global_streams_per_user value, or
set it to 0 to disable the cap, and scale Loki memory and CPU accordingly. For sizing guidance, see
Logging Stack Application Sizing Recommendations.
```

Incorrect Dry-run Output Directory File Order for Nutanix Cluster Creation
NCN-109240

When you run nkp create cluster --dry-run --output=yaml --output-
directory=`<dir>`, the generated resource files for a Nutanix cluster are
written in alphabetical order. The Cluster resource is created before its
dependencies, such as Secrets and failure domains, causing preflight checks to
fail because the credentials are missing.

Workaround: Create a single YAML manifest by omitting the --output-directory
flag.

Cluster Creation Failure on RHEL 8.10 GPU Images NCN-115035

On RHEL 8.10 GPU images, nkp create cluster can time out after 30 minutes when
a slow DHCP response on a joining control-plane VM causes kubeadm join to run
before NetworkManager establishes a default route. The command fails with
error waiting for control-planes to become ready.

```yaml
Workaround: The cluster usually self-recovers because MachineHealthCheck retries the failed VM.
Verify cluster health with nkp describe cluster and confirm that KubeadmControlPlane shows
3/3 Ready. To prevent the issue, ensure that DHCP responds within 45 seconds on the control-
plane subnet.
```

Workspace Upgrade Fails for Clusters with Long Names NCN-115563

Workspace upgrade to NKP 2.18.0 fails when a workload cluster name is longer
than 58 characters. Long cluster names cause derived Flux Kustomization labels
to exceed the 63-character Kubernetes label limit. Platform apps then fail to
install on the workload cluster. The Kommander upgrade completes, but the
workspace upgrade stalls during the platform upgrade phase and returns
platform upgrade did not complete successfully: platform upgrade failed on 1/1
clusters.

```yaml
Workaround: Use workload cluster names of 58 characters or fewer. If an existing cluster exceeds
this limit, create a new cluster with a shorter name and migrate workloads before upgrading.
```

gatekeeper-audit Pod OOM Crashes on Clusters with All Platform Apps Enabled
NCN-115572

On NKP 2.18 management clusters with all default platform apps enabled, the
gatekeeper-audit pod can exceed the default
512 MiB memory limit. The pod is repeatedly OOMKilled (exit code 137) and
enters CrashLoopBackOff. The audit controller
runs with --audit-match-kind-only=false, so it scans every Kubernetes object
on the cluster. Audit memory usage grows
with the number of objects and custom resource definitions on the cluster.
Between kills, the pod may intermittently
report 1/1 Running, which can mask the failure. Gatekeeper admission
enforcement is not affected. Only the periodic
audit function, which reports policy violations, is degraded.

```yaml
Workaround: Override the gatekeeper-audit AppDeployment configuration to raise the memory
limit above 512 MiB.
```

NKP 2.18 Limitations

Harbor Trivy Scan in an Air-gapped Environment NCN-105807 Trivy scanner does
not have access to a vulnerability database in an air-gapped environment.

```yaml
Workaround: To run a Trivy vulnerability scan in an air-gapped environment, you must first fetch
the vulnerability database and push it to your registry. For more information, see Database.
```

| gatekeeper-audit | AppDeployment |
| ---------------- | ------------- |

Self-signed CA Certificate Trust for the NCR Private Registry NCN-105470 When
you create a management cluster with the default configuration, the deployed
Nutanix Container Registry (NCR) is only accessible over HTTPS with a self-
signed certificate. To configure a trusted CA certificate instead, see
Configuring the Kommander Installation with a Custom Domain and Certificate.

```yaml
Workaround: To use NCR in a workload cluster, you must configure the cluster to trust the self-
signed certificate. For instructions, see Using Integrated Private Registry on an NKP Cluster.
```

NKP 2.18 Deprecations

GitRepository-based Catalog Applications NCN-115777

GitRepository-based catalogs have been deprecated since NKP 2.16 and are
completely unsupported in NKP 2.18. Migrate to an OCIRepository-based catalog
to continue using NKP catalogs. For more information, see Workspace Catalog
Applications and Project Catalog Applications.

Kubernetes Cluster Federation NCN-95441 Kubernetes Cluster Federation
(KubeFed) is deprecated in NKP 2.18 and is planned for removal in a future
release. NKP currently uses KubeFed to federate workspace and project
namespaces, ConfigMaps, RBAC, and similar resources from the management
cluster to attached clusters. The upstream kubernetes-sigs/kubefed project is
retired and is no longer maintained.

Legacy EKS Cluster Creation Workflow NCN-112124 The legacy, non-ClusterClass
workflow for Amazon Elastic Kubernetes Service (EKS) cluster creation and
upgrade is deprecated in NKP 2.18. NKP 2.18 supports EKS cluster creation and
upgrade only through ClusterClass. Migration of existing legacy EKS clusters
to ClusterClass is not supported.

NKP AI Navigator Cluster Info Agent NCN-109852 The NKP AI Navigator Cluster
Info Agent platform application is deprecated and removed from the NKP catalog
in NKP 2.18. Existing AppDeployments of the Cluster Info Agent are
automatically disabled when you upgrade to NKP 2.18.

Systemd-based Control Plane Certificate Renewal NCN-107761 The systemd-based
method for renewing the control plane certificate is deprecated in NKP 2.18.
NKP 2.18 renews control plane certificates through the Cluster API method.
When you upgrade to NKP 2.18, existing clusters that use systemd-based renewal
are automatically migrated to the Cluster API renewal method.

Kubernetes Dashboard NCN-115437

As of NKP 2.18, the Kubernetes Dashboard platform application is deprecated
and is planned for replacement with an upstream Kubernetes UI in a future
release. The upstream Kubernetes Dashboard project is archived and no longer
maintained.

This change applies only to the Kubernetes Dashboard instance that NKP
installs and manages. For the NKP-provided dashboard, no action is required.
NKP will automatically replace the upstream Kubernetes Dashboard during a
future upgrade.

If you run your own Kubernetes Dashboard instance for application workloads,
you can continue to manage it independently. Because the upstream project is
archived, Nutanix recommends migrating to a maintained Kubernetes UI project
instead of the upstream Kubernetes Dashboard Helm chart in a future release.

kommander-federated-edit Cluster Role NCN-111039 As of NKP 2.18, the
kommander-federated-edit cluster role, also known as the Global Edit Role at
the Global view, is deprecated and is planned for removal in a future release.
This ClusterRole allows privilege escalation on the management cluster.

> **Action required: Remove any RoleBindings or ClusterRoleBindings that
> bind this ClusterRole. If you used it to grant edit access, replace it
> with the Global Admin role.**

## Prism Central and AOS Version Compatibility

Nutanix recommends that you check the compatible Prism Central and AOS
versions before installing or upgrading NKP.

Table 1: Compatible Prism Central and AOS Versions

pc.7.5 or later 7.5 or later

For more information, see Compatibility and Interoperability Matrix.

## Supported Kubernetes Versions

Table mapping the supported Kubernetes® version by provisioner to NKP for
version 2.18.

Table 2: Compatible Kubernetes Versions

NKP Management Cluster 1.35.x, 1.34.x

Cluster Attached to NKP 1.35.x, 1.34.x

EKS Cluster Attached to NKP 1.35.x, 1.34.x

Legacy EKS Cluster Attached to NKP

1.35.x, 1.34.x

AKS Cluster Attached to NKP 1.35.x, 1.34.x

NKP 2.18

GKE Cluster Attached to NKP 1.35.x, 1.34.x

> **Important:**

- Nutanix recommends attaching Kubernetes clusters with versions no higher
  than n-1 of a specific version.
- If you attach a cluster with a lower Kubernetes version than the NKP
  default, build and use an image with that lower version of Kubernetes to
  prevent errors. For more information on building images, see Konvoy Image
  Builder.
- The latest supported Kubernetes version for deploying clusters in NKP is
  1.35.x. In NKP 2.18, the Kubernetes version installed by default is 1.35.2.
  NKP also supports the previous Kubernetes minor versions.
- Kubernetes 1.35.2 provides the latest upstream features and security fixes.
  For more information about the significant features in this release, see
  Kubernetes v1.35 Release Notes and Kubernetes v1.35 Dynamic Resource
  Allocation.

| Prism Central Versions | AOS Versions |
| ---------------------- | ------------ |

| Product | Provisioner | Compatible Kubernetes Versions |
| ------- | ----------- | ------------------------------ |

## Supported Nutanix Product Catalog Applications Versions

NKP supports attaching clusters with specific NDK versions.

Table 3: Compatible NDK Versions

NKP2.18 NDK2.1 NAI2.7.0

## Supported Components

This section summarizes the supported NKP configurations.

Components

NKP supports the following component versions:

Cluster API Core (CAPI) 1.12.4

Cluster API Amazon AWS Infrastructure Provider (CAPA)

2.11.0

Cluster API Google Cloud Infrastructure Provider (CAPG)

1.11.1

Cluster API Pre-provisioned Infrastructure Provider (CAPPP)

0.42.1

Cluster API vSphere Infrastructure Provider (CAPV) 1.15.2

Cluster API Azure Infrastructure Provider (CAPZ) 1.23.0

Cluster API Provider for Nutanix Cloud Infrastructure (CAPX)

1.9.2

containerd 2.1.6

etcd 3.5.24

Calico 3.30.4

Cilium 1.19.2

Cluster Autoscaler 1.34.3

CSI_VERSION For information on versions and drivers, see Default Storage
Providers.

Metal LB 0.15.2

Node Feature Discovery 0.18.3

## Supported Applications

Matrix of application versions that NKP supports.

NKP includes integrations with the applications listed below, some of which
are from third parties. Any third party applications are optional to use,
although some are installed by default. For the applications not installed by
default, you can install them post-deployment using the UI or pre-deployment
using a configuration file. See the NKP Support Policy for more information
about how we support these integrations.

| NKP | NDK | NAI |
| --- | --- | --- |

| Component Name | Version |
| -------------- | ------- |

AI Navigator App

ai-navigator- app

0.8.0 chart: 0.8.0

ai-navigator- app: 0.8.0

N/A Link

AI Navigator RAG

ai-navigator-rag 0.8.0 chart: 0.8.0 N/A Link

Centralized Grafana

centralized- grafana

82.13.6 chart: 82.13.6

prometheus- operator: v0.89.0

grafana: 12.4.1

Link Link

Centralized Opencost

centralized- opencost

2.5.14 chart: 2.5.14

centralized- opencost: 2.5.14

Link Link

Cert Manager cert-manager 1.19.3 chart: 1.19.3

cert-manager: 1.19.3

Link Link

Cilium Hubble Relay Traefik

cilium-hubble- relay-traefik

0.0.5 chart: 0.0.3 Link Link

Cloudnative Pg cloudnative-pg 0.28.0 chart: 0.28.0

cloudnative-pg: 1.29.0

Link Link

Cosi Driver Nutanix

cosi-driver- nutanix

0.6.3 chart: 0.6.0

cosi-driver- nutanix: 0.6.0

Link Link

Dex dex 2.14.5 chart: 2.14.0

dex: 2.37.0

Link Link

Dex K8s Authenticator

dex-k8s- authenticator

1.4.8 chart: 1.4.3

dex-k8s- authenticator: 1.4.1

Link Link

External DNS external-dns 10.20.0 chart: 9.0.3

external-dns: 0.18.0

Link Link

External Secrets

external-secrets 2.3.0 chart: 2.3.0 Link Link

- Common Application Name; APP ID; Version; Component Versions; Helm Values;
  NKP Values

| --- | --- | --- | --- | --- | --- |

Fluent Bit fluent-bit 0.57.2 chart: 0.57.2

fluent-bit: 5.0.2

Link Link

Gatekeeper gatekeeper 3.22.0 chart: 3.22.0

gatekeeper: 3.22.0

Link Link

Gateway API CRDs

```bash
gateway-api-
crds.
```

1.11.2 chart: 1.11.1 N/A Link

Git Operator git-operator 0.13.18 chart: 0.13.19 N/A Link

Grafana Logging

grafana-logging 11.3.3 chart: 11.3.3

grafana: 12.4.1

Link Link

Grafana Loki v3 grafana-loki-v3 3.6.7 chart: 6.55.0

loki:

Link Link

Grafana Loki grafana-loki 0.80.6 chart: 0.80.6

loki: 2.9.13

Link Link

Harbor harbor 1.18.3 chart 1.18.3

harbor: 2.14.3

Link Link

Istio istio 1.23.6 chart: 1.23.3

istio: 1.23.3

Link Link

Istio Helm istio-helm 1.25.0 chart: 1.25.0

istio: 1.29.0

Link Link

Jaeger jaeger 2.57.4 chart: 2.57.0

jaeger: 1.61.0

Link Link

Karma karma 2.0.10 chart: 2.0.3

karma: 0.70

Link Link

Karma Traefik karma-traefik 0.0.5 chart: 0.0.2

karma-traefik: 0.0.5

Link Link

Kiali kiali 2.24.0 chart: 2.24.0

kiali: 2.24.0

Link Link

Knative knative 1.20.2 chart: 1.21.0

knative: 1.21.0

Link Link

- Common Application Name; APP ID; Version; Component Versions; Helm Values;
  NKP Values

| --- | --- | --- | --- | --- | --- |

Flux kommander- flux

2.8.5 chart: 2.18.3

flux: 2.8.5

N/A Link

Kommander kommander 0.18.0 chart: 2.18.0 kommander: v2.18.0

N/A Link

Kommander Appmanagement

kommander- appmanagement

0.18.0 chart: 2.18.0 kommander- appmanagement: v2.18.0

N/A Link

Kommander Ui kommander-ui 17.234.30 chart: 17.234.30

kommander-ui: 17.234.30

N/A Link

Kube OIDC Proxy

kube-oidc-proxy 0.3.8 chart: 0.3.4

kube-oidc- proxy: 0.3.0

Link Link

Kube Prometheus Stack

kube- prometheus- stack

82.13.6 chart: 82.13.6

prometheus- operator: 0.89.0

grafana: 12.4.1

Link Link

Opencost opencost 2.5.14 chart: 2.5.14 Link Link

Kubefed kubefed 0.12.1 chart: 0.12.1

kubefed: 0.12.1

N/A Link

Kubernetes Dashboard

kubernetes- dashboard

7.14.1 chart: 7.14.0

kubernetes- dashboard: 7.14.0

Link Link

Kubetunnel kubetunnel 0.2.0 chart: 0.2.0

kubetunnel: 0.2.0

N/A Link

Logging Operator

logging- operator

6.4.0 chart: 6.4.0

logging- operator: 6.4.0

logging- operator- logging: 6.4.0

Link Link

- Common Application Name; APP ID; Version; Component Versions; Helm Values;
  NKP Values

| --- | --- | --- | --- | --- | --- |

NKP Insights nkp-insights 1.8.4 chart: 1.8.4

nkp-insights: 1.8.4

N/A Link

NKP Insights Management

nkp-insights- management

1.8.4 chart: 1.8.4

nkp-insights- management: 1.8.4

N/A Link

NKP MCP Server

nkp-mcp-server 0.1.2 chart: 0.1.2

nkp-mcp-server: 0.1.2

N/A Link

NKP Pulse Management

nkp-pulse- management

0.4.2 chart: 0.4.2

nkp-pulse- management: 0.4.2

N/A Link

NKP Pulse Workspace

nkp-pulse- workspace

0.4.2 chart: 0.4.2

nkp-pulse- workspace: 0.4.2

N/A Link

NVIDIA GPU Operator

nvidia-gpu- operator

26.3.0 chart: 26.3.0

nvidia-gpu- operator: 26.3.0

Link Link

NVIDIA Network Operator

nvidia-network- operator

26.1.0 chart: 26.1.0

nvidia-network- operator: 26.1.0

Link Link

Grafana (project)

project-grafana- logging

11.3.3 chart: 11.3.3

grafana: 12.4.1

Link Link

Grafana Loki (project)

project-grafana- loki

0.80.6 chart: 0.80.6

loki: 2.9.13

Object Bucket Claims: 0.1.11

Link Link

Project Grafana Loki V3

project-grafana- loki-v3

3.6.7 chart: 6.55.0

project-grafana- loki-v3: 6.55.0

Link Link

Project Logging project-logging 1.1.0 chart 1.1.0 N/A N/A

- Common Application Name; APP ID; Version; Component Versions; Helm Values;
  NKP Values

| --- | --- | --- | --- | --- | --- |

Prometheus Adapter

prometheus- adapter

5.3.0 chart: 5.3.0

prometheus- adapter: 0.12.0

Link Link

Prometheus- Thanos-traefik

prometheus- thanos-traefik

0.0.5 chart: 0.0.2 Link Link

Reloader reloader 2.2.11 chart: 2.2.11

reloader: 1.4.16

Link Link

Rook Ceph rook-ceph 1.19.6 chart: 1.19.6

rook-ceph: 1.19.6

Link Link

Rook Ceph Cluster

rook-ceph- cluster

1.19.6 chart: 1.19.6

rook-ceph: 1.19.6

Link Link

Thanos thanos 17.3.2 chart: 17.3.1

thanos: 0.39.2

Link Link

Traefik traefik 39.0.7 chart: 39.0.7

traefik: 3.6.12

Link Link

Traefik ForwardAuth

traefik-forward- auth

0.3.18 chart: 0.3.10

traefik-forward- auth: 3.1.0

Link Link

Traefik Forward Auth Mgmt

traefik-forward- auth-mgmt

0.3.18 chart: 0.3.10

traefik-forward- auth-mgmt: 3.1.0

Link Link

Velero velero 12.0.0 chart: 12.0.0

velero: 1.18.0

Link Link

vGPU Token Operator

vgpu-token- operator

1.0.8 chart: 1.0.7

vgpu-token- operator: 1.0.7

N/A Link

## CVE Management Policies

Nutanix Common Vulnerabilities and Exposures (CVE) policies and procedures.

At Nutanix, our commitment to providing secure software solutions is
paramount. We understand the critical importance of promptly addressing and
mitigating security vulnerabilities. To assure our customers of the safety and
trust of our software secure development program, we have created this
document to

- Common Application Name; APP ID; Version; Component Versions; Helm Values;
  NKP Values

| --- | --- | --- | --- | --- | --- |

outline our policies and procedures regarding Common Vulnerabilities and
Exposures (CVE) that are discovered in our software.

Our method for managing CVEs is described in the following sections:

### Scanning Policy

### Shipping Policy

### NKP Security Updates

For more information on our secure development program and process, see KB-4110.

### Scanning Policy (2)

- Our primary objective is to provide software free from security
  vulnerabilities at the time of delivery. NKP uses the Common Vulnerability
  Scoring System (CVSS), an industry standard for measuring security flaws.
  Each vulnerability is assigned a score between 0 and 10. Higher scores
  indicate more severe issues.
- We conduct regular scans of our software components, including:
- Kubernetes
- Nutanix Acropolis Operating System (AOS)
- Nutanix Platform applications such as Traefik and Istio.
- Nutanix Catalog application versions are compatible with the default
  Kubernetes version and are supported with a respective NKP release. For more
  information, see Workplace Catalog Applications.
- NKP Insights Add-on.
- Scans are performed every 24 hours using the latest vulnerability database
  to identify and address potential vulnerabilities promptly. When results are
  published, the vulnerability identifier, criticality, and release tied to
  mitigation or remediation are included.
- Security Advisories are published for severe vulnerabilities.

### Shipping Policy (2)

- Our objective is to ship software releases that do not have vulnerabilities
  where mitigation or remediation is unavailable.
- For major and minor releases, our objective is to ship only when there are
  no known severe vulnerabilities, or no mitigation is available.
- Depending on the component, a patch for a severe vulnerability might be
  provided in a minor or patch release.
- We prioritize resolving these issues in the next minor release to maintain
  our commitment to security.
- If we discover a severe vulnerability for a Generally Available (GA) version
  of our Software, a mitigation or patch release will be targeted for release
  within 45 days from the date of publication or development, as applicable.

### NKP Security Updates (2)

The Mitigated NKP Security Updates table presents mitigated Common
Vulnerabilities and Exposures (CVE) found in NKP Releases. Use the
Vulnerability Report column links to download a local detailed .csv file.

Table 4: Mitigated NKP Security Updates

v2.18.0 Download CSV File

v2.17.1 Download CSV File

v2.17.0 Download CSV File

v2.16.1 Download CSV File

v2.16.0 Download CSV File

v2.15.2 Download CSV File

v2.15.1 Download CSV File

v2.15.0 Download CSV File

v2.14.3 Download CSV File

v2.14.2 Download CSV File

v2.14.1 Download CSV File

v2.14 Download CSV File

v2.13.3 Download CSV File

v2.13.2 Download CSV File

v2.13.1 Download CSV File

v2.13 Download CSV File

v2.12.2 Download CSV File

v2.12.1 Download CSV File

v2.12 Download CSV File

## Ports

This section summarizes the supported NKP configurations for ports.

Ports List

This section describes ports used by the different Kubernetes components in
your NKP cluster. For more information on ports, see Ports and Protocols and
Kubernetes Ports and Protocols.

Table 5: Control Plane Nodes

22 ssh

179 calico-node BGP

1338 Conatinerd metrics

| Version | Vulnerability Reports |
| ------- | --------------------- |

| Port | NKP Component | Notes |
| ---- | ------------- | ----- |

2379 etcd client

2380 etcd peer

6443 kube-apiserver

9091 calico-node felix metrics

9092 calico-node bird metrics

9099 calico-node felix liveliness

9100 prometheus node-exporter metrics

10248 kubelet health

10249 kube-proxy metrics

10250 kubelet

10256 kube-proxy health

10257 kube-controller-manager secure port

10259 kube-scheduler secure port

30000-32767 Kubernetes NodePorts

4240 Cilium cilium cluster health check

4244 Cilium Hubble Server

4245 Cilium Hubble Relay

4250 Cilium Mutual Authentication port

Table 6: Worker Nodes

22 ssh

179 calico-node BGP

1338 Conatinerd metrics

5473 calico-typha csyncserver

9091 calico-node felix metrics

9092 calico-node bird metrics

9099 calico-node felix liveliness

9100 prometheus node-exporter metrics

9400 NVIDIA GPU DCGM metrics

10248 kubelet health

10249 kube-proxy metrics

10250 kubelet

10256 kube-proxy health

10257 kube-controller-manager secure port

| Port | NKP Component | Notes |
| ---- | ------------- | ----- |

| Port | NKP Component | Notes |
| ---- | ------------- | ----- |

10259 kube-scheduler secure port

30000-32767 Kubernetes NodePorts

4240 Cilium cilium cluster health check

4244 Cilium Hubble Server

4245 Cilium Hubble Relay

4250 Cilium Mutual Authentication port

| Port | NKP Component | Notes |
| ---- | ------------- | ----- |

## NKP Insights Release Notes

## Release Notes | Nutanix Kubernetes® Platform Insights 1.8

Release-specific information for NKP Insights.

New Features and Enhancements

Kubernetes 1.35 Support NKP v2.18 supports Kubernetes 1.35.2. NCN-110590

Authenticate Insights Backends to Management without Kubefed This feature
prepares Insights to work without Kubefed, which is deprecated. This feature
is enabled by default in v1.7. NCN-104679

NKP 2.18 Deprecations

NKP AI Navigator Cluster Info Agent The NKP AI Navigator Cluster Info Agent
platform application is deprecated and removed from the NKP catalog in NKP
2.18. Existing AppDeployments of the Cluster Info Agent are automatically
disabled when you upgrade to NKP 2.18. NCN-109852

## NKP Insights Component Versions

This version of NKP Insights contains the following component versions:

Table 7: NKP Insights Release Component Versions

aquasec/kube-bench v0.14.0

aquasec/trivy v0.64.\*

```yaml
Note: When Trivy is enabled, NKP Insights updates its security
databases regularly. In non-air-gapped environments, NKP
Insights checks for more recent databases before each scheduled
run (every two hours, by default). If a new database is found,
NKP Insights automatically bumps it to support the latest security
updates. In air-gapped environments, you can manually update
these databases.
```

For more information, see Trivy and Update Trivy Database in Air-Gapped
Environments.

fairwinds/nova v3.11.9

fairwinds/pluto v5.22.6

fairwinds/polaris v10.1.2

postgres v17.5.0

| Component Name | Version |
| -------------- | ------- |

## Alert Notifications with Alertmanager

The section also includes two configuration examples to enable NKP to
automatically send notifications for critical alerts through Slack or
Microsoft Teams.

## NKP Insights Alerts for Customer Workloads

NKP Insights focuses on troubleshooting issues related to your organization's
workloads. After deploying Insights or upgrading to this version, you might
not see any alerts for underlying NKP and Kubernetes components.

NKP Insights starts generating alerts after you deploy your workloads.

To enable NKP Insights Alerts on all components, including underlying NKP and
Kubernetes components, see Enable NKP-Related Insights Alerts.

## Upgrade Support

NKP Insights supports the same Kubernetes version as the NKP platform.

In previous versions, it was not possible to upgrade NKP Insights. To do so,
you had to uninstall NKP Insights, upgrade NKP, and reinstall NKP Insights.
Starting with NKP version 2.12, NKP Insights is upgraded as part of the NKP
upgrade, making it possible to upgrade without losing information on the
generated Insights.

For more information on the supported upgrade paths, see Upgrade NKP in the
Nutanix Kubernetes Platform Guide.

## CIS Benchmark Alerts

When running Kube-bench analyses, NKP Insights creates alerts for security-
related issues based on the CIS Benchmark. In this release, some of these
alerts are related to elements of clusters that were created with Konvoy,
NKP's provisioning tool.

For customers who require CIS Benchmark compliance, Nutanix provides a list of
mitigations and explanations for clusters created with Konvoy. You can use
these documented resources to either manually mitigate the issues or better
understand why these cannot be mitigated. For more information, see Known
Issues and Mitigations.
