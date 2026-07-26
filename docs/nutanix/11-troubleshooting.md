# Troubleshooting Guide

## Troubleshooting Guide (2)

Collection of tips for self-remedying common NKP user issues.

The sections in this chapter represent the most common areas of questions
directed at our Support Department. Starting here, you can answer those
frequently asked questions.

## Gather Environment Data for Nutanix NKP Support

Steps for gathering the data needed to troubleshoot a Kubernetes cluster.

The following pages provide the steps to troubleshoot a Kubernetes cluster
customization. These subtopics offer a way to supply a support bundle file
back to Nutanix for further analysis.

### Generate a Support Bundle

#### Prerequisites

Before generating a support bundle, verify that you have:

- An AMD 64-based Linux or macOS machine with a supported version of the
  operating system.
- A running Kubernetes cluster.
- Access to the NKP binary.

#### Diagnostic Bundle

```bash
nkp diagnose was developed by NKP and builds on the open source troubleshoot.sh project.
Note: The command nkp diagnose is based on version v0.92.2 of troubleshoot.sh with custom
modifications. The NKP fork is open source and available from this public GitHub repository: https://github.com/
mesosphere/troubleshoot.
nkp diagnose supports multiple support bundle collectors and can be configured as a SupportBundle Kubernetes
resource in a YAML file. For more information, see https://troubleshoot.sh/docs/collect/all/.
```

The following list is the minimum set of resources required to debug a
cluster, but it can be further customized.

The bundle uses the following collectors:

- clusterInfo collects basic information about the cluster. For more
  information, see `<https://troubleshoot.sh/>` docs/collect/cluster-info/.
- clusterResources collects a subset of available resources in the cluster.
  For more information, see https:// troubleshoot.sh/docs/collect/cluster-
  resources/.
- configMap collects the values of Kubernetes ConfigMaps. For more
  information, see `<https://troubleshoot.sh/>` docs/collect/configmap/.
- secrets collects the names and metadata of secrets, but NOT the secret
  values or keys. For more information, see
  `<https://troubleshoot.sh/docs/collect/secret/>`.
- execCopyFromHost runs a container on each node on the cluster and copies the
  created data. For more information, see Gathering information using the
  ExecCopyFromHost Collector on page 1080.
- allLogs can collect logs from all containers on the cluster. For more
  information, see Using the AllLogs Collector on page 1082.

#### Generating a Support Bundle

About this task

```yaml
Note: The command nkp diagnose uses the same Kubernetes configuration as the command kubectl. The nkp
diagnose command can also be pointed at a specific configuration using the --kubeconfig parameter.
```

To generate the support bundle, perform the following steps:

Procedure

1. Run the default collectors configuration using the command.

```bash
nkp diagnose
```

Output example:

```bash
Collecting support bundle ...
support-bundle-2021-08-13T14_44_23.tar.gz
```

1. To view the bundle contents, extract the bundle and replace support-

bundle-2021-08-13T14_44_23.tar.gz with the location from the previous step.
Example: 3. A new directory named support-bundle-`<date-created>` is created.
This directory contains a number of sub directories. These directories contain
the diagnostic information in files.

Example output:

```bash
cluster-info cluster-resources configmaps node-diagnostics pod-logs secrets
version.yaml
```

#### Collecting Information from a Bootstrap Cluster

About this task

During the initial deployment of the NKP management cluster, a bootstrap
cluster is created first and then the resources
are shifted to the newly created NKP management cluster. If your bootstrap
cluster has not yet pivoted towards your NKP
management cluster, you can collect log information from that bootstrap
cluster, and there is a preconfigured set of
relevant collectors. Specify an additional bootstrap cluster kubeconfig using
the -- bootstrap-kubeconfig parameter to
activate bootstrap cluster diagnostics. You will receive an additional support
bundle named bootstrap-support-
bundle-`<date created>`.

```yaml
Note: The bootstrap cluster diagnostics are independent of a general NKP cluster diagnostics configuration. We run a
static collector set that collects the following bootstrap cluster information:
```

- ClusterInfo

| tar -xzvf support-bundle- | `<date-created>` | .tar.gz |
| ------------------------- | ---------------- | ------- |

| support-bundle- | `<date-created>` |
| --------------- | ---------------- |

| ls support-bundle- | `<date-created>` | Col3 |
| ------------------ | ---------------- | ---- |

- ClusterResources
- AllLogs
- ConfigMaps
- Secrets

Procedure

Run the nkp diagnose command with bootstrap bundle configuration. Example:

```bash
nkp diagnose --bootstrap-kubeconfig <path-to-kubeconfig>
```

#### Using Customizations

About this task

To print the default collectors configuration, complete the following task:

Procedure

1. Run the nkp diagnose default-config > bundle.yaml command.
2. Edit the file to make appropriate modifications.

```yaml
Note: By default, nkp diagnose does not require that you supply a configuration. You can print the default
bundle by running nkp diagnose default-config.
```

1. Run the nkp diagnose bundle.yaml

### Using SSH Fallback and Ansible

About this task

In some cases, the Kubernetes API is unavailable for the cluster. In those
cases, you can collect node-level information using SSH access to the
diagnosed nodes. Be aware that not all clusters have SSH access configured. If
they do not, then access using SSH fallback is not possible.

