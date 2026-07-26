# Nutanix Kubernetes Platform Requirements

NUTANIX KUBERNETES PLATFORM REQUIREMENTS

Note the requirements for Nutanix Kubernetes Platform (NKP).

Before you create a Nutanix Kubernetes Platform (NKP) image and deploy the
initial NKP cluster, ensure that you use the supported version of either a
Linux-based or macOS machine and that meets all the prerequisites for the NKP
components.

```yaml
Note: For an air-gapped environment, additional prerequisites are required. First, ensure that you meet all the necessary
conditions for a non-air-gapped environment, and then include the additional prerequisites required for the air-gapped
environment.
```

For more information on the general NKP requirements, see General Nutanix
Kubernetes Platform Requirements on page 45.

For more information on the Konvoy component requirements, see Konvoy
Component Requirements on page 46.

For more information on the Kommander component requirements, seeKommander
Component Requirements on page 48.

Note the general requirements for Nutanix Kubernetes Platform (NKP).

Before using NKP to create a Nutanix cluster, ensure that your environment
meets the following requirements:

- Your host must be a x86_64-based Linux or macOS machine. For Linux hosts,
  cgroups v2 is required and must be enabled on the host.
- Download the NKP binaries from the Nutanix Support Portal.

For more information, see Downloading NKP on page 16.

- Ensure that you install a container engine or runtime based on your
  operating system for setting up the NKP and bootstrap cluster:
- A Docker or Podman container runtime is required.
- For Linux or macOS, a Docker container engine version 27.4.0 is required.

For more information, see Get Docker.

- For Linux machines, a Podman version 4.0 or later is required.

For more information, see Podman Installation Instructions.

For more information on host requirements, see Host Requirements.

- Your environment must include a container registry to store and manage
  container images.
- A Nutanix Prism Central account credentials with the required roles and
  permissions. For more information, see Prism Central Role and Permission
  Requirements.
- NKP uses the Nutanix Container Storage Interface (CSI) Volume Driver 3.0 as
  the default storage provider. For more information on the default storage
  providers, see Default Storage Providers on page 34.

For production environments, ensure that you choose the compatible storage
from any of the available storage options. For more information, see Types of
volumes.

To disable the default StorageClass deployed by Konvoy:

1. Set the default StorageClass to non-default. 2. Set your newly created
   StorageClass as the default.

For more information on changing the default storage class, see Change the
default StorageClass.

## Konvoy Component Requirements

Note the requirements for Nutanix Kubernetes Platform (NKP) Konvoy component.

For NKP and the Nutanix Image Builder to run, the operator machine must meet
the following requirements:

- All Non-air-gapped Environments:

In a non-air-gapped environment, your setup must have two-way access to and
from the internet. The prerequisites for installing NKP in a non-air-gapped
environment are as follows:

- Download the NKP binary on an x86_64-based Linux or macOS machine.

For more information, see Downloading NKP on page 16.

Verify the installed version of NKP for compatibility:

```bash
nkp version
```

- Ensure that you install a container engine or runtime based on your
  operating system for setting up the NKP and bootstrap cluster:
- For Linux or macOS, a Docker container engine version 27.4.0 is required.

For more information, see Get Docker.

- For Linux, a Podman version 4.0 or later is required.

For more information, see Podman Installation Instructions.

For host requirements, see Host Requirements.

- The host running the NKP CLI must have kubectl version 1.35.x installed.

For more information, see kubectl.

- Ensure that you install a Nutanix Image Builder.

For more information, see Nutanix Image Builder on page 51.

- Ensure that you have a valid cloud provider account with configured
  credentials.
- For AWS and Azure, you need the credentials that manage CloudFormation
  stacks, IAM policies, IAM roles, and IAM instance profiles.

For more information, see Configuration and credential file settings in the
AWS CLI.

- For more information on Azure credentials, see Getting started with cluster-
  api-provider-azure.
- Ensure that you have a CLI tool of your cloud provider:
- For aws-cli, see Installing or updating to the latest version of the AWS CLI.
- For googlecloud-cli, see Install the gcloud CL.
- For azure-cli, see How to install the Azure CLI.
- Elastic Kubernetes Service (EKS) and Azure Kubernetes Service (AKS) only:
- You need a management (self-managed) cluster.
- If you follow the instructions in Custom Installation and Additional
  Infrastructure Tools, ensure that you perform the self-managed process on
  your new cluster.
