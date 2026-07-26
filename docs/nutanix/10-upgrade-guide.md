# Upgrade Nutanix Kubernetes Platform

UPGRADE NUTANIX KUBERNETES PLATFORM

Upgrade your Nutanix Kubernetes Platform (NKP) environment to keep your
deployment current with the latest features, application updates, security
patches, and performance improvements.

Before you start the upgrade, validate platform version compatibility. Next,
upgrade Kommander on the management cluster, followed by the platform
applications on all attached clusters. Follow the prescribed upgrade sequence
to avoid compatibility issues. The exact sequence depends on your NKP license
and environment configuration.

GitOps-Managed Workload Clusters

If your workload clusters are ClusterClass-based Cluster API (CAPI) clusters
that you manage through a FluxCD GitOps repository, you must follow a modified
upgrade workflow. The workflow includes additional prerequisites and a GitOps
migration step to transition from CAPI Cluster resources to NKPCluster
resources.

The following table outlines the structure of this chapter and lists the
reference topics for each task that you perform to upgrade NKP in Nutanix and
non-Nutanix environments.

Table 79: Upgrade NKP Roadmap

## Plan the Upgrade

If you want to upgrade your clusters managed using NKP UI or CLI.

## Upgrade Nutanix Kubernetes Platform (2)

If you want to upgrade your GitOps-managed clusters.

Verify that the upgrade is successful. See Verifying Nutanix Kubernetes
Platform Upgrade on page 1072

## Plan the Upgrade (2)

Before upgrading your Nutanix Kubernetes Platform (NKP) cluster, select the
appropriate license for your requirements, identify the target version, and
verify that your cluster meets all configuration, resource, and version
compatibility requirements.

Review all prerequisites for upgrading your NKP environment, because they vary
depending on your infrastructure and environment configuration. Following the
correct checklist reduces the risk of upgrade failures.

The following table lists the required and optional prerequisites that you
must perform before upgrading your NKP environment. You can use this checklist
to prepare NKP in both Nutanix and non-Nutanix environment.

| Purpose | Reference Topic |
| ------- | --------------- |

Table 80: Prerequisites

Identify the current and target NKP versions.

Verify that your upgrade path is supported by determining both the current NKP
version and the target version that you plan to upgrade to.

See Identify the Upgrade Version on page 1045

Install the target NKP CLI version. Download and install the NKP CLI binary
for the target version.

See Downloading and Extracting Air-Gapped Image Bundle on page 1046

Identify the NKP license type. Identify the NKP license type for your NKP
cluster.

See Licenses on page 24

Verify compatibility. Confirm the supported Kubernetes, operating system,
applications, and component versions for your NKP cluster.

> **Note:**

- Verify that your user or custom applications are compatible with the target
  Kubernetes and NKP versions.
- NKP supports only operating system images that boot with control groups
  (cgroups) version 2 enabled by default.

NKP does not support nodes that use cgroups version 1 or require
post#provisioning modifications to switch from cgroups version 1 to version2.
These configurations can cause unpredictable behavior across Kubernetes
components and platform add-ons.

The operating system image provider validates cgroups mode prior to cluster
provisioning.

See Compatibility Requirements on page 1045

| Prerequisite | Description | Reference Topic |
| ------------ | ----------- | --------------- |

(Only applicable for air- gapped environments) Prepare air#gapped environment.

Verify that all required images and packages are available offline for
air#gapped upgrades.

See Preparing Air-Gapped Environments for Upgrade on page 1045

Back up using Velero. Use Velero to take a full backup of your existing
configuration before upgrade.

See Backup and Restore on page 555

Prepare the OS images. Use the pre-configured operating systems (OS) images or
build the image with Nutanix Image Builder. NKP does not support other custom
images.

See Nutanix Image Builder

Set infrastructure provider specific configuration.

Configure environment variables based on your infrastructure provider such as
Nutanix, Azure and AKS, AWS and EKS, vSphere, or GCP.

- For Nutanix, see Nutanix Infrastructure Requirements on page 719
- For Azure and AKS, see Azure Prerequisites on page 910and Install Nutanix
  Kubernetes Platform on AWS Infrastructure on page 814
- For AWS and EKS, see AWS Prerequisites on page 815.
- For vSphere, see vSphere Prerequisites: All Installation Types on page 189

(Optional) To resize the vSphere disk before upgrading, see vSphere: Base OS
Image in vCenter on page 859

- For GCP, see Google Cloud Platform (GCP) Infrastructure

(Optional) Configure pod disruption budget (PDB).

NKP upgrade involves draining and replacing nodes. Nutanix recommends
configuring PDB to maintain application availability and prevent unnecessary
workload disruptions during the upgrade.

See Pod Disruption Budget (Disruptions)

For the workload clusters provisioned through ClusterClass and managed through
a FluxCD GitOps repository.

- You must have write access to the GitOps repository that hosts the workload
  clusters.
- Disable Flux Pruning before upgrading to NKP 2.18.
- See Disabling Flux Pruning on page 1065.

| Prerequisite | Description | Reference Topic |
| ------------ | ----------- | --------------- |

For the EKS workload clusters. Ensure your EKS cluster uses ClusterClass. EKS
lifecycle operations are supported only for clusters that use ClusterClass.

NA

### Identify the Upgrade Version

For example, to upgrade from NKP v2.14.x to v2.16.x, first upgrade to v2.15.x,
then upgrade to v2.16.x.

You can skip intermediate patch versions. For example, you can upgrade
directly from NKP v2.15.0 to v2.16.1 without installing v2.15.1, v2.15.2, or
v2.16.0.

Ensure you refer to the following upgrade matrix for specific supported paths:

Table 81: NKP Upgrade Matrix

2.15.0 2.15.1 2.15.2 2.16.0 2.16.1 2.17.0 2.17.1 2.18.0

2.15.0 NA NA NA NA NA NA NA NA

2.15.1 Yes NA NA NA NA NA NA NA

2.15.2 Yes Yes NA NA NA NA NA NA

2.16.0 Yes Yes Yes NA NA NA NA NA

2.16.1 Yes Yes Yes Yes NA NA NA NA

2.17.0 NA NA NA Yes Yes NA NA NA

2.17.1 NA NA NA Yes Yes Yes NA NA

To Release

2.18.0 NA NA NA NA NA Yes Yes NA

### Compatibility Requirements

Verify compatibility for these components before upgrading:

- AOS and Prism Central: See Prism Central and AOS Version Compatibility in
  the NKP Release Notes or the Compatibility and Interoperability Matrix.
- Operating system: See Supported Infrastructure Operating Systems on page 12.
- Kubernetes: See Supported Kubernetes Versions section in the NKP Release
  Notes.
- Components: See Supported Components section in the NKP Release Notes.
- Applications: See Supported Applications section in the NKP Release Notes.

### Preparing Air-Gapped Environments for Upgrade

| Prerequisite | Description | Reference Topic |
| ------------ | ----------- | --------------- |

| Col1 | Upgrading from Release |
| ---- | ---------------------- |

your local registry mirror. Alternatively, you can use an internal registry
mirror that contains all necessary container images to bootstrap your NKP
cluster.

For Nutanix infrastructure, you can either use Nutanix-provided pre-built OS
images or build your own custom images using Nutanix Image Builder (NIB). For
non-Nutanix infrastructure, you can only build custom images using Nutanix
Image Builder (NIB). For more information, see Nutanix Image Builder on page 51. NIB supports building images without internet access by adding the
--override flag.

For AWS infrastructure deployments, specify the bundle image to avoid using
upstream cluster API provider AWS (CAPA) project images. NKP uses upstream
project images by default when you do not specify a bundle image. Nutanix does
not recommend upstream project images for production environments because they
can become unavailable and hence, NKP requires you to specify an Amazon
machine image (AMI) when creating a cluster.

#### Downloading and Extracting Air-Gapped Image Bundle

About this task

Air-gapped environments require container image access through a local or
internal registry mirror. The registry must contain all images necessary for
upgrade. For more information, see Air-Gapped or Non-Air-Gapped Environment on
page 22.

The air-gapped bundle contains the following artifacts (distro packages are
downloaded separately):

- NKP Kubernetes packages
- Python packages (provided by upstream)
- Containerd tarball

In earlier NKP versions, the air-gapped image bundle includes the distro
package bundles. For example, nkp-air- gapped-
bundle_v2.8.2_linux_amd64.tar.gz.

Before you begin

Verify the following connectivity requirements for clusters attached to the
management cluster:

- Both management and attached clusters must connect to the local registry.
- The management cluster must connect to the API servers of all attached
  clusters.

Procedure

1. Download the complete NKP air-gapped bundle. The bundle file name follows
   this format:

For more information, see Downloading NKP on page 16. 2. Extract the tarball
to a local directory: 3. Switch to the extracted directory:

This directory contains the files needed to run the bootstrap cluster.

| nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ------------------------ | ----------- | ------------------------ |

| tar -xzvf nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ---------------------------------- | ----------- | ------------------------ |

| cd nkp- | nkp-version | Col3 |
| ------- | ----------- | ---- |

1. Download and install the NKP CLI binary for the target version.

You can open the terminal with access to the NKP CLI and verify the NKP version:

```bash
nkp version
```

Sample output:

```bash
./nkp version
catalog: v0.7.0
diagnose: v0.12.0
imagebuilder: v2.16.1
kommander: v2.16.1
konvoy: v2.16.1
konvoybundlepusher: v2.16.1
mindthegap: v1.22.1
nkp: v2.16.1
```

1. From your download location with internet access, create an operating
   system package bundle for the target operating system used by the nodes in
   your NKP cluster:

```bash
nkp create package-bundle ${OS_TYPE} --artifacts-directory
path_to_artifacts_bundle_DIR
${FIPS_ENABLED:+--fips}
```

You can locate the Kubernetes image bundle in path_to_artifacts_bundle_DIR.
Replace path_to_artifacts_bundle_DIR with the path to the artifacts bundle
directory.

Ensure that you fetch the distro packages along with other artifacts. Fetching
packages directly from distro repositories includes the latest security fixes
available at machine image build time.

The system creates an OS bundle using the Kubernetes version defined in
ansible/group_vars/all/ defaults.yaml.

#### Load Images For Pre-provisioned Air-Gapped Environments

Configure pre-provisioned hosts by uploading necessary artifacts such as
packages, container images, and GPU drivers to existing nodes using Nutanix
Image Builder. Use this method to configure existing machines for Nutanix
Kubernetes Platform (NKP) clusters. After uploading artifacts, NKP uses these
pre-provisioned hosts to form a Kubernetes cluster quickly and consistently,
reducing upgrade errors caused by OS image and package misconfiguration.

For detailed instructions on uploading artifacts to pre-provisioned hosts, see
Upload artifacts to Pre-provisioned Hosts.

#### Load Images to Your Private Registry

Choose the appropriate registry type based on your environment setup. For more
information about air-gapped environments and registry types, see Air-Gapped
or Non-Air-Gapped Environment on page 22.

Prerequisites

Before loading images, verify that the Kubernetes image bundle is present in
path_to_artifacts_bundle_DIR.

Load Images to Local Registry

Use this method when you have a registry server external to your Kubernetes
cluster:

1. Set environment variables with your registry credentials:

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
```

1. Load the image bundles into your external registry:

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-nkp-version.tar,./
container-images/konvoy-image-bundle-nkp-version.tar,./container-images/nutanix-
product-catalog-nkp-version-airgapped.tar
--to-registry=$REGISTRY_URL
--to-registry-username=$REGISTRY_USERNAME
--to-registry-password=$REGISTRY_PASSWORD
```

Replace nkp_version with the NKP version at your site. Specify only the
required bundle as comma-separated values in the --bundle parameter.

The registry must be accessible from both the bastion virtual machine (VM) and
the cluster nodes. For more information, see Creating a Bastion Host on page 707.

Load Images to Internal Registry

Use this method when you have a registry running within your existing
management cluster:

- Load the image bundles into your internal registry:

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-nkp-version.tar,./
container-images/konvoy-image-bundle-nkp-version.tar,./container-images/nutanix-
product-catalog-nkp-version-airgapped.tar
--to-internal-registry-mirror
--kubeconfig=${CLUSTER_NAME}.conf
```

Replace nkp_version with the NKP version at your site. Specify only the
required bundle as comma-separated values in the --bundle parameter.

> **Note:**

- Pushing images to your registry might take time, depending on network
  performance between the machine running the command and the registry.
- The nutanix-product-catalog-nkp-version-airgapped.tar bundle is only
  supported on Nutanix infrastructure. You must exclude this bundle when
  deploying on other infrastructure providers such as Pre-provisioned, AWS,
  Azure, vSphere, and GCP.
- The nutanix-product-catalog-nkp-version-airgapped.tar included in the NKP
  air-gapped bundle contains images exclusively for Nutanix Data Services for
  Kubernetes (NDK). You must specify the Nutanix product catalog bundle only
  if you plan to deploy NDK.

## Upgrade Nutanix Kubernetes Platform (3)

Upgrade your Nutanix Kubernetes Platform (NKP) environment to the latest NKP
version. The NKP upgrade keeps your clusters current with the latest features,
improvements, and performance enhancements.

Upgrade your NKP environment in the following sequence to avoid compatibility
issues:

1. Upgrading Kommander on page 1049 2. Upgrading Platform Applications on
   Managed and Attached Clusters on page 1050 3. Upgrading Management and
   Managed Clusters on Nutanix Infrastructure on page 1051 4. Upgrade the
   Management and Managed Clusters on Other Infrastructures on page 1053

```yaml
Important: If your workload clusters are ClusterClass-based Cluster API (CAPI) clusters that are managed through
a FluxCD GitOps repository, you must follow a modified upgrade workflow. For the complete GitOps-managed
workload cluster upgrade procedure, see Upgrade Nutanix Kubernetes Platform with GitOps-Managed
Workload Clusters on page 1064.
```

### Upgrading Kommander

About this task

Before upgrading Nutanix Kubernetes Platform (NKP), upgrade Kommander to avoid
compatibility issues with the Kubernetes version supported by your current NKP
version. Always upgrade Kommander before upgrading the Kubernetes version in
attached clusters to apply any required updates for new or updated Kubernetes
APIs.

Verify that you upgrade Kommander on the correct cluster by using the
--kubeconfig=${CLUSTER_NAME}.conf flag or by setting the KUBECONFIG
environment variable. For alternative methods and best practices, see Commands
within a kubeconfig File on page 31.

NKP introduces changes to the authentication token. Earlier NKP versions
supported using the same token across clusters attached to the management
cluster. The current NKP version logs you out of attached clusters until the
upgrade completes. After the upgrade finishes, retrieve the new kubeconfig
from the endpoint and share it with all users who access the attached
clusters.

You can generate a URL to download a new kubeconfig:

- kubectl -n kommander get svc kommander-traefik -o go-
  template='`<https://{{with>` index .status.loadBalancer.ingress 0}}{{or
  .hostname .ip}}{{end}}/token/plugin/ kubeconfig{{ "\n"}}'

> **Important: During NKP upgrade, resources are limited:**

- If you configure a custom domain, services can be temporarily inaccessible
  through that domain for a few minutes while the upgrade is in progress.
- The NKP UI and other APIs can behave inconsistently or be unavailable until
  the upgrade completes.

Procedure

1. For non-air-gapped environments, run the upgrade command:

```bash
nkp upgrade kommander
Note: To disable Artificial Intelligence (AI) Navigator during the upgrade, add the flag --disable-
appdeployments ai-navigator-app to the nkp upgrade kommander command.
```

Sample output:

```bash
# Running pre-flight checks
# Fetching applications repository
# Deploying base resources
# Persisting registry credentials for OCI Artifacts
# Deploying Flux
```

1. For air-gapped environments, run the upgrade command with the repository
   path:

```bash
nkp upgrade kommander --kommander-applications-repository ./application-repositories/
kommander-applications-nkp-version.tar.gz
```

> **Note:**

- Run this command from the root of the extracted air-gapped bundle. The CLI
  relies on relative paths to locate charts and application bundles.
- If you run the command from the CLI directory where the binary is located,
  adjust the path to the air-gapped bundle based on your current working
  directory.

Sample output:

```bash
# Running pre-flight checks (2)
# Fetching applications repository (2)
# Deploying base resources (2)
# Persisting registry credentials for OCI Artifacts (2)
# Deploying Flux (2)
```

### Upgrading Platform Applications on Managed and Attached Clusters

About this task

Upgrade platform applications on managed or attached clusters by upgrading the
workspace. Complete the workspace upgrades on all additional clusters before
you upgrade the Kubernetes version. Platform applications from the earlier NKP
version are not compatible with the Kubernetes version included in the current
NKP version, so upgrading platform applications is a required step in the NKP
upgrade process.

```yaml
Note: For the management cluster, the nkp upgrade command upgrades all platform applications automatically in
the kommander workspace namespace.
```

To upgrade all platform applications in a workspace and its projects to the
same version as the platform applications running on the management cluster,
follow these steps:

Procedure

1. Get the WORKSPACE_NAME of your workspace:

```bash
nkp get workspaces
```

Sample output:

```bash
NAME NAMESPACE
default-workspace kommander-default-workspace
kommander-workspace kommander
temp-gspsh temp-gspsh-b5jgw
```

1. Set the WORKSPACE_NAME environment variable to the name of the workspace
   that hosts the managed or attached cluster:

For example, replace the WORKSPACE_NAME variable with the values returned in
the nkp get workspaces command output.

| export WORKSPACE NAME= \_ | workspace name \_ | Col3 |
| ------------------------- | ----------------- | ---- |

1. Upgrade all platform applications in a workspace:

```bash
nkp upgrade workspace ${WORKSPACE_NAME}
```

For example, replace the WORKSPACE_NAME variable with the values returned in
the nkp get workspaces command output.

Sample output:

```bash
# Updating 1 workload cluster(s) to platform version NKP version
...
```

### Upgrading Management and Managed Clusters on Nutanix Infrastructure

Before you begin

Before upgrading any Nutanix cluster, verify that the environment meets the
following requirements:

- Verify that your Nutanix environment meets all upgrade requirements. For
  more information, see Nutanix Infrastructure Requirements on page 719.
- Create or verify the VM image availability:
- The image must match the Kubernetes version of the current NKP version.
- If you use a pre-built image, select the image that is included with your
  current NKP version.
- If you create your own image, use the same nkp executable to run upgrade
  cluster nutanix. For more information, see Nutanix Image Builder on page 51.
- Upload the VM image to Prism Central.

The nkp upgrade cluster nutanix command references the image by name, so the
image must exist in Prism Central before you run the upgrade. For information
on how to upload images, see Importing Images to Prism Central.

> **Note: Do not rename the image downloaded from the Nutanix Support Portal.**

- Upgrade the management cluster before upgrading any managed cluster. Each
  NKP version updates the cluster management software. This software is
  applied when you upgrade the management cluster.
- Verify that your KUBECONFIG environment variable points to the kubeconfig
  for the management cluster.

About this task

You can upgrade NKP clusters deployed on Nutanix AHV using the upgrade cluster
nutanix command. Most clusters use the same VM image for both the control
plane and worker nodes, requiring only one VM image name during the upgrade.
However, some clusters use different VM images for their control plane and
worker nodes. In those cases, you must provide multiple VM image names, one
for each node type, to complete the upgrade successfully.

You can also upgrade multiple worker node pools in parallel. The
topology.cluster.x-k8s.io/upgrade- concurrency annotation on the cluster
object controls the number of parallel worker pools upgrades.

- If the annotation is not available, the default value is 1, and NKP upgrades
  one worker node pool at a time.
- If you set the value to 3, up to three worker pools upgrade simultaneously.

Verify that your upgrades adhere to pod scheduling requirements. For more
information, see Pod disruption budgets.

To upgrade a Nutanix cluster that uses same or multiple VM images, follow
these steps:

Procedure

1. If your Nutanix cluster uses the same VM image for both control plane and
   worker nodes, follow these steps:

a. Upgrade the management cluster:

```bash
export MANAGEMENT_CLUSTER_NAME=$(kubectl get -n kommander nkpcluster -l
'kommander.d2iq.io/host=true' -o jsonpath='{.items[0].metadata.name}')
export VM_IMAGE_NAME=<name of the Nutanix image to use>
nkp upgrade cluster nutanix \
--cluster-name ${MANAGEMENT_CLUSTER_NAME} \
--vm-image ${VM_IMAGE_NAME}
```

Sample output:

```bash
# Upgrading CAPI components
# Updating ClusterClass resources
# Upgrading the cluster
```

Upgrading the management cluster performs the following actions:

- Upgrades the CAPI components that manage the clusters.
- Updates ClusterClass resources, that defines the configuration metadata
  shared across clusters.
- Upgrades addons such as CNI and CSI on the management cluster.
- Upgrades the control plane to use the new VM image and the new Kubernetes
  version.
- Upgrades worker pools, one pool at a time to use the new VM image and the
  new Kubernetes version.

b. Upgrade the managed cluster:

1. List all clusters:

```bash
kubectl get nkpclusters -A
```

Sample output:

```bash
NAMESPACE NAME CLUSTERCLASS PHASE AGE
VERSION
default nkp-mgt Provisioned 5d18h
demo-zone-c4zz7-qjq6g demo-prod-01 nkp-nutanix Provisioned 3d1h
v<kubernetes-version>
```

1. Upgrade the managed cluster:

```bash
nkp upgrade cluster nutanix \
--cluster-name ${WORKLOAD_CLUSTER_NAME} \
--vm-image ${VM_IMAGE_NAME} -n ${WORKLOAD_CLUSTER_NAMESPACE}
```

For example, replace the WORKLOAD_CLUSTER_NAME and WORKLOAD_CLUSTER_NAMESPACE
variables with the values returned in the kubectl get nkpclusters -A command
output:

```bash
WORKLOAD_CLUSTER_NAME=demo-prod-01
WORKLOAD_CLUSTER_NAMESPACE=demo-zone-c4zz7-qjq6g
```

Sample output:

```bash
# Upgrading the cluster (2)
```

Upgrading the managed cluster performs the following actions:

- Upgrades the control plane to use the new VM image and the new Kubernetes
  version.
- Upgrades worker pools, one pool at a time to use the new VM image and the
  new Kubernetes version.
- Upgrades addons such as CNI and CSI on the managed cluster.

When you run the command nkp upgrade cluster nutanix, NKP performs a series of
preflight checks to prevent common issues with cluster upgrades. For more
information, see Preflight Checks on page 747. 2. If your Nutanix cluster uses
different VM images for both control plane and worker node pools, follow these
steps:

a. List the worker node pools for your cluster:

```bash
nkp get nodepools \
--cluster-name ${CLUSTER_NAME} -n ${WORKLOAD_CLUSTER_NAMESPACE}
```

Sample output:

```bash
NODEPOOL DESIRED READY KUBERNETES VERSION
md-0 5 5 v<kubernetes-
version>
other 3 3 v<kubernetes-
version>
```

b. Set the worker pool names as environment variables:

```bash
export WORKER_POOL_1_NAME=md-0
export WORKER_POOL_2_NAME=other
```

c. Upgrade the cluster:

```bash
nkp upgrade cluster nutanix \
--cluster-name ${CLUSTER_NAME} \
-n ${WORKLOAD_CLUSTER_NAMESPACE} \
--control-plane-vm-image ${CONTROL_PLANE_VM_IMAGE_NAME} \
--worker-vm-images
${WORKER_POOL_1_NAME}=${WORKER_POOL_1_VM_IMAGE_NAME},${WORKER_POOL_2_NAME}=
${WORKER_POOL_2_VM_IMAGE_NAME}
```

For example, WORKER_POOL_1_NAME and WORKER_POOL_2_NAME variables are the
worker node pool names returned from the nkp get nodepools command output.

### Upgrade the Management and Managed Clusters on Other Infrastructures

Upgrade NKP management and managed clusters on all infrastructures other than
Nutanix AHV as follows:

#### Upgrading CAPI Components on the Management Cluster

- Upgrading Core Addons on the Management Cluster on page 1054
- Upgrading Kubernetes Version on the Management Cluster on page 1056
- Upgrading Core Addons on Managed Clusters on page 1060
- Upgrading Kubernetes Version on Workload Clusters on page 1061

Before you begin

- Verify that your nkp configuration points to the correct management cluster
  by setting the KUBECONFIG environment variable or by using the --kubeconfig
  flag following Kubernetes conventions.
- If you manage multiple management clusters, repeat this upgrade procedure
  for each cluster.

> **Note:**

- For a Pre-provisioned air-gapped environment only, ensure you uploaded the
  artifacts.
- For air-gapped environment only, ensure you have created the air-gapped
  bundle correctly: Preparing Air-Gapped Environments for Upgrade on page 1045.

About this task

To upgrade CAPI components, follow these steps:

Procedure

1. Upgrade the CAPI components:

```bash
nkp upgrade capi-components
```

Sample output:

```bash
# Upgrading CAPI components (2)
# Waiting for CAPI components to be upgraded
# Initializing new CAPI components
```

1. (Optional) When you create CAPI components using specific flags, reuse
   those same flags during the upgrade to preserve existing values while
   applying new ones.

Reusing the flag is particularly important for the following flags:

- --with-aws-bootstrap-credentials
- --aws-service-endpoints

For flag descriptions, refer to the nkp create cluster aws CLI documentation.
For more information about the HTTP proxy configuration, see Cluster Creation
with HTTP or HTTPS Proxy on page 699.

What to do next

If the upgrade fails, review the prerequisites in Plan the Upgrade on page 1042.

#### Upgrading Core Addons on the Management Cluster

Before you begin

- Complete the CAPI component upgrade before upgrading core addons.
- Verify that your nkp configuration points to the correct management cluster
  by setting the KUBECONFIG environment variable or by using the --kubeconfig
  flag following Kubernetes conventions.
- If you have multiple managed clusters, repeat this procedure for each cluster.

