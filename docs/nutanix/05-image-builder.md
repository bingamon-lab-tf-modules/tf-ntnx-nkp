# Nutanix Image Builder

You can add images in the following ways:

- Use an image provided by Nutanix, for NKP on Nutanix Infrastructure. For
  more information, see Using an Image provided by Nutanix on page 51
- Build your own customized image for NKP on any of the supported
  Infrastructure Providers.

## Using an Image provided by Nutanix

Nutanix provides pre-built OS images with the tools and configurations
required for NKP Kubernetes cluster deployment. These images are supported
exclusively on Nutanix Infrastructure and eliminate the need to build custom
images.

Before you begin

Ensure that you meet the following prerequisites:

- AMD64 architecture.
- Subscribe to one of the following NKP licenses:
- NKP Starter
- NKP Pro
- NKP Ultimate

About this task

Here are some of the features of Pre-built images:

- Base OS with Kubernetes tools and configurations.
- CIS-Hardened: Center for Internet Security (CIS) Level 1 compliance
  (available only as pre-built images)

```yaml
Note: The operating system layer in the pre-built image is hardened to CIS Level 1, while the NKP and Kubernetes
components follow CIS Level 2 hardening guidelines.
```

The two pre-built image variants available are:

- Rocky Linux 9.6
- Ubuntu 24.04 LTS

The differences between pre-built and custom images are listed in the
following table:

Table 15: Differences between Pre-built and Custom Images

To use the image provided by Nutanix, follow these steps:

Procedure

1. Download the image from the Nutanix Support Portal.

| Characteristic Feature | Pre-built Images | |
| Custom Images | | |

|     |     |     |
| --- | --- | --- |

- Availability; Immediately available for deployment; Requires build time and
  process
- Configuration Control; Standard Nutanix-tested configurations; Full control
  over packages, configurations, and customizations
- Maintenance; Regular updates and security patches provided by Nutanix;
  User-managed updates and maintenance
- Customization; Limited to available variants; Flexibility for organization-
  specific requirements
- Use Cases; Standard deployments with common requirements; Specialized
  workloads, custom applications, or unique compliance needs

| CIS Hardening | Supported |
| Not supported | |
| | |
| FIPS Compliance | Not supported |
| Supported RHEL 8.10 and 9.6 | |

- GPU Support; The Ubuntu out of the box (OOTB) is supported for both NVIDIA
  GPU Passthrough and NVIDIA GRID Virtual GPU. The Rocky Linux OOTB image is
  not supported.; Supported NVIDIA GPU drivers can be pre- installed
- Application Integration; Standard compatibility; Custom applications and
  dependencies can be pre- installed
- Deployment Speed; Faster initial deployment; Slower initial deployment due
  to build process
- Optimization; Optimized for general-purpose usage; Optimized for specific
  workload requirements

1. Upload the image to Prism Central.

For information on how to upload images to Prism Central, see Importing Images
to Prism Central.

> **Note: Do not rename the image downloaded from the Nutanix Portal.**

For steps on creating a cluster, and more information, see Creating the
Nutanix Kubernetes Platform Management Cluster using CLI on page 740.

## Building a Custom Image with Nutanix

You can build your own customized image based on your requirements.

Before you begin

Ensure that you meet the following prerequisites:

- For container runtime, you must install a recent version of Docker or Podman.
- For Nutanix Kubernetes Platform (NKP) CLI, ensure that your environment is
  on Linux or macOS with AMD64.
- Export Nutanix Prism Central credentials such as NUTANIX_USERNAME and
  NUTANIX_PASSWORD as environment variables.
- Ensure that you subscribe to one of the NKP licenses such as Pro and
  Ultimate. Custom images are not supported on the NKP Starter license
- Base OS image can be built from ISO or cloud image. If using ISO, ensure the
  minimum prerequisites are met.
- Following are the minimum requirements for the base OS image:
- The source image must be in qcow2 or .img format
- The default user must have sudo privileges
- Ensure that you install and enable the SSH server
- Ensure that you install and configure cloud-init
- Ensure that you install Python version 3.x and it is accessible
- Ensure at least 20 GB of disk space on the root file system is available
- Image must use UEFI Boot type
- Ensure that no existing Kubernetes components are present

For more information on the supported operating system, see Supported
Infrastructure Operating Systems on page 12.

- Following are the additional prerequisites for creating a Nutanix image
  builder (NIB) image:
- Ensure that there is a network connectivity (DHCP or static)
- Verify DNS resolution is working
- Ensure remote repositories are accessible over network, if not air-gapped
- Import the base OS image to Prism Central.

For more information, see Importing Images to Prism Central in Prism Central
Infrastructure Guide.

> **Note:**

- You cannot use out of the box (OOTB) images downloaded from Nutanix Support
  Portal or already created NIB images as a baseOS image.

About this task

To create a custom OS image, you can use the nkp create image nutanix command
with required flags, or follow the comprehensive procedure below to configure
all options using the environment variables:

Procedure

1. Open the terminal with access to NKP CLI.
2. (Required only for air-gapped Environment): Run the following command:

Replace path_to_nkp-image-builder_tar_file with the path to the NKP Image
Builder container image tarball.

```yaml
Note: This step is only required for air-gapped environments. The container image is included in the NKP air-
gapped bundle downloaded from the Nutanix portal.
```

1. Choose the operating system:

```bash
export OS_TYPE=Operating System Type
```

For more information, see Supported Infrastructure Operating Systems on page 12. 4. Provide the Prism Central endpoint, and optionally the Prism Central
custom port:

```bash
export NUTANIX_ENDPOINT=URL of Prism Central Endpoint
export NUTANIX_PORT=Custom Prism Central port
```

- Replace URL of Prism Central Endpoint with the URL of Prism Central endpoint.