- Pre-provisioned Environments Only:
- Use pre-provisioned hosts with SSH access enabled.
- Configure each host with an unencrypted SSH private key with its
  corresponding public key.
- Use pre-provisioned override files, if necessary.
- vSphere Environments Only: Ensure that you have a valid VMware vSphere
  account with configured credentials.

```yaml
Note: NKP requires permissions for the cloud providers it uses. For more information, see Supported
Infrastructure Operating Systems on page 12.
```

- Additional Prerequisites for Air-gapped Environments Only: In an air-gapped
  environment, your setup is isolated from unsecured networks, such as the
  internet, and therefore requires additional considerations for installation.

If you are installing NKP in an air-gapped environment, configure the
following additional prerequisites:

- For AWS, configure a Linux-based NKP virtual machine (VM) with access to an
  existing virtual private cloud (VPC) instead of an x86_64-based Linux or
  macOS machine.
- Ensure the ability to download artifacts from the internet and then copy
  those artifacts to the NKP deployed VM.
- Ensure that you have an existing local container registry to seed the air-
  gapped environment.
- Ensure to download the complete NKP air-gapped bundle:

For more information, see Downloading NKP on page 16.

- To use a local registry in either an air-gapped or non-air-gapped
  environment, download and extract the complete NKP air-gapped bundle to load
  your registry:

## Kommander Component Requirements

Note the requirements for Nutanix Kubernetes Platform (NKP) Kommander component.

To install the Kommander component of NKP, ensure that your environment meet
the following prerequisites:

| nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ------------------------ | ----------- | ------------------------ |

| nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ------------------------ | ----------- | ------------------------ |

- All Non-air-gapped Environments:

In a non-air-gapped environment, your environment has two-way access to and
from the internet. The following are the prerequisites for installing NKP in a
non-air-gapped environment:

- The CLI version must match the NKP version that you plan to install.
- Ensure that your cluster meets the resource requirements. For more
  information, see Management Cluster Application Requirements and Workspace
  Platform Application Defaults and Resource Requirements.
- Ensure that a default StorageClass is configured in your cluster. The Konvoy
  component is responsible for configuring one. For more information, see
  Default Storage Providers on page 34.
- Ensure that you have a load balancer to route the external traffic.

In the cloud environments, the cloud provider provides information about the
external traffic. For on-premises and vSphere deployments, you can configure
MetalLB or use virtual IP address. For more information, see Load Balancing on
page 637.

```yaml
Note: For more information on customizing your cluster domain or certificate, see Configuring the
Kommander Installation with a Custom Domain and Certificate on page 1001.
```

- Ensure that your site firewall allows connection to GitHub.
- For pre-provisioned on-premises environments:
- Ensure that your environment meet the storage requirements.

For more information, see Storage on page 33, Default Storage Class, and
Workspace Platform Application Defaults and Resource Requirements on page 726.

- Ensure that you add at least 40 GB of raw storage to the worker nodes of
  your cluster.
- Additional Prerequisites for Air-gapped Environments Only:

In an air-gapped environment, your environment is isolated from unsecured
networks, such as the internet, and therefore requires additional
considerations for installation. If you are installing in an air-gapped
environment, configure the following additional prerequisites:

- To use a local registry containing all the required installation images,
  including the Kommander images in an air-gapped environment, download and
  extract the complete NKP air-gapped bundle to load your registry:

For more information, see Registry Mirror Tools on page 1028.

- Connectivity with the clusters attached to the management cluster:
- Both management and attached clusters must connect to the registry.
- The management cluster must connect to the API servers of all the attached
  clusters.
- The management cluster must connect to any load balancers created for
  platform services on the management cluster.

For more information on customizing your cluster domain or certificate, see
Configuring the Kommander Installation with a Custom Domain and Certificate on
page 1001.

| NKP-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ------------------------ | ----------- | ------------------------ |

- For pre-provisioned environments:
- Ensure that your environment meet the storage requirements.
- Ensure that you add at least 40 GB of raw storage to each of your cluster
  worker nodes.
