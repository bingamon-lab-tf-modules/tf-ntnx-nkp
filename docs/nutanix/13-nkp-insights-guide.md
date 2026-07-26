# Nutanix Kubernetes Platform Insights Guide

NUTANIX KUBERNETES PLATFORM INSIGHTS GUIDE

Nutanix Kubernetes Platform Insights (NKP Insights) tool is a predictive
analytics solution for the NKP .

Kubernetes® is a registered trademark of The Linux Foundation in the United
States and other countries and is used pursuant to a license from The Linux
Foundation.

NKP Insights is a predictive analytics capability that detects anomalies that
occur either in the present or future. When NKP Insights detects an anomaly,
an insight alert appears in a table and an alert details page to view root
cause analysis and recommended steps to resolve the alert, from both
Management Clusters and Managed or Attached Clusters. This enables you to save
a lot of time and, therefore, money.

## Nutanix Kubernetes Platform Insights Overview

Nutanix Kubernetes Platform Insights (NKP Insights) is a predictive analytics
solution that detects current and future anomalies in workload configurations
or Kubernetes clusters that can or could occur.

It consists of two components:

- NKP Insights Management runs on the NKP Management cluster.
- NKP Insights Engine runs on each Attached or Managed Kubernetes cluster or
  on the NKP Management cluster for NKP Pro (single-cluster environments)
  customers.

When the NKP Insights engine detects an anomaly, it sends an insight alert to
NKP Management and displays a summary in the Insights Alert table.

An Insight alert details corresponding to an insight alert provide the anomaly
description, root cause analysis, and recommended steps to resolve the anomaly
at a much lower Mean Time To Repair (MTTR) in a Management Cluster and Managed
or Attached Clusters. This maximizes your production environment uptime and
saves you time and money.

NKP Insights assists Kubernetes Administrators or Application Owners with
routine tasks such as:

- Resolving common anomalies
- Checking security issues
- Verifying whether workloads follow best practices

### NKP Insights Alert Table

You must explicitly enable the NKP Insights Engine to explicitly allow the NKP
to Insights Engine on each Attached cluster or Management cluster. The NKP
Insights Setup and Configuration on page 1113 section contains instructions
for configuring these components.

### NKP Insights Engine

- Project name
- Cluster name
- Description
- Type

You can also filter insight alerts in the Alerts table for each Severity level:

- Critical
- Warning
- Notice

### NKP Insights Architecture

Following diagram details the architecture for Nutanix Kubernetes Platform
Insights (NKP Insights).

## Nutanix Kubernetes Platform Insights Setup

Nutanix Kubernetes Platform Insights (NKP Insights) Management is enabled by
default on your Management Cluster as one of the Platform Applications on page
\350. You must enable NKP Insights on each managed or attached cluster that you
want to monitor. See NKP Insights Setup and Configuration on page 1113.

### NKP Insights Resource Requirements

Table 83: Resources needed to run Nutanix Kubernetes Platform Insights

NKP Insights Management

nkp-insights- management

CPU: 100m

Memory: 128Mi

NKP Critical (100002000)

NKP Insights nkp-insights- backend- deployment

CPU: 250m

Memory: 128Mi

NKP Critical (100002000)

nkp-insights- backend- reforwarder

CPU: 100m

Memory: 64Mi

nkp-insights- postgresql

CPU: 256Mi

Memory: 250m

## of PVs: 1

PV Sizes: 8Gi

nkp-insights- resolution

CPU: 100m

Memory: 64Mi

### NKP Insights Setup and Configuration

#### Prerequisites

This chapter contains the following setup and configuration topics:

- Installing NKP Insights

Before enabling NKP Insights, complete the following:

- You have installed NKP.
- You have an NKP Ultimate license applied.
- Decide from which clusters you want to receive insight alerts.
- Ensure you have Rook Ceph, Rook Ceph Cluster, and Kube Prometheus Stack
  deployed on the clusters where you perform the NKP Insights installation.
- You have CloudNativePG component enabled.

```yaml
Note: The Management cluster comes with Rook Ceph, Rook Ceph Cluster, and Kube Prometheus Stack by default.
Deploy Rook Ceph and Rook Ceph Cluster on any Managed or Attached clusters using the UI or CLI.
```

- Application Name; Component Name; Minimum Resources Suggested; Minimum
  Persistent Storage Required; Default PriorityClass

| --- | --- | --- | --- | --- |

#### Installing NKP Insights

About this task

NKP Insights consists of two applications:

- The Insights Management application or nkp-insights-management.
- The Insights Engine application or nkp-insights.

The Insights Management application is enabled by default in the Management
cluster. You must enable the Insights Engine application on the clusters you
want to monitor.

Procedure

1. Enable the Insights Engine (the nkp-insights application) on the clusters
   you want to monitor. There are several options:

» You can enable NKP Insights per cluster or workspace using the UI.

» You can enable NKP Insights per workspace using the CLI. This enables nkp-
insights in all clusters in the target workspace.

» You can enable NKP Insights per cluster using the CLI. This enables nkp-
insights in selected clusters within a workspace. 2. (Optional) Nutanix
recommends enabling the Insights Engine Application on the kommander workspace
to monitor your Management cluster.

> **Note: If you only want to monitor managed clusters, skip this step.**

a. Enable NKP Insights on the Management Cluster Workspace using the UI.

b. Create an AppDeployment for NKP Insights in the kommander namespace (the
workspace name is

kommander-workspace). Specify the correct application version. For more
information, see NKP Insights Release Notes on the Nutanix Support Portal. For
example:

```bash
nkp create appdeployment nkp-insights --app nkp-insights-1.4.4 --workspace
kommander-workspace
```

### Grant View Rights to Users Using the UI

By default, only admin users can access the NKP Insights Alerts table of the
NKP UI and the individual insight alert details.

To allow additional users and user groups to view these Insights resources,
create roles with rights to view them. Then, assign these roles to users or
user groups.

```yaml
Note: Access control to summary cards and details of insight alerts is performed via Kubernetes RBAC based on the
namespace of the Kubernetes resource to which the insight alert is tied. A workspace namespace of the cluster is used
for node-wide and cluster-wide insight alerts.
```

#### Workspace-Based Access Control

- Creating a Role with View Rights to Summary Cards

##### Creating a Role with View Rights to Insight Alert Details

##### Creating a Role with View Rights to Summary Cards

Admin task for creating a workspace-based role with view rights to Nutanix
Kubernetes Platform Insights summary cards.

About this task

When assigned, this role allows users and user groups to view the summary
table of all Nutanix Kubernetes Platform Insights alerts for all workspaces
and projects.

Procedure

1. Select the Management Cluster Workspace. The workspace selector is located
   at the top navigation bar.
2. Select Administration > Access Control in the sidebar menu.
3. Select Create Role, and add a Role Name
4. Select NKP Role, as you provide access to NKP UI resources.
5. Select + Add Rule in the Rules section.
6. Enter the following information:

Resources insights

Resource Names [Leave this field empty]

API Groups dkp-insights.d2iq.io

Verbs get, list and watch 7. Select Save to exit the rule configuration
window. 8. Select Save again to create the new role. 9. Assign the roles you
created to a user group as explained in Configuring Workspace Role Bindings on
page 411.

> **Note: It will take a few minutes to create the resource.**

##### Creating a Role with View Rights to Insight Alert Details (2)

Admin task for creating a project-based role with view rights to Nutanix
Kubernetes Platform Insights details.

About this task

When assigned to a user or user group, this role allows them to view alert
details for an alert generated in a specific project.

Procedure

1. Select the workspace you want to grant view rights to. The workspace
   selector is located at the top navigation bar. (Option available for
   Ultimate customers only)

| Field | Value |
| ----- | ----- |

1. Select Projects in the sidebar menu. Select or create a Project for which
   you want to create a role.
2. Select the Roles tab, and Create Role.
3. Assign a name to the role.
4. Select Role, as you provide access to Insights resources across clusters.
5. Select + Add Rule in the Rules section.
6. Enter the following information:

Select Rule Type Resources

Resources insights, rca, solutions

Resource Names [Leave this field empty]

API Groups virtual.backend.dkp-insights.d2iq.io

Verbs get 8. Select Save to exit the rule configuration window and Save again
to create the new role. 9. Assign the role you created to a user group as
explained in Configuring Workspace Role Bindings on page 411. 10. If you want
to grant view rights to the alert details for clusters in another Workspace,
repeat the same procedure on a per-workspace basis.

> **Note:**

- It will take a few minutes for the resource to be created.
- insights, rca, solutions are virtual resources and are not listed as a
  Kubernetes API resource.

#### Project-Based Access Control

##### Creating a Role with View Rights to Summary Cards (2)

- Creating a Role with View Rights to Insight Alert Details

Admin task for creating a project-based role with view rights to Nutanix
Kubernetes Platform Insights summary cards.

About this task

When assigned, this role allows users and user groups to view the summary
table of all Nutanix Kubernetes Platform Insights alerts for all workspaces
and projects.

Procedure

1. Select the Management Cluster Workspace. The workspace selector is located
   at the top navigation bar.

| Field | Value |
| ----- | ----- |

1. Select Projects in the sidebar menu.
2. Select or create a Project for which you want to create a role.
3. Select the Roles tab and Create Role.
4. Select NKP Role, as you are providing access to NKP UI resources, and add a
   Role Name
5. Select + Add Rule in the Rules section.
6. Enter the following information:

Resources insights

Resource Names [Leave this field empty]

API Groups dkp-insights.d2iq.io

Verbs get, list and watch 8. Select Save to exit the rule configuration
window. 9. Select Save again to create the new role. 10. Assign the roles you
created to a user group as explained in Configuring Workspace Role Bindings on
page 411.

> **Note: It will take a few minutes to create the resource.**

##### Creating a Role with View Rights to Insight Alert Details (3)

Admin task for creating a workspace-based role with view rights to Nutanix
Kubernetes Platform Insights details.

About this task

When assigned to a user or user group, this role allows them to view alert
details for an alert generated in a specific workspace.

Procedure

1. Select the workspace you want to grant view rights to. The workspace
   selector is located at the top navigation bar.
2. Select Administration > Access Control in the sidebar menu.
3. Select the Cluster Roles tab, and Create Role.
4. Provide a name for the role.
5. Select Cluster Roles, as you provide access to Insights resources across
   clusters.
6. Select + Add Rule in the Rules section.
7. Enter the following information:

Select Rule Type Resources

| Field | Value |
| ----- | ----- |

| Field | Value |
| ----- | ----- |

Resources insights, rca, solutions

Resource Names [Leave this field empty]

API Groups virtual.backend.dkp-insights.d2iq.io