By default, the NKP CLI uses the standard port for Prism Central. Use the
NUTANIX PORT variable if your Prism Central uses a non-standard port.

The NKP CLI uses the Prism Central API to create the OS image, and this API is
hosted at the Prism Central endpoint.

The endpoint must be in one of three formats:

- host
- host:port
- A valid URL: For example, `<https://host:port>`
- Replace Prism Central port with the custom port number for Prism Central.
  The default value is 9440.

1. Provide the Prism Central credentials:

| docker load --input | path to nkp-image-builder tar file \_ \_ \_ \_ | Col3 |
| ------------------- | ---------------------------------------------- | ---- |

| export NUTANIX USER= \_ | Prism Central Username | Col3 |
| ----------------------- | ---------------------- | ---- |

Replace

- Prism Central Username with the Prism Central username.
- Prism Central Password with the Prism Central password.

The NKP CLI needs a username and password to access Prism Central if
authentication is required. 6. (Optional) Access an HTTPS Prism Central
endpoint without a trusted Certificate Authority (CA) certificate:

```bash
export INSECURE=true
```

The NKP CLI can only verify server certificates signed by a trusted CA. Ensure
that you allow insecure access to the Prism Central endpoint if the Prism
Central server certificate is not signed by a trusted CA certificate, and use
HTTPS to access the endpoint.

If the Prism Central endpoint uses a self-signed CA certificate, the CA
certificate is untrusted. 7. Choose the name of a Prism Element cluster:

Replace Name of Prism Central Cluster with the name of the Prism Element
cluster.

The system creates the VM for building the OS image in the Prism Element
cluster. 8. Choose the name of a subnet associated with the Prism Element
cluster

Replace Subnet name or UUID with the name or UUID of the subnet.

The VM used for building the OS image is assigned an IP address from this
subnet.

> **Note: Ensure that the subnet is in the Prism Element cluster that you
> selected in the previous step.** 9. Choose a base source image:

Replace Base Image name or UUID or URL with the name, UUID, or URL of the base
source image.

The Nutanix Image Builder uses this base image to create the NKP compatible OS
image.

> **Note: For RHEL-8.10, you must provide a source image using this
> variable.** 10. (Optional) Create a FIPS-compliant image:

```bash
export FIPS_ENABLED=true
```

The Nutanix Image Builder creates a FIPS-compliant OS image. For more
information, see Supported Infrastructure Operating Systems on page 12 11.
(Required for air-gapped environment and optional for non-air-gapped
environment) Create a package bundle:

NKP requires Operating System packages to be available in the base image.
These packages are available in the package repositories accessible over the
internet. As air-gapped environments are restricted from accessing these
package repositories, you must first create a package bundle where the
repositories can be accessed. Then, transfer this bundle to an air-gapped
environment to build the OS image in an air-gapped environment.

Download the NKP air-gapped bundle from the Nutanix portal. For more
information, see Downloading NKP on page 16. This air-gapped bundle contains
the NKP artifacts to build the image. Run the following command

| export NUTANIX PASSWORD= \_ | Prism Central Password | Col3 |
| --------------------------- | ---------------------- | ---- |

| export NUTANIX CLUSTER= \_ | Name of Prism Central Cluster | Col3 |
| -------------------------- | ----------------------------- | ---- |

| export SUBNET= | Subnet name or UUID | Col3 |
| -------------- | ------------------- | ---- |

| export SOURCE IMAGE= \_ | Base Image name or UUID or URL | Col3 |
| ----------------------- | ------------------------------ | ---- |

in an environment with internet access to fetch and add the operating system
packages, to create a package bundle for NKP.

```bash
nkp create package-bundle ${OS_TYPE} --artifacts-directory nkp-nkp-version/image-
artifacts/
${FIPS_ENABLED:+--fips}
```

The package bundle contains all the necessary packages and artifacts required
to build an NKP compatible OS image in an air-gapped environment.

```yaml
Note: Ensure the nkp create package-bundle command is executed from a machine that has access to
the package repositories hosted by the OS vendor. You must refer to documentation from the OS vendor for the
list of endpoints that must be allowed to be accessed before you execute this command.
```

1. (Required for air-gapped environment and optional for non-air-gapped
   environment) Set the artifacts directory:

The artifacts directory contains the packages and artifacts required to build
the OS image. 13. (Optional) Configure a bastion host for air-gapped
environments:

```bash
export BASTION_HOST=IP or hostname of bastion VM
export BASTION_USERNAME=SSH user on bastion
export BASTION_PRIVATE_KEY_FILE=Path to SSH private key file
```

Replace:

- IP or hostname of bastion VM with the IP address or hostname of the bastion
  VM.
- SSH user on bastion with the SSH username on the bastion VM.
- Path to SSH private key file with the location of the SSH private key file.

In an air-gapped environment, the NKP CLI uses a bastion host to access the VM
that builds the OS image. 14. (Optional) Create an image for GPU workloads:

Replace Name of GPU attached to the cluster with the name of the GPU.

The Nutanix Image Builder installs the necessary GPU drivers in the OS image. 15. (Optional) Create an image for vGPU workloads:

```bash
export GPU_NAME=Name of GPU attached to the cluster
export VGPU_RUNFILE=Path to vGPU driver runfile
```

Replace:

- Name of GPU attached to the cluster with the name of the GPU.
- Path to vGPU driver runfile with the path to the vGPU driver runfile.

The Nutanix Image Builder installs the necessary vGPU drivers in the OS image.

| export ARTIFACTS DIRECTORY=nkp- \_ | nkp-version | /image-artifacts/ |
| ---------------------------------- | ----------- | ----------------- |

| export GPU NAME= \_ | Name of GPU attached to the cluster | Col3 |
| ------------------- | ----------------------------------- | ---- |

1. (Optional) Provide container image bundles for air-gapped environments:

```bash
export IMAGE_BUNDLE=./nkp-${nkp-version}/container-images/konvoy-image-bundle-
${nkp-version}.tar
```

Replace nkp-version with the NKP version at your site.

The --bundle flag is used in an air-gapped environment where the container
image needs to be pre-loaded into the OS image. NKP provides a bundle that
contains all the necessary container images required to bootstrap an NKP
cluster. Multiple bundles can be provided as a comma-separated list. Each file
must be in .tar format.

The Nutanix Image Builder loads these container image bundles into the OS
image during the build process. 17. Run NKP CLI to create an image:

```bash
nkp create image nutanix ${OS_TYPE} \
--cluster ${NUTANIX_CLUSTER} \
--endpoint ${NUTANIX_ENDPOINT} \
--subnet ${SUBNET} \
--source-image ${SOURCE_IMAGE} \
${ARTIFACTS_DIRECTORY:+--artifacts-directory ${ARTIFACTS_DIRECTORY}} \
${GPU_NAME:+--gpu-name ${GPU_NAME}} \
${VGPU_RUNFILE:+--vgpu-runfile ${VGPU_RUNFILE}} \
${FIPS_ENABLED:+--fips} \
${NUTANIX_PORT:+--port ${NUTANIX_PORT}}
${INSECURE:+--insecure} \
${IMAGE_BUNDLE:+--bundle ${IMAGE_BUNDLE}} \
${BASTION_HOST:+--bastion-host ${BASTION_HOST}} \
${BASTION_USERNAME:+--bastion-username ${BASTION_USERNAME}} \
${BASTION_PRIVATE_KEY_FILE:+--bastion-private-key-file
${BASTION_PRIVATE_KEY_FILE}} \
```

The NKP CLI command creates an NKP compatible OS image with the configuration
and environment variables that you exported.

What to do next

To view all the flags and their usage, use the command:

```bash
nkp create image nutanix --help
```

For information on creating a cluster, see Creating the Nutanix Kubernetes
Platform Management Cluster using CLI on page 740.

### Advanced Options for Nutanix Image Builder

About this task

The Nutanix Image Builder (NIB) provides several advanced flags for advanced
use cases, debugging, and custom workflows. These flags are not shown in the
standard `--help` output but can be used for specific scenarios.

To create an OS image with hidden and advanced flags, follow these steps:

Procedure

1. Open the terminal with access to NKP CLI.
2. (Optional) Specify a workspace directory for building the OS image:

Replace /path/to/workspace with the path to the workspace directory. The
directory must already exist. The Nutanix Image Builder uses this directory as
the workspace for building the OS image.

This command is used in the following scenarios:

- To control where temporary build files are stored
- To debug build issues
- To customize build workflows

1. (Optional) Enable dry-run mode:

```bash
export DRY_RUN=true
```

When set to true, the build process runs without creating artifacts, or
deletes them after creating.

This command is used in the following scenarios:

- Validating configurations before the actual build
- To test override files
- To verify the environment setup

1. (Optional) Enable debug mode:

```bash
export DEBUG=true
```

When set to true, NIB runs in debug mode. The user is prompted after each step
while building the image.

This command is used in the following scenarios:

- To troubleshoot build failures
- To understand the build process step-by-step

1. (Optional) Specify override YAML files:

Replace custom-override.yaml,another-override.yaml with a comma-separated list
of override YAML files to customize the build process.

This command is used in the following scenarios:

- To customize your system configuration
- To add custom packages
- To modify the packer file

> **Note: To use custom-overrides, contact Nutanix support.**

| export WORK DIRECTORY= \_ | /path/to/workspace | Col3 |
| ------------------------- | ------------------ | ---- |

| export OVERRIDES= | custom-override.yaml,another-override.yaml | Col3 |
| ----------------- | ------------------------------------------ | ---- |

1. (Optional) Add an additional name suffix to the OS image name:

Replace -custom with the additional name suffix to add to the OS image name.

This command is used in the following scenarios:

- To tag images with custom identifiers
- To distinguish between different build variants
- To track different versions

1. Create an NKP compatible OS image with hidden and advanced flags:

```bash
nkp create image nutanix ${OS_TYPE} \
--cluster ${NUTANIX_CLUSTER} \
--endpoint ${NUTANIX_ENDPOINT} \
--subnet ${SUBNET} \
--source-image ${SOURCE_IMAGE} \
${DRY_RUN:+--dry-run} \
${DEBUG:+--debug} \
${OVERRIDES:+--overrides ${OVERRIDES}} \
${EXTRA_BUILD_NAME:+--extra-build-name ${EXTRA_BUILD_NAME}} \
```

The NKP CLI command creates an NKP compatible OS image with the hidden and
advanced flags that you configured using environment variables.

```yaml
Note: Ensure all the required environment variables from the Building a Custom Image with Nutanix
on page 53 procedure are set before running this command (e.g., OS_TYPE, NUTANIX_CLUSTER,
NUTANIX_ENDPOINT, SUBNET, SOURCE_IMAGE).
```

## Building a Custom Image with AWS

You can build your own customized image with AWS based on your requirements.

About this task

To create a custom OS image, you can use the nkp create image aws command with
required flags, or follow the comprehensive procedure below to configure all
options using the environment variables:

Procedure

1. Open the terminal with access to NKP CLI.
2. Choose the operating system:

```bash
export OS_TYPE=Operating System Type
```

For more information, see Supported Infrastructure Operating Systems on page 12. 3. Configure AWS credentials:

The NKP CLI uses AWS credentials to access AWS services. You can provide
credentials in one of the following ways:

- Set the AWS_SHARED_CREDENTIALS_FILE environment variable to point to your
  credentials file
- Use the default location at ~/.aws/credentials

The credentials file should contain your AWS access key ID and secret access
key.

| export EXTRA BUILD NAME= \_ \_ | -custom | Col3 |
| ------------------------------ | ------- | ---- |

