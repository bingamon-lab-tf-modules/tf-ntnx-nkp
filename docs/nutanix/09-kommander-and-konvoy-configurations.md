# Additional Kommander and Konvoy Configurations

ADDITIONAL KOMMANDER CONFIGURATION

The Kommander component of NKP can be configured differently depending on your
environment type and other desired customizations.

## Kommander Installation Based on Your Environment

The Kommander Customizations on page 996 section contains instructions for
enabling a custom configuration of a Kommander component,see such as custom
domains or certificates, an HTTP Proxy, an external load balancer, etc.

This section provides installation instructions for the Kommander component of
NKP according to your environment type.

Before you install the Kommander component, perform the following checks:

Is Your environment Air-gapped or Non-Air-gapped?

In an air-gapped environment, your environment is isolated from unsecured
networks, like the Internet.

In a non-air-gapped environment, your environment has two-way access to and
from the Internet.

For more information, see Installing Kommander in an Air-gapped Environment on
page 981 and Installing Kommander in a Non-Air-gapped Environment on page 984.

What License do you Have?

NKP Pro and NKP Government Pro are self-managed single-cluster Kubernetes
solutions that give you a feature-rich, easy-to-deploy, and easy-to-manage
entry-level cloud container platform. The NKP Pro and NKP Gov licenses give
the user access to the entire Konvoy cluster environment, as well as manage
the Kommander platform application manager.

NKP Ultimate and NKP Government Advanced are multi-cluster solutions centered
around a management cluster that manage multiple attached or managed
Kubernetes clusters through a centralized management dashboard. For this
license type, you will determine whether or not to use the Workspace Catalog
Applications on page 379.

For more information, see Licenses on page 24.

Do you want to enable NKP Insights?

NKP Insights is a predictive analytics capability that detects anomalies that
occur either in the present or future and generates an alert in the NKP UI.

For more information, see Nutanix Kubernetes Platform Insights Guide on page 1111.

Decide Whether to Install the AI Navigator Application

The AI Navigator is an AI chatbot that offers real-time, interactive
communication to answer a wide range of user queries, spanning basic
instructions to complex functionalities. NKP installs this application by
default in non-air- gapped environments. However, you can disable it, if
desired, as part of the installation of the NKP Kommander component.

Typically, we recommend that you generate a Kommander configuration file so
that you can customize the configuration prior to installing Kommander. You
can use this method to disable AI Navigator. If you prefer to use a CLI
approach to the installation, there is also a flag for disabling the
application.

> **Note: For security purposes, AI Navigator is not installed for air-
> gapped environments.**

Installation Type Based on Your Environment

Select the installation type according to your environment:

- Installing Kommander in an Air-gapped Environment on page 981
- Installing Kommander in a Non-Air-gapped Environment on page 984
- Installing Kommander in a Pre-provisioned Air-gapped Environment on page 985
- Installing Kommander in a Pre-provisioned, Non-Air-gapped Environment on
  page 989
- Installing Kommander in a Small Environment on page 991

### Default StorageClass

For pre-provisioned environments, the Konvoy component handles the creation of
a StorageClass in the form of a local
volume provisioner, which is not suitable for production use. Before
installing the Kommander component, you should
identify and install a Kubernetes CSI (see
`<https://kubernetes.io/docs/concepts/storage/volumes/>` #volume-types)
compatible storage provider that is suitable for production, and then ensure
it is set as the default, as shown below.
For more information, see Provisioning a Static Local Volume on page 41..

For infrastructure driver specifics, see Default Storage Providers on page 34.

#### Identifying and Modifying Your StorageClass

Procedure

1. Execute the following command to verify one is configured.

```bash
kubectl get sc --kubeconfig ${CLUSTER_NAME}.conf
```

For example, output, note the (default) after the name:

```bash
NAME PROVISIONER RECLAIMPOLICY VOLUMEBINDINGMODE
ALLOWVOLUMEEXPANSION AGE
ebs-sc (default) ebs.csi.aws.com Delete WaitForFirstConsumer false
41s
```

1. If the desired StorageClass is not set as default, add the following
   annotation to the StorageClass manifest.

```bash
annotations:
storageclass.kubernetes.io/is-default-class: "true"
```

For more information on setting a StorageClass as default, see
`<https://kubernetes.io/docs/tasks/administer->` cluster/change-default-storage-
class/.

### Installing Kommander in an Air-gapped Environment

Before you begin

- Ensure you have reviewed all the Nutanix Kubernetes Platform Requirements on
  page 45.
- Ensure you have a default StorageClass.
- Ensure you have loaded all necessary images for your configuration. For more
  information, see Images Download into Your Registry: Air-gapped Environments
  on page 982.
- Note down the name of the cluster where you want to install Kommander. If
  you do not know it, use kubectl get nkpclusters -A to display it.

About this task

Create your Kommander Installer Configuration File as follows:

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

```bash
nkp install kommander --init --airgapped > kommander.yaml
```

1. If required, customize your kommander.yaml file.

For customization options, see Installing Kommander with a Configuration File
on page 997.

Some of them include:

- Custom Domains and Certificates
- HTTP proxy
- External Load Balancer
- GPU utilization, etc.
- Rook Ceph customization for Pre-provisioned environments

1. If required: If your cluster uses a custom AWS VPC and requires an internal
   load-balancer, set the traefik annotation to create an internal-facing ELB.

```bash
...
apps:
traefik:
enabled: true
values: |
service:
annotations:
service.beta.kubernetes.io/aws-load-balancer-internal: "true
...
```

#### Pro License: Installing Kommander in an Air-gapped Environment

Tips and Recommendations:

- The --kubeconfig=${CLUSTER_NAME}.conf flag ensures that you install
  Kommander on the correct cluster. For alternatives and to Provide Context
  for Commands with a kubeconfig File, see Commands within a kubeconfig File
  on page 31.
- Applications can take longer to deploy and time out the installation. Add
  the --wait-timeout `<time to wait>` flag and specify a period (for example,
  1h) to allocate more time to the deployment of applications.
- If the Kommander installation fails, or you want to reconfigure
  applications, rerun the install command to retry.

What to do next

See Verifying Kommander Installation on page 993.

If you want to enable a solution that detects current and future anomalies in
workload configurations or Kubernetes clusters, see Nutanix Kubernetes
Platform Insights Guide on page 1111.

Procedure

In the kommander.yaml file, run the following command.

```bash
nkp install kommander \
--installer-config kommander.yaml --kubeconfig=${CLUSTER_NAME}.conf \
--kommander-applications-repository ./application-repositories/kommander-
applications-nkp-version.tar.gz
```

#### Images Download into Your Registry: Air-gapped Environments

For more information on downloading images, see Registry Mirror Tools on page 1028.

##### Downloading all Images for Air-gapped Deployments

If you are operating in an air-gapped environment, a local container registry
containing all the necessary installation images, including the Kommander
images, is required. See below for prerequisites to download and then how to
push the necessary images to this registry.

Procedure

1. Download the NKP air-gapped bundle for this release to load registry images
   as explained below.

For more information, see Downloading NKP on page 16.

| nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ------------------------ | ----------- | ------------------------ |

1. Connectivity with clusters attaching to the management cluster is required.

- Both management and attached clusters must be able to connect to the local
  registry.
- The management cluster must be able to connect to all the attached cluster
  API servers.
- The management cluster must be able to connect to any load balancers created
  for platform services on the management cluster.

##### Extracting Air-gapped Images and Set Variables

Follow these steps to extract the air-gapped image bundles into your private
registry:

Procedure

1. Assuming you have downloaded nkp-air-gapped-bundle_nkp-
   version_linux_amd64.tar.gz, extract the tar file to a local directory.
2. The directory structure after extraction can be accessed in subsequent
   steps using commands to access files from different directories. EX: For the
   bootstrap, change your directory to the nkp-`<version>`directory, similar to
   the example below, depending on your current location.
3. Set an environment variable with your registry address.

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
```

##### Loading Images to Your Private Registry

Before creating or upgrading a Kubernetes cluster, you need to load the
required images in a local registry if operating in an air-gapped environment.
This registry must be accessible from both the bastion machine and either the
AWS EC2 instances or other machines that will be created for the Kubernetes
cluster.

About this task

For more information on creating a bastion machine, see Creating a Bastion
Host on page 707.

```yaml
Warning: If you do not already have a local registry, set up one. For more information, see Registry Mirror Tools
on page 1028.
```

Procedure

1. To load the air-gapped image bundle into your local registry mirror:

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-nkp-version.tar,./
container-images/konvoy-image-bundle-nkp-version.tar,./container-images/nutanix-
product-catalog-nkp-version-airgapped.tar
--to-registry=${REGISTRY_URL}
--to-registry-username=${REGISTRY_USERNAME}
--to-registry-password=${REGISTRY_PASSWORD}
```

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

| tar -xzvf nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ---------------------------------- | ----------- | ------------------------ |

| cd nkp- | nkp-version | Col3 |
| ------- | ----------- | ---- |

1. To load the air-gapped image bundle into your internal registry:

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-nkp-version.tar,./
container-images/konvoy-image-bundle-nkp-version.tar,./container-images/nutanix-
product-catalog-nkp-version-airgapped.tar
--to-internal-registry-mirror
--kubeconfig=${CLUSTER_NAME}.conf
```

> **Note:**

- Replace nkp_version with the NKP version at your site.
- Specify only the required bundle as comma-separated values in the --bundle
  parameter.
- Pushing images to your registry might take time, depending on network
  performance between the machine running the command and the registry.
- The nutanix-product-catalog-nkp-version-airgapped.tar bundle is only
  supported on Nutanix infrastructure. You must exclude this bundle when
  deploying on other infrastructure providers such as Pre-provisioned, AWS,
  Azure, vSphere, and GCP.
- The nutanix-product-catalog-nkp-version-airgapped.tar included in the NKP
  air- gapped bundle contains images exclusively for Nutanix Data Services for
  Kubernetes (NDK). You must specify the Nutanix product catalog bundle only
  if you plan to deploy NDK.

### Installing Kommander in a Non-Air-gapped Environment

Before you begin

- Ensure you have reviewed all the Nutanix Kubernetes Platform Requirements on
  page 45.
- Ensure you have a default StorageClass. See Identifying and Modifying Your
  StorageClass on page 980.
- Note down the name of the cluster where you want to install Kommander. If
  you do not know it, use kubectl get nkpclusters -A to display it.

About this task

Create your Kommander Installer Configuration File as follows:

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

```bash
nkp install kommander --init > kommander.yaml
```

1. (Optional) Customize your kommander.yaml file. See the Kommander
   Customizations page for customization options. Some options include Custom
   Domains and Certificates, HTTP proxy, Disabling the AI Navigator
   application, External Load Balancer, GPU utilization, Rook Ceph
   customization for Pre-provisioned environments, and so on.

For more information on installing Kommanderthe dataset, Installing Kommander
in a Pre-provisioned Air- gapped Environment on page 985. 5. (Optional) If
your cluster uses a custom AWS VPC and requires an internal load-balancer, set
the traefik annotation to create an internal-facing ELB.

```bash
...
apps:
traefik:
enabled: true
values: |
service:
annotations:
service.beta.kubernetes.io/aws-load-balancer-internal: "true
...
```

#### Pro License: Installing Kommander in a Non-Air-gapped Environment

Tips and Recommendations:

- The --kubeconfig=${CLUSTER_NAME}.conf flag ensures that you install
  Kommander on the correct cluster. For alternatives and to Provide Context
  for Commands with a kubeconfig File, see Commands within a kubeconfig File
  on page 31.
- Applications can take longer to deploy and time out the installation. Add
  the --wait-timeout `<time to wait>` flag and specify a period (for example,
  1h) to allocate more time to the deployment of applications.
- If the Kommander installation fails, or you want to reconfigure
  applications, rerun the install command to retry.

What to do next

See Verifying Kommander Installation on page 993.

If you want to enable a solution that detects current and future anomalies in
workload configurations or Kubernetes clusters, see Nutanix Kubernetes
Platform Insights Guide on page 1111.

Procedure

In the kommander.yaml file, run the following command.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

### Installing Kommander in a Pre-provisioned Air-gapped Environment

Before you begin

- Ensure you have completed all the Nutanix Kubernetes Platform Requirements
  on page 45.
- Ensure you have a default StorageClass. See Identifying and Modifying Your
  StorageClass on page 980.
- Ensure you have loaded all necessary images for your configuration. See
  Images Download into Your Registry: Air-gapped Environments on page 982.
- Note down the name of the cluster where you want to install Kommander. If
  you do not know it, use kubectl get nkpclusters -A to display it.

About this task

Create and customize your Kommander Installer Configuration File as follows:

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

For more information, see Installing Kommander with a Configuration File on
page 997.

```bash
nkp install kommander --init --airgapped > kommander.yaml
```

1. Include configuration overrides for the rook-ceph-cluster. Edit the
   installer file to perform this step.

NKP's default configuration ships Ceph with PVC based storage (see
`<https://rook.io/docs/rook/v1.10/CRDs/>` Cluster/pvc-
cluster/) which requires your CSI provider to support PVC with type
volumeMode: Block. As this is not possible with the
default local static provisioner (see Default Storage Providers on page 34),
you can install Ceph in host storagemode
(see `<https://rook.io/docs/rook/v1.10/CRDs/Cluster/host-cluster/>`). You can
choose whether Ceph's object storage daemon
(osd) pods should consume all or just some of the devices on your nodes.
Include one of the following Overrides.

a. To automatically assign all raw storage devices on all nodes to the Ceph
cluster.

```bash
...
rook-ceph-cluster:
enabled: true
values: |
cephClusterSpec:
storage:
storageClassDeviceSets: []
useAllDevices: true
useAllNodes: true
deviceFilter: "<<value>>"
...
```

b. To assign specific storage devices on all nodes to the Ceph cluster.

```bash
...
rook-ceph-cluster:
enabled: true
values: |
cephClusterSpec:
storage:
storageClassDeviceSets: []
useAllNodes: true
useAllDevices: false
deviceFilter: "^sdb."
...
```

> **Note:**