Verbs get 8. Select Save to exit the rule configuration window and Save again
to create the new role. 9. Assign the role you created to a user group as
explained in Configuring Workspace Role Bindings on page 411. 10. If you want
to grant view rights to the alert details for clusters in another Workspace,
repeat the same procedure on a per-workspace basis.

> **Note:**

- It will take a few minutes for the resource to be created.
- insights, rca, solutions are virtual resources and are not listed as a
  Kubernetes API resource.

## Uninstall NKP Insights

Overview of the applications you need to disable for uninstalling NKP Insights.

Nutanix Kubernetes Platform Insights (NKP Insights) consists of two
applications:

- The Insights Management application or nkp-insights-management.
- The Insights Engine application or nkp-insights.

### Disable NKP Insights Engine on Additional Clusters

This procedure applies only to environments where NKP Insights is installed on
additional Managed or Attached clusters. This step prevents duplicate data
collection, reduces unnecessary resource usage, and ensures that insights and
alerts stay centrally managed from the primary NKP Management Cluster.

#### Disabling NKP Insights Engine in a Workspace via the UI

- Disabling NKP Insights Engine in a Workspace via CLI

About this task

Disable the Nutanix Kubernetes Platform Insights (NKP Insights) Engine
application on additional clusters using the UI

Procedure

1. Access the NKP UI.
2. Select the target Workspace from the top menu bar.

| Field | Value |
| ----- | ----- |

1. Select Applications and search for NKP Insights.
2. Select Uninstall from the three-dot menu in the application card.
3. Confirm that you want to uninstall by following the pop-up window.
4. Wait until the application is entirely removed before you continue deleting
   persistent volume claims.
5. Verify that the application has been removed entirely from clusters.

a. Select the target Workspace > Clusters > View Details > Applications tab.

b. Ensure Insights is no longer deployed.

> **Note: The Insights Engine can take several minutes to delete completely.**

#### Disabling NKP Insights Engine in a Workspace via CLI

About this task

Export the environment variable for the target workspace:

Procedure

1. To list all workspaces and their namespaces using the command kubectl get
   workspaces

```bash
export WORKSPACE_NAMESPACE=<target_workspace_namespace>
```

1. Disable the Nutanix Kubernetes Platform Insights (NKP Insights) Engine
   application on all clusters in a workspace by deleting the nkp-insights
   AppDeployment on the management cluster:

```bash
kubectl delete appdeployment -n ${WORKSPACE_NAMESPACE} nkp-insights
```

1. Wait until the HelmRelease is removed from attached clusters:

```bash
kubectl -n ${WORKSPACE_NAMESPACE} wait --for=delete helmrelease/nkp-insights --
timeout=5m
```

> **Note: The Insights Engine can take several minutes to delete completely.**

### Deleting Persistent Volumes formerly used by NKP Insights

About this task

Ensure you delete all remaining data by deleting Insights-related PVs.

Procedure

1. Set the environment variable for an attached or management cluster using
   the command.

```bash
export KUBECONFIG=<attached/management_cluster_kubeconfig>
```

1. Delete the persistent volume using the following command:

```bash
kubectl delete pvc \
data-nkp-insights-postgresql-0 \
-n ${WORKSPACE_NAMESPACE}
```

> **Note:**

- Ensure your configuration references the cluster where the Insights Engine
  is installed. For more information, see the Provide Context for Commands
  with a kubeconfig File topic in the Nutanix Kubernetes Platform Guide.
- Ensure your configuration references the correct ${WORKSPACE_NAMESPACE}.

### Disabling NKP Insights Management

Procedure

1. Disable the Nutanix Kubernetes Platform Insights (NKP Insights) Management
   application on the Management cluster by deleting the nkp-insights-
   management AppDeployment:

```bash
kubectl delete appdeployment -n kommander nkp-insights-management
```

1. Delete insight alert summaries from the management cluster:

```bash
kubectl delete insights --all -A
```

## NKP Insights Bring Your Own Storage (BYOS) to Insights​

By default, NKP Insights uses the Rook Ceph instance installed by NKP, when
bucket creation and access is handled by Ceph COSI driver. This guide shows
how to configure NKP Insights to work with other object store providers. NKP
Insights can be configured to use the following object stores:

- Rook Ceph (via COSI)
- Nutanix Objects (via COSI)
- Manual S3-compatible configuration via secret

### Using Nutanix Objects with NKP Insights via COSI

About this task

To use Nutanix Objects with NKP Insights via COSI, follow these steps:

Procedure

1. Ensure a Nutanix Objects instance is set up and accessible and the COSI
   Driver is configured. For more information, see Configuring and Enabling
   COSI Driver for Nutanix in an NKP Cluster.
2. Enable NKP Insights with the following configuration:

```bash
backend:
s3:
cosi:
className: cosi-nutanix-nkp
accessClassName: cosi-nutanix-nkp
```

With this configuration, the bucket will be created automatically by COSI
controller, and access will be granted to the NKP Insights backend and plugins
to use the new bucket. 3. To use an already existing bucket, set the following
configuration when enabling NKP Insights in the UI:

```bash
backend:
s3:
bucketName: <existing bucket name>
cosi:
className: cosi-nutanix-nkp
accessClassName: cosi-nutanix-nkp
driverName: ntnx.objectstorage.k8s.io
```

### Using Rook Ceph with NKP Insights via COSI

About this task

To use Rook Ceph with NKP Insights via COSI, follow these steps:

Procedure

1. Ensure Rook Ceph Application is enabled. For more information, see Rook
   Ceph in NKP on page 681.
2. Enable NKP Insights with the following configuration:

```bash
backend:
s3:
cosi:
className: cosi-ceph-nkp
accessClassName: cosi-ceph-nkp
```

With this configuration, the bucket will be created automatically by COSI
controller, and access will be granted to the NKP Insights backend and plugins
to use the new bucket. 3. To use an already existing bucket, set the following
configuration when enabling NKP Insights in the UI:

```bash
backend:
s3:
bucketName: <existing bucket name>
cosi:
className: cosi-ceph-nkp
accessClassName: cosi-ceph-nkp
driverName: rook-ceph.ceph.objectstorage.k8s.io
```

### Using an external S3-compatible object storage provider

> **Note: This guide assumes you have an external S3 compatible object store
> that NKP does not manage.**

#### Requirements

```yaml
Important: If you choose to use a third-party, enterprise-grade S3-compatible bucket instead of Nutanix Object
Storage for NKP Insights, do not disable the Nutanix COSI driver unless you have confirmed that it is not being used by
any other applications, such as Harbor. Disabling the COSI driver while it is still in use may lead to service disruptions
or unexpected behavior.
```

If the COSI driver is confirmed to be unused by any application, it is safe to
disable it to reduce resource consumption and simplify the deployment.

The following are required for using Nutanix Kubernetes Platform Insights with
your storage:

- The bucket needs to be manually created, and the following user policies
  need to be enabled:

```bash
s3:DeleteObject
s3:DeleteObjectVersion
s3:GetBucketLocation
s3:GetObject
s3:ListBucket
s3:ListMultipartUploadParts
s3:PutObject
s3:PutLifecycleConfiguration
```

- Additionally, the following conditions have to be met:
- At least 1GB of storage
- TTL is set to a value of "n days" per S3 spec example: 7 Days. Insights will
  set TTL to this value on initialization, which fails if it can not be set.
- It is assumed the storage is hosted in the same cluster with fast networking
  access.
- The bandwidth usage is ~100Mb over the course of a day
- Latency and speed must be `<10 ms and >`1Gbs

#### Create a Secret to support BYOS for NKP Insights

About this task

To create a secret to support BYOS, follow these steps:

You must create a secret with the object store credentials for the bucket
created for Insights.

Procedure

1. Create a secret in the same namespace where you installed NKP Insights

```bash
# Set to the workspace namespace insights is installed in
export WORKSPACE_NAMESPACE=kommander
# Replace with your object store credentials
kubectl create secret generic nkp-insights-objectstore-credentials -n
${WORKSPACE_NAMESPACE} \
--from-literal='AWS_ACCESS_KEY_ID=<Insert Key Here>' \
--from-literal='AWS_SECRET_ACCESS_KEY=<Insert Secret Access Key Here>' \
```

1. In case a custom CA bundle is required to access an object store via HTTPS,
   create a secret with a certificate:

```bash
export WORKSPACE_NAMESPACE=kommander
kubectl create secret -n ${WORKSPACE_NAMESPACE} generic nkp-insights-s3-cert --from-
file=ca.crt=<Path to custom CA certificate>
```

#### Helm Values for Insights Storage

```bash
backend:
s3:
cosi:
enabled: false
port: 443
region: "us-east-1"
endpoint: "<Object Store FQDN or IP>"
bucketName: nkp-insights
disableSSL: false
caSecretName: nkp-insights-s3-cert
skipTLSVerification: false
cleanup:
insightsTTL: "168h"
```

Table 84: Helm Values for Insights Storage

port 80 Port of S3 storage provider.

region us-east-1 AWS Region for S3 storage provider. It may only be needed for
some providers. (Set to a dummy value.)

```bash
endpoint
rook-ceph-rgw-nkp-object-
store
```

Endpoint URL for S3 storage provider. Exclude HTTP://

insightsTTL 168h The time in hours spent maintaining insights data in the
database and S3. For S3, this is rounded up to the nearest day.

bucketName nkp-insights Name of the bucket in the S3 object storage

disableSSL true Force the client to disable SSL

forcePathStyle true Force the request to use path- style addressing

skipTLSVerification false controls whether a client verifies the server's
certificate chain and host name

caSecretName "" Name of the secret storing the custom CA for the S3 object
storage

#### Installing NKP Insights with external object storage using UI

About this task

To install Insights with an external object storage, complete the following
steps:

Procedure

Add the following in the UI:

```bash
backend:
s3:
cosi:
enabled: false
port: 443
region: "us-east-1"
endpoint: "<Object Store FQDN or IP>"
bucketName: nkp-insights
```

| Name | Default Value | Description |
| ---- | ------------- | ----------- |

```yaml
disableSSL: false
caSecretName: nkp-insights-s3-cert
skipTLSVerification: false
cleanup:
insightsTTL: "168h"
```

#### Installing NKP Insights with external object storage using CLI

About this task

To configure external object storage for Insights via the CLI, follow these
steps:

Procedure

1. Create the ConfigMap with the name provided along with the custom
   configuration:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
namespace: ${WORKSPACE_NAMESPACE}
name: nkp-insights-overrides
data:
values.yaml: |
# helm values here
backend:
s3:
cosi:
enabled: false
port: 443
region: "us-east-1"
endpoint: "<Object Store FQDN or IP>"
bucketName: nkp-insights
disableSSL: false
caSecretName: nkp-insights-s3-cert
skipTLSVerification: false
cleanup:
insightsTTL: "168h"
EOF
Note: Kommander waits for the ConfigMap to be present before deploying the AppDeployment to the
managed or attached clusters.
```

1. Provide the name of a ConfigMap in the AppDeployment, which provides a
   custom configuration on top of the default configuration:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: nkp-insights
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
kind: ClusterApp
name: nkp-insights-1.6.8
configOverrides:
name: nkp-insights-overrides
EOF
```