To get node-level information from your cluster using SSH access, perform the
following steps:

Procedure

To specify the nodes to access for data collection, run the command.

```bash
nkp diagnose ssh <path/to/ansible-inventory.yaml>
```

The ansible-inventory.yaml file specifies the nodes to access for data
collection.

```yaml
Note: This collector does not use the full Ansible inventory.yaml format, only a limited subset to describe the
infrastructure.
```

Only the following attributes of the ansible-inventory.yaml are supported. All
other group definitions are ignored.

- Support for all shared variables.
- Support for hosts key in all groups.
- Supported behavioral inventory is limited to:
- ansible_host
- ansible_port
- ansible_user
- ansible_ssh_private_key_file

The following is an example inventory.yaml file:

```bash
all:
vars:
ansible_user: centos
hosts:
host-1:
ansible_host: 192.168.10.1
host-2:
ansible_host: 192.168.10.22
ansible_port: 2222
```

More information on these Ansible parameters can be found in the Ansible User
Guide at `<https://docs.ansible.com/>`
ansible/latest/user_guide/intro_inventory.html#connecting-to-hosts-behavioral-
inventory-parameters.

> **Note: All other group definitions are in the inventory.yaml files are
> ignored.**

Example:

```bash
all:
vars:
ansible_user: centos
hosts:
host-1:
ansible_host: 192.168.10.1
host-2:
ansible_host: 192.168.10.22
ansible_port: 2222
```

The fallback collector runs a bash script over SSH and copies the collected
data. The format of the created bundle matches that of nkp diagnose collector-
generated bundles.

Example:

```bash
node-diagnostics/<HOSTNAME_PORT>/data/
- dmesg
- ....
```

Redactors are supported and are in the same format as the main nkp diagnose
command. Per node collection, timeouts are supported using the --timeout
parameter.

### Create Diagnostic Bundles using Custom Collectors

NKP integrates a customized version of troubleshoot.sh to gather data such as
logs, resource states, and configuration files. You can define custom
collectors to include specific namespaces, workloads, or components, allowing
precise troubleshooting and faster root cause analysis.

#### Customizations

To meet the specific needs of diagnosing NKP clusters, we have developed
custom collectors and modified the behavior of upstream collectors. For more
information on the changes, see our repository at `<https://github.com/>`
mesosphere/troubleshoot/blob/v0.92.2-d2iq/README.d2iq.md.

##### Gathering information using the ExecCopyFromHost Collector

About this task

This collector is explicitly created to gather host-level information from
cluster nodes. The collector allows you to run a provided container image in a
privileged mode as a root user, with additional Linux capabilities and the
host filesystem mounted in the container.

You can collect host-level information other than copying host-level files.
(This is already possible with the
CopyFromHost collector.) Like the CopyFromHost collector, this collector runs
as a Kubernetes DaemonSet executed on all
nodes in the system. The data produced by the container are copied from a pre-
defined directory into the diagnostics
bundle under each node name. The name of the parent directory in the
diagnostics bundle is determined by the name of the
collector specified in its configuration.

Procedure

1. The data written into the diagnostics bundle follows this format
   `<collector-name>` / `<node-name>` /

```bash
data / (file1|file2|...)
```

The following is a sample configuration file:

```bash
spec:
collectors:
- execCopyFromHost:
name: node-diagnostics
image: mesosphere/nkp-diagnostics-node-collector:latest
timeout: 30s
command:
- "/bin/bash"
- "-c"
- "/diagnostics/container.sh --hostroot /host --hostpath ${PATH} --
outputroot /output"
workingDir: "/diagnostics"
includeControlPlane: true
privileged: true
capabilities:
- AUDIT_CONTROL
- AUDIT_READ
- BLOCK_SUSPEND
- BPF
- CHECKPOINT_RESTORE
- DAC_READ_SEARCH
- IPC_LOCK
- IPC_OWNER
- LEASE
- LINUX_IMMUTABLE
- MAC_ADMIN
- MAC_OVERRIDE
- NET_ADMIN
- NET_BROADCAST
- PERFMON
- SYS_ADMIN
- SYS_BOOT
- SYS_MODULE
- SYS_NICE
- SYS_PACCT
- SYS_PTRACE
- SYS_RAWIO
- SYS_RESOURCE
- SYS_TIME
- SYS_TTY_CONFIG
- SYSLOG
- WAKE_ALARM
extractArchive: true
```

The following is an example of the data produced by running this collector:

```bash
### node-diagnostics
# ### troubleshoot-control-plane
# # ### data
# # ### certs_expiration_kubeadm
# # ### containerd_config.toml
...
# # ### whoami_validate
# ### troubleshoot-worker
# ### data
# ### containerd_config.toml
# ### containers_crictl
...
# ### whoami_validate
```

If an error occurs while collecting node diagnostics, the node-
diagnostics/`<node>`/pod-collector.json file contains the
serialized JSON representations of the running pod. This helps debug the
reasons for the collection failure. The node-
diagnostics/`<node>`/pod-collector.log file contains standard output from the
collector container that runs the
diagnostics script. In addition, the command may also produce certain
-error.txt files. file-copy-error.txt and pod-
collector-files-copy-error.txt are two file examples. These files contain
error messages generated while fetching log
files from the collector.

When using this collector for node-level information, you must run additional
docker containers and must have the following docker images:

- mesosphere/pause-alpine:3.2
- mesosphere/nkp-diagnostics-node-collector:$(nkp-diagnose version)

For more information on the configuration options, see the ExecCopyFromHost in
the pkg/apis/ troubleshoot/v1beta2/exec_copy_from_host.go file. 2. (Optional)
If there is a timeout, do the following:

a. Run the diagnose command: If there is a timeout, the following is displayed:

```bash
Collecting support bundle node-diagnostics
failed to run collector: exec-copy-from-host/node-diagnostics: timeout
```

This collector copies data collected from cluster nodes to the diagnostics
bundle. This collector is configured to run for 30 seconds by default .
Depending on the cluster size, the size of the collected data, and the network
connection speed between the CLI environment and the cluster, 30 seconds may
not be enough to copy the data.

b. Do one of the following:

- Configure the timeout field to higher value.
- Configure the timeout field to 0.

The timeout is removed. The collector copies data successfully.

##### Using the AllLogs Collector

About this task

This collector gathers pod logs from specified namespaces or all namespaces if
none are selected. You can collect logs of all the pods from all the
namespaces. The pod logs are collected under the allPodLogs directory.

Procedure

The data written into the diagnostics bundle follows this format: `<collector-
name>` / `<namespace-name>` / `<pod-name>` - (container1|container2|...)

The following is a sample configuration file to collect logs from all the pods
from all the namespaces:

```bash
spec:
collectors:
- allLogs:
namespaces:
- "*"
```

The following is a sample configuration file to collect logs from all the pods
from specific namespaces:

```bash
spec:
collectors:
- allLogs:
namespaces:
- default
- dev
- prod
```

The following is an example of the data produced by running this collector:

```bash
### node-diagnostics (2)
# ### troubleshoot-control-plane (2)
# # ### data (2)
# # ### certs_expiration_kubeadm (2)
# # ### containerd_config.toml (2)
...
# # ### whoami_validate (2)
# ### troubleshoot-worker (2)
# ### data (2)
# ### containerd_config.toml (2)
# ### containers_crictl (2)
...
# ### whoami_validate (2)
```

If an error occurs while collecting node diagnostics, the node-
diagnostics/`<node>`/pod-collector.json file contains the serialized JSON
representations of the running pod. This helps debug the reasons for the
collection failure. The node-diagnostics/`<node>`/pod-collector.log file
contains stdout from the collector container that runs the diagnostics script.

When using this collector for node-level information, you must run additional
docker containers and must have the following docker images:

- mesosphere/pause-alpine:3.2
- mesosphere/nkp-diagnostics-node-collector:$(nkp-diagnose version)

For more information on the configuration options, see the ExecCopyFromHost in
the pkg/apis/troubleshoot/ v1beta2/exec_copy_from_host.go file.

##### Collect from all Namespaces for ConfigMap and Secret Collector

Support for collecting from all namespaces forConfigMapandSecretcollector.

In the original collectors namespace there is a required parameter. This
supports collecting from all namespaces by not setting the namespace (or
setting it to ""). Note: To collect all config maps or secrets, an empty
selector must be used (selector: [""]).

##### Support for Optional support-bundle Name Prefix

The nkp diagnose command includes an optional --bundle-name-prefix option that
is used to add a prefix to the bundle names automatically. The original bundle
naming convention (i.e. support-bundle-`<date/time>`) is used if this option is
not specified.

When generating a support bundle, you need naming defaults to provide
deterministic bundle identifiers. This feature is especially useful for our
convenience extension of providing diagnostics for both, a bootstrap, Konvoy,
or other Kubernetes cluster. Using an empty prefix keeps the original naming
convention.

##### ClusterResources Collector

## Common Information Discovery Commands

Discovery commands provide information about the environment and system status
used to identify problems.

When troubleshooting Cluster Operations Management, sometimes just knowing
what, where, and status can help you determine where the problem is and help
reveal a solution to an issue.

Several kubectl commands can give you information from your environment that
can be useful in determining where a problem is occurring.

### Application Discovery Commands

Application definitions originate from the source Git repository. These are
configured in the cluster for Flux to consume. You can use common kubectl
verbs to investigate status and gather log data to help determine any problem
areas.

Investigate the Git repository using kubectl.

```bash
kubectl get gitrepository -A
```

or

```bash
kubectl describe -n <namespace> gitrepository <name>
```

Check the status logs of the source- controller pod

```bash
kubectl describe -n kommander-flux deploy/source-
controller
```

or

```bash
kubectl logs -n kommander-flux deploy/source-
controller --tail -1
```

Verify the status of the associated Apps, ClusterApps, and AppDeployments

```bash
kubectl get apps,clusterapps,appdeployments -A
```

Check the status and logs of the kommander-appmanagement pod

```bash
kubectl describe -n kommander deploy/kommander-
appmanagement
```

or

```bash
kubectl logs -n kommander deploy/kommander-
appmanagement --tail -1
```

Kustomizations

Check the status of all Kustomizations created by AppDeployment:

```bash
kubectl get kustomization -A
```

or

```bash
kubectl describe -n <namespace> kustomization <name>
```

Check the status and logs of the kustomize-controller pod since it manages
Kustomizations in the kommander-flux Namespace.

```bash
kubectl describe -n kommander-flux deploy/kustomize-
controller
```