1. Choose the AWS region:

Replace AWS region name with the name of the AWS region where you want to
create the Amazon Machine Image (AMI). For example, us-west-2.

The system creates the AMI in the specified AWS region. 5. (Optional) To
specify a custom instance type:

Replace Instance-type with the AWS instance type to use for building the
image. For example, t3.small.

If not specified, the default instance type is t3.small for regular builds or
g4dn.2xlarge for GPU builds. 6. (Optional) Specify a source AMI:

Replace AMI ID with the ID of the AMI to use as the source.

If not provided, a source AMI will be selected automatically based on the OS
type. 7. (Optional) Publish AMI to multiple regions:

Replace region1,region2,region3 with a comma-separated list of AWS regions
where you want to publish the AMI.

The AMI will be created in the primary region and then copied to the specified
additional regions. 8. (Required for air-gapped environment and optional for
non-air-gapped environment) Create a package bundle:

NKP requires Operating System packages to be available in the base image.
These packages are available in the package repositories accessible over the
internet. As air-gapped environments are restricted from accessing these
package repositories, you must first create a package bundle where the
repositories can be accessed. Then, transfer this bundle to an airgapped
environment to build the OS image in an airgapped environment.

Download the NKP air-gapped bundle from the Nutanix portal. For more
information, see Downloading NKP on page 16. This air-gapped bundle contains
the NKP artifacts to build the image. Run the following command in an
environment with internet access to fetch and add the operating system
packages, to create a package bundle for NKP.

```bash
nkp create package-bundle ${OS_TYPE} --artifacts-directory nkp-nkp-version/image-
artifacts/
${FIPS_ENABLED:+--fips}
```

Replace path_to_artifacts_bundle_DIR with the path to the artifacts bundle
directory.

The package bundle contains all the necessary packages and artifacts required
to build an NKP compatible OS image in an air-gapped environment. 9. (Required
for air-gapped environment and optional for non-air-gapped environment) Set
the artifacts directory:

The artifacts directory contains the packages and artifacts required to build
the OS image.

| export AWS REGION= \_ | AWS region name | Col3 |
| --------------------- | --------------- | ---- |

| export INSTANCE TYPE= \_ | Instance type | Col3 |
| ------------------------ | ------------- | ---- |

| export SOURCE AMI= \_ | AMI ID | Col3 |
| --------------------- | ------ | ---- |

| export AMI REGIONS= \_ | region1,region2,region3 | Col3 |
| ---------------------- | ----------------------- | ---- |

| export ARTIFACTS DIRECTORY=nkp- \_ | nkp-version | /image-artifacts/ |
| ---------------------------------- | ----------- | ----------------- |

1. (Optional) Create an image for GPU workloads:

```bash
export GPU_ENABLED=true
```

When GPU is enabled, the default instance type changes to g4dn.2xlarge (GPU-
optimized instance).

The AWS Image Builder installs the necessary GPU drivers in the OS image.

For more information, see Creating GPU-Enabled Operating System Images on page
\652. 11. (Optional) Create a FIPS compliant image:

```bash
export FIPS_ENABLED=true
```

The AWS Image Builder creates a FIPS compliant OS image.

For more information about supported operating systems for AWS, see Supported
Infrastructure Operating Systems on page 12.

> **Note: For air-gapped FIPS images, ensure you have created a FIPS enabled
> OS package bundle.** 12. Create an NKP compatible OS image:

```bash
nkp create image aws ${OS_TYPE} \
${ARTIFACTS_DIRECTORY:+--artifacts-directory ${ARTIFACTS_DIRECTORY}} \
${GPU_ENABLED:+--gpu} \
${FIPS_ENABLED:+--fips} \
${AWS_REGION:+--region ${AWS_REGION}} \
${INSTANCE_TYPE:+--instance-type ${INSTANCE_TYPE}} \
${SOURCE_AMI:+--source-ami ${SOURCE_AMI}} \
${AMI_REGIONS:+--ami-regions ${AMI_REGIONS}}
```

The NKP CLI command creates an NKP compatible OS image with the configuration
and environment variables that you exported in AWS. This image can be used to
create new NKP clusters.

To view all the flags and their purpose, run the following command:

```bash
nkp create image aws --help
```

For the steps to create a cluster and more information, see Install Nutanix
Kubernetes Platform on AWS Infrastructure on page 814.

## Building a Custom Image with Azure

You can build your own customized image with Azure based on your requirements.

About this task

To create a custom OS image, you can use the nkp create image azure command
with required flags, or follow the comprehensive procedure below to configure
all options using the environment variables:

Procedure

1. Open the terminal with access to NKP CLI.
2. Choose the operating system:

```bash
export OS_TYPE=Operating System Type
```

For more information, see Supported Infrastructure Operating Systems on page 12. 3. Provide Azure subscription ID:

Replace Azure subscription ID with your Azure subscription ID. Alternatively,
you can use the -- subscription-id flag in the command. 4. Provide Azure
client ID:

Replace Azure client ID with the client ID of your Azure service principal.
Alternatively, you can use the --client-id flag in the command. 5. Provide
Azure tenant ID:

Replace Azure tenant ID with your tenant ID. Alternatively, you can use the
--tenant-id flag in the command. 6. Provide Azure client secret:

Replace Azure client secret with the client secret of your Azure service
principal.

> **Note: The client secret must be provided via environment variable for
> security reasons.** 7. Choose the resource group name:

Replace Resource group name with the name of the Azure resource group where
the image will be created. If not specified, the default value is nkp. 8.
Choose the Azure location:

```bash
export AZURE_LOCATION=Azure location
```

Replace Azure location with the required location to create the image. For
example, westus.

If not specified, the default value is `westus`. 9. (Optional) Specify custom
gallery settings:

```bash
export GALLERY_NAME=Gallery name
export GALLERY_IMAGE_NAME=Image name
export GALLERY_IMAGE_OFFER=Offer name
export GALLERY_IMAGE_PUBLISHER=Publisher name
```

Replace:

- Gallery name with the name of the Azure Shared Image Gallery. The default is
  nkp.
- Image name with the name of the gallery image. If not provided, a default
  name based on the OS and Kubernetes version will be used.
- Offer name with the gallery image offer. The default is nkp.
- Publisher name with the gallery image publisher. The default is nkp.

| export AZURE SUBSCRIPTION ID= \_ \_ | Azure subscription ID | Col3 |
| ----------------------------------- | --------------------- | ---- |

| export AZURE CLIENT ID= \_ \_ | Azure client ID | Col3 |
| ----------------------------- | --------------- | ---- |

| export AZURE TENANT ID= \_ \_ | Azure tenant ID | Col3 |
| ----------------------------- | --------------- | ---- |

| export AZURE CLIENT SECRET= \_ \_ | Azure client secret | Col3 |
| --------------------------------- | ------------------- | ---- |

| export RESOURCE GROUP NAME= \_ \_ | Resource group name | Col3 |
| --------------------------------- | ------------------- | ---- |

1. (Optional) Replicate image to multiple regions:

Replace location1,location2,location3 with a comma-separated list of Azure
locations where you want to replicate the image.

If not provided, the image will only be available in the location specified in
the location specified in a previous step. 11. (Optional) Specify Azure cloud
endpoint:

```bash
export AZURE_CLOUD_ENDPOINT=Public|USGovernment|China
```

Replace Public|USGovernment|China with the Azure cloud endpoint you want to
use. The default value is Public 12. (Optional) Specify a custom instance
type:

Replace Instance type with the Azure VM instance type to use for building the
image. The default is Standard_D2s_v3. 13. Create an NKP compatible OS image:

```bash
nkp create image azure ${OS_TYPE} \
${AZURE_SUBSCRIPTION_ID:+--subscription-id ${AZURE_SUBSCRIPTION_ID}} \
${AZURE_CLIENT_ID:+--client-id ${AZURE_CLIENT_ID}} \
${AZURE_TENANT_ID:+--tenant-id ${AZURE_TENANT_ID}} \
${RESOURCE_GROUP_NAME:+--resource-group-name ${RESOURCE_GROUP_NAME}} \
${AZURE_LOCATION:+--location ${AZURE_LOCATION}} \
${GALLERY_NAME:+--gallery-name ${GALLERY_NAME}} \
${GALLERY_IMAGE_NAME:+--gallery-image-name ${GALLERY_IMAGE_NAME}} \
${GALLERY_IMAGE_OFFER:+--gallery-image-offer ${GALLERY_IMAGE_OFFER}} \
${GALLERY_IMAGE_PUBLISHER:+--gallery-image-publisher
${GALLERY_IMAGE_PUBLISHER}} \
${GALLERY_IMAGE_LOCATIONS:+--gallery-image-locations
${GALLERY_IMAGE_LOCATIONS}} \
${AZURE_CLOUD_ENDPOINT:+--cloud-endpoint ${AZURE_CLOUD_ENDPOINT}} \
${INSTANCE_TYPE:+--instance-type ${INSTANCE_TYPE}} \

```

The NKP CLI command creates an NKP compatible OS image with the configuration
and environment variables in the Azure Shared Image Gallery. This image can be
used to create new NKP clusters.

To view all the flags and their purpose, run the following command:

```bash
nkp create image azure --help
```

For the steps to create a cluster, see Azure: Creating a Cluster on page 923.

## Building a Custom Image with GCP

You can build your own customized image with GCP based on your requirements.

About this task

To create a custom OS image, you can use the nkp create image gcp command with
required flags, or follow the comprehensive procedure below to configure all
options using the environment variables:

Procedure

1. Open the terminal with access to NKP CLI.

| export GALLERY IMAGE LOCATIONS= \_ \_ | location1,location2,location3 | Col3 |
| ------------------------------------- | ----------------------------- | ---- |

| export INSTANCE TYPE= \_ | Instance type | Col3 |
| ------------------------ | ------------- | ---- |

1. Choose the operating system:

```bash
export OS_TYPE=Operating System Type
```

