# Downloading NKP and Getting Started

## Downloading NKP

You can download NKP from the Nutanix Support portal.

Before you begin

Ensure you log in to the Nutanix Portal with the Nutanix credentials.

Procedure

1. From the Nutanix Portal, select the Product Nutanix Kubernetes Platform
   (NKP).
2. Select the NKP binary for either MacOS or Linux OS.
3. Extract the .tar file that is compatible with your OS, as follows.

- For MacOS or Darwin:
- Double-click, or Right-click on the .tar file and open/extract it.
- For Linux, extract either the CLI binary nkp_nkp-version_linux_amd64.tar.gz,
  the air-gapped bundle nkp-air-gapped-bundle_nkp-version_linux_amd64.tar.gz,
  or the full bundle nkp-air-gapped- bundle_nkp-version_linux_amd64.tar.gz.

For example, extract the air-gapped bundle using the following command:

```bash
tar -xzvpf nkp-air-gapped-bundle_nkp-version_linux_amd64.tar.gz
Important: If you are deploying an air-gapped cluster with an internal registry mirror, include the -p flag to
preserve the file permissions on the extracted bundle tar files. Without it, a restrictive system umask can strip
read permissions during extraction. As a result, the deployment hangs at the Waiting for bundles to be pushed to
internal registry step with a permission denied error.
```

You can view the nkp binary in your working directory. Follow the instructions
in Installing NKP on page 43 using these binaries, and then add your license
(Adding a Nutanix Kubernetes® Platform License Through the UI on page 26) to
NKP. If you have problems downloading or installing NKP, contact Nutanix
Support.

## Getting Started with NKP

At Nutanix, we partner with you throughout the entire cloud-native journey as
follows:

About this task

- Help you in getting started with Nutanix Kubernetes Platform (NKP) by
  introducing concepts.
- Guide you with the Basic Installations by Infrastructure on page 72 through
  the NKP software installation and start-up.
- Guide you with the Cluster Operations Management on page 284, which involves
  customizing applications and managing operations.

You can install in multiple ways:

- On Nutanix infrastructure.
- On a public cloud infrastructure, such as Amazon Web Services (AWS), Google
  Cloud Platform (GCP), and Azure.
- On an internal network, on-premises environment, or with a physical or
  virtual infrastructure.
- On an air-gapped environment.
- With or without Federal Information Processing Standards (FIPS) and graphics
  processing unit (GPU).

Before you install NKP:

Procedure

1. Complete the prerequisites (see Nutanix Kubernetes Platform Requirements on
   page 45) required to install NKP.
2. Determine the infrastructure (see Control Plane Nodes and Worker Nodes
   Resource Requirements for Nutanix Kubernetes Platform on page 721) on which
   you want to deploy NKP.
3. After you choose your environment, download NKP, and select the Basic
   Installations by Infrastructure on page 72 for
   your infrastructure provider and environment. The basic installations set up
   the cluster with the Konvoy component and
   then install the Kommander component to access the dashboards through the NKP
   UI. The topics in the Basic Installations
   by Infrastructure on page 72 chapter help you explore NKP and prepare
   clusters
   for production to deploy and enable the
   applications that support Cluster Operations Management on page 284.
4. (Optional) After you complete the basic installation and are ready to
   customize, perform Custom Installation and Additional Infrastructure Tools,
   if required.
5. To prepare the software, perform the steps described in the Cluster
   Operations Management chapter.
6. Deploy and test your workloads.

## NKP Concepts and Terms

NKP is composed of three main components: Konvoy, Kommander, and Nutanix Image
Builder (NIB). These three components work together to provide a single and
centralized control point for an organization's application infrastructure.
NKP empowers organizations to deploy, manage, and scale Kubernetes workloads
in production environments more efficiently.

Each of the three main components specifically manages the following:

- Konvoy is the cluster life cycle manager component of NKP. Konvoy relies on,
  Kubernetes Cluster API and other open-source and proprietary software to
  provide simple cluster life cycle management for conformant Kubernetes
  clusters with networking and storage capabilities.

Konvoy uses industry-standard tools to provision certified Kubernetes clusters
on multiple cloud providers, vSphere, and on-premises hardware in connected
and air-gapped environments. Konvoy contains the following components:

Cluster Manager consists of Cluster API, Container Storage Interface (CSI),
Container Network Interface (CNI), Cluster Autoscaler, Cert Manager, and load
balancers.

For Networking, Kubernetes uses CNI (Container Network Interface) as an
interface between network infrastructure and Kubernetes pod networking. In
NKP, the Nutanix provider and Amazon EKS provider use the Cilium CNI. All
other providers use Calico CNI.

The Konvoy component is installed according to the cluster's infrastructure.
Remember:

1. To install NKP quickly and without much customization, see Basic
   Installations by Infrastructure on page 72. 2. To choose more environments
   and cluster customizations, see Custom Installation and Additional
   Infrastructure Tools.

- Kommander is the fleet management component of NKP. Kommander delivers
  centralized observability, control, governance, unified policy, and better
  operational insights.

In NKP Ultimate, Kommander supports attaching workload clusters and life cycle
management of clusters using Cluster API. NKP Ultimate also offers life cycle
management of applications through FluxCD. Kommander contains the following
components:

- User interface, Security, Observability, Networking, and Application
  Management.
- Platform Applications: Applications such as observability, cost management,
  monitoring, and logging are available with NKP and making NKP clusters
  production-ready right through. Platform applications are a choice of
  selected applications from the open-source community consumed by the
  platform.
- Platform Applications: Monitoring, Logging, Backup or Restore, Policy Agent,
  External DNS, Load Balance, Ingress, SSO, Service Mesh.
- Ultimate Platform Applications: Includes all of the Pro Platform
  applications, plus additional Access Control and Centralized Cost
  Management.
- Catalog Applications: Applications in NKP Ultimate that are deployed to be
  used for customer workloads.

The Kommander component is installed according to the cluster's environment
type. For more information, see Installing Kommander by Environment .

- Nutanix Image Builder (NIB) creates Cluster API-compliant machine images. It
  configures only those images to contain all the necessary software to deploy
  Kubernetes cluster nodes. For more information, see Nutanix Image Builder on
  page 51.

NKP also provide a helpful add-on called NKP Insights. For more information,
see Nutanix Kubernetes Platform Insights Guide on page 1111.

### Cluster Types

Multi-cluster Environment

- Management Cluster (All NKP editions): Is the cluster where you install NKP,
  and it is self-managed. In a multi-cluster environment, the Management
  cluster also manages other clusters. Customers are encouraged to run
  workloads on Managed and Attached clusters, not on the Management cluster
  except in single-cluster environments. For more information, see License
  Packaging.
- Managed Cluster (All NKP editions): Also called an "NKP cluster," this is a
  type of workload cluster that you can create with NKP. The NKP Management
  cluster manages its infrastructure, its life cycle, and its applications.
- Attached Cluster (NKP Ultimate only): This is a type of managed cluster that
  is created outside of NKP but is then connected to the NKP Management
  Cluster so that NKP can manage it's applications. The lifecycle will not be
  managed by NKP.

Figure 2: Multi-cluster Environment

Single-cluster Environment

The initial NKP cluster is a stand-alone cluster. It is self-managed and
capable of handling its own scaling, upgrades, and life-cycle. For more
information, see Self-Managed Cluster on page 20. In this single-cluster
environment, all workloads are run on your single NKP cluster. In distributed
environments with limited or unreliable connections, you can have separate NKP
instances, each with its own license.