#### Installing NKP Insights in an Air-gapped Environment

About this task

Follow the steps below to configure storage for NKP Insights in air-gapped
environments:

Procedure

In kommander.yaml, enable NKP Insights by setting the following:

```yaml
apiVersion: config.kommander.mesosphere.io/v1alpha1
kind: Installation
apps:
---
nkp-insights-management:
enabled: true
# helm values here (2)
backend:
s3:
port: 80
region: "us-east-1"
endpoint: "rook-ceph-rgw-nkp-object-store"
bucketSize: "1G"
storageClassName: nkp-object-store
enableObjectBucketClaim: true
cleanup:
insightsTTL: "168h"
---
catalog:
repositories:
  - name: insights-catalog-applications
labels:
kommander.nutanix.io/workspace-default-catalog-repository: "true"
kommander.nutanix.io/gitapps-gitrepository-type: "nkp"
path: ./application-repositories/nkp-insights-v2.5.0.tar.gz
```

What to do next

For more information, see the Install Air-gapped Kommander with NKP Insights
in the Nutanix Kubernetes Platform Guide.

## Nutanix Kubernetes Platform Insights Alerts

Nutanix Kubernetes Platform Insights (NKP Insights) alerts help you monitor
anomalies across clusters. Each alert persists for 72 hours unless they are
updated. If the anomaly recurs after expiration, the alert reappears
automatically.

```yaml
Note: A detected NKP Insights alert persists only for 72 hours. If an existing Insight alert is not updated in that period,
it expires and is removed from the table. If the anomaly recurs, the Insight alert reappears in the table.
```

To view and manage the alerts, follow these steps:

1. Log in to the Nutanix Kubernetes Platform (NKP) user interface.

By default, the Dashboard displays both management and managed clusters. 2. In
the top-left corner, from the dropdown list, select your target workspace.

By default, NKP displays Global workspace.

The Insights tab appears only when you select the workspace as Management
Cluster Workspace, or Default Workspace or any customised workspace. 3. From
the left navigation pane, click Insights.

The Insights page displays the most recent insight alerts and the number of
insights for each severity level, such as Critical, Warning, and Notices.

You can filter the NKP Insights alerts as follows:

- In the search box, enter the keywords of the alert description.
- To view the NKP Insights alerts based on their types, from the dropdown
  list, select the following:
- All types
- Availability
- Best Practices
- Configuration
- Security
- To view the NKP Insights alerts based on their severity, click All,
  Critical, Warning, or Notices tab.
- To view by status, click the dropdown list next to Muted.

By default, Open is selected. Muted and Resolved statuses are manually set.

- Select All Clusters or an individual cluster.
- Select All Projects or an individual project.

To clear filters and reset your view to all NKP Insights items, select Clear
All.

### Resolving or Muting Alerts

About this task

```yaml
Warning: When you resolve an alert, it is impossible to move it back to Open or Muted. Ensure you only resolve alerts
only when you fix the issue.
```

Procedure

1. Log in to the Nutanix Kubernetes Platform (NKP) user interface.

By default, the Dashboard displays both management and managed clusters. 2. In
the top-left corner, from the dropdown list, select your target workspace.

By default, NKP displays Global workspace.

The Insights tab appears only when you select the workspace as Management
Cluster Workspace, or Default Workspace or any customised workspace. 3. From
the left navigation pane, click Insights. 4. From the Insight alert table,
filter and check the boxes for the alerts. 5. From the top of the Insight
Alert table, select:

- Resolved if you have resolved the issues or
- Mute if you want to silence the alert

Figure 30: Insights Alerts UI

A confirmation prompt for the status change appears once you resolve or mute
an Insight Alert.

### Viewing Resolved or Muted Alerts

About this task

> **Note: Once you set an alert to Resolved or Muted, it does not appear in
> the Open Insight alert table.**

To view resolved or muted alerts, perform the following steps:

Procedure

1. Log in to the Nutanix Kubernetes Platform (NKP) user interface.

By default, the Dashboard displays both management and managed clusters. 2. In
the top-left corner, from the dropdown list, select your target workspace.

By default, NKP displays Global workspace.

The Insights tab appears only when you select the workspace as Management
Cluster Workspace, or Default Workspace or any customised workspace. 3. From
the left navigation pane, click Insights. 4. From the Insights alert field,
select the desired filter from the drop-down list.

Figure 31: Insights Alerts Filter List

### Insight Alert Usage Tips

For an Insight Alert you do not want to use, check the box corresponding to
that alert and select Mute. This only silences the individual Insight Alert.
The Insight remains muted if the anomaly recurs, but the Last Detected
timestamp and description can be updated.

### NKP Insight Alert Details

From the NKP Insight Alert table, select the Details link to view additional
information.

Apart from the contents of an insight alert summary, the Details page contains
two more sections:

- Root Cause Analysis, which contains additional information you may need to
  understand the cause of the anomaly.
- Solutions, which contains recommended steps to resolve the anomaly.

### NKP Insights Alert Notifications With Alertmanager

NKP Insights supports the configuration of Kube Prometheus Stack's
Alertmanager to send alert notifications to environment administrators and
users through Slack and Microsoft Teams.

```yaml
Note: You can configure NKP Insights to send notifications to other communication platforms like PagerDuty or e-
mail. However, we have only included examples for Slack and Microsoft Teams.
```

Table 85: Common Questions about Kube Prometheus Stack's Alertmanager

Why Should I Send Notifications for NKP Insights Alerts?

Activating this feature eliminates the need to check your cluster's health
manually. NKP Insights, combined with Alertmanager, can automatically warn
users about critical issues. They can then take measures to keep your
environment healthy and avoid possible downtime.

How Do NKP Insights and Alertmanager Work Together?

Alertmanager acts as a central component for managing and routing alerts. It
is available by default in your NKP installation and automatically monitors
several NKP-defined alerts.

By enabling NKP Insights to route alerts to Alertmanager, you add another
source of alerting. In the examples provided in this section, you use an
AlertmanagerConfig YAML file to enable Alertmanager to group and filter NKP
Insights alerts according to rules and send notifications to a communication
platform.

```yaml
Note: You add new configurations by applying the
#AlertmanagerConfig# example files referenced in this section. Existing
default or custom Alertmanager configurations remain unaffected.
```

What Type of Configuration Options Are Possible?

In the AlertmanagerConfig object, you can define the following parameters:

```yaml
Routes: Routes define which alert types generate notifications and
which do not. In the provided examples, we configure Alertmanager to
send notifications for all Critical and Warning NKP Insights based on
Severity.
Receivers: Receivers define the communication platform where you want
to receive the notifications. The provided examples show how to configure
notifications for Slack and Microsoft Teams.
```

Message content and format: The receiver configuration also defines the
display format for the alert message. The examples provide message formatting
designed for Slack and Microsoft Teams. The provided notification examples
display all the informational fields you can find when looking at an alert in
the NKP UI.

```yaml
Note: You can customize the AlertmanagerConfig YAML
file to include other routes, receivers, or a different message
formatting. However, this requires advanced knowledge of
AlertmanagerConfig specifications and Helm and Golang
templating rules.
```

How Do I Enable and Configure Alertmanager?

For more information, see:

- Slack: Send NKP Insights Alert Notifications to a Channel topics at Slack:
  Send Nutanix Kubernetes Platform Insights Alert Notification to a Channel.
- For configuration templates, see the Microsoft Teams: Send NKP Insights
  Alert Notifications to a Channel topic at Teams: Send Nutanix Kubernetes
  Platform Insights Alert Notification to a Channel

#### Slack®: Send Nutanix Kubernetes Platform Insights Alert Notifications to

a Channel

This page contains information on setting up a configuration for Alertmanager
to send alert notifications through Slack®. See NKP Insights Alert
Notifications With Alertmanager on page 1128 for more information about this
function.

```yaml
Important: Slack® is a trademark and service mark of Slack Technologies, Inc., registered in the U.S. and in other
countries.
```

##### Prerequisites (2)

- Kube Prometheus Stack installed on the Management cluster (included in the
  default configuration)
- A Slack® Incoming Webhook created by a Slack workspace admin. For more
  information, see https:// api.slack.com/messaging/webhooks#create_a_webhook.
- Nutanix Kubernetes Platform Insights installed. For more information, see
  Nutanix Kubernetes Platform Insights Setup on page 1112.

##### Preparing your Environment

About this task

Complete the following steps to prepare your environment:

Procedure

1. Set your environment variable to the kommander workspace namespace:

```bash
export WORKSPACE_NAMESPACE=kommander
```

1. Set the Slack® Webhook variable to the URL you obtained from Slack® for
   this purpose: The webhook format is similar to
   `<https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK>`.

```bash
export SLACK_WEBHOOK=<endpoint_URL>
```

##### Enable NKP Insights to Send Notifications with Alertmanager

About this task

Create an AlertmanagerConfig object and apply it on the kommander workspace
namespace.

Procedure

1. Create a secret for the Alertmanager-Slack integration:

```bash
kubectl create secret generic slack-webhook -n ${WORKSPACE_NAMESPACE} \
--from-literal=slack-webhook-url=${SLACK_WEBHOOK} \
--dry-run=client --save-config -o yaml | kubectl apply -f -
```

1. Create the AlertmanagerConfig YAML file and name it alertmanager-slack-
   config.yaml.

This example allows Alertmanager to send notifications for all Critical
Insights of all alert types that occur in any workspace to Slack.