For more information, see Supported Infrastructure Operating Systems on page 12. 3. Configure GCP credentials: Set the GOOGLE_APPLICATION_CREDENTIALS
environment variable to point to your GCP service account key file:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=Path to service account key file
```

Replace Path to service account key file with the path to your GCP service
account JSON key file. The NKP CLI uses these credentials to access GCP
services. 4. Choose the GCP project ID:

```bash
export GCP_PROJECT_ID=GCP project ID
```

Replace GCP project ID with your GCP project ID where you want to create the
image. 5. Choose the GCP region:

```bash
export GCP_REGION=GCP region
```

Replace GCP region with the GCP region where you want to launch the instance
for building the image. For example, us-west1.

If not specified, the default value is us-west1. 6. (Optional) Specify a
custom network:

```bash
export NETWORK=Network path
```

Replace Network path with the path to the GCP network to create an image.

The network path format is: projects/PROJECT_ID/global/networks/NETWORK_NAME

If not specified, the default network will be used. 7. (Optional) Specify
image storage locations:

Replace location1,location2,location3 with a comma-separated list of GCP
locations where you want to store the image.

The image will be stored in the specified locations for better availability
and performance. 8. Create an NKP compatible OS image:

```bash
nkp create image gcp ${OS_TYPE} \
--project-id ${GCP_PROJECT_ID} \
${GCP_REGION:+--region ${GCP_REGION}} \
${NETWORK:+--network ${NETWORK}} \
${IMAGE_STORAGE_LOCATIONS:+--image-storage-locations ${IMAGE_STORAGE_LOCATIONS}}
```

The NKP CLI command creates an NKP compatible OS image with the configuration
and environment variables that you exported in GCP. This image can be used to
create new NKP clusters.

To view all the flags and their purpose, run the following command:

```bash
nkp create image gcp --help
```

For the steps to create a cluster, see GCP Creating a Cluster.

## Building a Custom Image with vSphere

You can build your own customized image with VMware vSphere based on your
requirements.

| projects/PROJECT ID/global/networks/ | NETWORK NAME |
| ------------------------------------ | ------------ |

| export IMAGE STORAGE LOCATIONS= \_ \_ | location1,location2,location3 | Col3 |
| ------------------------------------- | ----------------------------- | ---- |

Before you begin

Before creating an image, ensure your base template meets the following
requirements:

- The base template must be a vSphere VM template (not a VM) and must be
  powered-off.
- The template must be accessible from the vCenter server and located in the
  specified datacenter.
- The default user must have sudo privileges.
- Ensure that you install and enable the SSH server.
- Ensure that you install and configure cloud-init.
- Ensure that you install Python version 3.x and it is accessible.
- Ensure availability of at least 20 GB of disk space on the root file system.
- Network configuration must allow SSH access during the build process.
- Ensure that no existing Kubernetes components are present.
- The template must have VMware Tools installed (recommended for optimal
  performance).

About this task

To create a custom OS image, you can use the nkp create image vsphere command
with required flags, or follow the comprehensive procedure below to configure
all options using the environment variables:

Procedure

1. Open the terminal with access to NKP CLI.
2. Choose the operating system:

```bash
export OS_TYPE=Operating System Type
```

For more information, see Supported Infrastructure Operating Systems on page 12. 3. Provide vCenter server credentials:

```bash
export VSPHERE_USERNAME=vCenter username
export VSPHERE_PASSWORD=vCenter password
```

Replace:

- vCenter username with the username to access vCenter
- vCenter password with the password to access vCenter

The NKP CLI needs these credentials to access vCenter. 4. Provide the vCenter
server host:

Replace vCenter server host or IP with the host IP or FQDN of the vCenter API
server. 5. Choose the base template:

Replace Base template name with the name of the base template to use for
creating the VM.

| export VCENTER SERVER= \_ | vCenter server host or IP | Col3 |
| ------------------------- | ------------------------- | ---- |

| export TEMPLATE= | Base template name | Col3 |
| ---------------- | ------------------ | ---- |

1. Choose the vSphere cluster:

Replace vSphere cluster name with the name of the vSphere cluster. 7. Choose
the datacenter:

Replace Datacenter name with the name of the vSphere datacenter. 8. Choose the
resource pool:

Replace Resource pool name with the name of the vSphere resource pool. 9.
Choose the datastore:

Replace Datastore name with the name of the vSphere datastore. 10. Choose the
network:

Replace Network name with the name of the vSphere network. 11. Choose the
folder:

Replace Folder name with the name of the vSphere folder. 12. (Optional) Use
insecure connection (self-signed certificates):

```bash
export INSECURE=true
```

The NKP CLI can only verify server certificates signed by a trusted CA. Ensure
that you allow insecure access to the vCenter endpoint if the vCenter server
certificate is not signed by a trusted CA certificate.

If the vCenter endpoint uses a self-signed CA certificate, the CA certificate
is untrusted. 13. (Required for air-gapped environment and optional for non-
air-gapped environment) Create a package bundle:

NKP requires Operating System packages to be available in the base image.
These packages are available in the package repositories accessible over the
internet. As air-gapped environments are restricted from accessing these
package repositories, you must first create a package bundle where the
repositories can be accessed. Then, transfer this bundle to an air-gapped
environment to build the OS image in an air-gapped environment.

Download the NKP air-gapped bundle from the Nutanix portal. For more
information, see Downloading NKP on page 16. This air-gapped bundle contains
the NKP artifacts to build the image. Run the following command in an
environment with internet access to fetch and add the operating system
packages, to create a package bundle for NKP.

```bash
nkp create package-bundle ${OS_TYPE} --artifacts-
directory path_to_artifacts_bundle_DIR
${FIPS_ENABLED:+--fips}
```

Replace path_to_artifacts_bundle_DIR with the path to the artifacts bundle
directory.

The package bundle contains all the necessary packages and artifacts required
to build an NKP compatible OS image in an air-gapped environment.

| export VSPHERE CLUSTER= \_ | vSphere cluster name | Col3 |
| -------------------------- | -------------------- | ---- |

| export DATACENTER= | Datacenter name | Col3 |
| ------------------ | --------------- | ---- |

| export RESOURCE POOL= \_ | Resource pool name | Col3 |
| ------------------------ | ------------------ | ---- |

| export DATASTORE= | Datastore name | Col3 |
| ----------------- | -------------- | ---- |

| export NETWORK= | Network name | Col3 |
| --------------- | ------------ | ---- |

| export FOLDER= | Folder name | Col3 |
| -------------- | ----------- | ---- |

1. (Required for air-gapped environment and optional for non-air-gapped
   environment) Set the artifacts directory:

Replace path_to_artifacts_bundle_Directory with the path to the artifacts
bundle directory.

The artifacts directory contains the packages and artifacts required to build
the OS image. 15. (Optional) Configure a bastion host for air-gapped
environments:

```bash
export BASTION_HOST=IP or hostname of bastion VM
export BASTION_USERNAME=SSH user on bastion
export BASTION_PRIVATE_KEY_FILE=Path to SSH private key file
```

Replace:

- IP or hostname of bastion VM with the IP address or hostname of the bastion
  VM.
- SSH user on bastion with the SSH username on the bastion VM.
- Path to SSH private key file with the location of the SSH private key file.

In an air-gapped environment, the NKP CLI uses a bastion host to access the VM
that builds the OS image. 16. (Optional) Create a FIPS-compliant image:

```bash
export FIPS_ENABLED=true
```

The vSphere Image Builder creates a FIPS-compliant OS image. For more
information, see Supported Infrastructure Operating Systems on page 12 17.
Create an NKP compatible OS image:

```bash
nkp create image vsphere ${OS_TYPE} \
--server ${VCENTER_SERVER} \
--template ${TEMPLATE} \
--cluster ${VSPHERE_CLUSTER} \
--data-center ${DATACENTER} \
--resource-pool ${RESOURCE_POOL} \
--data-store ${DATASTORE} \
--network ${NETWORK} \
--folder ${FOLDER} \
${FIPS_ENABLED:+--fips} \
${INSECURE:+--insecure} \
${ARTIFACTS_DIRECTORY:+--artifacts-directory ${ARTIFACTS_DIRECTORY}} \
${BASTION_HOST:+--bastion-host ${BASTION_HOST}} \
${BASTION_USERNAME:+--bastion-username ${BASTION_USERNAME}} \
${BASTION_PRIVATE_KEY_FILE:+--bastion-private-key-file
${BASTION_PRIVATE_KEY_FILE}} \
```

The NKP CLI command creates an NKP compatible OS image with the configuration
and environment variables that you exported in vSphere. This image can be used
to create new NKP clusters.

To view all the flags and their purpose, run the following command:

```bash
nkp create image vsphere --help
```

For the steps to create a cluster, and more information, see vSphere
Infrastructure on page 852.

## Upload artifacts to Pre-provisioned Hosts

The Nutanix Image Builder enables you to configure pre-provisioned hosts by
uploading the necessary artifacts (packages, container images, GPU drivers) to
existing nodes. This is used when existing machines need to be configured for
NKP clusters. After uploading the artifacts, NKP can use these pre-
provisioned hosts to form a Kubernetes cluster quickly and consistently. This
reduces Kubernetes cluster deployment and upgrade errors caused by
misconfiguration of OS images and packages

- export ARTIFACTS DIRECTORY= \_; path to artifacts bundle Directory \_ \_ \_
  \_; Col3

| --- | --- | --- |

In a pre-provisioned environment, existing machines are available to be used
to form NKP clusters. In the case of other providers, images must be built and
NKP provisions machines from those images. With pre-provisioned environments
your existing nodes are configured with the required artifacts using the nkp
upload image- artifacts command.

Key Differences:

- Pre-provisioned: You configure existing machines using nkp upload image-
  artifacts
- Other providers: You build images using nkp create image command, and NKP
  provisions machines from those images with providers such as AWS, Azure,
  GCP, vSphere, and Nutanix.

About this task

To upload image artifacts with all configuration options, follow these steps:

Procedure

1. Open the terminal with access to NKP CLI.
2. Provide the SSH host information:

Replace Host IP or hostname with the IP address or hostname of the remote
host(s). For multiple hosts, provide a comma-separated list:
host1,host2,host3. 3. Provide the SSH username:

Replace SSH username with the username to connect to the remote host. 4.
Choose SSH authentication method:

Choose one of the following authentication methods:

a. SSH private key (recommended)

Replace Path to SSH private key file with the location of the PEM encoded
private key file to use for authentication.

b. SSH password (not recommended)

Replace SSH password with the password for SSH authentication.

> **Note: Using SSH keys is strongly recommended over passwords for security
> reasons.** 5. (Optional) Specify a custom SSH port:

Replace the variable 22 with the SSH port of the remote host if you use a non-
standard port. If not specified, the default port is 22. 6. (Required for air-
gapped environment and optional for non-air-gapped environment) Create a
package bundle:

Download the NKP air-gapped bundle from the Nutanix portal. For air-gapped
environments on pre- provisioned hosts, download nkp-air-gapped-bundle_nkp-
version_linux_amd64.tar.gz from the

| export SSH HOST= \_ | Host IP or hostname | Col3 |
| ------------------- | ------------------- | ---- |

| export SSH USERNAME= \_ | SSH username | Col3 |
| ----------------------- | ------------ | ---- |

| export SSH PRIVATE KEY FILE= \_ \_ \_ | Path to SSH private key file | Col3 |
| ------------------------------------- | ---------------------------- | ---- |

| export SSH PASSWORD= \_ | SSH password | Col3 |
| ----------------------- | ------------ | ---- |

| export SSH PORT= \_ | 22  | Col3 |
| ------------------- | --- | ---- |

Nutanix portal. For more information, see Downloading NKP on page 16. Then,
extract the tarball to a local directory:

```bash
tar -xzvf nkp-air-gapped-bundle_nkp-version_linux_amd64.tar.gz
cd nkp-nkp-version
```

For air-gapped environments, you must build the OS packages after you fetch
the packages from the distribution repositories. The air-gapped bundle
contains the following artifacts, but does not include distribution packages:

- NKP Kubernetes packages
- Python packages (provided by upstream)
- Containerd tarball

1. (Optional) Create a FIPS-compliant image:

```bash
export FIPS_ENABLED=true
```

The Nutanix Image Builder creates a FIPS-compliant OS image. For more
information, see Supported Infrastructure Operating Systems on page 12 8.
(Required for air-gapped environment) Create a package bundle:

NKP requires Operating System packages to be available in the base image.
These packages are available in the package repositories accessible over the
internet. As air-gapped environments are restricted from accessing these
repositories, you must first create a package bundle where the repositories
can be accessed. Then, transfer this bundle to an air-gapped environment to
build the OS image in an air-gapped environment.

Download the NKP air-gapped bundle from the Nutanix portal. For more
information, see Downloading NKP on page 16.

This air-gapped bundle contains the NKP artifacts to build the image. Run the
following command in an environment with internet access to fetch and add the
operating system packages, to create a package bundle for NKP:

```bash
nkp create package-bundle ${OS_TYPE} --artifacts-directory
path_to_artifacts_bundle_DIR
${FIPS_ENABLED:+--fips}
```

Replace path_to_artifacts_bundle_DIR with the path to the artifacts bundle
directory.

The package bundle contains all necessary packages and artifacts required to
build an NKP compatible OS image in an air-gapped environment. 9. Set the
artifacts directory:

The artifacts directory contains the packages and artifacts required to
configure the pre-provisioned host.

```yaml
Note: For air-gapped environments, this should be the directory containing the package bundle created in the step
to create a bundle above.
```

1. (Optional) Configure a bastion host:

```bash
export BASTION_HOST=IP or hostname of bastion VM
export BASTION_USERNAME=SSH user on bastion
export BASTION_PRIVATE_KEY_FILE=Path to SSH private key file
export BASTION_PORT=22
```

Replace:

- IP or hostname of bastion VM with the IP address or hostname of the bastion
  VM.

| export ARTIFACTS DIRECTORY=nkp- \_ | nkp-version | /image-artifacts/ |
| ---------------------------------- | ----------- | ----------------- |

- SSH user on bastion with the SSH username on the bastion VM.
- Path to SSH private key file with the location of the SSH private key file.
- 22 with the Bastion SSH port, if it is different from the default port.

1. (Optional) Upload NVIDIA GPU drivers:

```bash
export NVIDIA_RUNFILE=Path to NVIDIA driver runfile
```

Replace Path to NVIDIA driver runfile with the path to the NVIDIA driver
runfile.

The Nutanix Image Builder uploads the NVIDIA driver runfile to the target host
for GPU workload support. 12. (Optional) Specify a provider hint:

Replace aws|azure|gcp|vsphere|nutanix with the provider name when installing
provider specific utilities.

This helps the image builder install the appropriate provider specific
utilities on the host. 13. Upload the image artifacts:

```bash
nkp upload image-artifacts \
--ssh-host ${SSH_HOST} \
--ssh-username ${SSH_USERNAME} \
${SSH_PRIVATE_KEY_FILE:+--ssh-private-key-file ${SSH_PRIVATE_KEY_FILE}} \
${SSH_PASSWORD:+--ssh-password ${SSH_PASSWORD}} \
${SSH_PORT:+--ssh-port ${SSH_PORT}} \
--artifacts-directory ${ARTIFACTS_DIRECTORY} \
${BASTION_HOST:+--bastion-host ${BASTION_HOST}} \
${BASTION_USERNAME:+--bastion-username ${BASTION_USERNAME}} \
${BASTION_PRIVATE_KEY_FILE:+--bastion-private-key-file ${BASTION_PRIVATE_KEY_FILE}}
\
${BASTION_PORT:+--bastion-port ${BASTION_PORT}} \
${NVIDIA_RUNFILE:+--nvidia-runfile ${NVIDIA_RUNFILE}} \
${PROVIDER:+--provider ${PROVIDER}} \
${FIPS_ENABLED:+--fips}
```

The NKP CLI uploads image artifacts to the specified host(s) with the
configuration and environment variables that were exported. You can use these
hosts to create new NKP clusters.

```yaml
Note: This command uses Ansible playbooks to upload and configure artifacts. Artifacts are uploaded to
standard locations (eg. `/opt/dkp/packages/`, `/opt/dkp/containerd/`, etc.) on the target host.
```

(Optional) For additional customizations that cannot be performed using flags
or YAML files, contact Nutanix support.

To view all the flags and their purpose, run the following command:

```bash
nkp upload image-artifacts --help
```

For the steps to create a cluster and more information, see Pre-provisioned
Infrastructure on page 761.

RedHat Subscription Manager Configuration for RedHat Enterprise Linux Images

This section details information on RedHat Subscription Manager (RHSM).

When creating RHEL (Red Hat Enterprise Linux) images, you must configure Red
Hat Subscription Manager (RHSM) to access RHEL repositories and install
packages. The Nutanix Image Builder (NIB) supports two methods for RHSM
registration:

| export PROVIDER= | aws | azure | gcp | vsphere | nutanix | Col3 |
| ---------------- | --- | ----- | --- | ------- | ------- | ---- |

- Username/password authentication
- Organization/activation key authentication

RHSM configuration is required in the following scenarios:

- Use of all RHEL images (For example, rhel-8.10, rhel-9.6)
- Installing RHEL packages and updates
- Accessing RHEL repositories

RedHat Subscription Manager Registration Method

- Registration Method 1: Username and Password

Use this method if you have the required Red Hat username and password
credentials.

```bash
export RHSM_USER=your-redhat-username
export RHSM_PASS=your-redhat-password
export RHSM_CONSUMER_NAME=my-rhel-image-builder #Optional
export RHSM_ENVIRONMENT=production # Optional
export RHSM_POOL_ID=pool-id-12345 # Optional
```

NIB automatically registers the system with RHSM during image creation. The
system is then unregistered after image creation to avoid subscription
conflicts

Use RHSM_CONSUMER_NAME to identify the system in Red Hat's subscription
management

Use RHSM_ENVIRONMENT to specify the environment. This option is available only
in the username/password method.

Use RHSM_POOL_ID to attach a specific subscription pool

- Registration Method 2: Organization ID and Activation Key

Use this method if you have an organization ID and activation key. This method
is recommended for automated registration.

```bash
export RHSM_ORG_ID=your-org-id
export RHSM_ACTIVATION_KEY=your-activation-key
export RHSM_CONSUMER_NAME=my-rhel-image-builder # Optional
export RHSM_POOL_ID=pool-id-12345 # Optional
```

Activation keys are preferred for automated builds and CI/CD pipelines. They
can also be scoped to specific repositories and pools.

This method is more secure than the username/password method as the keys can
be rotated independently.

Use RHSM_POOL_ID to attach a specific subscription pool