> **Note:**

- For a Pre-provisioned air-gapped environment only, ensure you uploaded the
  artifacts.
- For air-gapped environment only, ensure you have created the air-gapped
  bundle correctly: Preparing Air-Gapped Environments for Upgrade on page 1045.

About this task

NKP installs core addons using the ClusterResourceSet of ClusterAPI. During
the upgrade process, NKP removes outdated global ClusterResourceSets and
replaces them with cluster-specific ClusterResourceSets for each cluster.

The upgrade applies new versions of the following core addons bundled with the
latest NKP release:

- Container Storage Interface (CSI)
- Container Network Interface (CNI)
- Cluster Autoscaler
- Node Feature Discovery

Each cluster now manages its own set of resources named with the cluster's
name as a suffix. For example: calico- cni-installation-my-aws-cluster.

Procedure

1. Set the cluster name as an environment variable:

```bash
export CLUSTER_NAME=<your-cluster-name>
```

Replace `<your-cluster-name>` with your actual cluster name. 2. Upgrade core
addons of the management cluster of your infrastructure provider:

```bash
nkp upgrade addons <infrastructure-provider> --cluster-name=${CLUSTER_NAME}
```

Replace `<infrastructure-provider>` with one of the following values: aws,
azure, vsphere, eks, gcp, or preprovisioned.

Example for AWS:

```bash
export CLUSTER_NAME=my-aws-cluster
nkp upgrade addons aws --cluster-name=${CLUSTER_NAME}
```

Sample output:

```bash
Generating addon resources
clusterresourceset.addons.cluster.x-k8s.io/calico-cni-installation-my-aws-cluster
upgraded
configmap/calico-cni-installation-my-aws-cluster upgraded
clusterresourceset.addons.cluster.x-k8s.io/tigera-operator-my-aws-cluster upgraded
configmap/tigera-operator-my-aws-cluster upgraded
clusterresourceset.addons.cluster.x-k8s.io/aws-ebs-csi-my-aws-cluster upgraded
configmap/aws-ebs-csi-my-aws-cluster upgraded
clusterresourceset.addons.cluster.x-k8s.io/cluster-autoscaler-my-aws-cluster upgraded
configmap/cluster-autoscaler-my-aws-cluster upgraded
clusterresourceset.addons.cluster.x-k8s.io/node-feature-discovery-my-aws-cluster
upgraded
configmap/node-feature-discovery-my-aws-cluster upgraded
clusterresourceset.addons.cluster.x-k8s.io/nvidia-feature-discovery-my-aws-cluster
upgraded
configmap/nvidia-feature-discovery-my-aws-cluster upgraded
```

The core addons are successfully upgraded with the latest versions bundled
with your NKP release. Each cluster now uses cluster-specific
ClusterResourceSets instead of global configurations. 3. (Optional) If you
previously made custom modifications to any ClusterResourceSet definitions,
reapply your configurations:

a. Generate the new addon configuration using the dry-run option:

```bash
nkp upgrade addons <infrastructure-provider> --cluster-name=${CLUSTER_NAME} --dry-
run -o yaml
```

b. Apply the customized configuration:

```bash
kubectl apply -f
Note: Custom modifications to ClusterResourceSet definitions are not preserved during the upgrade. You
must regenerate and reapply your configurations after each upgrade.
```

Additional references:

- For more information about ClusterAPI, see Kubernetes Cluster API.
- For more information about Kubernetes conventions, see Configure Access to
  Multiple Clusters.

#### Upgrading Kubernetes Version on the Management Cluster

Before you begin

- Verify that your target Kubernetes version is supported. For more
  information, see Supported Kubernetes Versions section in the NKP Release
  Notes.
- Verify that your operating system is compatible with the target Kubernetes
  version. For more information, see Supported Infrastructure Operating
  Systems on page 12.
- Deploy pod disruption budgets (PDBs) for critical applications to maintain
  high availability during the upgrade.
- If you have a FIPS cluster, review the additional FIPS considerations in the
  upgrade commands.

About this task

Upgrade the Kubernetes version by first upgrading the control plane, then
upgrading each worker node pool. This process maintains cluster stability and
minimizes downtime.

Procedure

1. Set the cluster name as an environment variable:

```bash
export CLUSTER_NAME=<your-cluster-name>
```

Replace `<your-cluster-name>` with your actual management cluster name. 2.
Create new AMIs or VM images with the target Kubernetes version.

Verify that you select an operating system that matches the current supported
version and build a new image if required.

- If an AMI was specified when initially creating a cluster for AWS, you must
  build a new one AWS: Using Nutanix Image Builder and set the flag(s) in the
  update commands. Either AMI ID --ami AMI_ID, or the lookup image flags:
  --ami-owner AWS_ACCOUNT_ID, --ami-base-os ubuntu-OS-version, and -- ami-
  format 'example-{{.BaseOS}}-?{{.K8sVersion}}-\*'.

> **Warning: The AMI lookup method will return an error if the lookup uses
> the upstream CAPA account ID.**

- If an Azure Machine Image was specified for Azure, you must build a new one
  with Building a Custom Image with Azure on page 61.
- If a vSphere template Image was specified for vSphere, you must build a new
  one with Building a Custom Image with vSphere on page 64.
- You must build a new GCP image with Building a Custom Image with GCP on page 63.

1. Upgrade the control plane to the new VM image and Kubernetes version using
   the appropriate command for your infrastructure provider:

- AWS:

```bash
nkp update controlplane aws --cluster-name=${CLUSTER_NAME} --kubernetes-
version=v<kubernetes-version>
```

- AWS AMI ID Lookup:

```bash
nkp update controlplane aws \
--cluster-name=${CLUSTER_NAME} \
--ami-owner AWS_ACCOUNT_ID \
--ami-base-os ubuntu-OS-version \
--ami-format 'example-{{.BaseOS}}-?{{.K8sVersion}}-*' \
--kubernetes-version=v<kubernetes-version>
Note: If you created the initial cluster with a custom AMI using the --ami flag, include the same --ami flag
during the Kubernetes upgrade.
```

- Azure:

```bash
nkp update controlplane azure --cluster-name=${CLUSTER_NAME} --kubernetes-
version=v<kubernetes-version> --compute-gallery-id <Azure Compute Gallery built by
NIB for Kubernetes v<kubernetes-version>>
```

If you specified the --plan-offer, --plan-publisher, and --plan-sku fields in
the override file during image creation, include the same flags during
upgrade.

For example:

```bash
--plan-offer rockylinux-OS-version
--plan-publisher erockyenterprisesoftwarefoundationinc1653071250513
--plan-sku rockylinux-OS-version
```

- vSphere:

```bash
nkp update controlplane vsphere --cluster-name=${CLUSTER_NAME} --kubernetes-
version=v<kubernetes-version> --vm-template <vSphere template built by NIB for
Kubernetes v<kubernetes-version>>
```

| --ami-base-os ubuntu- | OS-version |
| --------------------- | ---------- |

- GCP:

```bash
nkp update controlplane gcp --cluster-name=${CLUSTER_NAME} --kubernetes-
version=v<kubernetes-version> --image=projects/${GCP_PROJECT}/global/images/<GCP
image built by NIB for Kubernetes v<kubernetes-version>>
```

- Pre-Provisioned:

```bash
nkp update controlplane preprovisioned --cluster-name=${CLUSTER_NAME} --
kubernetes-version=v<kubernetes-version>
```

- Additional Considerations for upgrading a FIPS cluster:

If you upgrade a FIPS cluster, upgrade the supported Kubernetes version of the
cluster:

```bash
nkp update controlplane aws --cluster-name=${CLUSTER_NAME} --kubernetes-
version=v<kubernetes-version>+fips.0 --ami=<ami-with-fips-id>
```

Sample output:

```bash
Updating control plane resource controlplane.cluster.x-k8s.io/v1beta1,
Kind=KubeadmControlPlane
default/my-aws-cluster-control-plane
Waiting for control plane update to finish.
# Updating the control plane
```

> **Note:**

- View all available options for your infrastructure provider:

```bash
nkp update controlplane aws|vsphere|preprovisioned|azure|gcp|eks --help
```

For example, to view more advance options for AWS AMI instance:

```bash
aws: --ami, --instance-type
```

- The nkp update controlplane command has a default timeout of 30 minutes. If
  you receive a "timed out waiting for the condition" error, check the control
  plane node versions before retrying:

```bash
kubectl get machines -o wide $KUBECONFIG
```

1. Upgrade the worker node pools to match the control plane Kubernetes version.

Upgrading a node pool drains existing nodes and replaces them with new nodes.
This process maintains high availability when you have pod disruption budgets
(PDBs) configured for critical applications. For more information, see
Updating Pod Disruption Budget on page 1038.

a. Obtain a list of all node pools available in your cluster:

```bash
nkp get nodepool --cluster-name ${CLUSTER_NAME} -n kommander
Note: Starting in NKP 2.18, the management cluster runs in the kommander namespace. Include -n
kommander in all nodepool commands that target the management cluster. In NKP 2.17 and earlier, this flag
was not required.
```

b. Select the node pool to upgrade:

```bash
export NODEPOOL_NAME=my-nodepool
```

c. Upgrade the selected node pool using the appropriate command for your
infrastructure provider:

```yaml
Note: If you created the initial cluster with a custom AMI using the --ami flag, include the same --ami flag
during the Kubernetes upgrade.
```

- AWS:

```bash
nkp update nodepool aws ${NODEPOOL_NAME} --cluster-name=${CLUSTER_NAME} -n
kommander --kubernetes-version=v<kubernetes-version>
```

- Azure:

```bash
nkp update nodepool azure ${NODEPOOL_NAME} --cluster-name=${CLUSTER_NAME} -
n kommander --kubernetes-version=v<kubernetes-version> --compute-gallery-id
<Azure Compute Gallery built by NIB for Kubernetes v<kubernetes-version>>
```

If you specified the --plan-offer, --plan-publisher, and --plan-sku fields in
the override file during image creation, include the same flags during
upgrade. For more information, see Azure: Creating an Image on page 252.

- vSphere:

```bash
nkp update nodepool vsphere ${NODEPOOL_NAME} --cluster-name=${CLUSTER_NAME} -
n kommander --kubernetes-version=v<kubernetes-version> --vm-template <vSphere
template built by NIB for Kubernetes v<kubernetes-version>>
```

- GCP:

```bash
nkp update nodepool gcp ${NODEPOOL_NAME} --cluster-name=${CLUSTER_NAME} -
n kommander --kubernetes-version=v<kubernetes-version> --image=projects/
${GCP_PROJECT}/global/images/<GCP image built by NIB for Kubernetes
v<kubernetes-version>>
```

- Pre-provisioned:

```bash
nkp update nodepool preprovisioned ${NODEPOOL_NAME} --cluster-name=
${CLUSTER_NAME} -n kommander --kubernetes-version=v<kubernetes-version>
```

- Additional Considerations for upgrading a FIPS cluster:

If you upgrade a FIPS cluster, upgrade the supported Kubernetes version of the
cluster:

```bash
nkp update nodepool aws ${NODEPOOL_NAME} --cluster-name=${CLUSTER_NAME} -n
kommander --kubernetes-version=v<kubernetes-version>+fips.0 --ami=<ami-with-
fips-id>
```

Sample output:

```bash
Updating node pool resource cluster.x-k8s.io/v1beta1, Kind=MachineDeployment
default/my-aws-cluster-my-nodepool
Waiting for node pool update to finish.
# Updating the my-aws-cluster-my-nodepool node pool
```

Repeat step 4 for each additional node pool in your cluster. 5. Verify that
the upgrade completed successfully:

```bash
kubectl get nodes
```

Verify that all nodes show the new Kubernetes version in the VERSION column.

The management cluster control plane and all worker node pools are
successfully upgraded to the target Kubernetes version.

What to do next

After upgrading the management cluster, upgrade any additional managed or
attached clusters:

- For managed clusters, upgrade both the core addons and the Kubernetes version.
- For attached clusters, upgrade the Kubernetes version to a supported Nutanix
  Kubernetes Platform (NKP) version using the tool that created the cluster.

#### Upgrading Core Addons on Managed Clusters

Before you begin

1. Complete the management cluster upgrade process, including CAPI components
   and core addons. 2. Upgrade platform applications on all workspace clusters.
   For more information, see Upgrading Platform Applications on Managed and
   Attached Clusters on page 1050.

About this task

To upgrade core addons on each managed cluster, follow these steps:

Procedure

1. To identify the clusters that you need to upgrade, list all managed clusters:

```bash
kubectl get nkpclusters -A
```

Sample output:

```bash
NAMESPACE NAME CLUSTERCLASS PHASE AGE VERSION
default nkp-mgmt Provisioned 5d18h
demo-zone-c4zz7-qjq6g demo-prod-01 nkp-nutanix Provisioned 3d1h
v<kubernetes-version>
demo-zone-c4zz7-qjq6g demo-staging nkp-nutanix Provisioned 2d1h
v<kubernetes-version>
```

Note the cluster names and their corresponding namespaces for the managed
clusters. 2. Set the environment variables for your managed cluster:

```bash
export CLUSTER_NAME=<your-workload-cluster-name>
export CLUSTER_NAMESPACE=<your-workspace-namespace>
```

Replace `<your-workload-cluster-name>` and `<your-workspace-namespace>` with
the values with the values returned in the kubectl get nkpclusters -A command
output.

For example:

```bash
export CLUSTER_NAME=demo-prod-01
export CLUSTER_NAMESPACE=demo-zone-c4zz7-qjq6g
```

1. Upgrade the core addons:

```bash
nkp upgrade addons <infrastructure-provider> --cluster-name=${CLUSTER_NAME} -n
${CLUSTER_NAMESPACE}
```

Replace `<infrastructure-provider>` with one of the following values: aws,
azure, vsphere, eks, gcp, or preprovisioned.

For example:

```bash
nkp upgrade addons aws --cluster-name=${CLUSTER_NAME} -n ${CLUSTER_NAMESPACE}
```

Repeat these steps for each additional managed cluster that requires core
addon upgrades.

Update the CLUSTER_NAME and CLUSTER_NAMESPACE environment variables for each
cluster and run the appropriate upgrade command.

#### Upgrading Kubernetes Version on Workload Clusters

Before you begin

- Complete the management cluster upgrade before upgrading any workload
  clusters.
- Verify that your target Kubernetes version is supported. For more
  information, see Supported Kubernetes Versions section in the NKP Release
  Notes.

About this task

Upgrade the Kubernetes version by first upgrading the control plane, then
upgrading each worker node pool. This process maintains cluster stability and
minimizes downtime for workload clusters.

Procedure

1. Set the environment variables for the workload cluster:

```bash
export CLUSTER_NAME=<your-workload-cluster-name>
export CLUSTER_NAMESPACE=<your-workspace-namespace>
```

Replace `<your-workload-cluster-name>` and `<your-workspace-namespace>` with
your actual cluster name and namespace. 2. Upgrade the control plane to the
new Kubernetes version using the appropriate command for your infrastructure
provider:

- AWS:

```bash
nkp update controlplane aws --cluster-name=${CLUSTER_NAME} --kubernetes-
version=v<kubernetes-version> -n ${CLUSTER_NAMESPACE}
```

- EKS:

NKP supports creating an EKS cluster with Kubernetes version 1.34 or later:

```bash
nkp upgrade cluster eks --cluster-name=${CLUSTER_NAME}
Note: NKP does not support upgrading non-ClusterClass EKS clusters. You must manually migrate all
applications that are currently running on older, non-ClusterClass EKS clusters to a newly provisioned
ClusterClass-based EKS clusters.
```

For more information on migrating your applications, see the KB-[Number]

- Azure:

```bash
nkp update controlplane azure --cluster-name=${CLUSTER_NAME} --kubernetes-
version=v<kubernetes-version> --compute-gallery-id <Azure Compute Gallery built by
NIB for Kubernetes v<kubernetes-version>> -n ${CLUSTER_NAMESPACE}
```

- vSphere:

```bash
nkp update controlplane vsphere --cluster-name=${CLUSTER_NAME} --kubernetes-
version=v<kubernetes-version> --vm-template <vSphere template built by NIB for
Kubernetes v<kubernetes-version>> -n ${CLUSTER_NAMESPACE}
```

- GCP:

```bash
nkp update controlplane gcp --cluster-name=${CLUSTER_NAME} --kubernetes-
version=v<kubernetes-version> --image=projects/${GCP_PROJECT}/global/images/<GCP
image built by NIB for Kubernetes v<kubernetes-version>> -n ${CLUSTER_NAMESPACE}
```

- Pre-provisioned:

```bash
nkp update controlplane preprovisioned --cluster-name=${CLUSTER_NAME} --
kubernetes-version=v<kubernetes-version> -n ${CLUSTER_NAMESPACE}
```

1. List all node pools in your cluster:

```bash
nkp get nodepools --cluster-name ${CLUSTER_NAME} -n ${CLUSTER_NAMESPACE}
```

Sample output:

```bash
NODEPOOL DESIRED READY KUBERNETES VERSION
md-0 3 3 v<kubernetes-
version>
worker-pool-1 2 2 v<kubernetes-
version>
```

1. Set the node pool name as an environment variable:

```bash
export NODEPOOL_NAME=<your-nodepool-name>
```