or

```bash
kubectl logs -n kommander-flux deploy/kustomize-
controller --tail -1
```

| Verb and Purpose | Examples |
| ---------------- | -------- |

HelmRelease

HelmRelease(s) are deployed by each Kustomization, and for the Application to
function, these resources must be in the "Ready" state. To check:

```bash
kubectl get helmrelease -A
```

or

```bash
kubectl describe -n <namespace> helmrelrease <name>
```

Each HelmRelease also consumes a HelmChart. We can ensure the status of
HelmCharts with the following:

```bash
kubectl get helmchart -A
```

or

```bash
kubectl describe -n <namespace> helmchart <name>
```

The controller that manages HelmReleases and HelmCharts is the helm-controller
in the kommander-flux Namespace. It can be helpful to check the status and
logs of the helm-controller pod:

```bash
kubectl describe -n kommander-flux deploy/helm-
controller
```

or

```bash
kubectl logs -n kommander-flux deploy/helm-controller
--tail -1
```

### Workspace Discovery Commands

Workspaces are managed by a Custom Resource named Workspaces. You can use
common kubectl verbs to investigate status and gather log data to help
determine any problem areas:

Leverage kubectl to investigate workspace information:

```bash
kubectl get workspaces
```

or

```bash
kubectl describe workspace <name>
```

The controller that manages Workspaces is the kommander- cm deployment in the
kommander Namespace. Check status logs :

```bash
kubectl describe -n kommander deployment/kommander-cm
```

or

```bash
kubectl logs -n kommander deployment/kommander-cm --
all-containers --tail -1
```

Federated\* Resources

Workspace resources federated to Attached clusters are managed by Federated\*
resources. To view the status of all Federated resources for the Workspace
Namespace, we can leverage the following command(s):

```bash
for resource in $(kubectl api-resources | awk '$1
~ /^federated.*$/ {print $1}'); do kubectl get -n
<workspace-namespace> $resource --show-kind --ignore-
not-found; done
```

or

```bash
kubectl describe -n <workspace-namespace> <resource>
```

The controller that manages Federated\* resources is the kubefed-controller-
manager in the kube-federation-system Namespace. It can be helpful to check
into the status and logs of the kubefed-controller-manager pod:

```bash
kubectl describe -n kube-federation-system deployment/
kubefed-controller-manager
```

or

```bash
for pod in $(kubectl get po -n kube-federation-system
-lkubefed-control-plane=controller-manager -oname);
do kubectl logs -n kube-federation-system $pod --all-
containers --tail -1; done
```

| Verb and Purpose | Examples |
| ---------------- | -------- |

| Examples | Examples |
| -------- | -------- |

Attached Clusters

To check kubectl get kommanderclusters -n `<workspace-namespace>` -o yaml

or

```bash
kubectl describe kommanderclusters -n <workspace-
namespace>
```

## Application Troubleshooting

Describes common application behaviors when the root cause is with an
application deployed on the Kommander component.

Not sure if you are having problems with the Applications deployed on the
Kommander component of NKP? This section will explain some behaviors you may
observe if you have issues with Applications. Also, you see context around the
machinery that manages the resources and how they interact.

Related Topics

- Deploying Platform Applications Using CLI on page 353
- Platform Applications Dependencies For All Clusters on page 354

### Applications Context

Application definitions originate from the source Git Repository(ies). They
are configured inside the cluster for Flux to consume. The controller that
manages Git Repositories is the source-controller deployment in the kommander-
flux Namespace.

Kommander Applications are deployed as AppDeployments and reference Apps and
ClusterApps. The controller that manages Apps, ClusterApps, and AppDeployments
is the kommander-appmanagement deployment in the kommander Namespace. For more
information on AppDeployments, see Applications on page 327.

Each AppDeployment creates a Kustomization. The controller that manages
Kustomizations is the kustomize-controller in the kommander-flux Namespace.

Each Kustomization typically deploys a few resources, with HelmRelease(s)
being the most notable. For the application functionality, these resources
should always be ready. Each HelmRelease also consumes a HelmChart. The
controller that manages HelmReleases and HelmCharts is the helm-controller in
the kommander-flux Namespace.

> **Note: The NKP Release Notes on the Nutanix Support Portal contains the
> current version information for Applications.**

### Troubleshooting Approach

To properly troubleshoot an issue, you need to be familiar with how all the
pieces connected to Applications work. This knowledge will assist in
identifying the problem and where to start troubleshooting.

```yaml
Note: For specific symptoms, you can always search the NKP Knowledge Base for resolutions to behaviors. For more
information, see https://portal.nutanix.com/page/documents/kbs/list?filterVal=Nutanix%20Kubernetes
%20Platform%20(NKP).
```

Example issues might be:

- My Kommander Apps are not getting federated down to my attached clusters.
- The process has halted. How can I check my status?

| Examples | Examples |
| -------- | -------- |

Use the subtopics in this section for more specific help:

### Applications Deployment CLI vs UI

- Application YAML Customizations on page 1091

### Related Topics

Additional troubleshooting information is located in the following sections of
the Cluster Operations Management on page 284 chapter of this guide:

- Platform Applications on page 350
- Deploying Platform Applications Using CLI on page 353
- Workspaces on page 369

Use the following subtopics for specific help:

### Applications Deployment CLI vs UI (2)

- Application YAML Customizations on page 1091

When installing NKP, an AppDeployment resource is created for each enabled
Platform Application. This AppDeployment resource references a ClusterApp,
which then references the repository that contains a concrete declarative and
preconfigured setup of an application, usually in the form of a HelmRelease.
ClusterApps are cluster-scoped, so these Platform Applications are deployable
to all Workspaces or Projects. Also, refer to AppDeployment Resources on page 327.

Applications can be enabled and configured using the UI or CLI at both levels:

- Workspace level for all clusters in a Workspace
- Cluster level for specific clusters within a Workspace.

See the following table for an overview:

Cluster-scoped deployment Create an AppDeployment, and specify target clusters
in spec.clusterSelector. Reference ConfigMap with customization overrides in
clusterConfigOverrides.

To see an example deployment, see Enabling an Application Per Cluster For the
First Time on page 374.

Go to the target workspace and enable through the application card, selecting
the target clusters.

For an example deployment, see Pro: Enabling an Application Using the UI on
page 336.

| Desired level of Configuration | CLI | UI  |
| ------------------------------ | --- | --- |

Workspace-scoped deployment

Create an AppDeployment without a spec.clusterSelector section. Automatically
deploys to all clusters in the workspace.

To see an example deployment, see Deploying Platform Applications Using CLI on
page 353.

Go to

the target workspace and enable it through the application card, selecting all
target clusters. For an example deployment, see Pro: Customizing an
Application Using the UI on page 337.

Cluster-scoped customization

Create an AppDeployment, and specify target clusters in spec.clusterSelector.
Reference ConfigMap with customization overrides in clusterConfigOverrides.

To see an example deployment, see Customizing an Application Per Cluster on
page 375.

Go to target workspace and enable through the application card. Select the
target clusters and establish customizations in the configuration service per
cluster.

For an example deployment, see Pro: Customizing an Application Using the UI on
page 337.

Workspace-scoped customization

Create an AppDeployment without a spec.clusterSelector section. Reference
ConfigMap with customization overrides in clusterConfigOverrides.
Automatically deploys customization to all clusters in the workspace.

To see an example deployment, see Customizing Your Application on page 328.

Go to the target workspace and enable it through the application card.
Manually select all clusters and copy-paste the customization in the
configuration service for all clusters.

For an example deployment, see Pro: Customizing an Application Using the UI on
page 337.

#### Applications Deployment in a Workspace

If you want to know how the AppDeployment resource is currently configured,
use the commands below to print a table of the declared information. If the
AppDeployment is configured for several clusters in a workspace, a column will
display a list of the clusters.

##### Reviewing all AppDeployments in a Workspace

About this task

To review the state of the AppDeployment resource for a specific workspace,
complete the following task.

Procedure

Using the name of your workspace, run the command.

```bash
nkp get appdeployments -w kommander-workspace
```

The output should contain a list of all your applications, as shown in the
example.

```bash
NAME APP CLUSTERS
[...]
kube-oidc-proxy kube-oidc-proxy-0.3.2 management
kube-prometheus-stack kube-prometheus-stack-46.8.0 management
```

| Desired level of Configuration | CLI | UI  |
| ------------------------------ | --- | --- |

```bash
[...]
```

##### Reviewing a Specific AppDeployment of an Application in a Workspace

About this task

To review the state of a specific AppDeployment of an application, complete
the following task.

Procedure

Using the application's name and your workspace, run the nkp get appdeployment
kube-prometheus-stack -w kommander-workspace command.

The output should contain a list of all your applications, as shown in the
example.

```bash
NAME APP CLUSTERS
kube-prometheus-stack kube-prometheus-stack-46.8.0 management
```

##### Deployment Scope

In a single-cluster environment with an Pro license, AppDeployments enable
customizing any platform application.

In a multi-cluster environment with an Ultimate license, AppDeployments enable
Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix
Kubernetes Platform on page 721, Project Applications on page 417, and
Cluster-scoped Application for Existing AppDeployments on page 373.

##### Use Case Example

About this task

As a user, I have multiple clusters in a Workspace. I want to allow an
application for some but not all clusters in that workspace. I also want to
enable a custom configuration.

To define which cluster should have an application deployed onto them, use the
AppDeployment's spec.clusterSelector field.

> **Note: The user can edit the AppDeployment at anytime to add or remove
> clusters from the spec.**

Enable Workspace Applications for a subset of clusters and custom
configurations for each cluster:

Procedure

1. Create an AppDeployment using the command to enable and disable clusters
   and set cluster config overrides per cluster:

```bash
nkp create appdeployment
```

1. Use the code editor to edit the AppDeployment spec to directly:

a. Enable or disable clusters

b. Add or remove cluster config overrides for clusters. using the nkp edit
appdeployment

APPDEPLOYMENT_NAME -n NAMESPACE command. Example:

```bash
nkp edit appdeployment kube-oidc-proxy -n kommander
Note: NAMESPACE is the namespace in which the AppDeployment resides - this can be a Workspace or a Project
Namespace. To list all available workspace namespaces, run kubectl get workspaces.
```

###### Troubleshooting

About this task

For up-to-date status on which clusters an application has been enabled, or
what configuration overrides have been applied to each cluster,

Procedure

1. Check the AppDeployment status using the command.