- If you want to assign specific devices to specific nodes using the
  deviceFilter option, see `<<https://rook.io/docs/rook/v1.10/CRDs/Cluster/host->`
  cluster/#specific-nodes-and-devices>.
- For general information on the deviceFilter value, see
  `<https://rook.io/docs/rook/v1.10/>` CRDs/Cluster/ceph-cluster-crd/#storage-
  selection-settings.

1. (Optional) Customize your kommander.yaml file. See the Kommander
   Customizations page for customization options. Some options include Custom
   Domains and Certificates, HTTP proxy, Disabling the AI Navigator
   application, External Load Balancer, GPU utilization, Rook Ceph
   customization for Pre-provisioned environments, and so on.
2. (Optional) If your cluster uses a custom AWS VPC and requires an internal
   load-balancer, set the traefik annotation to create an internal-facing ELB.

```bash
...
apps:
...
traefik:
enabled: true
values: |
service:
annotations:
service.beta.kubernetes.io/aws-load-balancer-internal: "true
...
```

#### Pro License: Installing Kommander in a Pre-provisioned Air-gapped

Environment

What to do next

See Verifying Kommander Installation on page 993.

If you want to enable a solution that detects current and future anomalies in
workload configurations or Kubernetes clusters, see Nutanix Kubernetes
Platform Insights Guide on page 1111.

Procedure

In the kommander.yaml file, run the following command.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf \
--kommander-applications-repository ./application-repositories/kommander-
applications-nkp-version.tar.gz
```

#### Images Download into Your Registry: Air-gapped, Pre-provisioned

Environments

For more information on downloading images, see Registry Mirror Tools on page 1028.

##### Downloading all Images for Air-gapped Pre-provisioned Deployments

If you are operating in an air-gapped environment, the local container
registry containing all the necessary installation images, including the
Kommander images, is required. See below for prerequisites to download and
then how to push the necessary images to this registry.

Procedure

1. Download the NKP air-gapped Bundle for this release (that is. nkp-air-
   gapped-bundle_nkp-

version>\_linux_amd64.tar.gz) to load registry images as explained below. See
Downloading NKP on page 16. 2. Connectivity with clusters attaching to the
management cluster is required.

- Both management and attached clusters must be able to connect to the local
  registry.
- The management cluster must be able to connect to all the attached cluster's
  API servers.
- The management cluster must be able to connect to any load balancers created
  for platform services on the management cluster.

##### Extracting Air-gapped Pre-provisioned Images and Set Variables

Follow these steps to extract the air-gapped image bundles into your private
registry:

Procedure

1. Assuming you have downloaded nkp-air-gapped-bundle_nkp-
   version_linux_amd64.tar.gz, extract the tar file to a local directory.
2. The directory structure after extraction can be accessed in subsequent
   steps using commands to access files from different directories. EX: For the
   bootstrap, change your directory to the nkp-`<version>`directory similar, to
   the example below, depending on your current location.
3. Set an environment variable with your registry address.

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
```

##### (Only Pre-provisioned) Loading Images for Deployments - Konvoy

For more information on loading images for Deployments, see the Nutanix Image
Builder (NIB) section.

Procedure

For detailed steps and procedure, see Upload artifacts to Pre-provisioned
Hosts on page 67.

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | > linux amd64.tar.gz |
| ------- | -------------------- |

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

| tar -xzvf nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ---------------------------------- | ----------- | ------------------------ |

| cd nkp- | nkp-version | Col3 |
| ------- | ----------- | ---- |

##### Loading Images to Your Private Registry (2)

Before creating or upgrading a Kubernetes cluster, you need to load the
required images in a local registry if operating in an air-gapped environment.
This registry must be accessible from both the bastion machine and either the
AWS EC2 instances or other machines that will be created for the Kubernetes
cluster.

About this task

For more information on creating a bastion machine, see Creating a Bastion
Host on page 707.

```yaml
Warning: If you do not already have a local registry, set up one. For more information, see Registry Mirror Tools
on page 1028.
```

Procedure

1. To load the air-gapped image bundle into your local registry mirror:

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-nkp-version.tar,./
container-images/konvoy-image-bundle-nkp-version.tar
--to-registry=${REGISTRY_URL}
--to-registry-username=${REGISTRY_USERNAME}
--to-registry-password=${REGISTRY_PASSWORD}
```

1. To load the air-gapped image bundle into your internal registry:

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-nkp-version.tar,./
container-images/konvoy-image-bundle-nkp-version.tar
--to-internal-registry-mirror
--kubeconfig=${CLUSTER_NAME}.conf
```

> **Note:**

- Replace nkp_version with the NKP version at your site.
- Specify only the required bundle as comma-separated values in the --bundle
  parameter.
- Pushing images to your registry might take time, depending on network
  performance between the machine running the command and the registry.

### Installing Kommander in a Pre-provisioned, Non-Air-gapped Environment

Before you begin

For more information on pre-provisioned environments, see Pre-provisioned
Installation Options on page 72. For more information on non-air-gapped
environments, see Air-Gapped or Non-Air-Gapped Environment on page 22.

- Ensure you have reviewed all the prerequisites for installation (see Nutanix
  Kubernetes Platform Requirements on page 45).
- Ensure you have a Default StorageClass on page 980.
- Note down the name of the cluster where you want to install Kommander. If
  you do not know it, use kubectl get nkpclusters -A to display it.

```yaml
Warning: You must modify the Kommander installer configuration file (kommander.yaml) before installing the
Kommander component of NKP in a pre-provisioned environment.
```

About this task

Create and customize your Kommander Installer Configuration File as follows:

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
```

1. Create a configuration file.

For more information, see Installing Kommander with a Configuration File on
page 997.

```bash
nkp install kommander --init > kommander.yaml
```

1. Include configuration overrides for the rook-ceph-cluster. NKP's default
   configuration ships Ceph with PersistentVolumeClaim (PVC) based storage,
   which requires your CSI provider to support PVC with type volumeMode: Block.
   As this is impossible with the default local static provisioner, you can
   install Ceph in host storage mode. You can choose whether Ceph's object
   storage daemon (osd) pods can consume all or just some of the devices on
   your nodes. Include one of the following Overrides.

a. To automatically assign all raw storage devices on all nodes to the Ceph
cluster.

```bash
rook-ceph-cluster:
enabled: true
values: |
cephClusterSpec:
storage:
storageClassDeviceSets: []
useAllDevices: true
useAllNodes: true
deviceFilter: "<<value>>"
```

b. To assign specific storage devices on all nodes to the Ceph cluster.

```bash
rook-ceph-cluster:
enabled: true
values: |
cephClusterSpec:
storage:
storageClassDeviceSets: []
useAllNodes: true
useAllDevices: false
deviceFilter: "^sdb."
Note: If you want to assign specific devices to specific nodes using the deviceFilter option, refer to
Specific Nodes and Devices. For general information on the deviceFilter value, refer to Storage
Selection Settings.
```

1. (Optional) Customize your kommander.yaml file. See the Kommander
   Customizations page for customization options. Some options include Custom
   Domains and Certificates, HTTP proxy, Disabling the AI Navigator
   application, External Load Balancer, GPU utilization, Rook Ceph
   customization for Pre-provisioned environments, and so on.
2. (Optional) If your cluster uses a custom AWS VPC and requires an internal
   load-balancer, set the traefik annotation to create an internal-facing ELB.

```bash
...
apps:
traefik:
enabled: true
values: |
service:
annotations:
service.beta.kubernetes.io/aws-load-balancer-internal: "true
...
```

#### Pro License: Installing Kommander in a Pre-provisioned, Non-Air-gapped

Environment

Tips and Recommendations:

- The --kubeconfig=${CLUSTER_NAME}.conf flag ensures that you install
  Kommander on the correct cluster. For alternatives and to Provide Context
  for Commands with a kubeconfig File, see Commands within a kubeconfig File
  on page 31.
- Applications can take longer to deploy and time out the installation. Add
  the --wait-timeout `<time to wait>` flag and specify a period (for example,
  1h) to allocate more time to the deployment of applications.
- If the Kommander installation fails, or you want to reconfigure
  applications, rerun the install command to retry.

What to do next

See Verifying Kommander Installation on page 993.

If you want to enable a solution that detects current and future anomalies in
workload configurations or Kubernetes clusters, see Nutanix Kubernetes
Platform Insights Guide on page 1111.

Procedure

In the kommander.yaml file, run the following command.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

### Installing Kommander in a Small Environment

About this task

Minimal Kommander installation:

The YAML file that is used to install a minimal configuration of Kommander
contains the bare minimum setup that allows you to deploy applications and
access the NKP UI. It does not include applications for cost monitoring,
logging, alerting, object storage, etc.

In this YAML file, you can find the lines that correspond to all platform
applications included in a normal Kommander setup. Applications that have
enabled set to false are not taken into account during installation. If you
want to test an additional application, you can enable it individually to be
installed by setting enabled to true on the corresponding line in the YAML
file.

For example, if you want to enable the logging stack, set enabled to true for
grafana-logging, grafana- lokilogging-operator, rook-ceph and rook-ceph-
cluster. Note that depending on the size of your cluster, enabling several
platform applications can exhaust your cluster's resources.

```yaml
Warning: Some applications depend on other applications to work properly. To find out which other applications you
need to enable to test the target application, see See Platform Applications on page 350
```

.

Before you begin

```yaml
Warning: Ultimate License considerations: Nutanix recommends performing testing and demo tasks in a single-cluster
environment. The Ultimate license is designed for multi-cluster environments and fleet management, which require a
minimum number of resources. Applying an Ultimate license key to the previous installation adds modifications to your
environment that can exhaust a small environment's resources.
```

Ensure you have done the following:

- You have acquired a NKP license.
- You have installed Basic Installations by Infrastructure on page 72.
- You have reviewed the prerequisite section pertaining to your air-gapped, or
  networked environment.

Procedure

1. Initialize your Kommander installation and name it kommander_minimal.yaml.

```bash
nkp install kommander --init --kubeconfig=${CLUSTER_NAME}.conf -oyaml >
kommander_minimal.yaml
```

1. Edit your kommander_minimal.yaml file to match the following example.

```yaml
apiVersion: config.kommander.mesosphere.io/v1alpha1
kind: Installation
apps:
dex:
enabled: true
dex-k8s-authenticator:
enabled: true
nkp-insights-management:
enabled: false
gatekeeper:
enabled: true
git-operator:
enabled: true
grafana-logging:
enabled: false
grafana-loki:
enabled: false
kommander:
enabled: true
kommander-ui:
enabled: true
kube-prometheus-stack:
enabled: false
```

| loki | logging-operator |
| ---- | ---------------- |

```bash
kubernetes-dashboard:
enabled: false
kubefed:
enabled: true
kubetunnel:
enabled: false
logging-operator:
enabled: false
prometheus-adapter:
enabled: false
reloader:
enabled: true
rook-ceph:
enabled: false
rook-ceph-cluster:
enabled: false
traefik:
enabled: true
traefik-forward-auth-mgmt:
enabled: true
velero:
enabled: false
ageEncryptionSecretName: sops-age
clusterHostname: ""
```

1. Install Kommander on your cluster with the following command.

```bash
nkp install kommander --installer-config ./kommander_minimal.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

In the previous command, the --kubeconfig=${CLUSTER_NAME}.conf flag ensures
that you set the context to install Kommander on the right cluster. For
alternatives and recommendations around setting your context, see Commands
within a kubeconfig File on page 31.

```yaml
Tip: Sometimes, applications require a longer period of time to deploy, which causes the installation to time out.
Add the --wait-timeout <time to wait> flag and specify a period of time (for example, 1h) to allocate
more time to the deployment of applications.
```

If the Kommander installation fails, or you wish to reconfigure applications,
you can rerun the install command, and you can view the progress by increasing
the log verbosity by adding the flag -v 2.

### Verifying Kommander Installation

About this task

```yaml
Note: If the Kommander installation fails or you want to reconfigure applications, you can rerun the install command
to retry the installation.
```

Procedure

1. Do one of the following.

» If you prefer the CLI not to wait for all applications to become ready, you
can set the --wait=false flag.

» If you choose not to wait through the NKP CLI, you can check the status of
the installation using the following command:

```bash
kubectl -n kommander wait --for condition=Ready helmreleases --all --timeout 15m
```

This will wait for each of the helm charts to reach their Ready condition,
eventually resulting in an output resembling below:

```bash
helmrelease.helm.toolkit.fluxcd.io/centralized-grafana condition met
helmrelease.helm.toolkit.fluxcd.io/dex condition met
helmrelease.helm.toolkit.fluxcd.io/dex-k8s-authenticator condition met
helmrelease.helm.toolkit.fluxcd.io/fluent-bit condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-logging condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-lokiLoki condition met
helmrelease.helm.toolkit.fluxcd.io/karma condition met
helmrelease.helm.toolkit.fluxcd.io/kommander condition met
helmrelease.helm.toolkit.fluxcd.io/kommander-appmanagement condition met
helmrelease.helm.toolkit.fluxcd.io/kube-prometheus-stack condition met
helmrelease.helm.toolkit.fluxcd.io/kubefed condition met
helmrelease.helm.toolkit.fluxcd.io/kubernetes-dashboard condition met
helmrelease.helm.toolkit.fluxcd.io/kubetunnel condition met
helmrelease.helm.toolkit.fluxcd.io/logging-operator condition met
helmrelease.helm.toolkit.fluxcd.io/logging-operator-logging condition met
helmrelease.helm.toolkit.fluxcd.io/prometheus-adapter condition met
helmrelease.helm.toolkit.fluxcd.io/prometheus-thanos-traefik condition met
helmrelease.helm.toolkit.fluxcd.io/reloader condition met
helmrelease.helm.toolkit.fluxcd.io/rook-ceph condition met
helmrelease.helm.toolkit.fluxcd.io/rook-ceph-cluster condition met
helmrelease.helm.toolkit.fluxcd.io/thanos condition met
helmrelease.helm.toolkit.fluxcd.io/traefik condition met
helmrelease.helm.toolkit.fluxcd.io/traefik-forward-auth-mgmt condition met
helmrelease.helm.toolkit.fluxcd.io/velero condition met
```