```yaml
Warning: Replace <#target_slack_channel> with the name of the Slack® channel where you want to
receive the notifications.
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
name: slack-config
namespace: kommander
spec:
route:
groupBy: ['source', 'insightClass', 'severity', 'cluster']
groupWait: 3m
groupInterval: 15m
repeatInterval: 1h
receiver: 'slack'
routes:
- receiver: 'slack'
matchers:
- name: source
value: Insights
matchType: =
- name: severity
value: Critical
matchType: =
continue: true
receivers:
- name: 'slack'
slackConfigs:
- apiURL:
name: slack-webhook
key: slack-webhook-url
channel: '#<target_slack_channel>'
username: Insights Slack Notifier
iconURL: https://avatars3.githubusercontent.com/u/3380462
title: |-
{{ .Status | toUpper -}}{{ if eq .Status "firing" }}: {{ .Alerts.Firing
| len }} {{- end}} Insights Alert{{ if gt (len .Alerts.Firing) 1 }}s{{ end }}
({{ .CommonLabels.insightClass }})
titleLink: 'https://{{ (index .Alerts 0).Annotations.detailsURL }}'
text: |-
{{- if (index .Alerts 0).Labels.namespace }}
{{- "\n" -}}
*Namespace:* `{{ (index .Alerts 0).Labels.namespace }}`
{{- end }}
{{- if (index .Alerts 0).Labels.severity }}
{{- "\n" -}}
*Severity:* `{{ (index .Alerts 0).Labels.severity }}`
{{- end }}
{{- if (index .Alerts 0).Labels.cluster }}
{{- "\n" -}}
*Cluster:* `{{ (index .Alerts 0).Labels.cluster }}`
{{- end }}
{{- if (index .Alerts 0).Annotations.description }}
{{- "\n" -}}
*Description:* {{ (index .Alerts 0).Annotations.description }}
{{- end }}
{{- if (index .Alerts 0).Annotations.categories }}
{{- "\n" -}}
*Categories:* {{ (index .Alerts 0).Annotations.categories }}
{{- end }}
actions:
- text: 'Go to Insight :mag:'
type: button
url: 'https://{{ (index .Alerts 0).Annotations.detailsURL }}'
```

1. Apply the AlertmanagerConfig file:

```bash
kubectl -n ${WORKSPACE_NAMESPACE} apply -f alertmanager-slack-config.yaml
```

#### Microsoft Teams®: Send NKP Insights Alert Notifications to a Channel

This page contains information on setting up a configuration for Alertmanager
to send alert notifications through Microsoft Teams®. See NKP Insights Alert
Notifications With Alertmanager on page 1128 for more information about this
function.

##### Prerequisites (3)

- Kube Prometheus Stack installed on the Management cluster (included in the
  default configuration)
- A Microsoft Teams® Incoming Webhook. For more information, see
  `<https://learn.microsoft.com/en-us/>` microsoftteams/platform/webhooks-and-
  connectors/how-to/add-incoming-webhook?tabs=newteams %2Cdotnet.
- Nutanix Kubernetes Platform Insights installed. For more information, see
  Nutanix Kubernetes Platform Insights Setup on page 1112.

##### Preparing your Environment (2)

About this task

Complete the following steps to prepare your environment:

Procedure

1. Set your environment variable to the kommander workspace namespace.

```bash
export WORKSPACE_NAMESPACE=kommander
```

1. Set the Microsoft Teams Webhook variable to the URL you obtained from
   Microsoft Teams® for this purpose: The webhook format is similar to:
   `<https://xxxx.webhook.office.com/xxxxxxxxx>`.

```bash
export TEAMS_WEBHOOK=<endpoint_URL>
```

##### Enabling NKP Insights to Send Notifications with Alertmanager

About this task

About this task

Install an extension for Kube Prometheus Stack that adds compatibility with
Microsoft Teams®. Then, create an

AlertmanagerConfig object and apply it to the kommander workspace namespace.

Procedure

1. Add the following repository to enable Microsoft Teams® configuration:

```bash
helm repo add prometheus-msteams https://prometheus-msteams.github.io/prometheus-
msteams/
```

1. Create a custom configuration of Kube Prometheus Stack, and name it teams-
   proxy-config.yaml Replace `<teams_webhook_URL>` with the webhook you
   obtained from Microsoft Teams®. The format is similar to
   `<https://xxxxx.webhook.office.com/xxxxxxxxx>`.

```yaml
replicaCount: 1
image:
repository: quay.io/prometheusmsteams/prometheus-msteams
tag: v1.5.1
connectors:
  - alertmanager: <teams_webhook_URL>
container:
additionalArgs:
  - -debug
metrics:
serviceMonitor:
enabled: true
additionalLabels:
release: kube-prometheus-stack-prometheus
scrapeInterval: 30s
```

1. Create a custom display format for your message in Microsoft Teams®
   message, and name the file custom-

card.tmpl:

```bash
{{ define "teams.card" }}
{
"@type": "MessageCard",
"@context": "http://schema.org/extensions",
"themeColor": "{{- if eq .Status "resolved" -}}2DC72D
{{- else if eq .Status "Firing" -}}
{{- if eq .CommonLabels.severity "Critical" -}}8C1A1A
{{- else if eq .CommonLabels.severity "Warning" -}}FFA500
{{- else -}}808080{{- end -}}
{{- else -}}808080{{- end -}}",
"summary": "{{- if eq .CommonAnnotations.description "" -}}
{{- if eq .CommonLabels.insightClass "" -}}
{{- if eq .CommonLabels.alertname "" -}}
Prometheus Alert
{{- else -}}
{{- .CommonLabels.alertname -}}
{{- end -}}
{{- else -}}
{{- .CommonLabels.insightClass -}}
{{- end -}}
{{- else -}}
{{- .CommonAnnotations.description -}}
{{- end -}}",
"title": "{{ .Status | toUpper -}}{{ if eq .Status "firing" }}: {{ .Alerts.Firing
| len }} {{- end}} Insights Alert{{ if gt (len .Alerts.Firing) 1 }}s{{ end }}
({{ .CommonLabels.insightClass }})",
"sections": [ {{$externalUrl := (index .Alerts 0).Annotations.detailsURL }}
{
"activityTitle": "[{{ (index .Alerts 0).Annotations.description }}]
({{ $externalUrl }})",
"facts": [
{{- if (index .Alerts 0).Labels.namespace }}
{
"name": "Namespace:",
"value": "{{ (index .Alerts 0).Labels.namespace }}"
},
{{- end }}
{{- if (index .Alerts 0).Labels.severity }}
{
"name": "Severity:",
"value": "{{ (index .Alerts 0).Labels.severity }}"
},
{{- end }}
{{- if (index .Alerts 0).Labels.cluster }}
{
"name": "Cluster:",
"value": "{{ (index .Alerts 0).Labels.cluster }}"
},
{{- end }}
{{- if (index .Alerts 0).Annotations.categories }}
{
"name": "Categories:",
"value": "{{ (index .Alerts 0).Annotations.categories }}"
}
{{- end }}
],
"markdown": true
}
]
}
{{ end }}
```

1. Upgrade the Helm values to apply the configuration in Step 4.

```bash
helm upgrade --install prometheus-msteams \
--namespace ${WORKSPACE_NAMESPACE} -f teams-proxy-config.yaml \
--set-file customCardTemplate=custom-card.tmpl \
prometheus-msteams/prometheus-msteams
```

1. Create the AlertmanagerConfig YAML file and name it alertmanager-teams-
   config.yaml.

This example allows Alertmanager to send notifications for all Critical alerts
of all alert types that occur in any workspace to Microsoft Teams®.

```yaml
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
name: alertmanager-teams-config.yaml
namespace: kommander
spec:
route:
groupBy: ['source', 'insightClass', 'severity', 'cluster']
groupWait: 3m
groupInterval: 15m
repeatInterval: 1h
receiver: 'default'
routes:
- receiver: 'teams'
matchers:
- name: source
value: Insights
matchType: =
- name: severity
value: Critical
matchType: =
continue: true
receivers:
- name: 'default'
- name: 'teams'
webhookConfigs:
- url: 'http://prometheus-msteams:2000/alertmanager'
```

1. Apply the AlertmanagerConfig file:

```bash
kubectl -n ${WORKSPACE_NAMESPACE} apply -f alertmanager-teams-config.yaml
```

#### Verifying that Alertmanager Sends Notifications

This section consists of the following topics :

- Prerequisites to enable an Alertmanager configuration for Slack® or
  Microsoft Teams®.
- Steps for Sending a TestAlert
- Troubleshooting steps for Verifying Alertmanager Notification

##### Prerequisite

This setup supports Alertmanager to forward alerts directly to the selected
collaboration platform. Having this configuration in place ensures that
notifications are delivered correctly, supports faster incident response, and
provides visibility into cluster health and operational issues.

You have enabled an Alertmanager configuration for Slack® or Microsoft Teams®:

- Slack®: Send Nutanix Kubernetes Platform Insights Alert Notifications to a
  Channel on page 1129
- Microsoft Teams®: Send NKP Insights Alert Notifications to a Channel on page
  1131

##### Sending a Test Alert

About this task

Trigger a mock Nutanix Kubernetes Platform Insights alert to confirm the
successful configuration.

Procedure

1. Open a local port for the Alertmanager mock alert:

```bash
kubectl -n kommander port-forward svc/kube-prometheus-stack-alertmanager 8083:9093
```

1. In another terminal session, send a mock alert to the open port:

```bash
curl -L 'http://localhost:8083/api/v2/alerts' \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \
-d \
'[{
"labels":
{
"alertname": "Test Insight Alert",
"namespace": "kommander",
"status": "Open",
"source": "Insights",
"severity": "Critical",
"cluster": "Kommander Host (Test)"
},
"annotations":
{
"description": "This is a mock Insight for testing",
"generatorURL": "https://test-endpoint.com",
"categories": "Best-Practices, Configuration"
}
}]'
```

This sends a Critical mock Insights alert to Alertmanager, which triggers
sending a notification to the configured communication platform.

##### Troubleshooting

This section describes how to check the Alertmanager dashboard for
notification status and how to review the Alertmanager log files for detailed
error information. Following these steps helps ensure that Alertmanager
operates properly and delivers alerts without delay or interruption.

###### Verifying the Alertmanager Dashboard

###### Verifying the Alertmanager Log Files

###### Verifying the Alertmanager Dashboard (2)

About this task

Verify if Nutanix Kubernetes Platform Insights (NKP Insights) alerts are
displayed in the Alertmanager Dashboard.

If you can see NKP Insights alerts present, the NKP Insights-Alertmanager
route is configured successfully.

```yaml
Note: You can recognize NKP Insights alerts from other default NKP alerts because the alert severity tags are
capitalized. For example, an NKP Insights alert is Critical, whereas other non-Insights alerts are critical.
```

Procedure

1. Access the NKP UI.
2. Select Management Cluster Workspace.
3. Select Application Dashboards, and look for the Prometheus Alert Manager
   application card.
4. Select Dashboard to open the Alertmanager console.

###### Verifying the Alertmanager Log Files (2)

About this task

If Slack® does not display any Alert messages, but you can see NKP Insights
alerts in the Alertmanager console, perform the following task:

Procedure

Verify the deployment logs using the command.

```bash
kubectl -n kommander logs alertmanager-kube-prometheus-stack-alertmanager-0
```

If the output is blank, the configuration has been successful. The output
displays errors if the deployment has failed.

### Enable NKP-Related Insights Alerts

#### Troubleshooting (2)

However, to ensure compliance with CVE databases or monitor NKP resources and
your workload resources, you can allow NKP Insights to analyze and create
alerts for underlying NKP resources and Kubernetes components.

