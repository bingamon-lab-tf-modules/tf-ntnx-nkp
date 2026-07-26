# Basic Installations by Infrastructure

BASIC INSTALLATIONS BY INFRASTRUCTURE

This topic provides basic installation instructions for your infrastructure
using combinations of providers and other variables.

> **Note: For custom installation procedures, see Custom Installation and
> Additional Infrastructure Tools.**

Production cluster configuration allows you to deploy and enable the cluster
management applications and your workload applications that you need for
production operations. For more information, see Cluster Operations Management
on page 284.

For virtualized environments, NKP can provision the virtual machines necessary
to run Kubernetes clusters. If you want to allow NKP to manage your
infrastructure, select your supported infrastructure provider installation
choices below.

## Nutanix Installation Options

## Pre-provisioned Installation Options

- EKS Installation Options on page 168
- vSphere Installation Options on page 189
- Azure Installation Options on page 250
- AKS Installation Options on page 260
- GCP Installation Options on page 272

```yaml
Note: If you want to provision your nodes in a bare metal environment or manually, see Pre-provisioned
Infrastructure on page 761.
```

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

## Nutanix Installation Options (2)

For information on how to install NKP in a Nutanix environment, see Install
Nutanix Kubernetes Platform on Nutanix Infrastructure on page 717.

## Pre-provisioned Installation Options (2)

Pre-provisioned infrastructure is provided for non-air-gapped and air-gapped
environments.

For non-air-gapped or air-gapped environment installation options, see Pre-
provisioned Installation Options on page 72.

For more options on custom YAML configurations, see Pre-provisioned
Infrastructure on page 761.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

For a list of all the NKP supported environment combinations, see Supported
Infrastructure Operating Systems on page 12.

Important Pre-provisioned Topics

- Pre-provisioned includes on-premises, vSphere, AWS, Azure, and GCP
  infrastructures and is described in more detail in Pre-provisioned
  Infrastructure on page 23.
- For more information regarding CSI Disk storage and changing default
  StorageClass, see Default Storage Providers on page 34.
- For Azure environment using Pre-provisioned specifics, see Pre-provisioned:
  Replacing the Driver with the Azure Disk CSI Driver on page 767.

The required specific machine resources are as follows:

- Control Plane machines:
- 15% of free space is available on the root file system.
- Multiple ports are open as described in the NKP Ports and Protocols page.
- firewalld systemd service is disabled. If it exists and is enabled, use the
  commands systemctl stop firewalld and systemctl disable firewalld to disable
  firewalldafter the machine restarts.
- Worker machines:
- 15% of free space is available on the root file system.
- Multiple ports are open as described in the NKP Ports and Protocols page.
- If you plan to use local volume provisioning to provide persistent volumes
  for your workloads, you must mount at least four volumes to the /mnt/disks/
  mount point on each machine. Each volume must have at least 100 GiB of
  capacity.
- Ensure your disk meets the resource requirements for Rook Ceph in Block mode
  for ObjectStorageDaemons as specified in the requirements table.
- firewalld systemd service disabled. If it exists and is enabled, use the
  commands systemctl stop firewalld then systemctl disable firewalld, so that
  firewalld remains disabled after the machine restarts.

```yaml
Note: Swap is disabled. kubelet does not support swapping. Due to variable commands, see the respective
Operating System documentation.
```

### Pre-provisioned Non-Air-gapped Installation

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

#### Pre-provisioned: Defining the Infrastructure

About this task

The component of NKP must know how to access your cluster hosts. Hence, you
must define the cluster hosts and infrastructure using the inventory
resources. For the initial cluster creation, define a control plane and at
least one worker pool.

Set the necessary environment variables as follows:

Procedure

1. Export the following environment variables, ensuring that all the control
   plane and worker nodes are included.

```bash
export CLUSTER_NAME=<my-nutanix-cluster>
export CONTROL_PLANE_1_ADDRESS="<control-plane-address-1>"
export CONTROL_PLANE_2_ADDRESS="<control-plane-address-2>"
export CONTROL_PLANE_3_ADDRESS="<control-plane-address-3>"
export WORKER_1_ADDRESS="<worker-address-1>"
export WORKER_2_ADDRESS="<worker-address-2>"
export WORKER_3_ADDRESS="<worker-address-3>"
export WORKER_4_ADDRESS="<worker-address-4>"
export SSH_USER="<ssh-user>"
export SSH_PRIVATE_KEY_SECRET_NAME="$CLUSTER_NAME-ssh-key"
```

1. Use the following template to define your infrastructure. The environment
   variables that you set in the previous step automatically replaces the
   variable names when the inventory YAML file is created.

```bash
cat <<EOF > preprovisioned_inventory.yaml
---
apiVersion: infrastructure.cluster.konvoy.d2iq.io/v1alpha1
kind: PreprovisionedInventory
metadata:
name: $CLUSTER_NAME-control-plane
namespace: default
labels:
cluster.x-k8s.io/cluster-name: $CLUSTER_NAME
clusterctl.cluster.x-k8s.io/move: ""
spec:
hosts:
# Create as many of these as needed to match your infrastructure
# Note that the command line parameter --control-plane-replicas determines how
many control plane nodes will actually be used.
#
- address: $CONTROL_PLANE_1_ADDRESS
- address: $CONTROL_PLANE_2_ADDRESS
- address: $CONTROL_PLANE_3_ADDRESS
sshConfig:
port: 22
# This is the username used to connect to your infrastructure. This user must be
root or
# have the ability to use sudo without a password
user: $SSH_USER
privateKeyRef:
# This is the name of the secret you created in the previous step. It must
exist in the same
# namespace as this inventory object.
name: $SSH_PRIVATE_KEY_SECRET_NAME
namespace: default
---
apiVersion: infrastructure.cluster.konvoy.d2iq.io/v1alpha1
kind: PreprovisionedInventory
metadata:
name: $CLUSTER_NAME-md-0
namespace: default
labels:
cluster.x-k8s.io/cluster-name: $CLUSTER_NAME
clusterctl.cluster.x-k8s.io/move: ""
spec:
hosts:
- address: $WORKER_1_ADDRESS
- address: $WORKER_2_ADDRESS
- address: $WORKER_3_ADDRESS
- address: $WORKER_4_ADDRESS
sshConfig:
port: 22
user: $SSH_USER
privateKeyRef:
name: $SSH_PRIVATE_KEY_SECRET_NAME
namespace: default
EOF
```

#### Pre-provisioned: Defining the Control Plane Endpoint

In addition, the control plane needs an endpoint that remains available if
some nodes fail.

Figure 4: Control Plane Load Balancer Architecture

In this example, the control plane endpoint host is lb.example.com , and the
control plane endpoint port is 6443. The control plane nodes are
cp1.example.com, cp2.example.com, and cp3.example.com. The port of each API
server is 6443.

Connection Mechanism Selection

A virtual IP is the address that the client uses to connect to the service. A
load balancer is a device that distributes the client connections to the
backend servers. Before you create a new NKP cluster, choose an external load
balancer (LB) or virtual IP.

- External load balancer: Nutanix recommends that an external load balancer be
  the control plane endpoint. To distribute request load among the control
  plane machines, configure the load balancer to send requests to all the
  control plane machines. Configure the load balancer to send requests only to
  control plane machines that are responding to API requests.
- Built-in virtual IP: If an external load balancer is not available, use the
  built-in virtual IP. The virtual IP is not a load balancer; it does not
  distribute request load among the control plane machines. However, if the
  machine receiving requests does not respond to them, the virtual IP
  automatically moves to another machine.

Single-Node Control Plane

> **Caution: Do not use a single-node control plane in a production cluster.**

A control plane with one node can use its single node as the endpoint, so you
will not require an external load balancer
or a built-in virtual IP. At least one control plane node must always be
running. Therefore, to upgrade a cluster with
one control plane node, a spare machine must be available in the control plane
inventory. This machine is used to
provision the new node before the old node is deleted. When the Application
Programming Interface (API) server endpoints
are defined, you can create the cluster using the link in the next step below.

```yaml
Note: Modify control plane audit log settings using the information in the Configure the Control Plane page. See
Configuring the Control Plane.
```

Known Limitations

The control plane endpoint port is also used as the API server port on each
control plane machine. The default port is 6443. Before you create the
cluster, ensure the port is available for use on each control plane machine.

#### Pre-provisioned: Creating the Management Cluster

About this task

After you define the infrastructure and control plane endpoints, proceed with
creating the cluster by following the steps below to create a new pre-
provisioned cluster. This process creates a self-managed cluster for use as
the Management cluster.

Before you begin

Specify a name for your cluster and run the command to deploy it. When
specifying the cluster-name, you must use the same cluster-name as used when
defining your inventory objects (see Pre-provisioned Air-gapped: Configuring
the Environment on page 88).

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if the
name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

By default, the control-plane nodes will be created in three different zones.
However, the default worker Nodes will reside in a single availability zone.
You may create additional node pools in other availability zones with the nkp
create nodepool command.

Procedure

1. Enter a unique name for your cluster that is suitable for your environment.
2. Set the environment variable for the cluster name using the following
   command.

```bash
export CLUSTER_NAME=cluster_name
```

1. Create a Kubernetes Cluster. After you define the infrastructure and
   control plane endpoints, you can proceed to create the cluster by following
   these steps to create a new Pre-provisioned cluster. This process creates a
   self-managed cluster to be used as the Management cluster.

What to do next

Before you create a new NKP cluster below, choose an external load balancer
(LB) or virtual IP and use the corresponding nkp create cluster command.

In a pre-provisioned environment, use the Kubernetes CSI and third party
drivers for local volumes and other storage devices in your data center.

```yaml
Warning: NKP uses local static provisioner as the default storage provider for a pre-provisioned environment.
However, localvolumeprovisioner is not suitable for production use. You can use a Kubernetes CSI
compatible storage that is suitable for production.
```

After disabling localvolumeprovisioner, you can choose from any of the storage
options available for Kubernetes. To make that storage the default storage,
use the commands shown in this section of the Kubernetes documentation:
`<<https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage->`
class/>

For Pre-provisioned environments, you define a set of nodes that already
exist. During the cluster creation process, Nutanix Image Builder on page 51
(NIB) is built into NKP and automatically runs the machine configuration
process (which NIB uses to build images for other providers) against the set
of nodes that you defined. This results in your pre-existing or pre-
provisioned nodes being configured properly.

The following command relies on the pre-provisioned cluster API infrastructure
provider to initialize the Kubernetes control plane and worker nodes on the
hosts defined in the inventory YAML previously created.

The create cluster command below includes the --self-managed flag. A self-
managed cluster refers to one in which the Cluster API (CAPI) resources and
controllers that describe and manage it are running on the same cluster they
are managing.

This command uses the default external load balancer (LB) option (see
alternative Step 1 for virtual IP):

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host <control plane endpoint host> \
--control-plane-endpoint-port <control plane endpoint port, if different than 6443> \
--pre-provisioned-inventory-file preprovisioned_inventory.yaml \
--ssh-private-key-file <path-to-ssh-private-key> \
--self-managed
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

1. ALTERNATIVE Virtual IP - if you don't have an external LB, and want to use
   a VIRTUAL IP provided by

kube-vip, specify these flags example below:

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host 196.168.1.10 \
--virtual-ip-interface eth1
```

1. Use the wait command to monitor the cluster control-plane readiness:

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=30m
```

Output:

```bash
cluster.cluster.x-k8s.io/cluster_name condition met
```

> **Note: Depending on the cluster size, it will take a few minutes to create.**

When the command completes, you will have a running Kubernetes cluster! For
bootstrap and custom YAML cluster creation, see the Additional Infrastructure
Customization section of the documentation for Pre-provisioned: Pre-
provisioned Infrastructure

Use this command to get the Kubernetes kubeconfig for the new cluster and
proceed to installing the NKP Kommander UI:

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
Note: If changing the Calico encapsulation, Nutanix recommends changing it after cluster creation, but before
production. See Calico encapsulation.
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by setting
the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

Audit Logs To modify Control Plane Audit logs settings using the information
contained in the page Configure the Control Plane.

Further Steps For more customized cluster creation, access the Pre-Provisioned
Additional Configurations section for custom flags, and more that specify the
secret as part of the create cluster command. If these are not specified, the
overrides for your nodes will not be applied.

Cluster Verification

If you want to monitor or verify the installation of your clusters, refer to:
Cluster and NKP Installation Verification on page 1039 and Installing NKP on
page 43.

#### Pre-provisioned: Configuring MetalLB

Nutanix recommends that an external load balancer be the control plane
endpoint. To distribute request load among the control plane machines,
configure the load balancer to send requests to all the control plane
machines. Configure the load balancer to send requests only to control plane
machines that are responding to API requests. If you do not have one, you can
use Metal LB to create MetalLB custom resources for your pre-provisioned
infrastructure.

Choose one of the following two protocols you want to use to define service
IPs. If your environment is not currently equipped with a load balancer, use
MetalLB. Otherwise, your load balancer will work, and you can continue the
installation process with Pre-provisioned: Installing Kommander on page 80. To
use MetalLB, create MetalLB custom resources for your pre-provisioned
infrastructure. MetalLB uses one of two protocols for exposing Kubernetes
services:

- Layer 2, with Address Resolution Protocol (ARP)
- Border Gateway Protocol (BGP)

Layer 2 Configuration

Layer 2 mode is the simplest to configure. In many cases, you do not require
any protocol-specific configuration, only IP addresses.

Layer 2 mode does not require the IPs to be bound to the network interfaces of
your worker nodes. It works by responding to ARP requests on your local
network directly to give the machine's MAC address to clients.

> **Warning:**

- MetalLB IP address ranges or Classless Inter-Domain Routing (CIDR) needs to
  be within the node's primary network subnets. For more information, see
  Cluster Pod and Services Subnets on page 706.
- MetalLB IP address ranges or CIDRs and node subnets must not conflict with
  the Kubernetes cluster pod and service subnets.

For example, the following configuration gives MetalLB control over IPs from
192.168.1.240 to 192.168.1.250 and configures Layer 2 mode:

The following values are generic; enter your specific values into the fields
where applicable.

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
name: default
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this is complete, run the kubectl apply -f metallb-conf.yaml command.

Border Gateway Protocol (BGP) Configuration

For a basic configuration featuring one BGP router and one IP address range,
you need the following four pieces of information:

- The router IP address that MetalLB must connect to.
- The router's autonomous systems (AS) number.
- The AS number MetalLB to use.
- An IP address range is expressed as a CIDR prefix.

As an example, if you want to specify the MetalLB range as 192.168.10.0/24 and
AS number as 64500 and connect it to a router at 10.0.0.1 with AS number
64501, your configuration will be as follows.

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
name: default
namespace: metallb-system
spec:
myASN: 64500
peerASN: 64501
peerAddress: 10.0.0.1
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.10.0/24
---
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
name: example
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this is complete, run the kubectl apply -f metallb-conf.yaml command.

#### Pre-provisioned: Installing Kommander

About this task

After installing the component of NKP, continue with the installation of the
Kommander component that enables you to bring up the UI dashboard.

> **Note:**

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

```yaml
Caution: Nutanix support is unable to recover forgotten credentials. Prevent Kommander UI lockouts with the
following best practices.
```

- Backup the kubeconfig file.
- Save your credentials.
- Configure an IDP (identity provider) instead of using a username and
  password credentials.

Before you begin

- Ensure you review all the prerequisites required for the installation.
- Ensure you have a default StorageClass (see Identifying and Modifying Your
  StorageClass on page 980).
- Note the name of the cluster where you want to install Kommander. If you do
  not know the cluster name, use kubectl get nkpclusters -A to search and find
  it.

To create your Kommander installer configuration file, perform the following
steps:

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} >> ${CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

```bash
nkp install kommander --init > kommander.yaml
```

1. Edit the installer file to include configuration overrides for the rook-
   ceph-cluster. NKP's default configuration ships Ceph with PVC based storage
   that requires your CSI povider to support for PVC with type volumeMode:
   Block. As this is not possible with the default local static provisioner,
   you can

install Ceph in host storage mode and choose whether Ceph's object storage
daemon (osd) pods can consume all or just some of the devices on your nodes.
Include one of the following overrides.

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

1. (Optional) Customize your kommander.yaml. Some options include custom
   domains and certificates, HTTP proxy, and external load balancer.
2. Use the customized kommander.yaml to install NKP.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

#### Pre-provisioned: Verifying your Installation

About this task

```yaml
Note: If the Kommander installation fails or you wish to reconfigure applications, you can rerun the install command
to retry the installation.
```

Procedure

Check the installation status:

```bash
kubectl -n kommander wait --for condition=Ready helmreleases --all --timeout 15m
Note: If you prefer using the CLI to not wait for all applications to be available, you can set the flag to --
wait=false.
```

The first wait for each of the helm charts to reach their Ready condition,
eventually resulting in an output.

```bash
helmrelease.helm.toolkit.fluxcd.io/centralized-grafana condition met
helmrelease.helm.toolkit.fluxcd.io/dex condition met
helmrelease.helm.toolkit.fluxcd.io/dex-k8s-authenticator condition met
helmrelease.helm.toolkit.fluxcd.io/fluent-bit condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-logging condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-loki condition met
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

What to do next

If an application fails to deploy, check the status of the HelmRelease using
the following command.

```bash
kubectl -n kommander get helmrelease <HELMRELEASE_NAME>
```

If you find any HelmReleases in a broken release state, such as exhausted or
another rollback/release in progress, trigger a reconciliation of the
HelmRelease using the following commands.

```bash
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": true}]'
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": false}]'
```

#### Pre-provisioned: Logging In To the UI

Procedure

1. By default, log in to the UI in Kommander with the following command:

```bash
nkp open dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

1. Retrieve the URL and credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

1. Do the following:

Use these static credentials only to configure an external identity provider.
For more information, see Identity Providers. Treat them as backup
credentials, not for regular UI access.

a. Rotate the dashboard password:

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

b. Retrieve the new dashboard credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

For more information, see Rotating the NKP Dashboard Password on page 308.

You can perform the following operations on Identity Providers:

- Create an Identity Provider
- Temporarily Disable an Identity Provider
- Create Groups

What to do next

Dashboard UI Functions

After installing the Konvoy component and building a cluster as well as
successfully installing Kommander and logging into the UI, you are now ready
to customize configurations. For more information, Cluster Operations
Management. The majority of the customization such as attaching clusters and
deploying applications takes place in the dashboard or the NKP UI.

#### Pre-provisioned: Creating Managed Clusters Using the NKP CLI

About this task

After initial cluster creation, you have the ability to create additional
clusters from the CLI. In a previous step, the new cluster was created as
Self-managed, which allows it to be a Management cluster or a stand-alone
cluster. Subsequent new clusters are not self-managed as they are likely to be
managed or attached clusters to this Management Cluster.

```yaml
Warning: When creating managed clusters, do not create and move CAPI cluster objects or install the Kommander
component. Those tasks are only done on Management clusters.
```

Your new managed cluster must be part of a workspace under a management
cluster. To make the new managed cluster a part of a workspace, set that
workspace's environment variable.

Procedure

1. If you have an Ultimate license and an existing workspace name, run this
   command to find the name.

> **Note: If you need to create a new Workspace, follow the instructions to
> Create a New Workspace**

```bash
kubectl get workspace -A
```

For other licence tiers, a new workspace will be automatically created. 2.
After you find the workspace name, set the WORKSPACE_NAMESPACE environment
variable.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

If you need to create a new workspace, see Creating a Workspace on page 369.

##### Name Your Cluster

About this task

Each cluster must have an original name.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if the
name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

By default, the control-plane Nodes will be created in 3 different zones.
However, the default worker Nodes will reside in a single Availability Zone.
You may create additional node pools in other Availability Zones with the nkp
create nodepool command.

Perform both steps to name the cluster:

Procedure

1. Give your cluster a unique name suitable for your environment.
2. Set the environment variable.

```bash
export CLUSTER_NAME=<cluster_name>
```

##### Create a Kubernetes Cluster

About this task

After you have defined the infrastructure and control plane endpoints, you can
proceed to create that cluster by following these steps to create a new pre-
provisioned cluster.

This process creates a self-managed cluster that can be used as the management
cluster.

```yaml
Tip: Before you create a new Nutanix Kubernetes Platform (NKP) cluster below, choose an external load balancer
(LB) or virtual IP and use the corresponding NKP create cluster command. For more information, see Pre-
provisioned: Built-in Virtual IP on page 782
```

In a Pre-provisioned environment, use the Kubernetes CSI and third-party
drivers for local volumes and other storage devices in your datacenter.

```yaml
Caution: NKP uses a local static provisioner as the default storage provider for a pre-provisioned environment.
For more information, see Default Storage Providers on page 34. However, localvolumeprovisioner
is not suitable for production use. Use Kubernetes CSI compatible storage that is suitable for production. For more
information, see Types of Volumes.
```

After disabling localvolumeprovisioner, you can choose from any of the storage
options available for Kubernetes. To make that storage the default storage,
use the commands shown in this section of the Kubernetes documentation: Change
the default StorageClass.

For Pre-provisioned environments, you define a set of nodes that already
exist. During the cluster creation process, Nutanix Image Builder (NIB) is
built into NKP and automatically runs the machine configuration process (which
NIB uses to build images for other providers) against the set of nodes that
you defined. This results in your pre-existing or pre-provisioned nodes being
configured properly. For more information, see Nutanix Image Builder on page 51.

The following command relies on the pre-provisioned cluster Application
Programming Interface (API) infrastructure provider to initialize the
Kubernetes control plane and worker nodes on the hosts defined in the
inventory YAML previously created. For more information, see Pre-provisioned:
Defining the Infrastructure on page 74.

Procedure

1. This command uses the default external load balancer (LB) option.

```bash
nkp create cluster preprovisioned
--cluster-name ${CLUSTER_NAME} \
--namespace ${WORKSPACE_NAMESPACE} \
--control-plane-endpoint-host <control plane endpoint host> \
--control-plane-endpoint-port <control plane endpoint port, if different than 6443>
\
--pre-provisioned-inventory-file preprovisioned_inventory.yaml \
--ssh-private-key-file <path-to-ssh-private-key>
```

1. Use the wait command to monitor the cluster control-plane readiness.

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=30m
```

> **Note: NOTE: Depending on the cluster size, it will take a few minutes to
> create.**

Output:

```bash
cluster.cluster.x-k8s.io/cluster_name condition met
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

##### Manually Attach an NKP CLI Cluster to the Management Cluster

About this task

```yaml
Warning: These steps are only applicable if you do not set a WORKSPACE_NAMESPACE when creating a cluster.
If you already set a WORKSPACE_NAMESPACE, then you do not need to perform these steps since the cluster is
already attached to the workspace.
```

When you create a Managed Cluster with the NKP CLI, it attaches automatically
to the Management Cluster after a few moments.

However, if you do not set a workspace, the attached cluster will be created
in the default workspace. To ensure that the attached cluster is created in
your desired workspace namespace, follow these instructions:

Procedure

1. Confirm you have your MANAGED_CLUSTER_NAME variable set with the following
   command.

```bash
echo ${MANAGED_CLUSTER_NAME}
```

1. Retrieve your kubeconfig from the cluster you have created without setting
   a workspace.

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} >
${MANAGED_CLUSTER_NAME}.conf
```

1. Note: This is only necessary if you never set the workspace of your cluster
   upon creation.

You can now either attach it in the UI, link to attaching it to the workspace
through the UI that was earlier, or attach your cluster to the workspace you
want in the CLI. 4. Retrieve the workspace where you want to attach the
cluster.

```bash
kubectl get workspaces -A
```

1. Set the WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace-namespace>
```

1. You need to create a secret in the desired workspace before attaching the
   cluster to that workspace. Retrieve the kubeconfig secret value of your
   cluster.

```bash
kubectl -n default get secret ${MANAGED_CLUSTER_NAME}-kubeconfig -o go-
template='{{.data.value}}{{ "\n"}}'
```

1. This will return a lengthy value. Copy this entire string for a secret
   using the template below as a reference. Create a new attached-cluster-
   kubeconfig.yaml file.

```yaml
apiVersion: v1
kind: Secret
metadata:
name: <your-managed-cluster-name>-kubeconfig
labels:
cluster.x-k8s.io/cluster-name: <your-managed-cluster-name>
type: cluster.x-k8s.io/secret
data:
value: <value-you-copied-from-secret-above>
```

1. Create this secret in the desired workspace.

```bash
kubectl apply -f attached-cluster-kubeconfig.yaml --namespace
${WORKSPACE_NAMESPACE}
```

1. Create this nkpcluster object to attach the cluster to the workspace.

```bash
cat << EOF | kubectl apply -f -
apiVersion: clusters.nkp.nutanix.com/v1alpha1
kind: NKPCluster
metadata:
name: ${MANAGED_CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
capiClusterRef:
name: ${MANAGED_CLUSTER_NAME}
namespace: default
kommanderCluster:
spec:
kubeconfigRef:
name: ${MANAGED_CLUSTER_NAME}-kubeconfig
clusterRef:
capiCluster:
name: ${MANAGED_CLUSTER_NAME}
EOF
```

1. You can now view this cluster in your Workspace in the UI, and you can
   confirm its status by running the command below. It might take a few minutes
   to reach "Joined" status.

```bash
kubectl get nkpclusters -A
```

If you have several Pro Clusters and want to turn one of them into a Managed
Cluster to be centrally administrated by a Management Cluster, see Platform
Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate Managed Cluster
on page 519.

### Pre-provisioned Air-gapped Installation

Installation instructions for installing NKP in a pre-provisioned air-gapped
environment.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

```yaml
Note: For air-gapped, ensure you have downloaded nkp-air-gapped-bundle_nkp-
version_linux_amd64.tar.gz, so you can extract the tarball to a local registry.
```

#### Pre-provisioned Air-gapped: Configuring the Environment

In order to create a cluster in a Pre-provisioned Air-gapped environment, you
must first prepare the environment.

The instructions below outline how to fulfill the requirements for using pre-
provisioned infrastructure in an air-
gapped environment. In order to create a cluster, you must first set up pre-
provisioned air-gapped need to be placed on
the environment with necessary artifacts. All artifacts for Pre-provisioned
Air-gapped need to get onto the bastion
host. Artifacts needed by nodes must be unpacked and distributed on the
bastion before other provisioning will work in
the absence of an internet connection.

There is an air-gapped bundle available to download NKP. In the previous NKP
releases, the distro package bundles were included in the downloaded air-
gapped bundle. Currently, that air-gapped bundle contains the following
artifact, with the exception of the distro packages:

- Containerd tar file

1. Set the Artifacts directory.

The artifacts directory contains the packages and artifacts required to
configure the pre-provisioned host. 2. Downloading NKP on page 16 nkp-air-
gapped-bundle_nkp-version_linux_amd64.tar.gz , and extract the tar file to a
local directory:

```bash
tar -xzvf nkp-air-gapped-bundle_nkp-version_linux_amd64.tar.gz -C
${ARTIFACTS_DIRECTORY}
```

1. You will need to fetch the distro packages as well as other artifacts. By
   fetching the distro packages from distro repositories, you get the latest
   security fixes available at machine image build time. 4. (Required for air-
   gapped environment) Create a package bundle.

NKP requires Operating System packages to be available in the base image.
These packages are available in the package repositories accessible over the
internet. As air-gapped environments are restricted from accessing these
repositories, you must first create a package bundle where the repositories
can be accessed. Then, transfer this bundle to an air-gapped environment to
build the OS image in an air-gapped environment.

Example command:

Setup Process

1. The bootstrap image must be extracted and loaded onto the bastion host. 2.
   Artifacts must be copied onto cluster hosts for nodes to access. 3. If using
   a graphics processing unit (GPU), those artifacts must be positioned
   locally. 4. Registry seeded with images locally.

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

| tar -xzvf nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ---------------------------------- | ----------- | ------------------------ |

| export ARTIFACTS DIRECTORY=nkp- \_ | nkp-version | /image-artifacts/ |
| ---------------------------------- | ----------- | ----------------- |

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

- nkp create package-bundle ${; OS TYPE; } --artifacts-directory ${;
  ARTIFACTS DIRECTORY; }

| --- | --- | --- | --- | --- |

Load the Bootstrap Image

1. Assuming you have downloaded nkp-air-gapped-bundle_nkp-
   version_linux_amd64.tar.gz from the

Downloading NKP on page 16 mentioned above and extracted the tar file, you
will load the bootstrap. 2. Load the bootstrap image on your bastion machine:

Copy Air-gapped Artifacts onto Cluster Hosts

Using the Nutanix Image Builder on page 51, you can copy the required
artifacts onto your cluster hosts.

1. Assuming you have downloaded nkp-air-gapped-bundle_nkp-
   version_linux_amd64.tar.gz, extract the tar file to a local directory.

```yaml
Note: For more information about the supported Operating System, see Supported Infrastructure Operating
Systems on page 12. For more information about the supported Kubernetes version, see Supported Kubernetes
Versions section in the NKP Release Notes.
```

1. Export the following environment variables, ensuring that all control plane
   and worker nodes are included:

```bash
export CONTROL_PLANE_1_ADDRESS="<control-plane-address-1>"
export CONTROL_PLANE_2_ADDRESS="<control-plane-address-2>"
export CONTROL_PLANE_3_ADDRESS="<control-plane-address-3>"
export WORKER_1_ADDRESS="<worker-address-1>"
export WORKER_2_ADDRESS="<worker-address-2>"
export WORKER_3_ADDRESS="<worker-address-3>"
export WORKER_4_ADDRESS="<worker-address-4>"
export SSH_USER="<ssh-user>"
export SSH_PRIVATE_KEY_FILE="<private key file>"
```

SSH_PRIVATE_KEY_FILE must be either the name of the SSH private key file in
your working directory or an absolute path to the file in your user's home
directory. 3. (Optional) Create a FIPS-compliant image:

```bash
export FIPS_ENABLED=true
```

The Nutanix Image Builder creates a FIPS-compliant OS image. For more
information, see Supported Infrastructure Operating Systems. 4. (Optional)
Upload NVIDIA GPU drivers:

Download the NVIDIA runfile for your NVIDIA driver version from the NVIDIA
download site.

Replace Path to NVIDIA driver runfile with the path to the NVIDIA driver
runfile.

The Nutanix Image Builder uploads the NVIDIA driver runfile to the target host
for GPU workload support. 5. (Optional) Specify a provider hint:

Replace aws|azure|gcp|vsphere|nutanix with the provider name when you install
provider specific utilities.

This helps the image builder install the appropriate provider specific
utilities on the host. 6. Upload the artifacts onto cluster hosts with the
following command:

```bash
./nkp upload image-artifacts \
--ssh-host "${CONTROL_PLANE_1_ADDRESS},${CONTROL_PLANE_2_ADDRESS}" \
--ssh-username "${SSH_USER}" \
${SSH_PRIVATE_KEY_FILE:+--ssh-private-key-file="$SSH_PRIVATE_KEY_FILE"} \
${SSH_PASSWORD:+--ssh-password="$SSH_PASSWORD"} \
${SSH_PORT:+--ssh-port="$SSH_PORT"} \
--artifacts-directory "${ARTIFACTS_DIRECTORY}" \
```

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

| docker load -i konvoy-bootstrap-image- | nkp-version | .tar |
| -------------------------------------- | ----------- | ---- |

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

| export NVIDIA RUNFILE= \_ | Path to NVIDIA driver runfile | Col3 |
| ------------------------- | ----------------------------- | ---- |

| export PROVIDER= | aws | azure | gcp | vsphere | nutanix | Col3 |
| ---------------- | --- | ----- | --- | ------- | ------- | ---- |

```bash
${NVIDIA_RUNFILE:+--nvidia-runfile="$NVIDIA_RUNFILE"} \
${PROVIDER:+--provider="$PROVIDER"} \
${FIPS_ENABLED:+--fips}
```

#### Pre-provisioned Air-gapped: Loading the Registry

About this task

The complete Nutanix Kubernetes Platform (NKP) air-gapped bundle is needed for
an air-gapped environment but can also be used in a non-air-gapped
environment. The bundle contains all the NKP components needed for an air-
gapped environment installation and also for using a local registry in a non-
air-gapped environment.

> **Warning: If you do not already have a local registry set up, see
> Registry Mirror Tools on page 1028.**

If you are operating in an air-gapped environment, a local container registry
containing all the necessary installation images, including the Kommander
images, is required. This registry must be accessible from both the bastion
machine and either the Amazon Web Services (AWS) EC2 instances (if deploying
to AWS) or other machines that will be created for the Kubernetes cluster.

Procedure

1. If not already done in prerequisites, download the air-gapped bundle nkp-
   air-gapped-bundle_nkp-

version_linux_amd64.tar.gz , and extract the tar file to a local directory. 2.
The directory structure after extraction can be accessed in subsequent steps
using commands to access files from different directories. For example, for
the bootstrap cluster, change your directory to the nkp-version directory,
similar to the example below, depending on your current location 3. Set an
environment variable with your registry address and any other needed variables
using this command.

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
export REGISTRY_CA=<path to the cacert file on the bastion>
```

1. Execute the following command to load the air-gapped image bundle into your
   private registry using any of the relevant flags to apply the variables
   above.

```bash
nkp push bundle --bundle ./container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
Note: It might take some time to push all the images to your image registry, depending on the performance of the
network between the machine you are running the script on and the registry.
```

##### Kommander Load Images

Procedure

If you are operating in an air-gapped environment, a local container registry
containing all the necessary installation images, including the Kommander
images is required. For instructions on how to push the necessary images to
this registry, see the steps below.

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

| tar -xzvf nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ---------------------------------- | ----------- | ------------------------ |

| cd nkp- | nkp-version | Col3 |
| ------- | ----------- | ---- |

##### Load Images to your Private Registry - Kommander

Procedure

Load the Kommander component images to your private registry using the command.

For the air-gapped kommander image bundle, run the command below. Run the
following command to load the image bundle.

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-nkp-version.tar --
to-registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
```

#### Pre-provisioned Air-gapped: Defining the Infrastructure

About this task

The Konvoy component of Nutanix Kubernetes Platform (NKP) needs to know how to
access your cluster hosts so you must define the cluster hosts and
infrastructure. This is done using inventory resources. For initial cluster
creation, you must define a control-plane and at least one worker pool.

This procedure sets the necessary environment variables.

Procedure

1. Export the following environment variables, ensuring that all control plane
   and worker nodes are included:

```bash
export CONTROL_PLANE_1_ADDRESS="<control-plane-address-1>"
export CONTROL_PLANE_2_ADDRESS="<control-plane-address-2>"
export CONTROL_PLANE_3_ADDRESS="<control-plane-address-3>"
export WORKER_1_ADDRESS="<worker-address-1>"
export WORKER_2_ADDRESS="<worker-address-2>"
export WORKER_3_ADDRESS="<worker-address-3>"
export WORKER_4_ADDRESS="<worker-address-4>"
export SSH_USER="<ssh-user>"
export SSH_PRIVATE_KEY_SECRET_NAME="$CLUSTER_NAME-ssh-key"
Note: For more information about creating a secret, see Pre-provisioned: Creating Secrets and
Overrides on page 772
```

1. Use the following template to help you define your infrastructure. The
   environment variables that you set in the previous step automatically
   replace the variable names when the inventory YAML Ain't Markup Language
   (YAML) file is created.

```bash
cat <<EOF > preprovisioned_inventory.yaml
---
apiVersion: infrastructure.cluster.konvoy.d2iq.io/v1alpha1
kind: PreprovisionedInventory
metadata:
name: $CLUSTER_NAME-control-plane
namespace: default
labels:
cluster.x-k8s.io/cluster-name: $CLUSTER_NAME
clusterctl.cluster.x-k8s.io/move: ""
spec:
hosts:
# Create as many of these as needed to match your infrastructure (2)
# Note that the command line parameter --control-plane-replicas determines how (2)
many control plane nodes will actually be used.
#
- address: $CONTROL_PLANE_1_ADDRESS
- address: $CONTROL_PLANE_2_ADDRESS
- address: $CONTROL_PLANE_3_ADDRESS
sshConfig:
port: 22
# This is the username used to connect to your infrastructure. This user must be (2)
root or
# have the ability to use sudo without a password (2)
user: $SSH_USER
privateKeyRef:
# This is the name of the secret you created in the previous step. It must (2)
exist in the same
# namespace as this inventory object. (2)
name: $SSH_PRIVATE_KEY_SECRET_NAME
namespace: default
---
apiVersion: infrastructure.cluster.konvoy.d2iq.io/v1alpha1
kind: PreprovisionedInventory
metadata:
name: $CLUSTER_NAME-md-0
namespace: default
labels:
cluster.x-k8s.io/cluster-name: $CLUSTER_NAME
clusterctl.cluster.x-k8s.io/move: ""
spec:
hosts:
- address: $WORKER_1_ADDRESS
- address: $WORKER_2_ADDRESS
- address: $WORKER_3_ADDRESS
- address: $WORKER_4_ADDRESS
sshConfig:
port: 22
user: $SSH_USER
privateKeyRef:
name: $SSH_PRIVATE_KEY_SECRET_NAME
namespace: default
EOF
```

#### Pre-provisioned Air-gapped: Defining the Control Plane Endpoint

Define the control plane endpoint for your cluster and the connection
mechanism. A control plane needs to have three, five, or seven nodes so it can
remain available if one or more nodes fail. A control plane with one node is
not for production use.

In addition, the control plane needs an endpoint that remains available if
some nodes fail.

```bash
-------- cp1.example.com:6443
|
lb.example.com:6443 ---------- cp2.example.com:6443
|
-------- cp3.example.com:6443
```

In this example, the control plane endpoint host is lb.example.com, and the
control plane endpoint port is 6443. The control plane nodes are
cp1.example.com, cp2.example.com, and cp3.example.com. The port of each API
server is 6443.

Select your Connection Mechanism

A virtual IP is the address that the client uses to connect to the service. A
load balancer is a device that distributes the client connections to the
backend servers. Before you create a new Nutanix Kubernetes Platform (NKP)
cluster, choose an external load balancer (LB) or virtual IP.

- External load balancer

It is recommended that an external load balancer be the control plane
endpoint. To distribute request load among the control plane machines,
configure the load balancer to send requests to all the control plane
machines. Configure the load balancer to send requests only to control plane
machines that are responding to Application Programming Interface (API)
requests.

- Built-in virtual IP

If an external load balancer is not available, use the built-in virtual IP.
The virtual IP is not a load balancer; it does not distribute request load
among the control plane machines. However, if the machine receiving requests
does not respond to them, the virtual IP automatically moves to another
machine.

Single-Node Control Plane

> **Caution: Do not use a single-node control plane in a production cluster.**

A control plane with one node can use its single node as the endpoint, so you
will not require an external load balancer
or a built-in virtual IP. At least one control plane node must always be
running. Therefore, to upgrade a cluster with
one control plane node, a spare machine must be available in the control plane
inventory. This machine is used to
provision the new node before the old node is deleted. When the API server
endpoints are defined, you can create the
cluster using the link in the Next Step below.

```yaml
Note: Modify Control Plane Audit logs settings using the information contained in the page Configure the Control
Plane.
```

Known Limitations

The control plane endpoint port is also used as the API server port on each
control plane machine. The default port is 6443. Before you create the
cluster, ensure the port is available for use on each control plane machine.

#### Pre-provisioned Air-gapped: Creating a Management Cluster

About this task

This process creates a self-managed cluster that can be used as the management
cluster.

Before you begin

First, you must name your cluster. Then, you run the command to deploy it.
When specifying the cluster-name, you must use the same cluster-name as used
when defining your inventory objects.

If your cluster is air-gapped or you have a local registry, you must provide
additional arguments when creating the cluster. These tell the cluster where
to locate the local registry to use by defining the URL.

```bash
export REGISTRY_URL=<https/http>://<registry-address>:<registry-port>
export REGISTRY_CA=<path to the CA on the bastion>
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
```

- REGISTRY_URL: the address of an existing registry accessible in the VPC that
  the new cluster nodes will be configured to use a mirror registry when
  pulling images.
- REGISTRY_CA: (optional) the path on the bastion machine to the registry CA.
  NKP will configure the cluster nodes to trust this CA. This value is only
  needed if the registry is using a self-signed certificate and the AMIs are
  not already configured to trust this CA.
- REGISTRY_USERNAME: optional, set to a user that has pull access to this
  registry.
- REGISTRY_PASSWORD: optional if the username is not set.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if the
name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

By default, the control-plane Nodes will be created in three different zones.
However, the default worker nodes will reside in a single availability zone.
You may create additional node pools in other availability zones with the nkp
create nodepool command.

Follow these steps:

Procedure

1. Give your cluster a unique name suitable for your environment.
2. Set the environment variable.

```yaml
Warning: Before you create a new NKP cluster below, choose an external load balancer (LB) or virtual IP and use
the corresponding nkp create cluster command.
```

What to do next

Other customizations are available but require different flags during nkp
create cluster command also. Refer to Pre-provisioned Cluster Creation
Customization Choices for more cluster customizations.

In a pre-provisioned environment, use the Kubernetes CSI and third-party
drivers for local volumes and other storage devices in your datacenter.

```yaml
Note: (Optional) Use a registry mirror. Configure your cluster to use an existing local registry as a mirror when
attempting to pull images previously pushed to your registry when defining your infrastructure. Instructions in the
expandable Custom Installation section. For registry mirror information, see topics Using a Registry Mirror and
Registry Mirror Tools.
```

Create an Air-gapped Kubernetes Cluster

After you have defined the infrastructure and control plane endpoints, you can
proceed to create the cluster by following these steps to create a new pre-
provisioned cluster.

```yaml
Warning: NKP uses a local static provisioner as the default storage provider for a pre-provisioned environment.
However, localvolumeprovisioner is not suitable for production use. Use Kubernetes CSI compatible
storage that is suitable for production.
```

After disabling localvolumeprovisioner, you can choose from any of the storage
options available for Kubernetes. To make that storage the default storage,
use the commands shown in this section of the Kubernetes documentation:
Changing the Default Storage Class.

For Pre-provisioned environments, you define a set of nodes that already
exist. During the cluster creation process, Nutanix Image Builder(NIB) is
built into DKP and automatically runs the machine configuration process (which
NIB uses to build images for other providers) against the set of nodes that
you defined. This results in your pre-existing or pre-provisioned nodes being
configured properly.

The following command relies on the pre-provisioned cluster API infrastructure
provider to initialize the Kubernetes control plane and worker nodes on the
hosts defined in the inventory.

The create cluster command below includes the --self-managed flag. A self-
managed cluster refers to one in which the CAPI resources and controllers that
describe and manage it are running on the same cluster they are managing.

| export CLUSTER NAME= \_ | cluster name \_ | Col3 |
| ----------------------- | --------------- | ---- |

This command uses the default external load balancer (LB) option (see
alternative Step 1 for virtual IP):

```bash
nkp create cluster preprovisioned --cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host <control plane endpoint host> \
--control-plane-endpoint-port <control plane endpoint port, if different th an
6443> \
--pre-provisioned-inventory-file preprovisioned_inventory.yaml \
--ssh-private-key-file <path-to-ssh-private-key> \
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-cacert=${REGISTRY_CA} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD} \
--self-managed
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

1. ALTERNATIVE Virtual IP - if you don't have an external LB and want to use a
   VIRTUAL IP provided by

kube-vip, specify these flags example below:

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host 196.168.1.10 \
--virtual-ip-interface eth1
```

1. Use the wait command to monitor the cluster control-plane readiness:

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=30m
```

Output:

```bash
cluster.cluster.x-k8s.io/cluster_name condition met
```

> **Note: Depending on the cluster size, it will take a few minutes to create.**

When the command is complete, you will have a running Kubernetes cluster! For
bootstrap and custom YAML cluster creation, refer to the Additional
Infrastructure Customization section of the documentation for Pre-
provisioned: Pre-provisioned Infrastructure.

Use this command to get the Kubernetes kubeconfig for the new cluster and
proceed to install the NKP Kommander UI:

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
Note: If changing the Calico encapsulation, Nutanix recommends doing so after cluster creation but before
production.
```

Audit Logs To modify Control Plane Audit logs settings using the information
contained in the page Configure the Control Plane.

Further Steps For more customized cluster creation, access the Pre-Provisioned
Additional Configurations section, for custom flags, and more that specify the
secret as part of the create cluster command. If these are not specified, the
overrides for your nodes will not be applied.

Cluster Verification If you want to monitor or verify the installation of your
clusters, refer to: Cluster and NKP Installation Verification on page 1039 and
Installing NKP on page 43.

#### Pre-provisioned Air-gapped: Configuring MetalLB

Create MetalLB configuration for your Pre-provisioned infrastructure.

It is recommended that an external load balancer (LB) be the control plane
endpoint. To distribute request load among the control plane machines,
configure the load balancer to send requests to all the control plane
machines. Configure the load balancer to send requests only to control plane
machines that are responding to API requests. If you do not have one, you can
use Metal LB to create MetalLB custom resources for your Pre-provisioned
infrastructure.

Choose one of the following two protocols you want to use to announce service
IPs. If your environment is not currently equipped with a load balancer, you
can use MetalLB. Otherwise, your own load balancer will work and you can
continue the installation process with Pre-provisioned Air-gapped: Installing
Kommander on page 97.

To use MetalLB, create MetalLB custom resources for your Pre-provisioned
infrastructure. MetalLB uses one of two protocols for exposing Kubernetes
services:

- Layer 2, with Address Resolution Protocol (ARP)
- Border Gateway Protocol (BGP)

Select one of the following procedures to create your MetalLB manifest for
further editing.

Layer 2 Configuration

Layer 2 mode is the simplest to configure: in many cases, you don't need any
protocol-specific configuration, only IP addresses.

Layer 2 mode does not require the IPs to be bound to the network interfaces of
your worker nodes. It works by responding to ARP requests on your local
network directly, to give the machine's MAC address to clients.

For example, the following configuration gives MetalLB control over IPs from
192.168.1.240 to 192.168.1.250, and configures Layer 2 mode:

The following values are generic, enter your specific values into the fields
where applicable.

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
name: default
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

BGP Configuration

For a basic configuration featuring one BGP router and one IP address range,
you need 4 pieces of information:

- The router IP address that MetalLB needs to connect to.
- The router's autonomous systems (AS) number.
- The AS number MetalLB to be used.
- An IP address range expressed as a CIDR prefix.

As an example, if you want to give MetalLB the range 192.168.10.0/24 and AS
number 64500, and connect it to a router at 10.0.0.1 with AS number 64501,
your configuration will look like:

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
name: default
namespace: metallb-system
spec:
myASN: 64500
peerASN: 64501
peerAddress: 10.0.0.1
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.10.0/24
---
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
name: example
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

#### Pre-provisioned Air-gapped: Installing Kommander

About this task

Once you have installed the Konvoy component of NKP, you will continue with
the installation of the Kommander component that will bring up the UI
dashboard.

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

```yaml
Caution: Nutanix support is unable to recover forgotten credentials. Prevent Kommander UI lockouts with the
following best practices.
```

- Backup the kubeconfig file.
- Save your credentials.
- Configure an IDP (identity provider) instead of using a username and
  password credentials.

Prerequisites:

- Ensure you have reviewed all Prerequisites for Installation.
- Ensure you have a default storage class. For more information, see Default
  StorageClass on page 980.
- Ensure you have loaded all the necessary images for your configuration. See:
  Load the Images into Your Registry: Air-gapped Environments.
- Note the name of the cluster where you want to install Kommander. If you do
  not know the cluster name, use kubectl get nkpclusters -A to display and
  find it.

Create your Kommander Installation Configuration File

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} >> ${CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

```bash
nkp install kommander --init --airgapped > kommander.yaml
```

1. Edit the installer file to include configuration overrides for the rook-
   ceph-cluster. NKP's default configuration
   ships Ceph with PersistentVolumeClaim (PVC) based storage, which requires
   your
   CSI provider to support PVC with type
   volumeMode: Block. As this is not possible with the default local static
   provisioner, you can install Ceph in host
   storage mode. You can choose whether Ceph's object storage daemon (osd) pods
   can consume all or just some of the devices
   on your nodes. Include one of the following Overrides.

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

1. (Optional) Customize your kommander.yaml. Some options include custom
   domains and certificates, HTTP proxy, and external load balancer.

##### Installing Kommander in an Air-gapped Environment

Procedure

Use the customized kommander.yaml to install NKP.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf \
--kommander-applications-repository ./application-repositories/kommander-applications-
v2.8.1.tar.gz
```

#### Pre-provisioned Air-gapped: Verifying your Installation and Logging In To

the UI

About this task

After you build the Konvoy cluster and you install Kommander, verify your
installation. It waits for all applications to be ready by default.

```yaml
Note: If the Kommander installation fails or you wish to reconfigure applications, you can rerun the install command
to retry the installation.
```

Procedure

Check the installation status:

```bash
kubectl -n kommander wait --for condition=Ready helmreleases --all --timeout 15m
Note: If you prefer the command-line interface (CLI) to not wait for all applications to become ready, you can set the
--wait=false flag.
```

The first wait for each of the helm charts to reach their Ready condition,
eventually resulting in an output resembling below:

```bash
helmrelease.helm.toolkit.fluxcd.io/centralized-grafana condition met
helmrelease.helm.toolkit.fluxcd.io/dex condition met
helmrelease.helm.toolkit.fluxcd.io/dex-k8s-authenticator condition met
helmrelease.helm.toolkit.fluxcd.io/fluent-bit condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-logging condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-loki condition met
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

##### Failed HelmReleases

Procedure

If an application fails to deploy, check the status of a HelmRelease using the
command kubectl -n kommander get helmrelease `<HELMRELEASE_NAME>`

If you find any HelmReleases in a "broken" release state, such as "exhausted"
or "another rollback/release in progress", trigger a reconciliation of the
HelmRelease using the commands.

```bash
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": true}]'
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": false}]'
```

###### Logging In To the UI

Procedure

1. By default, log in to the UI in Kommander with the following command:

```bash
nkp open dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

1. Retrieve your credentials:

```bash
kubectl -n kommander get secret dkp-credentials -o go-template='Username:
{{.data.username|base64decode}}{{ "\n"}}Password: {{.data.password|base64decode}}
{{ "\n"}}'
```

1. Retrieve the dashboard URL:

```bash
kubectl -n kommander get svc kommander-traefik -o go-template='https://{{with
index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}{{end}}/dkp/kommander/
dashboard{{ "\n"}}'
```

Only use these static credentials to access the UI for configuring an external
identity provider. Treat them as backup credentials rather than use them for
normal access.

a. Rotate the dashboard password:

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

b. Retrieve the new dashboard credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

For more information, see Rotating the NKP Dashboard Password on page 308.

You can perform the following operations on identity providers:

- Create an identity provider
- Temporarily disable an identity provider
- Create groups

What to do next

Dashboard UI Functions

After installing the Konvoy component and building a cluster as well as
successfully installing Kommander and logging into the UI, you are now ready
to customize configurations. For more information, Cluster Operations
Management. The majority of the customization such as attaching clusters and
deploying applications takes place in the dashboard or the NKP UI.

#### Pre-provisioned Air-gapped: Creating Managed Clusters Using the NKP CLI

About this task

After initial cluster creation, you have the ability to create additional
clusters from the CLI. In a previous step, the new cluster was created as
Self-managed which allows it to be a Management cluster or a stand alone
cluster. Subsequent new clusters are not self-managed as they will likely be
Managed or Attached clusters to this Management Cluster.

```yaml
Warning: When creating managed clusters, do not create and move CAPI cluster objects or install the Kommander
component. Those tasks are only done on Management clusters.
```

Your new managed cluster must be part of a workspace under a management
cluster. To make the new managed cluster a part of a workspace, set that
workspace's environment variable.

Procedure

1. If you have an existing Workspace name, find the name using the command.

```bash
kubectl get workspace -A
```

1. When you have the Workspace name, set the WORKSPACE_NAMESPACE environment
   variable using the command.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

If you need to create a new workspace, see Creating a Workspace on page 369.

##### Name Your Cluster (2)

About this task

Each cluster must have an original name.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if the
name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

By default, the control-plane Nodes will be created in 3 different zones.
However, the default worker Nodes will reside in a single Availability Zone.
You may create additional node pools in other Availability Zones with the nkp
create nodepool command.

Perform both steps to name the cluster:

Perform both steps to name the cluster:

Procedure

1. Give your cluster a unique name suitable for your environment.
2. Set the environment variable using the command.

```bash
export CLUSTER_NAME=<cluster_name>
```

##### Create a Kubernetes Cluster (2)

About this task

After you have defined the infrastructure and control plane endpoints, you can
proceed to creating the cluster by following these steps to create a new pre-
provisioned cluster.

This process creates a self-managed cluster that can be used as the Management
cluster.

```yaml
Tip: Before you create a new NKP cluster below, choose an external load balancer (LB) or Pre-provisioned: Built-
in Virtual IP on page 782 and use the corresponding nkp create cluster command.
```

In a Pre-provisioned environment, use the Kubernetes CSI and third-party
drivers for local volumes and other storage devices in your data center.

```yaml
Warning: NKP uses a local static provisioner as the default storage provider for a pre-provisioned environment.
However, localvolumeprovisioner is not suitable for production use. Use Kubernetes CSI-compatible storage
that is suitable for production. For more information, see https://kubernetes.io/docs/concepts/storage/
volumes/#volume-types.
```

After disabling localvolumeprovisioner, you can choose from any of the storage
options available for Kubernetes. To make that storage the default storage,
use the commands shown in the Change the default StorageClass section of the
Kubernetes documentation. For more information, see
`<https://kubernetes.io/docs/tasks/>` administer-cluster/change-default-storage-
class/

For Pre-provisioned environments, you define a set of nodes that already
exist. During the cluster creation process, Nutanix Image Builder (NIB) is
built into NKP and automatically runs the machine configuration process (which
NIB uses to build images for other providers) against the set of nodes that
you defined. This results in your pre-existing or pre-provisioned nodes being
configured properly.

The following command relies on the pre-provisioned cluster API infrastructure
provider to initialize the Kubernetes control plane and worker nodes on the
hosts defined in the inventory YAML previously created.

Procedure

1. This command uses the default external load balancer (LB) option.

```bash
nkp create cluster preprovisioned --cluster-name ${CLUSTER_NAME}
--control-plane-endpoint-host <control plane endpoint host>
--control-plane-endpoint-port <control plane endpoint port, if different than 6443>
--pre-provisioned-inventory-file preprovisioned_inventory.yaml
--ssh-private-key-file <path-to-ssh-private-key>
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-cacert=${REGISTRY_CA} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD}
```

1. Use the wait command to monitor the cluster control-plane readiness.

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=30m
```

> **Note: Depending on the cluster size, it will take a few minutes to create.**

Output:

```bash
cluster.cluster.x-k8s.io/cluster_name condition met
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

##### Manually Attach an NKP CLI Cluster to the Management Cluster (2)

About this task

```yaml
Warning: These steps are only applicable if you do not set a WORKSPACE_NAMESPACE when creating a cluster.
If you already set a WORKSPACE_NAMESPACE, then you do not need to perform these steps since the cluster is
already attached to the workspace.
```

When you create a Managed Cluster with the NKP CLI, it attaches automatically
to the Management Cluster after a few moments.

However, if you do not set a workspace, the attached cluster will be created
in the default workspace. To ensure that the attached cluster is created in
your desired workspace namespace, follow these instructions:

Procedure

1. Confirm you have your MANAGED_CLUSTER_NAME variable set using the command.

```bash
echo ${MANAGED_CLUSTER_NAME}
```

1. Retrieve your kubeconfig from the cluster you have created without setting
   a workspace using the command .

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} >
${MANAGED_CLUSTER_NAME}.conf
```

You can now either attach it in the UI, link to attaching it to the workspace
through earlier UI, or attach your cluster to the workspace you want in the
CLI.

> **Note: This is only necessary if you never set the workspace of your
> cluster upon creation.** 3. Retrieve the workspace where you want to
> attach the cluster using the command.

```bash
kubectl get workspaces -A
```

1. Set the WORKSPACE_NAMESPACE environment variable using the command.

```bash
export WORKSPACE_NAMESPACE=<workspace-namespace>
```

1. You need to create a secret in the desired workspace before attaching the
   cluster to that workspace. Retrieve the

kubeconfig secret value of your cluster using the command.

```bash
kubectl -n default get secret ${MANAGED_CLUSTER_NAME}-kubeconfig -o go-
template='{{.data.value}}{{ "\n"}}'
```

1. This will return a lengthy value. Copy this entire string for a secret
   using the template below as a reference. Create a new attached-cluster-
   kubeconfig.yaml file.

```yaml
apiVersion: v1
kind: Secret
metadata:
name: <your-managed-cluster-name>-kubeconfig
labels:
cluster.x-k8s.io/cluster-name: <your-managed-cluster-name>
type: cluster.x-k8s.io/secret
data:
value: <value-you-copied-from-secret-above>
```

1. Create this secret in the desired workspace using the command.

```bash
kubectl apply -f attached-cluster-kubeconfig.yaml --namespace ${WORKSPACE_NAMESPACE}
```

1. Create this nkpcluster object to attach the cluster to the workspace.
   Example:

```bash
cat << EOF | kubectl apply -f -
apiVersion: clusters.nkp.nutanix.com/v1alpha1
kind: NKPCluster
metadata:
name: ${MANAGED_CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
capiClusterRef:
name: ${MANAGED_CLUSTER_NAME}
namespace: default
kommanderCluster:
spec:
kubeconfigRef:
name: ${MANAGED_CLUSTER_NAME}-kubeconfig
clusterRef:
capiCluster:
name: ${MANAGED_CLUSTER_NAME}
EOF
```

1. You can now view this cluster in your Workspace in the UI, and you can
   confirm its status by using the command.

```bash
kubectl get nkpclusters -A
```

It might take a few minutes to reach "Joined" status. If you have several Pro
Clusters and want to turn one of them into a Managed Cluster to be centrally
administrated by a Management Cluster, see Platform Expansion: Conversion of
an NKP Pro Cluster to an NKP Ultimate Managed Cluster on page 519.

### Pre-provisioned FIPS Installation

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

#### Pre-provisioned FIPS: Defining the Infrastructure

About this task

NKP needs to know how to access your cluster hosts. This is done using
inventory resources. For initial cluster creation, you must define a control-
plane and at least one worker pool.

This procedure sets the necessary environment variables.

Procedure

1. Export the following environment variables, ensuring that all control plane
   and worker nodes are included:

```bash
export CONTROL_PLANE_1_ADDRESS="<control-plane-address-1>"
export CONTROL_PLANE_2_ADDRESS="<control-plane-address-2>"
export CONTROL_PLANE_3_ADDRESS="<control-plane-address-3>"
export WORKER_1_ADDRESS="<worker-address-1>"
export WORKER_2_ADDRESS="<worker-address-2>"
export WORKER_3_ADDRESS="<worker-address-3>"
export WORKER_4_ADDRESS="<worker-address-4>"
export SSH_USER="<ssh-user>"
export SSH_PRIVATE_KEY_SECRET_NAME="$CLUSTER_NAME-ssh-key"
```

1. Use the following template to help you define your infrastructure. The
   environment variables that you set in the previous step automatically
   replace the variable names when the inventory YAML file is created.

```bash
cat <<EOF > preprovisioned_inventory.yaml
---
apiVersion: infrastructure.cluster.konvoy.d2iq.io/v1alpha1
kind: PreprovisionedInventory
metadata:
name: $CLUSTER_NAME-control-plane
namespace: default
labels:
cluster.x-k8s.io/cluster-name: $CLUSTER_NAME
clusterctl.cluster.x-k8s.io/move: ""
spec:
hosts:
# Create as many of these as needed to match your infrastructure (3)
# Note that the command-line parameter--control-plane-replicas determines how
many control plane nodes will actually be used.
#
- address: $CONTROL_PLANE_1_ADDRESS
- address: $CONTROL_PLANE_2_ADDRESS
- address: $CONTROL_PLANE_3_ADDRESS
sshConfig:
port: 22
# This is the username used to connect to your infrastructure. This user must be (3)
root or
# have the ability to use sudo without a password (3)
user: $SSH_USER
privateKeyRef:
# This is the name of the secret you created in the previous step. It must (3)
exist in the same
# namespace as this inventory object. (3)
name: $SSH_PRIVATE_KEY_SECRET_NAME
namespace: default
---
apiVersion: infrastructure.cluster.konvoy.d2iq.io/v1alpha1
kind: PreprovisionedInventory
metadata:
name: $CLUSTER_NAME-md-0
namespace: default
labels:
cluster.x-k8s.io/cluster-name: $CLUSTER_NAME
clusterctl.cluster.x-k8s.io/move: ""
spec:
hosts:
- address: $WORKER_1_ADDRESS
- address: $WORKER_2_ADDRESS
- address: $WORKER_3_ADDRESS
- address: $WORKER_4_ADDRESS
sshConfig:
port: 22
user: $SSH_USER
privateKeyRef:
name: $SSH_PRIVATE_KEY_SECRET_NAME
namespace: default
EOF
```

#### Pre-provisioned FIPS: Defining the Control Plane Endpoint

Define the control plane endpoint for your cluster and the connection
mechanism. A control plane needs to have three, five, or seven nodes so it can
remain available if one or more nodes fail. A control plane with one node, is
not for production use.

In addition, the control plane needs an endpoint that remains available if
some nodes fail.

```bash
-------- cp1.example.com:6443
|
lb.example.com:6443 ---------- cp2.example.com:6443
|
-------- cp3.example.com:6443
```

In this example, the control plane endpoint host is lb.example.com, and the
control plane endpoint port is 6443. The control plane nodes are
cp1.example.com, cp2.example.com, and cp3.example.com. The port of each API
server is 6443.

Select your Connection Mechanism

A virtual IP is the address that the client uses to connect to the service. A
load balancer is a device that distributes the client connections to the
backend servers. Before you create a new NKP cluster, choose an external load
balancer (LB) or virtual IP.

- External load balancer

It is recommended that an external load balancer be the control plane
endpoint. To distribute request load among the control plane machines,
configure the load balancer to send requests to all the control plane
machines. Configure the load balancer to send requests only to control plane
machines that are responding to API requests.

- Built-in virtual IP

If an external load balancer is not available, use the built-in virtual IP.
The virtual IP is not a load balancer; it does not distribute request load
among the control plane machines. However, if the machine receiving requests
does not respond to them, the virtual IP automatically moves to another
machine.

Single-Node Control Plane

> **Caution: Do not use a single-node control plane in a production cluster.**

A control plane with one node can use its single node as the endpoint, so you
will not require an external load
balancer, or a built-in virtual IP. At least one control plane node must
always be running. Therefore, to upgrade a
cluster with one control plane node, a spare machine must be available in the
control plane inventory. This machine is
used to provision the new node before the old node is deleted. When the API
server endpoints are defined, you can create
the cluster using the link in the Next Step below.

```yaml
Note: Modify Control Plane Audit logs settings using the information contained in the page Configure the Control
Plane.
```

Known Limitations

The control plane endpoint port is also used as the API server port on each
control plane machine. The default port is 6443. Before you create the
cluster, ensure the port is available for use on each control plane machine.

#### Pre-provisioned FIPS: Creating the Management Cluster

About this task

After you have defined the infrastructure and control plane endpoints, you can
proceed to create the cluster by following these steps to create a new pre-
provisioned cluster. This process creates a self-managed cluster that can be
used as the management cluster.

For more information, see Deploying Clusters in FIPS Mode on page 1026.

Before you begin

First, you must name your cluster. Then, you run the command to deploy it.
When specifying the cluster-name, you must use the same cluster-name as used
when defining your inventory objects.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if the
name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

By default, the control-plane Nodes will be created in three different zones.
However, the default worker nodes will reside in a single availability zone.
You may create additional node pools in other availability zones with the nkp
create nodepool command.

Follow these steps:

Procedure

1. Give your cluster a unique name suitable for your environment.
2. Set the environment variable.

```bash
export CLUSTER_NAME=cluster_name
```

What to do next

Create a Kubernetes Cluster

After you have defined the infrastructure and control plane endpoints, you can
proceed to create the cluster by following these steps to create a new Pre-
provisioned cluster. This process creates a self-managed cluster to be used as
the Management cluster.

```yaml
Note: Before you create a new NKP cluster below, choose an external load balancer (LB) or virtual IP and use the
corresponding nkp create cluster command.
```

In a pre-provisioned environment, use the Kubernetes CSI and third party
drivers for local volumes and other storage devices in your data center.

```yaml
Warning: NKP uses local static provisioner as the default storage provider for a pre-provisioned environment.
However, localvolumeprovisioner is not suitable for production use. You can use a Kubernetes CSI
compatible storage that is suitable for production.
```

After turning off localvolumeprovisioner, you can choose from any of the
storage options available for Kubernetes. To make that storage the default
storage, use the commands shown in this section of the Kubernetes
documentation: Changing the Default Storage Class.

For Pre-provisioned environments, you define a set of nodes that already
exist. During the cluster creation process, Nutanix Image Builder on page 51
(NIB) is built into NKP and automatically runs the machine configuration
process (which NIB uses to build images for other providers) against the set
of nodes that you defined. This results in your pre-existing or pre-
provisioned nodes being configured properly.

The following command relies on the pre-provisioned cluster API infrastructure
provider to initialize the Kubernetes control plane and worker nodes on the
hosts defined in the inventory YAML previously created.

The create cluster command below includes the --self-managed flag. A self-
managed cluster refers to one in which the CAPI resources and controllers that
describe and manage it are running on the same cluster they are managing.

This command uses the default external load balancer (LB) option (see
alternative Step 1 for virtual IP):

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host <control plane endpoint host> \
--control-plane-endpoint-port <control plane endpoint port, if different than 6443> \
--pre-provisioned-inventory-file preprovisioned_inventory.yaml \
--ssh-private-key-file <path-to-ssh-private-key> \
--self-managed
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

1. ALTERNATIVE Virtual IP - if you don't have an external LB and want to use a
   VIRTUAL IP provided by

kube-vip, specify these flags example below:

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host 196.168.1.10 \
--virtual-ip-interface eth1
```

1. Use the wait command to monitor the cluster control-plane readiness:

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=30m
```

Output:

```bash
cluster.cluster.x-k8s.io/cluster_name condition met
```

> **Note: Depending on the cluster size, it will take a few minutes to
> create.** 3. When the command completes, you will have a running
> Kubernetes cluster! For bootstrap and custom YAML cluster creation, refer
> to the Additional Infrastructure Customization section of the
> documentation for Pre- provisioned: Pre-Provisioned Infrastructure.

Use this command to get the Kubernetes kubeconfig for the new cluster and
proceed to install the NKP Kommander UI:

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by
setting the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
Note: If changing the Calico encapsulation, Nutanix recommends doing so after cluster creation, but before
production. See Calico encapsulation.
```

Audit Logs To modify Control Plane Audit logs settings using the information
contained in the page Configure the Control Plane.

Further Steps For more customized cluster creation, access the Pre-Provisioned
Additional Configurations section, for custom flags, and more that specify the
secret as part of the create cluster command. If these are not specified, the
overrides for your nodes will not be applied.

Cluster Verification If you want to monitor or verify the installation of your
clusters, refer to: Cluster and NKP Installation Verification on page 1039 and
Installing NKP on page 43.

FIPS 140-3 Compliance For more information regarding FIPS, see FIPS 140-3
Compliance on page 1025.

#### Pre-provisioned FIPS: Configuring the MetalLB

Create MetalLB configuration for your Pre-provisioned infrastructure.

Choose one of the following two protocols you want to use to announce service
IPs. If your environment is not currently equipped with a load balancer, you
can use MetalLB. Otherwise, your own load balancer will work, and you can
continue the installation process with Pre-provisioned FIPS: Installing
Kommander on page 111. To use MetalLB, create MetalLB custom resources for
your Pre-provisioned infrastructure. MetalLB uses one of two protocols for
exposing Kubernetes services:

- Layer 2, with Address Resolution Protocol (ARP)
- Border Gateway Protocol (BGP)

Select one of the following procedures to create your MetalLB manifest for
further editing.

Layer 2 Configuration

Layer 2 mode is the simplest to configure: in many cases, you don't need any
protocol-specific configuration, only IP addresses.

Layer 2 mode does not require the IPs to be bound to the network interfaces of
your worker nodes. It works by responding to ARP requests on your local
network directly and giving the machine's MAC address to clients.

For example, the following configuration gives MetalLB control over IPs from
192.168.1.240 to 192.168.1.250, and configures Layer 2 mode:

The following values are generic, enter your specific values into the fields
where applicable.

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
name: default
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

BGP Configuration

For a basic configuration featuring one BGP router and one IP address range,
you need 4 pieces of information:

- The router IP address that MetalLB needs to connect to.
- The router's autonomous systems (AS) number.
- The AS number MetalLB to be used.
- An IP address range expressed as a Classless Inter-Domain Routing (CIDR)
  prefix.

As an example, if you want to give MetalLB the range 192.168.10.0/24 and AS
number 64500, and connect it to a router at 10.0.0.1 with AS number 64501,
your configuration will look like:

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
name: default
namespace: metallb-system
spec:
myASN: 64500
peerASN: 64501
peerAddress: 10.0.0.1
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.10.0/24
---
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
name: example
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

#### Pre-provisioned FIPS: Installing Kommander

About this task

Once you have installed the component of NKP, you will continue with the
installation of the Kommander component that will bring up the UI dashboard.

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

```yaml
Caution: Nutanix support is unable to recover forgotten credentials. Prevent Kommander UI lockouts with the
following best practices.
```

- Backup the kubeconfig file.
- Save your credentials.
- Configure an IDP (identity provider) instead of using a username and
  password credentials.

Before you begin:

- Ensure you have reviewed all Prerequisites for Install.
- Ensure you have a default StorageClass.
- Note the name of the cluster where you want to install Kommander. If you do
  not know the cluster name, use kubectl get nkpclusters -A to display and
  find it.

Create your Kommander Installation Configuration File

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} >> ${CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

```bash
nkp install kommander --init > kommander.yaml
```

1. Edit the installer file to include configuration overrides for the rook-
   ceph-cluster. NKP's default configuration
   ships Ceph with PersistentVolumeClaim (PVC) based storage which requires your
   CSI provider to support PVC with type
   volumeMode: Block. As this is not possible with the default local static
   provisioner, you can install Ceph in host
   storage mode. You can choose whether Ceph's object storage daemon (osd) pods
   can consume all or just some of the devices
   on your nodes. Include one of the following Overrides.

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

1. (Optional) Customize your kommander.yaml. Some options include custom
   domains and certificates, HTTP proxy, and external load balancer.

##### Installing Kommander

Procedure

Use the customized kommander.yaml to install NKP.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

#### Pre-provisioned FIPS: Verifying your Installation and Logging In To the UI

About this task

After you build the cluster and you install Kommander, verify your
installation. It waits for all applications to be ready by default.

```yaml
Note: If the Kommander installation fails or you wish to reconfigure applications, you can rerun the install command
to retry the installation.
```

Procedure

Check the installation status:

```bash
kubectl -n kommander wait --for condition=Ready helmreleases --all --timeout 15m
```

> **Note: If you prefer the CLI to not wait for all applications to become
> ready, you can set the --wait=false flag.**

The first wait for each of the helm charts to reach their Ready condition,
eventually resulting in an output resembling below:

```bash
helmrelease.helm.toolkit.fluxcd.io/centralized-grafana condition met
helmrelease.helm.toolkit.fluxcd.io/dex condition met
helmrelease.helm.toolkit.fluxcd.io/dex-k8s-authenticator condition met
helmrelease.helm.toolkit.fluxcd.io/fluent-bit condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-logging condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-loki condition met
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

##### Failed HelmReleases (2)

Procedure

If an application fails to deploy, check the status of a HelmRelease using the
command kubectl -n kommander get helmrelease `<HELMRELEASE_NAME>`

If you find any HelmReleases in a "broken" release state, such as "exhausted"
or "another rollback/release in progress", trigger a reconciliation of the
HelmRelease using the commands.

```bash
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": true}]'
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": false}]'
```

###### Logging In To the UI (2)

Procedure

1. By default, log in to the UI in Kommander with the following command:

```bash
nkp open dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

1. Retrieve your credentials:

```bash
kubectl -n kommander get secret dkp-credentials -o go-template='Username:
{{.data.username|base64decode}}{{ "\n"}}Password: {{.data.password|base64decode}}
{{ "\n"}}'
```

1. Retrieve the dashboard URL:

```bash
kubectl -n kommander get svc kommander-traefik -o go-template='https://{{with
index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}{{end}}/dkp/kommander/
dashboard{{ "\n"}}'
```

Only use the static credentials to access the UI for configuring an external
identity provider. Treat them as backup credentials rather than use them for
normal access.

a. Rotate the dashboard password:

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

b. Retrieve the new dashboard credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

For more information, see Rotating the NKP Dashboard Password on page 308.

You can perform the following operations on identity providers:

- Create an identity provider
- Temporarily disable an identity provider
- Create groups

What to do next

Dashboard UI Functions

After installing the Konvoy component and building a cluster as well as
successfully installing Kommander and logging into the UI, you are now ready
to customize configurations. For more information, Cluster Operations
Management. The majority of the customization such as attaching clusters and
deploying applications takes place in the dashboard or the NKP UI.

#### Pre-provisioned FIPS: Creating Managed Clusters Using the NKP CLI

About this task

After initial cluster creation, you have the ability to create additional
clusters from the CLI. In a previous step, the new cluster was created as
Self-managed which allows it to be a Management cluster or a stand alone
cluster. Subsequent new clusters are not self-managed as they will likely be
Managed or Attached clusters to this Management Cluster.

```yaml
Warning: When creating managed clusters, do not create and move CAPI cluster objects or install the Kommander
component. Those tasks are only done on Management clusters.
```

Your new managed cluster must be part of a workspace under a management
cluster. To make the new managed cluster a part of a workspace, set that
workspace's environment variable.

Procedure

1. If you have an existing Workspace name, run this command to find the name.

```bash
kubectl get workspace -A
```

1. When you have the Workspace name, set the WORKSPACE_NAMESPACE environment
   variable.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

> **Note: If you need to create a new Workspace, follow the instructions to
> Create a New Workspace**

##### Name Your Cluster (3)

About this task

Each cluster must have an original name.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if the
name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

By default, the control-plane Nodes will be created in 3 different zones.
However, the default worker Nodes will reside in a single Availability Zone.
You may create additional node pools in other Availability Zones with the nkp
create nodepool command.

Perform both steps to name the cluster:

Procedure

1. Give your cluster a unique name suitable for your environment.
2. Set the environment variable.

```bash
export CLUSTER_NAME=<cluster_name>
```

##### Create a Kubernetes Cluster (3)

About this task

After you have defined the infrastructure and control plane endpoints, you can
proceed to creating the cluster by following these steps to create a new pre-
provisioned cluster.

This process creates a self-managed cluster to be used as the Management
cluster.

```yaml
Tip: Before you create a new NKP cluster below, choose an external load balancer (LB) or virtual IP and use the
corresponding nkp create cluster command. For more information, see Pre-provisioned: Built-in Virtual
IP on page 782.
```

In a Pre-provisioned environment, use the Kubernetes CSI and third party
drivers for local volumes and other storage devices in your data center.

```yaml
Caution: NKP uses local static provisioner as the Default Storage Providers on page 34 for a pre-provisioned
environment. However, localvolumeprovisioner is not suitable for production use. Use Kubernetes CSI
compatible storage that is suitable for production.
```

After disabling localvolumeprovisioner, you can choose from any of the storage
options available for Kubernetes. To make that storage the default storage,
use the commands shown in this section of the Kubernetes documentation: Change
the default StorageClass

For Pre-provisioned environments, you define a set of nodes that already
exist. During the cluster creation process, Nutanix Image Builder (NIB) is
built into NKP and automatically runs the machine configuration process (which
NIB uses to build images for other providers) against the set of nodes that
you defined. This results in your pre-existing or pre-provisioned nodes being
configured properly. For more information, see Nutanix Image Builder on page 51.

The following command relies on the pre-provisioned cluster API infrastructure
provider to initialize the Kubernetes control plane and worker nodes on the
hosts defined in the inventory YAML previously created.

Procedure

1. This command uses the default external load balancer (LB) option.

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--namespace ${WORKSPACE_NAMESPACE} \
--control-plane-endpoint-host <control plane endpoint host> \
--control-plane-endpoint-port <control plane endpoint port, if different than 6443>
\
--pre-provisioned-inventory-file preprovisioned_inventory.yaml \
--ssh-private-key-file <path-to-ssh-private-key> \
--kubernetes-version=v<kubernetes-version>+fips.0 \
--etcd-version=etcd-version+fips.0 \
--kubernetes-image-repository=docker.io/mesosphere
Note: For more information about the supported Kubernetes version, see Supported Kubernetes Versions section
in the NKP Release Notes. For more information about the supported etcd version, see Supported Components
section in the NKP Release Notes.
```

1. Use the wait command to monitor the cluster control-plane readiness.

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=30m
```

> **Note: NOTE: Depending on the cluster size, it will take a few minutes to
> create.**

```bash
cluster.cluster.x-k8s.io/cluster_name condition met
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

##### Manually Attach an NKP CLI Cluster to the Management Cluster (3)

About this task

```yaml
Warning: These steps are only applicable if you do not set a WORKSPACE_NAMESPACE when creating a cluster.
If you already set a WORKSPACE_NAMESPACE, then you do not need to perform these steps since the cluster is
already attached to the workspace.
```

Procedure

When you create a Managed Cluster with the NKP CLI, it attaches automatically
to the Management Cluster after a few moments. However, if you do not set a
workspace, the attached cluster will be created in the default workspace. To
ensure that the attached cluster is created in your desired workspace
namespace, follow these instructions:

1. Confirm you have your MANAGED_CLUSTER_NAME variable set with the following
   command.

```bash
echo ${MANAGED_CLUSTER_NAME}
```

1. Retrieve your kubeconfig from the cluster you have created without setting
   a workspace.

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} >
${MANAGED_CLUSTER_NAME}.conf
```

1. Note: This is only necessary if you never set the workspace of your cluster
   upon creation.

You can now either attach it in the UI, link to attaching it to workspace
through UI that was earlier, or attach your cluster to the workspace you want
in the CLI. 4. Retrieve the workspace where you want to attach the cluster.

```bash
kubectl get workspaces -A
```

1. Set the WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace-namespace>
```

1. You need to create a secret in the desired workspace before attaching the
   cluster to that workspace. Retrieve the kubeconfig secret value of your
   cluster.

```bash
kubectl -n default get secret ${MANAGED_CLUSTER_NAME}-kubeconfig -o go-
template='{{.data.value}}{{ "\n"}}'
```

1. This will return a lengthy value. Copy this entire string for a secret
   using the template below as a reference. Create a new attached-cluster-
   kubeconfig.yaml file.

```yaml
apiVersion: v1
kind: Secret
metadata:
name: <your-managed-cluster-name>-kubeconfig
labels:
cluster.x-k8s.io/cluster-name: <your-managed-cluster-name>
type: cluster.x-k8s.io/secret
data:
value: <value-you-copied-from-secret-above>
```

1. Create this secret in the desired workspace.

```bash
kubectl apply -f attached-cluster-kubeconfig.yaml --namespace
${WORKSPACE_NAMESPACE}
```

1. Create this nkpcluster object to attach the cluster to the workspace.

```bash
cat << EOF | kubectl apply -f -
apiVersion: clusters.nkp.nutanix.com/v1alpha1
kind: NKPCluster
metadata:
name: ${MANAGED_CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
capiClusterRef:
name: ${MANAGED_CLUSTER_NAME}
namespace: default
kommanderCluster:
spec:
kubeconfigRef:
name: ${MANAGED_CLUSTER_NAME}-kubeconfig
clusterRef:
capiCluster:
name: ${MANAGED_CLUSTER_NAME}
EOF
```

1. You can now view this cluster in your Workspace in the UI and you can
   confirm its status by running the below command. It may take a few minutes
   to reach "Joined" status.

```bash
kubectl get nkpclusters -A
```

If you have several Pro Clusters and want to turn one of them into a Managed
Cluster to be centrally administrated by a Management Cluster, see Platform
Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate Managed Cluster
on page 519.

### Pre-provisioned FIPS Air-gapped Installation

This section provides instructions to install NKP in a Pre-provisioned air-
gapped environment with FIPS requirements.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

#### Pre-provisioned Air-gapped FIPS: Configuring the Environment

In order to create a cluster in a Pre-provisioned Air-gapped environment, you
must first prepare the environment.

The instructions below outline how to fulfill the requirements for using pre-
provisioned infrastructure in an air- gapped environment. In order to create a
cluster, you must first setup the environment with necessary artifacts. All
artifacts for Pre-provisioned Air-gapped need to get onto the bastion host.
Artifacts needed by nodes must be unpacked and distributed on the bastion
before other provisioning will work in the absence of an internet connection.

There is an air-gapped bundle available for download in the Nutanix Support
portal (see Downloading NKP). In previous NKP releases, the distro package
bundles were included in the downloaded air-gapped bundle. Currently, that
air-gapped bundle contains the following artifact with the exception of the
distro packages:

- Containerd tarball

1. Set the Artifacts directory.

The artifacts directory contains the packages and artifacts required to
configure the pre-provisioned host. 2. Download nkp-air-gapped-bundle_nkp-
version_linux_amd64.tar.gz , and extract the tarball to a local directory:

```bash
tar -xzvf nkp-air-gapped-bundle_nkp-version_linux_amd64.tar.gz -C
${ARTIFACTS_DIRECTORY}
```

1. You will need to fetch the distro packages as well as other artifacts. By
   fetching the distro packages from distro repositories, you get the latest
   security fixes available at machine image build time. 4. (Required for air-
   gapped environment) Create a package bundle.

NKP requires Operating System packages to be available in the base image.
These packages are available in the package repositories accessible over the
internet. As air-gapped environments are restricted from accessing these
repositories, you must first create a package bundle where the repositories
can be accessed. Then, transfer this bundle to an air-gapped environment to
build the OS image in an air-gapped environment.

Example command:

```bash
nkp create package-bundle ${OS_TYPE} --fips --artifacts-directory
${ARTIFACTS_DIRECTORY}
```

Setup Process

1. The bootstrap image must be extracted and loaded onto the bastion host. 2.
   Artifacts must be copied onto cluster hosts for nodes to access. 3. If using
   GPU, those artifacts must be positioned locally. 4. Registry seeded with
   images locally.

Load the Bootstrap Image

1. Assuming you have downloaded nkp-air-gapped-bundle_nkp-
   version_linux_amd64.tar.gz from the

download site mentioned above and extracted the tarball, you will load the
bootstrap. 2. Load the bootstrap image on your bastion machine:

Copy air-gapped artifacts onto cluster hosts

Using the Nutanix Image Builder on page 51, you can copy the required
artifacts onto your cluster hosts.

1. Assuming you have downloaded nkp-air-gapped-bundle_nkp-
   version_linux_amd64.tar.gz , extract the tarball to a local directory: 2.
   Export the following environment variables, ensuring that all control plane
   and worker nodes are included:

```bash
export CONTROL_PLANE_1_ADDRESS="<control-plane-address-1>"
export CONTROL_PLANE_2_ADDRESS="<control-plane-address-2>"
export CONTROL_PLANE_3_ADDRESS="<control-plane-address-3>"
export WORKER_1_ADDRESS="<worker-address-1>"
export WORKER_2_ADDRESS="<worker-address-2>"
export WORKER_3_ADDRESS="<worker-address-3>"
export WORKER_4_ADDRESS="<worker-address-4>"
export SSH_USER="<ssh-user>"
export SSH_PRIVATE_KEY_FILE="<private key file>"
```

SSH_PRIVATE_KEY_FILE must be either the name of the SSH private key file in
your working directory or an absolute path to the file in your user's home
directory.

| export ARTIFACTS DIRECTORY=nkp- \_ | nkp-version | /image-artifacts/ |
| ---------------------------------- | ----------- | ----------------- |

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

| docker load -i konvoy-bootstrap-image- | nkp-version | .tar |
| -------------------------------------- | ----------- | ---- |

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

1. Create a FIPS-compliant image:

```bash
export FIPS_ENABLED=true
```

The Nutanix Image Builder creates a FIPS-compliant OS image. For more
information, see Supported Infrastructure Operating Systems. 4. (Optional)
Upload NVIDIA GPU drivers:

Download the NVIDIA runfile for your NVIDIA driver version from the NVIDIA
download site.

Replace Path to NVIDIA driver runfile with the path to the NVIDIA driver
runfile.

The Nutanix Image Builder uploads the NVIDIA driver runfile to the target host
for GPU workload support. 5. (Optional) Specify a provider hint:

Replace aws|azure|gcp|vsphere|nutanix with the provider name when you install
provider specific utilities.

This helps the image builder install the appropriate provider specific
utilities on the host. 6. Upload the artifacts onto cluster hosts with the
following command:

```bash
./nkp upload image-artifacts \
--ssh-host ${CONTROL_PLANE_1_ADDRESS},${CONTROL_PLANE_2_ADDRESS} \
--ssh-username ${SSH_USER} \
${SSH_PRIVATE_KEY_FILE:+--ssh-private-key-file ${SSH_PRIVATE_KEY_FILE}} \
${SSH_PASSWORD:+--ssh-password ${SSH_PASSWORD}} \
${SSH_PORT:+--ssh-port ${SSH_PORT}} \
--artifacts-directory ${ARTIFACTS_DIRECTORY} \
${NVIDIA_RUNFILE:+--nvidia-runfile ${NVIDIA_RUNFILE}} \
${PROVIDER:+--provider ${PROVIDER}} \
${FIPS_ENABLED:+--fips}
```

NIB uses variable overrides to specify base image and container images to use
in your new machine image. The variable overrides files for NVIDIA and FIPS
can be ignored unless adding an overlay feature.

#### Pre-provisioned Air-gapped FIPS: Loading the Registry

About this task

The complete NKP air-gapped bundle is needed for an air-gapped environment but
can also be used in a non-air-gapped environment. The bundle contains all the
NKP components needed for an air-gapped environment installation and also to
use a local registry in a non-air-gapped environment.

> **Warning: If you do not already have a local registry set up, see
> Registry Mirror Tools on page 1028.**

If you are operating in an air-gapped environment, a local container registry
containing all the necessary installation images, including the Kommander
images is required. This registry must be accessible from both the bastion
machine and either the AWS EC2 instances (if deploying to AWS) or other
machines that will be created for the Kubernetes cluster.

Procedure

1. If not already done in prerequisites, download the air-gapped bundle nkp-
   air-gapped-bundle_nkp-

version_linux_amd64.tar.gz , and extract the tarball to a local directory.

| export NVIDIA RUNFILE= \_ | Path to NVIDIA driver runfile | Col3 |
| ------------------------- | ----------------------------- | ---- |

| export PROVIDER= | aws | azure | gcp | vsphere | nutanix | Col3 |
| ---------------- | --- | ----- | --- | ------- | ------- | ---- |

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

| tar -xzvf nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ---------------------------------- | ----------- | ------------------------ |

1. The directory structure after extraction can be accessed in subsequent
   steps using commands to access files from different directories. Example:
   For the bootstrap cluster, change your directory to the nkp-`<version>`
   directory similar to example below depending on your current location
2. Set an environment variable with your registry address and any other needed
   variables using this command.

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
export REGISTRY_CA=<path to the cacert file on the bastion>
```

1. Execute the following command to load the air-gapped image bundle into your
   private registry using any of the relevant flags to apply variables above.

```bash
nkp push bundle --bundle ./container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
Note: It may take some time to push all the images to your image registry, depending on the performance of the
network between the machine you are running the script on and the registry.
```

##### Kommander Load Images (2)

Procedure

If you are operating in an air-gapped environment, a local container registry
containing all the necessary installation images, including the Kommander
images is required. For instructions on how to push the necessary images to
this registry, see the steps below.

##### Load Images to your Private Registry - Kommander (2)

Procedure

Load the Kommander component images to your private registry using the command.

For the air-gapped kommander image bundle, run the command below. Run the
following command to load the image bundle.

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-nkp-version.tar --
to-registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
```

#### Pre-provisioned Air-gapped FIPS: Defining the Infrastructure

About this task

NKP needs to know how to access your cluster hosts. This is done using
inventory resources. For initial cluster creation, you must define a control-
plane and at least one worker pool.

This procedure sets the necessary environment variables.

Procedure

1. Export the following environment variables, ensuring that all control plane
   and worker nodes are included:

```bash
export CONTROL_PLANE_1_ADDRESS="<control-plane-address-1>"
export CONTROL_PLANE_2_ADDRESS="<control-plane-address-2>"
```

| cd nkp- | nkp-version | Col3 |
| ------- | ----------- | ---- |

```bash
export CONTROL_PLANE_3_ADDRESS="<control-plane-address-3>"
export WORKER_1_ADDRESS="<worker-address-1>"
export WORKER_2_ADDRESS="<worker-address-2>"
export WORKER_3_ADDRESS="<worker-address-3>"
export WORKER_4_ADDRESS="<worker-address-4>"
export SSH_USER="<ssh-user>"
export SSH_PRIVATE_KEY_SECRET_NAME="$CLUSTER_NAME-ssh-key"
```

1. Use the following template to help you define your infrastructure. The
   environment variables that you set in the previous step automatically
   replace the variable names when the inventory YAML file is created.

```bash
cat <<EOF > preprovisioned_inventory.yaml
---
apiVersion: infrastructure.cluster.konvoy.d2iq.io/v1alpha1
kind: PreprovisionedInventory
metadata:
name: $CLUSTER_NAME-control-plane
namespace: default
labels:
cluster.x-k8s.io/cluster-name: $CLUSTER_NAME
clusterctl.cluster.x-k8s.io/move: ""
spec:
hosts:
# Create as many of these as needed to match your infrastructure (4)
# Note that the command line parameter --control-plane-replicas determines how (3)
many control plane nodes will actually be used.
#
- address: $CONTROL_PLANE_1_ADDRESS
- address: $CONTROL_PLANE_2_ADDRESS
- address: $CONTROL_PLANE_3_ADDRESS
sshConfig:
port: 22
# This is the username used to connect to your infrastructure. This user must be (4)
root or
# have the ability to use sudo without a password (4)
user: $SSH_USER
privateKeyRef:
# This is the name of the secret you created in the previous step. It must (4)
exist in the same
# namespace as this inventory object. (4)
name: $SSH_PRIVATE_KEY_SECRET_NAME
namespace: default
---
apiVersion: infrastructure.cluster.konvoy.d2iq.io/v1alpha1
kind: PreprovisionedInventory
metadata:
name: $CLUSTER_NAME-md-0
namespace: default
labels:
cluster.x-k8s.io/cluster-name: $CLUSTER_NAME
clusterctl.cluster.x-k8s.io/move: ""
spec:
hosts:
- address: $WORKER_1_ADDRESS
- address: $WORKER_2_ADDRESS
- address: $WORKER_3_ADDRESS
- address: $WORKER_4_ADDRESS
sshConfig:
port: 22
user: $SSH_USER
privateKeyRef:
name: $SSH_PRIVATE_KEY_SECRET_NAME
namespace: default
EOF
```

#### Pre-provisioned Air-gapped FIPS: Defining the Control Plane Endpoint

Define the control plane endpoint for your cluster as well as the connection
mechanism. A control plane needs to have three, five, or seven nodes, so it
can remain available if one or more nodes fail. A control plane with one node,
is not for production use.

In addition, the control plane needs an endpoint that remains available if
nodes fail.

```bash
-------- cp1.example.com:6443
|
lb.example.com:6443 ---------- cp2.example.com:6443
|
-------- cp3.example.com:6443
```

In this example, the control plane endpoint host is lb.example.com, and the
control plane endpoint port is 6443. The control plane nodes are
cp1.example.com, cp2.example.com, and cp3.example.com. The port of each API
server is 6443.

Select your Connection Mechanism

A virtual IP is the address that the client uses to connect to the service. A
load balancer is the device that distributes the client connections to the
backend servers. Before you create a new NKP cluster, choose an external load
balancer (LB) or virtual IP.

- External load balancer

It is recommended that an external load balancer be the control plane
endpoint. To distribute request load among the control plane machines,
configure the load balancer to send requests to all the control plane
machines. Configure the load balancer to send requests only to control plane
machines that are responding to API requests.

- Built-in virtual IP

If an external load balancer is not available, use the built-in virtual IP.
The virtual IP is not a load balancer; it does not distribute request load
among the control plane machines. However, if the machine receiving requests
does not respond to them, the virtual IP automatically moves to another
machine.

Single-Node Control Plane

> **Caution: Do not use a single-node control plane in a production cluster.**

A control plane with one node can use its single node as the endpoint, so you
will not require an external load
balancer, or a built-in virtual IP. At least one control plane node must
always be running. Therefore, to upgrade a
cluster with one control plane node, a spare machine must be available in the
control plane inventory. This machine is
used to provision the new node before the old node is deleted. When the API
server endpoints are defined, you can create
the cluster using the link in Next Step below.

```yaml
Note: Modify Control Plane Audit logs settings using the information contained in the page Configure the Control
Plane.
```

Known Limitations

The control plane endpoint port is also used as the API server port on each
control plane machine. The default port is 6443. Before you create the
cluster, ensure the port is available for use on each control plane machine.

#### Pre-provisioned Air-gapped FIPS: Creating a Management Cluster

About this task

Before you begin

If your cluster is air-gapped or you have a local registry, you must provide
additional arguments when creating the cluster. These tell the cluster where
to locate the local registry to use by defining the URL.

```bash
export REGISTRY_URL=<https/http>://<registry-address>:<registry-port>
export REGISTRY_CA=<path to the CA on the bastion>
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
```

- REGISTRY_URL: the address of an existing registry accessible in the VPC that
  the new cluster nodes will be configured to use a mirror registry when
  pulling images.
- REGISTRY_CA: (optional) the path on the bastion machine to the registry CA.
  NKP will configure the cluster nodes to trust this CA. This value is only
  needed if the registry is using a self-signed certificate and the AMIs are
  not already configured to trust this CA.
- REGISTRY_USERNAME: optional, set to a user that has pull access to this
  registry.
- REGISTRY_PASSWORD: optional if username is not set.

```yaml
Note: (Optional) Use a registry mirror. Configure your cluster to use an existing local registry as a mirror when
attempting to pull images previously pushed to your registry when defining your infrastructure. Instructions in the
expandable Custom Installation section. For registry mirror information, see topics Using a Registry Mirror and
Registry Mirror Tools.
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by setting
the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

First you must name your cluster. Then you run the command to deploy it. When
specifying the cluster-name, you must use the same cluster-name as used when
defining your inventory objects.

```yaml
Note: When specifying the cluster-name, you must use the same cluster-name as used when defining your
inventory objects.
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if the
name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

By default, the control-plane Nodes will be created in three different zones.
However, the default worker nodes will reside in a single availability zone.
You may create additional node pools in other availability zones with the nkp
create nodepool command.

Follow these steps:

Procedure

1. Give your cluster a unique name suitable for your environment.
2. Set the environment variable: export CLUSTER_NAME=`<cluster_name>`

What to do next

Create an air-gapped Kubernetes Cluster

Before you create a new NKP cluster below, you may choose an external load
balancer or virtual IP and use the corresponding nkp create cluster command
example from that page in the docs from the links below. Other customizations
are available, but require different flags during nkp create cluster command
also. Refer to Pre- provisioned Cluster Creation Customization Choices for
more cluster customizations.

When you create a new NKP cluster below, choose an external load balancer (LB)
or virtual IP and use the corresponding nkp create cluster command.

In a pre-provisioned environment, use the Kubernetes CSI and third party
drivers for local volumes and other storage devices in your data center.

After disabling have defined the infrastructure and control plane endpoints,
you can proceed to create the cluster by following these steps to create a new
pre-provisioned cluster.

```yaml
Warning: NKP uses local static provisioner as the default storage provider for a pre-provisioned environment.
However, localvolumeprovisioner is not suitable for production use. Use Kubernetes CSI compatible
storage that is suitable for production.
```

After disabling localvolumeprovisioner, you can choose from any of the storage
options available for Kubernetes. To make that storage the default storage,
use the commands shown in this section of the Kubernetes documentation:
Changing the Default Storage Class

For Pre-provisioned environments, you define a set of nodes that already
exist. During the cluster creation process, Nutanix Image Builder (NIB) is
built into NKP and automatically runs the machine configuration process (which
NIB uses to build images for other providers) against the set of nodes that
you defined. This results in your pre-existing or pre-provisioned nodes being
configured properly.

The following command relies on the pre-provisioned cluster API infrastructure
provider to initialize the Kubernetes control plane and worker nodes on the
hosts defined in the inventory.

The create cluster command below includes the --self-managed flag. A self-
managed cluster refers to one in which the CAPI resources and controllers that
describe and manage it are running on the same cluster they are managing.

This command uses the default external load balancer (LB) option (see
alternative Step 1 for virtual IP):

```bash
nkp create cluster preprovisioned --cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host <control plane endpoint host> \
--control-plane-endpoint-port <control plane endpoint port, if different than 6443> \
--pre-provisioned-inventory-file preprovisioned_inventory.yaml \
--ssh-private-key-file <path-to-ssh-private-key> \
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-cacert=${REGISTRY_CA} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD} \
--self-managed
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

1. ALTERNATIVE Virtual IP - if you don't have an external LB, and want to use
   a VIRTUAL IP provided by

kube-vip, specify these flags example below:

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host 196.168.1.10 \
--virtual-ip-interface eth1
```

1. Use the wait command to monitor the cluster control-plane readiness:

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=30m
```

Output:

```bash
cluster.cluster.x-k8s.io/cluster_name condition met
```

> **Note: Depending on the cluster size, it will take a few minutes to create.**

When the command completes, you will have a running Kubernetes cluster! For
bootstrap and custom YAML cluster creation, refer to the Additional
Infrastructure Customization section of the documentation for Pre-provisioned:
Pre- provisioned Infrastructure

Use this command to get the Kubernetes kubeconfig for the new cluster and
proceed to installing the NKP Kommander UI:

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
Note: If changing the Calico encapsulation, Nutanix recommends changing it after cluster creation, but before
production.
```

Audit Logs To modify Control Plane Audit logs settings using the information
contained in the page Configure the Control Plane.

Further Steps For more customized cluster creation, access the Pre-Provisioned
Additional Configurations section, for custom flags, and more that specify the
secret as part of the create cluster command. If these are not specified, the
overrides for your nodes will not be applied.

Cluster Verification If you want to monitor or verify the installation of your
clusters, refer to: Cluster and NKP Installation Verification on page 1039 and
Installing NKP on page 43.

#### Pre-provisioned Air-gapped FIPS: Configuring MetalLB

Create MetalLB configuration for your Pre-provisioned infrastructure.

Choose one of the following two protocols you want to use to announce service
IPs. If your environment is not currently equipped with a load balancer, you
can use MetalLB. Otherwise, your own load balancer will work and you can
continue the installation process with Pre-provisioned Air-gapped FIPS:
Installing Kommander on page 128. To use MetalLB, create MetalLB custom
resources for your Pre-provisioned infrastructure. MetalLB uses one of two
protocols for exposing Kubernetes services:

- Layer 2, with Address Resolution Protocol (ARP)
- Border Gateway Protocol (BGP)

Select one of the following procedures to create your MetalLB manifest for
further editing.

Layer 2 Configuration

Layer 2 mode is the simplest to configure: in many cases, you don't need any
protocol-specific configuration, only IP addresses.

Layer 2 mode does not require the IPs to be bound to the network interfaces of
your worker nodes. It works by responding to ARP requests on your local
network directly, to give the machine's MAC address to clients.

For example, the following configuration gives MetalLB control over IPs from
192.168.1.240 to 192.168.1.250, and configures Layer 2 mode:

The following values are generic, enter your specific values into the fields
where applicable.

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
name: default
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

BGP Configuration

For a basic configuration featuring one BGP router and one IP address range,
you need 4 pieces of information:

- The router IP address that MetalLB needs to connect to.
- The router's autonomous systems (AS) number.
- The AS number MetalLB to be used.
- An IP address range expressed as a Classless Inter-Domain Routing (CIDR)
  prefix.

As an example, if you want to give MetalLB the range 192.168.10.0/24 and AS
number 64500, and connect it to a router at 10.0.0.1 with AS number 64501,
your configuration will look like:

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
name: default
namespace: metallb-system
spec:
myASN: 64500
peerASN: 64501
peerAddress: 10.0.0.1
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.10.0/24
---
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
name: example
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

#### Pre-provisioned Air-gapped FIPS: Installing Kommander

About this task

Once you have installed the component of NKP, you will continue with the
installation of the Kommander component that will bring up the UI dashboard.

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

Prerequisites:

- Ensure you have reviewed all Prerequisites for Install.
- Ensure you have a default StorageClass.
- Ensure you have loaded all the necessary images for your configuration. See:
  Load the Images into Your Registry: Air-gapped Environments.
- Note the name of the cluster where you want to install Kommander. If you do
  not know the cluster name, use kubectl get nkpclusters -A to display and
  find it.

Create your Kommander Installation Configuration File

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} >> ${CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

```bash
nkp install kommander --init > kommander.yaml
```

1. Edit the installer file to include configuration overrides for the rook-
   ceph-cluster. NKP's default configuration ships Ceph with PVC based storage
   which requires your CSI provider to support PVC with type volumeMode: Block.
   As this is not possible with the default local static provisioner, you can
   install Ceph in

host storage mode. You can choose whether Ceph's object storage daemon (osd)
pods can consume all or just some of the devices on your nodes. Include one of
the following Overrides.

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

1. (Optional) Customize your kommander.yaml. Some options include custom
   domains and certificates, HTTP proxy, and external load balancer.

##### Installing Kommander (2)

Procedure

Use the customized kommander.yaml to install NKP.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

#### Pre-provisioned Air-gapped FIPS: Verifying your Installation and Logging

In To the UI

About this task

After you build the cluster and you install Kommander, verify your
installation. It waits for all applications to be ready by default.

```yaml
Note: If the Kommander installation fails or you wish to reconfigure applications, you can rerun the install command
to retry the installation.
```

Procedure

Check the installation status:

```bash
kubectl -n kommander wait --for condition=Ready helmreleases --all --timeout 15m
```

> **Note: If you prefer the CLI to not wait for all applications to become
> ready, you can set the --wait=false flag.**

The first wait for each of the helm charts to reach their Ready condition,
eventually resulting in an output resembling below:

```bash
helmrelease.helm.toolkit.fluxcd.io/centralized-grafana condition met
helmrelease.helm.toolkit.fluxcd.io/dex condition met
helmrelease.helm.toolkit.fluxcd.io/dex-k8s-authenticator condition met
helmrelease.helm.toolkit.fluxcd.io/fluent-bit condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-logging condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-loki condition met
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

##### Failed HelmReleases (3)

Procedure

If an application fails to deploy, check the status of a HelmRelease using the
command kubectl -n kommander get helmrelease `<HELMRELEASE_NAME>`

If you find any HelmReleases in a "broken" release state, such as "exhausted"
or "another rollback/release in progress", trigger a reconciliation of the
HelmRelease using the commands.

```bash
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": true}]'
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": false}]'
```

###### Log in to the UI

Procedure

```bash
NKP open dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

1. Retrieve your credentials:

```bash
kubectl -n kommander get secret dkp-credentials -o go-template='Username:
{{.data.username|base64decode}}{{ "\n"}}Password: {{.data.password|base64decode}}
{{ "\n"}}'
```

1. Retrieve the dashboard URL:

```bash
kubectl -n kommander get svc kommander-traefik -o go-template='https://{{with
index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}{{end}}/dkp/kommander/
dashboard{{ "\n"}}'
```

Only use the static credentials to access the UI for configuring an external
identity provider. Treat them as backup credentials rather than use them for
normal access.

a. Rotate the dashboard password:

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

b. Retrieve the new dashboard credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

For more information, see Rotating the NKP Dashboard Password on page 308.

#### Pre-provisioned Air-gapped FIPS: Creating Managed Clusters Using the NKP

CLI

About this task

After initial cluster creation, you have the ability to create additional
clusters from the CLI. In a previous step, the new cluster was created as
Self-managed which allows it to be a Management cluster or a stand alone
cluster. Subsequent new clusters are not self-managed as they will likely be
Managed or Attached clusters to this Management Cluster.

```yaml
Warning: When creating managed clusters, do not create and move CAPI cluster objects or install the Kommander
component. Those tasks are only done on Management clusters.
```

Your new managed cluster must be part of a workspace under a management
cluster. To make the new managed cluster a part of a workspace, set that
workspace's environment variable.

Procedure

1. If you have an existing Workspace name, run this command to find the name.

```bash
kubectl get workspace -A
```

1. When you have the Workspace name, set the WORKSPACE_NAMESPACE environment
   variable.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

> **Note: If you need to create a new Workspace, follow the instructions to
> Create a New Workspace**

##### Name Your Cluster (4)

About this task

Each cluster must have an original name.

After you have defined the infrastructure and control plane endpoints, you can
proceed to creating the cluster by following these steps to create a new pre-
provisioned cluster. This process creates a self-managed cluster to be used as
the Management cluster.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if the
name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

Perform both steps to name the cluster:

Procedure

1. Give your cluster a unique name suitable for your environment.
2. Set the environment variable.

```bash
export CLUSTER_NAME=<cluster_name>
```

##### Create a Kubernetes Cluster (4)

About this task

After you have defined the infrastructure and control plane endpoints, you can
proceed to creating the cluster by following these steps to create a new pre-
provisioned cluster.

This process creates a self-managed cluster to be used as the Management
cluster.

```yaml
Tip: Before you create a new NKP cluster below, choose an external load balancer (LB) or virtual IP and use the
corresponding NKP create cluster command.
```

In a Pre-provisioned environment, use the Kubernetes CSI and third party
drivers for local volumes and other storage devices in your data center.

```yaml
Caution: NKP uses local static provisioner as the default storage provider for a pre-provisioned environment.
However, localvolumeprovisioner is not suitable for production use. Use Kubernetes CSI compatible
storage that is suitable for production.
```

After disabling localvolumeprovisioner, you can choose from any of the storage
options available for Kubernetes. To make that storage the default storage,
use the commands shown in this section of the Kubernetes documentation: Change
the default StorageClass

For Pre-provisioned environments, you define a set of nodes that already
exist. During the cluster creation process, Nutanix Image Builder on page 51
(NIB) is built into NKP and automatically runs the machine configuration
process (which NIB uses to build images for other providers) against the set
of nodes that you defined. This results in your pre-existing or pre-
provisioned nodes being configured properly.

The following command relies on the pre-provisioned cluster API infrastructure
provider to initialize the Kubernetes control plane and worker nodes on the
hosts defined in the inventory YAML previously created.

Procedure

1. This command uses the default external load balancer (LB) option.

```bash
nkp create cluster preprovisioned --cluster-name ${CLUSTER_NAME} \
--namespace ${WORKSPACE_NAME \
--control-plane-endpoint-host <control plane endpoint host> \
--control-plane-endpoint-port <control plane endpoint port, if different than 6443>
\
--pre-provisioned-inventory-file preprovisioned_inventory.yaml \
--ssh-private-key-file <path-to-ssh-private-key> \
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-cacert=${REGISTRY_CA} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD}
```

1. Use the wait command to monitor the cluster control-plane readiness.

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=30m
```

> **Note: NOTE: Depending on the cluster size, it will take a few minutes to
> create.**

```bash
cluster.cluster.x-k8s.io/cluster_name condition met
Tip: If your environment uses HTTP or HTTPS proxies, you must include the flags --http-proxy, --https-
proxy, and --no-proxy and their related values in this command for it to be successful. More information is
available in Configuring an HTTP or HTTPS Proxy on page 696.
```

##### Manually Attach an NKP CLI Cluster to the Management Cluster (4)

Procedure

```yaml
Warning: These steps are only applicable if you do not set a WORKSPACE_NAMESPACE when creating a cluster.
If you already set a WORKSPACE_NAMESPACE, then you do not need to perform these steps since the cluster is
already attached to the workspace.
```

When you create a Managed Cluster with the NKP CLI, it attaches automatically
to the Management Cluster after a few moments. However, if you do not set a
workspace, the attached cluster will be created in the default workspace. To
ensure that the attached cluster is created in your desired workspace
namespace, follow these instructions:

1. Confirm you have your MANAGED_CLUSTER_NAME variable set with the following
   command.

```bash
echo ${MANAGED_CLUSTER_NAME}
```

1. Retrieve your kubeconfig from the cluster you have created without setting
   a workspace.

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} >
${MANAGED_CLUSTER_NAME}.conf
```

1. Note: This is only necessary if you never set the workspace of your cluster
   upon creation.

You can now either attach it in the UI, link to attaching it to workspace
through UI that was earlier, or attach your cluster to the workspace you want
in the CLI. 4. Retrieve the workspace where you want to attach the cluster.

```bash
kubectl get workspaces -A
```

1. Set the WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace-namespace>
```

1. You need to create a secret in the desired workspace before attaching the
   cluster to that workspace. Retrieve the kubeconfig secret value of your
   cluster.

```bash
kubectl -n default get secret ${MANAGED_CLUSTER_NAME}-kubeconfig -o go-
template='{{.data.value}}{{ "\n"}}'
```

1. This will return a lengthy value. Copy this entire string for a secret
   using the template below as a reference. Create a new attached-cluster-
   kubeconfig.yaml file.

```yaml
apiVersion: v1
kind: Secret
metadata:
name: <your-managed-cluster-name>-kubeconfig
labels:
cluster.x-k8s.io/cluster-name: <your-managed-cluster-name>
type: cluster.x-k8s.io/secret
data:
value: <value-you-copied-from-secret-above>
```

1. Create this secret in the desired workspace.

```bash
kubectl apply -f attached-cluster-kubeconfig.yaml --namespace
${WORKSPACE_NAMESPACE}
```

1. Create this nkpcluster object to attach the cluster to the workspace.

```bash
cat << EOF | kubectl apply -f -
apiVersion: clusters.nkp.nutanix.com/v1alpha1
kind: NKPCluster
metadata:
name: ${MANAGED_CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
capiClusterRef:
name: ${MANAGED_CLUSTER_NAME}
namespace: default
kommanderCluster:
spec:
kubeconfigRef:
name: ${MANAGED_CLUSTER_NAME}-kubeconfig
clusterRef:
capiCluster:
name: ${MANAGED_CLUSTER_NAME}
EOF
```

1. You can now view this cluster in your Workspace in the UI and you can
   confirm its status by running the below command. It may take a few minutes
   to reach "Joined" status.

```bash
kubectl get nkpclusters -A
```

If you have several Pro Clusters and want to turn one of them into a Managed
Cluster to be centrally administrated by a Management Cluster, see Platform
Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate Managed Cluster
on page 519.

### Pre-provisioned with GPU Installation

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

#### Pre-provisioned GPU: Nodepool Secrets and Overrides

About this task

For pre-provisioned environments, NKP has introduced the nvidia-runfile flag
for Air-gapped Pre- provisioned environments. If the NVIDIA runfile installer
has not been downloaded, then retrieve and install the download first by
running the following command. The first line in the command below downloads
and installs the runfile and the second line places it in the artifacts
directory (you must create an artifacts directory if it doesn't already
exist).

```bash
curl -O https://download.nvidia.com/XFree86/Linux-x86_64/580.126.18/NVIDIA-Linux-
x86_64-580.126.18.run mv NVIDIA-Linux-x86_64-580.126.18.run artifacts
```

> **Note: The NKP supported NVIDIA driver version is 580.126.18. For more
> information, see NVIDIA Drivers.**

Procedure

1. Create the secret that GPU nodepool uses.

Example output of a file named overrides/nvidia.yaml.

```bash
gpu:
types:
- nvidia
build_name_extra: "-nvidia"
```

1. Create a secret on the bootstrap cluster that is populated from the above
   file. We will name it

```bash
${CLUSTER_NAME}-user-overrides
kubectl create secret generic ${CLUSTER_NAME}-user-overrides --from-
file=overrides.yaml=overrides/nvidia.yaml
```

1. Create an inventory and nodepool with the instructions below and use the
   ${CLUSTER_NAME}-user-overrides secret.

a. Create an inventory object that has the same name as the node pool you're
creating, and the details of the pre- provisioned machines that you want to
add to it. For example, to create a node pool named gpu-nodepool an inventory
named gpu-nodepool must be present in the same namespace.

```yaml
apiVersion: infrastructure.cluster.konvoy.d2iq.io/v1alpha1
kind: PreprovisionedInventory
metadata:
name: ${MY_NODEPOOL_NAME}
spec:
hosts:
- address: ${IP_OF_NODE}
sshConfig:
port: 22
user: ${SSH_USERNAME}
privateKeyRef:
name: ${NAME_OF_SSH_SECRET}
namespace: ${NAMESPACE_OF_SSH_SECRET}
```

b. (Optional) If your pre-provisioned machines have overrides, you must create
a secret that includes all of the overrides you want to provide in one file.
Create an override secret using the instructions detailed on this page.

c. Once the PreprovisionedInventory object and overrides are created, create a
node pool.

```bash
nkp create nodepool preprovisioned -c ${MY_CLUSTER_NAME} ${MY_NODEPOOL_NAME} --
override-secret-name ${MY_OVERRIDE_SECRET}
Note: Advanced users can use a combination of the --dry-run and --output=yaml or --output-
directory=<existing-directory> flags to get a complete set of node pool objects to modify locally
or store in version control.
Note: For more information regarding this flag or others, see the nkp create nodepool section of the
documentation for either cluster or nodepool and select your provider.
```

#### Pre-provisioned GPU: Defining the Infrastructure

About this task

NKP needs to know how to access your cluster hosts. This is done using
inventory resources. For initial cluster creation, you must define a control-
plane and at least one worker pool.

This procedure sets the necessary environment variables.

Procedure

1. Export the following environment variables, ensuring that all control plane
   and worker nodes are included:

```bash
export CONTROL_PLANE_1_ADDRESS="<control-plane-address-1>"
export CONTROL_PLANE_2_ADDRESS="<control-plane-address-2>"
export CONTROL_PLANE_3_ADDRESS="<control-plane-address-3>"
export WORKER_1_ADDRESS="<worker-address-1>"
export WORKER_2_ADDRESS="<worker-address-2>"
export WORKER_3_ADDRESS="<worker-address-3>"
export WORKER_4_ADDRESS="<worker-address-4>"
export SSH_USER="<ssh-user>"
export SSH_PRIVATE_KEY_SECRET_NAME="$CLUSTER_NAME-ssh-key"
```

1. Use the following template to help you define your infrastructure. The
   environment variables that you set in the previous step automatically
   replace the variable names when the inventory YAML file is created.

```bash
cat <<EOF > preprovisioned_inventory.yaml
---
apiVersion: infrastructure.cluster.konvoy.d2iq.io/v1alpha1
kind: PreprovisionedInventory
metadata:
name: $CLUSTER_NAME-control-plane
namespace: default
labels:
cluster.x-k8s.io/cluster-name: $CLUSTER_NAME
clusterctl.cluster.x-k8s.io/move: ""
spec:
hosts:
# Create as many of these as needed to match your infrastructure (5)
# Note that the command line parameter --control-plane-replicas determines how (4)
many control plane nodes will actually be used.
#
- address: $CONTROL_PLANE_1_ADDRESS
- address: $CONTROL_PLANE_2_ADDRESS
- address: $CONTROL_PLANE_3_ADDRESS
sshConfig:
port: 22
# This is the username used to connect to your infrastructure. This user must be (5)
root or
# have the ability to use sudo without a password (5)
user: $SSH_USER
privateKeyRef:
# This is the name of the secret you created in the previous step. It must (5)
exist in the same
# namespace as this inventory object. (5)
name: $SSH_PRIVATE_KEY_SECRET_NAME
namespace: default
---
apiVersion: infrastructure.cluster.konvoy.d2iq.io/v1alpha1
kind: PreprovisionedInventory
metadata:
name: $CLUSTER_NAME-md-0
namespace: default
labels:
cluster.x-k8s.io/cluster-name: $CLUSTER_NAME
clusterctl.cluster.x-k8s.io/move: ""
spec:
hosts:
- address: $WORKER_1_ADDRESS
- address: $WORKER_2_ADDRESS
- address: $WORKER_3_ADDRESS
- address: $WORKER_4_ADDRESS
sshConfig:
port: 22
user: $SSH_USER
privateKeyRef:
name: $SSH_PRIVATE_KEY_SECRET_NAME
namespace: default
EOF
```

#### Pre-provisioned GPU: Defining the Control Plane Endpoint

Define the control plane endpoint for your cluster as well as the connection
mechanism. A control plane needs to have three, five, or seven nodes, so it
can remain available if one or more nodes fail. A control plane with one node,
is not for production use.

In addition, the control plane needs an endpoint that remains available if
some nodes fail.

```bash
-------- cp1.example.com:6443
|
lb.example.com:6443 ---------- cp2.example.com:6443
|
-------- cp3.example.com:6443
```

In this example, the control plane endpoint host is lb.example.com, and the
control plane endpoint port is 6443. The control plane nodes are
cp1.example.com, cp2.example.com, and cp3.example.com. The port of each API
server is 6443.

Select your Connection Mechanism

A virtual IP is the address that the client uses to connect to the service. A
load balancer is the device that distributes the client connections to the
backend servers. Before you create a new NKP cluster, choose an external load
balancer (LB) or virtual IP.

- External load balancer

It is recommended that an external load balancer be the control plane
endpoint. To distribute request load among the control plane machines,
configure the load balancer to send requests to all the control plane
machines. Configure the load balancer to send requests only to control plane
machines that are responding to API requests.

- Built-in virtual IP

If an external load balancer is not available, use the built-in virtual IP.
The virtual IP is not a load balancer; it does not distribute request load
among the control plane machines. However, if the machine receiving requests
does not respond to them, the virtual IP automatically moves to another
machine.

Single-Node Control Plane

> **Caution: Do not use a single-node control plane in a production cluster.**

A control plane with one node can use its single node as the endpoint, so you
will not require an external load
balancer, or a built-in virtual IP. At least one control plane node must
always be running. Therefore, to upgrade a
cluster with one control plane node, a spare machine must be available in the
control plane inventory. This machine is
used to provision the new node before the old node is deleted. When the API
server endpoints are defined, you can create
the cluster using the link in Next Step below.

```yaml
Note: Modify Control Plane Audit logs settings using the information contained in the page Configure the Control
Plane.
```

Known Limitations

The control plane endpoint port is also used as the API server port on each
control plane machine. The default port is 6443. Before you create the
cluster, ensure the port is available for use on each control plane machine.

#### Pre-provisioned GPU: Creating the Management Cluster

About this task

After you have defined the infrastructure and control plane endpoints, you can
proceed to creating the cluster by following these steps to create a new pre-
provisioned cluster. This process creates a self- managed cluster to be used
as the Management cluster.

For GPU Steps in Pre-provisioned section of the documentation to use the
overrides/nvidia.yaml.

Additional helpful information can be found in the NVIDIA Device Plug-in for
Kubernetes instructions and the Installation Guide of Supported Platforms.

Before you begin

First you must name your cluster. Then you run the command to deploy it. When
specifying the cluster- name, you must use the same cluster-name as used when
defining your inventory objects.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if the
name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

Procedure

1. Give your cluster a unique name suitable for your environment.
2. Set the environment variable:

```bash
export CLUSTER_NAME=cluster_name
```

What to do next

Create a Kubernetes Cluster: After you have defined the infrastructure and
control plane endpoints, you can proceed to
creating the cluster by following these steps to create a new Pre-provisioned
cluster. This process creates a self-
managed cluster to be used as the Management cluster. By default, the control-
plane Nodes will be created in 3 different
zones. However, the default worker Nodes will reside in a single Availability
Zone. You may create additional node pools
in other Availability Zones with the nkp create nodepool command.

Before you create a new NKP cluster below, choose an external load balancer
(LB) or virtual IP and use the corresponding nkp create cluster command.

In a pre-provisioned environment, use the Kubernetes CSI and third party
drivers for local volumes and other storage devices in your data center.

```yaml
Warning: NKP uses local static provisioner as the default storage provider for a pre-provisioned environment.
However, localvolumeprovisioner is not suitable for production use. You can use a Kubernetes CSI
compatible storage that is suitable for production.
```

After disabling localvolumeprovisioner, you can choose from any of the storage
options available for Kubernetes. To make that storage the default storage,
use the commands shown in this section of the Kubernetes documentation:
Changing the Default Storage Class

For Pre-provisioned environments, you define a set of nodes that already
exist. During the cluster creation process, Nutanix Image Builder on page 51
(NIB) is built into NKP and automatically runs the machine configuration
process (which NIB uses to build images for other providers) against the set
of nodes that you defined. This results in your pre-existing or pre-
provisioned nodes being configured properly.

The following command relies on the pre-provisioned cluster API infrastructure
provider to initialize the Kubernetes control plane and worker nodes on the
hosts defined in the inventory YAML previously created.

The create cluster command below includes the --self-managed flag. A self-
managed cluster refers to one in which the CAPI resources and controllers that
describe and manage it are running on the same cluster they are managing.

This command uses the default external load balancer (LB) option (see
alternative Step 1 for virtual IP):

```bash
nkp create cluster preprovisioned \
--cluster-name=${CLUSTER_NAME} \
--control-plane-endpoint-host <control plane endpoint host> \
--control-plane-endpoint-port <control plane endpoint port, if different than 6443> \
--pre-provisioned-inventory-file preprovisioned_inventory.yaml \
--ssh-private-key-file <path-to-ssh-private-key> \
--self-managed
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

1. ALTERNATIVE Virtual IP - if you don't have an external LB, and want to use
   a VIRTUAL IP provided by

kube-vip, specify these flags example below:

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host 196.168.1.10 \
--virtual-ip-interface eth1
```

1. Use the wait command to monitor the cluster control-plane readiness:

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=30m
```

Output:

```bash
cluster.cluster.x-k8s.io/cluster_name condition met
```

> **Note: Depending on the cluster size, it will take a few minutes to create.**

When the command completes, you will have a running Kubernetes cluster! For
bootstrap and custom YAML cluster creation, refer to the Additional
Infrastructure Customization section of the documentation for Pre-provisioned:
Pre- Provisioned Infrastructure

Use this command to get the Kubernetes kubeconfig for the new cluster and
proceed to installing the NKP Kommander UI:

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
Note: If changing the Calico encapsulation, Nutanix recommends changing it after cluster creation, but before
production.
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by setting
the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

Audit Logs To modify Control Plane Audit logs settings using the information
contained in the page Configure the Control Plane.

Further Steps For more customized cluster creation, access the Pre-Provisioned
Additional Configurations section, for custom flags, and more that specify the
secret as part of the create cluster command. If these are not specified, the
overrides for your nodes will not be applied.

Cluster Verification If you want to monitor or verify the installation of your
clusters, refer to: Cluster and NKP Installation Verification on page 1039 and
Installing NKP on page 43.

#### Pre-provisioned GPU: Configuring MetalLB

Create MetalLB configuration for your Pre-provisioned infrastructure.

Choose one of the following two protocols you want to use to announce service
IPs. If your environment is not currently equipped with a load balancer, you
can use MetalLB. Otherwise, your own load balancer will work and you can
continue the installation process with Pre-provisioned GPU: Installing
Kommander on page 142. To use MetalLB, create MetalLB custom resources for
your Pre-provisioned infrastructure. MetalLB uses one of two protocols for
exposing Kubernetes services:

- Layer 2, with Address Resolution Protocol (ARP)
- Border Gateway Protocol (BGP)

Select one of the following procedures to create your MetalLB manifest for
further editing.

Layer 2 Configuration

Layer 2 mode is the simplest to configure: in many cases, you don't need any
protocol-specific configuration, only IP addresses.

Layer 2 mode does not require the IPs to be bound to the network interfaces of
your worker nodes. It works by responding to ARP requests on your local
network directly, to give the machine's MAC address to clients.

For example, the following configuration gives MetalLB control over IPs from
192.168.1.240 to 192.168.1.250, and configures Layer 2 mode:

The following values are generic, enter your specific values into the fields
where applicable.

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
name: default
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

BGP Configuration

For a basic configuration featuring one BGP router and one IP address range,
you need 4 pieces of information:

- The router IP address that MetalLB needs to connect to.
- The router's autonomous systems (AS) number.
- The AS number MetalLB to be used.
- An IP address range expressed as a Classless Inter-Domain Routing (CIDR)
  prefix.

As an example, if you want to give MetalLB the range 192.168.10.0/24 and AS
number 64500, and connect it to a router at 10.0.0.1 with AS number 64501,
your configuration will look like:

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
name: default
namespace: metallb-system
spec:
myASN: 64500
peerASN: 64501
peerAddress: 10.0.0.1
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.10.0/24
---
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
name: example
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

#### Pre-provisioned GPU: Installing Kommander

About this task

Once you have installed the component of NKP, you will continue with the
installation of the Kommander component that will bring up the UI dashboard.

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

Prerequisites:

- Ensure you have reviewed all Prerequisites for Install.
- Ensure you have a default storage class. For more information, see Default
  StorageClass on page 980.
- Note the name of the cluster where you want to install Kommander. If you do
  not know the cluster name, use kubectl get nkpclusters -A to display and
  find it.

Create your Kommander Installation Configuration File

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} >> ${CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

```bash
nkp install kommander --init > kommander.yaml
```

1. Edit the installer file to include configuration overrides for the rook-
   ceph-cluster. NKP's default configuration
   ships Ceph with PersistentVolumeClaim (PVC) based storage which requires your
   CSI provider to support PVC with type
   volumeMode: Block. As this is not possible with the default local static
   provisioner, you can install Ceph in host
   storage mode. You can choose whether Ceph's object storage daemon (osd) pods
   can consume all or just some of the devices
   on your nodes. Include one of the following Overrides.

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

1. (Optional) Customize your kommander.yaml. Some options include custom
   domains and certificates, HTTP proxy, and external load balancer.

##### Enabling GPU Resources

Procedure

Enable NVIDIA platform services in the same kommander.yamlfile. for GPU
resources.

```bash
apps:
nvidia-gpu-operator:
enabled: true
```

##### Installing Kommander (3)

Procedure

Use the customized kommander.yaml to install NKP.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

#### Pre-provisioned GPU: Verifying your Installation and UI Log in

About this task

After you build the cluster and you install Kommander, verify your
installation. It waits for all applications to be ready by default.

```yaml
Note: If the Kommander installation fails or you wish to reconfigure applications, you can rerun the install command
to retry the installation.
```

Procedure

Check the installation status:

```bash
kubectl -n kommander wait --for condition=Ready helmreleases --all --timeout 15m
```

> **Note: If you prefer the CLI to not wait for all applications to become
> ready, you can set the --wait=false flag.**

The first wait for each of the helm charts to reach their Ready condition,
eventually resulting in an output resembling below:

```bash
helmrelease.helm.toolkit.fluxcd.io/centralized-grafana condition met
helmrelease.helm.toolkit.fluxcd.io/dex condition met
helmrelease.helm.toolkit.fluxcd.io/dex-k8s-authenticator condition met
helmrelease.helm.toolkit.fluxcd.io/fluent-bit condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-logging condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-loki condition met
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

##### Failed HelmReleases (4)

Procedure

If an application fails to deploy, check the status of a HelmRelease using the
command kubectl -n kommander get helmrelease `<HELMRELEASE_NAME>`

If you find any HelmReleases in a "broken" release state, such as "exhausted"
or "another rollback/release in progress", trigger a reconciliation of the
HelmRelease using the commands.

```bash
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": true}]'
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": false}]'
```

###### Logging In To the UI (3)

Procedure

1. By default, log in to the UI in Kommander with the following command:

```bash
nkp open dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

1. Retrieve your credentials:

```bash
kubectl -n kommander get secret dkp-credentials -o go-template='Username:
{{.data.username|base64decode}}{{ "\n"}}Password: {{.data.password|base64decode}}
{{ "\n"}}'
```

1. Retrieve the dashboard URL:

```bash
kubectl -n kommander get svc kommander-traefik -o go-template='https://{{with
index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}{{end}}/dkp/kommander/
dashboard{{ "\n"}}'
```

Only use the static credentials to access the UI for configuring an external
identity provider. Treat them as backup credentials rather than use them for
normal access.

a. Rotate the dashboard password:

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

b. Retrieve the new dashboard credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

For more information, see Rotating the NKP Dashboard Password on page 308.

You can perform the following operations on identity providers:

- Create an identity provider
- Temporarily disable an identity provider
- Create groups

What to do next

Dashboard UI Functions

After installing the Konvoy component and building a cluster as well as
successfully installing Kommander and logging into the UI, you are now ready
to customize configurations. For more information, Cluster Operations
Management. The majority of the customization such as attaching clusters and
deploying applications takes place in the dashboard or the NKP UI.

#### Pre-provisioned GPU: Creating Managed Clusters Using the NKP CLI

About this task

After initial cluster creation, you can create additional clusters from the
CLI. In a previous step, the new cluster was created as Self-managed, which
allows it to be a Management cluster or a stand-alone cluster. Subsequent new
clusters are not self-managed, as they will likely be Managed or Attached
clusters to this Management Cluster.

```yaml
Warning: When creating managed clusters, do not create and move CAPI cluster objects or install the Kommander
component. Those tasks are only done on Management clusters.
```

Your new managed cluster must be part of a workspace under a management
cluster. To make the new managed cluster a part of a workspace, set that
workspace's environment variable.

Procedure

1. If you have an existing Workspace name, run this command to find the name.

> **Note: If you need to create a new Workspace, follow the instructions to
> Create a New Workspace**

```bash
kubectl get workspace -A
```

1. When you have the Workspace name, set the WORKSPACE_NAMESPACE environment
   variable.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

##### Name Your Cluster (5)

About this task

Each cluster must have an original name.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if the
name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

By default, the control-plane Nodes will be created in 3 different zones.
However, the default worker Nodes will reside in a single Availability Zone.
You may create additional node pools in other Availability Zones with the nkp
create nodepool command.

Perform both steps to name the cluster:

Procedure

1. Give your cluster a unique name suitable for your environment.
2. Set the environment variable.

```bash
export CLUSTER_NAME=<cluster_name>
```

###### Create a Cluster with GPU AMI

Procedure

- If a custom AMI was created using Nutanix Image Builder, use the --ami flag.
  The custom ami id is printed and written to ./manifest.json. To use the
  built ami with NKP, specify it with the --ami flag when calling cluster
  create in Step 1 in the next section where you create your Kubernetes
  cluster.

##### Create a Kubernetes Cluster (5)

About this task

After you have defined the infrastructure and control plane endpoints, you can
proceed to create the cluster by following these steps to create a new pre-
provisioned cluster.

This process creates a self-managed cluster that can be used as the management
cluster.

```yaml
Tip: Before you create a new NKP cluster below, choose an external load balancer (LB) or virtual IP and use the
corresponding nkp create cluster command. For more information, see Pre-provisioned: Built-in Virtual
IP on page 782
```

In a Pre-provisioned environment, use the Kubernetes CSI and third-party
drivers for local volumes and other storage devices in your data center.

```yaml
Caution: NKP uses a local static provisioner as the default storage provider for a pre-provisioned environment.
However, localvolumeprovisioner is not suitable for production use. Use Kubernetes CSI compatible
storage that is suitable for production.
```

After turning off localvolumeprovisioner, you can choose from any of the
storage options available for Kubernetes. To make that storage the default
storage, use the commands shown in this section of the Kubernetes
documentation: Change the default StorageClass.

For Pre-provisioned environments, you define a set of nodes that already
exist. During the cluster creation process, Nutanix Image Builder on page 51
(NIB) is built into NKP and automatically runs the machine configuration
process (which NIB uses to build images for other providers) against the set
of nodes that you defined. This results in your pre-existing or pre-
provisioned nodes being configured properly.

The following command relies on the pre-provisioned cluster API infrastructure
provider to initialize the Kubernetes control plane and worker nodes on the
hosts defined in the inventory YAML previously created.

Procedure

1. This command uses the default external load balancer (LB) option.

```bash
nkp create cluster preprovisioned --cluster-name ${CLUSTER_NAME} \
--namespace ${WORKSPACE_NAMESPACE} \
--control-plane-endpoint-host <control plane endpoint host> \
--control-plane-endpoint-port <control plane endpoint port, if different than 6443>
\
--pre-provisioned-inventory-file preprovisioned_inventory.yaml \
--ssh-private-key-file <path-to-ssh-private-key> \
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-cacert=${REGISTRY_CA} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD}
```

1. Use the wait command to monitor the cluster control-plane readiness.

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=30m
```

> **Note: Depending on the cluster size, it will take a few minutes to create.**

Output:

```bash
cluster.cluster.x-k8s.io/cluster_name condition met
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

##### Manually Attach an NKP CLI Cluster to the Management Cluster (5)

Procedure

```yaml
Warning: These steps are only applicable if you do not set a WORKSPACE_NAMESPACE when creating a cluster.
If you already set a WORKSPACE_NAMESPACE, then you do not need to perform these steps since the cluster is
already attached to the workspace.
```

When you create a Managed Cluster with the NKP CLI, it attaches automatically
to the Management Cluster after a few moments. However, if you do not set a
workspace, the attached cluster will be created in the default workspace. To
ensure that the attached cluster is created in your desired workspace
namespace, follow these instructions:

1. Confirm you have your MANAGED_CLUSTER_NAME variable set with the following
   command.

```bash
echo ${MANAGED_CLUSTER_NAME}
```

1. Retrieve your kubeconfig from the cluster you have created without setting
   a workspace.

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} >
${MANAGED_CLUSTER_NAME}.conf
```

1. Note: This is only necessary if you never set the workspace of your cluster
   upon creation.

You can now either attach it in the UI, link to attaching it to workspace
through UI that was earlier, or attach your cluster to the workspace you want
in the CLI. 4. Retrieve the workspace where you want to attach the cluster.

```bash
kubectl get workspaces -A
```

1. Set the WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace-namespace>
```

1. You need to create a secret in the desired workspace before attaching the
   cluster to that workspace. Retrieve the kubeconfig secret value of your
   cluster.

```bash
kubectl -n default get secret ${MANAGED_CLUSTER_NAME}-kubeconfig -o go-
template='{{.data.value}}{{ "\n"}}'
```

1. This will return a lengthy value. Copy this entire string for a secret
   using the template below as a reference. Create a new attached-cluster-
   kubeconfig.yaml file.

```yaml
apiVersion: v1
kind: Secret
metadata:
name: <your-managed-cluster-name>-kubeconfig
labels:
cluster.x-k8s.io/cluster-name: <your-managed-cluster-name>
type: cluster.x-k8s.io/secret
data:
value: <value-you-copied-from-secret-above>
```

1. Create this secret in the desired workspace.

```bash
kubectl apply -f attached-cluster-kubeconfig.yaml --namespace
${WORKSPACE_NAMESPACE}
```

1. Create this nkpcluster object to attach the cluster to the workspace.

```bash
cat << EOF | kubectl apply -f -
apiVersion: clusters.nkp.nutanix.com/v1alpha1
kind: NKPCluster
metadata:
name: ${MANAGED_CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
capiClusterRef:
name: ${MANAGED_CLUSTER_NAME}
namespace: default
kommanderCluster:
spec:
kubeconfigRef:
name: ${MANAGED_CLUSTER_NAME}-kubeconfig
clusterRef:
capiCluster:
name: ${MANAGED_CLUSTER_NAME}
EOF
```

1. You can now view this cluster in your Workspace in the UI and you can
   confirm its status by running the below command. It may take a few minutes
   to reach "Joined" status.

```bash
kubectl get nkpclusters -A
```

If you have several Pro Clusters and want to turn one of them into a Managed
Cluster to be centrally administrated by a Management Cluster, see Platform
Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate Managed Cluster
on page 519.

### Pre-provisioned Air-gapped with GPU Installation

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

#### Pre-provisioned Air-gapped GPU: Configuring the Environment

In order to create a cluster in a Pre-provisioned Air-gapped environment with
GPU, you must first prepare the environment.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

The instructions below outline how to fulfill the requirements for using pre-
provisioned infrastructure in an air- gapped environment. In order to create a
cluster, you must first set up the environment with the necessary artifacts.
All artifacts for Pre-provisioned Air-gapped need to get onto the bastion
host. Artifacts needed by nodes must be unpacked and distributed on the
bastion before other provisioning will work in the absence of an internet
connection.

There is an air-gapped bundle available to download. In previous NKP releases,
the distro package bundles were included in the downloaded air-gapped bundle.
Currently, that air-gapped bundle contains the following artifact, with the
exception of the distro packages:

- Containerd tar file

1. Set the Artifacts directory.

The artifacts directory contains the packages and artifacts required to
configure the pre-provisioned host. 2. Download nkp-air-gapped-bundle_nkp-
version_linux_amd64.tar.gz , and extract the tar file to a local directory:

```bash
tar -xzvf nkp-air-gapped-bundle_nkp-version_linux_amd64.tar.gz -C
${ARTIFACTS_DIRECTORY}
```

1. You will need to fetch the distro packages as well as other artifacts. By
   fetching the distro packages from distro repositories, you get the latest
   security fixes available at machine image build time. 4. (Required for air-
   gapped environment) Create a package bundle.

NKP requires Operating System packages to be available in the base image.
These packages are available in the package repositories accessible over the
internet. As air-gapped environments are restricted from accessing these
repositories, you must first create a package bundle where the repositories
can be accessed. Then, transfer this bundle to an air-gapped environment to
build the OS image in an air-gapped environment.

Example command:

Setup Process

1. The bootstrap image must be extracted and loaded onto the bastion host. 2.
   Artifacts must be copied onto cluster hosts for nodes to access. 3. If using
   GPU, those artifacts must be positioned locally. 4. Registry seeded with
   images locally.

Load the Bootstrap Image

1. Assuming you have downloaded nkp-air-gapped-bundle_nkp-
   version_linux_amd64.tar.gz from the

download site mentioned above and extracted the tar file, you will load the
bootstrap. 2. Load the bootstrap image on your bastion machine:

Copy air-gapped artifacts onto cluster hosts

.

| export ARTIFACTS DIRECTORY=nkp- \_ | nkp-version | /image-artifacts/ |
| ---------------------------------- | ----------- | ----------------- |

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

- nkp create package-bundle ${; OS TYPE; } --artifacts-directory ${;
  ARTIFACTS DIRECTORY; }

| --- | --- | --- | --- | --- |

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

| docker load -i konvoy-bootstrap-image- | nkp-version | .tar |
| -------------------------------------- | ----------- | ---- |

Using the Nutanix Image Builder on page 51, you can copy the required
artifacts onto your cluster hosts.

1. Assuming you have downloaded nkp-air-gapped-bundle_nkp-
   version_linux_amd64.tar.gz , extract the tar file to a local directory: 2.
   Export the following environment variables, ensuring that all control plane
   and worker nodes are included:

```bash
export CONTROL_PLANE_1_ADDRESS="<control-plane-address-1>"
export CONTROL_PLANE_2_ADDRESS="<control-plane-address-2>"
export CONTROL_PLANE_3_ADDRESS="<control-plane-address-3>"
export WORKER_1_ADDRESS="<worker-address-1>"
export WORKER_2_ADDRESS="<worker-address-2>"
export WORKER_3_ADDRESS="<worker-address-3>"
export WORKER_4_ADDRESS="<worker-address-4>"
export SSH_USER="<ssh-user>"
export SSH_PRIVATE_KEY_FILE="<private key file>"
```

SSH_PRIVATE_KEY_FILE must be either the name of the SSH private key file in
your working directory or an absolute path to the file in your user's home
directory. 3. (Optional) Create a FIPS-compliant image:

```bash
export FIPS_ENABLED=true
```

The Nutanix Image Builder creates a FIPS-compliant OS image. For more
information, see Supported Infrastructure Operating Systems. 4. (Optional)
Upload NVIDIA GPU drivers:

Download the NVIDIA runfile for your NVIDIA driver version from the NVIDIA
download site.

Replace Path to NVIDIA driver runfile with the path to the NVIDIA driver
runfile.

The Nutanix Image Builder uploads the NVIDIA driver runfile to the target host
for GPU workload support. 5. (Optional) Specify a provider hint:

Replace aws|azure|gcp|vsphere|nutanix with the provider name when you install
provider specific utilities.

This helps the image builder install the appropriate provider specific
utilities on the host. 6. Upload the artifacts onto cluster hosts with the
following command:

```bash
./nkp upload image-artifacts \
--ssh-host ${CONTROL_PLANE_1_ADDRESS},${CONTROL_PLANE_2_ADDRESS} \
--ssh-username ${SSH_USER} \
${SSH_PRIVATE_KEY_FILE:+--ssh-private-key-file ${SSH_PRIVATE_KEY_FILE}} \
${SSH_PASSWORD:+--ssh-password ${SSH_PASSWORD}} \
${SSH_PORT:+--ssh-port ${SSH_PORT}} \
--artifacts-directory ${ARTIFACTS_DIRECTORY} \
${NVIDIA_RUNFILE:+--nvidia-runfile ${NVIDIA_RUNFILE}} \
${PROVIDER:+--provider ${PROVIDER}} \
${FIPS_ENABLED:+--fips}
```

#### Pre-provisioned Air-gapped GPU: Loading the Registry

About this task

The complete NKP air-gapped bundle is needed for an air-gapped environment but
can also be used in a non-air-gapped environment. The bundle contains all the
NKP components needed for an air-gapped environment installation and also for
using a local registry in a non-air-gapped environment.

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

| export NVIDIA RUNFILE= \_ | Path to NVIDIA driver runfile | Col3 |
| ------------------------- | ----------------------------- | ---- |

| export PROVIDER= | aws | azure | gcp | vsphere | nutanix | Col3 |
| ---------------- | --- | ----- | --- | ------- | ------- | ---- |

> **Warning: If you do not already have a local registry set up, see
> Registry Mirror Tools on page 1028.**

If you are operating in an air-gapped environment, a local container registry
containing all the necessary installation images, including the Kommander
images, is required. This registry must be accessible from both the bastion
machine and either the AWS EC2 instances (if deploying to AWS) or other
machines that will be created for the Kubernetes cluster.

Procedure

1. If not already done in prerequisites, download the air-gapped bundle nkp-
   air-gapped-bundle_nkp-

version_linux_amd64.tar.gz , and extract the tar file to a local directory. 2.
The directory structure after extraction can be accessed in subsequent steps
using commands to access files from different directories. EX: For the
bootstrap cluster, change your directory to the nkp-`<version>` directory,
similar to the example below, depending on your current location 3. Set an
environment variable with your registry address and any other needed variables
using this command.

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
export REGISTRY_CA=<path to the cacert file on the bastion>
```

1. Execute the following command to load the air-gapped image bundle into your
   private registry using any of the relevant flags to apply the variables
   above.

```bash
nkp push bundle --bundle ./container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
Note: It might take some time to push all the images to your image registry, depending on the network
performance between the machine you are running the script on and the registry.
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by
setting the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

##### Kommander Load Images (3)

Procedure

If you are operating in an air-gapped environment, a local container registry
containing all the necessary installation images, including the Kommander
images is required. For instructions on how to push the necessary images to
this registry, see the steps below.

##### Load Images to your Private Registry - Kommander (3)

Procedure

Load the Kommander component images to your private registry using the command.

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

| tar -xzvf nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ---------------------------------- | ----------- | ------------------------ |

| cd nkp- | nkp-version | Col3 |
| ------- | ----------- | ---- |

For the air-gapped kommander image bundle, run the command below. Run the
following command to load the image bundle.

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-nkp-version.tar --
to-registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
```

#### Pre-provisioned Air-gapped GPU: Nodepool Secrets and Overrides

About this task

For pre-provisioned environments, NKP has introduced the nvidia-runfile flag
for Air-gapped Pre-provisioned environments. If the NVIDIA runfile installer
has not been downloaded, then retrieve and install the download first by
running the following command. The first line in the command below downloads
and installs the runfile and the second line places it in the artifacts
directory (you must create an artifacts directory if it doesn't already
exist).

> **Note:**

```bash
curl -O https://download.nvidia.com/XFree86/Linux-x86_64/580.126.18/NVIDIA-
Linux-x86_64-580.126.18.run mv NVIDIA-Linux-x86_64-580.126.18.run artifacts
```

Procedure

1. Create the secret that the GPU node pool uses.

Example output of a file named overrides/nvidia.yaml.

```bash
gpu:
types:
- nvidia
build_name_extra: "-nvidia"
```

1. Create a secret on the bootstrap cluster that is populated from the above
   file. We will name it

```bash
${CLUSTER_NAME}-user-overrides
kubectl create secret generic ${CLUSTER_NAME}-user-overrides --from-
file=overrides.yaml=overrides/nvidia.yaml
```

1. Create an inventory and nodepool with the instructions below and use the
   ${CLUSTER_NAME}-user-overrides secret.

a. Create an inventory object that has the same name as the node pool you're
creating and the details of the pre- provisioned machines that you want to add
to it. For example, to create a node pool named gpu-nodepool an inventory
named gpu-nodepool must be present in the same namespace.

```yaml
apiVersion: infrastructure.cluster.konvoy.d2iq.io/v1alpha1
kind: PreprovisionedInventory
metadata:
name: ${MY_NODEPOOL_NAME}
spec:
hosts:
- address: ${IP_OF_NODE}
sshConfig:
port: 22
user: ${SSH_USERNAME}
privateKeyRef:
name: ${NAME_OF_SSH_SECRET}
namespace: ${NAMESPACE_OF_SSH_SECRET}
```

b. (Optional) If your pre-provisioned machines have overrides, you must create
a secret that includes all of the overrides you want to provide in one file.
Create an override secret using the instructions detailed on this page.

c. Once the PreprovisionedInventory object and overrides are created, create a
node pool.

```bash
nkp create nodepool preprovisioned -c ${MY_CLUSTER_NAME} ${MY_NODEPOOL_NAME} --
override-secret-name ${MY_OVERRIDE_SECRET}
Note: Advanced users can use a combination of the --dry-run and --output=yaml or --output-
directory=<existing-directory> flags to get a complete set of node pool objects to modify locally
or store in version control.
Note: For more information regarding this flag or others, see the nkp create node pool section of the
documentation for either cluster or nodepool and select your provider.
```

#### Pre-provisioned Air-gapped GPU: Defining the Infrastructure

About this task

NKP needs to know how to access your cluster hosts. This is done using
inventory resources. For initial cluster creation, you must define a control
plane and at least one worker pool.

This procedure sets the necessary environment variables.

Procedure

1. Export the following environment variables, ensuring that all control plane
   and worker nodes are included:

```bash
export CONTROL_PLANE_1_ADDRESS="<control-plane-address-1>"
export CONTROL_PLANE_2_ADDRESS="<control-plane-address-2>"
export CONTROL_PLANE_3_ADDRESS="<control-plane-address-3>"
export WORKER_1_ADDRESS="<worker-address-1>"
export WORKER_2_ADDRESS="<worker-address-2>"
export WORKER_3_ADDRESS="<worker-address-3>"
export WORKER_4_ADDRESS="<worker-address-4>"
export SSH_USER="<ssh-user>"
export SSH_PRIVATE_KEY_SECRET_NAME="$CLUSTER_NAME-ssh-key"
```

1. Use the following template to help you define your infrastructure. The
   environment variables that you set in the previous step automatically
   replace the variable names when the inventory YAML file is created.

```bash
cat <<EOF > preprovisioned_inventory.yaml
---
apiVersion: infrastructure.cluster.konvoy.d2iq.io/v1alpha1
kind: PreprovisionedInventory
metadata:
name: $CLUSTER_NAME-control-plane
namespace: default
labels:
cluster.x-k8s.io/cluster-name: $CLUSTER_NAME
clusterctl.cluster.x-k8s.io/move: ""
spec:
hosts:
# Create as many of these as needed to match your infrastructure (6)
# Note that the command-line parameter--control-plane-replicas determines how (2)
many control plane nodes will actually be used.
#
- address: $CONTROL_PLANE_1_ADDRESS
- address: $CONTROL_PLANE_2_ADDRESS
- address: $CONTROL_PLANE_3_ADDRESS
sshConfig:
port: 22
# This is the username used to connect to your infrastructure. This user must be (6)
root or
# have the ability to use sudo without a password (6)
user: $SSH_USER
privateKeyRef:
# This is the name of the secret you created in the previous step. It must (6)
exist in the same
# namespace as this inventory object. (6)
name: $SSH_PRIVATE_KEY_SECRET_NAME
namespace: default
---
apiVersion: infrastructure.cluster.konvoy.d2iq.io/v1alpha1
kind: PreprovisionedInventory
metadata:
name: $CLUSTER_NAME-md-0
namespace: default
labels:
cluster.x-k8s.io/cluster-name: $CLUSTER_NAME
clusterctl.cluster.x-k8s.io/move: ""
spec:
hosts:
- address: $WORKER_1_ADDRESS
- address: $WORKER_2_ADDRESS
- address: $WORKER_3_ADDRESS
- address: $WORKER_4_ADDRESS
sshConfig:
port: 22
user: $SSH_USER
privateKeyRef:
name: $SSH_PRIVATE_KEY_SECRET_NAME
namespace: default
EOF
```

#### Pre-provisioned Air-gapped GPU: Defining the Control Plane Endpoint

Define the control plane endpoint for your cluster and the connection
mechanism. A control plane needs to have three, five, or seven nodes so it can
remain available if one or more nodes fail. A control plane with one node is
not for production use.

In addition, the control plane needs an endpoint that remains available if
some nodes fail.

```bash
-------- cp1.example.com:6443
|
lb.example.com:6443 ---------- cp2.example.com:6443
|
-------- cp3.example.com:6443
```

In this example, the control plane endpoint host is lb.example.com, and the
control plane endpoint port is 6443. The control plane nodes are
cp1.example.com, cp2.example.com, and cp3.example.com. The port of each API
server is 6443.

Select your Connection Mechanism

A virtual IP is the address that the client uses to connect to the service. A
load balancer is a device that distributes the client connections to the
backend servers. Before you create a new NKP cluster, choose an external load
balancer (LB) or virtual IP.

- External load balancer

It is recommended that an external load balancer be the control plane
endpoint. To distribute request load among the control plane machines,
configure the load balancer to send requests to all the control plane
machines. Configure the load balancer to send requests only to control plane
machines that are responding to API requests.

- Built-in virtual IP

If an external load balancer is not available, use the built-in virtual IP.
The virtual IP is not a load balancer; it does not distribute request load
among the control plane machines. However, if the machine receiving requests
does not respond to them, the virtual IP automatically moves to another
machine.

Single-Node Control Plane

> **Caution: Do not use a single-node control plane in a production cluster.**

A control plane with one node can use its single node as the endpoint, so you
will not require an external load
balancer, or a built-in virtual IP. At least one control plane node must
always be running. Therefore, to upgrade a
cluster with one control plane node, a spare machine must be available in the
control plane inventory. This machine is
used to provision the new node before the old node is deleted. When the API
server endpoints are defined, you can create
the cluster using the link in the Next Step below.

```yaml
Note: Modify Control Plane Audit logs settings using the information contained in the page Configure the Control
Plane.
```

Known Limitations

The control plane endpoint port is also used as the API server port on each
control plane machine. The default port is 6443. Before you create the
cluster, ensure the port is available for use on each control plane machine.

#### Pre-provisioned Air-gapped GPU: Creating a Management Cluster

About this task

> **Note:**

If your cluster is air-gapped or you have a local registry, you must provide
additional arguments when creating the cluster. These tell the cluster where
to locate the local registry to use by defining the URL.

```bash
export REGISTRY_URL=<https/http>://<registry-address>:<registry-port>
export REGISTRY_CA=<path to the CA on the bastion>
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
```

- REGISTRY_URL: the address of an existing registry accessible in the VPC that
  the new cluster nodes will be configured to use a mirror registry when
  pulling images.
- REGISTRY_CA: (optional) the path on the bastion machine to the registry CA.
  NKP will configure the cluster nodes to trust this CA. This value is only
  needed if the registry is using a self-signed certificate and the AMIs are
  not already configured to trust this CA.
- REGISTRY_USERNAME: optional, set to a user that has pull access to this
  registry.
- REGISTRY_PASSWORD: optional if the username is not set.

Create a Cluster with GPU AMI

If a custom AMI was created using Nutanix Image Builder, the custom ami id is
printed and written to packer.pkr.hcl.

To use the built ami with NKP, specify it with the --ami flag when calling
cluster create.

For GPU Steps in Pre-provisioned section of the documentation to use the
overrides/nvidia.yaml.

Additional helpful information can be found in the NVIDIA Device Plug-in for
Kubernetes instructions and the Installation Guide of Supported Platforms.

```yaml
Warning: Before you create a new NKP cluster below, choose an external load balancer (LB) or virtual IP and use the
corresponding nkp create cluster command.
```

Name Your Cluster

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if the
name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

By default, the control-plane Nodes will be created in three different zones.
However, the default worker nodes will reside in a single availability zone.
You may create additional node pools in other availability zones with the nkp
create nodepool command.

Follow these steps:

Procedure

1. Give your cluster a unique name suitable for your environment.
2. Set the environment variable: export CLUSTER_NAME=`<cluster_name>`

What to do next

Create an air-gapped Kubernetes Cluster

Before you create a new NKP cluster below, you may choose an external load
balancer or virtual IP and use the corresponding nkp create cluster command
example from that page in the docs from the links below. Other customizations
are available, but require different flags during nkp create cluster command
also. Refer to Pre- provisioned Cluster Creation Customization Choices for
more cluster customizations.

When you create a new NKP cluster below, choose an external load balancer (LB)
or virtual IP and use the corresponding nkp create cluster command.

In a pre-provisioned environment, use the Kubernetes CSI and third party
drivers for local volumes and other storage devices in your data center.

After disabling have defined the infrastructure and control plane endpoints,
you can proceed to create the cluster by following these steps to create a new
pre-provisioned cluster.

```yaml
Warning: NKP uses local static provisioner as the default storage provider for a pre-provisioned environment.
However, localvolumeprovisioner is not suitable for production use. Use Kubernetes CSI compatible
storage that is suitable for production.
```

After disabling localvolumeprovisioner, you can choose from any of the storage
options available for Kubernetes. To make that storage the default storage,
use the commands shown in this section of the Kubernetes documentation:
Changing the Default Storage Class

For Pre-provisioned environments, you define a set of nodes that already
exist. During the cluster creation process, Nutanix Image Builder (NIB) is
built into NKP and automatically runs the machine configuration process (which
NIB uses to build images for other providers) against the set of nodes that
you defined. This results in your pre-existing or pre-provisioned nodes being
configured properly.

The following command relies on the pre-provisioned cluster API infrastructure
provider to initialize the Kubernetes control plane and worker nodes on the
hosts defined in the inventory.

The create cluster command below includes the --self-managed flag. A self-
managed cluster refers to one in which the CAPI resources and controllers that
describe and manage it are running on the same cluster they are managing.

1. Execute this command to create a cluster with a GPU AMI using the default
   external load balancer option:

```bash
nkp create cluster preprovisioned --cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host <control plane endpoint host> \
--control-plane-endpoint-port <control plane endpoint port, if different than 6443>
\
--pre-provisioned-inventory-file preprovisioned_inventory.yaml \
--ssh-private-key-file <path-to-ssh-private-key> \
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-cacert=${REGISTRY_CA} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD} \
--self-managed
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

1. ALTERNATIVE Virtual IP - if you don't have an external LB, and want to use
   a VIRTUAL IP provided by

kube-vip, specify these flags example below:

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host 196.168.1.10 \
--virtual-ip-interface eth1
```

The output from this command is shortened here for reading clarity, but should
start like this:

```bash
Generating cluster resources
cluster.cluster.x-k8s.io/cluster_name created
cont.........
```

1. Create the node pool after cluster creation:

```bash
nkp create nodepool aws -c ${CLUSTER_NAME} \
--instance-type p2.xlarge \
--ami-id=${AMI_ID_FROM_NIB} \
--replicas=1 ${NODEPOOL_NAME} \
--kubeconfig=${CLUSTER_NAME}.conf
```

1. Use the wait command to monitor the cluster control-plane readiness:

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=30m
```

Output:

```bash
cluster.cluster.x-k8s.io/cluster_name condition met
```

> **Note: Depending on the cluster size, it will take a few minutes to create.**

When the command completes, you will have a running Kubernetes cluster! For
bootstrap and custom YAML cluster creation, refer to the Additional
Infrastructure Customization section of the documentation for Pre-provisioned:
Pre- provisioned Infrastructure

Use this command to get the Kubernetes kubeconfig for the new cluster and
proceed to installing the NKP Kommander UI:

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
Note: If changing the Calico encapsulation, Nutanix recommends changing it after cluster creation, but before
production.
```

Audit Logs To modify Control Plane Audit logs settings using the information
contained in the page Configure the Control Plane.

Further Steps For more customized cluster creation, access the Pre-Provisioned
Additional Configurations section, for custom flags, and more that specify the
secret as part of the create cluster command. If these are not specified, the
overrides for your nodes will not be applied.

Cluster Verification If you want to monitor or verify the installation of your
clusters, refer to: Cluster and NKP Installation Verification on page 1039 and
Installing NKP on page 43.

#### Pre-provisioned Air-gapped GPU: Configuring MetalLB

Choose one of the following two protocols you want to use to announce service
IPs. If your environment is not currently equipped with a load balancer, you
can use MetalLB. Otherwise, your own load balancer will work, and you can
continue the installation process with Pre-provisioned Air-gapped GPU:
Installing Kommander on page 160. To use MetalLB, create MetalLB custom
resources for your Pre-provisioned infrastructure. MetalLB uses one of two
protocols for exposing Kubernetes services:

- Layer 2, with Address Resolution Protocol (ARP)
- Border Gateway Protocol (BGP)

Select one of the following procedures to create your MetalLB manifest for
further editing.

Layer 2 Configuration

Layer 2 mode is the simplest to configure: in many cases, you don't need any
protocol-specific configuration, only IP addresses.

Layer 2 mode does not require the IPs to be bound to the network interfaces of
your worker nodes. It works by responding to ARP requests on your local
network directly and give the machine's MAC address to clients.

- MetalLB IP address ranges or CIDRs needs to be within the node's primary
  network subnet.
- MetalLB IP address ranges or CIDRs and node subnets must not conflict with
  the Kubernetes cluster pod and service subnets.

For example, the following configuration gives MetalLB control over IPs from
192.168.1.240 to 192.168.1.250, and configures Layer 2 mode:

The following values are generic; enter your specific values into the fields
where applicable.

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
name: default
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

BGP Configuration

For a basic configuration featuring one BGP router and one IP address range,
you need four pieces of information:

- The router IP address that MetalLB needs to connect to.
- The router's autonomous systems (AS) number.
- The AS number MetalLB to be used.
- An IP address range is expressed as a Classless Inter-Domain Routing (CIDR)
  prefix.

As an example, if you want to give MetalLB the range 192.168.10.0/24 and AS
number 64500, and connect it to a router at 10.0.0.1 with AS number 64501,
your configuration will look like this:

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
name: default
namespace: metallb-system
spec:
myASN: 64500
peerASN: 64501
peerAddress: 10.0.0.1
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.10.0/24
---
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
name: example
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

#### Pre-provisioned Air-gapped GPU: Installing Kommander

About this task

Once you have installed the component of NKP, you will continue with the
installation of the Kommander component that will bring up the UI dashboard.

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

Prerequisites:

- Ensure you have reviewed all Prerequisites for Install.
- Ensure you have a default storage class. For more information, see Default
  StorageClass on page 980.
- Ensure you have loaded all the necessary images for your configuration. See:
  Load the Images into Your Registry: Air-gapped Environments.
- Note the name of the cluster where you want to install Kommander. If you do
  not know the cluster name, use kubectl get nkpclusters -A to display and
  find it.

Create your Kommander Installation Configuration File

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} >> ${CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

```bash
nkp install kommander --init > kommander.yaml
```

1. Edit the installer file to include configuration overrides for the rook-
   ceph-cluster. NKP's default configuration
   ships Ceph with PersistentVolumeClaim (PVC) based storage which requires your
   CSI provider to support PVC with type
   volumeMode: Block. As this is not possible with the default local static
   provisioner, you can install Ceph in host
   storage mode. You can choose whether Ceph's object storage daemon (osd) pods
   can consume all or just some of the devices
   on your nodes. Include one of the following Overrides.

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

1. (Optional) Customize your kommander.yaml. Some options include custom
   domains and certificates, HTTP proxy, and external load balancer.

##### Enabling GPU Resources (2)

Procedure

Enable NVIDIA platform services in the same kommander.yamlfile. for GPU
resources.

```bash
apps:
nvidia-gpu-operator:
enabled: true
```

##### Installing Kommander (4)

Procedure

Use the customized kommander.yaml to install NKP.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

#### Pre-provisioned Air-gapped GPU: Verifying your Installation and UI Log in

About this task

After you build the cluster and you install Kommander, verify your
installation. It waits for all applications to be ready by default.

```yaml
Note: If the Kommander installation fails or you wish to reconfigure applications, you can rerun the install command
to retry the installation.
```

Procedure

Check the installation status:

```bash
kubectl -n kommander wait --for condition=Ready helmreleases --all --timeout 15m
```

> **Note: If you prefer the CLI to not wait for all applications to become
> ready, you can set the --wait=false flag.**

The first wait for each of the helm charts to reach their Ready condition,
eventually resulting in an output resembling below:

```bash
helmrelease.helm.toolkit.fluxcd.io/centralized-grafana condition met
helmrelease.helm.toolkit.fluxcd.io/dex condition met
helmrelease.helm.toolkit.fluxcd.io/dex-k8s-authenticator condition met
helmrelease.helm.toolkit.fluxcd.io/fluent-bit condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-logging condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-loki condition met
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

##### Failed HelmReleases (5)

Procedure

If an application fails to deploy, check the status of a HelmRelease using the
command kubectl -n kommander get helmrelease `<HELMRELEASE_NAME>`

If you find any HelmReleases in a "broken" release state, such as "exhausted"
or "another rollback/release in progress", trigger a reconciliation of the
HelmRelease using the commands.

```bash
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": true}]'
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": false}]'
```

###### Logging In To the UI (4)

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
index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}{{end}}/NKP/kommander/
dashboard{{ "\n"}}'
```

Use these static credentials only to configure an external identity provider.
For more information, see Identity Providers. Treat them as backup
credentials, not for regular UI access.

a. Rotate the dashboard password:

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

b. Retrieve the new dashboard credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

For more information, see Rotating the NKP Dashboard Password on page 308.

You can perform the following operations on identity providers:

- Create an identity provider
- Temporarily disable an identity provider
- Create groups

What to do next

Dashboard UI Functions

After installing the component and building a cluster as well as successfully
installing Kommander and logging into the UI, you are now ready to customize
configurations. For more information, Cluster Operations Management. The
majority of the customization such as attaching clusters and deploying
applications takes place in the dashboard or the NKP UI.

#### Pre-provisioned Air-gapped GPU: Creating Managed Clusters Using the NKP CLI

About this task

After initial cluster creation, you have the ability to create additional
clusters from the CLI. In a previous step, the new cluster was created as
Self-managed which allows it to be a Management cluster or a stand alone
cluster. Subsequent new clusters are not self-managed as they will likely be
Managed or Attached clusters to this Management Cluster.

```yaml
Warning: When creating managed clusters, do not create and move CAPI cluster objects or install the Kommander
component. Those tasks are only done on Management clusters.
```

Your new managed cluster must be part of a workspace under a management
cluster. To make the new managed cluster a part of a workspace, set that
workspace's environment variable.

Procedure

1. If you have an existing Workspace name, run this command to find the name.

> **Note: If you need to create a new Workspace, follow the instructions to
> Create a New Workspace**

```bash
kubectl get workspace -A
```

1. When you have the Workspace name, set the WORKSPACE_NAMESPACE environment
   variable.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

##### Name Your Cluster (6)

About this task

Each cluster must have an original name.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if the
name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

By default, the control-plane Nodes will be created in 3 different zones.
However, the default worker Nodes will reside in a single Availability Zone.
You may create additional node pools in other Availability Zones with the nkp
create nodepool command.

Perform both steps to name the cluster:

Procedure

1. Give your cluster a unique name suitable for your environment.
2. Set the environment variable using the command .

```bash
export CLUSTER_NAME=<cluster_name>
```

###### Create a Cluster with GPU AMI (2)

Procedure

- If a custom AMI was created using Nutanix Image Builder, use the --ami flag.
  The custom ami id is printed and written to ./manifest.json. To use the
  built ami with NKP, specify it with the --ami flag when calling cluster
  create in Step 1 in the next section where you create your Kubernetes
  cluster.

##### Create a Kubernetes Cluster (6)

About this task

After you have defined the infrastructure and control plane endpoints, you can
proceed to create the cluster by following these steps to create a new pre-
provisioned cluster.

This process creates a self-managed cluster that can be used as the management
third-party cluster.

```yaml
Tip: Before you create a new NKP cluster below, choose an external load balancer (LB) or virtual IP and use the
corresponding nkp create cluster command. For more information, see Pre-provisioned: Built-in Virtual
IP on page 782.
```

In a Pre-provisioned environment, use the Kubernetes CSI and third party
drivers for local volumes and other storage devices in your data center.

```yaml
Warning: NKP uses local static provisioners as the Default Storage Providers on page 34 for a pre-provisioned
environment. However, localvolumeprovisioner is not suitable for production use. Use Kubernetes CSI
compatible storage that is suitable for production.
```

After disabling localvolumeprovisioner, you can choose from any of the storage
options available for Kubernetes. To make that storage the default storage,
use the commands shown in this section of the Kubernetes documentation: Change
or Manage Multiple StorageClasses on page 37

For Pre-provisioned environments, you define a set of nodes that already
exist. During the cluster creation process, Nutanix Image Builder (NIB) is
built into NKP and automatically runs the machine configuration process (which
NIB uses to build images for other providers) against the set of nodes that
you defined. This results in your pre-existing or pre-provisioned nodes being
configured properly. For more information, see Nutanix Image Builder on page 51.

The following command relies on the pre-provisioned cluster API infrastructure
provider to initialize the Kubernetes control plane and worker nodes on the
hosts defined in the inventory YAML previously created.

Procedure

1. This command uses the default external load balancer (LB) option.

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--namespace ${WORKSPACE_NAMESPACE} \
--control-plane-endpoint-host <control plane endpoint host> \
--control-plane-endpoint-port <control plane endpoint port, if different than 6443>
\
--pre-provisioned-inventory-file preprovisioned_inventory.yaml \
--ssh-private-key-file <path-to-ssh-private-key> \
--registry-mirror-url=${_REGISTRY_URL} \
--registry-mirror-cacert=${_REGISTRY_CA} \
--registry-mirror-username=${_REGISTRY_USERNAME} \
--registry-mirror-password=${_REGISTRY_PASSWORD}
```

1. Use the wait command to monitor the cluster control-plane readiness.

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=30m
```

> **Note: NOTE: Depending on the cluster size, it will take a few minutes to
> create.**

```bash
cluster.cluster.x-k8s.io/cluster_name condition met
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

##### Manually Attach an NKP CLI Cluster to the Management Cluster (6)

Procedure

```yaml
Warning: These steps are only applicable if you do not set a WORKSPACE_NAMESPACE when creating a cluster.
If you already set a WORKSPACE_NAMESPACE, then you do not need to perform these steps since the cluster is
already attached to the workspace.
```

When you create a Managed Cluster with the NKP CLI, it attaches automatically
to the Management Cluster after a few moments. However, if you do not set a
workspace, the attached cluster will be created in the default workspace. To
ensure that the attached cluster is created in your desired workspace
namespace, follow these instructions:

1. Confirm you have your MANAGED_CLUSTER_NAME variable set with the following
   command.

```bash
echo ${MANAGED_CLUSTER_NAME}
```

1. Retrieve your kubeconfig from the cluster you have created without setting
   a workspace.

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} >
${MANAGED_CLUSTER_NAME}.conf
```

1. Note: This is only necessary if you never set the workspace of your cluster
   upon creation.

You can now either attach it in the UI, link to attaching it to the workspace
through earlier UI, or attach your cluster to the workspace you want in the
CLI. 4. Retrieve the workspace where you want to attach the cluster.

```bash
kubectl get workspaces -A
```

1. Set the WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace-namespace>
```

1. You need to create a secret in the desired workspace before attaching the
   cluster to that workspace. Retrieve the kubeconfig secret value of your
   cluster.

```bash
kubectl -n default get secret ${MANAGED_CLUSTER_NAME}-kubeconfig -o go-
template='{{.data.value}}{{ "\n"}}'
```

1. This will return a lengthy value. Copy this entire string for a secret
   using the template below as a reference. Create a new attached-cluster-
   kubeconfig.yaml file.

```yaml
apiVersion: v1
kind: Secret
metadata:
name: <your-managed-cluster-name>-kubeconfig
labels:
cluster.x-k8s.io/cluster-name: <your-managed-cluster-name>
type: cluster.x-k8s.io/secret
data:
value: <value-you-copied-from-secret-above>
```

1. Create this secret in the desired workspace.

```bash
kubectl apply -f attached-cluster-kubeconfig.yaml --namespace
${WORKSPACE_NAMESPACE}
```

1. Create this nkpcluster object to attach the cluster to the workspace.

```bash
cat << EOF | kubectl apply -f -
apiVersion: clusters.nkp.nutanix.com/v1alpha1
kind: NKPCluster
metadata:
name: ${MANAGED_CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
capiClusterRef:
name: ${MANAGED_CLUSTER_NAME}
namespace: default
kommanderCluster:
spec:
kubeconfigRef:
name: ${MANAGED_CLUSTER_NAME}-kubeconfig
clusterRef:
capiCluster:
name: ${MANAGED_CLUSTER_NAME}
EOF
```

1. You can now view this cluster in your Workspace in the UI, and you can
   confirm its status by running the command below. It might take a few minutes
   to reach "Joined" status.

```bash
kubectl get nkpclusters -A
```

If you have several Pro Clusters and want to turn one of them into a Managed
Cluster to be centrally administrated by a Management Cluster, see Platform
Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate Managed Cluster
on page 519.

## AWS Installation Options

For information on how to install NKP on AWS Infrastructure, see Install
Nutanix Kubernetes Platform on AWS Infrastructure on page 814.

## EKS Installation Options

For an environment that is on the EKS Infrastructure, install options based on
those environment variables are provided for you in this location.

Remember, there are always more options for custom YAML in the Custom
Installation and Additional Infrastructure Tools section, but this will get
you operative in the most common scenarios.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

```yaml
Note: An EKS cluster cannot be a Management or a Pro cluster. For more information, see NKP Concepts and
Terms on page 18. To install NKP on your EKS cluster, first ensure you have a Management cluster with NKP and the
Kommander component installed, that handles the lifecycle of your EKS cluster.
```

For a list of all the NKP supported environment combinations, see Supported
Infrastructure Operating Systems on page 12.

### EKS Installation

This installation provides instructions to install NKP in an AWS non-air-
gapped environment.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

```yaml
Note: Ensure that the KUBECONFIG environment variable is set to the Management cluster by running export
KUBECONFIG=<Management_cluster_kubeconfig>.conf.
```

AWS Prerequisites

Before you begin using Konvoy with AWS, you must:

1. A Management cluster with the Kommander component installed. 2. You have a
   valid AWS account with credentials configured that can manage CloudFormation
   Stacks, IAM Policies, and IAM Roles. 3. You will need to have the AWS CLI
   utility installed. 4. Install aws-iam-authenticator. This binary is used to
   access your cluster using kubectl.

```yaml
Note: An EKS cluster cannot be a Management or Pro cluster. To install NKP on your EKS cluster, first, ensure
you have a Management cluster with NKP and the Kommander component installed that handles the life cycle of your
EKS cluster.
```

In order to install Kommander, you need to have CAPI components, cert-manager,
etc on a self-managed cluster. The CAPI components mean you can control the
life cycle of the cluster, and other clusters. However, because EKS is semi-
managed by AWS, the EKS clusters are under AWS control and don't have those
components. Therefore, Kommander will not be installed and these clusters will
be attached to the management cluster.

### EKS: Minimal User Permission for Cluster Creation

The following is a CloudFormation stack which adds a policy named eks-
bootstrapper to manage EKS cluster to the nkp-bootstrapper-role created by the
CloudFormation stack for AWS in the Minimal Permissions and Role to Create
Cluster section.

Consult the Leveraging the Role section for an example of how to use this role
and how a system administrator wants to expose using the permissions.

EKS CloudFormation Stack:

> **Note: If your role is not named nkp-bootstrapper-role change the
> parameter on line 6 of the file.**

```yaml
AWSTemplateFormatVersion: 2010-09-09
Parameters:
existingBootstrapperRole:
Type: CommaDelimitedList
Description: 'Name of existing minimal role you want to add to add EKS cluster
management permissions to'
Default: NKP-bootstrapper-role
Resources:
EKSMinimumPermissions:
Properties:
Description: Minimal user policy to manage eks clusters
ManagedPolicyName: eks-bootstrapper
PolicyDocument:
Statement:
- Action:
- 'ssm:GetParameter'
Effect: Allow
Resource:
- 'arn:*:ssm:*:*:parameter/aws/service/eks/optimized-ami/*'
- Action:
- 'iam:CreateServiceLinkedRole'
Condition:
StringLike:
'iam:AWSServiceName': eks.amazonaws.com
Effect: Allow
Resource:
- >-
arn:*:iam::*:role/aws-service-role/eks.amazonaws.com/
AWSServiceRoleForAmazonEKS
- Action:
- 'iam:CreateServiceLinkedRole'
Condition:
StringLike:
'iam:AWSServiceName': eks-nodegroup.amazonaws.com
Effect: Allow
Resource:
- >-
arn:*:iam::*:role/aws-service-role/eks-nodegroup.amazonaws.com/
AWSServiceRoleForAmazonEKSNodegroup
- Action:
- 'iam:CreateServiceLinkedRole'
Condition:
StringLike:
'iam:AWSServiceName': eks-fargate.amazonaws.com
Effect: Allow
Resource:
- >-
arn:aws:iam::*:role/aws-service-role/eks-fargate-pods.amazonaws.com/
AWSServiceRoleForAmazonEKSForFargate
- Action:
- 'iam:GetRole'
- 'iam:ListAttachedRolePolicies'
Effect: Allow
Resource:
- 'arn:*:iam::*:role/*'
- Action:
- 'iam:GetPolicy'
Effect: Allow
Resource:
- 'arn:aws:iam::aws:policy/AmazonEKSClusterPolicy'
- Action:
- 'eks:DescribeCluster'
- 'eks:ListClusters'
- 'eks:CreateCluster'
- 'eks:TagResource'
- 'eks:UpdateClusterVersion'
- 'eks:DeleteCluster'
- 'eks:UpdateClusterConfig'
- 'eks:UntagResource'
- 'eks:UpdateNodegroupVersion'
- 'eks:DescribeNodegroup'
- 'eks:DeleteNodegroup'
- 'eks:UpdateNodegroupConfig'
- 'eks:CreateNodegroup'
- 'eks:AssociateEncryptionConfig'
- 'eks:ListIdentityProviderConfigs'
- 'eks:AssociateIdentityProviderConfig'
- 'eks:DescribeIdentityProviderConfig'
- 'eks:DisassociateIdentityProviderConfig'
Effect: Allow
Resource:
- 'arn:*:eks:*:*:cluster/*'
- 'arn:*:eks:*:*:nodegroup/*/*/*'
- Action:
- 'ec2:AssociateVpcCidrBlock'
- 'ec2:DisassociateVpcCidrBlock'
- 'eks:ListAddons'
- 'eks:CreateAddon'
- 'eks:DescribeAddonVersions'
- 'eks:DescribeAddon'
- 'eks:DeleteAddon'
- 'eks:UpdateAddon'
- 'eks:TagResource'
- 'eks:DescribeFargateProfile'
- 'eks:CreateFargateProfile'
- 'eks:DeleteFargateProfile'
Effect: Allow
Resource:
- '*'
- Action:
- 'iam:PassRole'
Condition:
StringEquals:
'iam:PassedToService': eks.amazonaws.com
Effect: Allow
Resource:
- '*'
- Action:
- 'kms:CreateGrant'
- 'kms:DescribeKey'
Condition:
'ForAnyValue:StringLike':
'kms:ResourceAliases': alias/cluster-api-provider-aws-*
Effect: Allow
Resource:
- '*'
Version: 2012-10-17
Roles: !Ref existingBootstrapperRole
Type: 'AWS::IAM::ManagedPolicy'
```

To create the resources in the cloudformation stack, copy the contents above
into a file. Before executing the following command, replace MYFILENAME.yaml
and MYSTACKNAME with the intended values for your system when running the
command to create the AWS cloudformation stack:

```bash
aws cloudformation create-stack --template-body=file://MYFILENAME.yaml --stack-
name=MYSTACKNAME --capabilities CAPABILITY_NAMED_IAM
```

### EKS: Cluster IAM Policies and Roles

Prerequisites from AWS:

Before you begin, ensure that you meet the following AWS prerequisites:

- The user you delegate from your role must have a minimum set of permissions.
  For more information, see User Roles and Instance Profiles.
- Create an IAM policy for the clusters in your AWS account. For more
  information, see AWS Prerequisites on page 815.

EKS IAM Artifacts

Policies:

- controllers-eks.cluster-api-provider-aws.sigs.k8s.io: Defines the actions
  required by the managed cluster to create and modify EKS clusters in the AWS
  account of the user. This role is attached to the existing control-
  plane.cluster-api-provider-aws.sigs.k8s.io.
- eks-nodes.cluster-api-provider-aws.sigs.k8s.io: Defines the actions required
  by the worker nodes of the EKS managed cluster. This role is attached to the
  existing nodes.cluster-api-provider- aws.sigs.k8s.io.

Roles:

- eks-controlplane.cluster-api-provider-aws.sigs.k8s.io - A role that is
  associated with EKS cluster control planes.

```yaml
Note: Configure the cluster identity and access management (IAM) policies and roles for Kubernetes on AWS.
After you configure, the cluster API provider for AWS (CAPA) automatically creates and configures control-
plane.cluster-api-provider-aws.sigs.k8s.io and nodes.cluster-api-provider-
aws.sigs.k8s.io roles. For more information, see AWS Prerequisites on page 815.
```

- The following CloudFormation stack defines the IAM policies and roles
  required to set up Amazon EKS clusters:

```yaml
AWSTemplateFormatVersion: 2010-09-09
Parameters:
existingControlPlaneRole:
Type: CommaDelimitedList
Description: 'Names of existing Control Plane Role you want to add to the newly
created EKS Managed Policy for AWS cluster API controllers'
Default: control-plane.cluster-api-provider-aws.sigs.k8s.io
existingNodeRole:
Type: CommaDelimitedList
Description: 'ARN of existing node IAM Role to attach the managed policy to'
Default: nodes.cluster-api-provider-aws.sigs.k8s.io
Resources:
AWSIAMManagedPolicyControllersEKS:
Properties:
Description: For the Kubernetes Cluster API Provider AWS Controllers
ManagedPolicyName: controllers-eks.cluster-api-provider-aws.sigs.k8s.io
PolicyDocument:
Statement:
- Action:
- 'ssm:GetParameter'
Effect: Allow
Resource:
- 'arn:*:ssm:*:*:parameter/aws/service/eks/optimized-ami/*'
- Action:
- 'iam:CreateServiceLinkedRole'
Condition:
StringLike:
'iam:AWSServiceName': eks.amazonaws.com
Effect: Allow
Resource:
- >-
arn:*:iam::*:role/aws-service-role/eks.amazonaws.com/
AWSServiceRoleForAmazonEKS
- Action:
- 'iam:CreateServiceLinkedRole'
Condition:
StringLike:
'iam:AWSServiceName': eks-nodegroup.amazonaws.com
Effect: Allow
Resource:
- >-
arn:*:iam::*:role/aws-service-role/eks-nodegroup.amazonaws.com/
AWSServiceRoleForAmazonEKSNodegroup
- Action:
- 'iam:CreateServiceLinkedRole'
Condition:
StringLike:
'iam:AWSServiceName': eks-fargate.amazonaws.com
Effect: Allow
Resource:
- >-
arn:aws:iam::*:role/aws-service-role/eks-fargate-pods.amazonaws.com/
AWSServiceRoleForAmazonEKSForFargate
- Action:
- 'iam:GetRole'
- 'iam:ListAttachedRolePolicies'
Effect: Allow
Resource:
- 'arn:*:iam::*:role/*'
- Action:
- 'iam:GetPolicy'
Effect: Allow
Resource:
- 'arn:aws:iam::aws:policy/AmazonEKSClusterPolicy'
- Action:
- 'eks:DescribeCluster'
- 'eks:ListClusters'
- 'eks:CreateCluster'
- 'eks:TagResource'
- 'eks:UpdateClusterVersion'
- 'eks:DeleteCluster'
- 'eks:UpdateClusterConfig'
- 'eks:UntagResource'
- 'eks:UpdateNodegroupVersion'
- 'eks:DescribeNodegroup'
- 'eks:DeleteNodegroup'
- 'eks:UpdateNodegroupConfig'
- 'eks:CreateNodegroup'
- 'eks:AssociateEncryptionConfig'
- 'eks:ListIdentityProviderConfigs'
- 'eks:AssociateIdentityProviderConfig'
- 'eks:DescribeIdentityProviderConfig'
- 'eks:DisassociateIdentityProviderConfig'
Effect: Allow
Resource:
- 'arn:*:eks:*:*:cluster/*'
- 'arn:*:eks:*:*:nodegroup/*/*/*'
- Action:
- 'ec2:AssociateVpcCidrBlock'
- 'ec2:DisassociateVpcCidrBlock'
- 'eks:ListAddons'
- 'eks:CreateAddon'
- 'eks:DescribeAddonVersions'
- 'eks:DescribeAddon'
- 'eks:DeleteAddon'
- 'eks:UpdateAddon'
- 'eks:TagResource'
- 'eks:DescribeFargateProfile'
- 'eks:CreateFargateProfile'
- 'eks:DeleteFargateProfile'
Effect: Allow
Resource:
- '*'
- Action:
- 'iam:PassRole'
Condition:
StringEquals:
'iam:PassedToService': eks.amazonaws.com
Effect: Allow
Resource:
- '*'
- Action:
- 'kms:CreateGrant'
- 'kms:DescribeKey'
Condition:
'ForAnyValue:StringLike':
'kms:ResourceAliases': alias/cluster-api-provider-aws-*
Effect: Allow
Resource:
- '*'
Version: 2012-10-17
Roles: !Ref existingControlPlaneRole
Type: 'AWS::IAM::ManagedPolicy'
AWSIAMManagedEKSNodesPolicy:
Properties:
Description: Additional Policies to nodes role to work for EKS
ManagedPolicyName: eks-nodes.cluster-api-provider-aws.sigs.k8s.io
PolicyDocument:
Statement:
- Action:
- "ec2:AssignPrivateIpAddresses"
- "ec2:AttachNetworkInterface"
- "ec2:CreateNetworkInterface"
- "ec2:DeleteNetworkInterface"
- "ec2:DescribeInstances"
- "ec2:DescribeTags"
- "ec2:DescribeNetworkInterfaces"
- "ec2:DescribeInstanceTypes"
- "ec2:DetachNetworkInterface"
- "ec2:ModifyNetworkInterfaceAttribute"
- "ec2:UnassignPrivateIpAddresses"
Effect: Allow
Resource:
- '*'
- Action:
- ec2:CreateTags
Effect: Allow
Resource:
- arn:aws:ec2:*:*:network-interface/*
- Action:
- "ec2:DescribeInstances"
- "ec2:DescribeInstanceTypes"
- "ec2:DescribeRouteTables"
- "ec2:DescribeSecurityGroups"
- "ec2:DescribeSubnets"
- "ec2:DescribeVolumes"
- "ec2:DescribeVolumesModifications"
- "ec2:DescribeVpcs"
- "eks:DescribeCluster"
Effect: Allow
Resource:
- '*'
Version: 2012-10-17
Roles: !Ref existingNodeRole
Type: 'AWS::IAM::ManagedPolicy'
AWSIAMManagedPolicyALBController:
Type: 'AWS::IAM::ManagedPolicy'
Properties:
Description: IAM policy for AWS Load Balancer Controller (ALB/NLB)
ManagedPolicyName: alb-controller.cluster-api-provider-aws.sigs.k8s.io
PolicyDocument:
Version: "2012-10-17"
Statement:
- Effect: Allow
Action:
- iam:CreateServiceLinkedRole
Resource: "*"
Condition:
StringEquals:
iam:AWSServiceName: elasticloadbalancing.amazonaws.com
- Effect: Allow
Action:
- ec2:DescribeAccountAttributes
- ec2:DescribeAddresses
- ec2:DescribeAvailabilityZones
- ec2:DescribeInternetGateways
- ec2:DescribeVpcs
- ec2:DescribeVpcPeeringConnections
- ec2:DescribeSubnets
- ec2:DescribeSecurityGroups
- ec2:DescribeInstances
- ec2:DescribeNetworkInterfaces
- ec2:DescribeTags
- ec2:GetCoipPoolUsage
- ec2:DescribeCoipPools
- ec2:GetSecurityGroupsForVpc
- ec2:DescribeIpamPools
- ec2:DescribeRouteTables
- elasticloadbalancing:DescribeLoadBalancers
- elasticloadbalancing:DescribeLoadBalancerAttributes
- elasticloadbalancing:DescribeListeners
- elasticloadbalancing:DescribeListenerCertificates
- elasticloadbalancing:DescribeSSLPolicies
- elasticloadbalancing:DescribeRules
- elasticloadbalancing:DescribeTargetGroups
- elasticloadbalancing:DescribeTargetGroupAttributes
- elasticloadbalancing:DescribeTargetHealth
- elasticloadbalancing:DescribeTags
- elasticloadbalancing:DescribeTrustStores
- elasticloadbalancing:DescribeListenerAttributes
- elasticloadbalancing:DescribeCapacityReservation
Resource: "*"
- Effect: Allow
Action:
- cognito-idp:DescribeUserPoolClient
- acm:ListCertificates
- acm:DescribeCertificate
- iam:ListServerCertificates
- iam:GetServerCertificate
- waf-regional:GetWebACL
- waf-regional:GetWebACLForResource
- waf-regional:AssociateWebACL
- waf-regional:DisassociateWebACL
- wafv2:GetWebACL
- wafv2:GetWebACLForResource
- wafv2:AssociateWebACL
- wafv2:DisassociateWebACL
- shield:GetSubscriptionState
- shield:DescribeProtection
- shield:CreateProtection
- shield:DeleteProtection
Resource: "*"
- Effect: Allow
Action:
- ec2:AuthorizeSecurityGroupIngress
- ec2:RevokeSecurityGroupIngress
Resource: "*"
- Effect: Allow
Action:
- ec2:CreateSecurityGroup
Resource: "*"
- Effect: Allow
Action:
- ec2:CreateTags
Resource: arn:aws:ec2:*:*:security-group/*
Condition:
StringEquals:
ec2:CreateAction: CreateSecurityGroup
Null:
aws:RequestTag/elbv2.k8s.aws/cluster: "false"
- Effect: Allow
Action:
- ec2:CreateTags
- ec2:DeleteTags
Resource: arn:aws:ec2:*:*:security-group/*
Condition:
Null:
aws:RequestTag/elbv2.k8s.aws/cluster: "true"
aws:ResourceTag/elbv2.k8s.aws/cluster: "false"
- Effect: Allow
Action:
- ec2:AuthorizeSecurityGroupIngress
- ec2:RevokeSecurityGroupIngress
- ec2:DeleteSecurityGroup
Resource: "*"
Condition:
Null:
aws:ResourceTag/elbv2.k8s.aws/cluster: "false"
- Effect: Allow
Action:
- elasticloadbalancing:CreateLoadBalancer
- elasticloadbalancing:CreateTargetGroup
Resource: "*"
Condition:
Null:
aws:RequestTag/elbv2.k8s.aws/cluster: "false"
- Effect: Allow
Action:
- elasticloadbalancing:CreateListener
- elasticloadbalancing:DeleteListener
- elasticloadbalancing:CreateRule
- elasticloadbalancing:DeleteRule
Resource: "*"
- Effect: Allow
Action:
- elasticloadbalancing:AddTags
- elasticloadbalancing:RemoveTags
Resource:
- arn:aws:elasticloadbalancing:*:*:targetgroup/*/*
- arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*
- arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*
Condition:
Null:
aws:RequestTag/elbv2.k8s.aws/cluster: "true"
aws:ResourceTag/elbv2.k8s.aws/cluster: "false"
- Effect: Allow
Action:
- elasticloadbalancing:AddTags
- elasticloadbalancing:RemoveTags
Resource:
- arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*
- arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*
- arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*
- arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*
- Effect: Allow
Action:
- elasticloadbalancing:ModifyLoadBalancerAttributes
- elasticloadbalancing:SetIpAddressType
- elasticloadbalancing:SetSecurityGroups
- elasticloadbalancing:SetSubnets
- elasticloadbalancing:DeleteLoadBalancer
- elasticloadbalancing:ModifyTargetGroup
- elasticloadbalancing:ModifyTargetGroupAttributes
- elasticloadbalancing:DeleteTargetGroup
- elasticloadbalancing:ModifyListenerAttributes
- elasticloadbalancing:ModifyCapacityReservation
- elasticloadbalancing:ModifyIpPools
Resource: "*"
Condition:
Null:
aws:ResourceTag/elbv2.k8s.aws/cluster: "false"
- Effect: Allow
Action:
- elasticloadbalancing:AddTags
Resource:
- arn:aws:elasticloadbalancing:*:*:targetgroup/*/*
- arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*
- arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*
Condition:
StringEquals:
elasticloadbalancing:CreateAction:
- CreateTargetGroup
- CreateLoadBalancer
Null:
aws:RequestTag/elbv2.k8s.aws/cluster: "false"
- Effect: Allow
Action:
- elasticloadbalancing:RegisterTargets
- elasticloadbalancing:DeregisterTargets
Resource: arn:aws:elasticloadbalancing:*:*:targetgroup/*/*
- Effect: Allow
Action:
- elasticloadbalancing:SetWebAcl
- elasticloadbalancing:ModifyListener
- elasticloadbalancing:AddListenerCertificates
- elasticloadbalancing:RemoveListenerCertificates
- elasticloadbalancing:ModifyRule
- elasticloadbalancing:SetRulePriorities
Resource: "*"
Roles: !Ref existingNodeRole
AWSIAMRoleEKSControlPlane:
Properties:
AssumeRolePolicyDocument:
Statement:
- Action:
- 'sts:AssumeRole'
Effect: Allow
Principal:
Service:
- eks.amazonaws.com
Version: 2012-10-17
ManagedPolicyArns:
- 'arn:aws:iam::aws:policy/AmazonEKSClusterPolicy'
RoleName: eks-controlplane.cluster-api-provider-aws.sigs.k8s.io
Type: 'AWS::IAM::Role'
```

For more information, see CloudFormation stack.

To create the resources in the CloudFormation stack, copy its contents into a
file and replace MYFILENAME.yaml and MYSTACKNAME with the intended values:

```bash
aws cloudformation create-stack --template-body=file://MYFILENAME.yaml --stack-
name=MYSTACKNAME --capabilities CAPABILITY_NAMED_IAM
```

Add EKS CSI Policy

AWS CloudFormation does not support attaching an existing IAM Policy to an
existing IAM Role. Add the necessary IAM policy to your worker instance
profile using the aws CLI:

```bash
aws iam attach-role-policy --role-name nodes.cluster-api-provider-aws.sigs.k8s.io --
policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
```

In other infrastructures, the next step is to create a custom image. However,
AWS EKS best practices discourage this approach. The Amazon EKS Optimized AMI
is the recommended way to deploy containers on EKS. Customizing the image can
disrupt autoscaling and security capabilities of EKS. Therefore, proceed
directly to creating your EKS cluster. For more information, see Amazon EKS
Optimized AMI.

### EKS: Creating an Image

AWS EKS best practices discourage building custom images. The Amazon EKS
Optimized AMI https:// docs.aws.amazon.com/eks/latest/userguide/eks-optimized-
amis.html is the preferred way to deploy containers for EKS. If the image is
customized, it breaks some of the autoscaling and security capabilities of
EKS.

### EKS: Creating an EKS Cluster

About this task

To access your cluster, use the previously installed AWS IAM authenticator
using Kubectl. For more information, see Amazon EKS. Amazon EKS uses IAM
policies and roles to provide authentication to your Kubernetes cluster.

Procedure

1. Create minimum user permissions for EKS cluster creation.

For more information, see EKS: Minimal User Permission for Cluster Creation on
page 169. 2. Create IAM policies and roles for EKS.

For more information, see EKS: Cluster IAM Policies and Roles on page 171. 3.
Export the AWS region:

```bash
export AWS_REGION=us-west-2
```

Set the region where you want to deploy the cluster. 4. Export the AWS
credentials you want to use for creating a Kubernetes cluster:

```bash
export AWS_ACCESS_KEY_ID=<aws_access_key_id>
export AWS_SECRET_ACCESS_KEY=<aws_secret_access_key>
# optional
export AWS_SESSION_TOKEN=<aws_session_token>
export AWS_PROFILE=<profile_name>
```

For more information about AWS credentials, see AWS Environment Variables.

#### Creating a Managed EKS Cluster from the CLI

About this task

If you prefer using the NKP UI, create a cluster following the steps in Create
an EKS Cluster from the NKP UI.

To create a EKS cluster, follow these steps:

Procedure

1. Set the environment variable to the name of your cluster:

```bash
export CLUSTER_NAME=<eks-example>
Note: The cluster name must only contain the characters such as a-z, 0-9, ., and -. Cluster creation fails when the
name has capital letters. For more information, see Kubernetes.
```

1. Set the kubeconfig to an existing management cluster:

```bash
export KUBECONFIG=<path to management cluster's kubeconfig>
```

The EKS cluster is a managed clusters and you must create it from a management
cluster.

Ensure that the management cluster is available in any supported
infrastructure before you proceed with cluster creation. 3. Update your AWS
credentials:

```bash
nkp update bootstrap credentials aws
```

Refresh the credentials only if you use access keys. For more information, see
AWS Prerequisites on page 815. If you use role-based authentication on a
bastion host, skip this step and continue to cluster creation. 4. (Optional)
Use an existing AWS ECR as registry mirror to pull images: For example,

```bash
export REGISTRY_MIRROR_FLAGS="
--registry-mirror-url=<ECR URL> \
--registry-mirror-username=AWS \
--registry-mirror-password=$(aws ecr get-login-password) \
"
```

You can pull images directly from AWS ECR registry or configure ECR as a
mirror to pull images. 5. To create an EKS cluster, choose one of the
following:

» Create an EKS cluster with the Kubernetes version 1.34 or later:

```bash
nkp create cluster eks \
--cluster-name=${CLUSTER_NAME} \
--kubeconfig=${KUBECONFIG} \
${REGISTRY_MIRROR_FLAGS}
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-
proxy, and --no-proxy with their values in the command to ensure it runs successfully. For more
information, see Configuring an HTTP or HTTPS Proxy on page 696.
```

» To create an EKS cluster with Kubernetes version earlier than 1.34:

```bash
nkp legacy create cluster eks \
--cluster-name=${CLUSTER_NAME} \
--kubeconfig=${KUBECONFIG} \
${REGISTRY_MIRROR_FLAGS}
```

NKP supports creating an EKS cluster with Kubernetes version 1.34 or later.
NKP deprecates creating an EKS cluster with Kubernetes version earlier than
1.34. For more information, see Supported Kubernetes Versions section in the
NKP Release Notes. 6. Check the current status of the cluster:

```bash
nkp describe cluster -c ${CLUSTER_NAME}
NAME READY SEVERITY
REASON SINCE MESSAGE
Cluster/eks-example True
10m
##ControlPlane - AWSManagedControlPlane/eks-example-control-plane True
10m
##Workers
##MachineDeployment/eks-example-md-0 True
26s
##Machine/eks-example-md-0-78fcd7c7b7-66ntt True
84s
##Machine/eks-example-md-0-78fcd7c7b7-b9qmc True
84s
##Machine/eks-example-md-0-78fcd7c7b7-v5vfq True
84s
##Machine/eks-example-md-0-78fcd7c7b7-zl6m2 True
84s
```

##### Known Limitations

About this task

Be aware of the following limitations for the current NKP version:

Procedure

- The NKP version you use to create a managed cluster must match the NKP
  version you use to delete it.
- You cannot self-manage EKS clusters.
- Cluster Verification: To monitor or verify the installation of your
  clusters, see Cluster and NKP Installation Verification on page 1039 and
  Installing NKP on page 43.

### EKS: Granting Cluster Access

About this task

You can access your cluster using AWS IAM roles in the dashboard. When you
create an EKS cluster, the IAM entity is granted system:masters permissions in
Kubernetes Role Based Access Control (RBAC) configuration.

```yaml
Note: More information about the configuration of the EKS control plane can be found on the EKS Cluster IAM
Policies and Roles page.
```

If the EKS cluster was created as a cluster using a self-managed AWS cluster
that uses IAM Instance Profiles, you will need to modify the
IAMAuthenticatorConfig field in the AWSManagedControlPlane API object to allow
other IAM entities to access the EKS managed cluster. Follow the steps below:

Procedure

1. Run the following command with your KUBECONFIG configured to select the
   self-managed cluster previously used to create the workload EKS cluster.
   Ensure you substitute ${CLUSTER_NAME} and ${CLUSTER_NAMESPACE} with their
   corresponding values for your cluster.

```bash
kubectl edit awsmanagedcontrolplane ${CLUSTER_NAME}-control-plane -n
${CLUSTER_NAMESPACE}
```

1. Edit the IamAuthenticatorConfig field with the IAM Role to the
   corresponding Kubernetes Role. In this example, the IAM role
   arn:aws:iam::111122223333:role/PowerUser is granted the cluster role
   system:masters. Note that this example uses example AWS resource ARNs,
   remember to substitute real values in the corresponding AWS account.

```bash
iamAuthenticatorConfig:
mapRoles:
- groups:
- system:bootstrappers
- system:nodes
rolearn: arn:aws:iam::111122223333:role/my-node-role
username: system:node:{{EC2PrivateDNSName}}
- groups:
- system:masters
rolearn: arn:aws:iam::111122223333:role/PowerUser
username: admin
```

For further instructions on changing or assigning roles or clusterroles to
which you can map IAM users or roles, see Amazon Enabling IAM access to your
cluster.

### EKS: Retrieving kubeconfig for EKS Cluster

About this task

Before you start, make sure you have created a managed cluster, as described
in EKS: Create an EKS Cluster.

To explore the new Kubernetes cluster, follow these steps:

Procedure

1. Get a kubeconfig file for the managed cluster from the Secret, and write it
   to a file using this command. When the managed cluster is created, the
   cluster life cycle services generate a kubeconfig file for the managed
   cluster, and write it to a Secret. The kubeconfig file is scoped to the
   cluster administrator. Get the kubeconfig from the Secret, and write it to a
   file, using this command:

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
```

1. List the Nodes using this command.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get nodes
```

Output will be similar to:

```bash
NAME STATUS ROLES AGE VERSION
ip-10-0-122-211.us-west-2.compute.internal Ready <none> 35m kubernetes-
version-eks-ae9a62a
ip-10-0-127-74.us-west-2.compute.internal Ready <none> 35m kubernetes-
version-eks-ae9a62a
ip-10-0-71-155.us-west-2.compute.internal Ready <none> 35m kubernetes-
version-eks-ae9a62a
ip-10-0-93-47.us-west-2.compute.internal Ready <none> 35m kubernetes-
version-eks-ae9a62a
Note: It may take a few minutes for the Status to move to Ready while the Pod network is deployed. The node
status will change to Ready soon after the calico-node DaemonSet Pods are Ready.
```

1. List the Pods using this command.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get --all-namespaces pods
```

Output will be similar to:

```bash
NAMESPACE NAME READY
STATUS RESTARTS AGE
calico-system calico-kube-controllers-7d6749878f-ccsx9 1/1
Running 0 34m
calico-system calico-node-2r6l8 1/1
Running 0 34m
calico-system calico-node-5pdlb 1/1
Running 0 34m
calico-system calico-node-n24hh 1/1
Running 0 34m
calico-system calico-node-qrh7p 1/1
Running 0 34m
calico-system calico-typha-7bbcb87696-7pk45 1/1
Running 0 34m
calico-system calico-typha-7bbcb87696-t4c8r 1/1
Running 0 34m
calico-system csi-node-driver-bz48k 2/2
Running 0 34m
calico-system csi-node-driver-k5mmk 2/2
Running 0 34m
calico-system csi-node-driver-nvcck 2/2
Running 0 34m
calico-system csi-node-driver-x4xnh 2/2
Running 0 34m
kube-system aws-node-2xp86 1/1
Running 0 35m
kube-system aws-node-5f2kx 1/1
Running 0 35m
kube-system aws-node-6lzm7 1/1
Running 0 35m
kube-system aws-node-pz8c6 1/1
Running 0 35m
kube-system cluster-autoscaler-789d86b489-sz9x2 0/1
Init:0/1 0 36m
kube-system coredns-57ff979f67-pk5cg 1/1
Running 0 75m
kube-system coredns-57ff979f67-sf2j9 1/1
Running 0 75m
kube-system ebs-csi-controller-5f6bd5d6dc-bplwm 6/6
Running 0 36m
kube-system ebs-csi-controller-5f6bd5d6dc-dpjt7 6/6
Running 0 36m
kube-system ebs-csi-node-7hmm5 3/3
Running 0 35m
kube-system ebs-csi-node-l4vfh 3/3
Running 0 35m
kube-system ebs-csi-node-mfr7c 3/3
Running 0 35m
kube-system ebs-csi-node-v8krq 3/3
Running 0 35m
kube-system kube-proxy-7fc5x 1/1
Running 0 35m
kube-system kube-proxy-vvkmk 1/1
Running 0 35m
kube-system kube-proxy-x6hcc 1/1
Running 0 35m
kube-system kube-proxy-x8frb 1/1
Running 0 35m
kube-system snapshot-controller-8ff89f489-4cfxv 1/1
Running 0 36m
kube-system snapshot-controller-8ff89f489-78gg8 1/1
Running 0 36m
node-feature-discovery node-feature-discovery-master-7d5985467-52fcn 1/1
Running 0 36m
node-feature-discovery node-feature-discovery-worker-88hr7 1/1
Running 0 34m
node-feature-discovery node-feature-discovery-worker-h95nq 1/1
Running 0 35m
node-feature-discovery node-feature-discovery-worker-lfghg 1/1
Running 0 34m
node-feature-discovery node-feature-discovery-worker-prc8p 1/1
Running 0 35m
tigera-operator tigera-operator-6dcd98c8ff-k97hq 1/1
Running 0 36m
```

### EKS: Attach a Cluster

About this task

After attaching the cluster, you can use the UI to examine and manage this
cluster. For more information, see Management Cluster on page 544. The
following procedure shows how to attach an existing Amazon Elastic Kubernetes
Service (EKS) cluster.

```yaml
Note: This procedure assumes you have an existing and spun up Amazon EKS cluster(s) with administrative
privileges. Refer to the Amazon EKS for setup and configuration information.
```

Before you begin

Install AWS IAM-authenticator. For more information, see aws-iam-
authenticator. This binary is used to access your cluster using kubectl.

About this task

Attach a Pre-existing EKS Cluster

Ensure that the KUBECONFIG environment variable is set to the Management
cluster before attaching by running:

> **Note:**

```bash
export KUBECONFIG=<Management_cluster_kubeconfig>.conf
```

Access Your EKS Clusters

Procedure

1. Ensure you are connected to your EKS clusters. Enter the following commands
   for each of your clusters.

```bash
kubectl config get-contexts
kubectl config use-context <context for first eks cluster>
```

1. Confirm kubectl can access the EKS cluster.

```bash
kubectl get nodes
```

#### Create a kubeconfig File

About this task

To get started, ensure you have kubectl set up and configured with
ClusterAdmin for the cluster you want to connect to Kommander.

Procedure

1. Create the necessary service account.

```bash
kubectl -n kube-system create serviceaccount kommander-cluster-admin
```

1. Create a token secret for the serviceaccount.

```bash
kubectl -n kube-system create -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
name: kommander-cluster-admin-sa-token
annotations:
kubernetes.io/service-account.name: kommander-cluster-admin
type: kubernetes.io/service-account-token
EOF
```

1. Verify that the serviceaccount token is ready by running this command.

```bash
kubectl -n kube-system get secret kommander-cluster-admin-sa-token -oyaml
```

Verify that the data.token field is populated.

Example output:

```yaml
apiVersion: v1
data:
ca.crt: LS0tLS1CRUdJTiBDR...
namespace: ZGVmYXVsdA==
token: DUMMY_BEARER_TOKEN
kind: Secret
metadata:
annotations:
kubernetes.io/service-account.name: kommander-cluster-admin
kubernetes.io/service-account.uid: b62bc32e-b502-4654-921d-94a742e273a8
creationTimestamp: "2022-08-19T13:36:42Z"
name: kommander-cluster-admin-sa-token
namespace: default
resourceVersion: "8554"
uid: 72c2a4f0-636d-4a70-9f1c-55a75f15e520
type: kubernetes.io/service-account-token
```

1. Configure the new service account for cluster-admin permissions.

```bash
cat << EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
name: kommander-cluster-admin
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: ClusterRole
name: cluster-admin
subjects:
- kind: ServiceAccount
name: kommander-cluster-admin
namespace: kube-system
EOF
```

1. Set up the following environment variables with the access data that is
   needed for producing a new kubeconfig file.

```bash
export USER_TOKEN_VALUE=$(kubectl -n kube-system get secret/kommander-cluster-admin-
sa-token -o=go-template='{{.data.token}}' | base64 --decode)
export CURRENT_CONTEXT=$(kubectl config current-context)
export CURRENT_CLUSTER=$(kubectl config view --raw -o=go-
template='{{range .contexts}}{{if eq .name "'''${CURRENT_CONTEXT}'''"}}
{{ index .context "cluster" }}{{end}}{{end}}')
export CLUSTER_CA=$(kubectl config view --raw -o=go-template='{{range .clusters}}{{if
eq .name "'''${CURRENT_CLUSTER}'''"}}"{{with index .cluster "certificate-authority-
data" }}{{.}}{{end}}"{{ end }}{{ end }}')
export CLUSTER_SERVER=$(kubectl config view --raw -o=go-template='{{range .clusters}}
{{if eq .name "'''${CURRENT_CLUSTER}'''"}}{{ .cluster.server }}{{end}}{{ end }}')
```

1. Confirm these variables have been set correctly.

```bash
export -p | grep -E 'USER_TOKEN_VALUE|CURRENT_CONTEXT|CURRENT_CLUSTER|CLUSTER_CA|
CLUSTER_SERVER'
```

1. Generate a kubeconfig file that uses the environment variable values from
   the previous step.

```yaml
Caution: Nutanix support is unable to recover forgotten credentials. Prevent Kommander UI lockouts with the
following best practices.
```

- Backup the kubeconfig file.
- Save your credentials.
- Configure an IDP (identity provider) instead of using a username and
  password credentials.

```bash
cat << EOF > kommander-cluster-admin-config
apiVersion: v1
kind: Config
current-context: ${CURRENT_CONTEXT}
contexts:
- name: ${CURRENT_CONTEXT}
context:
cluster: ${CURRENT_CONTEXT}
user: kommander-cluster-admin
namespace: kube-system
clusters:
- name: ${CURRENT_CONTEXT}
cluster:
certificate-authority-data: ${CLUSTER_CA}
server: ${CLUSTER_SERVER}
users:
- name: kommander-cluster-admin
user:
token: ${USER_TOKEN_VALUE}
EOF
```

1. This process produces a file in your current working directory called
   kommander-cluster-admin-config. The contents of this file are used in
   Kommander to attach the cluster. Before importing this configuration, verify
   the kubeconfig file can access the cluster.

```bash
kubectl --kubeconfig $(pwd)/kommander-cluster-admin-config get all --all-namespaces
```

What to do next

There are two options to attach the cluster. Choose from one of the following
based on your preference.

- EKS: Attaching a Cluster Manually Using the CLI on page 187

#### EKS: Attaching a Cluster from the UI Dashboard

About this task

Now that you have a kubeconfig, go to the NKP UI and follow these steps below:

Procedure

1. From the top menu bar, select your target workspace.
2. On the Dashboard page, select the Add Cluster option in the Actions
   dropdown list at the top right.
3. Select Attach Cluster.
4. Select the No additional networking restrictions card. Alternatively, if
   you must use network restrictions, stop following the steps below, and see
   the instructions on the page Attach a cluster WITH network restrictions. See
   Cluster Attachment with Networking Restrictions on page 492.
5. Upload the kubeconfig file you created in the previous section (or copy its
   contents) into the Cluster Configuration section.
6. The Cluster Name field automatically populates with the name of the cluster
   in the kubeconfig. You can edit this field with the name you want for your
   cluster.
7. Add labels to classify your cluster as needed.
8. Select Create to attach your cluster.

```yaml
Note: If a cluster has limited resources to deploy all the federated platform services, it will fail to stay attached in
the NKP UI. If this happens, ensure your system has sufficient resources for all pods.
```

#### EKS: Attaching a Cluster Manually Using the CLI

About this task

When you create a Managed Cluster with the NKP CLI, it attaches automatically
to the Management Cluster after a few moments.

However, if you do not set a workspace, the attached cluster will be created
in the default workspace. To ensure that the attached cluster is created in
your desired workspace namespace, follow these instructions:

Procedure

1. Confirm you have your MANAGED_CLUSTER_NAME variable set with the following
   command.

```bash
echo ${MANAGED_CLUSTER_NAME}
```

1. Retrieve your kubeconfig from the cluster you have created without setting
   a workspace.

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} >
${MANAGED_CLUSTER_NAME}.conf
```

1. You can now either attach it in the UI, or attach your cluster to the
   workspace you want in the CLI.

> **Note: This is only necessary if you never set the workspace of your
> cluster upon creation.** 4. Retrieve the workspace where you want to
> attach the cluster:

```bash
kubectl get workspaces -A
```

1. Set the WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace-namespace>
```

1. You need to create a secret in the desired workspace before attaching the
   cluster to that workspace. Retrieve the kubeconfig secret value of your
   cluster.

```bash
kubectl -n default get secret ${MANAGED_CLUSTER_NAME}-kubeconfig -o go-
template='{{.data.value}}{{ "\n"}}'
```

1. This will return a lengthy value. Copy this entire string for a secret
   using the template below as a reference. Create a new attached-cluster-
   kubeconfig.yaml file.

```yaml
apiVersion: v1
kind: Secret
metadata:
name: <your-managed-cluster-name>-kubeconfig
labels:
cluster.x-k8s.io/cluster-name: <your-managed-cluster-name>
type: cluster.x-k8s.io/secret
data:
value: <value-you-copied-from-secret-above>
```

1. Create this secret in the desired workspace.

```bash
kubectl apply -f attached-cluster-kubeconfig.yaml --namespace
${WORKSPACE_NAMESPACE}
```

1. Create this nkpcluster object to attach the cluster to the workspace.

```bash
cat << EOF | kubectl apply -f -
apiVersion: clusters.nkp.nutanix.com/v1alpha1
kind: NKPCluster
metadata:
name: ${MANAGED_CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
capiClusterRef:
name: ${MANAGED_CLUSTER_NAME}
namespace: default
kommanderCluster:
spec:
kubeconfigRef:
name: ${MANAGED_CLUSTER_NAME}-kubeconfig
clusterRef:
capiCluster:
name: ${MANAGED_CLUSTER_NAME}
EOF
```

1. You can now view this cluster in your Workspace in the UI and you can
   confirm its status by using the command. It may take a few minutes to reach
   "Joined" status. If you have several Pro Clusters and want to turn one of
   them to a Managed Cluster to be centrally administrated by a Management
   Cluster, review Platform Expansion.

```bash
kubectl get nkpclusters -A
```

If you have several Pro Clusters and want to turn one of them to a Managed
Cluster to be centrally administrated by a Management Cluster, see Platform
Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate Managed Cluster
on page 519.

For information on related topics or procedures, refer to the following:

- EKS: Creating an EKS Cluster from the UI on page 838
- Configuring and Running Amazon EKS Clusters
- Cluster Management on page 458

## vSphere Installation Options

For an environment that is on the vSphere Infrastructure, install options
based on those environment variables are provided for you in this location.

Remember, there are always more options for custom YAML in the Custom
Installation and Additional Infrastructure Tools section, but this will get
you operative in the most common scenarios.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

For a list of all the NKP supported environment combinations, see Supported
Infrastructure Operating Systems on page 12.

vSphere Overview

vSphere is a more complex setup than some of the other providers and
infrastructures, so an overview of steps has been provided to help. To confirm
that your OS is supported, see Supported Operating System.

The overall process for configuring vSphere and NKP together includes the
following steps:

1. Configure vSphere to provide the needed elements described in the vSphere
   Prerequisites: All Installation Types. 2.
   For more information on air-gapped environments, see Creating a Bastion Host
   on page 707. 3. Create a base OS image (for
   use in the OVA package containing the disk images packaged with the OVF). 4.
   Create a CAPI VM image template that uses
   the base OS image and adds the needed Kubernetes cluster components. 5.
   Create
   a new self-managing cluster on vSphere.
2. Install Kommander. 7. Verify and log on to the UI.

### vSphere Prerequisites: All Installation Types

This section contains all the prerequisite information specific to VMware
vSphere infrastructure. These are above and beyond all of the NKP
prerequisites for Install. Fulfilling the prerequisites involves completing
these two areas:

- NKP prerequisites
- vSphere prerequisites - vCenter Server + ESXi

NKP Prerequisites

Before using NKP to create a vSphere cluster, verify that you have:

- An x86_64-based Linux or macOS machine.
- Download NKP binaries image bundle for Linux or macOS.
- A Container engine/runtime installed is required to install NKP and bootstrap:
- Docker container engine version 27.4.0 installed for Linux or MacOS. For
  more information, see https:// docs.docker.com/get-docker/.
- Podman Version 4.0 or later for Linux. For more information, see
  `<https://podman.io/getting-started/>` installation. For host requirements,
  see `<https://kind.sigs.k8s.io/docs/user/rootless/#host-requirements>`.
- The host running the NKP CLI must have kubectl version 1.35.x installed.

For more information, see kubectl.

- A valid VMware vSphere account with credentials configured.

```yaml
Note: NKP uses the vsphere CSI driver as the default storage provider. Use a Kubernetes CSI-compatible storage
that is suitable for production. For more information, see https://kubernetes.io/docs/concepts/storage/
volumes/#volume-types.
Note: You can choose from any of the storage options available for Kubernetes. To turn off the default that NKP
deploys, set the default StorageClass as non-default. Then, set your newly created StorageClass to be the default by
following the commands in the Kubernetes documentation called Changing the Default Storage Class.
```

VMware vSphere Prerequisites

Before installing, verify that your VMware vSphere Client environment meets
the following basic requirements:

- Access to a bastion VM or other network-connected host, running vSphere
  version 7.0.3 or later.
- You must be able to reach the vSphere API endpoint from where the Konvoy
  command line interface (CLI) runs.
- vSphere account with credentials configured - this account must have
  Administrator privileges.
- A Red Hat subscription with a username and password for downloading DVD ISOs.
- For air-gapped environments, a bastion VM host template with access to a
  configured local registry. The recommended template naming pattern is
  ../folder-name/nkp-e2e-bastion-template or similar. Each infrastructure
  provider has its own set of bastion host instructions. For more information
  on Creating a Bastion Host on page 707, see your provider's documentation:
- AWS: `<https://aws.amazon.com/solutions/implementations/linux-bastion/>`
- Azure: `<<https://learn.microsoft.com/en-us/azure/bastion/quickstart-host->`
  portal>
- GCP: `<<https://blogs.vmware.com/cloud/2021/06/02/intro-google-cloud-vmware->`
  engine-bastion-host-> access-iap/
- vSphere: `<<https://docs.vmware.com/en/VMware->`
  vSphere/7.0/com.vmware.vsphere.security.doc/>
  GUID-6975426F-56D0-4FE2-8A58-580B40D2F667.html
- VMware: `<<https://docs.vmware.com/en/VMware->`
  vSphere/7.0/com.vmware.vsphere.security.doc/>
  GUID-6975426F-56D0-4FE2-8A58-580B40D2F667.html.
- Valid vSphere values for the following:
- vCenter API server URL
- Datacenter name
- Zone name that contains ESXi hosts for your cluster's nodes. For more
  information, see `<<https://docs.vmware.com/en/VMware->`
  vSphere/7.0/com.vmware.esxi.install.doc/GUID->
  B2F01BF5-078A-4C7E-B505-5DFFED0B8C38.html
- Datastore name for the shared storage resource to be used for the VMs in the
  cluster.
- Use of PersistentVolumes in your cluster depends on Cloud Native Storage
  (CNS), available in vSphere v7.0.3 and later versions. CNS depends on this
  shared Datastore's configuration.
- Datastore URL from the datastore record for the shared datastore you want
  your cluster to use.
- You need this URL value to ensure that the correct Datastore is used when
  NKP creates VMs for your cluster in vSphere.
- Folder name.
- Base template name, such as base-rhel-8.
- Name of a Virtual Network that has DHCP enabled for both air-gapped and non-
  air-gapped environments.
- Resource Pools - at least one resource pool is needed, with every host in
  the pool having access to shared storage, such as VSAN.
- Each host in the resource pool needs access to shared storage, such as NFS
  or VSAN, to make use of machine deployments and high-availability control
  planes.

#### vSphere Roles and Minimum Permissions

About this task

Roles in vSphere act as policy statements for objects in the vSphere
inventory. You can assign roles to users, and propagate object assignments to
child resources. In small vSphere environments, assigning a role at the top
level and propagating it to child resources might be appropriate. However, in
most enterprise environments, security teams enforce strict access
restrictions, requiring more specific role assignments.

Based on the security requirements of your environment, you can configure a
single role with minimum user permissions. You can also configure four
separate, specific roles such as nkp-vcenter, nkp-datacenter, nkp-k8srole, and
nkp-readonly. These four roles work together to provide NKP with the minimum
required permissions at each vCenter level, without requiring full admin
access.

Procedure

The following table describes the level at which you assign the permissions
and whether they propagate to child objects:

Table 16: vSphere Permissions Propagation

vCenter Server (Top Level) Yes No

| Level | Required | Propagate to Child |
| ----- | -------- | ------------------ |

Data Center Yes No

Resource Pool Yes No

Folder Yes Yes

Template Yes No

To configure the four specific vSphere roles with minimum permissions required
for provisioning and installing nodes, follow these steps:

1. Open the vSphere client and connect to your vCenter server.
2. Go to Home > Administration > Roles.
3. Click Add Role.
4. Assign the new role a name from the four options such as nkp-vcenter, nkp-
   datacenter, nkp-k8srole,

nkp-readonly. 5. Select the privileges from the permissions directory tree for
each of the following four roles:

You can set the list of permissions to create, modify, or delete resources or
clone templates, VMs, disks, and attach networks.

a. The nkp-vcenter is the root-level role that provides basic vCenter access
and search capabilities.

Assign this role at the vCenter root level with the following permissions:

Cns

X Searchable

Profile-driven storage

X Profile-driven storage view

Session

X ValidateSession

b. The nkp-datacenter role provides view-only access to datacenter, cluster,
and ESX host resources. You can assign this role to the resources.

> **Note: Do not propagate to child objects as it provides view privileges
> on all folders and resource pools.**

Data Center

X View

Cluster

X View

ESX Host 1

X View

ESX Host 2

X View

| Level | Required | Propagate to Child |
| ----- | -------- | ------------------ |

c. The nkp-k8srole allows cluster API provider vSphere (CAPV) to create
resources and assign networks. The

nkp-k8srole provides comprehensive permissions for creating, managing, and
operating your Kubernetes clusters. It includes folders, datastore management,
network assignment, virtual machine operations, and resource pool management
capabilities.

You can assign this role to the following resources:

- resource pool
- nkp folder
- nkp data store
- network

Datastore

X Allocate space

X Browse

X Delete File

X File Management

X Update Virtual Machine File

X Update Virtual Machine Data

Global

X Set Custom Field

Network

X Assign network

Resource

X Assign vApp to Pool

X Assign VM to Pool

Scheduled Task

X Create

X Delete

X Edit

X Run

Virtual machine

Change Configuration - select the following permissions:

X Add new disk

X Add existing disk

X Add or remove device

X Advanced configuration

X Change CPU count

X Change Memory

X Change resource

X Change Settings

X Reload from path

Edit inventory

X Create from existing

X Remove

Interaction

X Power off

X Power on

Provisioning

X Clone template

X Deploy template

Session

X ValidateSession

Storage Profile

X View

Storage Views

X View

d. (Optional) The nkp-readonly role provides read-only access to templates and
allows cloning operations from shared template repositories. Choose the nkp-
readonly role when templates are stored in separate folders or datastores that
require restricted access.

You can assign this role to templates folder and templates data store.

Datastore

X View

Folder

X View

vApp

X Clone

X Export

Provisioning

X Clone

X Clone template

X Deploy template

#### vSphere Storage Options

Explore storage options and considerations for using NKP with VMware vSphere.

The vSphere Container Storage plugin supports shared NFS, vNFS, and vSAN. You
need to provision your storage options in vCenter prior to creating a CAPI
image in NKP for use with vSphere.

NKP has integrated the CSI 2.x driver used in vSphere. When creating your NKP
cluster, NKP uses whatever configuration you provide for the Datastore name.
vSAN is not required. Using NFS can reduce the amount of tagging and
permission granting required to configure your cluster.

### vSphere Installation

This topic provides instructions on how to install NKP in a vSphere non-air-
gapped environment.

Remember, there are always more options for custom YAML in the Custom
Installation and Additional Infrastructure Tools section, but this will get
you operating with basic features.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

Further vSphere Prerequisites

Before you begin using Nutanix Kubernetes Platform (NKP), you must ensure you
already meet the other prerequisites in the vSphere Prerequisites: All
Installation Types section.

#### vSphere: Image Creation Overview

This diagram illustrates the image creation process:

Figure 5: vSphere Image Creation Process

The workflow on the left shows the creation of a base OS image in the vCenter
vSphere client using inputs from Packer. The workflow on the right shows how
NKP uses that same base OS image to create CAPI-enabled VM images for your
cluster.

After creating the base image, the NKP image builder uses it to create a CAPI-
enabled vSphere template that includes the Kubernetes objects for the cluster.
You can use that resulting template with the NKP create cluster command to
create the VM nodes in your cluster directly on a vCenter server. From that
point, you can use NKP to provision and manage your cluster.

NKP communicates with the code in vCenter Server as the management layer for
creating and managing virtual machines after ESXi v7.0.3 or later is installed
and configured. For more information, see https:// docs.vmware.com/en/VMware-
vSphere/7.0/com.vmware.esxi.install.doc/GUID-B2F01BF5-078A-4C7E-
B505-5DFFED0B8C38.html.

#### vSphere: BaseOS Image in vCenter

Creating a base OS image from DVD ISO files is a one-time process. The base OS
image file is created in the vSphere Client for use in the vSphere VM
template. Therefore, the base OS image is used by Nutanix Image Builder on
page 51 (NIB) to create a VM template to configure Kubernetes nodes by the NKP
vSphere provider.

The Base OS Image

For vSphere, a username is populated by SSH_USERNAME , and the user can use
authorization through SSH_PASSWORD or SSH_PRIVATE_KEY_FILE environment
variables and required by default by the packer. This user needs administrator
privileges. It is possible to configure a custom user and password when
building the OS image; however, that requires the Nutanix Image Builder (NIB)
configuration.

While creating the base OS image, it is important to take into consideration
the following elements:

- Storage configuration: Nutanix recommends customizing disk partitions and
  not configuring a SWAP partition.
- Network configuration: as NIB must download and install packages, activating
  the network is required.
- Connect to Red Hat: if using Red Hat Enterprise Linux (RHEL), registering
  with Red Hat is required to configure software repositories and install
  software packages.
- Software selection: Nutanix recommends choosing Minimal Install.
- NKP recommends installing with the packages provided by the operating system
  package managers. Use the version that corresponds to the major version of
  your operating system.

#### vSphere: Creating a CAPI VM Template

About this task

You must have at least one image before creating a new cluster. If you have an
image, this step in your configuration is not required each time since that
image can be used to spin up a new cluster. However, if you need different
images for different environments or providers, you will need to create a new
custom image.

Procedure

Follow the steps listed in Building a Custom Image with vSphere on page 64.

#### vSphere: Creating the Management Cluster

About this task

Use this procedure to create a self-managed Management cluster with NKP. A
self-managed cluster refers to one in which the CAPI resources and controllers
that describe and manage it are running on the same cluster they are managing.

Before you begin

First, you must name your cluster.

Procedure

1. Give your cluster a unique name suitable for your environment.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the environment variable.

```bash
export CLUSTER_NAME=<my-vsphere-cluster>
```

1. Create a new vSphere Kubernetes cluster.

```yaml
Note: NKP uses the vSphere CSI driver as the default storage provider. Use a Kubernetes CSI compatible
storage is suitable for production.
```

Use the following command to set the environment variables for vSphere.

```bash
export VSPHERE_SERVER=example.vsphere.url
export VSPHERE_USERNAME=user@example.vsphere.url
export VSPHERE_PASSWORD=example_password
```

1. Generate the Kubernetes cluster objects by copying and editing this command
   to include the correct values, including the VM template name you assigned
   in the previous procedure.

```yaml
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by
setting the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

If your vCenter Server uses a self-signed TLS certificate, obtain its
fingerprint:

```bash
openssl s_client -connect <vcenter-hostname>:443 </dev/null 2>/dev/null | openssl
x509 -noout -fingerprint -sha1
```

Then, add the following option to the NKP create cluster command:

```bash
--tls-thumb-print='Fingerprint from above command'
```

The following example shows a common configuration. See nkp create cluster
reference for the full list of cluster creation options:

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
--resource-pool <RESOURCE_POOL_NAME> \
--vm-template <TEMPLATE_NAME> \
--virtual-ip-interface <ip_interface_name> \
--self-managed
```

Flatcar OS use --os-hint to instruct the bootstrap cluster to make some
changes related to the installation paths.

```bash
--os-hint flatcar
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

For bootstrap and custom YAML cluster creation, refer to the Custom
Installation and Additional Infrastructure Tools section of the documentation
for vSphere: vSphere Infrastructure.

Cluster Verification

To monitor or verify the installation of your clusters, refer to: Cluster and
NKP Installation Verification on page 1039 and Installing NKP on page 43.

Known Limitations

- The NKP Konvoy version used to create a bootstrap cluster must match the NKP
  Konvoy version used to create a managed cluster.
- NKP Konvoy supports deploying one managed cluster.
- NKP Konvoy generates a set of objects for one Node Pool.
- NKP Konvoy does not validate edits to cluster objects.

#### vSphere: Configure MetalLB

Create MetalLB configuration for your vSphere infrastructure.

It is recommended that an external load balancer (LB) be the control plane
endpoint. To distribute request load among the control plane machines,
configure the load balancer to send requests to all the control plane
machines. Configure the load balancer to send requests only to control plane
machines that are responding to API requests. If you do not have one, you can
use Metal LB to create MetalLB custom resources for your vSphere
infrastructure.

Choose one of the following two protocols you want to use to announce service
IPs. If your environment is not currently equipped with a load balancer, you
can use MetalLB. Otherwise, your load balancer will work, and you can continue
the installation process with vSphere: Installing Kommander on page 201. To
use MetalLB, create MetalLB custom resources for your vSphere infrastructure.
MetalLB uses one of two protocols for exposing Kubernetes services:

- Layer 2, with Address Resolution Protocol (ARP)
- Border Gateway Protocol (BGP)

Select one of the following procedures to create your MetalLB manifest for
further editing.

Layer 2 Configuration

Layer 2 mode is the simplest to configure: in many cases, you don't need any
protocol-specific configuration, only IP addresses.

Layer 2 mode does not require the IPs to be bound to the network interfaces of
your worker nodes. It works by responding to ARP requests on your local
network directly and give the machine's MAC address to clients.

> **Warning:**

- MetalLB IP address ranges or CIDR needs to be within the node's primary
  network subnet.
- MetalLB IP address ranges or CIDRs and node subnets must not conflict with
  the Kubernetes cluster pod and service subnets.

For example, the following configuration gives MetalLB control over IPs from
192.168.1.240 to 192.168.1.250 and configures Layer 2 mode:

The following values are generic; enter your specific values into the fields
where applicable.

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
name: default
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

BGP Configuration

BGP, like any routing protocol, requires a mesh, so you configure BGP between
the nodes. If you are in a Data Center, peer with the BGP routers. The
instructions for use with Cloud providers is the same. For a standard
configuration featuring one BGP router and one IP address range, you need four
pieces of information:

- The router IP address that MetalLB needs to connect to.
- The router's autonomous systems (AS) number.
- The AS number MetalLB to be used.
- An IP address range is expressed as a CIDR prefix.

As an example, if you want to give MetalLB the range 192.168.10.0/24 and AS
number 64500, and connect it to a router at 10.0.0.1 with AS number 64501,
your configuration will look like this:

The following values are generic, enter your specific values into the fields
where applicable.

Extract the kubeconfig and deploy a config map for MetalLB using the following
command:

```bash
nkp get kubeconfig -c ${DKP_CLUSTER_NAME} > ${DKP_CLUSTER_NAME}.conf
```

Deploy MetalLB Configuration with the command below:

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
name: default
namespace: metallb-system
spec:
myASN: 64500
peerASN: 64501
peerAddress: 10.0.0.1
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.10.0/24
---
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
name: example
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

#### vSphere: Installing Kommander

About this task

Once you have installed the component of NKP, you will continue with the
installation of the Kommander component that will bring up the UI dashboard.

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

Prerequisites:

- Ensure you have reviewed all the prerequisites for installation.
- Ensure you have a Default StorageClass on page 980.
- Note the name of the cluster where you want to install Kommander. If you do
  not know the cluster name, use kubectl get nkpclusters -A to display and
  find it.

Create your Kommander Installation Configuration File

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} >> ${CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

```bash
nkp install kommander --init > kommander.yaml
```

1. If required: Customize your kommander.yaml. See Kommander Customizations
   page for customization options. Some options include Custom Domains and
   Certificates, HTTP proxy, External Load Balancer, GPU Utilization, and Rook
   Ceph customization for Pre- provisioned environments.
2. Use the customized kommander.yaml to install NKP.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

#### vSphere: Verifying your Installation and UI Log in

About this task

After you build the cluster and you install Kommander, verify your
installation. It waits for all applications to be ready by default.

```yaml
Note: If the Kommander installation fails or you wish to reconfigure applications, you can rerun the install command
to retry the installation.
```

Procedure

Check the installation status:

```bash
kubectl -n kommander wait --for condition=Ready helmreleases --all --timeout 15m
```

> **Note: If you prefer the CLI to not wait for all applications to become
> ready, you can set the --wait=false flag.**

The first wait for each of the helm charts to reach their Ready condition,
eventually resulting in an output resembling below:

```bash
helmrelease.helm.toolkit.fluxcd.io/centralized-grafana condition met
helmrelease.helm.toolkit.fluxcd.io/dex condition met
helmrelease.helm.toolkit.fluxcd.io/dex-k8s-authenticator condition met
helmrelease.helm.toolkit.fluxcd.io/fluent-bit condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-logging condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-loki condition met
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

##### Failed HelmReleases (6)

Procedure

If an application fails to deploy, check the status of a HelmRelease using the
command.

```bash
kubectl -n kommander get helmrelease <HELMRELEASE_NAME>
```

If you find any HelmReleases in a "broken" release state, such as "exhausted"
or "another rollback/release in progress", trigger a reconciliation of the
HelmRelease using the commands.

```bash
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": true}]'
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": false}]'
```

###### Log in to the UI (2)

Procedure

```bash
nkp open dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

1. Retrieve your credentials:

```bash
kubectl -n kommander get secret dkp-credentials -o go-template='Username:
{{.data.username|base64decode}}{{ "\n"}}Password: {{.data.password|base64decode}}
{{ "\n"}}'
```

1. Retrieve the dashboard URL:

```bash
kubectl -n kommander get svc kommander-traefik -o go-template='https://{{with
index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}{{end}}/dkp/kommander/
dashboard{{ "\n"}}'
```

Only use these static credentials to access the UI for configuring an external
identity provider. Treat them as backup credentials rather than use them for
normal access.

a. Rotate the dashboard password:

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

b. Retrieve the new dashboard credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

For more information, see Rotating the NKP Dashboard Password on page 308.

You can perform the following operations on Identity Providers on page 297:

- Create an Identity Provider
- Temporarily Disable an Identity Provider
- Create Groups

Dashboard UI Functions

After installing the component and building a cluster as well as successfully
installing Kommander and logging into the
UI, you are now ready to customize configurations using the Day 2 Cluster
Operations Management section of the
documentation. The majority of this customization such as attaching clusters
and deploying applications will take place
in the dashboard or UI of NKP. The Day 2 section allows you to manage cluster
operations and their application workloads
to optimize your organization's productivity.

#### vSphere: Creating Managed Clusters Using the NKP CLI

About this task

After stand-alone the initial cluster creation; you can create additional
clusters from the CLI. In a previous step, the new cluster was created as
Self-managed, which allows it to be a Management cluster or a stand-alone
cluster. Subsequent new clusters are not self-managed, as they will likely be
Managed or Attached clusters to this Management Cluster.

Creating a vSphere Managed cluster with the NKP CLI assumes that you already
fulfilled all of the prerequisites and successfully created a vSphere
Management cluster. Use this procedure to create a Managed vSphere cluster.

```yaml
Warning: When creating Managed clusters, you do not need to create and move CAPI cluster objects or install the
Kommander component. Those tasks are only done on Management clusters!
```

Your new managed cluster needs to be part of a workspace under a management
cluster. To make the new managed cluster a part of a Workspace, set that
workspace environment variable.

To make a new cluster part of a workspace:

Procedure

1. If you have an existing Workspace name, run this command to find the name.

```bash
kubectl get workspace -A
```

> **Note: If you need to create a new Workspace, follow the instructions to
> Create a New Workspace** 2. When you have the Workspace name, set the
> WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

##### Name Your Cluster (7)

About this task

Each cluster must have an original name.

Perform both steps to name the cluster:

Procedure

1. Give your cluster a unique name suitable for your environment.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the environment variable.

```bash
export CLUSTER_NAME=<my-managed-vsphere-cluster>
```

##### Create a Kubernetes Cluster (7)

About this task

```yaml
Warning: NKP uses the vsphere CSI driver as the default storage provider. Use a Kubernetes CSI compatible storage
that is suitable for production.
```

To create a cluster, follow these steps:

Procedure

1. Use the following command to set the environment variables for vSphere.

```bash
export VSPHERE_SERVER=example.vsphere.url
export VSPHERE_USERNAME=user@example.vsphere.url
export VSPHERE_PASSWORD=example_password
```

1. Generate the Kubernetes cluster objects by copying and editing this command
   to include the correct values, including the VM template name you assigned
   in the previous procedure

```yaml
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by
setting the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

The following example shows a common configuration. See nkp create cluster
reference for the full list of cluster creation options:

```bash
nkp create cluster vsphere \
--cluster-name ${MANAGED_CLUSTER_NAME} \
--additional-tags=owner=$(whoami) \
--namespace ${WORKSPACE_NAMESPACE} \
--network <NETWORK_NAME> \
--control-plane-endpoint-host <xxx.yyy.zzz.000> \
--data-center <DATACENTER_NAME> \
--data-store <DATASTORE_NAME> \
--folder <FOLDER_NAME> \
--server <VCENTER_API_SERVER_URL> \
--ssh-public-key-file <SSH_PUBLIC_KEY_FILE> \
--resource-pool <RESOURCE_POOL_NAME> \
--virtual-ip-interface <ip_interface_name> \
--vm-template <TEMPLATE_NAME> \
--kubeconfig=<management-cluster-kubeconfig-path> \
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

##### Retrieving the kubeconfig and Explore New vSphere Cluster

Procedure

1. Fetch the kubeconfig file with the command:

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} --kubeconfig <management-
cluster-kubeconfig-path> -n ${WORKSPACE_NAMESPACE} > ${MANAGED_CLUSTER_NAME}.conf
```

1. List the nodes with the following command:

```bash
kubectl --kubeconfig=${MANAGED_CLUSTER_NAME}.conf get nodes
```

1. List the pods with the following command:

```bash
kubectl --kubeconfig=${MANAGED_CLUSTER_NAME}.conf get pods -A
```

> **Note: Wait for the Status to move to Ready while calico-node pods are
> being deployed.**

##### Manually Attach an NKP CLI Cluster to the Management Cluster (7)

About this task

```yaml
Warning: These steps are only applicable if you do not set a WORKSPACE_NAMESPACE when creating a cluster.
If you already set a WORKSPACE_NAMESPACE, then you do not need to perform these steps since the cluster is
already attached to the workspace.
```

When you create a Managed Cluster with the NKP CLI, it attaches automatically
to the Management Cluster after a few moments.

However, if you do not set a workspace, the attached cluster will be created
in the default workspace. To ensure that the attached cluster is created in
your desired workspace namespace, follow these instructions:

Procedure

1. Confirm you have your MANAGED_CLUSTER_NAME variable set with the following
   command.

```bash
echo ${MANAGED_CLUSTER_NAME}
```

1. Retrieve your kubeconfig from the cluster you have created without setting
   a workspace.

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} >
${MANAGED_CLUSTER_NAME}.conf
```

1. Note: This is only necessary if you never set the workspace of your cluster
   upon creation.

You can now either attach it in the UI, link to attaching it to workspace
through UI that was earlier, or attach your cluster to the workspace you want
in the CLI.

> **Note: This is only necessary if you never set the workspace of your
> cluster upon creation.** 4. Retrieve the workspace where you want to
> attach the cluster.

```bash
kubectl get workspaces -A
```

1. Set the WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace-namespace>
```

1. You need to create a secret in the desired workspace before attaching the
   cluster to that workspace. Retrieve the kubeconfig secret value of your
   cluster.

```bash
kubectl -n default get secret ${MANAGED_CLUSTER_NAME}-kubeconfig -o go-
template='{{.data.value}}{{ "\n"}}'
```

1. This will return a lengthy value. Copy this entire string for a secret
   using the template below as a reference. Create a new attached-cluster-
   kubeconfig.yaml file.

```yaml
apiVersion: v1
kind: Secret
metadata:
name: <your-managed-cluster-name>-kubeconfig
labels:
cluster.x-k8s.io/cluster-name: <your-managed-cluster-name>
type: cluster.x-k8s.io/secret
data:
value: <value-you-copied-from-secret-above>
```

1. Create this secret in the desired workspace.

```bash
kubectl apply -f attached-cluster-kubeconfig.yaml --namespace
${WORKSPACE_NAMESPACE}
```

1. Create this nkpcluster object to attach the cluster to the workspace.

```bash
cat << EOF | kubectl apply -f -
apiVersion: clusters.nkp.nutanix.com/v1alpha1
kind: NKPCluster
metadata:
name: ${MANAGED_CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
capiClusterRef:
name: ${MANAGED_CLUSTER_NAME}
namespace: default
kommanderCluster:
spec:
kubeconfigRef:
name: ${MANAGED_CLUSTER_NAME}-kubeconfig
clusterRef:
capiCluster:
name: ${MANAGED_CLUSTER_NAME}
EOF
```

1. You can now view this cluster in your Workspace in the UI and you can
   confirm its status by running the below command. It may take a few minutes
   to reach "Joined" status.

```bash
kubectl get nkpclusters -A
```

If you have several Pro Clusters and want to turn one of them to a Managed
Cluster to be centrally administrated by a Management Cluster, see Platform
Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate Managed Cluster
on page 519.

If you have existing clusters or want to create other new clusters to attach,
there are many ways to attach a cluster with various requirements and
restrictions.

### vSphere Air-gapped Installation

This installation provides instructions on how to install Nutanix Kubernetes
Platform (NKP) in a vSphere air-gapped environment.

Remember, there are always more options for custom YAML in the Custom
Installation and Additional Infrastructure Tools section, but this will get
you operating with basic features.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

For air-gapped, ensure you have downloaded nkp-air-gapped-bundle_nkp-
version_linux_amd64.tar.gz, so you can extract the tarball on the page with
those instructions.

Further vSphere Prerequisites

Before you begin using NKP, you must ensure you already meet the other
prerequisites in the vSphere Prerequisites: All Installation Types section.

#### vSphere Air-gapped: Image Creation Overview

This diagram illustrates the image creation process:

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

Figure 6: vSphere Image Creation Process

The workflow on the left shows the creation of a base OS image in the vCenter
vSphere client using inputs from Packer. The workflow on the right shows how
NKP uses that same base OS image to create CAPI-enabled VM images for your
cluster.

After creating the base image, the NKP image builder uses it to create a CAPI-
enabled vSphere template that includes the Kubernetes objects for the cluster.
You can use that resulting template with the NKP create cluster command to
create the VM nodes in your cluster directly on a vCenter server. From that
point, you can use NKP to provision and manage your cluster.

#### vSphere Air-gapped: BaseOS Image in vCenter

Creating a base OS image from DVD ISO files is a one-time process. The base OS
image file is created in the vSphere Client for use in the vSphere VM
template. Therefore, the base OS image is used by Nutanix Image Builder on
page 51 (NIB) to create a VM template to configure Kubernetes nodes by the NKP
vSphere provider.

The Base OS Image

For vSphere, a username is populated by SSH_USERNAME , and the user can use
authorization through SSH_PASSWORD or SSH_PRIVATE_KEY_FILE environment
variables and required by default by the packer. This user needs administrator
privileges. It is possible to configure a custom user and password when
building the OS image; however, that requires the Nutanix Image Builder (NIB)
configuration.

While creating the base OS image, it is important to take into consideration
the following elements:

- Storage configuration: Nutanix recommends customizing disk partitions and
  not configuring a SWAP partition.
- Network configuration: as NIB must download and install packages, activating
  the network is required.
- Connect to Red Hat: if using Red Hat Enterprise Linux (RHEL), registering
  with Red Hat is required to configure software repositories and install
  software packages.
- Software selection: Nutanix recommends choosing Minimal Install.
- NKP recommends installing with the packages provided by the operating system
  package managers. Use the version that corresponds to the major version of
  your operating system.

#### vSphere Air-gapped: Loading the Registry

About this task

This registry must be accessible from both the bastion machine and either the
AWS EC2 instances (if deploying to AWS) or other machines that will be created
for the Kubernetes cluster.

```yaml
Warning: If you do not already have a local registry set up, see the Local Registry Tools page for more
information.
```

Procedure

1. Download the air-gapped bundle. For air-gapped, ensure you download the
   bundle nkp-air-gapped-bundle_nkp- version_linux_amd64.tar.gz and extract the
   tar file to a local directory. For more information, see Downloading NKP on
   page 16.
2. The directory structure after extraction can be accessed in subsequent
   steps using commands to access files from different directories. EX: For the
   bootstrap cluster, change your directory to the nkp-`<version>` directory
   similar to example below depending on your current location.
3. Set an environment variable with your registry address and any other needed
   variables using this command.

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
export REGISTRY_CA=<path to the cacert file on the bastion>
```

1. Execute the following command to load the air-gapped image bundle into your
   private registry using any of the relevant flags to apply variables above.

```bash
nkp push bundle --bundle ./container-images/konvoy-image-bundle-
<nkp_version_number>.tar --to-registry=${REGISTRY_URL} --to-registry-username=
${REGISTRY_USERNAME} --to-registry-password=${REGISTRY_PASSWORD}
Note: It may take some time to push all the images to your image registry, depending on the performance of the
network between the machine you are running the script on and the registry.
```

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

| tar -xzvf nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ---------------------------------- | ----------- | ------------------------ |

| cd nkp- | nkp-version | Col3 |
| ------- | ----------- | ---- |

##### Kommander Load Images (4)

About this task

If you are operating in an air-gapped environment, a local container registry
containing all the necessary installation images, including the Kommander
component images, is required. See below for how to push the necessary images
to this registry.

Load Images to your Private Registry - Kommander

About this task

Load Images to your Private Registry - Kommander

Procedure

For the air-gapped kommander image bundle, run the command below:

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-
<nkp_version_number>.tar --to-registry=${REGISTRY_URL} --to-registry-username=
${REGISTRY_USERNAME} --to-registry-password=${REGISTRY_PASSWORD}
```

#### vSphere Air-gapped: Creating a CAPI VM Template

About this task

You must have at least one image before creating a new cluster. As long as you
have an image, this step in your configuration is not required each time since
that image can be used to spin up a new cluster. However, if you need
different images for different environments or providers, you will need to
create a new custom image.

Procedure

Follow the steps listed in Building a Custom Image with vSphere on page 64.

#### vSphere Air-gapped: Creating the Management Cluster

About this task

This page of instructions will create a self-managed air-gapped management
cluster. A self-managed cluster refers to one in which the CAPI resources and
controllers that describe and manage it are running on the same cluster they
are managing.

Before you begin

Name Your Cluster

Procedure

1. Give your cluster a unique name suitable for your environment.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the environment variable using
the command.

```bash
export CLUSTER_NAME=<my-vsphere-cluster>
Warning: NKP uses the vsphere CSI driver as the default storage provider. Use a Kubernetes CSI compatible
storage that is suitable for production.
```

##### Creating a Kubernetes Cluster

Procedure

1. Configure your cluster to use an existing local registry as a mirror when
   attempting to pull images.

```yaml
Note: The image must be created by Nutanix Image Builder on page 51 in order to use the registry mirror
feature.
export REGISTRY_URL=<https/http>://<registry-address>:<registry-port>
export REGISTRY_CA=<path to the CA on the bastion>
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
```

- REGISTRY_URL: the address of an existing local registry accessible in the
  VPC that the new cluster nodes will be configured to use a mirror registry
  when pulling images.
- REGISTRY_CA: (optional) the path on the bastion machine to the registry CA.
  Konvoy will configure the cluster nodes to trust this CA. This value is only
  needed if the registry is using a self-signed certificate and the AMIs are
  not already configured to trust this CA.
- REGISTRY_USERNAME: optional, set to a user that has pull access to this
  registry.
- REGISTRY_PASSWORD: optional if username is not set.

1. Load the images, using either the docker or podman command.
2. Create the Kubernetes cluster objects by copying and editing this command
   to include the correct values, including the VM template name you assigned
   in the previous procedure:.

```bash
nkp create cluster vsphere \
--cluster-name=${MANAGED_CLUSTER_NAME} \
--additional-tags=owner=$(whoami) \
--kubeconfig=<management-cluster-kubeconfig-path> \
--namespace ${WORKSPACE_NAMESPACE}
--network <NETWORK_NAME> \
--control-plane-endpoint-host <CONTROL_PLANE_IP> \
--data-center <DATACENTER_NAME> \
--data-store <DATASTORE_NAME> \
--folder <FOLDER_NAME> \
--server <VCENTER_API_SERVER_URL> \
--ssh-public-key-file </path/to/key.pub> \
--resource-pool <RESOURCE_POOL_NAME> \
--vm-template konvoy-ova-vsphere-os-release-k8s_release-vsphere-timestamp \
--virtual-ip-interface <ip_interface_name> \
--extra-sans "127.0.0.1" \
--registry-mirror-url=${REGISTRY_URL} \
```

| docker load -i konvoy-bootstrap-image- | nkp-version | .tar |
| -------------------------------------- | ----------- | ---- |

| podman load -i konvoy-bootstrap-image- | nkp-version | .tar |
| -------------------------------------- | ----------- | ---- |

- podman image tag konvoy-bootstrap:2.12.0 docker.io/konvoy-bootstrap:; nkp-
  version; Col3

| --- | --- | --- |

```bash
--registry-mirror-cacert=${REGISTRY_CA} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD} \
--self-managed
```

Flatcar OS use --os-hint to instruct the bootstrap cluster to make some
changes related to the installation paths.

```bash
--os-hint flatcar
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
Note: For bootstrap and custom YAML cluster creation, refer to the Custom Installation and Additional
Infrastructure Tools section of the documentation for vSphere: vSphere Infrastructure
```

##### Retrieving the kubeconfig and Exploring New vSphere Cluster

Procedure

1. Fetch the kubeconfig file with the command:

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} --kubeconfig <management-
cluster-kubeconfig-path> -n ${WORKSPACE_NAMESPACE} > ${MANAGED_CLUSTER_NAME}.conf
```

1. List the nodes with the following command:

```bash
kubectl --kubeconfig=${MANAGED_CLUSTER_NAME}.conf get nodes
```

1. List the pods with the following command:

> **Note: Wait for the Status to move to Ready while calico-node pods are
> being deployed.**

```bash
kubectl --kubeconfig=${MANAGED_CLUSTER_NAME}.conf get pods -A
```

Cluster Verification

If you want to monitor or verify the installation of your clusters, refer to:
Verify your Cluster and DKP Installation.

As they progress, the controllers create Events, which you can also monitor
using the command:

```bash
kubectl get events | grep ${CLUSTER_NAME}
```

For brevity, this example uses grep. You can also use separate commands to get
Events for specific objects, such as

```bash
kubectl get events --field-selector
involvedObject.kind="VSphereCluster"
```

and

```bash
kubectl get events --field-selector
involvedObject.kind="VSphereMachine"
```

#### vSphere Air-gapped: Configure MetalLB

Create MetalLB configuration for your vSphere infrastructure.

It is recommended that an external load balancer (LB) be the control plane
endpoint. To distribute request load among the control plane machines,
configure the load balancer to send requests to all the control plane
machines. Configure the load balancer to send requests only to control plane
machines that are responding to API requests. If you do not have one, you can
use Metal LB to create MetalLB custom resources for your vSphere
infrastructure.

Choose one of the following two protocols you want to use to announce service
IPs. If your environment is not currently equipped with a load balancer, you
can use MetalLB. Otherwise, your own load balancer will work and you can
continue the installation process with vSphere Air-gapped: Installing
Kommander on page 215. To use MetalLB, create MetalLB custom resources for
your vSphere infrastructure. MetalLB uses one of two protocols for exposing
Kubernetes services:

- Layer 2, with Address Resolution Protocol (ARP)
- Border Gateway Protocol (BGP)

Select one of the following procedures to create your MetalLB manifest for
further editing.

Layer 2 Configuration

Layer 2 mode is the simplest to configure: in many cases, you don't need any
protocol-specific configuration, only IP addresses.

Layer 2 mode does not require the IPs to be bound to the network interfaces of
your worker nodes. It works by responding to ARP requests on your local
network directly, to give the machine's MAC address to clients.

> **Warning:**

- MetalLB IP address ranges or CIDRs need to be within the node's primary
  network subnet.
- MetalLB IP address ranges or CIDRs and node subnet must not conflict with
  the Kubernetes cluster pod and service subnets.

For example, the following configuration gives MetalLB control over IPs from
192.168.1.240 to 192.168.1.250, and configures Layer 2 mode:

The following values are generic, enter your specific values into the fields
where applicable.

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
name: default
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

BGP Configuration

BGP, like any routing protocol, requires a mesh, so you configure BGP between
the nodes. If you are in a Data Center, peer with the BGP routers. The
instructions for use with Cloud providers is the same. For a standard
configuration featuring one BGP router and one IP address range, you need four
pieces of information:

- The router IP address that MetalLB needs to connect to.
- The router's autonomous systems (AS) number.
- The AS number MetalLB to be used.
- An IP address range expressed as a CIDR prefix.

As an example, if you want to give MetalLB the range 192.168.10.0/24 and AS
number 64500, and connect it to a router at 10.0.0.1 with AS number 64501,
your configuration will look like:

The following values are generic, enter your specific values into the fields
where applicable.

Extract the kubeconfig and deploy a config map for MetalLB using the following
command:

```bash
nkp get kubeconfig -c ${DKP_CLUSTER_NAME} > ${DKP_CLUSTER_NAME}.conf
```

Deploy MetalLB Configuration with the command below:

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
name: default
namespace: metallb-system
spec:
myASN: 64500
peerASN: 64501
peerAddress: 10.0.0.1
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.10.0/24
---
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
name: example
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

#### vSphere Air-gapped: Installing Kommander

About this task

Once you have installed the component of NKP, you will continue with the
installation of the Kommander component that will bring up the UI dashboard.

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

Prerequisites:

- Ensure you have reviewed all Prerequisites for Install.
- Ensure you have a default StorageClass.
- Ensure you have loaded all necessary images for your configuration. See
  Images Download into Your Registry: Air-gapped Environments on page 982
- Note the name of the cluster where you want to install Kommander. If you do
  not know the cluster name, use kubectl get nkpclusters -A to display and
  find it.

Create your Kommander Installation Configuration File

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} >> ${CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

```bash
nkp install kommander --init > kommander.yaml
```

1. If required: Customize your kommander.yaml. See Kommander Customizations
   page for customization options. Some options include Custom Domains and
   Certificates, HTTP proxy, External Load Balancer, GPU Utilization, and Rook
   Ceph customization for Pre- provisioned environments.

##### Install Kommander in an Air-gapped Environment

Procedure

Use the customized kommander.yaml to install NKP.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf \
--kommander-applications-repository ./application-repositories/kommander-applications-
v2.8.1.tar.gz
```

#### vSphere Air-gapped: Verifying your Installation and UI Log in

About this task

After you build the cluster and you install Kommander, verify your
installation. It waits for all applications to be ready by default.

```yaml
Note: If the Kommander installation fails or you wish to reconfigure applications, you can rerun the install command
to retry the installation.
```

Procedure

Check the installation status:

```bash
kubectl -n kommander wait --for condition=Ready helmreleases --all --timeout 15m
```

> **Note: If you prefer the CLI to not wait for all applications to become
> ready, you can set the --wait=false flag.**

The first wait for each of the helm charts to reach their Ready condition,
eventually resulting in an output resembling below:

```bash
helmrelease.helm.toolkit.fluxcd.io/centralized-grafana condition met
helmrelease.helm.toolkit.fluxcd.io/dex condition met
helmrelease.helm.toolkit.fluxcd.io/dex-k8s-authenticator condition met
helmrelease.helm.toolkit.fluxcd.io/fluent-bit condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-logging condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-loki condition met
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

##### Failed HelmReleases (7)

Procedure

If an application fails to deploy, check the status of a HelmRelease using the
command.

```bash
kubectl -n kommander get helmrelease <HELMRELEASE_NAME>
```

If you find any HelmReleases in a "broken" release state, such as "exhausted"
or "another rollback/release in progress", trigger a reconciliation of the
HelmRelease using the commands.

```bash
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": true}]'
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": false}]'
```

###### Log in to the UI (3)

Procedure

```bash
nkp open dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

1. Retrieve your credentials:

```bash
kubectl -n kommander get secret dkp-credentials -o go-template='Username:
{{.data.username|base64decode}}{{ "\n"}}Password: {{.data.password|base64decode}}
{{ "\n"}}'
```

1. Retrieve the dashboard URL:

```bash
kubectl -n kommander get svc kommander-traefik -o go-template='https://{{with
index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}{{end}}/dkp/kommander/
dashboard{{ "\n"}}'
```

Only use these static credentials to access the UI for configuring an external
identity provider. Treat them as backup credentials rather than use them for
normal access.

a. Rotate the dashboard password:

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

b. Retrieve the new dashboard credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

For more information, see Rotating the NKP Dashboard Password on page 308.

You can perform the following operations on Identity Providers on page 297:

- Create an Identity Provider
- Temporarily Disable an Identity Provider
- Create Groups

Dashboard UI Functions

After installing the component and building a cluster as well as successfully
installing Kommander and logging into the
UI, you are now ready to customize configurations using the Day 2 Cluster
Operations Management section of the
documentation. The majority of this customization such as attaching clusters
and deploying applications will take place
in the dashboard or UI of NKP. The Day 2 section allows you to manage cluster
operations and their application workloads
to optimize your organization's productivity.

#### vSphere Air-gapped: Creating Managed Clusters Using the NKP CLI

About this task

Creating an air-gapped vSphere Managed cluster with the NKP CLI assumes that
you already fulfilled all of the prerequisites and successfully created a
vSphere Management cluster. Use this procedure to create a Managed vSphere
cluster.

```yaml
Warning: When creating Managed clusters, you do not need to create and move CAPI cluster objects, or install
the Kommander component. Those tasks are only done on Management clusters!
```

Procedure

1. If you have an existing Workspace name, run this command to find the name.
   If you need to create a new Workspace, follow the instructions to Create a
   New Workspace.

```bash
kubectl get workspace -A
```

> **Note: If you need to create a new Workspace, follow the instructions to
> Create a New Workspace** 2. When you have the Workspace name, set the
> WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

##### Name Your Cluster (8)

About this task

Each cluster must have an original name.

Perform both steps to name the cluster:

Procedure

1. Give your cluster a unique name suitable for your environment.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the environment variable.

```bash
export CLUSTER_NAME=<my-managed-vsphere-cluster>
Warning: NKP uses the vsphere CSI driver as the default storage provider. Use a Kubernetes CSI compatible
storage that is suitable for production.
```

##### Create a Kubernetes Cluster (8)

Procedure

1. Configure your cluster to use an existing local registry as a mirror when
   attempting to pull images:

```yaml
Note: The image must be created by Nutanix Image Builder on page 51 in order to use the registry mirror
feature.
export REGISTRY_URL=<https/http>://<registry-address>:<registry-port>
export REGISTRY_CA=<path to the CA on the bastion>
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
```

- REGISTRY_URL: the address of an existing local registry accessible in the
  VPC that the new cluster nodes will be configured to use a mirror registry
  when pulling images.
- REGISTRY_CA: (optional) the path on the bastion machine to the registry CA.
  NKP will configure the cluster nodes to trust this CA. This value is only
  needed if the registry is using a self-signed certificate and the AMIs are
  not already configured to trust this CA.
- REGISTRY_USERNAME: optional, set to a user that has pull access to this
  registry.
- REGISTRY_PASSWORD: optional if username is not set.

1. Load the images, using either the docker or podman command.

```bash
nkp create cluster vsphere \
--cluster-name=${MANAGED_CLUSTER_NAME} \
--additional-tags=owner=$(whoami) \
--kubeconfig=<management-cluster-kubeconfig-path> \
--namespace ${WORKSPACE_NAMESPACE}
--network <NETWORK_NAME> \
--control-plane-endpoint-host <CONTROL_PLANE_IP> \
--data-center <DATACENTER_NAME> \
--data-store <DATASTORE_NAME> \
--folder <FOLDER_NAME> \
--server <VCENTER_API_SERVER_URL> \
--ssh-public-key-file </path/to/key.pub> \
--resource-pool <RESOURCE_POOL_NAME> \
--vm-template konvoy-ova-vsphere-os-release-k8s_release-vsphere-timestamp \
--virtual-ip-interface <ip_interface_name> \
--extra-sans "127.0.0.1" \
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-cacert=${REGISTRY_CA} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD} \

Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

| docker load -i konvoy-bootstrap-image- | nkp-version | .tar |
| -------------------------------------- | ----------- | ---- |

| podman load -i konvoy-bootstrap-image- | nkp-version | .tar |
| -------------------------------------- | ----------- | ---- |

- podman image tag konvoy-bootstrap:2.12.0 docker.io/konvoy-bootstrap:; nkp-
  version; Col3

| --- | --- | --- |

##### Retrieving the kubeconfig and Exploring New vSphere Cluster (2)

Procedure

1. Fetch the kubeconfig file with the command:

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} --kubeconfig <management-
cluster-kubeconfig-path> -n ${WORKSPACE_NAMESPACE} > ${MANAGED_CLUSTER_NAME}.conf
```

1. List the nodes with the following command:

```bash
kubectl --kubeconfig=${MANAGED_CLUSTER_NAME}.conf get nodes
```

1. List the pods with the following command:

> **Note: Wait for the Status to move to Ready while calico-node pods are
> being deployed.**

```bash
kubectl --kubeconfig=${MANAGED_CLUSTER_NAME}.conf get pods -A
```

##### Manually Attach an NKP CLI Cluster to the Management Cluster (8)

About this task

```yaml
Warning: These steps are only applicable if you do not set a WORKSPACE_NAMESPACE when creating a cluster.
If you already set a WORKSPACE_NAMESPACE, then you do not need to perform these steps since the cluster is
already attached to the workspace.
```

When you create a Managed Cluster with the NKP CLI, it attaches automatically
to the Management Cluster after a few moments.

However, if you do not set a workspace, the attached cluster will be created
in the default workspace. To ensure that the attached cluster is created in
your desired workspace namespace, follow these instructions:

Procedure

1. Confirm you have your MANAGED_CLUSTER_NAME variable set with the following
   command.

```bash
echo ${MANAGED_CLUSTER_NAME}
```

1. Retrieve your kubeconfig from the cluster you have created without setting
   a workspace.

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} >
${MANAGED_CLUSTER_NAME}.conf
```

1. You can now either attach it in the UI, link to attaching it to workspace
   through UI that was earlier, or attach your cluster to the workspace you
   want in the CLI.

> **Note: This is only necessary if you never set the workspace of your
> cluster upon creation.** 4. Retrieve the workspace where you want to
> attach the cluster.

```bash
kubectl get workspaces -A
```

1. Set the WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace-namespace>
```

1. You need to create a secret in the desired workspace before attaching the
   cluster to that workspace. Retrieve the kubeconfig secret value of your
   cluster.

```bash
kubectl -n default get secret ${MANAGED_CLUSTER_NAME}-kubeconfig -o go-
template='{{.data.value}}{{ "\n"}}'
```

1. This will return a lengthy value. Copy this entire string for a secret
   using the template below as a reference. Create a new attached-cluster-
   kubeconfig.yaml file.

```yaml
apiVersion: v1
kind: Secret
metadata:
name: <your-managed-cluster-name>-kubeconfig
labels:
cluster.x-k8s.io/cluster-name: <your-managed-cluster-name>
type: cluster.x-k8s.io/secret
data:
value: <value-you-copied-from-secret-above>
```

1. Create this secret in the desired workspace.

```bash
kubectl apply -f attached-cluster-kubeconfig.yaml --namespace
${WORKSPACE_NAMESPACE}
```

1. Create this nkpcluster object to attach the cluster to the workspace.

```bash
cat << EOF | kubectl apply -f -
apiVersion: clusters.nkp.nutanix.com/v1alpha1
kind: NKPCluster
metadata:
name: ${MANAGED_CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
capiClusterRef:
name: ${MANAGED_CLUSTER_NAME}
namespace: default
kommanderCluster:
spec:
kubeconfigRef:
name: ${MANAGED_CLUSTER_NAME}-kubeconfig
clusterRef:
capiCluster:
name: ${MANAGED_CLUSTER_NAME}
EOF
```

1. You can now view this cluster in your Workspace in the UI and you can
   confirm its status by running the below command. It may take a few minutes
   to reach "Joined" status.

```bash
kubectl get nkpclusters -A
```

If you have several Pro Clusters and want to turn one of them to a Managed
Cluster to be centrally administrated by a Management Cluster, see Platform
Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate Managed Cluster
on page 519.

If you have existing clusters or want to create other new clusters to attach,
there are many ways to attach a cluster with various requirements and
restrictions.

### vSphere with FIPS Installation

This installation provides instructions to install NKP in a vSphere non-air-
gapped environment.

Remember, there are always more options for custom YAML in the Custom
Installation and Additional Infrastructure Tools section, but this will get
you operating with basic features.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

Further vSphere Prerequisites

Before you begin using NKP, you must ensure you already meet the other
prerequisites in the vSphere Prerequisites: All Installation Types section.

#### vSphere FIPS: Image Creation Overview

This diagram illustrates the image creation process:

Figure 7: vSphere Image Creation Process

The workflow on the left shows the creation of a base OS image in the vCenter
vSphere client using inputs from Packer. The workflow on the right shows how
NKP uses that same base OS image to create CAPI-enabled VM images for your
cluster.

After creating the base image, the NKP image builder uses it to create a CAPI-
enabled vSphere template that includes the Kubernetes objects for the cluster.
You can use that resulting template with the NKP create cluster command

to create the VM nodes in your cluster directly on a vCenter server. From that
point, you can use NKP to provision and manage your cluster.

#### vSphere FIPS: BaseOS Image in vCenter

Creating a base OS image from DVD ISO files is a one-time process. The base OS
image file is created in the vSphere Client for use in the vSphere VM
template. Therefore, the base OS image is used by Nutanix Image Builder on
page 51 (NIB) to create a VM template to configure Kubernetes nodes by the NKP
vSphere provider.

The Base OS Image

For vSphere, a username is populated by SSH_USERNAME and the user can use
authorization through SSH_PASSWORD or SSH_PRIVATE_KEY_FILE environment
variables and required by default by packer. This user needs administrator
privileges. It is possible to configure a custom user and password when
building the OS image, however, that requires the Nutanix Image Builder (NIB)
configuration to be completed.

While creating the base OS image, it is important to take into consideration
the following elements:

- Storage configuration: Nutanix recommends customizing disk partitions and
  not configuring a SWAP partition.
- Network configuration: as NIB must download and install packages, activating
  the network is required.
- Connect to Red Hat: if using Red Hat Enterprise Linux (RHEL), registering
  with Red Hat is required to configure software repositories and install
  software packages.
- Software selection: Nutanix recommends choosing Minimal Install.
- NKP recommends to install with the packages provided by the operating system
  package managers. Use the version that corresponds to the major version of
  your operating system.

#### vSphere FIPS: Creating a CAPI VM Template

About this task

You must have at least one image before creating a new cluster. As long as you
have an image, this step in your configuration is not required each time since
that image can be used to spin up a new cluster. However, if you need
different images for different environments or providers, you will need to
create a new custom image.

Procedure

Follow the steps listed in Building a Custom Image with vSphere on page 64.

#### vSphere FIPS: Creating the Management Cluster

About this task

Use this procedure to create a self-managed Management cluster with NKP. A
self-managed cluster refers to one in which the CAPI resources and controllers
that describe and manage it are running on the same cluster they are managing.
First you must name your cluster.

Deploying a Cluster in FIPS Mode

In order to create a cluster in FIPS mode, we must inform the bootstrap
controllers of the appropriate image repository and version tags of the
official Nutanix FIPS builds of Kubernetes.

The table below identifies the current FIPS and etcd versions for this release.

Before you begin

Table 17: Supported FIPS Builds

Kubernetes docker.io/mesosphere v`<kubernetes-version>`+fips.0

For more information, see Supported Kubernetes Versions section in the NKP
Release Notes.

etcd docker.io/mesosphere etcd-version+fips.0

For more information about the supported etcd version, see Supported
Components section in the Release Notes for your NKP version on the Nutanix
Support Portal.

Name of Cluster

Procedure

1. Give it a unique name suitable for your environment.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the CLUSTER_NAME environment
variable with the command:

```bash
export CLUSTER_NAME=<my-vsphere-cluster>
```

##### Create a New vSphere Kubernetes Cluster

About this task

```yaml
Warning: NKP uses the vSphere CSI driver as the default storage provider. Use a Kubernetes CSI compatible storage
that is suitable for production.
```

Procedure

1. Use the following command to set the environment variables for vSphere.

```bash
export VSPHERE_SERVER=example.vsphere.url
export VSPHERE_USERNAME=user@example.vsphere.url
export VSPHERE_PASSWORD=example_password
```

| Component | Repository | Version |
| --------- | ---------- | ------- |

1. Create the Kubernetes cluster objects by copying and editing this command
   to include the correct values, including the VM template name you assigned
   in the previous procedure.

```yaml
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by
setting the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

The following example shows a common configuration. See dkp create cluster
reference for the full list of cluster creation options:

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
--resource-pool <RESOURCE_POOL_NAME> \
--vm-template <TEMPLATE_NAME> \
--virtual-ip-interface <ip_interface_name> \
--kubernetes-version=v<kubernetes-version>+fips.0 \
--kubernetes-image-repository=docker.io/mesosphere \
--etcd-image-repository=docker.io/mesosphere \
--etcd-version=etcd-version+fips.0 \
--self-managed
```

For more information about the supported Kubernetes version, see Supported
Kubernetes Versions section in the NKP Release Notes. For more information
about the supported etcd version, see Supported Components section in the NKP
Release Notes.

```yaml
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

Flatcar OS use --os-hint to instruct the bootstrap cluster to make some
changes related to the installation paths.

```bash
--os-hint flatcar
Note: For bootstrap and custom YAML cluster creation, refer to the Custom Installation and Additional
Infrastructure Tools section of the documentation for vSphere: vSphere Infrastructure
```

Cluster Verification

If you want to monitor or verify the installation of your clusters, refer to:
Cluster and NKP Installation Verification on page 1039 and Installing NKP on
page 43.

#### vSphere FIPS: Configure MetalLB

Create MetalLB configuration for your vSphere infrastructure.

It is recommended that an external load balancer (LB) be the control plane
endpoint. To distribute request load among the control plane machines,
configure the load balancer to send requests to all the control plane
machines. Configure the load balancer to send requests only to control plane
machines that are responding to API requests. If you do not have one, you can
use Metal LB to create MetalLB custom resources for your vSphere
infrastructure.

Choose one of the following two protocols you want to use to announce service
IPs.

If your environment is not currently equipped with a load balancer, you can
use MetalLB. Otherwise, your own load balancer will work and you can continue
the installation process with vSphere FIPS: Installing Kommander on page 228.

To use MetalLB, create MetalLB custom resources for your vSphere
infrastructure. MetalLB uses one of two protocols for exposing Kubernetes
services:

- Layer 2, with Address Resolution Protocol (ARP)
- Border Gateway Protocol (BGP)

Select one of the following procedures to create your MetalLB manifest for
further editing.

Layer 2 Configuration

Layer 2 mode is the simplest to configure: in many cases, you don't need any
protocol-specific configuration, only IP addresses.

Layer 2 mode does not require the IPs to be bound to the network interfaces of
your worker nodes. It works by responding to ARP requests on your local
network directly, to give the machine's MAC address to clients.

> **Warning:**

- MetalLB IP address ranges or CIDRs need to be within the node's primary
  network subnet. For more information, see Cluster Pod and Services Subnets
  on page 706.
- MetalLB IP address ranges or CIDRs and node subnet must not conflict with
  the Kubernetes cluster pod and service subnets.

For example, the following configuration gives MetalLB control over IPs from
192.168.1.240 to 192.168.1.250, and configures Layer 2 mode:

The following values are generic, enter your specific values into the fields
where applicable.

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
name: default
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

BGP Configuration

BGP, like any routing protocol, requires a mesh, so you configure BGP between
the nodes. If you are in a Data Center, peer with the BGP routers. The
instructions for use with Cloud providers is the same. For a standard
configuration featuring one BGP router and one IP address range, you need four
pieces of information:

For a basic configuration featuring one BGP router and one IP address range,
you need 4 pieces of information:

- The router IP address that MetalLB needs to connect to.
- The router's autonomous systems (AS) number.
- The AS number MetalLB to be used.
- An IP address range expressed as a CIDR prefix.

As an example, if you want to give MetalLB the range 192.168.10.0/24 and AS
number 64500, and connect it to a router at 10.0.0.1 with AS number 64501,
your configuration will look like:

> **Note: The following values are generic, enter your specific values into
> the fields where applicable**

Extract the kubeconfig and deploy a config map for MetalLB using the following
command:

```bash
nkp get kubeconfig -c ${DKP_CLUSTER_NAME} > ${DKP_CLUSTER_NAME}.conf
```

Deploy MetalLB Configuration with the command below:

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
name: default
namespace: metallb-system
spec:
myASN: 64500
peerASN: 64501
peerAddress: 10.0.0.1
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.10.0/24
---
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
name: example
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

#### vSphere FIPS: Installing Kommander

About this task

Once you have installed the component of NKP, you will continue with the
installation of the Kommander component that will bring up the UI dashboard.

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

Prerequisites:

- Ensure you have reviewed all Prerequisites for Install.
- Ensure you have a default StorageClass.
- Note the name of the cluster where you want to install Kommander. If you do
  not know the cluster name, use kubectl get nkpclusters -A to display and
  find it.

Create your Kommander Installation Configuration File

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} >> ${CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

```bash
nkp install kommander --init > kommander.yaml
```

1. If required: Customize your kommander.yaml. See Kommander Customizations
   page for customization options. Some options include Custom Domains and
   Certificates, HTTP proxy, External Load Balancer, GPU Utilization, and Rook
   Ceph customization for Pre- provisioned environments.

##### Installing Kommander in an Air-gapped Environment (2)

Procedure

Use the customized kommander.yaml to install NKP.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

#### vSphere FIPS: Verifying your Installation and UI Log in

About this task

After you build the cluster and you install Kommander, verify your
installation. It waits for all applications to be ready by default.

```yaml
Note: If the Kommander installation fails or you wish to reconfigure applications, you can rerun the install command
to retry the installation.
```

Procedure

Check the installation status:

```bash
kubectl -n kommander wait --for condition=Ready helmreleases --all --timeout 15m
```

> **Note: If you prefer the CLI to not wait for all applications to become
> ready, you can set the --wait=false flag.**

The first wait for each of the helm charts to reach their Ready condition,
eventually resulting in an output resembling below:

```bash
helmrelease.helm.toolkit.fluxcd.io/centralized-grafana condition met
helmrelease.helm.toolkit.fluxcd.io/dex condition met
helmrelease.helm.toolkit.fluxcd.io/dex-k8s-authenticator condition met
helmrelease.helm.toolkit.fluxcd.io/fluent-bit condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-logging condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-loki condition met
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

##### Failed HelmReleases (8)

Procedure

If an application fails to deploy, check the status of a HelmRelease using the
command.

```bash
kubectl -n kommander get helmrelease <HELMRELEASE_NAME>
```

If you find any HelmReleases in a "broken" release state, such as "exhausted"
or "another rollback/release in progress", trigger a reconciliation of the
HelmRelease using the commands.

```bash
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": true}]'
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": false}]'
```

###### Log in to the UI (4)

Procedure

```bash
nkp open dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

1. Retrieve your credentials:

```bash
kubectl -n kommander get secret dkp-credentials -o go-template='Username:
{{.data.username|base64decode}}{{ "\n"}}Password: {{.data.password|base64decode}}
{{ "\n"}}'
```

1. Retrieve the dashboard URL:

```bash
kubectl -n kommander get svc kommander-traefik -o go-template='https://{{with
index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}{{end}}/dkp/kommander/
dashboard{{ "\n"}}'
```

Only use these static credentials to access the UI for configuring an external
identity provider. Treat them as backup credentials rather than use them for
normal access.

a. Rotate the dashboard password:

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

b. Retrieve the new dashboard credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

For more information, see Rotating the NKP Dashboard Password on page 308.

You can perform the following operations on Identity Providers on page 297:

- Create an Identity Provider
- Temporarily Disable an Identity Provider
- Create Groups

Dashboard UI Functions

After installing the component and building a cluster as well as successfully
installing Kommander and logging into the
UI, you are now ready to customize configurations using the Day 2 Cluster
Operations Management section of the
documentation. The majority of this customization such as attaching clusters
and deploying applications will take place
in the dashboard or UI of NKP. The Day 2 section allows you to manage cluster
operations and their application workloads
to optimize your organization's productivity.

#### vSphere FIPS: Creating Managed Clusters Using the NKP CLI

About this task

Creating a vSphere FIPS Managed cluster with the NKP CLI assumes that you
already fulfilled all of the prerequisites and successfully created a vSphere
Management cluster. Use this procedure to create a Managed vSphere cluster.

After initial cluster creation, you have the ability to create additional
clusters from the CLI. In a previous step, the new cluster was created as
Self-managed which allows it to be a Management cluster or a stand alone

cluster. Subsequent new clusters are not self-managed as they will likely be
Managed or Attached clusters to this Management Cluster.

```yaml
Note: When creating Managed clusters, you do not need to create and move CAPI cluster objects, or install the
Kommander component. Those tasks are only done on Management clusters!
```

Your new managed cluster needs to be part of a workspace under a management
cluster. To make the new managed cluster a part of a Workspace, set that
workspace environment variable.

Procedure

1. If you have an existing Workspace name, run this command to find the name.

```bash
kubectl get workspace -A
```

> **Note: If you need to create a new Workspace, follow the instructions to
> Create a New Workspace** 2. When you have the Workspace name, set the
> WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

##### Name Your Cluster (9)

About this task

Each cluster must have an original name.

Perform both steps to name the cluster:

Procedure

1. Give your cluster a unique name suitable for your environment.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the CLUSTER_NAME environment
variable with the command:

```bash
export CLUSTER_NAME=<my-managed-vsphere-cluster>
```

##### Creating a New Kubernetes Cluster

About this task

```yaml
Warning: NKP uses the vsphere CSI driver as the default storage provider. Use a Kubernetes CSI compatible storage
that is suitable for production.
```

Procedure

1. Use the following command to set the environment variables for vSphere.

```bash
export VSPHERE_SERVER=example.vsphere.url
export VSPHERE_USERNAME=user@example.vsphere.url
export VSPHERE_PASSWORD=example_password
```

1. Generate the Kubernetes cluster objects by copying and editing this command
   to include the correct values, including the VM template name you assigned
   in the previous procedure.

```yaml
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by
setting the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

The following example shows a common configuration. See nkp create cluster
reference for the full list of cluster creation options:

```bash
nkp create cluster vsphere \
--cluster-name=${MANAGED_CLUSTER_NAME} \
--additional-tags=owner=$(whoami) \
--kubeconfig=<management-cluster-kubeconfig-path> \
--namespace ${WORKSPACE_NAMESPACE}
--network <NETWORK_NAME> \
--control-plane-endpoint-host <xxx.yyy.zzz.000> \
--data-center <DATACENTER_NAME> \
--data-store <DATASTORE_NAME> \
--folder <FOLDER_NAME> \
--server <VCENTER_API_SERVER_URL> \
--ssh-public-key-file <SSH_PUBLIC_KEY_FILE> \
--resource-pool <RESOURCE_POOL_NAME> \
--vm-template <TEMPLATE_NAME> \
--virtual-ip-interface <ip_interface_name> \
--kubernetes-version=v<kubernetes-version>+fips.0 \
--kubernetes-image-repository=docker.io/mesosphere \
--etcd-image-repository=docker.io/mesosphere \
--etcd-version=etcd-version+fips.0 \
```

For more information about the supported Kubernetes version, see Supported
Kubernetes Versions section in the NKP Release Notes. For more information
about the supported etcd version, see Supported Components section in the NKP
Release Notes.

```yaml
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

##### Retrieving the kubeconfig and Exploring New vSphere Cluster (3)

Procedure

1. Fetch the kubeconfig file with the command:

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} --kubeconfig <management-
cluster-kubeconfig-path> -n ${WORKSPACE_NAMESPACE} > ${MANAGED_CLUSTER_NAME}.conf
```

1. List the nodes with the following command:

```bash
kubectl --kubeconfig=${MANAGED_CLUSTER_NAME}.conf get nodes
```

1. List the pods with the following command:

> **Note: Wait for the Status to move to Ready while calico-node pods are
> being deployed.**

```bash
kubectl --kubeconfig=${MANAGED_CLUSTER_NAME}.conf get pods -A
```

##### Manually Attach an NKP CLI Cluster to the Management Cluster (9)

About this task

```yaml
Warning: These steps are only applicable if you do not set a WORKSPACE_NAMESPACE when creating a cluster.
If you already set a WORKSPACE_NAMESPACE, then you do not need to perform these steps since the cluster is
already attached to the workspace.
```

When you create a Managed Cluster with the NKP CLI, it attaches automatically
to the Management Cluster after a few moments.

However, if you do not set a workspace, the attached cluster will be created
in the default workspace. To ensure that the attached cluster is created in
your desired workspace namespace, follow these instructions:

Procedure

1. Confirm you have your MANAGED_CLUSTER_NAME variable set with the following
   command.

```bash
echo ${MANAGED_CLUSTER_NAME}
```

1. Retrieve your kubeconfig from the cluster you have created without setting
   a workspace.

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} >
${MANAGED_CLUSTER_NAME}.conf
```

1. You can now either attach it in the UI, link to attaching it to workspace
   through UI that was earlier, or attach your cluster to the workspace you
   want in the CLI.

> **Note: This is only necessary if you never set the workspace of your
> cluster upon creation.** 4. Retrieve the workspace where you want to
> attach the cluster.

```bash
kubectl get workspaces -A
```

1. Set the WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace-namespace>
```

1. You need to create a secret in the desired workspace before attaching the
   cluster to that workspace. Retrieve the kubeconfig secret value of your
   cluster.

```bash
kubectl -n default get secret ${MANAGED_CLUSTER_NAME}-kubeconfig -o go-
template='{{.data.value}}{{ "\n"}}'
```

1. This will return a lengthy value. Copy this entire string for a secret
   using the template below as a reference. Create a new attached-cluster-
   kubeconfig.yaml file.

```yaml
apiVersion: v1
kind: Secret
metadata:
name: <your-managed-cluster-name>-kubeconfig
labels:
cluster.x-k8s.io/cluster-name: <your-managed-cluster-name>
type: cluster.x-k8s.io/secret
data:
value: <value-you-copied-from-secret-above>
```

1. Create this secret in the desired workspace.

```bash
kubectl apply -f attached-cluster-kubeconfig.yaml --namespace
${WORKSPACE_NAMESPACE}
```

1. Create this nkpcluster object to attach the cluster to the workspace.

```bash
cat << EOF | kubectl apply -f -
apiVersion: clusters.nkp.nutanix.com/v1alpha1
kind: NKPCluster
metadata:
name: ${MANAGED_CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
capiClusterRef:
name: ${MANAGED_CLUSTER_NAME}
namespace: default
kommanderCluster:
spec:
kubeconfigRef:
name: ${MANAGED_CLUSTER_NAME}-kubeconfig
clusterRef:
capiCluster:
name: ${MANAGED_CLUSTER_NAME}
EOF
```

1. You can now view this cluster in your Workspace in the UI and you can
   confirm its status by running the below command. It may take a few minutes
   to reach "Joined" status.

```bash
kubectl get nkpclusters -A
```

If you have several Pro Clusters and want to turn one of them to a Managed
Cluster to be centrally administrated by a Management Cluster, see Platform
Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate Managed Cluster
on page 519.

If you have existing clusters or want to create other new clusters to attach,
there are many ways to attach a cluster with various requirements and
restrictions.

### vSphere Air-gapped FIPS Installation

This installation provides instructions on how to install NKP in a vSphere
air-gapped environment using FIPS.

Remember, there are always more options for custom YAML in the Custom
Installation and Additional Infrastructure Tools section, but this will get
you operating with basic features.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

Further vSphere Prerequisites

Before you begin using NKP, you must ensure you already meet the other
prerequisites in the vSphere Prerequisites: All Installation Types section.

#### vSphere Air-gapped FIPS: Image Creation Overview

This diagram illustrates the image creation process:

Figure 8: vSphere Image Creation Process

The workflow on the left shows the creation of a base OS image in the vCenter
vSphere client using inputs from Packer. The workflow on the right shows how
NKP uses that same base OS image to create CAPI-enabled VM images for your
cluster.

After creating the base image, the NKP image builder uses it to create a CAPI-
enabled vSphere template that includes the Kubernetes objects for the cluster.
You can use that resulting template with the NKP create cluster command to
create the VM nodes in your cluster directly on a vCenter server. From that
point, you can use NKP to provision and manage your cluster.

#### vSphere Air-gapped FIPS: BaseOS Image in vCenter

Creating a base OS image from DVD ISO files is a one-time process. The base OS
image file is created in the vSphere Client for use in the vSphere VM
template. Therefore, the base OS image is used by Nutanix Image Builder on
page 51 (NIB) to create a VM template to configure Kubernetes nodes by the
Nutanix Kubernetes Platform (NKP) vSphere provider.

The Base OS Image

For vSphere, a username is populated by SSH_USERNAME , and the user can use
authorization through SSH_PASSWORD or SSH_PRIVATE_KEY_FILE environment
variables and required by default by the packer. This user needs administrator
privileges. It is possible to configure a custom user and password when
building the OS image; however, that requires the Nutanix Image Builder (NIB)
configuration to be completed.

While creating the base OS image, it is important to take into consideration
the following elements:

- Storage configuration: Nutanix recommends customizing disk partitions and
  not configuring a SWAP partition.
- Network configuration: as NIB must download and install packages, activating
  the network is required.
- Connect to Red Hat: if using Red Hat Enterprise Linux (RHEL), registering
  with Red Hat is required to configure software repositories and install
  software packages.
- Software selection: Nutanix recommends choosing Minimal Install.
- NKP recommends installing with the packages provided by the operating system
  package managers. Use the version that corresponds to the major version of
  your operating system.

#### vSphere Air-gapped FIPS: Loading the Registry

About this task

Before creating an air-gapped Kubernetes cluster, you need to load the
required images in a local registry for the Konvoy component. This registry
must be accessible from both the bastion machine and either the AWS EC2
instances (if deploying to AWS) or other machines that will be created for the
Kubernetes cluster.

```yaml
Warning: If you do not already have a local registry set up, see the Local Registry Tools page for more
information.
```

Procedure

1. Download the nkp-air-gapped bundle. For air-gapped, ensure you download the
   bundle nkp-air-gapped-bundle_nkp- version_linux_amd64.tar.gz and extract the
   tar file to a local directory. For more information, see Downloading NKP on
   page 16.
2. The directory structure after extraction can be accessed in subsequent
   steps using commands to access files from different directories. Example:
   For the bootstrap cluster, change your directory to the nkp-`<version>`
   directory, similar to the example below, depending on your current location.
3. Set an environment variable with your registry address and any other needed
   variables using this command.

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
export REGISTRY_CA=<path to the cacert file on the bastion>
```

1. Execute the following command to load the air-gapped image bundle into your
   private registry using any of the relevant flags to apply variables above.

```bash
nkp push bundle --bundle ./container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
Note: It might take some time to push all the images to your image registry, depending on the network
performance of the machine you are running the script on and the registry.
```

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

| tar -xzvf nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ---------------------------------- | ----------- | ------------------------ |

| cd nkp- | nkp-version | Col3 |
| ------- | ----------- | ---- |

##### Kommander Load Images (5)

About this task

If you are operating in an air-gapped environment, a local container registry
containing all the necessary installation images, including the Kommander
component images, is required. See below for instructions on how to push the
necessary images to this registry.

Load Images to your Private Registry - Kommander

Procedure

For the air-gapped kommander image bundle, run the command below:

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-nkp-version.tar --
to-registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
```

#### vSphere Air-gapped FIPS: Creating a CAPI VM Template

About this task

You must have at least one image before creating a new cluster. If you have an
image, this step in your configuration is not required each time since that
image can be used to spin up a new cluster. However, if you need different
images for different environments or providers, you will need to create a new
custom image.

Check the Supported Infrastructure Operating Systems on page 12.

Check the Supported Kubernetes Versions section in the NKP Release Notes for
your infrastructure provider.

Procedure

Follow the steps listed in Building a Custom Image with vSphere on page 64.

#### vSphere Air-gapped FIPS: Creating the Management Cluster

About this task

Use this procedure to create a self-managed Management cluster with NKP. A
self-managed cluster refers to one in which the CAPI resources and controllers
that describe and manage it are running on the same cluster they are managing.
First you must name your cluster.

Deploying a Cluster in FIPS Mode

In order to create a cluster in FIPS mode, we must inform the bootstrap
controllers of the appropriate image repository and version tags of the
official Nutanix FIPS builds of Kubernetes.

The table below identifies the current FIPS and etcd versions for this release.

Before you begin

Table 18: Supported FIPS Builds

Kubernetes docker.io/mesosphere v`<kubernetes-version>`+fips.0

For more information, see Supported Kubernetes Versions section in the NKP
Release Notes.

etcd docker.io/mesosphere etcd-version+fips.0

For more information about the supported etcd version, see Supported
Components section in the Release Notes for your NKP version on the Nutanix
Support Portal.

Name of Cluster

Procedure

1. Give it a unique name suitable for your environment.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the CLUSTER_NAME environment
variable with the command:

```bash
export CLUSTER_NAME=<my-vsphere-cluster>
```

##### Create a New vSphere Kubernetes Cluster (2)

About this task

About this task

```yaml
Warning: NKP uses the vsphere CSI driver as the default storage provider. Use a Kubernetes CSI compatible storage
that is suitable for production.
```

Procedure

1. Configure your cluster to use an existing local registry as a mirror when
   attempting to pull images.

```yaml
Note: The image must be created by Nutanix Image Builder on page 51 in order to use the registry mirror
feature. Use the following command to set the environment variables for vSphere.
export VSPHERE_SERVER=example.vsphere.url
export VSPHERE_USERNAME=user@example.vsphere.url
```

| Component | Repository | Version |
| --------- | ---------- | ------- |

```bash
export VSPHERE_PASSWORD=example_password
```

- REGISTRY_URL: the address of an existing local registry accessible in the
  VPC that the new cluster nodes will be configured to use a mirror registry
  when pulling images.
- REGISTRY_CA: (optional) the path on the bastion machine to the registry CA.
  NKP will configure the cluster nodes to trust this CA. This value is only
  needed if the registry is using a self-signed certificate and the AMIs are
  not already configured to trust this CA.
- REGISTRY_USERNAME: optional, set to a user that has pull access to this
  registry.
- REGISTRY_PASSWORD: optional if username is not set.

1. Load the image, using either the docker or podman command
2. Create a Kubernetes cluster by copying the following command and
   substituting the valid values for your environment:

```bash
nkp create cluster vsphere
--cluster-name ${CLUSTER_NAME} \
--network <NETWORK_NAME> \
--control-plane-endpoint-host <CONTROL_PLANE_IP> \
--data-center <DATACENTER_NAME> \
--data-store <DATASTORE_NAME> \
--folder <FOLDER_NAME> \
--server <VCENTER_API_SERVER_URL> \
--ssh-public-key-file </path/to/key.pub> \
--resource-pool <RESOURCE_POOL_NAME> \
--vm-template konvoy-ova-vsphere-os-release-k8s_release-vsphere-timestamp \
--virtual-ip-interface <ip_interface_name> \
--extra-sans "127.0.0.1" \
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-cacert=${REGISTRY_CA} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD} \
--kubernetes-version=v<kubernetes-version>+fips.0 \
--kubernetes-image-repository=docker.io/mesosphere \
--etcd-image-repository=docker.io/mesosphere --etcd-version=etcd-version+fips.0 \
```

| docker load -i konvoy-bootstrap-image- | nkp-version | .tar |
| -------------------------------------- | ----------- | ---- |

| podman load -i konvoy-bootstrap-image- | nkp-version | .tar |
| -------------------------------------- | ----------- | ---- |

- podman image tag konvoy-bootstrap:2.12.0 docker.io/konvoy-bootstrap:; nkp-
  version; Col3

| --- | --- | --- |

```bash
--self-managed
```

For more information about the supported etcd version, see NKP Release Notes
on the Nutanix Support Portal.

Flatcar OS use --os-hint to instruct the bootstrap cluster to make some
changes related to the installation paths.

```bash
--os-hint flatcar
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
Note: For bootstrap and custom YAML cluster creation, refer to the Custom Installation and Additional
Infrastructure Tools section of the documentation for vSphere: vSphere Infrastructure
```

Cluster Verification

If you want to monitor or verify the installation of your clusters, refer to:
Verify your Cluster and DKNKP Installation.

As they progress, the controllers create Events, which you can also monitor
using the command:

```bash
kubectl get events | grep ${CLUSTER_NAME}
```

For brevity, this example uses grep. You can also use separate commands to get
Events for specific objects, such as

```bash
kubectl get events --field-selector
involvedObject.kind="VSphereCluster"
```

and

```bash
kubectl get events --field-selector
involvedObject.kind="VSphereMachine"
```

.

#### vSphere Air-gapped FIPS: Configure MetalLB

Create MetalLB configuration for your vSphere infrastructure.

It is recommended that an external load balancer (LB) be the control plane
endpoint. To distribute request load among the control plane machines,
configure the load balancer to send requests to all the control plane
machines. Configure the load balancer to send requests only to control plane
machines that are responding to API requests. If you do not have one, you can
use Metal LB to create MetalLB custom resources for your vSphere
infrastructure.

Choose one of the following two protocols you want to use to announce service
IPs.

If your environment is not currently equipped with a load balancer, you can
use MetalLB. Otherwise, your load balancer will work, and you can continue the
installation process with vSphere Air-gapped FIPS: Installing Kommander on
page 243.

To use MetalLB, create MetalLB custom resources for your vSphere
infrastructure. MetalLB uses one of two protocols for exposing Kubernetes
services:

- Layer 2, with Address Resolution Protocol (ARP)
- Border Gateway Protocol (BGP)

Select one of the following procedures to create your MetalLB manifest for
further editing.

Layer 2 Configuration

Layer 2 mode is the simplest to configure: in many cases, you don't need any
protocol-specific configuration, only IP addresses.

Layer 2 mode does not require the IPs to be bound to the network interfaces of
your worker nodes. It works by responding to ARP requests on your local
network directly and giving the machine's MAC address to clients.

> **Warning:**

- MetalLB IP address ranges or CIDR need to be within the node's primary
  network subnet.
- MetalLB IP address ranges or CIDRs and node subnets must not conflict with
  the Kubernetes cluster pod and service subnets.

For example, the following configuration gives MetalLB control over IPs from
192.168.1.240 to 192.168.1.250 and configures Layer 2 mode:

The following values are generic, enter your specific values into the fields
where applicable.

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
name: default
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

BGP Configuration

BGP, like any routing protocol, requires a mesh, so you configure BGP between
the nodes. If you are in a Data Center, peer with the BGP routers. The
instructions for use with Cloud providers is the same. For a standard
configuration featuring one BGP router and one IP address range, you need four
pieces of information:

- The router IP address that MetalLB needs to connect to.
- The router's autonomous systems (AS) number.
- The AS number MetalLB is to be used.
- An IP address range is expressed as a CIDR prefix.

As an example, if you want to give MetalLB the range 192.168.10.0/24 and AS
number 64500 and connect it to a router at 10.0.0.1 with AS number 64501, your
configuration will look like this:

> **Note: The following values are generic, enter your specific values into
> the fields where applicable.**

Extract the kubeconfig and deploy a config map for MetalLB using the following
command:

```bash
nkp get kubeconfig -c ${DKP_CLUSTER_NAME} > ${DKP_CLUSTER_NAME}.conf
```

Deploy MetalLB Configuration with the command below:

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
name: default
namespace: metallb-system
spec:
myASN: 64500
peerASN: 64501
peerAddress: 10.0.0.1
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default
namespace: metallb-system
spec:
addresses:
- 192.168.10.0/24
---
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
name: example
namespace: metallb-system
spec:
ipAddressPools:
- default
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

#### vSphere Air-gapped FIPS: Installing Kommander

About this task

Once you have installed the component of NKP, you will continue with the
installation of the Kommander component that will bring up the UI dashboard.

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

Prerequisites:

- Ensure you have reviewed all Prerequisites for Install.
- Ensure you have a default StorageClass.
- Ensure you have loaded all necessary images for your configuration.
- Note the name of the cluster where you want to install Kommander. If you do
  not know the cluster name, use kubectl get nkpclusters -A to display and
  find it.

Create your Kommander Installation Configuration File

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} >> ${CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

```bash
nkp install kommander --init > kommander.yaml
```

1. If required: Customize your kommander.yaml. See Kommander Customizations
   page for customization options. Some options include Custom Domains and
   Certificates, HTTP proxy, External Load Balancer, GPU Utilization, and Rook
   Ceph customization for Pre- provisioned environments.

##### Installing Kommander in an Air-gapped Environment (3)

Procedure

Use the customized kommander.yaml to install NKP.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf \
--kommander-applications-repository ./application-repositories/kommander-
applications-nkp-version.tar.gz
```

#### vSphere Air-gapped FIPS: Verifying your Installation and UI Log in

About this task

After you build the cluster and you install Kommander, verify your
installation. It waits for all applications to be ready by default.

```yaml
Note: If the Kommander installation fails or you wish to reconfigure applications, you can rerun the install command
to retry the installation.
```

Procedure

Check the installation status:

```bash
kubectl -n kommander wait --for condition=Ready helmreleases --all --timeout 15m
```

> **Note: If you prefer the CLI to not wait for all applications to become
> ready, you can set the --wait=false flag.**

The first wait for each of the helm charts to reach their Ready condition,
eventually resulting in an output resembling below:

```bash
helmrelease.helm.toolkit.fluxcd.io/centralized-grafana condition met
helmrelease.helm.toolkit.fluxcd.io/dex condition met
helmrelease.helm.toolkit.fluxcd.io/dex-k8s-authenticator condition met
helmrelease.helm.toolkit.fluxcd.io/fluent-bit condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-logging condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-loki condition met
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

##### Failed HelmReleases (9)

Procedure

If an application fails to deploy, check the status of a HelmRelease using the
command.

```bash
kubectl -n kommander get helmrelease <HELMRELEASE_NAME>
```

If you find any HelmReleases in a "broken" release state, such as "exhausted"
or "another rollback/release in progress", trigger a reconciliation of the
HelmRelease using the commands.

```bash
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": true}]'
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": false}]'
```

###### Log in to the UI (5)

Procedure

```bash
nkp open dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

1. Retrieve your credentials:

```bash
kubectl -n kommander get secret dkp-credentials -o go-template='Username:
{{.data.username|base64decode}}{{ "\n"}}Password: {{.data.password|base64decode}}
{{ "\n"}}'
```

1. Retrieve the dashboard URL:

```bash
kubectl -n kommander get svc kommander-traefik -o go-template='https://{{with
index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}{{end}}/dkp/kommander/
dashboard{{ "\n"}}'
```

Only use these static credentials to access the UI for configuring an external
identity provider. Treat them as backup credentials rather than use them for
normal access.

a. Rotate the dashboard password:

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

b. Retrieve the new dashboard credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

For more information, see Rotating the NKP Dashboard Password on page 308.

You can perform the following operations on Identity Providers:

- Create an Identity Provider
- Temporarily Disable an Identity Provider
- Create Groups

Dashboard UI Functions

After installing the component and building a cluster as well as successfully
installing Kommander and logging into the
UI, you are now ready to customize configurations using the Day 2 Cluster
Operations Management section of the
documentation. The majority of this customization such as attaching clusters
and deploying applications will take place
in the dashboard or UI of NKP. The Day 2 section allows you to manage cluster
operations and their application workloads
to optimize your organization's productivity.

#### vSphere Air-gapped FIPS: Creating Managed Clusters Using the NKP CLI

About this task

Creating an air-gapped vSphere FIPS Managed cluster with the DKP CLI assumes
that you already fulfilled all of the prerequisites and successfully created a
vSphere Management cluster. Use this procedure to create a Managed vSphere
cluster.

After initial cluster creation, you have the ability to create additional
clusters from the CLI. In a previous step, the new cluster was created as
Self-managed which allows it to be a Management cluster or a stand alone
cluster. Subsequent new clusters are not self-managed as they will likely be
Managed or Attached clusters to this Management Cluster.

```yaml
Warning: When creating Managed clusters, you do not need to create and move CAPI cluster objects, or install
the Kommander component. Those tasks are only done on Management clusters!
```

Procedure

1. If you have an existing Workspace name, run this command to find the name.

```bash
kubectl get workspace -A
```

> **Note: If you need to create a new Workspace, follow the instructions to
> Create a New Workspace** 2. When you have the Workspace name, set the
> WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

##### Name Your Cluster (10)

About this task

Each cluster must have an original name.

Perform both steps to name the cluster:

Procedure

1. Give your cluster a unique name suitable for your environment.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the CLUSTER_NAME environment
variable with the command:

```bash
export CLUSTER_NAME=<my-managed-vsphere-cluster>
Warning: NKP uses local static provisioner as the Default Storage Providers on page 34. However,
localvolumeprovisioner is not suitable for production use. You should use a Kubernetes CSI
compatible storage that is suitable for production.
```

You can choose from any of the storage options available for Kubernetes. To
disable the default that NKP deploys, set the default StorageClass
localvolumeprovisioner as non-default. Then set your newly created
StorageClass to be the default by following the commands in the Kubernetes
documentation called Changing the Default Storage Class.

##### Create a Kubernetes Cluster (9)

About this task

The below instructions tell you how to create a cluster and have it
automatically attach to the workspace you set above. If you do not set a
workspace, it will be created in the default workspace, and you need to take
additional steps to attach to a workspace later. For instructions on how to do
this, see Attach a Kubernetes Cluster.

Procedure

1. Configure your cluster to use an existing local registry as a mirror when
   attempting to pull images.

```yaml
Note: The image must be created by Nutanix Image Builder on page 51 in order to use the registry mirror
feature.
export REGISTRY_URL=<https/http>://<registry-address>:<registry-port>
export REGISTRY_CA=<path to the CA on the bastion>
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
```

- REGISTRY_URL: the address of an existing local registry accessible in the
  VPC that the new cluster nodes will be configured to use a mirror registry
  when pulling images.
- REGISTRY_CA: (optional) the path on the bastion machine to the registry CA.
  NKP will configure the cluster nodes to trust this CA. This value is only
  needed if the registry is using a self-signed certificate and the AMIs are
  not already configured to trust this CA.
- REGISTRY_USERNAME: optional, set to a user that has pull access to this
  registry.
- REGISTRY_PASSWORD: optional if username is not set.

1. Create a Kubernetes cluster by copying the following command and
   substituting the valid values for your environment:

```bash
nkp create cluster vsphere \
--cluster-name ${MANAGED_CLUSTER_NAME} \
--additional-tags=owner=$(whoami) \
--namespace ${WORKSPACE_NAMESPACE}
--network <NETWORK_NAME> \
--control-plane-endpoint-host <CONTROL_PLANE_IP> \
--data-center <DATACENTER_NAME> \
--data-store <DATASTORE_NAME> \
--folder <FOLDER_NAME> \
--server <VCENTER_API_SERVER_URL> \
--ssh-public-key-file </path/to/key.pub> \e
--resource-pool <RESOURCE_POOL_NAME> \
--vm-template konvoy-ova-vsphere-os-release-k8s_release-vsphere-timestamp \
--virtual-ip-interface <ip_interface_name> \
--extra-sans "127.0.0.1" \
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-cacert=${REGISTRY_CA} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD} \
--kubernetes-version=v<kubernetes-version>+fips.0 \
--kubernetes-image-repository=docker.io/mesosphere \
--etcd-image-repository=docker.io/mesosphere \
--etcd-version=etcd-version+fips.0 \
--kubeconfig=<management-cluster-kubeconfig-path> \
```

For more information about the supported Kubernetes version, see Supported
Kubernetes Versions section in the NKP Release Notes. For more information
about the supported etcd version, see Supported Components section in the NKP
Release Notes.

```yaml
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

##### Retrieving the kubeconfig and Exploring New vSphere Cluster (4)

Procedure

1. Fetch the kubeconfig file with the command:

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} --kubeconfig <management-
cluster-kubeconfig-path> -n ${WORKSPACE_NAMESPACE} > ${MANAGED_CLUSTER_NAME}.conf
```

1. List the nodes with the following command:

```bash
kubectl --kubeconfig=${MANAGED_CLUSTER_NAME}.conf get nodes
```

1. List the pods with the following command:

> **Note: Wait for the Status to move to Ready while calico-node pods are
> being deployed.**

```bash
kubectl --kubeconfig=${MANAGED_CLUSTER_NAME}.conf get pods -A
```

##### Manually Attach an NKP CLI Cluster to the Management Cluster (10)

About this task

```yaml
Warning: These steps are only applicable if you do not set a WORKSPACE_NAMESPACE when creating a cluster.
If you already set a WORKSPACE_NAMESPACE, then you do not need to perform these steps since the cluster is
already attached to the workspace.
```

When you create a Managed Cluster with the NKP CLI, it attaches automatically
to the Management Cluster after a few moments.

However, if you do not set a workspace, the attached cluster will be created
in the default workspace. To ensure that the attached cluster is created in
your desired workspace namespace, follow these instructions:

Procedure

1. Confirm you have your MANAGED_CLUSTER_NAME variable set with the following
   command.

```bash
echo ${MANAGED_CLUSTER_NAME}
```

1. Retrieve your kubeconfig from the cluster you have created without setting
   a workspace.

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} >
${MANAGED_CLUSTER_NAME}.conf
```

1. You can now either attach it in the UI, link to attaching it to the
   workspace through UI that was earlier, or attach your cluster to the
   workspace you want in the CLI.

> **Note: This is only necessary if you never set the workspace of your
> cluster upon creation.** 4. Retrieve the workspace where you want to
> attach the cluster.

```bash
kubectl get workspaces -A
```

1. Set the WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace-namespace>
```

1. You need to create a secret in the desired workspace before attaching the
   cluster to that workspace. Retrieve the kubeconfig secret value of your
   cluster.

```bash
kubectl -n default get secret ${MANAGED_CLUSTER_NAME}-kubeconfig -o go-
template='{{.data.value}}{{ "\n"}}'
```

1. This will return a lengthy value. Copy this entire string for a secret
   using the template below as a reference. Create a new attached-cluster-
   kubeconfig.yaml file.

```yaml
apiVersion: v1
kind: Secret
metadata:
name: <your-managed-cluster-name>-kubeconfig
labels:
cluster.x-k8s.io/cluster-name: <your-managed-cluster-name>
type: cluster.x-k8s.io/secret
data:
value: <value-you-copied-from-secret-above>
```

1. Create this secret in the desired workspace.

```bash
kubectl apply -f attached-cluster-kubeconfig.yaml --namespace
${WORKSPACE_NAMESPACE}
```

1. Create this nkpcluster object to attach the cluster to the workspace.

```bash
cat << EOF | kubectl apply -f -
apiVersion: clusters.nkp.nutanix.com/v1alpha1
kind: NKPCluster
metadata:
name: ${MANAGED_CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
capiClusterRef:
name: ${MANAGED_CLUSTER_NAME}
namespace: default
kommanderCluster:
spec:
kubeconfigRef:
name: ${MANAGED_CLUSTER_NAME}-kubeconfig
clusterRef:
capiCluster:
name: ${MANAGED_CLUSTER_NAME}
EOF
```

1. You can now view this cluster in your Workspace in the UI and you can
   confirm its status by running the below command. It may take a few minutes
   to reach "Joined" status.

```bash
kubectl get nkpclusters -A
```

If you have several Pro Clusters and want to turn one of them to a Managed
Cluster to be centrally administrated by a Management Cluster, see Platform
Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate Managed Cluster
on page 519.

If you have existing clusters or want to create other new clusters to attach,
there are many ways to attach a cluster with various requirements and
restrictions.

## Azure Installation Options

For an environment that is on the Azure Infrastructure, install options based
on those environment variables are provided for you in this location.

Remember, there are always more options for custom YAML in the Custom
Installation and Additional Infrastructure Tools section, but this will get
you operative in the most common scenarios.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

For a list of all the NKP supported environment combinations, see Supported
Infrastructure Operating Systems on page 12.

Additional Resource Information Specific to Azure

- Control plane nodes - NKP on Azure defaults to deploying a Standard_D4s_v3
  virtual machine with a 128 GiB volume for the OS and an 80GiB volume for
  etcd storage, which meets the above resource requirements.
- Worker nodes - NKP on Azure defaults to deploying a Standard_D8s_v3 virtual
  machine with an 80 GiB volume for the OS, which meets the above resource
  requirements.

### Azure Installation

This installation provides instructions on how to install NKP in an Azure non-
air-gapped environment.

Remember, there are always more options for custom YAML in the Custom
Installation and Additional Infrastructure Tools section, but this will get
you operating with basic features.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

Azure Prerequisites

Before you begin using NKP with Azure, you must:

1. Sign in to Azure:

```bash
az login
[
{
"cloudName": "AzureCloud",
"homeTenantId": "a1234567-b132-1234-1a11-1234a5678b90",
"id": "b1234567-abcd-11a1-a0a0-1234a5678b90",
"isDefault": true,
"managedByTenants": [],
"name": "Nutanix Developer Subscription",
"state": "Enabled",
"tenantId": "a1234567-b132-1234-1a11-1234a5678b90",
"user": {
"name": "user@azuremesosphere.onmicrosoft.com",
"type": "user"
}
}
]
```

1. Create an Azure Service Principal (SP) by running the following commands:
1. If you have more than one Azure account, run this command to identify your
   account:

```bash
echo $(az account show --query id -o tsv)
```

1. Run this command to ensure you are pointing to the correct Azure
   subscription ID:

```bash
az account set --subscription "Nutanix Developer Subscription"
```

1. If an SP with the name exists, this command rotates the password:

```bash
az ad sp create-for-rbac --role contributor --name "$(whoami)-konvoy" --scopes=/
subscriptions/$(az account show --query id -o tsv) --query "{ client_id: appId,
client_secret: password, tenant_id: tenant }"
```

Output:

```bash
{
"client_id": "7654321a-1a23-567b-b789-0987b6543a21",
"client_secret": "DUMMY_CLIENT_SECRET",
"tenant_id": "a1234567-b132-1234-1a11-1234a5678b90"
}
```

1. Set the AZURE_CLIENT_SECRET environment variable:

```bash
export AZURE_CLIENT_SECRET="<azure_client_secret>" #
DUMMY_CLIENT_SECRET
export AZURE_CLIENT_ID="<client_id>" # 7654321a-1a23-567b-
b789-0987b6543a21
export AZURE_TENANT_ID="<tenant_id>" # a1234567-
b132-1234-1a11-1234a5678b90
export AZURE_SUBSCRIPTION_ID="<subscription_id>" # b1234567-abcd-11a1-
a0a0-1234a5678b90
```

1. Ensure you have an override file to configure specific attributes of your
   Azure image.

### Azure: Creating an Image

About this task

This procedure describes how to use the Nutanix Image Builder on page 51 (NIB)
to create a Cluster API compliant Azure Virtual Machine (VM) Image. NIB uses
to specify base images and container images to use in your new Azure Virtual
Machine (VM) Image.

```yaml
Note: The default Azure image is not recommended for use in production. We suggest using NIB for Azure to build
the image to take advantage of enhanced cluster operations. For more options, see Building a Custom Image with
Azure on page 61.
```

For more information regarding using the image in creating clusters, see
Azure: Creating a Cluster on page 923.

Procedure

Follow the steps listed in Building a Custom Image with Azure on page 61.

### Azure: Creating the Management Cluster

About this task

Name Your Cluster

Procedure

1. Give your cluster a unique name suitable for your environment.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the environment variable using
the command.

```bash
export CLUSTER_NAME=<azure-example>
```

#### Encoding your Azure Credential Variables

About this task

```yaml
Warning: NKP uses the Azure CSI driver as the default storage provider. Use a Kubernetes CSI compatible storage
that is suitable for production.
```

Procedure

Base64 encodes the Azure environment variables set in the Azure install
prerequisites step.

```bash
export AZURE_SUBSCRIPTION_ID_B64="$(echo -n "${AZURE_SUBSCRIPTION_ID}" | base64 | tr -d
'\n')"
export AZURE_TENANT_ID_B64="$(echo -n "${AZURE_TENANT_ID}" | base64 | tr -d '\n')"
export AZURE_CLIENT_ID_B64="$(echo -n "${AZURE_CLIENT_ID}" | base64 | tr -d '\n')"
export AZURE_CLIENT_SECRET_B64="$(echo -n "${AZURE_CLIENT_SECRET}" | base64 | tr -d
'\n')"
```

#### Create an Azure Kubernetes Cluster

About this task

If you use these instructions to create a cluster on Azure using the NKP
default settings without any edits to configuration files or additional flags,
your cluster is deployed on a three control plane nodes, and four worker
nodes.

NKP uses Azure CSI as the default storage provider. You can use a Kubernetes
CSIcompatible storage solution that is suitable for production. See the
Kubernetes documentation called Changing the Default Storage Class for more
information.

Availability zones (AZs) are isolated locations within datacenter regions from
which public cloud services originate and operate. Because all the nodes in a
node pool are deployed in a single AZ; you may wish to create additional node
pools to ensure your cluster has nodes deployed in multiple AZs.

```yaml
Note: By default, the control-plane Nodes will be created in 3 different zones. However, the default worker Nodes will
reside in a single Availability Zone. You may create additional node pools in other Availability Zones with the nkp
create nodepool command.
```

Procedure

Generate the Kubernetes cluster objects. Run this command to create your
Kubernetes cluster using any relevant flags. The following example shows a
common configuration. See nkp create cluster azure reference for the full list
of cluster creation options.

```bash
nkp create cluster azure \
--cluster-name=${CLUSTER_NAME} \
--self-managed
```

Output is similar to below:

```bash
Generating cluster resources
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

- A self-managed cluster refers to one in which the CAPI resources and
  controllers that describe and manage it are running on the same cluster they
  are managing. As part of the underlying processing using the --self-managed
  flag, the NKP CLI:
- creates a bootstrap cluster
- creates a managed cluster
- moves CAPI controllers from the bootstrap cluster to the managed cluster,
  making it self-managed
- deletes the bootstrap cluster

To understand how this process works step by step, you can find a customizable
Create a Custom Azure Cluster under Custom Installation and Additional
Infrastructure Tools.

Cluster Verification

If you want to monitor or verify the installation of your clusters, refer to:
Cluster and NKP Installation Verification on page 1039 and Installing NKP on
page 43.

Known Limitations

The Konvoy version used to create a bootstrap cluster must match the Konvoy
version used to create a managed cluster.

- Konvoy supports deploying one managed cluster.
- Konvoy generates a set of objects for one Node Pool.
- Konvoy does not validate edits to cluster objects.

### Azure: Installing Kommander

About this task

Once you have installed the component of NKP, you will continue with the
installation of the Kommander component that will bring up the UI dashboard.

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

Prerequisites:

- Ensure you have reviewed all Prerequisites for Install.
- Ensure you have a default storage class. For more information, see Default
  StorageClass on page 980.
- Note the name of the cluster where you want to install Kommander. If you do
  not know the cluster name, use kubectl get nkpclusters -A to display and
  find it.

Create your Kommander Installation Configuration File

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} >> ${CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

```bash
nkp install kommander --init > kommander.yaml
```

1. If required: Customize your kommander.yaml. See Kommander Customizations
   page for customization options. Some options include Custom Domains and
   Certificates, HTTP proxy, External Load Balancer, GPU Utilization, and Rook
   Ceph customization for Pre- provisioned environments.

#### Install Kommander in an Air-gapped Environment (2)

Procedure

Use the customized kommander.yaml to install NKP.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

### Azure: Verifying your Installation and UI Log in

About this task

After you build the cluster and you install Kommander, verify your
installation. It waits for all applications to be ready by default.

```yaml
Note: If the Kommander installation fails or you wish to reconfigure applications, you can rerun the install command
to retry the installation.
```

Procedure

Check the installation status:

```bash
kubectl -n kommander wait --for condition=Ready helmreleases --all --timeout 15m
```

> **Note: If you prefer the CLI to not wait for all applications to become
> ready, you can set the --wait=false flag.**

The first wait for each of the helm charts to reach their Ready condition,
eventually resulting in an output resembling below:

```bash
helmrelease.helm.toolkit.fluxcd.io/centralized-grafana condition met
helmrelease.helm.toolkit.fluxcd.io/dex condition met
helmrelease.helm.toolkit.fluxcd.io/dex-k8s-authenticator condition met
helmrelease.helm.toolkit.fluxcd.io/fluent-bit condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-logging condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-loki condition met
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

#### Failed HelmReleases (10)

Procedure

If an application fails to deploy, check the status of a HelmRelease using the
command.

```bash
kubectl -n kommander get helmrelease <HELMRELEASE_NAME>
```

If you find any HelmReleases in a "broken" release state, such as "exhausted"
or "another rollback/release in progress", trigger a reconciliation of the
HelmRelease using the commands.

```bash
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": true}]'
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": false}]'
```

##### Log in to the UI (6)

Procedure

```bash
nkp open dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

1. Retrieve your credentials:

```bash
kubectl -n kommander get secret dkp-credentials -o go-template='Username:
{{.data.username|base64decode}}{{ "\n"}}Password: {{.data.password|base64decode}}
{{ "\n"}}'
```

1. Retrieve the dashboard URL:

```bash
kubectl -n kommander get svc kommander-traefik -o go-template='https://{{with
index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}{{end}}/dkp/kommander/
dashboard{{ "\n"}}'
```

You should only use these static credentials to access the UI for configuring
an external identity provider. Treat them as backup credentials rather than
use them for normal access.

a. Rotate the dashboard password:

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

b. Retrieve the new dashboard credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

For more information, see Rotating the NKP Dashboard Password on page 308.

You can perform the following operations on Identity Providers:

- Create an Identity Provider
- Temporarily Disable an Identity Provider
- Create Groups

Dashboard UI Functions

After installing the component and building a cluster as well as successfully
installing Kommander and logging into the
UI, you are now ready to customize configurations using the Day 2 Cluster
Operations Management section of the
documentation. The majority of this customization such as attaching clusters
and deploying applications will take place
in the dashboard or UI of NKP. The Day 2 section allows you to manage cluster
operations and their application workloads
to optimize your organization's productivity.

### Azure: Creating Managed Clusters Using the NKP CLI

About this task

In the previous step, the new cluster was created as Self-managed which allows
it to be a Management cluster. Subsequent new clusters are not self-managed as
they will likely be Managed or Attached clusters to this Management Cluster.

After the initial cluster creation; you can create additional clusters from
the CLI. In a previous step, the new cluster was created as Self-managed,
which allows it to be a Management cluster or a stand-alone cluster.
Subsequent new clusters are not self-managed, as they will likely be Managed
or Attached clusters to this Management Cluster.

```yaml
Note: When creating Managed clusters, you do not need to create and move CAPI cluster objects or install the
Kommander component. Those tasks are only done on Management clusters!
```

Your new managed cluster needs to be part of a workspace under a management
cluster. To make the new managed cluster a part of a Workspace, set that
workspace environment variable.

Procedure

1. If you have an existing Workspace name, run this command to find the name.

```bash
kubectl get workspace -A
```

> **Note: If you need to create a new Workspace, follow the instructions to
> Create a New Workspace** 2. When you have the Workspace name, set the
> WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

#### Name Your Cluster (11)

About this task

Each cluster must have an original name.

Perform both steps to name the cluster:

Procedure

1. Give your cluster a unique name suitable for your environment.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the environment variable.

```bash
export MANAGED_CLUSTER_NAME=<MANAGED_CLUSTER_NAME>
```

#### Create a Kubernetes Cluster (10)

About this task

```yaml
Note: The below instructions tell you how to create a cluster and have it automatically attach to the workspace you set
above. If you do not set a workspace, it will be created in the default workspace, and you need to take additional
steps to attach to a workspace later. For instructions on how to do this, see Attach a Kubernetes Cluster.
```

Procedure

Execute this command to create an additional cluster without the self-managed
flag:

```bash
nkp create cluster azure \
--cluster-name=${MANAGED_CLUSTER_NAME} \
--namespace=${WORKSPACE_NAMESPACE} \
--additional-tags=owner=$(whoami) \
--kubeconfig=<management-cluster-kubeconfig-path>
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

#### Retrieving the kubeconfig and Exploring New Azure Cluster

Procedure

1. Fetch the kubeconfig file with the command:

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} --kubeconfig <management-
cluster-kubeconfig-path> -n ${WORKSPACE_NAMESPACE} > ${MANAGED_CLUSTER_NAME}.conf
```

1. List the nodes with the following command:

```bash
kubectl --kubeconfig=${MANAGED_CLUSTER_NAME}.conf get nodes
```

1. List the pods with the following command:

> **Note: Wait for the Status to move to Ready while calico-node pods are
> being deployed.**

```bash
kubectl --kubeconfig=${MANAGED_CLUSTER_NAME}.conf get pods -A
```

#### Manually Attach an NKP CLI Cluster to the Management Cluster (11)

About this task

```yaml
Warning: These steps are only applicable if you do not set a WORKSPACE_NAMESPACE when creating a cluster.
If you already set a WORKSPACE_NAMESPACE, then you do not need to perform these steps since the cluster is
already attached to the workspace.
```

When you create a Managed Cluster with the NKP CLI, it attaches automatically
to the Management Cluster after a few moments.

However, if you do not set a workspace, the attached cluster will be created
in the default workspace. To ensure that the attached cluster is created in
your desired workspace namespace, follow these instructions:

Procedure

1. Confirm you have your MANAGED_CLUSTER_NAME variable set with the following
   command.

```bash
echo ${MANAGED_CLUSTER_NAME}
```

1. Retrieve your kubeconfig from the cluster you have created without setting
   a workspace.

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} >
${MANAGED_CLUSTER_NAME}.conf
```

1. You can now either attach it in the UI, link to attaching it to workspace
   through UI that was earlier, or attach your cluster to the workspace you
   want in the CLI.

> **Note: This is only necessary if you never set the workspace of your
> cluster upon creation.** 4. Retrieve the workspace where you want to
> attach the cluster.

```bash
kubectl get workspaces -A
```

1. Set the WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace-namespace>
```

1. You need to create a secret in the desired workspace before attaching the
   cluster to that workspace. Retrieve the kubeconfig secret value of your
   cluster.

```bash
kubectl -n default get secret ${MANAGED_CLUSTER_NAME}-kubeconfig -o go-
template='{{.data.value}}{{ "\n"}}'
```

1. This will return a lengthy value. Copy this entire string for a secret
   using the template below as a reference. Create a new attached-cluster-
   kubeconfig.yaml file.

```yaml
apiVersion: v1
kind: Secret
metadata:
name: <your-managed-cluster-name>-kubeconfig
labels:
cluster.x-k8s.io/cluster-name: <your-managed-cluster-name>
type: cluster.x-k8s.io/secret
data:
value: <value-you-copied-from-secret-above>
```

1. Create this secret in the desired workspace.

```bash
kubectl apply -f attached-cluster-kubeconfig.yaml --namespace
${WORKSPACE_NAMESPACE}
```

1. Create this nkpcluster object to attach the cluster to the workspace.

```bash
cat << EOF | kubectl apply -f -
apiVersion: clusters.nkp.nutanix.com/v1alpha1
kind: NKPCluster
metadata:
name: ${MANAGED_CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
capiClusterRef:
name: ${MANAGED_CLUSTER_NAME}
namespace: default
kommanderCluster:
spec:
kubeconfigRef:
name: ${MANAGED_CLUSTER_NAME}-kubeconfig
clusterRef:
capiCluster:
name: ${MANAGED_CLUSTER_NAME}
EOF
```

1. You can now view this cluster in your Workspace in the UI and you can
   confirm its status by running the below command. It may take a few minutes
   to reach "Joined" status.

```bash
kubectl get nkpclusters -A
```

If you have several Pro Clusters and want to turn one of them to a Managed
Cluster to be centrally administrated by a Management Cluster, see Platform
Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate Managed Cluster
on page 519.

## AKS Installation Options

For an environment that is on the Azure Kubernetes Service (AKS)
Infrastructure, installation options based on those environment variables are
provided for you in this location.

Remember, there are always more options for custom YAML in the Custom
Installation and Additional Infrastructure Tools section, but this will get
you operative in the most common scenarios.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

For a list of all the NKP supported environment combinations, see Supported
Infrastructure Operating Systems on page 12.

```yaml
Note: An AKS cluster cannot be a Management or Pro cluster. Before installing NKP on your AKS cluster, first
ensure you have a Management cluster with NKP and the Kommander component installed that handles the life cycle of
your AKS cluster.
```

In order to install Kommander, you need to have CAPI components, cert-manager,
etc on a self-managed cluster. The CAPI components mean you can control the
lifecycle of the cluster, and other clusters. However, because AKS is semi-
managed by Azure, the AKS clusters are under Azure control and don't have
those components. Therefore, Kommander will not be able to be installed and
these clusters will be attached to the management cluster.

```yaml
Note: Kommander installation requires you to have Cluster API (CAPI) components, cert-manager, etc on a self-
managed cluster. The CAPI components mean you can control the life cycle of the cluster, and other clusters. However,
because AKS is semi-managed by Azure, the AKS clusters are under Azure control and don't have those components.
Therefore, Kommander will not be installed and these clusters will be attached to the management cluster.
```

To deploy a cluster with a custom image in a region where CAPI images
`<https://cluster-api-aws.sigs.k8s.io/topics/>` images/built-amis.html are not
provided, you need to use Nutanix Image Builder on page 51 to create your own
image for the region.

AKS best practices discourage building custom images. If the image is
customized, it breaks some of the autoscaling and security capabilities of
AKS. Since custom virtual machine images are discouraged in AKS, Nutanix Image
Builder (NIB) does not include any support for building custom machine images
for AKS.

### AKS Installation

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

For additional custom YAML Ain't Markup Language (YAML) options, see Custom
Installation and Additional Infrastructure Tools.

NKP Prerequisites

Before starting the NKP installation, verify that you have:

- A Management cluster with NKP and the Kommander component installed.

```yaml
Note: An AKS cluster cannot be a Management or Pro cluster. Before installing NKP on your AKS cluster, ensure
you have a Management cluster with NKP and the Kommander component installed, that handles the life cycle of
your AKS cluster.
```

- An x86_64-based Linux or macOS machine with a supported version of the
  operating system.
- Download the NKPbinary for Linux, or macOS. To check which version of NKP
  you installed for compatibility reasons, run the NKP version -h command.
- Docker `<https://docs.docker.com/get-docker/>` version 27.4.0.
- kubectl `<https://kubernetes.io/docs/tasks/tools/#kubectl>` for interacting
  with the running cluster.
- The Azure CLI `<https://docs.microsoft.com/en-us/cli/azure/install-azure-cli>`.
- A valid Azure account used to sign in to the Azure CLI
  `<https://docs.microsoft.com/en-us/cli/azure/>` authenticate-azure-
  cli?view=azure-cli-latest.
- All Resource requirements.

AKS Prerequisites

Before you begin using NKP with AKS, you must:

1. Sign in to Azure using the command az login. For example:

```bash
[
{
"cloudName": "AzureCloud",
"homeTenantId": "a1234567-b132-1234-1a11-1234a5678b90",
"id": "b1234567-abcd-11a1-a0a0-1234a5678b90",
"isDefault": true,
"managedByTenants": [],
"name": "Nutanix Developer Subscription",
"state": "Enabled",
"tenantId": "a1234567-b132-1234-1a11-1234a5678b90",
"user": {
"name": "user@azuremesosphere.onmicrosoft.com",
"type": "user"
}
}
]
```

1. Create an Azure Service Principal (SP) by using the command.

> **Note: If an SP with the name exists, this command will rotate the
> password.**

```bash
az ad sp create-for-rbac --role contributor --name "$(whoami)-konvoy" --scopes=/
subscriptions/$(az account show --query id -o tsv)
```

1. Set the Azure client secret environment variable using the command
   AZURE_CLIENT_SECRET. Example output:

```bash
export AZURE_CLIENT_SECRET="<azure_client_secret>" #
DUMMY_CLIENT_SECRET
export AZURE_CLIENT_ID="<client_id>" # 7654321a-1a23-567b-
b789-0987b6543a21
export AZURE_TENANT_ID="<tenant_id>" # a1234567-
b132-1234-1a11-1234a5678b90
export AZURE_SUBSCRIPTION_ID="<subscription_id>" # b1234567-abcd-11a1-
a0a0-1234a5678b90
```

1. Base64 encodes the same environment variables:

```bash
export AZURE_SUBSCRIPTION_ID_B64="$(echo -n "${AZURE_SUBSCRIPTION_ID}" | base64 | tr
-d '\n')"
export AZURE_TENANT_ID_B64="$(echo -n "${AZURE_TENANT_ID}" | base64 | tr -d '\n')"
export AZURE_CLIENT_ID_B64="$(echo -n "${AZURE_CLIENT_ID}" | base64 | tr -d '\n')"
export AZURE_CLIENT_SECRET_B64="$(echo -n "${AZURE_CLIENT_SECRET}" | base64 | tr -d
'\n')"
```

1. Check to see what version of Kubernetes is available in your region. When
   deploying with AKS, you must pick a version of Kubernetes that is available
   in AKS and use that version for subsequent steps. To find out the list of
   available Kubernetes versions in the Azure Region you are using, run the
   following command, substituting `<your-location>` for the Azure region
   you're deploying to:
1. az aks get-versions -o table --location `<your-location>`
1. The output resembles the following:

```bash
az aks get-versions -o table --location westus
KubernetesVersion Upgrades
------------------- ----------------------------------------
1.27.6(preview) None available
1.27.3(preview) 1.27.6(preview)
1.27.1(preview) 1.27.3(preview)
1.26.6 1.27.1(preview), 1.27.3(preview)
1.26.3 1.26.6, 1.27.1(preview), 1.27.3(preview)
1.25.11 1.26.3, 1.26.6
1.25.6 1.25.11, 1.26.3, 1.26.6
1.24.15 1.25.6, 1.25.11
1.24.10 1.24.15, 1.25.6, 1.25.11
Note: For more information about the supported Kubernetes version, see Supported Kubernetes Versions
section in the NKP Release Notes.
```

1. Choose a version of Kubernetes for installation from the list using the
   command KubernetesVersion The example shows the selected version is 1.30.0.

```bash
export KUBERNETES_VERSION=1.30.0
```

For the list of compatible supported Kubernetes versions, see Supported
Kubernetes Versions section in the NKP Release Notes.

### AKS: Creating an Image

AKS best practices discourage building custom images. If the image is
customized, it breaks some of the autoscaling and security capabilities of
AKS. Since custom virtual machine images are discouraged in AKS, Nutanix Image
Builder (NIB) does not include any support for building custom machine images
for AKS.

### AKS: Creating an AKS Cluster

About this task

When creating a Managed cluster on your AKS infrastructure, you can choose
from multiple configuration types.

Procedure

Use NKP to create a new AKS cluster

> **Note: Ensure that the KUBECONFIG environment variable is set to the
> Management cluster by running .**

```bash
export KUBECONFIG=<Management_cluster_kubeconfig>.conf
```

#### Name Your Cluster (12)

Procedure

1. Give your cluster a unique name suitable for your environment.
2. Set the environment variable.

```bash
export CLUSTER_NAME=<aks-example>
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

#### Create a New AKS Kubernetes Cluster from the CLI

Procedure

1. Set the environment variable to the name you assigned this cluster.

```bash
export CLUSTER_NAME=<aks-example>
```

1. Check to see what version of Kubernetes is available in your region. When
   deploying with AKS, you need to declare the version of Kubernetes you want
   to use by running the following command, substituting `<your- location>` for
   the Azure region you're deploying to.

```bash
az aks get-versions -o table --location <your-location>
```

1. Set the Kubernetes version you have chosen.

```yaml
Note: Refer to the current release Kubernetes for the correct version to use and choose an available Kubernetes
version. For more information, see Supported Kubernetes Versions section in the NKP Release Notes.
```

1. Create the cluster.

```bash
nkp create cluster aks --cluster-name=${CLUSTER_NAME} --additional-tags=owner=
$(whoami) --kubernetes-version=${KUBERNETES_VERSION}
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
Generating cluster resources
cluster.cluster.x-k8s.io/aks-example created
azuremanagedcontrolplane.infrastructure.cluster.x-k8s.io/aks-example created
azuremanagedcluster.infrastructure.cluster.x-k8s.io/aks-example created
machinepool.cluster.x-k8s.io/aks-example created
azuremanagedmachinepool.infrastructure.cluster.x-k8s.io/cp6dsz8 created
machinepool.cluster.x-k8s.io/aks-example-md-0 created
azuremanagedmachinepool.infrastructure.cluster.x-k8s.io/mp6gglj created
clusterresourceset.addons.cluster.x-k8s.io/cluster-autoscaler-aks-example created
configmap/cluster-autoscaler-aks-example created
clusterresourceset.addons.cluster.x-k8s.io/node-feature-discovery-aks-example created
configmap/node-feature-discovery-aks-example created
clusterresourceset.addons.cluster.x-k8s.io/nvidia-feature-discovery-aks-example
created
```

| 0-9, | .   |
| ---- | --- |

| export KUBERNETES VERSION= \_ | kubernetes-version | Col3 |
| ----------------------------- | ------------------ | ---- |

```bash
configmap/nvidia-feature-discovery-aks-example created
```

#### Inspecting or Editing the Cluster Objects

About this task

Use your favorite editor.

```yaml
Note: Editing the cluster objects requires some understanding of Cluster API. Edits can prevent the cluster from
deploying successfully. For more information about the objects, see Concepts in the Cluster API Book. For more
information on custom resources, see Custom Resources .
```

The objects are custom resources defined by Cluster API components, and they
belong in three different categories:

- Cluster: A Cluster object references the infrastructure-specific and control
  plane objects.
- Control Plane: A KubeadmControlPlane object describes the control plane, the
  group of machines that run the Kubernetes control plane components. Those
  include the etcd distributed database, the API server, the core controllers,
  and the scheduler. The object describes the configuration for these
  components and refers to an infrastructure-specific object that represents
  the properties of all control plane machines.
- Node Pool: A node pool is a collection of machines with identical
  properties. For example, a cluster might have one node pool with large
  memory capacity, another node pool with GPU support. Each node pool is
  described by three objects: The MachinePool references an object that
  describes the configuration of Kubernetes components (for example, kubelet)
  deployed on each node pool machine, and an infrastructure-specific object
  that describes the properties of all node pool machines. Here, it references
  a KubeadmConfigTemplate.

Procedure

1. Wait for the cluster control-plane to be ready.

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=20m
cluster.cluster.x-k8s.io/aks-example condition met
```

The READY status will become True after the cluster control-plane becomes
ready in one of the following steps. 2. After the objects are created on the
API server, the Cluster API controllers reconcile them. They create
infrastructure and machines. As they progress, they update the Status of each
object. NKP provides a command to describe the current status of the cluster.

```bash
nkp describe cluster -c ${CLUSTER_NAME}
NAME READY SEVERITY REASON
SINCE MESSAGE
Cluster/aks-example True
48m
##ClusterInfrastructure - AzureManagedCluster/aks-example
##ControlPlane - AzureManagedControlPlane/aks-example
```

1. As they progress, the controllers also create Events. List the Events using
   this command.

```bash
kubectl get events | grep ${CLUSTER_NAME}
```

For brevity, the example uses grep. It is also possible to use separate
commands to get Events for specific objects. For example, kubectl get events
--field-selector involvedObject.kind="AKSCluster" and kubectl get events
--field-selector involvedObject.kind="AKSMachine".

```bash
48m Normal SuccessfulSetNodeRefs machinepool/aks-
example-md-0 [{Kind: Namespace: Name:aks-mp6gglj-41174201-
vmss000000 UID:e3c30389-660d-46f5-b9d7-219f80b5674d APIVersion: ResourceVersion:
FieldPath:} {Kind: Namespace: Name:aks-mp6gglj-41174201-vmss000001 UID:300d71a0-
f3a7-4c29-9ff1-1995ffb9cfd3 APIVersion: ResourceVersion: FieldPath:} {Kind:
Namespace: Name:aks-mp6gglj-41174201-vmss000002 UID:8eae2b39-a415-425d-8417-
d915a0b2fa52 APIVersion: ResourceVersion: FieldPath:} {Kind: Namespace: Name:aks-
mp6gglj-41174201-vmss000003 UID:3e860b88-f1a4-44d1-b674-a54fad599a9d APIVersion:
ResourceVersion: FieldPath:}]
6m4s Normal AzureManagedControlPlane available azuremanagedcontrolplane/
aks-example successfully reconciled
48m Normal SuccessfulSetNodeRefs machinepool/aks-
example [{Kind: Namespace: Name:aks-mp6gglj-41174201-
vmss000000 UID:e3c30389-660d-46f5-b9d7-219f80b5674d APIVersion: ResourceVersion:
FieldPath:} {Kind: Namespace: Name:aks-mp6gglj-41174201-vmss000001 UID:300d71a0-
f3a7-4c29-9ff1-1995ffb9cfd3 APIVersion: ResourceVersion: FieldPath:} {Kind:
Namespace: Name:aks-mp6gglj-41174201-vmss000002 UID:8eae2b39-a415-425d-8417-
d915a0b2fa52 APIVersion: ResourceVersion: FieldPath:}]
```

Cluster Verification

If you want to monitor or verify the installation of your clusters, refer to:
Verify your Cluster and NKP Installation.

More information about AKS can be found in the AKS Infrastructure under Custom
Installation and Additional Infrastructure Tools.

### AKS: Retrieving kubeconfig for AKS Cluster

About this task

This guide explains how to use the command line to interact with your newly
deployed Kubernetes cluster. Before you start, make sure you have created a
managed cluster, as described in AKS: Create an AKS Cluster.

Explore the new AKS cluster with the steps below.

Procedure

1. Get a kubeconfig file for the managed cluster. When the managed cluster is
   created, the cluster life cycle services generate a kubeconfig file for the
   managed cluster and write it to a Secret. The kubeconfig file is scoped to
   the cluster administrator. Get the kubeconfig from the Secret, and write it
   to a file using this command.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
```

1. List the Nodes using this command.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get nodes
NAME STATUS ROLES AGE VERSION
aks-cp6dsz8-41174201-vmss000000 Ready agent 56m v<kubernetes-version>
aks-cp6dsz8-41174201-vmss000001 Ready agent 55m v<kubernetes-version>
aks-cp6dsz8-41174201-vmss000002 Ready agent 56m v<kubernetes-version>
aks-mp6gglj-41174201-vmss000000 Ready agent 55m v<kubernetes-version>
aks-mp6gglj-41174201-vmss000001 Ready agent 55m v<kubernetes-version>
aks-mp6gglj-41174201-vmss000002 Ready agent 55m v<kubernetes-version>
aks-mp6gglj-41174201-vmss000003 Ready agent 56m v<kubernetes-version>
Note: It might take a few minutes for the Status to move to Ready while the Pod network is deployed. The Node
Status will change to Ready soon after the calico-node DaemonSet Pods are Ready.
```

1. List the Pods using the command.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get --all-namespaces pods
```

Example output:

```bash
NAMESPACE NAME READY
STATUS RESTARTS AGE
calico-system calico-kube-controllers-5dcd4b47b5-tgslm 1/1
Running 0 3m58s
calico-system calico-node-46dj9 1/1
Running 0 3m58s
calico-system calico-node-crdgc 1/1
Running 0 3m58s
calico-system calico-node-m7s7x 1/1
Running 0 3m58s
calico-system calico-node-qfkqc 1/1
Running 0 3m57s
calico-system calico-node-sfqfm 1/1
Running 0 3m57s
calico-system calico-node-sn67x 1/1
Running 0 3m53s
calico-system calico-node-w2pvt 1/1
Running 0 3m58s
calico-system calico-typha-6f7f59969c-5z4t5 1/1
Running 0 3m51s
calico-system calico-typha-6f7f59969c-ddzqb 1/1
Running 0 3m58s
calico-system calico-typha-6f7f59969c-rr4lj 1/1
Running 0 3m51s
kube-system azure-ip-masq-agent-4f4v6 1/1
Running 0 4m11s
kube-system azure-ip-masq-agent-5xfh2 1/1
Running 0 4m11s
kube-system azure-ip-masq-agent-9hlk8 1/1
Running 0 4m8s
kube-system azure-ip-masq-agent-9vsgg 1/1
Running 0 4m16s
kube-system azure-ip-masq-agent-b9wjj 1/1
Running 0 3m57s
kube-system azure-ip-masq-agent-kpjtl 1/1
Running 0 3m53s
kube-system azure-ip-masq-agent-vr7hd 1/1
Running 0 3m57s
kube-system cluster-autoscaler-b4789f4bf-qkfk2 0/1
Init:0/1 0 3m28s
kube-system coredns-845757d86-9jf8b 1/1
Running 0 5m29s
kube-system coredns-845757d86-h4xfs 1/1
Running 0 4m
kube-system coredns-autoscaler-5f85dc856b-xjb5z 1/1
Running 0 5m23s
kube-system csi-azuredisk-node-4n4fx 3/3
Running 0 3m53s
kube-system csi-azuredisk-node-8pnjj 3/3
Running 0 3m57s
kube-system csi-azuredisk-node-sbt6r 3/3
Running 0 3m57s
kube-system csi-azuredisk-node-v25wc 3/3
Running 0 4m16s
kube-system csi-azuredisk-node-vfbxg 3/3
Running 0 4m11s
kube-system csi-azuredisk-node-w5ff5 3/3
Running 0 4m11s
kube-system csi-azuredisk-node-zzgqx 3/3
Running 0 4m8s
kube-system csi-azurefile-node-2rpcc 3/3
Running 0 3m57s
kube-system csi-azurefile-node-4gqkf 3/3
Running 0 4m11s
kube-system csi-azurefile-node-f6k8m 3/3
Running 0 4m16s
kube-system csi-azurefile-node-k72xq 3/3
Running 0 4m8s
kube-system csi-azurefile-node-vx7r4 3/3
Running 0 3m53s
kube-system csi-azurefile-node-zc8kr 3/3
Running 0 4m11s
kube-system csi-azurefile-node-zkl6b 3/3
Running 0 3m57s
kube-system kube-proxy-4fpb6 1/1
Running 0 3m53s
kube-system kube-proxy-6qfbf 1/1
Running 0 4m16s
kube-system kube-proxy-6wnt2 1/1
Running 0 4m8s
kube-system kube-proxy-cspd5 1/1
Running 0 3m57s
kube-system kube-proxy-nsgq6 1/1
Running 0 4m11s
kube-system kube-proxy-qz2st 1/1
Running 0 4m11s
kube-system kube-proxy-zvh9k 1/1
Running 0 3m57s
kube-system metrics-server-6bc97b47f7-ltkkj 1/1
Running 0 5m28s
kube-system tunnelfront-77d68f78bf-t78ck 1/1
Running 0 5m23s
node-feature-discovery node-feature-discovery-master-65dc499cd-fxwb5 1/1
Running 0 3m28s
node-feature-discovery node-feature-discovery-worker-277xc 1/1
Running 0 3m28s
node-feature-discovery node-feature-discovery-worker-4dq5k 1/1
Running 0 3m28s
node-feature-discovery node-feature-discovery-worker-57nb8 1/1
Running 0 3m28s
node-feature-discovery node-feature-discovery-worker-b4lkl 1/1
Running 0 3m28s
node-feature-discovery node-feature-discovery-worker-kslst 1/1
Running 0 3m28s
node-feature-discovery node-feature-discovery-worker-ppjtm 1/1
Running 0 3m28s
node-feature-discovery node-feature-discovery-worker-x5bgf 1/1
Running 0 3m28s
tigera-operator tigera-operator-74c4d9cf84-k7css 1/1
Running 0 5m25s
```

### AKS: Attach a Cluster

About this task

After attaching the cluster, you can use the UI to examine and manage this
cluster. The following procedure shows how to attach an existing Azure
Kubernetes Service (AKS) cluster.

Access Your AKS Clusters

Before you begin

This procedure requires the following items and configurations:

- A fully configured and running Azure AKS cluster with administrative
  privileges.
- The current version NKP Ultimate is installed (Basic Installations by
  Infrastructure on page 72) on your cluster.
- Ensure you have installed kubectl in your Management cluster.

```yaml
Note: This procedure assumes you have an existing and spun up Azure AKS cluster(s) with administrative privileges.
Refer to the Azure site regarding AKS for setup and configuration information.
```

Attach AKS Clusters

Procedure

1. Ensure that the KUBECONFIG environment variable is set to the Management
   cluster before attaching by running:

```bash
export KUBECONFIG=<Management_cluster_kubeconfig>.conf
```

1. Ensure you are connected to your AKS clusters. Enter the following commands
   for each of your clusters.

```bash
kubectl config get-contexts
kubectl config use-context <context for first aks cluster>
```

1. Confirm kubectl can access the AKS cluster.

```bash
kubectl get nodes
```

#### Create a kubeconfig File for your AKS Cluster

About this task

To get started, ensure you have kubectl set up and configured with
ClusterAdmin for the cluster you want to connect to Kommander.

Procedure

1. Create the necessary service account.

```bash
kubectl -n kube-system create serviceaccount kommander-cluster-admin
```

1. Create a token secret for the serviceaccount.

```bash
kubectl -n kube-system create -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
name: kommander-cluster-admin-sa-token
annotations:
kubernetes.io/service-account.name: kommander-cluster-admin
type: kubernetes.io/service-account-token
EOF
```

1. Verify that the serviceaccount token is ready by running this command.

```bash
kubectl -n kube-system get secret kommander-cluster-admin-sa-token -oyaml
```

Verify that the data.token field is populated, as seen in the example output.

```yaml
apiVersion: v1
data:
ca.crt: LS0tLS1CRUdJTiBDR...
namespace: ZGVmYXVsdA==
token: DUMMY_BEARER_TOKEN
kind: Secret
metadata:
annotations:
kubernetes.io/service-account.name: kommander-cluster-admin
kubernetes.io/service-account.uid: b62bc32e-b502-4654-921d-94a742e273a8
creationTimestamp: "2022-08-19T13:36:42Z"
name: kommander-cluster-admin-sa-token
namespace: default
resourceVersion: "8554"
uid: 72c2a4f0-636d-4a70-9f1c-55a75f15e520
type: kubernetes.io/service-account-token
```

1. Configure the new service account for cluster-admin permissions.

```bash
cat << EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
name: kommander-cluster-admin
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: ClusterRole
name: cluster-admin
subjects:
- kind: ServiceAccount
name: kommander-cluster-admin
namespace: kube-system
EOF
```

1. Set up the following environment variables with the access data that is
   needed for producing a new kubeconfig file.

```bash
export USER_TOKEN_VALUE=$(kubectl -n kube-system get secret/kommander-cluster-admin-
sa-token -o=go-template='{{.data.token}}' | base64 --decode)
export CURRENT_CONTEXT=$(kubectl config current-context)
export CURRENT_CLUSTER=$(kubectl config view --raw -o=go-
template='{{range .contexts}}{{if eq .name "'''${CURRENT_CONTEXT}'''"}}
{{ index .context "cluster" }}{{end}}{{end}}')
export CLUSTER_CA=$(kubectl config view --raw -o=go-template='{{range .clusters}}{{if
eq .name "'''${CURRENT_CLUSTER}'''"}}"{{with index .cluster "certificate-authority-
data" }}{{.}}{{end}}"{{ end }}{{ end }}')
export CLUSTER_SERVER=$(kubectl config view --raw -o=go-template='{{range .clusters}}
{{if eq .name "'''${CURRENT_CLUSTER}'''"}}{{ .cluster.server }}{{end}}{{ end }}')
```

1. Confirm these variables have been set correctly.

```bash
export -p | grep -E 'USER_TOKEN_VALUE|CURRENT_CONTEXT|CURRENT_CLUSTER|CLUSTER_CA|
CLUSTER_SERVER'
```

1. Generate a kubeconfig file that uses the environment variable values from
   the previous step.

```yaml
Caution: Nutanix support is unable to recover forgotten credentials. Prevent Kommander UI lockouts with the
following best practices.
```

- Backup the kubeconfig file.
- Save your credentials.
- Configure an IDP (identity provider) instead of using a username and
  password credentials.

```bash
cat << EOF > kommander-cluster-admin-config
apiVersion: v1
kind: Config
current-context: ${CURRENT_CONTEXT}
contexts:
- name: ${CURRENT_CONTEXT}
context:
cluster: ${CURRENT_CONTEXT}
user: kommander-cluster-admin
namespace: kube-system
clusters:
- name: ${CURRENT_CONTEXT}
cluster:
certificate-authority-data: ${CLUSTER_CA}
server: ${CLUSTER_SERVER}
users:
- name: kommander-cluster-admin
user:
token: ${USER_TOKEN_VALUE}
EOF
```

1. This process produces a file in your current working directory called
   kommander-cluster-admin-config. The contents of this file are used in
   Kommander to attach the cluster. Before importing this configuration, verify
   the kubeconfig file can access the cluster.

```bash
kubectl --kubeconfig $(pwd)/kommander-cluster-admin-config get all --all-namespaces
```

#### Finalize attaching your cluster from the UI

About this task

Now that you have the kubeconfig, go to the NKP UI and follow these steps below:

Procedure

From the top menu bar, select your target workspace.

a. On the Dashboard page, select the Add Cluster option in the Actions
dropdown menu at the top right.

b. Select Attach Cluster.

c. Select the No additional networking restrictions card. Alternatively, if
you must use network restrictions, stop following the steps below and see the
Attach a cluster WITH network restrictions.

d. Upload the kubeconfig file you created in the previous section (or copy its
contents) into the Cluster Configuration section.

e. The Cluster Name field automatically populates with the name of the cluster
in the kubeconfig. You can edit this field using the name you want for your
cluster.

f. Add labels to classify your cluster as needed.

g. Select Create to attach your cluster. Next Step

```yaml
Note: If a cluster has limited resources to deploy all the federated platform services, it will fail to stay attached in the
NKP UI. If this happens, ensure your system has sufficient resources for all pods.
```

## GCP Installation Options

For an environment that is on the GCP Infrastructure, install options based on
those environment variables are provided for you in this location.

Remember, there are always more options for custom YAML in the Custom
Installation and Additional Infrastructure Tools section, but this will get
you operative in the most common scenarios.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

For a list of all the NKP supported environment combinations, see Supported
Infrastructure Operating Systems on page 12.

Additional Resource Information Specific to GCP

- Control plane nodes - NKP on GCP defaults to deploying an n2-standard-4
  instance with an 80GiB root volume for control plane nodes, which meets the
  above requirements.
- Worker nodes - NKP on GCP defaults to deploying a n2-standard-8 instance
  with an 80GiB root volume for worker nodes, which meets the above
  requirements.

### GCP Installation

This installation provides instructions to install NKP in an GCP non-air-
gapped environment.

For an environment that is on the GCP Infrastructure, install options are
provided for you in this one location. Remember, there are always more options
for custom YAML in the Custom Installation and Additional Infrastructure Tools
section, but this will get you operating with basic features.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

GCP Prerequisites

Verify that your Google Cloud project does not have the Enable OS Login
feature enabled.

```yaml
Warning: The Enable OS Login feature is sometimes enabled by default in GCP projects. If the OS login feature
is enabled, NIB will not be able to ssh to the VM instances it creates and will not be able to create an image
successfully.
```

To check if it is enabled, use the commands on this page Set and remove custom
metadata | Compute Engine Documentation | Google Cloud to inspect the metadata
configured in your project. If you find the enable-oslogin flag set to TRUE,
you must remove it (or set it to FALSE) to use NIB.

The user creating the Service Accounts needs additional privileges in addition
to the Editor role. For more information, see GCP Roles.

### GCP: Creating an Image

About this task

This procedure describes how to use the Nutanix Image Builder on page 51 (NIB)
to create a Cluster API compliant GCP image. GCP images contain configuration
information and software to create a specific, pre-configured, operating
environment. For example, you can create a GCP image of your current computer
system settings and software. The GCP image can then be replicated and
distributed, creating your computer system for other users.

```yaml
Warning: Google Cloud Platform does not publish images. You must first build the image using Nutanix Image
Builder on page 51. Explore the Customize your Image topic for more options. For more information regarding using
the image in creating clusters, refer to the GCP Infrastructure section of the documentation.
```

Procedure

Follow the steps listed in Building a Custom Image with GCP on page 63.

### GCP: Creating the Management Cluster

About this task

Create a new Google Cloud Platform Kubernetes cluster in a non-air-gapped
environment with the steps below.

Use this procedure to create a self-managed Management cluster with NKP. A
self-managed cluster refers to one in which the CAPI resources and controllers
that describe and manage it are running on the same cluster they are managing.
First, you must name your cluster.

```yaml
Warning: NKP uses the GCP CSI driver as the default storage provider. Use a Kubernetes CSI compatible
storage that is suitable for production.
```

Name Your Cluster

Procedure

1. Give your cluster a unique name suitable for your environment.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the environment variable using
the command.

```bash
export CLUSTER_NAME=<gcp-example>
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by
setting the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

#### Create a GCP Cluster

About this task

Availability zones (AZs) are isolated locations within data center regions
from which public cloud services originate and operate. Because all the nodes
in a node pool are deployed in a single AZ, you may wish to create additional
node pools to ensure your cluster has nodes deployed in multiple AZs.

If you use these instructions to create a cluster on GCP using the NKP default
settings without any edits to configuration files or additional flags, your
cluster is deployed on a three control plane nodes, and four worker nodes.

```yaml
Note: By default, the control-plane Nodes will be created in 3 different zones. However, the default worker Nodes will
reside in a single zone. You might create additional node pools in other zones with the nkp create nodepool
command.
```

> **Note: Google Cloud Platform does not publish images. You must first
> build the image using Nutanix Image Builder.**

Procedure

1. Create an image using Nutanix Image Builder (NIB) and then export the image
   name.

```bash
export IMAGE_NAME=projects/${GCP_PROJECT}/global/images/<image_name_from_nib>
```

1. Ensure your subnets do not overlap with your host subnet because they
   cannot be changed after cluster creation. If you need to change the
   Kubernetes subnets, you must do this at cluster creation. The default
   subnets used in NKP are.

```bash
spec:
clusterNetwork:
pods:
cidrBlocks:
- 192.168.0.0/16
services:
cidrBlocks:
- 10.96.0.0/12
```

1. (Optional) Modify Control Plane Audit logs - Users can make modifications
   to the KubeadmControlplane cluster-api object to configure different kubelet
   options. See the following guide if you wish to configure your control plane
   beyond the existing options that are available from flags.
2. (Optional) Determine what VPC Network to use. All GCP accounts come with a
   preconfigured VPC Network named default, which will be used if you do not
   specify a different network. To use a different VPC network for your
   cluster, create one by following these instructions for Create and Manage
   VPC Networks. Then specify the --network `<new_vpc_network_name>` option on
   the create cluster command below. More information is available on GCP Cloud
   Nat and network flag.
3. Create a Kubernetes cluster. The following example shows a common
   configuration. See dkp create cluster gcp reference for the full list of
   cluster creation options.

```bash
nkp create cluster gcp \
--cluster-name=${CLUSTER_NAME} \
--additional-tags=owner=$(whoami) \
--project=${GCP_PROJECT} \
--image=${IMAGE_NAME} \
--self-managed
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

1. Wait for the cluster control-plane to be ready:

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=20m
```

1. After the objects are created on the API server, the Cluster API
   controllers reconcile them. They create infrastructure and machines. As they
   progress, they update the Status of each object. NKP provides a command to
   describe the current status of the cluster:

```bash
nkp describe cluster -c ${CLUSTER_NAME}
```

Output:

```bash
NAME READY
SEVERITY REASON SINCE MESSAGE
Cluster/gcp-example True
52s
##ClusterInfrastructure - GCPCluster/gcp-example
##ControlPlane - KubeadmControlPlane/gcp-example-control-plane True
52s
# ##Machine/gcp-example-control-plane-6fbzn True
2m32s
# # ##MachineInfrastructure - GCPMachine/gcp-example-control-plane-62g6s
# ##Machine/gcp-example-control-plane-jf6s2 True
7m36s
# # ##MachineInfrastructure - GCPMachine/gcp-example-control-plane-bsr2z
# ##Machine/gcp-example-control-plane-mnbfs True
54s
# ##MachineInfrastructure - GCPMachine/gcp-example-control-plane-s8xsx
##Workers
##MachineDeployment/gcp-example-md-0 True
78s
##Machine/gcp-example-md-0-68b86fddb8-8glsw True
2m49s
# ##MachineInfrastructure - GCPMachine/gcp-example-md-0-zls8d
##Machine/gcp-example-md-0-68b86fddb8-bvbm7 True
2m48s
# ##MachineInfrastructure - GCPMachine/gcp-example-md-0-5zcvc
##Machine/gcp-example-md-0-68b86fddb8-k9499 True
2m49s
# ##MachineInfrastructure - GCPMachine/gcp-example-md-0-k8h5p
##Machine/gcp-example-md-0-68b86fddb8-l6vfb True
2m49s
##MachineInfrastructure - GCPMachine/gcp-example-md-0-9h5vn
```

- A self-managed cluster refers to one in which the CAPI resources and
  controllers that describe and manage it are running on the same cluster they
  are managing. As part of the underlying processing using the --self- managed
  flag, the NKP CLI:
- creates a bootstrap cluster
- creates a managed cluster
- moves CAPI controllers from the bootstrap cluster to the managed cluster,
  making it self-managed
- deletes the bootstrap cluster

To understand how this process works step by step, you can find customizable
steps in GCP Infrastructure under Custom Installation and Additional
Infrastructure Tools.

Cluster Verification

If you want to monitor or verify the installation of your clusters, refer to:
Cluster and NKP Installation Verification on page 1039 and Installing NKP on
page 43.

### GCP: Installing Kommander

About this task

Once you have installed the component of NKP, you will continue with the
installation of the Kommander component that will bring up the UI dashboard.

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

Prerequisites:

- Ensure you have reviewed all Prerequisites for Install.
- Ensure you have a default StorageClass.
- Note the name of the cluster where you want to install Kommander. If you do
  not know the cluster name, use kubectl get nkpclusters -A to display and
  find it.

Create your Kommander Installation Configuration File

Procedure

1. Set the environment variable for your cluster.

```bash
export CLUSTER_NAME=<your-management-cluster-name>
```

1. Copy the kubeconfig file of your Management cluster to your local directory.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} >> ${CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

```bash
nkp install kommander --init > kommander.yaml
```

1. If required: Customize your kommander.yaml. See Kommander Customizations
   page for customization options. Some options include Custom Domains and
   Certificates, HTTP proxy, External Load Balancer, GPU Utilization, and Rook
   Ceph customization for Pre- provisioned environments.
2. Only required if your cluster uses a custom AWS VPC and requires an
   internal load-balancer; set the traefik annotation to create an internal-
   facing ELB.

```bash
apps:
traefik:
enabled: true
values: |
service:
annotations:
service.beta.kubernetes.io/aws-load-balancer-internal: "true"
```

### GCP: Verifying your Installation and UI Log in

About this task

After you build the cluster and you install Kommander, verify your
installation. It waits for all applications to be ready by default.

```yaml
Note: If the Kommander installation fails or you wish to reconfigure applications, you can rerun the install command
to retry the installation.
```

Procedure

Check the installation status:

```bash
kubectl -n kommander wait --for condition=Ready helmreleases --all --timeout 15m
```

> **Note: If you prefer the CLI to not wait for all applications to become
> ready, you can set the --wait=false flag.**

The first wait for each of the helm charts to reach their Ready condition,
eventually resulting in an output resembling below:

```bash
helmrelease.helm.toolkit.fluxcd.io/centralized-grafana condition met
helmrelease.helm.toolkit.fluxcd.io/dex condition met
helmrelease.helm.toolkit.fluxcd.io/dex-k8s-authenticator condition met
helmrelease.helm.toolkit.fluxcd.io/fluent-bit condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-logging condition met
helmrelease.helm.toolkit.fluxcd.io/grafana-loki condition met
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

#### Failed HelmReleases (11)

Procedure

If an application fails to deploy, check the status of a HelmRelease using the
command.

```bash
kubectl -n kommander get helmrelease <HELMRELEASE_NAME>
```

If you find any HelmReleases in a "broken" release state, such as "exhausted"
or "another rollback/release in progress", trigger a reconciliation of the
HelmRelease using the commands.

```bash
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": true}]'
kubectl -n kommander patch helmrelease <HELMRELEASE_NAME> --type='json' -p='[{"op":
"replace", "path": "/spec/suspend", "value": false}]'
```

##### Log in to the UI (7)

Procedure

```bash
nkp open dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

1. Retrieve your credentials:

```bash
kubectl -n kommander get secret dkp-credentials -o go-template='Username:
{{.data.username|base64decode}}{{ "\n"}}Password: {{.data.password|base64decode}}
{{ "\n"}}'
```

1. Retrieve the dashboard URL:

```bash
kubectl -n kommander get svc kommander-traefik -o go-template='https://{{with
index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}{{end}}/dkp/kommander/
dashboard{{ "\n"}}'
```

You should only use these static credentials to access the UI for configuring
an external identity provider. Treat them as backup credentials rather than
use them for normal access.

a. Rotate the dashboard password:

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

b. Retrieve the new dashboard credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

For more information, see Rotating the NKP Dashboard Password on page 308.

You can perform the following operations on Identity Providers:

- Create an Identity Provider
- Temporarily Disable an Identity Provider
- Create Groups

Dashboard UI Functions

After installing the component and building a cluster as well as successfully
installing Kommander and logging into the
UI, you are now ready to customize configurations using the Day 2 Cluster
Operations Management section of the
documentation. The majority of this customization such as attaching clusters
and deploying applications will take place
in the dashboard or UI of NKP. The Day 2 section allows you to manage cluster
operations and their application workloads
to optimize your organization's productivity.

### GCP: Creating Managed Clusters Using the NKP CLI

About this task

After the initial cluster creation, you can create additional clusters from
the CLI. In a previous step, the new cluster was created as Self-managed,
which allows it to be a Management cluster or a stand-alone cluster.
Subsequent new clusters are not self-managed, as they will likely be Managed
or Attached clusters to this Management Cluster.

```yaml
Warning: When creating Managed clusters, you do not need to create and move CAPI cluster objects or install the
Kommander component. Those tasks are only done on Management clusters!
```

Your new managed cluster needs to be part of a workspace under a management
cluster. To make the new managed cluster a part of a Workspace, set that
workspace environment variable.

To make new managed cluster part of a workspace:

Procedure

1. If you have an existing Workspace name, run this command to find the name.

> **Note: If you need to create a new Workspace, follow the instructions to
> Create a New Workspace**

```bash
kubectl get workspace -A
```

1. When you have the Workspace name, set the WORKSPACE_NAMESPACE environment
   variable.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

#### Name Your Cluster (13)

About this task

Each cluster must have an original name.

Perform both steps to name the cluster:

Procedure

1. Give your cluster a unique name suitable for your environment. In GCP it is
   critical that the name is unique, as no two clusters in the same GCP account
   can have the same name.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the environment variable.

```bash
export MANAGED_CLUSTER_NAME=<gcp-additional>
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by
setting the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

#### Create a new GCP Cluster

About this task

Availability zones (AZs) are isolated locations within data center regions
from which public cloud services originate and operate. Because all the nodes
in a node pool are deployed in a single AZ, you may wish to create additional
node pools to ensure your cluster has nodes deployed in multiple AZs.

If you use these instructions to create a cluster on GCP using the NKP default
settings without any edits to configuration files or additional flags, your
cluster is deployed on a three control plane nodes, and four worker nodes.

```yaml
Note: By default, the control-plane Nodes will be created in 3 different zones. However, the default worker Nodes will
reside in a single zone. You might create additional node pools in other zones with the nkp create nodepool
command.
Warning: Google Cloud Platform does not publish images. You must first build the image using Nutanix Image
Builder on page 51 (NIB).
Note: The instructions below tell you how to create a cluster and have it automatically attach to the workspace you set
above. If you do not set a workspace, the cluster will be created in the default workspace, and you will need to take
additional steps to attach to a workspace later. For instructions on how to do this, see Attach a Kubernetes Cluster.
```

Procedure

1. Create an image using Nutanix Image Builder on page 51 (NIB) and then
   export the image name.

```bash
export IMAGE_NAME=projects/${GCP_PROJECT}/global/images/<image_name_from_nib>
```

1. Create a Kubernetes cluster. The following example shows a common
   configuration. Execute this command to create your additional Kubernetes
   cluster using any relevant flags. This will create a new non-self-managed
   cluster that can be managed by the management cluster you created in the
   previous section. For the full list of cluster creation options, see dkp
   create cluster gcp reference.

```bash
nkp create cluster gcp \
--cluster-name=${MANAGED_CLUSTER_NAME} \
--additional-tags=owner=$(whoami) \
--namespace ${WORKSPACE_NAMESPACE} \
--project=${GCP_PROJECT} \
--image=${IMAGE_NAME} \
--kubeconfig=<management-cluster-kubeconfig-path>
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

#### Retrieving the kubeconfig and Exploring New GCP Cluster

Procedure

1. Fetch the kubeconfig file with the command:

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} --kubeconfig <management-
cluster-kubeconfig-path> -n ${WORKSPACE_NAMESPACE} > ${MANAGED_CLUSTER_NAME}.conf
```

1. List the nodes with the following command:

```bash
kubectl --kubeconfig=${MANAGED_CLUSTER_NAME}.conf get nodes
```

1. List the pods with the following command:

> **Note: Wait for the Status to move to Ready while calico-node pods are
> being deployed.**

```bash
kubectl --kubeconfig=${MANAGED_CLUSTER_NAME}.conf get pods -A
```

#### Manually Attach an NKP CLI Cluster to the Management Cluster (12)

About this task

```yaml
Warning: These steps are only applicable if you do not set a WORKSPACE_NAMESPACE when creating a cluster.
If you already set a WORKSPACE_NAMESPACE, then you do not need to perform these steps since the cluster is
already attached to the workspace.
```

When you create a Managed Cluster with the NKP CLI, it attaches automatically
to the Management Cluster after a few moments.

However, if you do not set a workspace, the attached cluster will be created
in the default workspace. To ensure that the attached cluster is created in
your desired workspace namespace, follow these instructions:

Procedure

1. Confirm you have your MANAGED_CLUSTER_NAME variable set with the following
   command.

```bash
echo ${MANAGED_CLUSTER_NAME}
```

1. Retrieve your kubeconfig from the cluster you have created without setting
   a workspace.

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} >
${MANAGED_CLUSTER_NAME}.conf
```

1. You can now either attach it in the UI, link to attaching it to the
   workspace through UI that was earlier, or attach your cluster to the
   workspace you want in the CLI.

> **Note: This is only necessary if you never set the workspace of your
> cluster upon creation.** 4. Retrieve the workspace where you want to
> attach the cluster.

```bash
kubectl get workspaces -A
```

1. Set the WORKSPACE_NAMESPACE environment variable.

```bash
export WORKSPACE_NAMESPACE=<workspace-namespace>
```

1. You need to create a secret in the desired workspace before attaching the
   cluster to that workspace. Retrieve the kubeconfig secret value of your
   cluster.

```bash
kubectl -n default get secret ${MANAGED_CLUSTER_NAME}-kubeconfig -o go-
template='{{.data.value}}{{ "\n"}}'
```

1. This will return a lengthy value. Copy this entire string for a secret
   using the template below as a reference. Create a new attached-cluster-
   kubeconfig.yaml file.

```yaml
apiVersion: v1
kind: Secret
metadata:
name: <your-managed-cluster-name>-kubeconfig
labels:
cluster.x-k8s.io/cluster-name: <your-managed-cluster-name>
type: cluster.x-k8s.io/secret
data:
value: <value-you-copied-from-secret-above>
```

1. Create this secret in the desired workspace.

```bash
kubectl apply -f attached-cluster-kubeconfig.yaml --namespace
${WORKSPACE_NAMESPACE}
```

1. Create this nkpcluster object to attach the cluster to the workspace.

```bash
cat << EOF | kubectl apply -f -
apiVersion: clusters.nkp.nutanix.com/v1alpha1
kind: NKPCluster
metadata:
name: ${MANAGED_CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
capiClusterRef:
name: ${MANAGED_CLUSTER_NAME}
namespace: default
kommanderCluster:
spec:
kubeconfigRef:
name: ${MANAGED_CLUSTER_NAME}-kubeconfig
clusterRef:
capiCluster:
name: ${MANAGED_CLUSTER_NAME}
EOF
```

1. You can now view this cluster in your Workspace in the UI, and you can
   confirm its status by running the command below. It may take a few minutes
   to reach "Joined" status.

```bash
kubectl get nkpclusters -A
```

If you have several Pro Clusters and want to turn one of them into a Managed
Cluster to be centrally administrated by a Management Cluster, see Platform
Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate Managed Cluster
on page 519.