If you expect to have more than one NKP cluster, we recommend using an
architecture including an NKP Management cluster and running the applications
in the NKP Managed clusters.

Figure 3: Single-cluster Environment

#### Self-Managed Cluster

- Creates a bootstrap cluster.

Run the following command:

```bash
nkp create bootstrap
```

- Creates a management cluster.

Run the following command:

```bash
nkp create cluster nutanix \
--control-plane-prism-element-cluster=${NUTANIX_CLUSTER} \
--control-plane-subnets=${NUTANIX_SUBNET} \
--control-plane-endpoint-ip=${CONTROL_PLANE_ENDPOINT} \
--control-plane-replicas=3 \
--worker-prism-element-cluster=${NUTANIX_CLUSTER} \
--worker-subnets=${NUTANIX_SUBNET} \
--worker-replicas=4 \
--endpoint="https://${NUTANIX_PRISM_CENTRAL_ENDPOINT}:9440" \
--kubernetes-service-load-balancer-ip-range="${LOAD_BALANCER_IP_RANGE}" \
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-username=${DOCKERHUB_USERNAME} \
--registry-mirror-password=${DOCKERHUB_PASSWORD} \
--cluster-name=${CLUSTER_NAME} \
--control-plane-vm-image="${NIB_IMAGE}" \
--worker-vm-image="${NIB_IMAGE}" \
# export kubeconfig of the cluster
nkp get kubeconfig --cluster-name ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
```

- Deploys CAPI controllers on the management cluster.

Run the following command:

```bash
nkp create capi-components --kubeconfig ${CLUSTER_NAME}.conf
```

- Pivots CAPI resources from the bootstrap cluster to the management cluster,
  making it self-managed.

Run the following command:

```bash
nkp move capi-resources --to-kubeconfig ${CLUSTER_NAME}.conf
```

- Deletes the bootstrap cluster.

Run the following command:

```bash
nkp delete bootstrap
```

#### Network-Restricted Cluster

### CAPI Concepts and Terms

CAPI makes use of a bootstrap cluster for provisioning and managing clusters.
A bootstrap cluster handles the following actions:

- Generating the cluster certificates if they are not otherwise specified.
- Initializing the control plane and managing the creation of other nodes
  until it is complete.
- Joining control plane and worker nodes to the cluster.
- Installing and configuring the networking plugin (CNI), Container Storage
  Interface (CSI) volume provisioners, cluster Autoscaler, and core Kubernetes
  components.

BootstrapData

BootstrapData is machine or node role-specific data, such as cloud
initialization data, used to bootstrap a "machine" onto a node.

For customers using NKP for multi-cluster management, a management cluster
manages the life cycle of workload clusters. As the management cluster, NKP
works with bootstrap and infrastructure providers and maintains cluster
resources such as bootstrap configurations and templates. If you are working
with only one cluster, Kommander will provide you with add-on (platform
application) management for that cluster but not others.

Managed Cluster

A managed cluster is a Kubernetes cluster whose life cycle is managed by a
management cluster. It provides the platform to deploy, execute, and run
workloads.

These additional concepts are essential for understanding the upgrade. They
are part of a collection of Custom Resource Definitions (CRDs) that extend the
Kubernetes API.

ClusterResourceSet

A ClusterResourceSet Kubernetes cluster created by CAPI is functionally
minimal. Crucial components like CSI and CNI are not in the default cluster
spec. A ClusterResourceSet is a custom resource definition (CRD) that can be
used to group and deploy core cluster components after the installation of the
Kubernetes cluster.

When you create a bootstrap cluster, you can find all the components in the
default namespace, and we move them to the managed cluster while making the
cluster self-managed.

Machine

A machine is a declarative specification for a platform or infrastructure
component that hosts a Kubernetes node as a
bare metal server or a VM. CAPI uses provider-specific controllers to
provision and install new hosts that register as
nodes. When you update a machine spec other than for specific values, such as
annotations, status, and labels, the
controller deletes the host and creates a new one that conforms to the latest
spec. This is called machine immutability.
If you delete a machine, the controller deletes the infrastructure and the
node. Provider-specific information is not
portable between providers.

MachineDeployments

Within CAPI, you use declarative MachineDeployments to handle changes to
machines by replacing them like a core Kubernetes Deployment replaces Pods.
MachineDeployments reconcile changes to machine specs by rolling out changes
to two MachineSets (similar to a ReplicaSet), both the old and the newly
updated.

MachineHealthCheck

A MachineHealthCheck (MHC) identifies unhealthy node conditions and initiates
remediation for nodes owned by a MachineSet.

In a MachineHealthCheck, the default value of maxunhealthy is set to 40%. You
can customize this value as per your requirements for self-healing. For more
information, see Configuring Self-healing on page 711.

Related Information

For information on related topics or procedures, see:

- ClusterAPI Book: `<https://cluster-api.sigs.k8s.io/user/concepts.html>`

### Air-Gapped or Non-Air-Gapped Environment

This topic describes an air-gapped and a non-air-gapped environment.

Air-Gapped Environments

An air-gapped environment is a network setup that is isolated from unsecured
networks, such as the internet. Nutanix Kubernetes Platform (NKP) supports
cluster deployment and management in air-gapped environments, allowing
organizations to run workloads securely while shielding infrastructure from
external threats or unauthorized access.

To create an air-gapped cluster in on-premises environments or any other
environment, you must configure access to container images and Helm charts
through one of the following registry types:

- Local Registry Mirror: A local registry mirror is the network-accessible
  container image repository populated by pulling images from public
  registries and storing them locally. It is used in environments that have
  limited or controlled internet access, allowing faster and more reliable
  image retrieval while reducing dependency on external sources.
- Internal Registry Mirror: An internal registry mirror is a container image
  repository hosted on an NKP cluster managed by NKP. The internal registry
  mirror is populated using an air-gapped bundle, allowing Kubernetes clusters
  to pull the required NKP images locally without relying on external network
  connectivity.

Air-gapped environments are designed to securely isolate systems from external
networks. However, there are several methods to perform actions that require
incoming data from other networks, even within such isolated environments.
Air-gapped environments might vary in their level of isolation:

- Fully Isolated: No inbound or outbound network connections.
- Inbound-Only: Clusters can receive data but cannot initiate outbound
  connections.
- Bastion Host Setup: A bastion host acts as a secure gateway between the air-
  gapped environment and external networks, facilitating controlled downloads
  of updates, images, and installation files.

Common industry synonyms include darksite, fettered, disconnected, restricted,
session initiation protocol (SIPREC), and so on.

Non-Air-Gapped Environments

In a non-air-gapped environment, two-way access to and from the Internet
exists. You can create a non-air-gapped cluster on on-premises environments or
any cloud infrastructure.

NKP in a non-air-gapped environment allows you to manage your clusters while
facilitating connections and offering integration with other tools and
systems.

Common Industry Synonyms: Open, accessible (to the Internet), not restricted,
Non-classified Internet Protocol (IP) Router Network (NIPRNet), etc.

### Pre-provisioned Infrastructure

Usage of Pre-provisioned Environments