You can do so by enabling customization of NKP Insights per workspace.

```yaml
Note: NKP Insights displays alerts related to DiskFull and PVCFull, regardless of whether they are rooted in your
environment's underlying NKP resources, Kubernetes resources, or one of your production workloads. Ensure you have
allocated sufficient disk capacity and have assigned adequate storage in your PVC objects to allow your environment to
run uninterruptedly and ensure no data is lost.
```

#### Navigating to your NKP Insights Configuration Service

About this task

To customize an Nutanix Kubernetes Platform Insights (NKP Insights)
Installation on a per-workspace basis:

Procedure

1. Log in to your NKP UI.
2. Select the target workspace from the top navigation bar.
3. Select Applications from the sidebar and search for NKP Insights.
4. Select the three-dot menu in the application card, and Edit > Configuration.

#### Adding a Custom Configuration to Receive NKP Alerts

About this task

To enable NKP-related Insight alerts, complete the following task:

Procedure

1. Copy the following customization and paste it into the code editor:

```bash
backend:
engineConfig:
nkpIdentification:
enabled: false
```

1. Select Save and exit.
2. Repeat the configuration steps included in this page for each workspace.

#### Making NKP Insights Treat Components of a Non-default Kommander

Application as Part of NKP

About this task

Properties of a generated Insight Alert, such as the description, severity,
and content of the Details page, depend on whether NKP Insights treats the
affected Kubernetes resource as an NKP component.

Typically, Insights identifies instances of Platform and Default Ultimate
Catalog Applications using default
AppDeployment names as parts of NKP and treats Kubernetes resources that
belong to this application as NKP components.
(A default AppDeployment name is the one that coincides with an App ID of an
App/ClusterApp; for example, a default
AppDeployment name of a ClusterApp named "kube-prometheus-stack-0.46.8" is
"kube- prometheus-stack."). For more
information, see Platform Applications on page 350.

To make NKP Insights treat as part of NKP an AppDeployment with a name that is
not present among the default names, Add an identification rule to
configuration overrides of the NKP Insights application that runs in the
workspace of that AppDeployment.

Procedure

Replace APPDEPLOYMENT_NAME value in the nameRegexp field with the name of the
AppDeployment.

The following example shows a configuration override that assumes you don't
have other configuration overrides set for
the NKP Insights app. The rule named Kustomization-custom-app-
APPDEPLOYMENT_NAME instructs NKP Insights running on
clusters in this workspace to treat any Kubernetes resources directly or
indirectly owned by a Flux Kustomization named
APPDEPLOYMENT_NAME on an attached cluster as components of an NKP application,
and adjust properties and content of
generated Insight Alerts accordingly.

```bash
backend:
engineConfig:
nkpIdentification:
appRoots:
Kustomization-custom-app-APPDEPLOYMENT_NAME:
groupKind:
group: kustomize.toolkit.fluxcd.io
kind: Kustomization
nameRegexp: APPDEPLOYMENT_NAME
```

### Configuration Anomalies

#### Polaris

Polaris by Fairwinds is an open-source project that identifies Kubernetes
deployment configuration errors. Polaris runs over a dozen checks to help
users discover Kubernetes misconfigurations that frequently cause security
vulnerabilities, outages, scaling limitations, and more. Using Polaris, you
can avoid problems and ensure you're using Kubernetes best practices.

Polaris checks configurations against a set of best practices for workloads
and Kubernetes cluster deployments, such as:

- Health Checks
- Images
- Networking
- Resources
- Security

It informs you about potential problems in configurations through insight
alerts.

To see which Polaris version is included in this release, see Nutanix
Kubernetes Platform Insights (NKP Insights) Release Notes on the Nutanix
Support Portal.

##### Enabling or Disabling Polaris Insights

About this task

To enable or disable Polaris insights, complete the following task:

Procedure

1. Edit the Service configuration with the following values:

```bash
polaris:
enabled: true
```

1. To modify an installation, select Workspace > Applications > NKP-Insights >
   Edit.

##### Changing the Frequency of Polaris Audit Scans

About this task

To change the default scan frequency, perform the following task:

Procedure

1. Polaris Audits run by default every 37 minutes and use Cron syntax. You can
   change the default by editing the Service configuration with the following
   values:

```bash
polaris:
schedule: "@every 37m"
Note: For more information on Cron syntax, see https://kubernetes.io/docs/concepts/workloads/
controllers/cron-jobs/#cron-schedule-syntax.
```

1. To modify an installation, select Workspace > Applications > NKP-Insights >
   Edit.

##### Modifying Severities of Polaris Insights

About this task

Polaris Audit specifies a default severity for each of these types:

- Security:`<https://polaris.docs.fairwinds.com/checks/security/>`
- Efficiency: `<https://polaris.docs.fairwinds.com/checks/efficiency/>`
- Reliability: `<https://polaris.docs.fairwinds.com/checks/reliability/>`

Procedure

1. You can change these defaults by modifying the Service configuration with
   the following values:

```bash
polaris:
config:
# See https://github.com/FairwindsOps/polaris/blob/master/examples/config.yaml
checks:
# reliability
deploymentMissingReplicas: warning
priorityClassNotSet: ignore
tagNotSpecified: danger
pullPolicyNotAlways: warning
readinessProbeMissing: warning
livenessProbeMissing: warning
metadataAndNameMismatched: ignore
pdbDisruptionsIsZero: warning
missingPodDisruptionBudget: ignore
# efficiency
cpuRequestsMissing: warning
cpuLimitsMissing: warning
memoryRequestsMissing: warning
memoryLimitsMissing: warning
# security
hostIPCSet: danger
hostPIDSet: danger
notReadOnlyRootFilesystem: warning
privilegeEscalationAllowed: danger
runAsRootAllowed: danger
runAsPrivileged: danger
dangerousCapabilities: danger
insecureCapabilities: warning
hostNetworkSet: danger
hostPortSet: warning
tlsSettingsMissing: warning
```

1. To modify an installation, select Workspace > Applications > NKP-Insights >
   Edit.

```yaml
Note: When you mark a Polaris Audit Insight alert as Not-Useful, newly generated alerts are set to the lowest
Notice severity.
```

##### Adding Exemptions to Polaris Insights

About this task

You can exclude a particular workload from a Polaris Audit via its Exemptions.
This example shows how to exempt the workload dummy-deployment, which
currently has an issue where CPU Limits are Missing.

Procedure

1. Change the exceptions list by modifying the Service configuration with the
   following values:

```bash
polaris:
config:
exemptions:
- controllerNames:
- dummy-deployment
rules:
- cpuLimitsMissing
```

1. To modify an installation, select Workspace > Applications > NKP-Insights >
   Edit.

#### Pluto

Pluto by Fairwinds is a tool that scans Live Helm releases running in your
cluster for deprecated Kubernetes API versions. It sends an alert about
deprecated apiVersions deployed in your Helm releases.

In Nutanix Kubernetes Platform Insights (NKP Insights), Pluto scans Live Helm
releases running in your cluster for deprecated API versions and sends an
alert about any deprecated apiVersions deployed in your Helm releases.

To know which Pluto version is included in this release, see NKP Insights
Release Notes on the Nutanix Support Portal.

For more information on Pluto, see `<https://pluto.docs.fairwinds.com/>`.

##### Enabling or Disabling Pluto Insights

Procedure

1. Enable or disable Helm release scanning with Pluto Insights by editing the
   Service configuration with the following values:

```bash
pluto:
enabled: true
```

1. To modify an installation, select Workspace > Applications > NKP-Insights >
   Edit.

##### Changing the Frequency of Pluto Scans

About this task

To change the default scan frequency, perform the following task:

Procedure

1. Pluto scans run by default every 41 minutes and uses Cron syntax. You can
   change the default by editing the values of the Service configuration:

```bash
pluto:
schedule: "@every 41m"
```

1. To modify an installation, select Workspace > Applications > NKP-Insights >
   Edit.

##### Severities of Pluto Insights

Table 86: Pluto Alert Severities

Deprecated Warning Kubernetes API is scheduled to be removed in a future
version of Kubernetes.

Removed Critical Kubernetes API has been removed in the current running
version of Kubernetes.

For more information, see Pluto's official documentation at
`<https://pluto.docs.fairwinds.com/>` information.

#### Nova

Nova by Fairwinds adds the ability for the Insights engine to check the helm
chart version of the current workload deployment. It scans the latest helm
chart version available from the configured Helm repositories and then sends a
structural Insight alert if there is an issue. The alert details show an RCA
and a solution to resolve the problem.

To know which Nova version is included in this release, see Nutanix Kubernetes
Platform Insights (NKP Insights) Release Notes on the Nutanix Support Portal.

For more information on Nova, see `<https://nova.docs.fairwinds.com/>`.

| Pluto Result | Insights Alert Level | Meaning |
| ------------ | -------------------- | ------- |

##### Enabling or Disabling Nova Insight

About this task

Edit the Service configuration:

Procedure

1. Set the nova.enabled value to true
2. Set the helmRepositoryURLs to the URLs for the Helm repositories used by
   your workloads where you want Helm chart versions to be scanned.

```bash
nova:
enabled: true
helmRepositoryURLs:
- https://charts.bitnami.com/bitnami/
- https://charts.jetstack.io
```

1. To modify an installation, select Workspace > Applications > NKP-Insights >
   Edit.

##### Changing the Frequency of Nova Scans

About this task

To change the default scan frequency, perform the following task:

Procedure

1. Nova runs every 37 minutes by default and uses the Cron syntax. You can
   change the default by editing the Service configuration with the following
   values:

```bash
nova:
schedule: "@every 34m"
```

1. To modify an installation, select Workspace > Applications > NKP-Insights >
   Edit.

#### Trivy

```yaml
Warning: The Trivy function is disabled in the default configuration of Nutanix Kubernetes Platform Insights (NKP
Insights). You must enable it in the service configuration to utilise the functionality of Trivy.
```

Trivy is an open-source vulnerability and misconfiguration scanner that
detects vulnerabilities in:

- Container images
- Rootfs
- Filesystems

The current and later versions of NKP Insights support the CVE scanning
functionality for customer-deployed managed clusters and deployments.

CVE or CIS databases are updated every couple of hours. When enabled, the CVE
scanning feature scans these databases and runs an analysis against your
workloads to flag any potential security issues.

To know which Trivy version is included in this release, see NKP Insights
Release Notes on the Nutanix Support Portal.

For more information on Trivy, see
`<https://aquasecurity.github.io/trivy/v0.44/docs/scanner/vulnerability/>`.

##### Enabling or Disabling Trivy Insights

About this task

Enable or disable CVE scanning with Trivy Insights by completing this task.

Procedure

1. Edit the Service configuration with the following values:

```bash
trivy:
enabled: true
```

1. To modify an installation, select Workspace > Applications > NKP-Insights >
   Edit.

##### Changing the Frequency of Trivy CVE Scans

About this task

To change the default scan frequency, perform the following task:

Procedure

1. Trivy scans run by default every 2 hours and uses Cron syntax. You can
   change the default by editing the values of the Service configuration:

```bash
trivy:
schedule: "@every 2h"
```

1. To modify an installation, select Workspace > Applications > NKP-Insights >
   Edit.

##### Severities of Trivy Insights

Table 87: Trivy Alert Severities

CRITICAL Critical Denial of crucial service

HIGH

MEDIUM

Warning Exposure of information to an unauthorized user

LOW

UNKNOWN

Notice Insufficient validation

##### Trivy Database Update in Air-Gapped and Non-Air-Gapped Environments

All Trivy versions include databases that are updated regularly.

In non-air-gapped environments, NKP Insights automatically updates the Trivy
database before each scheduled run (every two hours, by default) to support
the latest security updates.

In air-gapped environments, NKP Insights uses the Trivy database bundled with
the NKP release, but you can manually update this database as required.

- Trivy Severity Level; Insights Alert Level; Example (depends on the
  categorization of the source database)

| --- | --- | --- |

This section shows you how to update the Trivy databases manually in your air-
gapped environments.

###### Prerequisites for Trivy Database

Following are the prerequisites for updating the Trivy database in both air-
gapped and non-air-gapped environments. Reviewing these prerequisites ensures
that the update process runs smoothly and completes without errors.

- For installing Git, see Getting Started - Installing Git.
- For installing Docker, see Install Docker Engine.
- If you want to enable or disable Trivy, see Enabling or Disabling Trivy
  Insights on page 1143.

###### Verifying the Trivy Version

About this task

Procedure

Obtain the currently used Trivy version:

```bash
kubectl get cronjob -n <workspace_namespace> nkp-insights-trivy -o
jsonpath='{.spec.jobTemplate.spec.template.spec.initContainers[?
(@.name=="trivy")].image}' | cut -d ":" -f 2
```

The output displays the Trivy version, followed by the database timestamp.

In the example output, the Trivy version is 0.42.1 , and the database
timestamp is 20230816T060333Z.

```bash
0.42.1-20230816T060333Z
```

###### Creating a Bundle with the New Trivy Database

About this task

Create an air-gapped Trivy bundle from the trivy-bundles public repository.
For more information about trivy- bundles, see
`<https://github.com/mesosphere/trivy-bundles>`.

Starting on an internet-connected machine:

Procedure

1. Clone the NKP Insights - Trivy Bundles repository to your local machine
   using the command git clone

```bash
https://github.com/mesosphere/trivy-bundles.git
```

1. Specify the Trivy Version included in this version of NKP Insights using
   the command.
2. Build the air-gapped bundle using the command.

```bash
make create-airgapped-image-bundle
```

In this example output, the bundle is called trivy-
bundles-0.42.1-20230908T185308Z.tar.gz.

```bash
Executing target: install-mindthegap
Executing target: latest_image_tag
```

| export TRIVY VERSION= \_ | `<trivy-version>` | Col3 |
| ------------------------ | ----------------- | ---- |

```bash
[+] Building 7.3s (10/10) FINISHED

docker:default
=> [internal] load build definition from Dockerfile

0.0s
=> => transferring dockerfile: 534B

0.0s
=> [internal] load .dockerignore

0.0s
=> => transferring context: 2B

0.0s
=> [internal] load metadata for docker.io/aquasec/trivy:0.42.1

0.3s
=> [1/7] FROM docker.io/aquasec/
trivy:0.42.1@sha256:49a0b08589b7577f3e21a7d479284c69dc4d27cbb86bd07ad36773f075581313

0.0s
=> CACHED [2/7] RUN mkdir /trivy_cache

0.0s
=> CACHED [3/7] RUN chown 65532:65532 /trivy_cache

0.0s
=> [4/7] RUN echo 20230908T185308Z

0.3s
=> [5/7] RUN trivy image --download-db-only --cache-dir /trivy_cache

4.5s
=> [6/7] RUN ls -Rl /trivy_cache

0.3s
=> exporting to image

1.8s
=> => exporting layers

1.8s
=> => writing image
sha256:62f71725212e5b680a3cef771bcb312e931e05445c50632fa4495e216793c9cf

0.0s
=> => naming to docker.io/mesosphere/trivy-bundles:0.42.1-20230908T185308Z

0.0s
Executing target: create-airgapped-image-bundle

# Checking if output file already exists
# Parsing image bundle config
# Creating temporary directory
# Starting temporary Docker registry
# Pulling requested images [====================================>1/1] (time elapsed
23s)
# Archiving images to trivy-bundles-0.42.1-20230908T185308Z.tar.gz
```

1. Transfer the created bundle to the air-gapped bastion host or node you used
   to install NKP.

###### Uploading the Bundle to your Air-Gapped Environment

About this task

The air-gapped bundle can now be uploaded to the private registry.

Procedure

1. Go to the air-gapped bastion host or node you used for installing NKP.
2. Export the environment variables for your registry. For more information,
   see the Local Registry.

```bash
export REGISTRY_ADDRESS=<registry-address>:<registry-port>
export REGISTRY_USERNAME=<username>
export REGISTRY_PASSWORD=<password>
```

1. Run the following command to load the air-gapped Trivy bundle into your
   private registry:

```bash
nkp push bundle --bundle <trivy-bundle-name.tar.gz> --to-registry $REGISTRY_ADDRESS
--to-registry-username $REGISTRY_USERNAME --to-registry-password $REGISTRY_PASSWORD
```

Replace `<trivy-bundle-name.tar.gz>` with the name of the bundle you created
in the previous section. 4. Update NKP Insights in the air-gapped environment
to use the refreshed database. Edit the service configuration on each
workspace by providing the path to the Docker image.

To modify an existing installation, select Workspace, Applications, NKP-
Insights, and then Edit. Replace `<docker-image-name>` with the path to the
Docker image. It looks similar to docker.io/ mesosphere/trivy-
bundles:0.42.1-20230908T185308Z

```bash
trivy:
enabled: true
image:
imageFull: <docker-image-path>
```

###### Verify the Database

This section explains how to verify the Trivy database after Insights
completes deployment.

You check the Trivy database version in Verifying the Trivy Version on page
1144 to confirm that the configuration deploys correctly. Verifying the
database ensures that updates apply successfully, vulnerability definitions
remain current, and the system performs accurate and reliable security
scanning.

#### Kube-bench

Whenever a security standard is not met during a scan, an Insights alert is
created with comprehensive information.

For more information on Kube-bench, see
`<https://www.aquasec.com/products/kubernetes-security/>` and https://
aquasecurity.github.io/kube-bench/v0.6.12/. For more information on the Center
for Internet Security, see https:// `<www.cisecurity.org/>`.

##### Enabling or Disabling Kube-bench

About this task

Kube-bench is enabled by default, but you can disable it anytime.

Procedure

1. Edit the Service configuration with the following values:

```bash
kubeBench:
enabled: true
```

1. To modify an installation, select Workspace > Applications > NKP-Insights >
   Edit.

##### Changing the frequency of Kube-bench Scans

About this task

To change the default scan frequency, perform the following task:

Procedure

1. Kube-bench scans run by default every 35 minutes and uses Cron syntax. You
   can change the default by editing the Service configuration with the
   following values:

```bash
kubeBench:
schedule: "@every 35m"
Note: For more information on Cron syntax, see https://kubernetes.io/docs/concepts/workloads/
controllers/cron-jobs/#cron-schedule-syntax.
```

1. To modify an installation, select Workspace > Applications > NKP-Insights >
   Edit.

##### Changing CIS Benchmark Version

About this task

By default, Kube-bench attempts to auto-detect the running version of
Kubernetes and map this to the corresponding CIS Benchmark version. For
example, Kubernetes version 1.15 is mapped to CIS Benchmark version cis-1.15 ,
the benchmark version valid for Kubernetes 1.15. For an existing or a new
configuration instance,

Procedure

1. You can change this default behavior and define a CIS benchmark version to
   check against, editing the service configuration with the following values:
   The example configuration configures Kube-bench to check against the
   cis-1.15 regardless of the Kubernetes version.

```bash
kubeBench:
config:
instances:
defaultSetup:
additionalArgs: ["--version", "cis-1.15"]
```

1. To modify an installation, select Workspace > Applications > NKP-Insights >
   Edit.

##### Severity Levels

Kube-bench validation runs only have three possible outcomes:

- If the validation runs correctly and does not detect any anomalies, no
  Insight is created.
- If the validation runs and fails due to a detected anomaly, an Insight is
  created with the alert level Warning.
- If the validation check cannot run or is incomplete, an Insight is created
  with the alert level Warning.

##### Known Issues and Mitigations

kube-bench analyses security-related aspects of your cluster and creates
alerts when your Kubernetes cluster is not compliant with the best practices
established in the CIS benchmark.

Some issue alerts relate to cluster elements created with Konvoy, NKP's
provisioning tool.

For customers who require CIS Benchmark compliance, this page provides an
overview of how to mitigate these known alerts, or provide an explanation of
why it is not feasible to address the issue.

- For issues that can be mitigated, create patch files with the mitigations,
  then create a cluster kustomization that references these patch files, and,
  lastly, create a new cluster based on the kustomization file as shown in
  Mitigate Issues by Creating Custom Clusters on page 1148.
- For issues that cannot be mitigated, see the List of CIS Benchmark
  Explanations on page 1157.

###### Mitigate Issues by Creating Custom Clusters

For issues that can be mitigated, create patch files with the mitigations,
then create a cluster kustomization that references these patch files, and,
lastly, create a new cluster based on the kustomization file

###### Creating Patch Files with CIS Benchmark Mitigations

About this task

> **Note: All files you create in this and the following sections must be
> present in the same directory.**
>
> **Warning: You cannot perform this procedure for Nutanix AHV NKP clusters.**

Procedure

1. Establish a name for the cluster you will create by setting the
   CLUSTER_NAME environment variable: Replace the placeholder
   `<name_of_the_cluster>` with the actual name you want to use.

```bash
export CLUSTER_NAME=<name_of_the_cluster>
```

1. Create CIS patch files for the issues you want to mitigate. These are the
   issues that you can mitigate:

###### CIS 1.2.5

1.2.5 Ensure that the --kubelet- certificate-authority argument is set as
appropriate (Automated).

Follow the Kubernetes documentation and setup the TLS connection between the
apiserver and kubelets. Then, edit the API server pod specification file
$apiserverconf on the control plane node and set the --kubelet-certificate-
authority parameter to the path to the cert file for the certificate
authority.--kubelet-certificate- authority=`<ca-string>`.