```bash
nkp get appdeployment
```

1. Use the kubectl get appdeployment command to get the entire YAML object,
   including cluster config overrides that might be set on a cluster and the
   status of the appdeployment. Example:

```bash
nkp get appdeployment --output yaml
```

Example output:

```yaml
apiversion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
generation: 1 # this means there is only one instance of the application, must
match with the number of instances you expect to see
name: kube-oidc-proxy # APP ID of the application as displayed in the Release
Notes
namespace: kommander # equal to the workspace namespace of the workspace where the
app is deployed
spec:
appRef:
kind: ClusterApp
name: kube-oidc-proxy-0.3.2 # APP ID with the app version as displayed in the
Release Notes
clusterConfigOverrides: # present only for apps with custom configurations
- clusterSelector: # present only for workspaces with several clusters
matchLabels:
kommander.d2iq.io/cluster-name: management # cluster name where app is
deployed
configMapName: kube-oidc-proxy-management # name of the ConfigMap file that
contains the Overrides with the custom configuration for this specific cluster
clusterSelector:
matchExpressions:
- key: kommander.d2iq.io/cluster-name
operator: In
values:
- management # cluster name where app is deployed
status:
clusters:
- clusterConfigOverridesRef:
name: kube-oidc-proxy-host-management # name of the ConfigMap file that contains
the Overrides with the custom configuration for this specific cluster
conditions:
- status: "True" # must be True for app to be deployed successfully
type: AppDeploymentEnabled
name: management
observedGeneration: 1
```

###### Verifying Applications

About this task

Once the applications are enabled, verify the deployment using this task.

Procedure

Connect to the attached cluster and check the HelmReleases using the command.

```bash
kubectl get helmreleases -n ${WORKSPACE_NAMESPACE}
```

Example output:

```bash
NAMESPACE NAME READY STATUS
AGE
workspace-test-vjsfq operator True Release reconciliation succeeded 7m3s
```

## Application YAML Customizations

Customized application deployment objects establish how applications are
deployed.

NKP allows configuring an application for all clusters in a workspace and a
subset of clusters in a workspace. You can also apply customizations per
cluster or workspace.

An AppDeployment object creates a local HelmRelease YAML file that establishes
how an Application is deployed. To further customize the application, you can
create a ConfigMap object with overriding configuration.

You can apply the same ConfigMap to several clusters in a workspace or create
different customizations in individual ConfigMaps for each cluster.

The AppDeployment specifies the name of the app, the version of the app, and
the workspace where it applies. Additionally, you can specify a subset of
clusters where it should be deployed and, if required, any customizations.

For example, this is the default AppDeployment for the Kube Prometheus Stack
Platform Application:

```yaml
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: kube-prometheus-stack
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: kube-prometheus-stack-46.8.0
kind: ClusterApp
```

### Overriding the Clusters Within a Workspace

About this task

To change the default configuration of an application across all clusters in a
Workspace, follow these steps:

Procedure

1. Choose a ConfigMap that contains your override values.
2. In the AppDeployment, set the configOverrides field to the name of the
   ConfigMap. The following example customizes the Kube Prometheus Stack
   AppDeployment:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: kube-prometheus-stack
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: kube-prometheus-stack-46.8.0
kind: ClusterApp
configOverrides:
name: kube-prometheus-stack-overrides-attached
EOF
```

> **Note: The configOverrides.name field references the ConfigMap that
> contains the customization.** 3. Create the ConfigMap using the name
> specified in the previous step to provide the custom configuration in
> addition to the default configuration:

```bash
cat <<EOF > kube-prometheus-stack-overrides-attached | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
namespace: ${WORKSPACE_NAMESPACE}
name: kube-prometheus-stack-overrides-attached
data:
values.yaml: |
prometheus:
prometheusSpec:
storageSpec:
volumeClaimTemplate:
spec:
resources:
requests:
storage: 150Gi
EOF
```

On refresh, the AppDeployment includes references to the ConfigMap, which
overrides the application configuration for all clusters within the Workspace
unless the spec.clusterSelector field specifies otherwise.

### Available Customizations

Application YAML can be customized, but which customizations can you do, and
why would you customize? Take a look below for the answers.

- Why Customize? Your environment and provider, combined with various image
  locations or security requirements, might dictate the why behind customizing
  your Applications.
- Enable certain images
- Provide more storage
- Bump memory resources

Depending on which level you need your customizations determines the how.
Refer to the pages that follow for specifics about how to customize your
Applications.

### Custom Configurations

About this task

To get started, create a ConfigMap. A ConfigMap lets you decouple environment-
specific configuration from your container images, making your applications
easily portable. Use a ConfigMap to set configuration data separate from the
Application code. Provide the name of a ConfigMap in the AppDeployment, which
provides custom configuration on top of the default configuration.

This is an example of how to customize the AppDeployment of the Kube
Prometheus Stack:

Procedure

1. Create the ConfigMap, which provides the custom configuration on top of the
   default configuration:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
namespace: ${WORKSPACE_NAMESPACE}
name: kube-prometheus-stack-overrides-attached
data:
values.yaml: |
prometheus:
prometheusSpec:
storageSpec:
volumeClaimTemplate:
spec:
resources:
requests:
storage: 150Gi
EOF
```