1. In case of failed HelmReleases, do one of the following.

» If an application fails to deploy, check the status of a HelmRelease with:

```bash
kubectl -n kommander get helmrelease <HELMRELEASE_NAME
```

» If you find any HelmReleases in a "broken" release state, such as
"exhausted" or "another rollback/release in progress" trigger a reconciliation
of the HelmRelease using the following commands:

```bash
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -
p='[{"op": "replace", "path": "/spec/suspend", "value": true}]'
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -
p='[{"op": "replace", "path": "/spec/suspend", "value": false}]'
```

What to do next

### Logging into the UI with Kommander

Procedure

1. By default, log in to the UI in Kommander with the following command:

```bash
nkp open dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

1. Retrieve your credentials:

```bash
kubectl -n kommander get secret nkp-credentials -o go-template='Username:
{{.data.username|base64decode}}{{ "\n"}}Password: {{.data.password|base64decode}}
{{ "\n"}}'
```

1. Retrieve the dashboard URL:

```bash
kubectl -n kommander get svc kommander-traefik -o go-template='https://{{with
index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}{{end}}/nkp/kommander/
dashboard{{ "\n"}}'
```

Use these static credentials only to configure an external identity provider.
For more information, see Identity Providers. Treat them as backup
credentials, not for regular UI access. 4. Rotate the dashboard password:

```bash
nkp rotate dashboard-credentials
```

The CLI prompts for confirmation. Respond with y to continue or N to cancel:

```bash
This will rotate the NKP dashboard (static admin) password.
Existing sessions and stored credentials will stop working after rotation.
Are you sure you want to continue? [y/N]: y
The dashboard credentials have been rotated. Run nkp get dashboard to retrieve the
new password.
```

To skip this prompt in non-interactive terminals, add the --yes flag:

```bash
nkp rotate dashboard-credentials --yes
```

1. Retrieve the new dashboard credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

For more information, see Rotating the NKP Dashboard Password on page 308.

What to do next

You can perform the following operations on Identity Providers:

- Create an Identity Provider
- Temporarily Disable an Identity Provider
- Create Groups

### Dashboard UI Functions

For more information, see Basic Installations by Infrastructure on page 72.
The majority of the customization, such as attaching clusters and deploying
applications, will take place in the dashboard or UI of NKP. The Basic
Installation section allows you to manage cluster operations and their
application workloads to optimize your organization's productivity.

If you want to enable a solution that detects current and future anomalies in
workload configurations or Kubernetes clusters, see Nutanix Kubernetes
Platform Insights Guide on page 1111.

## Kommander Customizations

You can customize the Kommander component of NKP during initial installation
or after deployment using the Nutanix Kubernetes® Platform (NKP) CLI.

You can modify configuration values in the Kommander Helm chart, modify
settings for identity providers, enable or disable workspace features, and
apply post-install updates using the NKP CLI. The customizations allow you to
configure Kommander for access control, UI preferences, and integration
workflows across clusters.

### Initializing a Kommander Installer Configuration File

About this task

You can install Kommander with a bare minimum of applications on a small
environment with smaller memory, storage, and CPU requirements for testing and
demo purposes, see Installing Kommander in a Small Environment on page 991.

Before you begin

- To ensure your cluster has enough resources, review the Nutanix Kubernetes
  Platform Management Cluster Application Requirements on page 725.
- Ensure you have a default StorageClass, as shown in Identifying and
  Modifying Your StorageClass on page 980.

Initialize a Kommander Installer Configuration File as follows:

Procedure

To begin configuring Kommander, run the following command to initialize a
default configuration file.

» For an air-gapped environment, run the following command:

```bash
nkp install kommander --init --airgapped > kommander.yaml
```

» For a non-air-gapped environment, run the following command:

```bash
nkp install kommander --init > kommander.yaml
```

### Configuring Applications After Installing Kommander

Procedure

After the initial deployment of Kommander, you can find the application Helm
Charts by checking the spec.chart.spec.sourceRef field of the associated
HelmRelease.

```bash
kubectl get helmreleases <application> -o yaml -n kommander
```

Inline configuration (using values) :

In this example, you configure the centralized-grafana application with
resource limits by defining the Helm Chart values in the Kommander
configuration file.

```yaml
apiVersion: config.kommander.mesosphere.io/v1alpha1
kind: Installation
apps:
centralized-grafana:
values: |
grafana:
resources:
limits:
cpu: 150m
memory: 100Mi
requests:
cpu: 100m
memory: 50Mi
...
```

Reference another YAML file (using valuesFrom):

Alternatively, you can create another YAML file containing the configuration
for centralized-grafana and reference that using valuesFrom. You can point to
this file by using either a relative path (from the configuration file
location) or by using an absolute path.

```bash
cat > centralized-grafana.yaml <<EOF
grafana:
resources:
limits:
cpu: 150m
memory: 100Mi
requests:
cpu: 100m
memory: 50Mi
EOF
apiVersion: config.kommander.mesosphere.io/v1alpha1
kind: Installation
apps:
centralized-grafana:
valuesFrom: centralized-grafana.yaml
...
```

### Minimal Kommander Installation

You can install Kommander with a bare minimum of applications on a small
environment with smaller memory, storage, and CPU requirements for testing and
demo purposes.

For more information, see Installing Kommander in a Small Environment on page 991.

### Installing Kommander with a Configuration File

About this task

In the following command, the --kubeconfig=${CLUSTER_NAME}.conf flag ensures
that you set the context for installing Kommander on the right cluster. For
alternatives and recommendations around setting your context, see Commands
within a kubeconfig File on page 31.

Procedure

1. Add the --installer-config flag to the kommander install command to use a
   custom configuration file.
2. To reconfigure applications, you can also run this command after the
   initial installation.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
Tip: Sometimes, applications require a longer period of time to deploy, which causes the installation to time out.
Add the --wait-timeout <time to wait> flag and specify a period of time (for example, 1h) to allocate
more time to the deployment of applications.
```

What to do next

After building the Konvoy cluster and installing Kommander, you can verify
your Kommander installation (Verifying Kommander Installation on page 993),
then you can log in to the Kommander UI (Logging into the UI with Kommander on
page 994).

### Kommander Configuration Reference

Configuration Parameters

For additional information about configuring the Kommander component of NKP
during initial installation, see Installing Kommander with a Configuration
File on page 997.

Table 73: Configuration Parameters

apps List of platform applications that will be installed on the management
cluster.

```bash
apps:
ai-navigator-app:
enabled: true
dex:
enabled: true
dex-k8s-authenticator:
enabled: true
nkp-insights-management:
enabled: true
gatekeeper:
enabled: true
git-operator:
enabled: true
grafana-logging:
enabled: true
grafana-loki:
enabled: true
kommander:
enabled: true
kube-prometheus-stack:
enabled: true
values: <shortened for
brevity>
kubefed:
enabled: true
kubernetes-dashboard:
enabled: true
kubetunnel:
enabled: true
logging-operator:
enabled: true
prometheus-adapter:
enabled: true
reloader:
enabled: true
rook-ceph:
enabled: true
rook-ceph-cluster:
enabled: true
traefik:
enabled: true
traefik-forward-auth-mgmt:
enabled: true
velero:
enabled: true
```

ageEncryptionSecretName Defines the name of the secret in which to store the
Age encryption.

```bash
sops-age
```

clusterHostName Allows users to provide a hostname that is used for accessing
the cluster's ingresses.

ingressCertificate Allows users to provide a custom certificate that's used
for TLS in the cluster's ingresses.

| Parameter | Description | Default Value |
| --------- | ----------- | ------------- |

acme Enable automatic ingress certificate management through ACME.

appManagementImageTag Specifies image tag of the AppManagement container.

appManagementImageRepository Specifies the image repository of AppManagement
container

appManagementKubetoolsImageRepository Specifies the image repository of the
Kubetools container

kommanderChartsVersion Specifies NKP Kommander Helm chart version.

air-gapped Specifies parameters for an air- gapped environment.

catalog Specifies parameters for installing default catalog repositories.

AppConfig Parameters

Table 74: AppConfig Parameters

enabled Denotes whether the specific app should be deployed or not.

```yaml
Note: The ai-
navigator-app entry
defaults to true unless you
are installing in an air-gapped
environment. Set the value to
false if you do not want to
install the AI Navigator on
page 1100 application.
```

false

valuesFrom File path containing the values that are passed onto the
application's HelmRelease.

This is a Helm values file for all applications at the moment. The path in
this field must either be a relative file location, which is then interpreted
to be relative to the location of the configuration file, or an absolute path.

```yaml
Note: Only one of
valuesFrom or values
might be set; both cannot be
set.
```

| Parameter | Description | Default Value |
| --------- | ----------- | ------------- |

| Parameter | Description | Default Value |
| --------- | ----------- | ------------- |

values Contains the values that are passed to the application's HelmRelease.

```yaml
Note: Only one of
valuesFrom or values
may be set; both cannot be set.
```

IngressCertificate

Table 75: IngressCertificate Parameters

certificate The path to a certificate PEM file.

private_key The path to the certificate's private key (PEM).

ca The path to the certificate's CA bundle; a PEM file containing root and
intermediate certificates.

Airgapped Parameters

Table 76: Airgapped Parameters

enabled Specifies if installation happens in an air-gapped environment.

helmMirrorImageTag Specifies an image tag of the Helm-mirror container.

helmMirrorImageRepository Specifies image repository of Helm-mirror container.

Next Step:

Configuring HTTP proxy for the Kommander Clusters on page 1019

### Configuring the Kommander Installation with a Custom Domain and Certificate

There are two configuration methods:

| Parameter | Description | Default Value |
| --------- | ----------- | ------------- |

| Parameter | Description | Default Value |
| --------- | ----------- | ------------- |

| Parameter | Description | Default Value |
| --------- | ----------- | ------------- |

Table 77: Configuration Methods

While installing the Kommander component Only Pro or Management clusters

After installing the Kommander component All cluster types

For more information, see Custom Domains and Certificates Configuration for
All Cluster Types on page 537.

NKP supports configuring a custom domain name for accessing the UI and other
platform services, as well as setting up manual or automatic certificate
renewal or rotation. This section provides instructions and examples on how to
configure the NKP installation to add a customized domain and certificate to
your Pro cluster or Management cluster.

#### Reasons for Setting Up a Custom Domain or Certificate

Reasons for Using a Custom DNS Domain

NKP supports the customization of domains to allow you to use your domain or
hostname for your services. For example, you can set up your NKP UI or any of
your clusters to be accessible with your custom domain name instead of the
domain provided by default.

To set up a custom domain (without a custom certificate), see Configuring a
Custom Domain Without a Custom Certificate on page 1008.

Reasons for Using a Custom Certificate