NKP Explanation

The --kubelet-certificate-authority flag needs to be set on each API Server
after the cluster has been fully provisioned, adding it earlier causes issues
with the creation and adding of worker nodes via CAPI and kubeadm.

###### CIS 1.2.12

1.2.12 Ensure that the admission control plugin AlwaysPullImages is set
(Manual).

Edit the API server pod specification file $apiserverconf on the control plane
node and set the --enable-admission-plugins parameter to include
AlwaysPullImages:--enable-admission- plugins=...,AlwaysPullImages,...

NKP Mitigation

Create a file called cis-1.2.12-patches.yaml with the following in the same
folder as kustomization.yaml:

```bash
cat <<EOF > cis-1.2.12-patches.yaml
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
metadata:
name: ${CLUSTER_NAME}-control-plane
spec:
kubeadmConfigSpec:
clusterConfiguration:
apiServer:
extraArgs:
enable-admission-plugins: "AlwaysPullImages"
EOF
```

###### CIS 1.2.15

1.2.15 Ensure that the --profiling argument is set to false (Automated).

Edit the API server pod specification file $apiserverconf on the control plane
node and set the parameter:--profiling=false

NKP Mitigation

Create a file called cis-1.2.16-patches.yaml with the following in the same
folder as kustomization.yaml:

```bash
cat <<EOF > cis-1.2.16-patches.yaml
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
metadata:
name: ${CLUSTER_NAME}-control-plane
spec:
kubeadmConfigSpec:
```

| ID  | Text | Remediation |
| --- | ---- | ----------- |

| ID  | Text | Remediation |
| --- | ---- | ----------- |

| ID  | Text | Remediation |
| --- | ---- | ----------- |

```bash
clusterConfiguration:
apiServer:
extraArgs:
profiling: "false"
EOF
```

###### CIS 1.2.18

1.2.18 Ensure that the --profiling argument is set to false (Automated).

Edit the API server pod specification file $apiserverconf on the control plane
node and set the below parameter:--profiling=false

NKP Mitigation

Create a file called cis-1.2.18-patches.yaml with the following in the same
folder as kustomization.yaml:

```bash
cat <<EOF > cis-1.2.18-patches.yaml
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
metadata:
name: ${CLUSTER_NAME}-control-plane
spec:
kubeadmConfigSpec:
clusterConfiguration:
apiServer:
extraArgs:
profiling: "false"
EOF
```

###### CIS 1.2.32

1.2.32 Ensure that the API Server only makes use of Strong Cryptographic
Ciphers (Manual)

Edit the API server pod specification file /etc/kubernetes/ manifests/kube-
apiserver.yaml

on the control plane node and set the below parameter.

--tls-cipher- suites=TLS_AES_128_GCM_SHA256,TLS_AES_256_GCM_SHA384,

TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256,TLS_R

NKP Mitigation

Create a file called cis-1.2.32-patches.yaml with the following in the same
folder as kustomization.yaml:

```bash
cat <<EOF > cis-1.2.32-patches.yaml
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
metadata:
name: ${CLUSTER_NAME}-control-plane
spec:
kubeadmConfigSpec:
clusterConfiguration:
apiServer:
extraArgs:
tls-cipher-suites:
"TLS_AES_128_GCM_SHA256,TLS_AES_256_GCM_SHA384,TLS_CHACHA20_POLY1305_SHA256,TLS_ECDHE_ECDSA_WITH_A
EOF
```

###### CIS 1.3.1

| ID  | Text | Remediation |
| --- | ---- | ----------- |

| ID  | Text | Remediation |
| --- | ---- | ----------- |

1.3.1 Ensure that the --terminated-pod- gc-threshold argument is set as
appropriate (Manual).

Edit the Controller Manager pod specification file $controllermanagerconf on
the control plane node and set the --terminated-pod-gc-threshold to an
appropriate threshold, for example:--terminated- pod-gc-threshold=10

NKP Mitigation

Create a file called cis-1.3.1-patches.yaml with the following in the same
folder as kustomization.yaml:

```bash
cat <<EOF > cis-1.3.1-patches.yaml
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
metadata:
name: ${CLUSTER_NAME}-control-plane
spec:
kubeadmConfigSpec:
clusterConfiguration:
controllerManager:
extraArgs:
terminated-pod-gc-threshold: "12500"
EOF
```

###### CIS 1.3.2

1.3.2 Ensure that the --profiling argument is set to false (Automated).

Edit the Controller Manager pod specification file $controllermanagerconf on
the control plane node and set the below parameter:--profiling=false

NKP Mitigation

Create a file called cis-1.3.2-patches.yaml with the following in the same
folder as kustomization.yaml:

```bash
cat <<EOF > cis-1.3.2-patches.yaml
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
metadata:
name: ${CLUSTER_NAME}-control-plane
spec:
kubeadmConfigSpec:
clusterConfiguration:
controllerManager:
extraArgs:
profiling: "false"
EOF
```

###### CIS 1.4.1

1.4.1 Ensure that the --profiling argument is set to false (Automated).

Edit the Controller Manager pod specification file $schedulerconf on the
control plane node and set the below parameter:--profiling=false

NKP Mitigation

Create a file called cis-1.4.1-patches.yaml with the following in the same
folder as kustomization.yaml:

```bash
cat <<EOF > cis-1.4.1-patches.yaml
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
```

| ID  | Text | Remediation |
| --- | ---- | ----------- |

| ID  | Text | Remediation |
| --- | ---- | ----------- |

| ID  | Text | Remediation |
| --- | ---- | ----------- |

```yaml
kind: KubeadmControlPlane
metadata:
name: ${CLUSTER_NAME}-control-plane
spec:
kubeadmConfigSpec:
clusterConfiguration:
scheduler:
extraArgs:
profiling: "false"
EOF
```

###### CIS 4.1.1

4.1.1 Ensure that the kubeletservice file permissions are set to 600 or more
restrictive(Automated). All known nodes are affected.

Run the below command (based on the file location on your system) on the each
node. For example, chmod 600 /lib/systemd/system/ kubelet.service

NKP Mitigation

Create a file called cis-4.1.1-patches.yaml with the following in the same
folder as kustomization.yaml:

```bash
cat <<EOF > cis-4.1.1-patches.yaml
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
metadata:
name: ${CLUSTER_NAME}-control-plane
spec:
kubeadmConfigSpec:
postKubeadmCommands:
- chmod 600 /lib/systemd/system/kubelet.service
---
apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
kind: KubeadmConfigTemplate
metadata:
name: ${CLUSTER_NAME}-md-0
spec:
template:
spec:
postKubeadmCommands:
- chmod 600 /lib/systemd/system/kubelet.service
EOF
```

###### CIS 4.1.9

4.1.9 If the kubelet config.yamlconfiguration file is being used validate
permissions set to 600 or more restrictive.

Run the following command (using the config file location identified in the
Audit step):chmod 600 / var/lib/kubelet/config.yaml

NKP Mitigation

Create a file called cis-4.1.9-patches.yaml with the following in the same
folder as kustomization.yaml:

```bash
cat <<EOF > cis-4.1.9-patches.yaml
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
metadata:
name: ${CLUSTER_NAME}-control-plane
spec:
```

| ID  | Text | Remediation |
| --- | ---- | ----------- |

| ID  | Text | Remediation |
| --- | ---- | ----------- |

```bash
kubeadmConfigSpec:
postKubeadmCommands:
- chmod 600 /var/lib/kubelet/config.yaml
---
apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
kind: KubeadmConfigTemplate
metadata:
name: ${CLUSTER_NAME}-md-0
spec:
template:
spec:
postKubeadmCommands:
- chmod 600 /var/lib/kubelet/config.yaml
EOF
```

###### CIS 4.2.6

4.2.6 Ensure that the --protect-kernel- defaults argument is set to true
(Automated).

If using a Kubelet config file, edit the file to set protectKernelDefaults to
true. If using command line arguments, edit the kubelet service file
$kubeletsvc on each worker node and set the below parameter in
KUBELET_SYSTEM_PODS_ARGS variable:-- protect-kernel-defaults=trueBased on your
system, restart the kubelet service. For example systemctl daemon-
reloadsystemctl restart kubelet.service

NKP Mitigation

Create a file called cis-4.2.6-patches.yaml with the following in the same
folder as kustomization.yaml:

```bash
cat <<EOF > cis-4.2.6-patches.yaml
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
metadata:
name: ${CLUSTER_NAME}-control-plane
spec:
kubeadmConfigSpec:
initConfiguration:
nodeRegistration:
kubeletExtraArgs:
protect-kernel-defaults: "true"
joinConfiguration:
nodeRegistration:
kubeletExtraArgs:
protect-kernel-defaults: "true"
---
apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
kind: KubeadmConfigTemplate
metadata:
name: ${CLUSTER_NAME}-md-0
spec:
template:
spec:
joinConfiguration:
nodeRegistration:
kubeletExtraArgs:
protect-kernel-defaults: "true"
EOF
```

###### CIS 4.2.9

| ID  | Text | Remediation |
| --- | ---- | ----------- |

4.2.9 Ensure that the eventRecordQPS argument is set to a level that ensures
appropriate event capture (Manual).

If using a Kubelet config file, edit the file to set eventRecordQPS to an
appropriate level. If using command line arguments, edit the kubelet service
file$kubeletsvc on each worker node and set the parameter below in the
KUBELET_SYSTEM_PODS_ARGS variable. Based on your system, restart the kubelet
service. For example, systemctl daemon-reloadsystemctl restart kubelet.service

NKP Mitigation

eventRecordQPS can also be configured with the --event-qps argument on the
kubelet's arguments.

Create a file called cis-4.2.9-patches.yaml with the following in the same
folder as kustomization.yaml:

```bash
cat <<EOF > cis-4.2.9-patches.yaml
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
metadata:
name: ${CLUSTER_NAME}-control-plane
spec:
kubeadmConfigSpec:
initConfiguration:
nodeRegistration:
kubeletExtraArgs:
event-qps: "0"
joinConfiguration:
nodeRegistration:
kubeletExtraArgs:
event-qps: "0"
---
apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
kind: KubeadmConfigTemplate
metadata:
name: ${CLUSTER_NAME}-md-0
spec:
template:
spec:
joinConfiguration:
nodeRegistration:
kubeletExtraArgs:
event-qps: "0"
EOF
```

###### CIS 4.2.13

| ID  | Text | Remediation |
| --- | ---- | ----------- |

4.2.13 Ensure that the Kubelet only makes use of Strong Cryptographic Ciphers
(Manual)

If using a Kubelet config file, edit the file to set TLSCipherSuites to

TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE

or to a subset of these values.