1. Provide the name of a ConfigMap with the custom configuration in the
   AppDeployment. Override the default configuration of an Application by
   setting the configOverrides field on the AppDeployment to that ConfigMap.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: kube-prometheus-stack
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: kube-prometheus-stack-46.8.0
kind: ClusterApp
configOverrides:
name: kube-prometheus-stack-overrides-attached
EOF
```

> **Note:**

- The changes are applied only if the YAML file has a valid syntax.
- Set up only one cluster override ConfigMap per cluster. Only one will be
  applied if several ConfigMaps are configured for a cluster.
- Cluster override ConfigMaps must be created on the Management cluster.

Related Topics

- Customizing an Application Per Cluster on page 375
- Disabling the Custom Configuration of an Application Per Cluster on page 377

### Enable or Disable an App per Cluster

For newly attached clusters into the workspace, all Applications enabled for
the Workspace are automatically enabled on and deployed to the new clusters.
If you want to see what clusters your application is currently deployed in,
follow the steps below.

#### Print and Review the Current State of an AppDeployment Resource

If you want to know how the AppDeployment resource is currently configured,
use the commands below to print a table of the declared information. If the
AppDeployment is configured for several clusters in a workspace, a column will
display a list of the clusters.

##### Review all AppDeployments in a workspace

About this task

To review the state of the AppDeployment resource for a specific workspace,
complete this task.

Procedure

Run the command with the name of your workspace.

```bash
nkp get appdeployments -w kommander-workspace
```

The output should contain a list of all your applications, as shown in this
example:

```bash
NAME APP CLUSTERS
[...]
kube-oidc-proxy kube-oidc-proxy-0.3.2 management
kube-prometheus-stack kube-prometheus-stack-46.8.0 management
[...]
```

##### Review a specific AppDeployment of an application in a workspace

About this task

To review the state of a specific AppDeployment of an application, complete
this task.

Procedure

Run the nkp get appdeployment kube-prometheus-stack -w kommander-workspace
command with the name of the application and your workspace, as in this
example:

Example output

```bash
NAME APP CLUSTERS
kube-prometheus-stack kube-prometheus-stack-46.8.0 management
```

##### Deployment Scope (2)

In a single-cluster environment with a Pro license, AppDeployments enable
customizing any platform application.

In a multi-cluster environment with an Ultimate license, AppDeployments can be
customized with Control Plane Nodes and Worker Nodes Resource Requirements for
Nutanix Kubernetes Platform on page 721, Project Applications on page 417, and
Cluster-scoped Application for Existing AppDeployments on page 373.

##### Define a Custom Configuration

Enable or Disable an Application per Cluster after enabling it at the
workspace level. You can enable or disable applications at any time. After you
have enabled the application at the workspace level, the spec.clusterSelector
field populates.

Edit the AppDeployment YAML by adding or removing the names of the clusters
where you want to enable your application in the clusterSelector section.

The following snippet is an example. To customize, replace the following
according to your requirements:

- Application name
- Version
- Workspace name
- Cluster names

For the compatible components and application versions, see NKP Release Notes
on the Nutanix Support Portal.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: kube-prometheus-stack
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: kube-prometheus-stack-46.8.0
kind: ClusterApp
clusterSelector:
matchExpressions:
- key: kommander.d2iq.io/cluster-name
operator: In
values:
- attached-cluster1
- attached-cluster3-new
EOF
```

To verify the Current Configuration of your Application, see Verifying
Applications on page 1091.

## Object Locations and Explanations

Troubleshoot using Kommander component resource locations.

Objects are created and interact in many steps with coordination between
various components and applications. What deploys the Platform Applications,
where are the charts stored, what is the mechanism that deploys them, and how
are settings customized.

### Kommander

Flux Deploys Flux from a set of Kubernetes manifest files.

Helm Repositories Applies the Helm Repository resources from this repository.

ChartMuseum (Air-gapped Only) ChartMuseum stores the Helm Charts for Air-
gapped installations. In non-air-gapped installations, the charts are fetched
from upstream repositories, and ChartMuseum is not installed.

Gatekeeper Deploys Gatekeeper by applying the HelmRelease directly to the
cluster. AppDeployment adopts the HelmRelease.

| Kommander Object | Managed Resource |
| ---------------- | ---------------- |

```bash
kommander-vars
```

Flux Configuration Creates the management GitRepository object and commits it
to Git as well as encrypts and commits the Gitea credentials to Git. Flux
populates the kommander-vars ConfigMap with substitution variables.

Catalog Repository Loader Creates and commits the GitRepository objects to the
management Git repository that are defined in the installer config(catalog).
These default catalo Git repositories are then managed by a controller
(DefaultCatalogGitRepository) which does things like: Propagate the
GitRepository objects to workspaces and projects based on labels.

Related information

`<<https://github.com/mesosphere/kommander-applications/tree/main/common/helm->`
repositories>

### Kommander Resource Locations

Installation happens in many steps, with coordination between various
components and applications. This section describes the process and locations
for multiple repositories. After installing the Konvoy components of NKP using
the NKP CLI, install the Kommander component, by completing the following
tasks.

Kommander Installation Part I:

1. Base - Deploys base resources required, including Kommander and kommander
   flux namespaces. 2. Flux - Deploys Flux
   from a set of Kubernetes manifest files in the kommander-applications
   repository (deployments, etc). 3. Root CA -
   Creates Cert-manager custom resources: kommander-ca clusterIssuer, kommander-
   ca Certificate, and a self-signed
   ClusterIssuer. Then, it waits for the kommander-ca Certificate to be created
   and accessible. 4. ChartMuseum - Installs
   via the Helm library. The ChartMuseum Helm Release is created but will
   reconcile when the Git repository is created and
   populated. This is because ChartMuseum is being stored in the GitRepository.
   The installer will also set the
   helmRepositoryURL in the internal installer configuration to be used during
   the Helm repository installation in the next
   step. 5. Helm Repositories - Applies the Helm Repository resources from the
   kommander-applications repository
   `<https://github.com/mesosphere/kommander-applications/tree/main/common/helm->`
   repositories. If the helmRepositoryURL
   were set in the previous step, it would be applied via a substitution
   variable
   when the Helm Repository objects are
   applied. EX: "${helmMirrorURL:=`<https://kubernetes.github.io/>` dashboardx`}"
2. Ingress Certificate - Sets kommander
   chart values to create the self-attached KommanderCluster with custom
   domain/custom certificate settings. It also
   creates ACME resources (ClusterIssuer) as defined in the installer
   configuration. 7. Applications Definitions -
   Populates the management Git repository by copying the local kommander-
   applications repository provided via the
   --kommander-applications-repository flag. 8. Bootstrap Repository - Commits
   manifests and directories to the Management
   git repository to set up the Management Cluster and the repository structure.
   It also creates the apps-kommander
   kustomization, which deploys apps into the kommander namespace on the
   Management Cluster. 9. Age - Create an Age
   Encryption section for SOPs encryption and add the Age recipient(public) key
   to git. 10. Flux Configuration - Populates
   the kommander-vars ConfigMap with substitution variables as well as creates
   the management GitRepository object and
   commits it to Git 11. Gatekeeper Deploys Gatekeeper by applying the
   HelmRelease directly to the cluster. AppDeployment
   adopts the HelmRelease. 12. AppManagement - Deploys kommander-appmanagement
   via applying the HelmRelease directly to the
   cluster.

| Kommander Object | Managed Resource |
| ---------------- | ---------------- |

1. Core AppDeployments - Creates AppDeployments for the core components: Flux,
   kommander- appmanagement and ChartMuseum.
   These components were previously deployed, but this creates the
   AppDeployments, which will eventually manage the
   Applications. 14. Optional AppDeployments - Creates all the AppDeployments
   for
   the applications defined in the installer
   configuration. 15. Catalog Repository Loader - Creates and commits the
   GitRepository objects to the management Git
   repository defined in the installer config (catalog). These default catalog
   Git repositories are then managed by a
   controller (DefaultCatalogGitRepository), which propagates the GitRepository
   objects to workspaces and projects based on
   labels.

> **Note: The NKP Release Notes on the Nutanix Support Portal contains the
> current version information for Applications.**

Kommander Installation Part II:

This part of the installation deals with Kommander the Controller and Helm
Charts.

Figure 26: Kommander Installation Diagram

## Troubleshooting the Rook Ceph Install Error

If the installation of Kommander component of NKP is unsuccessful due to rook-
cephfailing, follow this workaround to install.

About this task

If the installation of Kommander component of NKP is unsuccessful due to rook-
ceph failing, follow these steps:

Procedure

1. Check if the cluster is affected by this issue:

```bash
kubectl describe CephObjectStores dkp-object-store -n kommander
```

- If the following output is not displayed, stop at this step.
- If the following output is displayed, continue to the next step to apply the
  workaround.

```yaml
Name: dkp-object-store
Namespace: kommander
...
Warning ReconcileFailed 7m55s (x19 over 52m)
rook-ceph-object-controller failed to reconcile CephObjectStore
"kommander/dkp-object-store". failed to create object store deployments: failed
to configure multisite for object store: failed create ceph multisite for
object-store ["dkp-object-store"]: failed to commit config changes after
creating multisite config for CephObjectStore "kommander/dkp-object-store":
failed to commit RGW configuration period changes%!(EXTRA []string=[]): signal:
interrupt
```

1. Kubectl exec into the rook-ceph-tools pod:

```bash
export WORKSPACE_NAMESPACE=<workspace namespace>
CEPH_TOOLS_POD=$(kubectl get pods -l app=rook-ceph-tools -n ${WORKSPACE_NAMESPACE} -o
name)
kubectl exec -it -n ${WORKSPACE_NAMESPACE} $CEPH_TOOLS_POD bash
```

1. Set dkp-object-store as the default zonegroup:

```bash
radosgw-admin zonegroup default --rgw-zonegroup=dkp-object-store
radosgw-admin period update --commit
```

The period update command may take a few minutes to complete. 4. Restart the
rook-ceph-operatordeployment:

```bash
kubectl rollout restart deploy -n${WORKSPACE_NAMESPACE} rook-ceph-operator
```

The rook-cephoperator reconciles the object . This takes time. The
CephObjectStoredisplays Connected. 5. Wait and verify if status of the
CephObjectStores Connected:

```bash
kubectl wait CephObjectStore --for=jsonpath='{.status.phase}'=Connected dkp-object-
store -n ${WORKSPACE_NAMESPACE} --timeout 10m
```