Pre-provisioned environments is often used in bare metal deployments, where
you deploy your OS (see Cluster Types on
page 19 (such as Red Hat Enterprise Linux (RHEL) or Ubuntu, and so on) on
physical machines. Creating a pre-provisioned
cluster as an Infrastructure Operations Manager, you are responsible for
allocating compute resources, setting up
networking, and collecting IP and Secure Shell (SSH) information to NKP. You
can then provide all the required details
to the pre-provisioned provider to deploy Kubernetes. These operations are
done manually or with the help of other
tools.

In pre-provisioned environments, NKP handles your cluster's life cycle
(installation, upgrade, node management, and so on). NKP installs Kubernetes,
performs monitoring and logging applications, and has its own UI.

The main use cases for the pre-provisioned provider are:

- On-premises clusters.
- Cloud or Infrastructure as a Service (IaaS) environments that do not
  currently have a NKP-supported infrastructure provider.
- Cloud environments, you must use pre-defined infrastructure instead of
  having one of the supported cloud providers create it for you.

In an environment with access to the Internet, you can retrieve artifacts from
specialized repositories dedicated to them, such as docker images from the
DockerHub and Helm Charts from a dedicated Helm Chart repository. However, in
an air-gapped environment, you need local repositories to store Helm charts,
docker images, and other artifacts. Tools such as JFrog, Harbor, and Nexus
handle multiple types of artifacts in a single local repository.

Related Information

For information on related topics or procedures see Pre-provisioned
Installation Options on page 72.

## Licenses

Use this section to add, remove, and review your NKP licenses.

### Feature Support Matrix

> **Note: You cannot downgrade a license after you register it for a cluster.**

NKP licenses are sold by core unit and apply to the vCPUs of all worker nodes
in on-premises, public cloud, or edge deployments. Contact a Nutanix sales
representative.

Applications

Workspace Platform Applications X X

Prometheus X X

Kubernetes Dashboard X X

Reloader X X X

Traefik X X X

Project Level Platform Applications X

Catalog Applications X X

Custom Applications X

Partner Applications X X

Integrated Image Registry X X

OpenCost X

AI OPS

Insights X

AI Navigator X X

NKP MCP Server X X

Cluster Management

LCM Management Cluster X X X

LCM Workload Clusters X X X

Workload Cluster Creation using UI, CLI, or YAML

X X X

| Feature | NKP Starter | NKP Pro | NKP Ultimate |
| ------- | ----------- | ------- | ------------ |

Attaching Workload Cluster X

Upgrade Management Cluster X X X

Upgrade Managed Clusters X X X

Third-Party Kubernetes Management

LCM of EKS Cluster X

LCM of AKS Cluster X

GitOps

Continuous Deployment (FluxCD) X

FluxCD (as an application) X X

UX

NKP CLI X X X

NKP UI X X X

Workspaces Management X

Projects X

Add new Infrastructure Provider X

Logging

Workspace Level Logging X X

Fluentbit X X

Multi-tenant Logging X

Additional Tooling

Backup & Restore based on Velero X X

NVIDIA GPU X X

Cluster Provisioning

NKP on Nutanix AHV X X X

NKP on AWS X X

NKP on Azure X X

NKP on GCP X X

NKP on vSphere X X

Pre-provisioned X X

EKS Provisioning X

Multi-Cloud, Hybrid Cloud (Management and Workload clusters on different
infrastructures)

X

Security

Single Sign On X X X

Policy control using Gatekeeper X X

FIPS Compliant Build X X

| Feature | NKP Starter | NKP Pro | NKP Ultimate |
| ------- | ----------- | ------- | ------------ |

Nutanix Image Builder or Bring your own OS

X X

Nutanix provided Rocky Linux OS Image

X X X

Nutanix provided Ubuntu OS Image X X

Air-Gapped Deployments X X X

RBAC

RBAC - Admin role only X X X

RBAC - Kubernetes X X X

NKP RBAC X X

Customize UI Banners X X

Upload custom Logo X

> **Note:**

- The NKP Ubuntu OS images are for NKP Pro and NKP Ultimate customers only and
  are only permitted to be used for NKP Kubernetes nodes. NKP Starter or Non-
  NKP customers are not permitted to download or use these images.
- The NKP Pro Ubuntu OS images are supported only when using the AHV
  infrastructure provider.

### Adding a Nutanix Kubernetes® Platform License Through the UI

About this task

For licenses purchased directly from D2iQ or Nutanix, you can obtain the
license token from the Nutanix Support Portal, see Generating NKP License
Keys. Insert this token in the last step of the procedure.

When you create an NKP cluster, NKP automatically assigns a default license
key, which you must replace with the one you obtain from the portal. The
default key is either a Starter for AHV installations or a Pro for all other
infrastructure providers. When you apply your license key, NKP installs the
additional applications installed by default with the different NKP license
levels. For more information, see Supported Platform Applications on page 350.

For example, if you apply Pro or Ultimate license key, NKP installs the AI
Navigator App along with the other applications associated with that license
key. NKP installs Centralized Grafana only when you apply an Ultimate license
key.

> **Note:**

- You must be an administrator to add licenses to NKP. Also, when adding a NKP
  Pro or Ultimate license, ensure that your cluster has enough resources to
  accommodate the additional applications that will be deployed.
- If you upgrade the license from NKP Starter to NKP Pro or NKP Ultimate,
  ensure that you size the worker nodes appropriately to support the
  installation of default platform services.

To add the license through NKP user interface, follow these steps:

| Feature | NKP Starter | NKP Pro | NKP Ultimate |
| ------- | ----------- | ------- | ------------ |

Procedure

1. Log into the NKP UI dashboard.
2. In the workspace header drop-down list, select Global.
3. In the navigation menu, select Settings > Licensing.
4. Choose the next step based on your current license and the procured license
   key.

» Default License: If you have a cluster which is at a default license level
(for example, NKP Starter in Nutanix Infrastructure, or NKP Pro in a non-
Nutanix infrastructure), you must select Activate License. Then, enter a valid
license key from either a Nutanix or D2IQ source and select Activate to
activate the license.

» Non-default Nutanix License: If your cluster uses a non-default Nutanix
license (for example, Nutanix Kubernetes® Platform (NKP) Ultimate), use the
Update License option to apply a new license. Enter a valid license key
obtained from the Nutanix Support Portal, and select Update.

Use the license update workflow in the following scenarios:

License renewal: If your cluster already has an NKP Ultimate license and the
license is expiring, update the cluster by applying a new valid NKP Ultimate
license.

Increased core capacity: If your cluster already has an NKP Ultimate license
and you need additional licensed core capacity, apply a new NKP Ultimate
license that supports a higher core count using the same update workflow.

The license is now activated and the license card will display the status as
Valid.

```yaml
Note: If there is an error submitting a license acquired directly from Nutanix, you can activate the license through
kubectl.
```

### Adding a Nutanix Kubernetes® Platform License Using Alternate Methods

Prerequisites

For licenses that you buy from the AWS Marketplace, an AWS administrator must
attach the AWS managed policy AWSLicenseManagerConsumptionPolicy to the
control-plane.cluster-api-provider- aws.sigs.k8s.io role created when
configuring AWS IAM policies. If an administrator does not attach this policy
attached to the role, Nutanix Kubernetes® Platform (NKP) cannot verify the
license information provided in the procedure steps that follow.

The machine onto which you install NKP must meet these requirements:

- Docker installed: NKP uses Kubernetes-in-Docker (Kind) to create a bootstrap
  cluster for creating Management clusters, and thus Docker installation is
  required. Docker is not used to run your Management or managed clusters.
- Active Internet connectivity.
- Existing AWS account.
- AWS Administrator logged into the AWS account used to buy NKP.

Downloading the Container Image and Extracting the Binaries

1. Select a NKP version from the Choose a fulfillment option dropdown when you
   complete the sales transaction in the AWS Marketplace.

Nutanix recommends that you select the latest version. 2. Select Continue to
Launch.

The download instructions appear when you select Usage Instructions. 3.
Complete the steps in each of the procedures under Usage Instructions.

The links in these steps open NKP documentation pages that explain how to set
up AWS for NKP and how to download and install NKP. 4. Expand the Create a
license token and IAM role link in the Container images section of the window.

This gives you access to the Create token button to generate the license token
and IAM role and exposes an inset code window with the token and role
credentials. 5. Use the generated command to log in to AWS using the token and
role you just generated.

> **Note: Ignore this step if you have already configured the AWS CLI with
> valid credentials.**

```yaml
Tip: Using the Copy button at the upper right of this inset code window helps ensure you copy the entire
command.
```

1. Run the commands sequentially using your environment's specific values.:

```bash
aws ecr get-login-password \
--region <insert-region> | docker login \
--username <username> \
--password-stdin <ecr-address>
CONTAINER_IMAGES="<ecr-address>/mesosphere/nutanix-nkp-pro-premium-support:v2.5.0"

for i in $(echo $CONTAINER_IMAGES | sed "s/,/ /g"); do docker pull $i; done
```

This step downloads the container images. 7. On the Linux machine where you
plan to run the NKP CLI cluster, open a terminal window. 8. Run the command,
using your environment's specific values.

This step downloads a container with NKP binaries. 9. Copy the binaries onto
your Linux machine:

```bash
docker run -it --rm -u $(id -u):$(id -g) -v $(pwd):/nkp $CONTAINER_IMAGES
```

You will then see the following output:

```bash
nkp binary is placed in the local directory, to run:
./nkp --help
```

You will now see the nkp binary in your working directory. Follow the
Installing NKP on page 43 instructions using these binaries, and then add your
license to NKP.

Obtaining the Amazon Resource Number (ARN) from the AWS Marketplace UI

You must use the AWS Marketplace user interface to navigate to the license
table and configure its settings to display the ARN for your purchased
license.

1. From the Launch this software page, go to the Product Detail page. 2.
   Select View Subscription button at the upper-right.

> **Tip: You can find this in the blue information box labeled "You have
> access to this product".** 3. From the left navigation pane, select Manage
> subscriptions, then click Manage on the specific license.

The license details page appears. 4. Select the License number hyperlink.

On the license page, select Granted licenses from the left navigation pane and
locate your license in the list. 5. Use the Settings icon in the upper-right
corner to choose which columns appear. 6. Enable the License arn value. 7.
Click Confirm.

The license list appears and the License ARN appears in the last column, ready
for you to copy.

If you have difficulty obtaining your ARN, contact Nutanix Support for
assistance.

Entering an NKP License Through kubectl

You can activate a license acquired from Nutanix directly using the kubectl
utility.

1. Create a secret:

```bash
kubectl create secret generic my-license-secret --from-literal=nutanix-license-
key=NKP-License-Key -n kommander
Note: Replace the value my-license-secret and NKP-License-Key in the command with your actual,
license secret name and Nutanix-provided NKP license token.
```

For example: 2. Create a license object:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: kommander.mesosphere.io/v1beta1
kind: License
metadata:
name: nutanix-license
namespace: kommander
spec:
nutanixLicenseRef:
name: nutanix-license-secret
EOF
```

1. Return to the license page in the NKP UI to see your valid license display.

### Updating a Nutanix Kubernetes® Platform License Through the UI

About this task

Update your license when you receive a new license key or when your current
license expires. You can find your license key in the Nutanix Support Portal
or the D2iQ Support Portal. You can update licenses through the NKP UI.

> **Note: You must have NKP administrator permissions to update licenses.**

Procedure

1. Log in to the NKP UI.
2. In the workspace header dropdown list, select Global.
3. In the sidebar menu, select Settings > Licensing. The Licensing page
   displays your existing license information.
4. On the Licensing page, click Update License.
5. In the New License Key field, enter your new license key.

- kubectl create secret generic test-license --from-literal=nutanix-license-
  key="AEAAQ- xxxxx-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx" -n kommander; "AEAAQ-

| --- | --- |

- _`xxxxx-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx"`_; _`xxxxx-xxxxx-xxxxx-xxxxx-xxxxx-
xxxxx"`_

1. Click Update.

### Enabling Nutanix Kubernetes® Platform Full Stack License on NKP

About this task

The NKP Full Stack (NKPFS) license applies only to Prism Central clusters such
as Cluster API Provider for Nutanix Cloud Infrastructure (CAPX) and Cluster
API Provider for vSphere (CAPV).

Follow these steps to generate and apply the Full Stack license key.

Before you begin

- Ensure that you have access to the NKP UI dashboard. If you do not have
  access, run the following command.

Where kubeconfigfile.conf indicates the kubeconfig file path.

- Ensure that you configure Nutanix credentials that are authorized to run the
  list of clusters API as follows:

```bash
export NUTANIX_USER=<username>
export NUTANIX_PASSWORD=<password>
```

- Verify whether the prism-central-metadata secret exists.

Run the following command in an environment that is already connected to your
Kubernetes cluster through kubectl.

```bash
export PC_SECRET_NAMESPACE=$(kubectl get -n kommander nkpcluster -l
'kommander.d2iq.io/host=true' -o
jsonpath='{.items[0].status.capiClusterRef.namespace}')
kubectl get secret prism-central-metadata -n $PC_SECRET_NAMESPACE -o
jsonpath='{.data}'
# it should print out a map that contains key 'uuid', where the value is a base64
encoded string.
{"uuid":"NGI2YTk3NTYtYTg0Zi00ZGQ3LThkN2UtMTM5N2YxM2UyMWU1"}
```

- If the prism-central-metadata secret does not exist, create a secret using
  the following command with the environment variables.

Replace PC_URL with the actual Prism Central endpoint.

> **Note: The NKP CLI version 2.13.1 and later is required to run the nkp
> create metadata command.**

Ensure that your Nutanix credentials environment variables are set as follows:
NUTANIX_USER and NUTANIX_PASSWORD.

- For existing Full Stack licenses only, to upgrade NKP Kommander components
  (including the licensing module that is updated to support Full Stack
  licensing) to 2.13.x, run the following command.

> **Note: Nutanix supports the Full Stack license with the following versions:**

- NKP 2.13.1 and later

| nkp open dashboard --kubeconfig | kubeconfigfile.conf | Col3 |
| ------------------------------- | ------------------- | ---- |

| nkp create metadata nutanix --endpoint | PC URL \_ | Col3 |
| -------------------------------------- | --------- | ---- |

| nkp upgrade kommander | other application flags | Col3 |
| --------------------- | ----------------------- | ---- |

- AOS versions:
- AOS 6.10.1
- AOS 7.0 and later
- Prism Central 2024.3 and later

Procedure

1. To generate the Full Stack license:

a. Log in to the Nutanix Support portal.

b. On the left navigation pane, select Licenses.

c. From the Manage Licenses drop#down list, select Prism Central or Prism
Element.

d. Click Upload CSF.

```yaml
Note: The cluster summary file (CSF) must be downloaded from the Prism Central that hosts the NKP
Management cluster.
```

For more information, see Downloading a Cluster Summary File From Your Cluster.

e. Select Upload File and upload your cluster summary file.

f. In the Manage Licenses > Select Licenses page, go to the NKP FS `<NKP License Type>` tile.

g. Click Select Licenses.

h. In the Select License Program window, select a license type.

i. Click Save.

j. In the Selecting NKP FS `<NKP License Type>` > Select Clusters page, select
the clusters for which you apply the NKP FS license from the list of clusters.

k. Save your changes.

l. Click Next.

m. In the Manage Licenses > Review and Finish page, verify the license details
and click Confirm. The NKP UI displays the Generating License File progress
bar.

n. Save the license file and click Done. 2. To apply the Full Stack license:

a. Log in to the NKP UI dashboard.

b. In the workspace header drop-down, select Global.

c. In the sidebar menu, select Settings > Licensing.

d. To apply the license key on the NKP UI, follow the procedure described in
Adding a Nutanix Kubernetes® Platform License Through the UI on page 26.

## Commands within a kubeconfig File

This topic specifies some basic recommendations regarding the kubeconfig file
related to target clusters and the -- kubeconfig=`<CLUSTER_NAME>`.conf flag.
For more information, see Kubernetes Documentation.

For kubectl and nkp commands to run, it is often necessary to specify the
environment or cluster in which you want to run them. This also applies to
commands that create, delete, or update a cluster's resources.

There are two options:

Table 12: Table

Export an environment variable from a cluster's kubeconfig file, which sets
the environment for the commands you run after exporting it.

Specify an environment variable for one command at a time by running it with
the -- kubeconfig=`<CLUSTER_NAME>`.conf flag.

Better suited for single-cluster environments. Better suited for multi-cluster
environments.

Single-cluster Environment

In a single-cluster environment, you do not need to switch between clusters to
run commands and perform operations. However, specifying an environment for
each terminal session is still necessary. Hence, the NKP CLI runs the
operations on the NKP cluster and does not accidentally run operations on, for
example, the bootstrap cluster.

To set the environment variable for all your operations using the kubeconfig
file, perform the following steps:

1. When you create a cluster, a kubeconfig file is generated automatically.
   Get the kubeconfig file and write it to the ${CLUSTER_NAME}.conf variable :

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
```

1. Set the context by exporting the kubeconfig file from the source file and
   executing the command for each terminal session using the --kubeconfig file
   except the current session:

```bash
export KUBECONFIG=${CLUSTER_NAME}.conf
```

Multi-cluster Environment

Having multiple clusters means switching between two clusters to run
operations. Nutanix recommends the following approaches:

- Start several terminal sessions, one per cluster, and set the environment
  variable as shown in the single-cluster environment example above, one time
  per cluster.
- Use a single terminal session and run the commands with a flag every time.
  The flag specifies the target cluster for the operation every time so that
  you can run the same command several times but with a different flag.
- Use a flag to reference the target cluster. The
  --kubeconfig=`<CLUSTER_NAME>`.conf flag defines the configuration file for
  the cluster that you configure and try to access.

This is the easiest way to ensure you are working on the correct cluster when
operating and using multiple clusters. If you create additional clusters and
do not store the name as an environment variable, you can enter the cluster
name followed by .conf to access your cluster.

```yaml
Note: Ensure that you run nkp get kubeconfig for each cluster you want to create to generate a
kubeconfig file.
```

Example flag:

```bash
--kubeconfig=azurecluster1.conf
```

Example command with flag:

```bash
nkp install kommander --kubeconfig=azurecluster1.conf
```

| Export an Environment Variable | Specify the Target Cluster in the Command |
| ------------------------------ | ----------------------------------------- |

- (For advanced users only): Use a kubeconfig file to configure access to
  multiple clusters using contexts

It is possible to set up a kubeconfig file to manage access to several
clusters. For more information, refer to
`<<https://kubernetes.io/docs/tasks/access-application-cluster/configure-access->`
multiple-clusters/>.

You can also set your environment variable to multiple kubeconfig files by
merging them. For more information, refer to
`<https://kubernetes.io/docs/concepts/configuration/organize-cluster-access->`
kubeconfig/.

## Storage

This document describes the model used in Kubernetes for managing persistent,
cluster-scoped storage for workloads requiring access to persistent data.

A workload on Kubernetes typically requires the following types of storage:

- Ephemeral Storage
- Persistent Volume
- Objects

Ephemeral Storage

Ephemeral storage, by its name, is ephemeral because it is cleaned up when the
workload is deleted or the container crashes. For example, the following are
examples of ephemeral storage provided by Kubernetes:

Table 13: Types of Ephemeral Storage

EmptyDir volume Managed by kubelet under /var/lib/kubelet

Container logs Typically under /var/logs/containers

Container image layers Managed by container runtime (for example, under
/var/lib/ containerd)

Container writable layers Managed by container runtime (e.g., under
/var/lib/containerd)

Kubernetes automatically manages ephemeral storage and typically does not
require explicit settings. However, you might need to express capacity
requests for temporary storage so that kubelet can use that information to
ensure that each node has enough.

Persistent Volume

Persistent Volumes are storage resources that can be used by the cluster.
Persistent Volumes are volume plug- ins that have lifecycle capabilities that
are independent of any Kubernetes Pod or Deployment. A Kubernetes persistent
volume (PV) is an object that allows pods to access persistent storage on a
storage device and defined via a Kubernetes StorageClass. Unlike regular
volumes, which are transient in nature, PVs are persistent, supporting
stateful application use cases.

You may have stateful workloads requiring persistent storage whose lifecycle
is longer than that of Pods or containers. For instance, a database server
needs to recover database files after it crashes. For those cases, the
workloads need to use PersistentVolumes (PV).

Persistent Volumes are resources that represent storage in the cluster that
has been provisioned by an administrator or dynamically provisioned using
Storage Classes. Unlike ephemeral storage, the lifecycle of a PersistentVolume
is independent of that of the workload that uses it.

| Ephemeral Storage Type | Location |
| ---------------------- | -------- |

The Persistent Volume API objects capture the details of the implementation of
the storage, be that NFS, iSCSI, or a cloud-provider-specific storage system.
In order to use a Persistent Volume (PV), your application needs to invoke a
Persistent Volume Claim (PVC).

Persistent Volume Claim

A persistent volume claim (PVC) is a storage request. A workload that requires
persistent volumes uses a persistent volume claim (PVC) to express its request
for persistent storage. A PVC can request a specific size and Access Modes
(for example, they can be mounted after read/write or many times read-only).

Any workload can specify a PersistentVolumeClaim. For example, a Pod may need
a volume that is at least 4Gi large or a volume mounted under /data in the
container's filesystem. If a PersistentVolume (PV) satisfies the specified
requirements in the PersistentVolumeClaim (PVC), it will be bound to the PVC
before the Pod starts.

Related Information:

- Storage for Applications on page 680 in the Kommander component
- Kubernetes Storage: `<https://kubernetes.io/docs/concepts/storage/>`
- Kubernetes persistent storage design document:
  `<https://github.com/kubernetes/design-proposals-archive/>` tree/main/storage

### Default Storage Providers

When deploying Nutanix Kubernetes Platform (NKP) using a supported cloud
provider (AWS, Azure, or GCP), NKP automatically configures native storage
drivers for the target platform. In addition, NKP deploys a default storage
class for provisioning dynamic volumes creation. For more information, see
Storage Classes and Dynamic Volume Provisioning

The following table lists the driver and default StorageClass for each
supported cloud provisioner:

Table 14: Default StorageClass for Supported Cloud Provisioners

Nutanix 3.7.1 nutanix-csi-driver nutanix-volume

AWS 1.51 aws-ebs-csi-driver ebs-sc

Azure 1.33.5 azuredisk-csi-driver azuredisk-sc

Pre provisioned

2.8.0 local-static-provisioner localvolumeprovisioner

vSphere 3.4.0 vsphere-csi-driver vsphere-raw-block-sc

GCP 1.15.4 gcp-compute-persistent-disk- csi-driver

```bash
csi-gce-pd
Note: NKP uses the local static provisioner as the default storage provider for pre-provisioned clusters. However,
localvolumeprovisioner is not suitable for production use. Use a Kubernetes CSI that is compatible with
storage that is suitable for production.
```

You can choose from any storage option available for Kubernetes. For more
information, see Types of Volumes. To disable the default that NKP deploys,
set the default StorageClass localvolumeprovisioner as non-default. Then, set
the newly created StorageClass to default by

| Cloud Provisioner | Version | Driver | Default Storage Class |
| ----------------- | ------- | ------ | --------------------- |

following the commands in the Changing the default StorageClass topic in the
Kubernetes documentation. For more information, see Default Storage Class.

When a default StorageClass is specified, you can create PVCs without
specifying the StorageClass. For instance, to request a volume using the
default provisioner, create a PVC with the following configurations:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
name: my-pv-claim
spec:
accessModes:
  - ReadWriteOnce
resources:
requests:
storage: 4Gi
```

To start the provisioning of a volume, launch a pod that references the PVC:

```bash
...
volumeMounts:
- mountPath: /data
name: persistent-storage
...
volumes:
- name: persistent-storage
persistentVolumeClaim:
claimName: my-pv-claim
Note: To specify a StorageClass that references a storage policy when making a PVC and specify a name in
storageClassName. If left blank, the default StorageClass is used. For more information, see Class.
```

#### Enabling Expansion of Storage Volumes

About this task

You can configure the allowVolumeExpansion setting in a StorageClass to enable
the expansion of storage volume. This value is set to true by default for NKP
on Nutanix AHV. This value is set to false by default for providers other than
Nutanix. To expand expansion of storage volumes, change the value of
allowVolumeExpansion to true.

To configure the value of allowVolumeExpansion, follow these steps:

Procedure

1. View the StorageClass:

```bash
konvoy@ubuntu:$ kubectl get sc --kubeconfig=$KUBECONFIG
```

The default StorageClass nutanix-volume is displayed.

```bash
NAME PROVISIONER RECLAIMPOLICY VOLUMEBINDINGMODE
ALLOWVOLUMEEXPANSION AGE
nutanix-volume (default) csi.nutanix.com Delete WaitForFirstConsumer
true 20d
```

| StorageClass | nutanix-volume |
| ------------ | -------------- |

1. View the details of the StorageClass in YAML:

```bash
kubectl get sc nutanix-volume -o yaml --kubeconfig=$KUBECONFIG
```

The value of allowVolumeExpansion is false.

```yaml
allowVolumeExpansion: false
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
annotations:
storageclass.kubernetes.io/is-default-class: "true"
creationTimestamp: "2024-11-14T19:24:13Z"
name: nutanix-volume
resourceVersion: "1598"
uid: 9f14bf9f-0bbe-41c1-b572-e5ac47163512
parameters:
csi.storage.k8s.io/controller-expand-secret-name: nutanix-csi-credentials
csi.storage.k8s.io/controller-expand-secret-namespace: ntnx-system
csi.storage.k8s.io/fstype: ext4
csi.storage.k8s.io/node-publish-secret-name: nutanix-csi-credentials
csi.storage.k8s.io/node-publish-secret-namespace: ntnx-system
csi.storage.k8s.io/provisioner-secret-name: nutanix-csi-credentials
csi.storage.k8s.io/provisioner-secret-namespace: ntnx-system
description: CSI StorageClass nutanix-volume for $CLUSTER_NAME
flashMode: DISABLED
hypervisorAttached: ENABLED
storageContainer: ${STORAGE_CONTAINER_NAME}
storageType: NutanixVolumes
provisioner: csi.nutanix.com
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

1. Update the value of allowVolumeExpansion to true:

```bash
kubectl patch sc nutanix-volume -p '{"allowVolumeExpansion":true}' --kubeconfig=
$KUBECONFIG
```

1. Verify if the value of allowVolumeExpansion is updated to true:

```bash
kubectl get sc nutanix-volume -o yaml --kubeconfig=$KUBECONFIG
```

If the value of allowVolumeExpansion is true in YAML, volume expansion is
enabled for the StorageClass. The YAML configuration file is displayed as
follows:

```yaml
allowVolumeExpansion: true
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata
annotations:
storageclass.kubernetes.io/is-default-class: "true"
creationTimestamp: "2024-11-14T19:24:13Z"
name: nutanix-volume
resourceVersion: "1598"
uid: 9f14bf9f-0bbe-41c1-b572-e5ac47163512
parameters:
csi.storage.k8s.io/controller-expand-secret-name: nutanix-csi-credentials
csi.storage.k8s.io/controller-expand-secret-namespace: ntnx-system
csi.storage.k8s.io/fstype: ext4
csi.storage.k8s.io/node-publish-secret-name: nutanix-csi-credentials
csi.storage.k8s.io/node-publish-secret-namespace: ntnx-system
csi.storage.k8s.io/provisioner-secret-name: nutanix-csi-credentials
csi.storage.k8s.io/provisioner-secret-namespace: ntnx-system
description: CSI StorageClass nutanix-volume for $CLUSTER_NAME
flashMode: DISABLED
hypervisorAttached: ENABLED
storageContainer: ${STORAGE_CONTAINER_NAME}
storageType: NutanixVolumes
provisioner: csi.nutanix.com
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
konvoy@ubuntu:$
```

1. Update corresponding value of allowExpansionin the Cluster Resource to be
   consistent with the value of the

allowVolumeExpansion setting in the StorageClass.

```bash
kubectl edit clusters $CLUSTER_NAME -o yaml --kubeconfig=$KUBECONFIG
```

### Change or Manage Multiple StorageClasses

The default StorageClass provisioned with Nutanix Kubernetes Platform (NKP) is
suitable for production but if your workload has different requirements, you
can create additional StorageClass types with specific configurations. You can
change the default StorageClass by referring to the Change the default
StorageClass section in Kubernetes web site.

Driver Information

Below is infrastructure provider CSI driver specifics.

Amazon Elastic Block Store (EBS) CSI Driver

NKP EBS default StorageClass:

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
annotations:
storageclass.kubernetes.io/is-default-class: "true" # This tells kubernetes to make
this the default storage class
name: ebs-sc
provisioner: ebs.csi.aws.com
reclaimPolicy: Delete # volumes are automatically reclaimed when no longer in use and
PVCs are deleted
volumeBindingMode: WaitForFirstConsumer # Physical volumes will not be created until a
pod is created that uses the PVC, required to use CSI's Topology feature
parameters:
csi.storage.k8s.io/fstype: ext4
type: gp3 # General Purpose SSD
```

NKP deploys with gp3 (general purpose SSDs) EBS volumes.

- Driver documentation: aws-ebs-csi-driver
- Volume types and pricing: volume types

Nutanix CSI Driver

NKP default storage class for Nutanix supports dynamic provisioning of block
volumes.

- Driver documentation: Nutanix CSI Driver Configuration
- Nutanix Volumes documentation: Nutanix Creating a Storage Class - Nutanix
  Volumes
- Hypervisor Attached Volumes documentation: Nutanix Creating a Storage Class
  - Hypervisor Attached Volumes

The CLI and UI allow you to enable or disable Hypervisor Attached volumes. The
selection passes to the CSI driver's storage class. See Manage Hypervisor.

```yaml
allowVolumeExpansion: true
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
name: default-hypervisorattached-storageclass
parameters:
csi.storage.k8s.io/fstype: file-system type
hypervisorAttached: ENABLED | DISABLED <========== Enabled by Default
flashMode: ENABLED | DISABLED
storageContainer: storage-container-name
storageType: NutanixVolumes
provisioner: csi.nutanix.com
reclaimPolicy: Delete | Retain
mountOptions:
-option1
-option2
```

Azure CSI Driver

NKP deploys with StandardSSD_LRS for Azure Virtual Disks.

- Driver documentation: azuredisk-csi-driver
- Volume types and pricing: volume types
- Specifics for Azure using Pre-provisioning can be found here: Pre-
  provisioned Azure-only Configurations

vSphere CSI Driver

NKP default storage class for vSphere supports dynamic provisioning and static
provisioning of block volumes.

- Driver documentation: VMware vSphere Container Storage Plug-in Documentation
- Specifics for using vSphere storage driver: Using vSphere Container Storage
  Plug-in

Pre-provisioned CSI Driver

In a Pre-provisioned environment, NKP will also deploy a CSI-compatible driver
and configure a default StorageClass - localvolumeprovisioner. For more
information, see Pre-provisioned Infrastructure on page 23.

- Driver documentation: local-static-provisioner

NKP uses (localvolumeprovisioner) as the default storage provider for a pre-
provisioned environment. However, localvolumeprovisioner is not suitable for
production use. Use an alternate compatible storage that is suitable for
production. See local-static-provisioner and Kubernetes CSI.

To disable the default that Konvoy deploys, set the default StorageClass
localvolumeprovisioner as non-default. Then, set your newly created
StorageClass by following the steps in the Kubernetes documentation: See
Change the default StorageClass. You can choose from any of the storage
options available for Kubernetes and make your storage choice the default
storage. See Storage choice

Ceph can also be used as CSI storage. For information on how to use Rook Ceph,
see Rook Ceph in NKP on page 681.

GCP CSI Driver

This driver allows volumes backed by Google Cloud Filestore instances to be
dynamically created and mounted by workloads.

- Driver documentation: gcp-filestore-csi-driver
- Persistent volumes and dynamic provisioning: volume types

### Driver Information

All default drivers implement the Container Storage Interface (CSI). For more
information, see `<https://github.com/>` container-storage-
interface/spec/blob/master/spec.md. The CSI provides a common abstraction to
container orchestrators for interacting with storage subsystems of various
types. Each driver has specific configuration parameters which effect PV
provisioning.

```yaml
Note: StorageClass parameters cannot be changed after creation. To use a different volume configuration, you
must create a new StorageClass.
```

Amazon Elastic Block Store (EBS) CSI Driver

NKP EBS default StorageClass:

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
annotations:
storageclass.kubernetes.io/is-default-class: "true" # This tells kubernetes to make
this the default storage class
name: ebs-sc
provisioner: ebs.csi.aws.com
reclaimPolicy: Delete # volumes are automatically reclaimed when no longer in use and
PVCs are deleted
volumeBindingMode: WaitForFirstConsumer # Physical volumes will not be created until a
pod is created that uses the PVC, required to use CSI's Topology feature
parameters:
csi.storage.k8s.io/fstype: ext4
type: gp3 # General Purpose SSD
```

NKP deploys with gp3 (general purpose SSDs) EBS volumes.

- Driver documentation: aws-ebs-csi-driver
- Volume types and pricing: volume types

Nutanix CSI Driver

NKP default storage class for Nutanix supports dynamic provisioning of block
volumes. NKP uses Nutanix Volumes for the default storage class by default.
You can also use Files Storage.

- Driver documentation: Nutanix CSI Driver Configuration
- Nutanix Volumes documentation: Nutanix Creating a Storage Class - Nutanix
  Volumes
- Hypervisor Attached Volumes documentation: Nutanix Creating a Storage Class
  - Hypervisor Attached Volumes

The CLI and UI allow you to enable or disable Hypervisor Attached volumes. The
selection passes to the CSI driver's storage class. See Manage Hypervisor.

```yaml
allowVolumeExpansion: true
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
name: default-hypervisorattached-storageclass
parameters:
csi.storage.k8s.io/fstype: file-system type
hypervisorAttached: ENABLED | DISABLED <==========
flashMode: ENABLED | DISABLED
storageContainer: storage-container-name
storageType: NutanixVolumes
provisioner: csi.nutanix.com
reclaimPolicy: Delete | Retain
mountOptions:
-option1
-option2
```

Azure CSI Driver

NKP deploys with StandardSSD_LRS for Azure Virtual Disks.

- Driver documentation: azuredisk-csi-driver
- Volume types and pricing: volume types
- Specifics for Azure using Pre-provisioning can be found here: Pre-
  provisioned Azure-only Configurations

vSphere CSI Driver

NKP default storage class for vSphere supports dynamic provisioning and static
provisioning of block volumes.

- Driver documentation: VMware vSphere Container Storage Plug-in Documentation
- Specifics for using vSphere storage driver: Using vSphere Container Storage
  Plug-in

Pre-provisioned CSI Driver

In a Pre-provisioned environment, NKP will also deploy a CSI-compatible driver
and configure a default StorageClass - localvolumeprovisioner. For more
information, see Pre-provisioned Infrastructure on page 23.

- Driver documentation: local-static-provisioner

NKP uses (localvolumeprovisioner) as the default storage provider for a pre-
provisioned environment. However, localvolumeprovisioner is not suitable for
production use. Use an alternate compatible storage that is suitable for
production. See local-static-provisioner and Kubernetes CSI.

To disable the default that Konvoy deploys, set the default StorageClass
localvolumeprovisioner as non-default. Then, set your newly created
StorageClass by following the steps in the Kubernetes documentation: See
Change the default StorageClass. You can choose from any of the storage
options available for Kubernetes and make your storage choice the default
storage. See Storage choice

Ceph can also be used as CSI storage. For information on how to use Rook Ceph,
see Rook Ceph in NKP on page 681.

GCP CSI Driver

This driver allows volumes backed by Google Cloud Filestore instances to be
dynamically created and mounted by workloads.

- Driver documentation: gcp-filestore-csi-driver
- Persistent volumes and dynamic provisioning: volume types

Related Information

- Kubernetes Storage: `<https://kubernetes.io/docs/concepts/storage/>`
- Kubernetes CSI Storage Drivers: `<<https://kubernetes->`
  csi.github.io/docs/drivers.html>
- Kubernetes Local Persistent Volumes:
  `<https://kubernetes.io/blog/2019/04/04/kubernetes-1.14-local->` persistent-
  volumes-ga/
- Persistent Volumes: `<<https://kubernetes.io/docs/concepts/storage/persistent->`
  volumes/#class-1>

### Provisioning a Static Local Volume

About this task

You can choose from any of the storage options available for Kubernetes. To
disable the default that NKP deploys, set the default StorageClass
localvolumeprovisioner to non-default. Then, set the newly created
StorageClass by following the steps in the Kubernetes documentation (see
Change the Default Storage Class).

For the Pre-provisioned infrastructure, the localvolumeprovisioner component
uses the local volume static provisioner to manage persistent volumes for pre-
allocated disks. For more information, see Local Static Provisioner. The
volume static provisioner does this by watching the /mnt/disks folder on each
host and creating persistent volumes in the localvolumeprovisioner storage
class for each disk it discovers in this folder.

For additional NKP documentation regarding StorageClass, see Default Storage
Providers on page 34.

```yaml
Note: When creating a pre-provisioned infrastructure cluster, NKP uses localvolumeprovisioner as the default
storage provider. However, localvolumeprovisioner is not suitable for production use. Use Kubernetes CSI to
check for compatible storage suitable for production. For more information, see Types of volumes.
```

Before starting, verify the following:

- You can access a Linux, macOS, or Windows computer with a supported OS
  version.
- You have a provisioned NKP cluster that uses the localvolumeprovisioner
  platform application but has not added any other NKP applications to the
  cluster yet.

This distinction between provisioning and deployment is important because some
applications depend on the storage class provided by the
localvolumeprovisioner component and can fail to start if not configured.

To provision the cluster and a volume, perform the following steps:

Procedure

1. Create a pre-provisioned cluster by following the steps outlined in the
   pre-provisioned infrastructure topic. As volumes are created or mounted on
   the nodes, the local volume provisioner detects each volume in the /mnt/
   disks directory. It adds it as a persistent volume with the
   localvolumeprovisioner StorageClass. For more information, see the
   documentation regarding Kubernetes Local Storage.
2. Create at least one volume in /mnt/disks on each host. For example, mount a
   tmpfs volume.

```bash
mkdir -p /mnt/disks/example-volume && mount -t tmpfs example-volume /mnt/disks/
example-volume
```

1. Verify the persistent volume by running the following command.

```bash
kubectl get pv
```

The command displays output similar to the following:

```bash
NAME CAPACITY ACCESS MODES RECLAIM POLICY STATUS CLAIM
STORAGECLASS REASON AGE
local-pv-4c7fc8ba 3986Mi RWO Delete Available
localvolumeprovisioner 2s
```

1. Claim the persistent volume using a PVC by running the following command.

```bash
cat <<EOF | kubectl create -f -
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
name: example-claim
spec:
accessModes:
- ReadWriteOnce
resources:
requests:
storage: 100Mi
storageClassName: localvolumeprovisioner
EOF
```

1. Reference the persistent volume claim in a pod by running the following
   command.

```bash
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
name: pod-with-persistent-volume
spec:
containers:
- name: frontend
image: nginx
volumeMounts:
- name: data
mountPath: "/var/www/html"
volumes:
- name: data
persistentVolumeClaim:
claimName: example-claim
EOF
```

1. Verify the persistent volume claim using the command.

```bash
kubectl get pvc
```

The command displays output similar to the following:

```bash
NAME STATUS VOLUME CAPACITY ACCESS MODES STORAGECLASS
AGE
example-claim Bound local-pv-4c7fc8ba 3986Mi RWO
localvolumeprovisioner 78s
```

And you can also check the persistent volume:

```bash
NAME CAPACITY ACCESS MODES RECLAIM POLICY STATUS CLAIM
STORAGECLASS REASON AGE
local-pv-4c7fc8ba 3986Mi RWO Delete Bound default/
example-claim localvolumeprovisioner 15m
```

Upon deletion of the persistent volume claim, the corresponding persistent
volume resource uses the Delete reclaim policy, which removes all data on the
volume.

## Installing NKP

The topic lists the basic package requirements for your environment to perform
a successful installation of Nutanix Kubernetes Platform (NKP). Next, install
NKP, and then you can begin any custom configurations based on your
environment.

About this task

Perform the following steps to install NKP:

Procedure

1. Install the required packages. In most cases, you can install the required
   software using your preferred package manager. For example, on a macOS
   computer, use Homebrew (see Homebrew Documentation) to install kubectl.

```bash
brew install kubernetes-cli
Note: The required packages depend on the chosen infrastructure provider. To select the provider and continue
with the installation, see Basic Installations by Infrastructure.
```

a. Check the Kubernetes client version. Many important Kubernetes functions do
not work if your client is outdated. You can verify the version of kubectl you
have installed to check whether it is supported by running the following
command.

```bash
kubectl version --short=true
```

b. Check the Supported Kubernetes Versions section in the NKP Release Notes
for a specific NKP version after finding your version with the preceding
command.

c. Update your kubectl versions to the Kubernetes version used by NKP. 2. For
air-gapped environments, create a bastion
host for the cluster nodes to use within the air-gapped network. The bastion
host needs access to a local registry
instead of an Internet connection to export images. The recommended template
naming pattern is ../folder-
name/NKP-e2e-bastion-template or similar. Each infrastructure provider has its
own set of bastion host instructions. For
specific details of your provider, see the respective provider's site for more
information: Azure (see
`<https://learn.microsoft.com/en-us/azure/bastion/>` quickstart-host-portal, AWS
(see
`<https://aws.amazon.com/solutions/implementations/linux-bastion/>`, GCP, or
vSphere Security. 3. Download NKP. For more
information, see Downloading NKP on page 16. 4. Create NKP machine images by
downloading the Nutanix Image Builder (NIB)
and extracting it.

» For Nutanix AHV deployments, use NKP CLI to create a new OS image or use the
pre-built image. For more information, see Nutanix Kubernetes Platform
Installation Prerequisites on page 719.

» For non-Nutanix AHV deployments, download NIB and create new images. 5.
Verify that you have valid infrastructure provider security credentials to
deploy the cluster.

```yaml
Note: This step regarding the provider security credentials is not required if you install NKP using Pre-
provisioned Infrastructure on page 761.
```

1. Start NKP cluster installation on your infrastructure. For more
   information, see Basic Installations by Infrastructure on page 72. To use
   customized YAML and other advanced features, see Custom Installation and
   Infrastructure Tools on page 696.
2. For non-Nutanix AHV deployments: Configure the Kommander component by
   initializing the configuration file under the Kommander Installer
   Configuration File component of NKP. For more information, see Kommander
   Installation Based on Your Environment on page 979. For Nutanix AHV, the NKP
   UI (Kommander) is installed automatically.
3. (Optional) Test operations by deploying a sample application, customizing
   the cluster configuration, and checking the status of cluster components.
4. Initialize the configuration file under the Kommander Installer
   Configuration File component of NKP. For more information, see Initializing
   a Kommander Installer Configuration File on page 996. You can test
   operations by deploying a simple, sample application, customizing the
   cluster configuration, or checking the status of cluster components.

What to do next

Here are some links to the NKP installation-specific information:

- To view supported Kubernetes versions, see Supported Kubernetes Versions
  section in the NKP Release Notes.
- To view the list of NKP versions and compatibility software, see Nutanix
  Image Builder on page 51.
- For details about default storage providers and drivers, see Default Storage
  Providers.
- For supported FIPS builds, see Deploying a Cluster in FIPS mode.