If using executable arguments, edit the kubelet service file

$kubeletsvc on each worker node and

set the --tls-cipher-suites parameter as follows or to a subset of these values.

--tls-cipher- suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_E

Based on your system, restart the kubelet service. For example,

```bash
systemctl daemon-reload
systemctl restart kubelet.service
```

NKP Mitigation

Create a file called cis-4.2.13-patches.yaml with the following in the same
folder as kustomization.yaml:

```bash
cat <<EOF > cis-4.2.13-patches.yaml
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
metadata:
name: ${CLUSTER_NAME}-control-plane
spec:
kubeadmConfigSpec:
initConfiguration:
nodeRegistration:
kubeletExtraArgs:
tls-cipher-suites:
"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WIT
joinConfiguration:
nodeRegistration:
kubeletExtraArgs:
tls-cipher-suites:
"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WIT
---
apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
kind: KubeadmConfigTemplate
metadata:
name: ${CLUSTER_NAME}-md-0
spec:
template:
spec:
joinConfiguration:
nodeRegistration:
kubeletExtraArgs:
tls-cipher-suites:
"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WIT
EOF
```

###### Create a Cluster Kustomization

| ID  | Text | Remediation |
| --- | ---- | ----------- |

Create a cluster kustomization that references the CIS patch files you created
in the previous section.

```yaml
Note: The kustomization.yaml file you create in this section must be in the same directory as the CIS patch
files.
```

###### Prerequisites to Create a Cluster Kustomization

Understanding the Infrastructure Cluster API is an important prerequisite for
creating a Cluster Kustomization. Familiarity with this API helps you
configure clusters correctly, manage resources effectively, and avoid errors
during setup. Ensuring this knowledge in advance supports a smoother
configuration process.

###### Creating a Kustomization YAML File

About this task

Create a cluster YAML using the NKP CLI,

Procedure

1. Create a cluster YAML and modify any arguments as necessary:

```bash
nkp create cluster aws
--cluster-name=${CLUSTER_NAME} \
--dry-run \
--output=yaml \
> ${CLUSTER_NAME}.yaml
```

1. Create a kustomization.yaml file will include patches for each of the CIS
   mitigations. We use the CIS-1.2.18 patch in this example, but you can
   include all mitigation files you created in the first section.

```bash
cat <<EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
bases:
- ${CLUSTER_NAME}.yaml
patches:
- cis-1.2.18-patch.yaml
#- Add more CIS patch files here.
EOF
```

###### Create a Cluster with the Kustomization

About this task

```yaml
Note: The CIS patch, kustomization.yaml, and ${CLUSTER_NAME}.yaml files must be in the same
directory.
```

Procedure

1. Create a Bootstrap Cluster. Ensure that the bootstrap cluster has been
   created for the desired provider.

> **Note: Supported providers include AWS, Azure, GCP, Pre-Provisioned, and
> vSphere.** 2. To apply the customizations and create a new cluster, use
> the command.

```bash
kubectl create -k .
```

1. Monitor and watch the cluster creation.

###### List of CIS Benchmark Explanations

This topic lists the CIS Benchmark Explanations.

The CIS Kubernetes Benchmark is a set of security best practices and
recommendations for hardening Kubernetes environments, published by the Center
for Internet Security (CIS).

Following are the CIS Benchmark list Explanations:

- CIS 1.1.10
- CIS 1.1.9
- CIS 1.1.12
- CIS 1.2.1
- CIS 1.2.5
- CIS 1.2.6
- CIS 1.2.10
- CIS 1.2.13
- CIS 4.2.8
- CIS 4.2.10

###### CIS 1.1.10

1.1.10 Ensure that the Container Network Interface file ownership is set to
root:root (Manual)

Run the below command (based on the file location on your system) on the
control plane node. For example,chown root:root `<path/to/cni/files>`

NKP Explanation

The kubelet config --cni-config-dir has been deprecated and removed since
Kubernetes v1.24. Calico, used for CNI stores, is configured at /etc/cni/net.d
and has ownership set to root:root.

###### CIS 1.1.9

1.1.9 Ensure that the Container Network Interface file permissions are set to
644 or more restrictive (Manual)

Run the below command (based on the file location on your system) on the
control plane node. For example, chmod 644 `<path/to/cni/files>`

NKP Explanation

The kubelet config --cni-config-dir has been deprecated and removed since
Kubernetes v1.24. Calico, which is used for CNI, stores its configuration at
/etc/cni/net.d and has permissions set to 644.

###### CIS 1.1.12

1.1.12 Ensure that the etcd data directory ownership is set to etcd:etcd
(Automated)

On the etcd server node, get the etcd data directory, passed as an argument
--data-dir, from the command 'ps -ef | grep etcd.'Run the below command (based
on the etcd data directory found above).For example, chown etcd:etcd
/var/lib/etcd

| ID  | Text | Remediation |
| --- | ---- | ----------- |

| ID  | Text | Remediation |
| --- | ---- | ----------- |

| ID  | Text | Remediation |
| --- | ---- | ----------- |

NKP Explanation

etcd files are owned by root. Creating another user adds additional attack
vectors. On previous STIGs, this has been acceptable to leave as root:root.

###### CIS 1.2.1

1.2.1 Ensure that the --anonymous-auth argument is set to false (Manual)

Edit the API server pod specification file $apiserverconfon the control plane
node and set the below parameter.--anonymous-auth=false

NKP Explanation

Although the --anonymous-auth flag defaults to true, we also set the
--authorization-mode=Node,RBAC flag. Having anonymous authorization enabled is
generally used for discovery and health checking. This is also important for
kubeadm join to function properly. For more information, see
`<https://github.com/aws/eks->` anywhere/pull/3122#issuecomment-1226581563.

###### CIS 1.2.5 (2)

1.2.5 Ensure that the --kubelet- certificate-authority argument is set as
appropriate (Automated).

Follow the Kubernetes documentation and setup the TLS connection between the
apiserver and kubelets. Then, edit the API server pod specification file
$apiserverconf on the control plane node and set the --kubelet-certificate-
authority parameter to the path to the cert file for the certificate
authority.--kubelet-certificate- authority=`<ca-string>`.

NKP Explanation

The --kubelet-certificate-authority flag needs to be set on each API Server
after the cluster has been fully provisioned, adding it earlier causes issues
with the creation and adding of worker nodes via CAPI and kubeadm.

###### CIS 1.2.6

1.2.6 Ensure that the --kubelet- certificate-authority argument is set as
appropriate (Automated)

Follow the Kubernetes documentation and set up the TLS connection between the
apiserver and kubelets. Then, edit the API server pod specification
file$apiserverconf on the control plane node and set the--kubelet-certificate-
authority parameter to the certificate authority's path to the cert file.--
kubelet- certificate-authority=`<ca-string>`

NKP Explanation

The --kubelet-certificate-authority flag needs to be set on each API Server
after the cluster has been fully provisioned; adding it earlier causes issues
with the creation and adding of worker nodes via CAPI and kubeadm.

###### CIS 1.2.10

| ID  | Text | Remediation |
| --- | ---- | ----------- |

| ID  | Text | Remediation |
| --- | ---- | ----------- |

| ID  | Text | Remediation |
| --- | ---- | ----------- |

4.2.10 Ensure that the --tls-cert-file and --tls-private-key-file arguments
are set as appropriate (Manual)

If using a Kubelet config file, edit the file to set tlsCertFile to the
location of the certificate file to identify
this Kubelet and tlsPrivateKeyFileto the location of the corresponding private
key file. If using command line
arguments, edit the kubelet service file$kubeletsvc on each worker node and
the below parameters in
KUBELET_CERTIFICATE_ARGS variable.--tls- cert-file=`<path/to/tls-certificate- file>`--tls-private-key- file=`<path/to/tls- key-file>`Based on your system, restart the kubelet service. For
example,systemctl daemon-reloadsystemctl restart
kubelet.service

NKP Explanation

This remediation refers to a serving certificate on the kubelet, where the
HTTPS endpoint on the kubelet is used. By default, a self-signed certificate
is used here. Connecting to the HTTPS endpoint of a kubelet must only be used
for diagnostic or debugging purposes where applying a provided key and
certificate isn't expected.

For more information, see Client and serving certificates at
`<https://kubernetes.io/docs/reference/access-authn->` authz/kubelet-tls-
bootstrapping/#client-and-serving-certificates.

###### CIS 1.2.13

1.2.13 Ensure that the admission control plugin SecurityContextDeny is set if
PodSecurityPolicy is not used (Manual)

Edit the API server pod specification file $apiserverconfon the control plane
node and set the --enable-admission-plugins parameter to
includeSecurityContextDeny, unless PodSecurityPolicy is already in place.--
enable- admission-plugins=...,SecurityContextDeny,...

NKP Explanation

The Kubernetes Project recommends not using this admission controller, as it
is deprecated and will be removed in a future release. For more information,
see Admission Controllers Reference `<https://kubernetes.io/docs/reference/>`
access-authn-authz/admission-controllers/#securitycontextdeny.

###### CIS 4.2.8

4.2.8 Ensure that the --hostname- override argument is not set (Manual)

Edit the kubelet service file $kubeletsvcon each worker node and remove the --
hostname-override argument from theKUBELET_SYSTEM_PODS_ARGS variable. Based on
your system, restart the kubelet service. For example,systemctl daemon-
reloadsystemctl restart kubelet.service

NKP Explanation

The hostname-override argument is used by various infrastructure providers to
provision nodes; removing this argument will impact how CAPI works with the
infrastructure provider.

###### CIS 4.2.10

| ID  | Text | Remediation |
| --- | ---- | ----------- |

| ID  | Text | Remediation |
| --- | ---- | ----------- |

| ID  | Text | Remediation |
| --- | ---- | ----------- |

1.2.10 Ensure that the admission control plugin EventRateLimit is set (Manual)

Follow the Kubernetes documentation and set the desired limits in a
configuration file. Then, edit the API server pod specification file
$apiserverconfand set the below parameters.--enable-admission-
plugins=...,EventRateLimit,...--admission-control- config-
file=`<path/to/configuration/file>`

NKP Explanation

Kubernetes recommends the use of API Priority and Fairness using the --max-
requests-inflight and --max- mutating-requests-inflight flags to control how
the Kubernetes API Server behaves in overload situations. The
APIPriorityAndFairness Feature Gate has been enabled by default since
Kubernetes v1.20.

For more information, see:

- API Priority and Fairness: `<<https://kubernetes.io/docs/concepts/cluster->`
  administration/flow-control/>
- Feature Gate: `<<https://kubernetes.io/docs/reference/command-line-tools->`
  reference/feature-gates/#feature-> gates-for-alpha-or-beta-features

| ID  | Text | Remediation |
| --- | ---- | ----------- |
