# Custom Installation and Infrastructure Tools

CUSTOM INSTALLATION AND INFRASTRUCTURE TOOLS

Nutanix Kubernetes Platform (NKP) cluster can be customized for different
environments and infrastructures depending on your network technology choices.
If you have already installed using Basic Installations by Infrastructure on
page 72 instructions, you might find helpful tools in this section. However,
if you have not already installed NKP with the Basic installation
instructions, find your infrastructure and begin the process of custom NKP
installation in this area.

See the following sections for details on custom installation options and
infrastructure-specific details.

## Universal Configurations for all Infrastructure Providers

Several areas of Nutanix Kubernetes Platform (NKP) configuration are shared
amongst all infrastructure providers. Some of the universal configurations
related to environment variables, flags for cluster creation, local registries
and more are described in this section.

For more information regarding global configurations, customization of
specific components, or additional Konvoy customizations, see Additional
Konvoy Configurations on page 1025.

### Container Engine

- Podman Version 4.0 or later for Linux. For more information, see Podman
  Installation and host requirements in kind .

```yaml
Note: Installation of Podman is different for different OS environments. For more information, see Podman
Installation.
```

> **Tip:**

You will need to restart your machine after following the Host Requirements to
add the /etc/systemd/ system/user@.service.d/delegate.conf and the
/etc/modules-load.d/iptables.conf files. On Linux, this will mean restarting
the host. On MacOS, it means restarting the Docker or Podman VM.

### Configuring an HTTP or HTTPS Proxy

When creating a Nutanix Kubernetes Platform (NKP) cluster in environments that
use an HTTP or HTTPS proxy, you must provide proxy details. The proxy values
are strings that list a set of proxy servers, URLs, or wildcard addresses
specific to your environment.

When creating a NKP cluster in a proxied environment, you need to specify
proxy settings for the following:

- Bootstrap cluster
- CAPI components
- NKP Kommander component

When you create a NKP cluster through the nkp create cluster command, the
bootstrap cluster and Cluster API (CAPI) components are created for you
automatically, and use the HTTP and HTTPS proxy settings you specify in the
nkp create cluster `<provider>`... command through the flags --http-proxy,
--https-proxy, and --no-proxy.

You can also create the bootstrap cluster and CAPI components manually, using
the appropriate commands: nkp create bootstrap and nkp create capi-components
, respectively, combined with the command line flags as shown above to include
your HTTP, HTTPS and no-proxy information.

You can also specify HTTP or HTTPS proxy information in an override file when
using Nutanix Image Builder (NIB). .

Without these values provided as part of the relevant nkp create command, NKP
cannot create the requisite parts of your new cluster correctly. This is true
of both management and managed clusters alike.

```yaml
Note: For NKP installation, create the bootstrap cluster from within the same network where the new cluster will run.
Using a bootstrap cluster on a laptop with different proxy settings, for example, or residing in a different network, can
cause problems.
```

To modify HTTP or HTTPS proxy settings after initial deployment, see Adding or
Modifying HTTP Proxy Settings After Deployment on page 701.

#### Bootstrap Cluster HTTP Proxy Settings

The Application Programming Interface (API) server doesn't exist yet in the
bootstrap environment before you install Nutanix Kubernetes Platform (NKP)
because the API server is created during cluster creation. To create a
bootstrap server in a proxied environment, you need to include the following
flags:

- --http-proxy <`<http proxy list>`>
- --https-proxy <`<https proxy list>`>
- --no-proxy <`<no proxy list>`>

The following is an example of the nkp create bootstrap command's syntax, with
the HTTP proxy settings included.

```bash
nkp create bootstrap --http-proxy <<http proxy list>> --https-proxy <<https proxy
list>> --no-proxy <<no proxy list>>
```

#### Creating a Bootstrap Cluster with HTTP Proxy Settings

Before you begin

If an HTTP proxy is required, locate the values to use for the http_proxy,
https_proxy, and no_proxy flags. They will be built into the bootstrap cluster
during cluster creation.

About this task

The flags can include a mix of IP addresses and domain names. Note that the
delimiter between each proxy value within a flag is a comma (,) with no space
character following it.

Procedure

Create a bootstrap cluster and any other flags you need using the command.

```bash
nkp create bootstrap --kubeconfig $HOME/.kube/config \
--http-proxy <string> \
--https-proxy <string> \
--no-proxy <string>
```

Example output shows values for the proxy settings:

```bash
nkp create bootstrap \
--http-proxy 10.0.0.15:3128 \
--https-proxy 10.0.0.15:3128 \
--no-proxy
127.0.0.1,192.168.0.0/16,10.0.0.0/16,10.96.0.0/12,169.254.169.254,169.254.0.0/24,localhost,kuberne
operator-logging-fluentd.kommander.svc.cluster.local,elb.amazonaws.com
```

#### Creating CAPI Components with HTTP or HTTPS Proxy Settings

About this task

If you created a cluster without using the --self-managed flag, the cluster
will not have any Cluster API (CAPI)
controllers or the cert-manager component. This means that the cluster will be
managed from the context of the cluster
from which it was created, such as the bootstrap cluster. However, you can
transform the cluster to a self-managed
cluster by performing the commands nkp create capi-components --
kubeconfig=`<newcluster>` and nkp move --to-
kubeconfig=`<newcluster>`. This combination of actions is sometimes called a
pivot.

When creating the CAPI components for a proxied environment using the Nutanix
Kubernetes Platform (NKP) command line interface, you must include the
following flags :

- --http-proxy <`<http proxy list>`>
- --https-proxy <`<https proxy list>`>
- --no-proxy <`<no proxy list>`>

The following is an example nkp create capi-components command's syntax with
the HTTP proxy settings included:

> **Note:**

```bash
nkp create capi-components --http-proxy <<http proxy list>> --https-proxy
<<https proxy list>> --no-proxy <<no proxy list>>
```

Create CAPI Components with HTTP Proxy Settings

Note that the delimiter between each proxy value within a flag is a comma ( ,
) with no space character following it. The flags can include a mix of IP
addresses and domain names.

Procedure

1. If an HTTP proxy is required, locate the values to use for the http_proxy,
   https_proxy, and no_proxy flags. They will be built into the CAPI components
   during their creation.
2. Create CAPI components using this command syntax and any other flags you
   might need.

```bash
nkp create capi-components --kubeconfig $HOME/.kube/config \
--http-proxy <string> \
--https-proxy <string> \
--no-proxy <string>
```

This code sample shows the command with example values for the proxy settings:

```bash
nkp create capi-components \
--http-proxy 10.0.0.15:3128 \
--https-proxy 10.0.0.15:3128 \
--no-proxy
127.0.0.1,192.168.0.0/16,10.0.0.0/16,10.96.0.0/12,169.254.169.254,169.254.0.0/24,localhost,kube
operator-logging-fluentd.kommander.svc.cluster.local,elb.amazonaws.com
```

#### Cluster Creation with HTTP or HTTPS Proxy

During cluster creation, you might need to configure the control plane and
worker nodes to use an HTTP proxy. This can occur during installation of the
Konvoy component of Nutanix Kubernetes Platform (NKP) or when creating a
managed cluster.

If you require HTTP proxy configurations, you can apply them during the NKP
create cluster operation by adding the appropriate flags to the command
example below:

Table 62: Nutanix Infrastructure

Table 63: AWS, Azure, GCP, VSphere, and Preprovisoned Infrastructures

```yaml
Note: Using an HTTP override file, you must apply the same configuration to any custom machine images built with
the Nutanix Image Builder (NIB).
```

Configure the Control Plane and Worker Nodes to Use HTTP/S Proxy

This method uses environment variables to configure the HTTP proxy values.
(You are not required to use this method.)

| Proxy configuration                        | Flag                   |
| ------------------------------------------ | ---------------------- |
| HTTP proxy for all nodes in the cluster    | `--http-proxy string`  |
| HTTPS proxy for all nodes in the cluster   | `--https-proxy string` |
| No Proxy list for all nodes in the cluster | `--no-proxy strings`   |

| Proxy configuration | Flag |

|                                       |                             |
| ------------------------------------- | --------------------------- |
| HTTP proxy for control plane machines | `--control-plane-http-proxy |

string` |

- HTTPS proxy for control plane machines; `--control-plane-https-proxy
string`
- No Proxy list for control plane machines; `--control-plane-no-proxy
strings`

| HTTP proxy for worker machines | `--worker-http-proxy string` |
| | |
| HTTPS proxy for worker machines | `--worker-https-proxy string` |
| | |
| No Proxy list for worker machines | `--worker-no-proxy strings` |
| | |

Review this sample code to configure environment variables for the control
plane and worker nodes, considering the list of considerations that follow the
sample.

```bash
export HTTP_PROXY=http://example.org:8080
export HTTPS_PROXY=http://example.org:8080
export
NO_PROXY="example.org,example.com,example.net,localhost,127.0.0.1,10.96.0.0/12,192.168.0.0/16,kuber
export WORKER_HTTP_PROXY=http://example.org:8080
export WORKER_HTTPS_PROXY=http://example.org:8080
export
WORKER_NO_PROXY="example.org,example.com,example.net,localhost,127.0.0.1,10.96.0.0/12,192.168.0.0/1
```

HTTP proxy configuration considerations to ensure the core components work
correctly

- Replace example.org,example.com,example.net with your internal addresses
- localhost and 127.0.0.1 addresses that can be accessed directly, not through
  the proxy.
- 10.96.0.0/12 is the default Kubernetes service subnet
- 192.168.0.0/16 is the default Kubernetes pod subnet
- kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.
  cluster,kubernetes.d are the internal Kubernetes kube-apiserver services
- The entries .svc,.svc.cluster,.svc.cluster.local are the internal Kubernetes
  services
- Auto-IP addresses 169.254.169.254 for any cloud provider
- 169.254.169.254 is the AWS metadata server
- .elb.amazonaws.com is for the worker nodes to allow them to communicate
  directly to the kube-apiserver ELB

Example of Creating a Cluster Using the Configured HTTP Proxy Variables

Nutanix Infrastructure: The following is an example of a nkp create cluster...
command that uses the values set in the environment variables from the code
sample.

```bash
nkp create cluster nutanix \
--cluster-name ${CLUSTER_NAME} \
--http-proxy="${HTTP_PROXY}" \
--https-proxy="${HTTPS_PROXY}" \
--no-proxy="${NO_PROXY}"
```

AWS, Azure, GCP, VSphere, and Preprovisoned Infrastructures: The following is
an example of a nkp create cluster... command that uses the values set in the
environment variables from the code sample above. Use the appropriate
infrastructure provider name in line 1 from the choices listed:

```bash
nkp create cluster [aws, azure, gcp, preprovisoned, vsphere] \
--cluster-name ${CLUSTER_NAME} \
--control-plane-http-proxy="${HTTP_PROXY}" \
--control-plane-https-proxy="${HTTPS_PROXY}" \
--control-plane-no-proxy="${NO_PROXY}" \
--worker-http-proxy="${WORKER_HTTP_PROXY}" \
--worker-https-proxy="${WORKER_HTTPS_PROXY}" \
--worker-no-proxy="${WORKER_NO_PROXY}"
```

#### HTTP or HTTPS Proxy Configuration for the NKP Kommander Component

After the cluster is running in the Konvoy component; you need to configure
the NO_PROXY variable for each provider.

For example, in addition to the values above for Amazon Web Services (AWS),
you need the following settings:

- The default VPC Classless Inter-Domain Routing (CIDR) range of 10.0.0.0/16
- kube-apiserver internal or external ELB address

```yaml
Warning: The NO_PROXY variable contains the Kubernetes Services CIDR. This example uses the default CIDR,
10.96.0.0/12. If your cluster's CIDR differs, update the value in the NO_PROXY field.
```

Set the httpProxy and httpsProxy environment variables to the address of the
HTTP and HTTPS proxy servers, respectively. (Frequently, environments use the
same values for both.) Set the noProxy environment variable to the addresses
that can be accessed directly and not through the proxy.

For the Kommander component of Nutanix Kubernetes Platform (NKP), refer to
more HTTP Proxy information in Configuring HTTP proxy for the Kommander
Clusters on page 1019.

#### Nutanix Image Builder HTTP or HTTPS Proxy

In some networked environments, the machines used for building images can
reach the Internet, but only through an HTTP or HTTPS proxy. For Nutanix
Kubernetes Platform (NKP) to operate in these networks, you need a way to
specify what proxies to use; see Configuring an HTTP or HTTPS Proxy on page
\696. You can use an HTTP proxy override file to specify that proxy. When NIB
tries installing a particular OS package, it uses that proxy to reach the
Internet to download it.

```yaml
Warning: The proxy setting specified here is NOT "baked into" the image - it is only used while the image is being
built. The settings are removed before the image is finalized.
```

While it might seem logical to include the proxy information in the image, the
reality is that many companies have
multiple proxies - one perhaps for each geographical region or maybe even a
proxy per datacenter or office datacenter.
All network traffic to the Internet goes through the proxy. If you were in
Germany, you probably would not want to send
all your traffic to a U.S.-based proxy. Doing that slows traffic down and
consumes too many network resources. If you
bake the proxy settings into the image, you must create a separate image for
each region. Creating an image without a
proxy makes more sense, but remember that you still need a proxy to access the
Internet. Thus, when creating the cluster
(and installing the Kommander component of NKP), you must specify the correct
proxy settings for the network environment
into which you install the cluster. You will use the same base image for that
cluster installed in an environment with
different proxy settings.

#### Adding or Modifying HTTP Proxy Settings After Deployment

Before you begin

- Ensure that the proxy server works correctly.
- Identify any addresses or domain suffixes that need to be added to NO_PROXY.
  See Cluster Creation with HTTP or HTTPS Proxy on page 699.

About this task

NKP clusters support modifying HTTP proxy settings through the Cluster API. To
add or modify HTTP proxy settings after deployment, follow these steps:

Procedure

1. Set your new proxy configuration as environment variables.

```bash
export HTTP_PROXY=http://example.org:8080
export HTTPS_PROXY=http://example.org:8080
export
NO_PROXY="example.org,example.com,example.net,localhost,127.0.0.1,10.96.0.0/12,192.168.0.0/16,k
```

1. Apply the new environment variables to the CAPI provider deployments and
   the git operator.

```bash
kubectl set env deployment/caaph-controller-manager -n caaph-system
HTTP_PROXY="${HTTP_PROXY}" HTTPS_PROXY="${HTTPS_PROXY}" NO_PROXY="${NO_PROXY}"
kubectl set env deployment/capa-controller-manager -n capa-system
HTTP_PROXY="${HTTP_PROXY}" HTTPS_PROXY="${HTTPS_PROXY}" NO_PROXY="${NO_PROXY}"
kubectl set env deployment/capg-controller-manager -n capg-system
HTTP_PROXY="${HTTP_PROXY}" HTTPS_PROXY="${HTTPS_PROXY}" NO_PROXY="${NO_PROXY}"
kubectl set env deployment/capi-kubeadm-bootstrap-controller-manager -n capi-
kubeadm-bootstrap-system HTTP_PROXY="${HTTP_PROXY}" HTTPS_PROXY="${HTTPS_PROXY}"
NO_PROXY="${NO_PROXY}"
kubectl set env deployment/capi-kubeadm-control-plane-controller-manager -n capi-
kubeadm-control-plane-system HTTP_PROXY="${HTTP_PROXY}" HTTPS_PROXY="${HTTPS_PROXY}"
NO_PROXY="${NO_PROXY}"
kubectl set env deployment/capi-controller-manager -n capi-system
HTTP_PROXY="${HTTP_PROXY}" HTTPS_PROXY="${HTTPS_PROXY}" NO_PROXY="${NO_PROXY}"
kubectl set env deployment/cappp-controller-manager -n cappp-system
HTTP_PROXY="${HTTP_PROXY}" HTTPS_PROXY="${HTTPS_PROXY}" NO_PROXY="${NO_PROXY}"
kubectl set env deployment/capv-controller-manager -n capv-system
HTTP_PROXY="${HTTP_PROXY}" HTTPS_PROXY="${HTTPS_PROXY}" NO_PROXY="${NO_PROXY}"
kubectl set env deployment/capx-controller-manager -n capx-system
HTTP_PROXY="${HTTP_PROXY}" HTTPS_PROXY="${HTTPS_PROXY}" NO_PROXY="${NO_PROXY}"
kubectl set env deployment/capz-controller-manager -n capz-system
HTTP_PROXY="${HTTP_PROXY}" HTTPS_PROXY="${HTTPS_PROXY}" NO_PROXY="${NO_PROXY}"
kubectl set env deployment/cluster-api-runtime-extensions-nutanix -n caren-system
HTTP_PROXY="${HTTP_PROXY}" HTTPS_PROXY="${HTTPS_PROXY}" NO_PROXY="${NO_PROXY}"
kubectl set env statefulset/git-operator-git -n git-operator-system
HTTP_PROXY="${HTTP_PROXY}" HTTPS_PROXY="${HTTPS_PROXY}" NO_PROXY="${NO_PROXY}"
Note: If you are upgrading CAPI components as part of an NKP upgrade, use nkp upgrade capi-
components with the proxy flags instead of applying the environment variables individually:
nkp upgrade capi-components \
--http-proxy "${HTTP_PROXY}" \
--https-proxy "${HTTPS_PROXY}" \
--no-proxy "${NO_PROXY}"
```

1. Update the gatekeeper-overrides ConfigMap to apply the new proxy settings
   to Kommander applications.

See Creating Gatekeeper ConfigMap in the Kommander Namespace on page 1020 for
detailed steps.

```yaml
Note: If a gatekeeper-overrides ConfigMap already exists in the kommander namespace, running the
command in that procedure updates it in place.
```

1. Update proxy configurations for kubelet and containerd by editing the
   Cluster resource.

Include the following proxy configurations in the spec:

```bash
spec:
topology:
variables:
- name: clusterConfig
value:
proxy:
http: http://example.com
https: http://example.com
additionalNo:
- no-proxy-1.example.com
```

| kubectl edit clusters | CLUSTER NAME | -n  | NAMESPACE | Col5 |
| --------------------- | ------------ | --- | --------- | ---- |

```bash
- no-proxy-2.example.com
```

> **Note: After applying the new manifests, Cluster API recreates nodes with
> the new settings.**

### Load Balancers

In a Kubernetes cluster, depending on the flow of traffic direction, there are
two kinds of load balancing:

- Internal load balancing for the traffic within a Kubernetes cluster
- External load balancing for the traffic coming from outside the cluster

Nutanix Kubernetes Platform (NKP) includes both internal and external load
balancing solutions for the supported cloud infrastructure providers and pre-
provisioned environments. For more information, see Load Balancing on page 637.

MetalLB MetalLB is an external load balancer that NKP deploys by default on
supported clusters to allocate virtual IP addresses for Kubernetes services.
You can create additional MetalLB configuration as needed.

MetalLB advertises virtual IP addresses using the following protocols:

- Layer 2, with Address Resolution Protocol (ARP)
- Border Gateway Protocol (BGP)

> **Important:**

Do not edit the default MetalLB IPAddressPool and L2Advertisement on a
cluster. Modifying these default objects to host additional IP address pools
for applications will cause the cluster upgrade process to stall and fail.

When configuring MetalLB for your applications, always create a new
IPAddressPool and a new L2Advertisement instead of modifying the default
objects.

Select one of the following procedures to create your MetalLB manifest.

Layer 2 Configuration

Layer 2 mode is the simplest to configure. In many cases, you do not need any
protocol-specific configuration, only IP addresses.

Layer 2 mode does not require IP addresses to be bound to the network
interfaces of your worker nodes. It responds to ARP requests on the local
network and gives clients the machine's MAC address.

Note the following requirements for MetalLB IP address ranges:

- MetalLB IP address ranges or CIDRs must be within the node's primary network
  subnet.
- MetalLB IP address ranges, CIDRs, and node subnets must not conflict with
  the Kubernetes cluster pod and service subnets.

For example, the following configuration gives MetalLB control over IP
addresses from 192.168.1.240 to 192.168.1.250 and configures layer 2 mode.
Replace the values with values specific to your environment.

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: example
namespace: metallb-system
spec:
addresses:
- 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
name: example
namespace: metallb-system
spec:
ipAddressPools:
- example
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

BGP Configuration

For a basic BGP configuration featuring one router and one IP address range,
you need the following information:

- The router IP address that MetalLB needs to connect to.
- The router's autonomous systems (AS) number.
- The MetalLB AS number.
- An IP address range expressed as a Classless Inter-Domain Routing (CIDR)
  prefix.

For example, if you specify 192.168.10.0/24 as the MetalLB range, 64500 as the
MetalLB AS number, 10.0.0.1 as the router IP address, and 64501 as the router
AS number, your configuration looks like this:

```bash
cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
name: example
namespace: metallb-system
spec:
myASN: 64500
peerASN: 64501
peerAddress: 10.0.0.1
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: example
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
- example
EOF
```

After this completes, run the following kubectl command.

```bash
kubectl apply -f metallb-conf.yaml
```

### Registry and Registry Mirrors

In an air-gapped environment, you need a local repository to store Helm
charts, Docker images, and other artifacts. In an environment with access to
the Internet, you can retrieve artifacts from specialized repositories
dedicated to them, such as Docker images contained in DockerHub and Helm
Charts that come from a dedicated Helm Chart repository.

Nutanix Kubernetes Platform (NKP) supports operation with several local
Registry Mirror Tools on page 1028.

- Registry Mirrors are local copies of images from a public registry that
  follow (or mirror) the file structure of a public registry. If you need to
  set up a private registry with a registry mirror or details on using the
  flag(s), see Using a Registry Mirror on page 1030.
- Container registries are collections of container repositories and can also
  offer API paths and access rules.
- Container repositories are a collection of related container images. The
  container image has everything the software might need to run, including
  code, resources, and tools. Container repositories store container images
  for setup and deployment, and you use the repositories to manage, pull, and
  push images during cluster operations.

Kubernetes does not natively provide a registry for hosting the container
images you will use to run the applications you want to deploy on Kubernetes.
Instead, Kubernetes requires you to use an external solution to store and
share container images. A variety of Kubernetes-compatible registry options
are compatible with NKP.

How the Registry Mirror Works

The first time you request an image from your local registry mirror, it pulls
the image from the public registry (such as Docker) and stores it locally
before handing it back to you. On subsequent requests, the local registry
mirror can serve the image from its storage.

Air-gapped vs. Non-air-gapped Environments

In a non-air-gapped environment, you can access the Internet. You retrieve
artifacts from specialized repositories dedicated to them, such as Docker
images contained in DockerHub and Helm Charts that come from a dedicated Helm
Chart repository. You can also create your local repository to hold the
downloaded container images needed or any custom images you have created with
the Nutanix Image Builder on page 51 tool.

In an air-gapped environment, you need a local repository to store Helm
charts, Docker images, and other artifacts.
Private registries provide security and privacy in enterprise container image
storage, whether hosted remotely or on-
premises locally in an air-gapped environment. NKP in an air-gapped
environment requires a local container registry of
trusted images to enable production-level Kubernetes cluster management.
However, a local registry is also an option in
a non-air-gapped environment for speed and security.

If you want to use images from this local registry to deploy applications
inside your Kubernetes cluster, you will need
to set up a secret for a private registry. The secret contains your login
data, which Kubernetes needs to connect to
your private repository. It is not required to export any variables for most
of the command examples. However, the
export, along with an arbitrary variable name, primarily clarifies what values
in the commands need to be substituted.
Also, that makes it easier to copy and paste the examples. Furthermore, if
multiple steps in a procedure need you to
specify a variable, you export it once with the following export command and
then reuse it in future commands.

For example,

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
```

To run the create cluster command using that variable created above, use the
example command replacing azure with your choice of provider gcp, vsphere,
vcd, pre-provisioned, aws:

```bash
nkp create cluster azure --registry-mirror-url=${REGISTRY_URL}
```

| vsphere, | vcd |
| -------- | --- |

A cluster administrator uses NKP CLI commands to upload the image bundle to
your registry with the parameters:

```bash
nkp push bundle --bundle <bundle> --to-registry=${REGISTRY_URL}
```

Parameter definitions:

- --bundle `<bundle>` the group of images. The example below is for the NKP
  air-gapped environment bundle
- Either use exported variable ${REGISTRY_URL} or --to-registry=`<registry-
address>`/`<registry- name>` to provide registry location for push

Command example:

```bash
nkp push bundle --bundle container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=333000009999.dkr.ecr.us-west-2.amazonaws.com/can-test
```

Any URL can contain an optional port specification. If no port is specified,
then the default port for the protocol is assumed. For example, for HTTPS
protocol, port 443 is the default, meaning these two URLs are equivalent:

```bash
https://docs.nutanix.com
https://docs.nutanix.com:443
```

A port specification is only required if the URL target uses a port number
other than the default.

Related Information

- Registry Mirror Tools on page 1028
- Using a Registry Mirror on page 1030
- Seeding the Registry for an Air-gapped Cluster on page 1030
- Images Download into Your Registry: Air-gapped Environments on page 982

### Cluster Pod and Services Subnets

About this task

A Kubernetes cluster defines subnets for Pods and Services. These subnets must
not overlap with subnets used by cluster Nodes, i.e. the machines that form
the cluster. In infrastructures where you allocate virtual IPs for
LoadBalancer Services, the Pods and Services subnets must not overlap with the
virtual IP subnets.

> **Note:**

- If the default Pods or Services subnets overlap with any subnets used by
  cluster Nodes, you must change the Pods or Services subnets. You must do
  this at cluster creation.
- The custom Pod network configurations for Grafana Loki are not supported.
- The default subnets used in NKP are:

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

To change the subnets, perform the following steps:

Procedure

1. Generate the YAML Ain't Markup Language (YAML) manifests for the cluster
   using the --dry-run and -o

yaml flags, along with the desired nkp cluster create command. Example:

```bash
nkp create cluster preprovisioned --cluster-name ${CLUSTER_NAME} --control-plane-
endpoint-host <control plane endpoint host> --control-plane-endpoint-port <control
plane endpoint port, if different than 6443> --dry-run -o yaml > cluster.yaml
```

1. To modify the Services subnet, add or edit the
   spec.clusterNetwork.services.cidrBlocks field of the

Cluster object. Example:

```yaml
kind: Cluster
spec:
clusterNetwork:
services:
cidrBlocks:
  - 10.0.0.0/12
```

1. To modify the cluster: Add or edit the spec.clusterNetwork.pods.cidrBlocks
   field. Example:

```yaml
kind: Cluster
spec:
clusterNetwork:
pods:
cidrBlocks:
  - 172.16.0.0/16
```

1. If using Calico CNI, update its configuration to edit the data."custom-

resources.yaml".spec.calicoNetwork.ipPools.cidr field with your desired Pod
subnet. Example:

```yaml
apiVersion: v1
data:
custom-resources.yaml: |
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
name: default
spec:
# Configures Calico networking.
calicoNetwork:
# Note: The ipPools section cannot be modified post-install.
ipPools:
- blockSize: 26
cidr: 172.16.0.0/16
kind: ConfigMap
metadata:
name: calico-cni-<cluster-name>
```

When you provision the cluster, the configured Pod and Services subnets are
applied.

### Creating a Bastion Host

About this task

Ensure the items below are installed and the environment matches the
requirements below:

- Create a bastion VM host template for the cluster nodes to use within the
  air-gapped network. This bastion VM host also needs access to a local
  registry instead of an Internet connection to pull images.
- Find and record the bastion VM's IP or hostname.
- Download the following required NKP Konvoy binaries and installation bundles
  are discussed in step 5 below. To access the download bundles, see
  Downloading NKP on page 16.
- A local registry or Docker version 27.4.0 installed. You must install Docker
  on the host where the NKP Konvoy CLI runs. For example, if you install
  Konvoy on your laptop, ensure the computer has a supported version of
  Docker. On macOS, Docker runs in a virtual machine that you configure with
  at least 8GB of memory. For information on the local registry, see Registry
  Mirror Tools on page 1028. For information on Docker, see
  `<https://docs.docker.com/get-docker/>`.
- To interact with the running cluster, install kubectl on the host where the
  NKP Konvoy command line interface (CLI) runs. For more information, see
  kubectl.
- You must have the following resource requirements: vCPU Count 8, Memory 16
  GB, and Disk Volume 80 GB. For more information see Resource requirements

Depending on your OS, various commands exist to set up your bastion host in an
air-gapped environment. The vSphere example workflow shows a generic instance
for Red Hat Enterprise Linux (RHEL) Bastion nodes using Docker.

Procedure

1. Open an ssh terminal to the bastion host and install the tools and packages
   using the command sudo yum

install -y yum-utils bzip2 wget. 2. Install kubectl. RHEL example:

```bash
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo yum install -y kubectl
```

1. Install Docker, for example (only on the Bastion Host), and add the
   repository for upstream Docker using the command.

```bash
sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-
ce.repo
Note: Other Docker repository downloads are available on docker.com: https://download.docker.com/
linux/
```

Docker Install example:

```bash
sudo yum install -y docker-ce docker-ce-cli containerd.io
```

1. Get the required Nutanix Software by downloading the air-gapped bundle.
   Download nkp-air-gapped-bundle_nkp-version_linux_amd64.tar.gz, extract the
   tar file to a local directory using the command tar -xzvf nkp-air-gapped-
   bundle_nkp-version_linux_amd64.tar.gz
2. Set the following environment variables to enable connection to an existing
   Docker or other registry using the command export
   REGISTRY_ADDRESS=`<https/http>`://`<registry-address>`:`<registry-port>`
   export REGISTRY_CA=`<path to the CA on the bastion host>`.

> **Note: You must create the VM template with the Nutanix Image Builder to
> use the registry mirror feature.**

Command variables for the export REGISTRY command.

- REGISTRY_ADDRESS: The address of an existing registry accessible in the
  environment where the new cluster nodes will be configured to use a mirror
  registry when pulling images.
- REGISTRY_CA: (Optional) path on the bastion host to the registry CA. Konvoy
  configures the cluster nodes to trust this CA. This value is only needed if
  the registry is using a self-signed certificate and the VMs are not already
  configured to trust this CA.

Each infrastructure provider has its own set of bastion host instructions.
Refer to your own OS instructions to setup a bastion host like AWS Bastion,
Azure, GCP, or vSphere.

### Export Registry Variables and Flags for Cluster Creation

If you have a local registry, you must provide additional arguments when
creating the cluster. These tell the cluster where to locate the local
registry to use by defining the URL. Set the needed environment variable(s)
with your registry information:

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_CA=<path to the CA on the bastion>
export REGISTRY_USERNAME=<username>
export REGISTRY_USERNAME=<password>
```

- REGISTRY_URL: the address of an existing container registry accessible in
  the VPC that the new cluster nodes will be configured to use a mirror
  registry when pulling images.
- REGISTRY_CA: (optional) the path on the bastion machine to the container
  registry CA. Konvoy will configure the cluster nodes to trust this CA. This
  value is only needed if the registry is using a self-signed certificate and
  the AMIs are not already configured to trust this CA.
- REGISTRY_USERNAME: optional, set to a user that has pull access to this
  registry.
- REGISTRY_PASSWORD: optional if username is not set.

When creating the cluster, apply the variables you defined above during the
nkp create cluster command with the flags needed for your environment:

```bash
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-cacert=${REGISTRY_CA} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD}
```

#### Export Variables

Set the environment variable with your registry information.

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
export REGISTRY_CA=<path to the cacert file on the bastion>
```

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

| tar -xzvf nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| ------------------------------- | ----------- | ------------------ |

Definitions:

```yaml
REGISTRY_URL: the address of an existing local registry accessible in the VPC that the new cluster nodes will be
configured to use a mirror registry when pulling images.
```

- For example, `<https://registry.example.com>`

Other local registries may use the options below:

- REGISTRY_USERNAME: optional-set to a user with pull access to this registry.
- REGISTRY_PASSWORD: optional if username is not set.
- JFrog - REGISTRY_CA: (optional) the path on the bastion machine to the
  registry CA. This value is only needed if the registry uses a self-signed
  certificate and the AMIs are not already configured to trust this CA.
- To increase Docker Hub's rate limit use your Docker Hub credentials when
  creating the cluster by setting flags ----registry-mirror-
  url=`<https://registry-1.docker.io>` --registry-mirror- username=`<your-
username>` --registry-mirror-password=`<your-password>` when running nkp
  create cluster.

### FIPS Requirements

To create a cluster in FIPS mode, inform the controllers of the appropriate
image repository and version tags of the official Nutanix FIPS builds of
Kubernetes by adding those flags to nkp create cluster command:

```bash
--kubernetes-version=v<kubernetes-version>+fips.0 \
--etcd-version=etcd-version+fips.0 \
--kubernetes-image-repository=docker.io/mesosphere \
```

For more information about enabling FIPS in the cluster, see Creating the
Nutanix Kubernetes Platform Management Cluster using CLI on page 740.

For more information about the supported Kubernetes version, see Supported
Kubernetes Versions section in the NKP Release Notes. For more information
about the supported etcd version, see Supported Components section in the NKP
Release Notes.

### Output Directory Flag

When creating a cluster, you can use the --output-directory flag to organize
the cluster configuration into individual files. This is particularly useful
for ease of editing and managing the cluster configuration. The flag creates
multiple files in the specified directory, which must already exist.

Refer to the Pre-provisioned Cluster Creation Customization Choices on page
770 section for more information on how to use optional flags such as the
--output-directory flag.

```bash
Example:
--output-directory=<existing-directory>
```

Cluster creation results:

The output from this command is shortened here for reading clarity, but should
start like this:

```bash
Generating cluster resources
cluster.cluster.x-k8s.io/cluster_name created
cont.........
```

### Provision Flatcar Linux OS

Flatcar default network interface name might require specifying. It is most
likely to be ens192 , which requires passing the parameter --virtual-ip-
interface ens192 to the nkp create cluster aws command. Otherwise, the cluster
creation might fail because kube-vip can not configure the first control-plane
virtual IP.

Flatcar Linux Example

These flags are also shown in context on the Create Cluster page for either
air-gapped or non-air-gapped environments:

Amazon Web Services (AWS) Example is shown; replace aws with vsphere if
required:

```bash
nkp create cluster aws \
--cluster-name ${CLUSTER_NAME} \
--os-hint flatcar
Note: For provisioning Nutanix Kubernetes Platform (NKP) on Flatcar, NKP configures cluster nodes to use Control
Groups (cgroups) version 1. In versions before Flatcar 3033.3.x, a restart is required to apply the changes to the kernel.
```

Also note that once Ignition runs, it is not available on reboot.

For more information on Flatcar usage, see:

- Flatcar documentation: `<<https://www.flatcar.org/docs/latest/container->`
  runtimes/switching-to-> unified-cgroups/#starting-new-nodes-with-legacy-
  cgroups
- Control Groups version 1:`<<https://www.kernel.org/doc/html/latest/admin->`
  guide/cgroup-v1/> cgroups.html#what-are-cgroups
- Ignition
  `<<https://www.flatcar.org/docs/latest/provisioning/ignition/#ignition-only->`
  runs-once>

### Inspect Cluster for Issues

You can investigate what is running and what has failed to try to resolve
those issues independently.

Investigate Cluster Issues

These commands can provide helpful information for troubleshooting.

- Check your pods to see if anything not running and investigate those pods.
  You can view your pods by checking their status with the command:

```bash
kubectl get pods -A
```

- You can check the logs in your cluster API pod of your cluster
  infrastructure provider choice. The example below uses Nutanix
  infrastructure, so replace it with your infrastructure.

```bash
kubectl logs -l cluster.x-k8s.io/provider=infrastructure-nutanix --namespace capx-
system --kubeconfig ${CLUSTER_NAME}.conf
```

- If you still have your bootstrap cluster running, you can check your CAPI
  logs from the bootstrap with the command. The example below uses Nutanix
  infrastructure, so replace it with your CAPI driver and infra name.

```bash
kubectl logs -l cluster.x-k8s.io/provider=infrastructure-nutanix --namespace capx-
system --kubeconfig ${CLUSTER_NAME}-bootstrap.conf
```

### Configuring Self-healing

About this task

To configure self-healing, follow these steps:

Procedure

1. Open a command line interface (CLI).
2. View the MachineHealthCheck resources:

```bash
kubectl get MachineHealthCheck
```

The list of MachineHealthCheck resources is displayed.

```bash
$ kubectl get MachineHealthCheck
NAME CLUSTER EXPECTEDMACHINES MAXUNHEALTHY CURRENTHEALTHY AGE
nkp-j5h4n nkp 3 40% 3 8h
nkp-md-0-qgxr8 nkp 4 40% 4 8h
```

In this example, the MachineHealthChecks for a control node pool named
nkp-j5h4n and a worker node pool named nkp-md-0-qgxr8 are displayed. 3. Edit
the required MachineHealthCheck resource:

» For ClusterClass-based clusters, run the following command:

```bash
kubectl edit cluster -n <namespace> <cluster name>
```

Replace `<namespace>` and `<cluster name>` with the appropriate information.

» For non-ClusterClass-based clusters, run the following command:

```bash
kubectl edit machinehealthcheck -n <namespace> <mhc-name>
```

Replace `<mhc-name>` with the name of the MachineHealthCheck resource of the
control pane node pool or the worker pane node pool. Edit the resource under
spec.

To configure MachineHealthCheck settings per node pool, edit the Cluster
resource under:

```bash
spec.topology.workers.machineDeployments[*].machineHealthCheck
```

For example:

```bash
spec:
topology:
workers:
machineDeployments:
- name: <nodepool-name>
class: <md-class&gt;
machineHealthCheck:
maxUnhealthy: 50%
```

1. Search for spec.maxUnhealthy.

> **Note: The default value is 40%.** 5. Update the value of
> spec.maxUnhealthy as required For example:

```bash
[...]
spec:
clusterName: nkp
maxUnhealthy: 50%
nodeStartupTimeout: 10m0s
[...]
```

1. Save the changes.
2. Verify this update:

```bash
kubectl describe machinehealthcheck <mhc-name>
```

### Certificate Renewal

You can renew the control plane certificate using one of the following
automated methods:

#### Renewing the Control Plane Certificate Using Cluster API Method

> **Note:**

- Nutanix recommends that you renew the control plane certificates in the NKP
  cluster only using the Cluster API (CAPI) method.
- NKP does not support automated renewal of control plane certificates for
  attached clusters. Nutanix recommends renewing the control plane
  certificates for those clusters manually to prevent cluster inaccessibility
  due to an expired certificate.

### Certificate Renewal (2)

About this task

To configure an automated renewal of control plane certificates using CAPI in
a new NKP cluster or in an existing control plane node, follow these steps:

Procedure

1. If you are creating a NKP cluster, follow these steps:

a. Create a NKP cluster.

By default, NKP sets the control plane certificate expiry to 180 days.

The supported infrastructure providers are Nutanix, AWS, Azure, GCP, Pre-
provisioned, and vSphere.

b. (Optional) Set the automated renewal interval for the control plane
certificate.

```bash
nkp create cluster infrastructure-provider --control-plane-renew-certificates-
before=50
```

The control-plane-renew-certificates-before flag indicates the number of days
before expiry when the control plane certificate renews automatically.

For example, a control-plane-renew-certificates-before value of 50 indicates
that the certificate automatically renews 50 days before expiration.

c. (Optional) Disable the automated renewal of control plane certificate on a
newly created NKP cluster.

```bash
nkp create cluster infrastructure-provider --control-plane-renew-certificates-
before=0
```

A control-plane-renew-certificates-before value of 0 disables the automated
renewal of control plane certificate.

```yaml
Note: If you disable the automated renewal of control plane certificate, you must manually renew the certificate
to prevent cluster inaccessibility due to expired certificate. For more information, see KB 19301.
```

1. To enable automated renewal of control plane certificate on an existing NKP
   cluster, follow these steps:

a. Update an existing control plane node pool in the NKP cluster.

```bash
nkp update controlplane infrastructure-provider --control-plane-renew-
certificates-before=50
```

The supported infrastructure providers are Nutanix, AWS, Azure, GCP, Pre-
provisioned, and vSphere.

The control-plane-renew-certificates-before flag indicates the number of days
before expiry when the control plane certificate renews automatically.

For example, a control-plane-renew-certificates-before value of 50 indicates
that the certificate automatically renews 50 days before expiration.

To modify the automated renew interval of control plane certificate, update
the control-plane-renew- certificates-before flag value as necessary.

b. (Optional) Disable the automated renewal of control plane certificate on an
existing NKP cluster.

```bash
nkp update controlplane infrastructure-provider --control-plane-renew-
certificates-before=0
```

A control-plane-renew-certificates-before value of 0 disables the automated
renewal of control plane certificate.

```yaml
Note: If you disable the automated renewal of control plane certificate, you must manually renew the certificate
to prevent cluster inaccessibility due to expired certificate. For more information, see KB 19301.
```

#### Viewing Alerts

| nkp create cluster | infrastructure-provider | Col3 |
| ------------------ | ----------------------- | ---- |

control plane certificate before it expires. Based on the expiry status and
renewal interval, NKP displays alerts with different severity levels,
including informational, warning, and critical alerts in the Kommander user
interface.

About this task

If you enable automated renewal of the control plane certificate during
cluster creation, the Kommander user interface displays the following alerts:

- Renews in (X) day: Triggers between one and seven days before automatic
  renewal.

(X) indicates one to seven days.

- Renewal In Progress: Triggers on the renewal day.
- Renewal Might Fail: Triggers as the renewal interval advances and one or
  more nodes fail to complete automated certificate renewal.
- Expired: Triggers when the automated certificate renewal fails and the
  certificate expires.

If you disable or when NKP does not support automated renewal of the control
plane certificate during cluster creation, the Kommander user interface
displays the following alerts:

- Auto-Renewal Disabled: Triggers when you disable automated renewal of
  control plane certificates.
- Unknown: Displays when NKP does not support automated renewal or cannot
  retrieve the renewal information.

> **Note: NKP does not support automated renewal of control plane
> certificates for the attached clusters.**

To view the alerts, follow these steps:

Procedure

1. Log in to the NKP user interface.

By default, the Dashboard displays both management and managed clusters. 2. In
the left navigation menu, click Clusters.

You can view the alerts on the following pages:

- To filter the cluster widget based on the severity of certificate alert,
  click All, Errors, Warning, or Notice tab.
- To view all the alerts, click All.
- When the certificate renewal fails, NKP displays the alerts in Errors.
- When the certificate might fail, NKP displays the alerts in Warning.
- When the certificate renewal is in X number of days or in progress, NKP
  displays the alerts in Notice.
- In the cluster (management or managed) widget, click the Certificate button.

A dialog box displays an appropriate alert message based on the alert.

> **Note:**

- The Certificate button appears in the widget when seven or fewer days remain
  before renewal.
- The Certificate button is greyed out when you disable or when NKP does not
  support automated renewal.
- In the Management Cluster or managed cluster widget, click View Details.

In the General Cluster Information page, click the alert message such as:

- Renews in 7 days
- Renewal In Progress
- Renewal Might Fail
- Expired
- Auto-Renewal Disabled
- Unknown

A dialog box displays an appropriate alert message based on the alert.

- To view the expiry and automated renewal information of a control plane
  certificate, go to Management Cluster or managed cluster widget, click View
  Details and select the Configuration tab.

Figure 21: Certificate Renewal Alerts

If you disable automated renewal of the control plane certificate, Nutanix
recommends that you either enable automated renewal or manually renew the
control plane certificate.

If NKP does not support automated renewal of the control plane certificate, it
triggers an alert Unknown. Nutanix recommends that you manually renew the
control plane certificate.

If the automated control plane certificate renewal fails or passes its expiry
date, Nutanix recommends that you manually renew it.

For more information, see KB 19301. 3. (Optional) To view the certificate
alerts in the Prometheus user interface, follow these steps:

a. In the Management Cluster widget, click View Details.

b. In the Enabled Applications tab, go to Prometheus widget and click
Dashboard. The Prometheus application is launched.

c. Go to the Alerts tab. The Alerts tab displays all the active and inactive
AutoRenewalCertificateAlerts. 4. To view the certificate alerts in NKP
Insights, see Nutanix Kubernetes Platform Insights Alerts on page 1125.

## Install Nutanix Kubernetes Platform on Nutanix Infrastructure

Install Nutanix Kubernetes Platform (NKP) on a Nutanix infrastructure.

This table lists all the steps to configure Nutanix infrastructure and NKP for
air-gapped and non-air-gapped environments.

Table 64: Installing NKP on Nutanix

Pre-requisites and Planning

- Nutanix Kubernetes Platform Requirements on page 45
- Nutanix Infrastructure Requirements on page 719
- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721

Access & Identity Management - Prism Central

- Prism Central Requirements for Nutanix Kubernetes Platform Installation on
  page 729
- Prism Central Credential and Role Management on page 729
- Preparing Prism Central Resources for the Nutanix Kubernetes Platform
  Cluster on page 732

Infrastructure Preparation

- Managing VMs from VLAN Basic Subnets to Network Controller-based VLAN
  Subnets on page 733
- Creating the Operating System Package Bundle on page 734
- Creating a Nutanix VM Image on page 734
- Preparing a Local Registry Mirror on page 736 (Required for air-gapped, and
  optional for non- airgapped environments)
- Pushing Images to the Registry on page 737 (Required for air-gapped, and
  optional for non- airgapped environments)

Installation

- Preflight Checks on page 747
- Deploying Nutanix Kubernetes Platform using UI from Nutanix Marketplace on
  page 738
- Creating the Nutanix Kubernetes Platform Management Cluster using CLI on
  page 740
- Creating a Nutanix Cluster With Custom Cilium Configuration on page 748
  (Advanced Use-cases)

| Section | Steps |
| ------- | ----- |

Post-Installation

- Setting up the Nutanix Kubernetes Platform User Interface Access on page 750
- Updating Prism Central Credentials on Deployed NKP Clusters on page 751

### Nutanix Kubernetes Platform Installation Prerequisites

The following requirements apply to installations of NKP on a Nutanix
infrastructure:

#### Nutanix Infrastructure Requirements

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Prism Central Requirements for Nutanix Kubernetes Platform Installation on
  page 729
- Managing VMs from VLAN Basic Subnets to Network Controller-based VLAN
  Subnets on page 733
- Creating the Operating System Package Bundle on page 734

Before installing Nutanix Kubernetes Platform (NKP) on a Nutanix
infrastructure, verify that your environment meets the following basic
requirements:

- Ensure the Prism Central and AOS versions are compatible. For more
  information, see Compatibility and Interoperability Matrix.
- The Nutanix environment must be either on-premises or hosted on one of the
  public clouds, such as NC2 Azure, NC2 AWS, or NC2 GCP.
- NKP is supported on Nutanix Cloud Platform with the following external
  storage integrations:
- Dell PowerFlex:
- For the supported configuration maximums and minimums, see Configuration
  Maximums and Minimums for NCP with Dell PowerFlex.
- For the recommendations and limitations, see Recommendations and Limitations
  of NCP with Dell PowerFlex.
- Pure Storage FlashArray:
- For the supported configuration maximums and minimums, see Configuration
  Maximums and Minimums for NCP with Pure Storage FlashArray.
- For the recommendations and limitations, see Recommendations and Limitations
  of NCP with Pure Storage FlashArray.

| Section | Steps |
| ------- | ----- |

- Configure valid values in the Prism Central instance.

For more information, see Prism Central Settings (Infrastructure).

- Ensure that the DNS servers configured on the Prism Central instance are
  reachable.
- You must have a pre-designated subnet.
- Ensure that a subnet is available with unused IP addresses.

Configure either Nutanix IP address management (IPAM) or dynamic host
configuration protocol (DHCP) on the subnet to automatically assign IP
addresses to control plane nodes and worker nodes.

Compute the number of required IP addresses:

- One IP address for each node in the Kubernetes cluster. The default cluster
  size includes three control plane nodes and four worker nodes, requiring a
  total of seven IP addresses.
- One IP address within the same classless inter-domain routing (CIDR) as the
  subnet, but outside the address pool for the Kubernetes API server.
- One IP address in the same CIDR as the subnet, but outside the address pool
  for the default ingress.
- Additional IP addresses might be required for additional load balancer
  services, such as Nutanix Data Services for Kubernetes (NDK).

For more information, see Prerequisites and Limitations in the Nutanix Data
Services for Kubernetes guide.

Example configuration: If your subnet uses the CIDR 10.0.0.0/24 and the DHCP
or Nutanix IPAM IP address pool range is 10.0.0.100 to 10.0.0.200, the system
randomly selects the individual node IP addresses of the cluster from that
address pool. Outside the IP address pool, reserve one IP address (for
example, 10.0.0.90)

for the Kubernetes control plane endpoint. Reserve a contiguous IP address
range on the same subnet as the worker nodes for MetalLB load balancer
services; for example, 10.0.0.150 to 10.0.0.160.

- Multi subnet configuration (optional)

Use different subnets for control plane nodes and worker nodes only under the
following conditions:

- Routing: Establish network routing between the control plane and worker node
  subnets.
- Nodes on multiple subnets: If you distribute worker and control plane nodes
  across multiple subnets, ensure that the IP range provided for the load
  balancer service (MetalLB) belongs to a Layer 2 subnet shared by all those
  nodes.
- For air-gapped environments, create a bastion VM host template with access
  to a configured local registry.

Nutanix recommends using a naming pattern such as ../folder-name/NKP-bastion-
template. Each infrastructure provider has its own instructions for setting up
a bastion host.

For more information, see Creating a Bastion Host on page 707.

- You need access to a bastion VM or other network-connected host running NKP
  image builder.

```yaml
Note: Nutanix provides a complete image built on its infrastructure, which eliminates the need to create your
own from a BaseOS image.
```

- Ensure that you can reach the Nutanix endpoint from where you run NKP CLI.

> **Note:**

- For an air-gapped environment, ensure that you download the bundle and
  extract the TAR file to a local directory.

For more information, see Downloading NKP on page 16.

- Some commands, such as nkp push bundle, require temporary disk space. These
  commands write to the temporary directory, which is usually /tmp. To
  override the directory, export the TMPDIR environment variable before
  running a command.

For example,

```bash
export TMPDIR=/path/to/your/directory
```

For more information on troubleshooting or additional information, see Nutanix
Knowledge Base.

#### Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix

Kubernetes Platform

> **Note:**

- NKP uses the Nutanix Container Storage Interface (CSI) driver as the default
  storage provider.

For more information, see Default Storage Providers on page 34.

- The Nutanix CSI driver uses the storage container associated with the Prism
  Central cluster. Every Prism Central cluster maintains its own set of
  storage containers, and the CSI driver searches for a storage container with
  the same name across all Prism Central clusters.

##### Starter Nutanix Kubernetes Platform Cluster Minimum Requirements

Note the minimum requirements for the Starter Nutanix Kubernetes Platform
(NKP) management and managed clusters.

The default configuration is set to three control plane nodes to provide high
availability. The exact number of worker nodes required for your environment
might vary depending on the workload of your cluster and the size of the
nodes.

> **Note:**

- The Starter license is supported exclusively with the Nutanix infrastructure.
- If you have two worker nodes in your Starter NKP management and managed
  clusters and you apply for a Pro or Ultimate license, the additional Pro or
  Ultimate features fail because your environment does not have enough cluster
  resources to deploy them.

To install the Starter NKP management and managed clusters with the minimum
amount of resources, review the resource tables before starting the
installation.

Table 65: Resource Requirements for Management Cluster

Minimum node requirements

3 2

vCPU count 2 4

Memory 8 GiB 8 GiB

Disk volume Approximately 80 GiB:

Used for /var/lib/kubelet and /var/ lib/containerd

Approximately 80 GiB:

Used for /var/lib/kubelet and /var/ lib/containerd

Root volume Disk usage must be below 85% Disk usage must be below 85%

Non-default flags in the CLI --control-plane-vcpus 2 \ --control-plane-memory
8 \ --worker-replicas 2 \ --worker-vcpus 4 \ --worker-memory 8

Table 66: Resource Requirements for Managed Cluster

Minimum node requirements

3 2

vCPU count 2 3

Memory 6 GiB 6 GiB

Disk volume Approximately 80 GiB:

Used for /var/lib/kubelet and /var/ lib/containerd

Approximately 80 GiB:

Used for /var/lib/kubelet and /var/ lib/containerd

| Resource | Control Plane Node | Worker Node |
| -------- | ------------------ | ----------- |

| Resource | Control Plane Node | Worker Node |
| -------- | ------------------ | ----------- |

Root volume Disk usage must be below 85% Disk usage must be below 85%

Non-default flags in the CLI --control-plane-vcpus 2 \ --control-plane-memory
6 \ --worker-replicas 2 \ --worker-vcpus 3 \ --worker-memory 6

```yaml
Caution: You can create a working NKP management cluster with a single control plane node. However, if the single
control plane node faces corruption or failure, it results in the loss of the entire cluster.
```

##### Pro and Ultimate Nutanix Kubernetes Platform Cluster Minimum Requirements

Note the minimum requirements for Pro and Ultimate Nutanix Kubernetes Platform
(NKP) management cluster.

The exact number of worker nodes required for your environment might vary
depending on the workload of your cluster and
the size of the nodes. The default configuration is set to three control plane
nodes to provide high availability. If
you follow the instructions to create a cluster using the default NKP settings
without modifying the configuration files
or additional flags, you can deploy the cluster with three control plane nodes
and four worker nodes, matching the
requirements in the General Resource Requirements for Pro and Ultimate
Clusters table.

```yaml
Caution: You can create a working NKP management cluster with a single control plane node. However, if the single
control plane node faces corruption or failure, it results in the loss of the entire cluster.
```

To install Pro and Ultimate NKP clusters with minimum resources, review the
requirements table before starting the installation.

Table 67: General Resource Requirements for Pro and Ultimate Clusters

Optimal nodes recommended

3 4

vCPU count 4 8

Memory 16 GiB 32 GiB

Disk volume Approximately 80 GiB: Used for / var/lib/kubelet and /var/lib/
containerd

Approximately 80 GiB: Used for / var/lib/kubelet and /var/lib/ containerd

Root volume Disk usage must be below 85% Disk usage must be below 85%

Table 68: Resource Requirements for Managed Clusters

Optimal nodes recommended

3 4

vCPU count 4 8

| Resource | Control Plane Node | Worker Node |
| -------- | ------------------ | ----------- |

| Resource | Control Plane Node | Worker Node |
| -------- | ------------------ | ----------- |

| Resource | Control Plane Node | Worker Node |
| -------- | ------------------ | ----------- |

Memory 12 GiB 12 GiB

Disk volume Approximately 80 GiB: Used for / var/lib/kubelet and /var/lib/
containerd

Approximately 80 GiB: Used for / var/lib/kubelet and /var/lib/ containerd

Root volume Disk usage must be below 85% Disk usage must be below 85%

##### Infrastructure Provider-Specific Requirements

Note the additional requirements that might apply to a certain infrastructure
providers.

For example, the Nutanix Kubernetes Platform (NKP) on Azure by default deploys
a Standard_D4s_v3 VM with a 128 GiB volume for the operating system and an 80
GiB volume for etcd storage, which meets the specified requirements.

For more information on resource requirements, see the relevant installation
options for the respective infrastructure provider:

- Nutanix Installation Options on page 72
- Pre-provisioned Installation Options on page 72
- AWS Installation Options on page 168
- Azure Installation Options on page 250
- vSphere Installation Options on page 189
- EKS Installation Options on page 168
- AKS Installation Options on page 260

##### Nutanix Kubernetes Platform Configuration Maximums

Note a list of supported configuration maximum for Nutanix Kubernetes Platform
(NKP).

You can view the latest list of supported configuration maximums from the
Nutanix Support Portal. For more information, see NKP Configuration Maximums.
Ensure that you select the required NKP version from the list.

> **Note: A Nutanix account is required to access the Nutanix Support Portal.**

##### Nutanix Kubernetes Platform Managed Cluster Requirements

Note the requirements for the Nutanix Kubernetes Platform (NKP) managed
clusters.

Minimum Recommendation for Managed Clusters

To create additional clusters in your Nutanix environment, ensure that you
have at least the following minimum recommended resources:

| Resource | Control Plane Node | Worker Node |
| -------- | ------------------ | ----------- |

- Worker Nodes: The default installation includes at least four worker nodes
  with the following specifications:
- 8 CPU cores each
- 12 GiB of memory
- A storage class and disk mounts that accommodate at least four persistent
  volumes

```yaml
Note: You need four worker nodes to support the upgrades to rook-ceph platform application. rook-ceph
supports the logging stack, velero backup tool, and NKP Insights. If you disable rook-ceph platform
application, you need only three worker nodes.
```

- Control Plane Nodes: The default installation includes at least three
  control plane nodes with the following specifications:
- 4 CPU cores each
- 12 GiB of memory

```yaml
Note: While one control plane node is acceptable for a non-critical test environment, any production workload
cluster must have at least three control plane nodes.
```

- Cluster: Requires a default storage class and three volumes of 10GiB,
  100GiB, and 10GiB or the ability to create those volumes based on the
  storage class.

Create a volume based on the storage class.

```bash
$ kubectl get pv -A
NAME CAPACITY ACCESS MODES RECLAIM POLICY
STATUS CLAIM STORAGECLASS
VOLUMEATTRIBUTESCLASS REASON AGE
pvc-01497817-b03a-4572-80e3-37839e29e116 10Gi RWO Delete
Bound york-ws/opencost-pvc ebs-sc
<unset> 151m
pvc-82461b4c-51e6-4f5f-b1c9-04cbf5f5eb40 100Gi RWO Delete
Bound york-ws/db-prometheus-kube-prometheus-stack-prometheus-0 ebs-sc
<unset> 151m
pvc-8a70db2f-101a-4d09-8fd3-2bc0b649df3d 10Gi RWO Delete
Bound york-ws/kube-prometheus-stack-grafana ebs-sc
<unset> 151m
```

> **Note: Actual workload clusters might demand more resources based on the
> usage.**

##### Nutanix Kubernetes Platform Management Cluster Application Requirements

Note the requirements for the Nutanix Kubernetes Platform (NKP) management
cluster applications.

The following table lists the workspace platform applications that are
specific to a management cluster including their minimum resource
requirements, minimum persistent storage requirements, and default
PriorityClass values. For more information on a list of all platform
applications, see Platform Application Configuration Requirements.

Common Name

Application ID Deployed by Default

Minimum Resources

Minimum Persistent Storage

Default PriorityClass

Centralized Grafana\*

centralized- grafana

Yes cpu: 200m

memory: 100Mi

Not applicable NKP Critical (100002000)

Centralized OpenCost\*

centralized- openCost

Yes cpu: 10m

memory: 55Mi

## of PVs: 1

PV sizes: 10Gi

NKP High (100001000)

Dex dex Yes cpu: 100m

memory: 50Mi

Not applicable NKP Critical (100002000)

Dex Authenticator

dex-k8s- authenticator

Yes cpu: 100m

memory: 128Mi

Not applicable NKP High (100001000)

Karma\* karma Yes Not applicable Not applicable NKP Critical (100002000)

Kommander kommander Yes cpu: 1100m

memory: 896Mi

Not applicable NKP Critical (100002000)

Kommander AppManagement

kommander- appmanagement

Yes cpu: 300m

memory: 256Mi

Not applicable NKP Critical (100002000)

Kommander Flux

kommander-flux Yes cpu: 7500m

memory: 5Gi

Not applicable NKP Critical (100002000)

Kommander UI kommander-ui Yes cpu: 100m

memory: 256Mi

Not applicable NKP Critical (100002000)

Kubefed kubefed Yes cpu: 300m

memory: 192Mi

Not applicable NKP Critical (100002000)

Kubetunnel kubetunnel Yes cpu: 200m

memory: 148Mi

Not applicable NKP Critical (100002000)

Thanos\* thanos Yes Not applicable Not applicable NKP Critical (100002000)

Traefik ForwardAuth

traefik-forward- auth-mgmt

Yes cpu: 100m

memory: 128Mi

Not applicable NKP Critical (100002000)

Applications with an asterisk ("\*") are only for NKP Ultimate users. If you
have an Ultimate license, NKP deploys these applications automatically.

For more information on application versions, see NKP Release Notes on the
Nutanix Support Portal.

### Workspace Platform Application Defaults and Resource Requirements

Note the resource requirements for the workspace platform applications
available within Nutanix Kubernetes Platform (NKP).

This section lists the workspace platform applications that are available
within NKP. Some of these applications are deployed by default upon
attachment. You need to manually install other applications through the CLI
under cluster operations. For more information, see Platform Applications.

Workspace platform applications require more resources than solely deploying
or attaching clusters to a workspace. Therefore, your cluster must have
sufficient resources available during deployment or attachment to ensure the
successful installation of platform services.

The following table describes all the workspace platform applications
available to the clusters within a workspace. It includes minimum resource
requirements, deployment information, and their default PriorityClasses.

Table 69: Available Workspace Platform Applications

Cert Manager cert-manager Yes cpu: 10m

memory: 32Mi

Not applicable system- cluster-critical (2000000000)

External DNS external-dns No Not applicable NKP High (100001000)

Fluent Bit fluent-bit No cpu: 350m \* # of nodes

```yaml
memory: 250Mi * #
of nodes
```

Not applicable NKP Critical (100002000)

Gatekeeper gatekeeper Yes cpu: 300m

memory: 768Mi

Not applicable system- cluster-critical (2000000000)

Grafana grafana- logging

No cpu: 200m

memory: 100Mi

Not applicable NKP Critical (100002000)

Loki grafana-loki No Not applicable # of PVs: 8

PV sizes: 10Gi x 8 (total: 80Gi)

NKP Critical (100002000)

Istio-Helm istio-helm No cpu: 1270m

memory: 4500Mi

Not applicable NKP Critical (100002000)

Jaeger jaeger No Not applicable Not applicable NKP High (100001000)

Kiali kiali No cpu: 20m

memory: 128Mi

Not applicable NKP High (100001000)

Knative knative No cpu: 610m

memory: 400Mi

Not applicable NKP High (100001000)

Kube OIDC Proxy

kube-oidc- proxy

Yes Not applicable Not applicable NKP Critical (100002000)

Kube Prometheus Stack

kube- prometheus- stack

Yes cpu: 1300m

memory: 4300Mi

## of PVs: 1 (2)

PV sizes: 100Gi

NKP Critical (100002000)

- Common Name; Application ID; Deployed by Default; Minimum Resources;
  Minimum Persistent Storage; Default PriorityClass

| --- | --- | --- | --- | --- | --- |

OpenCost\* OpenCost Yes cpu: 10m

memory: 55Mi

## of PVs: 1 (3)

PV sizes: 10Gi

NKP High (100001000)

Kubernetes Dashboard

kubernetes- dashboard

Yes cpu: 250m

memory: 300Mi

Not applicable NKP High (100001000)

Logging Operator

logging- operator

No cpu: 350m \* # of nodes + 600m

```yaml
memory: 228Mi +
350Mi * # of nodes
```

## of PVs: 1 (4)

PV sizes: 10Gi

NKP Critical (100002000)

NVIDIA GPU Operator

nvidia-gpu- operator

No cpu: 100m

memory: 128Mi

Not applicable system- cluster-critical (2000000000)

Prometheus Adapter

prometheus- adapter

Yes cpu: 1000m

memory: 1000Mi

Not applicable NKP Critical (100002000)

Reloader reloader Yes cpu: 100m

memory: 128Mi

Not applicable NKP High (100001000)

Rook Ceph rook-ceph Yes cpu: 100m

memory: 128Mi

Not applicable system- cluster-critical (2000000000)

Rook Ceph Cluster

rook-ceph- cluster

Yes cpu 2500m

mem 8Gi

## of PVs: 4

PV sizes: 40Gi

NKP Critical (100002000)

system- cluster-critical (2000000000)

system-node-critical

Traefik traefik Yes cpu: 500m Not applicable NKP Critical (100002000)

Traefik ForwardAuth

traefik- forward-auth

Yes cpu: 100m

memory: 128Mi

Not applicable NKP Critical (100002000)

Velero velero No cpu: 1000m

memory: 1024Mi

Not applicable NKP Critical (100002000)

- Application with an asterisk ("\*") is only for NKP Ultimate users. If you
  have an Ultimate license, NKP deploys these applications automatically.
- Currently, NKP only supports a single deployment of cert-manager for each
  cluster. Therefore, you cannot install cert-manager on Konvoy managed
  clusters or clusters with pre-installed cert-manager.
- NKP supports only a single deployment of traefik per cluster.

- Common Name; Application ID; Deployed by Default; Minimum Resources;
  Minimum Persistent Storage; Default PriorityClass

| --- | --- | --- | --- | --- | --- |

- NKP automatically manages the deployment of traefik-forward-auth and kube-
  oidc-proxy when you attach clusters to the workspace.

The NKP user interface does not display these workspace platform applications.

- You need to enable the workspace platform applications in NKP and then
  deploy them to the attached clusters.

Ensure successful deployment and verification of the applications enabled
through the CLI. For more information, see Deployment of Catalog Applications
in Workspaces on page 395.

For more information on application versions, see NKP Release Notes on the
Nutanix Support Portal.

### Prism Central Requirements for Nutanix Kubernetes Platform Installation

Prism Central requirements include setting up the Prism Central credentials,
user roles, and Prism Central resources for the NKP management and workload
clusters.

Prism Central Credential Requirements

Before updating your Prism Central credentials on a deployed Nutanix
Kubernetes Platform (NKP) clusters, ensure that you meet the following
requirements:

- Ensure that you have a kubeconfig file for the management cluster.
- Ensure that you have a kubeconfig file for each workload clusters that
  requires a Prism Central credential update.
- Update the following secrets with a new password for Prism Central instance:

Secrets for Prism Central Credentials

global-nutanix-credentials capx-system Management Cluster

${MANAGEMENT_CLUSTER_NAME}- pc-credentials

${MANAGEMENT_CLUSTER_NAMESPACE} Management Cluster

${MANAGEMENT_CLUSTER_NAME}- pc-credentials-for-csi

${MANAGEMENT_CLUSTER_NAMESPACE} Management Cluster

${MANAGED_CLUSTER_NAME}- pc-credentials

${MANAGED_CLUSTER_NAMESPACE} Management Cluster

${MANAGED_CLUSTER_NAME}- pc-credentials-for-csi

${MANAGED_CLUSTER_NAMESPACE} Management Cluster

nutanix-ccm-credentials kube-system

- Management Cluster
- Managed Cluster

nutanix-csi-credentials ntnx-system

- Management Cluster
- Managed Cluster

#### Prism Central Credential and Role Management

Define the user roles in Prism Central to manage the Nutanix Kubernetes
Platform (NKP) management and workload clusters.

| Secret Name | Namespace | NKP Cluster |
| ----------- | --------- | ----------- |

When you provision management and workload clusters with NKP on Nutanix
infrastructure, you need an admin role that includes the minimum required
permissions for NKP to provide proper access to deploy clusters.

NKP management cluster uses Prism Central credentials for the following
components:

- Cluster management: For listing subnets and other infrastructure, and
  creating VMs in Prism Central for the CAPX infrastructure provider.
- Persistent storage management: For Nutanix Container Storage Interface (CSI)
  provider.
- Node metadata discovery: For Nutanix Cloud Controller Manager (CCM) provider.

NKP requires Prism Central credentials to authenticate the Prism Central APIs.
CAPX currently supports two mechanisms to assign the required credentials:

- Credentials injected into the CAPX manager deployment.
- Managed cluster-specific credentials.

For examples, see Credential Management.

##### Prism Central Roles and Permissions for Nutanix Kubernetes Platform

Note the Prism Central roles and permissions required for the Kubernetes
cluster lifecycle on Nutanix Kubernetes Platform (NKP).

Following are the list of Prism Central roles and permissions required for the
Kubernetes cluster lifecycle on NKP:

- AHV VM: You need the following permissions for the AHV VM role:
- Create New VM
- Delete Existing VM
- Power On VM
- View Existing VM
- Update Virtual Machine Custom Attributes
- Category: You need the following permissions for the Category role:
- Create Category
- Delete Category
- Delete Value Category
- View Category
- Cluster: You need the following permissions for the Cluster role:
- View Cluster
- View Cluster Pgpu Profiles
- View Cluster Vgpu Profiles
- Host: You need the View Host permission for the Host role.
- Image: You need the following permissions for the Image role:
- Create Image
- Delete Image
- View Image
- Domain Manager (Prism Central): You need the View Domain Manager permission
  for the Domain Manager (Prism Central) role.
- Project: You need the View Project permission for the Project role.
- Subnet: You need the View Subnet permission for the Subnet role.
- Volume Group: You need the Detach Volume Group From AHV VM permission for
  the Volume Group role.
- VPC: You need the View VPC permission for the VPC role.

For information about roles, see Displaying Role Permissions in the Security
Guide.

To view the minimum permissions required for Container Storage Interface (CSI)
volume driver, see Operations Required to Perform CSI Actions in the CSI
Volume Driver Guide.

> **Note: You must apply the required CSI permissions.**

###### Configuring the Role with an Authorization Policy

Use Prism Central to create an authorization policy to assign the system-
defined roles.

About this task

When you provision Kubernetes clusters with Nutanix Kubernetes Platform (NKP)
on a Nutanix infrastructure, a pre- defined role that includes the minimum
permissions to deploy clusters is also provisioned. For more information, see
Configuring an Authorization Policy in the Security Guide.

To configure the role with an authorization policy, follow these steps:

Procedure

1. Log in to Prism Central as an administrator.
2. From the Application Switcher Function, select Admin Center.
3. Click IAM and go to Authorization Policies.
4. Click Create New Authorization Policy. The Create New Authorization Policy
   window appears.
5. In the Choose Role section, enter a role name in the Select the role to add
   to this policy field and click Next. You can enter the name of any built-in
   or custom roles.
6. In the Define Scope section, select one of the following options:

» Full Access: Grants all added users access to all entity types across the
entire environment under the associated role.

» Configure Access: Restricts permissions to specific target infrastructure
boundaries.

```yaml
Note: If you select this option for either All or Specific instances of objects, you must configure the following
entity requirements as listed:
```

- Domain Manager: Set this field to All Domain Manager.
- Cluster: Set this field to All Cluster. This setting is required to ensure
  the added users can view and interact with the Prism Central instance.
- Category: Set this field to All Category.

1. Click Next.
2. In the Assign Users section, select one of the following options:

» From the dropdown list, select Local User to add a local user or group to
the policy.

» From the dropdown list, select the available directory to add a directory
user or group.

To search for a user or group, type the first few letters of the name in the
text field. 9. Click Save.

For more information on displaying role permissions for any built-in role, see
Viewing Role Permissions. in the Security Guide.

Prism Central saves the authorization policy and lists it in the Authorization
Policies page.

##### Preparing Prism Central Resources for the Nutanix Kubernetes Platform

Cluster

Prepare Prism Central resources to create Nutanix Kubernetes Platform (NKP)
management cluster.

Before you begin

- Locate the following information in Prism Central instance:
- Prism Central Endpoint with or without the port:

For more information, see Admin Center Overview in the Prism Central Admin
Center Guide.

- Name of the Prism Element cluster:

For more information, see Modifying Cluster Details in the Prism Element Web
Console Guide.

- Name of the subnet:
- An available control plane endpoint IP not assigned to any VM.
- Name of the operating system image:

For more information, see Creating the Operating System Package Bundle on page 734.

- Docker Hub credentials. If you do not have Docker Hub credentials, you
  cannot create a NKP management cluster when the Docker Hub rate limit is
  reached.

About this task

To prepare Prism Central resources for creating the NKP management cluster,
follow these steps:

Procedure

1. Log in to Prism Central.
2. From the Application Switcher Function, select the Infrastructure
   Application.
3. Update the subnet.

Use an IP address in the subnet classless inter-domain routing (CIDR) but
outside the IP address pool. For more information, see Updating a Subnet in
the Flow Virtual Networking Guide. 4. Create a storage container.

For more information, see Creating a Storage Container in the Prism Central
Infrastructure Guide.

Prism Central resources are ready to create an NKP management cluster in the
air-gapped or non-air-gapped Nutanix infrastructure.

#### Managing VMs from VLAN Basic Subnets to Network Controller-based VLAN

Subnets

About this task

- If the node subnet in your Nutanix Kubernetes Platform (NKP) configuration
  overlaps with Kubernetes-reserved subnets, such as the pod or service
  subnet, the cluster might fail to deploy. You cannot change the subnets
  after creating a cluster. Ensure that the node subnet does not overlap with
  your host subnet.
- The default subnets used in NKP are as follows:

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

The current setup uses a basic VLAN configuration, while advanced VLAN uses
network-controller as the control plane instead of Acropolis.

To migrate a subnet from VLAN basic subnets to network controller-based VLAN
subnets, follow these steps:

Procedure

1. Log in to Prism Central.
2. From the Application Switcher Function, select the Infrastructure
   Application.
3. Click the Settings icon or from the navigation bar, navigate to Prism
   Central Setting.

For information about the navigation bar, see Application-specific Navigation
Bar.

The Settings page appears. 4. Click Network Controller, and select the
Configure Network Controller-Managed VLANs checkbox to set it as the default
setting. 5. Migrate VMs from VLAN basic subnets.

For more information, see Flow Virtual Networking Network Controller 5.0 -
Migrating VMs from VLAN Basic Subnets. 6. To use the new subnet, modify the
subnet specification in the control plane and worker nodes .

```bash
kubectl edit cluster <clustername>
```

The cluster API provider for Nutanix cloud infrastructure (CAPX) rolls out the
new control plane and worker nodes in the new subnet and destroys the old
ones.

You can choose basic or network controller-based VLAN subnets when you create
a subnet during cluster creation. If you create the cluster with basic VLAN
subnets, you can migrate it to network controller-based VLAN subnets.

For more information on modifying the service subnet, adding or modifying the
configmap, see Managing Subnets and Pods.

#### Creating the Operating System Package Bundle

About this task

You can complete perform this procedure using a machine with access to the
internet, or access to the operating system package repositories to download
the operating system packages.

To create an operating system package bundle, follow these steps:

Procedure

1. Open a terminal with access to the NKP CLI.
2. Create an operating system package bundle.

Use a sub-directory of the extracted air-gapped bundle to store the operating
system package bundle:

For Ubuntu 22.04:

```bash
export OS=ubuntu-22.04
nkp create package-bundle --artifacts-directory ${OS_BUNDLE_DIR} ${OS}
```

For Rocky 9.6:

```bash
export OS=rocky-9.6
nkp create package-bundle --artifacts-directory ${OS_BUNDLE_DIR} ${OS}
```

For RHEL 8.10:

```bash
export OS_BUNDLE_DIR=nib/artifacts
export OS=rhel-8.10
export RHSM_ORG_ID=<your-RHSM-id>
export RHSM_ACTIVATION_KEY=<your-RHSM-Activation-key>
nkp create package-bundle --artifacts-directory ${OS_BUNDLE_DIR} ${OS}
```

### Creating a Nutanix VM Image

| export OS BUNDLE DIR=nkp- \_ \_ | nkp version \_ | /nib/artifacts |
| ------------------------------- | -------------- | -------------- |

About this task

To create a Nutanix image, follow these steps:

Procedure

1. Open a terminal with access to the NKP CLI.
2. (Only for an air-gapped environment, and optional for non-air-gapped
   environments) Load the NKP image builder container image into the local
   container runtime store:

The NKP CLI image builder uses a container image. In an air-gapped
environment, you cannot automatically download the image from the public
registry. The image is included in the air-gapped bundle, and you must load
the image into the container runtime. 3. Create a Nutanix VM image:

```bash
nkp create image nutanix
```

To create a specialized VM image, the NKP CLI creates a VM from the base VM
image.

```bash
export NUTANIX_ENDPOINT=Prism Central Endpoint URL
export NUTANIX_CLUSTER=Prism Central Cluster Name
export NUTANIX_USER=Prism Central Username
export NUTANIX_PASSWORD=Prism Central Password
export SUBNET=VLAN Subnet
export BASE_VM_IMAGE=VM image name
export OS=OS name
```

The NKP CLI also makes changes, such as installing dependencies and
configuring services, and finally creates a new VM image with these changes.
The following attributes apply in the previous command:

- NUTANIX_ENDPOINT - Prism Central endpoint URL, including the scheme, host,
  and port.
- NUTANIX_CLUSTER - Prism Central cluster.
- NUTANIX_USER - Prism Central username.
- NUTANIX_PASSWORD - Prism Central password.
- SUBNET - Prism Central subnet to create a temporary VM.
- BASE_VM_IMAGE - Use a VM image uploaded to Prism Central as the base.
- OS - OS name with version. For possible values, run nkp create image nutanix
  --help.

1. Create the Nutanix VM image with the environment variables exported in the
   environment.

If you have created a package bundle, use it here:

If you use internal registry when creating an NKP cluster:

```bash
export BUNDLE_FLAG="--bundle nkp-${nkp-version}/container-images/konvoy-image-bundle-
${nkp-version}.tar
```

This bundle contains all the necessary container images required to bootstrap
an NKP cluster.

Replace nkp_version with the NKP version at your site.

```bash
nkp create image nutanix $OS \
--endpoint ${NUTANIX_ENDPOINT} \
--cluster ${NUTANIX_CLUSTER} \
--subnet ${SUBNET} \
```

- docker load --input "nkp-; nkp-version; /nkp-image-builder-; nkp-version;
  .tar"

| --- | --- | --- | --- | --- |

- export ARTIFACTS DIRECTORY FLAG="--artifacts-directory=nkp- \_ \_; nkp
  version \_; /nib/artifacts"

| --- | --- | --- |

```bash
--source-image ${BASE_IMAGE} \
"${ARTIFACTS_DIRECTORY_FLAG:-""}" \
--${BUNDLE_FLAG:-""}
```

1. Note the name of the created VM image.

Use this VM image name when you create the cluster. 6. Verify the image
placement policies of the VM image.

The VM image is covered by one or more image placement policies. Ensure that
these policies allow the VM image to be copied to all Prism Central clusters
that you plan to use with NKP.

The image placement policies are listed in the VM image details view in Prism
Central. For more information, see Image Placement Policies in the Prism
Central Infrastructure Guide.

What to do next

- You can Prepare a Local Registry Mirror and then Push Images to the Registry
  (Required for an air-gapped environment and optional for a non-air-gapped
  environment).
- You can proceed to Deploy NKP Using UI from Nutanix Marketplace, or Create
  the NKP Management Cluster through CLI.

### Preparing a Local Registry Mirror

Before you begin

If your site does not have a local registry set up, ensure that you configure
one before proceeding. For more information, see the Local Registry Tools.

About this task

```yaml
Important: This procedure is required for an air-gapped environment that does not use an internal registry mirror. It
is optional for a non-air-gapped environment, however it can increase stability and security. You can also use a registry
mirror with a self-signed registry CA certificate in the non-air-gapped environment.
```

In a non-air-gapped environment, Nutanix Kubernetes Platform (NKP) downloads
artifacts from sources on the internet. For example, NKP downloads container
images from container registries. In an air-gapped environment, NKP downloads
these artifacts from sources within the environment. For example, NKP
downloads container images from a registry reachable on the local network. The
registry must be reachable from the bastion, where the NKP CLI runs, and from
every machine in the Kubernetes cluster.

To prepare a local registry, follow these steps:

Procedure

1. Open the terminal with access to the NKP CLI.
2. Provide the registry mirror URL.

The registry address includes the scheme, the host, port, and optional path: 3. (Optional) Provide the registry mirror username and password. If the
registry mirror requires a username and password, provide the username and
password:

```bash
export REGISTRY_MIRROR_USERNAME=<username>
```

- export REGISTRY MIRROR URL="https://; registry-mirror-host; :; registry-
  mirror-port; "

| --- | --- | --- | --- | --- |

```bash
export REGISTRY_MIRROR_PASSWORD=<password>
```

1. Access the registry without a trusted CA certificate:

a. Export the environment variables:

```bash
export REGISTRY_MIRROR_CA=Path to store the downloaded CA certificate
export REGISTRY_MIRROR_ADDRESS=Registry address
export REGISTRY_MIRROR_PORT=Registry port
```

Replace:

- Path to store the downloaded CA certificate with the path to store the
  downloaded CA certificate.
- Registry address with the host of the registry URL.
- Registry port with the port of the registry URL.

b. Download the CA certificate:

```bash
openssl s_client \
-showcerts \
-connect $REGISTRY_MIRROR_ADDRESS:$REGISTRY_MIRROR_PORT \
</dev/null | \
openssl x509 \
-outform PEM \
> $REGISTRY_MIRROR_CA
```

If your registry CA certificate is self-signed, it might be a untrusted
certificate.

### Pushing Images to the Registry

Before you begin

```yaml
Important: This procedure is required for an air-gapped environment that does not use an internal registry mirror. It
is optional for a non-air-gapped environment, however it can increase stability and security. You can also use a registry
mirror with a self-signed registry CA certificate in the non-air-gapped environment.
```

Ensure that the registry is prepared and the environment variables are
exported before you push images to the registry. For more information, see
Preparing a Local Registry Mirror on page 736.

If you do not already have a local registry set up and want to use an external
solution, see Local Registry Tools.

About this task

To push images to the registry, follow these steps:

Procedure

1. Open a terminal with access to the NKP CLI.
2. Push all bundles to the registry:

```bash
nkp push bundle \
--bundle "nkp-nkp-version/container-images/konvoy-image-bundle-nkp-version.tar" \
--bundle "nkp-nkp-version/container-images/kommander-image-bundle-nkp-version.tar" \
--bundle "nkp-nkp-version/container-images/nutanix-product-catalog-nkp-version-
airgapped.tar" \
--to-registry=${REGISTRY_MIRROR_URL} \
--to-registry-username=${REGISTRY_MIRROR_USERNAME} \
--to-registry-password=${REGISTRY_MIRROR_PASSWORD} \
--to-registry-ca-cert-file=${REGISTRY_MIRROR_CA:-""}
```

Replace nkp_version with the NKP version at your site. Specify only the
required bundle as comma-separated values in the --bundle parameter.

```yaml
Note: The nutanix-product-catalog-nkp-version-airgapped.tar included in the NKP air-
gapped bundle contains images exclusively for Nutanix Data Services for Kubernetes (NDK). You must specify the
Nutanix product catalog bundle only if you plan to deploy NDK.
```

What to do next

You can Deploy NKP using UI from Nutanix Marketplace, or Create the NKP
Management Cluster using CLI.

### Deploying Nutanix Kubernetes Platform using UI from Nutanix Marketplace

Before you begin

- Ensure that you have enabled Nutanix Marketplace.
- Verify the NKP image, and Kubernetes version in the overview section. For
  more information, see Nutanix Image Builder on page 51 and Supported
  Infrastructure Operating Systems on page 12.
- You must have the required Prism Central Roles and Permissions for Nutanix
  Kubernetes Platform on page 730 to create a cluster.
- Ensure Valid Node OS images conforming to the Kubernetes version are
  available. For details on how to make these images available, see Using an
  Image provided by Nutanix and Importing Images to Prism Central. Do not
  rename the image downloaded from the Nutanix Portal.
- In connected environments, please ensure reachability to the nutanix-portal
  (download.nutanix.com). This will ensure the Bastion VM image can be
  downloaded during deployment.
- Ensure 1 IP for Kubernetes API VIP.
- Ensure IPs for Kubernetes service load balancer.
- Ensure selected VLAN has a pool of free IPs (required for DHCP allocation).
- Selected subnet should have IPAM/DHCP enabled.
- NKP starter licenses support deployment of Rocky Linux images only. For any
  other image, including Ubuntu, you must have a NKP Pro or NKP Ultimate
  License.

> **Note:**

- NKP deployment on Nutanix marketplace is not supported on X-Small Prism
  Central.
- NKP cluster deployment is not supported on a dual stack enabled Prism Central.

Procedure

1. Log in to Prism Central as an administrator.
2. Select Admin Center in the Application Switcher.
3. Click Marketplace in the navigation bar.
4. In the Nutanix Apps section, click Get for the Nutanix Kubernetes Platform
   app. The app details page opens.
5. Click Deploy. The deployment page is displayed
6. In the Name & Access tab, fill in the details:

a. Enter the cluster name.

This is the name assigned to the NKP cluster during deployment.

b. Enter the SSH username and SSH Public Key

The SSH username and public key is applied to the bastion VM, as well as the
control-plane and worker nodes. If the deployment fails, you can use these
credentials to SSH into the bastion VM and extract the support bundle. 7. In
the Provider tab, enter the details:

a. Enter the Prism Central username and password of the user creating and
managing the NKP cluster.

b. Select the Prism Element name from the dropdown list. This list is based on
the Prism Central credentials entered. 8. In the Resources tab, enter the
details:

a. Select the OS image.

b. Enter the values for the control plane nodes and worker nodes.

The recommended values are pre-filled. 9. In the Storage tab, enter the details:

a. Select the Nutanix storage container.

b. Select the Reclaim policy.

c. Select the Hypervisor attached volume. 10. In the Network & Proxy tab,
enter the details:

a. Select the subnets that are configured with either Nutanix IPAM or DHCP.
They should also be connected to the control plane and worker node pools.

b. Enter details of the Control Plane Endpoint IP and Port. The IP details
entered here must be unused, and must be outside the scope of Nutanix IPAM and
DHCP.

c. Enter details of the K8s load balancer Service IP Range.

d. Enter details of the Kubernetes Pod Network and Service CIDR. Ensure the
subnets do not overlap with your host subnet as it cannot be changed after
creation of the cluster. If you select a non-default CIDR, you must update the
new CIDR value in the no-proxy list.

e. Enter details of the Internet proxy for HTTP, HTTPS or if there is no
proxy. See Configuring an HTTP or HTTPS Proxy on page 696 for more details on
the flags and format to be used. 11. (Optional) In the Registry tab, enter the
details:

- Image Registry Mirror:
- If provided, the cluster uses this external registry mirror to pull and
  cache required container images.
- If you do not provide a mirror, the system automatically deploys an
  in#cluster private registry that acts as a pull#through cache for the
  required images.
- Private Registry:
- If you provide a private registry, the system configures it to the cluster
  to pull specific application images.
- If you do not provide a private registry, the system skips this configuration.

```yaml
Note: As both the Image Registry Mirror and Private Registry fields are optional. If you do not provide
details for either field, the system deploys an internal registry mirror to complete the cluster deployment.
```

1. Click Next. After deployment, the NKP App appears on the My Apps page. You
   can select the NKP Cluster in the application switcher to open and manage
   the app.

During deployment of the NKP instance, a bastion host VM tile is temporarily
visible. This is cleared on successful deployment. In case of a failure, you
can delete the failed NKP application instance which also cleans the bastion
VM for this instance.

What to do next

- The dashboard can be launched from the NKP application page after deployment.
- You can download the kubeconfig to connect with or manage the cluster, or to
  create worker clusters. See Cluster Operations Management on page 284 for
  more details.
- For license update or activation, you must use the Cluster UUID, and not the
  Application UUID details.
- Upgrade: To upgrade NKP, see Upgrade NKP.

> **Note: NKP upgrade through Nutanix marketplace is not supported.**

- Refresh: When you upgrade the cluster manually, you can select the Refresh
  option to view the latest cluster and Kubernetes details as well as the
  upgraded version details in the widget.
- Delete a cluster: If you have to delete a cluster, to avoid a failure you
  must ensure this cluster is not managing another cluster or workload. In the
  App widget, select the delete option to delete the selected cluster.

If there is an error during the delete operation, you can initiate the soft-
delete option which ignores the failures and clears the application tiles from
Nutanix Marketplace

### Creating the Nutanix Kubernetes Platform Management Cluster using CLI

About this task

To create the NKP management cluster, follow these steps:

```yaml
Note: To create a NKP management cluster when the bootstrap cluster is running on the host, you need a minimum of
2 CPUs and 4GB memory available for successful creation of the management cluster.
```

Procedure

1. Open the terminal with access to the NKP CLI.
2. (Required for air-gapped environment and optional for non-air-gapped
   environment) Load the NKP bootstrap cluster container image into the local
   container runtime store:

```bash
docker load --input "nkp-nkp-version/konvoy-bootstrap-image-nkp-version.tar"
```

The NKP CLI uses a container image to create the bootstrap cluster. In an air-
gapped environment, you cannot automatically download the image from the
public registry. The image is included in the air-gapped bundle, and you must
load the image into the container runtime. 3. Assign a name to your cluster
and store it in an environment variable:

Replace Name of the NKP Cluster with the name of the NKP management cluster.

```yaml
Note: NKP also uses the cluster name for some Kubernetes resources. Ensure that you only use lowercase
alphabets a-z, numbers 0-9, ., and - in the cluster name. For more information, see Kubernetes.
```

1. Provide the Prism Central endpoint. The NKP CLI uses the Prism Central API
   to create the NKP cluster, and this API is hosted at the Prism Central
   endpoint.

The endpoint must be in one of three formats:

- host
- host:port
- A valid URL. For example, https:// host:port

For example:

Replace URL of Prism Central Endpoint with the URL of Prism Central endpoint. 5. Provide the Prism Central credentials:

```bash
export NUTANIX_USER=Prism Central Username
export NUTANIX_PASSWORD=Prism Central Password
```

Replace:

- Prism Central Username with the Prism Central username.
- Prism Central Password with the Prism Central password.

The NKP CLI needs a username and password to access Prism Central.

| export CLUSTER NAME= | Name of the NKP Cluster |
| -------------------- | ----------------------- |

| export NUTANIX ENDPOINT= \_ | URL of Prism Central Endpoint | Col3 |
| --------------------------- | ----------------------------- | ---- |

1. (Optional) Access an HTTPS Prism Central endpoint hosted on a self-signed
   certificate:

» If the Prism Central endpoint uses a self-signed CA certificate, the CA
certificate is untrusted. When creating an NKP cluster, use --additional-
trust-bundle to pass only the Prism Central self#signed certificate file. The
input must be a Base64-encoded.

Run the following command to encode the plain text SSL certificate file into a
Base64-encoded file:

```yaml
Note: Do not include the full CA bundle, as large files can exceed the 16 KB cloud#init user data limit
and cause node VM creation errors.
```

For more information, see SSL Certificate Management in Prism Central.

» If you cannot provide a trusted CA certificate that can be verified, allow
insecure HTTPS access to the Prism Central endpoint:

```bash
export INSECURE=true
```

This method is not recommended for a production environment, as it skips
certificate validation and runs in an insecure mode. 7. Choose the name of a
Prism Element cluster:

Replace Name of the Prism Central Cluster with the name of the Prism Element
cluster.

The system creates the NKP control plane and worker nodes virtual machines in
the Prism Element cluster.

In this step, a single Prism Element cluster is used for both the control
plane and worker nodes. However, you can modify the NKP CLI command to use
separate Prism Element clusters for the control plane and worker nodes. 8.
Choose the name of a Nutanix storage container to use for Kubernetes
persistent volumes:

Replace Name of Storage Container with the name of the Nutanix storage
container.

By default, Kubernetes persistent volumes are provisioned using Nutanix
volumes in a Nutanix storage container. The storage container configuration
controls features such as replication, compression, and deduplication. You can
dedicate a storage container to your cluster, or share the storage container.

```yaml
Important: The storage container must be in the Prism Element cluster that you selected in step 4 on
page 741.
```

1. Choose an IP address for the control plane endpoint:

Replace Dedicated static IP with a static IP address for the control plane
endpoint. The NKP cluster control plane consists of multiple nodes, each
capable of responding to Kubernetes API requests. However, only one node
serves the requests at a time. The control plane endpoint uses a virtual IP

| cat | `<plain text SSL cert file name>` |     | base64 |
| --- | --------------------------------- | --- | ------ |

| export NUTANIX CLUSTER= \_ | Name of Prism Central Cluster | Col3 |
| -------------------------- | ----------------------------- | ---- |

| export STORAGE CONTAINER NAME= \_ \_ | Name of Storage Container | Col3 |
| ------------------------------------ | ------------------------- | ---- |

| export CONTROLPLANE IP= \_ | Dedicated static IP | Col3 |
| -------------------------- | ------------------- | ---- |

(VIP) address, which is assigned to an active node. This VIP ensures that API
requests are always directed to the current active control plane node.

> **Important: Ensure that the IP address for the control plane endpoint
> adheres to the following guidelines:**

- Routable from the control plane and worker subnets
- A static IP that is not part of a dynamic host configuration protocol (DHCP)
  or IP address management (IPAM) pool
- Not used for any other purpose

1. (Optional) Configure an external endpoint to access the control plane:

```bash
export CONTROLPLANE_EXTERNAL_ENDPOINT_FLAG="
--control-plane-external-endpoint=<IP or DNS name>"
```

The external endpoint can be used to access the cluster from outside the
control plane and worker subnets. The endpoint can be an IP or a fully-
qualified domain name.

> **Note:**

- Inside the VPC: To access a cluster in a Virtual Private Cloud (VPC), you
  can use a floating IP as the external endpoint. Use Prism Central to request
  a new floating IP, or choose a floating IP that is not associated. Finally,
  associate the floating IP with the static IP you chose in the previous step.
- To access the cluster in the VPC, use the Bastion VM or any other VM in the
  same VPC.
- Outside the VPC: To access a cluster from outside the VPC, link the floating
  IP to an internal IP used as CONTROL_PLANE_ENDPOINT_IP while deploying the
  cluster. For information on Floating IP, see the topic Request Floating IPs
  in Flow Virtual Networking.
- Access the cluster in the VPC from outside using updated kubeconfig after
  creating the cluster.
- To access the UI outside the VPC, you need to request three floating IPs.
- One IP for the bastion
- One IP for passing the --extra-sans flag during cluster creation
- One IP for the UI

1. Choose an IP address range for Kubernetes load balancer services:

Replace IP range in first IP-last IP format with the IP range in first IP-last
IP format. For example, 100.0.0.30-100.0.0.56.

The NKP cluster assigns an external IP address from a predefined range to
expose a Kubernetes service. The NKP UI uses the first IP address in this
range.

```yaml
Important: Ensure that the IP addresses for the Kubernetes load balancer services adhere to the following
guidelines:
```

- Routable from the control plane and worker subnets
- A static IP that is not part of a dynamic host configuration protocol (DHCP)
  or IP address management (IPAM) pool
- Not used for any other purpose

- export SERVICE LB IP RANGE=" \_ \_ \_; IP range in first IP-last IP format;
  "

| --- | --- | --- |

1. Choose a subnet for control plane and worker nodes:

Replace Subnet name with the name of the subnet for control plane and worker
nodes.

Every control plane and worker node is assigned an IP address from this subnet.

> **Important: Ensure that the subnet is in the Prism Element cluster that
> you selected in Step 4 on page 741.**

In this step, one subnet is used for both the control plane and the worker
nodes. However, you can modify the NKP CLI command to use separate subnets for
the control plane and the worker nodes. 13. Choose a Nutanix VM image:

Replace VM Image name with the name of the Nutanix VM image.

If you did not create a Nutanix VM image, you can use a prebuilt VM image. For
more information, see Creating a Nutanix VM Image on page 734.

In this step, one Nutanix VM image is used for both the control plane and the
worker nodes. However, you can modify the NKP CLI command to use separate
Nutanix VM images for the control plane and the worker nodes.

```yaml
Note: If the VM image was built with FIPS enabled, you also need to enable FIPS in the cluster, as described in
the next step.
```

1. (Optional) Enable FIPS in the cluster:

```bash
export FIPS_FLAG="--fips"
```

This flag enables FIPS in the cluster.

> **Note: To enable FIPS in the cluster, the VM image used in the previous
> step must be built with FIPS enabled.** 15. (Required for air-gapped
> environment and optional for non-air-gapped environment) Use one of the
> following registry methods to manage the container images:

a. Internal Registry Mirror: If you want NKP to manage the required container
images using its internal registry with a bundled image set.

```bash
export BUNDLE_FLAGS=" --bundle ./nkp-${nkp-version}/container-images/kommander-
image-bundle-${nkp-version}.tar,./nkp-${nkp-version}/container-images/konvoy-
image-bundle-${nkp-version}.tar,./nkp-${nkp-version}/container-images/nutanix-
product-catalog-${nkp-version}-airgapped.tar"
```

Replace nkp-version with the NKP version at your site.

NKP provides a bundle that contains all the necessary container images
required to bootstrap an NKP cluster. Specify only the required bundle as
comma-separated values in the --bundle parameter.

```yaml
Note: The nutanix-product-catalog-nkp-version-airgapped.tar included in the NKP
air-gapped bundle contains images exclusively for Nutanix Data Services for Kubernetes (NDK). You must
specify the Nutanix product catalog bundle only if you plan to deploy NDK.
```

b. Local Registry Mirror: If you want to configure a local or user-provided
registry mirror manually.

```bash
export REGISTRY_MIRROR_FLAGS="
--registry-mirror-url=$REGISTRY_MIRROR_URL \
--registry-mirror-username=$REGISTRY_MIRROR_USERNAME \
--registry-mirror-password=$REGISTRY_MIRROR_PASSWORD \
--registry-mirror-cacert=$REGISTRY_MIRROR_CA \
```

| export SUBNET= | Subnet name | Col3 |
| -------------- | ----------- | ---- |

| export VM IMAGE= \_ | VM Image name | Col3 |
| ------------------- | ------------- | ---- |

```bash
"
```

By default, an NKP cluster pulls container images from public registries. If
these registries are not available, or you do not use them, NKP can pull the
images from a registry mirror. To use a registry mirror, follow the steps in
Preparing a Local Registry Mirror on page 736, and export the following
environment variables.

For more information about the registry types, see Air-Gapped or Non-Air-
Gapped Environment on page 22. 16. (Required for air-gapped environment and
optional for non-air-gapped environment) Enable the air-gapped mode:

```bash
export AIRGAPPED=true
```

The air-gapped mode runs the NKP UI, and other NKP applications in an air-
gapped environment. 17. (Optional) Use registry credentials:

```bash
export REGISTRY_FLAGS="
--registry-url=<Registry URL> \
--registry-username=<Registry username> \
--registry-password=<Registry password> \
--registry-cacert=<Path to registry CA certificate file> \
"
```

By default, an NKP cluster pulls container images from public registries.
However, some registries, such as Docker Hub, limit the number of image pulls
unless you provide the credentials.

```yaml
Tip: If you do not use a local registry mirror or an internal registry, Nutanix recommends that you provide
credentials for Docker Hub.
```

1. (Optional) Choose networks for the Kubernetes pods and services:

```bash
export KUBERNETES_PODS_NETWORK=IP range in CIDR format
export KUBERNETES_SERVICES_NETWORK=IP range in CIDR format
```

Replace IP range in CIDR format with the IP range in CIDR format. For example,
192.168.0.0/16.

Every NKP cluster has two networks; one for Kubernetes pods, and another for
Kubernetes services. These networks are internal to the cluster. Every
Kubernetes pod is assigned an IP address from the Kubernetes pods network, and
every Kubernetes service is assigned an IP address from the Kubernetes
services network. The network size is based on the number of pods and services
in a cluster.

> **Important:**

- The Kubernetes pods network and Kubernetes services network must not overlap
  with each other, or with your control plane and worker nodes subnets.
- After cluster creation, you cannot change the pods and services subnets.

By default, the pods network is 192.168.0.0/16, and the services network is
10.96.0.0/12. These network sizes allow up to approximately 65 thousand pods,
and one million services. 19. (Optional) Enable SSH access to nodes:

| export SSH USERNAME= \_ | username | Col3 |
| ----------------------- | -------- | ---- |

Replace:

- username with the SSH user name
- path to SSH public key file with the location of SSH public key file

Provide a username and public SSH key to enable SSH access with these
credentials to all NKP cluster nodes. NKP creates the user on every cluster
node, and adds the public SSH key to the authorized SSH keys of the user. By
default, NKP cluster nodes allow SSH public key authentication.

Provide the public SSH key as a path to a file. 20. (Optional) To disable the
automatic onboarding of clusters:

```bash
export PC_ONBOARDING_FLAGS="
--onboard-to-prism-central=false \
"
```

This is an optional step to disable the automatic onboarding of clusters,
which is enabled by default.

```yaml
Note: If the konnector agent pod is stuck in Init state, you must enable karbon-core service in PC in version
7.3 and upgrade the karbon-core version to 2.10.2.
```

1. Configure Network Time Protocol (NTP) servers on Nutanix Kubernetes
   Platform (NKP) clusters.

Configure Network Time Protocol (NTP) on Nutanix Kubernetes Platform (NKP)
clusters to synchronize system time is mandatory across all the nodes in an
air-gapped environment.

Configure NTP servers on Nutanix Kubernetes Platform (NKP) clusters if you
cannot use the default public NTP servers that are set in the operating system
or prefer to use your own custom NTP server in non-air-gapped environments.

Use --ntp-servers flag to configure a comma separated list of NTP servers
across all the nodes. Each entry must be a Fully Qualified Domain Name (FQDN)
or an IP address (IPv4 or IPv6). This list overrides any default NTP settings
preconfigured in the machine image. For example, export NTP_FLAGS="--ntp-
servers=pool.ntp.org,time.google.com \ ". 22. Create a management cluster:

```bash
nkp create cluster nutanix \
--self-managed \
--airgapped=${AIRGAPPED:-false} \
\
--cluster-name=${CLUSTER_NAME} \
--endpoint=${NUTANIX_ENDPOINT} \
--insecure=${INSECURE:=false} \
--control-plane-endpoint-ip=${CONTROLPLANE_IP} \
--control-plane-external-endpoint=${CONTROLPLANE_EXTERNAL_ENDPOINT_FLAG} \
--csi-storage-container=${STORAGE_CONTAINER_NAME} \
--kubernetes-pod-network-cidr=${KUBERNETES_PODS_NETWORK:-"192.168.0.0/16"} \
--kubernetes-service-cidr=${KUBERNETES_SERVICES_NETWORK:-"10.96.0.0/12"} \
--kubernetes-service-load-balancer-ip-range=${SERVICE_LB_IP_RANGE} \
\
--control-plane-prism-element-cluster=${NUTANIX_CLUSTER} \
--control-plane-subnets=${SUBNET} \
--control-plane-vm-image=${VM_IMAGE} \
\
--worker-prism-element-cluster=${NUTANIX_CLUSTER} \
--worker-subnets=${SUBNET} \
--worker-vm-image=${VM_IMAGE} \
--ssh-username=${SSH_USERNAME} \
--ssh-public-key-file=${SSH_PUBLIC_KEY} \
```

| export SSH PUBLIC KEY= \_ \_ | path to SSH public key file | Col3 |
| ---------------------------- | --------------------------- | ---- |

```bash
\
${NTP_FLAGS} \
${BUNDLE_FLAGS} \
${REGISTRY_MIRROR_FLAGS} \
\
${REGISTRY_FLAGS}
\
${FIPS_FLAG}
Important: Do not use both BUNDLE_FLAG and REGISTRY_MIRROR_FLAG simultaneously. Use these flags
based on how you manage the container images.
```

To assign values to flags, the NKP CLI command creates a management cluster
with the configuration and environment variables that you exported.

If you require the use of an HTTP/S proxy in your environment, add the flags
--http-proxy, --https- proxy, and --no-proxy. For more information, see
Cluster Creation with HTTP or HTTPS Proxy on page 699.

#### Preflight Checks

For example, if the VM image name is missing from the worker and control plane
nodes, the following error is displayed in the output while creating cluster
resources:

You can skip a specific preflight check using a flag with the name of that
check. For example,

```bash
--skip-preflight-checks=NutanixVMImage
```

If you want to skip more than one preflight check, specify the flag for each
check individually. For example,

```bash
--skip-preflight-checks=NutanixVMImage --skip-preflight-
checks=NutanixStorageContainer
```

- Verifies that Prism Central is reachable and the credentials provided are
  valid.

The credentials are stored in their secret.

- Verifies that the VM image is present in Prism Central.
- Verifies that the Kubernetes cluster version is part of the VM image name.
  For example, Kubernetes version 1.35.x.
- If you configure Container Storage Interface (CSI), NKP verifies that the
  storage containers specified in the configuration exist in Prism Central.

The Nutanix CSI driver uses storage containers to provision persistent volumes
(PV).

- Validates your Pod and Service CIDR configurations. This check ensures that
  the Pod and Service CIDRs are large enough to prevent IP exhaustion and that
  they do not overlap each other, the Node subnets, or the control plane
  endpoint to prevent conflicts.

Preflight checks on the local registry:

- Verifies that the local registry is reachable and the credentials provided
  are valid.

The credentials are stored in their secret.

### Creating a Nutanix Cluster With Custom Cilium Configuration

About this task

```yaml
Warning: For this procedure, you must modify .yaml files directly. Therefore, this task is recommended only for
advanced users.
```

By default, Nutanix Kubernetes Platform (NKP) installs the Cilium add-on with
the default configuration while creating a cluster. However, you can override
the default configuration with a custom configuration for advanced use- cases.
For example, you can create a Nutanix cluster using NKP with transparent
encryption (Wireguard).

You can create a NKP cluster with a custom Cilium configuration in both air-
gapped and non-air-gapped environments.

Before you begin

- You must customize the configuration before you create a cluster. Only the
  custom configuration that you provide while creating the cluster is applied.
  If you update the cluster specification or the Cilium CNI configmap after
  you create a cluster, the updates are not applied to an installed Cilium
  add-on.
- This task must be performed only by advanced users as you are required to
  modify YAML files directly.

Procedure

1. Generate Cluster Objects.

You must set the target namespace with the name of the workspace you are
creating the cluster in, using the nkp create cluster nutanix ... --dry-run
--output=yaml > cluster.yaml command.

Depending upon your infrastructure, this command generates a set of cluster
objects that can be customized for advanced use-cases. 2. Create a file named
values.yaml with the following helm values. You must edit the values as
required:

```bash
cni:
exclusive: false
hubble:
enabled: true
tls:
auto:
enabled: true # enable automatic TLS certificate generation
method: cronJob # auto generate certificates using cronJob method
certValidityDuration: 60 # certificates validity duration in days (default 2
months)
schedule: "0 0 1 * *" # schedule on the 1st day regeneration of each
month
relay:
enabled: true
tls:
server:
enabled: true
mtls: true
image:
useDigest: false
priorityClassName: system-cluster-critical
ipam:
mode: kubernetes
image:
useDigest: false
operator:
image:
useDigest: false
certgen:
image:
useDigest: false
socketLB:
hostNamespaceOnly: true
envoy:
image:
useDigest: false
k8sServiceHost: "{{ trimPrefix .ControlPlaneEndpoint.Host "https://" }}"
k8sServicePort: "{{ .ControlPlaneEndpoint.Port }}"
kubeProxyReplacement: true
tunnelProtocol: geneve
loadBalancer:
mode: dsr
dsrDispatch: geneve
```

For example, add the following values to the values.yaml file to enable Cilium
with transparent encryption (Wireguard). As a result, Cilium encrypts network
traffic and sets the encryption method as WireGuard:

```bash
encryption:
enabled: true
type: wireguard
Note: The values.yaml file includes all the required Helm values needed to configure the Cilium add-on. NKP
uses these values from the file during cluster creation to install and configure Cilium.
Warning: You cannot modify the Cilium IPAM configuration, mode, Pod CIDR, or Service CIDR of a running
cluster. For more information, see IPAM Configuration Change Limitation on page 544.
```

1. Create an additional file named preflight-values.yaml with these values to
   ensure completion of the preflight checks during an upgrade of this cluster:

```yaml
agent: false
operator:
enabled: false
preflight:
enabled: true
envoy:
image:
useDigest: false
image:
useDigest: false
k8sServiceHost: "{{ trimPrefix .ControlPlaneEndpoint.Host "https://" }}"
k8sServicePort: "{{ .ControlPlaneEndpoint.Port }}"
```

1. Create a ConfigMap with the required Helm values, if you do not have a
   ConfigMap YAML file already:

```bash
kubectl create configmap <CLUSTER_NAME>-cilium-cni-helm-values-template
--from-file=values.yaml=values.yaml
--from-file=preflight-values.yaml=preflight-values.yaml -n <CLUSTER_NAMESPACE>
```

You can skip the previous step if you already have a ConfigMap YAML file
prepared. To apply it, edit it as required to add helm values. Ensure the
namespace in the ConfigMap YAML file is set to target the cluster's namespace
and apply it using this command:

```bash
kubectl apply <ConfigMap YAML Filepath>
```

1. Edit your cluster YAML file as follows:

You must first specify Cilium as the CNI provider.

Reference a ConfigMap that contains your custom Helm values. Ensure the
ConfigMap name is same as the one created in the previous step:

```yaml
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
name: <NAME>
namespace: <CLUSTER_NAMESPACE>
spec:
topology:
variables:
- name: clusterConfig
value:
addons:
cni:
provider: Cilium
strategy: HelmAddon
values:
sourceRef:
name: <CLUSTER_NAME>-cilium-cni-helm-values-template
kind: ConfigMap
```

1. Apply the edited cluster YAML files:

```bash
kubectl apply -f cluster.yaml
```

The cluster is created with the custom Cilium configuration.

```yaml
Note: If the self-managed flag was added in the dry-run, follow the steps to make the cluster a Self-
Managed Cluster on page 20
```

### Setting up the Nutanix Kubernetes Platform User Interface Access

About this task

To set up the NKP UI access, follow these steps:

Procedure

1. Open a terminal with access to the NKP CLI.
2. Access the NKP UI in Kommander and retrieve your credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

Use these static credentials only to configure an external identity provider.
For more information, see Identity Providers. Treat them as backup
credentials, not for regular UI access. 3. Rotate the dashboard password:

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

### Updating Prism Central Credentials on Deployed NKP Clusters

Before you begin

Before you update your Prism Central credentials on deployed Nutanix
Kubernetes Platform (NKP) clusters, ensure all requirements of Prism Central
Credentials are met . For more information, see Prism Central Credential
Requirements.

About this task

To update the Prism Central credentials using CLI, follow these steps:

> **Note: For an automated script to update Prism Central credentials on NKP
> clusters, see KB-18296.**

Procedure

1. Open the terminal with access to the NKP CLI.
2. Scale down the following associated pods:

a. Scale down the following deployments or controllers of the pods:

```bash
kubectl scale deployment capx-controller-manager -n capx-system --replicas=0
kubectl scale deployment cluster-api-runtime-extensions-nutanix -n caren-system
--replicas=0
kubectl scale deployment nutanix-cloud-controller-manager -n kube-system --
replicas=0
kubectl scale deployment nutanix-csi-controller -n ntnx-system --replicas=0
kubectl scale deployment nutanix-csi-controller -n ntnx-system --replicas=0 --
kubeconfig=$KUBECONFIG_WORKLOAD
kubectl scale deployment nutanix-cloud-controller-manager -n kube-system --
replicas=0 --kubeconfig=$KUBECONFIG_WORKLOAD
```

b. Scale down the Container Storage Interface (CSI) pods on the management
cluster:

```bash
kubectl -n ntnx-system patch daemonset nutanix-csi-node -p '{"spec":
{"template": {"spec": {"nodeSelector": {"non-existing": "true"}}}}}'
```

c. Scale down the CSI pods on each managed cluster:

```bash
kubectl -n ntnx-system patch daemonset nutanix-csi-node -p '{"spec":
{"template": {"spec": {"nodeSelector": {"non-existing": "true"}}}}}' --
kubeconfig=$KUBECONFIG_WORKLOAD
```

1. Update the global-nutanix-credentials:

a. Update the secret for the following global-nutanix-credentials:

```bash
kubectl get secrets global-nutanix-credentials -n capx-system -o yaml
apiVersion: v1
kind: Secret
metadata:
labels:
clusterctl.cluster.x-k8s.io/move: ""
dkp-infrastructure-provider-type: nutanix-secret
name: global-nutanix-credentials
namespace: capx-system
type: Opaque
data:
additionalTrustBundle: ""
insecure: base 64 encoded Insecure Mode
password: base 64 encoded PC Password
prismURL: base 64 encoded PC Endpoint
username: base 64 encoded PC Username
```

b. Store the password in base64 format and encode the new pass:

```bash
echo -n 'NEW_PASSWORD' | base64
TkVXX1BBU1NXT1JE
```

c. Update the global-nutanix-credentials with a new password:

```bash
kubectl edit secrets global-nutanix-credentials -n capx-system -o yaml
apiVersion: v1
kind: Secret
metadata:
labels:
clusterctl.cluster.x-k8s.io/move: ""
dkp-infrastructure-provider-type: nutanix-secret
name: global-nutanix-credentials
namespace: capx-system
type: Opaque
data:
additionalTrustBundle: ""
insecure: base 64 encoded Insecure Mode
password: base 64 encoded PC Password
prismURL: base 64 encoded PC Endpoint
username: base 64 encoded PC Username
```

1. Update the individual cluster credentials (secrets). Ensure that the
   secrets are in the formats cluster-name-pc-credentials and cluster-name-pc-
   credentials-for-csi.
2. Update the Prism Central credentials for the management cluster:

a. Get the secret:

```bash
kubectl get secrets ${MANAGEMENT_CLUSTER_NAME}-pc-credentials -o yaml
apiVersion: v1
kind: Secret
metadata:
finalizers:
- nutanixcluster/infrastructure.cluster.x-k8s.io
labels:
cluster.x-k8s.io/provider: nutanix
konvoy.d2iq.io/cluster-name: ${MANAGEMENT_CLUSTER_NAME}
konvoy.d2iq.io/provider: nutanix
name: ${MANAGEMENT_CLUSTER_NAME}-pc-credentials
namespace: default
ownerReferences:
- apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixCluster
name: ${MANAGEMENT_CLUSTER_NAME}-2smbz
uid: 8a9d1bba-02d5-4287-b3d8-284199d28a18
- apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
name: ${MANAGEMENT_CLUSTER_NAME}
uid: a74225d9-4367-4fc2-b424-53a0bd981020
type: Opaque
data:
credentials: base64 encoded PC credentials
```

Use the value of the credentials attribute in the secret:

```bash
echo base 64 String | base64 -d
[
{
"type": "basic_auth",
"data": {
"prismCentral": {
"username": "PC Username",
"password": "PC Password"
}
}
}
]
```

b. Decode the secret value and save it in a file:

c. Open the file using a text editor and modify the password:

```bash
cat update_new_password.txt
[
{
"type": "basic_auth",
"data": {
"prismCentral": {
"username": "PC Username",
"password": "PC Password"
}
```

| echo | base 64 String |     | base64 -d > update new password.txt \_ \_ |
| ---- | -------------- | --- | ----------------------------------------- |

```bash
}
}
]
```

d. Encode the updated secret value:

e. Edit the secret and update the secret with the new value:

```bash
kubectl edit secrets ${MANAGEMENT_CLUSTER_NAME}-pc-credentials -o yaml
```

f. Validate the changes:

```yaml
apiVersion: v1
data:
credentials: base64 encoded PC Credentials
kind: Secret
metadata:
creationTimestamp: "2024-09-30T16:16:07Z"
finalizers:
- nutanixcluster/infrastructure.cluster.x-k8s.io
labels:
cluster.x-k8s.io/provider: nutanix
konvoy.d2iq.io/cluster-name: ${MANAGEMENT_CLUSTER_NAME}
konvoy.d2iq.io/provider: nutanix
name: ${MANAGEMENT_CLUSTER_NAME}-pc-credentials
namespace: default
ownerReferences:
- apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixCluster
name: ${MANAGEMENT_CLUSTER_NAME}-2smbz
uid: 8a9d1bba-02d5-4287-b3d8-284199d28a18
- apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
name: ${MANAGEMENT_CLUSTER_NAME}
uid: a74225d9-4367-4fc2-b424-53a0bd981020
resourceVersion: "4982392"
uid: d382fa23-5e0e-46d7-a1c0-b5b3ee0bddd3
type: Opaque
```

1. Update the Prism Central credentials for the workload clusters:

a. Get the secret:

```bash
kubectl get secrets ${WORKLOAD_CLUSTER_NAME}-pc-credentials -n kommander-default-
workspace -o yaml
apiVersion: v1
data:
credentials: base64 encoded PC credentials
kind: Secret
metadata:
creationTimestamp: "2024-09-30T21:46:05Z"
finalizers:
- nutanixcluster/infrastructure.cluster.x-k8s.io
labels:
cluster.x-k8s.io/provider: nutanix
name: ${MANAGED_CLUSTER_NAME}-pc-credentials
namespace: kommander-default-workspace
ownerReferences:
- apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixCluster
name: ${MANAGED_CLUSTER_NAME}-7bqc2
```

| cat update new password.txt | base64 \_ \_ | base 64 String | Col3 |
| --------------------------- | ------------ | -------------- | ---- |

```yaml
uid: b4832f32-970b-4990-8d26-e5b134bca625
- apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
name: ${MANAGED_CLUSTER_NAME}
uid: 435ab407-b366-4bd7-b5e3-4b7c125244e8
resourceVersion: "5006043"
uid: d132a4aa-7906-4584-b178-effdfcf3c5ce
type: Opaque

echo base 64 String | base64 -d
[{"type":"basic_auth","data":{"prismCentral":{"username":"PC
Username","password":"PC Password"}}}]

```

Ensure that the secrets are in the format cluster-name-pc-credentials.

b. Decode the secret and save it in a file:

```bash
echo -n '[{"type":"basic_auth","data":{"prismCentral":{"username":"PC
Username","password":"PC Password"}}}]' | base64
base 64 String
```

c. Edit the secret and update the secret with the new value:

```bash
kubectl edit secrets ${WORKLOAD_CLUSTER_NAME}-pc-credentials -o yaml
```

d. Validate the changes:

```bash
kubectl edit secrets ${WORKLOAD_CLUSTER_NAME}-pc-credentials -n
apiVersion: v1
data:
credentials: base 64 encoded PC Password
kind: Secret
metadata:
creationTimestamp: "2024-09-30T21:46:05Z"
finalizers:
- nutanixcluster/infrastructure.cluster.x-k8s.io
labels:
cluster.x-k8s.io/provider: nutanix
name: ${WORKLOAD_CLUSTER_NAME}-pc-credentials
namespace: kommander-default-workspace
ownerReferences:
- apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixCluster
name: ${WORKLOAD_CLUSTER_NAME}-7bqc2
uid: b4832f32-970b-4990-8d26-e5b134bca625
- apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
name: ${WORKLOAD_CLUSTER_NAME}
uid: 435ab407-b366-4bd7-b5e3-4b7c125244e8
resourceVersion: "5006043"
uid: d132a4aa-7906-4584-b178-effdfcf3c5ce
type: Opaque
```

1. Update the CSI credentials for the management cluster:

a. Update the CSI credentials:

```bash
kubectl get secrets ${MANAGEMENT_CLUSTER_NAME}-pc-credentials-for-csi -o yaml
apiVersion: v1
data:
key: Key ID
kind: Secret
metadata:
creationTimestamp: "2024-09-30T16:16:06Z"
labels:
cluster.x-k8s.io/provider: nutanix
konvoy.d2iq.io/cluster-name: ${MANAGEMENT_CLUSTER_NAME}
konvoy.d2iq.io/provider: nutanix
name: ${MANAGEMENT_CLUSTER_NAME}-pc-credentials-for-csi
namespace: default
ownerReferences:
- apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
name: ${MANAGEMENT_CLUSTER_NAME}
uid: a74225d9-4367-4fc2-b424-53a0bd981020
resourceVersion: "5000354"
uid: e76fe412-d904-4b5f-b029-4800571898b4
type: Opaque
```

Ensure that you use the cluster-name-for-csi format for the management cluster
name.

b. Validate the base64 value:

```bash
echo base 64 String | base64 -d
PC IP:9440:PC Username:PC Password
```

c. Update the password and encode in base64:

d. Edit the secret and update the base64 value:

```bash
kubectl edit secrets ${MANAGEMENT_CLUSTER_NAME}-pc-credentials-for-csi -o yaml
```

e. Validate the updated secret:

```bash
kubectl get secrets ${MANAGEMENT_CLUSTER_NAME}-pc-credentials-for-csi -o yaml
apiVersion: v1
data:
key: NEW_BASE64ENCODED_PASSWORD
kind: Secret
metadata:
creationTimestamp: "2024-09-30T16:16:06Z"
labels:
cluster.x-k8s.io/provider: nutanix
konvoy.d2iq.io/cluster-name: ${MANAGEMENT_CLUSTER_NAME}
konvoy.d2iq.io/provider: nutanix
name: ${MANAGEMENT_CLUSTER_NAME}-pc-credentials-for-csi
namespace: default
ownerReferences:
- apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
name: ${MANAGEMENT_CLUSTER_NAME}
uid: a74225d9-4367-4fc2-b424-53a0bd981020
resourceVersion: "5000354"
uid: e76fe412-d904-4b5f-b029-4800571898b4
type: Opaque
```

1. Update the konnector-agent credentials for the management cluster:

a. Update the konnector-agent credentials:

```bash
kubectl get secret ${MANAGEMENT_CLUSTER_NAME}-pc-credentials-for-konnector-agent
-o yaml
```

- echo -n '; PC IP; :9440:admin:NEW PASSWORD'; base64; base 64 String; Col5

| --- | --- | --- | --- | --- | --- |

```yaml
apiVersion: v1
data:
password: base64encoded-password
username: base64encoded-username
kind: Secret
metadata:
creationTimestamp: "2025-12-18T04:46:58Z"
labels:
cluster.x-k8s.io/provider: nutanix
konvoy.d2iq.io/cluster-name: ${MANAGEMENT_CLUSTER_NAME}
konvoy.d2iq.io/provider: nutanix
name: ${MANAGEMENT_CLUSTER_NAME}-pc-credentials-for-konnector-agent
namespace: default
ownerReferences:
- apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
name: ${MANAGEMENT_CLUSTER_NAME}
uid: 3075d1d4-2357-4ffc-a88a-3563c87513d8
resourceVersion: "10962"
uid: 6bd05762-3007-4c39-a56a-707564f52b8d
type: Opaque
```

Ensure your management cluster uses this format for the cluster name:
${MANAGEMENT_CLUSTER_NAME}- pc-credentials-for-konnector-agent

b. Edit the secret with an updated base64 password:

```bash
kubectl edit secrets ${MANAGEMENT_CLUSTER_NAME}-pc-credentials-for-konnector-
agent -o yaml
```

c. Validate the updated secret:

```bash
kubectl get secret ${MANAGEMENT_CLUSTER_NAME}-pc-credentials-for-konnector-agent
-o yaml
apiVersion: v1
data:
password: UPDATED-BASE64-ENCODED-PASSWORD
username: base64encoded-username
kind: Secret
metadata:
creationTimestamp: "2025-12-18T04:46:58Z"
labels:
cluster.x-k8s.io/provider: nutanix
konvoy.d2iq.io/cluster-name: ${MANAGEMENT_CLUSTER_NAME}
konvoy.d2iq.io/provider: nutanix
name: ${MANAGEMENT_CLUSTER_NAME}-pc-credentials-for-konnector-agent
namespace: default
ownerReferences:
- apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
name: ${MANAGEMENT_CLUSTER_NAME}
uid: 3075d1d4-2357-4ffc-a88a-3563c87513d8
resourceVersion: "10962"
uid: 6bd05762-3007-4c39-a56a-707564f52b8d
type: Opaque
```

1. Update the Konnector-agent credentials for each workload cluster:

a. Get the workload cluster konnector-agent credentials:

```bash
kubectl get secret konnector-agent -n ntnx-system --kubeconfig <WORKLOAD-CLUSTER-
KUBECONFIG> -o yaml
apiVersion: v1
data:
password: base64encoded-password
username: base64encoded-username
kind: Secret
metadata:
creationTimestamp: "2025-12-18T04:33:19Z"
name: konnector-agent
namespace: ntnx-system
resourceVersion: "433"
uid: ff0d18db-7ff8-4df3-a641-1d5fc474d1aa
type: Opaque
```

b. Edit the secret and update the base64 value:

```bash
kubectl edit secret konnector-agent -n ntnx-system --kubeconfig <WORKLOAD-
CLUSTER-KUBECONFIG>
```

Though the -kubeconfig changes for each cluster, the steps remain the same. 10. Update the CSI credentials for each workload cluster in the management
cluster:

a. Update the CSI credentials:

```bash
kubectl get secret ${WORKLOAD_CLUSTER_NAME}-pc-credentials-for-csi -n kommander-
default-workspace -o yaml
apiVersion: v1
data:
key: Key ID
kind: Secret
metadata:
creationTimestamp: "2024-09-30T21:46:05Z"
labels:
cluster.x-k8s.io/provider: nutanix
name: ${WORKLOAD_CLUSTER_NAME}-pc-credentials-for-csi
namespace: kommander-default-workspace
ownerReferences:
- apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
name: ${WORKLOAD_CLUSTER_NAME}
uid: 435ab407-b366-4bd7-b5e3-4b7c125244e8
resourceVersion: "5008388"
uid: bdf259ec-fa26-48a7-9be9-7712d3614802
type: Opaque
```

Ensure that you use the cluster-name-for-csi format for workload cluster name.

b. Validate the base64 value:

c. Update the password and encode in base64:

d. Edit the secret and update the base64 value:

```bash
kubectl edit secret ${WORKLOAD_CLUSTER_NAME}-pc-credentials-for-csi -n
kommander-default-workspace -o yaml
kubectl get secret ${WORKLOAD_CLUSTER_NAME}-pc-credentials-for-csi -n kommander-
default-workspace -o yaml
apiVersion: v1
data:
key: base64 encoded New Password
kind: Secret
```

- echo; base 64 String; base64 -d; PC IP; :9440:; PC Username; :; PC
  Password; Col9

| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

- echo -n '; PC IP; :9440:admin:NEW PASSWORD'; base64; base 64 String; Col5

| --- | --- | --- | --- | --- | --- |

```bash
metadata:
creationTimestamp: "2024-09-30T21:46:05Z"
labels:
cluster.x-k8s.io/provider: nutanix
name: ${WORKLOAD_CLUSTER_NAME}-pc-credentials-for-csi
namespace: kommander-default-workspace
ownerReferences:
- apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
name: ${WORKLOAD_CLUSTER_NAME}
uid: 435ab407-b366-4bd7-b5e3-4b7c125244e8
resourceVersion: "5008388"
uid: bdf259ec-fa26-48a7-9be9-7712d3614802
type: Opaque
```

1. Update the cloud controller manager (CCM) and CSI credentials at the
   individual cluster level:

a. Update the CCM and CSI credentials:

```bash
kubectl get secrets nutanix-ccm-credentials -n kube-system --kubeconfig=
$KUBECONFIG_MANAGEMENT -o yaml
apiVersion: v1
data:
credentials: base64 encoded PC Credentials
kind: Secret
metadata:
creationTimestamp: "2024-09-30T16:12:20Z"
name: nutanix-ccm-credentials
namespace: kube-system
resourceVersion: "5017728"
uid: 3290249e-facb-45e3-a785-62ac620d5861
type: Opaque
```

For each cluster, --kubeconfig changes. However, the steps remain the same.

b. Validate the base64 value:

```bash
echo base 64 String | base64 -d
[
{
"type": "basic_auth",
"data": {
"prismCentral": {
"username": "PC Username",
"password": "PC Password"
}
}
}
]
echo base 64 String | base64 -d > update_ccm_password.txt
cat update_ccm_password.txt
[
{
"type": "basic_auth",
"data": {
"prismCentral": {
"username": "PC Username",
"password": "PC Password"
}
}
}
]
cat update_ccm_password.txt | base64 base 64 String

kubectl edit secrets nutanix-ccm-credentials -n kube-system --kubeconfig=
$KUBECONFIG_MANAGEMENT -o yaml

kubectl get secrets nutanix-ccm-credentials -n kube-system --kubeconfig=
$KUBECONFIG_MANAGEMENT -o yaml
apiVersion: v1
data:
credentials: base64 encoded New Password
kind: Secret
metadata:
creationTimestamp: "2024-09-30T16:12:20Z"
name: nutanix-ccm-credentials
namespace: kube-system
resourceVersion: "5017728"
uid: 3290249e-facb-45e3-a785-62ac620d5861
type: Opaque
```

c. Update the CSI password:

```bash
kubectl get secrets nutanix-csi-credentials -n ntnx-system -o yaml
apiVersion: v1
data:
key: Key ID
kind: Secret
metadata:
creationTimestamp: "2024-09-30T16:12:20Z"
name: nutanix-csi-credentials
namespace: ntnx-system
resourceVersion: "5023111"
uid: e78d3eef-3d86-4c26-966f-4672531b30aa
type: Opaque

echo base 64 String | base64 -d
PC IP:9440:PC Username:PC Password
echo -n 'PC IP:9440:admin:NEW_PASSWORD' | base64 base 64 String

kubectl edit secrets nutanix-csi-credentials -n ntnx-system -o yaml
apiVersion: v1
data:
key: base64 encoded New Password
kind: Secret
metadata:
creationTimestamp: "2024-09-30T16:12:20Z"
name: nutanix-csi-credentials
namespace: ntnx-system
resourceVersion: "5023111"
uid: e78d3eef-3d86-4c26-966f-4672531b30aa
type: Opaque
```

1. Scale up the pods on the management cluster:

```bash
kubectl -n ntnx-system patch daemonset nutanix-csi-node --type json -p='[{"op":
"remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'
kubectl scale deployment cluster-api-runtime-extensions-nutanix -n caren-system --
replicas=1
kubectl scale deployment capx-controller-manager -n capx-system --replicas=1
kubectl scale deployment nutanix-csi-controller -n ntnx-system --replicas=1
kubectl scale deployment nutanix-cloud-controller-manager -n kube-system --
replicas=1
```

1. Scale up the pods on the workload cluster:

```bash
kubectl -n ntnx-system patch daemonset nutanix-csi-node --type json -p='[{"op":
"remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]' --kubeconfig=
$KUBECONFIG_WORKLOAD
kubectl scale deployment nutanix-cloud-controller-manager -n kube-system --
replicas=1 --kubeconfig=$KUBECONFIG_WORKLOAD
kubectl scale deployment nutanix-csi-controller -n ntnx-system --replicas=1 --
kubeconfig=$KUBECONFIG_WORKLOAD
```

## Pre-provisioned Infrastructure

Configuration types for installing the Nutanix Kubernetes Platform (NKP) on a
Pre-provisioned Infrastructure.

Create a Kubernetes cluster on pre-provisioned nodes in a bare metal
infrastructure.

Completing this procedure results in a Kubernetes cluster that includes a
Container Networking Interface (CNI) and a Local Persistence Volume Static
Provisioner that is ready for workload deployment.

For more information, see:

- Container Networking Interface (CNI): `<https://docs.projectcalico.org/>`
- Local Persistence Volume Static Provisioner: `<<https://github.com/kubernetes->`
  sigs/sig-storage-local-static-> provisioner

Before moving to a production environment, you might add applications for
logging and monitoring, storage, security, and other functions. You can use
NKP to select and deploy applications or deploy your own. For more
information, see Deploying Platform Applications Using CLI on page 353.

### Pre-provisioned Prerequisites and Environment Variables

Pre-provisioning is the process of setting up an environment that authorized
users, devices, and servers can access. Network provisioning primarily
concerns connectivity and security, which means a heavy focus on device and
identity management. Pre-provisioning can bring enterprises greater efficiency
and more secure operations.

A cloud-based or on-premises server must first be provisioned with the correct
data, software, and configuration to function on a network.

The steps in this process typically include:

- Installing an operating system, device drivers, and partitioning and setup
  tools
- Installing enterprise software and applications
- Setting parameters such as IP addresses
- Performing partitioning or installation of virtualization software
- Connectivity, whether an air-gapped or non-air-gapped environment, meaning
  it is connected to the internet

#### Pre-provisioned: Prerequisites

Infrastructure and machine requirements will be required to fulfill all the
prerequisites for a successful implementation in a Pre-provisioned
environment. Read all the sections on this page to ensure you have met all
prerequisites. Before you begin using Nutanix Kubernetes Platform, you must
have the following set:

- An x86_64-based Linux or macOS machine.
- The nkp binary for Linux or macOS.
- kubectl for interacting with the running cluster.
- Pre-provisioned hosts with SSH access enabled.
- An unencrypted SSH private key, whose public key is configured on the above
  hosts.
- A Container engine/runtime installed is required to install NKP and bootstrap:
- Docker container engine version 27.4.0 installed for Linux or MacOS. For
  more information, see https:// docs.docker.com/get-docker/.

Docker runs in a virtual machine which needs configured with at least 8 GB of
memory.

- Podman Version 4.0 or later for Linux. For more information, see
  `<https://podman.io/getting-started/>` installation. For host requirements,
  see `<https://kind.sigs.k8s.io/docs/user/rootless/#host-requirements>`.
- Air-Gapped Environment Setup:
- NKP Bundle: Download and extract the complete NKP Air-gapped Bundle (NKP
  Air-gapped Bundle for this release (for example, nkp-air-gapped-bundle_nkp-
  version_linux_amd64.tar.gz) to load the registry).
- Local Registry: Set up a working registry.local on a bastion host or another
  accessible machine to host the loaded images.
- Additional steps: Follow the specific guidance in the Pre-provisioned Air-
  gapped: Prerequisites and Docker Registry documentation.
- Ensure your Control Plane Nodes and Worker Nodes Resource Requirements for
  Nutanix Kubernetes Platform on page 721 meet the specific CPU, RAM, and Disk
  specifications.

When in an air-gapped environment, you must also follow the steps described in
Pre-provisioned Air-gapped: Prerequisites on page 795 and Docker Registry as a
prerequisite.

```yaml
Warning: NKP uses localvolumeprovisioner as the default storage provider. However,
localvolumeprovisioner is not suitable for production use. Use a Kubernetes CSI compatible storage that is
suitable for production.
```

You can choose from any of the storage options available for Kubernetes. To
disable the default that Konvoy deploys, set the default StorageClass
localvolumeprovisioner as non-default. Then, set your newly created
StorageClass as the default by following the commands in the Kubernetes
documentation called Changing the Default Storage Class
(`<<https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage->`
class/>).

Machine Specifications

You need to have at least three Control Plane Machines.

Each control plane machine must have the following:

- 4 cores
- 16 GB memory

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

- Approximately 80 GB of free space for the volume used for /var/lib/kubelet
  and /var/lib/containerd.
- 15% free space on the root file system.
- Multiple ports are open as described in the NKP Ports and Protocols page.
- firewalld systemd service disabled. If it exists and is enabled, use the
  commands systemctl stop firewalld then systemctl disable firewalld, so that
  firewalld remains disabled after the machine restarts.

```yaml
Note: Swap is disabled. The kubelet does not have generally available support for swap. Due to variable commands,
refer to your operating system documentation.
```

Worker Machines

You need to have at least four worker machines. The specific number of worker
machines required for your environment can vary depending on the cluster
workload and size of the machines.

Each worker machine must have the following:

- 8 cores
- 32 GiB memory
- Around 80 GiB of free space for the volume used for /var/lib/kubelet and
  /var/lib/containerd
- 15% free space on the root file system
- If you plan to use local volume provisioning to provide persistent volumes
  for your workloads, you must mount at least four volumes to the /mnt/disks/
  mount point on each machine. Each volume must have at least 55 GB capacity.
- Ensure your disk meets the resource requirements for Rook Ceph in Block mode
  for ObjectStorageDaemons
  (`<<https://rook.io/docs/rook/v1.10/CRDs/Cluster/ceph-cluster-crd/#storage->`
  selection-settings>) as specified in the requirements table (Rook Ceph:
  Configuration on page 682).
- Multiple ports are open as described in the NKP Ports and Protocols page.
- firewalld systemd service disabled. If it exists and is enabled, use the
  commands systemctl stop firewalld then systemctl disable firewalld, so that
  firewalld remains disabled after the machine restarts.

```yaml
Note: Swap is disabled. The kubelet does not generally support swap. Due to variable commands, refer to your
operating system documentation.
```

#### Pre-provisioned: Defining the Set Infrastructure

About this task

The Konvoy component of Nutanix Kubernetes Platform (NKP) must know how to
access your cluster hosts, so you must define the cluster hosts and
infrastructure. This is done using inventory resources. For initial cluster
creation, you must define a control-plane and at least one worker pool for
air-gapped and non-air-gapped environments.

Complete the steps to set the necessary environment variables and specify the
control plane and worker nodes:

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

1. Use the following template to define your infrastructure. The environment
   variables you set in this step automatically replace the variable names when
   the inventory YAML file is created.

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

1. To tell the bootstrap cluster which nodes you want to be control plane
   nodes and which nodes are worker nodes. Apply the file to the bootstrap
   cluster using the command kubectl apply.

```bash
kubectl apply -f preprovisioned_inventory.yaml
```

Example:

```bash
preprovisionedinventory.infrastructure.cluster.konvoy.nutanix.io/cluster_name-
control-plane created
preprovisionedinventory.infrastructure.cluster.konvoy.nutanix.io/cluster_name-md-0
created
```

What to do next

Pre-provisioned Cluster Creation Customization Choices

#### Pre-provisioned: Loading the Registry for an Air-gapped Kubernetes Cluster

About this task

The complete Nutanix Kubernetes Platform (NKP) air-gapped bundle is needed for
an air-gapped environment but can also be used in a non-air-gapped
environment. The bundle contains all the NKP components needed for an air-
gapped environment installation and a local registry in a non-air-gapped
environment.

Before you begin

Extract Air-gapped Images

Follow these steps to extract the air-gapped image bundles into your private
registry.

If you are operating in an air-gapped environment, a local container registry
containing all the necessary installation images, including the Kommander
images is required. See below for prerequisites to download and then how to
push the necessary images to this registry.

1. Download the Complete NKP Air-gapped Bundle for this release (that is, nkp-
   air-gapped-bundle_nkp-

version_linux_amd64.tar.gz) to load registry images as explained below. 2.
Connectivity with clusters attaching to the management cluster is required:

- Both management and attached clusters must be able to connect to the local
  registry.
- The management cluster must be able to connect to all attached cluster's API
  servers.
- The management cluster must be able to connect to any load balancers created
  for platform services on the management cluster.

Load the Bootstrap Image

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

Procedure

1. Assuming you have downloaded the air-gapped bundle nkp-air-gapped-bundle_nkp-

version_linux_amd64.tar.gz and extracted the tar file to a local directory
using the command tar -xzvf nkp-air-gapped-bundle_nkp-
version_linux_amd64.tar.gz.

Example directory structure after extraction

```bash
nkp-nkp-version/
### application-charts
# ### NOTICES.txt
# ### nkp-insights-charts-bundle-v2.8.0-rc.2.tar.gz
# ### nkp-kommander-charts-bundle-v2.8.0-rc.2.tar.gz
### application-repositories
# ### nkp-insights-v2.8.0-rc.2.tar.gz
# ### kommander-applications-v2.8.0-rc.2.tar.gz
### container-images
# ### NOTICES.txt (2)
# ### nkp-insights-image-bundle-v2.8.0-rc.2.tar
# ### kommander-image-bundle-v2.8.0-rc.2.tar
# ### konvoy-image-bundle-v2.8.0-rc.2.tar
### nkp
### kib
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

1. The directory structure after extraction can be accessed in subsequent
   steps using commands to access files from different directories. For the
   bootstrap, change your directory to the nkp-`<version>` directory similar to
   example below depending on your current location.
2. Load the bootstrap container image on your bastion machine replacing docker
   with podman if needed:

##### Set Environment Variables

Procedure

Set an environment variable with your registry address and any other needed
variables using this command.

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
REGISTRY_URL: the address of an existing local registry accessible in the VPC that the new cluster nodes will be
configured to use a mirror registry when pulling images.
```

Additional Registry Variables: More environment variables if needed:

```bash
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
```

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

| cd nkp- | nkp-version | Col3 |
| ------- | ----------- | ---- |

| docker load -i konvoy-bootstrap-image- | nkp-version | .tar |
| -------------------------------------- | ----------- | ---- |

```bash
export REGISTRY_CA=<path to the cacert file on the bastion>
```

##### Load Images to your Private Registry - Konvoy

About this task

Before creating or upgrading a Kubernetes cluster, you need to load the
required images in a local registry if operating in an air-gapped environment.
This registry must be accessible from both the bastion machine and either the
AWS EC2 instances or other machines that will be created for the Kubernetes
cluster.

> **Warning: If you do not already have a local registry set up, refer to
> Local Registry Tools page for more information.**

Procedure

Execute the following command to load the air-gapped image bundle into your
private registry: nkp push bundle --bundle ./container-images/konvoy-image-
bundle-nkp-version.tar --to-registry= ${REGISTRY_URL} --to-registry-
username=${REGISTRY_USERNAME} --to-registry-password= ${REGISTRY_PASSWORD}

```yaml
Note: It might take some time to push all the images to your image registry, depending on the network's performance
between the machine you are running the script on and the registry.
```

##### Load Images to your Private Registry - Kommander

About this task

Load Kommander images to your Private Registry.

For the air-gapped kommander image bundle, run the command below.

Procedure

Run the following command to load the image bundle:

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-nkp-version.tar --
to-registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
```

#### Pre-provisioned: Replacing the Driver with the Azure Disk CSI Driver

About this task

The Nutanix Kubernetes Platform (NKP) Pre-provisioned provider installs by
default the storage-local-static- provisioner CSI driver, which is not
suitable for production environments. For this reason, it needs to be replaced
by the Azure Disk CSI Driver.

Before you begin

- An x86_64-based Linux or macOS machine.
- Download the nkp binary for Linux or macOS. To check which version of NKP
  you installed for compatibility reasons, run the nkp version command.

- bundle --bundle ./container-images/konvoy-image-bundle-; nkp-version; .tar
  --to-registry=

| --- | --- | --- |

- A Container engine or runtime installed is required to install NKP and
  bootstrap:
- Docker container engine version 27.4.0 installed for Linux or MacOS. For
  more information, see https:// docs.docker.com/get-docker/.
- Podman Version 4.0 or later for Linux. For more information, see
  `<https://podman.io/getting-started/>` installation. For host requirements,
  see `<https://kind.sigs.k8s.io/docs/user/rootless/#host-requirements>`.
- CLI tool Kubectl is used to interact with the running cluster.
  `<https://kubernetes.io/docs/tasks/tools/#kubectl>`
- Azure CLI. For more information, see `<<https://docs.microsoft.com/en->`
  us/cli/azure/install-azure-cli>.
- A valid Azure account with credentials configured. For more information, see
  `<https://learn.microsoft.com/en->` us/azure/aks/concepts-identity.
- Create a custom Azure image using NIB. For more information, see Building a
  Custom Image with Azure on page 61.
- For air-gapped environments only:
- Ability to download artifacts from the internet and then copy those onto
  your Bastion machine.
- Download the Complete NKP Air-gapped Bundle for this release - nkp-air-
  gapped-bundle_nkp- version_linux_amd64.tar.gz.
- An existing local registry to seed the air-gapped environment. For more
  information, see Registry and Registry Mirrors on page 705.

> **Note: On macOS, Docker runs in a virtual machine. Configure this virtual
> machine with at least 8GB of memory.**

About this task

Set Environment Variables with Credentials - An Azure Service Principal is
needed for deploying resources. To configure your Azure environment, follow
below.

Procedure

1. Log in to Azure using the command az login. Example output:

```bash
[
{
"cloudName": "AzureCloud",
"homeTenantId": "a1234567-b132-1234-1a11-1234a5678b90",
"id": "b1234567-abcd-11a1-a0a0-1234a5678b90",
"isDefault": true,
"managedByTenants": [],
"name": "Mesosphere Developer Subscription",
"state": "Enabled",
"tenantId": "a1234567-b132-1234-1a11-1234a5678b90",
"user": {
"name": "user@azuremesosphere.onmicrosoft.com",
"type": "user"
}
}
]
```

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

1. Create an Azure Service Principal (SP) by using the command az ad sp
   create-for-rbac --role contributor --name "$(whoami)-konvoy"
  --scopes=/subscriptions/$(az account show -- query id -o tsv). This command
   will rotate the password if an SP with the name exists. Example output:

```bash
{
"appId": "7654321a-1a23-567b-b789-0987b6543a21",
"displayName": "azure-cli-2021-03-09-23-17-06",
"password": "DUMMY_CLIENT_SECRET",
"tenant": "a1234567-b132-1234-1a11-1234a5678b90"
}
```

- For air-gapped environments, you need to create a resource management
  private link (https:// learn.microsoft.com/en-us/azure/azure-resource-
  manager/management/create-private-link-access- portal) with a private
  endpoint to ensure the Azure CSI driver will run correctly in further steps.
  Private links enable you to access Azure services over a private endpoint in
  your virtual network. For more information, see
  `<<https://learn.microsoft.com/en-us/azure/azure-resource->`
  manager/management/create-private-> link-access-portal.

To set up a private link resource, use the following process.

1. Create a private resource management link using Azure CLI. For more
   information, see https:// learn.microsoft.com/en-
   us/azure/azure-resource-manager/management/create-private-link- access-
   commands?tabs=azure-cli#create-resource-
   management-private-link 2. Create a private link association for the root
   management group, which also references the
   resource ID for the resource management private link. For more information,
   see `<https://learn.microsoft.com/>` en-
   us/azure/azure-resource-manager/management/create-private-link-access-
   commands? tabs=azure-cli#create-private-link-
   association. 3. Add a private endpoint referencing the resource management
   private link using the Azure Documentation.
   For more information, see `<<https://learn.microsoft.com/en-us/azure/private->`
   link/> create-private-endpoint-
   cli?tabs=dynamic-ip.
2. Set the required environment variables. Example:

```bash
export AZURE_SUBSCRIPTION_ID="<id>" # b1234567-abcd-11a1-a0a0-1234a5678b90
export AZURE_TENANT_ID="<tenant>" # a1234567-b132-1234-1a11-1234a5678b90
export AZURE_CLIENT_ID="<appId>" # 7654321a-1a23-567b-b789-0987b6543a21
export AZURE_CLIENT_SECRET="<password>" # DUMMY_CLIENT_SECRET
export AZURE_RESOURCE_GROUP="<resource group name>" # set to the name of the
resource group
export AZURE_LOCATION="westus" # set to the location you are using
```

1. Set your KUBECONFIG environment variable using the command export
   kubeconfig= ${CLUSTER_NAME}.conf
2. Create the Secret with the Azure credentials. The Azure CSI driver will use
   this.

a. Create an azure.json file.

```bash
cat <<EOF > azure.json
{
"cloud": "AzurePublicCloud",
"tenantId": "$AZURE_TENANT_ID",
"subscriptionId": "$AZURE_SUBSCRIPTION_ID",
"aadClientId": "$AZURE_CLIENT_ID",
"aadClientSecret": "$AZURE_CLIENT_SECRET",
"resourceGroup": "$AZURE_RESOURCE_GROUP",
"location": "$AZURE_LOCATION"
}
EOF
```

b. Create the Secret using the command kubectl create secret generic azure-
cloud-provider --

namespace=kube-system --type=Opaque --from-file=cloud-config=azure.json. 6.
Install the Azure Disk CSI driver using the command $ curl -skSL https://
raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/v`<kubernetes- version>`/deploy/install-driver.sh | bash -s v`<kubernetes-version>` snapshot
-.

```yaml
Note: For more information about the supported Kubernetes version, see Supported Kubernetes Versions section
in the NKP Release Notes.
```

1. Check the status to see if the driver is ready for use using the command.

```bash
kubectl -n kube-system get pod -o wide --watch -l app=csi-azuredisk-controller
kubectl -n kube-system get pod -o wide --watch -l app=csi-azuredisk-node
```

Kubernetes knows this is Azure disk and will create clusters on Azure. 8.
Create the StorageClass for the Azure Disk CSI Driver using the command
kubectl create -f https:// raw.githubusercontent.com/kubernetes-
sigs/azuredisk-csi-driver/master/deploy/ example/storageclass-azuredisk-
csi.yaml. 9. Change the default storage class to this new StorageClass so that
every new disk will be created in the Azure environment using the command.

```bash
kubectl patch sc/localvolumeprovisioner -p '{"metadata": {"annotations":
{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch sc/managed-csi -p '{"metadata": {"annotations":
{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

1. Verify that the StorageClass chosen is currently the default using the
   command kubectl get storageclass. For more information about Azure Disk CSI
   for persistent storage and changing the default StorageClass, see Default
   Storage Providers in NKP.

### Pre-provisioned Cluster Creation Customization Choices

Below are two methods to customize your cluster during creation. If none of
these choices apply, proceed to the next section.

- Pre-provisioned Install in a Non-air-gapped Environment
- Pre-provisioned Install in an Air-gapped Environment

Pre-provisioned Section Topics

Many options are available when creating clusters, such as those listed in
this documentation section. A brief explanation of each choice is given in the
following topic summaries with a link to the more descriptive page. To use
these, proceed to the cluster choice page for detailed instructions:

- Pre-provisioned Customizing CAPI Clusters : Familiarize yourself with the
  Cluster API before editing the cluster objects, as edits can prevent the
  cluster from deploying successfully.
- Pre-provisioned Registry Mirrors: In an air-gapped environment, you need a
  local repository to store Helm charts, Docker images, and other artifacts.
  In an environment with access to the Internet, you can retrieve artifacts
  from specialized repositories dedicated to them, such as Docker images
  contained in DockerHub and Helm Charts that come from a dedicated Helm Chart
  repository.

- raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/v<;
  kubernetes-

| --- | --- |

- version; >/deploy/install-driver.sh; bash -s v`<; kubernetes-version;>`
  snapshot –

| --- | --- | --- | --- | --- |

- Pre-provisioned Create Secrets and Overrides: Create necessary secrets and
  overrides for pre-provisioned clusters. Most applications deployed through
  Kubernetes (`<https://kubernetes.io/docs/concepts/configuration/>` secret/)
  require access to databases, services, and other external resources. The
  easiest way to manage the login information necessary to access those
  resources is using secrets, which help organize and distribute sensitive
  information across a cluster while minimizing the risk of sensitive
  information exposure.
- Pre-provisioned Define Control Plane Endpoint: A control plane needs to have
  three, five, or seven nodes to remain available if one, two, or three nodes
  fail. A control plane with one node is not for production use.
- Pre-provisioned Configure MetalLB: An external load balancer (LB) is
  recommended to be the control plane endpoint. To distribute request load
  among the control plane machines, configure the load balancer to send
  requests to all the control plane machines. Configure the load balancer to
  send requests only to control plane machines responding to API requests. If
  you do not have one, you can use Metal LB to create MetalLB configmap for
  your Pre-provisioned infrastructure.
- Pre-provisioned Modify the Calico Installation: Calico is a networking and
  security solution that enables Kubernetes and non-Kubernetes/legacy
  workloads to communicate seamlessly and securely. Sometimes, changes are
  needed, so use the information on this Pre-provisioned Modify the Calico
  Installation page.
- Pre-provisioned Built-in Virtual IP: As explained in Define the Control
  Plane Endpoint, we recommend using an external load balancer for the control
  plane endpoint but provide a built-in virtual IP when one is not available.
- Pre-provisioned Use HTTP Proxy: When you require HTTP proxy configurations,
  you can apply them during the create operation by adding the appropriate
  flags to the nkp create cluster command.
- Pre-provisioned Use Alternate Pod or Service Subnets: Some subnets are
  reserved by Kubernetes and can prevent proper cluster deployment if you
  unknowingly configure NKP so that the Node subnet collides with either the
  Pod or Service subnet.
- Pre-provisioned Output Directory YAML: You can create individual files with
  different smaller manifests for ease in editing using the --output-directory
  flag used with --output=json|yaml. You create the directory where resources
  are outputted to files.

Single-Node Control Plane

> **Caution: Do not use a single-node control plane in a production cluster.**

A control plane with one node can use its single node as the endpoint, so you
will not require an external load balancer or a built-in virtual IP. At least
one control plane node must always be running. Therefore, a spare machine must
be available in the control plane inventory to upgrade a cluster with one
control plane node. This machine is used to provision the new node before the
old node is deleted.

When the API server endpoints are defined, you can create the cluster.

> **Note: For more information on modifying Control Plane Audit logs
> settings, see Configuring the Control Plane.**

#### Pre-provisioned: Customizing CAPI Clusters

Familiarize yourself with Cluster API before editing the cluster objects
because edits can prevent the cluster from deploying successfully.

The result of this command will allow such edits:

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host <control plane endpoint host> \
--pre-provisioned-inventory-file preprovisioned_inventory.yaml \
--ssh-private-key-file <path-to-ssh-private-key> \
--dry-run \
--output=yaml \
> ${CLUSTER_NAME}.yaml
```

To edit the YAML, you need to understand the CAPI components to avoid breaking
the cluster.

#### Pre-provisioned: Registry Mirrors

In an air-gapped environment, you need a local repository to store Helm
charts, Docker images, and other artifacts. In an environment with access to
the Internet, you can retrieve artifacts from specialized repositories
dedicated to them, such as Docker images contained in DockerHub and Helm
Charts that come from a dedicated Helm Chart repository.

Kubernetes does not natively provide a registry for hosting the container
images you will use to run the applications you want to deploy on Kubernetes.
Instead, Kubernetes requires you to use an external solution to store and
share container images. A variety of Kubernetes-compatible registry options
are compatible with NKP.

How the Registry Mirror Works

The first time you request an image from your local registry mirror, it pulls
the image from the public registry (such as Docker) and stores it locally
before handing it back to you. On subsequent requests, the local registry
mirror can serve the image from its storage.

Air-gapped vs. Non-air-gapped Environments

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
premises locally in an air-gapped environment. NKP in an air-gapped
environment requires a local container registry of
trusted images to enable production-level Kubernetes cluster management.
However, a local registry is also an option in
a non-air-gapped environment for speed and security.

If you want to use images from this local registry to deploy applications
inside your Kubernetes cluster, you will need to set up a secret for a private
registry. The secret contains your login data, which Kubernetes needs to
connect to your private repository.

#### Pre-provisioned: Creating Secrets and Overrides

About this task

Most applications deployed through Kubernetes require external access to
databases, services, and other resources. The easiest way to manage the login
information necessary to access those resources is by using secrets to help
organize and distribute sensitive information across a cluster while
minimizing the risk of sensitive information exposure.

Nutanix Kubernetes Platform (NKP) requires SSH access to your infrastructure
with superuser privileges. You must provide an unencrypted SSH private key to
NKP , so secrets are a good way to achieve this. Populate the key and create
the required secret on your bootstrap cluster using the following procedure.

Before you begin

Create a Unique Cluster Name

Give your cluster a unique name suitable for your environment.

Procedure

Set the environment variable to be used throughout this procedure using the
command export CLUSTER_NAME=`<cluster_name>`

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if the
name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

(Optional) If you want to create a unique cluster name using the command.

```bash
export CLUSTER_NAME=cluster_name-$(LC_CTYPE=C tr -dc 'a-z0-9' </dev/urandom | fold -w 5
| head -n1)
echo $CLUSTER_NAME
```

> **Note: This creates a unique name every time you run it, so use it
> carefully.**

```bash
cluster_name-pf4a3
```

##### Create a Secret

About this task

Procedure

1. Export the key using the command export SSH_PRIVATE_KEY_FILE="`<path-to-
ssh-private-key>`"
2. Export the secret using the command export
   SSH_PRIVATE_KEY_SECRET_NAME=$CLUSTER_NAME-ssh-key.
3. Create the secret using the command.

```bash
kubectl create secret generic ${SSH_PRIVATE_KEY_SECRET_NAME} --from-file=ssh-
privatekey=${SSH_PRIVATE_KEY_FILE}
kubectl label secret ${SSH_PRIVATE_KEY_SECRET_NAME} clusterctl.cluster.x-k8s.io/move=
```

Example output:

```bash
secret/cluster_name-ssh-key created
secret/cluster_name-ssh-key labeled
```

##### Create Overrides

About this task

##### Create a Secret (2)

Procedure

1. Example CentOS7 and Docker - If you want to provide an override with Docker
   credentials and a different source for EPEL on a CentOS7 machine, create a
   file like this.

```bash
cat > overrides.yaml << EOF
image_registries_with_auth:
- host: "registry-1.docker.io"
username: "my-user"
password: "my-password"
auth: ""
identityToken: ""
epel_centos_7_rpm: https://my-rpm-repostory.org/epel/epel-release-latest-7.noarch.rpm
EOF
```

You can then create the related secret by using the command.

```bash
kubectl create secret generic $CLUSTER_NAME-user-overrides --from-
file=overrides.yaml=overrides.yaml
kubectl label secret $CLUSTER_NAME-user-overrides clusterctl.cluster.x-k8s.io/move=
```

1. When using Oracle 7 OS, you might wish to deploy the RHCK kernel instead of
   the default UEK kernel. To do so, add the following text to your
   overrides.yaml.

```bash
cat > overrides.yaml << EOF
---
oracle_kernel: RHCK
EOF
kubectl create secret generic $CLUSTER_NAME-user-overrides --from-
file=overrides.yaml=overrides.yaml
kubectl label secret $CLUSTER_NAME-user-overrides clusterctl.cluster.x-k8s.io/move=
```

#### Pre-provisioned: Creating FIPS Secrets and Overrides

About this task

You must provide an unencrypted SSH private key to NKP , so secrets are a good
way to achieve this. Populate the key and create the required secret on your
bootstrap cluster using the following procedure.

Before you begin

Create a Unique Cluster Name

Give your cluster a unique name suitable for your environment.

Procedure

Set the environment variable to be used throughout this procedure using the
command export CLUSTER_NAME=`<cluster_name>`

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if the
name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

(Optional) If you want to create a unique cluster name, use the command.

```bash
export CLUSTER_NAME=cluster_name-$(LC_CTYPE=C tr -dc 'a-z0-9' </dev/urandom | fold -w 5
| head -n1)
echo $CLUSTER_NAME
```

> **Note: This creates a unique name every time you run it, so use it
> carefully.**

```bash
cluster_name-pf4a3
```

##### Create a Secret (3)

About this task

Procedure

1. Export the key using the command export SSH_PRIVATE_KEY_FILE="`<path-to-
ssh-private-key>`" .
2. Export the secret using the command

```bash
export SSH_PRIVATE_KEY_SECRET_NAME=$CLUSTER_NAME-ssh-key
```

1. Create the secret using the command.

```bash
kubectl create secret generic ${SSH_PRIVATE_KEY_SECRET_NAME} --from-file=ssh-
privatekey=${SSH_PRIVATE_KEY_FILE}
kubectl label secret ${SSH_PRIVATE_KEY_SECRET_NAME} clusterctl.cluster.x-k8s.io/move=
```

Example output:

```bash
secret/cluster_name-ssh-key created
secret/cluster_name-ssh-key labeled
```

##### Create Overrides (2)

About this task

Procedure

1. Create a secret that includes the customization Overrides for FIPS
   compliance.

```bash
cat > overrides.yaml << EOF
---
k8s_image_registry: docker.io/mesosphere
fips:
enabled: true
build_name_extra: -fips
kubernetes_build_metadata: fips.0
default_image_repo: hub.docker.io/mesosphere
kubernetes_rpm_repository_url: "https://packages.nutanix.com/konvoy/stable/linux/
repos/el/kubernetes-v{{ kubernetes_version }}-fips/x86_64"
docker_rpm_repository_url: "\
https://containerd-fips.s3.us-east-2.amazonaws.com\
/{{ ansible_distribution_major_version|int }}\
/x86_64"
EOF
```

1. If your pre-provisioned machines need customization with alternate package
   libraries, Docker image or other container registry image repositories, or
   other Custom Override Files, add more lines to the same Overrides file.

a. Example One - If you want to provide an override with Docker credentials
and a different source for EPEL on a CentOS7 machine, create a file like this.

```bash
cat > overrides.yaml << EOF
---
# fips configuration
k8s_image_registry: docker.io/mesosphere
fips:
enabled: true
build_name_extra: -fips
kubernetes_build_metadata: fips.0
default_image_repo: hub.docker.io/mesosphere
kubernetes_rpm_repository_url: "https://packages.nutanix.com/konvoy/stable/linux/
repos/el/kubernetes-v{{ kubernetes_version }}-fips/x86_64"
docker_rpm_repository_url: "\
https://containerd-fips.s3.us-east-2.amazonaws.com\
/{{ ansible_distribution_major_version|int }}\
/x86_64"
EOF
```

b. Example Two - When using Oracle 7 OS, you may wish to deploy the RHCK
kernel instead of the default UEK kernel. To do so, add the following text to
your overrides.yaml.

```bash
cat > overrides.yaml << EOF
---
# fips configuration (2)
k8s_image_registry: docker.io/mesosphere
fips:
enabled: true
build_name_extra: -fips
kubernetes_build_metadata: fips.0
default_image_repo: hub.docker.io/mesosphere
kubernetes_rpm_repository_url: "https://packages.nutanix.com/konvoy/stable/linux/
repos/el/kubernetes-v{{ kubernetes_version }}-fips/x86_64"
docker_rpm_repository_url: "\
https://containerd-fips.s3.us-east-2.amazonaws.com\
/{{ ansible_distribution_major_version|int }}\
/x86_64"
# custom configuration
oracle_kernel: RHCK
EOF
```

1. Create the related secret by using the command.

```bash
kubectl create secret generic $CLUSTER_NAME-user-overrides --from-
file=overrides.yaml=overrides.yaml
kubectl label secret $CLUSTER_NAME-user-overrides clusterctl.cluster.x-k8s.io/move=
```

#### Pre-provisioned: Defining Control Plane Endpoint

Define the control plane endpoint for your cluster and the connection
mechanism. A control plane must have three, five, or seven nodes to remain
available if one or more nodes fail. A control plane with one node is not for
production use.

In addition, the control plane should have an endpoint that remains available
if some nodes fail.

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

The control plane endpoint port is also used as the API server port on each
control plane machine. The default port is 6443. Before creating the cluster,
ensure the port is available on each control plane machine.

Select your Connection Mechanism

A virtual IP is the client's address to which to connect to the service. A
load balancer is a device that distributes the client connections to the
backend servers. Before you create a new Nutanix Kubernetes Platform (NKP)
cluster, choose an external load balancer (LB) or virtual IP.

- External load balancer

It is recommended that an external load balancer be the control plane
endpoint. To distribute request load among the control plane machines,
configure the load balancer to send requests to all the control plane
machines. Configure the load balancer to send requests only to control plane
machines responding to API requests.

- Built-in virtual IP

You can use the built-in virtual IP if an external load balancer is
unavailable. The virtual IP is not a load balancer; it does not distribute
request load among the control plane machines. However, if the machine
receiving requests does not respond, the virtual IP automatically moves to
another machine.

Single-Node Control Plane

> **Caution: Do not use a single-node control plane in a production cluster.**

A control plane with one node can use its single node as the endpoint, so you
will not require an external load balancer
or a built-in virtual IP. At least one control plane node must always be
running. Therefore, a spare machine must be
available in the control plane inventory to upgrade a cluster with one control
plane node. This machine is used to
provision the new node before the old node is deleted. When the API server
endpoints are defined, you can create the
cluster using the link in the Next Step below.

> **Note: Modify Control Plane Audit log settings using the information on
> the page Configure the Control Plane.**

#### Pre-provisioned: Configuring MetalLB

Create MetalLB configuration for your Pre-provisioned infrastructure.

Nutanix recommends that an external load balancer (LB) be the control plane
endpoint. To distribute request load among the control plane machines,
configure the load balancer to send requests to all the control plane
machines. Configure the load balancer to send requests only to control plane
machines responding to API requests. If you do not have one, you can use Metal
LB to create MetalLB custom resources for your Pre-provisioned infrastructure.

Choose one of the two protocols you want to use to announce service IPs. If
your environment is not currently equipped
with a load balancer, you can use MetalLB, a load balancer implementation for
Kubernetes. Otherwise, your load balancer
will work, and you can continue the installation process with Pre-provisioned:
Installing Kommander on page 80. To use
MetalLB, create MetalLB custom resources for your Pre-provisioned
infrastructure. MetalLB uses one of two protocols to
expose Kubernetes services.

Select one of the following procedures to create your MetalLB manifest for
further editing:

- Layer 2, with Address Resolution Protocol (ARP)
- Border Gateway Protocol (BGP)

Layer 2 Configuration

Layer 2 mode is the simplest to configure: in many cases, you do not need any
protocol-specific configuration, only IP addresses. It does not require the
IPs to be bound to the network interfaces of your worker nodes. It responds to
ARP requests on your local network directly and gives clients the machine's
MAC address.

> **Warning:**

- MetalLB IP address ranges or CIDRs must be within the node's primary network
  subnet. For more information, see Cluster Pod and Services Subnets on page

1.

- MetalLB IP address ranges, CIDRs, and node subnets must not conflict with
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

For a basic configuration featuring one BGP router and one IP address range,
you need four pieces of information:

- The router IP address that MetalLB needs to connect to.
- The router's autonomous systems (AS) number.
- The AS number MetalLB.
- An IP address range is a Classless Inter-Domain Routing (CIDR) prefix.

As an example, if you want to give MetalLB the range 192.168.10.0/24 and AS
number 64500 and connect it to a router at 10.0.0.1 with AS number 64501, your
configuration will look like this:

> **Note: The following values are generic, enter your specific values into
> the fields where applicable.**

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

#### Pre-provisioned: Modifying the Calico Installation

About this task

Set the Interface

By default, Calico automatically detects the IP address to use for each node
using the first-found method. This is not always appropriate for your
particular nodes. In that case, you must modify Calico's configuration to use
a different method. An alternative is to use the interface method by providing
the interface ID.

> **Note: Azure does not set the interface. Proceed to Change the
> Encapsulation Type section below.**

In this example, all cluster nodes use ens192 as the interface name.

Procedure

1. Get the pods running on your cluster with this command.

```bash
kubectl get pods -A --kubeconfig ${CLUSTER_NAME}.conf
```

Output:

```bash
NAMESPACE NAME
READY STATUS RESTARTS AGE
calico-system calico-kube-controllers-57fbd7bd59-vpn8b
1/1 Running 0 16m
calico-system calico-node-5tbvl
1/1 Running 0 16m
calico-system calico-node-nbdwd
1/1 Running 0 4m40s
calico-system calico-node-twl6b
0/1 PodInitializing 0 9s
calico-system calico-node-wktkh
1/1 Running 0 5m35s
calico-system calico-typha-54f46b998d-52pt2
1/1 Running 0 16m
calico-system calico-typha-54f46b998d-9tzb8
1/1 Running 0 4m31s
default cuda-vectoradd
0/1 Pending 0 0s
kube-system coredns-78fcd69978-frwx4
1/1 Running 0 16m
kube-system coredns-78fcd69978-kkf44
1/1 Running 0 16m
kube-system etcd-ip-10-0-121-16.us-west-2.compute.internal
0/1 Running 0 8s
kube-system etcd-ip-10-0-46-17.us-west-2.compute.internal
1/1 Running 1 16m
kube-system etcd-ip-10-0-88-238.us-west-2.compute.internal
1/1 Running 1 5m35s
kube-system kube-apiserver-ip-10-0-121-16.us-west-2.compute.internal
0/1 Running 6 7s
kube-system kube-apiserver-ip-10-0-46-17.us-west-2.compute.internal
1/1 Running 1 16m
kube-system kube-apiserver-ip-10-0-88-238.us-west-2.compute.internal
1/1 Running 1 5m34s
kube-system kube-controller-manager-ip-10-0-121-16.us-
west-2.compute.internal 0/1 Running 0 7s
kube-system kube-controller-manager-ip-10-0-46-17.us-
west-2.compute.internal 1/1 Running 1 (5m25s ago) 15m
kube-system kube-controller-manager-ip-10-0-88-238.us-
west-2.compute.internal 1/1 Running 0 5m34s
kube-system kube-proxy-gclmt
1/1 Running 0 16m
kube-system kube-proxy-gptd4
1/1 Running 0 9s
kube-system kube-proxy-mwkgl
1/1 Running 0 4m40s
kube-system kube-proxy-zcqxd
1/1 Running 0 5m35s
kube-system kube-scheduler-ip-10-0-121-16.us-west-2.compute.internal
0/1 Running 1 7s
kube-system kube-scheduler-ip-10-0-46-17.us-west-2.compute.internal
1/1 Running 3 (5m25s ago) 16m
kube-system kube-scheduler-ip-10-0-88-238.us-west-2.compute.internal
1/1 Running 1 5m34s
kube-system local-volume-provisioner-2mv7z
1/1 Running 0 4m10s
kube-system local-volume-provisioner-vdcrg
1/1 Running 0 4m53s
kube-system local-volume-provisioner-wsjrt
1/1 Running 0 16m
node-feature-discovery node-feature-discovery-master-84c67dcbb6-m78vr
1/1 Running 0 16m
node-feature-discovery node-feature-discovery-worker-vpvpl
1/1 Running 0 4m10s
tigera-operator tigera-operator-d499f5c8f-79dc4
1/1 Running 1 (5m24s ago) 16m
Note: If a calico-node pod is not ready on your cluster, you must edit the default Installation resource. To
edit the Installation resource, run the command:
kubectl edit installation default --kubeconfig ${CLUSTER_NAME}.conf
```

1. Change the value for spec.calicoNetwork.nodeAddressAutodetectionV4 to
   interface: ens192, and save the resource.

```bash
spec:
calicoNetwork:
...
nodeAddressAutodetectionV4:
interface: ens192
```

1. Save this resource. If that pod has failed, you might need to delete the
   node feature discovery worker pod in the node-feature-discovery namespace.
   After you delete it, Kubernetes replaces the pod as part of its normal
   reconciliation.

##### Change the Encapsulation Type

About this task

Calico can leverage different network encapsulation methods to route traffic
for your workloads. Encapsulation is useful when running on top of an
underlying network that is unaware of workload IPs.

Common Examples:

Procedure

- Public cloud environments where you do not own the hardware.
- AWS across VPC subnet boundaries.
- Environments where you cannot peer Calico over BGP to the underlay or easily
  configure static routes.

```yaml
Warning: Switching encapsulation modes can cause disruption to in-progress connections. You can do this safely
when the cluster is first deployed. However, if user workloads are already running on the cluster, plan accordingly
for interruption.
```

###### Provider Specific Steps

About this task

The encapsulation type for networking depends on the cloud provider.IP-in-IP
is Calico's default encapsulation method, which most providers use, but not
Azure.

```yaml
Note: Azure only supports VXLAN encapsulation type. Therefore, if you install on Azure pre-provisioned VMs, you
must set the encapsulation mode to VXLAN.
```

##### Change the Encapsulation Type (2)

Procedure

1. First, remove the existing default-ipv4-ippool IPPool resource from
   kubeconfig. After you edit the installation resource, the resource must be
   deleted to be recreated. Run the command below to delete.

```bash
kubectl delete ippool default-ipv4-ippool
```

1. Run the following command to edit.

```bash
kubectl edit installation default --kubeconfig ${CLUSTER_NAME}.conf
```

1. Change the value for encapsulation - encapsulation: as shown below.

```bash
spec:
calicoNetwork:
ipPools:
- encapsulation: VXLAN
```

VXLAN is a tunneling protocol that encapsulates Layer 2 Ethernet frames in UDP
packets, enabling you to create virtualized Layer 2 subnets that span Layer 3
networks. It has a slightly larger header than IP-in-IP, which slightly
reduces performance over IP-in-IP.

IPIP IP-in-IP is an IP tunneling protocol that encapsulates one IP packet in
another IP packet. An outer packet header is added with the tunnel entry and
exit points. The calico implementation of this protocol uses BGP to determine
the exit point, which makes this protocol unusable on networks that do not
pass BGP

For more information, see:

- Calico Overlay Networking
- Calico Routing for VXLAN
- IP-in-IP RFC 2003
- VXLAN RFC 7348

#### Pre-provisioned: Built-in Virtual IP

Nutanix recommends using an external load balancer for the control plane
endpoint but provide a built-in virtual IP when an external load balancer is
unavailable. If an external load balancer is unavailable, use the built-in
virtual IP.

The virtual IP is not a load balancer; it does not distribute request load
among the control plane machines. However, if the machine receiving requests
does not respond to them, the virtual IP automatically moves to another
machine. The built-in virtual IP uses the kube-vip project. To use the virtual
IP, add these flags to the create cluster command:

Table 70: Create Cluster Flags

Virtual IP Example

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host 196.168.1.10 \
--virtual-ip-interface eth1
--pre-provisioned-inventory-file preprovisioned_inventory.yaml
--ssh-private-key-file <path-to-ssh-private-key>
--self-managed
```

For more information on kube-vip, see `<https://kube-vip.io/>`

#### Pre-provisioned: HTTP Proxy

When you require HTTP proxy configurations, you can apply them during the
create operation by adding the appropriate flags to the nkp create cluster
command.

If your environment uses HTTP/HTTPS proxies, you must include the flags
--http-proxy, --https-proxy, and --no-proxy and their related values in this
command for it to be successful. Prior to DKP 2.6, you had to specify the HTTP
proxy in the NIB override setup and then again in the dkp create cluster
command. After DKP 2.6, an HTTP proxy gets created from the Konvoy flags for
the control plane proxy and workers proxy values. The flags in

| Virtual IP Configuration | |
| Flag | |

|     |     |
| --- | --- |

- Network interface to use for Virtual IP. It must exist on all control plane
  machines. --virtual-ip-interface string IPv4 address. Reserved for use by
  the cluster. --control-plane-endpoint string; Network interface to use for
  Virtual IP. It must exist on all control plane machines. --virtual-ip-
  interface string IPv4 address. Reserved for use by the cluster. --control-
  plane-endpoint string

the NKP command for Pre-provisioned clusters populate a Secret automatically
in the bootstrap cluster. That Secret has a known name that the Pre-
provisioned controller finds and applies when it runs the NIB provisioning
job.

More information is available in Configuring an HTTP or HTTPS Proxy on page 696.

You must also add the same configuration as an override .

HTTP Proxy Example

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--control-plane-http-proxy http://proxy.example.com:8080 \
--control-plane-https-proxy https://proxy.example.com:8080 \
--control-plane-no-proxy
"127.0.0.1,10.96.0.0/12,192.168.0.0/16,kubernetes,kubernetes.default.svc,kubernetes.default.svc.cl
\
--worker-http-proxy http://proxy.example.com:8080 \
--worker-https-proxy https://proxy.example.com:8080 \
--worker-no-proxy
"127.0.0.1,10.96.0.0/12,192.168.0.0/16,kubernetes,kubernetes.default.svc,kubernetes.default.svc.cl
```

#### Pre-provisioned: Using Alternate Pod or Service Subnets

Procedure

1. In Konvoy, the default pod subnet is 192.168.0.0/16, and the default
   service subnet is 10.96.0.0/12. Ensure your subnets do not overlap with your
   host subnet because they cannot be changed after cluster creation.

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

If you need to change the Kubernetes subnets, you must do this at cluster
creation. To change the subnets, perform the following steps: 2. Generate the
YAML manifests for the cluster using the --dry-run and -o yaml flags, along
with the desired

```bash
nkp cluster create command:
nkp create cluster preprovisioned --cluster-name ${CLUSTER_NAME} --control-plane-
endpoint-host <control plane endpoint host> --control-plane-endpoint-port <control
plane endpoint port, if different than 6443> --dry-run -o yaml > cluster.yaml
```

| Proxy configuration | Flag |

|                                       |                             |
| ------------------------------------- | --------------------------- |
| HTTP proxy for control plane machines | `--control-plane-http-proxy |

string` |

- HTTPS proxy for control plane machines; `--control-plane-https-proxy
string`
- No Proxy list for control plane machines; `--control-plane-no-proxy
strings`

| HTTP proxy for worker machines | `--worker-http-proxy string` |
| | |
| HTTPS proxy for worker machines | `--worker-https-proxy string` |
| | |
| No Proxy list for worker machines | `--worker-no-proxy strings` |
| | |

1. To modify the service subnet, add or edit the
   spec.clusterNetwork.services.cidrBlocks field of the

Cluster object:

```yaml
kind: Cluster
spec:
clusterNetwork:
services:
cidrBlocks:
  - 10.0.0.0/12
```

1. To modify the pod subnet, edit the Cluster and calico-cni ConfigMap
   resources:

Cluster: Add or edit the spec.clusterNetwork.pods.cidrBlocks field:

```yaml
kind: Cluster
spec:
clusterNetwork:
pods:
cidrBlocks:
- 172.16.0.0/16
ConfigMap: Edit the data."custom-resources.yaml".spec.calicoNetwork.ipPools.cidr field with
your desired pod subnet:
apiVersion: v1
data:
custom-resources.yaml: |
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
name: default
spec:
# Configures Calico networking. (2)
calicoNetwork:
# Note: The ipPools section cannot be modified post-install. (2)
ipPools:
- blockSize: 26
cidr: 172.16.0.0/16
kind: ConfigMap
metadata:
name: calico-cni-<cluster-name>
```

When you provision the cluster, the configured pod and service subnets will be
applied.

#### Pre-provisioned: Output Directory YAML

You can create individual files with different smaller manifests for ease in
editing using the --output-directory flag used with --output=json|yaml. You
create the directory of where to output resources to files.

Using this flag will create multiple files in the specified directory which
must already exist:

```bash
nkp create cluster preprovisioned
--cluster-name=${CLUSTER_NAME} \
--dry-run \
--output=yaml \
--output-directory=<existing-directory>
```

For more information regarding this flag or others, please refer to the CLI
section of the documentation for the nkp create cluster command and select
your provider.

### Pre-provisioned Installation in a Non-air-gapped Environment

In pre-provisioned environments, Nutanix Kubernetes Platform (NKP) handles
your cluster's life cycle, including installation, upgrade, and node
management. NKP installs Kubernetes, monitoring and logging apps, and its own
UI.

In an environment with access to the Internet, you retrieve artifacts from
specialized repositories dedicated to them, such as Docker images contained in
DockerHub and Helm Charts that come from a dedicated Helm Chart repository.
However, in an air-gapped environment, you need local repositories to store
Helm charts, Docker images, and other artifacts. Tools such as JFrog, Harbor,
and Nexus handle multiple types of artifacts in one local repository.

```yaml
Note: If desired, a local registry can also be used in a non-air-gapped environment for speed and security. To do so,
add the Pre-provisioned Installation in an Air-gapped Environment on page 795 steps to your non-air-
gapped installation process.
```

#### Pre-provisioned Non-Air-gapped: Bootstrap

About this task

To create Kubernetes clusters, NKP uses Cluster API (CAPI) controllers. These
controllers run on a Kubernetes cluster. To get started, you need a bootstrap
cluster. By default, Konvoy creates a bootstrap cluster for you in a Docker
container using the Kubernetes-in-Docker (KIND) tool.

NKP deploys all cluster lifecycle services to a bootstrap cluster, which
deploys a managed cluster. When the workload cluster is ready, move the
cluster lifecycle services to the managed cluster. The managed cluster then
manages its own lifecycle.

Prerequisites:

Before you begin, you must:

- Complete the steps in Prerequisites.
- Ensure the nkp binary can be found in your $PATH.
- If using a Registry Mirror even though you are not in an air-gapped
  environment, refer to the air-gapped section for loading images: Pre-
  provisioned Air-gapped Define Environment

Bootstrap Cluster Lifecycle Services

Procedure

1. Review Universal Configurations for all Infrastructure Providers regarding
   settings, flags, and other choices and then begin bootstrapping.
2. Create a bootstrap cluster using the command nkp create bootstrap
   --kubeconfig $HOME/.kube/

config.

```yaml
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

Example output:

```bash
# Creating a bootstrap cluster
# Initializing new CAPI components
```

To create a bootstrap cluster in a proxied environment (Bootstrap Cluster HTTP
Proxy Settings on page 697), in addition to any other flags you need, run the
following command.

```bash
--http-proxy <string> \
--https-proxy <string> \
--no-proxy <string>
```

1. NKP creates a bootstrap cluster using KIND as a library.

For more information, see `<https://github.com/kubernetes-sigs/kind>`. 4. NKP
then deploys the following Cluster API providers on the cluster.

- Core Provider: `<https://github.com/kubernetes-sigs/cluster-api/tree/v0.3.20/>`
- AWS Infrastructure Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api-provider-aws>
- Kubeadm Bootstrap Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api/tree/v0.3.20/bootstrap/> kubeadm
- Kubeadm ControlPlane Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api/tree/v0.3.20/> controlplane/kubeadm

For more information on Cluster APIs, see `<https://cluster-api.sigs.k8s.io/>`. 5. NKP waits until these providers' controller-manager and webhook deployments
are ready. List these deployments using the command kubectl get --all-
namespaces deployments -l=clusterctl.cluster.x- k8s.io. Example output:

```bash
NAMESPACE NAME
READY UP-TO-DATE AVAILABLE AGE
capa-system capa-controller-manager
1/1 1 1 1h
capg-system capg-controller-manager
1/1 1 1 1h
capi-kubeadm-bootstrap-system capi-kubeadm-bootstrap-controller-manager
1/1 1 1 1h
capi-kubeadm-control-plane-system capi-kubeadm-control-plane-controller-manager
1/1 1 1 1h
capi-system capi-controller-manager
1/1 1 1 1h
cappp-system cappp-controller-manager
1/1 1 1 1h
capv-system capv-controller-manager
1/1 1 1 1h
capz-system capz-controller-manager
1/1 1 1 1h
cert-manager cert-manager
1/1 1 1 1h
cert-manager cert-manager-cainjector
1/1 1 1 1h
cert-manager cert-manager-webhook
1/1 1 1 1h
```

#### Pre-provisioned Non-Air-gapped: Creating a New Cluster

About this task

After defining the infrastructure and control plane endpoints, you can create
the cluster by following these steps to create a new pre-provisioned cluster.

Before you create a new Nutanix Kubernetes Platform (NKP) cluster below, you
may choose an external load balancer or virtual IP and use the corresponding
nkp create cluster command example from that page in the docs from the links
below. Other customizations are available but require different flags during
the nkp create cluster command. Refer to Pre-provisioned Cluster Creation
Customization Choices for more cluster customizations.

```yaml
Warning: NKP uses a local static provisioner as the default storage provider for a pre-provisioned environment.
However, localvolumeprovisioner is not suitable for production use. Use Kubernetes CSI compatible
storage that is suitable for production.
```

After turning off localvolumeprovisioner, you can choose from any of the
storage options available for Kubernetes. To make that storage the default
storage, use the commands in this section of the Kubernetes documentation:
Changing the Default Storage Class

> **Note:**

- When creating the cluster, specify the cluster-name. Using the same cluster-
  name used when defining your inventory objects would be best. See topic
  Defining Cluster Hosts and Infrastructure for more details.
- Ensure your subnets do not overlap with your host subnet because they cannot
  be changed after cluster creation. If you need to change the Kubernetes
  subnets, you must do this at cluster creation. See the topic Subnets.
- The default subnets used in NKP are:

```bash
spec:
clusterNetwork:
pods:
cidrBlocks:
- 192.168.0.0/16
services:
cidrBlocks:
- 10.96.0.0/12
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by setting
the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

First you must name your cluster. Then you run the command to deploy it. When
specifying the cluster-name, you must use the same cluster-name as used when
defining your inventory objects.

Procedure

1. Give your cluster a unique name suitable for your environment.

```yaml
Note: The cluster name may only contain the following characters: a-z, 0-9, and -. Cluster creation will fail if the
name has capital letters. See Kubernetes for more naming information.
```

1. Set the environment variable: export CLUSTER_NAME=`<cluster_name>`

What to do next

Create a Kubernetes Cluster

When you create a new NKP cluster below, choose an external load balancer (LB)
or virtual IP and use the corresponding nkp create cluster command.

In a pre-provisioned environment, use the Kubernetes CSI and third-party
drivers for local volumes and other storage devices in your datacenter.

For Pre-provisioned environments, you define a set of existing nodes. During
the cluster creation process, Nutanix Image Builder (NIB) is built into NKP
and automatically runs the machine configuration process (which NIB uses to
build images for other providers) against the set of nodes that you defined.
This results in your pre-existing or pre- provisioned nodes being
appropriately configured.

##### Generate the Kubernetes cluster objects

About this task

The following command relies on the pre-provisioned cluster API infrastructure
provider to initialize the Kubernetes control plane and worker nodes on the
hosts defined in the inventory. It uses the default external load balancer.

- 1. (Optional) If you have overrides for your clusters, specify the secret as
     part of the create cluster command. If these are not specified, the
     overrides for your nodes will not be applied.

--override-secret-name=$CLUSTER_NAME-user-overrides 2. (Optional) Use a
registry mirror. Configure your cluster to use an existing local registry as a
mirror when attempting to pull images previously pushed to your registry when
defining your infrastructure. Instructions in the expandable Custom
Installation section. For registry mirror information, see topics Using a
Registry Mirror and Registry Mirror Tools.

Export Registry Variables and Flags for Cluster Creation:: If you have a local
registry, you must provide additional arguments when creating the cluster.
These tell the cluster where to locate the local registry to use by defining
the URL. Set the needed environment variable(s) with your registry
information:

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
  Konvoy will configure the cluster nodes to trust this CA. This value is only
  needed if the registry is using a self-signed certificate and the AMIs are
  not already configured to trust this CA.
- REGISTRY_USERNAME: optional, set to a user that has pull access to this
  registry.
- REGISTRY_PASSWORD: optional if username is not set.

When creating the cluster, apply the variables you defined above during the
dkp create cluster command with the flags needed for your environment:

```bash
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-cacert=${REGISTRY_CA} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD}
```

Procedure

1. Create cluster command - Depending on the cluster size, it will take a few
   minutes to create the Kubernetes cluster objects:

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host <control plane endpoint host> \
--control-plane-endpoint-port <control plane endpoint port, if different than 6443>
\
--override-secret-name=$CLUSTER_NAME-user-overrides \
--dry-run \
--output=yaml \
> ${CLUSTER_NAME}.yaml
```

a. ALTERNATIVE Virtual IP - if you do not have an external LB and want to use
a VIRTUAL IP provided by

kube-vip, specify these flags example below:

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host 196.168.1.10 \
--virtual-ip-interface eth1 \
--dry-run \
--output=yaml \
> ${CLUSTER_NAME}.yaml
```

Configuring an HTTP or HTTPS Proxy on page 696

FIPS Requirements on page 710

Output Directory Flag on page 710 2. Inspect or edit the cluster objects and
familiarize yourself with Cluster API
before editing the cluster objects as edits can prevent the cluster from
deploying successfully. Familiarize yourself
with Cluster API before editing the cluster objects as edits can prevent the
cluster from deploying successfully. 3.
Create the cluster from the objects generated in the dry run. A warning will
appear in the console if the resource
already exists and will require you to remove the resource or update your YAML.

```bash
kubectl create -f ${CLUSTER_NAME}.yaml
Note: If you used the --output-directory flag in your nkp create .. --dry-run step above, create
the cluster from the objects you created by specifying the directory.
kubectl create -f <existing-directory>/
```

1. Use the wait command to monitor the cluster control-plane readiness:

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=30m
```

Output:

```bash
cluster.cluster.x-k8s.io/cluster_name condition met
```

> **Note: It will take a few minutes to create, depending on the cluster
> size.** 5. After the creation, use this command to get the Kubernetes
> kubeconfig for the new cluster and begin deploying workloads:

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
```

Azure requires changing the CNI encapsulation type of Calico from the default
of IPtoIP to VXlan. If changing the Calico encapsulation, Nutanix recommends
changing it after cluster creation, but before production.

Audit Logs

To modify Control Plane Audit logs settings using the information on the page
Configure the Control Plane.

#### Pre-provisioned Non-Air-gapped: Making the New Cluster Self-Managed

About this task

Nutanix Kubernetes Platform (NKP) deploys all cluster life cycle services to a
bootstrap cluster, which then deploys a managed cluster. When the managed
cluster is ready, move the cluster life cycle services to the workload
cluster, which makes the managed cluster self-managed.

This page contains instructions on how to make your cluster self-managed. This
is necessary if there is only one cluster in your environment or if this
cluster becomes the Management cluster in a multi-cluster environment.

> **Note: If you already have a self-managed or Management cluster in your
> environment, skip this page.**

Before you begin

Before starting, ensure you can create a managed cluster as described in the
topic: Create a New Pre-provisioned Cluster.

Follow these steps to turn your new cluster into a Management Cluster for an
Ultimate license environment (or a free-standing Pro Cluster):

If you have not already retrieved the kubeconfig after creating the cluster,
use this command before proceeding: nkp get kubeconfig -c ${CLUSTER_NAME} >
${CLUSTER_NAME}.conf

Procedure

1. Deploy cluster life cycle services on the managed cluster.

```bash
nkp create capi-components --kubeconfig ${CLUSTER_NAME}.conf
```

Output:

```bash
# Initializing new CAPI components (2)
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

1. Move the Cluster API objects from the bootstrap to the managed cluster: The
   cluster life cycle services on the managed cluster are ready, but the
   managed cluster configuration is on the bootstrap cluster. The move command
   moves the configuration, which takes the form of Cluster API Custom Resource
   objects, from the bootstrap to the managed cluster. This process is called a
   Pivot. For more information, see `<<https://cluster->`
   api.sigs.k8s.io/reference/glossary.html?highlight=pivot#pivot>.

```bash
unset KUBECONFIG
```

Next:

```bash
nkp move capi-resources --to-kubeconfig ${CLUSTER_NAME}.conf
```

Output:

```bash
# Moving cluster resources
You can now view resources in the moved cluster by using the --kubeconfig flag with
kubectl. For example: kubectl --kubeconfig=gcp-example.conf get nodes
Note: To ensure only one set of cluster life cycle services manages the managed cluster, NKP first pauses the
reconciliation of the objects on the bootstrap cluster, then creates the objects on the managed cluster. As NKP
copies the objects, the cluster life cycle services on the managed cluster reconcile the objects. The managed cluster
becomes self-managed after NKP creates all the objects. If it fails, the move command can be safely retried.
```

1. Wait for the cluster control plane to be ready.

```bash
kubectl --kubeconfig ${CLUSTER_NAME}.conf wait --for=condition=Available=True
"clusters/${CLUSTER_NAME}" --timeout=20m
```

Output:

```bash
cluster.cluster.x-k8s.io/gcp-example condition met
```

1. Use the cluster life cycle services on the managed cluster to check the
   managed cluster status.

```yaml
Note: After moving the cluster life cycle services to the managed cluster, remember to use NKP with the managed
cluster kubeconfig.
nkp describe cluster --kubeconfig ${CLUSTER_NAME}.conf -c ${CLUSTER_NAME}
```

Output:

```bash
NAME READY
SEVERITY REASON SINCE MESSAGE
Cluster/cluster_name True
2m31s
##ClusterInfrastructure - PreprovisionedCluster/cluster_name

##ControlPlane - KubeadmControlPlane/cluster_name-control-plane True
2m31s
# ##Machine/cluster_name-control-plane-6g6nr True
2m33s
# ##Machine/cluster_name-control-plane-8lhcv True
2m33s
# ##Machine/cluster_name-control-plane-kk2kg True
2m33s
##Workers

##MachineDeployment/cluster_name-md-0 True
2m34s
##Machine/cluster_name-md-0-77f667cd9-tnctd True
2m33s
```

1. Remove the bootstrap cluster because the managed cluster is now self-managed.

```bash
nkp delete bootstrap --kubeconfig $HOME/.kube/config
```

Output:

```bash
# Deleting bootstrap cluster
```

##### Known Limitations

Procedure

- NKP only supports moving all namespaces in the cluster; NKP does not support
  migration of individual namespaces.
- Konvoy supports moving only one set of cluster objects from the bootstrap
  cluster to the managed cluster or vice- versa.

#### Pre-provisioned Non-Air-gapped: Installing Kommander

About this task

Once you have installed the Konvoy component of Nutanix Kubernetes Platform
(NKP), you will continue installing the Kommander component that will bring up
the UI dashboard.

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

- Ensure you have reviewed all Nutanix Kubernetes Platform Requirements on
  page 45.
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
   ships Ceph with PersistentVolumeClaim (PVC) based storage, which requires
   your
   CSI provider to support PVC with type
   volumeMode: Block. As this is impossible with the default local static
   provisioner, you can install Ceph in host storage
   mode. You can choose whether Ceph's object storage daemon (osd) pods can
   consume all or just some of the devices on your
   nodes. Include one of the following Overrides.

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

1. If required: Customize your kommander.yaml.

See Kommander Customizations on page 996 page for customization options. Some
options include Custom Domains and Certificates, HTTP proxy, External Load
Balancer, GPU Utilization, and Rook Ceph customization for Pre-provisioned
environments. 6. If required: If your cluster uses a custom AWS VPC and
requires an internal load-balancer, set the traefik annotation to create an
internal-facing ELB:

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

1. Expand one of the following sets of instructions, depending on your license
   and application environments:

» Pro License: Install Kommander in a Pre-provisioned, Non-Air-Gapped
Environment .

Pro License: Install Kommander

Use the customized kommander.yaml to install NKP:

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

Kommander Customizations

You can configure the Kommander component of NKP during the initial
installation, and also post-installation using the NKP CLI. If you are not
sure of what you want to customize during install, then proceed to the next
step. To read about Kommander component customization options, refer to this
section of the documentation: Kommander Customizations on page 996

#### Pre-provisioned Non-Air-gapped: Verifying the Kommander Install and UI

Log in

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

##### Failed HelmReleases

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

###### Log in to the UI

Procedure

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

After installing Konvoy component and building a cluster as well as
successfully installing Kommander and logging into
the UI, you are now ready to customize configurations using the Day 2 Cluster
Operations Management section of the
documentation. The majority of this customization such as attaching clusters
and deploying applications will take place
in the dashboard or UI of NKP. The Day 2 section allows you to manage cluster
operations and their application workloads
to optimize your organization's productivity.

### Pre-provisioned Installation in an Air-gapped Environment

In pre-provisioned environments, Nutanix Kubernetes Platform (NKP) handles
your cluster's life cycle, including installation, upgrade, and node
management. NKP installs Kubernetes, monitoring and logging apps, and its UI.

In an environment with access to the Internet, you retrieve artifacts from
specialized repositories dedicated to them, such as Docker images contained in
DockerHub and Helm Charts that come from a dedicated Helm Chart repository.
However, in an air-gapped environment, you need local repositories to store
Helm charts, Docker images, and other artifacts. Tools such as JFrog, Harbor,
and Nexus handle multiple types of artifacts in one local repository.

Follow these steps to deploy NKP in a Pre-provisioned, Non-air-gapped
environment:

#### Pre-provisioned Air-gapped: Prerequisites

About this task

Nutanix Kubernetes Platform (NKP) in an air-gapped environment requires a
local container registry of trusted images to enable production-level
Kubernetes cluster management. In an environment with access to the internet,
you retrieve artifacts from specialized repositories dedicated to them, such
as Docker images contained in DockerHub and Helm Charts that come from a
dedicated Helm Chart repository. However, in an air-gapped environment, you
need:

Before you begin

- Local repositories to store Helm charts, Docker images, and other artifacts.
  Tools such as ECR, jFrog, Harbor, and Nexus handle multiple types of
  artifacts in one local repository.
- Bastion Host - If you have not set up a Bastion Host yet, refer to that
  Documentation section.
- The complete NKP air-gapped bundle, which contains all the NKP components
  needed for an air-gapped environment installation and also to use a local
  registry in a non-air-gapped environment: Pre-provisioned Loading the
  Registry

Copy Air-gapped Artifacts onto Cluster Hosts

Procedure

1. Set the Artifacts directory.

The artifacts directory contains the packages and artifacts required to
configure the pre-provisioned host. 2. Download nkp-air-gapped-bundle_nkp-
version_linux_amd64.tar.gz, and extract the tar file to a local directory.

```bash
tar -xzvf nkp-air-gapped-bundle_nkp-version_linux_amd64.tar.gz -C
${ARTIFACTS_DIRECTORY}
```

1. Export the following environment variables, ensuring that all control plane
   and worker nodes are included.

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
directory. 4. (Optional) Create a FIPS-compliant image:

```bash
export FIPS_ENABLED=true
```

The Nutanix Image Builder creates a FIPS-compliant OS image. For more
information, see Supported Infrastructure Operating Systems. 5. (Optional)
Upload NVIDIA GPU drivers:

Download the NVIDIA runfile for your NVIDIA driver version from the NVIDIA
download site.

Replace Path to NVIDIA driver runfile with the path to the NVIDIA driver
runfile.

The Nutanix Image Builder uploads the NVIDIA driver runfile to the target host
for GPU workload support.

| export ARTIFACTS DIRECTORY=nkp- \_ | nkp-version | /image-artifacts/ |
| ---------------------------------- | ----------- | ----------------- |

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

| export NVIDIA RUNFILE= \_ | Path to NVIDIA driver runfile | Col3 |
| ------------------------- | ----------------------------- | ---- |

1. (Optional) Specify a provider hint:

Replace aws|azure|gcp|vsphere|nutanix with the provider name when you install
provider specific utilities.

This helps the image builder install the appropriate provider specific
utilities on the host. 7. Upload the artifacts onto cluster hosts with the
following command.

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

#### Pre-provisioned Air-gapped: GPU-only Steps

```yaml
Note: If the NVIDIA runfile installer has not been downloaded, then retrieve and install the download first by running
the following command. The first line in the command below downloads the runfile, the second saves the runfile and
the third line places it in the artifacts directory.
curl -O https://download.nvidia.com/XFree86/Linux-x86_64/580.126.18/NVIDIA-Linux-
x86_64-580.126.18.run
mv NVIDIA-Linux-x86_64-580.126.18.run artifacts
```

1. Create an inventory for GPU Nodes.

```bash
cat <<EOF > gpu_inventory.yaml
all:
vars:
ansible_port: 22
ansible_ssh_private_key_file: $SSH_PRIVATE_KEY_FILE
ansible_user: $SSH_USER
hosts:
$GPU_WORKER_1_ADDRESS:
ansible_host: $GPU_WORKER_1_ADDRESS
EOF
```

1. Save the gpu_inventory.yaml file in the ./image-artifacts/ directory
2. Upload the gpu_inventory.yaml, along with the bundle artifacts to the gpu
   nodepool with the nvidia- runfile flag. If you have more than one node in
   the nodepool, you must comma-separate your hosts. For example, -- ssh-
   host='`<vm-ip-address-1>`','`<vm-ip-address-2>`','`<vm-ip-address-3>`'):

```bash
./nkp upload image-artifacts \
--artifacts-directory=./image-artifacts/ \
--ssh-host='<vm-ip-address-1>' \
--ssh-username=<ssh-username> \
--ssh-private-key-file=<ssh_key> \
--nvidia-runfile=./image-artifacts/NVIDIA-Linux-x86_64-580.126.18.run
```

#### Pre-provisioned Air-gapped: Bootstrapping Air-gapped Pre-provisioned

| export PROVIDER= | aws | azure | gcp | vsphere | nutanix | Col3 |
| ---------------- | --- | ----- | --- | ------- | ------- | ---- |

About this task

Konvoy deploys all cluster lifecycle services to a bootstrap cluster, which
deploys a managed cluster. When the managed cluster is ready, move the cluster
lifecycle services to the managed cluster. The managed cluster then manages
its own lifecycle.

To create Kubernetes clusters, Konvoy uses Cluster API (CAPI) controllers.
These controllers run on a Kubernetes cluster. To get started, you need a
bootstrap cluster. By default, Konvoy creates a bootstrap cluster for you in a
Docker container using the Kubernetes-in-Docker (KIND) tool.

Prerequisites:

Before you begin, you must:

- Complete the Nutanix Infrastructure Prerequisites. For more information, see
  Nutanix Infrastructure Requirements on page 719.
- Ensure the nkp binary can be found in your $PATH.
- If using a Registry Mirror even though you are not in an air-gapped
  environment, refer to the air-gapped section for loading images: Pre-
  provisioned Air-gapped Define Environment

Bootstrap Cluster Lifecycle Services

Procedure

1. Review Universal Configurations for all Infrastructure Providers regarding
   settings, flags, and other choices and then begin bootstrapping.
2. Create a bootstrap cluster using the command.

```bash
nkp create bootstrap --kubeconfig $HOME/.kube/config
```

Output:

```bash
# Creating a bootstrap cluster (2)
# Initializing new CAPI components (3)
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

To create a bootstrap cluster in a proxied environment (Bootstrap Cluster HTTP
Proxy Settings on page 697), in addition to any other flags you need, run the
following command.

```bash
--http-proxy <string> \
--https-proxy <string> \
--no-proxy <string>
```

NKP creates a bootstrap cluster using KIND as a library and deploys Cluster
API providers on the cluster. 3. NKP waits until these providers' controller-
manager and webhook deployments are ready. List these deployments using the
command kubectl get --all-namespaces deployments -l=clusterctl.cluster.x-
k8s.io. Output example:

```bash
NAMESPACE NAME
READY UP-TO-DATE AVAILABLE AGE
capa-system capa-controller-manager
1/1 1 1 1h
capg-system capg-controller-manager
1/1 1 1 1h
capi-kubeadm-bootstrap-system capi-kubeadm-bootstrap-controller-manager
1/1 1 1 1h
capi-kubeadm-control-plane-system capi-kubeadm-control-plane-controller-manager
1/1 1 1 1h
capi-system capi-controller-manager
1/1 1 1 1h
cappp-system cappp-controller-manager
1/1 1 1 1h
capv-system capv-controller-manager
1/1 1 1 1h
capz-system capz-controller-manager
1/1 1 1 1h
cert-manager cert-manager
1/1 1 1 1h
cert-manager cert-manager-cainjector
1/1 1 1 1h
cert-manager cert-manager-webhook
1/1 1 1 1h
```

1. NKP then deploys the following Cluster API providers on the cluster.

- Core Provider: `<https://github.com/kubernetes-sigs/cluster-api/tree/v0.3.20/>`
- AWS Infrastructure Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api-provider-aws>
- Kubeadm Bootstrap Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api/tree/v0.3.20/bootstrap/> kubeadm
- Kubeadm ControlPlane Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api/tree/v0.3.20/> controlplane/kubeadm

For more information on Cluster APIs, see `<https://cluster-api.sigs.k8s.io/>`.

#### Pre-provisioned Air-gapped: Creating a New Cluster

About this task

Before you create a new Nutanix Kubernetes Platform (NKP) cluster below, you
may choose an external load balancer or virtual IP and use the corresponding
nkp create cluster command example from that page in the docs from the links
below. Other customizations are available but require different flags during
the nkp create cluster command. Refer to Pre-provisioned Cluster Creation
Customization Choices for more cluster customizations.

First you must name your cluster. Then you run the command to deploy it. When
specifying the cluster-name, you must use the same cluster-name as used when
defining your inventory objects.

Procedure

1. Give your cluster a unique name suitable for your environment.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the environment variable:
export CLUSTER_NAME=`<cluster_name>`

```yaml
Warning: When you create a new NKP cluster below, choose an external load balancer (LB) or virtual IP and use
the corresponding nkp create cluster command.
```

What to do next

Create a Kubernetes Cluster

After defining the infrastructure and control plane endpoints, you can create
the cluster by following these steps to create a new pre-provisioned cluster.

```yaml
Warning: NKP uses a localvolumeprovisioner as the default storage provider for a pre-provisioned
environment. However, localvolumeprovisioner is not suitable for production use. Use Kubernetes CSI
compatible storage that is suitable for production.
```

After disabling localvolumeprovisioner, you can choose from any of the storage
options available for Kubernetes. To make that storage the default storage,
use the commands in this section of the Kubernetes documentation: Changing the
Default Storage Class

For Pre-provisioned environments, you define a set of existing nodes. During
the cluster creation process, Nutanix Image Builder on page 51 (NIB) is built
into NKP and automatically runs the machine configuration process (which NIB
uses to build images for other providers) against the set of nodes you
defined. This results in your pre-existing or pre-provisioned nodes being
appropriately configured.

The following command relies on the pre-provisioned cluster API infrastructure
provider to initialize the Kubernetes control plane and worker nodes on the
hosts defined in the inventory.

```yaml
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by setting
the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

Ensure your subnets do not overlap with your host subnet because they cannot
be changed after cluster creation. If you need to change the Kubernetes
subnets, you must do this at cluster creation. See the topic Subnets. The
default subnets used in NKP are:

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

Create cluster command - Depending on the cluster size, it will take a few
minutes to create:

This command uses the default external load balancer (LB) option (see
alternative Step 1 for virtual IP):

```yaml
Note: (Optional) If you have overrides for your clusters, specify the secret in the create cluster command. If these are
not specified, the overrides for your nodes will not be applied.--override-secret-name=$CLUSTER_NAME-
user-overrides.
nkp create cluster preprovisioned --cluster-name ${CLUSTER_NAME}
--control-plane-endpoint-host <control plane endpoint host>
--control-plane-endpoint-port <control plane endpoint port, if different than 6443>
--pre-provisioned-inventory-file preprovisioned_inventory.yaml
--ssh-private-key-file <path-to-ssh-private-key>
--registry-mirror-url=${REGISTRY_URL} \
--dry-run \
--output=yaml \
> ${CLUSTER_NAME}.yaml
```

1. ALTERNATIVE Virtual IP - if you do not have an external LB and want to use
   a VIRTUAL IP provided by

kube-vip, specify these flags example below:

```bash
nkp create cluster preprovisioned \
--cluster-name ${CLUSTER_NAME} \
--control-plane-endpoint-host 196.168.1.10 \
--virtual-ip-interface eth1 \
--dry-run \
--output=yaml \
> ${CLUSTER_NAME}.yaml
```

Configuring an HTTP or HTTPS Proxy on page 696

Export Registry Variables and Flags for Cluster Creation on page 709

FIPS Requirements on page 710

Output Directory Flag on page 710 2. Inspect or edit the cluster objects and
familiarize yourself with Cluster API before editing them, as edits can
prevent the cluster from deploying successfully.

Familiarize yourself with Cluster API before editing the cluster objects as
edits can prevent the cluster from deploying successfully. 3. Create the
cluster from the objects generated in the dry run. A warning will appear in
the console if the resource already exists, requiring you to remove the
resource or update your YAML.

```bash
kubectl create -f ${CLUSTER_NAME}.yaml
Note: If you used the --output-directory flag in your nkp create .. --dry-run step above, create
the cluster from the objects you created by specifying the directory:
kubectl create -f <existing-directory>/
```

1. Use the wait command to monitor the cluster control-plane readiness:

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=30m
```

Output:

```bash
cluster.cluster.x-k8s.io/cluster_name condition met
```

> **Note: It will take a few minutes to create, depending on the cluster size.**

When the command completes complete, you will have a running Kubernetes
cluster! For bootstrap and custom YAML cluster creation, refer to the
Additional Infrastructure Customization section of the documentation for Pre-
provisioned Pre-provisioned Infrastructure

Use this command to get the Kubernetes kubeconfig for the new cluster and
proceed to install the NKP Kommander UI:

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
Note: Azure requires changing the CNI encapsulation type of Calico from the default of IPtoIP to VXlan. If changing
the Calico encapsulation, Nutanix recommends changing it after cluster creation, but before production.
```

Audit Logs To modify Control Plane Audit logs settings using the information
contained in the page Configure the Control Plane.

Cluster Verification If you want to monitor or verify the installation of your
clusters, refer to: Cluster and NKP Installation Verification on page 1039 and
Installing NKP on page 43.

#### Pre-provisioned Air-gapped: Making the New Cluster Self-Managed

About this task

Nutanix Kubernetes Platform (NKP) deploys all cluster life cycle services to a
bootstrap cluster, which then deploys a managed cluster. When the managed
cluster is ready, move the cluster life cycle services to the workload
cluster, which makes the managed cluster self-managed.

Before you begin

Before starting, ensure you can create a managed cluster as described in the
topic: Create a New Pre-provisioned Cluster.

This page contains instructions on how to make your cluster self-managed. This
is necessary if there is only one cluster in your environment or if this
cluster becomes the Management cluster in a multi-cluster environment.

> **Note: If you already have a self-managed or Management cluster in your
> environment, skip this page.**

Make the New Kubernetes Cluster Manage Itself

Follow these steps to turn your new cluster into a Management Cluster for an
Ultimate license environment (or a free-standing Pro Cluster):

> **Note: If you have not already retrieved the kubeconfig after creating
> the cluster, use this command before proceeding:**

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
```

Procedure

1. Deploy cluster life cycle services on the managed cluster.

```bash
nkp create capi-components --kubeconfig ${CLUSTER_NAME}.conf
```

Output:

```bash
# Initializing new CAPI components (4)
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

1. Move the Cluster API objects from the bootstrap to the managed cluster. The
   cluster life cycle services on the
   managed cluster are ready, but the managed cluster configuration is on the
   bootstrap cluster. The move command moves the
   configuration, which takes the form of Cluster API Custom Resource objects,
   from the bootstrap to the managed cluster.
   This process is called a Pivot. For more information, see `<<https://cluster->`
   api.sigs.k8s.io/reference/glossary.html?highlight=pivot#pivot>. First unset
   the kubeconfig and then move the CAPI:

```bash
unset KUBECONFIG
nkp move capi-resources --to-kubeconfig ${CLUSTER_NAME}.conf
```

Output:

```bash
# Moving cluster resources (2)
You can now view resources in the moved cluster by using the --kubeconfig flag with
kubectl. For example: kubectl --kubeconfig=gcp-example.conf get nodes
Note: To ensure only one set of cluster life cycle services manages the managed cluster, NKP first pauses the
reconciliation of the objects on the bootstrap cluster, then creates the objects on the managed cluster. As NKP
```

copies the objects, the cluster life cycle services on the managed cluster
reconcile the objects. The managed cluster becomes self-managed after NKP
creates all the objects. If it fails, the move command can be safely retried. 3. Wait for the cluster control-plane to be ready.

```bash
kubectl --kubeconfig ${CLUSTER_NAME}.conf wait --for=condition=Available=True
"clusters/${CLUSTER_NAME}" --timeout=20m
```

Output:

```bash
cluster.cluster.x-k8s.io/gcp-example condition met
```

1. Use the cluster life cycle services on the managed cluster to check the
   managed cluster status.

```yaml
Note: After moving the cluster life cycle services to the managed cluster, remember to use NKP with the managed
cluster kubeconfig.
nkp describe cluster --kubeconfig ${CLUSTER_NAME}.conf -c ${CLUSTER_NAME}
```

Output:

```bash
NAME READY
SEVERITY REASON SINCE MESSAGE
Cluster/cluster_name True
2m31s
##ClusterInfrastructure - PreprovisionedCluster/cluster_name

##ControlPlane - KubeadmControlPlane/cluster_name-control-plane True
2m31s
# ##Machine/cluster_name-control-plane-6g6nr True (2)
2m33s
# ##Machine/cluster_name-control-plane-8lhcv True (2)
2m33s
# ##Machine/cluster_name-control-plane-kk2kg True (2)
2m33s
##Workers

##MachineDeployment/cluster_name-md-0 True
2m34s
##Machine/cluster_name-md-0-77f667cd9-tnctd True
2m33s
```

1. Remove the bootstrap cluster because the managed cluster is now self-managed.

```bash
nkp delete bootstrap --kubeconfig $HOME/.kube/config
```

Output:

```bash
# Deleting bootstrap cluster (2)
```

##### Known Limitations (2)

Procedure

- NKP only supports moving all namespaces in the cluster; NKP does not support
  migration of individual namespaces.
- Konvoy supports moving only one set of cluster objects from the bootstrap
  cluster to the managed cluster or vice- versa.

#### Pre-provisioned Air-gapped: Installing Kommander

About this task

Once you have installed the Konvoy component of Nutanix Kubernetes Platform
(NKP), you will continue installing the Kommander component that will bring up
the UI dashboard.

Prerequisites:

- Ensure you have reviewed all Prerequisites for Install.
- Ensure you have a Default StorageClass on page 980.
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
nkp get kubeconfig -c ${CLUSTER_NAME} >> $ {CLUSTER_NAME}.conf
```

1. Create a configuration file for the deployment.

```bash
nkp install kommander --init --airgapped > kommander.yaml
```

1. If required: Customize your kommander.yaml. See the Kommander
   Customizations page for customization options. Some options include Custom
   Domains and Certificates, HTTP proxy, External Load Balancer, GPU
   utilization, Rook Ceph customization for Pre-provisioned environments, and
   so on.
2. If required: If your cluster uses a custom AWS VPC and requires an internal
   load-balancer, set the traefik annotation to create an internal-facing ELB:

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

1. Expand one of the following sets of instructions, depending on your license
   and application environments:

» Pro License: Install Kommander in a Pre-provisioned, air-Gapped Environment.

Use the customized kommander.yaml to install NKP:

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf \
--kommander-applications-repository ./application-repositories/kommander-
applications-nkp-version.tar.gz
```

» Ultimate License: Install Kommander in a Pre-provisioned, air-gapped
Environment.

Use the customized kommander.yaml to install NKP:

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf \
--kommander-applications-repository ./application-repositories/kommander-
applications-nkp-version.tar.gz
```

Kommander Customizations

You can configure the Kommander component of NKP during the initial
installation, and also post-installation using the NKP CLI. If you are not
sure of what you want to customize during install, then proceed to the next
step. To read about Kommander component customization options, refer to this
section of the documentation: Kommander Customizations on page 996

#### Pre-provisioned Air-gapped: Verifying the Install and UI Log in

About this task

After you build the Konvoy cluster and you install the Kommander component for
the UI, you can verify your installation. It waits for all applications to be
ready by default.

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

After installing Konvoy component and building a cluster as well as
successfully installing Kommander and logging into
the UI, you are now ready to customize configurations using the Day 2 Cluster
Operations Management section of the
documentation. The majority of this customization such as attaching clusters
and deploying applications will take place
in the dashboard or UI of NKP. The Day 2 section allows you to manage cluster
operations and their application workloads
to optimize your organization's productivity.

### Pre-Provisioned Management Tools

After cluster creation and configuration, you can revisit clusters to update
and change variables.

You can manage or delete a pre-provisioned cluster. You can also manage the
pre-provisioned node pools through the steps listed in the following topics.

#### Pre-provisioned: Deleting a Cluster

About this task

```yaml
Note: A self-managed managed cluster cannot delete itself. If your managed cluster is self-managed, you must first
create a bootstrap cluster and move the cluster life cycle services to it before deleting the managed cluster.
```

Procedure

If you did not make your managed cluster self-managed, as described in Make
New Cluster Self-Managed, proceed to the instructions for Delete the managed
cluster.

##### Creating a Bootstrap Cluster and Move CAPI Resources

About this task

Follow these steps to create a bootstrap cluster and move CAPI resources:

Procedure

1. Create a bootstrap cluster. The bootstrap cluster will host the Cluster API
   controllers that reconcile the cluster objects marked for deletion.

> **Note: To avoid using the wrong kubeconfig, the following steps use
> explicit kubeconfig paths and contexts.**

```bash
nkp create bootstrap --kubeconfig $HOME/.kube/config
# Creating a bootstrap cluster (3)
# Initializing new CAPI components (5)
```

1. Move the Cluster API objects from the workload to the bootstrap cluster:
   The cluster life cycle services on the bootstrap cluster are ready, but the
   managed cluster configuration is on the managed cluster. The move command
   moves the configuration, which takes the form of Cluster API Custom Resource
   objects, from the workload to the bootstrap cluster. This process is also
   called a Pivot.

```bash
nkp move capi-resources \
--from-kubeconfig ${CLUSTER_NAME}.conf \
--from-context ${CLUSTER_NAME}-admin@${CLUSTER_NAME} \
--to-kubeconfig $HOME/.kube/config \
--to-context kind-konvoy-capi-bootstrapper
```

Output:

```bash
# Moving cluster resources (3)
You can now view resources in the moved cluster by using the --kubeconfig flag with
kubectl. For example: kubectl --kubeconfig $HOME/.kube/config get nodes
```

1. Use the cluster life cycle services on the managed cluster to check the
   managed cluster's status.

```bash
nkp describe cluster --kubeconfig $HOME/.kube/config -c ${CLUSTER_NAME}
```

Output:

```bash
NAME READY
SEVERITY REASON SINCE MESSAGE
Cluster/cluster_name True
2m31s
##ClusterInfrastructure - PreprovisionedCluster/cluster_name

##ControlPlane - KubeadmControlPlane/cluster_name-control-plane True
2m31s
# ##Machine/cluster_name-control-plane-6g6nr True (3)
2m33s
# ##Machine/cluster_name-control-plane-8lhcv True (3)
2m33s
# ##Machine/cluster_name-control-plane-kk2kg True (3)
2m33s
##Workers

##MachineDeployment/cluster_name-md-0 True
2m34s
##Machine/cluster_name-md-0-77f667cd9-tnctd True
2m33s
Note: After moving the cluster lifecycle services to the managed cluster, remember to use nkp with the managed
cluster kubeconfig.
```

1. Wait for the cluster control-plane to be ready. Run the command below and
   wait for the condition to be met:

```bash
kubectl --kubeconfig $HOME/.kube/config wait --for=condition=controlplaneready
"clusters/${CLUSTER_NAME}" --timeout=20m
```

Output:

```bash
cluster.cluster.x-k8s.io/cluster_name condition met
```

Persistent Volumes (PVs) are not deleted automatically by design in order to
preserve your data. However, they take up storage space if not deleted. You
must delete PVs manually. Information for backup of a cluster and PVs is on
the page in documentation called Back up your Cluster's Applications and
Persistent Volumes. See Cluster Applications and Persistent Volumes Backup on
page 521.

###### Deleting the Workload Cluster

About this task

If you have a need to remove the Kubernetes cluster, such as for environment
cleanup, use this command to delete the provisioned Kubernetes cluster.

Procedure

1. To delete a cluster, Use nkp delete cluster and pass in the name of the
   cluster you are trying to delete with --cluster-name flag. Use kubectl get
   clusters to get those details (--cluster-name and -- namespace) of the
   Kubernetes cluster to delete it.

```yaml
Note: Do not use nkp get clusters since that gets you NKP cluster details rather than Konvoy Kubernetes
cluster details.
kubectl get nkpclusters
```

1. Delete the Kubernetes cluster and wait a few minutes.

```yaml
Note: Before deleting the cluster, Nutanix Kubernetes Platform (NKP) deletes all Services of type LoadBalancer
on the cluster. Each Service is backed by an AWS Classic ELB. Deleting the Service deletes the ELB that backs it.
To skip this step, use the flag --delete-kubernetes-resources=false. Do not skip this step if the VPC
is managed by NKP. When NKP deletes the cluster; it deletes the VPC. If the VPC has any AWS Classic ELBs,
AWS does not allow the VPC to be deleted, and NKP cannot delete the cluster.
nkp delete cluster --cluster-name=${CLUSTER_NAME} --kubeconfig $HOME/.kube/config
```

Output:

```bash
# Deleting Services with type LoadBalancer for Cluster default/cluster_name
# Deleting ClusterResourceSets for Cluster default/cluster_name
# Deleting cluster resources
# Waiting for the cluster to be fully deleted
Deleted default/cluster_name cluster
```

After the managed cluster is deleted, you can delete the bootstrap cluster.

###### Deleting the Bootstrap Cluster

About this task

After you have moved the workload resources back to a bootstrap cluster and
deleted the managed cluster, you no longer need the bootstrap cluster. You can
safely delete the bootstrap cluster with these steps:

Use nkp with the bootstrap cluster to delete the managed cluster. Delete the
kind Kubernetes cluster:

Procedure

Delete the bootstrap cluster.

```bash
nkp delete bootstrap --kubeconfig $HOME/.kube/config
```

Output:

```bash
# Deleting bootstrap cluster (3)
```

#### Manage Pre-provisioned Node Pools

Node pools are part of a cluster and managed as a group, and you can use a
node pool to manage a group of machines using
the same common properties. When Konvoy creates a new default cluster, there
is one node pool for the worker nodes, and
all nodes in that new node pool have the same configuration. You can create
additional node pools for more specialized
hardware or configuration. For example, if you want to tune your memory usage
on a cluster where you need maximum memory
for some machines and minimal memory for others, you create a new node pool
with those specific resource needs.

Nutanix Kubernetes Platform (NKP) implements node pools using Cluster API
Machine Deployments. For more information, see MachineDeployment.

##### Pre-provisioned: Creating Node Pools

Creating a node pool is useful when you need to run workloads that require
machines with specific resources, such as a GPU, additional memory, or
specialized network or storage hardware.

About this task

Node pools are part of a cluster and managed as a group, and can be used to
manage a group of machines using common properties. New default clusters
created by Konvoy contain one node pool of worker nodes that have the same
configuration.

You can create additional node pools for specialized hardware or other
configurations. For example, if you want to tune your memory usage on a
cluster where you need maximum memory for some machines and minimal memory on
others, you could create a new node pool with those specific resource needs.

Environment variables, such as defining the node pool name, are set in the
Prepare the Environment section on the previous page. If needed, refer to that
page to set those variables.

> **Note: Konvoy implements node pools using Cluster API MachineDeployments.**

Create a Pre-provisioned Node Pool:

Procedure

1. Create an inventory object with the same name as the node pool you're
   creating and the details of the pre- provisioned machines you want to add to
   it. For example, to create a node pool named gpu-nodepool, an inventory
   named gpu-nodepool must be present in the same namespace.

```yaml
apiVersion: infrastructure.cluster.konvoy.nutanix.io/v1alpha1
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

1. (Optional) If your pre-provisioned machines have overrides, you must create
   a secret that includes all the overrides you want to provide in one file.
   Create an override secret using the instructions detailed on this page. See
   Pre-provisioned: Creating Secrets and Overrides on page 772.
2. Once the PreprovisionedInventory object and overrides are created, create a
   node pool.

```bash
nkp create nodepool preprovisioned -c ${MY_CLUSTER_NAME} ${MY_NODEPOOL_NAME} --
override-secret-name ${MY_OVERRIDE_SECRET}
```

Advanced users can use a combination of the --dry-run and --output=yaml or
--output- directory=`<existing-directory>` flags to get a complete set of node
pool objects to modify locally or store in version control.

For more information regarding this flag or others, please refer to the nkp
create nodepool section of the documentation for either cluster or nodepool
and select your provider.

##### Pre-provisioned: Scaling Up Node Pools

While running Cluster Autoscaler, you can manually scale your node pools up or
down when you need finite control over your environment. This sections covers
the prerequisites and procedure you need to scale-up or scale-down nodes in an
existing NKP cluster.

Before you begin

- You must have the bootstrap node running with the SSH key or secrets created.
- The export values in the environment variables section need to contain the
  addresses of the nodes that you need to add Pre-provisioned: Define
  Infrastructure.
- Update the preprovisioned_inventory.yaml with the new host addresses.
- Run the kubectl apply command.

Scale Up Node Pools

Procedure

1. Fetch the existing preprovisioned_inventory.

```bash
kubectl get preprovisionedinventory
```

1. Edit the preprovisioned_inventory to add additional IPs needed for
   additional worker nodes in the

spec.hosts: section.

```bash
kubectl edit preprovisionedinventory <preprovisioned_inventory> -n default
```

1. Add any additional IPs that you require

```bash
spec:
hosts:
- address: <worker.ip.add.1>
- address: <worker.ip.add.2>
```

After you edit preprovisioned_inventory, fetch the machine deployment. The
naming convention with md means that it is for worker machines. For example.

```bash
$ kubectl --kubeconfig ${CLUSTER_NAME}.conf get machinedeployment
NAME CLUSTER AGE PHASE REPLICAS READY UPDATED
UNAVAILABLE
machinedeployment-md-0 cluster-name 9m10s Running 4 4 4
```

1. Scale the worker node to the required number. In this example, we scale
   from 4 to 6 worker nodes.

```bash
$ kubectl --kubeconfig ${CLUSTER_NAME}.conf scale --replicas=6 machinedeployment
machinedeployment-md-0
machinedeployment.cluster.x-k8s.io/machinedeployment-md-0 scaled
```

1. Monitor the scaling with this command by adding the -w option to watch.

```bash
$ kubectl --kubeconfig ${CLUSTER_NAME}.conf get machinedeployment -w
NAME CLUSTER AGE PHASE REPLICAS READY UPDATED
UNAVAILABLE
machinedeployment-md-0 cluster-name 20m ScalingUp 6 4 6
2
```

1. Also, you can check the machine deployment to see if it is already scaled.

Example output

```bash
$ kubectl --kubeconfig ${CLUSTER_NAME}.conf get machinedeployment
NAME CLUSTER AGE PHASE REPLICAS READY UPDATED
UNAVAILABLE
machinedeployment-md-0 cluster-name 3h33m Running 6 6 6
```

1. Alternately, you can use this command to verify the NODENAME column and see
   the additional worker nodes added and in Running state.

```bash
$ kubectl --kubeconfig ${CLUSTER_NAME}.conf get machines -o wide
NAME CLUSTER AGE PROVIDERID PHASE VERSION NODENAME
```

##### Pre-provisioned: Scaling Down Node Pools

While running Cluster Autoscaler, you can manually scale your node pools up or
down when you need finite control over your environment. This sections covers
the prerequisites and procedure you need to scale-up or scale-down nodes in an
existing NKP cluster.

Procedure

1. Run this command on your worker nodes.

```bash
kubectl scale machinedeployment <machinedeployment-name> --replicas <new number>
```

1. For control plane nodes, execute the following command.

```bash
kubectl scale kubeadmcontrolplane ${CLUSTER_NAME}-control-plane --replicas <new
number>
```

Additional Notes for Scaling Down

Machines can get stuck in the provisioning stage when you scale down. You can
utilize a delete operation to clear the stale machine deployment:

```bash
kubectl delete machine ${CLUSTER_NAME}-control-plane-<hash>
kubectl delete machine <machinedeployment-name>-<hash>
```

##### Pre-provisioned: Deleting Node Pools

Deleting a node pool deletes the Kubernetes nodes and the underlying
infrastructure.

About this task

All nodes will be drained before deletion, and the pods running on those nodes
will be rescheduled.

```yaml
Note: To delete a node pool on the management cluster on NKP 2.18 or later, add -n kommander to the command.
Starting in NKP 2.18, the management cluster runs in the kommander namespace. In NKP 2.17 and earlier, this flag
was not required.
```

Procedure

1. Delete a node pool from a managed cluster using the command.

```bash
nkp delete nodepool ${NODEPOOL_NAME} --cluster-name=${CLUSTER_NAME}
```

In this example output,example is the node pool to be deleted.

```bash
INFO[2021-07-28T17:14:26-07:00] Running nodepool delete command
Nodepool=example clusterName=d2iq-e2e-cluster-1 managementClusterKubeconfig=
namespace=default src="nodepool/delete.go:80"
```

1. Delete an invalid node pool using the command. Example output:

```bash
nkp delete nodepool ${CLUSTER_NAME}-md-invalid --cluster-name=${CLUSTER_NAME}
INFO[2021-07-28T17:11:44-07:00] Running nodepool delete command
Nodepool=demo-cluster-md-invalid clusterName=nutanix-e2e-cluster-1
managementClusterKubeconfig= namespace=default src="nodepool/delete.go:80"
Error: failed to get nodepool with name demo-cluster-md-invalid in namespace
default : failed to get nodepool with name demo-cluster-md-invalid in namespace
default : machinedeployments.cluster.x-k8s.io "demo-cluster-md-invalid" not found
```

##### Pre-provisioned: Creating GPU Node Pools

For pre-provisioned environments, Nutanix Kubernetes Platform (NKP) has
provided the nvidia-runfile flag for Air-gapped Pre-provisioned environments.

About this task

Add the download to the artifacts directory.

Before you begin

- If the NVIDIA runfile installer has not been downloaded, retrieve and
  install the download by running the command.

```bash
curl -O https://download.nvidia.com/XFree86/Linux-x86_64/580.126.18/NVIDIA-Linux-
x86_64-580.126.18.run
mv NVIDIA-Linux-x86_64-580.126.18.run artifacts
```

> **Note: The NKP supported NVIDIA driver version is 580.126.18. For more
> information, see NVIDIA Drivers.**

- Create an artifacts directory if it does not already exist.

```yaml
Note: For using GPUs in an air-gapped on-premises environment, Nutanix recommends setting up Pod Disruption
Budget before Update Cluster Nodepools. For more information, see https://kubernetes.io/docs/
```

concepts/workloads/pods/disruptions/ and
`<https://docs.nvidia.com/datacenter/tesla/tesla->` installation-
notes/index.html#runfile.

Procedure

1. In your overrides/nvidia.yaml file, add the following to enable GPU builds.
   You can also access and use the overrides repo. Create the secret that GPU
   nodepool uses.

```bash
gpu:
types:
- nvidia
build_name_extra: "-nvidia"
```

1. Create a secret on the bootstrap cluster populated from the above file. We
   will name it ${CLUSTER_NAME}-

```bash
user-overrides
kubectl create secret generic ${CLUSTER_NAME}-user-overrides --from-
file=overrides.yaml=overrides/nvidia.yaml
```

1. Create an inventory and node pool with the instructions below and use the
   $CLUSTER_NAME-user-overrides secret. Follow these steps.

a. Create an inventory object with the same name as the node pool you're
creating and the details of the pre- provisioned machines you want to add to
it. For example, to create a node pool named gpu-nodepool an inventory named
gpu-nodepool must be present in the same namespace.

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
a secret that includes all the overrides you want to provide in one file.
Create an override secret using the instructions detailed on this page. See
Pre-provisioned FIPS Air-gapped Installation on page 118.

c. Once the PreprovisionedInventory object and overrides are created, create a
node pool.

```bash
nkp create nodepool preprovisioned -c ${MY_CLUSTER_NAME} ${MY_NODEPOOL_NAME} --
override-secret-name ${MY_OVERRIDE_SECRET}
```

- Advanced users can use a combination of the --dry-run and --output=yaml or
  --output- directory=`<existing-directory>` flags to get a complete set of
  node pool objects to modify locally or store in version control.

For more information regarding this flag or others, please refer to the nkp
create nodepool section of the documentation for either cluster or nodepool
and select your provider.

## Install Nutanix Kubernetes Platform on AWS Infrastructure

Install Nutanix Kubernetes Platform (NKP) on AWS infrastructure.

This table lists all the steps to configure AWS infrastructure and NKP for
air-gapped and non-air-gapped environments.

Table 71: Install NKP on AWS Infrastructure

Pre-requisites and Planning

- Nutanix Kubernetes Platform Requirements on page 45

### AWS Prerequisites

Infrastructure Preparation

- Building a Custom Image with AWS on page 59
- Preparing a Local Registry Mirror on page 816 (Required for air-gapped, and
  optional for non- airgapped environments)
- Pushing Images to the Registry on page 817 (Required for air-gapped, and
  optional for non- airgapped environments)

Installation

- Creating the NKP Management Cluster on AWS on page 818

Post-Installation

- Setting up the Nutanix Kubernetes Platform User Interface Access on page 750
- AWS Node Pool Operations on page 820
- Delete an AWS Cluster on page 822

Operator Machine Requirements

The machine that you use to run the installation must meet the following
requirements:

- An x86_64-based Linux or macOS machine.
- Ensure the NKP binary for Linux or macOS is downloaded and accessible.
- A supported container engine must be installed and running. You can use the
  Docker container engine version 27.4.0 (for Linux or macOS) or Podman
  version 4.0 or later (for Linux).
- Ensure the AWS CLI utility, and the kubectl command-line tool is installed.

AWS Account and Security Requirements

Ensure your AWS environment has the appropriate access and permissions:

- AWS account: You must have a valid AWS account with configured credentials
  that grant permissions to manage CloudFormation Stacks, IAM Policies, IAM
  Roles, and IAM Instance Profiles.

| Section | Steps |
| ------- | ----- |

- IAM policies and roles: Ensure that you created the minimum permissions and
  roles required to create clusters, as well as specific cluster IAM policies
  and roles for the control plane and worker nodes.
- Environment variables: Ensure that you exported the AWS region (for example,
  export AWS_REGION=us- west-2) and the AWS profile containing the credentials
  that you plan to use (export AWS_PROFILE=profile).
- Multi-tenancy: If you plan to host multiple tenants, every tenant must be
  placed in a different AWS account to ensure complete independence and
  enforce security.

Cluster resource requirements

Verify that your AWS environment can support the default resource allocations
for NKP clusters. NKP requires a minimum of three control plane nodes and four
worker nodes for production deployments.

- Control plane nodes: NKP defaults to deploying an m5.xlarge instance with an
  80 GiB root volume. Each node must have at least four CPU cores, 16 GiB of
  memory, and approximately 80 GiB of free space for the /var/lib/ kubelet and
  /var/lib/containerd volumes.
- Worker nodes: NKP defaults to deploying an m5.2xlarge instance with an 80
  GiB root volume. Each node must have at least eight CPU cores, 32 GiB of
  memory, and approximately 80 GiB of free space for the /var/lib/kubelet and
  /var/lib/containerd volumes.
- Disk usage: For all nodes, root volume disk usage must remain below 85%.

Amazon Machine Image requirements

NKP requires you to specify an Amazon Machine Image (AMI) when creating a
cluster. Nutanix strongly recommends using the Nutanix Image Builder (NIB) to
create a custom, Cluster API-compliant AMI rather than using default upstream
images. Using a custom AMI ensures your cluster includes the necessary
optimizations and components, such as FIPS-compliant binaries if required.

Air-gapped environment requirements

If you install NKP in an air-gapped environment, you must meet the following
additional prerequisites:

- A Linux-based bastion machine that has access to the existing AWS Virtual
  Private Cloud (VPC).
- The NKP binary and kubectl tool installed on the bastion machine.
- An existing container registry that can be reached by the VPC to host the
  required NKP container images.
- The complete NKP air-gapped bundle (nkp-air-gapped-bundle_nkp-
  version_linux_amd64.tar.gz) downloaded from an internet-connected machine
  and extracted to the local directory.

### Preparing a Local Registry Mirror (2)

Before you begin

If you do not already have a container registry set up, configure one before
proceeding. For AWS environments, you can use Amazon Elastic Container
Registry (ECR) or other compatible external tools such as JFrog Artifactory,
Nexus, or Harbor.

About this task

```yaml
Important: This procedure is required for an air-gapped environment. It is optional for a non-air-gapped environment;
however it can increase stability and security. You can also use a registry mirror with a self-signed registry CA
certificate in a non-air-gapped environment.
```

| export AWS PROFILE= | profile |
| ------------------- | ------- |

| nkp-air-gapped-bundle | nkp-version | linux amd64.tar.gz |
| --------------------- | ----------- | ------------------ |

To prepare a local registry mirror to host container images for deploying the
NKP management cluster on AWS, follow these steps:

Procedure

1. Open a terminal with access to the NKP CLI.
2. Provide the registry URL by exporting it as an environment variable:

The environment where you run the NKP CLI must authenticate with AWS to load
images into ECR. 3. (Optional) If your registry requires authentication,
export the registry username and password:

```bash
export REGISTRY_MIRROR_USERNAME=username
export REGISTRY_MIRROR_PASSWORD=password
```

1. (Optional) If your registry uses a self-signed certificate and the AWS AMIs
   do not already trust this CA, set variables for the CA file path, registry
   host, and registry port; then download the CA certificate:

a. Export the path to the CA certificate and the registry address and port on
the bastion host:

```bash
export REGISTRY_MIRROR_CA=path-to-ca-file
export REGISTRY_MIRROR_ADDRESS=registry-host
export REGISTRY_MIRROR_PORT=registry-port
```

Replace path-to-ca-file with the path where the downloaded CA certificate is
stored. Replace registry-host with the host of the registry URL. Replace
registry-port with the port of the registry URL.

b. Download the CA certificate:

```bash
openssl s_client \
-showcerts \
-connect $REGISTRY_MIRROR_ADDRESS:$REGISTRY_MIRROR_PORT \
</dev/null | \
openssl x509 \
-outform PEM \
> $REGISTRY_MIRROR_CA
```

### Pushing Images to the Registry (2)

Before you begin

- Ensure that your registry (such as AWS ECR, Harbor, or JFrog) is configured
  and accessible from both your bastion machine and the AWS EC2 instances that
  you plan to create for the Kubernetes cluster.
- Ensure that you downloaded the complete NKP air-gapped bundle to your
  bastion host.
- Ensure that your registry environment variables are configured.

About this task

Push container images to your registry to deploy the NKP management cluster on
AWS.

To extract the bundle and push images to the registry, follow these steps:

| export REGISTRY MIRROR URL= \_ \_ | ecr-registry-URI | Col3 |
| --------------------------------- | ---------------- | ---- |

Procedure

1. Extract the downloaded air-gapped bundle to a local directory on your
   bastion host:
2. Navigate to the extracted directory:
3. Set the environment variables with your registry address and credentials:

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=username
export REGISTRY_PASSWORD=password
```

(Optional) If your registry uses a self-signed certificate, specify the path
to the CA certificate on the bastion:

If you are using AWS ECR, your REGISTRY_URL is your ECR registry URL, and your
environment must be authenticated with AWS to push the images. 4. Load the
air-gapped image bundle into your private registry:

```bash
cd cli/
nkp push bundle \
--bundle ../container-images/konvoy-image-bundle-nkp-version.tar \
--to-registry=${REGISTRY_URL} \
--to-registry-username=${REGISTRY_USERNAME} \
--to-registry-password=${REGISTRY_PASSWORD} \
--to-registry-ca-cert-file=${REGISTRY_CA:-""}
```

The time taken to push all the images depends on network performance between
the bastion host and the registry. 5. Load the Kommander component images into
your private registry:

```bash
nkp push bundle \
--bundle ../container-images/kommander-image-bundle-nkp-version.tar \
--to-registry=${REGISTRY_URL} \
--to-registry-username=${REGISTRY_USERNAME} \
--to-registry-password=${REGISTRY_PASSWORD} \
--to-registry-ca-cert-file=${REGISTRY_CA:-""}
```

1. On the bastion host, load the Konvoy bootstrap image into your local
   container runtime:

```bash
cd ../
docker load -i konvoy-bootstrap-image-nkp-version.tar
```

If you are using Podman, replace docker with podman.

### Creating the NKP Management Cluster on AWS

Before you begin

- Ensure that your AWS credentials are configured.
- Ensure that you loaded the necessary container images into your registry
  mirror.
- Ensure that you created a custom Amazon Machine Image (AMI) in the AWS
  region where you are deploying to use the Nutanix Image Builder (NIB).

| tar -xzvf nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ---------------------------------- | ----------- | ------------------------ |

| cd nkp- | nkp-version | /   |
| ------- | ----------- | --- |

| export REGISTRY CA= \_ | path-to-cacert-on-bastion | Col3 |
| ---------------------- | ------------------------- | ---- |

- Ensure that your AWS VPC has the required VPC endpoints if operating in an
  air-gapped environment.

About this task

To create a NKP management cluster in a non-air-gapped and air-gapped
environment using the NKP default settings, follow these steps:

Procedure

1. Open a terminal with access to the NKP CLI.
2. (Required for air-gapped environments and optional for non-air-gapped
   environments) Load the NKP bootstrap cluster container image into the local
   container runtime store.

The NKP CLI uses a container image to create the temporary bootstrap cluster.
In an air-gapped environment, you cannot automatically download the image from
the public registry. The image is included in the air-gapped bundle, and you
must load it manually using either Docker or Podman. 3. Assign a unique name
to your cluster and store it in an environment variable.

In AWS it is critical that the name is unique, because no two clusters in the
same AWS account can have the same name. The cluster name must contain only
lowercase alphanumeric characters and hyphens. 4. Export variables for your
existing AWS infrastructure details.

```bash
export AWS_VPC_ID=vpc-id
export AWS_SUBNET_IDS=subnet-id-1,subnet-id-2,subnet-id-3
export AWS_ADDITIONAL_SECURITY_GROUPS=security-group-id
export AWS_AMI_ID=custom-ami-id
```

- vpc-id: VPC ID where the cluster will be created. The VPC requires the
  following AWS VPC endpoints to be already present: ec2,
  elasticloadbalancing, secretsmanager, autoscaling, ecr.api, and ecr.dkr
  (required in an air-gapped environment).
- subnet-ids: Comma-separated list of one or more private subnet IDs, each in
  a different Availability Zone (required in an air-gapped environment).
- security-group-id: Optional comma-separated list of security group IDs to
  use in addition to those automatically created by NKP (required in an air-
  gapped environment when you use additional groups).
- custom-ami-id: ID of the AMI you created using Nutanix Image Builder (NIB).

1. (Optional) If you are using a local registry such as AWS ECR, provide the
   registry mirror configuration environment variables.

```bash
export REGISTRY_URL=ecr-registry-URL
export REGISTRY_USERNAME=username
export REGISTRY_PASSWORD=password
```

Optional: If your registry uses a self-signed certificate, export the path to
your CA certificate: 6. (Required for air-gapped environments and optional for
non-air-gapped environments) Configure local registry mirror flags to append
to your cluster creation command.

```bash
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD} \
```

- docker load --input "nkp-; nkp-version; /konvoy-bootstrap-image-; nkp-
  version; .tar"

| --- | --- | --- | --- | --- |

| export CLUSTER NAME= \_ | aws-example | Col3 |
| ----------------------- | ----------- | ---- |

| export REGISTRY CA= \_ | path-to-cacert-on-bastion | Col3 |
| ---------------------- | ------------------------- | ---- |

```bash
--registry-mirror-cacert=${REGISTRY_CA:-""} \
Important: To increase Docker Hub rate limits, use your Docker Hub credentials when creating the cluster by
setting the following flags on the nkp create cluster command:
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

1. (Optional) Export variables for FIPS mode.

```bash
export FIPS_FLAGS=" \
--kubernetes-version=vkubernetes-version+fips.0 \
--etcd-version=etcd-version+fips.0 \
--kubernetes-image-repository=docker.io/mesosphere \
--etcd-image-repository=docker.io/mesosphere \
"
```

The image created using NIB must be FIPS compliant. 8. (Optional) Export
variables to provision the cluster on Flatcar Linux.

```bash
export FLATCAR_FLAGS=" \
--os-hint flatcar
"
```

1. Create a self-managed management cluster using the nkp create cluster aws
   command.

Include optional flags such as --internal-load-balancer=true, --additional-
security-group-ids= ${AWS_ADDITIONAL_SECURITY_GROUPS}, or --os-hint flatcar
when your environment requires them. Append ${FIPS_FLAGS} or ${FLATCAR_FLAGS}
when you set those variables.

```bash
nkp create cluster aws \
--cluster-name=${CLUSTER_NAME} \
--additional-tags=owner=$(whoami) \
--with-aws-bootstrap-credentials=true \
--vpc-id=${AWS_VPC_ID} \
--ami=${AWS_AMI_ID} \
--subnet-ids=${AWS_SUBNET_IDS} \
--internal-load-balancer=true \
--additional-security-group-ids=${AWS_ADDITIONAL_SECURITY_GROUPS} \
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD} \
--registry-mirror-cacert=${REGISTRY_CA:-""} \
--self-managed
```

The NKP CLI creates a management cluster using the configuration and
environment variables that you exported.

If you require an HTTP or HTTPS proxy, add the flags --http-proxy, --https-
proxy, and --no-proxy. For more information, see Cluster Creation with HTTP or
HTTPS Proxy.

For advanced customizations, remove the --self-managed flag and use --dry-run
and --output=yaml > ${CLUSTER_NAME}.yaml to generate Cluster API configuration
files. Edit the YAML file and use kubectl create -f ${CLUSTER_NAME}.yaml to
create the cluster.

### AWS Node Pool Operations

Use the topics in this section to scale worker node pools, tune the Cluster
Autoscaler, and remove clusters safely- including bootstrap and workload
clusters when your management cluster is self-managed.

#### Scaling AWS Node Pools

Node pools are part of a cluster and are managed as a group. You can use a
node pool to manage machines that share the same properties. When Konvoy
creates a new default cluster, one node pool is created for the worker nodes,
and all nodes in that node pool have the same configuration. You can create
additional node pools for more specialized hardware or configuration.

NKP implements node pools using Cluster API MachineDeployments. While running
the Cluster Autoscaler allows dynamic adjustments, you can manually scale your
node pools up or down when you require direct control over capacity.

List AWS Node Pools

Use the nkp get nodepools command to list node pools for an AWS cluster using
the NKP CLI.

For example:

```bash
nkp get nodepools --cluster-name=${CLUSTER_NAME} --kubeconfig=${CLUSTER_NAME}.conf
```

About this task

To scale AWS nodepools, follow this step:

```yaml
Note: To scale node pools on the management cluster on NKP 2.18 or later, add -n kommander to the command.
Starting in NKP 2.18, the management cluster runs in the kommander namespace. In NKP 2.17 and earlier, this flag
was not required.
```

Procedure

- Scale the node pool to the target number of replicas.

Replace the count with the target replica count that is more than the current
value to scale up the node pools, or a count that is less than the current
value to scale down the node pools.

#### Scaling Node Pools Using the Cluster Autoscaler

About this task

To scale node pools using the Cluster Autoscaler, follow these steps:

Procedure

1. Verify that the Cluster Autoscaler controller is running without errors or
   restarts in the logs.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf logs deployments/cluster-autoscaler
cluster-autoscaler -n kube-system -f
```

1. Enable the Cluster Autoscaler by applying the minimum and maximum range
   annotations to your target node pool MachineDeployment.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf annotate machinedeployment ${NODEPOOL_NAME}
cluster.x-k8s.io/cluster-api-autoscaler-node-group-min-size=2
```

- nkp scale nodepools ${NODEPOOL NAME} --replicas= \_; count; --cluster-
   name=${CLUSTER NAME} \_

| --- | --- | --- |

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf annotate machinedeployment ${NODEPOOL_NAME}
cluster.x-k8s.io/cluster-api-autoscaler-node-group-max-size=6
```

In this example, the minimum range is 2 nodes and the maximum is 6 nodes.

```yaml
Note: If you scale a node pool beyond the maximum bounds in MachineDeployment, the NKP CLI returns an
error. Scaling below the minimum size also returns an error.
```

What to do next

Review the Cluster Autoscaler logs to confirm that worker nodes are associated
with the node groups and the controller is watching for pending pods.

```bash
cat <<EOF | kubectl --kubeconfig=${CLUSTER_NAME}.conf apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
name: busybox-deployment
labels:
app: busybox
spec:
replicas: 600
selector:
matchLabels:
app: busybox
template:
metadata:
labels:
app: busybox
spec:
containers:
- name: busybox
image: busybox:latest
command:
- sleep
- "3600"
imagePullPolicy: IfNotPresent
restartPolicy: Always
EOF
```

### Delete an AWS Cluster

A self-managed cluster cannot delete itself. If your managed cluster is self-
managed, you must first create a temporary bootstrap cluster and move the
cluster lifecycle services to it before deleting the managed cluster. If you
did not make your managed cluster self-managed, you can skip the bootstrap
creation steps and proceed directly to deleting the workload cluster.

#### Creating a Bootstrap Cluster and Move CAPI Resources (2)

About this task

To create a bootstrap cluster and move CAPI resources for a self-managed
cluster, follow these steps:

Procedure

1. Ensure that your AWS credentials are up to date:

```bash
nkp update bootstrap credentials aws --kubeconfig $HOME/.kube/config
```

1. Create a bootstrap cluster that can host the Cluster API controllers that
   reconcile cluster objects marked for deletion:

```bash
nkp create bootstrap --kubeconfig $HOME/.kube/config --with-aws-bootstrap-
credentials=true
```

1. Move the Cluster API objects from the workload cluster to the bootstrap
   cluster:

```bash
nkp move capi-resources \
--from-kubeconfig ${CLUSTER_NAME}.conf \
--from-context ${CLUSTER_NAME}-admin@${CLUSTER_NAME} \
--to-kubeconfig $HOME/.kube/config \
--to-context kind-konvoy-capi-bootstrapper
```

The cluster lifecycle services on the bootstrap cluster are ready, but the
workload cluster configuration is still on the managed cluster. The move
command pivots the Cluster API custom resources from the workload cluster to
the bootstrap cluster. 4. Check the managed cluster status using cluster
lifecycle services:

```bash
nkp describe cluster --kubeconfig $HOME/.kube/config -c ${CLUSTER_NAME}
```

Sample output:

```bash
NAME READY SEVERITY
REASON SINCE MESSAGE
Cluster/aws-example True
91s
##ClusterInfrastructure - AWSCluster/aws-example True
103s
##ControlPlane - KubeadmControlPlane/aws-example-control-plane True
91s
# ##Machine/aws-example-control-plane-55jh4 True
102s
# ##Machine/aws-example-control-plane-6sn97 True
102s
# ##Machine/aws-example-control-plane-nx9v5 True
102s
##Workers
##MachineDeployment/aws-example-md-0 True
108s
##Machine/aws-example-md-0-cb9c9bbf7-hcl8z True
102s
##Machine/aws-example-md-0-cb9c9bbf7-rtdqw True
102s
##Machine/aws-example-md-0-cb9c9bbf7-td29r True
102s
##Machine/aws-example-md-0-cb9c9bbf7-w64kg True
102s
Note: After moving cluster lifecycle services, use the appropriate kubeconfig for each cluster when you run NKP
commands for deletion.
```

#### Delete an AWS Workload Cluster

About this task

To delete the provisioned Kubernetes cluster to remove the cluster and its
resources from your cloud provider, follow these steps:

Procedure

1. Ensure that your AWS credentials are up to date:

```bash
nkp update bootstrap credentials aws --kubeconfig $HOME/.kube/config
```

1. Retrieve the details of the Kubernetes cluster that you plan to delete:

```bash
kubectl get nkpclusters
Note: Do not use nkp get clusters for Konvoy Kubernetes cluster details; that command returns NKP cluster
information.
```

1. Delete the Kubernetes cluster and wait for the operation to complete.

```bash
nkp delete cluster --cluster-name=${CLUSTER_NAME} --kubeconfig $HOME/.kube/config
```

Persistent volumes (PVs) are not deleted during this process. PVs continue to
consume storage until you delete them manually in AWS.

#### Delete the Bootstrap Cluster

About this task

After you move workload resources to a bootstrap cluster and successfully
delete the managed cluster, you no longer need the bootstrap cluster and can
delete it.

Procedure

```bash
nkp delete bootstrap --kubeconfig $HOME/.kube/config
```

Sample output:

```bash
# Deleting bootstrap cluster (4)
```

## EKS Infrastructure

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

### EKS: Introduction

Nutanix Kubernetes Platform (NKP) brings value to EKS customers by providing
all components needed for a production-ready Kubernetes environment. NKP
provides the capability to provision EKS clusters using the NKP UI. It also
provides the ability to upgrade your EKS clusters using the NKP platform,
making it possible to manage the complete life cycle of EKS clusters from a
centralized platform.

NKP adds value to Amazon EKS through:

- Time to Value in hours/days to get to production, instead of weeks/months,
  or even failure. Particularly in complex environments like air-gapped,
  customers tried various options and spending millions did not succeed or saw
  Day 2 later than expected. We delivered results in hours or days.
- Less Risk
- Cloud-Native Expertise eliminates the issue of a lack of skills. Our
  industry-leading expertise closes skill gaps on the customer side, avoids
  costly mistakes, transfers skills, and improves project success rates while
  shortening timelines.
- Simplicity mitigates operational complexity. We focus on a great user
  experience and automate parts of cloud-native operations to get customers to
  Day 2 faster and meet all Day 2 operational challenges. This frees up
  customer time to build what differentiates them instead of reinventing the
  wheel for Kubernetes operations.
- Military-Grade Security alleviates security concerns. The Nutanix Kubernetes
  Platform can be configured to meet NSA Kubernetes security hardening
  guidelines. Nutanix Kubernetes Platform and supported add-on components are
  security scanned and secure pre-built-encryption of data-at-rest, FIPS
  compliance, and fully supported air-gapped deployments round out Nutanix
  offerings.
- Lower TCO - With operational insights and a more straightforward platform
  that curates needed capabilities from Amazon EKS and the open source
  community that reduces the time and cost of consulting engagements and
  ongoing support costs.
- Ultimate-grade Kubernetes - Comes with a curated list of Day 2 applications
  necessary for running Kubernetes in production.
- One platform for all - Single platform to manage multiple clusters on any
  infrastructure cloud, on-premises, and edge.
- Nutanix GitOps and EKS - Delivering business value through applications is
  the primary goal of any Kubernetes cluster. While EKS provides the hosted
  framework that leads the market, delivering applications to your environment
  requires a mature and integrated approach. Nutanix NKP provides workspace
  and project level constructs to a Kubernetes cluster so that application
  teams have a division of resources, security, and cost optimization at the
  project and namespace level.
- Projects deliver applications through FluxCD's built-in GitOps-just provide
  a Git repository, and NKP does the rest.
- Through integration with OpenCost, NKP monitors the utilization of project
  resources and provides real-time reporting for performance and cost
  optimization.
- Project security is defined through forced the integration of customer
  authentication methods by NKP and enforced through several application
  security layers.
- Cluster Life cycle Management through CAPI - Through cluster API, NKP gives
  customers complete life cycle management of their EKS clusters with the
  ability to instantiate new EKS clusters through a unified API. This allows
  administrators to deploy new EKS clusters through code and deliver
  consistent cluster configurations.
- Time to application value is significantly reduced by minimizing the steps
  necessary to provision a cluster segment clusters through integrated
  permissions.
- Secure and reliable cluster deployments.
- Automatic day 2 operations of EKS clusters (Monitoring, Logging, Central
  Management, Security, Cost Optimization).
- Day 2 GitOps integration with every EKS cluster.

### EKS: Prerequisites and Permissions

Konvoy Prerequisites

Before you begin using Konvoy, you must have:

- An x86_64-based Linux or macOS machine.
- The nkp binary for Linux or macOS.
- A Container engine or runtime installed is required to install Nutanix
  Kubernetes Platform (NKP) :
- Docker container engine version 27.4.0 installed for Linux or MacOS. For
  more information, see https:// docs.docker.com/get-docker/.
- Podman Version 4.0 or later for Linux. For more information, see
  `<https://podman.io/getting-started/>` installation. For host requirements,
  see `<https://kind.sigs.k8s.io/docs/user/rootless/#host-requirements>`.
- kubectl for interacting with the running cluster.
- A valid AWS account with credentials configured.
- For a local registry, whether air-gapped or non-air-gapped environment,
  download and extract the bundle. Download the Complete NKP Air-gapped Bundle
  for this release (that is. nkp-air-gapped-bundle_nkp-
  version_linux_amd64.tar.gz) to load registry.

> **Note: On macOS, Docker runs in a virtual machine. Configure this virtual
> machine with at least 8GB of memory.**

Control Plane Nodes

You need at least three control plane nodes. Each control plane node needs to
have at least the following:

- 4 cores
- 16 GiB memory
- Approximately 80 GiB of free space for the volume used for /var/lib/kubelet
  and /var/lib/containerd.
- Disk usage must be below 85% on the root volume.

NKP on AWS defaults to deploying an m5.xlarge instance with an 80GiB root
volume for control plane nodes, which meets the above requirements.

Worker Nodes

You need at least four worker nodes. The specific number of worker nodes
required for your environment can vary depending on the cluster workload and
size of the nodes. Each worker node needs to have at least the following:

- 8 cores
- 32 GiB memory
- Around 80 GiB of free space for the volume used for /var/lib/kubelet and
  /var/lib/containerd.
- Disk usage must be below 85% on the root volume.

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

NKP on AWS defaults to deploying am5.2xlarge instance with an 80GiB root
volume for worker nodes, which meets the above requirements.

If you use these instructions to create a cluster on AWS using the NKP default
settings without any edits to configuration files or additional flags, your
cluster is deployed on a three control plane nodes, and four worker nodes,
which match the requirements above.

AWS Prerequisites

Before you begin using Konvoy with AWS, you must meet the required AWS
Prerequisites on page 815.

#### EKS: Minimal User Permissions

The following is a CloudFormation stack that adds a policy named eks-
bootstrapper to manage the EKS cluster to the nkp-bootstrapper-role created by
the CloudFormation stack for AWS.

Consult the AWS Prerequisites on page 815 section for an example of using this
role and how a system administrator wants to expose using the permissions.

EKS CloudFormation Stack

```yaml
AWSTemplateFormatVersion: 2010-09-09
Parameters:
existingBootstrapperRole:
Type: CommaDelimitedList
Description: 'Name of existing minimal role you want to add to add EKS cluster
management permissions to'
Default: nkp-bootstrapper-role
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

> **Note: If your role is not named nkp-bootstrapper-role , change the
> parameter in line 6 of the file.**

To create the resources in the cloudformation stack, copy the contents above
into a file. Before executing the following command, replace MYFILENAME.yaml
and MYSTACKNAME with the intended values for your system.

```bash
aws cloudformation create-stack --template-body=file://MYFILENAME.yaml
--stack-name=MYSTACKNAME --capabilities CAPABILITY_NAMED_IAM
```

#### EKS: Cluster IAM Permissions and Roles

Prerequisites from AWS

Before you begin, ensure you meet the following AWS prerequisites:

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
aws.sigs.k8s.io roles in AWS. For more information, see AWS Prerequisites on page 815.
```

- The following CloudFormation stack defines the IAM policies and roles
  required to set up Amazon EKS clusters. For more information, see
  CloudFormation stack.

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
Description: 'ARN of existing Node IAM Role to attach the managed policy to'
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

### EKS: Creating a Managed EKS Cluster from the CLI

About this task

To create a EKS cluster, follow these steps:

Procedure

1. Set the environment variable to your cluster name:

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
Use an existing AWS ECR as registry mirror:

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
NKP Release Notes.

By default, NKP creates the control-plane nodes in three different
availability zones. The default worker nodes, however, reside in a single
availability zone. To distribute worker nodes across multiple availability
zones, create additional node pools in other availability zones nkp create
nodepool. 6. Check the current status of the cluster:

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

#### Known Limitations (3)

About this task

Be aware of the following limitations for the current NKP version:

Procedure

- The NKP version you use to create a managed cluster must match the NKP
  version you use to delete it.
- You cannot self-manage EKS clusters.
- Cluster Verification: To monitor or verify the installation of your
  clusters, see Cluster and NKP Installation Verification on page 1039 and
  Installing NKP on page 43.

### EKS: Creating an EKS Cluster from the UI

Create and provision an EKS cluster directly from the NKP UI. The browser-
based UI simplifies cluster setup and access, enabling quick deployment and
management without complex configurations.

#### EKS: Creating an AWS Infrastructure Provider

About this task

To create an AWS infrastructure provider to store your AWS or EKS credentials,
follow these steps:

Procedure

1. Get the AWS RoleARN:

```bash
aws iam get-role --role-name <role-name> --query 'Role.[RoleName, Arn]' --output text
```

For more information, see AWS Prerequisites on page 815. 2. From the Dashboard
menu, select Infrastructure Providers. 3. Click Add Infrastructure Provider. 4. Choose a workspace.

If you are already in a workspace, NKP automatically creates the
infrastructure provider in that workspace. 5. Select Amazon Web Services. 6.
Enter a Name for your infrastructure provider and add the Role ARN that you
generated. 7. Click Save.

> **Warning: You can use static credentials, but it is not recommended
> because it is less secure.**

#### EKS: Provisioning a Cluster

About this task

Follow these steps to provision the EKS cluster:

Procedure

1. From the top menu bar, select your target workspace.
2. To start the provisioning workflow, Select Clusters > Cluster
3. Choose Create Cluster.
4. Enter the Cluster Name.
5. Select EKS from the Choose Infrastructure choices.
6. If available, choose a Kubernetes Version. Otherwise, the default
   Kubernetes version installs.
7. Select a datacenter region or specify a custom region.
8. Edit your worker Node Pools as necessary. You can choose the Number of
   Nodes, the Machine Type, and our IAM Instance Profile. You can also choose a
   #Worker Availability Zone#for the worker pool.
9. Add any additional Labels or Infrastructure Provider Tags as necessary.
10. Validate your inputs, and then select Create. You are redirected to the
    Clusters page, where you see your Clusters in the Provisioning status. Hover
    over the status to view the details. Expect your cluster to change to the
    Provisioned status after 15 minutes.

What to do next

For more information on AWS IAM ARNs, see
`<https://docs.aws.amazon.com/IAM/latest/UserGuide/>`
reference_identifiers.html#identifiers-arns.

#### EKS: Accessing the Cluster

After successfully attaching the cluster (managed), you can retrieve a custom
kubeconfig file from the UI using your Kommander administrator credentials.

#### EKS: IAM User and Role Access for Clusters

About this task

When creating an EKS cluster through the UI, the kubeconfig returned using the
download kubeconfig button allows access for 15 minutes. To follow best
practices for AWS security,

configure access to the EKS cluster using the IAM role or user-based
authentication. This allows account administrators to monitor all actions
made.

To enable IAM-based cluster access, follow the steps below:

Procedure

1. Download the kubeconfig by selecting the Download kubeconfig button on the
   top section of the UI.
2. Using that kubeconfig, edit the config map with a command similar to the
   example.

```bash
kubectl --kubeconfig=MYCLUSTER.conf edit cm -n kube-system aws-auth
```

1. Modify the mapRoles and mapUsers objects according to the permissions as
   needed. The following example shows mapping the
   arn:aws:iam::MYAWSACCOUNTID:role/PowerUser role to the systems:masters on
   the Kubernetes cluster.

```yaml
apiVersion: v1
data:
mapRoles: |
- groups:
- system:bootstrappers
- system:nodes
rolearn: arn:aws:iam::MYAWSACCOUNTID:role/nodes.cluster-api-provider-
aws.sigs.k8s.io
username: system:node:{{EC2PrivateDNSName}}
- groups:
- system:masters
rolearn: arn:aws:iam::MYAWSACCOUNTID:role/PowerUser
username: admin
kind: ConfigMap
```

For more information, see:

- Enabling IAM user and role access:
  `<https://docs.aws.amazon.com/eks/latest/userguide/add-user->` role.html.
- Kubernetes RBAC guide:`<<https://kubernetes.io/docs/reference/access-authn->`
  authz/rbac/>.

1. From your management cluster, run the nkp get kubeconfig command to fetch a
   kubeconfig that uses IAM- based permissions.

```bash
nkp get kubeconfig -c ${EKS_CLUSTER_NAME} -n ${KOMMANDER_WORKSPACE_NAMESPACE} >>
${EKS_CLUSTER_NAME}.conf
```

### EKS: Granting Cluster Access

About this task

You can access your cluster using AWS IAM roles in the dashboard. When you
create an EKS cluster, the IAM entity is granted system:masters permissions in
Kubernetes Role Based Access Control (RBAC) configuration. at
`<https://kubernetes.io/docs/reference/access-authn-authz/rbac/>`

```yaml
Note: More information about the configuration of the EKS control plane can be found on the EKS Cluster IAM
Policies and Roles page.
```

Suppose the EKS cluster was created as a cluster using a self-managed AWS
cluster that uses IAM Instance Profiles. In that case, you must modify the
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
   system:masters. Note that this example uses an example AWS resource ARNs
   (https:// docs.aws.amazon.com/IAM/latest/UserGuide/reference-arns.html), so
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

What to do next

For more information on changing or assigning roles or clusterroles to which
you can map IAM users or roles, see Amazon Enabling IAM access to your cluster
at `<https://docs.aws.amazon.com/eks/latest/userguide/add->` user-role.html.

### EKS: Exploring Your Cluster

About this task

This section describes how to use the command line to interact with your
Kubernetes cluster.

Before you begin

Create a managed cluster as described in Create a New Cluster.

To explore the new Kubernets cluster, follow these steps:

Procedure

1. Get the kubeconfig file for the managed cluster: When the managed cluster
   is created, the cluster life cycle services generate a kubeconfig file for
   the managed cluster and write it to a Secret. The kubeconfig file is scoped
   to the cluster administrator.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
Caution: Nutanix support is unable to recover forgotten credentials. Prevent Kommander UI lockouts with the
following best practices.
```

- Backup the kubeconfig file.
- Save your credentials.
- Configure an IDP (identity provider) instead of using a username and
  password credentials.

1. List the nodes using the kubectl --kubeconfig=${CLUSTER_NAME}.conf get
   nodes command. Example output:

```bash
NAME STATUS ROLES AGE VERSION
ip-10-0-122-211.us-west-2.compute.internal Ready <none> 35m v<kubernetes-
version>-eks-ba74326
ip-10-0-127-74.us-west-2.compute.internal Ready <none> 35m v<kubernetes-
version>-eks-ba74326
ip-10-0-71-155.us-west-2.compute.internal Ready <none> 35m v<kubernetes-
version>-eks-ba74326
ip-10-0-93-47.us-west-2.compute.internal Ready <none> 35m v<kubernetes-
version>-eks-ba74326
Note: The Status may take a few minutes to move to Ready while the Pod network is deployed. The node status
will change to Ready soon after the calico-node DaemonSet Pods are Ready.
```

1. List the Pods using the kubectl --kubeconfig=${CLUSTER_NAME}.conf get
   --all-namespaces pods command.

Output:

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

What to do next

### EKS: Attaching an Existing Cluster to the Management Cluster

You can attach existing Kubernetes clusters to the Management Cluster. After
attaching the cluster, you can use the UI to examine and manage this cluster.
The following chapter describes attaching an existing Amazon Elastic
Kubernetes Service (EKS) cluster.

```yaml
Note: This procedure assumes you have an existing and spun-up Amazon EKS cluster(s) with administrative
privileges. Refer to the Amazon EKS at https://aws.amazon.com/eks/ for setup and configuration information.
```

Install aws-iam-authenticator as described in
`<https://docs.aws.amazon.com/eks/latest/userguide/install-aws->` iam-
authenticator.html. This binary is used to access your cluster using kubectl.

#### EKS: Attaching a Pre-existing Cluster

About this task

Attach a pre-existing EKS cluster.

Procedure

Ensure that the KUBECONFIG environment variable is set to the Management
cluster by running the following command.

##### EKS: Accessing your EKS clusters

About this task

To access your EKS clusters, perform the following steps:

Procedure

1. Ensure you are connected to your EKS clusters, using the command for each
   of your clusters

```bash
kubectl config get-contexts
kubectl config use-context <context for first eks cluster>
```

1. Confirm kubectl can access the EKS cluster using the command.

```bash
kubectl get nodes
```

| export KUBECONFIG= | Management cluster kubeconfig \_ \_ | .conf |
| ------------------ | ----------------------------------- | ----- |

##### EKS: Creating a kubeconfig File

About this task

To get started, ensure you have kubectl set up and configured with
ClusterAdmin for the cluster you want to connect to Kommander. For more
information, see kubectl and ClusterAdmin.

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
   kommander-cluster-admin-config . The contents of this file are used in
   Kommander to attach the cluster. Before importing this configuration, verify
   the kubeconfig file can access the cluster.

```bash
kubectl --kubeconfig $(pwd)/kommander-cluster-admin-config get all --all-namespaces
```

#### EKS: Attaching the EKS Cluster Through the UI

About this task

Finish attaching the EKS Cluster from the UI. Starting in the Nutanix
Kubernetes Platform (NKP) UI, perform the following steps.

Procedure

1. From the top menu bar, select your target workspace.
2. On the Dashboard page, select the Add Cluster option in the Actions
   dropdown menu at the top right.
3. Select Attach Cluster.
4. Select the No additional networking restrictions card. Alternatively, if
   you must use network restrictions, stop following the steps below and see
   the instructions on the page Cluster Attachment with Networking Restrictions
   on page 492.
5. Upload the kubeconfig file you created in the previous section (or copy its
   contents) into the Cluster Configuration section.
6. The Cluster Name field automatically populates with the name of the cluster
   in the kubeconfig. You can edit this field using the name you want for your
   cluster.
7. Add labels to classify your cluster as needed.
8. Select Create to attach your cluster.

```yaml
Note: If a cluster has limited resources to deploy all the federated platform services, it will fail to stay attached to
the NKP UI. If this happens, ensure your system has sufficient resources for all pods.
```

#### EKS: Attaching an EKS Cluster Through the CLI

About this task

Starting with Nutanix Kubernetes Platform (NKP) 2.6, when you create a Managed
Cluster with the NKP CLI, it attaches automatically to the Management Cluster
after a few moments.

However, the attached cluster will be created in the default workspace if you
do not set a workspace. To ensure that the attached cluster is created in your
desired workspace namespace, follow these instructions:

```yaml
Warning: These steps only apply if you do not set a WORKSPACE_NAMESPACE when creating a cluster. If you
already set a WORKSPACE_NAMESPACE, then you do not need to perform these steps since the cluster is already
attached to the workspace.
```

Procedure

1. Confirm you have your MANAGED_CLUSTER_NAME variable set using the command
   echo ${MANAGED_CLUSTER_NAME}.
2. Retrieve your kubeconfig from the cluster you have created without setting
   a workspace using the command nkp get kubeconfig --cluster-name
   $MANAGED_CLUSTER_NAME > $MANAGED_CLUSTER_NAME.conf

- get kubeconfig --cluster-name $; MANAGED CLUSTER NAME; > $; MANAGED CLUSTER
  NAME; .conf

| --- | --- | --- | --- | --- |

1. You can now attach it in the UI (link to attaching it to workspace through
   UI that was earlier) or attach your cluster to the workspace you want in the
   CLI.

> **Note: This is only necessary if you never set the workspace of your
> cluster upon creation** 4. Retrieve the workspace where you want to attach
> the cluster using the command kubectl get workspaces -A . 5. Set the
> WORKSPACE_NAMESPACE environment variable using the command export
> WORKSPACE_NAMESPACE=workspace-namespace. 6. Create a secret in the desired
> workspace before attaching the cluster to that workspace. Retrieve the
> kubeconfig secret value of your cluster using the command kubectl -n
> default get secret $MANAGED_CLUSTER_NAME-kubeconfig -o go-
> template='{.data.value}{"\n"}' 7. This will return a lengthy value. Copy
> this entire string for a secret using the template below as a reference.
> Create a new attached-cluster-kubeconfig.yaml file.

```yaml
apiVersion: v1
kind: Secret
metadata:
name: your-managed-cluster-name-kubeconfig
labels:
cluster.x-k8s.io/cluster-name: your-managed-cluster-name
type: cluster.x-k8s.io/secret
data:
value: value-you-copied-from-secret-above
```

1. Create this secret in the desired workspace using the command kubectl apply
   -f attached-cluster- kubeconfig.yaml --namespace $WORKSPACE_NAMESPACE.
2. Create this nkpcluster object to attach the cluster to the workspace Example:

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
   confirm its status by using the command kubectl get nkpclusters -A. It may
   take a few minutes to reach "Joined" status.

| WORKSPACE NAMESPACE= | workspace-namespace |
| -------------------- | ------------------- |

- $; MANAGED CLUSTER NAME; -kubeconfig -o go-template='{; .data.value; }{;
  "\n"; }'

| --- | --- | --- | --- | --- | --- | --- |

| kubeconfig.yaml --namespace $ | WORKSPACE NAMESPACE | .   |
| ----------------------------- | ------------------- | --- |

1. If you have several Pro Clusters and want to turn one of them into a
   Managed Cluster to be centrally administrated by a Management Cluster, see
   Platform Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate
   Managed Cluster on page 519.

What to do next

Cluster Management on page 458.

For more information on related topics, see:

- Cluster Management on page 458

### EKS: Deleting an EKS Cluster Through the CLI

- Configuring and Running Amazon EKS Clusters in the Amazon documentation site
  `<https://aws.amazon.com/>` eks/.

About this task

```yaml
Note: Ensure that the KUBECONFIG environment variable is set to the self-managed cluster by running export
KUBECONFIG={SELF_MANAGED_AWS_CLUSTER}.conf.
```

If you prefer to continue working in the terminal or shell using the CLI, the
steps for deleting the cluster are listed below. If you are in the NKP UI, you
can also delete the cluster from the UI using the steps on this page: Delete
EKS Cluster from the NKP UI

Follow these steps for deletion from the CLI:

Procedure

1. Ensure your AWS credentials are up to date. If you use user profiles,
   refresh the credentials using the command below. Otherwise, proceed to step
2.

```bash
nkp update bootstrap credentials aws
```

1. Important: Do not skip this step if the VPC is managed by Nutanix
   Kubernetes Platform (NKP). When NKP deletes the cluster, it deletes the VPC.
   If the VPC has any EKS Classic ELBs, EKS does not allow the VPC to be
   deleted, and NKP cannot delete the cluster.

Delete the Kubernetes cluster and wait a few minutes. Before deleting the
cluster, nkp deletes all Services of type LoadBalancer on the cluster. Service
is backed by an AWS Classic ELBAn, and an AWS Classic ELB backs each service.
Deleting the Service deletes the ELB that backs it. To skip this step, use the
flag --delete- kubernetes-resources=false.

```bash
nkp delete cluster --cluster-name=${CLUSTER_NAME}
```

Example output

```bash
# Deleting Services with type LoadBalancer for Cluster default/eks-example
# Deleting ClusterResourceSets for Cluster default/eks-example
# Deleting cluster resources (2)
# Waiting for cluster to be fully deleted
Deleted default/eks-example cluster
```

Known Limitations:

The NKP version used to create the managed cluster must match the DKP version
used to delete the managed cluster.

### EKS: Deleting an EKS Cluster from the NKP UI

About this task

To delete a cluster in the UI, you must first EKS: Creating an EKS Cluster
from the UI on page 838 and have permission to delete.

Procedure

1. Open the dashboard and select Clusters in the left menu.
2. Select the cluster you wish to delete and click the triple dot vertical
   icon in the bottom right corner.
3. Then select Delete in red.

Figure 22: Delete EKS Cluster 4. When the next screen appears, copy the name
of your cluster and paste it into the empty box. 5. Now execute the deletion
using the Delete Cluster button.

Figure 23: Delete EKS Cluster Button 6. You will see the status as "Deleting"
in the top left corner of the cluster you selected for deletion.

What to do next

For a generic overview of deleting clusters within the UI and troubleshooting,
see the Disconnecting or Deleting Clusters on page 543 instructions.

### EKS: Manage Node Pools

```yaml
Note: Ensure that the KUBECONFIG environment variable is set to the self-managed cluster by running export
KUBECONFIG={SELF_MANAGED_AWS_CLUSTER}.conf.
```

Node pools are part of a cluster and are managed as a group. They can be used
to manage a group of machines using common properties. New default clusters
created by Konvoy contain one node pool of worker nodes with the same
configuration.

You can create additional node pools for specialized hardware or other
configurations. For example, suppose you want to tune your memory usage on a
cluster where you need maximum memory for some machines and minimal memory for
others. In that case, you can create a new node pool with those specific
resource needs.

> **Note: Konvoy implements node pools using Cluster API MachineDeployments.**

#### EKS: Creating a Node Pool

About this task

Availability zones (AZs) are isolated locations within datacenter regions
where public cloud services originate and operate. Because all the nodes in a
node pool are deployed in a single Availability Zone, you may wish to create
additional node pools to ensure your cluster has nodes deployed in multiple
Availability Zones.

```yaml
Note: By default, the first Availability Zone in the region is used for the nodes in the node pool. To create the nodes
in a different Availability Zon,e set the appropriate --availability-zone. For more information, see https://
aws.amazon.com/about-aws/global-infrastructure/regions_az/.
```

Procedure

To create a new EKS node pool with 3 replicas, run.

```bash
nkp create nodepool eks ${NODEPOOL_NAME} \
--cluster-name=${CLUSTER_NAME} \
--replicas=3
machinedeployment.cluster.x-k8s.io/example created
awsmachinetemplate.infrastructure.cluster.x-k8s.io/example created
eksconfigtemplate.bootstrap.cluster.x-k8s.io/example created
# Creating default/example nodepool resources
```

Advanced users can use a combination of the --dry-run and --output=yaml flags
to get a complete set of node pool objects to modify locally or store in
version control.

#### EKS: Scaling Up Node Pools

About this task

To scale up a node pool in a cluster, complete the tasks.

Procedure

1. Run the following command.

```bash
nkp scale nodepools
nkp scale nodepools ${NODEPOOL_NAME} --replicas=5 --cluster-name=${CLUSTER_NAME}
```

Example output indicating the scaling is in progress.

```bash
# Scaling node pool example to 5 replicas
```

1. After a few minutes, you can list the node pools to.

```bash
nkp get nodepools --cluster-name=${CLUSTER_NAME}
```

Example output showing the number of DESIRED and READY replicas increased to 5.

```bash
NODEPOOL DESIRED READY
KUBERNETES VERSION
example 5 5
v<kubernetes-version>
eks-example-md-0 4 4
v<kubernetes-version>
```

#### EKS: Deleting EKS Node Pools

About this task

Deleting a node pool deletes the Kubernetes nodes and the underlying
infrastructure. All nodes are drained before deletion, and the pods running on
those nodes are rescheduled.

Procedure

1. To delete a node pool from a managed cluster using the command.

```bash
nkp delete nodepool ${NODEPOOL_NAME} --cluster-name=${CLUSTER_NAME}
```

The expected output will be similar to the following example, indicating the
node pool is being deleted.

```bash
# Deleting default/example nodepool resources
```

1. Deleting an invalid node pool results in output similar to this example.

```bash
nkp delete nodepool ${CLUSTER_NAME}-md-invalid --cluster-name=${CLUSTER_NAME}
MachineDeployments or MachinePools.infrastructure.cluster.x-k8s.io "no
MachineDeployments
or MachinePools found for cluster eks-example" not found
```

## vSphere Infrastructure

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

vSphere Overview

vSphere is a more complex setup than other providers and infrastructures, so
an overview of steps has been provided to help.

The overall process for configuring vSphere and Nutanix Kubernetes Platform
(NKP) together includes the following steps:

1. Configure vSphere to provide the elements described in the vSphere
   Prerequisites. 2. For more information on air-
   gapped environments, see Creating a Bastion Host on page 707. 3. Create a
   base
   OS image (for use in the OVA package
   containing the disk images packaged with the OVF). 4. Create a CAPI VM image
   template that uses the base OS image and
   adds the needed Kubernetes cluster components. 5. Create a bootstrap cluster.
2. Create a new self-managing NKP cluster
   on vSphere. 7. Install Kommander.
3. Verify and log in to the UI.

Figure 24: vSphere Image Creation Process

The workflow on the left shows the creation of a base OS image in the vCenter
vSphere client using inputs from Packer. The workflow on the right shows how
NKP uses that same base OS image to create CAPI-enabled VM images for your
cluster.

After creating the base image, the NKP image builder uses it to create a CAPI-
enabled vSphere template that includes the Kubernetes objects for the cluster.
You can use that resulting template with the NKP create cluster command to
create the VM nodes in your cluster directly on a vCenter server.

You can NKP to provision and manage your cluster from that point NKP
communicates with the code in vCenter Server as the management layer for
creating and managing virtual machines after ESXi v7.0.3 or later is installed
and configured. For more information, see `<<https://docs.vmware.com/en/VMware->`
vSphere/7.0/>
com.vmware.esxi.install.doc/GUID-B2F01BF5-078A-4C7E-B505-5DFFED0B8C38.html.

### vSphere Prerequisites

This section contains all the prerequisite information specific to VMware
vSphere infrastructure. These are above and beyond all of the NKP
prerequisites for Install. Fulfilling the prerequisites involves completing
these two areas:

1. NKP Prerequisites

Before using NKP to create a vSphere cluster, verify that you have:

- An x86_64-based Linux or macOS machine.
- Download NKP binaries image bundle for Linux or macOS.
- A Container engine or runtime installed is required to install NKP and
  bootstrap:
- Docker container engine version 27.4.0 installed for Linux or MacOS. For
  more information, see https:// docs.docker.com/get-docker/.
- Podman Version 4.0 or later for Linux. For more information, see
  `<https://podman.io/getting-started/>` installation. For host requirements,
  see `<https://kind.sigs.k8s.io/docs/user/rootless/#host-requirements>`.
- A registry needs to be installed on the host where the NKP Konvoy CLI runs.
  For example, if you install Konvoy on your laptop, ensure the computer has a
  supported version of Docker or other registry.

> **Note: On macOS, Docker runs in a virtual machine. Configure this virtual
> machine with at least 8GB of memory.**

- The host running the NKP CLI must have kubectl version 1.35.x installed.

For more information, see kubectl.

- A valid VMware vSphere account with credentials configured.

```yaml
Note: NKP uses the vsphere CSI driver as the default storage provider. Use a Kubernetes CSI-compatible storage
that is suitable for production. For more information, see https://kubernetes.io/docs/concepts/storage/
volumes/#volume-types.
```

You can choose from any of the storage options available for Kubernetes. To
disable the default that Konvoy deploys, set the default StorageClass
localvolumeprovisioner as non-default. Then, set your newly created
StorageClass as the default by following the commands in the Kubernetes
documentation called Changing the Default Storage Class
(`<<https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage->`
class/>).

VMware vSphere Prerequisites

Before installing, verify that your VMware vSphere Client environment
(`<https://techdocs.broadcom.com/us/en/>` vmware-
cis/vsphere/vsphere/6-7/vsphere-virtual-machine-administration-guide-6-7.html)
meets the following basic requirements:

- Access to a bastion VM or other network-connected host running vSphere
  Client version 7.0.3 or later.
- You must reach the vSphere API endpoint from where the Konvoy command line
  interface (CLI) runs.
- vSphere account with credentials configured - this account must have
  Administrator privileges.
- A Red Hat subscription with a username and password for downloading DVD ISOs.
- For air-gapped environments, a bastion VM host template with access to a
  configured local registry. The recommended template naming pattern is
  ../folder-name/NKP-e2e-bastion-template or similar. Each infrastructure
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
- Valid values for the following:
- vCenter server URL.
- Datacenter name.
- Zone name that contains ESXi hosts for your cluster's nodes. For more
  information, see `<<https://docs.vmware.com/en/VMware->`
  vSphere/7.0/com.vmware.esxi.install.doc/GUID->
  B2F01BF5-078A-4C7E-B505-5DFFED0B8C38.html
- Datastore name for the shared storage resource to be used for the VMs in the
  cluster.
- The use of Persistent Volumes in your cluster depends on Cloud Native
  Storage (CNS), which is available in vSphere v7.0.3 and later versions. CNS
  depends on this shared datastore's configuration.
- Datastore URL from the datastore record for the shared datastore you want
  your cluster to use.
- You need this URL value to ensure the correct Datastore is used when NKP
  creates VMs for your cluster in vSphere.
- Folder name.
- Base template names, such as base-rhel-8.
- Name of a Virtual Network with DHCP enabled for air-gapped and non-air-
  gapped environments.
- Resource Pools - at least one resource pool is needed, with every host in
  the pool having access to shared storage, such as VSAN.
- Each host in the resource pool needs access to shared storage, such as NFS
  or VSAN, to use MachineDeployments and high-availability control planes.

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

Table 72: vSphere Permissions Propagation

vCenter Server (Top Level) Yes No

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

| Level | Required | Propagate to Child |
| ----- | -------- | ------------------ |

Cluster

X View

ESX Host 1

X View

ESX Host 2

X View

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

#### vSphere: Base OS Image in vCenter

Creating a base OS image from DVD ISO files is a one-time process in vCenter.
The base OS image file is created in the vSphere Client for use in the vSphere
VM template. Therefore, Nutanix Image Builder (NIB) uses the base OS image to
create a VM template to configure Kubernetes nodes by the Nutanix Kubernetes
Platform (NKP) vSphere provider. For more information about images in vSphere
vCenter, refer to VMware documentation.

The Base OS Image

For vSphere, SSH_USERNAME populates a username, and the user can use
authorization through SSH_PASSWORD or SSH_PRIVATE_KEY_FILE environment
variables and required by default by packer. This user needs administrator
privileges. It is possible to configure a custom user and password when
building the OS image; however, that requires the Nutanix Image Builder (NIB)
configuration to be overridden.

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

Disk Size

For each cluster you create using this base OS image, ensure you establish the
disk size of the root file system based on the following:

- The minimum NKP Resource Requirements.
- The minimum storage requirements for your organization.

Defaults

Clusters are created with a default disk size of 80 GB.

```yaml
Warning: For clusters created with the default disk size, the base OS image root file system must be exactly 80 GB.
The root file system cannot be reduced automatically when a machine first boots.
```

Customization

: You can specify a custom disk size when creating a cluster (see the flags
available for use with the vSphere Create Cluster command). This allows you to
use one base OS image to create multiple clusters with different storage
requirements.

Before specifying a disk size when you create a cluster, take into account:

- For some base OS images, the custom disk size option does not affect the
  size of the root file system. This is because some root file systems, for
  example, those contained in an LVM Logical Volume, cannot be resized
  automatically when a machine first boots.
- The specified custom disk size must be equal to, or larger than, the size of
  the base OS image root file system. This is because a root file system
  cannot be reduced automatically when a machine first boots.

This Base OS Image is later used toCreate during installation and cluster
creation.

If using Flatcar, the documentation from Flatcar regarding disabling or
enabling autologin in the Base OS Image is found here: In a vSphere or Pre-
provisioned environment, anyone with access to the console of a Virtual
Machine(VM) has access to the core operating system user. This is called
autologin. To disable autologin, you add parameters to your base Flatcar
image. For more information on using Flatcar, see

- Running Flatcar Container Linux on VMware:
  `<https://www.flatcar.org/docs/latest/installing/cloud/vmware/>`
  #disablingenabling-autologin
- Kernel modules and other settings:
  `<https://www.flatcar.org/docs/latest/setup/customization/other-settings/>`
  #adding-custom-kernel-boot-options

#### vSphere: Infrastructure Storage Options

Explore storage options and considerations for using NKP with VMware vSphere.

The vSphere Container Storage plugin
(`<https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/container->` storage-
plugin/2-0/getting-started-with-vmware-vsphere-container-storage-plug-
in-2-0.html) supports shared NFS, vNFS, and vSAN. You must provision your
storage options in vCenter before creating a CAPI image (vSphere Non-Air-
gapped: Creating a CAPI VM Template on page 868 or vSphere Air-gapped:
Creating an Air- gapped CAPI VM Template on page 884) in NKP for use with
vSphere.

NKP has integrated the CSI 2.x driver used in vSphere. When creating your NKP
cluster, NKP uses whatever configuration you provide for the Datastore name.
vSAN is not required. Using NFS can reduce the tagging and permission granting
needed to configure your cluster.

### vSphere Cluster Creation Customization Choices

Below are two methods to customize your cluster during creation. If none of
these choices apply, proceed to the next section.

- vSphere Installation in a Non-air-gapped Environment on page 868
- vSphere Installation in an Air-Gapped Environment on page 883

vSphere Section Topics

When creating clusters, many options are available such as those listed in
this section of the documentation. Familiarize yourself with the flags
required to apply these customizations during cluster creation.

- vSphere Customizing CAPI Clusters: Familiarize yourself with Cluster API
  before editing the cluster objects because edits can prevent the cluster
  from deploying successfully. For more information, see CAPI Concepts and
  Terms on page 21.
- vSphere Registry Mirrors: Configure your cluster to use an existing local
  registry (Registry Mirror Tools on page 1028) when attempting to pull images
  by adding the flag(s) to the nkp create cluster command to pull images from
  your local registry.
- vSphere Loading the Registry: Because air-gapped environments do not have
  direct access to the Internet, you must download, extract and load several
  required images to your local container registry, before installing

NKP. If desired, environments that are non-air-gapped can also perform the
follow steps to use a local registry for speed and security reasons.

- vSphere HTTP Proxy: When creating a NKP cluster in environments that use an
  HTTP/HTTPS proxy, you must provide proxy details. The proxy values are
  strings that list a set of proxy servers, URLs, or wildcard addresses that
  is specific to your environment.
- vSphere Provision on the Flatcar Linux OS: When provisioning onto the
  Flatcar Container Linux distribution, you must instruct the bootstrap
  cluster to make some changes related to the installation paths. To
  accomplish this, add the --os-hint flatcar flag to the nkp create cluster
  command.
- Configure MetalLB for a vSphere infrastructure: Nutanix recommends that an
  external load balancer (LB) be the control plane endpoint. To distribute
  request load among the control plane machines, configure the load balancer
  to send requests to all the control plane machines. Configure the load
  balancer to send requests only to control plane machines that are responding
  to API requests. If you do not have one, you can use Metal LB to create a
  MetalLB configmap for your vSphere infrastructure.
- vSphere Output Directory YAML: You can create individual files with
  different smaller manifests for ease in editing using the --output-directory
  flag used with --output=json|yaml. You create the directory of where to
  output resources to files.

#### vSphere: Customizing CAPI Clusters

Familiarize yourself with Cluster API before editing the cluster objects
because edits can prevent the cluster from deploying successfully.

The result of this command will allow such edits:

```bash
nkp create cluster vsphere \
--cluster-name=${CLUSTER_NAME} \
--dry-run \
--output=yaml \
> ${CLUSTER_NAME}.yaml
```

To edit the YAML, you need to understand the CAPI components to avoid breaking
the cluster.

#### vSphere: Registry Mirrors

Configure your cluster to use an existing local registry (Registry Mirror
Tools on page 1028) when attempting to pull images by adding the flag(s) to
the nkp create cluster command to pull images from your local registry.

Kubernetes does not natively provide a registry for hosting the container
images you will use to run the applications you want to deploy on Kubernetes.
Instead, Kubernetes requires you to use an external solution to store and
share container images. A variety of Kubernetes-compatible registry options
are compatible with NKP.

How the Registry Mirror Works

The first time you request an image from your local registry mirror, it pulls
the image from the public registry (such as Docker) and stores it locally
before handing it back to you. On subsequent requests, the local registry
mirror can serve the image from its storage.

Air-gapped vs. Non-air-gapped Environments

In a non-air-gapped environment, you can access the Internet. You retrieve
artifacts from specialized repositories dedicated to them, such as Docker
images contained in DockerHub and Helm Charts that come from a dedicated Helm
Chart repository. You can also create your local repository to hold the
downloaded container images needed or any custom images you've created with
the Nutanix Image Builder on page 51 tool.

In an air-gapped environment, you need a local repository to store Helm
charts, Docker images, and other artifacts. Private registries provide
security and privacy in enterprise container image storage, whether hosted
remotely or on- premises locally in an air-gapped environment. NKP in an air-
gapped environment requires a local container registry

of trusted images to enable production-level Kubernetes cluster management.
However, a local registry is also an option in a non-air-gapped environment
for speed and security.

If you want to use images from this local registry to deploy applications
inside your Kubernetes cluster, you'll need to set up a secret for a private
registry. The secret contains your login data, which Kubernetes needs to
connect to your private repository.

More information and detail can be found:

- Registry Mirror Tools on page 1028
- Using a Registry Mirror on page 1030

#### vSphere: Loading the Registry

About this task

Because air-gapped environments do not have direct access to the Internet, you
must download, extract and load several required images to your local
container registry, before installing NKP.

If desired, environments that are non-air-gapped can also perform the follow
steps to use a local registry for speed and security reasons.

Load Images into your Registry

Because air-gapped environments do not have direct access to the Internet, you
must download, extract and load several required images to your local
container registry, before installing NKP.

Before you begin

Download all Images for Air-gapped Deployments

If you are operating in an air-gapped environment, a local container registry
containing all the necessary installation images, including the Kommander
images, is required. See below for prerequisites to download and then how to
push the necessary images to this registry.

1. Download the Complete NKP Air-gapped Bundle for this release (i.e. nkp-air-
   gapped-bundle_nkp-

version_linux_amd64.tar.gz) to load registry images as explained below. 2.
Connectivity with clusters attaching to the management cluster is required:

- Both management and attached clusters must be able to connect to the local
  registry.
- The management cluster must be able to connect to all attached cluster's API
  servers.
- The management cluster must be able to connect to any load balancers created
  for platform services on the management cluster.

Extract Air-gapped Images and Set Variables

Follow these steps to extract the air-gapped image bundles into your private
registry using these examples for ECR:

Procedure

1. If not already done in prerequisites, download the air-gapped bundle nkp-
   air-gapped-bundle_nkp-

version_linux_amd64.tar.gz, and extract the tar file to a local directory. 2.
The directory structure after extraction can be accessed in subsequent steps
using commands to access files from different directories. EX: For the
bootstrap cluster, change your directory to the nkp-`<version>` directory,
similar to the example below, depending on your current location

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

| tar -xzvf nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ---------------------------------- | ----------- | ------------------------ |

| cd nkp- | nkp-version | Col3 |
| ------- | ----------- | ---- |

1. Set an environment variable with your registry address for ECR.

Registry flags to use during cluster creation:

For other registries, more environment variables are:

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
```

For more information, see Using a Registry Mirror on page 1030.

Definitions:

- REGISTRY_URL: the address of an existing local registry accessible in the
  VPC that the new cluster nodes will be configured to use a mirror registry
  when pulling images.

Other local registries may use the options below:

- JFrog - REGISTRY_CA: (optional) the path on the bastion machine to the
  registry CA. This value is only needed if the registry is using a self-
  signed certificate and the AMIs are not already configured to trust this CA.
- REGISTRY_USERNAME: optional-set to a user that has pull access to this
  registry.
- REGISTRY_PASSWORD: optional if username is not set.

1. Load Images to your Private Registry - Konvoy

Before creating or upgrading a Kubernetes cluster, you need to load the
required images in a local registry if operating in an air-gapped environment.
This registry must be accessible from both the bastion machine and either the
AWS EC2 instances or other machines that will be created for the Kubernetes
cluster.

```yaml
Warning: If you do not already have a local registry set up, refer to Local Registry Tools page for more
information.
```

Execute the following command to load the air-gapped image bundle into your
private registry:

```bash
dkp push bundle --bundle ./container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
Note: It may take some time to push all the images to your image registry, depending on the performance of the
network between the machine you are running the script on and the registry.
```

For specific push flags, refer to the nkp push bundle section of CLI commands.

Additional Flags for Registry push:

The push command will be different depending on username and password
requirements:

If not ECR as shown in the example code below, use the other relevant flags:
--to-registry= ${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME}
--to-registry-password= ${REGISTRY_PASSWORD}

```bash
nkp push bundle --bundle ./container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by
setting the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

1. Load the Kommander component images to your private registry using the
   command.

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-nkp-version.tar
--to-registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-
registry-password=${REGISTRY_PASSWORD}
```

Additional Flags for Registry push:

If not using ECR, the push command will be different depending on username and
password requirements:

The push command will be different depending on username and password
requirements:

```bash
nkp push bundle --bundle ./container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
```

1. On the Bastion, load the Konvoy bootstrap image, using either the Docker or
   Podman command. Docker example:

Podman example:

```bash
podman load -i konvoy-bootstrap-image-nkp-version.tar
podman image tag konvoy-bootstrap:vnkp-version docker.io/mesosphere/konvoy-
bootstrap:vnkp-version
```

> **Note: Replace v nkp-version with the version number. For example, here
> it is v2.15.0.**

#### vSphere: HTTP Proxy

When creating a NKP cluster in environments that use an HTTP/HTTPS proxy, you
must provide proxy details. The proxy values are strings that list a set of
proxy servers, URLs, or wildcard addresses that is specific to your
environment.

If your environment uses HTTP/HTTPS proxies, you must include the flags and
their related values in commands for the proxy to be successful throughout
various steps of installation:

- --http-proxy
- --https-proxy
- --no-proxy

Create the bootstrap cluster and CAPI components using the appropriate
commands, nkp create bootstrap and nkp create capi-components respectively,
combined with the command line flags to include your HTTP/S proxy information.

You can also specify HTTP/S proxy information in an override file when using
Nutanix Image Builder on page 51.

Without these values provided as part of the relevant nkp create command, DKP
cannot create the requisite parts of your new cluster correctly. This is true
of both management and managed clusters alike.

To create a proxied environment, you need to include flags at various action
item points:

- Bootstrap cluster
- CAPI components
- Cluster creation
- NKP Kommander component

| docker load -i konvoy-bootstrap-image- | nkp-version | .tar |
| -------------------------------------- | ----------- | ---- |

For full HTTP Proxy configuration, you need to specify proxy settings using
all the details in the Cluster Creation with HTTP or HTTPS Proxy on page 699
section of the documentation for:

- Creating a Bootstrap Cluster with HTTP Proxy Settings on page 697
- Creating CAPI Components with HTTP or HTTPS Proxy Settings on page 698
- Cluster Creation with HTTP or HTTPS Proxy on page 699
- HTTP or HTTPS Proxy Configuration for the NKP Kommander Component on page 700

HTTP Proxy Example

```bash
nkp create cluster vsphere \
--cluster-name ${CLUSTER_NAME} \
--control-plane-http-proxy="${CONTROL_PLANE_HTTP_PROXY}" \
--control-plane-https-proxy="${CONTROL_PLANE_HTTPS_PROXY}" \
--control-plane-no-proxy="${CONTROL_PLANE_NO_PROXY}" \
--worker-http-proxy="${WORKER_HTTP_PROXY}" \
--worker-https-proxy="${WORKER_HTTPS_PROXY}" \
--worker-no-proxy="${WORKER_NO_PROXY}"
```

#### vSphere: Provision Flatcar Linux OS

Flatcar default network interface name might require specifying. It is most
likely to be ens192 , which requires passing the parameter --virtual-ip-
interface ens192 to the nkp create cluster vsphere command. Otherwise, the
cluster creation might fail because kube-vip can not configure the first
control-plane virtual IP.

Flatcar Linux Example

These flags are also shown in context on the Create Cluster page for either
air-gapped or non-air-gapped environments:

```bash
nkp create cluster vsphere \
--cluster-name ${CLUSTER_NAME} \
--os-hint flatcar
Note: For provisioning NKP on Flatcar, NKP configures cluster nodes to use Control Groups (cgroups) version 1. In
versions before Flatcar 3033.3.x, a restart is required to apply the changes to the kernel.
```

Also note that once Ignition runs, it is not available on reboot.

For more information on Flatcar usage, see:

- Flatcar documentation: `<<https://www.flatcar.org/docs/latest/container->`
  runtimes/switching-to-> unified-cgroups/#starting-new-nodes-with-legacy-
  cgroups
- Control Groups version 1:`<<https://www.kernel.org/doc/html/latest/admin->`
  guide/cgroup-v1/> cgroups.html#what-are-cgroups
- Ignition
  `<<https://www.flatcar.org/docs/latest/provisioning/ignition/#ignition-only->`
  runs-once>

#### vSphere: Configuring MetalLB

Create MetalLB configuration for your vSphere infrastructure.

Nutanix recommends that an external load balancer(LB) be the control plane
endpoint. To distribute request load among the control plane machines,
configure the load balancer to send requests to all the control plane
machines. Configure the load balancer to send requests only to control plane
machines that are responding to API requests. If you do not have one, you can
use Metal LB to create a MetalLB configmap for your vSphere infrastructure.

Choose one of the two protocols you want to use to announce service IPs. If
your environment is not currently equipped with a load balancer, you can use
MetalLB, a load balancer implementation for Kubernetes. Otherwise, your

load balancer will work, and you can continue the installation process with
vSphere Non-Air-gapped: Installing Kommander on page 880. To use MetalLB,
create MetalLB custom resources for your vSphere infrastructure, MetalLB uses
one of two protocols to expose Kubernetes services.

Select one of the following procedures to create your MetalLB manifest for
further editing:

- Layer 2, with Address Resolution Protocol (ARP)
- Border Gateway Protocol (BGP)

Layer 2 Configuration

Layer 2 mode is the simplest to configure: in many cases, you don't need any
protocol-specific configuration, only IP addresses. It does not require the
IPs to be bound to the network interfaces of your worker nodes. It responds to
ARP requests on your local network directly and gives clients the machine's
MAC address.

> **Warning:**

- MetalLB IP address ranges or CIDRs must be within the node's primary network
  subnet. For more information, see Cluster Pod and Services Subnets on page

1.

- MetalLB IP address ranges, CIDRs, and node subnets must not conflict with
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
instructions for use with Cloud providers is the same.

For a standard configuration featuring one BGP router and one IP address
range, you need four pieces of information:

- The router IP address that MetalLB needs to connect to.
- The router's autonomous systems (AS) number.
- The AS number MetalLB is to be used.
- An IP address range is a Classless Inter-Domain Routing (CIDR) prefix.

As an example, if you want to give MetalLB the range 192.168.10.0/24 and AS
number 64500 and connect it to a router at 10.0.0.1 with AS number 64501, your
configuration will look like this:

> **Note: The following values are generic, enter your specific values into
> the fields where applicable.**

Extract the kubeconfig and deploy a config map for MetalLB using the following
command:

```bash
nkp get kubeconfig -c ${DKP_CLUSTER_NAME} > ${NKP_CLUSTER_NAME}.conf
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

#### vSphere: Output Directory YAML

You can create individual files with different smaller manifests for ease in
editing using the --output-directory flag used with --output=json|yaml. You
create the directory of where to output resources to files.

Using this flag will create multiple files in the specified directory which
must already exist:

```bash
nkp create cluster vsphere
--cluster-name=${CLUSTER_NAME} \
--dry-run \
--output=yaml \
--output-directory=<existing-directory>
```

For more information regarding this flag or others, please refer to the CLI
section of the documentation for the nkp create cluster command and select
your provider.

### vSphere Installation in a Non-air-gapped Environment

This installation provides instructions on how to install Nutanix Kubernetes
Platform (NKP) in a vSphere non-air- gapped environment.

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

Before you begin using NKP, you must ensure you meet the other prerequisites
in the vSphere Prerequisites section.

In an environment with access to the Internet, you retrieve artifacts from
specialized repositories dedicated to them, such as Docker images contained in
DockerHub and Helm Charts that come from a dedicated Helm Chart repository.
However, in an air-gapped environment, you need local repositories to store
Helm charts, Docker images, and other artifacts. Tools such as JFrog, Harbor,
and Nexus handle multiple types of artifacts in one local repository.

```yaml
Tip: A local registry can also be used in a non-air-gapped environment for speed and security if desired. To do so, add
the following steps to your non-air-gapped installation process. See the topic Registry Mirror Tools and vSphere:
Loading the Registry on page 862.
```

#### vSphere Non-Air-gapped: Creating a CAPI VM Template

About this task

You must have at least one image before creating a new cluster. As long as you
have an image, this step in your configuration is not required each time since
that image can be used to spin up a new cluster. However, if you need
different images for different environments or providers, you must create a
new custom image.

Using NIB, you can build an image without requiring access to the internet by
providing an additional offline -- override flag. You can use the overrides
files to customize some of the components installed on your machine image. For
example, you could tell NIB to install the FIPS versions of the Kubernetes
components.

Procedure

For more steps, see Building a Custom Image with vSphere on page 64.

#### vSphere Non-Air-gapped: Bootstrapping vSphere

About this task

To get started, you need a bootstrap cluster. By default, Nutanix Kubernetes
Platform (NKP) creates a bootstrap cluster for you in a Docker container using
the Kubernetes-in-Docker (KIND) tool.

Procedure

1. Complete the Nutanix Infrastructure Prerequisites. For more information,
   see Nutanix Infrastructure Requirements on page 719.
2. Ensure the NKP binary can be found in your $PATH.

##### Bootstrap Cluster Life Cycle Services

Procedure

1. Review Universal Configurations for all Infrastructure Providers regarding
   settings, flags and other choices and then begin bootstrapping.
2. Create a bootstrap cluster using the command.

```bash
nkp create bootstrap --kubeconfig $HOME/.kube/config
Note: Use --http-proxy, --https-proxy, and --no-proxy and their related values in this command for
it to be successful. For more information, see Configuring an HTTP or HTTPS Proxy on page 696.
```

Example output:

```bash
# Creating a bootstrap cluster (4)
# Initializing new CAPI components (6)
```

To create a bootstrap cluster in a proxied environment (Bootstrap Cluster HTTP
Proxy Settings on page 697), in addition to any other flags you need, run the
following command.

```bash
--http-proxy <string> \
--https-proxy <string> \
--no-proxy <string>
```

1. NKP creates a bootstrap cluster using KIND as a library.

For more information, see `<https://github.com/kubernetes-sigs/kind>`. 4. NKP
then deploys the following Cluster API providers on the cluster.

- Core Provider: `<https://github.com/kubernetes-sigs/cluster-api/tree/v0.3.20/>`
- AWS Infrastructure Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api-provider-aws>
- Kubeadm Bootstrap Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api/tree/v0.3.20/bootstrap/> kubeadm
- Kubeadm ControlPlane Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api/tree/v0.3.20/> controlplane/kubeadm

For more information on Cluster APIs, see `<https://cluster-api.sigs.k8s.io/>`. 5. Ensure that the CAPV controllers are present using the command kubectl get
pods -n capv-system. Output example:

```bash
NAME READY STATUS RESTARTS AGE
capv-controller-manager-785c5978f-nnfns 1/1 Running 0 13h
```

1. NKP waits until the controller-manager and webhook deployments of these
   providers are ready. List these deployments using the command.

```bash
kubectl get --all-namespaces deployments -l=clusterctl.cluster.x-k8s.io
```

Output example:

```bash
NAMESPACE NAME READY UP-
TO-DATE AVAILABLE AGE
capa-system capa-controller-manager
1/1 1 1 1h
capg-system capg-controller-manager
1/1 1 1 1h
capi-kubeadm-bootstrap-system capi-kubeadm-bootstrap-controller-manager
1/1 1 1 1h
capi-kubeadm-control-plane-system capi-kubeadm-control-plane-controller-manager
1/1 1 1 1h
capi-system capi-controller-manager
1/1 1 1 1h
cappp-system cappp-controller-manager
1/1 1 1 1h
capv-system capv-controller-manager
1/1 1 1 1h
capz-system capz-controller-manager
1/1 1 1 1h
cert-manager cert-manager
1/1 1 1 1h
cert-manager cert-manager-cainjector
1/1 1 1 1h
cert-manager cert-manager-webhook
1/1 1 1 1h
```

#### vSphere Non-Air-gapped: Creating a Cluster

About this task

Use this procedure to create a new Kubernetes cluster with Nutanix Kubernetes
Platform (NKP).

If you use these instructions to create a cluster on vSphere using the NKP
default settings without any edits to configuration files or additional flags,
your cluster is deployed on a three control plane nodes, and four worker
nodes. First, you must name your cluster.

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
```

1. Create a new vSphere Kubernetes cluster. To set the environment variables
   for vSphere use the command.

```bash
export VSPHERE_SERVER=<example.vsphere.url>
export VSPHERE_USERNAME=<user@example.vsphere.url>
export VSPHERE_PASSWORD=<example_password>
Note: NKP uses the vSphere CSI driver as the default storage provider. Use a Kubernetes CSI
compatible storage that is suitable for production. For more information, see the Kubernetes documentation
called Changing the Default Storage Class If you're not using the default, you cannot deploy an alternate provider
until after the nkp create cluster is finished. However, this must be determined before the Kommander
installation.
```

1. Ensure your vSphere credentials are up-to-date by refreshing the
   credentials with the command.

```bash
nkp update bootstrap credentials vsphere
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
Warning: Ensure your subnets do not overlap with your host subnet because they cannot be changed after cluster
creation. If you need to change the Kubernetes subnets, you must do this at cluster creation. The default subnets
used in NKP are:
spec:
clusterNetwork:
pods:
cidrBlocks:
- 192.168.0.0/16
services:
cidrBlocks:
- 10.96.0.0/12
```

The following example shows a common configuration. Other options and their
corresponding flags are available in the expands below the code and were also
explained in vSphere Cluster Creation Customization Choices on page 860.

See dkp create cluster vsphere reference for the full list of cluster creation
flags.

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
--virtual-ip-interface <ip_interface_name> \
--vm-template <TEMPLATE_NAME>
--dry-run \
--output=yaml \
> ${CLUSTER_NAME}.yaml
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-
proxy, and --no-proxy with their values in the command to ensure it runs successfully. For more
information, see Configuring an HTTP or HTTPS Proxy on page 696.
```

- Flatcar OS use --os-hint to instruct the bootstrap cluster to make some
  changes related to the installation paths.

```bash
--os-hint flatcar
```

- Export Registry Variables and Flags for Cluster Creation:: If you have a
  local registry, you must provide additional arguments when creating the
  cluster. These tell the cluster where to locate the local registry to use by
  defining the URL. Set the needed environment variable(s) with your registry
  information:

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
  Konvoy will configure the cluster nodes to trust this CA. This value is only
  needed if the registry is using a self-signed certificate and the AMIs are
  not already configured to trust this CA.
- REGISTRY_USERNAME: optional, set to a user that has pull access to this
  registry.
- REGISTRY_PASSWORD: optional if username is not set.

When creating the cluster, apply the variables you defined above during the
dkp create cluster command with the flags needed for your environment:

```bash
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-cacert=${REGISTRY_CA} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD}
```

- FIPS Requirements on page 710
- HTTP Proxy: See Cluster Creation with HTTP or HTTPS Proxy on page 699
- Individual manifests using the Output Directory flag: You can create
  individual manifest files with different smaller manifests for ease in
  editing using the --output-directory flag. For more information, see Output
  Directory Flag on page 710.

```bash
--output-directory=<existing-directory>
```

Refer to the vSphere Cluster Creation Customization Choices on page 860
section for more information on how to use
optional flags such as the --output-directory flag. 6. (Optional) Modify
Control Plane Audit logs - Users can make
modifications to the KubeadmControlplane cluster-api object to configure
different kubelet options. See Control Plane
Configuration on page 1032 if you wish to configure your control plane beyond
the existing options that are available
from flags. 7. Inspect or edit the cluster objects. Familiarize yourself with
the Cluster API before editing the cluster
objects, as edits can prevent the cluster from deploying successfully. 8.
Create the cluster from the objects generated
from the dry run. A warning will appear in the console if the resource already
exists, requiring you to remove the
resource or update your YAML.

```bash
kubectl create -f ${CLUSTER_NAME}.yaml
Note: If you used the --output-directory flag in your nkp create .. --dry-run step above,
create the cluster from the objects you created by specifying the directory:
kubectl create -f <existing-directory>/.
```

Output:

```bash
cluster.cluster.x-k8s.io/vsphere-example created
cluster.infrastructure.cluster.x-k8s.io/vsphere-example created
kubeadmcontrolplane.controlplane.cluster.x-k8s.io/vsphere-example-control-plane
created
machinedeployment.cluster.x-k8s.io/vsphere-example-mp-0 created
kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/vsphere-example-mp-0 created
```

1. Wait for the cluster control plan to be ready.

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --
timeout=20m
```

Output:

```bash
cluster.cluster.x-k8s.io/${CLUSTER_NAME} condition met
```

The READY status becomes True after the cluster control-plane becomes Ready in
one of the following steps. 10. After the objects are created on the API
server, the Cluster API controllers reconcile them. They create infrastructure
and machines. As they progress, they update the Status of each object. Konvoy
provides a command to describe the current status of the cluster.

```bash
nkp describe cluster -c ${CLUSTER_NAME}
```

Output:

```bash
NAME READY SEVERITY
REASON SINCE MESSAGE
Cluster/nutanix-e2e-cluster_name-1 True
13h
##ClusterInfrastructure - VSphereCluster/nutanix-e2e-cluster_name-1 True
13h
##ControlPlane - KubeadmControlPlane/nutanix-control-plane True
13h
# ##Machine/nutanix--control-plane-7llgd True
13h
# ##Machine/nutanix--control-plane-vncbl True
13h
# ##Machine/nutanix--control-plane-wbgrm True
13h
##Workers
##MachineDeployment/nutanix--md-0 True
13h
##Machine/nutanix--md-0-74c849dc8c-67rv4 True
13h
##Machine/nutanix--md-0-74c849dc8c-n2skc True
13h
##Machine/nutanix--md-0-74c849dc8c-nkftv True
13h
##Machine/nutanix--md-0-74c849dc8c-sqklv True
13h
Note: NKP uses the vSphere CSI driver as the default storage provider. Use a Kubernetes CSI compatible
storage that is suitable for production. For more information, see the Kubernetes documentation called Changing
the Default Storage Class If you're not using the default, you cannot deploy an alternate provider until after the
nkp create cluster is finished. However, this must be determined before the Kommander installation. For
more information, see https://kubernetes.io/docs/concepts/storage/volumes/#volume-types and
https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/
```

1. Check all machines has NODE_NAME assigned.

```bash
kubectl get machines
```

Output:

```bash
NAME CLUSTER NODENAME
PROVIDERID PHASE
AGE VERSION
nutanix-e2e-cluster-1-control-plane-7llgd nutanix-e2e-cluster-1 nutanix-e2e-
cluster-1-control-plane-7llgd vsphere://421638e2-e776-9af6-f683-5e105de5da5a
Running 13h v<kubernetes-version>
nutanix-e2e-cluster-1-control-plane-vncbl nutanix-e2e-cluster-1 nutanix-e2e-
cluster-1-control-plane-vncbl vsphere://42168835-7fef-95c4-3652-ebcad3e10d36
Running 13h v<kubernetes-version>
nutanix-e2e-cluster-1-control-plane-wbgrm nutanix-e2e-cluster-1 nutanix-e2e-
cluster-1-control-plane-wbgrm vsphere://421642df-afc4-b6c2-9e61-5b86e7c37eac
Running 13h v<kubernetes-version>
nutanix-e2e-cluster-1-md-0-74c849dc8c-67rv4 nutanix-e2e-cluster-1 nutanix-e2e-
cluster-1-md-0-74c849dc8c-67rv4 vsphere://4216f467-8483-73cb-a8b6-8d6a4a71e4b4
Running 14h v<kubernetes-version>
nutanix-e2e-cluster-1-md-0-74c849dc8c-n2skc nutanix-e2e-cluster-1 nutanix-e2e-
cluster-1-md-0-74c849dc8c-n2skc vsphere://42161cde-9904-4dd2-7a3e-cdfc7655f090
Running 14h v<kubernetes-version>
nutanix-e2e-cluster-1-md-0-74c849dc8c-nkftv nutanix-e2e-cluster-1 nutanix-e2e-
cluster-1-md-0-74c849dc8c-nkftv vsphere://42163a0d-eb8d-b5a6-82d5-188e24817c00
Running 14h v<kubernetes-version>
nutanix-e2e-cluster-1-md-0-74c849dc8c-sqklv nutanix-e2e-cluster-1 nutanix-e2e-
cluster-1-md-0-74c849dc8c-sqklv vsphere://42161dff-92a5-6da9-7ac1-e987e2c8fed2
Running 14h v<kubernetes-version>
```

1. Verify that the kubeadm control plane is ready with the command.

```bash
kubectl get kubeadmcontrolplane
```

Output is similar to:

```bash
NAME CLUSTER INITIALIZED API SERVER
AVAILABLE REPLICAS READY UPDATED UNAVAILABLE AGE VERSION
nutanix-e2e-cluster-1-control-plane nutanix-e2e-cluster-1 true true
3 3 3 0 14h v<kubernetes-
version>
```

1. Describe the kubeadm control plane and check its status and events with the
   command.

```bash
kubectl describe kubeadmcontrolplane
```

1. As they progress, the controllers also create Events, which you can list
   using the command

```bash
kubectl get events | grep ${CLUSTER_NAME}
```

For brevity, this example uses grep. You can also use separate commands to get
Events for specific objects, such as kubectl get events --field-selector
involvedObject.kind="VSphereCluster" and kubectl get events --field-selector
involvedObject.kind="VSphereMachine".

```yaml
Note: NKP uses the AWS CSI driver as the default storage provider. Use a Kubernetes CSI compatible
storage that is suitable for production. For more information, see the Kubernetes documentation called Changing
the Default Storage Class at https://kubernetes.io/docs/concepts/storage/volumes/#volume-types.
If you're not using the default, you cannot deploy an alternate provider until after the nkp create cluster
is finished. However, this must be determined before the Kommander installation.
```

Known Limitations

> **Note: Be aware of these limitations in the current release of NKP Konvoy.**

- • The NKP Konvoy version used to create a bootstrap cluster must match the
  NKP Konvoy version used to create a managed cluster.
- NKP Konvoy supports deploying one managed cluster.
- NKP Konvoy generates a set of objects for one Node Pool.
- NKP Konvoy does not validate edits to cluster objects.

#### vSphere Non-Air-gapped: Making the Cluster Self-Managed

About this task

Nutanix Kubernetes Platform (NKP) deploys all cluster life cycle services to a
bootstrap cluster, which then deploys a managed cluster. When the managed
cluster is ready, move the cluster life cycle services to the workload
cluster, which makes the managed cluster self-managed.

Before you begin

Ensure you can create a managed cluster as described in the topic: vSphere
Non-Air-gapped: Creating a Cluster on page 870.

This page contains instructions on how to make your cluster self-managed. This
is necessary if there is only one cluster in your environment or if this
cluster should become the Management cluster in a multi-cluster environment.

> **Note: If you already have a self-managed or Management cluster in your
> environment, skip this page.**

Make the New Kubernetes Cluster Manage Itself

Follow these steps to turn your new cluster into a Management Cluster for an
Ultimate license environment (or a free-standing Pro Cluster):

Procedure

1. Deploy cluster life cycle services on the managed cluster.

```bash
nkp create capi-components --kubeconfig ${CLUSTER_NAME}.conf
```

Output:

```bash
# Initializing new CAPI components (7)
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

1. The cluster life cycle services on the managed cluster are ready, but the
   managed cluster configuration is on the bootstrap cluster. The move command
   moves the configuration, which takes the form of Cluster API Custom Resource
   objects, from the bootstrap to the managed cluster. This process is called a
   Pivot. For more information, see `<<https://cluster->`
   api.sigs.k8s.io/reference/glossary.html?highlight=pivot#pivot>.

Move the Cluster API objects from the bootstrap to the workload cluster:

```bash
nkp move capi-resources --to-kubeconfig ${CLUSTER_NAME}.conf
```

Output:

```bash
# Moving cluster resources (4)
You can now view resources in the moved cluster by using the --kubeconfig flag with
kubectl. For example: kubectl --kubeconfig=gcp-example.conf get nodes
Note: To ensure only one set of cluster life cycle services manages the managed cluster, NKP first pauses
reconciliation of the objects on the bootstrap cluster, then creates the objects on the managed cluster. As NKP
copies the objects, the cluster life cycle services on the managed cluster reconcile the objects. The managed cluster
becomes self-managed after NKP creates all the objects. If it fails, the move command can be safely retried.
```

1. Wait for the cluster control-plane to be ready.

```bash
kubectl --kubeconfig ${CLUSTER_NAME}.conf wait --for=condition=Available=True
"clusters/${CLUSTER_NAME}" --timeout=20m
```

Output:

```bash
cluster.cluster.x-k8s.io/gcp-example condition met
Note: After moving the cluster life cycle services to the managed cluster, remember to use NKP with the managed
cluster kubeconfig.
```

1. Use the cluster life cycle services on the managed cluster to check the
   managed cluster status.

```bash
nkp describe cluster --kubeconfig ${CLUSTER_NAME}.conf -c ${CLUSTER_NAME}
```

Output:

```bash
NAME READY SEVERITY
REASON SINCE MESSAGE
Cluster/vsphere-example-1 True
13h
##ClusterInfrastructure - VSphereCluster/vsphere-example-1 True
13h
##ControlPlane - KubeadmControlPlane/vsphere-example-control-plane True
13h
# ##Machine/vsphere-example-control-plane-7llgd True
13h
# ##Machine/vsphere-example-control-plane-vncbl True
13h
# ##Machine/vsphere-example-control-plane-wbgrm True
13h
##Workers
##MachineDeployment/vsphere-example-md-0 True
13h
##Machine/vsphere-example-md-0-74c849dc8c-67rv4 True
13h
##Machine/vsphere-example-md-0-74c849dc8c-n2skc True
13h
##Machine/vsphere-example-md-0-74c849dc8c-nkftv True
13h
##Machine/vsphere-example-md-0-74c849dc8c-sqklv True
13h
```

1. Remove the bootstrap cluster because the managed cluster is now self-managed.

```bash
nkp delete bootstrap --kubeconfig $HOME/.kube/config
```

Output:

```bash
# Deleting bootstrap cluster (5)
```

Known Limitations

> **Note: Be aware of these limitations in the current release of NKP Konvoy.**

- Before making a managed cluster self-managed, be sure that its control plane
  nodes have sufficient permissions for running Cluster API controllers.
- NKP Konvoy supports moving only one set of cluster objects from the
  bootstrap cluster to the managed cluster, or vice-versa.
- NKP Konvoy only supports moving all namespaces in the cluster; NKP does not
  support migration of individual namespaces.

#### vSphere Non-Air-gapped: Exploring the vSphere Cluster

About this task

Before you start, make sure you have created a managed cluster, as described
in Create a New vSphere Cluster.

Procedure

1. Get the kubeconfig file for the managed cluster: When the managed cluster
   is created, the cluster life cycle services generate a kubeconfig file for
   the managed cluster and write it to a Secret. The kubeconfig file is scoped
   to the cluster administrator.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
Caution: Nutanix support is unable to recover forgotten credentials. Prevent Kommander UI lockouts with the
following best practices.
```

- Backup the kubeconfig file.
- Save your credentials.
- Configure an IDP (identity provider) instead of using a username and
  password credentials.

1. Create a StorageClass with a vSphere datastore.

a. Access the Datastore tab in the vSphere client and select a datastore by
name.

b. Copy the URL of that datastore from the information dialog that displays.

c. Return to the Nutanix Kubernetes Platform (NKP) CLI, and delete the
existing StorageClass with the command: kubectl delete storageclass vsphere-
raw-block-sc

d. Run the following command to create a new StorageClass, supplying the
correct values for your environment.

```bash
cat <<EOF > vsphere-raw-block-sc.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
annotations:
storageclass.kubernetes.io/is-default-class: "true"
name: vsphere-raw-block-sc
provisioner: csi.vsphere.vmware.com
parameters:
datastoreurl: "<url>"
volumeBindingMode: WaitForFirstConsumer
EOF
```

1. Verify the API server is up by listing the nodes.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get nodes
Note: It may take a few minutes for the Status to move to Ready while the Pod network is deployed. The Nodes'
Status will change to Ready soon after the calico-node DaemonSet Pods are Ready.
```

Output:

```bash
NAME STATUS ROLES AGE VERSION
aws-example-control-plane-9z77w Ready control-plane,master 4m44s
v<kubernetes-version>
aws-example-control-plane-rtj9h Ready control-plane,master 104s
v<kubernetes-version>
aws-example-control-plane-zbf9w Ready control-plane,master 3m23s
v<kubernetes-version>
aws-example-md-0-88c46 Ready <none> 3m28s
v<kubernetes-version>
aws-example-md-0-fp8s7 Ready <none> 3m28s
v<kubernetes-version>
aws-example-md-0-qvnx7 Ready <none> 3m28s
v<kubernetes-version>
aws-example-md-0-wjdrg Ready <none> 3m27s
v<kubernetes-version>
```

1. List the Pods with the command.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get pods -A
```

Verify the output:

```bash
NAMESPACE NAME
READY STATUS RESTARTS AGE
calico-system calico-kube-controllers-57fbd7bd59-qqd96
1/1 Running 0 20h
calico-system calico-node-2m524
1/1 Running 3 (19h ago) 19h
calico-system calico-node-bbhg5
1/1 Running 0 20h
calico-system calico-node-cc5lf
1/1 Running 2 (19h ago) 19h
calico-system calico-node-cwg7x
1/1 Running 1 (19h ago) 19h
calico-system calico-node-d59hn
1/1 Running 1 (19h ago) 19h
calico-system calico-node-qmmcz
1/1 Running 0 19h
calico-system calico-node-wdqhx
1/1 Running 0 19h
calico-system calico-typha-655489d8cc-b5jnt
1/1 Running 0 20h
calico-system calico-typha-655489d8cc-q92x9
1/1 Running 0 19h
calico-system calico-typha-655489d8cc-vjlkx
1/1 Running 0 19h
kube-system cluster-autoscaler-68c759fbf6-7d2ck
0/1 Init:0/1 0 20h
kube-system coredns-78fcd69978-qn4qt
1/1 Running 0 20h
kube-system coredns-78fcd69978-wqpmg
1/1 Running 0 20h
kube-system etcd-nutanix-e2e-air-gapped-1-control-plane-7llgd
1/1 Running 0 20h
kube-system etcd-nutanix-e2e-air-gapped-1-control-plane-vncbl
1/1 Running 0 19h
kube-system etcd-nutanix-e2e-air-gapped-1-control-plane-wbgrm
1/1 Running 0 19h
kube-system kube-apiserver-nutanix-e2e-air-gapped-1-control-plane-7llgd
1/1 Running 0 20h
kube-system kube-apiserver-nutanix-e2e-air-gapped-1-control-plane-vncbl
1/1 Running 0 19h
kube-system kube-apiserver-nutanix-e2e-air-gapped-1-control-plane-wbgrm
1/1 Running 0 19h
kube-system kube-controller-manager-nutanix-e2e-air-gapped-1-control-
plane-7llgd 1/1 Running 1 (19h ago) 20h
kube-system kube-controller-manager-nutanix-e2e-air-gapped-1-control-
plane-vncbl 1/1 Running 0 19h
kube-system kube-controller-manager-nutanix-e2e-air-gapped-1-control-
plane-wbgrm 1/1 Running 0 19h
kube-system kube-proxy-cpscs
1/1 Running 0 19h
kube-system kube-proxy-hhmxq
1/1 Running 0 19h
kube-system kube-proxy-hxhnk
1/1 Running 0 19h
kube-system kube-proxy-nsrbp
1/1 Running 0 19h
kube-system kube-proxy-scxfg
1/1 Running 0 20h
kube-system kube-proxy-tth4k
1/1 Running 0 19h
kube-system kube-proxy-x2xfx
1/1 Running 0 19h
kube-system kube-scheduler-nutanix-e2e-air-gapped-1-control-plane-7llgd
1/1 Running 1 (19h ago) 20h
kube-system kube-scheduler-nutanix-e2e-air-gapped-1-control-plane-vncbl
1/1 Running 0 19h
kube-system kube-scheduler-nutanix-e2e-air-gapped-1-control-plane-wbgrm
1/1 Running 0 19h
kube-system kube-vip-nutanix-e2e-air-gapped-1-control-plane-7llgd
1/1 Running 1 (19h ago) 20h
kube-system kube-vip-nutanix-e2e-air-gapped-1-control-plane-vncbl
1/1 Running 0 19h
kube-system kube-vip-nutanix-e2e-air-gapped-1-control-plane-wbgrm
1/1 Running 0 19h
kube-system vsphere-cloud-controller-manager-4zj7q
1/1 Running 0 19h
kube-system vsphere-cloud-controller-manager-87tgm
1/1 Running 0 19h
kube-system vsphere-cloud-controller-manager-xqmn4
1/1 Running 1 (19h ago) 20h
node-feature-discovery node-feature-discovery-master-84c67dcbb6-txfw9
1/1 Running 0 20h
node-feature-discovery node-feature-discovery-worker-8tg2l
1/1 Running 3 (19h ago) 19h
node-feature-discovery node-feature-discovery-worker-c5f6q
1/1 Running 0 19h
node-feature-discovery node-feature-discovery-worker-fjfkm
1/1 Running 0 19h
node-feature-discovery node-feature-discovery-worker-x6tz8
1/1 Running 0 19h
tigera-operator tigera-operator-d499f5c8f-r2srj
1/1 Running 1 (19h ago) 20h
vmware-system-csi vsphere-csi-controller-7ffd6884cc-d7rql
7/7 Running 5 (19h ago) 20h
vmware-system-csi vsphere-csi-controller-7ffd6884cc-k82cm
7/7 Running 2 (19h ago) 20h
vmware-system-csi vsphere-csi-controller-7ffd6884cc-qttkp
7/7 Running 1 (19h ago) 20h
vmware-system-csi vsphere-csi-node-678hw
3/3 Running 0 19h
vmware-system-csi vsphere-csi-node-6tbsh
3/3 Running 0 19h
vmware-system-csi vsphere-csi-node-9htwr
3/3 Running 5 (20h ago) 20h
vmware-system-csi vsphere-csi-node-g8r6l
3/3 Running 0 19h
vmware-system-csi vsphere-csi-node-ghmr6
3/3 Running 0 19h
vmware-system-csi vsphere-csi-node-jhvgm
3/3 Running 0 19h
vmware-system-csi vsphere-csi-node-rp77r
3/3 Running 0 19h
```

#### vSphere Non-Air-gapped: Installing Kommander

About this task

Once you have installed the Konvoy component of Nutanix Kubernetes Platform
(NKP) , you will continue with the installation of the Kommander component
that will bring up the UI dashboard.

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

1. Only required if your cluster uses a custom AWS VPC and requires an
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

1. If required: Customize your kommander.yaml. See the Kommander
   Customizations page for customization options. Some options include Custom
   Domains and Certificates, HTTP proxy, External Load Balancer, GPU
   utilization, Rook Ceph customization for Pre-provisioned environments, and
   so on.
2. Expand one of the following sets of instructions, depending on your license
   and application environments:

» Pro License: Install Kommander in a Non-Air-Gapped Environment

Pro License: Install Kommander

Use the customized kommander.yaml to install NKP:

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

Kommander Customizations

You can configure the Kommander component of NKP during the initial
installation, and also post-installation using the NKP CLI. If you are not
sure of what you want to customize during install, then proceed to the next
step. To read about Kommander component customization options, refer to this
section of the documentation: Kommander Customizations on page 996

#### vSphere Non-Air-gapped: Verifying the Install and Log in to the UI

About this task

After you build the Konvoy cluster and you install the Kommander component for
the UI, you can verify your installation. It waits for all applications to be
ready by default.

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

After installing Konvoy component and building a cluster as well as
successfully installing Kommander and logging into
the UI, you are now ready to customize configurations using the Day 2 Cluster
Operations Management section of the
documentation. The majority of this customization such as attaching clusters
and deploying applications will take place
in the dashboard or UI of NKP. The Day 2 section allows you to manage cluster
operations and their application workloads
to optimize your organization's productivity.

### vSphere Installation in an Air-Gapped Environment

This installation provides instructions to install NKP in a vSphere air-gapped
environment.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

Further vSphere Prerequisites

Create a Kubernetes vSphere cluster in a private network with no access to the
Internet (air-gapped)

In an environment with access to the Internet, you retrieve artifacts from
specialized repositories dedicated to them, such as Docker® images contained
in DockerHub, and Helm™ Charts that come from a dedicated Helm Chart
repository. However, in an air-gapped environment, you need local repositories
to store Helm charts, Docker images, and other artifacts. Tools such as
JFrog™, Harbor™, and Nexus™ handle multiple types of artifacts in one local
repository.

Before you begin using Nutanix Kubernetes Platform (NKP) , you must ensure you
meet the other prerequisites in the vSphere Prerequisites section.

#### vSphere Air-gapped: Creating an Air-gapped CAPI VM Template

About this task

You must have at least one image before creating a new cluster. As long as you
have an image, this step in your configuration is not required each time since
that image can be used to spin up a new cluster. However, if you need
different images for different environments or providers, you will need to
create a new custom image.

Procedure

For detailed steps, see Building a Custom Image with vSphere on page 64.

#### vSphere Air-gapped: Loading the Registry

About this task

The complete Nutanix Kubernetes Platform (NKP) air-gapped bundle is needed for
an air-gapped environment but can also be used in a non-air-gapped
environment. The bundle contains all the NKP components needed for an air-
gapped environment installation and also to use a local registry in a non-air-
gapped environment.

```yaml
Warning: If you do not already have a local registry set up, see the Local Registry Tools page for more
information.
```

If you are operating in an air-gapped environment, a local container registry
containing all the necessary installation images, including the Kommander
images is required. This registry must be accessible from both the bastion
machine or other machines that will be created for the Kubernetes cluster.

Procedure

1. If not already done in prerequisites, download the air-gapped bundle nkp-
   air-gapped-bundle_vnkp-

version_linux_amd64.tar.gz , and extract the tarball to a local directory.

| nkp-air-gapped-bundle v | nkp- |
| ----------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

| tar -xzvf nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ---------------------------------- | ----------- | ------------------------ |

1. The directory structure after extraction can be accessed in subsequent
   steps using commands to access files from different directories. EX: For the
   bootstrap cluster, change your directory to the nkp-`<version>` directory
   similar to example below depending on your current location
2. Set an environment variable with your registry address for ECR.

```bash
export REGISTRY_URL=<ecr-registry-URI>
```

- REGISTRY_URL: the address of an existing local registry accessible in the
  VPC that the new cluster nodes will be configured to use a mirror registry
  when pulling images
- The environment where you are running the nkp push command must be
  authenticated with AWS in order to load your images into ECR.
- Other registry variables:

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
export REGISTRY_CA=<path to the cacert file on the bastion>
```

Before creating or upgrading a Kubernetes cluster, you need to load the
required images in a local registry if operating in an air-gapped environment. 4. Execute the following command to load the air-gapped image bundle into your
private registry using any of the relevant flags to apply variables above. If
not ECR as shown in example code below, use the other relevant flags: --to-
registry= ${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-
registry-password= ${REGISTRY_PASSWORD}

```bash
nkp push bundle --bundle ./container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
Note: It may take some time to push all the images to your image registry, depending on the performance of the
network between the machine you are running the script on and the registry.
```

1. Load the Kommander component images to your private registry using the
   command.

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-nkp-version.tar
--to-registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-
registry-password=${REGISTRY_PASSWORD}
```

#### vSphere Air-gapped: Bootstrapping Air-gapped vSphere

About this task

To get started, you need a bootstrap cluster. By default, Nutanix Kubernetes
Platform (NKP) creates a bootstrap cluster for you in a Docker container using
the Kubernetes-in-Docker (KIND) tool.

Before you begin

| cd nkp- | nkp-version | Col3 |
| ------- | ----------- | ---- |

Procedure

1. Complete the Nutanix Infrastructure Prerequisites. For more information,
   see Nutanix Infrastructure Requirements on page 719.
2. Ensure the NKP binary can be found in your $PATH.

##### Bootstrap Cluster Life Cycle Services (2)

Procedure

1. Review Universal Configurations for all Infrastructure Providers regarding
   settings, flags, and other choices and then begin bootstrapping.
2. Create a bootstrap cluster using the command.

```bash
nkp create bootstrap --kubeconfig $HOME/.kube/config
```

Example output:

```bash
# Creating a bootstrap cluster (5)
# Initializing new CAPI components (8)
```

> **Note:**

- To create a bootstrap cluster in a proxied environment (Bootstrap Cluster
  HTTP Proxy Settings on page 697), in addition to any other flags you need,
  run the following command.

```bash
--http-proxy <string> \
--https-proxy <string> \
--no-proxy <string>
```

- Flatcar OS use --os-hint to instruct the bootstrap cluster to make some
  changes related to the installation paths.

```bash
--os-hint flatcar
```

1. NKP creates a bootstrap cluster using KIND as a library.

For more information, see `<https://github.com/kubernetes-sigs/kind>`. 4. NKP
then deploys the following Cluster API providers on the cluster.

- Core Provider: `<https://github.com/kubernetes-sigs/cluster-api/tree/v0.3.20/>`
- AWS Infrastructure Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api-provider-aws>
- Kubeadm Bootstrap Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api/tree/v0.3.20/bootstrap/> kubeadm
- Kubeadm ControlPlane Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api/tree/v0.3.20/> controlplane/kubeadm

For more information on Cluster APIs, see `<https://cluster-api.sigs.k8s.io/>`. 5. Ensure that the CAPV controllers are present using the command.

```bash
kubectl get pods -n capv-system
```

Output example:

```bash
NAME READY STATUS RESTARTS AGE
capv-controller-manager-785c5978f-nnfns 1/1 Running 0 13h
```

1. NKP waits until these providers' controller-manager and webhook deployments
   are ready. List these deployments using the command kubectl get --all-
   namespaces deployments -l=clusterctl.cluster.x- k8s.io. Output example:

```bash
NAMESPACE NAME
READY UP-TO-DATE AVAILABLE AGE
capa-system capa-controller-manager
1/1 1 1 1h
capg-system capg-controller-manager
1/1 1 1 1h
capi-kubeadm-bootstrap-system capi-kubeadm-bootstrap-controller-manager
1/1 1 1 1h
capi-kubeadm-control-plane-system capi-kubeadm-control-plane-controller-manager
1/1 1 1 1h
capi-system capi-controller-manager
1/1 1 1 1h
cappp-system cappp-controller-manager
1/1 1 1 1h
capv-system capv-controller-manager
1/1 1 1 1h
capz-system capz-controller-manager
1/1 1 1 1h
cert-manager cert-manager
1/1 1 1 1h
cert-manager cert-manager-cainjector
1/1 1 1 1h
cert-manager cert-manager-webhook
1/1 1 1 1h
```

#### vSphere Air-gapped: Creating a Cluster

About this task

If you use these instructions to create a cluster on vSphere using the Nutanix
Kubernetes Platform (NKP) default settings without any edits to configuration
files or additional flags, your cluster is deployed on a three control plane
nodes, and four worker nodes. First, you must name your cluster.

Before you begin

Name Your Cluster

Procedure

1. Give your cluster a unique name suitable for your environment.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the environment variable:

```bash
export CLUSTER_NAME=<my-vsphere-cluster>
Warning: Ensure your subnets do not overlap with your host subnet because they cannot be changed after cluster
creation. If you need to change the Kubernetes subnets, you must do this at cluster creation. The default subnets
used in NKP are:
spec:
clusterNetwork:
pods:
cidrBlocks:
- 192.168.0.0/16
services:
cidrBlocks:
- 10.96.0.0/12
```

1. Configure your cluster to use an existing registry as a mirror when
   attempting to pull images as done on the

vSphere Air-gapped: Loading the Registry on page 884 page previously. 4.
Generate the Kubernetes cluster objects by copying and editing this command to
include the correct values, including the VM template name you assigned in the
previous procedure.

- Flatcar OS use --os-hint to instruct the bootstrap cluster to make some
  changes related to the installation paths.

```bash
--os-hint flatcar
```

- FIPS Requirements on page 710
- Configuring an HTTP or HTTPS Proxy on page 696
- Individual manifests using the Output Directory flag: You can create
  individual manifest files with different smaller manifests for ease in
  editing using the --output-directory flag. For more information, see Output
  Directory Flag on page 710.

```bash
--output-directory=<existing-directory>
```

Refer to the vSphere Cluster Creation Customization Choices on page 860
section for more information on how to use optional flags such as the
--output-directory flag.

```yaml
Note: NKP uses the vSphere CSI driver as the default storage provider. Use a Kubernetes CSI compatible
storage that is suitable for production. For more information, see the Kubernetes documentation called Changing
the Default Storage Class If you're not using the default, you cannot deploy an alternate provider until after the nkp
create cluster is finished. However, this must be determined before the Kommander installation. For more
information, see https://kubernetes.io/docs/concepts/storage/volumes/#volume-types and https://
kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/
```

1. Inspect or edit the cluster objects. Familiarize yourself with the Cluster
   API before editing the cluster objects, as edits can prevent the cluster
   from deploying successfully.

```bash
kubectl get clusters,kubeadmcontrolplanes,machinedeployments
```

1. Create the cluster from the objects generated from the dry run. A warning
   will appear in the console if the resource already exists, requiring you to
   remove the resource or update your YAML.

```bash
kubectl create -f ${CLUSTER_NAME}.yaml
Note: If you used the --output-directory flag in your nkp create .. --dry-run step above, create
the cluster from the objects you created by specifying the directory:
kubectl create -f <existing-directory>/.
```

1. Use the wait command to monitor the cluster control-plane readiness:

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --timeout=20m
```

Output:

```bash
cluster.cluster.x-k8s.io/${CLUSTER_NAME} condition met
```

The READY status becomes True after the cluster control-plane becomes Ready in
one of the following steps.

After NKP creates the objects on the API server, the Cluster API controllers
reconcile them, creating infrastructure and machines. As the controllers
progress, they update the Status of each object. 8. Run the NKP describe
command to monitor the current status of the cluster:

```bash
nkp describe cluster -c ${CLUSTER_NAME}
```

Output:

```bash
NAME READY SEVERITY
REASON SINCE MESSAGE
Cluster/nutanix-e2e-cluster_name-1 True
13h
##ClusterInfrastructure - VSphereCluster/nutanix-e2e-cluster_name-1 True
13h
##ControlPlane - KubeadmControlPlane/nutanix-control-plane True
13h
# ##Machine/nutanix--control-plane-7llgd True (2)
13h
# ##Machine/nutanix--control-plane-vncbl True (2)
13h
# ##Machine/nutanix--control-plane-wbgrm True (2)
13h
##Workers
##MachineDeployment/nutanix--md-0 True
13h
##Machine/nutanix--md-0-74c849dc8c-67rv4 True
13h
##Machine/nutanix--md-0-74c849dc8c-n2skc True
13h
##Machine/nutanix--md-0-74c849dc8c-nkftv True
13h
##Machine/nutanix--md-0-74c849dc8c-sqklv True
13h
```

1. As they progress, the controllers also create Events, which you can list
   using the command

```bash
kubectl get events | grep ${CLUSTER_NAME}
```

For brevity, this example uses grep. You can also use separate commands to get
Events for specific objects, such as kubectl get events --field-selector
involvedObject.kind="VSphereCluster" and kubectl get events --field-selector
involvedObject.kind="VSphereMachine".

Known Limitations

> **Note: Be aware of these limitations in the current release of NKP Konvoy.**

- • The NKP Konvoy version used to create a bootstrap cluster must match the
  NKP Konvoy version used to create a managed cluster.
- NKP Konvoy supports deploying one managed cluster.
- NKP Konvoy generates a set of objects for one Node Pool.
- NKP Konvoy does not validate edits to cluster objects.

#### vSphere Air-gapped: Making the Cluster Self-Managed

About this task

Nutanix Kubernetes Platform (NKP) deploys all cluster life cycle services to a
bootstrap cluster, which then deploys a managed cluster. When the managed
cluster is ready, move the cluster life cycle services to the workload
cluster, which makes the managed cluster self-managed.

Before you begin

Ensure you can create a managed cluster as described in the topic: Create a
New Air-gapped vSphere Cluster.

This page contains instructions on how to make your cluster self-managed. This
is necessary if there is only one cluster in your environment or if this
cluster becomes the Management cluster in a multi-cluster environment.

> **Note: If you already have a self-managed or Management cluster in your
> environment, skip this page.**

Make the New Kubernetes Cluster Manage Itself

Follow these steps to turn your new cluster into a Management Cluster for an
Ultimate license environment (or a free-standing Pro Cluster):

Procedure

1. Deploy cluster life cycle services on the managed cluster.

```bash
nkp create capi-components --kubeconfig ${CLUSTER_NAME}.conf
```

Output:

```bash
# Initializing new CAPI components (9)
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

1. The cluster life cycle services on the managed cluster are ready, but the
   managed cluster configuration is on the bootstrap cluster. The move command
   moves the configuration, which takes the form of Cluster API Custom

Resource objects, from the bootstrap to the managed cluster. This process is
called a Pivot. For more information, see `<<https://cluster->`
api.sigs.k8s.io/reference/glossary.html?highlight=pivot#pivot>.

Move the Cluster API objects from the bootstrap to the workload cluster:

```bash
nkp move capi-resources --to-kubeconfig ${CLUSTER_NAME}.conf
```

Output:

```bash
# Moving cluster resources (5)
You can now view resources in the moved cluster by using the --kubeconfig flag with
kubectl. For example: kubectl --kubeconfig=gcp-example.conf get nodes
Note: To ensure only one set of cluster life cycle services manages the managed cluster, NKP first pauses the
reconciliation of the objects on the bootstrap cluster, then creates the objects on the managed cluster. As NKP
copies the objects, the cluster life cycle services on the managed cluster reconcile the objects. The managed cluster
becomes self-managed after NKP creates all the objects. If it fails, the move command can be safely retried.
```

1. Wait for the cluster control-plane to be ready.

```bash
kubectl --kubeconfig ${CLUSTER_NAME}.conf wait --for=condition=Available=True
"clusters/${CLUSTER_NAME}" --timeout=20m
```

Output:

```bash
cluster.cluster.x-k8s.io/gcp-example condition met
Note: After moving the cluster life cycle services to the managed cluster, remember to use NKP with the managed
cluster kubeconfig.
```

1. Use the cluster life cycle services on the managed cluster to check the
   managed cluster status.

```bash
nkp describe cluster --kubeconfig ${CLUSTER_NAME}.conf -c ${CLUSTER_NAME}
```

Output:

```bash
NAME READY SEVERITY
REASON SINCE MESSAGE
Cluster/vsphere-example-1 True
13h
##ClusterInfrastructure - VSphereCluster/vsphere-example-1 True
13h
##ControlPlane - KubeadmControlPlane/vsphere-example-control-plane True
13h
# ##Machine/vsphere-example-control-plane-7llgd True (2)
13h
# ##Machine/vsphere-example-control-plane-vncbl True (2)
13h
# ##Machine/vsphere-example-control-plane-wbgrm True (2)
13h
##Workers
##MachineDeployment/vsphere-example-md-0 True
13h
##Machine/vsphere-example-md-0-74c849dc8c-67rv4 True
13h
##Machine/vsphere-example-md-0-74c849dc8c-n2skc True
13h
##Machine/vsphere-example-md-0-74c849dc8c-nkftv True
13h
##Machine/vsphere-example-md-0-74c849dc8c-sqklv True
13h
```

1. Remove the bootstrap cluster because the managed cluster is now self-managed.

```bash
nkp delete bootstrap --kubeconfig $HOME/.kube/config
```

Output:

```bash
# Deleting bootstrap cluster (6)
```

Known Limitations

> **Note: Be aware of these limitations in the current release of NKP Konvoy.**

- Before making a managed cluster self-managed, be sure that its control plane
  nodes have sufficient permissions for running Cluster API controllers.
- NKP Konvoy supports moving only one set of cluster objects from the
  bootstrap cluster to the managed cluster, or vice-versa.
- NKP Konvoy only supports moving all namespaces in the cluster; NKP does not
  support migration of individual namespaces.

#### vSphere Air-gapped: Exploring the vSphere Air-gapped Cluster

About this task

Before you start, make sure you have created a managed cluster, as described
in Create a New vSphere Air- gapped Cluster.

Procedure

1. When the managed cluster is created, the cluster life cycle services
   generate a kubeconfig file for the managed cluster and write it to a Secret.
   The kubeconfig file is scoped to the cluster administrator. Get a kubeconfig
   file for the workload cluster.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
```

1. Create a StorageClass with a vSphere datastore.

a. Access the Datastore tab in the vSphere client and select a datastore by
name.

b. Copy the URL of that datastore from the information dialog displayed.

c. Return to the Nutanix Kubernetes Platform (NKP) CLI, and delete the
existing StorageClass with the command:

```bash
kubectl delete storageclass vsphere-raw-block-sc
```

d. Run the following command to create a new StorageClass, supplying the
correct values for your environment.

```bash
cat <<EOF > vsphere-raw-block-sc.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
annotations:
storageclass.kubernetes.io/is-default-class: "true"
name: vsphere-raw-block-sc
provisioner: csi.vsphere.vmware.com
parameters:
datastoreurl: "<url>"
volumeBindingMode: WaitForFirstConsumer
EOF
```

1. Verify the API server is up by listing the nodes.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get nodes
Note: The Status may take a few minutes to move to Ready while the Pod network is deployed. The Nodes' Status
will change to Ready soon after the calico-node DaemonSet Pods are Ready.
```

The output resembles this example:

```bash
NAME STATUS ROLES AGE
VERSION
nutanix-e2e-air-gapped-1-control-plane-7llgd Ready control-plane,master 20h
v<kubernetes-version>
nutanix-e2e-air-gapped-1-control-plane-vncbl Ready control-plane,master 19h
v<kubernetes-version>
nutanix-e2e-air-gapped-1-control-plane-wbgrm Ready control-plane,master 19h
v<kubernetes-version>
nutanix-e2e-air-gapped-1-md-0-74c849dc8c-67rv4 Ready <none> 19h
v<kubernetes-version>
nutanix-e2e-air-gapped-1-md-0-74c849dc8c-n2skc Ready <none> 19h
v<kubernetes-version>
nutanix-e2e-air-gapped-1-md-0-74c849dc8c-nkftv Ready <none> 19h
v<kubernetes-version>
nutanix-e2e-air-gapped-1-md-0-74c849dc8c-sqklv Ready <none> 19h
v<kubernetes-version>
```

1. List the Pods with the command.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get pods -A
```

Verify the output:

```bash
NAMESPACE NAME
READY STATUS RESTARTS AGE
calico-system calico-kube-controllers-57fbd7bd59-qqd96
1/1 Running 0 20h
calico-system calico-node-2m524
1/1 Running 3 (19h ago) 19h
calico-system calico-node-bbhg5
1/1 Running 0 20h
calico-system calico-node-cc5lf
1/1 Running 2 (19h ago) 19h
calico-system calico-node-cwg7x
1/1 Running 1 (19h ago) 19h
calico-system calico-node-d59hn
1/1 Running 1 (19h ago) 19h
calico-system calico-node-qmmcz
1/1 Running 0 19h
calico-system calico-node-wdqhx
1/1 Running 0 19h
calico-system calico-typha-655489d8cc-b5jnt
1/1 Running 0 20h
calico-system calico-typha-655489d8cc-q92x9
1/1 Running 0 19h
calico-system calico-typha-655489d8cc-vjlkx
1/1 Running 0 19h
kube-system cluster-autoscaler-68c759fbf6-7d2ck
0/1 Init:0/1 0 20h
kube-system coredns-78fcd69978-qn4qt
1/1 Running 0 20h
kube-system coredns-78fcd69978-wqpmg
1/1 Running 0 20h
kube-system etcd-nutanix-e2e-cluster-1-control-plane-7llgd
1/1 Running 0 20h
kube-system etcd-nutanix-e2e-cluster-1-control-plane-vncbl
1/1 Running 0 19h
kube-system etcd-nutanix-e2e-cluster-1-control-plane-wbgrm
1/1 Running 0 19h
kube-system kube-apiserver-nutanix-e2e-cluster-1-control-plane-7llgd
1/1 Running 0 20h
kube-system kube-apiserver-nutanix-e2e-cluster-1-control-plane-vncbl
1/1 Running 0 19h
kube-system kube-apiserver-nutanix-e2e-cluster-1-control-plane-wbgrm
1/1 Running 0 19h
kube-system kube-controller-manager-nutanix-e2e-cluster-1-control-
plane-7llgd 1/1 Running 1 (19h ago) 20h
kube-system kube-controller-manager-nutanix-e2e-cluster-1-control-plane-
vncbl 1/1 Running 0 19h
kube-system kube-controller-manager-nutanix-e2e-cluster-1-control-plane-
wbgrm 1/1 Running 0 19h
kube-system kube-proxy-cpscs
1/1 Running 0 19h
kube-system kube-proxy-hhmxq
1/1 Running 0 19h
kube-system kube-proxy-hxhnk
1/1 Running 0 19h
kube-system kube-proxy-nsrbp
1/1 Running 0 19h
kube-system kube-proxy-scxfg
1/1 Running 0 20h
kube-system kube-proxy-tth4k
1/1 Running 0 19h
kube-system kube-proxy-x2xfx
1/1 Running 0 19h
kube-system kube-scheduler-nutanix-e2e-cluster-1-control-plane-7llgd
1/1 Running 1 (19h ago) 20h
kube-system kube-scheduler-nutanix-e2e-cluster-1-control-plane-vncbl
1/1 Running 0 19h
kube-system kube-scheduler-nutanix-e2e-cluster-1-control-plane-wbgrm
1/1 Running 0 19h
kube-system kube-vip-nutanix-e2e-cluster-1-control-plane-7llgd
1/1 Running 1 (19h ago) 20h
kube-system kube-vip-nutanix-e2e-cluster-1-control-plane-vncbl
1/1 Running 0 19h
kube-system kube-vip-nutanix-e2e-cluster-1-control-plane-wbgrm
1/1 Running 0 19h
kube-system vsphere-cloud-controller-manager-4zj7q
1/1 Running 0 19h
kube-system vsphere-cloud-controller-manager-87tgm
1/1 Running 0 19h
kube-system vsphere-cloud-controller-manager-xqmn4
1/1 Running 1 (19h ago) 20h
node-feature-discovery node-feature-discovery-master-84c67dcbb6-txfw9
1/1 Running 0 20h
node-feature-discovery node-feature-discovery-worker-8tg2l
1/1 Running 3 (19h ago) 19h
node-feature-discovery node-feature-discovery-worker-c5f6q
1/1 Running 0 19h
node-feature-discovery node-feature-discovery-worker-fjfkm
1/1 Running 0 19h
node-feature-discovery node-feature-discovery-worker-x6tz8
1/1 Running 0 19h
tigera-operator tigera-operator-d499f5c8f-r2srj
1/1 Running 1 (19h ago) 20h
vmware-system-csi vsphere-csi-controller-7ffd6884cc-d7rql
7/7 Running 5 (19h ago) 20h
vmware-system-csi vsphere-csi-controller-7ffd6884cc-k82cm
7/7 Running 2 (19h ago) 20h
vmware-system-csi vsphere-csi-controller-7ffd6884cc-qttkp
7/7 Running 1 (19h ago) 20h
vmware-system-csi vsphere-csi-node-678hw
3/3 Running 0 19h
vmware-system-csi vsphere-csi-node-6tbsh
3/3 Running 0 19h
vmware-system-csi vsphere-csi-node-9htwr
3/3 Running 5 (20h ago) 20h
vmware-system-csi vsphere-csi-node-g8r6l
3/3 Running 0 19h
vmware-system-csi vsphere-csi-node-ghmr6
3/3 Running 0 19h
vmware-system-csi vsphere-csi-node-jhvgm
3/3 Running 0 19h
vmware-system-csi vsphere-csi-node-rp77r
3/
```

#### vSphere Air-gapped: Installing Kommander

About this task

After you have installed the Konvoy component of NKP, you will continue
installing the Kommander component that will bring up the UI dashboard.

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
  vSphere Air-gapped: Loading the Registry on page 884.
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

1. If required: Customize your kommander.yaml. See the Kommander
   Customizations page for customization options. Some options include Custom
   Domains and Certificates, HTTP proxy, External Load Balancer, GPU
   utilization, Rook Ceph customization for Pre-provisioned environments, and
   so on.
2. If required: If your cluster uses a custom AWS VPC and requires an internal
   load-balancer, set the traefik annotation to create an internal-facing ELB:

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

1. Expand one of the following sets of instructions, depending on your license
   and application environments:

```yaml
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

» Pro License: Install Kommander in a Air-Gapped Environment

Pro License: Install Kommander

Use the customized kommander.yaml to install NKP:

```bash
nkp install kommander \
--installer-config kommander.yaml --kubeconfig=${CLUSTER_NAME}.conf \
--kommander-applications-repository ./application-repositories/kommander-
applications-nkp-version.tar.gz
```

» Ultimate License: Install Kommander in a Air-gapped Environment.

Use the customized kommander.yaml to install NKP:

```bash
nkp install kommander \
--installer-config kommander.yaml --kubeconfig=${CLUSTER_NAME}.conf \
--kommander-applications-repository ./application-repositories/kommander-
applications-nkp-version.tar.gz
```

Kommander Customizations

You can configure the Kommander component of NKP during the initial
installation, and also post-installation using the NKP CLI. If you are not
sure of what you want to customize during install, then proceed to the next
step. To read about Kommander component customization options, refer to this
section of the documentation: Kommander Customizations on page 996.

#### vSphere Air-gapped: Verifying the Install and Log in to the UI

About this task

You can verify your installation after you build the Konvoy cluster and
install the Kommander component for the UI. bu default, verification waits for
all applications to be ready.

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

After installing Konvoy component and building a cluster as well as
successfully installing Kommander and logging into
the UI, you are now ready to customize configurations using the Day 2 Cluster
Operations Management section of the
documentation. The majority of this customization such as attaching clusters
and deploying applications will take place
in the dashboard or UI of NKP. The Day 2 section allows you to manage cluster
operations and their application workloads
to optimize your organization's productivity.

### vSphere Management Tools

After cluster creation and configuration, you can revisit existing clusters to
modify configurations such as control plane and worker node variables, modify
cluster metadata, and resource allocations after initial deployment.

#### vSphere: Manage Node Pools

Node pools are part of a cluster and managed as a group, and you can use a
node pool to manage a group of machines using
the same common properties. When Konvoy creates a new default cluster, there
is one node pool for the worker nodes, and
all nodes in that new node pool have the same configuration. You can create
additional node pools for more specialized
hardware or configuration. For example, suppose you want to tune your memory
usage on a cluster where you need maximum
memory for some machines and minimal memory for others. In that case, you
create a new node pool with those specific
resource needs.

Nutanix Kubernetes Platform (NKP) implements node pools using Cluster API
MachineDeployments. For more information on node pools, see these sections:

##### vSphere: Creating Node Pools

Creating a node pool is useful when you need to run workloads that require
machines with specific resources, such as a GPU, additional memory, or
specialized network or storage hardware.

About this task

Availability zones (AZs) are isolated locations within datacenter regions
where public cloud services originate and operate. Because all the nodes in a
node pool are deployed in a single Availability Zone, you may wish to create
additional node pools to ensure your cluster has nodes deployed in multiple
Availability Zones.

The first task is to prepare the environment.

Procedure

1. Set the environment variable to the name you assigned this cluster.

```bash
export CLUSTER_NAME=<my-vsphere-cluster>
```

1. If your managed cluster is self-managed, as described in Make the New
   Cluster Self-Managed, configure kubectl to use the kubeconfig for the
   cluster.

```bash
export KUBECONFIG=${CLUSTER_NAME}.conf
```

1. Define your node pool name.

```bash
export NODEPOOL_NAME=example
```

###### Create a vSphere Node Pool

Procedure

Create a new node pool with three replicas using this command.

```bash
nkp create nodepool vsphere ${NODEPOOL_NAME} \
--cluster-name=${CLUSTER_NAME} \
--network=example_network \
--data-center=example_datacenter \
--data-store=example_datastore \
--folder=example_folder \
--server=example_vsphere_api_server_url\
--resource-pool=example_resource_pool \
--vm-template=example_vm_template \
--replicas=3
```

The output resembles this example:

```bash
machinedeployment.cluster.x-k8s.io/example created
vspheremachinetemplate.infrastructure.cluster.x-k8s.io/example created
kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/example created
# Creating default/example nodepool resources (2)
```

This example uses default values for brevity. Advanced users can use a
combination of the --dry-run and -- output=yaml or --output-
directory=`<existing-directory>` flags to get a complete set of node pool
objects to modify locally or store in version control.

##### vSphere: Listing Node Pools

List the node pools of a given cluster. This returns specific properties of
each node pool so that you can see the name of the MachineDeployments.

About this task

List node pools for a managed cluster.

```yaml
Note: To list node pools for the management cluster on NKP 2.18 or later, add -n kommander alongside --
kubeconfig=${CLUSTER_NAME}.conf. Starting in NKP 2.18, the management cluster runs in the kommander
namespace. In NKP 2.17 and earlier, this flag was not required.
```

Procedure

To list all node pools for a managed cluster, run:.

```bash
nkp get nodepools --cluster-name=${CLUSTER_NAME} --kubeconfig=${CLUSTER_NAME}.conf
```

The expected output is similar to the following example, indicating the
desired size of the node pool, the number of replicas ready in the node pool,
and the Kubernetes version those nodes are running:

```bash
NODEPOOL DESIRED READY KUBERNETES
VERSION
demo-cluster-md-0 4 4 v<kubernetes-
version>
example 3 0 v<kubernetes-
version>
```

##### vSphere: Scaling Node Pools

While running Cluster Autoscaler, you can manually scale your node pools up or
down when you need finite control over your environment.

About this task

For more information, see vSphere: Configuring Cluster Autoscaler on page 905.

If you require ten machines to run a process, you can only manually set the
scaling to run those ten machines. However, using the Cluster Autoscaler, you
must stay within your minimum and maximum bounds. This process allows you to
scale manually.

Environment variables, such as defining the node pool name, are set in the
Prepare the Environment section on the previous page. If needed, refer to that
page to set those variables.

```yaml
Note: To scale node pools on the management cluster on NKP 2.18 or later, add -n kommander to the command.
Starting in NKP 2.18, the management cluster runs in the kommander namespace. In NKP 2.17 and earlier, this flag
was not required.
```

Scale Up Node Pools

Procedure

1. To scale up a node pool in a cluster, run one of the following.

```bash
nkp scale nodepools ${NODEPOOL_NAME} --replicas=5 --cluster-name=${CLUSTER_NAME}
```

Output example indicating scaling is in progress:

```bash
INFO[2021-07-26T08:54:35-07:00] Running scale nodepool command
clusterName=demo-cluster managementClusterKubeconfig= namespace=default
src="nodepool/scale.go:82"
INFO[2021-07-26T08:54:35-07:00] Nodepool example scaled to 5 replicas
clusterName=demo-cluster managementClusterKubeconfig= namespace=default
src="nodepool/scale.go:94"
```

1. After a few minutes, you can list the node pools.

```bash
nkp get nodepools --cluster-name=${CLUSTER_NAME} --kubeconfig=${CLUSTER_NAME}.conf
```

Example output showing the number of DESIRED and READY replicas increased to 5:

```bash
NODEPOOL DESIRED READY KUBERNETES
VERSION
example 5 5
v<kubernetes-version>
demo-cluster-md-0 4 4
v<kubernetes-version>
```

##### vSphere: Scaling Down Node Pools

While running Cluster Autoscaler, you can manually scale your node pools up or
down when you need finite control over your environment.

About this task

For more information, see vSphere: Configuring Cluster Autoscaler on page 905.

If you require ten machines to run a process, you can only manually set the
scaling to run those ten machines. However, using the Cluster Autoscaler, you
must stay within your minimum and maximum bounds. This process allows you to
scale manually.

```yaml
Note: To scale node pools on the management cluster on NKP 2.18 or later, add -n kommander to the command.
Starting in NKP 2.18, the management cluster runs in the kommander namespace. In NKP 2.17 and earlier, this flag
was not required.
```

Procedure

1. To scale down a node pool, run.

```bash
nkp scale nodepools ${NODEPOOL_NAME} --replicas=4 --cluster-name=${CLUSTER_NAME}
```

Output example indicating that scaling is in progress:

```bash
INFO[2021-07-26T08:54:35-07:00] Running scale nodepool command
clusterName=demo-cluster managementClusterKubeconfig= namespace=default
src="nodepool/scale.go:82"
INFO[2021-07-26T08:54:35-07:00] Nodepool example scaled to 4 replicas
clusterName=demo-cluster managementClusterKubeconfig= namespace=default
src="nodepool/scale.go:94"
```

In a default cluster, the nodes to delete are selected at random. This
behavior is controlled by CAPI's delete policy For more information, see
`<https://github.com/kubernetes-sigs/cluster-api/blob/v0.4.0/api/v1alpha4/>`
machineset_types.go#L85-L105. However, when using the Konvoy CLI to scale down
a node pool, you can specify the Kubernetes Nodes you want to delete.

To do this, set the flag --nodes-to-delete with a list of nodes, as shown in
the next command. This adds an annotation cluster.x-k8s.io/delete-machine=yes
to the matching Machine object that contains status.NodeRef with the node
names from --nodes-to-delete.

```bash
nkp scale nodepools ${NODEPOOL_NAME} --replicas=3 --nodes-to-delete=<> --cluster-
name=${CLUSTER_NAME}
```

1. After a few minutes, you can list the node pools.

```bash
nkp get nodepools --cluster-name=${CLUSTER_NAME} --kubeconfig=${CLUSTER_NAME}.conf
```

Example output showing that the number of DESIRED and READY replicas decreased
to 4:

```bash
INFO[2021-07-26T08:54:35-07:00] Running scale nodepool command
clusterName=demo-cluster managementClusterKubeconfig= namespace=default
src="nodepool/scale.go:82"
INFO[2021-07-26T08:54:35-07:00] Nodepool example scaled to 3 replicas
clusterName=demo-cluster managementClusterKubeconfig= namespace=default
src="nodepool/scale.go:94"
```

###### Scaling Node Pools when Using Cluster Autoscaler

About this task

If you configured the cluster autoscaler for the demo-cluster-md-0 node pool,
the value of --replicas must be within the minimum and maximum bounds.

Procedure

1. For example, assuming you have the these annotations:

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf annotate machinedeployment ${NODEPOOL_NAME}
cluster.x-k8s.io/cluster-api-autoscaler-node-group-min-size=2
kubectl --kubeconfig=${CLUSTER_NAME}.conf annotate machinedeployment ${NODEPOOL_NAME}
cluster.x-k8s.io/cluster-api-autoscaler-node-group-max-size=6
```

1. Try to scale the node pool to 7 replicas with the command:

```bash
nkp scale nodepools ${NODEPOOL_NAME} --replicas=7 -c demo-cluster
```

1. This action results in an error similar to:

```bash
INFO[2021-07-26T09:46:37-07:00] Running scale nodepool command
clusterName=demo-cluster managementClusterKubeconfig= namespace=default
src="nodepool/scale.go:82"
Error: failed to scale nodepool: scaling MachineDeployment is forbidden: desired
replicas 7 is greater than the configured max size annotation cluster.x-k8s.io/
cluster-api-autoscaler-node-group-max-size: 6
```

Similarly, scaling down to a number of replicas less than the configured min-
size also returns an error.

##### vSphere: Replacing Node Pools

This is a Nutanix task.

About this task

In certain situations, you may want to delete a worker node and have Cluster
API replace it with a newly-provisioned machine.

Before you begin

- vSphere Non-Air-gapped: Creating a Cluster on page 870 or vSphere Air-
  gapped: Creating a Cluster on page 887
- vSphere Non-Air-gapped: Making the Cluster Self-Managed on page 875 or
  vSphere Air-gapped: Making the Cluster Self-Managed on page 890

Procedure

1. Identify the name of the node to delete. List the nodes.

```bash
kubectl --kubeconfig ${CLUSTER_NAME}.conf get nodes
```

The output from this command resembles the following:

```bash
NAME STATUS ROLES AGE
VERSION
nutanix-e2e-cluster-1-control-plane-7llgd Ready control-plane,master 20h
v<kubernetes-version>
nutanix-e2e-cluster-1-control-plane-vncbl Ready control-plane,master 20h
v<kubernetes-version>
nutanix-e2e-cluster-1-control-plane-wbgrm Ready control-plane,master 19h
v<kubernetes-version>
nutanix-e2e-cluster-1-md-0-74c849dc8c-67rv4 Ready <none> 20h
v<kubernetes-version>
nutanix-e2e-cluster-1-md-0-74c849dc8c-n2skc Ready <none> 20h
v<kubernetes-version>
nutanix-e2e-cluster-1-md-0-74c849dc8c-nkftv Ready <none> 20h
v<kubernetes-version>
nutanix-e2e-cluster-1-md-0-74c849dc8c-sqklv Ready <none> 20h
v<kubernetes-version>
```

1. Export a variable with the node name to use in the next steps. This example
   uses the name nutanix-e2e-cluster-1-md-0-74c849dc8c-67rv4.

```bash
export NAME_NODE_TO_DELETE="d2iq-e2e-cluster-1-md-0-74c849dc8c-67rv4"
```

1. Delete the Machine resource with the command.

```bash
NAME_MACHINE_TO_DELETE=$(kubectl --kubeconfig ${CLUSTER_NAME}.conf get
machine -ojsonpath="{.items[?(@.status.nodeRef.name==\"$NAME_NODE_TO_DELETE
\")].metadata.name}")
kubectl --kubeconfig ${CLUSTER_NAME}.conf delete machine "$NAME_MACHINE_TO_DELETE"
```

Output:

```bash
machine.cluster.x-k8s.io "d2iq-e2e-cluster-1-md-0-74c849dc8c-67rv4" deleted
```

The command does not return immediately, but it does return after the Machine
resource is deleted.

A few minutes after the Machine resource is deleted, the corresponding Node
resource is also deleted. 4. Observe the Machine resource replacement using
this command:

```bash
kubectl --kubeconfig ${CLUSTER_NAME}.conf get machinedeployment
```

Output

```bash
NAME CLUSTER REPLICAS READY UPDATED
UNAVAILABLE PHASE AGE VERSION
nutanix-e2e-cluster-1-md-0 d2iq-e2e-cluster-1 4 3 4 1
ScalingUp 20h kubernetes-version
```

In this example, there exist 4 replicas, but only 3 are ready. One replica is
unavailable, and the ScalingUp phase means a new Machine is being created. 5.
Identify the replacement Machine using this command:

```bash
export NAME_NEW_MACHINE=$(kubectl --kubeconfig ${CLUSTER_NAME}.conf get machines \
-l=cluster.x-k8s.io/deployment-name=${CLUSTER_NAME}-md-0 \
-ojsonpath='{.items[?(@.status.phase=="Provisioning")].metadata.name}{"\n"}')
echo "$NAME_NEW_MACHINE"
```

If the output is empty, the new Machine has probably exited the Provisioning
phase and entered the Running phase. 6. Identify the replacement Node using
this command:

```bash
kubectl --kubeconfig ${CLUSTER_NAME}.conf get nodes \
-o=jsonpath="{.items[?(@.metadata.annotations.cluster\.x-k8s\.io/machine==
\"$NAME_NEW_MACHINE\")].metadata.name}"
```

The output should be similar to this example:

```bash
nutanix-e2e-cluster-1-md-0-74c849dc8c-rc528
```

If the output is empty, the Node resource is not yet available, or does not
yet have the expected annotation. Wait a few minutes, then repeat the command.

##### vSphere: Deleting Node Pools

Deleting a node pool deletes the Kubernetes nodes and the underlying
infrastructure.

About this task

All nodes will be drained before deletion, and the pods running on those nodes
will be rescheduled.

```yaml
Note: To delete a node pool on the management cluster on NKP 2.18 or later, add -n kommander to the command.
Starting in NKP 2.18, the management cluster runs in the kommander namespace. In NKP 2.17 and earlier, this flag
was not required.
```

Procedure

1. To delete a node pool from a managed cluster, run.

```bash
nkp delete nodepool ${NODEPOOL_NAME} --cluster-name=${CLUSTER_NAME}
```

Here, example is the node pool to be deleted.

The expected output will be similar to the following example, indicating the
node pool is being deleted:

```bash
# Deleting default/example nodepool resources (2)
```

1. Deleting an invalid node pool results in output similar to this example.

```bash
nkp delete nodepool ${CLUSTER_NAME}-md-invalid --cluster-name=${CLUSTER_NAME}
```

Output:

```bash
nkp delete nodepool ${CLUSTER_NAME}-md-invalid --cluster-name=${CLUSTER_NAME}
INFO[2021-07-28T17:11:44-07:00] Running nodepool delete command
Nodepool=demo-cluster-md-invalid clusterName=nutanix-e2e-cluster-1
managementClusterKubeconfig= namespace=default src="nodepool/delete.go:80"
Error: failed to get nodepool with name demo-cluster-md-invalid in namespace
default : failed to get nodepool with name demo-cluster-md-invalid in namespace
default : machinedeployments.cluster.x-k8s.io "demo-cluster-md-invalid" not found
```

#### vSphere: Configuring Cluster Autoscaler

About this task

Cluster Autoscaler provides the ability to automatically scale up or scale
down the number of worker nodes in a cluster based on the number of pending
pods to be scheduled. Running the Cluster Autoscaler is optional. Unlike
Horizontal-Pod Autoscaler, Cluster Autoscaler does not depend on any Metrics
server and does not need Prometheus or any other metrics source.

The Cluster Autoscaler looks at the following annotations on a
MachineDeployment to determine its scale-up and scale-down ranges:

> **Note:**

```bash
cluster.x-k8s.io/cluster-api-autoscaler-node-group-min-size
cluster.x-k8s.io/cluster-api-autoscaler-node-group-max-size
```

The full list of command line arguments to the Cluster Autoscaler controller
is on the Kubernetes public GitHub repository.

For more information about how Cluster Autoscaler works, see these documents:

- What is Cluster Autoscaler
- How does scale-up work
- How does scale-down work
- CAPI Provider for Cluster Autoscaler

Before you begin

Ensure you have the following:

- Bootstrap cluster Life cycle: vSphere Non-Air-gapped: Bootstrapping vSphere
  on page 868
- vSphere Non-Air-gapped: Creating a Cluster on page 870.
- Self-Managed Cluster.

Run Cluster Autoscaler to the Management Cluster

Procedure

1. Ensure the Cluster Autoscaler controller is up and running (no restarts and
   no errors in the logs)

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf logs deployments/cluster-autoscaler
cluster-autoscaler -n kube-system -f
```

1. Enable Cluster Autoscaler by setting the min & max ranges.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf annotate machinedeployment ${NODEPOOL_NAME}
cluster.x-k8s.io/cluster-api-autoscaler-node-group-min-size=2
kubectl --kubeconfig=${CLUSTER_NAME}.conf annotate machinedeployment ${NODEPOOL_NAME}
cluster.x-k8s.io/cluster-api-autoscaler-node-group-max-size=6
```

1. The Cluster Autoscaler logs will show that the worker nodes are associated
   with node-groups and that pending pods are being watched.
2. To demonstrate that it is working properly, create a large deployment that
   will trigger pending pods (For this example, we used AWS m5.2xlarge worker
   nodes. If you have larger worker-nodes, you need to scale up the number of
   replicas accordingly).

```bash
cat <<EOF | kubectl --kubeconfig=${CLUSTER_NAME}.conf apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
name: busybox-deployment
labels:
app: busybox
spec:
replicas: 600
selector:
matchLabels:
app: busybox
template:
metadata:
labels:
app: busybox
spec:
containers:
- name: busybox
image: busybox:latest
command:
- sleep
- "3600"
imagePullPolicy: IfNotPresent
restartPolicy: Always
EOF
```

Cluster Autoscaler will scale up the number of Worker Nodes until there are no
pending pods. 5. Scale down the number of replicas for busybox-deployment.

```bash
kubectl --kubeconfig ${CLUSTER_NAME}.conf scale --replicas=30 deployment/busybox-
deployment
```

1. Cluster Autoscaler starts to scale down the number of Worker Nodes after
   the default timeout of 10 minutes.

##### Run Cluster Autoscaler on a Managed (Workload) Cluster

About this task

Unlike the Management(self-managed) cluster instructions above, an additional
instance of Autoscaler is required to run
Autoscaler on a managed cluster. This instance is run on the management
cluster but must be pointed at the managed
cluster. The nkp create cluster command for building a managed cluster then
runs against the Management cluster so that
the clusterresourcset for that cluster's Autoscaler is modified to deploy the
Autoscaler on the management cluster
itself. The flags for cluster-autoscaler are changed as well.

Procedure

1. Create a secret with a kubeconfig file of the master cluster in the managed
   cluster with limited user permissions to only modify resources for the given
   cluster.
2. Mount the secret into the cluster-autoscaler deployment.
3. Add the following flag to the cluster-autoscaler command so that
   /mnt//masterconfig/ value is the path where the master cluster's kubeconfig
   is loaded through the secret created.

```bash
--cloud-config=/mnt//masterconfig/value
```

#### vSphere: Deleting a Cluster

About this task

```yaml
Note: A self-managed managed cluster cannot delete itself. If your managed cluster is self-managed, you must first
create a bootstrap cluster and move the cluster life cycle services to it before deleting the managed cluster.
```

Procedure

If you did not make your managed cluster self-managed, proceed to the
instructions for Delete the managed cluster.

##### Create a Bootstrap Cluster and Move CAPI Resources

About this task

Procedure

1. The bootstrap cluster will host the Cluster API controllers that reconcile
   the cluster objects marked for deletion. Create a bootstrap cluster. To
   avoid using the wrong kubeconfig, the following steps use explicit
   kubeconfig paths and contexts.

```bash
nkp create bootstrap --kubeconfig $HOME/.kube/config --with-vSphere-bootstrap-
credentials=true
```

The output resembles this example:

```bash
# Creating a bootstrap cluster (6)
# Initializing new CAPI components (10)
```

1. Move the Cluster API objects from the workload to the bootstrap cluster:
   The cluster life cycle services on the bootstrap cluster are ready, but the
   managed cluster configuration is on the managed cluster. The move command
   moves the configuration, which takes the form of Cluster API Custom Resource
   objects, from the workload to the

bootstrap cluster. This process is also called a Pivot (`<<https://cluster->`
api.sigs.k8s.io/reference/glossary.html>? highlight=pivot#pivot).

```bash
nkp move capi-resources \
--from-kubeconfig ${CLUSTER_NAME}.conf \
--from-context ${CLUSTER_NAME}-admin@${CLUSTER_NAME} \
--to-kubeconfig $HOME/.kube/config \
--to-context kind-konvoy-capi-bootstrapper
```

Output:

```bash
INFO[2021-06-09T11:47:11-07:00] Running pivot command
fromClusterKubeconfig=aws-example.conf fromClusterContext= src="move/move.go:83"
toClusterKubeconfig=/home/clusteradmin/.kube/config toClusterContext=
INFO[2021-06-09T11:47:36-07:00] Pivot operation complete.
src="move/move.go:108"
INFO[2021-06-09T11:47:36-07:00] You can now view resources in the moved cluster by
using the --kubeconfig flag with kubectl. For example: kubectl --kubeconfig=/home/
clusteradmin/.kube/config get nodes src="move/move.go:155"
# Moving cluster resources (6)
You can now view resources in the moved cluster by using the --kubeconfig flag with
kubectl. For example: kubectl --kubeconfig $HOME/.kube/config get nodes
```

1. Use the cluster life cycle services on the managed cluster to check the
   managed cluster's status.

```bash
nkp describe cluster --kubeconfig $HOME/.kube/config -c ${CLUSTER_NAME}
```

Output:

```bash
NAME READY SEVERITY
REASON SINCE MESSAGE
Cluster/nutanix-e2e-cluster_name-1 True
13h
##ClusterInfrastructure - VSphereCluster/nutanix-e2e-cluster_name-1 True
13h
##ControlPlane - KubeadmControlPlane/nutanix-control-plane True
13h
# ##Machine/nutanix--control-plane-7llgd True (3)
13h
# ##Machine/nutanix--control-plane-vncbl True (3)
13h
# ##Machine/nutanix--control-plane-wbgrm True (3)
13h
##Workers
##MachineDeployment/nutanix--md-0 True
13h
##Machine/nutanix--md-0-74c849dc8c-67rv4 True
13h
##Machine/nutanix--md-0-74c849dc8c-n2skc True
13h
##Machine/nutanix--md-0-74c849dc8c-nkftv True
13h
##Machine/nutanix--md-0-74c849dc8c-sqklv True
13h
```

After moving the cluster lifecycle services to the managed cluster, remember
to use nkp with the managed cluster kubeconfig. Use DKP with the bootstrap
cluster to delete the managed cluster. 4. Wait for the cluster control-plane
to be ready.

```bash
kubectl --kubeconfig $HOME/.kube/config wait --for=condition=controlplaneready
"clusters/${CLUSTER_NAME}" --timeout=20m
```

Output:

```bash
cluster.cluster.x-k8s.io/vSphere-example condition met
Note: Persistent Volumes (PVs) are not deleted automatically by design to preserve your data. However, the PVs
take up storage space if not deleted. You must delete PVs manually. Information for backup of a cluster and PVs is
on the Back up your Cluster's Applications and Persistent Volumes page.
```

###### Deleting the Workload Cluster (2)

Procedure

1. Make sure your vSphere credentials are up to date. Refresh the credentials
   using this command.

```bash
nkp update bootstrap credentials vSphere --kubeconfig $HOME/.kube/config
```

1. To delete a cluster, Use NKP delete cluster and pass in the name of the
   cluster you are trying to delete with --cluster-name flag. Use kubectl get
   clusters to get those details (--cluster-name and -- namespace) of the
   Kubernetes cluster to delete it.

```bash
kubectl get clusters
```

1. Delete the Kubernetes cluster and wait a few minutes.

```yaml
Note: Before deleting the cluster, Nutanix Kubernetes Platform (NKP) deletes all Services of type LoadBalancer
on the cluster. A vSphere Classic ELB backs each Service. Deleting the Service deletes the ELB that backs it.
To skip this step, use the flag --delete-kubernetes-resources=false. Do not skip this step if NKP
manages the VPC. When NKP deletes the cluster, it deletes the VPC. If the VPC has any vSphere Classic ELBs,
vSphere does not allow the VPC to be deleted, and NKP cannot delete the cluster.
nkp delete cluster --cluster-name=${CLUSTER_NAME} --kubeconfig $HOME/.kube/config
```

Output:

```bash
INFO[2022-03-30T11:53:42-07:00] Running cluster delete command
clusterName=nutanix-e2e-cluster-1 managementClusterKubeconfig= namespace=default
src="cluster/delete.go:95"
INFO[2022-03-30T11:53:42-07:00] Waiting for cluster to be fully deleted
src="cluster/delete.go:123"
INFO[2022-03-30T12:14:03-07:00] Deleted default/nutanix-e2e-cluster-1 cluster
src="cluster/delete.go:129"
```

After the managed cluster is deleted, you can delete the bootstrap cluster.

###### Deleting the Bootstrap Cluster (2)

About this task

After you have moved the workload resources back to a bootstrap cluster and
deleted the managed cluster, you no longer need the bootstrap cluster. You can
safely delete the bootstrap cluster with these steps:

Procedure

1. Make sure your vSphere credentials are up to date. Refresh the credentials
   using this command.

```bash
nkp update bootstrap credentials vSphere --kubeconfig $HOME/.kube/config
```

1. Delete the bootstrap cluster.

```bash
nkp delete bootstrap --kubeconfig $HOME/.kube/config
```

Output:

```bash
INFO[2021-06-09T12:15:20-07:00] Deleting bootstrap cluster
src="bootstrap/bootstrap.go:182"
# Deleting bootstrap cluster (7)
```

What to do next

Once your cluster is built in the Konvoy component of NKP for your
infrastructure/environment, you will install the Kommander component of NKP to
see your dashboard and continue customization. For more information, see
Kommander Customizations on page 996.

Known Limitations

The NKP Konvoy version used to create the managed cluster must match the NKP
Konvoy version used to delete the managed cluster.

> **Note: Be aware of these limitations in the current release of NKP Konvoy.**

## Azure Infrastructure

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

### Azure Prerequisites

Before beginning a Nutanix Kubernetes Platform (NKP) installation, verify that
you have the following:

Prepare your machine and environment to run NKP.

NKP Prerequisites

Before you begin using NKP you must have:

- An x86_64-based Linux or macOS machine with a supported operating system
  version.
- Download the NKP binary for Linux or macOS. To check which version of NKP
  you installed for compatibility reasons, run the NKP version -h command.
- A Container engine/runtime installed is required to install NKP and bootstrap:
- Docker container engine version 27.4.0 installed for Linux or MacOS. For
  more information, see https:// docs.docker.com/get-docker/.
- Podman Version 4.0 or later for Linux. For more information, see
  `<https://podman.io/getting-started/>` installation. For host requirements,
  see `<https://kind.sigs.k8s.io/docs/user/rootless/#host-requirements>`.
- kubectl for interacting with the running cluster.
- Install the Azure CLI
- A valid Azure account with credentials configured.
- Create a custom Azure image using Nutanix Image Builder on page 51.

> **Note: On macOS, Docker runs in a virtual machine. Configure this virtual
> machine with at least 8GB of memory.**

Control Plane Nodes

You must have at least three control plane nodes. Each control plane node
needs to have at least the following:

- 4 cores
- 16 GiB memory
- Approximately 80 GiB of free space for the volume used for /var/lib/kubelet
  and /var/lib/containerd.
- Disk usage must be below 85% on the root volume.

NKP on Azure defaults to deploying an Standard_D4s_v3 virtual machine with a
128 GiB volume for the OS and an 80GiB volume for etcd storage, which meets
the above requirements.

Worker Nodes

You must have at least four worker nodes. The specific number of worker nodes
required for your environment can vary depending on the cluster workload and
size of the nodes. Each worker node needs to have at least the following:

- 8 cores
- 32 GiB memory
- Around 80 GiB of free space for the volume used for /var/lib/kubelet and
  /var/lib/containerd.
- Disk usage must be below 85% on the root volume.

NKP on Azure defaults to deploying a Standard_D4s_v3 instance with an 80GiB
root volume for the OS, which meets the above requirements.

Azure Prerequisites

In Azure, application registration, application objects, and service
principals in Azure Active Directory (Azure AD) are
used for access. An application must be registered with an Azure AD tenant to
delegate identity and access management
functions to Azure AD. An Azure AD application is defined by its only
application object, which resides in the Azure AD.
To access resources secured by an Azure AD tenant, a security principal must
represent the entity that requires access.
This requirement is true for both users (user principal) and applications
(service principal). Therefore, a service
principal is a prerequisite, and the next step explains it.

#### Azure: Creating a Service Principal

About this task

Service principals provide access to Azure resources with your subscription
level. The access is restricted by the roles assigned to the service
principal. For more information, see `<<https://learn.microsoft.com/en->`
us/azure/active-> directory/develop/app-objects-and-service-
principals?tabs=browser and `<https://learn.microsoft.com/en-us/>`
azure/databricks/security/auth-authz/access-control/service-principal-acl.

```yaml
Note: If you have already set a service principal, then the environment variables needed by KIB
([AZURE_CLIENT_SECRET, AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID] ) are
set and do not need repeated if you are still working in the same window.
```

They are listed below if you have not executed the Azure Service Principal
steps.

Procedure

1. Sign in to Azure.

```bash
az login
```

Output

```bash
[
{
"cloudName": "AzureCloud",
"homeTenantId": "a1234567-b132-1234-1a11-1234a5678b90",
"id": "b1234567-abcd-11a1-a0a0-1234a5678b90",
"isDefault": true,
"managedByTenants": [],
"name": "Mesosphere Developer Subscription",
"state": "Enabled",
"tenantId": "a1234567-b132-1234-1a11-1234a5678b90",
"user": {
"name": "user@azuremesosphere.onmicrosoft.com",
"type": "user"
}
}
]
```

1. Create an Azure Service Principal (SP).

This command will rotate the password if an SP with the name exists.

```bash
az ad sp create-for-rbac --role contributor --name "$(whoami)-konvoy" --scopes=/
subscriptions/$(az account show --query id -o tsv) --query "{ client_id: appId,
client_secret: password, tenant_id: tenant }"
{
"client_id": "7654321a-1a23-567b-b789-0987b6543a21",
"client_secret": "DUMMY_CLIENT_SECRET",
"tenant_id": "a1234567-b132-1234-1a11-1234a5678b90"
}
```

1. Set the AZURE_CLIENT_SECRET environment variable.

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
   Azure image. Otherwise, edit the YAML file for your OS directly. For more
   information, see `<https://github.com/mesosphere/konvoy-image-builder/>`
   tree/7447074a6d910e71ad2e61fc4a12820d073ae5ae/images/azure.

#### Azure: Using Nutanix Image Builder

About this task

```yaml
Note: The default Azure image is not recommended for use in production. We suggest using NIB for Azure to build
the image to take advantage of enhanced cluster operations.
```

For more information regarding using the image in creating clusters, see
Azure: Creating a Cluster on page 923.

Procedure

For detailed steps, see Building a Custom Image with Azure on page 61.

### Azure Cluster Creation Customization Choices

Below are two methods to customize your cluster during creation. If none of
these choices apply, proceed to the next section.

- Azure: Non-air-gapped Install on page 920

Azure Section Topics

When creating clusters, many options are available such as those listed in
this section of the documentation. Familiarize yourself with the flags
required to apply these customizations during cluster creation.

- Azure Customizing CAPI Clusters: Familiarize yourself with Cluster API
  before editing the cluster objects because edits can prevent the cluster
  from deploying successfully. For more information, see CAPI Concepts and
  Terms on page 21.
- Azure Registry Mirrors: Configure your cluster to use an existing local
  registry when attempting to pull images by adding the flag(s) to the nkp
  create cluster command to pull images from your local registry. For more
  information, see Using a Registry Mirror on page 1030.
- Azure Load the Registry: Because air-gapped environments do not have direct
  access to the Internet, you must download, extract and load several required
  images to your local container registry, before installing NKP.
- Azure HTTP Proxy: When creating a NKP cluster in environments that use an
  HTTP/HTTPS proxy, you must provide proxy details. The proxy values are
  strings that list a set of proxy servers, URLs, or wildcard addresses that
  is specific to your environment.
- Azure Output Directory YAML: You can create individual files with different
  smaller manifests for ease in editing using the --output-directory flag used
  with --output=json|yaml. You create the directory of where to output
  resources to files.
- Azure Custom DNS: To use a custom Domain Name Servers (DNS) on Azure, you
  need a DNS name in your control. Once the resource group has been created,
  you can create your hosted zone with the command below:
- Azure Marketplace: To allow NKP to create a cluster with Marketplace based
  images such as for Rocky Linux, you must specify them with flags.
-

#### Azure: Customizing CAPI Clusters

Familiarize yourself with Cluster API before editing the cluster objects
because edits can prevent the cluster from deploying successfully.

The result of this command will allow such edits:

```bash
dkp create cluster azure \
--cluster-name=${CLUSTER_NAME} \
--dry-run \
--output=yaml \
> ${CLUSTER_NAME}.yaml
```

To edit the YAML, you need to understand the CAPI components to avoid breaking
the cluster.

#### Azure: Registry Mirrors

Configure your cluster to use an existing local registry (Registry Mirror
Tools on page 1028) when attempting to pull images by adding the flag(s) to
the nkp create cluster command to pull images from your local registry.

Kubernetes does not natively provide a registry for hosting the container
images you will use to run the applications you want to deploy on Kubernetes.
Instead, Kubernetes requires you to use an external solution to store and
share container images. A variety of Kubernetes-compatible registry options
are compatible with NKP.

How the Registry Mirror Works

The first time you request an image from your local registry mirror, it pulls
the image from the public registry (such as Docker) and stores it locally
before handing it back to you. On subsequent requests, the local registry
mirror can serve the image from its storage.

Air-gapped vs. Non-air-gapped Environments

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
premises locally in an air-gapped environment. NKP in an air-gapped
environment requires a local container registry of
trusted images to enable production-level Kubernetes cluster management.
However, a local registry is also an option in
a non-air-gapped environment for speed and security.

If you want to use images from this local registry to deploy applications
inside your Kubernetes cluster, you'll need to set up a secret for a private
registry. The secret contains your login data, which Kubernetes needs to
connect to your private repository.

Set the environment variable with your registry information.

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
export REGISTRY_CA=<path to the cacert file on the bastion>
REGISTRY_URL: the address of an existing local registry accessible in the VPC that the new cluster nodes will be
configured to use a mirror registry when pulling images.
```

Other local registries might use the options below.

- JFrog - REGISTRY_CA: (optional) the path on the Creating a Bastion Host on
  page 707 to the registry CA. This value is only needed if the registry uses
  a self-signed certificate and the AMIs are not already configured to trust
  this CA.
- REGISTRY_USERNAME: optional, set to a user with pull access to this registry.
- REGISTRY_PASSWORD: optional if username is not set.
- Important: To increase Docker Hub's rate limit, use your Docker Hub
  credentials when creating the cluster by setting the following flag on the
  nkp create cluster command.

```bash
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

- Use the flag now during nkp create cluster: --registry-mirror-url

More information and detail can be found:

- Registry Mirror Tools on page 1028
- Using a Registry Mirror on page 1030

#### Azure: Loading the Registry

About this task

Because air-gapped environments do not have direct access to the Internet, you
must download, extract and load several required images to your local
container registry, before installing NKP.

If desired, environments that are non-air-gapped can also perform the follow
steps to use a local registry for speed and security reasons.

Load Images into your Registry

Because air-gapped environments do not have direct access to the Internet, you
must download, extract and load several required images to your local
container registry, before installing NKP.

Before you begin

Download all Images for Air-gapped Deployments

If you are operating in an air-gapped environment, a local container registry
Local Registry Tools containing all the necessary installation images,
including the Kommander images, is required. See below for prerequisites to
download and then how to push the necessary images to this registry.

1. Download the Complete NKP Air-gapped Bundle for this release (i.e. nkp-air-
   gapped-

bundle_v2.8.1_linux_amd64.tar.gz) to load registry images as explained below. 2. Connectivity with clusters attaching to the management cluster is required:

- Both management and attached clusters must be able to connect to the local
  registry.
- The management cluster must be able to connect to all attached cluster's API
  servers.
- The management cluster must be able to connect to any load balancers created
  for platform services on the management cluster.

Extract Air-gapped Images and Set Variables

Follow these steps to extract the air-gapped image bundles into your private
registry using these examples for ECR:

Procedure

1. If not already done in prerequisites, download the air-gapped bundle nkp-
   air-gapped-bundle_nkp-

version_linux_amd64.tar.gz, and extract the tar file to a local directory.

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

| tar -xzvf nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ---------------------------------- | ----------- | ------------------------ |

1. The directory structure after extraction can be accessed in subsequent
   steps using commands to access files from different directories. EX: For the
   bootstrap cluster, change your directory to the nkp-`<version>` directory,
   similar to the example below, depending on your current location
2. Set an environment variable with your registry address for ECR.

To use ECR:

```bash
export REGISTRY_URL=<ecr-registry-URI>
```

Registries other than ECR

- REGISTRY_URL: the address of an existing local registry accessible in the
  VPC that the new cluster nodes will be configured to use a mirror registry
  when pulling images
- Other local registries may use the options below:
- JFrog - CONTAINER_REGISTRY_CA: (optional) the path on the bastion machine to
  the registry CA. This value is only needed if the registry is using a self-
  signed certificate and the AMIs are not already configured to trust this CA.
- CONTAINER_REGISTRY_USERNAME: optional, set to a user that has pull access to
  this registry.
- CONTAINER_REGISTRY_PASSWORD: optional if username is not set.
- The environment where you are running the nkp push command must be
  authenticated with AWS to load your images into ECR.
- Registries other than ECR: Other registry variables:

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
export REGISTRY_CA=<path to the cacert file on the bastion>
```

Before creating or upgrading a Kubernetes cluster, you must load the required
images in a local registry if operating in an air-gapped environment.

| cd nkp- | nkp-version | Col3 |
| ------- | ----------- | ---- |

1. Execute the following command to load the air-gapped image bundle into your
   private registry using any relevant flags to apply the above variables.

Load Images to your Private Registry - Konvoy

Before creating or upgrading a Kubernetes cluster, you need to load the
required images in a local registry if operating in an air-gapped environment.
This registry must be accessible from both the bastion machine and either the
AWS EC2 instances or other machines that will be created for the Kubernetes
cluster.

```yaml
Warning: If you do not already have a local registry set up, refer to Local Registry Tools page for more
information.
```

Execute the following command to load the air-gapped image bundle into your
private registry:

```bash
nkp push bundle --bundle ./container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=${REGISTRY_URL}
Note: It may take some time to push all the images to your image registry, depending on the performance of the
network between the machine you are running the script on and the registry.
```

For specific push flags, refer to the nkp push bundle section of CLI commands.

Additional Flags for Registry push:

The push command will be different depending on username and password
requirements:

If not ECR as shown in the example code below, use the other relevant flags:
--to-registry= ${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME}
--to-registry-password= ${REGISTRY_PASSWORD}

```bash
nkp push bundle --bundle ./container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by
setting the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

1. Load the Kommander component images to your private registry using the
   command.

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-nkp-version.tar
--to-registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-
registry-password=${REGISTRY_PASSWORD}
```

Additional Flags for Registry push:

If not using ECR, the push command will be different depending on username and
password requirements:

The push command will be different depending on username and password
requirements:

```bash
nkp push bundle --bundle ./container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
```

1. On the Bastion, load the Konvoy bootstrap image, using either the Docker or
   Podman command. Docker example:

Podman example:

| docker load -i konvoy-bootstrap-image- | nkp-version | .tar |
| -------------------------------------- | ----------- | ---- |

| podman load -i konvoy-bootstrap-image- | nkp-version | .tar |
| -------------------------------------- | ----------- | ---- |

```bash
podman image tag konvoy-bootstrap:vnkp-version docker.io/mesosphere/konvoy-
bootstrap:vnkp-version
```

> **Note: Replace v nkp-version with the version number. For example, here
> it is v2.15.0.**

#### Azure: HTTP Proxy

When creating a NKP cluster in environments that use an HTTP/HTTPS proxy, you
must provide proxy details. The proxy values are strings that list a set of
proxy servers, URLs, or wildcard addresses that is specific to your
environment.

- --http-proxy
- --https-proxy
- --no-proxy

To create a proxied environment, you need to include flags at various action
item points:

- Bootstrap cluster
- CAPI components
- Cluster creation
- NKP Kommander component

Create the bootstrap cluster and CAPI components using the appropriate
commands, nkp create bootstrap and nkp create capi-components respectively,
combined with the command line flags to include your HTTP/S proxy information.

You can also specify HTTP/S proxy information in an override file when using
Nutanix Image Builder on page 51.

Without these values provided as part of the relevant nkp create command, DKP
cannot create the requisite parts of your new cluster correctly. This is true
of both management and managed clusters alike.

For full HTTP Proxy configuration, you need to specify proxy settings using
all the details in the Cluster Creation with HTTP or HTTPS Proxy on page 699
section of the documentation for:

- Creating a Bootstrap Cluster with HTTP Proxy Settings on page 697
- Creating CAPI Components with HTTP or HTTPS Proxy Settings on page 698
- Cluster Creation with HTTP or HTTPS Proxy on page 699
- HTTP or HTTPS Proxy Configuration for the NKP Kommander Component on page 700

HTTP Proxy Example

```bash
nkp create cluster azure \
--cluster-name ${CLUSTER_NAME} \
--control-plane-http-proxy="${CONTROL_PLANE_HTTP_PROXY}" \
--control-plane-https-proxy="${CONTROL_PLANE_HTTPS_PROXY}" \
--control-plane-no-proxy="${CONTROL_PLANE_NO_PROXY}" \
--worker-http-proxy="${WORKER_HTTP_PROXY}" \
--worker-https-proxy="${WORKER_HTTPS_PROXY}" \
--worker-no-proxy="${WORKER_NO_PROXY}"
```

#### Azure: Output Directory YAML

You can create individual files with different smaller manifests for ease in
editing using the --output-directory flag used with --output=json|yaml. You
create the directory of where to output resources to files.

Using this flag will create multiple files in the specified directory which
must already exist:

```bash
nkp create cluster azure
--cluster-name=${CLUSTER_NAME} \
--dry-run \
--output=yaml \
--output-directory=<existing-directory>
```

For more information regarding this flag or others, please refer to the CLI
section of the documentation for the nkp create cluster command and select
your provider.

#### Azure: Custom DNS

To use a custom Domain Name Server (DNS) on Azure, you need a DNS name in your
control. Once the resource group has been created, you can create your hosted
zone with the command below:

```bash
az network dns zone create --resource-group "d2iq-professional-services" --name
```

You no longer need to create a cluster issuer. Several documents explain
custom DNS in the Kommander component. For more information from the Azure
site, refer to their DNS Overview at `<https://learn.microsoft.com/en-us/>`
azure/dns/dns-overview.

#### Azure: Marketplace

To allow Nutanix Kubernetes Platform (NKP) to create a cluster with Rocky
Linux or RHEL 9.x Marketplace-based images, you must specify them with flags.

If these fields were specified in the override file during image creation
image creation, the flags must be used in cluster creation:

- --plan-offer, --plan-publisher and --plan-sku

```bash
--plan-offer rockylinux-OS-version
--plan-publisher erockyenterprisesoftwarefoundationinc1653071250513
--plan-sku rockylinux-OS-version
```

For more information about the supported Operating System, see Supported
Infrastructure Operating Systems on page 12.

```yaml
Warning: If you see a similar error to "Creating a virtual machine from Marketplace image or a custom image sourced
from a Marketplace image requires Plan information in the request." when creating a cluster, you must also set the
following flags --plan-offer, --plan-publisher, --plan-sku. For example, when creating a cluster with
Rocky Linux VMs, add the following flags to your nkp create cluster azure command: --plan-offer,
--plan-publisher and --plan-sku
```

Conversely, if you do not use these fields when you create a machine image
with NIB, you do not need to set these flags when you create your cluster with
NKP.

```bash
---
download_images: true
packer:
distribution: "rockylinux-OS-version" # Offer
distribution_version: "rockylinux-OS-version" # SKU
# Azure Rocky linux official image: https://portal.azure.com/
#view/Microsoft_Azure_Marketplace/GalleryItemDetailsBladeNopdl/id/
erockyenterprisesoftwarefoundationinc1653071250513.rockylinux-OS-version
image_publisher: "erockyenterprisesoftwarefoundationinc1653071250513"
image_version: "latest"
ssh_username: "azureuser"
plan_image_sku: "rockylinux-OS-version" # SKU
plan_image_offer: "rockylinux-OS-version" # offer
plan_image_publisher: "erockyenterprisesoftwarefoundationinc1653071250513" #
publisher
build_name: "rocky-OS-version-az"
packer_builder_type: "azure"
python_path: ""
```

In order to create a cluster with Marketplace-based images using the supported
RHEL v9.6 Operating System, you must specify them in the cluster create
command:

```bash
nkp create cluster azure \
--plan-publisher redhat \
--plan-offer "rh-rhel" \
--plan-sku "rh-rhel9" ...
```

See the following for images:

- Azure Marketplace: `<<https://azuremarketplace.microsoft.com/en->`
  us/marketplace/apps>? search=procomputers&page=1
- Rocky Linux: `<<https://forums.rockylinux.org/t/azure-rocky-image-on->`
  marketplace/5230>

### Azure: Non-air-gapped Install

This installation provides instructions on how to install Nutanix Kubernetes
Platform (NKP) in an Azure non-air- gapped environment.

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

Before you begin using Konvoy with Azure, you must meet all the Azure
Prerequisites on page 910.

To deploy a cluster with a custom image in a region where CAPI images are not
provided, you need to use Nutanix Image Builder on page 51 to create your own
image for the region.

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

#### Azure: Bootstrapping Azure

About this task

To get started, you need a bootstrap cluster. By default, Nutanix Kubernetes
Platform (NKP) creates a bootstrap cluster for you in a Docker container using
the Kubernetes-in-Docker (KIND) tool.

Before you begin

Procedure

1. Complete the Nutanix Infrastructure Prerequisites. For more information,
   see Nutanix Infrastructure Requirements on page 719.
2. Ensure the nkp binary can be found in your $PATH.

##### Bootstrap Cluster Life Cycle Services (3)

Procedure

1. Review Universal Configurations for all Infrastructure Providers regarding
   settings, flags, and other choices and then begin bootstrapping.
2. Create a bootstrap cluster using the command.

```bash
nkp create bootstrap --kubeconfig $HOME/.kube/config
```

Example output:

```bash
# Creating a bootstrap cluster (7)
# Initializing new CAPI components (11)
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

To create a bootstrap cluster in a proxied environment (Bootstrap Cluster HTTP
Proxy Settings on page 697), in addition to any other flags you need, run the
following command.

```bash
--http-proxy <string> \
--https-proxy <string> \
--no-proxy <string>
```

1. NKP creates a bootstrap cluster using KIND as a library.

For more information, see `<https://github.com/kubernetes-sigs/kind>`. 4. NKP
then deploys the following Cluster API providers on the cluster.

- Core Provider: `<https://github.com/kubernetes-sigs/cluster-api/tree/v0.3.20/>`
- AWS Infrastructure Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api-provider-aws>
- Kubeadm Bootstrap Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api/tree/v0.3.20/bootstrap/> kubeadm
- Kubeadm ControlPlane Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api/tree/v0.3.20/> controlplane/kubeadm

For more information on Cluster APIs, see `<https://cluster-api.sigs.k8s.io/>`. 5. NKP waits until these providers' controller-manager and webhook deployments
are ready. List these deployments using the command.

```bash
kubectl get --all-namespaces deployments -l=clusterctl.cluster.x-k8s.io
```

Output example:

```bash
NAMESPACE NAME
READY UP-TO-DATE AVAILABLE AGE
capa-system capa-controller-manager
1/1 1 1 1h
capg-system capg-controller-manager
1/1 1 1 1h
capi-kubeadm-bootstrap-system capi-kubeadm-bootstrap-controller-manager
1/1 1 1 1h
capi-kubeadm-control-plane-system capi-kubeadm-control-plane-controller-manager
1/1 1 1 1h
capi-system capi-controller-manager
1/1 1 1 1h
cappp-system cappp-controller-manager
1/1 1 1 1h
capv-system capv-controller-manager
1/1 1 1 1h
capz-system capz-controller-manager
1/1 1 1 1h
cert-manager cert-manager
1/1 1 1 1h
cert-manager cert-manager-cainjector
1/1 1 1 1h
cert-manager cert-manager-webhook
1/1 1 1 1h
```

(Optional) Create Identity Secret for Azure

If your bootstrap cluster resides on a Virtual machine inside Azure, create an
identity secret that uses the cappz- controller:

```bash
export AZURE_CLUSTER_IDENTITY_SECRET_NAME="cluster-identity-secret"
export CLUSTER_IDENTITY_NAME="cluster-identity"
export AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE="default"
kubectl create secret generic ${AZURE_CLUSTER_IDENTITY_SECRET_NAME} --from-
literal=clientSecret=${AZURE_CLIENT_SECRET}
```

#### Azure: Creating a Cluster

About this task

Use this procedure to create a Kubernetes cluster with NKP. A self-managed
cluster is one in which the CAPI resources and controllers that describe and
manage it run on the same cluster they are managing. First, you must name your
cluster.

Before you begin

Procedure

1. Give your cluster a unique name suitable for your environment.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the environment variable using
the command export CLUSTER_NAME=`<azure-example>`.

a. To create a cluster name that is unique, use the following command. This
creates a unique name every time you run it, so use it with forethought:

```bash
export CLUSTER_NAME=azure-example-$(LC_CTYPE=C tr -dc 'a-z0-9' </dev/urandom |
fold -w 5 | head -n1)
echo $CLUSTER_NAME
azure-example-pf4a3
```

##### Encode your Azure Credential Variables

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

##### Creating an Azure Kubernetes Cluster

About this task

If you use these instructions to create a cluster on Azure using the NKP
default settings without any edits to configuration files or additional flags,
your cluster is deployed with three control plane nodes, and four worker
nodes.

NKP uses Azure CSI as the default storage provider. You can use a Kubernetes
CSI compatible storage solution suitable for production. For more information,
see the Kubernetes documentation called Changing the Default Storage Class.

Procedure

1. Create an Azure Image using NIB and use the flag --compute-gallery-id to
   identify the image.

```bash
...
--compute-gallery-id "<Managed Image Shared Image Gallery Id>"
```

> **Note: The --compute-gallery-id image format is as follows:**

```bash
--compute-gallery-id /subscriptions/<subscription id>/resourceGroups/
<resource group
name>/providers/Microsoft.Compute/galleries/<gallery name>/images/
<image definition
name>/versions/<version id>
Note: If you use a base image from the Azure Marketplace to build your Azure Image, you must also provide the
plan information for that base image using the flags --plan-offer, --plan-publisher, and --plan-
sku.
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

» Additional Options for your environment; otherwise, proceed to the next step
to create your cluster. (Optional) Modify
Control Plane Audit logs - Users can modify the KubeadmControlplane cluster-
API object to configure different kubelet
options. See the following guide if you wish to configure your control plane
beyond the existing options available from
flags. 3. Availability zones (AZs), which are isolated locations within
datacenter regions from which public cloud
services originate and operate. Because all the nodes in a node pool are
deployed in a single Availability Zone, you may
wish to create additional node pools to ensure your cluster has nodes deployed
in multiple Availability Zones.

```yaml
Note: By default, the control-plane Nodes will be created in 3 different zones. However, the default worker
Nodes will reside in a single Availability Zone. You may create additional node pools in other Availability
```

Zones with the dkp create nodepool command. See Microsoft's documentation for
more information on Availability Options for Azure VM. 4. Default Storage
Provisioning: The below cluster creation directions instead describes how to
create a cluster using Azure as the infrastructure provider provisioning
clusters, which uses Azure Disks Container Storage Interface as the default
StorageClass.

```yaml
Warning: If you are using Azure as a Pre-provisioned environment: NKP uses localvolumeprovisioner
as the default storage provider if creating a pre-provisioned Azure cluster. However,
localvolumeprovisioner is not suitable for production use. You should use a Kubernetes CSI
compatible storage that is suitable for production.
```

You can choose from any of the storage options available for Kubernetes. To
disable the default that Konvoy deploys, set
the default StorageClass localvolumeprovisioner as non-default. Then set your
newly created StorageClass to be the
default by following the commands in the Kubernetes documentation called
Changing the Default Storage Class. 5. Generate
the Kubernetes cluster objects. See nkp create cluster azure reference for the
full list of cluster creation options. 6.
(Optional) Use a registry mirror. Configure your cluster to use an existing
local registry as a mirror when attempting
to pull images previously pushed to your registry.

Export Registry Variables and Flags for Cluster Creation:: If you have a local
registry, you must provide additional arguments when creating the cluster.
These tell the cluster where to locate the local registry to use by defining
the URL. Set the needed environment variable(s) with your registry
information:

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
  Konvoy will configure the cluster nodes to trust this CA. This value is only
  needed if the registry is using a self-signed certificate and the AMIs are
  not already configured to trust this CA.
- REGISTRY_USERNAME: optional, set to a user that has pull access to this
  registry.
- REGISTRY_PASSWORD: optional if username is not set.

When creating the cluster, apply the variables you defined above during the
dkp create cluster command with the flags needed for your environment:

```bash
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-cacert=${REGISTRY_CA} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD}
```

1. Create a cluster. Run this command to create your Kubernetes cluster using
   any relevant flags.

```bash
nkp create cluster azure \
--cluster-name=${CLUSTER_NAME} \
--dry-run \
--output=yaml \
> ${CLUSTER_NAME}.yaml
```

Output:

```bash
Generating cluster resources
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-
proxy, and --no-proxy with their values in the command to ensure it runs successfully. For more
information, see Configuring an HTTP or HTTPS Proxy on page 696.
```

- FIPS Requirements on page 710
- Configuring an HTTP or HTTPS Proxy on page 696
- Azure: Custom DNS on page 919
- Using Custom Image:

When creating your cluster, you will add this flag during the create process
for your custom image: -- compute-gallery-id "`<Managed Image Shared Image Gallery Id>`". See the Prerequisites section Azure Using Nutanix Image Builder
for specific consumption of image commands.

The SKU and Image Name will default to the values found in the image YAML.

- Azure: Marketplace on page 919
- Individual manifests using the Output Directory flag: You can create
  individual manifest files with different smaller manifests for ease in
  editing using the --output-directory flag. For more information, see Output
  Directory Flag on page 710.

Refer to the Azure Cluster Creation Customization Choices on page 913 section
for more information on how to use optional flags such as the --output-
directory flag.

For more information regarding this flag or others, please refer to the CLI
for the nkp create cluster section of the documentation and select your
provider. 8. Inspect or edit the cluster objects. Familiarize yourself with
the Cluster API before editing the cluster objects, as edits can prevent the
cluster from deploying successfully.

See Azure: Customizing CAPI Clusters on page 914. 9. (Optional) Modify Control
Plane Audit logs - Users can make
modifications to the KubeadmControlplane cluster-api object to configure
different kubelet options. See Control Plane
Configuration on page 1032 if you wish to configure your control plane beyond
the existing options that are available
from flags. 10. Create the cluster from the objects generated from the dry
run. A warning will appear in the console if
the resource already exists, requiring you to remove the resource or update
your YAML.

```bash
kubectl create -f ${CLUSTER_NAME}.yaml
Note: If you used the --output-directory flag in your nkp create .. --dry-run step above,
create the cluster from the objects you created by specifying the directory:
kubectl create -f <existing-directory>/.
```

Output:

```bash
cluster.cluster.x-k8s.io/azure-example created
azurecluster.infrastructure.cluster.x-k8s.io/azure-example created
kubeadmcontrolplane.controlplane.cluster.x-k8s.io/azure-example-control-plane
created
azuremachinetemplate.infrastructure.cluster.x-k8s.io/azure-example-control-plane
created
secret/azure-example-etcd-encryption-config created
machinedeployment.cluster.x-k8s.io/azure-example-md-0 created
azuremachinetemplate.infrastructure.cluster.x-k8s.io/azure-example-md-0 created
kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/azure-example-md-0 created
clusterresourceset.addons.cluster.x-k8s.io/calico-cni-installation-azure-example
created
configmap/calico-cni-installation-azure-example created
configmap/tigera-operator-azure-example created
clusterresourceset.addons.cluster.x-k8s.io/azure-disk-csi-azure-example created
configmap/azure-disk-csi-azure-example created
clusterresourceset.addons.cluster.x-k8s.io/cluster-autoscaler-azure-example created
configmap/cluster-autoscaler-azure-example created
clusterresourceset.addons.cluster.x-k8s.io/node-feature-discovery-azure-example
created
configmap/node-feature-discovery-azure-example created
clusterresourceset.addons.cluster.x-k8s.io/nvidia-feature-discovery-azure-example
created
configmap/nvidia-feature-discovery-azure-example created
```

1. Wait for the cluster control plan to be ready.

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --
timeout=20m
```

Output:

```bash
cluster.cluster.x-k8s.io/azure-example condition met
```

1. After the objects are created on the API server, the Cluster API
   controllers reconcile them. They create infrastructure and machines. As they
   progress, they update the Status of each object. Konvoy provides a command
   to describe the current status of the cluster.

```bash
nkp describe cluster -c ${CLUSTER_NAME}
```

Output:

```bash
NAME READY SEVERITY
REASON SINCE MESSAGE
Cluster/azure-example True
3m4s
##ClusterInfrastructure - AzureCluster/azure-example True
8m26s
##ControlPlane - KubeadmControlPlane/azure-example-control-plane True
3m4s
# ##Machine/azure-example-control-plane-l8j9r True
3m9s
# ##Machine/azure-example-control-plane-slprd True
7m17s
# ##Machine/azure-example-control-plane-xhxxg True
5m9s
##Workers
##MachineDeployment/azure-example-md-0 True
4m31s
##Machine/azure-example-md-0-d67567c8b-2674r True
5m19s
##Machine/azure-example-md-0-d67567c8b-mbmhk True
5m17s
##Machine/azure-example-md-0-d67567c8b-pzg8k True
5m17s
##Machine/azure-example-md-0-d67567c8b-z8km9 True
5m17s
```

1. As they progress, the controllers also create Events, which you can list
   using the command

```bash
kubectl get events | grep ${CLUSTER_NAME}
```

For brevity, this example uses grep. You can also use separate commands to get
Events for specific objects, such as kubectl get events --field-selector
involvedObject.kind="VSphereCluster" and kubectl get events --field-selector
involvedObject.kind="VSphereMachine".

Output:

```bash
15m Normal AzureClusterObjectNotFound azurecluster
AzureCluster object default/azure-example not
found
15m Normal AzureManagedControlPlaneObjectNotFound
azuremanagedcontrolplane AzureManagedControlPlane
object default/azure-example not found
15m Normal AzureClusterObjectNotFound azurecluster
AzureCluster.infrastructure.cluster.x-k8s.io
"azure-example" not found
8m22s Normal SuccessfulSetNodeRef machine/azure-
example-control-plane-bmc9b azure-example-control-plane-fdvnm
10m Normal Machine controller dependency not yet met azuremachine/
azure-example-control-plane-fdvnm Machine Controller has not yet set OwnerRef
12m Normal SuccessfulSetNodeRef machine/azure-
example-control-plane-msftd azure-example-control-plane-z9q45
10m Normal SuccessfulSetNodeRef machine/azure-
example-control-plane-nrvff azure-example-control-plane-vmqwx
12m Normal Machine controller dependency not yet met azuremachine/
azure-example-control-plane-vmqwx Machine Controller has not yet set OwnerRef
14m Normal Machine controller dependency not yet met azuremachine/
azure-example-control-plane-z9q45 Machine Controller has not yet set OwnerRef
14m Warning VMIdentityNone
azuremachinetemplate/azure-example-control-plane You are using Service Principal
authentication for Cloud Provider Azure which is less secure than Managed
Identity. Your Service Principal credentials will be written to a file on the
disk of each VM in order to be accessible by Cloud Provider. To learn more, see
https://capz.sigs.k8s.io/topics/identities-use-cases.html#azure-host-identity
12m Warning ControlPlaneUnhealthy
kubeadmcontrolplane/azure-example-control-plane Waiting for control plane to
pass preflight checks to continue reconciliation: [machine azure-example-control-
plane-msftd does not have APIServerPodHealthy condition, machine azure-example-
control-plane-msftd does not have ControllerManagerPodHealthy condition, machine
azure-example-control-plane-msftd does not have SchedulerPodHealthy condition,
machine azure-example-control-plane-msftd does not have EtcdPodHealthy condition,
machine azure-example-control-plane-msftd does not have EtcdMemberHealthy
condition]
11m Warning ControlPlaneUnhealthy
kubeadmcontrolplane/azure-example-control-plane Waiting for control plane to
pass preflight checks to continue reconciliation: [machine azure-example-control-
plane-nrvff does not have APIServerPodHealthy condition, machine azure-example-
control-plane-nrvff does not have ControllerManagerPodHealthy condition, machine
azure-example-control-plane-nrvff does not have SchedulerPodHealthy condition,
machine azure-example-control-plane-nrvff does not have EtcdPodHealthy condition,
machine azure-example-control-plane-nrvff does not have EtcdMemberHealthy
condition]
9m52s Normal SuccessfulSetNodeRef machine/azure-
example-md-0-84bd8b5f5b-b8cnq azure-example-md-0-bsc82
9m53s Normal SuccessfulSetNodeRef machine/azure-
example-md-0-84bd8b5f5b-j8ldg azure-example-md-0-mjcbn
9m52s Normal SuccessfulSetNodeRef machine/azure-
example-md-0-84bd8b5f5b-lx89f azure-example-md-0-pmq8f
10m Normal SuccessfulSetNodeRef machine/azure-
example-md-0-84bd8b5f5b-pcv7q azure-example-md-0-vzprf
15m Normal SuccessfulCreate machineset/azure-
example-md-0-84bd8b5f5b Created machine "azure-example-md-0-84bd8b5f5b-
j8ldg"
15m Normal SuccessfulCreate machineset/azure-
example-md-0-84bd8b5f5b Created machine "azure-example-md-0-84bd8b5f5b-
lx89f"
15m Normal SuccessfulCreate machineset/azure-
example-md-0-84bd8b5f5b Created machine "azure-example-md-0-84bd8b5f5b-
pcv7q"
15m Normal SuccessfulCreate machineset/azure-
example-md-0-84bd8b5f5b Created machine "azure-example-md-0-84bd8b5f5b-
b8cnq"
15m Normal Machine controller dependency not yet met azuremachine/
azure-example-md-0-bsc82 Machine Controller has not yet set OwnerRef
15m Normal Machine controller dependency not yet met azuremachine/
azure-example-md-0-mjcbn Machine Controller has not yet set OwnerRef
15m Normal Machine controller dependency not yet met azuremachine/
azure-example-md-0-pmq8f Machine Controller has not yet set OwnerRef
Note: If changing the Pre-provisioned: Modifying the Calico Installation on page 779, Nutanix
recommends changing it after cluster creation, but before production.
Note: NKP uses the Azure CSI driver as the default storage provider. Use a Kubernetes CSI compatible
storage that is suitable for production. For more information, see the Kubernetes documentation called Changing
the Default Storage Class at https://kubernetes.io/docs/concepts/storage/volumes/#volume-types.
If you're not using the default, you cannot deploy an alternate provider until after the is finished. However,nkp
create cluster must be determined before the Kommander installation.
```

Known Limitations

> **Note: Be aware of these limitations in the current release of NKP Konvoy.**

- • The NKP Konvoy version used to create a bootstrap cluster must match the
  NKP Konvoy version used to create a managed cluster.
- NKP Konvoy supports deploying one managed cluster.
- NKP Konvoy generates a set of objects for one Node Pool.
- NKP Konvoy does not validate edits to cluster objects.

#### Azure: Making the Cluster Self-Managed

About this task

Nutanix Kubernetes Platform (NKP) deploys all cluster life cycle services to a
bootstrap cluster, which then deploys a managed cluster. When the managed
cluster is ready, move the cluster life cycle services to the workload
cluster, which makes the managed cluster self-managed.

Before you begin

Before starting, ensure you can create a managed cluster as described in the
topic: Create a New Azure Cluster.

This page contains instructions on how to make your cluster self-managed. This
is necessary if there is only one cluster in your environment or if this
cluster becomes the Management cluster in a multi-cluster environment.

> **Note: If you already have a self-managed or Management cluster in your
> environment, skip this page.**

Make the New Kubernetes Cluster Manage Itself

Follow these steps to turn your new cluster into a Management Cluster for an
Ultimate license environment (or a free-standing Pro Cluster):

Procedure

1. Deploy cluster life cycle services on the managed cluster.

```bash
nkp create capi-components --kubeconfig ${CLUSTER_NAME}.conf
```

Output:

```bash
# Initializing new CAPI components (12)
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

1. The cluster life cycle services on the managed cluster are ready, but the
   managed cluster configuration is on the bootstrap cluster. The move command
   moves the configuration, which takes the form of Cluster API Custom Resource
   objects, from the bootstrap to the managed cluster. This process is called a
   Pivot. For more information, see `<<https://cluster->`
   api.sigs.k8s.io/reference/glossary.html?highlight=pivot#pivot>.

Move the Cluster API objects from the bootstrap to the workload cluster:

```bash
nkp move capi-resources --to-kubeconfig ${CLUSTER_NAME}.conf
```

Output:

```bash
# Moving cluster resources (7)
You can now view resources in the moved cluster by using the --kubeconfig flag with
kubectl. For example: kubectl --kubeconfig=gcp-example.conf get nodes
Note: To ensure only one set of cluster life cycle services manages the managed cluster, NKP first pauses the
reconciliation of the objects on the bootstrap cluster, then creates the objects on the managed cluster. As NKP
copies the objects, the cluster life cycle services on the managed cluster reconcile the objects. The managed cluster
becomes self-managed after NKP creates all the objects. If it fails, the move command can be safely retried.
```

1. Wait for the cluster control plan to be ready.

```bash
kubectl --kubeconfig ${CLUSTER_NAME}.conf wait --for=condition=Available=True
"clusters/${CLUSTER_NAME}" --timeout=20m
```

Output:

```bash
cluster.cluster.x-k8s.io/gcp-example condition met
```

1. Use the cluster life cycle services on the managed cluster to check the
   managed cluster status. After moving the cluster life cycle services to the
   managed cluster, remember to use NKP with the managed cluster kubeconfig.

```bash
nkp describe cluster --kubeconfig ${CLUSTER_NAME}.conf -c ${CLUSTER_NAME}
```

Output:

```bash
NAME READY SEVERITY
REASON SINCE MESSAGE
Cluster/azure-example True
55s
##ClusterInfrastructure - AzureCluster/azure-example True
67s
##ControlPlane - KubeadmControlPlane/azure-example-control-plane True
55s
# ##Machine/azure-example-control-plane-67f47 True
58s
# ##Machine/azure-example-control-plane-7pllh True
65s
# ##Machine/azure-example-control-plane-jtfgv True
65s
##Workers

##MachineDeployment/azure-example-md-0 True
67s
##Machine/azure-example-md-0-f9cb9c79b-6nsb9 True
59s
##Machine/azure-example-md-0-f9cb9c79b-jxwl6 True
58s
##Machine/azure-example-md-0-f9cb9c79b-ktg7z True
59s
##Machine/azure-example-md-0-f9cb9c79b-nxcm2 True
66s
```

1. Remove the bootstrap cluster because the managed cluster is now self-managed.

```bash
nkp delete bootstrap --kubeconfig $HOME/.kube/config
```

Output:

```bash
# Deleting bootstrap cluster (8)
```

##### Known Limitations (4)

Procedure

- NKP only supports moving all namespaces in the cluster; NKP does not support
  migration of individual namespaces.
- Konvoy supports moving only one set of cluster objects from the bootstrap
  cluster to the managed cluster or vice- versa.

#### Azure: Exploring the Azure Cluster

About this task

Before starting, create a managed cluster, as described in Create a New Azure
Cluster.

Procedure

1. Get a kubeconfig file for the managed cluster. When the managed cluster is
   created, the cluster life cycle services generate a kubeconfig file for the
   managed cluster and write it to a Secret. The kubeconfig file is scoped to
   the cluster administrator.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
```

1. Verify the API server is up by listing the nodes.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get nodes
Note: The Status may take a few minutes to move to Ready while the Pod network is deployed. The node status
will change to Ready soon after the calico-node DaemonSet Pods are Ready.
```

Example output:

```bash
NAME STATUS ROLES AGE VERSION
azure-example-control-plane-7ffnl Ready control-plane,master 6m18s
v<kubernetes-version>
azure-example-control-plane-l4bv8 Ready control-plane,master 14m
v<kubernetes-version>
azure-example-control-plane-n4g4l Ready control-plane,master 18m
v<kubernetes-version>
azure-example-md-0-mpctb Ready <none> 15m
v<kubernetes-version>
azure-example-md-0-qglp9 Ready <none> 15m
v<kubernetes-version>
azure-example-md-0-sgrd6 Ready <none> 16m
v<kubernetes-version>
azure-example-md-0-wzbkl Ready <none> 16m
v<kubernetes-version>
```

1. List the Pods with the command.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get --all-namespaces pods
```

Verify the output:

```bash
NAMESPACE NAME
READY STATUS RESTARTS AGE
calico-system calico-kube-controllers-57fbd7bd59-v4tss
1/1 Running 0 19m
calico-system calico-node-59llv
1/1 Running 0 17m
calico-system calico-node-7t7wj
1/1 Running 0 16m
calico-system calico-node-pf8q8
1/1 Running 0 17m
calico-system calico-node-sh2b7
1/1 Running 0 8m17s
calico-system calico-node-tmxl5
1/1 Running 0 19m
calico-system calico-node-vt5fh
1/1 Running 0 18m
calico-system calico-node-whfs8
1/1 Running 0 18m
calico-system calico-typha-797c9666d5-5w99r
1/1 Running 0 19m
calico-system calico-typha-797c9666d5-hj6mj
1/1 Running 0 18m
calico-system calico-typha-797c9666d5-s7rc6
1/1 Running 0 17m
capa-system capa-controller-manager-74fffb5676-ch6xd
1/1 Running 0 11m
capi-kubeadm-bootstrap-system capi-kubeadm-bootstrap-controller-
manager-867759cc67-vg4lh 1/1 Running 0 15m
capi-kubeadm-control-plane-system capi-kubeadm-control-plane-controller-
manager-5df55579c4-pc8x9 1/1 Running 1 (11m ago) 15m
capi-system capi-controller-manager-79cc58bf5f-xsp9t
1/1 Running 0 15m
cappp-system cappp-controller-manager-85b5c77497-8ss8r
1/1 Running 0 14m
capv-system capv-controller-manager-7bf4d8b66-6x2mx
1/1 Running 0 14m
capz-system capz-controller-manager-5d4c6468bf-wfhcc
1/1 Running 0 14m
capz-system capz-nmi-2cbrg
1/1 Running 0 14m
capz-system capz-nmi-8dllm
1/1 Running 0 14m
capz-system capz-nmi-95dfk
1/1 Running 0 14m
capz-system capz-nmi-rtnd4
1/1 Running 0 14m
cert-manager cert-manager-848f547974-gjc5p
1/1 Running 1 (10m ago) 15m
cert-manager cert-manager-cainjector-54f4cc6b5-rnh4f
1/1 Running 0 15m
cert-manager cert-manager-webhook-7c9588c76-rn2sd
1/1 Running 0 15m
kube-system cluster-autoscaler-68c759fbf6-6vg5r
1/1 Running 1 (11m ago) 20m
kube-system coredns-78fcd69978-6gx44
1/1 Running 0 20m
kube-system coredns-78fcd69978-gr5q7
1/1 Running 0 20m
kube-system csi-azuredisk-controller-c8fb44c8b-jhmfz
6/6 Running 5 (11m ago) 20m
kube-system csi-azuredisk-controller-c8fb44c8b-lpbbs
6/6 Running 0 20m
kube-system csi-azuredisk-node-2g7vw
3/3 Running 0 8m17s
kube-system csi-azuredisk-node-6rdqc
3/3 Running 0 18m
kube-system csi-azuredisk-node-99c6q
3/3 Running 0 17m
kube-system csi-azuredisk-node-9b4ms
3/3 Running 0 17m
kube-system csi-azuredisk-node-mz5pr
3/3 Running 0 18m
kube-system csi-azuredisk-node-r2t99
3/3 Running 0 16m
kube-system csi-azuredisk-node-t7gfs
3/3 Running 0 20m
kube-system etcd-azure-example-control-plane-7ffnl
1/1 Running 0 8m15s
kube-system etcd-azure-example-control-plane-l4bv8
1/1 Running 0 16m
kube-system etcd-azure-example-control-plane-n4g4l
1/1 Running 0 19m
kube-system kube-apiserver-azure-example-control-plane-7ffnl
1/1 Running 0 8m16s
kube-system kube-apiserver-azure-example-control-plane-l4bv8
1/1 Running 0 16m
kube-system kube-apiserver-azure-example-control-plane-n4g4l
1/1 Running 0 19m
kube-system kube-controller-manager-azure-example-control-
plane-7ffnl 1/1 Running 0 8m17s
kube-system kube-controller-manager-azure-example-control-
plane-l4bv8 1/1 Running 0 16m
kube-system kube-controller-manager-azure-example-control-
plane-n4g4l 1/1 Running 1 (17m ago) 19m
kube-system kube-proxy-82zdl
1/1 Running 0 8m17s
kube-system kube-proxy-fd9f9
1/1 Running 0 18m
kube-system kube-proxy-l6lgc
1/1 Running 0 17m
kube-system kube-proxy-lzswh
1/1 Running 0 16m
kube-system kube-proxy-ndfmt
1/1 Running 0 20m
kube-system kube-proxy-nxlp9
1/1 Running 0 18m
kube-system kube-proxy-v9sxp
1/1 Running 0 17m
kube-system kube-scheduler-azure-example-control-plane-7ffnl
1/1 Running 0 8m16s
kube-system kube-scheduler-azure-example-control-plane-l4bv8
1/1 Running 0 16m
kube-system kube-scheduler-azure-example-control-plane-n4g4l
1/1 Running 1 (17m ago) 19m
node-feature-discovery node-feature-discovery-master-84c67dcbb6-d2gm7
1/1 Running 0 20m
node-feature-discovery node-feature-discovery-worker-drgf6
1/1 Running 0 17m
node-feature-discovery node-feature-discovery-worker-hcz6k
1/1 Running 0 17m
node-feature-discovery node-feature-discovery-worker-pgbcd
1/1 Running 0 16m
node-feature-discovery node-feature-discovery-worker-vhj96
1/1 Running 0 16m
tigera-operator tigera-operator-d499f5c8f-jnj8b
1/1 Running 1 (18m ago) 19m
```

#### Azure: Installing Kommander

About this task

Once you have installed the Konvoy component of Nutanix Kubernetes Platform
(NKP), you will continue installing the Kommander component that will bring up
the UI dashboard.

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
- Ensure you have a default StorageClass. For more information, see Creating a
  Default StorageClass on page 475.
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

1. If required: Customize your kommander.yaml. See the Kommander
   Customizations page for customization options. Some options include Custom
   Domains and Certificates, HTTP proxy, External Load Balancer, GPU
   utilization, Rook Ceph customization for Pre-provisioned environments, and
   so on.
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

1. Expand one of the following sets of instructions, depending on your license
   and application environments:

» Pro License: Install Kommander in a Non-Air-Gapped Environment

Pro License: Install Kommander

Use the customized kommander.yaml to install NKP:

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

Kommander Customizations

You can configure the Kommander component of NKP during the initial
installation, and also post-installation using the NKP CLI. If you are not
sure of what you want to customize during install, then proceed to the next
step. To read about Kommander component customization options, refer to this
section of the documentation: Kommander Customizations on page 996

### Azure Management Tools

After cluster creation and configuration, you can revisit clusters to update
and change the variables. You can perform steps such as renew a certificate,
replace a node, or delete an Azure cluster. Use these tools to perform the
actions to manage your Azure cluster and NKP on Azure Infrastructure.

#### Azure: Replacing a Node

Before you begin

- Azure: Creating a Cluster on page 923
- Azure: Making the Cluster Self-Managed on page 929

Procedure

1. Identify the name of the node to delete. List the nodes.

```bash
kubectl --kubeconfig ${CLUSTER_NAME}.conf get nodes
```

The output from this command resembles the following:

```bash
NAME STATUS ROLES AGE VERSION
azure-example-control-plane-ckwm4 Ready control-plane,master 35m
v<kubernetes-version>
azure-example-control-plane-d4fdf Ready control-plane,master 31m
v<kubernetes-version>
azure-example-control-plane-qrvm9 Ready control-plane,master 33m
v<kubernetes-version>
azure-example-md-0-4w7gq Ready <none> 33m
v<kubernetes-version>
azure-example-md-0-6gb9k Ready <none> 33m
v<kubernetes-version>
azure-example-md-0-p2n8c Ready <none> 11m
v<kubernetes-version>
azure-example-md-0-s5zbh Ready <none> 33m
v<kubernetes-version>
```

1. Export a variable with the node name for the next steps. This example uses
   the name ip-10-0-100-85.us-

west-2.compute.internal.

```bash
export NAME_NODE_TO_DELETE="<azure-example-control-plane-ckwm4>"
```

1. Delete the Machine resource.

```bash
export NAME_MACHINE_TO_DELETE=$(kubectl --kubeconfig ${CLUSTER_NAME}.conf get
machine -ojsonpath="{.items[?(@.status.nodeRef.name==\"$NAME_NODE_TO_DELETE
\")].metadata.name}")
kubectl --kubeconfig ${CLUSTER_NAME}.conf delete machine "$NAME_MACHINE_TO_DELETE"
```

Output:

```bash
machine.cluster.x-k8s.io "aws-example-1-md-0-cb9c9bbf7-t894m" deleted
```

The command will not return immediately. It will return after the Machine
resource has been deleted.

The corresponding Node resource is also deleted a few minutes after the
Machine resource is deleted. 4. Observe that the Machine resource is being
replaced using this command.

```bash
kubectl --kubeconfig ${CLUSTER_NAME}.conf get machinedeployment
```

Output:

```bash
NAME CLUSTER REPLICAS READY UPDATED UNAVAILABLE PHASE
AGE VERSION
azure-example-md-0 azure-example 4 3 4 1
ScalingUp 7m30s v<kubernetes-version>
long-running-md-0 long-running 4 4 4 0
Running 7m28s v<kubernetes-version>
```

In this example, there are two replicas, but only 1 is ready. One replica is
unavailable, and the ScalingUp phase means a new Machine is being created. 5.
Identify the replacement Machine using this command.

```bash
export NAME_NEW_MACHINE=$(kubectl --kubeconfig ${CLUSTER_NAME}.conf get machines \
-l=cluster.x-k8s.io/deployment-name=${CLUSTER_NAME}-md-0 \
-ojsonpath='{.items[?(@.status.phase=="Running")].metadata.name}{"\n"}')
echo "$NAME_NEW_MACHINE"
```

Output:

```bash
azure-example-md-0-d67567c8b-2674r azure-example-md-0-d67567c8b-n276j azure-example-
md-0-d67567c8b-pzg8k azure-example-md-0-d67567c8b-z8km9
```

If the output is empty, the new Machine has probably exited the Provisioning
phase and entered the Running phase. 6. Identify the replacement Node using
this command.

```bash
kubectl --kubeconfig ${CLUSTER_NAME}.conf get nodes
```

Output:

```bash
NAME STATUS ROLES AGE VERSION
azure-example-control-plane-d4fdf Ready control-plane,master 43m
v<kubernetes-version>
azure-example-control-plane-qrvm9 Ready control-plane,master 45m
v<kubernetes-version>
azure-example-control-plane-tz56m Ready control-plane,master 8m22s
v<kubernetes-version>
azure-example-md-0-4w7gq Ready <none> 45m
v<kubernetes-version>
azure-example-md-0-6gb9k Ready <none> 45m
v<kubernetes-version>
azure-example-md-0-p2n8c Ready <none> 22m
v<kubernetes-version>
azure-example-md-0-s5zbh Ready <none> 45m
v<kubernetes-version>
```

If the output is empty, the Node resource is not yet available or does not yet
have the expected annotation. Wait a few minutes, then repeat the command.

#### Azure: Deleting an Azure Cluster

About this task

```yaml
Note: A self-managed managed cluster cannot delete itself. If your managed cluster is self-managed, you must first
create a bootstrap cluster and move the cluster life cycle services to it before deleting the managed cluster.
```

Procedure

If you did not make your managed cluster self-managed, as described in Make
New Cluster Self-Managed, proceed to the instructions for Delete the managed
cluster.

##### Create a Bootstrap Cluster and Move CAPI Resources (2)

About this task

Procedure

1. Create a bootstrap cluster. The bootstrap cluster will host the Cluster API
   controllers that reconcile the cluster objects marked for deletion.

> **Note: To avoid using the wrong kubeconfig, the following steps use
> explicit kubeconfig paths and contexts.**

```bash
nkp create bootstrap --kubeconfig $HOME/.kube/config --with-aws-bootstrap-
credentials=true
```

Output:

```bash
# Creating a bootstrap cluster (8)
# Initializing new CAPI components (13)
```

1. Move the Cluster API objects from the workload to the bootstrap cluster:
   The cluster life cycle services on the bootstrap cluster are ready, but the
   managed cluster configuration is on the managed cluster. The move command
   moves the configuration, which takes the form of Cluster API Custom Resource
   objects, from the workload to the bootstrap cluster. This process is also
   called a Pivot.

```bash
nkp move capi-resources \
--from-kubeconfig ${CLUSTER_NAME}.conf \
--from-context ${CLUSTER_NAME}-admin@${CLUSTER_NAME} \
--to-kubeconfig $HOME/.kube/config \
--to-context kind-konvoy-capi-bootstrapper
```

Output:

```bash
# Moving cluster resources (8)
You can now view resources in the moved cluster by using the --kubeconfig flag with
kubectl. For example: kubectl --kubeconfig $HOME/.kube/config get nodes
```

1. Use the cluster life cycle services on the managed cluster to check the
   managed cluster's status.

```bash
nkp describe cluster --kubeconfig $HOME/.kube/config -c ${CLUSTER_NAME}
```

Output:

```bash
NAME READY SEVERITY
REASON SINCE MESSAGE
Cluster/azure-example True
15s
##ClusterInfrastructure - AzureCluster/azure-example True
29s
##ControlPlane - KubeadmControlPlane/azure-example-control-plane True
15s
# ##Machine/azure-example-control-plane-gvj5d True
22s
# ##Machine/azure-example-control-plane-l8j9r True (2)
23s
# ##Machine/azure-example-control-plane-xhxxg True (2)
23s
##Workers
##MachineDeployment/azure-example-md-0 True
35s
##Machine/azure-example-md-0-d67567c8b-2674r True
24s
##Machine/azure-example-md-0-d67567c8b-n276j True
25s
##Machine/azure-example-md-0-d67567c8b-pzg8k True
23s
##Machine/azure-example-md-0-d67567c8b-z8km9 True
24s
Note: After moving the cluster lifecycle services to the managed cluster, remember to use dkp with the managed
cluster kubeconfig.
```

1. Wait for the cluster control plan to be ready.

```bash
kubectl --kubeconfig $HOME/.kube/config wait --for=condition=controlplaneready
"clusters/${CLUSTER_NAME}" --timeout=20m
```

Output:

```bash
cluster.cluster.x-k8s.io/azure-example condition met
Note: Persistent Volumes (PVs) are not deleted automatically by design in order to preserve your data. However,
they take up storage space if not deleted. You must delete PVs manually. Information for backup of a cluster and
PVs is on the page in documentation called Back up your Cluster's Applications and Persistent Volumes .
```

###### Deleting the Workload Cluster (3)

Procedure

1. Make sure your Azure credentials are up to date. Refresh the credentials
   using this command.

```bash
nkp update bootstrap credentials azure --kubeconfig $HOME/.kube/config
```

1. To delete a cluster, Use nkp delete cluster and pass in the name of the
   cluster you are trying to delete with --cluster-name flag. Use kubectl get
   clusters to get those details (--cluster-name and -- namespace) of the
   Kubernetes cluster to delete it.

```bash
kubectl get clusters
Note: Before deleting the cluster, dkp deletes all Services of type LoadBalancer on the cluster. To skip this step,
use the flag --delete-kubernetes-resources=false.
```

1. Delete the Kubernetes cluster and wait a few minutes.

```yaml
Note: Before deleting the cluster, Nutanix Kubernetes Platform (NKP) deletes all Services of type LoadBalancer
on the cluster. To skip this step, use the flag --delete-kubernetes-resources=false.
nkp delete cluster --cluster-name=${CLUSTER_NAME} --kubeconfig $HOME/.kube/config
```

Output:

```bash
# Deleting Services with type LoadBalancer for Cluster default/azure-example
# Deleting ClusterResourceSets for Cluster default/azure-example
# Deleting cluster resources (3)
# Waiting for cluster to be fully deleted (2)
Deleted default/azure-example cluster
```

After the managed cluster is deleted, you can delete the bootstrap cluster.

###### Deleting the Bootstrap Cluster (3)

About this task

After you have moved the workload resources back to a bootstrap cluster and
deleted the managed cluster, you no longer need the bootstrap cluster. You can
safely delete the bootstrap cluster with these steps:

Procedure

Delete the bootstrap cluster.

```bash
nkp delete bootstrap --kubeconfig $HOME/.kube/config
```

Output:

```bash
# Deleting bootstrap cluster (9)
```

What to do next

Once your cluster is built in the Konvoy component of NKP for your
infrastructure/environment, you will install the Kommander component of NKP to
see your dashboard and continue customization. For more information, see
Kommander Customizations on page 996.

Known Limitations

The NKP Konvoy version used to create the managed cluster must match the NKP
Konvoy version used to delete the managed cluster.

> **Note: Be aware of these limitations in the current release of NKP Konvoy.**

## AKS Infrastructure

You can choose from multiple configuration types when installing NKP on Azure
Kubernetes Service (AKS) infrastructure. If not already done, see the
documentation for:

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

The different types of AKS configuration types supported in NKP are covered in
this section.

```yaml
Note: An AKS cluster cannot be a Management or Pro cluster. When installing NKP on your AKS cluster, first ensure
you have a Management cluster with NKP and the Kommander component installed that handles the life cycle of your
AKS cluster.
```

### AKS: Use of Nutanix Kubernetes Platform to Create an AKS Cluster

```yaml
Note: Ensure that the KUBECONFIG environment variable is set to the Management cluster by running export
KUBECONFIG=<Management_cluster_kubeconfig>.conf.
```

#### AKS: Naming Your Cluster

Give your cluster a unique name suitable for your environment.

- Note: A cluster name can include only the following characters: a-z, 0-9, .,
  and -. The cluster creation fails if the name has uppercase letters. For
  more instructions on naming, see Object Names and IDs.

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency.

- Cluster creation will fail if the name includes capital letters.
- For more naming information, see
  `<https://kubernetes.io/docs/concepts/overview/working-with-objects/>` names/.

#### AKS: Creating a Cluster

Procedure

1. Set the environment variable to a name for this cluster.
2. Check to see what version of Kubernetes is available in your region. When
   deploying with Azure Kubernetes Service (AKS), you need to declare the
   version of Kubernetes you wish to use by running the following command,
   substituting `<your-location>` for the Azure region you're deploying to.
3. Set the version of Kubernetes you have chosen.

```yaml
Note: Refer to the current release Kubernetes for the correct version to use and choose an available Kubernetes
version. For more information, see Supported Kubernetes Versions section in the NKP Release Notes.
```

1. Create the cluster.

```bash
nkp create cluster aks --cluster-name=$CLUSTER_NAME --additional-tags=owner=$(whoami)
--kubernetes-version=$KUBERNETES_VERSION
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
configmap/nvidia-feature-discovery-aks-example created
```

| 0-9, | .   |
| ---- | --- |

| export CLUSTER NAME= \_ | aks-example | Col3 |
| ----------------------- | ----------- | ---- |

| az aks get-versions -o table --location | your-location | Col3 |
| --------------------------------------- | ------------- | ---- |

| export KUBERNETES VERSION= \_ | kubernetes-version | Col3 |
| ----------------------------- | ------------------ | ---- |

#### AKS: Inspecting or Editing the Cluster Objects

About this task

```yaml
Note: Editing the cluster objects requires some understanding of Cluster API. Edits can prevent the cluster from
deploying successfully. For more information about the objects, see Concepts in the Cluster API Book. For more
information on custom resources, see Custom Resources .
```

The objects are custom resources defined by Cluster API components, and they
belong to three different categories:

- Cluster: A Cluster object references the infrastructure-specific and control
  plane objects. Because this is an Amazon Web Services (AWS) cluster, an
  AWSCluster object describes the infrastructure-specific cluster properties.
  This means the AWS region, the VPC ID, subnet IDs, and security group rules
  required by the Pod network implementation.
- Control Plane: A KubeadmControlPlane object describes the control plane, the
  group of machines that run the Kubernetes control plane components. Those
  include the etcd distributed database, the API server, the core controllers,
  and the scheduler. The object describes the configuration for these
  components and refers to an infrastructure-specific object that represents
  the properties of all control plane machines. For AWS, the object references
  an AWSMachineTemplate object, which means the instance type, the type of
  disk used, and the disk size, among other properties.
- Node Pool: A node pool is a collection of machines with identical
  properties. For example, a cluster might have one node pool with large
  memory capacity, another node pool with GPU support. Each node pool is
  described by three objects such as MachineDeployment, Configuration
  Resource, and Infrastructure Resource.
- The MachineDeployment references an object that represents the configuration
  of Kubernetes components (kubelet) deployed on each node pool machine.
- Configuration resource describes the bootstrap configuration of all node
  pool machines. For AWS, it references the KubeadmConfigTemplate that defines
  how the node boots and attaches to the cluster.
- Infrastructure-specific resource describes the properties of all node pool
  machines. For AWS, it references a AWSMachineTemplate object, which
  represents the instance type, the type of disk used, and the disk size,
  among other properties.

Perform this task using your favorite text editor.

Procedure

1. Wait for the cluster control-plane to be ready using the command.

```bash
cluster.cluster.x-k8s.io/aks-example condition met
```

The READY status will become True after the cluster control-plane becomes
ready. 2. After the objects are created on the API server, the Cluster API
controllers reconcile them. They create infrastructure and machines. As they
progress, they update the Status of each object. To describe the current
status of the cluster, use the command.

```bash
NAME READY SEVERITY REASON
SINCE MESSAGE
Cluster/aks-example True
48m
##ClusterInfrastructure - AzureManagedCluster/aks-example
##ControlPlane - AzureManagedControlPlane/aks-example
```

- kubectl wait --for=condition=Available=True "clusters/$; CLUSTER NAME \_; "
  --timeout=20m

| --- | --- | --- |

| nkp describe cluster -c $ | CLUSTER NAME \_ | Col3 |
| ------------------------- | --------------- | ---- |

1. As they progress, the controllers also create Events. To list the events,
   use the command.

For brevity, the example uses grep. Using separate commands to get Events for
specific objects is also possible. For example, kubectl get events --field-
selector involvedObject.kind="AKSCluster" and kubectl get events --field-
selector involvedObject.kind="AKSMachine".

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

#### AKS: Known Limitations

The following are known limitations:

- The Nutanix Kubernetes Platform (NKP) version used to create a workload
  cluster must match the NKP version used to create a managed cluster.
- NKP supports deploying one workload cluster.
- NKP generates a single node pool deployed by default; adding additional node
  pools is supported.
- NKP does not validate edits to cluster objects.

### AKS: Creating a Cluster Through UI

The Nutanix Kubernetes Platform (NKP) UI allows you to provision an Azure
Kubernetes Service (AKS) cluster from your browser quickly and easily.

Prerequisites

#### AKS: Creating an Infrastructure Provider

About this task

Before provisioning a cluster through the UI, create an Azure Kubernetes
Service (AKS) infrastructure provider to hold your AKS credentials:

| kubectl get events | grep $ | CLUSTER NAME \_ | Col3 |
| ------------------ | ------ | --------------- | ---- |

Procedure

1. Log in to the Azure command line.

```bash
az login
```

1. Create an Azure Service Principal (SP) by running the following command.

```bash
az ad sp create-for-rbac --role contributor --name "$(whoami)-konvoy" --scopes=/
subscriptions/$(az account show --query id -o tsv)
```

1. Select Infrastructure Providers from the Dashboard menu.
2. Select Add Infrastructure Provider.
3. Choose a workspace. If you are already in a workspace, the provider is
   automatically created in that workspace.
4. Select Microsoft Azure.
5. Add a Name for your Infrastructure Provider.
6. Take the ID output from the log in command above and put it into the
   Subscription ID field.
7. Take the tenant used in Step 2 and put it into the Tenant ID field.
8. Take the appId used in Step 2 and put it into the Client ID field.
9. Take the password used in Step 2 and put it into the Client Secret field.
10. Click Save.

#### AKS: Provisioning an AKS Cluster

About this task

Follow these steps to provision an Azure Kubernetes Service (AKS) cluster:

Procedure

1. From the top menu bar, select your target workspace.
2. Select Clusters > Add Clusters > .
3. Choose Create Cluster.
4. Enter the Cluster Name.
5. From Select Infrastructure Provider, choose the provider created in the
   prerequisites section.
6. To create a Kubernetes Version, run the command below in the az CLI, and
   then select the version of AKS you want to use.
7. Select a datacenter location or specify a custom location.
8. Edit your worker Node Pools, as necessary. You can choose the Number of
   Nodes, the Machine Type, and for the worker nodes, you can choose a Worker
   Availability Zone.
9. Add any additional Labels or Infrastructure Provider Tags, as necessary.

| azI aks get-versions -o table --location | location | Col3 |
| ---------------------------------------- | -------- | ---- |

1. Validate your inputs, then select Create.

> **Note: Your cluster can take up to 15 minutes to appear in the
> Provisioned status.**

You are then redirected to the Clusters page, where you'll see your new
cluster in the Provisioning status. Hover over the status to view the details.

#### AKS: Accessing an AKS Cluster

After successfully attaching the cluster (managed), you can retrieve a custom
kubeconfig file from the UI using your NKP UI administrator credentials.

### AKS: Exploring the New AKS Cluster

This section explains how to use the command line to interact with your newly
deployed Kubernetes cluster.

Before you start, make sure you have created a managed cluster, as described
in Create a New Cluster.

#### AKS: Interacting with your AKS Kubernetes Cluster

Procedure

1. Get a kubeconfig file for the managed cluster.

When the managed cluster is created, the cluster life cycle services generate
a kubeconfig file for the managed cluster and write it to a Secret. The
kubeconfig file is scoped to the cluster administrator.

```yaml
Caution: Nutanix support is unable to recover forgotten credentials. Prevent Kommander UI lockouts with the
following best practices.
```

- Backup the kubeconfig file.
- Save your credentials.
- Configure an IDP (identity provider) instead of using a username and
  password credentials.

Get the kubeconfig from the Secret, and write it to a file using this command: 2. List the Nodes using this command.

```bash
NAME STATUS ROLES AGE VERSION
aks-cp6dsz8-41174201-vmss000000 Ready agent 56m v<kubernetes-version>
aks-cp6dsz8-41174201-vmss000001 Ready agent 55m v<kubernetes-version>
aks-cp6dsz8-41174201-vmss000002 Ready agent 56m v<kubernetes-version>
aks-mp6gglj-41174201-vmss000000 Ready agent 55m v<kubernetes-version>
aks-mp6gglj-41174201-vmss000001 Ready agent 55m v<kubernetes-version>
aks-mp6gglj-41174201-vmss000002 Ready agent 55m v<kubernetes-version>
aks-mp6gglj-41174201-vmss000003 Ready agent 56m v<kubernetes-version>
Note: The Status may take a few minutes to move to Ready while the Pod network is deployed. The node status
will change to Ready after the calico-node DaemonSet Pods are Ready.
```

| nkp get kubeconfig -c $ | CLUSTER NAME | > $ | CLUSTER NAME | .conf |
| ----------------------- | ------------ | --- | ------------ | ----- |

| kubectl --kubeconfig=$ | CLUSTER NAME \_ | .conf get nodes |
| ---------------------- | --------------- | --------------- |

1. List the Pods using the command.

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
```

| kubectl --kubeconfig=$ | CLUSTER NAME \_ | .conf get --all-namespaces pods |
| ---------------------- | --------------- | ------------------------------- |

```bash
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

When ready, you can delete the cluster.

### AKS: Deleting an AKS Cluster

Ensure that the KUBECONFIG environment variable is set to the self-managed
cluster by running the following command export
KUBECONFIG=SELF_MANAGED_AZURE_CLUSTER.conf.

| export KUBECONFIG= | SELF MANAGED AZURE CLUSTER | .conf |
| ------------------ | -------------------------- | ----- |

> **Note:**

The NKP version used to create the managed cluster must match the NKP version
used to delete the managed cluster.

#### AKS: Deleting the Managed Cluster

About this task

Context for the current task

Procedure

Delete the Kubernetes cluster and wait a few minutes.

Before deleting the cluster, NKP deletes all Services of type LoadBalancer on
the cluster. Deleting the Service deletes the Azure LoadBalancer that backs
it. To skip this step, use the flag --delete-kubernetes-resources=false.

```yaml
Caution: Do not skip this step; if NKP manages the Azure Network when NKP deletes the cluster, it also deletes the
Network.
# Deleting Services with type LoadBalancer for Cluster default/aks-example
# Deleting ClusterResourceSets for Cluster default/aks-example
# Deleting cluster resources (4)
# Waiting for cluster to be fully deleted (3)
Deleted default/aks-example cluster
```

What to do next

To view your dashboard and continue your customization, complete the Kommander
installation. For more information, see Kommander Installation Based on Your
Environment on page 979.

#### AKS: Known Limitations (2)

The following limitations apply to the current NKP release.

> **Note: Be aware of these limitations in the current release of NKP Konvoy.**

The NKP version used to create the managed cluster must match the NKP version
used to delete the managed cluster.

## Google Cloud Platform (GCP) Infrastructure

Configuration types for installing NKP on GCP Infrastructure.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

Otherwise, proceed to the GCP Prerequisites and Permissions topic to begin
your custom installation.

| nkp delete cluster --cluster-name=$ | CLUSTER NAME \_ | Col3 |
| ----------------------------------- | --------------- | ---- |

### GCP Prerequisites

Before beginning a Nutanix Kubernetes Platform (NKP) installation, verify that
you have the following:

- An x86_64-based Linux or macOS machine with a supported operating system
  version.
- Download the NKP binary for Linux or macOS from Downloading NKP on page 16.
  To check which version of NKP you installed for compatibility reasons, use
  the command nkp version -h.
- A Container engine or runtime installed is required to install NKP and
  bootstrap:
- Docker container engine version 27.4.0 installed for Linux or MacOS. For
  more information, see https:// docs.docker.com/get-docker/. On macOS, Docker
  runs in a virtual machine which needs configured with at least 8 GB of
  memory.
- Podman Version 4.0 or later for Linux. For more information, see
  `<https://podman.io/getting-started/>` installation. For host requirements,
  see `<https://kind.sigs.k8s.io/docs/user/rootless/#host-requirements>`.
- kubectl for interacting with the running cluster.
- Install the GCP gcloud CLI by following the Install the gcloud CLI | Google
  Cloud CLI Documentation

Control Plane Nodes

You must have at least three control plane nodes. Each control plane node
needs to have at least the following:

- Four (4) cores
- 16 GiB memory
- Approximately 80 GiB of free space for the volume used for /var/lib/kubelet
  and /var/lib/containerd.
- Disk usage must be below 85% on the root volume.

NKP on GCP defaults to deploying an n2-standard-4 instance with an 80GiB root
volume for control plane nodes, which meets the above requirements.

Worker Nodes

You must have at least four worker nodes. The specific number of worker nodes
required for your environment can vary depending on the cluster workload and
size of the nodes. Each worker node needs to have at least the following:

- Eight (8) cores
- 32 GiB memory
- Around 80 GiB of free space for the volume used for /var/lib/kubelet and
  /var/lib/containerd.
- Disk usage must be below 85% on the root volume.

NKP on GCP defaults to deploying a n2-standard-8 instance with an 80GiB root
volume for worker nodes, which meets the above requirements.

- Verify that your Google Cloud project does not enable the OS Login feature.

```yaml
Warning: GCP projects may have the Enable OS Login feature enabled by default. If this feature is enabled, NIB
cannot ssh to the VM instances it creates, and the image creation fails.
```

To check if it is enabled, use the Google commands to inspect the metadata
configured in your project. If you find the enable-oslogin flag set to TRUE,
you must remove or set it to FALSE to use NIB. For

more information on Set and Remove Custom Metadata, see
`<https://cloud.google.com/compute/docs/>` metadata/setting-custom-
metadata#console_2

#### GCP: Roles

Service accounts are a special type of Google account that grants permissions
to virtual machines instead of end users. The primary purpose of Service
accounts is to ensure safe, managed connections to APIs and Google Cloud
services.

These roles are needed when creating an image using Nutanix Image Builder on
page 51.

GCP Prerequisite Roles

If you are creating your image on either a non-GCP instance or one that does
not have the required roles (Editor role), you must either:

- Create a GCP service account.
- If you have already created a service account, retrieve the credentials for
  an existing service account.
- Export the static credentials that you will use to create the cluster using
  the command export GCP_B64ENCODED_CREDENTIALS=$(base64 <
  "${GOOGLE_APPLICATION_CREDENTIALS}" | tr -d '\n').

> **Note: To enhance security, rotate static credentials regularly.**

Role Options

- Either create a new GCP service account or retrieve credentials from an
  existing one.
- (Option 1) Create a GCP Service Account using the following gcloud commands:

```bash
export GCP_PROJECT=<your GCP project ID>
export GCP_SERVICE_ACCOUNT_USER=<some new service account user>
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.gcloud/credentials.json"
gcloud iam service-accounts create "$GCP_SERVICE_ACCOUNT_USER" --project=$GCP_PROJECT
gcloud projects add-iam-policy-binding $GCP_PROJECT --member="serviceAccount:
$GCP_SERVICE_ACCOUNT_USER@$GCP_PROJECT.iam.gserviceaccount.com" --role=roles/editor
gcloud iam service-accounts keys create $GOOGLE_APPLICATION_CREDENTIALS --iam-
account="$GCP_SERVICE_ACCOUNT_USER@$GCP_PROJECT.iam.gserviceaccount.com"
```

- (Option 2) Retrieve the credentials for an existing service account using
  the following gcloud commands:

```bash
export GCP_PROJECT=<your GCP project ID>
export GCP_SERVICE_ACCOUNT_USER=<existing service account user>
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.gcloud/credentials.json"
gcloud iam service-accounts keys create $GOOGLE_APPLICATION_CREDENTIALS --iam-
account="$GCP_SERVICE_ACCOUNT_USER@$GCP_PROJECT.iam.gserviceaccount.com"
```

- Export the static credentials you will use to create the cluster using the
  command.

```bash
export GCP_B64ENCODED_CREDENTIALS=$(base64 < "${GOOGLE_APPLICATION_CREDENTIALS}" | tr
-d '\n')
```

To create a GCP Service Account with the Editor role, the user creating the
GCP Service Account needs the Editor, RoleAdministrator, and SecurityAdmin
roles. However, those pre-defined roles grant more

permissions than the minimum set needed to create a Nutanix Kubernetes
Platform (NKP) cluster. Granting unnecessary permissions can lead to potential
security risks and should be avoided.

```yaml
Note: For NKP cluster creation, a minimal set of roles and permissions needed for the user creating the GCP Service
Account is the Editor role plus the following additional permissions:
```

- compute.disks.setIamPolicy
- compute.instances.setIamPolicy
- iam.roles.create
- iam.roles.delete
- iam.roles.update
- iam.serviceAccounts.setIamPolicy
- resourcemanager.projects.setIamPolicy

For more information on GCP service accounts, see GCP's documentation:

- GCP service account: `<<https://cloud.google.com/iam/docs/service-account->`
  overview>
- Create service accounts: `<<https://cloud.google.com/iam/docs/creating->`
  managing-service-accounts>
- Best practices for using service accounts:
  `<https://cloud.google.com/iam/docs/best-practices-service->` accounts

#### GCP: Using Nutanix Image Builder

This procedure describes using the Nutanix Image Builder (NIB) to create a
Cluster API-compliant GCP image. GCP images
contain configuration information and software to create a specific, pre-
configured operating environment. For example,
you can create a GCP image of your computer system settings and software.
Then, replicate the GCP image and distribute
it to others to use a replica of your computer system settings and software.
NIB uses variable overrides to specify your
new GCP image base and container images.

```yaml
Warning: Google Cloud Platform does not publish images. You must first build the image using Nutanix Image
Builder. Explore the Customize your Image topic for more options. For more information regarding using the image in
creating clusters, refer to the GCP Infrastructure section of the documentation.
```

NKP Prerequisites

Before you begin, you must:

- Download the Nutanix Image Builder on page 51 bundle for your Nutanix
  Kubernetes Platform (NKP) version.
- Check the Supported Infrastructure Operating Systems.
- Check the Supported Kubernetes Versions section in the NKP Release Notes for
  your infrastructure provider.
- Create a working Docker or other registry setup.
- On Debian-based Linux distributions, install a version of the cri-tools
  package compatible with the Kubernetes and container runtime versions. For
  more information, see `<https://github.com/kubernetes-sigs/cri-tools>`.
- Verify that your Google Cloud project does not enable the Enable OS Login
  feature. See below for more information:

```yaml
Warning: GCP projects may have the Enable OS Login feature enabled by default. If this feature is enabled, NIB
cannot ssh to the VM instances it creates, and the image creation fails.
```

To check if it is enabled, use the Google commands to inspect the metadata
configured in your project. If you find the enable-oslogin flag set to TRUE,
you must remove or set it to FALSE to use NIB. For more information on Set and
Remove Custom Metadata, see `<https://cloud.google.com/compute/docs/>`
metadata/setting-custom-metadata#console_2

GCP Prerequisite Roles

If you are creating your image on either a non-GCP instance or one that does
not have the required GCP: Roles on page 950, you must either:

- Create a GCP service account. For more information, see
  `<https://cloud.google.com/iam/docs/service-account->` overview.
- If you have already created a service account, retrieve the credentials for
  an existing service account.
- Export the static credentials that you will use to create the cluster using
  the command.

```bash
export GCP_B64ENCODED_CREDENTIALS=$(base64 < "${GOOGLE_APPLICATION_CREDENTIALS}" | tr
-d '\n')
```

> **Tip: Make sure to rotate static credentials for increased security.**

Build the GCP Image

1. For detailed steps, see Building a Custom Image with GCP on page 63.

### GCP Cluster Creation Customization Choices

Below are two methods to customize your cluster during creation. If none of
these choices apply, proceed to the next section.

- GCP Installation in a Non-air-gapped Environment on page 957

GCP Section Topics

When creating clusters, many options are available such as those listed in
this section of the documentation. Familiarize yourself with the flags
required to apply these customizations during cluster creation.

- GCP Customizing CAPI Clusters: Familiarize yourself with Cluster API before
  editing the cluster objects because edits can prevent the cluster from
  deploying successfully. For more information, see CAPI Concepts and Terms on
  page 21.
- GCP Registry Mirrors: Configure your cluster to use an existing local
  registry (Registry Mirror Tools on page 1028) when attempting to pull images
  by adding the flag(s) to the nkp create cluster command to pull images from
  your local registry.
- GCP Loading the Registry: Because air-gapped environments do not have direct
  access to the Internet, you must download, extract and load several required
  images to your local container registry, before installing NKP. If desired,
  environments that are non-air-gapped can also perform the follow steps to
  use a local registry for speed and security reasons.
- GCP HTTP Proxy: When creating a NKP cluster in environments that use an
  HTTP/HTTPS proxy, you must provide proxy details. The proxy values are
  strings that list a set of proxy servers, URLs, or wildcard addresses that
  is specific to your environment.
- GCP Output Directory YAML: You can create individual files with different
  smaller manifests for ease in editing using the --output-directory flag used
  with --output=json|yaml. You create the directory of where to output
  resources to files.

#### GCP: Customizing CAPI Clusters

Familiarize yourself with Cluster API before editing the cluster objects
because edits can prevent the cluster from deploying successfully.

The result of this command will allow such edits:

```bash
nkp create cluster gcp \
--cluster-name=${CLUSTER_NAME} \
--dry-run \
--output=yaml \
> ${CLUSTER_NAME}.yaml
```

To edit the YAML, you need to understand the CAPI components to avoid breaking
the cluster.

#### GCP: Registry Mirrors

Configure your cluster to use an existing local registry (Registry Mirror
Tools on page 1028) when attempting to pull images by adding the flag(s) to
the nkp create cluster command to pull images from your local registry.

Kubernetes does not natively provide a registry for hosting the container
images you will use to run the applications you want to deploy on Kubernetes.
Instead, Kubernetes requires you to use an external solution to store and
share container images. A variety of Kubernetes-compatible registry options
are compatible with NKP.

How the Registry Mirror Works

The first time you request an image from your local registry mirror, it pulls
the image from the public registry (such as Docker) and stores it locally
before handing it back to you. On subsequent requests, the local registry
mirror can serve the image from its storage.

Air-gapped vs. Non-air-gapped Environments

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
premises locally in an air-gapped environment. NKP in an air-gapped
environment requires a local container registry of
trusted images to enable production-level Kubernetes cluster management.
However, a local registry is also an option in
a non-air-gapped environment for speed and security.

If you want to use images from this local registry to deploy applications
inside your Kubernetes cluster, you'll need to set up a secret for a private
registry. The secret contains your login data, which Kubernetes needs to
connect to your private repository.

More information and detail can be found:

- Registry Mirror Tools on page 1028
- Using a Registry Mirror on page 1030

#### GCP: Loading the Registry

About this task

Because air-gapped environments do not have direct access to the Internet, you
must download, extract and load several required images to your local
container registry, before installing NKP.

If desired, environments that are non-air-gapped can also perform the follow
steps to use a local registry for speed and security reasons.

Load Images into your Registry

Because air-gapped environments do not have direct access to the Internet, you
must download, extract and load several required images to your local
container registry, before installing NKP.

Before you begin

Download all Images for Air-gapped Deployments

If you are operating in an air-gapped environment, a local container registry
containing all the necessary installation images, including the Kommander
images, is required. See below for prerequisites to download and then how to
push the necessary images to this registry.

1. Download the Complete NKP Air-gapped Bundle for this release (i.e. nkp-air-
   gapped-bundle_nkp-

version_linux_amd64.tar.gz) to load registry images as explained below. 2.
Connectivity with clusters attaching to the management cluster is required:

- Both management and attached clusters must be able to connect to the local
  registry.
- The management cluster must be able to connect to all attached cluster's API
  servers.
- The management cluster must be able to connect to any load balancers created
  for platform services on the management cluster.

Extract Air-gapped Images and Set Variables

Follow these steps to extract the air-gapped image bundles into your private
registry using these examples for ECR:

Procedure

1. If not already done in prerequisites, download the air-gapped bundle nkp-
   air-gapped-bundle_nkp-

version_linux_amd64.tar.gz, and extract the tar file to a local directory. 2.
The directory structure after extraction can be accessed in subsequent steps
using commands to access files from different directories. EX: For the
bootstrap cluster, change your directory to the nkp-`<version>` directory,
similar to the example below, depending on your current location. 3. Set an
environment variable with your registry address to use ECR.

```bash
export REGISTRY_URL="<https/http>://<registry-address>:<registry-port>"
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
```

- REGISTRY_URL: the address of an existing local registry accessible in the
  VPC that the new cluster nodes will be configured to use a mirror registry
  when pulling images
- Other local registries may use the options below:
- JFrog - CONTAINER_REGISTRY_CA: (optional) the path on the bastion machine to
  the registry CA. This value is only needed if the registry is using a self-
  signed certificate and the AMIs are not already configured to trust this CA.
- CONTAINER_REGISTRY_USERNAME: optional, set to a user that has pull access to
  this registry.
- CONTAINER_REGISTRY_PASSWORD: optional if username is not set

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

| nkp-air-gapped-bundle | nkp- |
| --------------------- | ---- |

| version | linux amd64.tar.gz |
| ------- | ------------------ |

| tar -xzvf nkp-air-gapped-bundle \_ | nkp-version | linux amd64.tar.gz \_ \_ |
| ---------------------------------- | ----------- | ------------------------ |

| cd nkp- | nkp-version | Col3 |
| ------- | ----------- | ---- |

1. Load Images to your Private Registry - Konvoy

Before creating or upgrading a Kubernetes cluster, you need to load the
required images in a local registry if operating in an air-gapped environment.
This registry must be accessible from both the bastion machine and either the
AWS EC2 instances or other machines that will be created for the Kubernetes
cluster.

```yaml
Warning: If you do not already have a local registry set up, refer to Local Registry Tools Compatible with
NKP on page 1029 page for more information.
```

Execute the following command to load the air-gapped image bundle into your
private registry:

```bash
nkp push bundle --bundle ./container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=${REGISTRY_URL}
Note: It may take some time to push all the images to your image registry, depending on the performance of the
network between the machine you are running the script on and the registry.
```

For specific push flags, refer to the nkp push bundle section of CLI commands.

Additional Flags for Registry push:

The push command will be different depending on username and password
requirements:

If not ECR as shown in the example code below, use the other relevant flags:
--to-registry= ${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME}
--to-registry-password= ${REGISTRY_PASSWORD}

```bash
nkp push bundle --bundle ./container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by
setting the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

1. Load the Kommander component images to your private registry using the
   command.

```bash
nkp push bundle --bundle ./container-images/kommander-image-bundle-nkp-version.tar
--to-registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-
registry-password=${REGISTRY_PASSWORD}
```

Additional Flags for Registry push:

If not using ECR, the push command will be different depending on username and
password requirements:

The push command will be different depending on username and password
requirements:

```bash
nkp push bundle --bundle ./container-images/konvoy-image-bundle-nkp-version.tar --to-
registry=${REGISTRY_URL} --to-registry-username=${REGISTRY_USERNAME} --to-registry-
password=${REGISTRY_PASSWORD}
```

1. On the Bastion, load the Konvoy bootstrap image, using either the Docker or
   Podman command. Docker example:

Podman example:

| docker load -i konvoy-bootstrap-image- | nkp-version | .tar |
| -------------------------------------- | ----------- | ---- |

| podman load -i konvoy-bootstrap-image- | nkp-version | .tar |
| -------------------------------------- | ----------- | ---- |

```bash
podman image tag konvoy-bootstrap:vnkp-version docker.io/mesosphere/konvoy-
bootstrap:vnkp-version
```

> **Note: Replace v nkp-version with the version number. For example, here
> it is v2.15.0.**

#### GCP: HTTP Proxy

When creating a NKP cluster in environments that use an HTTP/HTTPS proxy, you
must provide proxy details. The proxy values are strings that list a set of
proxy servers, URLs, or wildcard addresses that is specific to your
environment.

If your environment uses HTTP/HTTPS proxies, you must include the flags and
their related values in commands for the proxy to be successful throughout
various steps of installation:

- --http-proxy
- --https-proxy
- --no-proxy

Create the bootstrap cluster and CAPI components using the appropriate
commands, nkp create bootstrap and nkp create capi-components respectively,
combined with the command line flags to include your HTTP/S proxy information.

You can also specify HTTP/S proxy information in an override file when using
Nutanix Image Builder on page 51.

Without these values provided as part of the relevant nkp create command, DKP
cannot create the requisite parts of your new cluster correctly. This is true
of both management and managed clusters alike.

To create a proxied environment, you need to include flags at various action
item points:

- Bootstrap cluster
- CAPI components
- Cluster creation
- NKP Kommander component

For full HTTP Proxy configuration, you need to specify proxy settings using
all the details in the Cluster Creation with HTTP or HTTPS Proxy on page 699
section of the documentation for:

- Creating a Bootstrap Cluster with HTTP Proxy Settings on page 697
- Creating CAPI Components with HTTP or HTTPS Proxy Settings on page 698
- Cluster Creation with HTTP or HTTPS Proxy on page 699
- HTTP or HTTPS Proxy Configuration for the NKP Kommander Component on page 700

HTTP Proxy Example

```bash
nkp create cluster gcp \
--cluster-name ${CLUSTER_NAME} \
--control-plane-http-proxy="${CONTROL_PLANE_HTTP_PROXY}" \
--control-plane-https-proxy="${CONTROL_PLANE_HTTPS_PROXY}" \
--control-plane-no-proxy="${CONTROL_PLANE_NO_PROXY}" \
--worker-http-proxy="${WORKER_HTTP_PROXY}" \
--worker-https-proxy="${WORKER_HTTPS_PROXY}" \
--worker-no-proxy="${WORKER_NO_PROXY}"
```

#### GCP: Output Directory YAML

You can create individual files with different smaller manifests for ease in
editing using the --output-directory flag used with --output=json|yaml. You
create the directory of where to output resources to files.

Using this flag will create multiple files in the specified directory which
must already exist:

```bash
nkp create cluster vsphere
--cluster-name=${CLUSTER_NAME} \
--dry-run \
--output=yaml \
--output-directory=<existing-directory>
```

For more information regarding this flag or others, please refer to the CLI
section of the documentation for the nkp create cluster command and select
your provider.

### GCP Installation in a Non-air-gapped Environment

This installation provides instructions on how to install the Nutanix
Kubernetes Platform (NKP) in a GCP non-air- gapped environment.

Remember, there are always more options for custom YAML in the Custom
Installation and Additional Infrastructure Tools section, but this will get
you operating with basic features.

If not already done, perform the following tasks in Getting Started with NKP
on page 17.

- Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
  Kubernetes Platform on page 721
- Nutanix Kubernetes Platform Requirements on page 45
- Installing NKP on page 43

GCP Prerequisites

Verify that your Google Cloud project does not enable the OS Login feature.

```yaml
Warning: GCP projects may have the Enable OS Login feature enabled by default. If this feature is enabled, NIB
cannot ssh to the VM instances it creates, and the image creation fails.
```

To check if it is enabled, use the Google commands to inspect the metadata
configured in your project. If you find the enable-oslogin flag set to TRUE,
you must remove or set it to FALSE to use NIB. For more information on Set and
Remove Custom Metadata, see `<https://cloud.google.com/compute/docs/>`
metadata/setting-custom-metadata#console_2

- The user creating the Service Accounts needs additional privileges in
  addition to the Editor role. For more information, see GCP Roles
- To deploy a cluster with a custom image in a region where CAPI images are
  not provided, you need to use Nutanix Image Builder on page 51 to create
  your own image for the region.

#### GCP Non-Air-gapped: Bootstrapping GCP

About this task

To get started, you need a bootstrap cluster. By default, Nutanix Kubernetes
Platform (NKP) creates a bootstrap cluster for you in a Docker container using
the Kubernetes-in-Docker (KIND) tool.

Before you begin

Procedure

1. Complete the Nutanix Infrastructure Prerequisites. For more information,
   see Nutanix Infrastructure Requirements on page 719.
2. Ensure the NKP binary can be found in your $PATH.

##### Bootstrap Cluster Life Cycle Services (4)

Procedure

1. Review Universal Configurations for all Infrastructure Providers regarding
   settings, flags, and other choices and then begin bootstrapping.
2. Create a bootstrap cluster using the command.

```bash
nkp create bootstrap --kubeconfig $HOME/.kube/config
```

Example output:

```bash
# Creating a bootstrap cluster (9)
# Initializing new CAPI components (14)
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

To create a bootstrap cluster in a proxied environment (Bootstrap Cluster HTTP
Proxy Settings on page 697), in addition to any other flags you need, run the
following command.

```bash
--http-proxy <string> \
--https-proxy <string> \
--no-proxy <string>
```

1. NKP creates a bootstrap cluster using KIND as a library.

For more information, see `<https://github.com/kubernetes-sigs/kind>`. 4. NKP
then deploys the following Cluster API providers on the cluster.

- Core Provider: `<https://github.com/kubernetes-sigs/cluster-api/tree/v0.3.20/>`
- GCP Infrastructure Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api-provider-gcp>
- Kubeadm Bootstrap Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api/tree/v0.3.20/bootstrap/> kubeadm
- Kubeadm ControlPlane Provider: `<<https://github.com/kubernetes-sigs/cluster->`
  api/tree/v0.3.20/> controlplane/kubeadm

For more information on Cluster APIs, see `<https://cluster-api.sigs.k8s.io/>`. 5. NKP waits until these providers' controller-manager and webhook deployments
are ready. List these deployments using the command.

```bash
kubectl get --all-namespaces deployments -l=clusterctl.cluster.x-k8s.io
```

Output example:

```bash
NAMESPACE NAME
READY UP-TO-DATE AVAILABLE AGE
capa-system capa-controller-manager
1/1 1 1 1h
capg-system capg-controller-manager
1/1 1 1 1h
capi-kubeadm-bootstrap-system capi-kubeadm-bootstrap-controller-manager
1/1 1 1 1h
capi-kubeadm-control-plane-system capi-kubeadm-control-plane-controller-manager
1/1 1 1 1h
capi-system capi-controller-manager
1/1 1 1 1h
cappp-system cappp-controller-manager
1/1 1 1 1h
capv-system capv-controller-manager
1/1 1 1 1h
capz-system capz-controller-manager
1/1 1 1 1h
cert-manager cert-manager
1/1 1 1 1h
cert-manager cert-manager-cainjector
1/1 1 1 1h
cert-manager cert-manager-webhook
1/1 1 1 1h
```

#### GCP Non-Air-gapped: Creating a Cluster

About this task

Use this procedure to create a custom GCP cluster with Nutanix Kubernetes
Platform (NKP). First, you must name your cluster.

Name Your Cluster

```yaml
Note: NKP uses the GCP CSI driver as the default storage provider. Use a Kubernetes CSI compatible storage
that is suitable for production.
```

Procedure

1. Give your cluster a unique name suitable for your environment.

```yaml
Note: A cluster name can include only the following characters: a-z, 0-9, ., and -. The cluster creation fails if
the name has uppercase letters. For more instructions on naming, see Object Names and IDs.
```

When specifying the cluster-name, use the same cluster-name defined in your
inventory objects to ensure consistency. 2. Set the environment variable using
the command export CLUSTER_NAME=`<gcp-example>`.

```yaml
Important: To increase Docker Hub's rate limit, use your Docker Hub credentials when creating the cluster by
setting the following flag on the nkp create cluster command.
--registry-mirror-url=https://registry-1.docker.io
--registry-mirror-username=${REGISTRY_USERNAME}
--registry-mirror-password=${REGISTRY_PASSWORD}
```

##### Creating a New GCP Cluster

About this task

If you use these instructions to create a cluster on GCP using the NKP default
settings without any edits to configuration files or additional flags, your
cluster is deployed on a three control plane nodes, and four worker nodes.

Availability zones (AZs) are isolated locations within datacenter regions
where public cloud services originate and operate. Because all the nodes in a
node pool are deployed in a single Availability Zone, you may wish to create
additional node pools to ensure your cluster has nodes deployed in multiple
Availability Zones.

```yaml
Note: By default, the control-plane Nodes will be created in 3 different zones. However, the default worker Nodes
will reside in a single zone. You may create additional node pools in other zones with the nkp create nodepool
command. The default region for the availability zones is us-west1.
Warning: Google Cloud Platform does not publish images. You must first build the image using Nutanix Image
Builder on page 51.
```

Procedure

1. Create an image using Nutanix Image Builder on page 51 (NIB) and then
   export the image name.

```bash
export IMAGE_NAME=projects/${GCP_PROJECT}/global/images/<image_name_from_nib>
```

1. Ensure your subnets do not overlap with your host subnet because they
   cannot be changed after cluster creation. If you need to change the
   kubernetes subnets, you must do this at cluster creation. The default
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

1. (Optional) Modify Control Plane Audit logs - Users can modify the
   KubeadmControlplane cluster-API object to configure different kubelet
   options. See the following guide if you wish to configure your control plane
   beyond the existing options available from flags.
2. (Optional) Determine what VPC Network to use. All GCP accounts come with a
   default preconfigured VPC Network, which will be used if you do not specify
   a different network. To use a different VPC network for your cluster, create
   one by following these instructions for Create and Manage VPC Networks. Then
   select the -- network `<new_vpc_network_name>` option on the create cluster
   command below. More information is available on GCP Cloud Nat and network
   flag.
3. (Optional) Use a registry mirror. Configure your cluster to use an existing
   local registry as a mirror when pulling images previously pushed to your
   registry.

Export Registry Variables and Flags for Cluster Creation:: If you have a local
registry, you must provide additional arguments when creating the cluster.
These tell the cluster where to locate the local registry to use by defining
the URL. Set the needed environment variable(s) with your registry
information:

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
  Konvoy will configure the cluster nodes to trust this CA. This value is only
  needed if the registry is using a self-signed certificate and the AMIs are
  not already configured to trust this CA.
- REGISTRY_USERNAME: optional, set to a user that has pull access to this
  registry.
- REGISTRY_PASSWORD: optional if username is not set.

When creating the cluster, apply the variables you defined above during the
dkp create cluster command with the flags needed for your environment:

```bash
--registry-mirror-url=${REGISTRY_URL} \
--registry-mirror-cacert=${REGISTRY_CA} \
--registry-mirror-username=${REGISTRY_USERNAME} \
--registry-mirror-password=${REGISTRY_PASSWORD}
```

1. Create a Kubernetes cluster object with a dry run output for
   customizations. The following example shows a common configuration.

```bash
nkp create cluster gcp \
--cluster-name=${CLUSTER_NAME} \
--additional-tags=owner=$(whoami) \
--with-gcp-bootstrap-credentials=true \
--project=${GCP_PROJECT} \
--image=${IMAGE_NAME} \
--dry-run \
--output=yaml \
> ${CLUSTER_NAME}.yaml
Note: More flags can be added to the nkp create cluster command for more options. See Choices below
or refer to the topic Universal Configurations:
```

- Configuring an HTTP or HTTPS Proxy on page 696
- Individual manifests using the Output Directory flag: You can create
  individual manifest files with different smaller manifests for ease in
  editing using the --output-directory flag. For more information, see Output
  Directory Flag on page 710.

For more information regarding this flag or others, please refer to the CLI
for the nkp create cluster section of the documentation and select your
provider.

```bash
--output-directory=<existing-directory>
```

Refer to the GCP Cluster Creation Customization Choices on page 952 section
for more information on how to use optional
flags such as the --output-directory flag. 7. Inspect or edit the cluster
objects. Familiarize yourself with the Cluster
API before editing the cluster objects, as edits can prevent the cluster from
deploying successfully. 8. (Optional)
Modify Control Plane Audit logs - Users can make modifications to the
KubeadmControlplane cluster-api object to
configure different kubelet options. See Control Plane Configuration on page
1032 if you wish to configure your control
plane beyond the existing options that are available from flags. 9. Create the
cluster from the objects generated from
the dry run. A warning will appear in the console if the resource already
exists, requiring you to remove the resource
or update your YAML.

```bash
kubectl create -f ${CLUSTER_NAME}.yaml
Note: If you used the --output-directory flag in your NKP create .. --dry-run step above,
create the cluster from the objects you created by specifying the directory:
kubectl create -f <existing-directory>/.
```

1. Wait for the cluster control plan to be ready.

```bash
kubectl wait --for=condition=Available=True "clusters/${CLUSTER_NAME}" --
timeout=20m
```

1. After the objects are created on the API server, the Cluster API
   controllers reconcile them. They create infrastructure and machines. As they
   progress, they update the Status of each object. Konvoy provides a command
   to describe the current status of the cluster.

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
Note: NKP uses the GCP CSI driver as the default storage provider. Use a Kubernetes CSI compatible
storage that is suitable for production. For more information, see the Kubernetes documentation Changing the
Default Storage Class. If you're not using the default, you cannot deploy an alternate provider until after the
nkp create cluster is finished. However, this must be determined before the Kommander installation.
```

#### GCP Non-Air-gapped: Making the Cluster Self-Managed

About this task

Nutanix Kubernetes Platform (NKP) deploys all cluster life cycle services to a
bootstrap cluster, which then deploys a managed cluster. When the managed
cluster is ready, move the cluster life cycle services to the workload
cluster, which makes the managed cluster self-managed.

Before you begin

Before starting, ensure you can create a managed cluster as described in the
topic: Create a New GCP Cluster.

This page contains instructions on how to make your cluster self-managed. This
is necessary if there is only one cluster in your environment or if this
cluster becomes the Management cluster in a multi-cluster environment.

> **Note: If you already have a self-managed or Management cluster in your
> environment, skip this page.**

Make the New Kubernetes Cluster Manage Itself

Follow these steps to turn your new cluster into a Management Cluster for an
Ultimate license environment (or a free-standing Pro Cluster):

Procedure

1. Deploy cluster life cycle services on the managed cluster.

```bash
nkp create capi-components --kubeconfig ${CLUSTER_NAME}.conf
```

Output:

```bash
# Initializing new CAPI components (15)
Note: If your environment uses HTTP or HTTPS proxies, include the flags --http-proxy, - -https-proxy,
and --no-proxy with their values in the command to ensure it runs successfully. For more information, see
Configuring an HTTP or HTTPS Proxy on page 696.
```

1. Move the Cluster API objects from the bootstrap to the managed cluster.

The cluster life cycle services on the managed cluster are ready, but the
managed cluster configuration is on the bootstrap cluster. The move command
moves the configuration, which takes the form of Cluster API Custom Resource
objects, from the bootstrap to the managed cluster. This process is called a
Pivot. For more information, see `<<https://cluster->`
api.sigs.k8s.io/reference/glossary.html?highlight=pivot#pivot>.

```bash
nkp move capi-resources --to-kubeconfig ${CLUSTER_NAME}.conf
```

Output:

```bash
# Moving cluster resources (9)
You can now view resources in the moved cluster by using the --kubeconfig flag with
kubectl. For example: kubectl --kubeconfig=gcp-example.conf get nodes
Note: To ensure only one set of cluster life cycle services manages the managed cluster, NKP first pauses the
reconciliation of the objects on the bootstrap cluster, then creates the objects on the managed cluster. As NKP
copies the objects, the cluster life cycle services on the managed cluster reconcile the objects. The managed cluster
becomes self-managed after NKP creates all the objects. If it fails, the move command can be safely retried.
```

1. Wait for the cluster control plan to be ready.

```bash
kubectl --kubeconfig ${CLUSTER_NAME}.conf wait --for=condition=Available=True
"clusters/${CLUSTER_NAME}" --timeout=20m
```

Output:

```bash
cluster.cluster.x-k8s.io/gcp-example condition met
```

1. Use the cluster life cycle services on the managed cluster to check the
   managed cluster status. After moving the cluster life cycle services to the
   managed cluster, remember to use NKP with the managed cluster kubeconfig.

```bash
nkp describe cluster --kubeconfig ${CLUSTER_NAME}.conf -c ${CLUSTER_NAME}
```

Output:

```bash
NAME READY
SEVERITY REASON SINCE MESSAGE
Cluster/gcp-example True
14s
##ClusterInfrastructure - GCPCluster/gcp-example
##ControlPlane - KubeadmControlPlane/gcp-example-control-plane True
14s
# ##Machine/gcp-example-control-plane-6fbzn True (2)
17s
# # ##MachineInfrastructure - GCPMachine/gcp-example-control-plane-62g6s (2)
# ##Machine/gcp-example-control-plane-jf6s2 True (2)
17s
# # ##MachineInfrastructure - GCPMachine/gcp-example-control-plane-bsr2z (2)
# ##Machine/gcp-example-control-plane-mnbfs True (2)
17s
# ##MachineInfrastructure - GCPMachine/gcp-example-control-plane-s8xsx (2)
##Workers
##MachineDeployment/gcp-example-md-0 True
17s
##Machine/gcp-example-md-0-68b86fddb8-8glsw True
17s
# ##MachineInfrastructure - GCPMachine/gcp-example-md-0-zls8d (2)
##Machine/gcp-example-md-0-68b86fddb8-bvbm7 True
17s
# ##MachineInfrastructure - GCPMachine/gcp-example-md-0-5zcvc (2)
##Machine/gcp-example-md-0-68b86fddb8-k9499 True
17s
# ##MachineInfrastructure - GCPMachine/gcp-example-md-0-k8h5p (2)
##Machine/gcp-example-md-0-68b86fddb8-l6vfb True
17s
##MachineInfrastructure - GCPMachine/gcp-example-md-0-9h5vn
```

1. Remove the bootstrap cluster because the managed cluster is now self-managed.

```bash
nkp delete bootstrap --kubeconfig $HOME/.kube/config
```

Output:

```bash
# Deleting bootstrap cluster (10)
```

Known Limitations: NKP only supports moving all namespaces in the cluster; NKP
does not support migration of individual namespaces.

#### GCP Non-Air-gapped: Exploring the GCP Cluster

About this task

Before you start, make sure you have created a managed cluster, as described
in Create a New GCP Cluster.

Procedure

1. When the managed cluster is created, the cluster life cycle services
   generate a kubeconfig file for the managed cluster and write it to a Secret.
   The kubeconfig file is scoped to the cluster administrator. Get a kubeconfig
   file for the workload cluster.

```bash
nkp get kubeconfig -c ${CLUSTER_NAME} > ${CLUSTER_NAME}.conf
```

1. Verify the API server is up by listing the nodes.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get nodes
Note: The Status may take a few minutes to move to Ready while the Pod network is deployed. The node status
will change to Ready soon after the calico-node DaemonSet Pods are Ready.
```

Output:

```bash
NAME STATUS ROLES AGE VERSION
gcp-example-control-plane-9z77w Ready control-plane,master 4m44s
v<kubernetes-version>
gcp-example-control-plane-rtj9h Ready control-plane,master 104s
v<kubernetes-version>
gcp-example-control-plane-zbf9w Ready control-plane,master 3m23s
v<kubernetes-version>
gcp-example-md-0-88c46 Ready <none> 3m28s
v<kubernetes-version>
gcp-example-md-0-fp8s7 Ready <none> 3m28s
v<kubernetes-version>
gcp-example-md-0-qvnx7 Ready <none> 3m28s
v<kubernetes-version>
gcp-example-md-0-wjdrg Ready <none> 3m27s
v<kubernetes-version>
```

1. List the Pods with the command.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get pods -A
```

Verify the output:

```bash
NAMESPACE NAME
READY STATUS RESTARTS AGE
calico-system calico-kube-controllers-577c696df9-v2nzv
1/1 Running 0 5m23s
calico-system calico-node-4x5rk
1/1 Running 0 4m22s
calico-system calico-node-cxsgc
1/1 Running 0 4m23s
calico-system calico-node-dvlnm
1/1 Running 0 4m23s
calico-system calico-node-h6nlt
1/1 Running 0 4m23s
calico-system calico-node-jmkwq
1/1 Running 0 5m23s
calico-system calico-node-tnf54
1/1 Running 0 4m18s
calico-system calico-node-v6bwq
1/1 Running 0 2m39s
calico-system calico-typha-6d8c94bfdf-dkfvq
1/1 Running 0 5m23s
calico-system calico-typha-6d8c94bfdf-fdfn2
1/1 Running 0 3m43s
calico-system calico-typha-6d8c94bfdf-kjgzj
1/1 Running 0 3m43s
capa-system capa-controller-manager-6468bc488-w7nj9
1/1 Running 0 67s
capg-system capg-controller-manager-5fb47f869b-6jgms
1/1 Running 0 53s
capi-kubeadm-bootstrap-system capi-kubeadm-bootstrap-controller-
manager-65ffc94457-7cjdn 1/1 Running 0 74s
capi-kubeadm-control-plane-system capi-kubeadm-control-plane-controller-manager-
bc7b688d4-vv8wg 1/1 Running 0 72s
capi-system capi-controller-manager-dbfc7b49-dzvw8
1/1 Running 0 77s
cappp-system cappp-controller-manager-8444d67568-rmms2
1/1 Running 0 59s
capv-system capv-controller-manager-58b8ccf868-rbscn
1/1 Running 0 56s
capz-system capz-controller-manager-6467f986d8-dnvj4
1/1 Running 0 62s
cert-manager cert-manager-6888d6b69b-7b7m9
1/1 Running 0 91s
cert-manager cert-manager-cainjector-76f7798c9-gnp8f
1/1 Running 0 91s
cert-manager cert-manager-webhook-7d4b5d8484-gn5dr
1/1 Running 0 91s
gce-pd-csi-driver csi-gce-pd-controller-5bd587fbfb-lrx29
5/5 Running 0 5m40s
gce-pd-csi-driver csi-gce-pd-node-4cgd8
2/2 Running 0 4m22s
gce-pd-csi-driver csi-gce-pd-node-5qsfk
2/2 Running 0 4m23s
gce-pd-csi-driver csi-gce-pd-node-5w4bq
2/2 Running 0 4m18s
gce-pd-csi-driver csi-gce-pd-node-fbdbw
2/2 Running 0 4m23s
gce-pd-csi-driver csi-gce-pd-node-h82lx
2/2 Running 0 4m23s
gce-pd-csi-driver csi-gce-pd-node-jzq58
2/2 Running 0 5m39s
gce-pd-csi-driver csi-gce-pd-node-k6bz9
2/2 Running 0 2m39s
kube-system cluster-autoscaler-7f695dc48f-v5kvh
1/1 Running 0 5m40s
kube-system coredns-64897985d-hbkqd
1/1 Running 0 5m38s
kube-system coredns-64897985d-m8g5j
1/1 Running 0 5m38s
kube-system etcd-gcp-example-control-plane-9z77w
1/1 Running 0 5m32s
kube-system etcd-gcp-example-control-plane-rtj9h
1/1 Running 0 2m37s
kube-system etcd-gcp-example-control-plane-zbf9w
1/1 Running 0 4m17s
kube-system kube-apiserver-gcp-example-control-plane-9z77w
1/1 Running 0 5m32s
kube-system kube-apiserver-gcp-example-control-plane-rtj9h
1/1 Running 0 2m38s
kube-system kube-apiserver-gcp-example-control-plane-zbf9w
1/1 Running 0 4m17s
kube-system kube-controller-manager-gcp-example-control-
plane-9z77w 1/1 Running 0 5m33s
kube-system kube-controller-manager-gcp-example-control-
plane-rtj9h 1/1 Running 0 2m37s
kube-system kube-controller-manager-gcp-example-control-
plane-zbf9w 1/1 Running 0 4m17s
kube-system kube-proxy-bskz2
1/1 Running 0 4m18s
kube-system kube-proxy-gdkn5
1/1 Running 0 4m23s
kube-system kube-proxy-knvb9
1/1 Running 0 4m22s
kube-system kube-proxy-tcj7r
1/1 Running 0 4m23s
kube-system kube-proxy-thdpl
1/1 Running 0 5m38s
kube-system kube-proxy-txxmb
1/1 Running 0 4m23s
kube-system kube-proxy-vq6kv
1/1 Running 0 2m39s
kube-system kube-scheduler-gcp-example-control-plane-9z77w
1/1 Running 0 5m33s
kube-system kube-scheduler-gcp-example-control-plane-rtj9h
1/1 Running 0 2m37s
kube-system kube-scheduler-gcp-example-control-plane-zbf9w
1/1 Running 0 4m17s
node-feature-discovery node-feature-discovery-master-7d5985467-lh7dc
1/1 Running 0 5m40s
node-feature-discovery node-feature-discovery-worker-5qtvg
1/1 Running 0 3m40s
node-feature-discovery node-feature-discovery-worker-66rwx
1/1 Running 0 3m40s
node-feature-discovery node-feature-discovery-worker-7h92d
1/1 Running 0 3m35s
node-feature-discovery node-feature-discovery-worker-b4666
1/1 Running 0 3m40s
tigera-operator tigera-operator-5f9bdc5c59-j9tnr
1/1 Running 0 5m38s
```

#### GCP Non-Air-gapped: Installing Kommander

About this task

Once you have installed the Konvoy component of Nutanix Kubernetes Platform
(NKP), you will continue installing the Kommander component that will bring up
the UI dashboard.

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

1. If required: Customize your kommander.yaml. See the Kommander
   Customizations page for customization options. Some options include Custom
   Domains and Certificates, HTTP proxy, Disabling the AI Navigator
   application, External Load Balancer, GPU utilization, Rook Ceph
   customization for Pre-provisioned environments, and so on.
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

1. Expand one of the following sets of instructions, depending on your license
   and application environments:

» Pro License: Install Kommander in a Non-Air-Gapped Environment

Pro License: Install Kommander

Use the customized kommander.yaml to install NKP:

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

Kommander Customizations

You can configure the Kommander component of NKP during the initial
installation, and also post-installation using the NKP CLI. If you are not
sure of what you want to customize during install, then proceed to the next
step. To read about Kommander component customization options, refer to this
section of the documentation: Kommander Customizations on page 996.

### GCP Management Tools

After cluster creation and configuration, you can revisit clusters to update
and change variables.

You can manage node pools, configure cluster autoscalers, or even delete a
cluster.

#### GCP: Manage Node Pools

When Konvoy creates a new default cluster, there is one node pool for the
worker nodes, and all nodes in that new node pool have the same configuration.
You can create additional node pools for more specialized hardware or
configuration. For example, if you have to tune your memory usage on a cluster
where you need maximum memory for some machines and minimal memory on others,
you create a new node pool with those specific resource needs.

Nutanix Kubernetes Platform (NKP) implements node pools using Cluster API
MachineDeployments. For more information on node pools, see these sections:

##### GCP: Creating Node Pools

Creating a node pool is useful when you need to run workloads that require
machines with specific resources, such as a GPU, additional memory, or
specialized network or storage hardware.

About this task

The first task is to prepare the environment.

Procedure

1. Set the environment variable to the name you assigned this cluster.

```bash
export CLUSTER_NAME=gcp-example
```

1. If your managed cluster is self-managed, as described in GCP Non-Air-
   gapped: Making the Cluster Self- Managed on page 963, configure kubectl to
   use the kubeconfig for the cluster.

```bash
export KUBECONFIG=${CLUSTER_NAME}.conf
```

1. Define your node pool name.

```bash
export NODEPOOL_NAME=example
```

###### Create a GCP Node Pool

About this task

Availability zones (AZs) are isolated locations within datacenter regions
where public cloud services originate and operate. Because all the nodes in a
node pool are deployed in a single Availability Zone, you may wish to create
additional node pools to ensure your cluster has nodes deployed in multiple
Availability Zones.

Create a new AWS node pool with 3 replicas using this command:

Procedure

Set the --zone flag to a zone in the same region as your cluster. Create a new
node pool with three replicas using this command.

```bash
nkp create nodepool gcp ${NODEPOOL_NAME} \
--cluster-name=${CLUSTER_NAME} \
--image $IMAGE_NAME \
--zone us-west1-b \
--replicas=3
machinedeployment.cluster.x-k8s.io/example created
## Creating default/example nodepool resources (3)
gcpmachinetemplate.infrastructure.cluster.x-k8s.io/example created
kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/example created
# Creating default/example nodepool resources (4)
```

This example uses default values for brevity. Use flags to define custom
instance types, images, and other properties.

Advanced users can use a combination of the --dry-run and --output=yaml or
--output- directory=`<existing-directory>` flags to get a complete set of node
pool objects to modify locally or store in version control.

##### GCP: Listing Node Pools

List the node pools of a given cluster. This returns specific properties of
each node pool so that you can see the name of the MachineDeployments.

About this task

List node pools for a managed cluster.

```yaml
Note: To list node pools for the management cluster on NKP 2.18 or later, add -n kommander alongside --
kubeconfig=${CLUSTER_NAME}.conf. Starting in NKP 2.18, the management cluster runs in the kommander
namespace. In NKP 2.17 and earlier, this flag was not required.
```

Procedure

To list all node pools for a managed cluster, run:.

```bash
nkp get nodepools --cluster-name=${CLUSTER_NAME} --kubeconfig=${CLUSTER_NAME}.conf
NODEPOOL DESIRED READY KUBERNETES
VERSION
example 3 3
v<kubernetes-version>
gcp-example-md-0 4 4
v<kubernetes-version>
```

##### GCP: Scaling Up Node Pools

While you can run Cluster Autoscaler, you can also manually scale your node
pools up or down when you need finite control over your environment.

About this task

If you require 10 machines to run a process, you can only manually set the
scaling to run those 10 machines. However, if you also use Cluster Autoscaler,
you must stay within your minimum and maximum bounds. This process allows you
to scale manually.

```yaml
Note: To scale node pools on the management cluster on NKP 2.18 or later, add -n kommander to the command.
Starting in NKP 2.18, the management cluster runs in the kommander namespace. In NKP 2.17 and earlier, this flag
was not required.
```

Scale Up Node Pools

Procedure

1. To scale up a node pool in a cluster, run one of the following.

» Cluster:

```bash
nkp scale nodepools ${NODEPOOL_NAME} --replicas=5 --cluster-name=${CLUSTER_NAME}
```

» Attached Cluster:

```bash
nkp scale nodepools ${ATTACHED_NODEPOOL_NAME} --replicas=5 --cluster-
name=${ATTACHED_CLUSTER_NAME} --kubeconfig=${CLUSTER_NAME}.conf -n
${ATTACHED_CLUSTER_WORKSPACE}
```

Example output indicating that scaling is in progress:

```bash
# Scaling node pool example to 5 replicas (2)
```

1. After a few minutes, you can list the node pools.

```bash
nkp get nodepools --cluster-name=${CLUSTER_NAME} --kubeconfig=${CLUSTER_NAME}.conf
```

Example output showing the number of DESIRED and READY replicas increased to 5:

```bash
NODEPOOL DESIRED READY
KUBERNETES VERSION
gcp-example-md-0 5 5
v<kubernetes-version>
gcp-attached-md-0 5 5
v<kubernetes-version>
```

##### GCP: Scaling Down Node Pools

While you can run Cluster Autoscaler, you can also manually scale your node
pools down when you need more finite control over your environment.

About this task

If you require 10 machines to run a process, you can only manually set the
scaling to run those 10 machines. However, if also using the Cluster
Autoscaler, you must stay within your minimum and maximum bounds. This process
allows you to scale manually.

```yaml
Note: To scale node pools on the management cluster on NKP 2.18 or later, add -n kommander to the command.
Starting in NKP 2.18, the management cluster runs in the kommander namespace. In NKP 2.17 and earlier, this flag
was not required.
```

Procedure

1. To scale down a node pool, run.

```bash
nkp scale nodepool ${NODEPOOL_NAME} --replicas=4 --cluster-name=${CLUSTER_NAME}
```

Example output shows scaling is in progress.

```bash
# Scaling node pool example to 4 replicas
```

1. After a few minutes, you can list the node pools.

```bash
nkp get nodepools --cluster-name=${CLUSTER_NAME} --kubeconfig=${CLUSTER_NAME}.conf
```

Example output showing that the number of DESIRED and READY replicas decreased
to 4.

```bash
NODEPOOL DESIRED READY
KUBERNETES VERSION
example 4 4
v<kubernetes-version>
gcp-example-md-0 4 4
v<kubernetes-version>
```

1. In a default cluster, the nodes to delete are selected at random. • CAPI's
   delete policy controls this behavior. However, when using the Nutanix
   Kubernetes Platform (NKP) CLI to scale down a node pool, it is also possible
   to specify the Kubernetes Nodes you want to delete.

To do this, set the flag --nodes-to-delete with a list of nodes as below. This
adds an annotation cluster.x- k8s.io/delete-machine=yes to the matching
Machine object that contains status.NodeRef with the node names from --nodes-
to-delete.

```bash
nkp scale nodepools ${NODEPOOL_NAME} --replicas=3 --nodes-to-delete=<> --cluster-
name=${CLUSTER_NAME}
```

Output:

```bash
# Scaling node pool example to 3 replicas
```

###### Scaling Node Pools When Using Cluster Autoscaler (2)

About this task

If you configured the cluster autoscaler for the demo-cluster-md-0 node pool,
the value of --replicas must be within the minimum and maximum bounds.

Procedure

1. For example, assuming you have these annotations:

```bash
kubectl annotate machinedeployment ${NODEPOOL_NAME} cluster.x-k8s.io/cluster-api-
autoscaler-node-group-min-size=2
kubectl annotate machinedeployment ${NODEPOOL_NAME} cluster.x-k8s.io/cluster-api-
autoscaler-node-group-max-size=6
```

1. Try to scale the node pool to 7 replicas with the command:

```bash
nkp scale nodepool ${NODEPOOL_NAME} --replicas=7 --cluster-name=${CLUSTER_NAME}
```

Which results in an error similar to:

```bash
# Scaling node pool example to 7 replicas
failed to scale nodepool: scaling MachineDeployment is forbidden: desired replicas
7 is greater than the configured max size annotation cluster.x-k8s.io/cluster-api-
autoscaler-node-group-max-size: 6
```

Similarly, scaling down to a number of replicas less than the configured min-
size also returns an error.

##### GCP: Deleting Node Pools

Deleting a node pool deletes the Kubernetes nodes and the underlying
infrastructure.

About this task

All nodes will be drained before deletion, and the pods running on those nodes
will be rescheduled.

```yaml
Note: To delete a node pool on the management cluster on NKP 2.18 or later, add -n kommander to the command.
Starting in NKP 2.18, the management cluster runs in the kommander namespace. In NKP 2.17 and earlier, this flag
was not required.
```

Procedure

1. To delete a node pool from a managed cluster, run.

```bash
nkp delete nodepool ${NODEPOOL_NAME} --cluster-name=${CLUSTER_NAME}
```

Here, example is the node pool to be deleted.

The expected output will be similar to the following example, indicating the
node pool is being deleted:

```bash
# Deleting default/example nodepool resources (3)
```

1. Deleting an invalid node pool results in output similar to this example.

```bash
nkp delete nodepool ${CLUSTER_NAME}-md-invalid --cluster-name=${CLUSTER_NAME}
```

Output:

```bash
MachineDeployments or MachinePools.infrastructure.cluster.x-k8s.io "no
MachineDeployments or MachinePools found for cluster aws-example" not found
```

#### GCP: Configuring Cluster Autoscaler

About this task

Cluster Autoscaler provides the ability to automatically scale up or scale
down the number of worker nodes in a cluster based on the number of pending
pods to be scheduled. Running the Cluster Autoscaler is optional. Unlike
Horizontal-Pod Autoscaler, Cluster Autoscaler does not depend on any Metrics
server and does not need Prometheus or any other metrics source.

The Cluster Autoscaler looks at the following annotations on a
MachineDeployment to determine its scale-up and scale-down ranges:

> **Note:**

```bash
cluster.x-k8s.io/cluster-api-autoscaler-node-group-min-size
cluster.x-k8s.io/cluster-api-autoscaler-node-group-max-size
```

The full list of command line arguments to the Cluster Autoscaler controller
is on the Kubernetes public GitHub repository.

For more information about how Cluster Autoscaler works, see these documents:

- What is Cluster Autoscaler
- How does scale-up work
- How does scale-down work
- CAPI Provider for Cluster Autoscaler

Before you begin

Ensure you have the following:

- Bootstrap cluster Life cycle: GCP Non-Air-gapped: Bootstrapping GCP on page
  957
- GCP Non-Air-gapped: Creating a Cluster on page 959.
- GCP Non-Air-gapped: Making the Cluster Self-Managed on page 963.

Run Cluster Autoscaler to the Management Cluster

Procedure

1. Ensure the Cluster Autoscaler controller is up and running (no restarts and
   no errors in the logs)

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf logs deployments/cluster-autoscaler
cluster-autoscaler -n kube-system -f
```

1. Enable Cluster Autoscaler by setting the min & max ranges.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf annotate machinedeployment ${NODEPOOL_NAME}
cluster.x-k8s.io/cluster-api-autoscaler-node-group-min-size=2
kubectl --kubeconfig=${CLUSTER_NAME}.conf annotate machinedeployment ${NODEPOOL_NAME}
cluster.x-k8s.io/cluster-api-autoscaler-node-group-max-size=6
```

1. The Cluster Autoscaler logs will show that the worker nodes are associated
   with node-groups and that pending pods are being watched.
2. To demonstrate that it is working properly, create a large deployment that
   will trigger pending pods (For this example, we used GCP m5.2xlarge worker
   nodes. If you have larger worker-nodes, you need to scale up the number of
   replicas accordingly).

```bash
cat <<EOF | kubectl --kubeconfig=${CLUSTER_NAME}.conf apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
name: busybox-deployment
labels:
app: busybox
spec:
replicas: 600
selector:
matchLabels:
app: busybox
template:
metadata:
labels:
app: busybox
spec:
containers:
- name: busybox
image: busybox:latest
command:
- sleep
- "3600"
imagePullPolicy: IfNotPresent
restartPolicy: Always
EOF
```

Cluster Autoscaler will scale up the number of Worker Nodes until there are no
pending pods. 5. Scale down the number of replicas for busybox-deployment.

```bash
kubectl --kubeconfig ${CLUSTER_NAME}.conf scale --replicas=30 deployment/busybox-
deployment
```

1. Cluster Autoscaler starts to scale down the number of Worker Nodes after
   the default timeout of 10 minutes.

#### GCP: Deleting a Cluster

About this task

```yaml
Note: A self-managed managed cluster cannot delete itself. If your managed cluster is self-managed, you must first
create a bootstrap cluster and move the cluster life cycle services to it before deleting the managed cluster.
```

Procedure

If you did not make your managed cluster self-managed, as described in Make
New Cluster Self-Managed, proceed to the instructions for deleting the
workload cluster.

##### Create a Bootstrap Cluster and Move CAPI Resources (3)

About this task

Procedure

1. Create a bootstrap cluster. The bootstrap cluster will host the Cluster API
   controllers that reconcile the cluster objects marked for deletion.

> **Note: To avoid using the wrong kubeconfig, the following steps use
> explicit kubeconfig paths and contexts.**

```bash
nkp create bootstrap --kubeconfig $HOME/.kube/config --with-gcp-bootstrap-
credentials=true
```

Output:

```bash
# Creating a bootstrap cluster (10)
# Initializing new CAPI components (16)
```

1. Move the Cluster API objects from the workload to the bootstrap cluster:
   The cluster life cycle services on the bootstrap cluster are ready, but the
   managed cluster configuration is on the managed cluster. The move command
   moves the configuration, which takes the form of Cluster API Custom Resource
   objects, from the workload to the bootstrap cluster. This process is also
   called a Pivot (`<https://cluster-api.sigs.k8s.io/reference/glossary.html>`?
   highlight=pivot#pivot).

```bash
nkp move capi-resources \
--from-kubeconfig ${CLUSTER_NAME}.conf \
--to-kubeconfig $HOME/.kube/config
```

Output:

```bash
# Moving cluster resources (10)
You can now view resources in the moved cluster by using the --kubeconfig flag with
kubectl. For example: kubectl --kubeconfig $HOME/.kube/config get nodes
```

1. Use the cluster life cycle services on the managed cluster to check the
   managed cluster's status.

```bash
nkp describe cluster --kubeconfig $HOME/.kube/config -c ${CLUSTER_NAME}
```

Output:

```bash
NAME READY
SEVERITY REASON SINCE MESSAGE
Cluster/gcp-example True
34s
##ClusterInfrastructure - GCPCluster/gcp-example
##ControlPlane - KubeadmControlPlane/gcp-example-control-plane True
34s
# ##Machine/gcp-example-control-plane-6fbzn True (3)
37s
# # ##MachineInfrastructure - GCPMachine/gcp-example-control-plane-62g6s (3)
# ##Machine/gcp-example-control-plane-jf6s2 True (3)
37s
# # ##MachineInfrastructure - GCPMachine/gcp-example-control-plane-bsr2z (3)
# ##Machine/gcp-example-control-plane-mnbfs True (3)
37s
# ##MachineInfrastructure - GCPMachine/gcp-example-control-plane-s8xsx (3)
##Workers
##MachineDeployment/gcp-example-md-0 True
37s
##Machine/gcp-example-md-0-68b86fddb8-8glsw True
37s
# ##MachineInfrastructure - GCPMachine/gcp-example-md-0-zls8d (3)
##Machine/gcp-example-md-0-68b86fddb8-bvbm7 True
37s
# ##MachineInfrastructure - GCPMachine/gcp-example-md-0-5zcvc (3)
##Machine/gcp-example-md-0-68b86fddb8-k9499 True
37s
# ##MachineInfrastructure - GCPMachine/gcp-example-md-0-k8h5p (3)
##Machine/gcp-example-md-0-68b86fddb8-l6vfb True
37s
##MachineInfrastructure - GCPMachine/gcp-example-md-0-9h5vn
Warning: After moving the cluster lifecycle services to the managed cluster, remember to use dkp with the
managed cluster kubeconfig.
Note: Persistent Volumes (PVs) are not deleted automatically by design in order to preserve your data. However,
they take up storage space if not deleted. You must delete PVs manually. Information for backup of a cluster and
PVs is on the page in documentation called Back up your Cluster's Applications and Persistent Volumes.
```

1. Wait for the cluster control plan to be ready.

```bash
kubectl --kubeconfig $HOME/.kube/config wait --for=condition=controlplaneready
"clusters/${CLUSTER_NAME}" --timeout=20m
```

Output:

```bash
NAME READY
SEVERITY REASON SINCE MESSAGE
Cluster/gcp-example True
34s
##ClusterInfrastructure - GCPCluster/gcp-example
##ControlPlane - KubeadmControlPlane/gcp-example-control-plane True
34s
# ##Machine/gcp-example-control-plane-6fbzn True (4)
37s
# # ##MachineInfrastructure - GCPMachine/gcp-example-control-plane-62g6s (4)
# ##Machine/gcp-example-control-plane-jf6s2 True (4)
37s
# # ##MachineInfrastructure - GCPMachine/gcp-example-control-plane-bsr2z (4)
# ##Machine/gcp-example-control-plane-mnbfs True (4)
37s
# ##MachineInfrastructure - GCPMachine/gcp-example-control-plane-s8xsx (4)
##Workers
##MachineDeployment/gcp-example-md-0 True
37s
##Machine/gcp-example-md-0-68b86fddb8-8glsw True
37s
# ##MachineInfrastructure - GCPMachine/gcp-example-md-0-zls8d (4)
##Machine/gcp-example-md-0-68b86fddb8-bvbm7 True
37s
# ##MachineInfrastructure - GCPMachine/gcp-example-md-0-5zcvc (4)
##Machine/gcp-example-md-0-68b86fddb8-k9499 True
37s
# ##MachineInfrastructure - GCPMachine/gcp-example-md-0-k8h5p (4)
##Machine/gcp-example-md-0-68b86fddb8-l6vfb True
37s
##MachineInfrastructure - GCPMachine/gcp-example-md-0-9h5vn
```

###### Deleting the Workload Cluster (4)

Procedure

1. To delete a cluster, Use nkp delete cluster and pass in the name of the
   cluster you are trying to delete with --cluster-name flag. Use kubectl get
   clusters to get those details (--cluster-name and -- namespace) of the
   Kubernetes cluster to delete it.

```yaml
Note: Do not use nkp get clusters since that gets you NKP cluster details rather than Konvoy cluster
details.
kubectl get nkpclusters
```

1. Delete the Kubernetes cluster and wait a few minutes.

Use nkp with the bootstrap cluster to delete the managed cluster.

```yaml
Note: Before deleting the cluster, Nutanix Kubernetes Platform (NKP) deletes all Services of type LoadBalancer
on the cluster. An AWS Classic ELB backs each Service. Deleting the Service deletes the ELB that backs it. To
skip this step, use the --delete-kubernetes-resources=false flag. Do not skip this step if NKP
manages the VPC when NKP deletes the cluster, it deletes the VPC. If the VPC has any AWS Classic ELBs, AWS
does not allow the VPC to be deleted, and NKP cannot delete the cluster.
nkp delete cluster --cluster-name=${CLUSTER_NAME} --kubeconfig $HOME/.kube/config
```

Output:

```bash
# Deleting Services with type LoadBalancer for Cluster default/azure-example (2)
# Deleting ClusterResourceSets for Cluster default/azure-example (2)
# Deleting cluster resources (5)
# Waiting for cluster to be fully deleted (4)
Deleted default/azure-example cluster
```

After the managed cluster is deleted, you can delete the bootstrap cluster.

###### Deleting the Bootstrap Cluster (4)

About this task

After you have moved the workload resources back to a bootstrap cluster and
deleted the managed cluster, you no longer need the bootstrap cluster. You can
safely delete the bootstrap cluster with these steps:

Procedure

Delete the bootstrap cluster.

```bash
nkp delete bootstrap --kubeconfig $HOME/.kube/config
```

Output:

```bash
# Deleting bootstrap cluster (11)
```

Known Limitations

The NKP version used to create the managed cluster must match the NKP version
used to delete the managed cluster.