Replace `<your-nodepool-name>` with the name of the node pool returned in the
nkp get nodepools command output: 5. Upgrade the node pool to match the
control plane Kubernetes version using the appropriate command for your
infrastructure provider:

- AWS:

```bash
nkp update nodepool aws ${NODEPOOL_NAME} --cluster-name=${CLUSTER_NAME} --
kubernetes-version=v<kubernetes-version> -n ${CLUSTER_NAMESPACE}
```

- EKS:

NKP supports creating an EKS cluster with Kubernetes version 1.34 or later:

```bash
nkp upgrade cluster eks --cluster-name=${CLUSTER_NAME}
Note: NKP does not support upgrading non-ClusterClass EKS clusters. You must manually migrate all
applications that are currently running on older, non-ClusterClass EKS clusters to a newly provisioned
ClusterClass-based EKS clusters.
```

For more information on migrating your applications, see the KB-[Number].

- Azure:

```bash
nkp update nodepool azure ${NODEPOOL_NAME} --cluster-name=${CLUSTER_NAME}
--kubernetes-version=v<kubernetes-version> --compute-gallery-id <Azure
Compute Gallery built by NIB for Kubernetes v<kubernetes-version>> -n
${CLUSTER_NAMESPACE}
```

- vSphere:

```bash
nkp update nodepool vsphere ${NODEPOOL_NAME} --cluster-name=${CLUSTER_NAME} --
kubernetes-version=v<kubernetes-version> --vm-template <vSphere template built by
NIB for Kubernetes v<kubernetes-version>> -n ${CLUSTER_NAMESPACE}
```

- GCP:

```bash
nkp update nodepool gcp ${NODEPOOL_NAME} --cluster-name=${CLUSTER_NAME} --
kubernetes-version=v<kubernetes-version> --image=projects/${GCP_PROJECT}/
global/images/<GCP image built by NIB for Kubernetes v<kubernetes-version>> -n
${CLUSTER_NAMESPACE}
```

- Pre-provisioned:

```bash
nkp update nodepool preprovisioned ${NODEPOOL_NAME} --cluster-name=${CLUSTER_NAME}
--kubernetes-version=v<kubernetes-version> -n ${CLUSTER_NAMESPACE}
```

Repeat step 5 for each additional node pool in your cluster. 6. Verify that
the upgrade completed successfully:

```bash
kubectl get nodes
```

Verify that all nodes show the new Kubernetes version in the VERSION column.

The managed cluster control plane and all worker node pools are successfully
upgraded to the target Kubernetes version.

What to do next

Nutanix Kubernetes Platform (NKP) does not upgrade components on attached
clusters because their respective cloud providers manage them. The tool that
you originally used to create the managed clusters also upgrades them. Before
upgrading, verify that the tool supports a compatible Kubernetes version.

Upgrade Nutanix Kubernetes Platform with GitOps-Managed Workload Clusters

Upgrade Nutanix Kubernetes Platform (NKP) when your workload clusters are
GitOps-managed by following a modified workflow that includes a GitOps
migration step. The workflow transitions your GitOps repository from managing
cluster API CAPICluster resources to managing NKPCluster resources.

NKP introduces a unified cluster management model built on two new components
NKPCluster custom resource definition (CRD) and a corresponding admission
webhook.

The NKPCluster resource wraps the configuration of a CAPICluster and a
KommanderCluster into a single resource and it defines the following major
fields:

spec.capiCluster Contains the CAPICluster topology, including the ClusterClass
reference, the Kubernetes version, the cluster network, control plane
replicas, and worker machine deployments.

spec.kommanderCluster Contains the KommanderCluster configuration that governs
platform application management.

spec.version Records the NKP platform version.

A sample NKPCluster resource structure:

```yaml
apiVersion: clusters.nkp.nutanix.com/v1alpha1
kind: NKPCluster
metadata:
name: <cluster-name>
namespace: <namespace>
labels:
cluster.x-k8s.io/cluster-name: <cluster-name>
cluster.x-k8s.io/provider: nutanix
spec:
# CAPI Cluster topology - replaces the standalone CAPI Cluster resource
capiCluster:
clusterNetwork:
pods:
cidrBlocks:
- 192.168.0.0/16
services:
cidrBlocks:
- 10.96.0.0/12
topology:
classRef:
name: nkp-nutanix-v2.18.0 # ClusterClass version
version: v1.35.2 # Kubernetes version
controlPlane:
replicas: 3
variables:
- name: clusterConfig
value: # ... cluster configuration variables ...
workers:
machineDeployments:
- class: default-worker
name: md-0 # ... worker configuration ...
# Reference to the auto-created CAPI Cluster (managed by NKPCluster controller)
capiClusterRef:
name: <cluster-name>
namespace: <namespace>
# KommanderCluster configuration for platform application management
kommanderCluster:
spec:
clusterRef:
capiCluster:
name: <cluster-name>
namespace: <namespace>
kubeconfigRef:
name: <cluster-name>-kubeconfig
# Reference to the auto-created KommanderCluster
kommanderClusterRef:
name: <cluster-name>
namespace: <namespace>
# NKP platform version
version: v2.18.0
```

The NKPCluster controller creates the underlying CAPICluster and
KommanderCluster from the NKPCluster specification and continuously reconciles
them. As a result, the NKPCluster resource is the single source of truth for
cluster lifecycle operations.

The admission webhook rejects any direct modification to the spec.topology
field of a managed CAPICluster, regardless of whether the request originates
from kubectl, another controller, or a GitOps tool such as Flux. Only the
NKPCluster controller can update the topology.

Upgrade Sequence for GitOps-Managed Workload Clusters

If your workload clusters are ClusterClass-based CAPI clusters that you manage
through a FluxCD GitOps repository, you must migrate the repository to manage
NKPCluster resources. The upgrade procedure for these clusters includes a
GitOps migration step in addition to the standard upgrade workflow. Upgrade
your NKP environment in the following sequence to avoid compatibility issues:

### Disabling Flux Pruning

About this task

After you upgrade GitOps-managed workload clusters, an admission webhook
blocks Flux from applying CAPICluster resources directly. If spec.prune is set
to true on the Flux Kustomization that manages your workload cluster, removing
the CAPICluster YAML from Git during the migration causes Flux to delete the
live workload cluster. To prevent this issue, disable pruning on the Flux
Kustomization that manages the workload cluster, before you start the upgrade.

> **Note: Skip this procedure if spec.prune is already set to false on the
> Flux Kustomization.**

To disable Flux pruning, follow these steps:

Procedure

1. Disable the prune based on the option that matches how your Flux
   Kustomization is managed.

- If the Flux Kustomization was applied manually, patch it directly instead of
  updating the YAML in Git:

```bash
kubectl patch kustomization <kustomization-name> -n <namespace> \
--type merge -p '{"spec":{"prune":false}}'
```

- If the Flux Kustomization is reconciled by a parent Kustomization through
  GitOps, follow these steps:

1. Update spec.prune to false in the Kustomization YAML in your Git
   repository. 2. Commit the change to your local repository. 3. Push the
   commit to the remote repository

Wait for Flux to reconcile the change on the cluster. 2. Verify that pruning
is disabled on the Flux Kustomization:

```bash
kubectl get kustomization <kustomization-name> -n <namespace> \
-o jsonpath='{.spec.prune}'
```

The expected output is false.

### Upgrading Kommander (2)

Before you begin

Ensure that the flux pruning is disable before you start the Kommander
upgrade. For more information, see Disabling Flux Pruning on page 1065.

About this task

Upgrade Kommander to avoid compatibility issues with the Kubernetes version
supported by your current NKP version. Always upgrade Kommander before
upgrading the Kubernetes version in attached clusters to apply any required
updates for new or updated Kubernetes APIs.

Verify that you upgrade Kommander on the correct cluster by using the
--kubeconfig=${CLUSTER_NAME}.conf flag or by setting the KUBECONFIG
environment variable. For alternative methods and best practices, see Commands
within a kubeconfig File on page 31.

> **Important: During NKP upgrade, resources are limited:**

- If you configure a custom domain, services can be temporarily inaccessible
  through that domain for a few minutes while the upgrade is in progress.
- The NKP UI and other APIs can behave inconsistently or be unavailable until
  the upgrade completes.

To upgrade Kommander, follow these steps:

Procedure

1. In non-air-gapped environments, run the upgrade command:

```bash
nkp upgrade kommander
Note: (Optional) To disable Artificial Intelligence (AI) Navigator during the upgrade, add the flag --disable-
appdeployments ai-navigator-app to the nkp upgrade kommander command.
```

Sample output:

```bash
# Running pre-flight checks (3)
# Fetching applications repository (3)
# Deploying base resources (3)
# Persisting registry credentials for OCI Artifacts (3)
# Deploying Flux (3)
```

1. In air-gapped environments, run the upgrade command with the repository path:

```bash
nkp upgrade kommander --kommander-applications-repository ./application-repositories/
kommander-applications-nkp-version.tar.gz
```

> **Note:**

- Run this command from the root of the extracted air-gapped bundle. The CLI
  relies on relative paths to locate charts and application bundles.
- If you run the command from the CLI directory where the binary is located,
  adjust the path to the air-gapped bundle based on your current working
  directory.

Sample output:

```bash
# Running pre-flight checks (4)
# Fetching applications repository (4)
# Deploying base resources (4)
# Persisting registry credentials for OCI Artifacts (4)
# Deploying Flux (4)
```

The nkp upgrade kommander command performs the following additional actions
when you upgrade GitOps- managed workload clusters:

- Installs the NKPCluster custom resource definition (CRD) and controllers.
- Registers new admission webhooks.
- Auto-adopts existing ClusterClass-based CAPI Cluster resources into
  NKPCluster resources.

After the Kommander upgrade completes, Flux reconciliation of CAPI Cluster
resources fails with webhook rejection errors on GitOps-managed workload
clusters. This behavior is expected and is resolved when you migrate the
GitOps repository to manage NKPCluster resources. For more information, see
Migrating the GitOps Repository and Upgrading Workload Clusters on page 1070.

### Upgrading Platform Applications

About this task

When you upgrade GitOps-managed workload clusters, you must upgrade platform
applications on all workspaces that host GitOps-managed workload clusters.
Platform applications from the earlier Nutanix Kubernetes Platform (NKP)
version are not compatible with the Kubernetes version included in the current
NKP version, so upgrading platform applications is a required step before the
Kubernetes upgrade.

```yaml
Note: For the management cluster, the nkp upgrade command upgrades all platform applications automatically in
the kommander workspace namespace.
```

To upgrade platform operations, follow these steps:

Procedure

1. Get the WORKSPACE_NAME of your workspace:

```bash
nkp get workspaces
```

Sample output:

```bash
NAME NAMESPACE
default-workspace kommander-default-workspace
kommander-workspace kommander
temp-gspsh temp-gspsh-b5jgw
```

1. Set the WORKSPACE_NAME environment variable to the name of the workspace
   that hosts the GitOps-managed workload cluster:

For example, replace the WORKSPACE_NAME variable with the values returned in
the nkp get workspaces command output. 3. Upgrade all platform applications in
the workspace:

```bash
nkp upgrade workspace ${WORKSPACE_NAME}
```

Sample output:

```bash
# Updating 1 workload cluster(s) to platform version NKP version (2)
...
```

What to do next

After you complete the platform application upgrades for all workspaces,
upgrade the Kubernetes version on the management cluster.

### Upgrading the Kubernetes Version on the Management Cluster

Before you begin

Before upgrading the Kubernetes version any cluster, verify that the
environment meets the following requirements:

- Verify that your environment meets all upgrade requirements. For more
  information, see Plan the Upgrade on page 1042.

| export WORKSPACE NAME= \_ | workspace name \_ | Col3 |
| ------------------------- | ----------------- | ---- |

- Create or verify the VM image availability:
- The image must match the Kubernetes version of the current Nutanix
  Kubernetes Platform (NKP) version.
- If you use a pre-built image, select the image that is included with your
  current NKP version.
- If you create your own image, use the same nkp executable to run upgrade
  cluster. For more information, see Nutanix Image Builder on page 51.
- Upgrade the management cluster before upgrading any managed cluster. Each
  NKP version updates the cluster management software. This software is
  applied when you upgrade the management cluster.
- Verify that your KUBECONFIG environment variable points to the kubeconfig
  for the management cluster.

About this task

This procedure upgrades only the management cluster infrastructure and
prepares it for the GitOps migration that follows. NKP performs the Kubernetes
upgrade for the GitOps-managed workload cluster during the GitOps migration.

You can upgrade NKP clusters deployed on Nutanix AHV using the upgrade cluster
nutanix command. Most clusters use the same VM image for both the control
plane and worker nodes, requiring only one VM image name during the upgrade.
However, some clusters use different VM images for their control plane and
worker nodes. In those cases, you must provide multiple VM image names, one
for each node type, to complete the upgrade successfully.

You can also upgrade multiple worker node pools in parallel. The
topology.cluster.x-k8s.io/upgrade- concurrency annotation on the cluster
object controls the number of parallel worker pools upgrades:

- If the annotation is not available, the default value is 1, and NKP upgrades
  one worker node pool at a time.
- If you set the value to 3, up to three worker pools upgrade simultaneously.

Verify that your upgrades adhere to pod scheduling requirements. For more
information, see Pod disruption budgets.

To upgrade the Kubernetes version on a Nutanix cluster that uses same or
multiple VM images, follow these steps:

Procedure

1. If your Nutanix cluster uses the same VM image for both control plane and
   worker nodes, upgrade your management cluster:

```bash
export MANAGEMENT_CLUSTER_NAME=<name of your management cluster>
export VM_IMAGE_NAME=<name of the Nutanix image to use>
nkp upgrade cluster nutanix \
--cluster-name ${MANAGEMENT_CLUSTER_NAME} \
--vm-image ${VM_IMAGE_NAME}
```

Sample output:

```bash
# Upgrading CAPI components (3)
# Updating ClusterClass resources (2)
# Upgrading the cluster (3)
```

Upgrading the management cluster performs the following actions:

- Upgrades the CAPI components that manage the clusters.
- Updates ClusterClass resources that define the configuration metadata shared
  across clusters.
- Upgrades addons such as CNI and CSI on the management cluster.
- Upgrades the control plane to use the new VM image and the new Kubernetes
  version.
- Upgrades worker pools one pool at a time to use the new VM image and the new
  Kubernetes version.

1. If your Nutanix cluster uses different VM images for both control plane and
   worker node pools, follow these steps:

a. List the worker node pools for your cluster:

```bash
nkp get nodepools \
--cluster-name ${CLUSTER_NAME} -n ${WORKLOAD_CLUSTER_NAMESPACE}
```

> **Note: Set WORKLOAD_CLUSTER_NAMESPACE based on your target cluster:**

- For the management cluster on NKP 2.18 or later, set
  WORKLOAD_CLUSTER_NAMESPACE=kommander. Starting in NKP 2.18, the management
  cluster runs in the kommander namespace.
- For a workload cluster, set WORKLOAD_CLUSTER_NAMESPACE to the namespace of
  that workload cluster.

Sample output:

```bash
NODEPOOL DESIRED READY KUBERNETES VERSION
md-0 5 5 v<kubernetes-
version>
other 3 3 v<kubernetes-
version>
```

b. Set the worker pool names as environment variables:

```bash
export WORKER_POOL_1_NAME=md-0
export WORKER_POOL_2_NAME=other
```

c. Upgrade the cluster:

```bash
nkp upgrade cluster nutanix \
--cluster-name ${CLUSTER_NAME} \
-n ${WORKLOAD_CLUSTER_NAMESPACE} \
--control-plane-vm-image ${CONTROL_PLANE_VM_IMAGE_NAME} \
--worker-vm-images
${WORKER_POOL_1_NAME}=${WORKER_POOL_1_VM_IMAGE_NAME},${WORKER_POOL_2_NAME}=
${WORKER_POOL_2_VM_IMAGE_NAME}
```

For example, WORKER_POOL_1_NAME and WORKER_POOL_2_NAME variables are the
worker node pool names returned from the nkp get nodepools command output.

What to do next

After the management cluster Kubernetes upgrade completes and all nodes are
stable, migrate the GitOps repository and upgrade the workload cluster
Kubernetes versions.

### Migrating the GitOps Repository and Upgrading Workload Clusters

About this task

This procedure combines two actions in a single Git commit: migrating from a
CAPICluster resource to an NKPCluster resource in Git and upgrading the
ClusterClass and Kubernetes version of a workload cluster. The

GitOps repository migration and workload cluster upgrade happen automatically,
preventing inconsistencies between the desired state in Git and the actual
cluster configuration.

The NKPCluster controller updates the CAPICluster topology and performs the
Kubernetes upgrade. During the upgrade, the controller rolls the control plane
nodes first, then rolls the worker nodes after the control plane is healthy.

```yaml
Note: Your GitOps directory structure might differ from the structure described in this topic. It demonstrates one
possible way to organize your GitOps repository for workload clusters. Regardless of your directory structure, your
repository must contain a YAML file with the Cluster API Cluster object that represents your workload cluster instance.
```

Procedure

1. Generate the upgraded NKPCluster YAML using the nkp upgrade cluster command
   in dry-run mode:

```bash
nkp upgrade cluster --cluster-name <cluster-name> \
--namespace <namespace> \
--kubeconfig <management-kubeconfig> \
--dry-run -o yaml > nkpcluster-upgrade.yaml
```