NKP's default CA identity supports the encryption of data exchange and traffic
(between your client and your environment's server). To configure an
additional security layer that validates your environment's server
authenticity, NKP supports configuring a custom certificate issued by a
trusted Certificate Authority either directly in a Secret or managed
automatically using the ACME protocol (for example, Let's Encrypt).

Changing the default certificate for any of your clusters can be helpful. For
example, you can adapt it to classify your NKP UI or any other type of service
as trusted (when accessing a service through a browser).

To set up a custom domain and certificate, refer to the following pages
respectively:

- Configure a custom domain and certificate as part of the cluster's
  installation process. This is only possible for your Management or Pro
  cluster. For more information, see Configuring the Kommander Installation
  with a Custom Domain and Certificate on page 1001.
- Update your cluster's current domain and certificate configuration as part
  of your cluster operations. You can do this for any cluster type in your
  environment. For more information, see Cluster Operations Management on page

1.

```yaml
Note: Using Let's Encrypt or other public ACME certificate authorities does not work in air-gapped scenarios, as these
services require a connection to the Internet for their setup. For air-gapped environments, you can either use self-signed
certificates issued by the cluster (the default configuration) or a certificate created manually using a trusted Certificate
Authority.
```

#### Certificate Issuer and KommanderCluster Concepts

KommanderCluster Object

The KommanderCluster resource is an object that contains key information for
all types of clusters that are part of your environment, such as:

| Configuration Methods | Supported cluster types |
| --------------------- | ----------------------- |

- Cluster access and endpoint information
- Cluster attachment information
- Cluster status and configuration information

Issuer Objects

Issuer, ClusterIssuer or certificateSecret?

If you use a certificate issued and managed automatically by cert-manager, you
need an Issuer or ClusterIssuerthat you reference in your KommanderCluster
resource. The referenced object must contain the information of your
certificate provider.

If you want to use a manually-created certificate, you need a
certificateSecret that you reference in your KommanderCluster resource.

Location of the KommanderCluster and Issuer Objects

In the Management or Pro cluster, both the KommanderCluster and issuer objects
are stored on the same cluster. The issuer can be referenced as an Issuer,
ClusterIssuer or certificateSecret.

In Managed and Attached clusters, the KommanderCluster object is stored on the
Management cluster. The Issuer, ClusterIssuer or certificateSecret is stored
on the Managed or Attached cluster.

HTTP and DNS solver

When configuring a certificate for your NKP cluster, you can set up an HTTP
solver or a DNS solver. The HTTP protocol exposes your cluster to the public
Internet, whereas DNS keeps your traffic hidden. If you use HTTP, your cluster
must be publicly accessible (through the ingress or load balancer). If you use
DNS, this is not a requirement. For HTTP and DNS configuration options, see
Advanced Configuration: ClusterIssuer on page 1007.

```yaml
Note: If you are enabling a proxied access (see Proxied Access to Network-Restricted Clusters on page 510)
for a network-restricted cluster, this configuration is restricted to DNS.
```

#### Certificate Authority

Use these values for Configuring the Kommander Installation with a Custom
Domain and Certificate on page 1001.

Table 78: Table

Let's Encrypt None Generated automatically by Kommander when acme is enabled

ZeroSSL An access and a secret key provided by ZeroSSL

```bash
acme.server: https://
acme.zerossl.com/v2/DV90
```

SSL.com An access and a secret key provided by SSL

```bash
acme.server: https://
acme.ssl.com/sslcom-dv-rsa
```

#### Certificate Configuration Options

| Issuer, | ClusterIssuer |
| ------- | ------------- |

| Certificate Authority | Prerequisites | Kommander Installervalues |
| --------------------- | ------------- | ------------------------- |

For more information on values that are specific to your Certificate Authority
or CA, see Certificate Authority on page 1003. Choose an ACME-supported
Certificate Authority if you want the cert-manager to handle certificate
renewal and rotation automatically.

The configuration options are as follows:

- Choose an ACME-supported Certificate Authority, if you want the cert-manager
  to automatically handle certificate renewal and rotation.
- For more information on values that are specific to your Certificate
  Authority or CA, see Certificate Authority on page 1003.

```yaml
Warning: Certificates issued by another Issuer: You can also configure a certificate issued by another
Certificate Authority. In this case, the CA will determine which information to include in the configuration.
```

- For configuration examples, `<https://cert-manager.io/docs/configuration/>`.
- The ClusterIssuer's name must be kommander-acme-issuer.

Next Step:

Verifying and Troubleshooting the Domain and Certificate Customization on page
1009

##### Using an Automatically-generated Certificate with ACME and Required

Basic Configuration

When you enable ACME, by default NKP generates an ACME-supported certificate
with an HTTP01 solver. The cert-manager automatically issues a trusted
certificate for the configured custom domain, and takes care of renewing the
certificate before expiration.

Procedure

1. Open the Kommander Installer Configuration File or kommander.yaml file.

a. If you do not have the kommander.yaml file to initialize the configuration
file so that you can edit it in the following steps.

> **Warning: Initialize this file only ONE time, otherwise, you will
> overwrite previous customizations.**

b. If you have initialized the configuration file already, open the
`<kommander.yaml>` with the editor of your choice. 2. In that file, configure
the custom domain for your cluster.

```bash
[...]
clusterHostname: <mycluster.example.com>
[...]
```

1. Enable ACME by adding acme value, the issuer's server, and your e-mail. If
   you don't provide a server, NKP sets up Let's Encrypt as your certificate
   provider.

```bash
acme:
email: <your_email>
server: <your_server>
[...]
```

1. Use the configuration file to install Kommander.

See Kommander Customizations on page 996.

```yaml
Note: Basic configuration in this topic refers to the ACME server without EAB (External Account Bindings) and
HTTP solver.
```

##### Using an Automatically-generated Certificate with ACME and Required (2)

Advanced Configuration

If you require additional configuration options like DNS solver, EAB, among
others, create a ClusterIssuer with the required configurations before you run
the installation of Kommander. The cert- manager automatically issues a
trusted certificate for the configured custom domain, and takes care of
renewing the certificate before expiration.

About this task

For more information on the ClusterIssuer, other objects, and where to store
them, see Advanced Configuration: ClusterIssuer on page 1007 and Certificate
Issuer and KommanderCluster Concepts on page 1002.

Procedure

1. Create a ClusterIssuer and store it in the target cluster. It must be
   called kommander-acme-issuer:

a. If you require an HTTP solver, adapt the following example with the
properties required for your certificate and run the command:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
name: kommander-acme-issuer # This part is important
spec:
acme:
email: <your_email>
server: <https://acme.server.example>
skipTLSVerify: true
privateKeySecretRef:
name: kommander-acme-issuer-account # Set this to <name>-account
solvers:
- http01:
ingress:
ingressTemplate:
metadata:
annotations:
kubernetes.io/ingress.class: kommander-traefik
"traefik.ingress.kubernetes.io/router.priority": "2147483647"
EOF
Warning: The values kommander-acme-issuer, kommander-acme-issuer-account and,
"traefik.ingress.kubernetes.io/router.priority": "2147483647" are not placeholders
and must be filled out exactly as in the example.
```

In on-premises environments, replace the annotation in the previous example
with traefik.ingress.kubernetes.io/router.tls: "true".

b. If you require a DNS solver, adapt the following example with the
properties required for your certificate and run the command:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
name: kommander-acme-issuer # This part is important
spec:
acme:
email: <your_email>
server: <https://acme.server.example>
privateKeySecretRef:
name: kommander-acme-issuer-account # Set this to <name>-account
solvers:
- dns01:
route53:
region: us-east-1
role: arn:aws:iam::YYYYYYYYYYYY:role/dns-manager
EOF
Warning: The values kommander-acme-issuer, and kommander-acme-issuer-account are
not placeholders and must be filled out exactly as in the example.
```

1. (Optional) If you require External Account Bindings to link your ACME
   account to an external database, see

`<https://cert-manager.io/docs/configuration/acme/#external-account-bindings>`. 3. (Optional): Create a DNS record by
setting up the external-dns service. For more information, DNS Record Creation
with External DNS on page 1010. This way,
the external-dns will take care of pointing the DNS record to the ingress of
the cluster automatically. You can also
manually create a DNS record , that maps your domain name or IP address to the
cluster ingress. If you choose to create
a DNS record manually, finish installing the Kommander component, and then
manually create a DNS record that points to
the load balancer address. 4. Open the Kommander Installer Configuration File
or kommander.yaml file.

a. If you do not have the kommander.yaml file, initialize the configuration
file, so you can edit it in the following steps.

> **Warning: Initialize this file only ONCE, otherwise you will overwrite
> previous customizations.**

b. If you have initialized the configuration file already, open the
kommander.yaml with the editor of your choice. 5. In that file, configure the
cluster to use your custom domain.

```bash
[...]
clusterHostname: <mycluster.example.com>
[...]
```

1. Enable ACME by configuring the issuer's server and your e-mail.

```bash
[...]
acme:
email: <your_email>
server: <your_server>
[...]
```

1. Use the configuration file to install Kommander.

See Kommander Customizations on page 996.

##### Using a Manually-generated Certificate

Nutanix supports the use of a manually-created certificate. In this case,
there is no certificate controller that handles the renewal and update of your
certificate automatically, so you will have to take care of these tasks
manually.

Before you begin

Obtain the PEM files of your certificate and store them in the target
cluster's namespace:

- Certificate
- Private key of the certificate
- CA bundle (containing the root and intermediate certificates)

```yaml
Important: The following instructions are for configuring certificates during the initial installation. If you have
an already deployed Kommander cluster and need to update or use manually generated certificates, see Using a
Manually-generated Certificate in the Cluster Operations Management section.
```

To configure the manually-generated certificate:

Procedure

1. Open the Kommander Installer Configuration File or `<kommander.yaml>` file.

a. If you do not have the kommander.yaml file, initialize the configuration
file so that you can edit it in the following steps.

> **Warning: Initialize this file only ONCE; otherwise, you will overwrite
> previous customizations.**

b. If you have initialized the configuration file already, open the kommander.
yaml with the editor of your choice. 2. In the Kommander Installer
Configuration file, provide your custom domain and the paths to the PEM files
of your certificate.

```bash
[...]
clusterHostname: <mycluster.example.com>
ingressCertificate:
certificate: <certs/cert.pem>
private_key: <certs/key.pem>
ca: <certs/ca.pem>
[...]
```

1. Use the configuration file to install Kommander.

See Kommander Customizations on page 996.

#### Advanced Configuration: ClusterIssuer

For more information, see Configuring the Kommander Installation with a Custom
Domain and Certificate on page 1001.

Ensure you review Certificate Issuer and KommanderCluster Concepts on page 1002

You can also set up an advanced configuration for a Custom Domain and
Certificate. In these cases, the custom configuration cannot be done
completely through the installer config file, but must be specified further

in a ClusterIssuer. For more information, see Certificate Issuer and
KommanderCluster Concepts on page 1002.

Whether it is sufficient to establish the configuration of your custom
certificate in the installer config file only or you require a ClusterIssuer
to define further configuration options depends on the degree of
customization.

> **Warning: If you require a ClusterIssuer, you must create it before you
> run the Kommander installation.**

When do You Need a ClusterIssuer?

The configuration of the ClusterIssuer resource depends on your NKP landscape:

Figure 25: Cluster Domain in the NKP Landscape

How do You Configure a ClusterIssuer?

You can set configurable fields in a ClusterIssuer.

For more information on the available options, see the ACME section in
`<https://cert-manager.io/docs/>` configuration/acme/.

Examples

For configuration steps and examples, see Configuring the Kommander
Installation with a Custom Domain and Certificate on page 1001.

```yaml
Warning: If you need to make changes in the configuration of your domain or certificate after you have installed NKP,
or if you want to set up a custom domain and certificate for Attached or Managed clusters , modify the ingress in the
KommanderCluster object as shown in the Custom domains and certificates configuration section.
```

#### Configuring a Custom Domain Without a Custom Certificate

Procedure

1. Open the Kommander Installer Configuration File or kommander.yaml file.

a. If you do not have the kommander.yaml file, see Installing Kommander with a
Configuration File on page 997, so you can edit it in the following steps.

> **Warning: Initialize this file only ONCE, otherwise, you will overwrite
> previous customizations.**

b. If you have initialized the configuration file already, open the
kommander.yaml with the editor of your choice. 2. In that file, configure the
custom domain for your cluster by adding this line.

```bash
[...]
clusterHostname: <mycluster.example.com>
[...]
```

1. This configuration can be used when installing or reconfiguring Kommander
   by passing it to the nkp install

kommander command.

```bash
nkp install kommander --installer-config <kommander.yaml> --kubeconfig=
${CLUSTER_NAME}.conf
Note: To ensure Kommander is installed on the right cluster, use the --kubeconfig=cluster_name.conf
flag as an alternative to KUBECONFIG.
```

1. After the command completes, obtain the cluster ingress IP address or
   hostname using the following command.

```bash
kubectl -n kommander get svc kommander-traefik -o go-template='{{with
index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}{{end}}{{ "\n"}}'
```

If required, create a DNS record (for example, by using external-dns) for your
custom hostname that resolves to the cluster ingress load balancer hostname or
IP address. If the previous command returns a hostname, you should create a
CNAME DNS entry that resolves to that hostname. If the cluster ingress is an
IP address, create a DNS A record.

```yaml
Warning: The domain must be resolvable from both the client (your browser) and the cluster. If you set up an
external-dns service, it automatically points the DNS record to the cluster ingress. If you are manually creating
a DNS record, you have to install Kommander first to obtain the load balancer address required for the DNS record.
```

For more details and examples on how and when to set up the DNS record, see
Configuring the Kommander Installation with a Custom Domain and Certificate on
page 1001.

#### Verifying and Troubleshooting the Domain and Certificate Customization

About this task

On the Management cluster, perform the following steps:

Procedure

1. Inspect the modified KommanderCluster object.

```bash
kubectl describe kommandercluster -n <workspace_name> <cluster_name>
```

1. If the ingress is still being provisioned, the output looks similar to this.

```bash
[...]
Conditions:
Last Transition Time: 2022-06-24T07:48:31Z
Message: Ingress service object was not found in the cluster
Reason: IngressServiceNotFound
Status: False
Type: IngressAddressReady
[...]
```

If the provisioning has been completed, the output looks similar to this.

```bash
[...]
Conditions:
Last Transition Time: 2022-06-28T13:43:33Z
Message: Ingress service address has been provisioned
Reason: IngressServiceAddressFound
Status: True
Type: IngressAddressReady
Last Transition Time: 2022-06-28T13:42:24Z
Message: Certificate is up to date and has not expired
Reason: Ready
Status: True
Type: IngressCertificateReady
[...]
```

The same command also prints the actual customized values for the
KommanderCluster.Status.Ingress. Here is an example.

```bash
[...]
ingress:
address: 172.20.255.180
caBundle: LS0tLS1CRUdJTiBD...<output has been shortened>...DQVRFLS0tLS0K
[...]
```

### DNS Record Creation with External DNS

When you set up a custom domain, that is, Custom Domains and Certificates
Configuration for All Cluster Types for your cluster, you require a DNS record
that maps the configured domain or IP address to the cluster's ingress. You
can either create one manual or set up the external-dns service to manage your
DNS record automatically. For more information, see Custom Domains and
Certificates Configuration for All Cluster Types on page 537.

If you choose to use external-dns to maintain your DNS records, the external-
dns will take care of pointing the DNS record to the ingress of the cluster
automatically.

Select one of the following options to configure the external-dns service for
Management or Pro clusters or for Managed or Attached clusters.

#### Configuring External DNS with the CLI: Management or Pro Cluster

- Configuring the External DNS Using the UI on page 1012
- Verifying Your External DNS Configuration on page 1014

If you choose to create a DNS record manually, finish installing the Kommander
component and then manually create a DNS record that points to the load
balancer address.

Before you begin

Ensure you have configured a DNS zone with your cloud provider.

About this task

Configure External DNS and Customize Traefik. The configuration varies
depending on your cloud provider.

Procedure

1. Open the Kommander Installer Configuration File or kommander.yaml file.

a. If you do not have the kommander.yaml file, see Installing Kommander with a
Configuration File on page 997 so that you can edit it in the following steps.

> **Warning: Initialize this file only ONCE; otherwise, you will overwrite
> previous customizations.**

b. If you have installed the Kommander component already, open the existing
kommander.yaml with the editor of your choice. 2. Adjust the app section of
your kommander.yaml file to include these values.

AWS Example: Replace the placeholders `<...>` with your environment's
information.

The following example shows how to configure external-dns to manage DNS
records in AWS Route 53 automatically:

```bash
apps:
external-dns:
enabled: true
values: |
aws:
credentials:
secretKey: <secret-key>
accessKey: <access-key>
region: <provider-region>
preferCNAME: true
policy: upsert-only
txtPrefix: local-
domainFilters:
- <example.com>
```

Azure Example: Replace the placeholders `<...>`with your environment's
information.

```bash
apps:
external-dns:
enabled: true
values: |
azure:
cloud: AzurePublicCloud
resourceGroup: <resource-group>
tenantId: <tenant-id>
subscriptionId: <your-subscription-id>
aadClientId: <client-id>
aadClientSecret: <client-secret>
domainFilters:
- <example.com>
txtPrefix: txt-
policy: sync
provider: azure
```

1. In the same app section, adjust the traefiksection to include the following.

```bash
traefik:
enabled: true
values: |
service:
annotations:
external-dns.alpha.kubernetes.io/hostname: <mycluster.example.com>
```

1. Use the configuration file to install or update the Kommander component.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

For more information and configuring external-dns to use other DNS providers
like Google Cloud DNS, CloudFlare, or on-site providers, see
`<https://artifacthub.io/packages/helm/bitnami/external-dns>`.

What to do next

Verifying Your External DNS Configuration on page 1014

#### Configuring the External DNS Using the UI

About this task

This page contains information on how to configure an external-dns service to
manage DNS records automatically and applies to all cluster types.

The configuration varies depending on your cloud provider.

Before you begin

Ensure you have configured a DNS zone with your cloud provider.

Procedure

1. Select the target workspace from the top navigation bar. It must be the
   workspace that contains the cluster, for which you want to configure
   External DNS. In the case of the Management cluster, it is the Management
   cluster workspace.
2. Select Applications from the sidebar menu.
3. Search for the External DNS application.
4. On the application card, select the triple dot vertical icon > Enable.
5. On the Enable Workspace Platform Application page, select Configuration
   from the sidebar menu.
6. Copy and paste the following contents into the code editor and replace the
   placeholders `<...>` with your environment's information. Here is an example
   configuration.

AWS Example: Replace the placeholders `<...>`with your environment's
information.

The following example shows how to configure external-dns to manage DNS
records in AWS Route 53 automatically.

```bash
aws:
credentials:
secretKey: <secret-key>
accessKey: <access-key>
region: <provider-region>
preferCNAME: true
policy: upsert-only
txtPrefix: local-
domainFilters:
- <example.com>
```

Azure Example: Replace the placeholders `<...>`with your environment's
information.

```bash
azure:
cloud: AzurePublicCloud
resourceGroup: <resource-group>
tenantId: <tenant-id>
subscriptionId: <your-subscription-id>
aadClientId: <client-id>
aadClientSecret: <client-secret>
domainFilters:
- <example.com>
txtPrefix: txt-
policy: sync
provider: azure
```

For more information and configuring external-dns to use other DNS providers
like Google Cloud DNS, CloudFlare, or on-site providers, see
`<https://artifacthub.io/packages/helm/bitnami/external-dns>`.

#### Customizing the Traefik Deployment Using the UI

About this task

> **Note: NKP deploys Traefik to all clusters by default.**

Procedure

1. Select the target workspace from the top navigation bar. It must be the
   workspace that contains the cluster, for which you want to configure
   External DNS. In the case of the Management cluster, it is the Management
   cluster workspace.
2. Select Applications from the sidebar menu.
3. Search for the Traefik application.
4. On the application card, select the triple dot vertical icon > Edit.
5. Select the Configuration lateral tab to add a customization.
6. Copy and paste the following configuration into the code editor:

Use the Cluster Application Configuration Override code editor to apply a
configuration per cluster.

```bash
service:
annotations:
external-dns.alpha.kubernetes.io/hostname: <mycluster.example.com>
Warning: Ensure you set up a domain per cluster, for example: <mycluster1.example.com>,
<mycluster2.example.com> and <mycluster3.example.com>.
```

What to do next

Verifying Your External DNS Configuration on page 1014

#### Verifying Your External DNS Configuration

About this task

If the external-dns service is not working properly, these commands also
provide aids to find the cause or identify the issue.

To verify that the deployment was triggered:

About this task

To verify that the deployment was triggered, follow these steps:

Procedure

1. Set the environment variable to the Management/Pro cluster by exporting the
   kubeconfig file in your terminal window or using the
   --kubeconfig=${CLUSTER_NAME}.conf as explained in Commands within a
   kubeconfig File on page 31.
2. Verify that the external-dns deployment is present. Replace
   `<target_WORKSPACE_NAMESPACE>` in the namespace -n flag with the target
   cluster's workspace namespace.

```bash
kubectl get appdeployments.apps.kommander.d2iq.io -n <target_WORKSPACE_NAMESPACE>
external-dns
```

The output should look like this:

```bash
NAME APP AGE
external-dns external-dns-<app_version> 36s
```

The CLI has triggered the application's deployment. However, this does not
mean that the application has been installed completely and successfully.

#### Verifying Whether the DNS Deployment Is Successful

Procedure

1. Set the environment variable to the target cluster (where you enabled
   external-dns) by exporting the

kubeconfig file in your terminal window or using the
--kubeconfig=${CLUSTER_NAME}.conf as explained in Commands within a kubeconfig
File on page 31. 2. Verify that the external-dns deployment is ready. Replace
`<target_WORKSPACE_NAMESPACE>` in the namespace -n flag with the target
cluster's workspace namespace.

```bash
kubectl get deployments.apps -n <target_WORKSPACE_NAMESPACE> external-dns
```

The deployment should display a ready state.

```bash
NAME READY UP-TO-DATE AVAILABLE AGE
external-dns 1/1 1 1 42s
```

The CLI has deployed the application completely and successfully.

#### Examining the Cluster's Ingress

Procedure

1. Set the environment variable to the target cluster (where you enabled
   external-dns) by exporting the

kubeconfig file in your terminal window or using the
--kubeconfig=${CLUSTER_NAME}.conf as explained in Commands within a kubeconfig
File on page 31. 2. Verify that the cluster's ingress contains the correct
hostname annotation. Replace `<target_WORKSPACE_NAMESPACE>` in the namespace
-n flag with the target cluster's workspace namespace.

```bash
kubectl get services -n <target_WORKSPACE_NAMESPACE> kommander-traefik -o yaml
```

The output looks like this. Ensure that the service object contains the
external-dns.alpha.kubernetes.io/hostname: `<mycluster.example.com>`
annotation.

```yaml
apiVersion: v1
kind: Service
metadata:
annotations:
meta.helm.sh/release-name: kommander-traefik
meta.helm.sh/release-namespace: kommander
external-dns.alpha.kubernetes.io/hostname: <mycluster.example.com>
creationTimestamp: "2023-06-21T04:52:49Z"
finalizers:
[...]
```

The external-dns service has been linked to the cluster correctly.

#### Verifying the DNS Record

About this task

```yaml
Note: It can take a few minutes for the external-dns service to create a DNS record. The delay depends on your
cloud provider.
```

Procedure

1. Set the environment variable to the target cluster (where you enabled
   external-dns) by exporting the

kubeconfig file in your terminal window or using the
--kubeconfig=${CLUSTER_NAME}.conf as explained in Commands within a kubeconfig
File on page 31. 2. Access and run the required image.

```bash
kubectl run -it --image=nicolaka/netshoot --rm test-dns -- /bin/bash
```

1. Use the image to check your domain and see the record. Replace
   `<mycluster.example.com>` with the domain you assigned to your target
   cluster.

```bash
nslookup <mycluster.example.com>
```

The output should look like this.

```yaml
Server: 192.168.178.1
Address: 192.168.178.1#53
Non-authoritative answer:
Name: <mycluster.example.com>
Address: 134.568.789.12
```

The external-dns service is working, and the DNS provider recognizes the
record created by the service. If the command displays an error, the
configuration is failing on the end of the DNS provider.

```yaml
Troubleshooting: If your deployment has not succeeded and the previous steps have not helped you identify the
issue, you can also check the logs for the external-dns deployment:
```

- 1. Set the environment variable to the target cluster (where you enabled
     external-dns) by exporting the

kubeconfigfile in your terminal window or using the
--kubeconfig=${CLUSTER_NAME}.conf as explained in Commands within a kubeconfig
File on page 31. 2. Verify the external-dns logs:

Replace `<target_WORKSPACE_NAMESPACE>` in the namespace -n flag with the
target cluster's workspace namespace.

```bash
kubectl logs -n kommander deployment/external-dns
```

The output displays the pod's logs for the external-dns deployment. Here is an
example:

```bash
...
time="2023-07-04T06:56:35Z" level=info msg="Instantiating new Kubernetes
client"
time="2023-07-04T06:56:35Z" level=info msg="Using inCluster-config based on
serviceaccount-token"
time="2023-07-04T06:56:35Z" level=info msg="Created Kubernetes client
https://10.96.0.1:443"
time="2023-07-04T06:56:35Z" level=error msg="records retrieval failed: failed
to list hosted zones:
...
```

### External Load Balancer

NKP includes a load-balancing solution for the Supported Infrastructure
Operating Systems on page 12 and for pre-provisioned environments. For more
information, see Load Balancing on page 637.

Procedure

1. Open the Kommander Installer Configuration File or kommander.yaml file.

a. If you do not have the kommander.yaml file, see Installing Kommander with a
Configuration File on page 997 so that you can edit it in the following steps.

> **Warning: Initialize this file only once. Otherwise you will overwrite
> previous customizations.**

b. If you have installed the Kommander component already, open the existing
kommander.yaml with the editor of your choice. 2. In that file, add the
following line for the IP address or DNS name:

```yaml
Warning: ACME does not support the automatic creation of a certificate if you select an IP address for your
clusterHostname.
[...]
clusterHostname: <mycluster.example.com OR IP_address>
[...]
```

1. (Optional): If you require a custom certificate for your clusterHostname,
   see Configuring the Kommander Installation with a Custom Domain and
   Certificate on page 1001.
2. In the same Kommander Installer Configuration File, configure Kommander to
   use the NodePort service by adding a custom configuration under traefik.

```yaml
Warning: You can specify the nodePort entry points for the load balancer. Ensure the port is within the
Kubernetes default (30 000 - 32 768). If not specified, Kommander assigns a port dynamically.
traefik:
enabled: true
values: |-
ports:
web:
nodePort: 32080 #if not specified, will be assigned dynamically
websecure:
nodePort: 32443 #if not specified, will be assigned dynamically
registry:
nodePort: 35000 #if not specified, will be assigned dynamically
external-ceph:
nodePort: 32808 #if not specified, will be assigned dynamically
service:
type: NodePort
```

> **Note: Additional port configuration may be necessary depending on the
> Traefik port configuration.** 5. Use the configuration file to install
> Kommander.

See Kommander Customizations on page 996.

#### Configuring the External Load Balancer to Target the Specified Ports

Procedure

Configure the load balancer targets to include every worker node address (DNS
name or IP address) and node port combination by following this format.

```bash
<node1>:<nodePort_web> # for example, my.node1.internal:32080
<node2>:<nodePort_web>
<node3>:<nodePort_web>
[...]
<node1>:<nodePort_websecure> # for example, my.node1.internal:32443
<node2>:<nodePort_websecure>
<node3>:<nodePort_websecure>
[...]
```

> **Note: The exact configuration depends on your load balancer provider.**

### HTTP Proxy Configuration Considerations

When you configure HTTP proxy settings for a Kubernetes cluster, you must
exclude certain network addresses from proxy routing. Internal cluster
communications must bypass the proxy to maintain performance and security.
Always add the following addresses to the noProxy configuration:

- Loopback addresses such as 127.0.0.1 and localhost.
- Kubernetes API server addresses:
- The current cluster's endpoint VIP address and all control-plane addresses,
  including the IP pool. Kubelet (Go- based) handles CIDR in NO_PROXY, so you
  can specify these in CIDR format.
- On management clusters, the Kubernetes API endpoint VIPs of all managed
  clusters must be listed as explicit IP addresses, not in CIDR format. The
  Kommander UI does not interpret CIDR format in NO_PROXY.
- Kubernetes Pod IP addresses. For example, 192.168.0.0/16.

Pod IP addresses come from two sources:

- The pod CIDR configured in the CNI plugin. Defaults to 192.168.0.0/16.
- The podSubnet value configured in CAPI objects, which must match the CNI pod
  CIDR. Defaults to 192.168.0.0/16.
- Kubernetes Service addresses and DNS names:
- Service CIDR. For example, 10.96.0.0/12.
- Kubernetes API service names such as kubernetes, kubernetes.default, and so
  on.
- Service DNS suffixes such as .svc, .svc.cluster, .svc.cluster.local, svc.,
  .svc.cluster., and .svc.cluster.local..
- Auto-IP addresses such as 169.254.169.254 and 169.254.0.0/24.
- IP address or hostname of the kommander-traefik service for the type:
  LoadBalancer in the kommander namespace.
- For Nutanix infrastructure, Preprovisioned, and vSphere: Use the first IP
  address in the MetalLB range for the kommander-traefik service.
- For cloud providers: By default, the kommander-traefik IP address or
  hostname is unknown before creation.

Infrastructure-Specific Settings

In addition, the following infrastructure-specific settings might apply:

For AWS, add the default VPC CIDR range 10.0.0.0/16 to noProxy configuration.

Additional Notes

Add all of the addresses listed above to the NO_PROXY variable when
configuring HTTP proxy settings for your cluster.

> **Important:**

- The NO_PROXY variable contains the Kubernetes Services CIDR. This
  documentation uses the default CIDR (10.96.0.0/12). If your cluster uses a
  different CIDR, update the value in the NO_PROXY field accordingly.
- Core services might not receive proxy environment variables due to
  Gatekeeper deployment timing. Gatekeeper guarantees proxy environment
  variables only to user-deployed workloads. To ensure a core service uses
  your proxy environment variables, restart the AppDeployment for that
  service.
- Add a trailing dot to wildcard domain suffixes in NO_PROXY (for example,
  .svc.cluster.local. instead of .svc.cluster.local). Without the trailing
  dot, proxy clients append the cluster search domain, which routes internal
  cluster traffic through the proxy.

#### Configuring HTTP proxy for the Kommander Clusters

About this task

Kommander supports environments that connect through an HTTP/HTTPS proxy when
access to the Internet is restricted. Use the information in this section to
configure the Kommander component of NKP correctly.

In these environments, you must configure Kommander to use the HTTP/HTTPS
proxy. In turn, Kommander configures all platform services to use the
HTTP/HTTPS proxy.

```yaml
Note: Kommander follows a common convention for using an HTTP proxy server. The convention is based on three
environment variables, and is supported by many, though not all, applications.
```

- HTTP_PROXY: the HTTP proxy server address
- HTTPS_PROXY: the HTTPS proxy server address
- NO_PROXY: a list of IP addresses and domain names that are not subject to
  proxy settings

Before you begin

- The curl command-line tool is available on the host.
- The proxy server address is `<http://proxy.company.com:3128>`.
- The HTTP and HTTPS proxy server addresses use the http scheme.
- The proxy server can reach `<www.google.com>` using HTTP or HTTPS.

Procedure

1. Verify the cluster nodes can access the Internet through the proxy server.
2. On each cluster node, run the following command.

```bash
curl --proxy http://proxy.company.com:3128 --head http://www.google.com
curl --proxy http://proxy.company.com:3128 --head https://www.google.com
```

If the proxy is working for HTTP and HTTPS, respectively, the curl command
returns a 200 OK HTTP response.

#### Enabling Gatekeeper

About this task

For more information, see MutatingAdmissionWebhook.

You can use this to mutate the Pod resources with HTTP_PROXY, HTTPS_PROXY and
NO_PROXY environment variables.

To enable Gatekeeper, follow these steps:

Procedure

1. Create (if necessary) or update the Kommander installation configuration
   file. If one does not already exist, then create it using the following
   commands.

```bash
nkp install kommander --init > kommander.yaml
```

1. Append this apps section to the kommander.yaml file with the following
   values to enable Gatekeeper and configure it to add HTTP proxy settings to
   the pods.

```yaml
Note: Only pods created after applying this setting will be mutated. Also, this will only affect pods in the
namespace with the "gatekeeper.d2iq.com/mutate=pod-proxy" label.
apps:
gatekeeper:
values: |
disableMutation: false
mutations:
enablePodProxy: true
podProxySettings:
noProxy:
"127.0.0.1,192.168.0.0/16,10.0.0.0/16,10.96.0.0/12,169.254.169.254,169.254.0.0/24,localhost,kub
operator-logging-fluentd.kommander.svc.cluster.local,elb.amazonaws.com"
httpProxy: "http://proxy.company.com:3128"
httpsProxy: "http://proxy.company.com:3128"
excludeNamespacesFromProxy: []
namespaceSelectorForProxy:
"gatekeeper.d2iq.com/mutate": "pod-proxy"
Note: If you choose to keep the Kubecost application and its data running while upgrading Kommander to Nutanix
Kubernetes Platform (NKP) 2.17, ensure that you include kubecost-prometheus-server.kommander as
a comma#separated value for noProxy.
```

1. Create the kommander and kommander-flux namespaces, or the namespace where
   Kommander will be installed. Label the namespaces to activate the Gatekeeper
   mutation on them.

```bash
kubectl create namespace kommander
kubectl label namespace kommander gatekeeper.d2iq.com/mutate=pod-proxy
kubectl create namespace kommander-flux
kubectl label namespace kommander-flux gatekeeper.d2iq.com/mutate=pod-proxy
```

#### Creating Gatekeeper ConfigMap in the Kommander Namespace

Procedure

Run the following command.

```bash
export NAMESPACE=kommander
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
name: gatekeeper-overrides
namespace: ${NAMESPACE}
data:
values.yaml: |
---
# enable mutations
disableMutation: false
mutations:
enablePodProxy: true
podProxySettings:
noProxy:
"127.0.0.1,192.168.0.0/16,10.0.0.0/16,10.96.0.0/12,169.254.169.254,169.254.0.0/24,localhost,kubern
operator-logging-fluentd.kommander.svc.cluster.local,elb.amazonaws.com"
httpProxy: "http://proxy.company.com:3128"
httpsProxy: "http://proxy.company.com:3128"
excludeNamespacesFromProxy: []
namespaceSelectorForProxy:
"gatekeeper.d2iq.com/mutate": "pod-proxy"
EOF
Note: If you choose to keep the Kubecost application and its data running while upgrading Kommander to Nutanix
Kubernetes Platform (NKP) 2.17, ensure that you include kubecost-prometheus-server.kommander as a
comma#separated value for noProxy.
```

Set the httpProxy and httpsProxy environment variables to the address of the
HTTP and HTTPS proxy servers, respectively. Set the noProxy environment
variable to the addresses that should be accessed directly, not through the
proxy.

Performing this step before installing Kommander allows the Flux components to
respect the proxy configuration in this ConfigMap.

#### Configuring the Workspace or Project

Procedure

1. To have Gatekeeper mutate the manifests, create the Workspace (or Project)
   with the following label.

```bash
labels:
gatekeeper.d2iq.com/mutate: "pod-proxy"
```

1. This can be done when creating the Workspace (or Project) from the UI OR by
   running the following command from the CLI after creating the namespace.

```bash
kubectl label namespace <NAMESPACE> "gatekeeper.d2iq.com/mutate=pod-proxy"
Note: For NKP Starter clusters, you cannot perform this procedure from the UI. Instead, configure the Kommander
namespace labels by modifying the template of the federated namespace directly:
kubectl patch fns -n kommander kommander --type json -p '[{"op":"add",
"path":"/spec/template/metadata/labels/gatekeeper.d2iq.com~1mutate",
"value":"pod-proxy"}]'
```

#### Configuring HTTP Proxy in Attached Clusters

Procedure

1. Run the following command in the attached cluster before attaching it to
   the management cluster.

```bash
kubectl create namespace <NAMESPACE>
```

1. Then, to configure the pods in this namespace to use proxy configuration,
   you must label the Workspace with gatekeeper.d2iq.com/mutate=pod-proxy when
   creating it so that Gatekeeper deploys a validatingwebhook to mutate the
   pods with proxy configuration.

```bash
kubectl label namespace <NAMESPACE> "gatekeeper.d2iq.com/mutate=pod-proxy"
```

#### Creating Gatekeeper ConfigMap in the Workspace Namespace

About this task

To configure Gatekeeper so that these environment variables are mutated in the
pods, create the following gatekeeper-overrides ConfigMap in the Workspace
Namespace.

Procedure

To export the Workspace Namespace, follow these steps:

```bash
export NAMESPACE=<NAMESPACE>
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
name: gatekeeper-overrides
namespace: ${NAMESPACE}
data:
values.yaml: |
---
# enable mutations (2)
disableMutation: false
mutations:
enablePodProxy: true
podProxySettings:
noProxy:
"127.0.0.1,192.168.0.0/16,10.0.0.0/16,10.96.0.0/12,169.254.169.254,169.254.0.0/24,localhost,kubern
operator-logging-fluentd.kommander.svc.cluster.local,elb.amazonaws.com"
httpProxy: "http://proxy.company.com:3128"
httpsProxy: "http://proxy.company.com:3128"
excludeNamespacesFromProxy: []
namespaceSelectorForProxy:
"gatekeeper.d2iq.com/mutate": "pod-proxy"
EOF
```

Set the httpProxy and httpsProxy environment variables to the address of the
HTTP and HTTPS proxy servers, respectively. Set the noProxy environment
variable to the addresses that should be accessed directly, not through the
proxy. To view the list of the recommended settings, see HTTP Proxy
Configuration Considerations on page 1018.

#### Configuring Your Application Manually

About this task

```yaml
Note: If Gatekeeper is not installed and you need to use an HTTP proxy, you must manually configure your
applications.
```

In this example, the environment variables are set for a container in a Pod.

For more information, see `<<https://kubernetes.io/docs/tasks/inject-data->`
application/define-environment-> variable-container/#define-an-environment-
variable-for-a-container.

Procedure

Some applications follow the convention of HTTP_PROXY, HTTPS_PROXY, and
NO_PROXY environment variables.

What to do next

Select your environment, and finish your Kommander Installation using one of
the following:

- Installing Kommander in an Air-gapped Environment on page 981
- Installing Kommander in a Non-Air-gapped Environment on page 984
- Installing Kommander in a Small Environment on page 991

### Creating Configuration Overrides for Flux Customizations

About this task

To create the configuration overrides for Flux, follow these steps:

```yaml
Note: Flux is a fundamental part of NKP. Ensure that you make the configuration changes with care. NKP provides
default configurations that cover most use cases. For advanced scenarios, follow these steps:
```

Procedure

1. Set the namespace value to WORKSPACE_NAMESPACE:

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

When you update Flux on the management cluster, the workspace defaults to
Kommander. 2. Create a kommander-flux-overrides.yaml: For more information,
see the following example:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: kommander-flux-overrides
namespace: ${WORKSPACE_NAMESPACE}
data:
values.yaml: |
helmController:
resources:
limits:
cpu: 2000m
memory: 2Gi
requests:
cpu: 500m
memory: 250Mi
kustomizeController:
resources:
limits:
cpu: 2500m
memory: 1Gi
requests:
cpu: 250m
memory: 150Mi
notificationController:
resources:
limits:
cpu: 1000m
memory: 1Gi
requests:
cpu: 100m
memory: 64Mi
sourceController:
resources:
limits:
cpu: 2000m
memory: 1Gi
requests:
cpu: 250m
memory: 100Mi
imageAutomationController:
create: true
imageReflectionController:
create: true
```

By default, NKP enables the imageAutomationController and
imageReflectionController. To disable these controllers, you can set the
create value to false. 3. Create a configuration customization for Flux:

```bash
kubectl apply -f kommander-flux-overrides.yaml
```

1. (Optional) To update the configuration customization for Flux, follow Step
   1 and to update and re-apply the

kommander-flux-overrides.yaml, follow Step 2.

## Additional Konvoy Configurations

When installing Nutanix Kubernetes Platform (NKP for a project, line-of-
business, or enterprise, the first step is to determine the infrastructure on
which you want to deploy. The infrastructure you select then determines the
specific requirements for a successful installation.

For basic recommended installations by infrastructure, see Basic Installations
by Infrastructure on page 72.

For custom or advanced installations by infrastructure, see Custom
Installation and Infrastructure Tools on page 696.

If you have decided to uninstall NKP, see the same infrastructure
documentation you have selected in the Basic Installations by Infrastructure
on page 72.

## FIPS 140-3 Compliance

Understand FIPS-140 operating mode and requirements.

Developed by a working group of government, industry operators, and vendors,
the Federal Information Processing Standard
(FIPS), FIPS-140 defines security requirements for cryptographic modules. FIPS
defines what cryptographic cyphers can be
used. Kubernetes uses encryption by default between various components, and
FIPS support ensures that the ciphers used
for those communications meet those standards. The standard provides a broad
spectrum of data sensitivity, transaction
values, and various application environment security situations. The standard
specifies four security levels for each of
the eleven requirement areas. Each successive level offers increased security.

NIST introduced FIPS 140-3 validation by accredited third-party laboratories
as a formal, rigorous process to protect sensitive digitally stored
information not under Federal security classifications.

### FIPS Support in NKP

Nutanix Kubernetes Platform (NKP) supports provisioning a FIPS-enabled
Kubernetes control plane. Core Kubernetes components are compiled using a
version of Go called goboring, which uses a FIPS-certified cryptographic
module for all cryptographic functions. For more information, see
`<https://csrc.nist.gov/CSRC/>` media/projects/cryptographic-module-validation-
program/documents/security-policies/140sp3702.pdf.

Before provisioning NKP, follow your OS vendor's instructions to ensure that
your OS or OS images are prepared for operating in FIPS mode. To view an
example for Red Hat Enterprise Linux (RHEL), see https://
access.redhat.com/documentation/en-
us/red_hat_enterprise_linux/7/html/security_guide/chap-
federal_standards_and_regulations#sec-Enabling-FIPS-Mode.

Additional helpful reading:

- CSRC. See `<https://csrc.nist.gov/publications/fips>`
- Federal Information Processing Standards Publication. See
  `<https://nvlpubs.nist.gov/nistpubs/FIPS/>` NIST.FIPS.140-3.pdf
- For the steps to create a FIPS compliant image, see Building a Custom Image
  with Nutanix on page 53.

```yaml
Note: You cannot apply FIPS mode to an existing cluster. You must create a new cluster with FIPS enabled. Similarly,
a FIPS-mode cluster must remain a FIPS-mode cluster; you cannot change the FIPS status after creating it.
```

### Infrastructure Requirements for FIPS 140-3 Mode

Be sure that your environment meets the FIPS 140 Mode Performance Impact
requirements. For more information, see FIPS 140 Mode Performance Impact.

Supported Operating Systems

Supported Operating Systems for FIPS mode are Red Hat Enterprise Linux and
CentOS. For details on the tested and supported versions, see Supported
Infrastructure Operating Systems.

### Deploying Clusters in FIPS Mode

Kubernetes docker.io/mesosphere v`<kubernetes-version>`+fips.0

For more information, see Supported Kubernetes Versions section in the NKP
Release Notes.

etcd docker.io/mesosphere etcd-version+fips.0

For more information about the supported etcd version, see Supported
Components section in the NKP Release Notes.

AWS Example

When creating a cluster, use the following command line options:

- --ami `<fips enabled AMI>` (AWS only)
- --kubernetes-version `<version>`+fips.`<build>`
- --etcd-version `<version>`+fips.`<build>`
- --kubernetes-image-repository docker.io/mesosphere
- --etcd-image-repository docker.io/mesosphere

```bash
nkp create cluster aws --cluster-name myFipsCluster \
--ami=ami-03dcaa75d45aca36f \
--kubernetes-version=v<kubernetes-version>+fips.0 \
--kubernetes-image-repository=docker.io/mesosphere \
--etcd-image-repository=docker.io/mesosphere \
--etcd-version=etcd-version+fips.0
```

vSphere Example

```bash
nkp create cluster vsphere \
--cluster-name ${CLUSTER_NAME} \
--network <NETWORK_NAME> \
--control-plane-endpoint-host <xxx.yyy.zzz.000> \
--data-center <DATACENTER_NAME> \
--data-store <DATASTORE_NAME> \
--folder <FOLDER_NAME> \
--server <VCENTER_API_SERVER_URL> \
--ssh-public-key-file <SSH_PUBLIC_KEY_FILE> \
```

| Component | Repository | Version |
| --------- | ---------- | ------- |

```bash
--resource-pool <RESOURCE_POOL_NAME> \
--vm-template <TEMPLATE_NAME> \
--self-managed \
--kubernetes-version=v<kubernetes-version>+fips.0 \
--kubernetes-image-repository=docker.io/mesosphere \
--etcd-image-repository=docker.io/mesosphere --etcd-version=etcd-version+fips.0
```

### FIPS 140 Images: Non-Air-Gapped Environments

Use the fips.yaml override file provided with the image bundles to produce
images containing FIPS-140 compliant binaries. For more information, see
Nutanix Image Builder on page 51.

### FIPS 140 Images: Air-gapped Environment

Use the fips.yaml override file provided with the image bundles to produce
images containing FIPS-140 compliant binaries. For more information, see
Nutanix Image Builder on page 51.

#### Creating FIPS Clusters in Pre-provisioned FIPS Infrastructure

About this task

If you are targeting Pre-provisioned Installation Options on page 72, you can
create a FIPS-compliant cluster by doing the following:

Procedure

1. Create a Pre-provisioned: Bootstrap Cluster
2. Create a secret on the bootstrap cluster with the contents from fips.yaml
   override file and any other user overrides you wish to provide.

```bash
kubectl create secret generic $CLUSTER_NAME-fips-overrides --from-
file=overrides.yaml=overrides.yaml
kubectl label secret $CLUSTER_NAME-fips-overrides clusterctl.cluster.x-k8s.io/move=
```

### Validate FIPS 140 in Cluster

You can use the FIPS validation tool to verify that specific components and
services are FIPS-compliant. The tool checks the components by comparing their
file signatures against those stored in a signed signature file and by
checking that services use the certified algorithms.

Run FIPS Validation

To verify the FIPS compliant cluster, run nkp check cluster fips. This command
reads from the signature files embedded in the nkp executable to validate that
specific components and services are FIPS-compliant. Run the command:

The full command usage and flags include:

```bash
nkp check cluster fips
```

Upon successful completion, the command's output displays details about the
deployment in JSON format. If validation fails, the output will say which
components fail and a list of the nodes that failed validation will return.

The full command usage and flags include:

```bash
nkp check cluster fips [flags]
```

Flags:

```bash
-h, --help Help for fips
--kubeconfig string Path to the kubeconfig file for the fips cluster.
If unspecified, default discovery rules apply.
-n, --namespace string If present, the namespace scope for this CLI
request. (default "default")
--output-configmap string ConfigMap to store result of the fips check.
(default "check-cluster-fips-output") (DEPRECATED: This flag will be removed in a
future release.)
--signature-configmap string ConfigMap with fips signature data to verify.
--signature-file string File containing fips signature data.
--timeout duration The length of time to wait before giving up. Zero
means wait forever (e.g. 1s, 2m, 3h). (default 10m0s)
```

### FIPS 140 Mode Performance Impact

The Go language cryptographic module, Goboring, relies on CGO's foreign
function interface to call C-language functions exposed by the cryptographic
module. Each call into the C library starts with a base overhead of 200ns.

One benchmark finds that the time to encrypt a single AES-128 block increased
from 13ns to 209ns over the internal Golang implementation. The preferred mode
of Nutanix's FIPS module is TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384.

The aggregate impact on a stable control plane seems to be an increase of
around 10% CPU utilization over default operation. Workloads that do not
directly interact with the control plane are not affected.

For more information, see `<https://github.com/golang/go/issues/21525>`.

## Registry Mirror Tools

Using an external solution for storing and sharing container images.

Kubernetes does not natively provide a registry for hosting the container
images you will use to run the applications you want to deploy on Kubernetes.
Instead, Kubernetes requires you to use an external solution to store and
share container images. There are a variety of Kubernetes-compatible registry
options that are compatible with Nutanix Kubernetes Platform (NKP).

How Does it Work?

The first time you request an image from your local registry mirror, it pulls
the image from the public registry (such as Docker) and stores it locally
before handing it back to you. On subsequent requests, the local registry
mirror can serve the image from its own storage.

### Air-gapped vs. Non-air-gapped Environments

In a non-air-gapped environment, you can access the Internet. You retrieve
artifacts from specialized repositories dedicated to them, such as Docker
images contained in DockerHub and Helm Charts that come from a dedicated Helm
Chart repository. You can also create your local repository to hold the
downloaded container images needed or any custom images you've created with
the Nutanix Image Builder on page 51 tool.

In an air-gapped environment, you need a local repository to store Helm
charts, Docker images, and other artifacts.
Private registries provide security and privacy in enterprise container image
storage, whether hosted remotely or on-
premises locally in an air-gapped environment. Nutanix Kubernetes Platform
(NKP) in an air-gapped environment requires a
local container registry of trusted images to enable production-level
Kubernetes cluster management. However, a local
registry is also an option in a non-air-gapped environment for speed and
security.

If you want to use images from this local registry to deploy applications
inside your Kubernetes cluster, you'll need to set up a secret for a private
registry. The secret contains your login data, which Kubernetes needs to
connect to your private repository.

### Local Registry Tools Compatible with NKP

#### JFrog Artifactory

#### AWS ECR

AWS ECR (Elastic Container Registry) is supported as your air-gapped image
registry or a non-air-gapped registry mirror. Nutanix Kubernetes Platform
(NKP) added support for using AWS ECR as a default registry when uploading
image bundles in AWS.

Prerequisites

- Ensure that you have followed the steps to create proper permissions.
- Ensure that you have the required AWS Prerequisites on page 815

Upload the Air-gapped Image Bundle to the Local ECR Registry:

A cluster administrator uses NKP CLI commands to upload the image bundle to
ECR with parameters:

```bash
nkp push bundle --bundle <bundle> --to-registry=<ecr-registry-address>/<ecr-registry-
name>
```

Parameter Definitions:

- --bundle `<bundle>` the group of images. The example below is for the NKP
  air-gapped environment bundle
- --to-registry=`<ecr-registry-address>`/`<ecr-registry-name>` to provide
  registry location for push

An example command:

```bash
nkp push bundle --bundle container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=333000009999.
dkr.ecr.us-west-2.amazonaws.com/can-test
```

> **Note: You can also set an environment variable with your registry
> address for ECR:**

```bash
export REGISTRY_URL=<ecr-registry-URI>
```

- REGISTRY_URI: the address of an existing local registry accessible in the
  VPC that the new cluster nodes will be configured to use a mirror registry
  when pulling images.
- The environment where you are running the NKP push command must be
  authenticated with AWS to load your images into ECR.

Air-gapped Environment Information regarding your AWS ECR Account

The cluster administrator uses existing NKP CLI commands to create the cluster
and refer to their internal ECR for image repository. The administrator does
not need to provide static ECR registry credentials. See Use a Registry Mirror
and Create an EKS Cluster from the CLI for more details.

#### JFrog Artifactory (2)

For more information, see `<https://jfrog.com/artifactory/>`.

#### Nexus Registry

Nexus Repository is a package registry for your Docker images and Helm Chart
repositories and supports Proxy, Hosted, and Group repositories. It can be
used as a single registry for all your Kubernetes deployments.

For more information, see `<<https://www.sonatype.com/products/sonatype-nexus->`
repository>.

#### Harbor Registry

While seeding, you may see error messages such as the following:

```bash
2023/09/12 20:01:18 retrying without mount: POST https://harbor-registry.daclusta/
v2/harbor-registry/mesosphere/kube-proxy/blobs/uploads/?from=mesosphere%2Fkube-
proxy&mount=sha256%3A9fd5070b83085808ed850ff84acc98a116e839cd5dcfefa12f2906b7d9c6e50d&origin=REDACT
UNAUTHORIZED: project not found, name: mesosphere: project not found, name: mesosphere
```

This indicates that the image was not successfully pushed to your Harbor
docker registry but is a false positive error message. This will only affect
the version of the Nutanix Kubernetes Platform (NKP) binary newer than NKP
2.14.0. This does not affect any other Local Registry solution, such as Nexus
or Artifactory. You can safely ignore these error messages.

#### Bastion Host

When creating an air-gapped cluster, the bastion Virtual Machine (VM) hosts
the installation of the Nutanix Kubernetes Platform (NKP) Konvoy bundles,
images, and the Docker or other local registry are needed to create and
operate your cluster. In a given environment, the bastion VM must have access
to the infrastructure provider's Application Programming Interface (API).

#### Related Information

If you need to configure a private registry with a registry mirror, see Use a
Registry Mirror.

### Using a Registry Mirror

Registry mirrors are local copies of images from a public registry that
follows (or mirrors) the file structure of a public registry. You can push
container images to a local registry from downloaded images or images you
create with the Nutanix Image Builder on page 51. If your environment allows
Internet access, the mirror registry consults its upstream registries when an
image is not found locally. This kind of registry contains no images other
than the ones requested.

## Seeding the Registry for an Air-gapped Cluster

About this task

### Bastion Host (2)

This procedure is optional and not mandatory for clusters created from NKP
2.16 onwards.

> **Note: If you do not already have a local registry set up, see the Local
> Registry Tools page for more information.**

Procedure

1. If not already done in prerequisites, download the air-gapped bundle nkp-
   air-gapped-bundle_nkp-

version_linux_amd64.tar.gz, and extract the tarball to a local directory. 2.
The directory structure after extraction can be accessed in subsequent steps
using commands to access files from different directories. Change your
directory to the NKP `<version>` directory for the bootstrap cluster example, 3. Set an environment variable with your registry address and any other needed
variables using this command.

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
export REGISTRY_CA=<path to the cacert file on the bastion>
```

1. Execute the following command to load the air-gapped image bundle into your
   private registry using any relevant flags to apply the mentioned variables.

```bash
nkp push bundle --bundle ./container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=${REGISTRY_URL}
--to-registry-username=${REGISTRY_USERNAME} --to-registry-password=
${REGISTRY_PASSWORD}
```

> **Note:**

- NKP takes some time to push all the images to your image registry, depending
  on the performance of the network between the machine you are running the
  script on and the registry.
- To use Elastic Container Registry (ECR), set an environment variable with
  your registry address for ECR:

```bash
export REGISTRY_URL=<ecr-registry-URI>
```

- REGISTRY_URL: the address of an existing local registry accessible in the
  Virtual Private Cloud (VPC) that the new cluster nodes will be configured to
  use a mirror registry when pulling images.
- The environment where you are running the nkp push command must be
  authenticated with AWS in order to load your images into ECR.

You are now ready to create an air-gapped bootstrap cluster for a custom
cluster for your infrastructure provideror create an air-gapped cluster from
the Day 1 - Basic Installs section for your provider.

Example directory structure after extraction::

```bash
nkp-nkp-version/
### application-charts
# ### NOTICES.txt
# ### nkp-insights-charts-bundle-nkp-version-rc.2.tar.gz
# ### nkp-kommander-charts-bundle-nkp-version-rc.2.tar.gz
### application-repositories
# ### nkp-insights-nkp-version-rc.2.tar.gz
# ### kommander-applications-nkp-version-rc.2.tar.gz
### container-images
# ### NOTICES.txt (2)
# ### nkp-insights-image-bundle-nkp-version-rc.2.tar
# ### kommander-image-bundle-nkp-version-rc.2.tar
# ### konvoy-image-bundle-nkp-version>-rc.2.tar
```

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

- tar -xzvf nkp-air-gapped-bundle \_; nkp-version; > linux amd64.tar.gz \_ \_

| --- | --- | --- |

| cd nkp- | nkp-version | Col3 |
| ------- | ----------- | ---- |

```bash
### nkp
### nib
# ### LICENSE
# ### README.md
# ### ansible
# ### artifacts
# ### goss
# ### images
# ### konvoy-image
# ### overrides
### konvoy-bootstrap-image-nkp-version-rc.2.tar
### kubectl
```

## Control Plane Configuration

Users can modify the KubeadmControlplane cluster-api object to configure
different kubelet options. See the following guide if you wish to configure
your control plane beyond the existing options available from flags.

Prerequisites

Make sure you have created your cluster using a bootstrap cluster from the
respective Infrastructure Providers section.

### Modifying Audit Logs

About this task

To modify the control plane option, get the appropriate cluster-api objects
that describe the cluster by running the following command:

```yaml
Note: The following example uses AWS, but can be used for non-ClusterClass based clusters such as gcp, azure,
preprovisioned, and vsphere clusters.
nkp create cluster aws -c {MY_CLUSTER_NAME} -o yaml --dry-run >>
{MY_CLUSTER_NAME}.yaml
```

Procedure

1. When you open {MY_CLUSTER_NAME}.yaml with your favorite text editor, look
   for the KubeadmControlPlane object for your cluster. For example.

```yaml
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
metadata:
name: my-cluster-control-plane
namespace: default
spec:
kubeadmConfigSpec:
clusterConfiguration:
apiServer:
extraArgs:
audit-log-maxage: "30"
audit-log-maxbackup: "10"
audit-log-maxsize: "100"
audit-log-path: /var/log/audit/kube-apiserver-audit.log
audit-policy-file: /etc/kubernetes/audit-policy/apiserver-audit-policy.yaml
cloud-provider: aws
encryption-provider-config: /etc/kubernetes/pki/encryption-config.yaml
extraVolumes:
- hostPath: /etc/kubernetes/audit-policy/
mountPath: /etc/kubernetes/audit-policy/
name: audit-policy
- hostPath: /var/log/kubernetes/audit
mountPath: /var/log/audit/
name: audit-logs
controllerManager:
extraArgs:
cloud-provider: aws
configure-cloud-routes: "false"
dns: {}
etcd:
local:
imageTag: 3.5.7
networking: {}
scheduler: {}
files:
- content: |
# Taken from https://github.com/kubernetes/kubernetes/blob/master/cluster/
gce/gci/configure-helper.sh
# Recommended in Kubernetes docs
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
# The following requests were manually identified as high-volume and low-
risk,
# so drop them.
- level: None
users: ["system:kube-proxy"]
verbs: ["watch"]
resources:
- group: "" # core
resources: ["endpoints", "services", "services/status"]
- level: None
# Ingress controller reads 'configmaps/ingress-uid' through the unsecured
port.
# TODO(#46983): Change this to the ingress controller service account.
users: ["system:unsecured"]
namespaces: ["kube-system"]
verbs: ["get"]
resources:
- group: "" # core
resources: ["configmaps"]
- level: None
users: ["kubelet"] # legacy kubelet identity
verbs: ["get"]
resources:
- group: "" # core
resources: ["nodes", "nodes/status"]
- level: None
userGroups: ["system:nodes"]
verbs: ["get"]
resources:
- group: "" # core
resources: ["nodes", "nodes/status"]
- level: None
users:
- system:kube-controller-manager
- system:kube-scheduler
- system:serviceaccount:kube-system:endpoint-controller
verbs: ["get", "update"]
namespaces: ["kube-system"]
resources:
- group: "" # core
resources: ["endpoints"]
- level: None
users: ["system:apiserver"]
verbs: ["get"]
resources:
- group: "" # core
resources: ["namespaces", "namespaces/status", "namespaces/finalize"]
- level: None
users: ["cluster-autoscaler"]
verbs: ["get", "update"]
namespaces: ["kube-system"]
resources:
- group: "" # core
resources: ["configmaps", "endpoints"]
# Don't log HPA fetching metrics.
- level: None
users:
- system:kube-controller-manager
verbs: ["get", "list"]
resources:
- group: "metrics.k8s.io"
# Don't log these read-only URLs.
- level: None
nonResourceURLs:
- /healthz*
- /version
- /swagger*
# Don't log events requests.
- level: None
resources:
- group: "" # core
resources: ["events"]
# node and pod status calls from nodes are high-volume and can be large,
don't log responses for expected updates from nodes
- level: Request
users: ["kubelet", "system:node-problem-detector",
"system:serviceaccount:kube-system:node-problem-detector"]
verbs: ["update","patch"]
resources:
- group: "" # core
resources: ["nodes/status", "pods/status"]
omitStages:
- "RequestReceived"
- level: Request
userGroups: ["system:nodes"]
verbs: ["update","patch"]
resources:
- group: "" # core
resources: ["nodes/status", "pods/status"]
omitStages:
- "RequestReceived"
# deletecollection calls can be large, don't log responses for expected
namespace deletions
- level: Request
users: ["system:serviceaccount:kube-system:namespace-controller"]
verbs: ["deletecollection"]
omitStages:
- "RequestReceived"
# Secrets, ConfigMaps, and TokenReviews can contain sensitive & binary
data,
# so only log at the Metadata level.
- level: Metadata
resources:
- group: "" # core
resources: ["secrets", "configmaps"]
- group: authentication.k8s.io
resources: ["tokenreviews"]
omitStages:
- "RequestReceived"
# Get responses can be large; skip them.
- level: Request
verbs: ["get", "list", "watch"]
resources:
- group: "" # core
- group: "admissionregistration.k8s.io"
- group: "apiextensions.k8s.io"
- group: "apiregistration.k8s.io"
- group: "apps"
- group: "authentication.k8s.io"
- group: "authorization.k8s.io"
- group: "autoscaling"
- group: "batch"
- group: "certificates.k8s.io"
- group: "extensions"
- group: "metrics.k8s.io"
- group: "networking.k8s.io"
- group: "node.k8s.io"
- group: "policy"
- group: "rbac.authorization.k8s.io"
- group: "scheduling.k8s.io"
- group: "settings.k8s.io"
- group: "storage.k8s.io"
omitStages:
- "RequestReceived"
# Default level for known APIs
- level: RequestResponse
resources:
- group: "" # core
- group: "admissionregistration.k8s.io"
- group: "apiextensions.k8s.io"
- group: "apiregistration.k8s.io"
- group: "apps"
- group: "authentication.k8s.io"
- group: "authorization.k8s.io"
- group: "autoscaling"
- group: "batch"
- group: "certificates.k8s.io"
- group: "extensions"
- group: "metrics.k8s.io"
- group: "networking.k8s.io"
- group: "node.k8s.io"
- group: "policy"
- group: "rbac.authorization.k8s.io"
- group: "scheduling.k8s.io"
- group: "settings.k8s.io"
- group: "storage.k8s.io"
omitStages:
- "RequestReceived"
# Default level for all other requests.
- level: Metadata
omitStages:
- "RequestReceived"
path: /etc/kubernetes/audit-policy/apiserver-audit-policy.yaml
permissions: "0600"
- content: |
#!/bin/bash
# CAPI does not expose an API to modify KubeProxyConfiguration
# this is a workaround to use a script with preKubeadmCommand to modify the
kubeadm config files
# https://github.com/kubernetes-sigs/cluster-api/issues/4512
for i in $(ls /run/kubeadm/ | grep 'kubeadm.yaml\|kubeadm-join-config.yaml');
do
cat <<EOF>> "/run/kubeadm//$i"
---
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
metricsBindAddress: "0.0.0.0:10249"
EOF
done
path: /run/kubeadm/konvoy-set-kube-proxy-configuration.sh
permissions: "0700"
- content: |
[metrics]
address = "0.0.0.0:1338"
grpc_histogram = false
path: /etc/containerd/conf.d/konvoy-metrics.toml
permissions: "0644"
- content: |
#!/bin/bash (2)
systemctl restart containerd
SECONDS=0
until crictl info
do
if (( SECONDS > 60 ))
then
echo "Containerd is not running. Giving up..."
exit 1
fi
echo "Containerd is not running yet. Waiting..."
sleep 5
done
path: /run/konvoy/restart-containerd-and-wait.sh
permissions: "0700"
- contentFrom:
secret:
key: value
name: my-cluster-etcd-encryption-config
owner: root:root
path: /etc/kubernetes/pki/encryption-config.yaml
permissions: "0640"
format: cloud-config
initConfiguration:
localAPIEndpoint: {}
nodeRegistration:
kubeletExtraArgs:
cloud-provider: aws
name: '{{ ds.meta_data.local_hostname }}'
joinConfiguration:
discovery: {}
nodeRegistration:
kubeletExtraArgs:
cloud-provider: aws
name: '{{ ds.meta_data.local_hostname }}'
preKubeadmCommands:
- systemctl daemon-reload
- /run/konvoy/restart-containerd-and-wait.sh
- /run/kubeadm/konvoy-set-kube-proxy-configuration.sh
machineTemplate:
infrastructureRef:
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: AWSMachineTemplate
name: my-cluster-control-plane
namespace: default
metadata: {}
replicas: 3
rolloutStrategy:
rollingUpdate:
maxSurge: 1
type: RollingUpdate
version: kubernetes-version
Note: If you use the previous example as-is, update the Kubernetes version number on the final line. For more
information about the supported Kubernetes version, see Supported Kubernetes Versions section in the NKP
Release Notes.
```

1. Now, you can configure the fields below for the log backend. The log
   backend will write audit events to a file in JSON format
   `<https://jsonlines.org/>`. You can configure the log audit backend using the
   kube-apiserver flags shown in the example.

```bash
audit-log-maxage
audit-log-maxbackup
audit-log-maxsize
audit-log-path
Note: For more information, see upstream documentation at https://kubernetes.io/docs/tasks/debug/
debug-cluster/audit/#log-backend.
```

1. After modifying the values appropriately, you can create the cluster by
   running the kubectl create -f

{MY_CLUSTER_NAME}.yaml command.

```bash
kubectl create -f {MY_CLUSTER_NAME}.yaml
```

1. Once the cluster is created, users can get the corresponding kubeconfig for
   the cluster by running the command.

```bash
nkp get kubeconfig -c {MY_CLUSTER_NAME} >> {MY_CLUSTER_NAME}.conf
```

### Viewing the Audit Logs

About this task

Fluent Bit is disabled by default on the management cluster. To view the audit
logs, perform the following task.

Procedure

1. To view the audit logs, run the following command.

```bash
nkp diagnose --kubeconfig={MY_CLUSTER_NAME}.conf
```

A file similar to support-bundle-2022-08-15T02_28_48.tar.gz is created. 2.
Untar the file. For example:

```bash
tar -xzf support-bundle-2022-08-15T02_28_48.tar.gz
```

1. Navigate to the node-diagnostics sub-directory from the extracted file. For
   example:

```bash
cd support-bundle-2022-08-15T02_28_48/node-diagnostics
```

1. To find the audit logs, run the following command.

```bash
$ find . -type f | grep audit.log
./ip-10-0-142-117.us-west-2.compute.internal/data/kube_apiserver_audit.log
./ip-10-0-148-139.us-west-2.compute.internal/data/kube_apiserver_audit.log
./ip-10-0-128-181.us-west-2.compute.internal/data/kube_apiserver_audit.log
```

What to do next

For information on related topics or procedures, see Fluent bit.

## Updating Pod Disruption Budget

About this task

Upgrading a node pool involves draining the existing nodes in the node pool
and replacing them with new nodes. To ensure minimum downtime and maintain
high availability of the critical application workloads during the upgrade
process, we recommend deploying Pod Disruption Budget (Disruptions) for your
critical applications. For more information, see
`<https://kubernetes.io/docs/concepts/workloads/pods/disruptions/>`.

The Pod Disruption Budget will prevent any impact on critical applications as
a result of misconfiguration or failures during the upgrade process.

Before you begin

- Deploy Pod Disruption Budget (PDB). For more information, see
  `<https://kubernetes.io/docs/concepts/>` workloads/pods/disruptions/
- Nutanix Image Builder on page 51 (NIB)

Procedure

1. Deploy Pod Disruption Budget for your critical applications. If your
   application can tolerate only one replica to be unavailable at a time, then
   you can set the Pod disruption budget as shown in the following example. The
   example below is for NVIDIA GPU node pools, but the process is the same for
   all.

> **Note: Repeat this step for each additional node pool** 2. Create the
> pod-disruption-budget-nvidia.yaml file.

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
name: nvidia-critical-app
spec:
maxUnavailable: 1
selector:
matchLabels:
app: nvidia-critical-app
```

1. Apply the YAML file above using the command.

```bash
kubectl create -f pod-disruption-budget-nvidia.yaml
```

1. Prepare OS image for your node pool using the Nutanix Image Builder on page
2.

What to do next

For information on related topics or procedures, see Upgrade Nutanix
Kubernetes Platform on page 1048.

## Cluster and NKP Installation Verification

Check Nutanix Kubernetes Platform (NKP) components to verify the status of
your cluster

This section contains information on how to verify a NKP installation.

### Checking the Cluster Infrastructure and Nodes

About this task

Nutanix Kubernetes Platform (NKP) ships with default diagnosis tools to check
your cluster, such as the describe command. You can use those tools to
validate your installation.

Procedure

1. If you have not done so already, set the environment variable for your
   cluster name, substituting nkp-example with the name of your cluster.

```bash
export CLUSTER_NAME=nkp-example
```

1. Then, run this command to check the health of the cluster infrastructure.

```bash
nkp describe cluster --cluster-name=${CLUSTER_NAME}
```

A healthy cluster returns an output similar to this example.

```bash
NAME READY SEVERITY
REASON SINCE MESSAGE
Cluster/nkp-example True
121m
##ClusterInfrastructure - AWSCluster/nkp-example True
121m
##ControlPlane - KubeadmControlPlane/nkp-example-control-plane True
121m
# ##Machine/nkp-example-control-plane-h52t6 True
121m
# ##Machine/nkp-example-control-plane-knrrh True
121m
# ##Machine/nkp-example-control-plane-zmjjx True
121m
##Workers

##MachineDeployment/nkp-example-md-0 True
121m
##Machine/nkp-example-md-0-88488cb74-2vxjq True
121m
##Machine/nkp-example-md-0-88488cb74-84xsd True
121m
##Machine/nkp-example-md-0-88488cb74-9xmc6 True
121m
##Machine/nkp-example-md-0-88488cb74-mjf6s True
121m
```

1. Use this kubectl command to see if all cluster nodes are ready.

```bash
kubectl get nodes
```

Example output showing all statuses set to Ready.

```bash
NAME STATUS ROLES AGE
VERSION
ip-10-0-112-116.us-west-2.compute.internal Ready <none> 135m
v<kubernetes-version>
ip-10-0-122-142.us-west-2.compute.internal Ready <none> 135m
v<kubernetes-version>
ip-10-0-186-214.us-west-2.compute.internal Ready control-plane,master 133m
v<kubernetes-version>
ip-10-0-231-82.us-west-2.compute.internal Ready control-plane,master 135m
v<kubernetes-version>
ip-10-0-71-114.us-west-2.compute.internal Ready <none> 135m
v<kubernetes-version>
ip-10-0-71-207.us-west-2.compute.internal Ready <none> 135m
v<kubernetes-version>
ip-10-0-85-253.us-west-2.compute.internal Ready control-plane,master 137m
v<kubernetes-version>
```

To verify a successful installation, all of the previous commands should
return as Ready or True.

### Monitor the CAPI Resources

Gather a list of all resources that comprise a cluster and their statuses.

```bash
kubectl get cluster-api
```

The status of clusters, machines, control planes, and infrastructure
components ensures that all resources are provisioned and functioning as
expected. Before proceeding with workload deployment or integration, reviewing
the CAPI resources helps identify configuration issues and confirms that the
cluster is stable.

### Verify all Pods

Ensure to check pod status across all namespaces of the cluster, and that the
system components are operational.

```bash
kubectl get pods --all-namespaces
```

### Troubleshooting

If any pod is not in Running or Completed status, you need to investigate
further.

If something has not been deployed properly or thoroughly, run the nkp
diagnose command. This collects information from pods and infrastructure.

For more information, see Generate a Support Bundle on page 1076.

## GPU for Konvoy

In this version of Nutanix Kubernetes Platform (NKP), the nodes with NVIDIA
GPUs are configured with nvidia- gpu-operator (Overview - NVIDIA Cloud Native
Technologies documentation) and NVIDIA drivers to support the container
runtime.

This page will link you to all the necessary GPU pages.

- Nutanix GPU Passthrough
- Updating Cluster Nodepools

The remainder of GPU information is found in Cluster Management Operations
section of the documentation.