The command generates an NKPCluster resource YAML file that contains the
upgraded ClusterClass version, Kubernetes version, OS image references, and
other required changes. 2. Review the generated YAML file to verify the
upgrade configuration:

- Updated spec.capiCluster.topology.classRef.name to a new ClusterClass version
- Updated spec.capiCluster.topology.version to a new Kubernetes version
- Updated OS image references
- All other required changes for the new Nutanix Kubernetes Platform (NKP)
  version

1. Clean up the generated YAML file by removing server-side fields that you
   need not store in Git:

- metadata.resourceVersion
- metadata.uid
- metadata.creationTimestamp
- metadata.generation
- metadata.managedFields
- status

1. Retain the following server-side fields that you need to store in Git:

- metadata.name
- metadata.namespace
- metadata.labels
- metadata.annotations

1. Replace the contents of your existing cluster.yaml file or an equivalent
   file with the cleaned NKPCluster YAML:

The directory structure after migration might look as follows:

```bash
clusters/
### <namespace>_<cluster-name>/
### kustomization.yaml
### cluster.yaml # Now contains NKPCluster (not CAPI Cluster)
Tip: If you prefer clearer naming, rename the file to nkpcluster.yaml and update the
kustomization.yamlof the cluster accordingly.
```

1. Commit and push the changes to your Git repository:

```bash
git add clusters/<namespace>_<cluster-name>/cluster.yaml
git commit -m "Migrate <cluster-name> to NKPCluster and upgrade to NKP 2.18"
git push
```

What to do next

Wait for Flux to reconcile the changes. The GitOps migration and workload
cluster upgrade performs the following actions:

1. The NKPCluster controller updates the CAPI Cluster topology. 2. The
   controller rolls the control plane nodes to the new Kubernetes version and
   ClusterClass configuration. 3. After the control plane is healthy, the
   controller rolls the worker nodes to the new configuration. 4. The workload
   cluster is upgraded with the new Kubernetes version.

After the GitOps migration and workload cluster upgrade are complete, you can
optionally re-enable Flux pruning by setting prune: true on the Flux
Kustomization, if it was disabled.

## Verifying Nutanix Kubernetes Platform Upgrade

Verify that the Nutanix Kubernetes Platform (NKP) upgrade completed
successfully by checking cluster health, addon status, control plane and node
versions, and confirming that all platform components are running as expected.

About this task

To verify that the NKP upgrade is successful, follow these steps:

Procedure

1. Verify the NKP CLI version:

```bash
nkp version
```

Confirm that the reported version matches your target upgrade version. 2.
Verify cluster and machine health:

- For management cluster:

```bash
kubectl get clusters,machines
```

- For workload cluster:

```bash
kubectl get clusters,machines -n workspace-namespace
```

Confirm the following:

- All clusters are in the Ready state and that none are currently Upgrading.
- The clusterclass and Kubernetes version correspond to your target NKP version.

1. Verify node readiness and Kubernetes versions:

```bash
kubectl get nodes
```

Confirm that all control plane and worker nodes are in Ready state and the
target Kubernetes version in the VERSION column.

```yaml
Note: When connected to the management cluster, this command shows only the management cluster nodes, not
the workload cluster nodes.
```

1. Verify system pod health across all namespaces:

```bash
kubectl get pods -A
```

Confirm that no core platform pods are stuck in CrashLoopBackOff,
ImagePullBackOff, Error, or extended Pending state. 5. For GitOps-managed
workload clusters, verify that the migration and upgrade is complete:

- Verify that an NKPCluster resource is created for each existing workload
  cluster:

```bash
kubectl get nkpclusters -A
```

Each workload cluster has a corresponding NKPCluster resource in the Ready
state.

- Verify that each GitOps-managed workload cluster in the workspace is
  reconciled to the new version of the platform application, kuberenetes
  version, cluster version:

```bash
kubectl get nkpcluster <cluster-name> -n <namespace> \
-o jsonpath='{.status.phase}'
```

During the upgrade, the NKPCluster status transitions through Reconciling...
and returns to Reconciled when the upgrade is complete.

- Check the Flux reconciliation status:
- Monitor the machine rollout to track the upgrade progress:

```bash
kubectl get machines -n <namespace> \
-l cluster.x-k8s.io/cluster-name=<cluster-name>
```

The NKPCluster controller rolls the control plane nodes first, then rolls the
worker nodes after the control plane is healthy.

## Troubleshoot Management Cluster Upgrades

Resolve common issues that might occur during management cluster and platform
application upgrades. This troubleshooting guide provides solutions for
upgrade failures, HelmRelease issues, and configuration problems.

Upgrade Failures and Timeouts

The upgrade process might fail or time out during execution.

Solution: Run the upgrade command with increased verbosity for detailed
information about the failure:

```bash
nkp upgrade kommander -v 6
```

HelmRelease Issues in Management Cluster

HelmReleases in the kommander namespace are stuck in broken states such as
"exhausted" or "another rollback/ release in progress".

| kubectl get kustomization `< | kustomization-name | >`-n`< | namespace | >`  |
| ---------------------------- | ------------------ | ------ | --------- | --- |

Solution: Trigger a reconciliation of the HelmRelease:

```bash
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": true}]'
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": false}]'
```

HelmRelease Issues in Workspace Clusters

HelmReleases in workspace namespace clusters are stuck in broken states such
as "exhausted" or "another rollback/ release in progress".

Solution: Set the workspace namespace environment variable and trigger
HelmRelease reconciliation:

1. Set the workspace namespace variable:

```bash
export WORKSPACE_NAMESPACE=<workspace-namespace>
```

1. Reconcile the HelmRelease:

```bash
kubectl --kubeconfig -n ${WORKSPACE_NAMESPACE} patch helmrelease <HELMRELEASE_NAME>
--type='json' -p='[{"op": "replace", "path": "/spec/suspend", "value": true}]'
kubectl -n ${WORKSPACE_NAMESPACE} patch helmrelease <HELMRELEASE_NAME> --type='json'
-p='[{"op": "replace", "path": "/spec/suspend", "value": false}]'
Note: The --kubeconfig flag ensures that you set the context to the Attached or Managed cluster. For alternatives
and recommendations around setting your context, see Commands within a kubeconfig File on page 31.
```

Konnector-Agent Configuration Issues

The upgrade process automatically enables the konnector-agent addon, but you
might want to disable it during the upgrade.

```yaml
Solution: Manually modify the cluster configuration after the upgrade manifest is generated. For more information,
see Disabling Automatic Onboarding During Cluster Upgrade on page 552.
```

LoggingStack GrafanaLokiV3Deployed Failure

During a platform upgrade, the logging stack controller automatically migrates
Grafana Loki from v2 to v3. As part of the migration, the controller validates
and converts existing Grafana Loki override ConfigMaps into the v3 format. If
the controller fails to convert one or more ConfigMaps, the migration blocks
and requires manual resolution.

Solution: See Troubleshooting LoggingStack GrafanaLokiV3Deployed Failure on
page 596

Flux Reconciliation Fails with Webhook Rejection

After you upgrade Kommander, Flux reconciliation of cluster API CAPICluster
resources fails with admission webhook error similar to the following:

```bash
admission webhook "webhook.nkpcluster.child.kommander.mesosphere.io" denied the
request:
spec.topology: Forbidden: CAPI Cluster topology spec is managed by NKPCluster ...
```

The admission webhook prevents direct modifications to CAPICluster resources
that the NKPCluster resources manage.

```yaml
Solution: Complete the GitOps migration to change the GitOps-managed resource from a CAPICluster to an
NKPCluster. For more information, see Migrating the GitOps Repository and Upgrading Workload Clusters on
page 1070.
```

NKPCluster Stuck in Reconciling State

The NKPCluster resource remains in a Reconciling state for an extended period
during the GitOps migration and workload cluster upgrade.

Gather diagnostic information to identify the root cause:

```bash
kubectl get nkpcluster <cluster-name> -n <namespace> -o yaml
kubectl get cluster <cluster-name> -n <namespace> -o yaml
kubectl get machines -n <namespace> -l cluster.x-k8s.io/cluster-name=<cluster-name>
Solution: Check the .status.conditions field of NKPCluster resources for specific error messages. Common
causes include missing credential secrets or image references that are not available on the Nutanix infrastructure.
```

Cluster Deletion During Migration

The CAPICluster resource is deleted unexpectedly during the GitOps migration.

If spec.prune was set to true on the Flux Kustomization and you removed the
cluster.yaml file from Git without disabling pruning first, Flux attempts to
delete the CAPICluster resource.

```yaml
Solution: Ensure that you disable Flux pruning before you upgrade the GitOps-managed workload clusters. For more
information, see Disabling Flux Pruning on page 1065.
```
