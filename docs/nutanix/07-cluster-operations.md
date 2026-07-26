# Cluster Operations Management

## Cluster Operations Management (2)

## Operations

- Applications on page 327
- Workspaces on page 369
- Projects on page 415
- Cluster Management on page 458
- Backup and Restore on page 555
- Logging on page 590
- Security on page 618
- Networking on page 632
- GPU Management on page 651
- Monitoring and Alerts on page 663
- Storage for Applications on page 680

You can manage your cluster and deployed applications using platform
applications.

In most cases, a production cluster requires additional advanced configuration
tailored for your environment, ongoing maintenance, authentication and
authorization, and other common activities. For example, it is important to
monitor cluster activity and collect metrics to ensure application performance
and response time, evaluate network traffic patterns, manage user access to
services, and verify workload distribution and efficiency.

In addition to the configurations, you can also control the appearance of your
NKP UI by adding banners and footers. There are different options available
depending on the NKP level that you license and install.

- Access Control on page 285
- Identity Providers on page 297
- Kubectl API Access Using an Identity Provider on page 305
- Infrastructure Providers on page 309
- Header, Footer, and Logo Implementation on page 325

### Access Control

You can centrally manage access across clusters and define role-based
authorization within the NKP UI to control resource access on the management
cluster for a set or all of the target clusters. These resources are similar
to Kubernetes RBAC but with crucial differences, and they make it possible to
define the roles and role bindings once and federate them to clusters within a
given scope.

- Kommander Roles: control access to resources on the management clusters.
- Cluster Roles: control access to resources on all target clusters.

Table 19: Managing Access Across Scopes

Global : Manages access to the entire environment.

Create ClusterRoles on the management cluster.

Federates ClusterRoles on all target clusters across all workspaces.

```yaml
Workspace: Manages access to
clusters in a specific workspace,
for example, in the scope of multi-
tenancy. See Multi-Tenancy in
NKP on page 412.
```

Create namespaced Roles on the management cluster in the workspace namespace.

Federates ClusterRoles on all target clusters in the workspace.

```yaml
Project: Manages access for
clusters in a specific project, for
example, in the scope of multi-
tenancy. See Multi-Tenancy in
NKP on page 412.
```

Create namespaced Roles on the management cluster in the project namespace.

Federates namespaced Roles on all target clusters in the project in the
project namespace.

Create the role bindings for each level and type create RoleBindings or
ClusterRoleBindings on the clusters that apply to each category.

This approach gives you maximum flexibility over who has access to what
resources, conveniently mapped to your existing identity providers' claims.

#### Limitation for Kommander Roles

### Access Control (2)

The property for the subjects.name varies depending on the context for which
you have established an Identity Provider.

- If you have set up an identity provider for All Workspaces:
- For groups: configure the subjects.name field to oidc:`<IdP_user_group>`.
  For example, oidc:engineering.
- For users: configure the subjects.name field to `<user_email>`. For example,
  `<jane.doe@example.com>`

| Environment Context | Kommander Roles | Cluster Roles |
| ------------------- | --------------- | ------------- |

- If you have set up an identity provider for a Specific Workspace:
- For groups: configure the subjects.name field to
  oidc:`<workspace_ID>`:`<IdP_user_group>`. For example,
  oidc:tenant-z:engineering.
- For users: configure the subjects.name field to
  `<workspace_ID>`:`<user_email>`. For example, tenant-z:jane.doe@example.com.

```yaml
Note: Run kubectl get workspaces to obtain a list of all existing workspaces. The workspace_ID
is listed under the NAME column.
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
name: eng-kommander-dashboard
labels:
"workspaces.kommander.mesosphere.io/rbac": ""
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: ClusterRole
name: dkp-kommander-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
kind: Group
name: oidc:engineering
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
name: eng-nkp-routes
labels:
"workspaces.kommander.mesosphere.io/rbac": ""
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: ClusterRole
name: dkp-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
kind: Group
name: oidc:engineering
EOF
```

#### Types of Access Control Objects

Manage Kubernetes role-based access control with three different object
categories: Groups, Roles, and Policies.

Groups

Access control groups are configured in the Groups tab of the Identity
Providers page.

You can map group and user claims made by your configured identity providers
to Kommander groups by selecting administration or identity providers in the
left sidebar in the global workspace level, and then select the Groups tab.

The syntax for the Identity Provider groups you add to a Group varies
depending on the context for which you have established an Identity Provider.

- If you have set up an identity provider globally, for All Workspaces:
- For groups: Add an Identity Provider Group in the
  oidc:`<github_org>`:`<github_team>` format. For example, oidc:org:team-a.
- For users: Add an Identity Provider User in the `<user_email>`. For example,
  `<jane.doe@example.com>`
- If you have set up an identity provider for a Specific Workspace:
- For groups: Add an Identity Provider Group in the
  oidc:`<workspace_ID>`:`<github_org>`:`<github_team>`. For example,
  oidc:tenant-z:org:team-a.
- For users: Add an Identity Provider User in the
  `<workspace_ID>`:`<user_email>`. For example, tenant-z:jane.doe@example.com.

```yaml
Note: Run kubectl get workspaces to obtain a list of all existing workspaces. The workspace_ID
is listed under the NAME column.
```

Roles

ClusterRoles are named collections of rules defining which verbs can be
applied to what resources.

- Kommander Roles apply specifically to resources in the management cluster.
- Cluster Roles apply to target clusters within their scope at these levels:
- Global level - this is all target clusters in all workspaces.
- Workspace level - all target clusters in the workspaces.
- Project level - this i all target clusters that are added to the project.

#### Propagating Workspace Roles to Projects

About this task

Each workspace has roles defined using KommanderWorkspaceRole resources.
Automatic propagation is controlled using the annotation
"workspace.kommander.mesosphere.io/sync-to-project": "true" on a
KommanderWorkspaceRole resource. You can manage this only by using the CLI.

Procedure

1. Run the command kubectl get kommanderworkspaceroles -n
   `<WORKSPACE_NAMESPACE>`.

```bash
NAME DISPLAY NAME AGE
kommander-workspace-admin Kommander Workspace Admin Role 2m18s
kommander-workspace-edit Kommander Workspace Edit Role 2m18s
kommander-workspace-view Kommander Workspace View Role 2m18s
```

1. To prevent propagation of the kommander-workspace-view role, remove this
   annotation from the

KommanderWorkspaceRole resource.

```bash
kubectl annotate kommanderworkspacerole -n <WORKSPACE_NAMESPACE> kommander-workspace-
view workspace.kommander.mesosphere.io/sync-to-project=false --overwrite
```

1. To enable propagation of the role, add this annotation to the relevant
   KommanderWorkspaceRole resource.

```bash
kubectl annotate kommanderworkspacerole -n <WORKSPACE_NAMESPACE> kommander-workspace-
view workspace.kommander.mesosphere.io/sync-to-project=true --overwrite
```

#### Limitation for Workspace

During the inheritance of the Project Role, when granting users access to a
workspace, you must manually grant access to the projects within that
workspace. Each project is created with a set of admin, edit, or view roles,
and you can choose to add RoleBinding to each group or user of the workspace
for one of these project roles. Usually, these are prefixed with one of the
roles kommander-project-(admin/edit/view).

This is an example of RoleBinding that grants the Kommander Project Admin role
access for the project namespace to the engineering group:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
name: workspace-admin-project1-admin
namespace: <my-project-namespace-xxxxx>
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: Role
name: <kommander-project-admin-xxxxx>
subjects:
- apiGroup: rbac.authorization.k8s.io
kind: Group
name: oidc:engineering
EOF
```

#### Role Bindings

#### Access to Kubernetes and Kommander Resources

You can grant access to Kommander and Kubernetes resources using RBAC.

Initially, users and groups from an external identity provider have no access
to Kubernetes resources. Privileges must be granted explicitly by interacting
with the RBAC API. This section provides some basic examples for general
usage. For more information on the RBAC API, see the Using RBAC Authorization
section in the Kubernetes documentation at
`<https://kubernetes.io/docs/reference/access-authn-authz/rbac/>`.

#### Role Bindings (2)

For example, if you want to make `<mary@example.com>` a cluster administrator,
bind their username to the cluster- admin default role as follows:

```bash
cat << EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
name: mary-admin
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: ClusterRole
name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
kind: User
name: mary@example.com
EOF
```

If you have configured an Identity Provider for a specific workspace,
configure the subjects.name field to `<workspace_ID>`:`<user_email>`. For
example, tenant-z:jane.doe@example.com.

User Namespace Restriction

A common example is granting users access to specific namespaces by creating a
RoleBinding (RoleBindings are namespaced scoped). For example, to make the
user `<bob@example.com>` a reader of the baz namespace, bind the user to the
view role:

```bash
cat << EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
name: bob-view
namespace: baz
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: ClusterRole
name: view
subjects:
- apiGroup: rbac.authorization.k8s.io
kind: User
name: bob@example.com
EOF
```

If you have configured an Identity Provider for a specific workspace,
configure the subjects.name field to `<workspace_ID>`:`<user_email>`. For
example, tenant-z:jane.doe@example.com.

The user can now only perform non-destructive operations targeting resources
in the #baz# namespace.

Groups

If your external identity provider supports group claims, you can also bind
groups to roles. To make the engineering LDAP group administrators of the
production namespace bind the group to the admin role:

```bash
cat << EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
name: engineering-admin
namespace: production
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: Role
name: admin
subjects:
- apiGroup: rbac.authorization.k8s.io
kind: Group
name: oidc:engineering
EOF
```

One important distinction from adding users is that all external groups are
prefixed with oidc:, so a group name is oidc:devops. This prevents collision
with locally defined groups.

The property for the subjects.name varies depending on the context for which
you have established an Identity Provider.

- If you have set up an identity provider for All Workspaces:
- For groups: configure the subjects.name field to oidc:`<IdP_user_group>`.
  For example, oidc:engineering.
- For users: configure the subjects.name field to `<user_email>`. For example,
  `<jane.doe@example.com>`
- If you have set up an identity provider for a Specific Workspace:
- For groups: configure the subjects.name field to
  oidc:`<workspace_ID>`:`<IdP_user_group>`. For example,
  oidc:tenant-z:engineering.
- For users: configure the subjects.name field to
  `<workspace_ID>`:`<user_email>`. For example, tenant-z:jane.doe@example.com.

```yaml
Note: Run kubectl get workspaces to obtain a list of all existing workspaces. The workspace_ID
is listed under the NAME column.
```

##### NKP UI Authorization

The NKP UI and other HTTP applications protected by Kommander forward
authentication, are also authorized by the Kubernetes RBAC API. In addition to
the Kubernetes API resources, it is possible to define rules which map to HTTP
URIs and HTTP verbs. Kubernetes RBAC refer to these as nonResourceURLs,
Kommander forward authentication uses these rules to grant or deny access to
HTTP endpoints.

##### Default Roles

Roles are created to grant access to the dashboard and select applications
that expose an HTTP server through the ingress controller. The cluster-admin
role is a system role that grants permission to all actions (verbs) on any
resource, including non-resource URLs. The default dashboard user is bound to
this role.

> **Note:**

- With the NKP Starter license, you can only select the following cluster
  roles: cluster-admin or cluster view
- Granting user administrator privileges on /dkp/\* grants admin privileges to
  all sub-resources, even if the bindings exist for sub-resources with fewer
  privileges.

Table 20: Table

- cluster-admin \* read, write, delete

kommander dkp-view /dkp/\* read

kommander dkp-edit /dkp/\* read, write

| Dashboard | Role | Path | access |
| --------- | ---- | ---- | ------ |

kommander dkp-admin /dkp/\* read, write, delete

kommander-dashboard dkp-kommander-view /dkp/kommander/ dashboard/\*

read

kommander-dashboard dkp-kommander-edit /dkp/kommander/ dashboard/\*

read, write

kommander-dashboard dkp-kommander-admin /dkp/kommander/ dashboard/\*

read, write, delete

alertmanager dkp-kube-prometheus- stack-alertmanager-view

/dkp/alertmanager/\* read

alertmanager dkp-kube-prometheus- stack-alertmanager-edit

/dkp/alertmanager/\* read, write

alertmanager dkp-kube-prometheus- stack-alertmanager- admin

/dkp/alertmanager/\* read, write, delete

centralized-grafana dkp-centralized-grafana- grafana-view

/dkp/kommander/ monitoring/grafana/\*

read

centralized-grafana dkp-centralized-grafana- grafana-edit

/dkp/kommander/ monitoring/grafana/\*

read, write

centralized-grafana dkp-centralized-grafana- grafana-admin

/dkp/kommander/ monitoring/grafana/\*

read, write, delete

centralized-opencost dkp-centralized- opencost-view

/dkp/kommander/ opencost/\*

read

centralized-opencost dkp-centralized- opencost-edit

/dkp/kommander/ opencost/\*

read, write

centralized-opencost dkp-centralized- opencost-admin

/dkp/kommander/ opencost/\*

read, write, delete

grafana dkp-kube-prometheus- stack-grafana-view

/dkp/grafana/\* read

grafana dkp-kube-prometheus- stack-grafana-edit

/dkp/grafana/\* read, write

grafana dkp-kube-prometheus- stack-grafana-admin

/dkp/grafana/\* read, write, delete

grafana-logging dkp-grafana-logging-view /dkp/logging/grafana/\* read

grafana-logging dkp-grafana-logging-edit /dkp/logging/grafana/\* read, write

grafana-logging dkp-grafana-logging- admin

/dkp/logging/grafana/\* read, write, delete

karma dkp-karma-view /dkp/kommander/ monitoring/karma/\*

read

karma dkp-karma-edit /dkp/kommander/ monitoring/karma/\*

read, write

karma dkp-karma-admin /dkp/kommander/ monitoring/karma/\*

read, write, delete

| Dashboard | Role | Path | access |
| --------- | ---- | ---- | ------ |

kubernetes-dashboard dkp-kubernetes- dashboard-view

/dkp/kubernetes/\* read

kubernetes-dashboard dkp-kubernetes- dashboard-edit

/dkp/kubernetes/\* read, write

kubernetes-dashboard dkp-kubernetes- dashboard-admin

/dkp/kubernetes/\* read, write, delete

prometheus dkp-kube-prometheus- stack-prometheus-view

/dkp/prometheus/\* read

prometheus dkp-kube-prometheus- stack-prometheus-edit

/dkp/prometheus/\* read, write

prometheus dkp-kube-prometheus- stack-prometheus-admin

/dkp/prometheus/\* read, write, edit

traefik dkp-traefik-view /dkp/traefik/\* read

traefik dkp-traefik-edit /dkp/traefik/\* read, edit

traefik dkp-traefik-admin /dkp/traefik/\* read, edit, delete

thanos dkp-thanos-query-view /dkp/kommander/ monitoring/query/\*

read

thanos dkp-thanos-query-edit /dkp/kommander/ monitoring/query/\*

read, write

thanos dkp-thanos-query-admin /dkp/kommander/ monitoring/query/\*

read, write, delete

##### Examples of Default Roles

This topic provides a few examples of binding subjects to the default roles
defined for the NKP UI endpoints.

User

To grant the user `<mary@example.com>` administrative access to all Kommander
resources, bind the user to the dkp- admin role:

```bash
cat << EOF | kubectl apply -f -
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
name: dkp-admin-mary
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: ClusterRole
name: dkp-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
kind: User
name: mary@example.com
EOF
```

| Dashboard | Role | Path | access |
| --------- | ---- | ---- | ------ |

If you inspect the role, you can see what access is now granted:

```bash
kubectl describe clusterroles dkp-admin
Name: dkp-admin
Labels: app.kubernetes.io/instance=kommander
app.kubernetes.io/managed-by=Helm
app.kubernetes.io/version=v2.13.1
helm.toolkit.fluxcd.io/name=kommander
helm.toolkit.fluxcd.io/namespace=kommander
rbac.authorization.k8s.io/aggregate-to-admin=true
Annotations: meta.helm.sh/release-name: kommander
meta.helm.sh/release-namespace: kommander
PolicyRule:
Resources Non-Resource URLs Resource Names Verbs
--------- ----------------- -------------- -----
[/dkp/*] [] [delete]
[/dkp] [] [delete]
[/dkp/*] [] [get]
[/dkp] [] [get]
[/dkp/*] [] [head]
[/dkp] [] [head]
[/dkp/*] [] [post]
[/dkp] [] [post]
[/dkp/*] [] [put]
[/dkp] [] [put]
```

The user can now use the HTTP verbs HEAD, GET, DELETE, POST, and PUT when
accessing any URL at or under /dkp. The downstream application follows REST
conventions. This effectively allows privileges to be read, edited, and
deleted.

```yaml
Note: To enable users to access the NKP UI, ensure they have the appropriate dkp-kommander role and the
Kommander roles granted in the NKP UI.
```

Group

To grant view access to the /dkp/\* endpoints and edit access to the grafana
logging endpoint to group logging- ops, create the following
ClusterRoleBindings:

```bash
cat << EOF | kubectl apply -f -
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
name: nkp-view-logging-ops
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: ClusterRole
name: dkp-view
subjects:
- apiGroup: rbac.authorization.k8s.io
kind: Group
name: oidc:logging-ops
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
name: dkp-logging-edit-logging-ops
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: ClusterRole
name: dkp-logging-edit
subjects:
- apiGroup: rbac.authorization.k8s.io
kind: Group
name: oidc:logging-ops
EOF
```

> **Note: External groups must be prefixed by oidc:**

Members of logging-ops to view all the resources under /nkp and edit all the
resources under /nkp/logging/ grafana.

##### Creating Custom Roles

If one of the predefined roles from NKP does not include all the permissions
you need, you can create a custom role.

About this task

Perform the following tasks to assign actions and permissions to roles:

Procedure

1. In the Administration section of the sidebar menu, select Access Control.
2. Select the Cluster Roles tab, and then select + Create Role .
3. Enter a descriptive name for the role and ensure that Cluster Role is
   selected as the type.
4. For example, to configure a read-only role, select Add Rule.

a. In the Resources input, select All Resource Types.

b. Select the get, list, and watch options.

c. Click Save. You can assign your newly created role to the developer's group.

##### Kubernetes Dashboard

```bash
cat << EOF | kubectl apply -f -
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
name: developer-dashboard-access
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: ClusterRole
name: dkp-kubernetes-dashboard-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
kind: Group
name: oidc:developers
EOF
```

However, access to the underlying Kubernetes resources exposed by the
dashboard are protected by the cluster RBAC policy.

#### Onboarding a User to an NKP Cluster

Before you begin

You must have administrator rights. Also, ensure that:

- You have an LDAP Connector.
- You are a cluster administrator.
- You have a valid NKP license (Ultimate, Starter, or Pro)
- You have a running cluster.

For information about adding users using other types of connectors, see:

- `<https://dexidp.io/docs/connectors/oidc/>`
- `<https://dexidp.io/docs/connectors/saml/>`
- `<https://dexidp.io/docs/connectors/github/>`

To onboard a user:

Procedure

1. Create an LDAP Connector definition and name the file ldap.yaml.

```yaml
apiVersion: v1
kind: Secret
metadata:
name: ldap-password
namespace: kommander
type: Opaque
stringData:
password: superSecret
---
apiVersion: dex.mesosphere.io/v1alpha1
kind: Connector
metadata:
name: ldap
namespace: kommander
spec:
enabled: true
type: ldap
displayName: LDAP Test Connector
ldap:
host: ldapdce.testdomain
insecureNoSSL: true
bindDN: cn=ldapconnector,cn=testgroup,ou=testorg,dc=testdomain
bindSecretRef:
name: ldap-password
userSearch:
baseDN: dc=testdomain
filter: "(objectClass=inetOrgPerson)"
username: uid
idAttr: uid
emailAttr: uid
groupSearch:
baseDN: ou=testorg,dc=testdomain
filter: "(objectClass=posixGroup)"
userMatchers:
- userAttr: uid
groupAttr: memberUid
nameAttr: cn
```

1. Add the connector and use the command kubectl apply -f ldap.yaml.

The following output is displayed.

```bash
secret/ldap-password created
connector.dex.mesosphere.io/ldap created
```

1. Add the appropriate role bindings and name the file new_user.yaml.

The property for the subjects.name varies depending on the context for which
you have established an Identity Provider.

- If you have set up an identity provider for All Workspaces:
- For groups: configure the subjects.name field to oidc:`<IdP_user_group>`.
  For example, oidc:engineering.
- For users: configure the subjects.name field to `<user_email>`. For example,
  `<jane.doe@example.com>`
- If you have set up an identity provider for a Specific Workspace:
- For groups: configure the subjects.name field to
  oidc:`<workspace_ID>`:`<IdP_user_group>`. For example,
  oidc:tenant-z:engineering.
- For users: configure the subjects.name field to
  `<workspace_ID>`:`<user_email>`. For example, tenant-z:jane.doe@example.com.

```yaml
Note: Run kubectl get workspaces to obtain a list of all existing workspaces. The
workspace_ID is listed under the NAME column.
```

See the following examples for both Single User and Group Bindings.

» For Single Users:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
name: cluster-admin
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: ClusterRole
name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
kind: User
name: newUser
```

» For Group Binding:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
name: cluster-admin
namespace: ml
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: ClusterRole
name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
kind: Group
name: oidc:kommanderAdmins
```

1. Add the role binding(s) use the command kubectl apply -f new_user.yaml.

> **Note:**

- ClusterRoleBindings permissions are applicable at the global level.
- RoleBindings permissions are applicable at the namespace level.

For additional information about the other roles in NKP and their permissions,
see Access to Kubernetes and Kommander Resources on page 288.

### Identity Providers

Configuring a dedicated identity provider per workspace can be useful if you
want to retain access to your workspaces separately. In this case, users of a
specific workspace have a dedicated login 2-factor authentication page with
the identity provider options configured for their workspace. This setup is
particularly helpful if you have multiple tenants. For more information, see
Multi-Tenancy in NKP on page 412.

Advantages of Using an External Identity Provider

Using an external identity provider is beneficial for:

- Centralized management of multiple users and multiple clusters.
- Centralized management of password rotation, expiration, and so on.
- Support of 2-factor-authentication methods for increased security.
- Separate storage of user credentials.

Access Limitations

- The GitHub provider allows you to specify any organizations and teams that
  are eligible for access.
- The LDAP provider allows you to configure search filters for either users or
  groups.
- The OIDC provider cannot limit users based on identity.
- The SAML provider allows users to log in using a single sign-on (SSO).

#### Configuring an Identity Provider Through the UI

Before you begin

Limit Access

- The GitHub provider allows you to specify any of the organizations and teams
  are eligible for access.
- The LDAP provider allows you to configure search filters for either users or
  groups.
- The OIDC provider cannot limit users based on identity.
- The SAML provider allows users to log in using a single sign-on (SSO) profile.

To configure an identity provider:

Procedure

1. Log into the Kommander UI. See Pre-provisioned: Logging In To the UI on
   page 83.
2. From the dropdown list, select the Global workspace.
3. Select Administration > Identity Providers.
4. Select the Identity Providers tab.
5. Select Add Identity Provider.
6. Select an identity provider.
7. Select the target workspace for the identity provider and complete the
   fields with the relevant details.

```yaml
Note: You can configure an identity provider globally for your entire organization using theAll Workspaces
option or per workspace, enabling multi-tenancy.
```

1. Click Save.

#### Disabling an Identity Provider

Procedure

1. Select the three-dot button on the Identity Providers table.
2. Select Disable from the dropdown menu. The identity provider is disabled.
   You can view the disabled identity providers in the Identity Providers tab.

#### GitHub Identity Provider Configuration

You can configure GitHub as an identity provider and grant access to NKP.

NKP allows authorizing access to your clusters and the UI with GitHub
credentials but it must be configured in the dashboard. To ensure every
developer in your GitHub organization has access to your Kubernetes clusters
using their GitHub credentials, add that option for login by adding an
identity provider with the information from your GitHub profile in the OAuth
application settings

The first login requires you to authorize the GitHub account. As an
administrator of the cluster, select the Authorize github-username button on
the page that follows the login. After setting up the GitHub authorization,
the future login screens will have the Log in with github-auth button as an
option.

##### Adding an Identity Provider Using GitHub

To authorize all developers to access your clusters using their GitHub
credentials, set up GitHub as an identity provider login option.

Procedure

1. Start by creating a new OAuth Application in your GitHub organization by
   completing the registration form.

To view the form, see `<https://github.com/settings/applications/new>`. 2. In
the Application name field, enter a name for your application. 3. In the
Homepage URL field, enter your cluster URL. 4. In the Authorization callback
URL field, use your cluster URL followed by /dex/callback by adding this to
the end of your URL. 5. Click Register application. After you complete the
application, the Settings page. appears 6. You need the Client ID and Client
Secret from this page for the NKP UI.

If you do not have a Client Secret for the application, to generate a new
client secret, select Generate a new client
secret. 7. Log in to your NKP UI from the top menu bar, and select the Global
workspace. 8. Select Identity Providers in
the Administration section of the sidebar menu. 9. Select the Identity
Providers tab and then click Add Identity
Provider . 10. Select GitHub as the identity provider type, and select the
target workspace. 11. Copy the Client ID and
Client Secret values from GitHub into this form. 12. To configure dex to load
all the groups configured in the user's
GitHub identity, select the Load All Groups check box. This allows you to
configure group-specific access to NKP and
Kubernetes resources.

> **Note: Do not select the Enable Device Flow checkbox before selecting
> `<Register the Application>` .** 13. Click Save.

##### Mapping the Identity Provider Groups to the Kubernetes Groups

You can map the identity provider groups to the Kubernetes groups.

Procedure

1. In the NKP UI, select the Groups tab from the Identity Provider screen, and
   then click Create Group.
2. In the Enter Name field, enter a descriptive name.

The syntax for the Identity Provider groups you add to a Group varies
depending on the context for which you have established an Identity Provider.

- If you have set up an identity provider globally, for All Workspaces:
- For groups: Add an Identity Provider Group in the
  oidc:`<github_org>`:`<github_team>` format. For example, oidc:org:team-a.
- For users: Add an Identity Provider User in the `<user_email>`. For example,
  `<jane.doe@example.com>`
- If you have set up an identity provider for a Specific Workspace:
- For groups: Add an Identity Provider Group in the
  oidc:`<workspace_ID>`:`<github_org>`:`<github_team>`. For example,
  oidc:tenant- z:org:team-a.
- For users: Add an Identity Provider User in the
  `<workspace_ID>`:`<user_email>`. For example, tenant-z:jane.doe@example.com.

```yaml
Note: Run kubectl get workspaces to obtain a list of all existing workspaces. The
workspace_ID is listed under the NAME column.
```

1. Add the groups or teams from your GitHub provider under Identity Provider
   Groups.

For more information on finding the teams to which you are assigned in GitHub,
see the Changing team visibility section at
`<<https://docs.github.com/en/organizations/organizing-members-into->`
teams/changing-team-> visibility. 4. Click Save.

##### Assigning a Role to the Developers Group

After defining a group, bind one or more roles to this group. This topic
describes how to bind the group to the View Only role.

Procedure

1. In the NKP UI, from the top menu bar, select Global or the target workspace.
2. Select the Cluster Role Bindings tab and then select Add roles.
3. Select View Only role from the Roles dropdown list and select Save.

For more information on granting users access to Kommander paths on your
cluster, see Access to Kubernetes and Kommander Resources on page 288. 4. At a
minimum, add a read only path for access to all the Kommander Dashboard views:

Table 21: Kommander Dashboard Views

kommander-dashboard nkp-kommander-view /nkp/kommander/ dashboard/\*

read

When you check your attached clusters and login as a user from your matched
groups, every resource, is listed. Do delete or edit them.

Future Log In

The first login will require you to authorize the GitHub account, so the
administrator of the cluster will select the `<Authorize github-username>`
button on the page that follows the login. After setting up GitHub
authorization, future login screens will have that as an option: `<Log in with github-auth>` button.

#### External LDAP Directory Configuration

You can connect your cluster to an external LDAP directory. Configure your NKP
cluster for logging in with the credentials stored in an external LDAP
directory service.

Each LDAP directory is set up in unique ways. You may add the LDAP
authentication mechanism using the CLI or UI.

##### Adding an LDAP Connector

Each LDAP directory is set up in unique ways. So, these steps are important.
Add the LDAP authentication mechanism using the CLI or UI.

About this task

This topic describes the configuration of an NKP cluster to connect to the
Online LDAP Test Server in Forum Systems Web
site at `<<https://www.forumsys.com/tutorials/integration-how-to/ldap/online->`
ldap-test-server/>. For demonstration
purpose, the configuration shown uses insecureNoSSL: true. In production, you
should protect LDAP communication with a
properly configured transport layer security (TLS). When using TLS, as an
admin, you can add insecureSkipVerify: true to
spec.ldap to skip server certificate verification, if needed.

Procedure

Choose whether to establish an external LDAP globally or for a specific
workspace.

» Global LDAP - identity provider serves all workspaces: Create and apply the
following objects:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
name: ldap-password
namespace: kommander
type: Opaque
stringData:
password: password
---
apiVersion: dex.mesosphere.io/v1alpha1
kind: Connector
metadata:
```

| Dashboard | Role | Path | Access |
| --------- | ---- | ---- | ------ |

```yaml
name: ldap
namespace: kommander
spec:
enabled: true
type: ldap
displayName: LDAP Test
ldap:
host: ldap.forumsys.com:389
insecureNoSSL: true
bindDN: cn=read-only-admin,dc=example,dc=com
bindSecretRef:
name: ldap-password
userSearch:
baseDN: dc=example,dc=com
filter: "(objectClass=inetOrgPerson)"
username: uid
idAttr: uid
emailAttr: mail
groupSearch:
baseDN: dc=example,dc=com
filter: "(objectClass=groupOfUniqueNames)"
userMatchers:
- userAttr: DN
groupAttr: uniqueMember
nameAttr: ou
EOF
Note: The value for the LDAP connector spec:displayName (here LDAP Test) appears on the Login button
for this identity provider in the NKP UI. Enter a name for the users.
```

» Workspace LDAP - identity provider serves a specific workspace: Create and
apply the following objects:

> **Note: Establish LDAP for a specific workspace in the scope of multiple
> tenants.**

- 1. Obtain the workspace name for which you are establishing an LDAP
     authentication server.

```bash
kubectl get workspaces
```

Note down the value under the WORKSPACE NAMESPACE column. 2. Set the
WORKSPACE_NAMESPACE environment variable to that namespace.

```bash
export WORKSPACE_NAMESPACE=<your-namespace>
```

1. Create and apply the following objects on that workspace.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
name: ldap-password
namespace: ${WORKSPACE_NAMESPACE}
type: Opaque
stringData:
password: password
---
apiVersion: dex.mesosphere.io/v1alpha1
kind: Connector
metadata:
name: ldap
namespace: ${WORKSPACE_NAMESPACE}
spec:
enabled: true
type: ldap
displayName: LDAP Test
ldap:
host: ldap.forumsys.com:389
insecureNoSSL: true
bindDN: cn=read-only-admin,dc=example,dc=com
bindSecretRef:
name: ldap-password
userSearch:
baseDN: dc=example,dc=com
filter: "(objectClass=inetOrgPerson)"
username: uid
idAttr: uid
emailAttr: mail
groupSearch:
baseDN: dc=example,dc=com
filter: "(objectClass=groupOfUniqueNames)"
userMatchers:
- userAttr: DN
groupAttr: uniqueMember
nameAttr: ou
EOF
Note: The value for the LDAP connector spec:displayName (here LDAP Test) appears
on the Login button for this identity provider in the NKP UI. Choose a name for the users.
```

##### Testing the LDAP Connector

You can test the LDAP connector.

Procedure

1. To retrieve a list of connectors using the kubectl get
   connector.dex.mesosphere.io -A command.
2. Run the kubectl get Connector.dex.mesosphere.io -n kommander `<LDAP-
CONNECTOR-NAME>` -o

yaml command to verify that the LDAP connector is created successfully.

##### Logging In for Global LDAP

Global LDAP identity provider serves all workspaces.

Procedure

1. Visit `<https://`>`<YOUR-CLUSTER-HOST>`/token and initiate a login flow.
2. On the login page, click Log in with `<ldap-name>`.
3. Enter the LDAP credentials and log in.

```yaml
Note: In the UI, after the LDAP authentication is enabled, additional access rights must be configured using the
Add Identity Provider page in the UI.
```

##### Logging In for Workspace LDAP

Workspace LDAP identity provider serves a specific workspace.

| https:// | `<YOUR-CLUSTER-HOST>` | /token |
| -------- | --------------------- | ------ |

Procedure

1. Complete the steps in Generating a Dedicated Login URL for Each Tenant on
   page 414.
2. On the login page, click Log in with `<ldap-name>`.
3. Enter the LDAP credentials and log in.

```yaml
Note: In the UI, after the LDAP authentication is enabled, additional access rights must be configured using the
Add Identity Provider page in the UI.
```

##### LDAP Troubleshooting

If the Dex LDAP connector configuration is incorrect, you must debug the
problem, and iterate on it to identify and resolve the issue. The Dex log
output contains error messages that must be reviewed, as indicated in the
following examples:

###### Reading Errors During Dex Startup

About this task

If the Dex configuration fragment provided results in an invalid Dex config
log file, Dex does not properly start up. Then, read the error details by
reviewing the Dex logs.

Procedure

1. Use the following command to retrieve the Dex logs.

```bash
kubectl logs -f dex-66675fcb7c-snxb8 -n kommander
```

You may see an error similar to the following example:

```bash
error parse config file /etc/dex/cfg/config.yaml: error unmarshaling JSON: parse
connector config: illegal base64 data at input byte 0
```

1. Another reason for Dex not starting up correctly is that `<https://`>`<YOUR-
CLUSTER-HOST>`/token displays a 5xx HTTP error response after timing out.

###### Errors Upon Login

Most problems with the Dex LDAP connector configuration become apparent only
after a login attempt. A login that fails from misconfiguration results in an
error displaying only Internal Server Error and Login error. You can find the
root cause by reading the Dex log, as shown in the following example.

```bash
kubectl logs -f dex-5d55b6b94b-9pm2d -n kommander
```

You can look for output similar to this example.

```bash
[...]
time="2019-07-29T13:03:57Z" level=error msg="Failed to login user: failed to connect:
LDAP Result Code 200 \"Network Error\": dial tcp: lookup freeipa.example.com on
10.255.0.10:53: no such host"
```

Here, the directory's DNS name was misconfigured, which should be easy to
address.

A more difficult problem occurs when a login through Dex through LDAP fails
because Dex cannot find the specified user unambiguously in the directory.
That is the result of an invalid LDAP user search configuration. Here's an
example error message from the Dex log.

```bash
time="2019-07-29T14:21:27Z" level=info msg="performing ldap search
cn=users,cn=compat,dc=demo1,dc=freeipa,dc=org sub (&(objectClass=posixAccount)
(uid=employee))"
time="2019-07-29T14:21:27Z" level=error msg="Failed to login user: ldap: filter
returned multiple (2) results: \"(&(objectClass=posixAccount)(uid=employee))\""
```

Solving problems like this requires you to review the directory structures
carefully. Directory structures can be very different between different LDAP
setups. You must carefully assemble a user search configuration matching the
directory structure.

Notably, with some directories, it can be hard to distinguish between the
cases such as properly configured and user not found where login fails in an
expected way and displays not properly configured, and therefore user not
found where login fails in an unexpected way.

###### Successful Login Example

For comparison, here are some sample log lines issued by Dex for a successful
login:

```bash
time="2019-07-29T15:35:51Z" level=info msg="performing ldap search
cn=accounts,dc=demo1,dc=freeipa,dc=org sub (&(objectClass=posixAccount)
(uid=employee))"
time="2019-07-29T15:35:52Z" level=info msg="username \"employee\" mapped to entry
uid=employee,cn=users,cn=accounts,dc=demo1,dc=freeipa,dc=org"
time="2019-07-29T15:35:52Z" level=info msg="login successful: connector \"ldap\",
username=\"\", email=\"employee@demo1.freeipa.org\", groups=[]"
```

#### Kubectl API Access Using an Identity Provider

To allow other users and user groups to access your environment, Nutanix
recommends setting up an external identity provider. Users added through an
identity provider do not have static credentials, but have to generate a token
to gain access to your environment's kubectl API. This token ensures that
certificates are rotated continuously for security reasons.

There are two options for the generation of this token:

Table 22: Token Generation

Generating a token User must log in with credentials and manually generate a
kubeconfig file with a fresh token every 24 hours.

Enabling the Konvoy Async Plugin

User configures the Konvoy Async Plugin so the authentication is routed
through Dex's oidc and the token is generated automatically. By enabling the
plugin, the user is routed to an additional login procedure for
authentication, but they no longer have to generate a token manually in the
UI.

The instructions for either generating a token manually or enabling the Konvoy
Async Plugin differ slightly depending on whether you configured the identity
provide globally for all the workspaces, or individually for a single
workspace.

| Method | How Often Does the User Have to Generate a Token? |
| ------ | ------------------------------------------------- |

##### Configuring Token Authentication for Global Identity Providers

In this scenario, the Identity Provider serves all workspaces.

About this task

> **Note: You must manually generate a new token every 24 hours:**

About this task

Procedure

1. Log in to the NKP UI with your credentials.
2. Select your username.
3. Select Generate Token.
4. Login again.
5. If there are several clusters, select the target cluster.
6. Follow the instructions on the displayed page.

##### Enabling the Konvoy Async Plugin for Global Identity Providers

Enable the Konvoy Async Plugin to automatically update the token.

Before you begin

You or a global admin must configure an identity provider to see this option.

Procedure

1. Open the login URL.
2. To authenticate, select Konvoy credentials plugin instructions.
3. Follow the instructions on the displayed (Konvoy) Credentials plugin
   instructionspage.

If you use Method 1 in the instructions documented in the (Konvoy) Credentials
plugin instructions, then download a kubeconfig file that includes the
contexts for all clusters.

Alternatively, to switch between clusters, you can use Method 2 to create a
kubeconfig file per cluster and use the --kubeconfig= flag or export
KUBECONFIG= commands.

```yaml
Warning: If you choose Method 2, the Set profile name field is not optional if you have multiple clusters in
your environment. Ensure you change the name of the profile for each cluster for which you want to generate a
kubeconfig file. Otherwise, all clusters will use the same token, which makes cluster authentication vulnerable
and can let users access clusters for which they do not have authorization.
```

##### Configuring Token Authentication for Workspace Identity Providers

In this scenario, the identity provider serves a specific workspace or tenant.

About this task

> **Note: You must manually generate a new token every 24 hours:**

Procedure

1. Open the login link you obtained from the global administrator, which they
   generated for your workspace or tenant.
2. Select Generate Kubectl Configuration.
3. If there are several clusters in the workspace, select the cluster for
   which you want to generate a token.
4. Log in with your credentials.
5. Follow the instructions on the page displayed.

##### Enabling the Konvoy Async Plugin for Workspace Identity Providers

Enable the Konvoy Async Plugin to automatically update the token.

Before you begin

You or a global admin must configure a workspace-scoped identity provider to
see this option.

Procedure

1. Open the login link you obtained from the global administrator, which they
   generated for your workspace or tenant.
2. Select Credentials plugin instructions.
3. Follow the instructions on the (Konvoy) Credentials plugin instructions page.

If you use Method 1 in the instructions documented in the (Konvoy) Credentials
plugin instructions, then download a kubeconfig file that includes the
contexts for all clusters.

Alternatively, to switch between clusters, you can use Method 2 to create a
kubeconfig file per cluster and use the --kubeconfig= flag or export
KUBECONFIG= commands.

```yaml
Warning: If you choose Method 2, the Set profile name field is not optional if you have multiple clusters in
your environment. Ensure you change the name of the profile for each cluster for which you want to generate a
kubeconfig file. Otherwise, all clusters will use the same token, which makes cluster authentication vulnerable
and can let users access clusters for which they do not have authorization.
```

##### Frequently Asked Questions

What happens if I have several clusters in my environment?

Each cluster has a unique API server address, and each cluster requires a
unique token.

There are several things you can do to have access to several clusters.

If you decide to manually create a kubeconfig file with a fresh token every 24
hours, you must do this for each cluster in your environment.

If you decide to enable the Konvoy Async Plugin to automatically refresh the
token, you can use the Method 1 steps documented in the (Konvoy) Credentials
plugin instructions page to download a kubeconfig that includes the contexts
for all clusters.

Alternatively, you can use the Method 2 steps documented in the (Konvoy)
Credentials plugin instructions page to create a kubeconfig file per cluster,
and use the --kubeconfig= flag export KUBECONFIG= or commands to switch
between clusters.

```yaml
Warning: If you choose Method 2, the Set profile name field is not optional if you have multiple clusters in
your environment. Ensure you change the name of the profile for each cluster for which you want to generate a
kubeconfig file. Otherwise, all clusters will use the same token, which makes cluster authentication vulnerable and
can let users access clusters for which they do not have authorization.
```

How does NKP ensure that users only see the login options for their specific
workspace?

NKP supports multi-tenancy by enabling administrators to configure dedicated
Identity Providers per workspace/ tenant. Given that a user employs a
dedicated workspace login URL to access the NKP UI, the user only sees the
login options (and IdPs) available in said workspace.

What is a kubeconfig file?

A file that is used to configure access to clusters is called a kubeconfig file.

The kubectl and NKP command-line tools use kubeconfig files to find the
information it needs to choose a cluster and communicate with the API server
of a cluster.

In NKP, a kubeconfig file is created automatically when you create a cluster,
but it requires a valid token to obtain access to it.

For more information, see Provide Context for Commands with a kubeconfig File.

### Rotating the NKP Dashboard Password

About this task

The NKP dashboard uses a static local administrator account as a backup
credential. Rotating the password invalidates existing sessions and any stored
copies of the previous password. Retrieve the new password with the nkp get
dashboard command after the rotation completes.

Procedure

1. Open a terminal with access to the NKP CLI.
2. Rotate the dashboard password:

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

If you decline the prompt, the command aborts without changing the password:

```bash
Aborted. The dashboard password was not rotated.
```

To skip this prompt in non-interactive terminals, add the --yes flag:

```bash
nkp rotate dashboard-credentials --yes
```

1. Retrieve the new dashboard credentials:

```bash
nkp get dashboard --kubeconfig=${CLUSTER_NAME}.conf
```

The user name, new password, and dashboard URL appear in the command output.
Store the new password securely.

What to do next

The static local credentials are backup credentials. For regular user access,
configure an external identity provider. For more information, see Identity
Providers.

### Infrastructure Providers

- NKP Pro supports multi-cluster environment, with a single management cluster
  and one or more attached or managed clusters of the same infrastructure
  provider.

#### Configuring a Nutanix Infrastructure Provider in the UI

- For AWS, see Configuring an AWS Infrastructure Provider with a User Role on
  page 310
- For Azure, Configuring an Azure Infrastructure Provider in the UI on page 323
- For vSphere, see Configuring a vSphere Infrastructure Provider in the UI on
  page 324

Infrastructure provider credentials are configured in each workspace. The name
you assign must be unique across all the other namespaces in your cluster.

### Infrastructure Providers (2)

About this task

Before you provision Nutanix clusters using the NKP user interface, you must
first create a Nutanix infrastructure provider to contain your Prism Central
credentials.

To add a single or multiple Nutanix infrastructures and contain your Prism
Central credentials, follow these steps:

Procedure

1. Log in to the NKP dashboard.
2. In the top-left corner, from the dropdown list, select the target workspace.

By default, NKP displays the Global workspace. 4. Click Add Infrastructure
Provider.

The Add Infrastructure Provider page appears. 5. In the Workspace dropdown
menu, select the workspace for your infrastructure provider.

NKP automatically creates the new infrastructure provider in that workspace. 6. From the Select Infrastructure Provider, select Nutanix and add the
following information:

a. In the Name field, enter a name for your infrastructure provider.

b. In the Prism Central Endpoint field, enter the endpoint URL of Prism Central.

The Prism Central endpoint must be in the format `https://<Prism Central IP Address or FQDN>:9440`

c. In the Username field, enter a valid Prism Central username.

d. In the Password field, enter a valid Prism Central user password.

e. To upload the trust bundle, follow these steps:

1. Click Upload File. 2. Browse to the location of the Prism Central endpoint
   certificate and click Open.

f. Click Save.

#### Configuring an AWS Infrastructure Provider with a User Role

Before you begin

Before creating an AWS Infrastructure Provider in the NKP user interface,
ensure that you manually create a user role. For more information, see Create
a Role Manually on page 311

About this task

Create your infrastructure provider to add resources to your AWS account. For
more flexible credential configuration and third-party access, NKP offers a
role-based authentication method with an optional external ID. For more
information, see IAM roles for Amazon EC2.

> **Note:**

- Nutanix recommends using the role-based method as it is more secure.
- If your management cluster runs on AWS, you can use the role authentication
  method.

To create a single or multiple AWS infrastructure provider with a user role,
follow these steps:

Procedure

1. Log in to the NKP dashboard.
2. In the top-left corner, from the dropdown list, select the target workspace.

By default, NKP displays the Global workspace. 3. From the left navigation
pane, click Administration > Infrastructure Providers. 4. Click Add
Infrastructure Provider.

The Add Infrastructure Provider page appears. 5. In the Workspace dropdown
menu, select the workspace for your infrastructure provider.

NKP automatically creates the new infrastructure provider in that workspace. 6. From the Select Infrastructure Provider, select Amazon Web Services (AWS)
and add the following information:

a. In the Name field, enter a name for your infrastructure provider.

Select a name that matches the AWS user.

b. To configure the AWS infrastructure provider with the user role, in the
Authentication Method dropdown list, select Role.

Ensure to select Role as the authentication method only when your management
cluster runs on AWS.

c. In the Role ARN field, enter the unique identifier of the IAM role.

d. (Optional) To share the role with a third-party account or service, in the
External ID field, add a secret string or unique identifier of that account or
service.

External IDs secure your environment from accidentally used roles. For more
information see Access to AWS accounts owned by third parties.

e. Click Save.

##### Create a Role Manually

About this task

The role must grant permissions to create the following resources in the AWS
account:

- EC2 Instances
- VPC
- Subnets
- Elastic Load Balancer (ELB)
- Internet Gateway
- NAT Gateway
- Elastic Block Storage (EBS) Volumes
- Security Groups
- Route Tables
- IAM Roles

Procedure

1. The user you delegate from your role must have a minimum set of
   permissions. The following snippet is the minimal IAM policy required.

```bash
{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Action": [
"ec2:AllocateAddress",
"ec2:AssociateRouteTable",
"ec2:AttachInternetGateway",
"ec2:AuthorizeSecurityGroupIngress",
"ec2:CreateInternetGateway",
"ec2:CreateNatGateway",
"ec2:CreateRoute",
"ec2:CreateRouteTable",
"ec2:CreateSecurityGroup",
"ec2:CreateSubnet",
"ec2:CreateTags",
"ec2:CreateVpc",
"ec2:ModifyVpcAttribute",
"ec2:DeleteInternetGateway",
"ec2:DeleteNatGateway",
"ec2:DeleteRouteTable",
"ec2:DeleteSecurityGroup",
"ec2:DeleteSubnet",
"ec2:DeleteTags",
"ec2:DeleteVpc",
"ec2:DescribeAccountAttributes",
"ec2:DescribeAddresses",
"ec2:DescribeAvailabilityZones",
"ec2:DescribeInstances",
"ec2:DescribeInternetGateways",
"ec2:DescribeImages",
"ec2:DescribeNatGateways",
"ec2:DescribeNetworkInterfaces",
"ec2:DescribeNetworkInterfaceAttribute",
"ec2:DescribeRouteTables",
"ec2:DescribeSecurityGroups",
"ec2:DescribeSubnets",
"ec2:DescribeVpcs",
"ec2:DescribeVpcAttribute",
"ec2:DescribeVolumes",
"ec2:DetachInternetGateway",
"ec2:DisassociateRouteTable",
"ec2:DisassociateAddress",
"ec2:ModifyInstanceAttribute",
"ec2:ModifyNetworkInterfaceAttribute",
"ec2:ModifySubnetAttribute",
"ec2:ReleaseAddress",
"ec2:RevokeSecurityGroupIngress",
"ec2:RunInstances",
"ec2:TerminateInstances",
"tag:GetResources",
"elasticloadbalancing:AddTags",
"elasticloadbalancing:CreateLoadBalancer",
"elasticloadbalancing:ConfigureHealthCheck",
"elasticloadbalancing:DeleteLoadBalancer",
"elasticloadbalancing:DescribeLoadBalancers",
"elasticloadbalancing:DescribeLoadBalancerAttributes",
"elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
"elasticloadbalancing:DescribeTags",
"elasticloadbalancing:ModifyLoadBalancerAttributes",
"elasticloadbalancing:RegisterInstancesWithLoadBalancer",
"elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
"elasticloadbalancing:RemoveTags",
"autoscaling:DescribeAutoScalingGroups",
"autoscaling:DescribeInstanceRefreshes",
"ec2:CreateLaunchTemplate",
"ec2:CreateLaunchTemplateVersion",
"ec2:DescribeLaunchTemplates",
"ec2:DescribeLaunchTemplateVersions",
"ec2:DeleteLaunchTemplate",
"ec2:DeleteLaunchTemplateVersions",
"ec2:DescribeKeyPairs"
],
"Resource": ["*"]
},
{
"Effect": "Allow",
"Action": [
"autoscaling:CreateAutoScalingGroup",
"autoscaling:UpdateAutoScalingGroup",
"autoscaling:CreateOrUpdateTags",
"autoscaling:StartInstanceRefresh",
"autoscaling:DeleteAutoScalingGroup",
"autoscaling:DeleteTags"
],
"Resource": [
"arn:*:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/*"
]
},
{
"Effect": "Allow",
"Action": ["iam:CreateServiceLinkedRole"],
"Resource": [
"arn:*:iam::*:role/aws-service-role/autoscaling.amazonaws.com/
AWSServiceRoleForAutoScaling"
],
"Condition": {
"StringLike": { "iam:AWSServiceName": "autoscaling.amazonaws.com" }
}
},
{
"Effect": "Allow",
"Action": ["iam:CreateServiceLinkedRole"],
"Resource": [
"arn:*:iam::*:role/aws-service-role/elasticloadbalancing.amazonaws.com/
AWSServiceRoleForElasticLoadBalancing"
],
"Condition": {
"StringLike": {
"iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
}
}
},
{
"Effect": "Allow",
"Action": ["iam:CreateServiceLinkedRole"],
"Resource": [
"arn:*:iam::*:role/aws-service-role/spot.amazonaws.com/
AWSServiceRoleForEC2Spot"
],
"Condition": {
"StringLike": { "iam:AWSServiceName": "spot.amazonaws.com" }
}
},
{
"Effect": "Allow",
"Action": ["iam:PassRole"],
"Resource": ["arn:*:iam::*:role/*.cluster-api-provider-aws.sigs.k8s.io"]
},
{
"Effect": "Allow",
"Action": [
"secretsmanager:CreateSecret",
"secretsmanager:DeleteSecret",
"secretsmanager:TagResource"
],
"Resource": ["arn:*:secretsmanager:*:*:secret:aws.cluster.x-k8s.io/*"]
},
{
"Effect": "Allow",
"Action": ["ssm:GetParameter"],
"Resource": ["arn:*:ssm:*:*:parameter/aws/service/eks/optimized-ami/*"]
},
{
"Effect": "Allow",
"Action": ["iam:CreateServiceLinkedRole"],
"Resource": [
"arn:*:iam::*:role/aws-service-role/eks.amazonaws.com/
AWSServiceRoleForAmazonEKS"
],
"Condition": {
"StringLike": { "iam:AWSServiceName": "eks.amazonaws.com" }
}
},
{
"Effect": "Allow",
"Action": ["iam:CreateServiceLinkedRole"],
"Resource": [
"arn:*:iam::*:role/aws-service-role/eks-nodegroup.amazonaws.com/
AWSServiceRoleForAmazonEKSNodegroup"
],
"Condition": {
"StringLike": { "iam:AWSServiceName": "eks-nodegroup.amazonaws.com" }
}
},
{
"Effect": "Allow",
"Action": ["iam:CreateServiceLinkedRole"],
"Resource": [
"arn:aws:iam::*:role/aws-service-role/eks-fargate-pods.amazonaws.com/
AWSServiceRoleForAmazonEKSForFargate"
],
"Condition": {
"StringLike": { "iam:AWSServiceName": "eks-fargate.amazonaws.com" }
}
},
{
"Effect": "Allow",
"Action": ["iam:GetRole", "iam:ListAttachedRolePolicies"],
"Resource": ["arn:*:iam::*:role/*"]
},
{
"Effect": "Allow",
"Action": ["iam:GetPolicy"],
"Resource": ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
},
{
"Effect": "Allow",
"Action": [
"eks:DescribeCluster",
"eks:ListClusters",
"eks:CreateCluster",
"eks:TagResource",
"eks:UpdateClusterVersion",
"eks:DeleteCluster",
"eks:UpdateClusterConfig",
"eks:UntagResource",
"eks:UpdateNodegroupVersion",
"eks:DescribeNodegroup",
"eks:DeleteNodegroup",
"eks:UpdateNodegroupConfig",
"eks:CreateNodegroup",
"eks:AssociateEncryptionConfig"
],
"Resource": ["arn:*:eks:*:*:cluster/*", "arn:*:eks:*:*:nodegroup/*/*/*"]
},
{
"Effect": "Allow",
"Action": [
"eks:ListAddons",
"eks:CreateAddon",
"eks:DescribeAddonVersions",
"eks:DescribeAddon",
"eks:DeleteAddon",
"eks:UpdateAddon",
"eks:TagResource",
"eks:DescribeFargateProfile",
"eks:CreateFargateProfile",
"eks:DeleteFargateProfile"
],
"Resource": ["*"]
},
{
"Effect": "Allow",
"Action": ["iam:PassRole"],
"Resource": ["*"],
"Condition": {
"StringEquals": { "iam:PassedToService": "eks.amazonaws.com" }
}
},
{
"Effect": "Allow",
"Action": ["kms:CreateGrant", "kms:DescribeKey"],
"Resource": ["*"],
"Condition": {
"ForAnyValue:StringLike": {
"kms:ResourceAliases": "alias/cluster-api-provider-aws-*"
}
}
}
]
}
```

Ensure to add a correct trust relationship to the created role.

This provides everyone within the same account to assign AssumeRole with the
created role. 2. Replace YOURACCOUNTRESTRICTION with the AWS Account ID that
you want AssumeRole from.

> **Note: Never add a \*/ wildcard. This opens your account to the public.**

```bash
{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Principal": {
"Service": "ec2.amazonaws.com",
"AWS": "arn:aws:iam::YOURACCOUNTRESTRICTION:root"
},
"Action": "sts:AssumeRole"
}
]
}
```

1. To use the role created, attach the following policy to the role which is
   already attached to your managed or attached cluster. Replace
   YOURACCOUNTRESTRICTION with the AWS Account ID where the role AssumeRole is
   saved. Also, replace THEROLEYOUCREATED with the AWS Role name.

```bash
{
"Version": "2012-10-17",
"Statement": [
{
"Sid": "AssumeRoleKommander",
"Effect": "Allow",
"Action": "sts:AssumeRole",
"Resource": "arn:aws:iam::YOURACCOUNTRESTRICTION:role/THEROLEYOUCREATED"
}
]
}
```

#### Configuring an AWS Infrastructure Provider with Static Credentials

About this task

When configuring AWS infrastructure provider with static credentials, you need
an access key ID and a secret access key for the IAM user with a set of
minimum capabilities. For more information, see

To create a single or multiple AWS infrastructure provider with static
credentials, follow these steps:

Procedure

1. Log in to the NKP dashboard.
2. In the top-left corner, from the dropdown list, select the target workspace.

By default, NKP displays the Global workspace. 3. From the left navigation
pane, click Administration > Infrastructure Providers. 4. Click Add
Infrastructure Provider.

The Add Infrastructure Provider page appears. 5. In the Workspace dropdown
menu, select the workspace for your infrastructure provider.

NKP automatically creates the new infrastructure provider in that workspace. 6. From the Select Infrastructure Provider, select Amazon Web Services (AWS)
and add the following information:

a. In the Name field, enter a name for your infrastructure provider.

Select a name that matches the AWS user.

b. To configure the AWS infrastructure provider with the static credentials,
in the Authentication Method dropdown list, select Static.

c. In the Access Key field, enter the access key ID of the IAM user.

d. In the Secret Key field, enter the secret access key of the IAM user.

e. Click Save.

##### Creating a User Using CLI

You can create a user using CLI.

Before you begin

Ensure that you install the AWS CLI utility. For more information, see Install
or update to the latest version of the AWS CLI.

About this task

To create a IAM user using AWS CLI, follow these steps:

Procedure

1. Create a user:

```bash
aws iam create-user --user-name Kommander
```

1. Create an IAM policy:

```bash
aws iam create-policy --policy-name kommander-policy --policy-document
'{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":
["ec2:AllocateAddress","ec2:AssociateRouteTable","ec2:AttachInternetGateway","ec2:AuthorizeSecur
["*"]},{"Effect":"Allow","Action":
["autoscaling:CreateAutoScalingGroup","autoscaling:UpdateAutoScalingGroup","autoscaling:CreateOr
["arn:*:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/*"]},
{"Effect":"Allow","Action":["iam:CreateServiceLinkedRole"],"Resource":
["arn:*:iam::*:role/aws-service-role/autoscaling.amazonaws.com/
AWSServiceRoleForAutoScaling"],"Condition":{"StringLike":
{"iam:AWSServiceName":"autoscaling.amazonaws.com"}}},
{"Effect":"Allow","Action":["iam:CreateServiceLinkedRole"],"Resource":
["arn:*:iam::*:role/aws-service-role/elasticloadbalancing.amazonaws.com/
AWSServiceRoleForElasticLoadBalancing"],"Condition":{"StringLike":
{"iam:AWSServiceName":"elasticloadbalancing.amazonaws.com"}}},
{"Effect":"Allow","Action":["iam:CreateServiceLinkedRole"],"Resource":
["arn:*:iam::*:role/aws-service-role/spot.amazonaws.com/
AWSServiceRoleForEC2Spot"],"Condition":{"StringLike":
{"iam:AWSServiceName":"spot.amazonaws.com"}}},{"Effect":"Allow","Action":
["iam:PassRole"],"Resource":["arn:*:iam::*:role/*.cluster-
api-provider-aws.sigs.k8s.io"]},{"Effect":"Allow","Action":
["secretsmanager:CreateSecret","secretsmanager:DeleteSecret","secretsmanager:TagResource"],"Reso
["arn:*:secretsmanager:*:*:secret:aws.cluster.x-k8s.io/*"]},
{"Effect":"Allow","Action":["ssm:GetParameter"],"Resource":["arn:*:ssm:*:*:parameter/
aws/service/eks/optimized-ami/*"]},{"Effect":"Allow","Action":
["iam:CreateServiceLinkedRole"],"Resource":["arn:*:iam::*:role/aws-service-
role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS"],"Condition":{"StringLike":
{"iam:AWSServiceName":"eks.amazonaws.com"}}},{"Effect":"Allow","Action":
["iam:CreateServiceLinkedRole"],"Resource":["arn:*:iam::*:role/aws-service-role/
eks-nodegroup.amazonaws.com/AWSServiceRoleForAmazonEKSNodegroup"],"Condition":
{"StringLike":{"iam:AWSServiceName":"eks-nodegroup.amazonaws.com"}}},
{"Effect":"Allow","Action":["iam:CreateServiceLinkedRole"],"Resource":
["arn:aws:iam::*:role/aws-service-role/eks-fargate-pods.amazonaws.com/
AWSServiceRoleForAmazonEKSForFargate"],"Condition":{"StringLike":
{"iam:AWSServiceName":"eks-fargate.amazonaws.com"}}},{"Effect":"Allow","Action":
["iam:GetRole","iam:ListAttachedRolePolicies"],"Resource":["arn:*:iam::*:role/
*"]},{"Effect":"Allow","Action":["iam:GetPolicy"],"Resource":
["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]},{"Effect":"Allow","Action":
["eks:DescribeCluster","eks:ListClusters","eks:CreateCluster","eks:TagResource","eks:UpdateClust
["arn:*:eks:*:*:cluster/*","arn:*:eks:*:*:nodegroup/*/*/*"]},
{"Effect":"Allow","Action":
["eks:ListAddons","eks:CreateAddon","eks:DescribeAddonVersions","eks:DescribeAddon","eks:DeleteA
["*"]},{"Effect":"Allow","Action":["iam:PassRole"],"Resource":
["*"],"Condition":{"StringEquals":{"iam:PassedToService":"eks.amazonaws.com"}}},
{"Effect":"Allow","Action":["kms:CreateGrant","kms:DescribeKey"],"Resource":
["*"],"Condition":{"ForAnyValue:StringLike":{"kms:ResourceAliases":"alias/cluster-
api-provider-aws-*"}}}]}'
```

1. Create an IAM attach-user policy:

```bash
aws iam attach-user-policy --user-name Kommander --policy-arn $(aws iam list-policies
--query 'Policies[?PolicyName==`kommander-policy`].Arn' | grep -o '".*"' | tr -d
'"')
```

1. Create an IAM access key:

```bash
aws iam create-access-key --user-name Kommander
```

##### Using an Existing User to Configure an AWS Infrastructure

You can use an existing AWS user with the credentials configured.

Before you begin

Ensure that you are authorized to create the following resources in the AWS
account:

- EC2 Instances
- VPC
- Subnets
- Elastic Load Balancer (ELB)
- Internet Gateway
- NAT Gateway
- Elastic Block Storage (EBS) Volumes
- Security Groups
- Route Tables
- IAM Roles

For more information, see Configuration and credential file settings in the
AWS CLI

Procedure

The following is the minimal IAM policy required.

```bash
{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Action": [
"ec2:AllocateAddress",
"ec2:AssociateRouteTable",
"ec2:AttachInternetGateway",
"ec2:AuthorizeSecurityGroupIngress",
"ec2:CreateInternetGateway",
"ec2:CreateNatGateway",
"ec2:CreateRoute",
"ec2:CreateRouteTable",
"ec2:CreateSecurityGroup",
"ec2:CreateSubnet",
"ec2:CreateTags",
"ec2:CreateVpc",
"ec2:ModifyVpcAttribute",
"ec2:DeleteInternetGateway",
"ec2:DeleteNatGateway",
"ec2:DeleteRouteTable",
"ec2:DeleteSecurityGroup",
"ec2:DeleteSubnet",
"ec2:DeleteTags",
"ec2:DeleteVpc",
"ec2:DescribeAccountAttributes",
"ec2:DescribeAddresses",
"ec2:DescribeAvailabilityZones",
"ec2:DescribeInstances",
"ec2:DescribeInternetGateways",
"ec2:DescribeImages",
"ec2:DescribeNatGateways",
"ec2:DescribeNetworkInterfaces",
"ec2:DescribeNetworkInterfaceAttribute",
"ec2:DescribeRouteTables",
"ec2:DescribeSecurityGroups",
"ec2:DescribeSubnets",
"ec2:DescribeVpcs",
"ec2:DescribeVpcAttribute",
"ec2:DescribeVolumes",
"ec2:DetachInternetGateway",
"ec2:DisassociateRouteTable",
"ec2:DisassociateAddress",
"ec2:ModifyInstanceAttribute",
"ec2:ModifyNetworkInterfaceAttribute",
"ec2:ModifySubnetAttribute",
"ec2:ReleaseAddress",
"ec2:RevokeSecurityGroupIngress",
"ec2:RunInstances",
"ec2:TerminateInstances",
"tag:GetResources",
"elasticloadbalancing:AddTags",
"elasticloadbalancing:CreateLoadBalancer",
"elasticloadbalancing:ConfigureHealthCheck",
"elasticloadbalancing:DeleteLoadBalancer",
"elasticloadbalancing:DescribeLoadBalancers",
"elasticloadbalancing:DescribeLoadBalancerAttributes",
"elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
"elasticloadbalancing:DescribeTags",
"elasticloadbalancing:ModifyLoadBalancerAttributes",
"elasticloadbalancing:RegisterInstancesWithLoadBalancer",
"elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
"elasticloadbalancing:RemoveTags",
"autoscaling:DescribeAutoScalingGroups",
"autoscaling:DescribeInstanceRefreshes",
"ec2:CreateLaunchTemplate",
"ec2:CreateLaunchTemplateVersion",
"ec2:DescribeLaunchTemplates",
"ec2:DescribeLaunchTemplateVersions",
"ec2:DeleteLaunchTemplate",
"ec2:DeleteLaunchTemplateVersions",
"ec2:DescribeKeyPairs"
],
"Resource": ["*"]
},
{
"Effect": "Allow",
"Action": [
"autoscaling:CreateAutoScalingGroup",
"autoscaling:UpdateAutoScalingGroup",
"autoscaling:CreateOrUpdateTags",
"autoscaling:StartInstanceRefresh",
"autoscaling:DeleteAutoScalingGroup",
"autoscaling:DeleteTags"
],
"Resource": [
"arn:*:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/*"
]
},
{
"Effect": "Allow",
"Action": ["iam:CreateServiceLinkedRole"],
"Resource": [
"arn:*:iam::*:role/aws-service-role/autoscaling.amazonaws.com/
AWSServiceRoleForAutoScaling"
],
"Condition": {
"StringLike": { "iam:AWSServiceName": "autoscaling.amazonaws.com" }
}
},
{
"Effect": "Allow",
"Action": ["iam:CreateServiceLinkedRole"],
"Resource": [
"arn:*:iam::*:role/aws-service-role/elasticloadbalancing.amazonaws.com/
AWSServiceRoleForElasticLoadBalancing"
],
"Condition": {
"StringLike": {
"iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
}
}
},
{
"Effect": "Allow",
"Action": ["iam:CreateServiceLinkedRole"],
"Resource": [
"arn:*:iam::*:role/aws-service-role/spot.amazonaws.com/
AWSServiceRoleForEC2Spot"
],
"Condition": {
"StringLike": { "iam:AWSServiceName": "spot.amazonaws.com" }
}
},
{
"Effect": "Allow",
"Action": ["iam:PassRole"],
"Resource": ["arn:*:iam::*:role/*.cluster-api-provider-aws.sigs.k8s.io"]
},
{
"Effect": "Allow",
"Action": [
"secretsmanager:CreateSecret",
"secretsmanager:DeleteSecret",
"secretsmanager:TagResource"
],
"Resource": ["arn:*:secretsmanager:*:*:secret:aws.cluster.x-k8s.io/*"]
},
{
"Effect": "Allow",
"Action": ["ssm:GetParameter"],
"Resource": ["arn:*:ssm:*:*:parameter/aws/service/eks/optimized-ami/*"]
},
{
"Effect": "Allow",
"Action": ["iam:CreateServiceLinkedRole"],
"Resource": [
"arn:*:iam::*:role/aws-service-role/eks.amazonaws.com/
AWSServiceRoleForAmazonEKS"
],
"Condition": {
"StringLike": { "iam:AWSServiceName": "eks.amazonaws.com" }
}
},
{
"Effect": "Allow",
"Action": ["iam:CreateServiceLinkedRole"],
"Resource": [
"arn:*:iam::*:role/aws-service-role/eks-nodegroup.amazonaws.com/
AWSServiceRoleForAmazonEKSNodegroup"
],
"Condition": {
"StringLike": { "iam:AWSServiceName": "eks-nodegroup.amazonaws.com" }
}
},
{
"Effect": "Allow",
"Action": ["iam:CreateServiceLinkedRole"],
"Resource": [
"arn:aws:iam::*:role/aws-service-role/eks-fargate-pods.amazonaws.com/
AWSServiceRoleForAmazonEKSForFargate"
],
"Condition": {
"StringLike": { "iam:AWSServiceName": "eks-fargate.amazonaws.com" }
}
},
{
"Effect": "Allow",
"Action": ["iam:GetRole", "iam:ListAttachedRolePolicies"],
"Resource": ["arn:*:iam::*:role/*"]
},
{
"Effect": "Allow",
"Action": ["iam:GetPolicy"],
"Resource": ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
},
{
"Effect": "Allow",
"Action": [
"eks:DescribeCluster",
"eks:ListClusters",
"eks:CreateCluster",
"eks:TagResource",
"eks:UpdateClusterVersion",
"eks:DeleteCluster",
"eks:UpdateClusterConfig",
"eks:UntagResource",
"eks:UpdateNodegroupVersion",
"eks:DescribeNodegroup",
"eks:DeleteNodegroup",
"eks:UpdateNodegroupConfig",
"eks:CreateNodegroup",
"eks:AssociateEncryptionConfig"
],
"Resource": ["arn:*:eks:*:*:cluster/*", "arn:*:eks:*:*:nodegroup/*/*/*"]
},
{
"Effect": "Allow",
"Action": [
"eks:ListAddons",
"eks:CreateAddon",
"eks:DescribeAddonVersions",
"eks:DescribeAddon",
"eks:DeleteAddon",
"eks:UpdateAddon",
"eks:TagResource",
"eks:DescribeFargateProfile",
"eks:CreateFargateProfile",
"eks:DeleteFargateProfile"
],
"Resource": ["*"]
},
{
"Effect": "Allow",
"Action": ["iam:PassRole"],
"Resource": ["*"],
"Condition": {
"StringEquals": { "iam:PassedToService": "eks.amazonaws.com" }
}
},
{
"Effect": "Allow",
"Action": ["kms:CreateGrant", "kms:DescribeKey"],
"Resource": ["*"],
"Condition": {
"ForAnyValue:StringLike": {
"kms:ResourceAliases": "alias/cluster-api-provider-aws-*"
}
}
}
]
}
```

#### Configuring an Azure Infrastructure Provider in the UI

About this task

Before you provision Azure clusters using the NKP user interface, you must
first create an Azure infrastructure provider to contain your Azure
credentials.

To add a single or multiple AWS infrastructures and contain your Azure
credentials, follow these steps:

Procedure

1. Log in to the Azure command line.

```bash
az login
```

1. Create an Azure service principal.

```bash
az ad sp create-for-rbac --role contributor --name "$(whoami)-konvoy" --scopes=/
subscriptions/$(az account show --query id -o tsv)
```

1. Log in to the NKP dashboard.
2. In the top-left corner, from the dropdown list, select the target workspace.

By default, NKP displays the Global workspace. 5. From the left navigation
pane, click Administration > Infrastructure Providers. 6. Click Add
Infrastructure Provider.

The Add Infrastructure Provider page appears. 7. In the Workspace dropdown
menu, select the workspace for your infrastructure provider.

NKP automatically creates the new infrastructure provider in that workspace. 8. From the Select Infrastructure Provider, select Microsoft Azure and add the
following information:

a. In the Subscription ID field, copy and paste the ID from the output of the
login command.

b. In the Tenant ID field, copy and paste the tenant value used for creating
Azure service principal.

c. In the Client ID field, copy and paste the appId value used for creating
Azure service principal.

d. In the Client Secret field, copy and paste the password value used for
creating Azure service principal.

e. Click Save.

#### Configuring a vSphere Infrastructure Provider in the UI

About this task

To add a single or multiple vSphere infrastructures, follow these steps:

Procedure

1. Log in to the NKP dashboard.
2. In the top-left corner, from the dropdown list, select the target workspace.

By default, NKP displays the Global workspace. 3. From the left navigation
pane, click Administration > Infrastructure Providers. 4. Click Add
Infrastructure Provider.

The Add Infrastructure Provider page appears. 5. In the Workspace dropdown
menu, select the workspace for your infrastructure provider.

NKP automatically creates the new infrastructure provider in that workspace. 6. From the Select Infrastructure Provider, select vSphere and add the
following information:

a. In the Name field, enter a name your infrastructure provider.

b. In the Username field, enter a valid vSphere vCenter username.

c. In the Password field, enter a valid vSphere vCenter user password.

d. In the Host URL field, enter the vSphere vCenter server URL.

Ensure that you add only the domain for the URL, such as vcenter.ca1.your-org-
platform.domain.cloud. Do not specify the protocol http:// to avoid errors
during cluster creation.

e. (Optional) In the TLS Certificate Thumbprint field, enter a valid SHA-1
thumbprint of the vSphere server TLS certificate.

The TLS certificate thumbprint creates a secure connection to VMware vCenter.
If you do not have a thumbprint, NKP might mark your connection as insecure.
You only need the TLS certificate thumbprint when you have a self-signed
vCenter instance.

To generate the SHA-1 thumbprint for the TLS certificate of vSpheres server,
the terminal with access to the NKP CLI and run the following command:

```bash
openssl s_client -connect <host url>:443 2>/dev/null | openssl x509 -noout -
fingerprint -sha1
```

f. Click Save.

#### Viewing and Modifying Infrastructure Providers

About this task

To view and modify an infrastructure provider, follow these steps:

Procedure

1. Log in to the NKP dashboard.
2. In the top-left corner, from the dropdown list, select the target workspace.

By default, NKP displays the Global workspace. 3. From the left navigation
pane, click Administration > Infrastructure Providers. The list of available
infrastructure providers appears. 4. To modify an infrastructure provider
information, click the triple dot vertical icon on that infrastructure
provider. 5. Click Edit.

> **Note: You cannot modify the default or any Nutanix infrastructure
> provider information.**

The Add Infrastructure Provider page appears. 6. After updating the required
information specific to your infrastructure provider, click Save.

#### Deleting an infrastructure provider

Before you begin

Ensure that no clusters are currently associated with the infrastructure
provider that you intend to delete.

About this task

To delete an infrastructure provider, follow these steps:

Procedure

1. Log in to the NKP dashboard.
2. In the top-left corner, from the dropdown list, select the target workspace.

By default, NKP displays the Global workspace. 3. From the left navigation
pane, click Administration > Infrastructure Providers. The list of available
infrastructure providers appears. 4. To delete an infrastructure provider,
click the triple dot vertical icon next to that infrastructure provider. 5.
Click Delete.

> **Note: You cannot delete the default Nutanix infrastructure provider.**

### Header, Footer, and Logo Implementation

NKP displays your header and footer banner in a default typeface and size,
which cannot be changed.

#### Creating a Header Banner

About this task

The Color selection control uses the style of your browser for its color
picker tool. This control allows you to select a color for your header banner:

Procedure

1. Enter the color's Hex code.
2. Select a general color range, and then select a specific shade or tint. The
   color input uses the style of your browser for its color selection tool.
3. Select the eyedropper, move it to a sample of the color you want and select
   once to select that color's location.

#### Creating a Footer Banner

About this task

The Color selection control uses the style of your browser for its color
picker tool. This control allows you to select a color for your footer banner:

Procedure

1. Enter the color's Hex code.
2. Select a general color range from the slider bar, and then select a
   specific shade or tint with your mouse cursor.
3. Select the eyedropper, move it to a sample of the color you want and select
   once to select that color's location.

#### Adding Your Organization's Logo Using the Drag and Drop Option

Before you begin

Your logo graphic must meet the following criteria:

- Use a suggested file format: PNG, SVG, or JPEG.
- The file size cannot exceed 200 KB.

Error messages affecting the file to upload appear below the image in red,
inside the shaded logo area.

```yaml
Note: To provide security against certain kinds of malicious activity, your browser has a same-origin policy for
accessing resources. When you upload a file, the browser creates a unique identifier for the file. This prevents you from
selecting a file more than once.
```

Procedure

1. Locate the required file in the MacOS Finder or Windows File Explorer.
2. Drag and drop an image of the appropriate file type into the shaded area to
   see a preview of the image and display the file name.

You can select X on the upper-right or Remove on the lower-right to clear the
image, if needed. 3. Click Save.

> **Warning: You cannot select a file for drag-and-drop if it does not have
> a valid image format.**

#### Adding Your Organization's Logo Using the Upload Option

Procedure

1. Select Browse Files.
2. To clear the image, select X or click the Remove link, if needed.
3. Click Save.

## Applications

### AppDeployment Resources

- Customizing Your Application on page 328
- Printing and Reviewing the Current State of an AppDeployment Resource on
  page 329

## Applications (2)

For example, this is the default AppDeployment for the Kube Prometheus Stack
platform application:

```yaml
apiVersion: apps.kommander.nutanix.io/v1alpha3
kind: AppDeployment
metadata:
name: kube-prometheus-stack
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: kube-prometheus-stack-82.13.6
kind: ClusterApp
```

### Customizing Your Application

About this task

For workspace applications, you can also enable and customize them on a per-
cluster basis. For instructions on how to enable and customize an application
per cluster in a given workspace, see Cluster-scoped Application for Existing
AppDeployments on page 373.

Before you begin

Set the WORKSPACE_NAMESPACE environment variable to the name of the
workspace's namespace where the cluster is attached:

```bash
export WORKSPACE_NAMESPACE=<your_workspace_namespace>
```

You can now copy the following commands without replacing the placeholder with
your workspace namespace every time you run a command.

Here's an example of how to customize the AppDeployment of Kube Prometheus
Stack:

Procedure

1. Provide the name of a ConfigMap with the custom configuration in the
   AppDeployment.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: kube-prometheus-stack
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: kube-prometheus-stack-82.13.6
kind: ClusterApp
configOverrides:
name: kube-prometheus-stack-overrides-attached
EOF
```

1. Create the ConfigMap with the name provided in the previous step, which
   provides the custom configuration on top of the default configuration.

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

### Printing and Reviewing the Current State of an AppDeployment Resource

About this task

You can review all the AppDeployments in a workspace or a specific
AppDeployments of an application in a workspace.

Procedure

You can run the following commands to review AppDeployments.

» Review all AppDeployments in a workspace: To review the state of the
AppDeployment resource for a specific workspace, run the get command with the
name of your workspace. Here's as example:

```bash
nkp get appdeployments -w kommander-workspace
```

The output displays a list of all your applications:

```bash
NAME APP CLUSTERS
[...]
kube-oidc-proxy kube-oidc-proxy-0.3.8 management
kube-prometheus-stack kube-prometheus-stack-82.13.6 management
[...]
```

» Review a Specific AppDeployment of an application in a workspace: To review
the state of a specific AppDeployment of an application, run the get command
with the name of the application and your workspace. Here's an example:

```bash
nkp get appdeployment kube-prometheus-stack -w kommander-workspace
```

The output is as follows:

```bash
NAME APP CLUSTERS
kube-prometheus-stack kube-prometheus-stack-82.13.6 management
```

> **Note: For more information on how to create, or get an AppDeployment,
> see the CLI documentation.**

### Deployment Scope

In a single-cluster environment with a Starter license, AppDeployments do not
allow for any customization.

In a single-cluster environment with a Pro license, AppDeployments enable
customizing any platform application.

In a multi-cluster environment with an Ultimate license, you can customize
AppDeployments to enable resource requirements, project applications, and
cluster-scoped applications for existing AppDeployments.

For more information on how to create, or get an AppDeployment, see the CLI
documentation.

### Logging Stack Application Sizing Recommendations

For information on how you customize your AppDeployments, see AppDeployment
Resources on page 327.

```yaml
Note: When configuring storage for logging-operator-logging-overrides, ensure that you create a
ConfigMap in your workspace namespace for every cluster in that workspace.
```

Keep in mind that you can configure logging-operator-logging-overrides only
through the CLI.

Table 23: Table

Logging Operator Logging Override Config

```bash
values.yaml: |-
clusterOutputs:
- name: loki
spec:
loki:
# change
${WORKSPACE_NAMESPACE} to
the actual value of your
workspace namespace
url: http://grafana-
loki-loki-distributed-gateway.
${WORKSPACE_NAMESPACE}.svc.cluster.local:8

extract_kubernetes_labels:
true

configure_kubernetes_labels:
true
buffer:
disabled: true
retry_forever:
false
retry_max_times: 5
flush_mode:
interval
flush_interval:
10s

flush_thread_count: 8
extra_labels:
log_source:
kubernetes_container
fluentbit:
inputTail:
Mem_Buf_Limit: 512MB
fluentd:
bufferStorageVolume:
emptyDir:
medium: Memory
disablePvc: true
scaling:
replicas: 10
resources:
requests:
memory: 1000Mi
cpu: 1000m
limits:
memory: 2000Mi
cpu: 1000m
```

50 1.4 MB/s

Loki ingester: replicas: 10 distributor: replicas: 2

```bash
values.yaml: |-
clusterOutputs:
- name: loki
spec:
loki:
# change (2)
${WORKSPACE NAMESPACE} to
```

- No. of Worker Nodes; Log Generating Load; Application; Suggested
  Configuration

| --- | --- | --- | --- |

- 100 8.5 MB/s Logging Operator Logging Override Config; values.yaml:; -
  clusterOutputs: - name: loki

| --- | --- | --- |

### Rook Ceph Cluster Sizing Recommendations

For information on how you customize your AppDeployments, see AppDeployment
Resources on page 327.

```yaml
Note: To add more storage to rook-ceph-cluster, copy and paste storageClassDeviceSets
list from the rook-ceph-cluster-your-ceph-version-d2iq-defaults ConfigMap
into your workspace where rook-ceph-cluster is present and then modify count and
volumeClaimTemplates.spec.resource.requests.storage .
```

| rook-ceph-cluster- | your-ceph-version | -d2iq-defaults |
| ------------------ | ----------------- | -------------- |

Table 24: Table

100 dkp: grafana-loki: additionalConfig:

| No. of Worker Nodes | Application | Suggested Configuration |
| ------------------- | ----------- | ----------------------- |

- 50 Rook Ceph Cluster; cephClusterSpec: labels: monitoring:
  prometheus.kommander.d2iq.io/select: "true" storage:
  storageClassDeviceSets: - name: rook-ceph-osd-set1 count: 4 portable: true
  encrypted: false placement: topologySpreadConstraints: - maxSkew: 1
  topologyKey: topology.kubernetes.io/zone # The nodes in the same rack have
  the same topology.kubernetes.io/zone label. whenUnsatisfiable:
  ScheduleAnyway labelSelector: matchExpressions: - key: app operator: In
  values: - rook-ceph-osd - rook-ceph-osd- prepare - maxSkew: 1 topologyKey:
  kubernetes.io/ hostname whenUnsatisfiable: ScheduleAnyway labelSelector:
  matchExpressions: - key: app operator: In values: - rook-ceph-osd - rook-
  ceph-osd- prepare volumeClaimTemplates: # If there are some faster devices
  and some slower devices, it is more efficient to use # separate metadata,
  wal, and data devices. # Refer `<https://rook.io/docs/>`
  rook/v1.10/CRDs/Cluster/pvc-cluster/ #dedicated-metadata-and-wal-device-
  for- osd-on-pvc - metadata: name: data spec: resources: requests: storage:
  120Gi volumeMode: Block accessModes: - ReadWriteOnce

| --- | --- |

### Application Management Using the UI

To ensure that the applications are deployed successfully, review them
carefully before customizing. There may be dependencies between the
applications, which are listed in Platform Applications Dependencies For All
Clusters on page 354.

```yaml
Note: To use the NKP CLI to deploy or uninstall applications, see Deploying Platform Applications Using CLI
on page 353.
```

#### Ultimate: Enabling an Application Using the UI

This topic describes how to enable your platform applications from the UI.

Procedure

1. Log into the NKP UI dashboard.
2. In the workspace header drop-down list, select your target workspace.
3. From the sidebar, browse through the available applications from your
   configured repositories, and select Applications.
4. Select the three-dot button of the desired application card > Enable.
5. If available, select a version from the dropdown list. The dropdown list is
   only visible if there are more than one versions to choose from.
6. Select the clusters where you want to deploy the application.
7. For customizations only: to override the default configuration values,
   follow these steps:

```yaml
Note: If there are customization Overrides at the workspace and cluster level, they are combined for
implementation. Cluster-level Overrides take precedence over Workspace Overrides.
```

a. To customize an application for all clusters in a workspace, copy your
customized values into the text editor under Workspace Application
Configuration or upload your YAML file that contains the values.

```bash
someField: someValue
```

b. To add a customization per cluster, copy the customized values into the
text editor of each cluster under Cluster Application Configuration Override
or upload your YAML file that contains the values.

```bash
someField: someValue
```

1. Verify that the details are correct and select Enable.

```yaml
Warning: There may be dependencies between the applications, which are listed in Platform Applications
Dependencies For All Clusters on page 354. Review them carefully before customizing to ensure that the
applications are deployed successfully.
```

##### Ultimate: Customizing an Application Using the UI

You can enable an application and customize it using the UI.

About this task

```yaml
Note: If you want to enable an application for the first time and customize it, see Ultimate: Enabling an
Application Using the UI on page 334.
```

To customize the applications that are deployed to a workspace's cluster using
the UI:

Procedure

1. From the top menu bar, select your target workspace.
2. From the sidebar, browse through the available applications from your
   configured repositories, and select Applications.
3. In the Application card you want to customize, select the three dot menu
   and Edit.
4. To override the default configuration values, follow these steps:

```yaml
Note: If there are customization Overrides at the workspace and cluster levels, they are combined for
implementation. Cluster-level Overrides take precedence over Workspace Overrides.
```

a. To customize an application for all clusters in a workspace, copy your
customized values into the text editor under Workspace Application
Configuration or upload your YAML file that contains the values.

```bash
someField: someValue
```

b. To add a customization per cluster, copy the customized values into the
text editor of each cluster under Cluster Application Configuration Override
or upload your YAML file that contains the values.

```bash
someField: someValue
```

1. Verify that the details are correct and select Save.

##### Ultimate: Customizing an Application For a Specific Cluster

You can also customize an application for a specific cluster from the Clusters
view:

Procedure

1. From the sidebar menu, select Clusters.
2. Select the target cluster.
3. Select the Applications tab.
4. Navigate to the target Applications card.
5. Select the triple dot vertical icon > Edit.

##### Ultimate: Verifying an Application using the UI

The application has now been enabled.

About this task

To verify that the application is deployed correctly:

Procedure

1. From the top menu bar, select your target workspace.
2. Select the cluster you want to verify.

a. Select Management Cluster if your target cluster is the Management Cluster
Workspace.

b. Otherwise, select Clusters, and choose your target cluster. 3. Select the
Applications tab and navigate to the application you want to verify. 4. If the
application was deployed successfully, the status Deployed appears in the
application card. Otherwise, hover over the failed status to obtain more
information on why the application failed to deploy.

```yaml
Note: It can take several minutes for the application to deploy completely. If the Deployed or Failed status is not
displayed, the deployment process is not finished.
```

##### Ultimate: Disabling an Application Using the UI

You can disable an application using the UI.

About this task

Follow these steps to disable an application with the UI:

Procedure

1. From the top menu bar, select your target workspace.
2. From the sidebar, browse through the available applications from your
   configured repositories, and select Applications.
3. Select the three-dot button of the desired application card and select
   Disable.
4. Follow the instructions on the confirmation pop-up message and select
   Disable Application.

#### Pro: Application Management Using the UI

You can enable an application and customize it using the UI.

You can deploy and uninstall an application using the UI.

```yaml
Note: To use the CLI to deploy or uninstall applications, see Deploying Platform Applications Using CLI on
page 353.
```

##### Pro: Enabling an Application Using the UI

About this task

To enable your platform applications from the UI in Kommander:

Procedure

1. Log into the NKP UI dashboard.
2. In the workspace header drop-down list, select your target workspace.
3. From the sidebar to browse through the available applications from your
   configured repositories, select Applications.
4. Select the three-dot button of the desired application card > Enable.
5. If available, select a version from the dropdown list. This dropdown list
   is only visible if there is more than one version to choose from.
6. For customizations only: to override the default configuration values,
   follow these steps:

a. To customize an application for all clusters in a workspace, copy your
customized values into the text editor under Workspace Application
Configuration or upload your YAML file that contains the values.

```bash
someField: someValue
```

1. Confirm the details are correct and then select Enable.

```yaml
Warning: There may be dependencies between the applications, which are listed in Platform Applications
Dependencies For All Clusters on page 354. Review them carefully before customizing to ensure that the
applications are deployed successfully.
```

##### Pro: Customizing an Application Using the UI

About this task

```yaml
Note: If you want to enable an application for the first time and customize it, see Ultimate: Enabling an
Application Using the UI on page 334.
```

To customize the applications that are deployed to your Management Cluster
cluster using the UI:

Procedure

1. Log into the NKP UI dashboard.
2. In the workspace header drop-down list, select your target workspace.
3. From the sidebar, browse through the available applications from your
   configured repositories and select Applications
4. In the Application card you want to customize, select the three dot menu
   and Edit.
5. To override the default configuration values, follow these steps:

```yaml
Note: If there are customization Overrides at the workspace and cluster level, they are combined for
implementation. Cluster-level Overrides take precedence over Workspace Overrides.
```

a. To customize an application for all clusters in a workspace, copy your
customized values into the text editor under Workspace Application
Configuration or upload your YAML file that contains the values.

```bash
someField: someValue
```

1. Verify that the details are correct and select Save.

##### Pro: Verifying an Application using the UI

The application has now been enabled.

About this task

To ensure that the application is deployed correctly:

Procedure

1. From the sidebar, select Management Cluster.
2. Select the Applications tab and navigate to the application you want to
   verify.
3. If the application was deployed successfully, the status Deployed appears
   in the application card. Otherwise, hover over the failed status to obtain
   more information on why the application failed to deploy.

```yaml
Note: It can take several minutes for the application to deploy completely. If the Deployed or Failed status is not
displayed, the deployment process is not finished.
```

##### Pro: Disabling an Application Using the UI

About this task

To disable an application with the UI:

Procedure

1. From the sidebar, browse through the available applications from your
   configured repositories and select Applications
2. Select the three-dot button of the desired application card and select
   Disable.
3. Follow the instructions on the confirmation pop-up message, and select
   Disable Application.

#### Deploying Harbor on a Management Cluster

Before you begin

Ensure you complete the following:

- Deploy CloudNativePG.
- Enable the CloudNativePG application on a NKP cluster.
- Get access to any of the following S3-compatible object storage options:
- Nutanix Objects: Nutanix Objects are well-integrated with Nutanix and
  managed by the COSI Driver for Nutanix. Nutanix Objects include a built-in
  lifecycle management for storage and manages the entire bucket lifecycle.
- S3 storage from other providers such as AWS, Azure, GCP, or any enterprise-
  grade S3 storage. The lifecycle management of external buckets are managed
  separately.
- Integrated Rook Ceph: You can set up integrated Rook Ceph as an S3 bucket
  within your infrastructure. You can install the Rook Ceph on the same NKP
  cluster. However, Rook Ceph shares storage with other internal applications
  which may cause space limitations.

It is recommended you choose an S3-compatible object storage based on the your
requirements:

- For production environments, choose either enterprise-grade S3 storage or
  Nutanix Object Storage, because these provide better scalability and
  lifecycle management.
- To avoid external dependency, choose integrated Rook Ceph instead of Nutanix
  Objects.
- Install and configure the Kubernetes CLI kubectl to interact with your
  cluster.
- Appropriate user credentials with permissions to create and manage resources.
- Ensure that storage requirements are according to Storage Requirements for
  Harbor on page 341.

To deploy Harbor on a management cluster, follow these steps:

Procedure

1. From the top menu bar, select Management Cluster Workspace.
2. Search for the required application:

» From the sidebar, select Applications, then browse through the available
applications,and navigate to the General section.

» In the Filter by Name field, enter CloudNativePG, Harbor, or COSI Driver For
Nutanix.

CloudNativePG, Harbor, or COSI Driver For Nutanix are displayed. 3. Enable
CloudNativePG.

a. In the search field, enter CloudNativePG, select the triple dot vertical
icon on the CloudNativePG application card.

b. Click Enable.

c. (Optional) Enter application overrides as per the environment. For example,
you can enter replicaCount: 2. 4. In the search field, enter Harbor, select
the triple dot vertical icon on the Harbor application card, and click Enable. 5. In the Enable Workspace Platform Application page, under S3 Configuration >
S3 Objects Store drop-down list, select one of the following options:

- Nutanix Objects: You do not have to provide additional information after
  selecting Nutanix Objects.

```yaml
Note: Ensure that you pre-install and configure the COSI Driver for Nutanix application. For more
information, see Configuring and Enabling COSI Driver for Nutanix in an NKP Cluster on
page 344.
```

- Rook Ceph: You do not have to provide additional information after selecting
  Rook Ceph.

> **Note: Ensure that you have enable the Rook Ceph Cluster application.**

- Manual Bucket Configuration: Provide the necessary URL and credentials for
  accessing the S3- compatible storage as follows:
- Endpoint: The endpoint URL for the S3-compatible object storage.
- Access Key: The key used to access the S3-compatible storage.
- Secret Key: The secret associated with the access key.
- Region: The geographical region where the bucket is hosted.
- Bucket: The name of the specific bucket where you store the container images.

1. Click Enable.
2. In the Platform Applications page, click the Configuration tab and verify
   the Harbor application details.
3. Retrieve the Harbor registry URL:

```bash
echo "https://$(kubectl get kommandercluster -A -l 'kommander.d2iq.io/host=true' -o
jsonpath='{.items[0].status.ingress.address}'):5000"
```

1. Retrieve default password for Harbor admin:

```bash
kubectl get secrets -n ncr-system harbor-admin-password -o
jsonpath='{.data.HARBOR_ADMIN_PASSWORD}' | base64 -d
```

1. Create a custom user for Harbor: Harbor has its own user management system,
   and the UI login credentials are validated by Harbor's authentication
   services. You can create separate accounts such as machine accounts for
   pulling images and human accounts for UI access. For more information on
   Harbor user management, see Managing Users.

a. Log in to Harbor UI with default credentials:

```bash
'admin/<retrieved-password>'
```

b. Select Administration > Users > NEW USER.

c. Enter information in all the fields and save.

d. (Optional) To assign an administration role to a newly created user, select
the custom user and click SET AS ADMIN. An end users can use this user
credentials for administration tasks instead of the default user generated by
Harbor.

What to do next

On completion of the steps above, you can perform the following steps to
deploy harbor:

- Preparing a Local Registry Mirror on page 736
- Pushing Images to the Registry on page 737

##### Storage Requirements for Harbor

Ensure that storage requirements are according to the following recommendations.

- It is recommended you have 100 GB storage space for most use cases.
- To use Harbor as an Open Container Initiative (OCI) registry for charts and
  other artifacts, ensure that you have sufficient storage based on the size
  of the artifacts and charts.
- To use Harbor as a pull-through cache for temporarily storing images, ensure
  that you have sufficient storage based on the number of images you need to
  cache.
- To use integrated Rook Ceph, increase the available storage. This is
  because, integrated Rook Ceph provides 120 GB of space by default which is
  shared with other services such as logging and backups. When you expand the
  integrated Rook Ceph storage, note that integrated Rook Ceph uses erasure
  coding. Therefore, you can use only 75% of the space. For example, if you
  add 100 GB, you can use only 75 GB to store data. For more information on
  how to configure auto expansion of Ceph OSDs, see Rook Ceph Cluster Sizing
  Recommendations and Auto Expansion of OSDs.

For example, to increase the integrated Rook Ceph storage from the default 4 x
40G to 8 x 40G, you can configure the following overrides:

```bash
cephClusterSpec:
labels:
monitoring:
prometheus.kommander.d2iq.io/select: "true"
storage:
storageClassDeviceSets:
- name: rook-ceph-osd-set1
count: 8 # Refers to the number of PVs
portable: true
encrypted: false
placement:
topologySpreadConstraints:
- maxSkew: 1
topologyKey: topology.kubernetes.io/zone # The nodes in the same rack
have the same topology.kubernetes.io/zone label.
whenUnsatisfiable: ScheduleAnyway
labelSelector:
matchExpressions:
- key: app
operator: In
values:
- rook-ceph-osd
- rook-ceph-osd-prepare
- maxSkew: 1
topologyKey: kubernetes.io/hostname
whenUnsatisfiable: ScheduleAnyway
labelSelector:
matchExpressions:
- key: app
operator: In
values:
- rook-ceph-osd
- rook-ceph-osd-prepare
volumeClaimTemplates:
- metadata:
name: data
spec:
resources:
requests:
storage: 40Gi # Size of each PV
volumeMode: Block
accessModes:
- ReadWriteOnce
```

##### Authentication types for launching workloads

Configure Certificate authority (CA) certificates to ensure the following:

- Secure TLS connections and cluster-wide credentials for management and
  workload clusters.
- Enabling secure and streamlined access to Harbor.
- Authenticated and encrypted communication between NKP clusters and the
  registry.
- Protection of sensitive image data.
- Simplify deployments.

Configure the CA certificate only if the NKP cluster where you install Harbor
is installed is using an ingress TLS certificate that was signed by a CA that
is not included in the OS trust bundles (private CA).

The authentication is different for Nutanix infrastructure and non-Nutanix
infrastructure.

###### Authentication for Nutanix Providers

You can configure NKP clusters using the Nutanix provider with multiple image
registries, including authentication and the CA certificate setup. You can
configure through the CLI or UI. However, there are limited options through
the UI only when launching a new NKP cluster. NKP clusters with Nutanix
provider can be configured with a registry mirror.

Configuring Through NKP UI

Configure the Harbor registry of the management cluster as a private registry
when launching a managed cluster. You can configure this through the NKP UI

- Image Registry Mirror: This is a general registry for pulling images from
  public registries. The NKP platform application images will be pulled from
  this registry. If you don't have a registry mirror, provide docker.io
  credentials here to avoid DockerHub registry pull limits.
- Private Registry: Enter information about the Harbor registry :

URL: Specify the location where the Harbor registry is running.

Username and Password: Specify the username and password. The username and
password are required for cluster-wide authentication of the newly launched
cluster.

CA Certificate: Provide a custom CA certificate if Harbor is running on an NKP
cluster with ingress TLS certificate that was signed by a private CA.

You cannot change this configuration using the UI. For reconfiguring private
image registries, reconfigure through CLI.

Configuring Through CLI

Use CLI to configure additional image registries on NKP Nutanix clusters after
the initial cluster launch. You can adjust configuration on management and
managed clusters. It is recommended to create a dedicated Harbor user or a
Harbor robot user and provide a dedicated set of credentials for each NKP
cluster.

Create a secret with credentials and CA certificate that will be used by
containerd.

```bash
REGISTRY_USERNAME="username"
REGISTRY_PASSWORD="password"
kubectl create secret generic harbor-registry-credentials \
--from-literal username=$REGISTRY_USERNAME \
--from-literal password=$REGISTRY_PASSWORD \
--from-file=ca.crt=<(kubectl -n kommander get nkpcluster -l 'kommander.d2iq.io/
host=true' -o jsonpath='{.items[0].kommanderCluster.status.ingress.caBundle}' | base64
-d)
```

- Include username and password only if cluster-wide authentication is required.
- Include ca.crt if Harbor is installed on cluster with a TLS certificate that
  is signed by a private CA
- You can create a secret with ca.crt without providing a username and password.
- If you include the username and password in the secret, the registry is
  authenticated at the cluster level.
- If only the ca.crt value will be present in the secret then the containerd
  will be able establish verified TLS connections to the private registry but
  won't be able to pull images from Harbor projects that require
  authentication. A Kubernetes imagePullSecret can be then used to provide
  credentials per workload.
- Get the address of Harbor installed on management cluster:

```bash
echo "https://$(kubectl -n kommander get nkpcluster -l 'kommander.d2iq.io/host=true'
-o jsonpath='{.items[0].kommanderCluster.status.ingress.address}'):5000"
```

- Modify the NKP cluster resource and add new image registry configuration to
  the .spec.capiCluster.topology.variables.imageRegistries section and replace
  the HARBOR_ADDRESS with the address from the previous step.

```yaml
apiVersion: clusters.nkp.nutanix.com/v1alpha1
kind: NKPCluster
metadata:
name: <NAME>
namespace: kommander
spec:
capiCluster:
topology:
variables:
- name: clusterConfig
value:
imageRegistries:
- url: <HARBOR_ADDRESS>
credentials:
secretRef:
name: harbor-registry-credentials
```

Changing the image registry configuration will result in a rolling upgrade of
all nodes in a cluster.

Configuring through Harbor

Harbor supports multiple authentication modes, including database, LDAP/AD,
and OpenID Connect (OIDC), which should be selected during initial deployment.
Once user accounts are created in database mode, switching to another
authentication method is not allowed. For more information, see Configuring
Authentication.

You can install Harbor within the management cluster using catalog
applications. After you install, you must ensure you have the correct
authorizations for image access. You can use Harbor to store and scan images
from both management and managed clusters. Therefore, you must manage
authorizations as per your requirements.

###### Limitations for non-Nutanix Infrastructure Providers

For non-Nutanix infrastructure providers such as AWS, vSphere, or GCP, you can
provide Harbor configuration only as a single cluster-wide registry mirror.
Therefore, each image pulled to the cluster will be first attempted with the
registry mirror, even for container images that are hosted in public
registries like docker.io which can increase the load on Harbor.

The limitations of non-Nutanix infrastructure providers are as follows:

- You can configure and apply Harbor settings only during the initial creation
  of the cluster.
- You can only use Harbor as a registry mirror which you can use as a local
  cache for images pulled from a remote registry.
- After you launch the cluster, you cannot change the Harbor configuration.
  You cannot modify the registry URL, credentials, or any other related
  settings.

##### Configuring and Enabling COSI Driver for Nutanix in an NKP Cluster

This topic provides the instructions to configure the COSI Driver for Nutanix
on an NKP cluster to enable seamless integration with Nutanix Object Storage.

About this task

To configure the COSI Driver for Nutanix on an NKP cluster, follow these steps:

Procedure

1. Configure Nutanix Object Storage in Prism Central, if not configured already.

a. Enable Objects in Nutanix Marketplace.

For more information, see Enabling Objects.

b. Create an Object Store from Prism Central.

For more information, see Creating or Deploying an Object Store on Prism
Central. 2. Configure the COSI Driver for Nutanix in the NKP UI.

a. Log in to the NKP Management Cluster UI.

b. Select Management Cluster Workspace from the dropdown menu.

c. On the left navigation page, select Applications as the storage provider.

d. Search for COSI Driver for Nutanix.

e. Select the triple dot vertical icon on the application card and click Enable.

f. In the Enable Workspace Platform Application dialog box, enter the
following details:

- Prism Central Endpoint: Enter the PC endpoint URL as
  `<https://`>`<PRISM_CENTRAL_IP>`:9440
- Prism Central Username: Enter the PC administrator username.
- Prism Central Password: Enter the PC administrator password.
- Enable TLS Validation: You can provide the Prism Central CA (Certificate
  Authority) certificate. This is a recommended but optional step. This
  certificate is used to validate the TLS connection and ensure secure
  communication between the NKP Cluster and Prism Central.

To provide the certificate, select the Enable TLS Validation checkbox. Then,
you can either select the Upload File button to import the CA certificate, or
paste the certificate into the text field.

- Nutanix Object Storage Endpoint: Enter the Nutanix Object Storage Endpoint
  URL: http:// `<nutanix-object-endpoint-ip/fqdn>`:`<port-number>` or
  https://`<nutanix-object- endpoint-ip/fqdn>`:`<port-number>`
- The Nutanix Object Storage Endpoint URL is referred as Public Network static
  IPs in Nutanix Objects.
- If you do not enter a port number , then port 80 is configured as the
  default port.
- Enable TLS Validation: You can provide the Nutanix Object Storage CA
  (Certificate Authority) certificate. This is a recommended but optional
  step. This certificate is used to validate the TLS connection and ensure
  secure communication between the NKP Cluster and Nutanix Object Storage .

To provide the certificate, select the Enable TLS Validation checkbox. Then,
you can either select the Upload File button to import the CA certificate, or
paste the certificate into the text field.

- Nutanix Object Access Key
- Nutanix Object Secret Key

> **Note: TLS requires a secure connection. Please ensure the URL starts
> with https:// when you enable TLS.**

g. Click Enable. The COSI Driver for Nutanix application is enabled.

#### Using Harbor on an NKP Cluster

Before you begin

Ensure you complete the following:

- Install NKP Management or Workload Cluster running on Nutanix infrastructure.
- Access to the NKP UI with administrative privileges.
- Install and configure the Kubernetes CLI kubectl to interact with your
  cluster.
- Access to Kubernetes cluster with the necessary permissions to create
  secrets and modify cluster configurations.
- Deploy and enable Harbor.
- Create Harbor registry credentials.
- Install Docker on your local machine.

For more information, see Managing Users.

- A valid container image to push to Harbor.
- Network connectivity between the cluster nodes and Harbor.

To use Harbor on an NKP management cluster on Nutanix infrastructure, follow
these steps:

Procedure

1. Use admin credentials to create a robot account for every cluster.

For more information on how to create a robot account , see Create Project
Robot Accounts. 2. Create a secret in Kubernetes for Harbor authentication
using the robot account credentials you created in the previous step. 3.
Modify the managed cluster resource:

```bash
kubectl edit nkpcluster -n kommander <WORKLOAD_CLUSTER_NAME>
```

1. Update the imageRegistries:

```bash
imageRegistries:
- url: https://<HARBOR_ADDRESS>:5000
credentials:
secretRef:
name: harbor-registry-credentials
```

Save and verify the changes. 5. Export the Harbor registry address:

```bash
export HARBOR_ADDRESS="$(kubectl -n kommander get kommandercluster -l
'kommander.d2iq.io/host=true' -o jsonpath='{.items[0].status.ingress.address}')"
```

This authenticates Docker with Harbor. 6. Modify deployment configuration to
use Harbor:

```bash
spec:
containers:
- name: my-app
image: <HARBOR_ADDRESS>:5000/library/my-app:latest
```

a. Deploy the application:

```bash
kubectl apply -f my-app-deployment.yaml
```

b. Verify the deployment:

```bash
kubectl get pods -n <namespace>
```

1. (Optional) Configure authentication for NKP clusters that need to access
   images for launching workloads:

a. Log on to Harbor, navigate to the dashboard, and create a new username and
password.

b. In the management cluster, create a secret ("harbor-registry-credentials" )
to store your Harbor credentials ("username"/"password") This Harbor registry
credentials allow the Management cluster to pull images from Harbor on the
Management Cluster to deploy an app.

c. After the deployment, fetch the Ingress TLS certificate (TLS certificate)
in case it is generated.

```bash
kubectl get kommandercluster -n kommander -l 'kommander.d2iq.io/host=true' -o
jsonpath='{.items[0].status.ingress.caBundle}' | base64 -d > ca.crt
```

Store the ca.crt for future configuration.

d. To enable secure access to Harbor, update the registry configuration by
creating a secret.

```bash
REGISTRY_USERNAME="username"
REGISTRY_PASSWORD="password"
kubectl create secret generic harbor-registry-credentials \
--from-literal username=$REGISTRY_USERNAME \
--from-literal password=$REGISTRY_PASSWORD \
--from-file=ca.crt=<(kubectl -n kommander get kommandercluster -o
jsonpath='{.status.ingress.caBundle}' | base64 -d)
```

> **Note: Include the ca.crt only if the Harbor installation uses a private
> CA signed certificate.**

##### Using Harbor as a Mirror Registry or a Private Registry for Clusters

This topic provides instructions for configuring Harbor running on the NKP
management cluster as a mirror registry for NKP clusters. Using Harbor as a
mirror registry ensures that clusters pull images from a local registry,
reducing latency, external dependencies, and security risks. This topic
described the process to configure Harbor as a mirror registry or a private
registry through the NKP UI.

About this task

> **Note: You can deploy Harbor as mirror registry for clusters across all
> infrastructure providers.**

Before you begin

- NKP Management or Workload Cluster installed and running on your
  infrastructure.
- Access to the NKP UI with administrative privileges.
- The Kubernetes CLI kubectl is installed and configured to interact with your
  cluster.
- Access to Kubernetes cluster with the necessary permissions to create
  secrets and modify cluster configurations.
- Deploy and enable Harbor.
- Create Harbor registry credentials.
- Install Docker on your local machine.

To use Harbor as a mirror registry or a private registry on an NKP cluster,
follow these steps:

Procedure

1. Deploy Harbor as described in Deploying Harbor on a Management Cluster on
   page 338.
2. Log into the Harbor UI using the following credentials.

- Username: admin
- Password: Retrieve the password.

```bash
kubectl get secrets -n ncr-system harbor-admin-password -o
jsonpath='{.data.HARBOR_ADMIN_PASSWORD}' | base64 -d
```

1. Go to Users > New User and complete the following fields: Use robot
   accounts for machine or cluster authentication. For more information on how
   to create a robot account , see Create Project Robot Accounts.

- Username: `<custom_user>`
- Email
- First and last name
- Password: `<secure_password>`
- Confirm Password

a. Click OK.

b. To provide administrator privileges for users, select the check box of the
corresponding user and click SET AS ADMIN. 4. Create a secret in Kubernetes
for Harbor authentication using the robot account credentials you created in
the previous step. 5. To configure the NKP management cluster to use Harbor,
retrieve the Harbor address.

```bash
echo "https://$(kubectl -n kommander get kommandercluster -l 'kommander.d2iq.io/
host=true' -o jsonpath='{.items[0].status.ingress.address}'):5000"
```

a. Modify the cluster resource through the NKP UI.

Select Clusters > Create Cluster > Image Registries

b. Enter details. of Harbor.

c. In the CA Certificate section, click Upload File to upload the ca.crt
certificate. 6. To deploy a managed cluster with Harbor mirror registry.

a. Navigate to Clusters > Create New Cluster.

b. Under Private Registry, select Harbor Mirror Registry.

c. Upload the ca.crt file.

d. Verify the managed cluster configuration:

```bash
kubectl get nkpclusters -A
kubectl get nkpcluster -n <WORKSPACE_NAMESPACE> <NKPCLUSTER_NAME> -o yaml
```

1. To deploy and validate the image usage from the Harbor mirror registry,
   push and pull an image to the Harbor mirror registry.

```bash
docker pull alpine
docker tag alpine $HARBOR_ADDRESS:5000/library/alpine
docker push $HARBOR_ADDRESS:5000/library/alpine
```

a. Deploy a pod from the Harbor mirror registry:

```yaml
apiVersion: v1
kind: Pod
metadata:
name: image-registry-test
spec:
containers:
- name: alpine
image: $HARBOR_ADDRESS:5000/library/alpine
command: ["/bin/sh", "-c", "sleep 100000"]
kubectl apply -f image-registry-pod-test.yaml
```

1. To validate the registry configuration on a managed cluster, check the
   secret on the managed cluster.

```bash
kubectl get secret -n <WORKSPACE_NAMESPACE> <NKPCLUSTER_NAME>-image-registry-
credentials -o yaml

```

##### Pushing a Container Image to Harbor

You can push a container image to Harbor.

About this task

To push a container image to Harbor, follow these steps:

Procedure

1. Configure TLS trust.

For more information, see Configuring Docker with a Harbor TLS Certificate on
page 350. 2. Authenticate the local docker daemon. Ensure that you have the
HARBOR_ADDRESS environment variable before running the commands in this
procedure. You can configure this when Harbor is running on a management
cluster.

```bash
export HARBOR_ADDRESS="$(kubectl -n kommander get kommandercluster nkp-cluster -o
jsonpath='{.status.ingress.address}')"
```

1. Push a container image to Harbor:

a. Pull a sample image from Docker Hub:

```bash
docker pull alpine:latest
```

b. Tag the image to match the address of Harbor:

```bash
docker tag alpine:latest $HARBOR_ADDRESS:5000/library/alpine:latest
```

c. Push the image to Harbor:

```bash
docker push $HARBOR_ADDRESS:5000/library/alpine:latest
```

d. Verify if the image is available in the Harbor UI.

###### Configuring Docker with a Harbor TLS Certificate

If Harbor is running in an NKP cluster that uses an ingress TLS certificate
that is from a private Certificate Authority or a self-signed certificate,
then configure the Docker daemon to trust the ingress certificate.

About this task

Perform this procedure on the user machine where the docker CLI is used to
push and pull from the Harbor registry.

To configure the Docker daemon to trust the ingress certificate, follow these
steps:

Procedure

1. Verify if the cluster is using a custom certificate:

```bash
kubectl get nkpcluster -n kommander -l 'kommander.d2iq.io/host=true' -o
jsonpath='{.items[0].kommanderCluster.status.ingress.caBundle}'
```

1. Switch to a privileged user as sudo -s and configure the Docker daemon to
   trust the ingress certificate.

```bash
sudo mkdir -p /etc/docker/certs.d/$HARBOR_ADDRESS:5000/
kubectl -n kommander get nkpcluster -l 'kommander.d2iq.io/host=true' -o
jsonpath='{.items[0].kommanderCluster.status.ingress.caBundle}' | base64 -d | sudo
tee /etc/docker/certs.d/$HARBOR_ADDRESS:5000/ca.crt > /dev/null
```

1. (Optional) If you use MacOS, save these certificates to the
   ~/.docker/certs.d/ directory. For more information, see

Directory structures for certificates 4. Restart Docker Desktop after making
any certificate configuration changes.

### Platform Applications

For more information on the applications supported for management and workload
clusters, see Supported Platform Applications on page 350.

This topic contains all the applications that are currently for use with
Nutanix Kubernetes Platform (NKP).

Table 25: Supported Applications per NKP Licenses

AI Navigator App

X X

| Applications | NKP Starter | Col3 | | | | |
| NKP Pro | Col5 | NKP Ultimate | | | | |

| Col7 |     |     |     |     |     |     |
| ---- | --- | --- | --- | --- | --- | --- |

- **Applications**; **Management** **Cluster**; **Workload** **Cluster**;
  **Management** **Cluster**; **Workload** **Cluster**; **Management**
  **Cluster**; **Workload** **Cluster**

AI Navigator Cluster Info Agent

X X

AI Navigator RAG

X X

Centralized Grafana

X

Cert Manager X X X X X X

Cilium Hubble Relay Traefik

X X X X

Cloudnative PG

X X X X

COSI Driver Nutanix

X X X X

Dex X X X

Dex K8s Authenticator

X X X

External DNS X X X X

External Secrets

X X X

Fluent Bit X X X X

Flux X X X X X X

Gatekeeper X X X X X X

Gateway API CRDs

X X X X X X

Git Operator X X X

Grafana Logging

X X X X

Grafana Loki X X X X

Harbor X X

Istio Helm X X X X

Jaeger X X X X

Karma X

Kiali X X X X

Knative X X X X

| Applications | NKP Starter | Col3 | | | | |
| NKP Pro | Col5 | NKP Ultimate | | | | |

| Col7 |     |     |     |     |     |     |
| ---- | --- | --- | --- | --- | --- | --- |

- **Applications**; **Management** **Cluster**; **Workload** **Cluster**;
  **Management** **Cluster**; **Workload** **Cluster**; **Management**
  **Cluster**; **Workload** **Cluster**

Kube OIDC Proxy

X X X X X X

Kube Prometheus Stack

X X X X

OpenCost X X

Kubernetes Dashboard

X X X X

Kubetunnel X X X X

Logging Operator

X X X X

NKP Insights X X

NKP Insights Management

X

NKP Pulse Management

X X X

NKP Pulse Workspace

X X X

NVIDIA GPU Operator

X X X X

Project Grafana Logging

X X

Project Grafana Loki

X X

Project Logging

X X

Prometheus Adapter

X X X X

Reloader X X X X X X

Rook Ceph X X X X

Rook Ceph Cluster

X X X X

Thanos X

Traefik X X X X X X

Traefik ForwardAuth

X X X

| Applications | NKP Starter | Col3 | | | | |
| NKP Pro | Col5 | NKP Ultimate | | | | |

| Col7 |     |     |     |     |     |     |
| ---- | --- | --- | --- | --- | --- | --- |

- **Applications**; **Management** **Cluster**; **Workload** **Cluster**;
  **Management** **Cluster**; **Workload** **Cluster**; **Management**
  **Cluster**; **Workload** **Cluster**

Traefik Forward Auth Mgmt

X X X

Velero X X X X

vGPU Token Operator

X X X X

#### Deploying Platform Applications Using CLI

Before you begin

Before you begin, you must have:

- A running cluster with Kommander installed.
- An existing Kubernetes cluster attached to Kommander (see Attaching an
  Existing Kubernetes Cluster on page 474).
- Determine the name of the workspace where you wish to perform the
  deployments. You can use the nkp get workspaces command to view the list of
  workspace names and their corresponding namespaces.
- Set the WORKSPACE_NAMESPACE environment variable to the name of the
  workspace's namespace where the cluster is attached:

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

- Set the WORKSPACE_NAME environment variable to the name of the workspace
  where the cluster is attached:

```bash
export WORKSPACE_NAME=<workspace_name>
Warning: From the CLI, you can enable applications to deploy in the workspace. Verify that the application has
successfully deployed through the CLI.
```

To create the AppDeployment, enable a supported application to deploy to your
existing attached or managed cluster with an AppDeployment resource (see
AppDeployment Resources on page 327).

Procedure

1. Obtain the APP ID and Version of the application. For more information, see
   NKP Release Notes on the Nutanix Support Portal. You must add them in the
   `<APP-ID>`-`<Version>` format, for example, kiali-2.24.0.

| Applications | NKP Starter | Col3 | | | | |
| NKP Pro | Col5 | NKP Ultimate | | | | |

| Col7 |     |     |     |     |     |     |
| ---- | --- | --- | --- | --- | --- | --- |

- **Applications**; **Management** **Cluster**; **Workload** **Cluster**;
  **Management** **Cluster**; **Workload** **Cluster**; **Management**
  **Cluster**; **Workload** **Cluster**

1. Run the following command and define the --app flag to specify which
   platform application and version will be enabled.

```bash
nkp create appdeployment kiali --app kiali-2.24.0 --workspace ${WORKSPACE_NAME}
```

> **Note:**

- The --app flag must match the APP NAME from the list of available platform
  applications.
- Observe that the nkp create command must be run with the WORKSPACE_NAME
  instead of the WORKSPACE_NAMESPACE flag.

This instructs Kommander to create and deploy the AppDeployment to the
KommanderClusters in the specified WORKSPACE_NAME.

#### Verifying the Deployed Platform Applications

Procedure

Connect to the attached cluster and watch the HelmReleases to verify the
deployment. In this example, we are checking whether kiali is deployed
correctly.

```bash
kubectl get helmreleases kiali -n ${WORKSPACE_NAMESPACE} -w
```

HelmRelease must be marked as Ready.

```bash
NAMESPACE NAME READY STATUS AGE
workspace-test-vjsfq kiali True Release reconciliation succeeded 7m3s
```

Some supported applications have dependencies on other applications. For more
information, see Platform Applications Dependencies For All Clusters on page 354.

#### Platform Applications Dependencies For All Clusters

As you deploy or troubleshoot platform applications, understand how they
interact and rely on other applications as dependencies. If a required
dependency of a platform application fails to deploy, any dependent
application also fails to deploy. For more information on the applications
supported per license for management and workload clusters, see Supported
Platform Applications on page 350.

1. To view the applications that are enabled or disabled in each category,
   verify their status:

```bash
kubectl get apps,clusterapps,appdeployments -A
```

1. After enabling the applications, deploy the HelmReleases.

To check whether the HelmReleases are deployed, connect to the attached
cluster and monitor their status. In this example, check if kiali is deployed
successfully:

```bash
kubectl get helmreleases kiali -n ${WORKSPACE_NAMESPACE} -w
```

You must see the HelmRelease marked as Ready:

```bash
NAMESPACE NAME READY STATUS AGE
workspace-test-vjsfq kiali True Release reconciliation succeeded 7m3s
```

Foundational Applications

Provides the foundation for all platform application capabilities and
deployments on management and managed clusters. You must enable the
foundational applications for any platform applications to work properly.

The foundational applications comprise of the following platform applications:

- flux: A tool that keeps Kubernetes clusters in sync with sources of
  configuration such as Git repositories, and automates updates to
  configuration when there is new code to deploy. For more information, see
  Flux.
- reloader: A Kubernetes controller that automatically reloads values for
  ConfigMaps and Secrets in Pods. For more information, see Reloader.
- traefik: Provides an HTTP reverse proxy and load balancer. For more
  information, see Traefik.

Table 26: Foundational Applications

Flux

[Applicable for both management and managed clusters]

kommander-flux Yes N/A N/A

Reloader

[Applicable for both management and managed clusters]

reloader No N/A N/A

Traefik

[Applicable for both management and managed clusters]

traefik No N/A

- cert-manager
- reloader

Logging

Collects logs over time from Kubernetes and applications deployed on
management and managed clusters. Logging enables you to visualize and query
the aggregated logs.

- fluent-bit: An open source and multi-platform log processor tool that is
  designed to be a generic Swiss knife for logs processing and distribution.
  For more information, see Fluent Bit documentation.
- grafana-logging: A logging dashboard to view the logs aggregated to Grafana
  Loki. For more information, see Grafana.
- grafana-loki: A horizontally-scalable, highly-available, multi-tenant log
  aggregation system inspired by Prometheus. For more information, see Grafana
  Loki.
- logging-operator: An operator automates the deployment and configuration of
  a Kubernetes logging pipelines. For more information, see Logging Operator.
- project-grafana-logging: A logging dashboard to view the project logs
  aggregated to Grafana Loki. For more information, see Grafana.
- project-grafana-loki: A horizontally-scalable, highly-available, multi-
  tenant log aggregation system inspired by Prometheus. For more information,
  see Grafana Loki.
- project-logging: A Nutanix application that defines resources for the
  logging operator, which are used for directing project logs to its Loki
  application. For more information, see Logging operator.

- Platform Application; APP ID; Internal; Required Dependency; Optional
  Dependency

| --- | --- | --- | --- | --- |

- rook-ceph-cluster: The Ceph cluster is managed by Rook Ceph operator and it
  provides storage services in cloud native environments. For more
  information, see Ceph Cluster Helm Chart.
- rook-ceph: Rook orchestrates the Ceph storage solution, with a specialized
  Kubernetes operator to automate management. For more information, see Ceph
  Operator Helm Chart.

Table 27: Logging

Fluent Bit

[Applicable for both management and managed clusters]

fluent-bit No N/A N/A

Grafana Logging

[Applicable for both management and managed clusters]

grafana-logging No N/A grafana-loki

Grafana Loki

[Applicable for both management and managed clusters]

grafana-loki No N/A rook-ceph-cluster

Logging Operator

[Applicable for both management and managed clusters]

logging-operator No N/A N/A

Project Grafana Logging

[Applicable for both management and managed clusters]

project-grafana- logging

No N/A project-grafana-loki

Project Grafana Loki

[Applicable for both management and managed clusters]

project-grafana- loki

No N/A

- project-logging
- grafana-loki
- logging-operator

- Platform Application; APP ID; Internal; Required Dependency; Optional
  Dependency

| --- | --- | --- | --- | --- |

Project Logging

[Applicable for both management and managed clusters]

project-logging No N/A logging-operator

Rook Ceph Cluster

[Applicable for both management and managed clusters]

rook-ceph-cluster No N/A rook-ceph

```yaml
Note: You can
override the
configuration
to remove the
dependency, as
needed.
```

Rook Ceph

[Applicable for both management and managed clusters]

rook-ceph No N/A N/A

> **Note: By default, NKP deploys only the monitoring stack and not the
> logging stack.**

Monitoring

Enables you to collect performance and cost metrics for Kubernetes and
applications deployed on clusters. Monitoring visualizes metrics and evaluates
rule-based expressions to trigger alerts when specific conditions are met.

- centralized-grafana: A dashboard that collects centralized metrics and
  provides visualization and alerting capabilities. For more information, see
  Grafana.
- opencost: Provides real-time cost visibility and insights for Kubernetes
  workloads. OpenCost helps you to continuously reduce your cloud costs. For
  more information, see OpenCost.
- karma: An alert dashboard for the Prometheus alertmanager. For more
  information, see Karma.
- kube-prometheus-stack: A stack of applications that collect metrics to
  provide visualization and configuring alerts. For more information, see Kube
  Prometheus Stack.

```yaml
Note: Kube Prometheus Stack includes Prometheus, Prometheus Alertmanager, and Grafana. For more
information, see Prometheus, Alertmanager, and Grafana.
```

- kubernetes-dashboard: A general purpose, web-based UI that enables you to
  manage applications deployed in the cluster, troubleshoot them, and manage
  the Kubernetes clusters. For more information, see Kubernetes Dashboard.
- prometheus-adapter: Provides cluster metrics from Prometheus. For more
  information, see Prometheus Adapter.
- thanos: An open-source, highly available Prometheus-compatible solution that
  offers unlimited data retention through object storage while remaining fully
  compatible with existing Prometheus tools. For more information, see Thanos.

- Platform Application; APP ID; Internal; Required Dependency; Optional
  Dependency

| --- | --- | --- | --- | --- |

Table 28: Monitoring

Centralized Grafana

[Only applicable for management clusters]

centralized-grafana Yes N/A N/A

OpenCost

[Applicable for both management and managed clusters]

opencost No N/A kube-prometheus- stack

Karma

[Only applicable for management clusters]

karma Yes karma-traefik N/A

Full Prometheus Monitoring Stack

[Applicable for both management and managed clusters]

kube-prometheus- stack

No N/A N/A

Kubernetes Dashboard

[Applicable for both management and managed clusters]

kubernetes- dashboard

No N/A traefik

Prometheus Adapter

[Applicable for both management and managed clusters]

prometheus- adapter

No kube-prometheus- stack

N/A

Thanos

[Only applicable for management clusters]

thanos Yes N/A N/A

Security

Enables you to manage the security constraints and capabilities for the
clusters.

- cert-manager: Automates the management and issuance of TLS certificate from
  various issuing sources. For more information, see cert-manager.
- external-secrets: External secrets operator is a Kubernetes operator that
  integrates external secret management systems such as AWS secrets manager,
  HashiCorp Vault, Google Secrets Manager, Azure Key Vault, IBM Cloud Secrets
  Manager, CyberArk Secrets Manager, Pulumi ESC, and so on. The external
  secrets operator reads information from external APIs and automatically
  injects the values into a Kubernetes secret. For more information, see
  External Secrets Operator.

- Platform Application; APP ID; Internal; Required Dependency; Optional
  Dependency

| --- | --- | --- | --- | --- |

- gatekeeper: A customizable admission webhook for Kubernetes to enforce
  policies executed by open policy agent (OPA). For more information, see
  Gatekeeper.

Table 29: Security

Cert-Manager

[Applicable for both management and managed clusters]

cert-manager No N/A N/A

External Secrets Operator

[Applicable for both management and managed clusters]

external-secrets No N/A N/A

Gatekeeper

[Applicable for both management and managed clusters]

gatekeeper No N/A N/A

Single Sign On (SSO)

A group of platform applications that enable single sign on (SSO) integration
on attached clusters. SSO provides a centralized system to securely connect
the attached clusters to the centralized authority hosted on the managed
cluster.

- dex-k8s-authenticator: A helper web application that integrates with one or
  more Dex identity services and provides a unified web UI for managing one or
  more clusters. For more information, see Dex K8 Authenticator.
- dex: An identity service that leverages openID connect (OIDC) to provide
  authentication for other applications. For more information, see Dex.
- kube-oidc-proxy: A proxy that consistently authenticates the managed
  Kubernetes clusters on multi-cloud using openID connect (OIDC). For more
  information, see Kube-OIDC-Proxy.
- traefik-forward-auth and traefik-forward-auth-mgmt: Installs a forward
  authentication service from Nutanix that provides Google OAuth based
  authentication for Traefik. For more information, see Traefik ForwardAuth.

Table 30: SSO

Dex K8s Authenticator

[Only applicable for management clusters]

dex-k8s- authenticator

Yes

- dex
- kommander
- traefik

N/A

- Platform Application; APP ID; Internal; Required Dependency; Optional
  Dependency

| --- | --- | --- | --- | --- |

- Platform Application; APP ID; Internal; Required Dependency; Optional
  Dependency

| --- | --- | --- | --- | --- |

Dex

[Only applicable for management clusters]

dex Yes N/A N/A

Kube OIDC Proxy

[Applicable for both management and managed clusters]

kube-oidc-proxy Yes N/A

- cert-manager
- traefik

Traefik ForwardAuth

[Only applicable for managed clusters]

traefik-forward-auth Yes traefik N/A

Traefik ForwardAuth Mgmt

[Only applicable for management clusters]

traefik-forward- auth-mgmt

Yes

- dex
- kommander
- traefik

N/A

Backup

A platform application that assists you securely back up and restore your
environment.

- velero: An open source tool to safely back up and restore Kubernetes cluster
  resources, perform disaster recovery, and migrate resources and persistent
  volumes across Kubernetes cluster. For more information, see Velero.

Table 31: Backup

Velero

[Applicable for both management and managed clusters]

velero No N/A

- rook-ceph-cluster
- Velero is an optional dependency. You can override the configuration to
  remove the dependency, as needed.

Review the resource requirements of workspace platform application and ensure
that the attached clusters have sufficient resources. For more information,
see Workspace Platform Application Defaults and Resource Requirements on page
726

Platform applications are bundled and tested as a single unit. You must deploy
or upgrade the entire bundle in one operation per workspace. As a result, all
clusters within a workspace run the same set and version of the deployed
platform applications.

- Platform Application; APP ID; Internal; Required Dependency; Optional
  Dependency

| --- | --- | --- | --- | --- |

- Platform Application; APP ID; Internal; Required Dependency; Optional
  Dependency

| --- | --- | --- | --- | --- |

Service Mesh

Enables service mesh deployment on clusters to manage microservices in cloud-
native applications. Service mesh offers several benefits, including:

- Observability into communication
- Secure connections
- Automated retries and back-off for failed requests
- istio-helm: Addresses the challenges faced with distributed or microservices
  architecture. For more information, see Istio.
- jaeger: A distributed tracing system used for monitoring and troubleshooting
  microservices-based distributed systems. For more information, see Jaeger.
- kiali: A management console for an Istio-based service mesh that provides
  dashboards, observability tools, and enables you to operate your service
  with robust configuration and validation. For more information, see Kiali.

Table 32: Service Mesh

Istio Helm

[Applicable for both management and managed clusters]

istio-helm No kube-prometheus- stack

N/A

Jaeger

[Applicable for both management and managed clusters]

jaeger No istio N/A

Kiali

[Applicable for both management and managed clusters]

kiali No istio jaeger

(optional for monitoring purposes)

Nutanix Kubernetes Platform (NKP) AI Navigator

Coupled with the AI Navigator, it analyses the data of your cluster to include
live information on queries made through the AI Navigator chatbot.

- ai-navigator-info-api: A chatbot with advanced artificial intelligence used
  for seamless Kubernetes cluster management and NKP environment optimization.
  The AI Navigator application is enabled by default and included in the AI
  Navigator.
- ai-navigator-cluster-info-agent: Includes the cluster information agent and
  API service. The AI Navigator Cluster Info Agent collects information about
  the NKP cluster and sends it to the AI Navigator service.
- ai-navigator-rag: A component that provides NKP AI Navigator with
  documentation and interfaces it with an external large language models
  (LLM).

For more information, see AI Navigator on page 1100.

- Platform Application; APP ID; Internal; Required Dependency; Optional
  Dependency

| --- | --- | --- | --- | --- |

Table 33: NKP AI Navigator

AI Navigator App

[Only applicable for management clusters]

ai-navigator-app No N/A N/A

AI Navigator Cluster Info Agent

[Only applicable for management clusters]

ai-navigator-cluster- info-agent

No cloudnative-pg N/A

AI Navigator RAG

[Only applicable for management clusters]

ai-navigator-rag No cloudnative-pg N/A

NKP Insights

Analyses the health of your health, detects current and future anomalies, and
creates alerts that offer root cause analysis and recommended solutions.

- nkp-insights: Also known as NKP Insights engine that collects events and
  metrics from your cluster and applies rule-based heuristics to detect
  potential anomalies of across different levels of severity.
- nkp-insights-management: Also known as NKP Insights Management that collects
  anomaly alerts from one or more clusters and displays root cause analysis
  and recommended solutions in the UI.

For more information, see Nutanix Kubernetes Platform Insights Guide on page 1111.

Table 34: NKP Insights

NKP Insights

[Applicable for both management and managed clusters]

nkp-insights No

- kube-prometheus- stack
- cloudnative-pg

N/A

NKP Insights Management

[Only applicable for management clusters]

nkp-insights- management

Yes kubefed N/A

General

- cloudnative-pg: A comprehensive open source platform designed to seamlessly
  manage PostgreSQL databases within Kubernetes environments. For more
  information, see CloudNativePG.
- cosi-driver-nutanix: An interface that seamlessly manage provisioning of
  object storage resources on Nutanix platforms within Kubernetes environments
  adhering to COSI standard. For more information, see COSI Driver Nutanix.

- Platform Application; APP ID; Internal; Required Dependency; Optional
  Dependency

| --- | --- | --- | --- | --- |

- Platform Application; APP ID; Internal; Required Dependency; Optional
  Dependency

| --- | --- | --- | --- | --- |

- harbor: A cloud native registry used for storing, signing, and scanning
  container images. For more information, see Harbor.
- knative: A Kubernetes-based platform to build, deploy, and manage modern
  serverless workloads. For more information, see Knative Technical Overview.
- nvidia-gpu-operator: The NVIDIA GPU Operator manages the NVIDIA GPU
  resources in Kubernetes cluster and automates tasks related to bootstrapping
  the GPU nodes. For more information, see NVIDIA GPU Operator.
- vgpu-token-operator: A Kubernetes native way to handle VGPU tokens and
  license validation. For more information, see vGPU Token Operator.

Table 35: General

CloudNativePG

[Applicable for both management and managed clusters]

cloudnative-pg No N/A N/A

COSI Driver Nutanix

[Applicable for both management and managed clusters]

cosi-driver-nutanix No N/A N/A

Harbor

[Only applicable for management clusters]

harbor No cloudnative-pg N/A

Knative

[Applicable for both management and managed clusters]

knative No istio N/A

NVIDIA GPU Operator

[Applicable for both management and managed clusters]

nvidia-gpu-operator No N/A N/A

vGPU Token Operator

[Applicable for both management and managed clusters]

vgpu-token- operator

No N/A N/A

- Platform Application; APP ID; Internal; Required Dependency; Optional
  Dependency

| --- | --- | --- | --- | --- |

Tools

- external-dns: ExternalDNS synchronizes the exposed Kubernetes services and
  ingresses with the DNS providers. For more information, see External DNS.

Table 36: Tools

External DNS

[Applicable for both management and managed clusters]

external-dns No N/A N/A

Networking

Interna apps: - Need category, definition, and reference links for the
following:

- cilium-hubble-relay-traefik: Exposes the Cilium Hubble Relay gRPC service
  through Traefik with TLS passthrough enabled, since Hubble Relay handles
  mTLS termination.
- gateway-api-crds: Gateway API is an interface that defines a set of
  Kubernetes resources and models service networking in Kubernetes. For more
  information, see Gateway API.
- kubetunnel: Enables access to the API server of a remote cluster without
  ingress by establishing a secure tunnel. For more information, see Cluster
  Attachment with Networking Restrictions on page 492

Table 37: Networking

Cilium Hubble Relay Traefik

[Applicable for both management and managed clusters]

cilium-hubble-relay- traefik

Yes traefik N/A

Gateway API CRDs

[Applicable for both management and managed clusters]

gateway-api-crds Yes N/A N/A

Kubetunnel

[Applicable for both management and managed clusters]

kubetunnel Yes N/A N/A

- Platform Application; APP ID; Internal; Required Dependency; Optional
  Dependency

| --- | --- | --- | --- | --- |

- Platform Application; APP ID; Internal; Required Dependency; Optional
  Dependency

| --- | --- | --- | --- | --- |

NKP Pulse

- nkp-pulse-management: An application or component within NKP that
  automatically sends telemetry data to improve diagnostics and product
  performance. NKP Pulse management simplifies Kubernetes lifecycle management
  by provisioning, scaling, and upgrades across hybrid and multi-cloud
  environments.
- nkp-pulse-workspace: An application or component within NKP that handles
  pulse telemetry and potentially integrates with the pulse workspace.

For more information, see Pulse Telemetry in NKP on page 693.

Table 38: NKP Pulse

NKP Pulse Management

[Only applicable for management clusters]

nkp-pulse- management

Yes N/A N/A

NKP Pulse Workspace

[Only applicable for managed clusters]

nkp-pulse- workspace

Yes N/A N/A

#### External Secrets Operator

From NKP 2.17, the management cluster includes ESO pre-installed by default.

The two key roles of ESO in NKP are:

- Platform Operations: NKP uses ESO internally to manage critical platform
  secrets, including OCI registry credentials and certificates, ensuring
  secure propagation from management to workload clusters.
- User Workloads: ESO can be enabled on workload clusters as a platform
  application to manage secrets for your own applications. This allows you to
  centralize sensitive data management outside of Kubernetes while ensuring
  your workloads have the credentials they need to run securely.

> **Note:**

- Disabling configurations of ESO on the management cluster is not permitted,
  and the option is not available in the NKP UI.
- The createPushSecrets and processPushSecrets keys in the charts are true by
  default, and must not be changed to false.

##### Enable ESO on a Workload Cluster Using UI

Enable ESO on a Workload Cluster using NKP UI.

- Platform Application; APP ID; Internal; Required Dependency; Optional
  Dependency

| --- | --- | --- | --- | --- |

Procedure

1. Log in to the NKP UI.
2. Navigate to the Management Cluster Workspace dashboard.
3. Select the Applications tab from the left navigation bar.
4. Locate the External Secrets Operator or ESO card in the application catalog.
5. Click Enable.
6. Select the workload cluster to enable ESO on.
7. (Optional) Configure the Overrides

- If you need to customize the installation (for example, change the target
  namespace or resource limits), edit the configuration YAML in the provided
  editor.
- By default, ESO is deployed to the external-secrets namespace.

1. Click Enable to begin the deployment.

##### Migrate to The ESO Application

For existing users with External Secrets Operator (ESO) already deployed using
helm-charts on workload clusters (a
brownfield scenario), you must complete the following procedure to migrate to
the ESO Platform Application to manage
your secrets. This will ensure existing secrets and credentials are not lost,
and there are no Custom Resource
Definition (CRD) conflicts and lifecycle management issues. On completion of
the migration procedure, you can use the
NKP UI for operating ESO or making any updates.

Procedure

1. Backup the resources and secrets referred to in these custom resources.

```bash
kubectl get externalsecrets -n <namespace> -o yaml > backup/externalsecrets.yaml
kubectl get pushsecrets -n <namespace> -o yaml > backup/pushsecrets.yaml
kubectl get secretstores -n <namespace> -o yaml > backup/secretstores.yaml
kubectl get clustersecretstores --all-namespaces -o yaml > backup/
clustersecretstores.yaml
kubectl get clusterPushSecrets --all-namespaces -o yaml > backup/
clusterpushsecrets.yaml
kubectl get clusterexternalsecrets --all-namespaces -o yaml > backup/
clusterexternalsecrets.yaml
helm get values manual-eso -n custom-eso-ns > backup/values.yaml
```

1. Uninstall the helm installed ESO.

```bash
helm uninstall external-secrets
-n external-secrets \
```

1. Enable ESO from the Kommander UI. During this process, you must use the
   values backed up in the

values.yaml file that was created in Step 1 to retain the older
configurations. 4. To retain the values and apply the overrides that were
configured earlier, use the .yaml file that was created in Step 1. For
example:

```bash
k apply -f externalsecrets_default.yaml
externalsecret.external-secrets.io/my-first-es created
k apply -f pushsecrets.yaml
pushsecrets.external-secrets.io/push-secrets created
k apply -f secretstores.yaml
secretstores.external-secrets.io/my-secretstores created
k apply -f clustersecretstores.yaml
clustersecretstore.external-secrets.io/kubernetes-backend created

k apply -f clusterPushSecrets.yaml
clusterPushSecrets.external-secrets.io/cluster-push-secrets created
k apply -f clusterexternalsecrets.yaml
clusterexternalsecrets.external-secrets.io/cluster-es created
```

What to do next

To verify the successful migration, use the command k get externalsecrets -n
external-secrets. The 'ExternalSecret' resource status displays Synced if the
procedure is executed successfully.

In this example, ClusterSecretStore is executed successfully and the status
SecretSynced confirms it.

k get externalsecrets -n external-secrets NAME STORETYPE STORE REFRESH
INTERVAL STATUS READY my-first-es ClusterSecretStore kubernetes-backend 1m0s
SecretSynced True

### Setting PriorityClasses in NKP Applications

About this task

By default, the PriorityClasses of Platform Applications are set by NKP.

For more information about the default PriorityClasses for NKP applications,
see the following pages:

- Workspace Platform Application Defaults and Resource Requirements on page 726
- Nutanix Kubernetes Platform Management Cluster Application Requirements on
  page 725
- Project Platform Application Configuration Requirements on page 421

This topic provides instructions on how to override the default PriorityClass
of any application in NKP to a different one.

NKP Priority Classes: The PriorityClasses that are available in NKP are as
follows:

Before you begin

Table 39: PriorityClasses

NKP High nkp-high-priority 100001000 This is the PriorityClass that is used
for high priority NKP workloads.

| Class | Value Name | Value | Description |
| ----- | ---------- | ----- | ----------- |

NKP Critical nkp-critical-priority 100002000 This is the highest PriorityClass
that is used for critical priority NKP workloads.

1. Set the WORKSPACE_NAMESPACE environment variable to the name of the
   workspace's namespace where the cluster is attached: xport
   WORKSPACE_NAMESPACE=`<your_workspace_namespace>`.

```bash
export WORKSPACE_NAMESPACE=<your_workspace_namespace>
```

1. You are now able to copy the following commands without having to replace
   the placeholder with your workspace namespace every time you run a command.

Follow these steps.

```yaml
Note: Keep in mind that the overrides for each application appears differently and is dependent on how the
application's helm chart values are configured.
```

For more information about the helm chart values used in the NKP, see NKP
Release Notes on the Nutanix Support Portal.

Generally speaking, performing a search for the priorityClassName field allows
you to find out how you can set the PriorityClass for a component.

In the example below which uses the helm chart values in Grafana Loki, the
referenced priorityClassName field is nested under the ingester component. The
PriorityClass can be set for several other components, including distributor,
ruler, and on a global level.

Procedure

1. Create a ConfigMap with custom PriorityClass configuration values for
   Grafana Loki. The following example sets the PriorityClass of ingester
   component to the NKP critical priority class.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
namespace: ${WORKSPACE_NAMESPACE}
name: grafana-loki-v3-overrides
data:
values.yaml: |
ingester:
priorityClassName: nkp-critical-priority
EOF
```

1. Edit the grafana-loki-v3 AppDeployment to set the value of
   spec.configOverrides.name to grafana-

loki-v3-overrides. After your editing is complete, the AppDeployment resembles
this example.

```yaml
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: grafana-loki-v3
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: grafana-loki-v3-3.6.7
kind: ClusterApp
configOverrides:
```

| Class | Value Name | Value | Description |
| ----- | ---------- | ----- | ----------- |

```bash
name: grafana-loki-v3overrides
```

1. It will take a few minutes to reconcile but you can check the ingester
   pod's PriorityClass after reconciling.

```bash
kubectl get pods -n ${WORKSPACE_NAMESPACE} -o custom-
columns=NAME:.metadata.name,PRIORITY:.spec.priorityClassName,PRIORITY:.spec.priority
|grep ingester
```

The results appears as follows::

```bash
NAME PRIORITY
PRIORITY
grafana-loki-loki-distributed-ingester-0 nkp-critical-
priority 100002000
```

For more information about PriorityClasses, see
`<https://kubernetes.io/docs/concepts/scheduling-eviction/>` pod-priority-
preemption/.

## Workspaces

- Deploying Platform Applications Using CLI on page 353
- Platform Applications on page 350
- Platform Applications Dependencies For All Clusters on page 354
- Workspace Platform Application Defaults and Resource Requirements on page 726

Global or Workspace UI

The UI is designed to be accessible for different roles at different levels:

- Workspace: DevOps administrators manage multiple clusters within a workspace.
- Projects: DevOps administrators or developers manage configuration and
  services across multiple clusters.

Default Workspace

To get started immediately, you can use the default workspace deployed in NKP.
However, take into account that you cannot move clusters from one workspace to
another after creating/attaching them.

About this task

To create a workspace:

Procedure

1. From the workspace selection dropdown list in the top menu bar, select
   Create Workspace.
2. Type a name and description.
3. Click Save. The workspace is now accessible from the workspace selection
   dropdown list.

### Adding or Editing Workspace Annotations and Labels

About this task

To perform an action in workspace:

Procedure

1. From the top menu bar, select your target workspace.
2. Select the Actions from the dropdown list and click Edit.
3. Enter in new Key and Value labels for your workspace, or edit existing Key
   and Value labels.

> **Note: Labels that are added to a workspace are also applied to all the
> kommanderclusters in the workspace.**

### Deleting a Workspace

About this task

To delete a workspace:

> **Note: Workspaces can only be deleted if all the clusters in the
> workspace have been deleted or detached.**

Procedure

1. From the top menu bar, select Global.
2. From the sidebar menu, select Workspaces.
3. Select the three-dot button to the right of the workspace you want to
   delete, and then click Delete.
4. Confirm the workspace deletion in the Delete Workspace dialog box. The
   following procedures are supported for workspaces:

- Deploying Platform Applications Using CLI on page 353
- Platform Applications on page 350
- Platform Applications Dependencies For All Clusters on page 354
- Workspace Platform Application Defaults and Resource Requirements on page 726

### Workspace Applications

- Platform Applications on page 350 are applications integrated into NKP.
- Catalog Applications: are either pre-packaged applications from the Nutanix
  Application Catalog or custom applications that you maintain for your teams
  or organization.

#### Cluster-scoped Application Configuration from the NKP UI

This functionality allows you to use NKP in a multi-cluster scenario without
restricting the management of multiple clusters from a single workspace.

```yaml
Note: NKP Pro users are only be able to configure and deploy applications to a single cluster within a workspace.
Selecting an application to deploy to a cluster skips cluster selection and takes you directly to the workspace
configuration overrides page.
```

##### Enabling a Cluster-scoped Application Using the NKP UI

Before you begin

Ensure that you've provisioned or attached clusters in one of the following
environments:

- Amazon Web Services (AWS): Creating the NKP Management Cluster on AWS on
  page 818
- Amazon Elastic Kubernetes Service (EKS):EKS: Creating an EKS Cluster from
  the UI on page 838
- Microsoft Azure:Creating a Managed Azure Cluster Through the NKP UI on page
  468

For more information, see the current list of Catalog and Platform Applications:

- Workspace Catalog Applications on page 379
- Platform Applications on page 350

Navigate to the workspace containing the clusters you want to deploy to by
selecting the appropriate workspace name from the dropdown list at the top of
the NKP dashboard.

Procedure

1. Log into the NKP UI dashboard.
2. In the workspace header drop-down list, select your target workspace.
3. From the left navigation pane, find the application you want to deploy to
   the cluster, and select Applications.
4. Select the triple dot vertical icon in the desired application's tile and
   select Enable.

```yaml
Note: You can also access the Application Enablement by selecting the triple dot vertical icon > View >
Details. Then, select Enable from the application's details page.
```

The Application Enablement page appears. 5. Select the cluster(s) that you
want to deploy the application to.

The available clusters are sorted by Name, Type, Provider and any Labels that
you added. 6. In the lower-right of the Application Enablement page, deploy
the application to the clusters by selecting Enable. You are automatically
redirected to either the Applications or View Details page.

To view the application enabled in your chosen cluster, navigate to the
Clusters page on the left navigation bar. The application appears in the
Applications pane of the appropriate cluster.

```yaml
Note: Once you enable an application at the workspace level, NKP automatically enables that app on any other
cluster you create or attach.
```

##### Configuring a Cluster-scoped Application Using the NKP UI

About this task

For scenarios where applications require different configurations on a per-
cluster basis, navigate to the Applications page and select Edit from the
triple dot vertical icon of the appropriate application to return to the
application enablement page.

Procedure

1. Log into the NKP UI dashboard.
2. In the workspace header drop-down list, select your target workspace.
3. From the left navigation pane, find the application you want to deploy to
   the cluster, and select Applications.

The available clusters can be sorted by Name, Type, Provider and any Labels
you've added. 4. The Applications page contains two separate types of code
editors, where you can enter your specified overrides and configurations.

» Workspace Application Configuration: A workspace-level code editor that
applies all configurations and overrides to the entirety of the workspace and
its clusters for this application.

» Cluster Application Configuration Override: A cluster-scoped code editor
that applies configurations and overrides to
the cluster specified. These customizations will merge with the workspace
application configuration. If there is no
cluster-scoped configuration, the workspace configuration applies. 5. If you
already have a configuration to apply in a
text or .yaml file, you can upload the file by selecting Upload File. If you
want to download the displayed set of
configurations, select Download File. 6. Finish configuring the cluster-scoped
applications by selecting Save. You are
automatically redirected to either the Applications or View Details page. To
view the custom configurations of the
application in the cluster, select the Configurations tab on the details page
of the application.

```yaml
Note: Editing is disabled in the code boxes displayed in the application's details page. To edit the configuration,
click Edit in the top right of the page and repeat the steps in this section.
```

##### Removing a Cluster-scoped Application

About this task

Navigate to the cluster you've deployed your applications to by selecting
Clusters from the left navigation bar.

Procedure

1. Click on the Applications tab.
2. Select the triple dot vertical icon in the application tile that you want
   and select Disable. A prompt appears to confirm your decision to disable the
   application.
3. Follow the instructions in the prompt and select Disable
4. Refresh the page to confirm that the application has been removed from the
   cluster. This process only removes the application from the specific cluster
   you have navigated to. To remove this application from other clusters,
   navigate to the Clusters page and repeat the process.

#### Cluster-scoped Application for Existing AppDeployments

When you enable an application for a workspace, you deploy this application to
all clusters within that workspace. You can also choose to enable or customize
an application on certain clusters within a workspace. This functionality
allows you to use NKP in a multi-cluster scenario without restricting the
management of multiple clusters from a single workspace.

Your NKP cluster comes bundled with a set of default application
configurations. If you want to override the default configuration of your
applications, you can define workspace configOverrides on top of the default
workspace configuration. And if you want to further customize your workspace
by enabling applications on a per-cluster basis or by defining per-cluster
customizations, you can create and apply clusterConfigOverrides.

The cluster-scoped enablement and customization of applications is an
Ultimate-only feature, which allows the configuration of all workspace
Platform Applications on page 350, Workspace Catalog Applications on page 379,
and Custom Applications on page 402 through the CLI in your managed and
attached clusters regardless of your environment setup (air-gapped or non-air-
gapped). This capability is not provided for project applications.

##### Cluster-scope Application Prerequisites

Prerequisites for enabling an application per cluster for the first time or
after it is enabled at the workspace level.

- Any application you wish to enable or customize at a cluster level, first
  needs to be enabled at the workspace-level through an AppDeployment. See
  Deploying Platform Applications Using CLI on page 353 and Workspace Catalog
  Applications on page 379.
- For custom configurations, you must created a ConfigMap. For all the
  required spec fields for each customization you want to add to an
  application in a cluster, see AppDeployment Resources on page 327.

You can apply a ConfigMap to several clusters, or create a ConfigMap for each
cluster, but the ConfigMap object must exist in the Management cluster.

- Determine the name of the workspace where you wish to perform the
  deployments. You can use the nkp get workspaces command to see the list of
  workspace names and their corresponding namespaces.
- Set the WORKSPACE_NAMESPACE environment variable to the name of the
  workspace's namespace where the cluster is attached.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

- Set the WORKSPACE_NAME environment variable to the name of the workspace
  where the cluster is attached.

```bash
export WORKSPACE_NAME=<workspace_name>
```

##### Enabling an Application Per Cluster For the First Time

Before you begin

See Cluster-scope Application Prerequisites on page 373.

About this task

When you enable an application on a workspace, it is deployed to all clusters
in the workspace by default. If you want to deploy it only to a subset of
clusters when enabling it on a workspace for the first time, you can follow
the steps in this topic.

To enable an application per cluster for the first time:

Procedure

1. Create an AppDeployment for your application, selecting a subset of
   clusters within the workspace to enable it on. You can use the nkp get
   clusters --workspace ${WORKSPACE_NAME} command to see the list of clusters
   in the workspace. The following snippet is an example. Replace the
   application name, version, workspace name and cluster names according to
   your requirements. For compatible components and application versions, see
   NKP Release Notes on the Nutanix Support Portal.

```bash
nkp create appdeployment kube-prometheus-stack --app kube-prometheus-stack-82.13.6 --
workspace ${WORKSPACE_NAME} --clusters attached-cluster1,attached-cluster2
```

1. (Optional) Check the current status of the AppDeployment to see the names
   of the clusters where the application is currently enabled.

##### Enabling an Application Per Cluster After it is Enabled at the Workspace

Level

You can enable or disable an application per cluster after it has been enabled
at the workspace level.

Before you begin

See Cluster-scope Application Prerequisites on page 373.

About this task

You can enable or disable applications at any time. After you have enabled the
application at the workspace level, the spec.clusterSelector field populates.

```yaml
Note: For clusters that are newly attached into the workspace, all applications enabled for the workspace are
automatically enabled on and deployed to the new clusters.
```

If you want to see on what clusters your application is currently deployed,
see the print and review the current state of your AppDeployment. For more
information, see AppDeployment Resources on page 327.

Procedure

Edit the AppDeployment YAML by adding or removing the names of the clusters
where you want to enable your application in the clusterSelector section: The
following snippet is an example. Replace the application name, version,
workspace name and cluster names according to your requirements.

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

##### Customizing an Application Per Cluster

You can customize the application for each cluster occurrence of said
application. If you want to customize the application for a cluster that is
not yet attached, refer to the instructions below, so the application is
deployed with the custom configuration during attachment.

About this task

To enable per-cluster customizations:

Procedure

1. Reference the name of the ConfigMap to be applied per cluster in the
   spec.clusterConfigOverrides fields. In this example, you have three
   different customizations specified in three different ConfigMaps for three
   different clusters in one workspace.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: kube-prometheus-stack
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: kube-prometheus-stack-82.13.6
kind: ClusterApp
clusterSelector:
matchExpressions:
- key: kommander.d2iq.io/cluster-name
operator: In
values:
- attached-cluster1
- attached-cluster2
- attached-cluster3-new
clusterConfigOverrides:
- configMapName: kps-cluster1-overrides
clusterSelector:
matchExpressions:
- key: kommander.d2iq.io/cluster-name
operator: In
values:
- attached-cluster1
- configMapName: kps-cluster2-overrides
clusterSelector:
matchExpressions:
- key: kommander.d2iq.io/cluster-name
operator: In
values:
- attached-cluster2
- configMapName: kps-cluster3-overrides
clusterSelector:
matchExpressions:
- key: kommander.d2iq.io/cluster-name
operator: In
values:
- attached-cluster3-new
EOF
```

1. If you have not done so yet, create the ConfigMaps referenced in each
   clusterConfigOverrides entry.

> **Note:**

- The changes are applied only if the YAML file has a valid syntax.
- Set up only one cluster override ConfigMap per cluster. If there are several
  ConfigMaps configured for a cluster, only one will be applied.
- Cluster override ConfigMaps must be created on the Management cluster.

##### Customizing an Application Per Cluster at Attachment

You can customize the application configuration for a cluster prior to its
attachment, so that the application is deployed with this custom configuration
on attachment. This is preferable, if you do not want to redeploy the
application with an updated configuration after it has been initially
installed, which may cause downtime.

About this task

To enable per-cluster customizations, follow these steps before attaching the
cluster

Procedure

1. Set the CLUSTER_NAME environment variable to the cluster name that you will
   give your to-be-attached cluster.

```bash
export CLUSTER_NAME=<your_attached_cluster_name>
```

Reference the name of the ConfigMap you want to apply to this cluster in the

spec.clusterConfigOverrides fields. You do not need to update the
spec.clusterSelector field. In this example, you have the kps-
cluster1-overrides customization specified for attached-cluster-1 and a
different customization (in kps-your-attached-cluster-overrides ConfigMap) for
your to-be- attached cluster.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: kube-prometheus-stack
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: kube-prometheus-stack-82.13.6
kind: ClusterApp
clusterSelector:
matchExpressions:
- key: kommander.d2iq.io/cluster-name
operator: In
values:
```

| kps-your-attached-cluster-overrides | ConfigMap |
| ----------------------------------- | --------- |

```bash
- attached-cluster1
clusterConfigOverrides:
- configMapName: kps-cluster1-overrides
clusterSelector:
matchExpressions:
- key: kommander.d2iq.io/cluster-name
operator: In
values:
- attached-cluster1
- configMapName: kps-your-attached-cluster-overrides
clusterSelector:
matchExpressions:
- key: kommander.d2iq.io/cluster-name
operator: In
values:
- ${CLUSTER_NAME}
EOF
```

1. If you have not done so yet, create the ConfigMap referenced for your to-
   be-attached cluster.

> **Note:**

- The changes are applied only if the YAML file has a valid syntax.
- Cluster override ConfigMaps must be created on the Management cluster.

##### Disabling the Custom Configuration of an Application Per Cluster

Enabled customizations are defined in a ConfigMap which, in turn, is
referenced in the spec.clusterConfigOverrides object of your AppDeployment.

Procedure

1. Review your current configuration to establish what you want to remove.

```bash
kubectl get appdeployment -n ${WORKSPACE_NAMESPACE} kube-prometheus-stack -o yaml
```

The result appears as follows.

```yaml
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: kube-prometheus-stack
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: kube-prometheus-stack-82.13.6
kind: ClusterApp
configOverrides:
name: kube-prometheus-stack-overrides-attached
clusterSelector:
matchExpressions:
- key: kommander.d2iq.io/cluster-name
operator: In
values:
- attached-cluster1
- attached-cluster2
clusterConfigOverrides:
- configMapName: kps-cluster1-overrides
clusterSelector:
matchExpressions:
- key: kommander.d2iq.io/cluster-name
operator: In
values:
- attached-cluster1
- configMapName: kps-cluster2-overrides
clusterSelector:
matchExpressions:
- key: kommander.d2iq.io/cluster-name
operator: In
values:
- attached-cluster2
```

Here you can see that kube-prometheus-stack has been enabled for the attached-
cluster1 and attached-cluster2. There is also a custom configuration for each
of the clusters: kps-cluster1- overrides and kps-cluster2-overrides. 2. To
delete the customization, delete the configMapName entry of the cluster. This
is located under

clusterConfigOverrides.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: kube-prometheus-stack
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
kind: ClusterApp
name: kube-prometheus-stack-82.13.6
configOverrides:
name: kube-prometheus-stack-ws-overrides
clusterSelector:
matchExpressions:
- key: kommander.d2iq.io/cluster-name
operator: In
values:
- attached-cluster1
clusterConfigOverrides:
- configMapName: kps-cluster1-overrides
clusterSelector:
matchExpressions:
- key: kommander.d2iq.io/cluster-name
operator: In
values:
- attached-cluster1
EOF
```

> **Note: Compare steps one and two for a reference of how an entry should
> be deleted.** 3. Before deleting a ConfigMap that contains your
> customization, ensure you will NOT require it at a later time. It is not
> possible to restore a deleted ConfigMap. If you choose to delete it, run.

```bash
kubectl delete configmap <name_configmap> -n ${WORKSPACE_NAMESPACE}
Note: It is not possible to delete a ConfigMap that is being actively used and referenced in the
configOverride of any AppDeployment.
```

##### Verify the Configuration of your Application

Procedure

### Workspace Catalog Applications

1. If you want to know how the AppDeployment resource is currently configured,
   refer to the print and review the state of your AppDeployments.

#### Nutanix Enterprise AI in Workspace

Nutanix Enterprise AI (NAI) is a comprehensive inference endpoint management
product designed to streamline and optimize your AI model orchestration
experience. NAI allows you to select, deploy, and manage large language models
(LLMs) on a Kubernetes cluster. You can deploy NAI on any Kubernetes
distribution, including Nutanix Kubernetes Platform(NKP) and public cloud
Kubernetes platforms such as Amazon Elastic Kubernetes Service (EKS).

Nutanix Enterprise AI (NAI) includes the following features:

- Built-in support for Nutanix products: NAI supports seamless integration
  with existing Nutanix products, thus providing a robust and compliant
  solution.
- Model access integration: NAI supports selecting and deploying text-based
  generative AI LLMs from Hugging Face.
- API endpoint integration: NAI supports creating an API endpoint and sharing
  it with developers to incorporate into their AI applications. You can also
  manage and validate these endpoints to ensure they are configured correctly.
- API-based access control: NAI supports accessing an endpoint by an
  application using API keys. API key management allows you to provide and
  revoke API access to ensure proper access security controls.
- User access and role-based access control: NAI supports role-based access
  control (RBAC), which you can configure to provide customized access
  permissions to users based on their assigned roles. The user dashboard
  displays information about all the defined roles.
- Enterprise user interface: NAI has a simple and dynamic user interface that
  streamlines your deployment processes using one-click deployment.
- Metrics dashboard: NAI has a dynamic dashboard where you can monitor the
  health of your deployment with real-time monitoring tools that identify
  bottlenecks, track performance, and troubleshoot issues.

##### Nutanix Enterprise AI on NKP Prerequisites

Before configuring Nutanix Enterprise AI on NKP, verify that you have
completed the following:

- Create or use your existing NKP workload cluster in a workspace.

For more information on creating the management cluster, see Creating a
Managed Nutanix Cluster Through the NKP UI on page 458.

- Locate the DockerHub credentials that is provided as part of your Nutanix
  Enterprise AI purchase.

For more information, see Generating Nutanix Docker Hub Access Tokens.

- Ensure to apply your NKP Pro or Ultimate License to your cluster.

For more information, see Kubernetes Cluster Setup.

##### Deploying Nutanix Enterprise AI 2.7.0 on NKP

This topic describes how to deploy Nutanix Enterprise AI (NAI) 2.7.0 on an NKP
cluster.

Before you begin

- Ensure your cluster meets all the Nutanix Enterprise AI Requirements.
- Enable the following applications on your managed cluster:
- Cert Manager
- Prometheus Monitoring
- NVIDIA GPU Operator
- NAI - Envoy Gateway (Supported by NAI) (v1.7.0)
- Kserve (v0.15.0)
- OpenTelemetry Operator (v0.102.0)

About this task

The NKP catalog includes NAI as an application. This allows you to deploy NAI
on your clusters with a single click.

> **Note:**

- Starting with NKP 2.16, you can access Nutanix AI directly from the NKP UI.
  The nkp create catalog CLI command is no longer required and is now
  deprecated.
- NAI deployment is supported on Management and Workload clusters.

To enable the NAI catalog applications from the NKP UI, perform the following
steps.

Procedure

1. Set the KUBECONFIG environment variable: The KUBECONFIG environment
   variable must be set to the configuration file of the cluster where NAI is
   being installed.

```bash
export KUBECONFIG=<cluster.conf>
```

1. Create the Nutanix file storage class. Use the following manifest to
   replace nfs-path and nfs-server:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
name: nai-nfs-storage
parameters:
nfsPath: <nfs-path>
nfsServer: <nfs-server>
storageType: NutanixFiles
provisioner: csi.nutanix.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
EOF

```

1. Create the docker registry secrets.

Create the nai-system namespace and the docker-registry secret in both nai-
system and envoy-gateway-system namespaces:

```bash
export REGISTRY_SECRET_NAME=nai-regcred
export DOCKER_SERVER=https://index.docker.io/v1/
export DOCKER_USERNAME=<docker-username>
export DOCKER_PASSWORD=<docker-password>
export DOCKER_EMAIL=<docker-email>
kubectl create namespace nai-system --dry-run=client -o yaml | kubectl apply -f -
kubectl -n nai-system create secret docker-registry ${REGISTRY_SECRET_NAME} \
--docker-server=${DOCKER_SERVER} \
--docker-username=${DOCKER_USERNAME} \
--docker-password=${DOCKER_PASSWORD} \
--docker-email=${DOCKER_EMAIL} \
--dry-run=client -o yaml | kubectl apply -f -
kubectl -n envoy-gateway-system create secret docker-registry
${REGISTRY_SECRET_NAME} \
--docker-server=${DOCKER_SERVER} \
--docker-username=${DOCKER_USERNAME} \
--docker-password=${DOCKER_PASSWORD} \
--docker-email=${DOCKER_EMAIL} \
--dry-run=client -o yaml | kubectl apply -f -
```

> **Note:**

The envoy-gateway-system namespace is already present on the cluster. 4. Log
in to the NKP dashboard. 5. Enable NAI from the UI.

a. Go to the Applications tab.

b. Select Nutanix Enterprise AI.

c. Click Enable. 6. From the Version dropdown, select 2.7.0. 7. Configure the
application override settings.

In the Application Configuration Override window:

a. Select the target cluster(s).

b. Paste the following configuration:

```bash
global:
imagePullSecrets:
- name: nai-regcred
```

- For information on generating the Docker Hub Access Tokens, see Generating
  Nutanix Docker Hub Access Tokens.
- For information on the configuration override fields, see Nutanix Enterprise
  AI Configuration Parameters.

1. Access the NAI dashboard.

You can use the cluster's application dashboard NAI card to access the Nutanix
Enterprise AI dashboard.

a. Go to the cluster where NAI is deployed.

b. In Enabled Applications, search for Nutanix Enterprise AI.

c. Click the Dashboard link.

This will open NAI using the service external IP. 9. Create a DNS record. A
DNS record is required to map the service IP to the FQDN. 10. (Optional)
Update the Dashboard link:

```bash
export NAI_UI_ENDPOINT=https://<FQDN>/
kubectl patch cm nai-ui -n <workspace-namespace> -p '{"data":
{"dashboardLink":"'${NAI_UI_ENDPOINT}'"}}'
Note: This NAI deployment by default provisions a self-signed certificate to access NAI. For more information,
refer to Setting TLS Encryption for NAI.
```

What to do next

After you enable an application for a workspace, you can deploy this
application on all the clusters within that workspace. For more information on
managing cluster-scoped applications in the NKP UI, see Cluster- scoped
Application Configuration from the NKP UI on page 371.

##### Upgrading Nutanix Enterprise AI to 2.7.0 on NKP

This topic describes how to upgrade Nutanix Enterprise AI (NAI) 2.7.0 on an
NKP cluster.

Before you begin

- You must disable Envoy Gateway (v1.6.3) and enable NAI - Envoy Gateway
  (Supported by NAI) (v1.7.0) on your managed cluster as NAI 2.7.0 requires
  the AI gateway powered Envoy Gateway.
- Enable the following applications on your managed cluster:
- Cert Manager
- Prometheus Monitoring
- NVIDIA GPU Operator
- NAI - Envoy Gateway (Supported by NAI) (v1.7.0)
- Kserve (v0.15.0)
- OpenTelemetry Operator (v0.102.0)

About this task

The NKP catalog includes NAI as an application. This allows you to deploy NAI
on your clusters with a single click.

> **Note:**

- Upgrades to Nutanix Enterprise AI version 2.7.0 are supported only from NAI
  version 2.6.0.
- For a fresh installation of Nutanix Enterprise AI 2.7.0, see Deploying
  Nutanix Enterprise AI 2.7.0 on NKP on page 380.
- Starting with NKP 2.16, you can access Nutanix AI directly from the NKP UI.
  The nkp create catalog CLI command is no longer required and is now
  deprecated.
- NAI deployment is supported on Management and Workload clusters.

To upgrade the NAI catalog applications from the NKP UI, perform the following
steps:

Procedure

1. Set the KUBECONFIG environment variable: The KUBECONFIG environment
   variable must be set to the configuration file of the cluster where NAI is
   being upgraded:

```bash
export KUBECONFIG=<cluster.conf>
```

1. Update the docker registry secret in the nai-system and envoy-gateway-
   system namespaces with your current credentials:

```bash
export REGISTRY_SECRET_NAME=nai-regcred
export DOCKER_SERVER=https://index.docker.io/v1/
export DOCKER_USERNAME=<docker-username>
export DOCKER_PASSWORD=<docker-password>
export DOCKER_EMAIL=<docker-email>
kubectl -n nai-system create secret docker-registry ${REGISTRY_SECRET_NAME} \
--docker-server=${DOCKER_SERVER} \
--docker-username=${DOCKER_USERNAME} \
--docker-password=${DOCKER_PASSWORD} \
--docker-email=${DOCKER_EMAIL} \
--dry-run=client -o yaml | kubectl apply -f -
kubectl -n envoy-gateway-system create secret docker-registry
${REGISTRY_SECRET_NAME} \
--docker-server=${DOCKER_SERVER} \
--docker-username=${DOCKER_USERNAME} \
--docker-password=${DOCKER_PASSWORD} \
--docker-email=${DOCKER_EMAIL} \
--dry-run=client -o yaml | kubectl apply -f -
```

1. Log in to the NKP dashboard.
2. Edit the application:

a. Go to the Applications tab.

b. Select Nutanix Enterprise AI.

c. Click Edit. 5. From the Version dropdown, select 2.7.0. 6. Update the
application configuration override:

In the Application Configuration Override window:

a. Select the target cluster(s) where NAI 2.6.0 is already deployed.

b. Replace the override content:

```bash
global:
imagePullSecrets:
- name: nai-regcred
```

1. Access the NAI dashboard: Use the cluster's Application Dashboard NAI card
   to access the Nutanix Enterprise AI dashboard:

a. Go to the cluster where NAI is deployed.

b. In Enabled Applications, search for Nutanix Enterprise AI.

c. Click Dashboard link. This will open NAI on service External IP. 8. Verify
the DNS record:

Ensure a DNS record exists that maps the service IP to the FQDN. If the
service IP has changed as part of the upgrade, update the record accordingly. 9. Verify cluster health post-upgrade:

Confirm that all NAI pods in the nai-system namespace are Running and that the
new NAI - Envoy Gateway is healthy in the envoy-gateway-system namespace. 10.
(Optional) Update the dashboard link:

```bash
export NAI_UI_ENDPOINT=https://<FQDN>/
kubectl patch cm nai-ui -n <workspace-namespace> -p '{"data":
{"dashboardLink":"'${NAI_UI_ENDPOINT}'"}}'
Note: This NAI deployment by default provisions a self-signed certificate to access NAI. For more information,
refer to Setting TLS Encryption for NAI.
```

What to do next

After you enable an application for a workspace, you can deploy this
application on all the clusters within that workspace. For more information on
managing cluster-scoped applications in the NKP UI, see Cluster- scoped
Application Configuration from the NKP UI on page 371.

##### Deploying Nutanix Enterprise AI 2.6.0 on NKP

This topic describes how to deploy Nutanix Enterprise AI (NAI) 2.6.0 on an NKP
cluster.

Before you begin

- Ensure your cluster meets all the Nutanix Enterprise AI Requirements.
- Enable the following applications on your managed cluster:
- Cert Manager
- Prometheus Monitoring
- NVIDIA GPU Operator
- Envoy Gateway (v1.6.3)
- Kserve (v0.15.0)
- OpenTelemetry Operator (v0.102.0)

About this task

The NKP catalog includes NAI as an application. This allows you to deploy NAI
on your clusters with a single click.

> **Note:**

- Starting with NKP 2.16, you can access Nutanix AI directly from the NKP UI.
  The nkp create catalog CLI command is no longer required and is now
  deprecated.
- NAI deployment is supported on Management and Workload clusters.

To enable the NAI catalog applications from the NKP UI, perform the following
steps.

Procedure

1. Set the KUBECONFIG environment variable: The KUBECONFIG environment
   variable must be set to the configuration file of the cluster where NAI is
   being installed.

```bash
export KUBECONFIG=<cluster.conf>
```

1. Create the Nutanix file storage class. Use the following manifest to
   replace nfs-path and nfs-server:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
name: nai-nfs-storage
parameters:
nfsPath: <nfs-path>
nfsServer: <nfs-server>
storageType: NutanixFiles
provisioner: csi.nutanix.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
EOF

```

1. Create the docker registry secrets.

Create the nai-system namespace and the docker-registry secret in both nai-
system and envoy-gateway-system namespaces:

```bash
export REGISTRY_SECRET_NAME=nai-regcred
export DOCKER_SERVER=https://index.docker.io/v1/
export DOCKER_USERNAME=<docker-username>
export DOCKER_PASSWORD=<docker-password>
export DOCKER_EMAIL=<docker-email>
kubectl create namespace nai-system --dry-run=client -o yaml | kubectl apply -f -
kubectl -n nai-system create secret docker-registry ${REGISTRY_SECRET_NAME} \
--docker-server=${DOCKER_SERVER} \
--docker-username=${DOCKER_USERNAME} \
--docker-password=${DOCKER_PASSWORD} \
--docker-email=${DOCKER_EMAIL} \
--dry-run=client -o yaml | kubectl apply -f -
kubectl -n envoy-gateway-system create secret docker-registry
${REGISTRY_SECRET_NAME} \
--docker-server=${DOCKER_SERVER} \
--docker-username=${DOCKER_USERNAME} \
--docker-password=${DOCKER_PASSWORD} \
--docker-email=${DOCKER_EMAIL} \
--dry-run=client -o yaml | kubectl apply -f -
```

> **Note:**

The envoy-gateway-system namespace is already present on the cluster. 4. Log
in to the NKP dashboard. 5. Enable NAI from the UI.

a. Go to the Applications tab.

b. Select Nutanix Enterprise AI.

c. Click Enable. 6. From the Version dropdown, select 2.6.0. 7. Configure the
application override settings.

In the Application Configuration Override window:

a. Select the target cluster(s).

b. Paste the following configuration:

```bash
global:
imagePullSecrets:
- name: nai-regcred
```

- For information on generating the Docker Hub Access Tokens, see Generating
  Nutanix Docker Hub Access Tokens.
- For information on the configuration override fields, see Nutanix Enterprise
  AI Configuration Parameters.

1. Access the NAI dashboard.

You can use the cluster's application dashboard NAI card to access the Nutanix
Enterprise AI dashboard.

a. Go to the cluster where NAI is deployed.

b. In Enabled Applications, search for Nutanix Enterprise AI.

c. Click the Dashboard link.

This will open NAI using the service external IP. 9. Create a DNS record. A
DNS record is required to map the service IP to the FQDN. 10. (Optional)
Update the Dashboard link:

```bash
export NAI_UI_ENDPOINT=https://<FQDN>/
kubectl patch cm nai-ui -n <workspace-namespace> -p '{"data":
{"dashboardLink":"'${NAI_UI_ENDPOINT}'"}}'
```

What to do next

After you enable an application for a workspace, you can deploy this
application on all the clusters within that workspace. For more information on
managing cluster-scoped applications in the NKP UI, see Cluster- scoped
Application Configuration from the NKP UI on page 371.

##### Upgrading Nutanix Enterprise AI to 2.6.0 on NKP

This topic describes how to upgrade Nutanix Enterprise AI (NAI) 2.6.0 on an
NKP cluster.

Before you begin

- Enable the following applications on your managed cluster:
- Cert Manager
- Prometheus Monitoring
- NVIDIA GPU Operator
- Envoy Gateway (v1.6.3)
- Kserve (v0.15.0)
- OpenTelemetry Operator (v0.102.0)

About this task

The NKP catalog includes NAI as an application. This allows you to deploy NAI
on your clusters with a single click.

> **Note:**

- Upgrades to Nutanix Enterprise AI version 2.6.0 are supported only from NAI
  version 2.5.0.
- For a fresh installation of Nutanix Enterprise AI 2.6.0, see Deploying
  Nutanix Enterprise AI 2.6.0 on NKP on page 384.
- Starting with NKP 2.16, you can access Nutanix AI directly from the NKP UI.
  The nkp create catalog CLI command is no longer required and is now
  deprecated.
- NAI deployment is supported on Management and Workload clusters.

To upgrade the NAI catalog applications from the NKP UI, perform the following
steps:

Procedure

1. Set the KUBECONFIG environment variable. The KUBECONFIG environment
   variable must be set to the configuration file of the cluster where NAI is
   being upgraded:

```bash
export KUBECONFIG=<cluster.conf>
```

1. Update the docker registry secret in the nai-system and envoy-gateway-
   system namespaces with your current credentials:

```bash
export REGISTRY_SECRET_NAME=nai-regcred
export DOCKER_SERVER=https://index.docker.io/v1/
export DOCKER_USERNAME=<docker-username>
export DOCKER_PASSWORD=<docker-password>
export DOCKER_EMAIL=<docker-email>
kubectl -n nai-system create secret docker-registry ${REGISTRY_SECRET_NAME} \
--docker-server=${DOCKER_SERVER} \
--docker-username=${DOCKER_USERNAME} \
--docker-password=${DOCKER_PASSWORD} \
--docker-email=${DOCKER_EMAIL} \
--dry-run=client -o yaml | kubectl apply -f -
kubectl -n envoy-gateway-system create secret docker-registry ${REGISTRY_SECRET_NAME}
\
--docker-server=${DOCKER_SERVER} \
--docker-username=${DOCKER_USERNAME} \
--docker-password=${DOCKER_PASSWORD} \
--docker-email=${DOCKER_EMAIL} \
--dry-run=client -o yaml | kubectl apply -f -
```

1. Log in to the NKP dashboard.
2. Edit the application.

a. Go to the Applications tab.

b. Select Nutanix Enterprise AI.

c. Click Edit. 5. From the Version dropdown, select 2.6.0. 6. Update the
application configuration override.

In the Application Configuration Override window:

a. Select the target cluster(s) where NAI 2.5.0 is already deployed.

b. Replace the override content:

```bash
global:
imagePullSecrets:
- name: nai-regcred
```

1. Access the NAI dashboard. Use the cluster's Application Dashboard NAI card
   to access the Nutanix Enterprise AI dashboard:

a. Go to the cluster where NAI is deployed.

b. In Enabled Applications, search for Nutanix Enterprise AI.

c. Click Dashboard link. This will open NAI on service External IP.

What to do next

After you enable an application for a workspace, you can deploy this
application on all the clusters within that workspace. For more information on
managing cluster-scoped applications in the NKP UI, see Cluster- scoped
Application Configuration from the NKP UI on page 371.

#### Nutanix Data Services for Kubernetes in Workspace

NDK provides the following features and services for applications running on
Kubernetes:

- Business Continuity and Disaster Recovery (BCDR)
- Data Management
- Data Protection and Restoration
- Application Delivery Acceleration
- Application Self-Service Management (meeting specific requirements)
- Infrastructure Automation and Monitoring (for optimal operations)
- Standardization of Governance and Compliance Policies

For more information, see the Nutanix Data Services for Kubernetes user guide.

##### Nutanix Data Services for Kubernetes on NKP Prerequisites

Note the requirements for deploying Nutanix Data Services for Kubernetes (NDK)
on Nutanix Kubernetes Platform (NKP).

- Ensure to apply your NKP Pro, Ultimate, or Full Stack (NKPFS) License to
  your cluster.

For more information, see Licenses on page 24.

- Ensure the user account that interacts with Prism Central has admin
  privileges.
- Ensure that you assign a virtual IP address to the Prism Element clusters
  for iSCSI Data Services.
- Ensure that you configure the Prism Central virtual IP address on the scale-
  out Prism Central deployments.
- Ensure that the iscsi-initiator-utils is installed on the worker nodes:

```bash
sh-5.1# rpm -q iscsi-initiator-utils
iscsi-initiator-utils-6.2.1.9-1.gita65a472.el9.x86_64
```

- For NDK version 2.0, ensure that the CSI version 3.3.8 or later is installed
  in the NKP cluster.

For more information, see Install the CSI Drivers.

- Ensure that you maintain sufficient IP addresses in the MetalLB address pool
  for Kubernetes service type:LoadBalancer.

For information about service type:LoadBalancer, see Service type:
LoadBalancer in NDK Custom Resources.

- Ensure to locate the DockerHub credentials provided as part of your NDK
  purchase.

You must log in to the Nutanix Support Portal to generate the access token for
image pull secret. Your organization can have up to two access tokens. For
more information, see Generating Nutanix Docker Hub Access Tokens.

- When enabling NDK in the NKP UI, securely reference the credentials or
  secret in values.yaml to authenticate the storage registry:

```bash
imageCredentials:
credentials:
registry: https://index.docker.io/v1/ # Leave as-is for Docker Hub, or enter
your private registry URL
username: <your-username>
password: <your-password> # For Docker Hub, use a generated access token
email: <your-email>
```

- If you already configured the credential secret, provide the
  imagePullSecretName for enabling NDK in the NKP UI:

```bash
imageCredentials:
# Name of the secret used to pull images.
imagePullSecretName: <name of the secret with image pull credentials>
```

The secret must exist in the same namespace where you install NDK. For
information on generating docker hub access tokens, see Generating Nutanix
Docker Hub Access Tokens.

To create a custom secret in the ntnx-system namespace, follow these steps:

- Enter the DockerHub credentials in config.json file:

```bash
cat > config.json << EOF
{
"auths":
{
"https://index.docker.io/v1/":
{
"auth": "$(echo -n 'username:password' | base64)",
"email": "your-email@example.com"
}
}
}
EOF
```

- Create a generic secret:

```bash
$ kubectl create secret generic <name of image pull secret> -n ntnx-system --from-
file=.dockerconfigjson=./config.json --type=kubernetes.io/dockerconfigjson
```

- Verify that the secret created exists in ntnx-system namespace:

```bash
$ kubectl get secret <name of image pull secret> -n ntnx-system
Note: If you use the pre-configured secret approach imagePullSecretName, you must manually create this
secret on every workload cluster where you deployed NDK. The secret is not automatically referenced across
clusters, so each cluster requires its own copy of the secret in the appropriate namespace.
```

##### Deploying Nutanix Data Services for Kubernetes on Air-Gapped NKP

Environments

You can deploy Nutanix Data Services for Kubernetes (NDK) on a Nutanix Nutanix
Kubernetes Platform(NKP) cluster in an air-gapped environment.

About this task

The NKP catalog includes NDK as an application, enabling you to deploy NDK on
your Nutanix clusters with a single click.

> **Note:**

- Starting with NKP 2.17, you can install Nutanix Data Services for Kubernetes
  directly from the NKP UI.

For more information on the NDK functionalities and workflows, see Nutanix
Data Services for Kubernetes.

- NDK deployment is supported on management and workload clusters.
- NDK is a cluster-scoped application and therefore each cluster runs its own
  NDK instance.

To enable NDK catalog application in the Nutanix air-gapped environment:

Procedure

1. Clone the repository:

```bash
git clone https://github.com/nutanix-cloud-native/nkp-nutanix-product-catalog.git
```

1. Go to the cloned repository:

```bash
cd nkp-nutanix-product-catalog/
```

1. Log in to DockerHub using the credentials generated in Nutanix Support
   Portal:

```bash
$ docker login --username nutanixndk
Password:
```

You must log in to the Nutanix Support Portal to generate the access token for
image pull secret. Your organization can have up to two access tokens. For
more information, see Generating Nutanix Docker Hub Access Tokens.

For air-gapped environments, the bundle includes Helm charts, container
images, and NDK images pulled from the Nutanix DockerHub, which requires
corresponding credentials. 4. Create a bundle for the catalog application:

| $ nkp create catalog-bundle --airgapped --apps=ndk=" | ndk-version | "   |
| ---------------------------------------------------- | ----------- | --- |

1. Push the bundle to the registry mirror that you configured:

```bash
$ nkp push bundle --bundle ndk-ndk-version-airgapped.tar
--to-registry-mirror-url=${REGISTRY_URL}
--to-registry-mirror-username=${REGISTRY_USERNAME} \
--to-registry-mirror-password=${REGISTRY_PASSWORD}
```

1. Create a catalog application. Copy the nkp create catalog-application
   command from the output of nkp create catalog- bundle:

```bash
$ nkp create catalog-application --url oci://<registry-url>/nkp-nutanix-product-
catalog/ndk --tag ndk-version --workspace kommander-workspace
```

Adding the catalog in kommander-workspace automatically propagates it to all
workspaces. 7. Log in to the NKP UI dashboard. 8. From the workspace header
dropdown list, select your target workspace. 9. Click View Details in the
cluster widget (management, managed, or attached clusters). The General
Cluster Configuration page is displayed. 10. In the Applications tab, select
Nutanix Data Services for Kubernetes and click Enable. 11. In the General
page, follow these steps:

a. In the Selected Cluster section, choose at least one target cluster.

b. In the Workspace Application Configuration Override code editor, enter the
configuration override:

- (Optional) To enable TLS for the webhook and NDK server, provide the
  following configuration override:

> **Note: By default, the TLS is in a disabled state.**

- For self-signed certificates by cert-manager:

```bash
tls:
server:
enable: true
clusterName: <name of NKP cluster on which this configuration is
applied>
```

- For custom issuer (a pre-configured issuer in ntnx-system namespace):

```bash
tls:
server:
enable: true
mode: "ISSUER"
issuer:
issuerName: <issuer-name>
clusterName: <name of NKP clusters>
```

- For custom secret (a pre-configured secret in ntnx-system namespace):

```bash
tls:
server:
enable: true
mode: "SECRET"
secretName: <name of pre-existing secret in ntnx-system namespace>
clusterName: <name of NKP cluster>
```

For more information about creating issuer and secret, see Installing NDK with
Server Side TLS Using CA-signed Certificates in the Nutanix Data Services for
Kubernetes guide.

- (Optional) To enable MTLS between the NDK intercom service on the source
  cluster and the replication Kubernetes cluster, provide the following
  configuration override:

```bash
tls:
server:
enableMTLS: true
```

> **Note: By default, the MTLS is in a disabled state.**

The same trusted CA must sign the certificates used by the primary and
replication clusters.

- (Optional) To enable communication between the NDK intercom service on the
  source cluster and the replication Kubernetes cluster using your own load
  balancer:

```bash
intercomService:
type: LoadBalancer
loadBalancerClass:
loadBalancerIP:
```

- Provide both loadBalancerClass and loadBalancerIP.
- If you do not provide both loadBalancerClass and loadBalancerIP, MetalLB
  assigns a free IP address from its pool.
- IP assignment fails with an error, in the following cases:
- No free IP address is available in the MetalLB address pool.
- The loadBalancerIP you specify is not present in the MetalLB address pool.

1. Click Enable.

What to do next

After you enable an application for a workspace, you can deploy this
application on all the clusters within that workspace. To configure the
various policies and schedules in NDK, see Configure NDK.

For more information on managing cluster-scoped applications in the NKP UI,
see Cluster-scoped Application Configuration from the NKP UI on page 371.

##### Deploying Nutanix Data Services for Kubernetes on Non Air-Gapped NKP

Environments

You can deploy Nutanix Data Services for Kubernetes (NDK) on a Nutanix Nutanix
Kubernetes Platform(NKP) cluster in a non-air-gapped environment.

About this task

The NKP catalog includes NDK as an application, enabling you to deploy NDK on
your clusters with a single click.

> **Note:**

- Starting with NKP 2.17, you can install Nutanix Data Services for Kubernetes
  directly from the NKP UI.

For more information on the NDK functionalities and workflows, see Nutanix
Data Services for Kubernetes.

- NDK deployment is supported on Management and Workload clusters.
- NDK is a cluster-scoped application and therefore each cluster runs its own
  NDK instance.

To enable NDK catalog application in the Nutanix non-air-gapped environment:

Procedure

1. Log into the NKP UI dashboard.
2. From the workspace header drop-down list, select your target workspace.
3. Click View Details in the cluster widget (management, managed, or attached
   clusters). The General Cluster Configuration page is displayed.
4. In the Applications tab, select Nutanix Data Services for Kubernetes and
   click Enable.
5. In the General page, follow these steps:

a. In the Selected Cluster section, choose at least one target cluster.

b. In the Workspace Application Configuration Override code editor, enter the
configuration override to customize the application deployment:

- To pull the image from the container registry, update the `<username>`,
  `<password>` and `<email>` fields with the Docker Hub credentials provided
  as part of the NDK purchase.

```bash
imageCredentials:
credentials:
registry: https://index.docker.io/v1/ # Leave as-is for Docker Hub, or
enter your private registry URL
username: <your-username>
password: <your-password> # For Docker Hub, use a generated access token
email: <your-email>
```

If you already configured the credential secret, provide the
imagePullSecretName:

```bash
imageCredentials:
# Name of the secret that will be created to pull images.
imagePullSecretName: <name of the secret with image pull credentials>
```

The secret must exist in the same namespace where you install NDK. For
information on generating docker hub access tokens, see Generating Nutanix
Docker Hub Access Tokens.

- Note: By default, the TLS is in a disabled state.

(Optional) To enable TLS for the webhook and NDK server, provide the following
configuration override:

- For self-signed certificates by cert-manager:

```bash
tls:
server:
enable: true
clusterName: <name of NKP cluster on which this configuration is applied>
```

- For custom issuer (a pre-configured issuer in ntnx-system namespace):

```bash
tls:
server:
enable: true
mode: "ISSUER"
issuer:
issuerName: <issuer-name>
clusterName: <name of NKP cluster>
```

- For custom secret (a pre-configured secret in ntnx-system namespace):

```bash
tls:
server:
enable: true
mode: "SECRET"
secretName: <name of pre-existing secret in ntnx-system namespace>
clusterName: <name of NKP cluster>
```

For more information about creating issuer and secret, see Installing NDK with
Server Side TLS Using CA-signed Certificates in the Nutanix Data Services for
Kubernetes guide.

- Note: By default, the MTLS is in a disabled state.

(Optional) To enable MTLS between the NDK intercom service on the source
cluster and the replication Kubernetes cluster, provide the following
configuration override:

```bash
tls:
server:
enableMTLS: true
```

The same trusted CA must sign the certificates used by the primary and
replication clusters.

- (Optional) To enable communication between the NDK intercom service on the
  source cluster and the replication Kubernetes cluster using your own load
  balancer:

```bash
intercomService:
type: LoadBalancer
loadBalancerClass:
loadBalancerIP:
```

- To make the configuration valid, provide both loadBalancerClass and
  loadBalancerIP.
- If you do not provide both loadBalancerClass and loadBalancerIP, MetalLB
  assigns a free IP address from its pool.
- IP assignment fails with an error, when:
- No free IP address is available in the MetalLB address pool.
- The loadBalancerIP you specify is not present in the MetalLB address pool.

1. Click Enable.

What to do next

After you enable an application for a workspace, you can deploy this
application on all the clusters within that workspace. To configure the
various policies and schedules in NDK, see Configure NDK.

For more information on managing cluster-scoped applications in the NKP UI,
see Cluster-scoped Application Configuration from the NKP UI on page 371.

#### Deployment of Catalog Applications in Workspaces

To deploy an application to selected clusters within a workspace, see Cluster-
scoped Application for Existing AppDeployments on page 373.

##### Enabling the Catalog Application Using the UI

Before you begin

Before you begin, you must have:

- A running cluster with Kommander installed. The cluster must be on a
  supported Kubernetes version for this release of NKP and also compatible
  with the catalog application version you want to install.
- Attach an Existing Kubernetes Cluster section of the documentation
  completed. For more information, see Attaching an Existing Kubernetes
  Cluster on page 474.
- Set the WORKSPACE_NAMESPACE environment variable to the name of the
  workspace's namespace the attached cluster exists in.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

- A Git Repository. After creating a GitRepository, use either the NKP UI or
  the CLI to enable your catalog applications. For more information, see
  Creating a Catalog Collection or an Application on page 404.

```yaml
Warning: From within a workspace, you can enable applications to deploy. Verify that an application has
successfully deployed through the CLI.
```

About this task

Follow these steps to enable your catalog applications from the NKP UI:

Procedure

1. Ultimate only: From the top menu bar, select your target workspace.
2. From the sidebar menu to browse the available applications from your
   configured repositories and select Applications.
3. Select the three dot button on the required application tile and select
   Enable.
4. If available, select a version from the dropdown list. This dropdown list
   will only be visible if there is more than one version.
5. (Optional) If you want to override the default configuration values, copy
   your customized values into the text editor under Workspace Configuration or
   upload your YAML file that contains the values.

```bash
someField: someValue
```

1. Confirm the details are correct, and then click Enable. For all
   applications, you must provide a display name and an ID which is
   automatically generated based on what you enter for the display name, unless
   or until you edit the ID directly. The ID must be compliant with Kubernetes
   DNS subdomain name validation rules in the Kubernetes documentation.
   Alternately, you can use the CLI to enable your catalog applications.

##### Enabling the Catalog Application Using the CLI

See Workspace Catalog Applications for the list of available applications that
you can deploy on the attached cluster.

Before you begin

Procedure

1. Enable a supported application to deploy to your attached Kubernetes
   cluster with an AppDeployment resource.

For more information, see Attaching an Existing Kubernetes Cluster on page
\474. 2. Within the AppDeployment, define the appRef to specify which App to
enable.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: operator
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: operator-0.25.1
kind: App
EOF
```

> **Note:**

- The appRef.name must match the app name from the list of available catalog
  applications.
- Create the resource in the workspace you just created, which instructs
  Kommander to deploy the AppDeployment to the KommanderClusters in the same
  workspace.

##### Enabling the Catalog Application With a Custom Configuration Using the CLI

About this task

To enable the catalog application:

Procedure

1. Provide the name of a ConfigMap in the AppDeployment, which provides custom
   configuration on top of the default configuration.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: operator
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: operator-0.25.1
kind: App
configOverrides:
name: operator-overrides
EOF
```

1. Create the ConfigMap with the name provided in the step above, with the
   custom configuration.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
namespace: ${WORKSPACE_NAMESPACE}
name: operator-overrides
data:
values.yaml: |
operator:
verboseLogging: true
EOF
```

Kommander waits for the ConfigMap to be present before deploying the
AppDeployment to the managed or attached clusters.

##### Verify the Catalog Applications

The applications are now enabled.

Procedure

Connect to the attached cluster and check the HelmReleases to verify the
deployment.

```bash
kubectl get helmreleases -n ${WORKSPACE_NAMESPACE}
```

The result appears as follows.

```bash
NAMESPACE NAME READY STATUS
AGE
workspace-test-vjsfq operator True Release reconciliation succeeded 7m3s
```

#### Workspace Catalog Application Upgrade

Before upgrading, keep in mind the distinction between Platform applications
and Catalog applications. Platform applications are deployed and upgraded as a
set for each cluster or workspace. Catalog applications are deployed
separately, so that you can deploy and upgrade them individually for each
workspace or project.

##### Upgrading the Catalog Applications Using the UI

Before you begin

Complete the upgrade prerequisites tasks. For more information, see Plan the
Upgrade on page 1042.

About this task

To upgrade an application from the NKP UI:

Procedure

1. From the top menu bar, select your target workspace.
2. From the sidebar menu, select Applications.
3. Select the three dot button on the required application tile, and then
   select Edit.
4. Select the Version from the dropdown list and select a new version. This
   dropdown list is only available if there is a newer version to upgrade to.
5. Click Save.

##### Upgrading the Catalog Applications Using the CLI

Before you begin

> **Note: The commands use the workspace name and not namespace.**

You can retrieve the workspace name by running the following command.

```bash
nkp get workspaces
```

To view a list of the deployed apps to your workspace, run the following
command.

```bash
nkp get appdeployments --workspace=<workspace-name>
```

Complete the upgrade prerequisites tasks. For more information, see Plan the
Upgrade on page 1042.

About this task

To upgrade an application from the CLI:

Procedure

1. To see what app(s) and app versions are available to upgrade, run the
   following command.

> **Note: You can reference the app version by going into the app name (e.g.
> `<APP ID>`-`<APP VERSION>`.**

```bash
kubectl get apps -n ${WORKSPACE_NAMESPACE}
```

You can also use this command to display the apps and app versions, for example.

```bash
kubectl get apps -n ${WORKSPACE_NAMESPACE} -o jsonpath='{range .items[*]}
{@.spec.appId}{"----"}{@.spec.version}{"\n"}{end}'
```

The output displays the different application and application versions. 2. Run
the following command to upgrade an application from the NKP CLI.

```bash
nkp upgrade catalogapp <appdeployment-name> --workspace=<my-workspace-name> --to-
version=<version.number>
Note: Platform applications cannot be upgraded on a one-off basis, and must be upgraded in a single process for
each workspace. If you attempt to upgrade a platform application with these commands, you receive an error and
the application is not upgraded.
```

#### Partner Catalog in NKP

You can contribute to partner catalog only if you are a Nutanix Elevate
Technology Alliance Partner with Kubernetes-based applications that meet NKP
quality and security standards.

NKP partner catalog helps NKP customers discover their product or application
across hybrid-cloud, multi-cloud, and multi-cluster environments. By
submitting applications to the catalog, you can:

- Reach the enterprise customer base of NKP without requiring separate
  installation channels. You can deploy and update your software through a
  familiar NKP workflow.
- Tag releases against specific NKP versions so that customers see only the
  compatible versions.

After onboarding the application, you are granted access to a dedicated Git
repository.

- Prepare and test your application. Package the application into a Helm
  chart, test installation, and upgrade flows locally before submission.
- Fork and contribute. Fork the catalog repository, place the application
  under the appropriate directory (for NKP specific apps or cross-cluster
  apps), and create a pull request (PR).
- Provide metadata. Each submission must include a metadata file, specifying
  description, version, supported NKP releases, support contacts, categories,
  keywords and a logo. NKP requires capabilities, container image, creation
  date, support contact, and repository fields, and NKP will require analogous
  metadata.
- Run automated tests. When a PR is opened, the CI system of NKP automatically
  validates if the application is installed and can be upgraded. Applications
  that fail installation or upgrade tests are flagged for partner correction.
- Review and approval. The NKP engineering team reviews submissions for
  security, licensing, and quality. Once approved and merged, the application
  appears in the partner catalog Git repository and is visible when enabled in
  the catalog.

> **Note:**

- Partners can update or remove applications by submitting additional PRs.
- Each application version must be tagged with the NKP releases it supports.
  Only the versions compatible with the your NKP version is displayed.

In NKP UI, Applications Catalog displays Preferred Partner Apps category
containing all approved partner applications. You can browse descriptions, see
which NKP versions are supported, and deploy the apps with a few clicks. The
catalog ensures that only applications qualified for your NKP version are
displayed, reducing the risk of incompatible deployments. The support contacts
are provided by the partner for assistance.

##### Creating a New Application

This page details the creation of a new application in Partner Catalog.

About this task

To create a new application and update an existing application, follow these
steps:

Procedure

1. Clone the repository.

```bash
git clone git@github.com:nutanix-cloud-native/nkp-partner-catalog.git
```

> **Note:**

- You must fork and work off the repository.
- You must download the NKP binary to create a new application in partner
  catalog.

1. Install devbox.

Devbox is a CLI tool used for creating isolated shells for development. For
more information, see devbox. 3. Run devbox shell to enter the devbox
environment in the cloned repository directory. An environment with all the
necessary dependencies is set up. Subsequently, you can run commands like nkp,
just, and go directly. 4. Generate a placeholder application version directory
by running the following command:

```bash
nkp generate catalog-repository --apps=<app-name>=<app-version>
```

A placeholder directory layout for your new application is generated in
applications/ directory with your application name and version.

##### Overview of the Application Structure

This page details about the partner catalog application repository structure.

- Each application can have multiple versions with its own directory.
- Each version must include metadata.yaml used by NKP UI for rendering
  metadata description.
- After merging, the OCI artifacts are built and pushed to the
  ghcr.io/nutanix-cloud-native/nkp- partner-catalog/`<app-name>`
  automatically.

Sample directory structure:

```bash
...
### applications (3)
# ### <app-name>
# ### <app-version1>
# ### helmrelease
# # ### cm.yaml // ConfigMap specifying default
configuration overrides for HelmRelease
# # ### helmrelease.yaml // OCIRepository and HelmRelease
# # ### kustomization.yaml // Kubernetes Kustomization file
# ### helmrelease.yaml // FluxCD Kustomization file for the
HelmRelease
# ### kustomization.yaml // Kubernetes Kustomization file
# ### metadata.yaml // Application details
# ### <app-version2>
# ### helmrelease (2)
# # ### cm.yaml
# # ### helmrelease.yaml
# # ### kustomization.yaml
# ### helmrelease.yaml
# ### kustomization.yaml
# ### metadata.yaml
...
Note: For more information about Git Repository Structure and Application Metadata, see
Custom Applications on page 402.
```

##### Structuring an Application in Partner Catalog

This page details the structuring of application in the partner catalog.

About this task

To structure an application in the partner catalog.

Procedure

1. Update open container initiative OCIRepository URL to point the Helm chart
   of your application.
2. Add optional overrides for application HelmRelease into cm.yaml as
   necessary. The default layout (generated in the previous step) addresses
   most use cases that deploy a simple application with no dependencies. If
   there are dependencies in deploying various components of the application,
   see Flux Kustomization. Flux Kustomization provides the necessary details to
   deploy an application with multiple

top level Flux Kustomization files that depends on each other and the ability
to define health checks for each kustomization. For more information, see
Dependencies and Health checks.

> **Note: Following are the substitution variables in the application:**

- ${releaseName}: Dynamically substituted with the AppDeployment value
  provided during installation. For more information, see Applications on page

1.

- ${releaseNamespace}: Dynamically substituted with the namespace where the
  app is deployed.

1. Validate your directory by running the following command.

```bash
nkp validate catalog-repository --repo-dir=/path/to/nkp-partner-catalog
```

(Optional) Customize the validation behavior by adding a bloodhound
configuration file. Bloodhound is the linter configuration used for catalog
application validation during CI/CD processes. You can configure validation
settings by creating a .bloodhound.yaml or .bloodhound.yml file at the
repository root or application level. For more information, see Bloodhound
Configuration.

#### Custom Applications

##### Git Repository Structure

Git repositories must be structured in a specific manner for defined
applications to be processed by Kommander.

You must structure your Git repository based on the following guidelines, for
your applications to be processed properly by Kommander so that they can be
deployed.

Git Repository Directory Structure

Run the following command to generate a new Git repository for hosting your
catalog applications:

```bash
mkdir -p /new/directory/for/catalog
cd /new/directory/for/catalog
nkp generate catalog-repository
```

Run the following command, to generate a directory for your application
version. You can run this command multiple times (once for each version of a
given application).

```bash
nkp generate catalog-repository --apps <app-name>=<app-version>
```

Above commands will generate following basic directory structure:

```bash
...
### applications (4)
# ### <app-name> (2)
# ### <app-version1> (2)
# ### helmrelease (3)
# # ### cm.yaml // ConfigMap specifying default (2)
configuration overrides for HelmRelease
# # ### helmrelease.yaml // OCIRepository and HelmRelease (2)
# # ### kustomization.yaml // Kubernetes Kustomization file (2)
# ### helmrelease.yaml // FluxCD Kustomization file for the (2)
HelmRelease
# ### kustomization.yaml // Kubernetes Kustomization file (2)
# ### metadata.yaml // Application details (2)
# ### <app-version2> (2)
# ### helmrelease (4)
# # ### cm.yaml (2)
# # ### helmrelease.yaml (2)
# # ### kustomization.yaml (2)
# ### helmrelease.yaml (2)
# ### kustomization.yaml (2)
# ### metadata.yaml (2)
...
```

Remember the following guidelines:

- Define applications in the applications/ directory.
- You can define multiple versions of an application, under different
  directories nested under the applications/ `<app name>`/ directory.
- Populate the HelmRelease and OCIRepository details in the versioned
  directory applications/`<app name>`/ `<app version>`/helmrelease in the
  helmrelease.yaml file. For more information, see HelmRelease, OCIRepository
  in the Flux documentation, and The Kustomization File in the SIG CLI
  documentation.
- Define the default values ConfigMap for HelmReleases in the
  applications/`<app name>`/`<app version>`/helmrelease/cm.yaml file accompanied
  by a kustomization.yaml Kubernetes Kustomization file pointing to the
  ConfigMap file.
- Define the metadata.yaml of each application under the applications/`<app name>`/`<app version>` directory. For more information, see Application
  Metadata on page 405.
- You can generate a new application version directory with the required
  layout and files by running:

```bash
nkp generate catalog-repository --apps=<app-name>=<app-version>
```

For an example of how to structure catalog Git repositories, see Overview of
the Application Structure on page 401.

OCI Repositories

You must include the OCIRepository that is referenced in each HelmRelease's
Chart spec.

Each applications/`<app name>`/`<app version>`/helmrelease/helmrelease.yaml file
must include YAML definition of the OCIRepository along with the HelmRelease
definition.

For more information, see OCI Repository in the Flux documentation.

Substitution Variables

Some substitution variables are provided. For more information, see
Kustomization in the Flux documentation.

- ${releaseName}: For each App deployment, this variable is set to the
  AppDeployment name. Use this variable to prefix the names of any resources
  that are defined in the application directory in the Git repository so that
  multiple instances of the same application can be deployed. If you create
  resources without using the releaseName prefix (or suffix) in the name
  field, there can be conflicts if the same named resource is created in that
  same namespace.
- ${releaseNamespace}: The namespace of the workspace.
- ${workspaceNamespace}: The namespace of the workspace that the Workspace
  belongs to.

##### Creating a Catalog Collection or an Application

Use CLI to create a Flux OCIRepository resource in your workspace or project
that acts as a source for your catalog applications.

About this task

Create an OCIRepository in the workspace or project namespace.

Procedure

1. To build an OCI artifact from your catalog git repository run the following
   command. This generates a .tar file locally.

```bash
nkp create catalog-bundle --collection-tag <tag>
```

Above command will bundle up all versions of all applications in the current
directory.

> **Note:**

- To include only selected applications use --apps flag.
- To include the container images use --airgapped flag. This is required for
  air-gapped environments.

1. Push the OCI artifact to a registry that is accessible to the cluster. The
   registry used must be OCI Compliant.

```bash
nkp push bundle --bundle <path-to-file-generated-above.tar> --to-registry <your-
registry-url>
```

1. You can either create a catalog collection (group of applications) or just
   one application in your NKP Cluster. Note that creating a catalog in the
   Kommander workspace will automatically propagate it to all other
   workspaces/projects/. If you prefer to limit the scope of catalog to a
   single workspace or project, use the --workspace or --project flags
   accordingly. Run either one of the following commands:

- Create a Catalog Collection

```bash
nkp create catalog-collection --url oci://<registry-url>/<repo-name>/collection --
workspace <workspace-or-project-namespace> --tag <tag>
```

- Create a Catalog Application

```bash
nkp create catalog-collection --url oci://<registry-url>/<repo-name>/<app-name> --
workspace <workspace-or-project-namespace> --tag <app-version>
```

1. Optionally, ensure the status of the OCIRepository signals a ready state.

```bash
kubectl get ocirepository -n <workspace-or-project-namespace>${WORKSPACE_NAMESPACE}
<name-printed-in-above-create-command>
```

The repository commit also displays the ready state.

```bash
NAME URL READY STATUS

AGE
example-repo https://github.com/example-org/example-repo True stored
artifact for digest
'2.16@sha256:c7cbee436dc81ac09c7b985696ba798c4d55f6964634c0f1e89e282e632aaaf3'
1m
```

###### Troubleshooting an OCIRepository

Logs used for troubleshooting issues with creating OCIRepository sources.

Procedure

Review the following logs:

```bash
kubectl -n kommander-flux logs -l app=source-controller
[...]
kubectl -n kommander-flux logs -l app=kustomize-controller
[...]
kubectl -n kommander-flux logs -l app=helm-controller
[...]
```

For more information, see:

- Flux: `<https://fluxcd.io/>`
- Flux documentation: `<https://fluxcd.io/docs>`

##### Application Metadata

You can define how custom applications display in the NKP UI by defining a
metadata.yaml file for each version of an application in the git repository.
You must define this file at applications/`<app name>`/`<app version>`/metadata.yaml for it to process correctly.

You can define the following fields:

displayName App ID Display name of the application for the UI.

allowMultipleInstances true Whether multiple instances of the application can
be installed.

category [general] One or more categories for this application. Categories are
used to group applications in the UI.

description "" Short description, must be a sentence or two, displayed in the
UI on the application card.

dependencies List of applications that must be installed in order for the
application to function properly. The UI will not block the installation of
the application if the dependencies are not installed

requiredDependencies List of applications that are required to be installed in
order for the application to be enabled in the UI.

k8sVersionSupport A string indicating the compatible Kubernetes version or
range. For example, from 1.29 to 1.32).

icon Base64 encoded icon SVG file used for application logos in the UI.

nkpVersionSupport A string indicating the compatible NKP version or range.

| Field | Default | Description |
| ----- | ------- | ----------- |

overview Markdown overview used on the application detail page in the UI.

supportLink A link to the support page

scope [project] List of scopes, can be set only to project or workspace
currently.

upgradesFrom A string indicating the version or range of versions that the
application can be upgraded from.

licensing [Pro, Ultimate] Cluster must have one of these licenses applied in
order for the application to be installable.

certifications List of certifications that the application has.

type custom Type of application

The following JSON Schema must be adhered to in the metadata.yaml file for it
to be processed accurately. To validate metadata.yaml against the schema, run
the following command:

```bash
nkp validate catalog-repository --repo-dir=/path/to/catalog-repository
{
"$schema": "https://json-schema.org/draft/2020-12/schema",
"$id": "catalog.nkp.nutanix.com/v1/application-metadata",
"properties": {
"schema": {
"type": "string",
"description": "Identifies the schema used."
},
"displayName": {
"type": "string",
"description": "Display name of the application for the UI.\nFalls back to App ID
if not given."
},
"allowMultipleInstances": {
"type": "boolean",
"description": "Whether multiple instances of the application can be installed.
Defaults to true.",
"default": true
},
"category": {
"items": {
"type": "string"
},
"type": "array",
"description": "1 or more categories for this application. Categories are used to
group applications in the UI.\nDefaults to [general].",
"default": [
"general"
]
},
"description": {
"type": "string",
"description": "Short description, should be a sentence or two, displayed in the
UI on the application card."
},
"dependencies": {
"items": {
"type": "string"
},
```

| Field | Default | Description |
| ----- | ------- | ----------- |

```bash
"type": "array",
"description": "List of applications that should be installed in order for the
application to function properly.\nThe UI will not block the installation of the
application if the dependencies are not installed."
},
"requiredDependencies": {
"items": {
"type": "string"
},
"type": "array",
"description": "List of applications that are required to be installed in order
for the application to be enabled in the UI."
},
"k8sVersionSupport": {
"type": "string",
"pattern": "^(0|[1-9]\\d*)(\\.(0|[1-9]\\d*)){0,2}$|^((>=?|<=?)\\s*(v)?(0|[1-9]\
\d*)(\\.(0|[1-9]\\d*)){0,2})(\\s*(>=?|<=?)\\s*(v)?(0|[1-9]\\d*))?(\\.(0|[1-9]\\d*))
{0,2}?$",
"description": "A string indicating the compatible Kubernetes version or range."
},
"icon": {
"type": "string",
"description": "Base64 encoded icon SVG file used for application logos in the
UI."
},
"nkpVersionSupport": {
"type": "string",
"pattern": "^(0|[1-9]\\d*)(\\.(0|[1-9]\\d*)){0,2}$|^((>=?|<=?)\\s*(v)?(0|[1-9]\
\d*)(\\.(0|[1-9]\\d*)){0,2})(\\s*(>=?|<=?)\\s*(v)?(0|[1-9]\\d*))?(\\.(0|[1-9]\\d*))
{0,2}?$",
"description": "A string indicating the compatible NKP version or range."
},
"overview": {
"type": "string",
"description": "Markdown overview used on the application detail page in the UI."
},
"supportLink": {
"type": "string",
"pattern": "^https?:\\/\\/([a-zA-Z0-9\\.-]+)\\.([a-zA-Z]{2,6})(:[0-9]{1,5})?(\\/
[^\\s]*)?$",
"description": "A link to the support page."
},
"scope": {
"items": {
"type": "string",
"enum": [
"project",
"workspace"
]
},
"type": "array",
"description": "List of scopes, can be set only to project and/or workspace.
Defaults to project.",
"default": [
"project"
]
},
"upgradesFrom": {
"type": "string",
"pattern": "^(0|[1-9]\\d*)(\\.(0|[1-9]\\d*)){0,2}$|^((>=?|<=?)\\s*(v)?(0|[1-9]\
\d*)(\\.(0|[1-9]\\d*)){0,2})(\\s*(>=?|<=?)\\s*(v)?(0|[1-9]\\d*))?(\\.(0|[1-9]\\d*))
{0,2}?$",
"description": "A string indicating the version or range of versions that the
application can be upgraded from."
},
"licensing": {
"items": {
"type": "string",
"enum": [
"Starter",
"Pro",
"Ultimate"
]
},
"type": "array",
"description": "Cluster must have one of these licenses applied in order for the
application to be installable.\nDefaults to [Pro, Ultimate].",
"default": [
"Pro",
"Ultimate"
]
},
"certifications": {
"items": {
"type": "string",
"enum": [
"airgapped",
"qualified",
"nutanix-supported"
]
},
"type": "array",
"description": "List of certifications that the application has."
},
"type": {
"type": "string",
"enum": [
"internal",
"nkp-core-platform",
"nkp-catalog",
"preferred-partner",
"custom"
],
"description": "Type of application.",
"default": "custom"
}
},
"additionalProperties": false,
"type": "object",
"required": [
"schema"
],
"description": "Metadata for an application."
}
```

None of these fields are required for the application to display in the UI.

Here is an example metadata.yaml file.

```yaml
schema: "catalog.nkp.nutanix.com/v1/application-metadata"
displayName: Prometheus Monitoring Stack
description: Stack of applications that collect metrics and provides visualization and
alerting capabilities. Includes Prometheus, Prometheus Alertmanager and Grafana.
category:
- monitoring
overview: >
# Overview
A stack of applications that collects metrics and provides visualization and alerting
capabilities. Includes Prometheus, Prometheus Alertmanager and Grafana.
## Dashboards
By deploying the Prometheus Monitoring Stack, the following platform applications and
their respective dashboards are deployed. After deployment to clusters in a workspace,
the dashboards are available to access from a respective cluster's detail page.
### Prometheus
A software application for event monitoring and alerting. It records real-time
metrics in a time series database built using a HTTP pull model, with flexible and
real-time alerting.
- [Prometheus Documentation - Overview](https://prometheus.io/docs/introduction/
overview/)
### Prometheus Alertmanager
A Prometheus component that enables you to configure and manage alerts sent by the
Prometheus server and to route them to notification, paging, and automation systems.
- [Prometheus Alertmanager Documentation - Overview](https://prometheus.io/docs/
alerting/latest/alertmanager/)
### Grafana
A monitoring dashboard from Grafana that can be used to visualize metrics collected
by Prometheus.
- [Grafana Documentation](https://grafana.com/docs/)
icon:
PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAzMDAgMzAwIiBzdHlsZT0iZW5hYm
```

##### Custom Application from the Workspace Catalog

After creating a catalog collection or an application, you can either use the
NKP user interface or the CLI to enable your custom applications. To deploy an
application to selected clusters within a workspace, see Cluster-scoped
Application Configuration from the NKP UI on page 371.

From within a workspace, you can enable applications to deploy. Verify that
the application has successfully deployed through the CLI.

###### Enabling the Custom Application Using the UI

About this task

Procedure

1. From the top menu bar, select your target workspace.
2. From the sidebar menu to browse the available applications from your
   configured repositories, select Applications.
3. Select the three dot button on the required application tile and click
   Enable.
4. If available, select a version from the dropdown list. This dropdown list
   will only be visible if there is more than one version.
5. (Optional) If you want to override the default configuration values, copy
   your customized values into the text editor under Workspace Configuration or
   upload your YAML file that contains the values.

```bash
someField: someValue
```

1. Confirm the details are correct, and then click Enable.

For all applications, you must provide a display name and an ID which is
automatically generated based on what you enter for the display name, unless
or until you edit the ID directly. The ID must be compliant with Kubernetes
DNS subdomain name validation rules. For more information, see DNS Subdomain
Names section in the Kubernetes documentation.

Alternately, you can use the CLI to enable your catalog applications.

###### Enabling the Custom Application Using the CLI

Before you begin

- Determine the name of the workspace where you wish to perform the
  deployments. You can use the nkp get workspaces command to see the list of
  workspace names and their corresponding namespaces.
- Set the WORKSPACE_NAMESPACE environment variable to the name of the
  workspace's namespace where the cluster is attached:

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

Procedure

1. Get the list of available applications to enable using the following command.

```bash
kubectl get apps -n ${WORKSPACE_NAMESPACE}
```

1. Deploy one of the supported applications from the list with an
   AppDeployment resource.
2. Within the AppDeployment, define the appRef to specify which App to enable.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: my-custom-app
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: custom-app-0.0.1
kind: App
EOF
```

> **Note:**

- The appRef.name must match the app name from the list of available catalog
  applications.
- Create the resource in the workspace you just created, which instructs
  Kommander to deploy the AppDeployment to the KommanderClusters in the same
  workspace.

###### Enabling the Custom Application With Custom Configuration Using the CLI

About this task

Procedure

1. Provide the name of a ConfigMap in the AppDeployment, which provides custom
   configuration on top of the default configuration.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: my-custom-app
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: custom-app-0.0.1
kind: App
configOverrides:
name: my-custom-app-overrides
EOF
```

1. Create the ConfigMap with the name provided in the step above, with the
   custom configuration.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
namespace: ${WORKSPACE_NAMESPACE}
name: my-custom-app-overrides
data:
values.yaml: |
someField: someValue
EOF
```

Kommander waits for the ConfigMap to be present before deploying the
AppDeployment to the managed or attached clusters.

###### Verify the Custom Applications

After completing the previous steps, your applications are enabled.

Procedure

Connect to the attached cluster and check the HelmReleases to verify the
deployment.

```bash
kubectl get helmreleases -n ${WORKSPACE_NAMESPACE}
```

The output is as follows.

```bash
NAMESPACE NAME READY STATUS AGE
workspace-test-vjsfq my-custom-app True Release reconciliation succeeded 7m3s
```

### Configuring Workspace Role Bindings

Before you begin

Before you can create a Workspace Role Binding, ensure you have created a
workspace Group. A Group can contain one or several Identity Provider users,
groups or both.

The syntax for the Identity Provider groups you add to a Group varies
depending on the context for which you have established an Identity Provider.

- If you have set up an identity provider globally, for All Workspaces:
- For groups: Add an Identity Provider Group in the oidc:`<IdP_user_group>`
  format. For example, oidc:engineering.
- For users: Add an Identity Provider User in the `<user_email>`. For example,
  `<jane.doe@example.com>`.
- If you have set up an identity provider for a Specific Workspace:
- For groups: Add an Identity Provider Group in the
  oidc:`<workspace_name>`:`<IdP_user_group>` format. For example,
  oidc:tenant-z:engineering.
- For users: Add an Identity Provider User in the
  `<workspace_ID>`:`<user_email>` format. For example,
  tenant-z:jane.doe@example.com.

```yaml
Note: Run kubectl get workspaces to obtain a list of all existing workspaces. The workspace_ID is listed
under the NAME column.
```

About this task

You can assign a role to this Kommander Group:

Procedure

1. From the top menu bar, select your target workspace.
2. Select Access Control in the Administration section of the sidebar menu.
3. Select the Cluster Role Bindings tab, and then select Add Roles next to the
   group you want.
4. Select the Role, or Roles, you want from the dropdown list and click Save.
   It will take a few minutes for the resource to be created.

### Multi-Tenancy in NKP

Here are some important concepts:

Multi-tenant environments have at least two participating parties: the
Ultimate license administrator (for example, an MSP), and one or several
tenants.

- Managed Service Providers or MSPs are partner organizations that use NKP to
  facilitate cloud infrastructure services to their customers or tenants.
- Tenants can be customers of Managed Service Provider partners. They
  outsource their cloud management requirements to MSPs, so they can focus on
  the development of their products.

Tenants can also be divisions within an organization that require a strict
isolation from other divisions, for example, through differentiated access
control.

In NKP, a workspace is assigned to a tenant.

Access Control in Multi-Tenant Environments

To isolate each tenant's information and environment, multi-tenancy allows you
to configure an identity provider per workspace or tenant. In this setup, NKP
keeps all workspaces and tenants separate and isolated from each other.

You, as a global administrator, manage tenant access at the Workspace level. A
tenant can further adapt user access at the Project level.

Figure 9: Multi-tenant Cluster

Here are some important concepts:

- Workspaces: In a multi-tenant system, workspaces and tenants are synonymous.
  You can set up an identity provider to control all workspaces, including the
  Management cluster's kommander workspace. You can then set up additional
  identity providers for each workspace/tenant, and generate a dedicated Login
  URL so each tenant has its own user access.

### Generating a Dedicated Login URL for Each Tenant

- Projects: After you set up an identity provider per workspace or tenant, the
  tenant can choose to further narrow down access with an additional layer. A
  tenant can choose to organize clusters into projects and assign
  differentiated access to user groups with Project Role Bindings.

For more information, see Project Role Bindings on page 442.

By assigning clusters to one or several projects, you can enable more complex
user access.

Multi-Tenancy Enablement

To enable multi-tenancy, you must:

- If you want to use a single IdP to access all of your tenant's environments,
  configure an Identity Provider globally.
- Configure an Identity Provider per workspace. This way, each tenant has a
  dedicated IdP to access their workspace.
- Create NKP Identity Provider groups with the correct prefixes to map your
  existing IdP groups.
- Create a dedicated login URL for each tenant. You can provide a workspace
  login link to each tenant for access to the NKP UI and for the generation of
  kubectl API access tokens.

To enforce security, every tenant should be in a different AWS account, so
they are truly independent of each other.

About this task

By making this URL available to your tenant, you provide them with a dedicated
login page, where users can enter their SSO credentials to access their
workspace in the NKP UI and to where users can create a token to access a
cluster's kubectl API. Other tenants and their SSO configurations are not
visible.

Before you begin

- Complete the steps in Multi-Tenancy in NKP on page 412.
- Ensure you have administrator permissions and access to all workspaces.

Procedure

1. Set an environment variable to point at the workspace for which you want to
   generate a URL: Replace `<name_target_workspace>` with the workspace name.
   If you do not know the exact name of the workspace, run kubectl get
   workspace to get a list of all workspace names.

```bash
export WORKSPACE_NAME=<name_target_workspace>
```

1. Generate an NKP UI login URL for that workspace.

```bash
echo https://$(kubectl get nkpcluster -n kommander -l 'kommander.d2iq.io/host=true'
-o jsonpath='{.items[0].kommanderCluster.status.ingress.address }')/token/landing/
${WORKSPACE_NAME}
```

The output is as follows.

```bash
https://example.com/token/landing/<WORKSPACE_NAME>
```

1. Share the output login URL with your tenant, so users can start accessing
   their workspace from the NKP UI.

> **Note: The login page displays:**

- Identity providers set globally.
- Identity providers set for that specific workspace.

The login page does not display any resources or workspaces for which the
tenant has no permissions.

## Projects

Multi-cluster Configuration Management

Projects support the management of configMaps, continuous deployments,
secrets, services, quotas, and role-based access control and multi-tenant
logging by leveraging federated resources. When a Project is created, NKP
creates a federated namespace that is propagated to the Kubernetes clusters
associated with this Project.

Federation in this context means that a common configuration is pushed out
from a central location (NKP) to all Kubernetes clusters, or a pre-defined
subset group, under NKP management. This pre-defined subset group of
Kubernetes clusters is called a Project.

Projects enable teams to deploy their configurations and services to clusters
in a consistent way. Projects enable central IT or a business unit to share
their Kubernetes clusters among several teams. Using Projects, NKP leverages
Kubernetes Cluster Federation (KubeFed) to coordinate the configuration of
multiple Kubernetes clusters.

Kommander allows a user to use labels to select, manually or dynamically, the
Kubernetes clusters associated with a Project.

Project Namespaces

A Project Namespace is a Kommander-specific concept. Project Namespaces
isolate configurations across clusters and are created on all clusters
matching the project labels. When creating a new project, you can customize
the name of the Kubernetes namespace that is created.

### Creating a Project Using the UI

About this task

When you create a Project, you must specify a Project Name, a Namespace Name
(optional) and a way to allow Kommander to determine which Kubernetes clusters
will be part of this project.

As mentioned previously, a Project Namespace corresponds to a Kubernetes
Federated Namespace. By default, the name of the namespace is auto-generated
based on the project name (first 57 characters) plus 5 unique alphanumeric
characters. You can specify a namespace name, but you must ensure it does not
conflict with any existing namespace on the target Kubernetes clusters, that
will be a part of the Project.

To determine which Kubernetes clusters will be part of this project, you can
either select manually existing clusters or define labels that Kommander will
use to dynamically add clusters. The latter is recommended because it will
allow you to deploy additional Kubernetes clusters later and to have them
automatically associated with Projects based on their labels.

To create a Project, you can either use the NKP UI or create a Project object
on the Kubernetes cluster where Kommander is running (using kubectl or the
Kubernetes API). The latter allows you to configure Kommander resources in a
declarative way. It is available for all kinds of Kommander resources.

To create a project using the NKP UI:

Procedure

1. Enter the following fields:

- Project Name
- ID / Namespace
- Description

1. In the Clusters field, add one or more active clusters.
2. Click Create.

### Creating a Project Using the CLI

About this task

The following sample is a YAML Kubernetes object for creating a Kommander
Project. This example does not work verbatim because it depends on a workspace
name that has been previously created and does not exist by default in your
cluster.

Procedure

Use this as an example format and fill in the workspace name and namespace
name appropriately along with the proper labels.

```yaml
apiVersion: workspaces.kommander.mesosphere.io/v1alpha1
kind: Project
metadata:
name: My-Project-Name
namespace: my-project-k8s-namespace-name
spec:
workspaceRef:
name: myworkspacename
namespaceName: myworkspacename-di3tx
placement:
clusterSelector:
matchLabels:
cluster: prod
```

The following procedures are supported for projects:

- Project Applications on page 417
- Project Deployments on page 432
- Project Role Bindings on page 442
- Project Roles on page 445
- Project ConfigMaps on page 448
- Project Secrets on page 449
- Project Quotas and Limit Ranges on page 451
- Project Network Policies on page 453

### Project Applications

Application types are:

- Workspace Catalog Applications on page 379 that are either pre-packaged
  applications from the Nutanix Application Catalog or custom applications
  that you maintain for your teams or organization.
- NKP Applications on page 327 are applications that are provided by Nutanix
  and added to the Catalog.
- Custom Applications on page 402 are applications integrated into Kommander.
- Platform Applications on page 350

When deploying and upgrading applications, platform applications come as a
bundle; they are tested as a single unit and you must deploy or upgrade them
in a single process, for each workspace. This means all clusters in a
workspace have the same set and versions of platform applications deployed.
Whereas catalog applications are individual, so you can deploy and upgrade
them individually, for each project.

#### Project Platform Applications

The following table describes the list of applications that can be deployed to
attached clusters within a project.

Review the Project Platform Application Configuration Requirements on page 421
to ensure that the attached clusters in the project have sufficient resources.

From within a project, you can enable applications to deploy. Verify that an
application has successfully deployed through the CLI.

Platform Applications

Table 41: Platform Applications

project-grafana-logging-11.3.3 project-grafana-logging False

project-grafana-loki-v3-3.6.7 project-grafana-loki False

project-logging-1.1.0 project-logging False

##### Enabling the Platform Application Using the UI

About this task

Follow these steps to:

Procedure

1. Log into the NKP UI dashboard.
2. In the workspace header drop-down list, select your target workspace.
3. From the left navigation menu, select Projects.

| Name | APP ID | Deployed by default |
| ---- | ------ | ------------------- |

1. From the list of project, select your project.
2. To browse the available applications, select the Applications tab.
3. Select the triple dot vertical from the bottom-right corner of the desired
   application tile, and then select Enable.
4. If you want to override the default configuration values, copy your
   customized values into the text editor under Configure Application or upload
   your YAML file that contains the values.

```bash
someField: someValue
```

1. Confirm the details are correct, and then click Enable.

To use the CLI to enable or disable applications, see Deploying Platform
Applications Using CLI on page 353

```yaml
Warning: There may be dependencies between the applications, which are listed in Project Platform
Application Dependencies on page 420. Review them carefully prior to customizing to ensure that the
applications are deployed successfully.
```

##### Platform Applications Upgrade Using the CLI

Platform Applications within a Project are automatically upgraded when the
Workspace that a Project belongs to is upgraded.

For more information on how to upgrade these applications, see Upgrading
Platform Applications on Managed and Attached Clusters on page 1050.

##### Deploying Project Platform Applications Using the CLI

Deploy applications to attached clusters in a project using the CLI.

About this task

This topic describes how to use the CLI to deploy an application to attached
clusters within a project.

For a list of all applications and those that are enabled by default, see
Project Platform Applications on page 417.

Before you begin

Ensure that you have:

- A running cluster with Kommander installed.
- An existing Kubernetes cluster attached to Kommander.
- Set the WORKSPACE_NAME environment variable to the name of the workspace
  where the cluster is attached.

```bash
export WORKSPACE_NAME=<workspace_name>
```

- Set the WORKSPACE_NAMESPACE environment variable to the namespace of the
  above workspace.

```bash
export WORKSPACE_NAMESPACE=$(kubectl get namespace --
selector='workspaces.kommander.mesosphere.io/workspace-name=${WORKSPACE_NAME}' -o
jsonpath='{.items[0].metadata.name}')
```

- Set the PROJECT_NAME environment variable to the name of the project in
  which the cluster is included:

```bash
export PROJECT_NAME=<project_name>
```

- Set the PROJECT_NAMESPACE environment variable to the name of the above
  project's namespace:

```bash
export PROJECT_NAMESPACE=$(kubectl get project ${PROJECT_NAMESPACE} -n
${WORKSPACE_NAMESPACE} -o jsonpath='{.status.namespaceRef.name}')
```

Procedure

1. Deploy one of the supported applications to your existing attached cluster
   with an AppDeployment resource. Provide the appRef and application version
   to specify which App is deployed.

```bash
nkp create appdeployment project-grafana-logging --app project-grafana-logging-11.3.3
--workspace ${WORKSPACE_NAME} --project ${PROJECT_NAME}
```

1. Create the resource in the project you just created, which instructs
   Kommander to deploy the AppDeployment to the KommanderClusters in the same
   project.

> **Note:**

- The appRef.name must match the app name from the list of available catalog
  applications.
- Observe that the nkp create command must be run with both the --workspace
  and --project flags for project platform applications.

##### Deploying the Project Platform Application With Custom Configuration

Using the CLI

About this task

To perform custom configuration using the CLI:

Procedure

1. Create the AppDeployment and provide the name of a ConfigMap, which
   provides custom configuration on top of the default configuration.

```bash
nkp create appdeployment project-grafana-logging --app project-grafana-logging-11.3.3
--config-overrides project-grafana-logging-overrides --workspace ${WORKSPACE_NAME}
--project ${PROJECT_NAMESPACE}
```

1. Create the ConfigMap with the name provided in the step above, with the
   custom configuration.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
namespace: ${PROJECT_NAMESPACE}
name: project-grafana-logging-overrides
data:
values.yaml: |
datasources:
datasources.yaml:
apiVersion: 1
datasources:
- name: Loki
type: loki
url: "http://project-grafana-loki-loki-distributed-gateway"
access: proxy
isDefault: false
EOF
```

Kommander waits for the ConfigMap to be present before deploying the
AppDeployment to the managed or attached clusters.

##### Verify the Project Platform Applications

After completing the previous steps, your applications are enabled.

Procedure

1. Export the project_namespace with this command.

```bash
export PROJECT_NAMESPACE=<project_namespace>
```

1. Connect to the attached cluster and check the HelmReleases to verify the
   deployment.

```bash
kubectl get helmreleases -n ${PROJECT_NAMESPACE}
NAMESPACE NAME READY STATUS
AGE
project-test-vjsfq project-grafana-logging True Release reconciliation
succeeded 7m3s
Note: Some of the supported applications have dependencies on other applications. See Project Platform
Application Dependencies on page 420 for that table.
```

##### Project Platform Application Dependencies

Dependencies between project platform applications.

There are many dependencies between the applications that are deployed to a
project's attached clusters. It is important to note these dependencies when
customizing the platform applications to ensure that your services are
properly deployed to the clusters. For more information on how to customize
platform applications, see Project Platform Applications on page 417.

Application Dependencies

When deploying or troubleshooting applications, it helps to understand how
applications interact and may require other applications as dependencies.

If an application's dependency does not successfully deploy, the application
requiring that dependency does not successfully deploy.

The following sections detail information about the platform applications.

Logging

Collects logs over time from Kubernetes pods deployed in the project
namespace. Also provides the ability to visualize and query the aggregated
logs.

- project-logging: Defines resources for the Logging Operator which uses them
  to direct the project's logs to its respective Grafana Loki application. For
  more information, see `<https://grafana.com/oss/grafana/>`.
- project-grafana-loki: A horizontally-scalable, highly-available, multi-
  tenant log aggregation system inspired by Prometheus. For more information,
  see `<https://grafana.com/oss/loki/>`.
- project-grafana-logging: Logging dashboard used to view logs aggregated to
  Grafana Loki. For more information, see `<https://grafana.com/oss/grafana/>`.

```yaml
Warning: The project logging applications depend on the Enabling Logging Applications Using the UI on
page 600 being deployed.
```

Table 42: Project Platform Application Dependencies

project-logging logging-operator (workspace)

project-grafana-loki project-logging, grafana-loki (workspace), logging-
operator (workspace)

project-grafana-logging project-grafana-loki

##### Project Platform Application Configuration Requirements

Project Platform Application Descriptions and Resource Requirements

Platform applications require more resources than solely deploying or
attaching clusters into a project. Your cluster must have sufficient resources
when deploying or attaching to ensure that the applications are installed
successfully.

The following table describes all the platform applications that are available
to the clusters in a project, minimum resource and persistent storage
requirements, and whether they are enabled by default.

project-grafana- logging

cpu: 200m

memory: 100Mi

No NKP Critical (100002000)

project-grafana-loki # of PVs: 3

PV sizes: 10Gi x 3 (total: 30Gi)

No NKP Critical (100002000)

project-logging No NKP Critical (100002000)

#### Project Catalog Applications

Before upgrading your catalog applications, verify the current and supported
versions of the application. Also, keep in mind the distinction between
Platform applications and Catalog applications. Platform applications are
deployed and upgraded as a set for each cluster or workspace. Catalog
applications are deployed separately, so that you can deploy and upgrade them
individually for each project.

| Application | Required Dependencies |
| ----------- | --------------------- |

- Name; Minimum Resources Suggested; Minimum Persistent Storage Required;
  Deployed by Default; Default PriorityClass

| --- | --- | --- | --- | --- |

About this task

Catalog applications must be upgraded to the latest version BEFORE upgrading
the Konvoy component for Managed clusters or Kubernetes version for attached
clusters.

To upgrade an application from the NKP UI:

Procedure

1. From the top menu bar, select your target workspace.
2. From the side menu bar, select Projects.
3. Select your target project.
4. Select Applications from the project menu bar.
5. Select the three dot button from the bottom-right corner of the desired
   application tile, and then click Edit.
6. Select the Version dropdown list, and select a new version. This dropdown
   list will only be available if there is a newer version to upgrade to.
7. Click Save.

##### Upgrading Project Catalog Applications Using the CLI

About this task

To upgrade project catalog applications:

Procedure

1. To see what app(s) and app versions are available to upgrade, run the
   following command:

> **Note: The APP ID column displays the available apps and the versions
> available to upgrade.**

```bash
kubectl get apps -n ${PROJECT_NAMESPACE}
```

1. Run the following command to upgrade an application from the NKP CLI.

```bash
nkp upgrade catalogapp <appdeployment-name> --workspace=my-workspace --project=my-
project --to-version=<version.number>
Note: Platform applications cannot be upgraded on a one-off basis, and must be upgraded in a single process for
each workspace. If you attempt to upgrade a platform application with these commands, you receive an error and
the application is not upgraded.
```

##### Project-level NKP Applications

NKP applications are catalog applications provided by Nutanix for use in your
environment.

Some NKP workspace catalog applications will provision
CustomResourceDefinitions, which allow you to deploy Custom Resources to a
Project. See your NKP workspace catalog application's documentation for
instructions.

##### Usage of Custom Resources with Workspace Catalog Applications

Some workspace catalog applications provision one or more
CustomResourceDefinition (CRD) objects as part of their deployment process.

The CRDs allow you to deploy and manage the corresponding custom resources
within your environment. For more information on how to configure and use the
custom resources effectively, see the documentation specific to your workspace
catalog application.

##### Custom Project Applications

Custom applications are third-party applications you have added to the
Kommander Catalog.

Custom applications are any third-party applications that are not provided in
the NKP Application Catalog. Custom applications can leverage applications
from the NKP Catalog or be fully-customized. There is no expectation of
support by Nutanix for a Custom application. Custom applications can be
deployed on Konvoy clusters or on any Nutanix supported 3rd party Kubernetes
distribution.

###### Git Repository Structure (2)

- Creating a Catalog Collection or an Application on page 404
- Application Metadata on page 405
- Enabling a Custom Application From the Project Catalog Using the UI on page
  430 and Enabling a Custom Application From the Project Catalog Using the CLI
  on page 431

Git repositories must be structured in a specific manner for defined
applications to be processed by Kommander.

You must structure your Git repository based on the following guidelines, for
your applications to be processed properly by Kommander so that they can be
deployed.

Git Repository Directory Structure

Run the following command to generate a new Git repository for hosting your
catalog applications:

```bash
mkdir -p /new/directory/for/catalog
cd /new/directory/for/catalog
nkp generate catalog-repository
```

Run the following command, to generate a directory for your application
version. You can run this command multiple times (once for each version of a
given application).

```bash
nkp generate catalog-repository --apps <app-name>=<app-version>
```

Above commands will generate following basic directory structure:

```bash
...
### applications (5)
# ### <app-name> (3)
# ### <app-version1> (3)
# ### helmrelease (5)
# # ### cm.yaml // ConfigMap specifying default (3)
configuration overrides for HelmRelease
# # ### helmrelease.yaml // OCIRepository and HelmRelease (3)
# # ### kustomization.yaml // Kubernetes Kustomization file (3)
# ### helmrelease.yaml // FluxCD Kustomization file for the (3)
HelmRelease
# ### kustomization.yaml // Kubernetes Kustomization file (3)
# ### metadata.yaml // Application details (3)
# ### <app-version2> (3)
# ### helmrelease (6)
# # ### cm.yaml (3)
# # ### helmrelease.yaml (3)
# # ### kustomization.yaml (3)
# ### helmrelease.yaml (3)
# ### kustomization.yaml (3)
# ### metadata.yaml (3)
...
```

Remember the following guidelines:

- Define applications in the applications/ directory.
- You can define multiple versions of an application, under different
  directories nested under the applications/ `<app name>`/ directory.
- Populate the HelmRelease and OCIRepository details in the versioned
  directory applications/`<app name>`/ `<app version>`/helmrelease in the
  helmrelease.yaml file. For more information, see HelmRelease, OCIRepository
  in the Flux documentation, and The Kustomization File in the SIG CLI
  documentation.
- Define the default values ConfigMap for HelmReleases in the
  applications/`<app name>`/`<app version>`/helmrelease/cm.yaml file accompanied
  by a kustomization.yaml Kubernetes Kustomization file pointing to the
  ConfigMap file.
- Define the metadata.yaml of each application under the applications/`<app name>`/`<app version>` directory. For more information, see Application
  Metadata on page 405.
- You can generate a new application version directory with the required
  layout and files by running:

```bash
nkp generate catalog-repository --apps=<app-name>=<app-version>
```

For an example of how to structure catalog Git repositories, see Overview of
the Application Structure on page 401.

OCI Repositories

You must include the OCIRepository that is referenced in each HelmRelease's
Chart spec.

Each applications/`<app name>`/`<app version>`/helmrelease/helmrelease.yaml file
must include YAML definition of the OCIRepository along with the HelmRelease
definition.

For more information, see OCI Repository in the Flux documentation.

Substitution Variables

Some substitution variables are provided. For more information, see
Kustomization in the Flux documentation.

- ${releaseName}: For each App deployment, this variable is set to the
  AppDeployment name. Use this variable to prefix the names of any resources
  that are defined in the application directory in the Git repository so that
  multiple instances of the same application can be deployed. If you create
  resources without using the releaseName prefix (or suffix) in the name
  field, there can be conflicts if the same named resource is created in that
  same namespace.
- ${releaseNamespace}: The namespace of the workspace.
- ${workspaceNamespace}: The namespace of the workspace that the Workspace
  belongs to.

###### Creating a Catalog Collection or an Application (2)

Use CLI to create a Flux OCIRepository resource in your workspace or project
that acts as a source for your catalog applications.

About this task

Create an OCIRepository in the workspace or project namespace.

Procedure

1. To build an OCI artifact from your catalog git repository run the following
   command. This generates a .tar file locally.

```bash
nkp create catalog-bundle --collection-tag <tag>
```

Above command will bundle up all versions of all applications in the current
directory.

> **Note:**

- To include only selected applications use --apps flag.
- To include the container images use --airgapped flag. This is required for
  air-gapped environments.

1. Push the OCI artifact to a registry that is accessible to the cluster. The
   registry used must be OCI Compliant.

```bash
nkp push bundle --bundle <path-to-file-generated-above.tar> --to-registry <your-
registry-url>
```

1. You can either create a catalog collection (group of applications) or just
   one application in your NKP Cluster. Note that creating a catalog in the
   Kommander workspace will automatically propagate it to all other
   workspaces/projects/. If you prefer to limit the scope of catalog to a
   single workspace or project, use the --workspace or --project flags
   accordingly. Run either one of the following commands:

- Create a Catalog Collection

```bash
nkp create catalog-collection --url oci://<registry-url>/<repo-name>/collection --
workspace <workspace-or-project-namespace> --tag <tag>
```

- Create a Catalog Application

```bash
nkp create catalog-collection --url oci://<registry-url>/<repo-name>/<app-name> --
workspace <workspace-or-project-namespace> --tag <app-version>
```

1. Optionally, ensure the status of the OCIRepository signals a ready state.

```bash
kubectl get ocirepository -n <workspace-or-project-namespace>${WORKSPACE_NAMESPACE}
<name-printed-in-above-create-command>
```

The repository commit also displays the ready state.

```bash
NAME URL READY STATUS

AGE
example-repo https://github.com/example-org/example-repo True stored
artifact for digest
'2.16@sha256:c7cbee436dc81ac09c7b985696ba798c4d55f6964634c0f1e89e282e632aaaf3'
1m
```

###### Troubleshooting an OCIRepository (2)

Procedure

Review the following logs:

```bash
kubectl -n kommander-flux logs -l app=source-controller
[...]
kubectl -n kommander-flux logs -l app=kustomize-controller
[...]
kubectl -n kommander-flux logs -l app=helm-controller
[...]
```

For more information, see:

- Flux: `<https://fluxcd.io/>`
- Flux documentation: `<https://fluxcd.io/docs>`

###### Application Metadata (2)

You can define how custom applications display in the NKP UI by defining a
metadata.yaml file for each version of an application in the git repository.
You must define this file at applications/`<app name>`/`<app version>`/metadata.yaml for it to process correctly.

You can define the following fields:

displayName App ID Display name of the application for the UI.

allowMultipleInstances true Whether multiple instances of the application can
be installed.

category [general] One or more categories for this application. Categories are
used to group applications in the UI.

description "" Short description, must be a sentence or two, displayed in the
UI on the application card.

dependencies List of applications that must be installed in order for the
application to function properly. The UI will not block the installation of
the application if the dependencies are not installed

requiredDependencies List of applications that are required to be installed in
order for the application to be enabled in the UI.

k8sVersionSupport A string indicating the compatible Kubernetes version or
range. For example, from 1.29 to 1.32).

icon Base64 encoded icon SVG file used for application logos in the UI.

nkpVersionSupport A string indicating the compatible NKP version or range.

overview Markdown overview used on the application detail page in the UI.

supportLink A link to the support page

scope [project] List of scopes, can be set only to project or workspace
currently.

upgradesFrom A string indicating the version or range of versions that the
application can be upgraded from.

licensing [Pro, Ultimate] Cluster must have one of these licenses applied in
order for the application to be installable.

| Field | Default | Description |
| ----- | ------- | ----------- |

certifications List of certifications that the application has.

type custom Type of application

The following JSON Schema must be adhered to in the metadata.yaml file for it
to be processed accurately. To validate metadata.yaml against the schema, run
the following command:

```bash
nkp validate catalog-repository --repo-dir=/path/to/catalog-repository
{
"$schema": "https://json-schema.org/draft/2020-12/schema",
"$id": "catalog.nkp.nutanix.com/v1/application-metadata",
"properties": {
"schema": {
"type": "string",
"description": "Identifies the schema used."
},
"displayName": {
"type": "string",
"description": "Display name of the application for the UI.\nFalls back to App ID
if not given."
},
"allowMultipleInstances": {
"type": "boolean",
"description": "Whether multiple instances of the application can be installed.
Defaults to true.",
"default": true
},
"category": {
"items": {
"type": "string"
},
"type": "array",
"description": "1 or more categories for this application. Categories are used to
group applications in the UI.\nDefaults to [general].",
"default": [
"general"
]
},
"description": {
"type": "string",
"description": "Short description, should be a sentence or two, displayed in the
UI on the application card."
},
"dependencies": {
"items": {
"type": "string"
},
"type": "array",
"description": "List of applications that should be installed in order for the
application to function properly.\nThe UI will not block the installation of the
application if the dependencies are not installed."
},
"requiredDependencies": {
"items": {
"type": "string"
},
"type": "array",
"description": "List of applications that are required to be installed in order
for the application to be enabled in the UI."
},
```

| Field | Default | Description |
| ----- | ------- | ----------- |

```bash
"k8sVersionSupport": {
"type": "string",
"pattern": "^(0|[1-9]\\d*)(\\.(0|[1-9]\\d*)){0,2}$|^((>=?|<=?)\\s*(v)?(0|[1-9]\
\d*)(\\.(0|[1-9]\\d*)){0,2})(\\s*(>=?|<=?)\\s*(v)?(0|[1-9]\\d*))?(\\.(0|[1-9]\\d*))
{0,2}?$",
"description": "A string indicating the compatible Kubernetes version or range."
},
"icon": {
"type": "string",
"description": "Base64 encoded icon SVG file used for application logos in the
UI."
},
"nkpVersionSupport": {
"type": "string",
"pattern": "^(0|[1-9]\\d*)(\\.(0|[1-9]\\d*)){0,2}$|^((>=?|<=?)\\s*(v)?(0|[1-9]\
\d*)(\\.(0|[1-9]\\d*)){0,2})(\\s*(>=?|<=?)\\s*(v)?(0|[1-9]\\d*))?(\\.(0|[1-9]\\d*))
{0,2}?$",
"description": "A string indicating the compatible NKP version or range."
},
"overview": {
"type": "string",
"description": "Markdown overview used on the application detail page in the UI."
},
"supportLink": {
"type": "string",
"pattern": "^https?:\\/\\/([a-zA-Z0-9\\.-]+)\\.([a-zA-Z]{2,6})(:[0-9]{1,5})?(\\/
[^\\s]*)?$",
"description": "A link to the support page."
},
"scope": {
"items": {
"type": "string",
"enum": [
"project",
"workspace"
]
},
"type": "array",
"description": "List of scopes, can be set only to project and/or workspace.
Defaults to project.",
"default": [
"project"
]
},
"upgradesFrom": {
"type": "string",
"pattern": "^(0|[1-9]\\d*)(\\.(0|[1-9]\\d*)){0,2}$|^((>=?|<=?)\\s*(v)?(0|[1-9]\
\d*)(\\.(0|[1-9]\\d*)){0,2})(\\s*(>=?|<=?)\\s*(v)?(0|[1-9]\\d*))?(\\.(0|[1-9]\\d*))
{0,2}?$",
"description": "A string indicating the version or range of versions that the
application can be upgraded from."
},
"licensing": {
"items": {
"type": "string",
"enum": [
"Starter",
"Pro",
"Ultimate"
]
},
"type": "array",
"description": "Cluster must have one of these licenses applied in order for the
application to be installable.\nDefaults to [Pro, Ultimate].",
"default": [
"Pro",
"Ultimate"
]
},
"certifications": {
"items": {
"type": "string",
"enum": [
"airgapped",
"qualified",
"nutanix-supported"
]
},
"type": "array",
"description": "List of certifications that the application has."
},
"type": {
"type": "string",
"enum": [
"internal",
"nkp-core-platform",
"nkp-catalog",
"preferred-partner",
"custom"
],
"description": "Type of application.",
"default": "custom"
}
},
"additionalProperties": false,
"type": "object",
"required": [
"schema"
],
"description": "Metadata for an application."
}
```

None of these fields are required for the application to display in the UI.

Here is an example metadata.yaml file.

```yaml
schema: "catalog.nkp.nutanix.com/v1/application-metadata"
displayName: Prometheus Monitoring Stack
description: Stack of applications that collect metrics and provides visualization and
alerting capabilities. Includes Prometheus, Prometheus Alertmanager and Grafana.
category:
- monitoring
overview: >
# Overview (2)
A stack of applications that collects metrics and provides visualization and alerting
capabilities. Includes Prometheus, Prometheus Alertmanager and Grafana.
## Dashboards (2)
By deploying the Prometheus Monitoring Stack, the following platform applications and
their respective dashboards are deployed. After deployment to clusters in a workspace,
the dashboards are available to access from a respective cluster's detail page.
### Prometheus (2)
A software application for event monitoring and alerting. It records real-time
metrics in a time series database built using a HTTP pull model, with flexible and
real-time alerting.
- [Prometheus Documentation - Overview](https://prometheus.io/docs/introduction/
overview/)
### Prometheus Alertmanager (2)
A Prometheus component that enables you to configure and manage alerts sent by the
Prometheus server and to route them to notification, paging, and automation systems.
- [Prometheus Alertmanager Documentation - Overview](https://prometheus.io/docs/
alerting/latest/alertmanager/)
### Grafana (2)
A monitoring dashboard from Grafana that can be used to visualize metrics collected
by Prometheus.
- [Grafana Documentation](https://grafana.com/docs/)
icon:
PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAzMDAgMzAwIiBzdHlsZT0iZW5hYm
```

###### Enabling a Custom Application From the Project Catalog Using the UI

Enable a Custom Application from the Project Catalog. After creating a
GitRepository, you can either use the NKP UI or the CLI to enable your custom
applications.

About this task

```yaml
Note: From within a project, you can enable applications to deploy. Verify that an application has successfully
deployed through the CLI.
```

Procedure

1. From the top menu bar, select your target workspace.
2. From the side menu bar, select Projects.
3. Select your target project from the list.
4. Select Applications from the sidebar menu to browse the available
   applications from your configured repositories.
5. Select the three dot button from the bottom-right corner of the desired
   application tile, and then select Enable.
6. If available, select a version from the dropdown list. This dropdown list
   will only be visible if there is more than one version.
7. (Optional) If you want to override the default configuration values, copy
   your customized values into the text editor under Configure Application or
   upload your YAML file that contains the values.

```bash
someField: someValue
```

1. Confirm the details are correct, and then click Enable.

For all applications, you must provide a display name and an ID which is
automatically generated based on what you enter for the display name, unless
or until you edit the ID directly. The ID must be compliant with Kubernetes

DNS subdomain name validation rules. For more information, see
`<https://kubernetes.io/docs/concepts/>` overview/working-with-
objects/names/#dns-subdomain-names.

Alternately, you can use the CLI to enable your catalog applications. For more
information, see Deployment of Catalog Applications in Workspaces on page 395.

###### Enabling a Custom Application From the Project Catalog Using the CLI

Enable a Custom Application from the Project Catalog. After creating a
GitRepository, you can either use the NKP UI or the CLI to enable your custom
applications.

About this task

```yaml
Note: From within a project, you can enable applications to deploy. Verify that an application has successfully
deployed through the CLI.
```

Procedure

1. Set the PROJECT_NAMESPACE environment variable to the name of the above
   project's namespace.

```bash
export PROJECT_NAMESPACE=<project_namespace>
```

1. Get the list of available applications to enable using the following command.

```bash
kubectl get apps -n ${PROJECT_NAMESPACE}
```

1. Enable one of the supported applications from the list with an
   AppDeployment resource.
2. Within the AppDeployment resource. Provide the appRef and application
   version to specify which App is deployed.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: my-custom-app
namespace: ${PROJECT_NAMESPACE}
spec:
appRef:
name: custom-app-0.0.1
kind: App
EOF
```

> **Note: The appRef.name must match the app name from the list of available
> catalog applications.**

###### Enabling a Custom Application Configuration With Custom Configuration

Using the CLI

About this task

Follow these steps:

Procedure

1. Provide the name of a ConfigMap in the AppDeployment, which provides custom
   configuration on top of the default configuration.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: my-custom-app
namespace: ${PROJECT_NAMESPACE}
spec:
appRef:
name: custom-app-0.0.1
kind: App
configOverrides:
name: my-custom-app-overrides
EOF
```

1. Create the ConfigMap with the name provided in the step above, with the
   custom configuration.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
namespace: ${PROJECT_NAMESPACE}
name: my-custom-app-overrides
data:
values.yaml: |
someField: someValue
EOF
```

Kommander waits for the ConfigMap to be present before deploying the
AppDeployment to the attached clusters in the Project.

###### Project: Verify the Custom Applications

After completing the previous steps, your applications are enabled.

Procedure

Connect to the attached cluster and check the HelmReleases to verify the
deployment.

```bash
kubectl get helmreleases -n ${PROJECT_NAMESPACE}
```

The output looks similar to this:

```bash
NAMESPACE NAME READY STATUS AGE
project-test-vjsfq my-custom-app True Release reconciliation succeeded 7m3s
```

###### Custom Applications Upgrade

You must maintain your custom applications manually.

When upgrading NKP, ensure you validate for compatibility issues any custom
applications you run against the current version of Kubernetes. We recommend
upgrading to the latest compatible application versions as soon as possible.

#### Project AppDeployments

For more information about these Custom Resources and how to customize them,
see Printing and Reviewing the Current State of an AppDeployment Resource on
page 329 section of this guide.

### Project Deployments

You can configure Kommander Projects with GitOps-based Continuous Deployments
for federation of your Applications to associated clusters of the project.
This is backed by Flux, which enables software and applications

to be continuously deployed (CD) using GitOps processes. GitOps enables the
application to be deployed as per a manifest that is stored in a Git
repository. This ensures that the application deployment can be automated,
audited, and declaratively deployed to the infrastructure.

GitOps GitOps is a modern software deployment strategy. The configuration that
describes how your application is deployed to a cluster are stored in a Git
repository. The configuration is continuously synchronized from the Git
repository to the cluster, ensuring that the specified state of the cluster
always matches what is defined in the "GitOps" Git repository.

The benefits of using a GitOps deployment strategy are:

- Familiar, collaborative change and review process. Engineers are intimately
  familiar with Git-based workflows: branches, pull requests, code reviews,
  etc. GitOps leverages this experience to control the deployment of software
  and updates to catch issues early.
- Clear change log and audit trail. The Git commit log serves as an audit
  trail to answer the question: "who changed what, and when?" Having such
  information available, you can contact the right people when fixing or
  prioritizing a production incident to determine the why and correctly
  resolve the issue as quickly as possible. Additionally, Kommander's CD
  component (Flux CD) maintains a separate audit trail in the form of
  Kubernetes Events, as changes to a Git repository don't include exactly when
  those changes were deployed.
- Avoid configuration drift. The scope of manual changes made by operators
  expands over time. It soon becomes difficult to know which cluster
  configuration is critical and which is left over from temporary workarounds
  or live debugging. Over time, changing a project configuration or
  replicating a deployment to a new environment becomes a daunting task.
  GitOps supports simple, reproducible deployment to multiple different
  clusters by having a single source of truth for cluster and application
  configuration.

That said, there are some cases when live debugging is necessary in order to
resolve an incident in the minimum amount
of time. In such cases, pull-request-based workflow adds precious time to
resolution for critical production outages.
Kommander's CD strategy supports this scenario by letting you disable the auto
sync feature. After auto sync is
disabled, Flux will stop synchronizing the cluster state from the GitOps git
repository. This lets you use kubectl,
helm, or whichever tool you need to resolve the issue.

Security Security measures and best practices to ensure the secure and
efficient operation of FluxCD in multi- tenant environments on workload
clusters.

This section details the security measures implemented within Project
Deployments to ensure secure multi-tenant deployments on workload clusters.
These measures are designed to minimize the risk of unauthorized access and
maintain the integrity of individual tenant environments.

Automated Service Account Generation and Namespace Restriction

When a cluster administrator uses the NKP Project CD feature to manage Git
repositories, a dedicated service account is
automatically generated. This service account with the same name as the
Project name is configured with limited RBAC
permissions, restricting its access solely to the namespace where the
resources are provisioned. This service account is
applied on the root Kustomization pointing to the GitRepository and all the
generated Kustomization and HelmRelease
resources. This prevents tenants from accessing or modifying resources outside
their designated namespace, ensuring
isolation and avoiding potential conflicts.

Benefits of Namespace Restriction

- Enhanced Security: By limiting the service account's permissions to a
  specific namespace, we prevent unauthorized access to cluster-scoped
  resources, such as ClusterRoleBindings and ClusterRoles. This mitigates
  privilege escalation risk and ensures tenants can only manage resources
  within their environment.
- Simplified Management: The automated generation of the service account with
  pre-configured, namespace- specific permissions simplifies the deployment
  process for cluster administrators. They do not need to manually create and
  configure service accounts for each tenant, reducing the administrative
  overhead.
- Improved Isolation: Namespace restriction ensures tenants operate in
  isolated environments, preventing deployment interference and minimizing
  potential security breaches' impact. If a security issue arises within one
  tenant's namespace, it is contained within that namespace and does not
  affect other tenants.

Best Practices for Multi-tenant Deployments

In addition to the automated security measures, we recommend the following
best practices for secure multi-tenant deployments:

- Regularly Review RBAC Permissions: Periodically review the RBAC permissions
  assigned to the automatically generated service accounts to ensure that they
  align with the tenant's requirements and security policies.
- Implement Network Policies: Use network policies to control traffic flow
  between namespaces and further enhance the isolation between tenants.
- Monitor Resource Usage: Monitor resource usage within each namespace to
  identify potential anomalies and prevent resource starvation.
- Gatekeeper Constraints: To enforce rules at the resource level, custom
  gatekeeper constraints must be implemented. This allows for fine-grained
  control over resource creation and modification, further enhancing security
  and compliance.

#### Continuous Delivery with GitOps

This section contains step-by-step tutorials for performing some common
deployment-related tasks using NKP. All tutorials begin with a Prerequisites
section that contains links to any steps that need to be taken first. This
means you can visit any tutorial to get started.

#### Secrets Stored in GitOps Repository Using SealedSecrets

- Deploying a Sample Application from NKP GitOps on page 437

For security reasons, Kubernetes secrets are usually the only resource that
cannot be managed with a GitOps workflow. Instead of managing secrets outside
of GitOps and having to use a third-party tool like Vault, SealedSecrets
provides a way to keep all the advantages of using a GitOps workflow while
avoiding exposing secrets. SealedSecrets is composed of two main components:

- A CLI (Kubeseal) to encrypt secrets.
- A cluster-side controller to decrypt the sealed secrets into regular
  Kubernetes secrets. Only this controller can decrypt sealed secrets, not
  even the original author.
- This tutorial describes how to install these two components, configure the
  controller, and add or remove sealed secrets.

For instructions on the latest release, see the release page. For full
documentation on SealedSecrets, see the GitHub repository.

##### Installing Kubeseal CLI to Encrypt Your Secrets

Procedure

Based on your OS, perform the following steps:

- On MacOS:

```bash
brew install kubeseal
```

- On Linux:

```bash
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.18.1/
kubeseal-0.18.1-linux-amd64.tar.gz -O kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```

##### Installing the SealedSecrets Controller on Your Cluster

This controller will be able to decrypt SealedSecrets and create Kubernetes
secrets.

Procedure

1. Create the controller.

```bash
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/
v0.18.1/controller.yaml
```

1. Fetch the certificate that you will use to encrypt your secrets into sealed
   secrets.

```bash
kubeseal --fetch-cert > mycert.pem
```

1. Commit mycert.pem to your git repo.

##### Adding a Secret

Secrets can be securely added to Git using sealed secrets.

Procedure

1. Export the project namespace that you are using for your GitOps repository.

```bash
export PROJECT_NAMESPACE=<your-project-with-gitops>
```

1. Create a Kubernetes secret and pipe it into kubeseal using the certificate
   mycert.pem that you fetched from the controller in the setup.

```bash
echo '---' >> secrets.yaml
kubectl create secret -n ${PROJECT_NAMESPACE} generic mysecret --dry-run=client -o
yaml --from-literal=my-secret=value | \
kubeseal --format yaml --cert mycert.pem >> secrets.yaml
```

1. Go to the end of secrets.yaml where you just added your new sealed secret.
   Remove any "creationTimestamp" fields from the YAML.
2. Apply the secrets.yaml file to your namespace. If you do not have
   permission, commit your changes to the repository and let FluxCD apply the
   changes for you.

```bash
kubectl apply -f secrets.yaml
```

1. The sealed secret controller will then decrypt the sealed secret and
   generate a Kubernetes secret from it. Your secret got successfully created
   by running:

```bash
kubectl get secret mysecret -n ${PROJECT_NAMESPACE} -o yaml
```

1. If your sealed secret got created successfully but did not generate the
   matching secret, look at the logs of the controller.

```bash
kubectl logs -l=name=sealed-secrets-controller -n kube-system
```

1. Commit secrets.yaml to your repository if you have not already done so in
   step 3.

##### Removing a Secret

Procedure

1. Following the same example from above in "Adding a secret", now remove the
   manifest for mysecret in

secrets.yaml and commit those changes to the repository. 2. Delete the
SealedSecret in the cluster:

```bash
kubectl delete SealedSecret -n ${PROJECT_NAMESPACE} mysecret
```

1. Delete the secret itself.

```bash
kubectl delete secret -n ${PROJECT_NAMESPACE} mysecret
```

##### Rotating the Controller's Sealing Key

For added security, it is a good practice to rotate the key the controller
uses to decrypt sealed secrets. By default, the controller generates a new key
every 30 days.

Procedure

1. When this happens, you need to update the certificate you use to create
   sealed secrets by fetching the latest one.

```bash
kubeseal --fetch-cert > mycert.pem
```

> **Note: Do not forget to commit it back to the repository.**

In a disaster case, let's say your cluster gets destroyed, you would lose all
your sealing keys, so you would not be able to recreate all the secrets from
the sealed secrets in your GitOps repository. For this reason, you might want
to back up the sealing keys. 2. To do this every time a new sealing key is
generated, run.

```bash
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o
yaml > sealing-key
```

Then store sealing-key with the others in a safe location such as OneLogin
Notes or Vault. To restore from a backup after a disaster, recreate all of the
sealing keys with kubectl apply -f sealing-key1 sealing- key2 ... before
starting the controller. If the controller was already started, restart it:

```bash
kubectl delete pod -n
kube-system -l name=sealed-secrets-controller
```

To disable sealing key rotation For example, configure the controller's
command in the pod template with --key- renew-period=0. See the following YAML
file.

```bash
Pod Template:
Labels: name=sealed-secrets-controller
Service Account: sealed-secrets-controller
Containers:
sealed-secrets-controller:
Image: docker.io/bitnami/sealed-secrets-controller:v0.18.1
Port: 8080/TCP
Host Port: 0/TCP
Command: controller
--key-renew-period=0
```

If required, edit the controller's manifest with:

```bash
kubectl edit deployment.apps/sealed-secrets-controller -n kube-system
```

#### Deploying a Sample Application from NKP GitOps

Before you begin

- Install NKP: For more information, see Installing NKP on page 43
- Github account and personal access token. For more information, see Managing
  your personal access tokens
- Add cluster to Kommander: For more information, see Attaching an Existing
  Kubernetes Cluster on page 474
- Setup Workspace and Projects: For more information, see Workspaces on page 369.

> **Note: This procedure was run on an AWS cluster with NKP installed.**

Follow these steps:

Procedure

1. Ensure you are on the Default Workspace (or other workspace you have access
   to) so that you can create a project.
2. Create a project, as described in Projects on page 415. In the working
   example, we name the project pod- info. When you create a namespace,
   Kommander appends five alphanumeric characters. You can opt to select a
   target cluster for this project from one of the available attached clusters,
   and then this (pod-info-xxxxx) is the namespace used for deployments under
   the project.
3. [Optional] Create a secret in order to pull from the repository, for
   private repositories.

a. Select the Secrets tab and set up your secret according to the Continuous
Deployment on page 439 documentation.

b. Add a key and value pair for the GitHub personal access token and then
select Create. 4. Verify that the secret podinfo-secret is created on the
project namespace in the managed or attached cluster.

```bash
kubectl get secrets -n pod-info-xt2sz --kubeconfig=${CLUSTER_NAME}.conf
NAME TYPE DATA AGE
default-token-k685t kubernetes.io/service-account-token 3 94m
pod-info-xt2sz-token-p9k5z kubernetes.io/service-account-token 3 94m
podinfo-secret Opaque 1 1s
tls-root-ca Opaque 1 93m
```

1. Select your project and then select the CD tab.
2. In the Create GitOps Source dialog box, enter the following fields :
3. Enter the ID(name). For example, podinfo-source.

> **Note: Ensure that the name is unique within the project. You cannot
> modify the name once it is saved.** 2. Enter the Repository URL. For
> example, `<https://github.com/stefanprodan/podinfo>` 3. Select the Git Ref
> Type as Branch from the drop down list. Also, provide the Branch Name as
> master.
>
> **Note: If you do not enter a value, the Git reference uses the default
> branch for the repository.** 4. The Path value must contain where the
> manifests are located. In this example, we use ./kustomize as the Path
> value. 5. Enter the Primary Git Secret (which is podinfo-secret) to access
> the private repositories that you created in the previous step. This can
> be disregarded for public repositories. 7. Click Save. 8. Do the
> following.

a. Verify the status of gitrepository creation with this command (on the
attached or managed cluster), and if READY is marked as True.

```bash
kubectl get gitrepository -A --kubeconfig=${CLUSTER_NAME}.conf
NAMESPACE NAME URL
AGE READY STATUS
kommander-flux management https://git-operator-git.git-operator-system.svc/
repositories/kommander/kommander.svc/kommander/kommander.git 134m True
stored artifact for revision 'main/4fbee486076778c85e14f3196e49b8766e50e6ce'
pod-info-xt2sz podinfo-source https://github.com/stefanprodan/podinfo
116m True stored artifact for revision 'master/
b3b00fe35424a45d373bf4c7214178bc36fd7872'
```

1. Verify the Kustomization with this command below (on the attached or
   managed cluster), and if READY is marked as True.

```bash
kubectl get kustomizations -n pod-info-xt2sz --kubeconfig=${CLUSTER_NAME}.conf
NAME AGE READY STATUS
originalpodinfo 10m True Applied revision: master/
b3b00fe35424a45d373bf4c7214178bc36fd7872
podinfo-source 113m True Applied revision: master/
b3b00fe35424a45d373bf4c7214178bc36fd7872
project 116m True Applied revision:
main/4fbee486076778c85e14f3196e49b8766e50e6ce
project-tls-root-ca 117m True Applied revision:
main/4fbee486076778c85e14f3196e49b8766e50e6ce
```

Note the

```bash
port
```

so that you can use to verify if the app is deployed correctly (on the
attached or managed cluster).

```bash
kubectl get deployments,services -n pod-info-xt2sz --kubeconfig=
${CLUSTER_NAME}.conf
NAME READY UP-TO-DATE AVAILABLE AGE
deployment.apps/podinfo 2/2 2 2 118m
NAME TYPE CLUSTER-IP EXTERNAL-IP PORT(S) AGE
service/podinfo ClusterIP 10.99.239.120 <none> 9898/TCP,9999/TCP
118m
```

1. Port forward the podinfo service (port 9898) to verify (on the attached or
   managed cluster):

```bash
kubectl port-forward svc/podinfo -n pod-info-xt2sz 9898:9898 --kubeconfig=
${CLUSTER_NAME}.conf
Forwarding from 127.0.0.1:9898 -> 9898
Forwarding from [::1]:9898 -> 9898
Handling connection for 9898
Handling connection for 9898
Handling connection for 9898
```

1. Open a browser and type in localhost:9898. A successful deployment of the
   podinfo app gives you this page.

#### Continuous Deployment

Here you create a GitOps source which is a source code management (SCM)
repository hosting the application definition. Nutanix recommends that you
create a secret first then create a GitOps source accessed by the secret.

##### Setting Up a Secret for Accessing GitOps

You can create a secret that Kommander uses to deploy the contents of your
GitOps repository.

About this task

```yaml
Note: This dialog box creates a types.kubefed.io/v1beta1, Kind=FederatedSecret and this is not yet
supported by NKP CLI. Use the GUI, as described above, to create a federated secret or create a FederatedSecret
manifest and apply it to the project namespace. For more information about secrets, see Project Secrets on
page 449
```

Kommander secrets (for CD) can be configured to support any of the following
three authentication methods:

- HTTPS Authentication (described above)
- HTTPS self-signed certificates
- SSH Authentication

The following table describes the fields required for each authentication
method.

Procedure

Table 45: Secret in GitOps

username username identity

password password identity.pub

caFile known_hosts

If you are using a GitHub personal access token, you must have a key:value
pair of username.

1. If you are using GitOps by using a GitHub repository as your source, you
   can create your secret with a personal access token. Then, in the NKP UI, in
   your project, create a Secret, with a key:value pair of password: `<your- token-created-on-github>`. If you are using a GitHub personal access token,
   you must have a key:value pair of username: `<your-github-username>`.

| HTTP Auth | HTTPS Auth (Self-signed) | SSH Auth |
| --------- | ------------------------ | -------- |

1. If you are using a secret with your GitHub username and your password, you
   will need one secret created in the NKP UI, with key:value pairs of
   username: `<your-github-username>` and password: `<your-github- password>`.

> **Note: If you have multi-factor authentication turned on in your GitHub
> account, this will not work.**

```yaml
Note: Using a token without a username is valid for GitHub, but other providers (such as GitLab) require both
username and tokens.
```

> **Warning: If you are using a public GitHub repository, you do not need to
> use a secret.**

##### Creating the GitOps Source

After the secret is created, you can view it in the Secrets tab. Configure the
GitOps source accessed by the secret.

About this task

```yaml
Note: If using an SSH secret, the SCM repository URL needs to be an SSH address. It does not support SCP syntax.
The URL format is ssh://user@host:port/org/repository.
```

It takes a few moments for the GitOps Source to be reconciled and the
manifests from the SCM repository at the given path to be federated to
attached clusters. After the sync is complete, manifests from GitOps source
are created in attached clusters.

After a GitOps Source is created, there are various commands that can be
executed from the CLI to check the various stages of syncing the manifests.

Procedure

On the management cluster, check your GitopsRepository to ensure that the CD
manifests have been created successfully.

```bash
kubectl describe gitopsrepositories.dispatch.d2iq.io -n<PROJECT_NAMESPACE> gitopsdemo
Name: gitopsdemo
Namespace: <PROJECT_NAMESPACE>
...
Events:
Type Reason Age From Message
---- ------ ---- ---- -------
Normal ManifestSyncSuccess 1m7s GitopsRepositoryController manifests synced to
bootstrap repo
...
```

On the attached cluster, check for your Kustomization and GitRepository
resources. The status field reflects the syncing of manifests.

```bash
kubectl get kustomizations.kustomize.toolkit.fluxcd.io -n<PROJECT_NAMESPACE>
<GITOPS_SOURCE_NAME> -oyaml
...
status:
conditions:
- reason: ReconciliationSucceeded
status: "True"
type: Ready
...
...
```

Similarly, with GitRepository resource.

```bash
kubectl get gitrepository.source.toolkit.fluxcd.io -n<PROJECT_NAMESPACE>
<GITOPS_SOURCE_NAME> -oyaml
...
status:
conditions:
- reason: GitOperationSucceed
status: "True"
type: Ready
...
...
```

If there are errors creating the manifests, those events are populated in the
status field of the GitopsRepository resource on the management cluster, the
GitRepository and Kustomization resources on the attached cluster(s), or both.

##### Editing the GitOps Source

About this task

To edit the GitOPs Source from within the UI::

Procedure

1. From the top menu bar, select your target workspace.
2. Select Projects from the sidebar menu.
3. Select your project from the list.
4. Select the Continuous Deployment (CD) tab.
5. Select the GitOps Sources button.

From here, you can edit the ID (name), Repository URL, Git Ref Type , Branch
Name, Type, Path, and Primary Git Secret.

##### Suspending the GitOps Source

There may be times when you need to suspend the auto-sync between the GitOps
repository and the associated clusters. This live debugging may be necessary
to resolve an incident in the minimum amount of time without the overhead of
pull request based workflows.

About this task

To Suspend the GitOps Source from the NKP UI:

Procedure

1. From the top menu bar, select your target workspace.
2. Select Projects from the sidebar menu.
3. Select your project from the list.
4. Select the Continuous Deployment (CD) tab.
5. Select the three dot button to the right of the desired GitOps Source.
6. Suspend to manually suspend the GitOps reconciliation.

This lets you use kubectl, helm, or another tool to resolve the issue. After
the issue is resolved select Resume to sync the updated contents of the GitOps
source to the associated clusters.

Similar to Suspend/Resume, you can use the Delete action to remove the GitOps
source. Removing the GitOps source results in removal of all the manifests
applied from the GitOps source.

You can have more than one GitOps Source in your Project to deploy manifests
from various sources.

Kommander deployments are backed by FluxCD. For Flux docs for advanced
configuration and more examples, see Source Controller at
`<https://fluxcd.io/docs/components/source/>` and Kustomize controller at
https:// fluxcd.io/docs/components/kustomize/.

#### Project Deployments Troubleshooting

- View the events and logs for deployments/kommander-cm in Kommander
  namespace, if there are any unexpected errors.
- Enabling the Kommander repository controller for your project namespace
  causes a number of related Flux controller components to deploy into the
  namespace. These are necessary for the proper operation of the repository
  controller and should not be removed. For more information, see
  `<https://toolkit.fluxcd.io/>` components/.
- Ensure your GitOps repository does not contain any manifests that are
  cluster-scoped - for example, Namespace, ClusterRole, ClusterRoleBinding,
  etc. All of the manifests must be namespace-scoped.
- Ensure your GitOps repository does not contain any HelmRelease and
  Kustomization resources that are targeting a different namespace than the
  project namespace.

#### Viewing Helm Releases

Procedure

1. From the top menu bar, select your target workspace.
2. Select Projects from the sidebar menu.
3. Select your project from the list.
4. Select the Continuous Deployment (CD) tab.
5. Click Helm Releases . All of the current Helm Release charts are displayed
   with their Chart Version and the names of the clusters.

```yaml
Note: If an error occurs with the Helm Releases charts deployment, an "Install Failed" error status appears in the
Kommander Host field .
```

Select the error status to open a screen that details specific issues related
to the error.

### Project Role Bindings

Before creating a binding, you create a Kommander group that includes one or
more identity provider users or groups. Using the NKP UI, you can create a
group and assign the appropriate project role. Using the NKP CLI, you can
configure bindings directly and, for a specific instance, bind a project role
to a WorkspaceRole.

#### Configuring Project Role Bindings Using the UI

About this task

You can assign a role to this Kommander Group:

Procedure

1. From the Projects page, select your project.
2. Select the Role Bindings tab, then select Add Roles next to the group you
   want.
3. Select the Role you want from the dropdown list, and then click Save.

#### Configuring Project Role Bindings Using the CLI

Procedure

A Project role binding can also be created using kubectl.

```bash
cat << EOF | kubectl create -f -
apiVersion: workspaces.kommander.mesosphere.io/v1alpha1
kind: VirtualGroupProjectRoleBinding
metadata:
generateName: projectpolicy-
namespace: ${projectns}
spec:
projectRoleRef:
name: ${projectrole}
virtualGroupRef:
name: ${virtualgroup}
EOF
```

#### Configure Project Role Bindings to Bind to WorkspaceRoles Using the CLI

Procedure

1. To list the WorkspaceRoles that you can bind to a Project, run the
   following command.

```bash
kubectl get workspaceroles -n ${workspacens} -o=jsonpath="{.items[?
(@.metadata.annotations.workspace\.kommander\.d2iq\.io\/project-default-workspace-
role-for==\"${projectns}\")].metadata.name}"
```

You can bind to any of the above WorkspaceRoles by setting
spec.workspaceRoleRef in the project role binding.

```bash
cat << EOF | kubectl create -f -
apiVersion: workspaces.kommander.mesosphere.io/v1alpha1
kind: VirtualGroupProjectRoleBinding
metadata:
generateName: projectpolicy-
namespace: ${projectns}
spec:
workspaceRoleRef:
name: ${workspacerole}
virtualGroupRef:
name: ${virtualgroup}
EOF
```

Note that you must specify either workspaceRoleRef or projectRoleRef to be
validated by the admission webhook. Specifying both values is not valid and
will cause an error.

Ensure the projectns, workspacens, projectrole (or workspacerole) and the
virtualgroup variables are set before executing the command.

When a Project Role Binding is created, Kommander creates a Kubernetes
FederatedRoleBinding on the Kubernetes cluster where Kommander is running. You
can view this by first finding the name of the project role binding that you
created: kubectl -n ${projectns} get federatedrolebindings.types.kubefed.io.

Then, view the details like in this example:

```bash
kubectl -n ${projectns} get federatedrolebindings.types.kubefed.io projectpolicy-
gtct4-rdkwq -o yaml
```

Output.

```yaml
apiVersion: types.kubefed.io/v1beta1
kind: FederatedRoleBinding
metadata:
creationTimestamp: "2020-06-04T16:19:27Z"
finalizers:
- kubefed.io/sync-controller
generation: 1
name: projectpolicy-gtct4-rdkwq
namespace: project1-5ljs9-lhvjl
ownerReferences:
- apiVersion: workspaces.kommander.mesosphere.io/v1alpha1
blockOwnerDeletion: true
controller: true
kind: VirtualGroupProjectRoleBinding
name: projectpolicy-gtct4
uid: 19614de2-4593-433e-82fa-96dc9470e07a
resourceVersion: "196270"
selfLink: /apis/types.kubefed.io/v1beta1/namespaces/project1-5ljs9-lhvjl/
federatedrolebindings/projectpolicy-gtct4-rdkwq
uid: beaffc29-edec-4258-9813-3a17ba27a2a6
spec:
placement:
clusterSelector: {}
template:
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: Role
name: admin-dbfpj-l6s9g
subjects:
- apiGroup: rbac.authorization.k8s.io
kind: User
name: user1@d2iq.lab
status:
clusters:
- name: konvoy-5nr5h
conditions:
- lastTransitionTime: "2020-06-04T16:19:27Z"
lastUpdateTime: "2020-06-04T16:19:27Z"
status: "True"
type: Propagation
observedGeneration: 1
```

1. Then, if you run the following command on a Kubernetes cluster associated
   with the Project, you'll see a Kubernetes RoleBinding Object, in the
   corresponding namespace.

```bash
kubectl -n ${projectns} get rolebinding projectpolicy-gtct4-rdkwq -o yaml
```

Output:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
creationTimestamp: "2020-06-04T16:19:27Z"
labels:
kubefed.io/managed: "true"
name: projectpolicy-gtct4-rdkwq
namespace: project1-5ljs9-lhvjl
resourceVersion: "125392"
selfLink: /apis/rbac.authorization.k8s.io/v1/namespaces/project1-5ljs9-lhvjl/
rolebindings/projectpolicy-gtct4-rdkwq
uid: 2938398d-437b-4f3a-9cb9-c92e50139196
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: Role
name: admin-dbfpj-l6s9g
subjects:
- apiGroup: rbac.authorization.k8s.io
kind: User
name: user1@d2iq.lab
```

#### Role Binding with VirtualGroup

- ClusterRole for cluster-scoped objects
- WorkspaceRole for workspace-scoped objects
- ProjectRole for project-scoped objects

In order to define which VirtualGroup(s) is assigned to one of these roles,
administrators can create corresponding role bindings such as
VirtualGroupClusterRoleBinding, VirtualGroupWorkspaceRoleBinding, and
VirtualGroupProjectRoleBinding.

Note that for WorkspaceRole and ProjectRole, the referenced VirtualGroup and
corresponding role and role binding objects need to be in the same namespace.
If they are not in the same namespace, the role will not bind to the
VirtualGroup since it is assumed that the rules set in the role apply to
objects that live in that namespace. Whereas for ClusterRole which is cluster-
scoped, the VirtualGroupClusterRoleBinding is also cluster-scoped, even though
it references a namespace-scoped VirtualGroup.

### Project Roles

#### Configuring the Project Role Using the UI

About this task

Create a project role with one or more rules.

Procedure

Create a Project Role with a single rule. In this example, the Project Role
corresponds to an admin role:

Figure 10: Adding a Project Role using the UI

#### Configuring the Project Role Using the CLI

About this task

In the example below, a Project Role is created with a single Rule. This
Project Role corresponds to an admin role.

Procedure

1. The same Project Role can also be created using kubectl:

```bash
cat << EOF | kubectl create -f -
apiVersion: workspaces.kommander.mesosphere.io/v1alpha1
kind: ProjectRole
metadata:
annotations:
kommander.mesosphere.io/display-name: Admin
generateName: admin-
namespace: ${projectns}
spec:
rules:
- apiGroups:
- '*'
resources:
- '*'
verbs:
- '*'
EOF
```

> **Note: Ensure the projectns variable is set before executing the
> command.** 2. You can set it using the following command (for a Kommander
> Project called project1, and after setting the

workspacens as explained in the previous section).

```bash
projectns=$(kubectl -n ${workspacens} get projects.workspaces.kommander.mesosphere.io
-o jsonpath='{.items[?
(@.metadata.generateName=="project1-")].status.namespaceRef.name}')
```

When a Project Role is created, Kommander creates a Kubernetes FederatedRole
on the Kubernetes cluster where Kommander is running.

```bash
kubectl -n ${projectns} get federatedroles.types.kubefed.io admin-dbfpj-l6s9g -o yaml
apiVersion: types.kubefed.io/v1beta1
kind: FederatedRole
metadata:
creationTimestamp: "2020-06-04T11:54:26Z"
finalizers:
- kubefed.io/sync-controller
generation: 1
name: admin-dbfpj-l6s9g
namespace: project1-5ljs9-lhvjl
ownerReferences:
- apiVersion: workspaces.kommander.mesosphere.io/v1alpha1
blockOwnerDeletion: true
controller: true
kind: ProjectRole
name: admin-dbfpj
uid: e5f3b2ca-16bf-474d-8305-7be04c034793
resourceVersion: "75680"
selfLink: /apis/types.kubefed.io/v1beta1/namespaces/project1-5ljs9-lhvjl/
federatedroles/admin-dbfpj-l6s9g
uid: 1e5a3d98-b223-4605-bba1-16276a3eb47c
spec:
placement:
clusterSelector: {}
template:
rules:
- apiGroups:
- '*'
resourceNames:
- '*'
resources:
- '*'
verbs:
- '*'
status:
clusters:
- name: konvoy-5nr5h
conditions:
- lastTransitionTime: "2020-06-04T11:54:26Z"
lastUpdateTime: "2020-06-04T11:54:26Z"
status: "True"
type: Propagation
observedGeneration: 1
```

1. Then, if you run the following command on a Kubernetes cluster associated
   with the Project, you see a Kubernetes Role object in the corresponding
   namespace.

```bash
kubectl -n ${projectns} get role admin-dbfpj-l6s9g -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
creationTimestamp: "2020-06-04T11:54:26Z"
labels:
kubefed.io/managed: "true"
name: admin-dbfpj-l6s9g
namespace: project1-5ljs9-lhvjl
resourceVersion: "29218"
selfLink: /apis/rbac.authorization.k8s.io/v1/namespaces/project1-5ljs9-lhvjl/roles/
admin-dbfpj-l6s9g
uid: f05b998c-4649-4e73-bbfe-c12bc4c86a3c
rules:
- apiGroups:
- '*'
resourceNames:
- '*'
resources:
- '*'
verbs:
- '*'
```

### Project ConfigMaps

As reference, a ConfigMap is a key-value pair to store some type of non-
confidential data like "name=bob" or "state=CA". For a full reference to the
concept, consult the Kubernetes documentation on the topic of ConfigMaps. For
more information, see
`<https://kubernetes.io/docs/concepts/configuration/configmap/>`.

About this task

The below Project ConfigMap form can be navigated to by:

Procedure

1. From the top menu bar, select your target workspace.
2. Select Projects from the sidebar menu.
3. Select your project from the list.
4. Select the ConfigMaps tab to browse the deployed ConfigMaps.
5. Click + Create ConfigMap .
6. Enter an ID, Description and Data for the ConfigMap, and click Create.

#### Configuring Project ConfigMaps Using the CLI

Procedure

1. A Project ConfigMap is simply a Kubernetes FederatedConfigMap and can be
   created using kubectl with YAML.

```bash
cat << EOF | kubectl create -f -
apiVersion: types.kubefed.io/v1beta1
kind: FederatedConfigMap
metadata:
generateName: cm1-
namespace: ${projectns}
spec:
placement:
clusterSelector: {}
template:
data:
key: value
EOF
Note: Ensure the projectns variable is set before executing the command. This variable is the project
namespace (the Kubernetes Namespace associated with the project) that was defined/created when the project itself
was initially created.
projectns=$(kubectl -n ${workspacens} get
projects.workspaces.kommander.mesosphere.io -o jsonpath='{.items[?
(@.metadata.generateName=="project1-")].status.namespaceRef.name}')
```

1. Then, if you run the following command on a Kubernetes cluster associated
   with the Project, you'll see a Kubernetes ConfigMap Object, in the
   corresponding namespace.

```bash
kubectl -n ${projectns} get configmap cm1-8469c -o yaml
apiVersion: v1
data:
key: value
kind: ConfigMap
metadata:
creationTimestamp: "2020-06-04T16:37:10Z"
labels:
kubefed.io/managed: "true"
name: cm1-8469c
namespace: project1-5ljs9-lhvjl
resourceVersion: "131844"
selfLink: /api/v1/namespaces/project1-5ljs9-lhvjl/configmaps/cm1-8469c
uid: d32acb98-3d57-421f-a677-016da5dab980
```

### Project Secrets

When you create a project secret, NKP automatically provisions the
corresponding Kubernetes secret in each associated cluster and namespace. The
project secrets simplify credential distribution, configuration consistency,
and reduce manual effort in multi-cluster environments.

#### Configuring the Project Secrets Using the UI

About this task

Context for the current task

Procedure

1. Select the workspace your project was created in from the workspace
   selection dropdown in the header.
2. In the sidebar menu, select Projects.
3. Select the project you want to configure from the table.
4. Select the Secrets tab, and then click Create Secret .
5. Complete the form and click Create.

#### Configuring the Project Secrets Using the CLI

Procedure

1. A Project Secret is simply a Kubernetes FederatedConfigSecret and can also
   be created using kubectl.

```bash
cat << EOF | kubectl create -f -
apiVersion: types.kubefed.io/v1beta1
kind: FederatedSecret
metadata:
generateName: secret1-
namespace: ${projectns}
spec:
placement:
clusterSelector: {}
template:
data:
key: dmFsdWU=
EOF
```

Ensure the projectns variable is set before executing the command.

```bash
projectns=$(kubectl -n ${workspacens} get projects.workspaces.kommander.mesosphere.io
-o jsonpath='{.items[?
(@.metadata.generateName=="project1-")].status.namespaceRef.name}')
```

> **Note: The value of the key is base64 encoded.** 2. If you run the
> following command on a Kubernetes cluster associated with the Project, you
> see a Kubernetes Secret Object, in the corresponding namespace.

```bash
kubectl -n ${projectns} get secret secret1-r9vk2 -o yaml
apiVersion: v1
data:
key: dmFsdWU=
kind: Secret
metadata:
creationTimestamp: "2020-06-04T16:51:59Z"
labels:
kubefed.io/managed: "true"
name: secret1-r9vk2
namespace: project1-5ljs9-lhvjl
resourceVersion: "137215"
selfLink: /api/v1/namespaces/project1-5ljs9-lhvjl/secrets/secret1-r9vk2
uid: e5c6fc1d-93e7-47fe-ae1e-f418f8e35d72
type: Opaque
```

### Project Quotas and Limit Ranges

About this task

Procedure

1. Select the workspace your project was created in from the workspace
   selection dropdown in the header.
2. In the sidebar menu, select Projects.
3. Select the project you want to configure from the table.
4. Select the Quotas & Limit Ranges tab, and then select Edit. Kommander
   provides a set of default resources for which
   you can set Quotas. You can also define Quotas for custom resources. We
   recommend that you set Quotas for CPU and
   Memory. By using Limit Ranges, you can restrict the resource consumption of
   individual Pods, Containers, and Persistent
   Volume Claims in the project namespace. You can also constrain memory and CPU
   resources consumed by Pods and Containers,
   and storage resources consumed by Persistent Volume Claims.
5. To add a custom quota, scroll to the bottom of the form and select Add Quota.
6. When you are finished, click Save.

About this task

```yaml
Important: The values in the following examples are illustrative only. Determine ResourceQuota and
LimitRange values appropriate to your workloads and cluster capacity before applying them.
```

Procedure

1. All the Project Quotas are defined using a Kubernetes
   FederatedResourceQuota called kommander which you can also create/update
   using kubectl.

```bash
cat << EOF | kubectl apply -f -
apiVersion: types.kubefed.io/v1beta1
kind: FederatedResourceQuota
metadata:
name: kommander
namespace: ${projectns}
spec:
placement:
clusterSelector: {}
template:
spec:
hard:
limits.cpu: "10"
limits.memory: 1024.000Mi
EOF
```

Ensure the projectns variable is set before executing the command.

```bash
projectns=$(kubectl -n ${workspacens} get projects.workspaces.kommander.mesosphere.io
-o jsonpath='{.items[?
(@.metadata.generateName=="project1-")].status.namespaceRef.name}')
```

1. Then, if you run the following command on a Kubernetes cluster associated
   with the Project, you'll see a Kubernetes Resource Quota in the
   corresponding namespace.

```bash
kubectl -n ${projectns} get resourcequota kommander -o yaml
apiVersion: v1
kind: ResourceQuota
metadata:
creationTimestamp: "2020-06-05T08:04:37Z"
labels:
kubefed.io/managed: "true"
name: kommander
namespace: project1-5ljs9-lhvjl
resourceVersion: "470822"
selfLink: /api/v1/namespaces/project1-5ljs9-lhvjl/resourcequotas/kommander
uid: 925b61b4-134b-4c45-915c-96a05b63d3c3
spec:
hard:
limits.cpu: "10"
limits.memory: 1Gi
status:
hard:
limits.cpu: "10"
limits.memory: 1Gi
used:
limits.cpu: "0"
limits.memory: "0"
```

Similarly, Project Limit Ranges are defined using a FederatedLimitRange object
with name kommander in the project namespace.

```bash
cat << EOF | kubectl apply -f -
apiVersion: types.kubefed.io/v1beta1
kind: FederatedLimitRange
metadata:
name: kommander
namespace: ${projectns}
spec:
placement:
clusterSelector: {}
template:
spec:
limits:
- type: "Pod"
max:
cpu: "2"
memory: 1Gi
min:
cpu: 200m
memory: 6Mi
- type: "Container"
max:
cpu: 2
memory: 1Gi
min:
cpu: 100m
memory: 3Mi
- type: "PersistentVolumeClaim"
max:
storage: 3Gi
min:
storage: 1Gi
EOF
```

### Project Network Policies

Cluster networking is a critical and central part of Kubernetes that can also
be quite challenging. All network communication within and between clusters
depends on the presence of a Container Network Interface (CNI) plugin.

#### Network Policies

Since the Kubernetes default is to allow all traffic, it is a common practice
to create a default "deny all traffic" rule, and then specifically open up
some combination of the pods, ports, and applications as needed.

Network Plugins

Since pods are short-lived, the cluster needs a way to configure the network
dynamically as pods are created and destroyed. Plugins provision and manage IP
addresses to interfaces and let administrators manage IPs and their
assignments to containers, in addition to connections to more than one host,
when needed.

- General information
- Ingress rules
- Egress rules

General Information section

The fields in this part of the form allow you to create a name and description
for this policy. Creating a detailed Description helps to keep policy
functions understandable for additional use and maintenance.

This section also contains the Pod Selector fields for selecting pods using
either Labels or Expressions. Labels added to pod declarations are a common
means of identifying individual pods, or creating groups of pods, in a
Kubernetes cluster. Expressions are similar to Labels, but allow you to define
parameters that identify a range of pods.

The Policy Types selections help to define the type of Network Policy you are
creating:

- Default - automatically includes ingress, and egress is set only if the
  network policy defines egress rules.
- Ingress - this policy applies to ingress traffic for the selected pods, to
  namespaces using the options you define below, or both.
- Egress - this policy applies to egress traffic for the selected pods, to
  namespaces using the options you define below, or both.

If the Default policy type is too rigid or does not offer what you need, you
can select the Ingress or Egress type, or both, and explicitly define the
policy with the options that follow. For example, if you do not want this
policy to apply to ingress traffic, you only select Egress, and then define
the policy.

To deny all ingress traffic, select the Ingress option here and then leave the
ingress rules empty.

To deny all egress traffic, select the Egress option here and then leave the
egress rules empty.

Ingress rules section

Ingress rules use a combination of Port/ Protocol and Source to define the
incoming traffic allowed to some or all of the pods in this namespace.

The options under Sources: From enable you to define a source either by using
the pod selector or by defining an IP block. When using the pod selector
method, you can define the namespace, the pods within that namespace, or both.

Namespaces - Selecting a namespace in an ingress rule source permits the pods
selected by the pod selector, in your selected namespaces, to receive incoming
traffic that meets the other defined criteria. If you have not selected any
pods, the rule permits traffic from all pods in the selected namespaces.

Pods - This option selects specific Pods which should be allowed as ingress
sources or egress destinations. If you have not selected any namespaces in the
namespace selector, this option selects all matching pods in the project
namespace. Otherwise, this option selects all matching pods in the selected
namespaces.

There also are options to select all namespaces, all pods, or both.

When defining ingress rules using the IP Block method, you define a CIDR and
exception conditions. CIDR stands for
Classless Inter-Domain Routing and is an IP standard for creating unique
network and device identifiers. When grouped
together so that they share an initial sequence of bits in their binary
representation, the range of addresses creates a
CIDR block. The block identity is in an IPv4-like notation including a dotted-
decimal address, followed by a slash, then
a colon and a number from 0 through 32, for example, 127.0.26.33:31.

Egress rules section

Egress rules use a similar combination of options to define the outgoing
traffic from pods, ranges of pods, or namespaces in a Kommander Project. Port,
Protocol, and Destination options for egress rules define the outgoing
traffic. You can define your egress rules under Destination: To. Ensure the
egress policy on the source pods, and the ingress policy on the destination
pods, permit traffic in order for the pods to be able to communicate over the
network.

Network Policy Examples

Before you begin each example, ensure you're on the Network Policy page for
your project

#### Navigating to the Network Policy Page

#### Ingress: Permit Access to API Service Pods from All Namespaces

- Ingress: Limit Pods That Access a Database to a Namespace on page 456
- Ingress: Disable But Not Delete Ingress Rules on page 457
- Egress: Deny all Egress Traffic from Restricted Pods on page 457

#### Navigating to the Network Policy Page (2)

About this task

To navigate to your project's Network Policy page:

Procedure

1. From the top menu bar, select your target workspace.
2. Select Projects from the sidebar menu.
3. Select your project from the list.
4. Select the Network Policy tab.

#### Ingress: Permit Access to API Service Pods from All Namespaces (2)

Suppose you need to create a network policy to permit incoming traffic to API
service pods in a specific Kommander Project's namespace from any other pod in
any namespace that has the label, service.corp/users-api-role: client. For
this example, API service pods are those pods created with the Label,
service.corp/users-api- role: api.

You can limit the policy to just incoming traffic from select namespaces by
adding an ingress rule with these characteristics:

- Use Port 8080 to receive incoming TCP traffic
- Refuse traffic from pods unless they are client pods that have a specific
  Label, such as service.corp/users- api-role: client. This example follows a
  common microservice architecture pattern, microservice-tier-role:
  access_mode

##### Configuring General Information to Access the API Service Pods

Procedure

1. Select + Create Network Policy .
2. Type "microsvc-users-api-allow" in the ID Name field.
3. Type "Allow Users microservice clients to reach the APIs provided in this
   namespace" in the Description field.
4. Select Add under Pod Selector and then select Match Label.
5. Set the Key to "service.corp/users-api-role" and the Value to "API".

##### Creating an Ingress Rule to Access API Service Pods

Procedure

1. Leave Policy Types set to Default.
2. Scroll down to Ingress Rules and select + Add an Ingress Rule.
3. Select + Add Port, and set the Port to "8080" and the Protocol to TCP.

##### Adding Sources to Access API Service Pods

Procedure

1. Select + Add Source and mark the Select All Namespaces checkbox.
2. Select + Add Pod Selector.
3. Select Match Label.
4. Set the Key value to service.corp/users-api-role, and Value to client.
5. Scroll up and click Save.

#### Ingress: Limit Pods That Access a Database to a Namespace

Suppose that while deploying an application in a project, you want to protect
its database pods by permitting ingress only from API service pods in the
current namespace, and prevent ingress from pods in any other namespace.

You can limit the database pods to just the incoming traffic from the current
namespaces by adding an ingress rule with these characteristics:

- Use Port 3306 to receive incoming TCP traffic for pods that have the label,
  tier: database
- Refuse traffic from pods unless they have the label, tier: api

##### Configuring General Information to Access a Database

About this task

To configure general information to access a database:

Procedure

1. Select + Create Network Policy .
2. Type "database-access-api-only" in the ID Name field.
3. Type "Allow MySQL access only from API pods in this namespace" in the
   Description field.
4. Select Add under Pod Selector and then select Match Label.
5. Set the Key to "tier" and the Value to "database".

##### Creating an Ingress Rule to Access a Database

Procedure

1. Leave Policy Types set to Default.
2. Scroll down to Ingress Rules and select + Add an Ingress Rule.
3. Select + Add Port, and set the Port to "3306" and the Protocol to TCP.

##### Adding Sources to Access a Database

Procedure

1. Select + Add Source.
2. Select + Add Pod Selector.
3. Select Match Label.
4. Set the Key value to "tier" and set the Value to "database".
5. Scroll up and click Save.

#### Ingress: Disable But Not Delete Ingress Rules

First, you need to create a network policy with one or more ingress rules.
Follow one of the preceding procedures. Then, edit the policy to match the
following example:

##### Editing Your Network Policy

Procedure

To modify or edit your network policy, identify the corresponding row in the
table belonging to your network policy. Click the context menu icon on the
right side of the row and select the Edit option.

##### Disabling Ingress Rules

Procedure

1. Update the Policy Types so that only Egress is selected. If you don't want
   to deny all egress traffic, ensure that you add an egress rule that suits
   your preferred level of access. You can add an empty rule to allow all
   egress traffic.
2. Scroll up and click Save.

#### Egress: Deny all Egress Traffic from Restricted Pods

##### Configuring General Information to Deny Egress

Procedure

1. Select + Add Network Policy .
2. Type "deny-restricted-egress" in the ID Name field.
3. Type "Deny egress traffic from restricted pods" in the Description field.
4. Select Add under Pod Selector and then select Match Label.
5. Set the Key to "access" and the Value to "restricted".

##### Denying Egress Traffic

Procedure

1. You must update the Policy Types to ensure that only Egress is selected. Do
   not define any egress rules.
2. Once the policy types are updated, you must scroll up and click Save.

## Cluster Management

View clusters created with Kommander or any connected Kubernetes cluster

Kommander allows you to monitor and manage very large numbers of clusters. Use
the features described in this area to connect existing clusters, or to create
new clusters whose life cycle is managed by Konvoy. You can view clusters from
the Clusters tab in the navigation pane on the left. You can see the details
for a cluster by selecting the View Details link at the bottom of the cluster
card or the cluster name in either the card or the table view.

### Creating a Managed Nutanix Cluster Through the NKP UI

About this task

Provisioning a production-ready cluster requires you to specify a number of
parameters. Breaking up the form sections, as done in this documentation
section, makes it a little easier to complete.

Before you begin

Ensure you have fulfilled the Prism Central Requirements for Nutanix
Kubernetes Platform Installation on page 729 requirements. To Provision a
Nutanix Cluster, you must also create a Nutanix infrastructure before you can
create additional clusters.

```yaml
Caution: Before provisioning a managed cluster, ensure your network allows seamless access from the management
cluster to the Prism Central (PC) environment to avoid provisioning issues.
```

Select the View Details link (on the cluster card's bottom left corner) to see
additional information about this cluster.

Procedure

Open the NKP UI.

What to do next

#### Specifying Nutanix Cluster Information

About this task

In the section of the provisioning form, you give the cluster a name and
provide some basic information:

Procedure

1. In the selected workspace Dashboard, select the Add Cluster button at the
   top right to display the Add Cluster page.
2. Select the Create Cluster card.
3. Provide these cluster details in the form:

- Cluster Name: A valid Kubernetes name for the cluster.
- Add Labels: Add any required Labels the cluster needs for your environment
  by selecting the + Add Label link.

Adding a cluster label might add the cluster to NKP projects.

- Infrastructure Provider: This field's value corresponds to the Nutanix
  infrastructure provider you created.
- Kubernetes Version: Select a supported version of Kubernetes for this
  version of NKP.
- SSH Username: This field corresponds to the name of the SSH user to create
  or use. Leaving this field blank creates the default user name 'konvoy' for
  the specified SSH public key.
- SSH Public Key: Paste the SSH public key that specifies the user's
  authorized key.

#### Configuring Nutanix Node Pool Information

About this task

You must configure node pool information for your control plane and worker
nodes. The form splits these information sets into two groups.

Procedure

1. Provide the control plane node pool name and resource sizing information.

- Nutanix Prism Project: Select Nutanix Prism Project. Selecting this will
  associate all the NKP control plane node virtual machines to this project.

> **Note:**

Nutanix recommends that you create NKP clusters only on the default Prism
Central project (\_internal). When you create a cluster, do not select a Prism
Central project. Prism Central 7.5 does not enforce this recommendation.

- If a cluster uses the default project, continue to use it.
- A cluster must use a single project for all of its resources. NKP does not
  support spreading a cluster's resources across multiple projects.
- NKP does not support moving an existing cluster from one project to another.
- To use a different project, create a new cluster.
- Nutanix AOS Cluster: Nutanix AOS cluster is used to host the control plane
  virtual machines. If a Nutanix Prism Project is chosen, only the AOS
  clusters linked to that project will be shown.
- Subnet: Subnet used for the control plane nodes. Subnet must be precreated
  in Nutanix Prism Central. If a Nutanix Prism project is chosen, only the
  subnets associated with the Nutanix Prism Project will be shown. At least
  one subnet must be selected.
- OS Image: Select an NKP compliant OS image uploaded in Prism Central for the
  Kubernetes control plane nodes.
- Nutanix Prism Categories: Add additional Nutanix Prism Categories to the NKP
  control plane VMs. The categories must exist in Prism Central.
- Control Plane Endpoint IP : Endpoint IP is used for the NKP Kubernetes API
  VIP.

> **Note: This IP address should not belong to a DHCP range or Nutanix IPAM
> address pool.**

- Control plane Endpoint port : Port used for NKP Kubernetes API server. By
  default the value is 6443.
- Control plane Node Count : This field corresponds to the amount of control
  plane nodes for the NKP cluster. The default value is 3, other options are 1
  or 5.

> **Caution: Do not use a single-node control plane in a production cluster.
> Recommended is 3 or more.**

- CPU per Node (vCPU) : The amount of vCPUs per control plane node.
- Memory per node (GiB) : The amount of Memory per control plane node (in GiB).
- Disk Size per node (GiB) : The amount of disk size per control plane node
  (in GiB).

```yaml
Note: When you select a project, AOS cluster, subnets, and images in the control plane section, these selections
will automatically populate the worker node pool section. This eliminates the need to input the same information
twice manually. However, if desired, you can modify these selections for the worker node pool.
```

1. Provide the worker node pool name and resource sizing information.

- Nutanix Prism Project: Select Nutanix Prism Project. Selecting this will
  associate all the NKP worker node virtual machines to this project.

> **Note:**

Nutanix recommends that you create NKP clusters only on the default Prism
Central project (\_internal). When you create a cluster, do not select a Prism
Central project. Prism Central 7.5 does not enforce this recommendation.

- If a cluster uses the default project, continue to use it.
- A cluster must use a single project for all of its resources. NKP does not
  support spreading a cluster's resources across multiple projects.
- NKP does not support moving an existing cluster from one project to another.
- To use a different project, create a new cluster.
- Nutanix AOS Cluster: Nutanix AOS cluster is used to host the control plane
  virtual machines. If a Nutanix Prism Project is chosen, only the AOS
  clusters linked to that project will be shown.
- Subnet: Subnet used for the control plane nodes. Subnet must be precreated
  in Nutanix Prism Central. If a Nutanix Prism project is chosen, only the
  subnets associated with the Nutanix Prism Project will be shown. At least
  one subnet must be selected.
- OS Image: Select an NKP compliant OS image uploaded in Prism Central for the
  Kubernetes worker nodes.
- Nutanix Prism Categories: Add additional Nutanix Prism Categories to the NKP
  worker node VMs. The categories must exist in Prism Central.
- Worker node Autoscaling: Enable or disable worker node autoscaling. If
  enabled, NKP will automatically add or remove nodes based on workload
  demands. This is disabled by default.
- If worker node autoscaling is enabled :
- Minimum number of nodes: Minimum amount of worker nodes in the worker node
  pool.
- Maximum number of nodes: Maximum amount of worker nodes in the worker node
  pool.
- If worker node autoscaling is disabled::
- Worker node count:: The amount of worker nodes in the node pool.
- CPU per Node (vCPU): The amount of vCPUs per worker node.
- Memory per node (GiB): The amount of Memory per worker node (in GiB).
- Disk Size per node (GiB): The amount of disk size per worker node (in GiB).

1. Provide the Storage information.

- Hypervisor attached Volumes: The hypervisor attached Nutanix Volume uses the
  hypervisor internal network for data traffic instead of external iSCSI
  connections. Enabled by default.
- Nutanix Storage container: The Storage container is used for the Nutanix
  Volumes. Nutanix Storage container must be pre-created in Prism Central.
- Reclaim Policy: This field corresponds to the Reclaim policy for the
  persistent volumes. The allowed values are Retain and Delete. Default is
  Delete.

1. Provide the Networking information.

- Pod Network: The Kubernetes Pod network CIDR to use in the cluster (Default
  is 192.168.0.0/16).

```yaml
Note: Ensure the CIDRs do not overlap with your host subnets because they cannot be changed after cluster
creation.
```

- Service Network: The Kubernetes Service CIDR to use in the cluster (Default
  is 10.96.0.0/12).

```yaml
Note: Ensure the CIDRs do not overlap with your host subnets because they cannot be changed after cluster
creation.
```

- Service load balancer start IP: Enter the first IP address in the private
  range you're allocating for load balancing.

> **Note: These IP addresses should not belong to a DHCP range or Nutanix
> IPAM address pool.**

- Service load balancer end IP: Enter the last IP address in the private range
  you're allocating for load balancing.

> **Note: These IP addresses should not belong to a DHCP range or Nutanix
> IPAM address pool.** 5. Provide the Image registries information.

- Image Registry Mirror: Use an image registry mirror as a local copy of
  public registries. Defining a mirror registry is recommended if you have an
  air-gapped environment or want to avoid restrictions with firewalls.
- URL: Enter the valid URL for the image registry mirror.
- Username: Enter the Username for the registry mirror.
- Password: Enter the password for the registry mirror.
- CA certificate: Enter the CA certificate for the registry mirror. This is
  required in case of self-signed certificates.
- Private Registry: Use a private image registry for your application images.
- URL: Enter the valid URL for the image registry mirror.
- Username: Enter the Username for the registry mirror.
- Password: Enter the password for the registry mirror.
- CA certificate: Enter the CA certificate for the registry mirror. This is
  required in case of self-signed certificates.

#### Configuring CIDR Values for the Pod Network and Kubernetes Services

About this task

In this section of the form, you configure Classless Inter-Domain Routing
(CIDR) Values that your cluster uses.

Procedure

Specify the following values.

- Enter a CIDR value for the Pod network in the Pod Network CIDR field. The
  default value is 192.168.0.0/16.
- Enter a CIDR value for Kubernetes Services in the Service CIDR field. The
  default value is 10.96.0.0/12.

### Creating Nutanix Kubernetes® Platform (NKP) Clusters on Failure Domains

Use failure domains to achieve the following:

- Higher availability of Kubernetes control plane: Creates three control plane
  VMs across three Prism Element clusters.
- Predetermined placement of worker node pools: Assigns each node pool to a
  specific Prism Element cluster.
- Reusable configuration: After you create a Nutanix failure domain object,
  you can reference it on any cluster within that namespace.

```yaml
Caution: The persistent volumes are not portable across failure domains. If the Prism Element cluster associated
with the failure domain fails and cannot recover, NKP does not replicate the corresponding storage volumes to Prism
Element clusters associated with other failure domains.
```

Prerequisites

Before you create and apply failure domain objects to an NKP cluster, ensure
that your infrastructure meets the following requirements:

Table 46: Prerequisites for Failure Domains

NKP version Failure domains are supported starting from NKP version 2.16 and
later

Failure domain cluster resources Failure domain cluster resources must reside
in the same namespace as the target cluster object

Network latency between control-plane failure domains remains within a
10-millisecond round trip time (RTT) of each other

etcd is sensitive to network latencies and is deployed on control plane nodes
that are distributed across failure domains

Control#plane failure domains share an L2 subnet Ensure that all control plane
failure domains share an L2 subnet, so that address resolution protocol (ARP)
resolves the virtual IP (VIP) address using any control plane VM

Storage container Storage container referenced in the cluster must exist in
every failure domain.

#### Creating Nutanix Failure Domain Objects

About this task

To create a failure domain object, follow these steps:

| Requirements | Description |
| ------------ | ----------- |

> **Note: If you are adding failure domains to an already deployed cluster,
> skip Step 1 and Step 2.**

Procedure

1. If you are creating a new cluster, first create the required cluster
   manifests using the --dry-run flag and store them in a file using
   --output=yaml

```bash
$ nkp create cluster nutanix \
--cluster-name=example-cluster \
--control-plane-prism-element-cluster=${NUTANIX_CLUSTER} \
--control-plane-subnets=${NUTANIX_SUBNET} \
--control-plane-endpoint-ip=${CONTROL_PLANE_ENDPOINT} \
--control-plane-replicas=3 \
--worker-prism-element-cluster=${NUTANIX_CLUSTER} \
--worker-subnets=${NUTANIX_SUBNET} \
--worker-replicas=4 \
--endpoint="https://${NUTANIX_PRISM_CENTRAL_ENDPOINT}:9440" \
--kubernetes-service-load-balancer-ip-range="${LOAD_BALANCER_IP_RANGE}" \
--csi-storage-container=${NUTANIX_STORAGE_CONTAINER} \
--csi-hypervisor-attached-volumes=false \
--timeout=60m0s \
--registry-url=${REGISTRY_URL} \
--registry-username=${DOCKERHUB_USERNAME} \
--registry-password=${DOCKERHUB_PASSWORD} \
--control-plane-vm-image="${NIB_IMAGE}" \
--worker-vm-image="${NIB_IMAGE}" \
--control-plane-memory=8 \
--worker-memory=16 \
--dry-run \
--output=yaml > example-cluster.yaml
# Generating cluster configuration (Kubernetes resources)
# Running preflight checks
# Creating metadata object
```

1. Note the namespace of the generated cluster object.
2. Create a NutanixFailureDomain object in the same namespace as the cluster.

```yaml
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixFailureDomain
metadata:
name: fd-1 # must be unique per namespace
namespace: cluster-ns # same namespace as the cluster
spec:
prismElementCluster:
type: name
name: example-prism-element-cluster
subnets:
- type: name
name: example-subnet
```

The NKP failure domain name must adhere to Kubernetes resource naming
conventions.

> **Note: Nutanix recommends that you create three or more failure domains
> for high availability control planes.**

#### Modifying Failure Domains in a Nutanix Kubernetes® Platform (NKP) Cluster

About this task

To add failure domains to the control plane and worker machine node pools,
follow these steps:

Procedure

For Control Planes:

1. Add a list of failure domain names to the clusterconfig variable of the
   cluster.

```bash
clusterConfig.controlPlane.nutanix.failureDomains
```

- If the number of replicas is less than the number of failure domains, NKP
  uses the kubeadm control plane (KCP) round-robin approach and that leaves
  some failure domains remain unused.
- If the number of replicas exceeds the number of failure domains, KCP
  utilizes the failure domains as evenly as possible.
- When you add or remove an existing failure domain configuration on a running
  cluster, NKP rolls out new control plane nodes across the updated failure
  domains.
- If failure domains are set, you cannot specify cluster and subnet
  configuration in the control plane machineDetails.

```yaml
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
name: demo
namespace: cluster-ns
spec:
...
topology:
class: nutanix-quick-start
controlPlane:
replicas: 3
variables:
- name: clusterConfig
value:
controlPlane:
nutanix:
failureDomains: # list of strings
- fd-1
- fd-2
- fd-3
machineDetails:
bootType: uefi
image:
name: nkp-rocky-os-version-number-
release-1.33.3-20250701150806.qcow2
type: name
memorySize: 8Gi
systemDiskSize: 80Gi
vcpuSockets: 4
vcpusPerSocket: 1
```

For Worker Machine Node Pools: 2. Add the failure domain name for each worker
machine node pool deployment.

```bash
topology.workers.machineDeployment[].failureDomain
```

If failure domains are set, you cannot specify cluster and subnet settings in
the worker node machineDetails.

```bash
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
name: demo
namespace: cluster-ns
spec:
...
topology:
class: nutanix-quick-start
controlPlane:
replicas: 3
variables:
- name: clusterConfig
value:
...
workers:
machineDeployments:
- name: md-0
class: default-worker
replicas: 4
failureDomain: fd-3 # string, one failure domain
variables:
overrides:
- name: workerConfig
value:
...
nutanix:
machineDetails:
bootType: uefi
image:
name: nkp-rocky-os-version-number-
release-1.33.3-20250701150806.qcow2
type: name
memorySize: 8Gi
systemDiskSize: 80Gi
vcpuSockets: 4
vcpusPerSocket: 1
```

For the supported operating system, see Supported Infrastructure Operating
Systems on page 12. 3. Apply the failure domain cluster resources in the
target namespace.

```bash
kubectl apply -f <cluster#yaml>
```

For example, the cluster objects appears as follows:

```bash
kubectl -n cluster-ns get cluster,nutanixcluster,machine,nutanixmachine
```

1. Log in to the NKP dashboard.
2. In the workspace drop-down list, select your workspace.

By default, NKP dashboard displays Global workspace. 6. Click View Details in
the cluster widget (management, managed, or attached clusters). 7. In the
General Cluster Information page, click the Configuration tab.

The Node Pools table displays only the failure domain name.

> **Note: You cannot modify the node pools associated with a failure domain
> in the user interface.**

#### Failure Domain Mitigation Scenarios and Troubleshooting

Mitigation Scenarios

The following scenarios explain how NKP handles failure domains in different
conditions:

- If you deliberately remove or replace a failure domain. For more
  information, see Modifying Failure Domains in a Nutanix Kubernetes® Platform
  (NKP) Cluster on page 464
- If the failure domain temporarily goes down due to a power or network outage
  and later recovers.
- If the failure domain is permanently lost due to a catastrophic failure.

> **Note: For recoverable failures, wait for the domain to recover. For
> unrecoverable failures, see KB-19816.**

The following are the most common issues with failure domains and their fixes.

Table 47: Common Failure Domain Issues and Fixes

Missing storage container Preflight checks fail when the storage container is
missing in the Prism Element cluster specified in the failure domain.

Create a storage container in the referenced Prism Element cluster or remove
the failure domain from the configuration.

Cluster not using specified failure domain

Cluster creation skips the control plane machine due to a typo in the failure
domain name or non#existent failure domain.

Ensure that the failure domain exists in the same namespace as the cluster and
includes valid Prism Element cluster and subnet entries.

CSI volume driver failure The CSI driver fails due to a missing storage
container in the failure domain.

Create a storage container in the Prism Element cluster.

Machine deployment stuck The machine deployment stalls due to resource
exhaustion in the Prism Element.

Monitor Prism dashboards to free up resources or switch to a different failure
domain.

Virtual IP failover issue Virtual IP failover fails due to L2 subnet and
address resolution protocol (ARP) reachability issues across control plane
failure domains.

Ensure that you plan failure domains on the same L2 subnets and test the
virtual IPs during staging to avoid IP conflicts.

Emptycluster.status.failureDomains If cluster.status.failureDomains is empty,
CAPX cannot validate any specified failure domains.

Check CAPX logs and verify that the clusters and subnets referenced in the
failure domains are valid.

| Errors | Reasons | Fixes |
| ------ | ------- | ----- |

NodePool edit disabled in the user interface

NKP user interface does not support editing node pools associated with a
failure domain.

Use kubectl edit cluster to edit the corresponding MachineDeployment in the
cluster resource.

Degraded control plan (only 2 of 3 running)

Caused by either a recoverable or and unrecoverable failure in the Prism
Element cluster.

For recoverable failures, wait for the domain to recover. For unrecoverable
failures, see KB-19816.

### Creating a Managed Azure Cluster Through the NKP UI

Before you begin

Before you provision an Azure cluster using the NKP UI, you must first create
an Azure infrastructure provider. For more information on how to hold your
Azure credentials, see Configuring an Azure Infrastructure Provider in the UI
on page 323.

Follow these steps to provision an Azure cluster:

Procedure

1. From the top menu bar, select your target workspace.
2. Select Clusters > Add Cluster.
3. Choose Create Cluster.
4. Enter the Cluster Name.
5. From Select Infrastructure Provider, choose the provider created in the
   prerequisites section.
6. If available, choose a Kubernetes Version. Otherwise, the review of
   Supported Kubernetes Versions section in the NKP Release Notes.
7. Select a datacenter location or specify a custom location.
8. Edit your worker Node Pools as necessary. You can choose the Number of
   Nodes, the Machine Type, and for the worker nodes, you can choose a Worker
   Availability Zone.
9. Add any additional Labels or Infrastructure Provider Tags as necessary.
10. Review your inputs to ensure they meet the predefined criteria, and select
    Create.

> **Note: It can take up to 15 minutes for your cluster to appear in the
> Provisioned status.**

You are then redirected to the Clusters page, where you'll see your new
cluster in the Provisioning status. Hover over the status to view the details.

### Creating a Managed vSphere Cluster Through the NKP UI

About this task

Provisioning a production-ready cluster in vSphere requires you to specify a
fairly large number of parameters. Breaking up the sections of the form, as
done below, makes it a little easier to complete.

| Errors | Reasons | Fixes |
| ------ | ------- | ----- |

Before you begin

Before you begin these procedures, ensure that you have fulfilled the vSphere
vCenter configuration prerequisites described in vSphere Prerequisites.

> **Note:**

You must also create a vSphere infrastructure provider before you can create
additional vSphere clusters.

To Provision a vSphere Cluster.

Procedure

Complete these procedures to provision a vSphere cluster.

- Provide Basic Cluster Information
- Specifying the Cluster Resources and Network Information on page 470
- Configure Node Pool Information
- Set Virtual IP Parameters
- Supply MetalLB Information
- Configure the StorageClass Options
- Advanced Configuration Parameters

What to do next

Select the View Details link (on the cluster card's bottom left corner) to see
additional information about this cluster.

#### Specifying Basic Cluster Information

About this task

In the section of the provisioning form, you give the cluster a name and
provide some basic information:

Procedure

1. In the selected workspace Dashboard, select the Add Cluster button at the
   top right to display the Add Cluster page.
2. Select the Create Cluster card.
3. Provide these cluster details in the form:

- Cluster Name: A valid Kubernetes name for the cluster.
- Add Labels: Add any required Labels the cluster needs for your environment
  by selecting the + Add Label link.

By default, your cluster has labels that reflect the infrastructure provider
provisioning. For example, your vSphere cluster might have a label for the
datacenter and provider: vsphere. Cluster labels are matched to

the selectors created for Projects. Changing a cluster label might add or
remove the cluster from projects. For more information, see Projects on page 415.

- Infrastructure Provider: The value in this field corresponds to the vSphere
  infrastructure provider you created while fulfilling the prerequisites.
- Kubernetes Version: Select a supported version of Kubernetes for this
  version of NKP.
- SSH Public Key: Paste into this field the public key value for a user who is
  authorized to create the public key value for a user who is authorized to
  create vSphere clusters into this field clusters.
- Workspace: The workspace where this cluster belongs (if within the Global
  works).

#### Specifying the Cluster Resources and Network Information

About this task

This section of the form identifies resources already present in your VMware
vCenter configuration. Refer to your vCenter configuration to find the
necessary values.

Procedure

1. Provide the following values for the Resources that are specific to vSphere.

- Datacenter: Select an existing data center name.

The datacenter is the top level organizational unit in vSphere.

- Datastore: Enter a valid vSphere datastore name.

Datastores in vSphere are storage resources that provide storage
infrastructure for virtual machines within a datacenter. They are a subset of
datacenter resources, with each datastore being associated with a specific
datacenter.

- Folder: Enter a valid, existing folder name, or leave it blank to use the
  vSphere root folder.

When provisioning a Kubernetes cluster on vSphere using Cluster API and
clusterctl, vSphere uses the folder parameter to specify the vSphere folder
where it creates and manages the virtual machines for the Kubernetes cluster.
Specifying the folder helps maintain an organized inventory of your virtual
machines and other resources in your vSphere environment. 2. Enter the values
for the network information in the lower half of this section.

- Network: Enter an existing network name you want the new cluster to use.

You need to create required network resources, such as port groups or
distributed port groups, in the vSphere Client or using the vSphere API before
you use NKP to create a new cluster.

- Resource Pool: Enter the name of a logical resource pool for the cluster's
  resources.

In vSphere, resource pools are a logical abstraction that allows you to
allocate and manage computing resources, such as CPU and memory, for a group
of virtual machines. Use resource pools only when needed, as they can add
complexity to your environment.

- Virtual Machine Template: Enter the name of the virtual machine template to
  use for the managed cluster's virtual machines.

In vSphere, a virtual machine (VM) template is a pre-configured virtual
machine that you can use to create new virtual machines with identical
configurations quickly. The template contains the basic configuration settings
for the VM, such as the operating system, installed software, and hardware
configurations.

- Storage Policy: Enter the name of a valid vSphere storage policy. This field
  is optional.

A storage policy in vSphere specifies the storage requirements for virtual
machine disks and files. It consists of a
rule set that defines the storage capabilities required, tags to identify
them, profiles that collect settings and
requirements, and storage requirements that include storage performance,
capacity, redundancy, and other attributes
necessary for the virtual machine to function properly. By creating and
applying a storage policy to a specific
datastore or group of datastores, you can ensure that virtual machines using
that datastore meet the specified storage
requirements.

#### Configuring Node Pool Information

About this task

You need to configure node pool information for both your control plane nodes
and your worker nodes. The form splits these information sets into two groups.

Procedure

1. Provide the control plane node pool name and resource sizing information.

- Node Pool Name: NKP sets this field's value, control plane, and you cannot
  change it.
- Disk: Enter the amount of disk space allocated for each control plane node.
  The default value is 80 GB. The specified custom disk size must be equal to,
  or larger than, the size of the base OS image root file system. This is
  because a root file system cannot be reduced automatically when a machine
  first boots.
- Memory: The amount of memory for each control plane node in MB. The default
  value is 16384 MB.
- Number of CPUs: Enter the number of virtual processors in each control plane
  node. The default value is 4 CPUs per control plane node.
- Number of Nodes: Enter the number of control plane nodes to create for your
  new cluster.

Valid values for production clusters are 3 or 5. You can enter one if you are
creating a test cluster, but a single control plane is not a valid production
configuration. You must enter an odd number to allow for internal leader
selection processes to provide proper failover for high availability. The
default value is three control plane nodes. 2. Provide the worker node pool
name and resource sizing information.

- Node Pool Name: Enter a node pool name for the worker nodes. NKP sets this
  field's default value to worker-0.
- Disk: Enter the amount of disk space allotted for each worker node. The
  default value is 80GB. The specified custom disk size must be equal to, or
  larger than, the size of the base OS image root file system. This is because
  a root file system cannot be reduced automatically when a machine first
  boots.
- Memory: The amount of memory for each worker node in MB. The default value
  is 32768 GB.
- Number of CPUs: Enter the number of virtual processors in each worker node.
  The default value is 8 CPUs per node.
- Number of Nodes: Enter the number of worker nodes to create for your new
  cluster. The default value is four worker nodes.

#### Setting Virtual IP Parameters

About this task

In this section of the form, you configure the built-in virtual IP.

Procedure

Provide the Virtual IP information needed for managing this cluster with NKP.

- Interface: Enter the name of the network used for the virtual IP control
  plane endpoint.

This value is specific to your environment and cannot be inferred by NKP. An
example value is eth0 or ens5.

- Host: Enter the control plane endpoint address.

To use an external load balancer, set this value to the load balancer's IP
address or hostname. To use the built-in virtual IP, set to a static IPv4
address in the Layer 2 network of the control plane machines.

- Port: Enter the control plane's endpoint port.

The default port value is 6443. To use an external load balancer, see this
value in the load balancer's listening port.

#### Specifying the MetalLB Information

Procedure

The MetalLB load balancer is needed for cluster installation, and requires
these values.

- Provide a Starting IP address range value for the load balancing allocation.
- Provide an Ending IP address range value for the load balancing allocation.

#### Configuring the StorageClass Options

About this task

In this section of the form, you configure the storage options for your
vSphere cluster. The StorageClass defines the provisioning properties and
requirements for the storage used to store the persistent data of the
Kubernetes application.

You can provide either the Datastore URL or the Storage Policy Name in this
section.

Procedure

1. Select Datastore URL if it is not already highlighted, and then in the
   Datastore URL field, enter a unique identifier in URL format used by vSphere
   to access specific storage locations. A typical example of the field's
   format is ds:///vmfs/volumes/`<datastore_uuid>`/.
2. Select Storage Policy Name if it is not already highlighted, and then in
   the Storage Policy Name field, enter the name of the storage policy to use
   with the cluster's StorageClass.

#### Advanced Configuration Parameters

##### Configuring CIDR Values for the Pod Network and Kubernetes Services (2)

About this task

In this section of the form, you configure Classless Inter-Domain Routing
(CIDR) Values that your cluster uses.

Procedure

Specify the following values.

- Enter a CIDR value for the Pod network in the Pod Network CIDR field. The
  default value is 192.168.0.0/16.
- Enter a CIDR value for Kubernetes Services in the Service CIDR field. The
  default value is 10.96.0.0/12.

##### Configuring the Docker Registry Mirror

About this task

In this section, you configure a registry mirror for container images. The
first time you request an image from your local registry mirror, it pulls the
image from a public registry and stores it locally before handing it back to
you. On subsequent requests, the local registry mirror serves the image from
its own storage.

Procedure

Configure the image registry mirror.

- Registry Mirror URL: Enter the URL of a container registry to use as a
  registry mirror.
- Registry Mirror Username: Enter the name of a user who can authenticate to
  the registry mirror.
- Registry Mirror Password: Enter the password for the username in the
  previous entry.
- Registry Mirror CA Cert: Upload a certificate file or copy the CA
  certificate chain value into the provided field to use while communicating
  with the registry mirror using Transport Layer Security (TLS).

This value is a trusted root certificate (or chain of certificates) that
validates the SSL/TLS connection between clients and the registry mirror,
ensuring secure and trustworthy communications.

##### Creating the Managed Cluster on vSphere

About this task

This step may take a few minutes, as the cluster must be ready and fully
deploy its components. The cluster automatically tries to join the management
cluster for federation and fleet operations and should resolve after it is
fully provisioned.

While NKP provisions the new cluster, you can access the Clusters page to view
the new cluster. A new cluster card with the name of your cluster appears and
shows a "Pending" cluster status when the cluster comes up and joins the
management cluster.

Procedure

1. Select the Create button (at the page's top right corner) to begin
   provisioning the cluster.
2. To see additional information about this cluster, click the View Details
   link on the cluster card tile that is on the bottom left corner of the page.

### Attaching an Existing Kubernetes Cluster

You can attach an existing cluster (whether it is a cluster created with the
NKP CLI or by means of another platform) to NKP. At the time of attachment,
certain namespaces are created on the cluster, and workspace platform
applications are deployed automatically into the newly-created namespaces.

Review the Workspace Platform Application Defaults and Resource Requirements
on page 726 to ensure the attached cluster has sufficient resources. For more
information on platform applications and customizing them, see Workspace
Applications on page 370.

If the cluster you want to attach was created using Amazon EKS, Azure AKS, or
Google GKE, create a service account as described in Cluster Attachment
without Networking Restrictions on page 478.

```yaml
Note: Starting with DKP 2.6.0, NKP supports the attachment of all Kubernetes Conformant clusters, but only x86-64
architecture is supported, not ARM.
```

Platform applications extend the functionality of Kubernetes and provide
ready-to-use logging and monitoring stacks. Platform applications are deployed
when a cluster is attached to Kommander.

#### Requirements for Attaching an Existing Cluster

##### Basic Requirements

- Creating a Default StorageClass on page 475
- Projects and Workspaces on page 475
- Platform Application Requirements on page 475
- Requirements for Attaching Existing AKS, EKS, and GKE Clusters on page 475
- Requirements for Attaching Clusters with an Existing cert-manager
  Installation on page 476

To attach an existing cluster in the UI, the Application Management cluster
must be able to reach the services and the api-server of the target cluster.

The cluster you want to attach can be a NKP-CLI-created cluster (which will
become a Managed cluster upon attachment), or another Kubernetes cluster like
AKS, EKS, or GKE (which will become an Attached cluster upon attachment).

For attaching existing clusters without networking restrictions, the
requirements depend on which NKP version you are using. Each version of NKP
supports a specific range of Kubernetes versions. You must ensure that the
target cluster is running a compatible version.

##### Creating a Default StorageClass

About this task

To deploy many of the services on the attached cluster, a default

## StorageClass must be configured

Procedure

1. Run the following command on the cluster you want to attach.

```bash
kubectl get sc
```

The output should look similar to this. Note the (default) after the name:

```bash
NAME PROVISIONER RECLAIMPOLICY VOLUMEBINDINGMODE
ALLOWVOLUMEEXPANSION AGE
ebs-sc (default) ebs.csi.aws.com Delete WaitForFirstConsumer false
41s
```

1. If the StorageClass is not set as default, add the following annotation to
   the StorageClass manifest.

```bash
annotations:
storageclass.kubernetes.io/is-default-class: "true"
```

### Projects and Workspaces

```yaml
Note: Do not attach a cluster in the "Management Cluster Workspace" workspace. This workspace is reserved for your
Application Management cluster only.
```

#### Platform Application Requirements

In addition to the basic cluster requirements, the platform services you want
NKP to manage on those clusters will impact the total cluster requirements.
The specific combinations of platform applications will affect the
requirements for the cluster nodes and their resources (CPU, memory, and
storage).

To view a list of platform applications that NKP provides by default, see
Platform Applications on page 350.

##### Requirements for Attaching Existing AKS, EKS, and GKE Clusters

Attaching an existing AWS cluster requires that the cluster be fully
configured and running. You must create a separate service account when
attaching existing AKS, EKS, or Google GKE Kubernetes clusters. This is
necessary because the kubeconfig files generated from those clusters are not
usable pre-built by Kommander. The kubeconfig files call CLI commands, such as
azure, aws , or gcloud, and use locally-obtained authentication

tokens. Having a separate service account also allows you to keep access to
the cluster-specific to and isolated from Kommander.

The suggested default cluster configuration includes a control plane pool
containing three m5.xlarge nodes and a worker pool containing four m5.2xlarge
nodes.

Consider the additional resource requirements for running the platform
services you want NKP to manage and ensure that your existing clusters comply.

To attach an existing EKS cluster, see EKS Cluster Attachment on page 480.

To attach an existing GKE cluster, see GKE Cluster Attachment on page 488.

##### Requirements for Attaching Clusters with an Existing cert-manager

Installation

If you are attaching clusters that already have cert-manager installed, the
cert-manager HelmRelease provided by NKP will fail to deploy, due to the
existing cert-manager installation. As long as the pre-existing cert-manager
functions as expected, you can ignore this failure. It will have no impact on
the operation of the cluster.

#### Creating a kubeconfig File for Attachment

About this task

If you already have a kubeconfig file to attach your cluster, go directly to
Attaching a Cluster with No Networking Restrictions on page 478 or Cluster
Attachment with Networking Restrictions on page 492

The kubeconfig files generated from existing clusters are not usable pre-built
because they call provisioner-specific CLI commands (like aws commands) and
use locally-obtained authentication tokens that are not compatible with NKP.
Having a separate service account also allows you to have a dedicated identity
for all NKP operations.

To get started, ensure you have kubectl set up and configured with
ClusterAdmin for the cluster you want to connect to Kommander.

Procedure

1. Create the necessary service account.

```bash
kubectl -n kube-system create serviceaccount kommander-cluster-admin
```

1. Create a token secret for the serviceaccount:

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

1. Verify that the serviceaccount token is ready by running the kubectl -n
   kube-system get secret

kommander-cluster-admin-sa-token -oyaml command. Verify that the data.token
field is populated. The output should be similar to this example:

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
export -p USER_TOKEN_VALUE CURRENT_CONTEXT CURRENT_CLUSTER CLUSTER_CA CLUSTER_SERVER
```

1. Generate a kubeconfig file that uses the environment variable values from
   the previous step.

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

Use this kubeconfig to:

##### Attaching a Cluster with No Networking Restrictions

- Cluster Attachment with Networking Restrictions on page 492

```yaml
Note: If a cluster has limited resources to deploy all the federated platform services, it will fail to stay attached to the
NKP UI. If this happens, check if any pods are not getting the resources required.
```

#### Cluster Attachment without Networking Restrictions

Use this option when you need to attach a cluster that does not require
additional access information. You can attach existing Kubernetes clusters to
the Management Cluster. After attaching the cluster, you can use the UI to
examine and manage this cluster.

##### Attaching a Cluster with No Networking Restrictions (2)

About this task

Using the Add Cluster option, you can attach an existing Kubernetes or NKP
cluster directly to NKP. This enables you to access the multi-cluster
management and monitoring benefits that NKP provides, while keeping your
existing cluster on its current provider and infrastructure.

Use this option when you want to attach a cluster that does not require
additional access information.

Procedure

1. From the top menu bar, select your target workspace.
2. On the Dashboard page, select the Add Cluster option in the Actions
   dropdown menu at the top right.
3. Select Attach Cluster.
4. Select the No additional networking restrictions card. Alternatively, if
   you must use network restrictions, perform the steps in Cluster Attachment
   with Networking Restrictions on page 492.
5. In the Cluster Configuration section, paste your kubeconfig file into the
   field, or select Upload kubeconfig File to specify the file.
6. The Cluster Name field will automatically populate with the name of the
   cluster is in the kubeconfig. You can edit this field with the name you want
   for your cluster.
7. The Context select list is populated from the kubeconfig. Select the
   desired context with admin privileges from the Context select list.
8. Add labels to classify your cluster as needed.
9. Select Create to attach your cluster.

##### Attaching a Cluster with No Networking Restrictions Through the CLI

Use the NKP CLI to attach an existing Kubernetes cluster to your Management
Cluster when the attached cluster requires no additional networking
restrictions.

About this task

Use the nkp attach cluster command to attach an existing Kubernetes or NKP
cluster to NKP directly from the command line. This enables you to access the
multi-cluster management and monitoring benefits that NKP provides, while
keeping your existing cluster on its current provider and infrastructure.

Use this option when you want to attach a cluster that does not require
additional access information.

Procedure

1. Ensure your kubeconfig file for the cluster you want to attach is ready. If
   you need to create one, see Creating a kubeconfig File for Attachment on
   page 476.
2. Point KUBECONFIG to the Management Cluster's kubeconfig file.

```bash
export KUBECONFIG=<management-cluster-kubeconfig>
```

1. Attach the cluster to the target workspace by running the nkp attach
   cluster command.

```bash
nkp attach cluster \
--name <cluster-name> \
--attached-kubeconfig <path-to-kubeconfig> \
--workspace <workspace-name>
```

Where:

- --name: The name to assign the attached cluster in NKP.
- --attached-kubeconfig: The path to the kubeconfig file of the cluster you
  want to attach (created in the previous step).
- --workspace: The name of the workspace where you want to attach the cluster.

1. Confirm the attachment status.

```bash
kubectl get kommanderclusters -A
```

It might take a few minutes for the cluster to reach the Joined status.

What to do next

After the cluster reaches the Joined status, see Accessing a Managed or
Attached Cluster on page 519 to access the attached cluster from the NKP UI.

```yaml
Note: If a cluster has limited resources to deploy all the federated platform services, it will fail to stay attached to the
NKP UI. If this happens, ensure your system has sufficient resources for all pods.
```

##### EKS Cluster Attachment

Attach an existing EKS cluster

You can attach existing Kubernetes clusters to the Management Cluster. After
attaching the cluster, you can use the UI to examine and manage this cluster.
The following procedure shows how to attach an existing Amazon Elastic
Kubernetes Service (EKS) cluster.

Related Information: For information on related topics or procedures, see:

- `<https://aws.amazon.com/eks/>`
- EKS Infrastructure on page 824
- Installing Kommander in a Non-Air-gapped Environment on page 984
- Cluster Management on page 458

###### EKS: Preparing the Cluster

About this task

This procedure requires the following items and configurations:

This procedure assumes you have an existing and spun-up Amazon EKS cluster(s)
with administrative privileges. For more information, see the Amazon for setup
and configuration information, see `<https://aws.amazon.com/eks/>`.

- A fully configured and running Amazon EKS cluster with administrative
  privileges.
- The current version NKP Ultimate is on your cluster.
- Ensure you have installed kubectl in your Management cluster.
- Attach Amazon EKS Clusters. Ensure that the KUBECONFIG environment variable
  is set to the Management cluster before attaching by running:

```bash
export KUBECONFIG=<Management_cluster_kubeconfig>.conf
```

Ensure you have access to your EKS clusters.

Procedure

Ensure you are connected to your EKS clusters. Enter the following commands
for each of your clusters.

```bash
kubectl config get-contexts
kubectl config use-context <context for first eks cluster>
```

Confirm kubectl can access the EKS cluster:

```bash
kubectl get nodes
```

###### EKS: Creating a kubeconfig File

Create a kubeconfig file for your EKS cluster

About this task

To get started, ensure you have kubectl set up and configured with
ClusterAdmin for the cluster you want to connect to Kommander. Create the
necessary service account:

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

###### EKS: Finalizing Attaching the Cluster Through the UI

About this task

Now that you have kubeconfig file, go to the NKP UI and follow these steps
below:

Procedure

1. From the top menu bar, select your target workspace.
2. On the Dashboard page, select the Add Cluster option in the Actions
   dropdown menu at the top right.
3. Select Attach Cluster.
4. Select the No additional networking restrictions card. Alternatively, if
   you must use network restrictions, follow the steps in Cluster Attachment
   with Networking Restrictions on page 492.
5. Upload the kubeconfig file you created in the previous section (or copy its
   contents) into the Cluster Configuration section.
6. The Cluster Name field automatically populates with the name of the cluster
   in the kubeconfig file. You can edit this field using the name you want for
   your cluster.
7. Add labels to classify your cluster as needed.
8. Select Create to attach your cluster.

```yaml
Note: If a cluster has limited resources to deploy all the federated platform services, it will fail to stay attached to
the NKP UI. If this happens, ensure your system has sufficient resources for all pods.
```

Related Information:

###### EKS: Finalizing Attaching the Cluster Through the CLI

Use the NKP CLI to attach your Amazon EKS cluster to your Management Cluster.

About this task

Now that you have the kubeconfig file, use the nkp attach cluster command to
attach your Amazon EKS cluster to NKP from the command line.

Procedure

1. Ensure the kubeconfig file you created in EKS: Creating a kubeconfig File
   on page 480 is available on your local system.
2. Point KUBECONFIG to the Management Cluster's kubeconfig file.

```bash
export KUBECONFIG=<management-cluster-kubeconfig>
```

1. Attach the EKS cluster to the target workspace by running the nkp attach
   cluster command.

```bash
nkp attach cluster \
--name <cluster-name> \
--attached-kubeconfig <path-to-kubeconfig> \
--workspace <workspace-name>
```

Where:

- --name: The name to assign the attached cluster in NKP.
- --attached-kubeconfig: The path to the kubeconfig file of the EKS cluster
  you want to attach (created in the previous section).
- --workspace: The name of the workspace where you want to attach the cluster.

1. Confirm the attachment status.

```bash
kubectl get kommanderclusters -A
```

It might take a few minutes for the cluster to reach the Joined status.

What to do next

After the cluster reaches the Joined status, see Accessing a Managed or
Attached Cluster on page 519 to access the attached cluster from the NKP UI.

```yaml
Note: If a cluster has limited resources to deploy all the federated platform services, it will fail to stay attached to the
NKP UI. If this happens, ensure your system has sufficient resources for all pods.
```

##### AKS Cluster Attachment

Attach an existing AKS cluster

You can attach existing Kubernetes clusters to the Management Cluster. After
attaching the cluster, you can use the UI to examine and manage this cluster.
The following procedure shows how to attach an existing Azure Kubernetes
Service (AKS) cluster.

Related Information: For information on related topics or procedures, see:

- AKS Infrastructure on page 940
- Kommander Installation Based on Your Environment on page 979
- Cluster Management on page 458

###### AKS: Preparing the Cluster

About this task

This procedure requires the following items and configurations:

- A fully configured and running Azure AKS cluster with administrative
  privileges.
- The current version NKP Ultimate is installed on your cluster.
- Ensure you have installed kubectl in your Management cluster.
- Attach AKS Clusters. Ensure that the KUBECONFIG environment variable is set
  to the Management cluster before attaching by running:

```bash
export KUBECONFIG=<Management_cluster_kubeconfig>.conf
```

- Ensure you have access to your AKS clusters.

```yaml
Note: This procedure assumes you have an existing and spun-up Azure AKS cluster(s) with administrative privileges.
For information on the Azure AKS for setup and configuration, see https://azure.microsoft.com/en-us/
products/kubernetes-service/.
```

Procedure

1. Enter the following commands for each of your clusters.

```bash
kubectl config get-contexts
kubectl config use-context <context for first AKS cluster>
```

1. Confirm kubectl can access the AKS cluster.

```bash
kubectl get nodes
```

###### AKS: Creating a kubeconfig File

Create a kubeconfig file for your AKS cluster

About this task

To get started, ensure you have kubectl set up and configured with
ClusterAdmin for the cluster you want to connect to Kommander. Create the
necessary service account:

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

Verify that the data.token field is populated. The output must be similar to
this:

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

###### AKS: Finalizing Attaching the Cluster Through the UI

About this task

Now that you have kubeconfig file, go to the NKP UI and follow these steps
below:

Procedure

1. From the top menu bar, select your target workspace.
2. On the Dashboard page, select the Add Cluster option in the Actions
   dropdown menu at the top right.
3. Select Attach Cluster.
4. Select the No additional networking restrictions card. Alternatively, if
   you must use network restrictions, follow the steps in Cluster Attachment
   with Networking Restrictions on page 492.
5. Upload the kubeconfig file you created in the previous section (or copy its
   contents) into the Cluster Configuration section.
6. The Cluster Name field automatically populates with the name of the cluster
   in the kubeconfig file. You can edit this field using the name you want for
   your cluster.
7. Add labels to classify your cluster as needed.
8. Select Create to attach your cluster.

```yaml
Note: If a cluster has limited resources to deploy all the federated platform services, it will fail to stay attached in
the NKP UI. If this happens, ensure your system has sufficient resources for all pods.
```

###### AKS: Finalizing Attaching the Cluster Through the CLI

Use the NKP CLI to attach your Azure AKS cluster to your Management Cluster.

About this task

Now that you have the kubeconfig file, use the nkp attach cluster command to
attach your Azure AKS cluster to NKP from the command line.

Procedure

1. Ensure the kubeconfig file you created in AKS: Creating a kubeconfig File
   on page 485 is available on your local system.
2. Point KUBECONFIG to the kubeconfig file of the management cluster.

```bash
export KUBECONFIG=<management-cluster-kubeconfig>
```

1. Attach the AKS cluster to the target workspace by running the nkp attach
   cluster command.

```bash
nkp attach cluster \
--name <cluster-name> \
--attached-kubeconfig <path-to-kubeconfig> \
--workspace <workspace-name>
```

Where:

- --name: The name to assign the attached cluster in NKP.
- --attached-kubeconfig: The path to the kubeconfig file of the AKS cluster
  you want to attach (created in the previous section).
- --workspace: The name of the workspace where you want to attach the cluster.

1. Confirm the attachment status.

```bash
kubectl get kommanderclusters -A
```

It might take a few minutes for the cluster to reach the Joined status.

What to do next

After the cluster reaches the Joined status, see Accessing a Managed or
Attached Cluster on page 519 to access the attached cluster from the NKP UI.

```yaml
Note: If a cluster has limited resources to deploy all the federated platform services, it will fail to stay attached in the
NKP UI. If this happens, ensure your system has sufficient resources for all pods.
```

##### GKE Cluster Attachment

Attach an existing GKE cluster in NKP.

You can attach existing Kubernetes clusters to the Management Cluster. After
attaching the cluster, you can use the UI to examine and manage this cluster.
The following procedure shows how to attach an existing Google Kubernetes
Engine (GKE) cluster.

Related Information: For information on related topics or procedures, see:

- Kommander Installation Based on Your Environment on page 979
- Cluster Management on page 458

###### GKE: Preparing the Cluster

About this task

This procedure requires the following items and configurations:

- A fully configured and running with a GKE cluster supported Kubernetes
  version cluster with administrative privileges.
- The current version NKP Ultimate is installed on your cluster.
- Ensure you have installed kubectl in your Management cluster.

> **Note: This procedure assumes you have an existing and spun-up GKE
> cluster with administrator privileges.**

- Attach GKE Clusters.
- Ensure you have access to your GKE clusters.
- Confirm kubectl can access the GKE cluster.

Procedure

1. Enter the following commands for each of your clusters.

```bash
kubectl config get-contexts
kubectl config use-context <context for first gcloud cluster>
```

1. Confirm kubectl can access the GKE cluster.

```bash
kubectl get nodes
```

###### GKE: Creating a kubeconfig File

Create a kubeconfig file for your GKE cluster

About this task

To get started, ensure you have kubectl set up and configured with
ClusterAdmin for the cluster you want to connect to Kommander.

```yaml
Caution: Nutanix support is unable to recover forgotten credentials. The following best practices will prevent
Kommander UI lockouts.
```

- Backup the kubeconfig file.
- Save your credentials.
- Configure an IDP (identity provider) instead of using a username and
  password credentials.

Create the necessary service account:

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

###### GKE: Finalizing Attaching the Cluster Through the UI

About this task

Now that you have the kubeconfig file, go to the NKP UI and follow these steps
below:

Procedure

1. From the top menu bar, select your target workspace.
2. On the Dashboard page, select the Add Cluster option in the Actions
   dropdown menu at the top right.
3. Select Attach Cluster.
4. Select the No additional networking restrictions card. Alternatively, if
   you must use network restrictions, follow the steps in Cluster Attachment
   with Networking Restrictions on page 492.
5. Upload the kubeconfig file you created in the previous section (or copy its
   contents) into the Cluster Configuration section.
6. The Cluster Name field automatically populates with the name of the cluster
   in the kubeconfig file. You can edit this field using the name you want for
   your cluster.
7. Add labels to classify your cluster as needed.
8. Select Create to attach your cluster.

```yaml
Note: If a cluster has limited resources to deploy all the federated platform services, it will fail to stay attached to
the NKP UI. If this happens, ensure your system has sufficient resources for all pods.
```

###### GKE: Finalizing Attaching the Cluster Through the CLI

Use the NKP CLI to attach your Google GKE cluster to your Management Cluster.

About this task

Now that you have the kubeconfig file, use the nkp attach cluster command to
attach your Google GKE cluster to NKP from the command line.

Procedure

1. Ensure the kubeconfig file you created in GKE: Creating a kubeconfig File
   on page 489 is available on your local system.
2. Point KUBECONFIG to the Management Cluster's kubeconfig file.

```bash
export KUBECONFIG=<management-cluster-kubeconfig>
```

1. Attach the GKE cluster to the target workspace by running the nkp attach
   cluster command.

```bash
nkp attach cluster \
--name <cluster-name> \
--attached-kubeconfig <path-to-kubeconfig> \
--workspace <workspace-name>
```

Where:

- --name: The name to assign the attached cluster in NKP.
- --attached-kubeconfig: The path to the kubeconfig file of the GKE cluster
  you want to attach (created in the previous section).
- --workspace: The name of the workspace where you want to attach the cluster.

1. Confirm the attachment status.

```bash
kubectl get kommanderclusters -A
```

It might take a few minutes for the cluster to reach the Joined status.

What to do next

After the cluster reaches the Joined status, see Accessing a Managed or
Attached Cluster on page 519 to access the attached cluster from the NKP UI.

```yaml
Note: If a cluster has limited resources to deploy all the federated platform services, it will fail to stay attached to the
NKP UI. If this happens, ensure your system has sufficient resources for all pods.
```

#### Cluster Attachment with Networking Restrictions

Configure the network-resrtricted cluster settings.

Need for a Secure Tunnel

When attaching a cluster to NKP, the Management cluster initiates an outbound
connection to the cluster you want to attach. This is not possible if the
cluster you want to attach (Managed or Attached) has networking restrictions
and is not exposed, for example, because it is in a private network or its API
is not accessible from the same network as the Management cluster. This is
what we call a network-restricted cluster.

Figure 11: Network-restricted Cluster

Tunneled Attachment Workflow

NKP can create a secure tunnel to enable the attachment of clusters that are
not directly reachable.

To create a secure tunnel, you must provide a configuration for the tunnel in
the cluster you want to attach. After you apply that configuration, the
cluster you want to attach will establish a secure tunnel with the Management
cluster and make an attachment request.

Figure 12: Secure Tunnel Attachment Workflow

After the attachment request is accepted and the connection between clusters
is established, both clusters will allow bilateral communication.

Figure 13: Connection Establishment of the Secure Tunnel Attachment

##### Prerequisites for a Tunneled Attachment

Before you enable the tunnel attachment, ensure to:

- Gain more understanding of this approach by reviewing Cluster Attachment
  with Networking Restrictions on page 492.
- Review the general requirements at Requirements for Attaching an Existing
  Cluster on page 474.
- Ensure that kubetunnel is deployed on the Management Cluster. Use the
  following command to check if kubetunnel is deployed:

```bash
kubectl get appdeployments.apps.kommander.d2iq.io -n kommander kubetunnel
```

The output should look similar to this:

```bash
NAME APP AGE
kubetunnel kubetunnel-<version> 5h14m
Note: Kubetunnel is deployed by default. If you need to install it manually, see Deploying Platform Applications
Using CLI on page 353 and ensure you install it on the Management cluster.
```

Table 48: Firewall Rules

Protocol HTTPS (TCP/443) and WebSocket

HTTPS (TCP/443) and WebSocket

Source Any Any node of the Attached or Managed cluster

Destination NKP Traefik Service External IP/ URL

NKP Traefik Service on the Management cluster

- Col1; The ingress rule on the Management cluster network must allow:; The
  egress rule on the Attached or Managed cluster private network must allow:

| --- | --- | --- |

Figure 14: Tunnel Attachment

##### UI: Attaching a Network-Restricted Cluster Using a Tunnel Through the UI

Use the UI to attach a network-restricted cluster.

Before you begin

Ensure you have reviewed and followed the steps in Prerequisites for a
Tunneled Attachment on page 494.

To attach a cluster:

Procedure

1. From the top menu bar, select your target workspace.
2. On the Dashboard page, select the Add Cluster option in the Actions
   dropdown menu at the top right.
3. Select Attach Cluster.
4. Select the Cluster has networking restrictions card to display the
   configuration page.
5. Establish the configuration parameters for the attachment: Enter the
   Cluster Name of the cluster you're attaching.
6. Create additional new Labels as needed.
7. Select the hostname that is the Ingress for the cluster from the Load
   Balancer Hostname dropdown menu. The hostname must match the Kommander Host
   cluster to which you are attaching your existing cluster with network
   restrictions.
8. Specify the URL Path Prefix for your Load Balancer Hostname. This URL path
   will serve as the prefix for the specific
   tunnel services you want to expose on the Kommander management cluster. If no
   value is specified, the value defaults to
   /nkp/tunnel. Kommander uses Traefik ingress, which requires the explicit
   definition of strip prefix middleware as a
   Kubernetes API object, as opposed to a simple annotation. Kommander provides
   default middleware that supports creating
   tunnels only on the /nkp/tunnel URL prefix. This is indicated by using the
   extra

annotation, traefik.ingress.kubernetes.io/router.middlewares: kommander-
stripprefixes- kubetunnel@kubernetescrd as shown in the code sample that
follows. If you want to expose a tunnel on a different URL prefix, you must
manage your own middleware configuration. 9. (Optional): Enter a value for the
Hostname field. 10. Provide a secret for your certificate in the Root CA
Certificate dropdown list.

a. For environments where the Management cluster uses a publicly-signed CA
(like ZeroSSL or Let's Encrypt), select Use Publicly Trusted CA.

b. If you manually created a secret in advance, select it from the dropdown
list.

c. For all other cases, select Create a new secret. Then, run the following
command on the Management cluster to obtain the caBundle key:

```bash
kubectl get nkpcluster -n kommander -l 'kommander.d2iq.io/host=true' -o
jsonpath='{.items[0].status.kommanderCluster.ingress.caBundle}'
```

Copy and paste the output into the Root CA Certificate field. 11. Add any
Extra Annotations as needed. 12. (Optional) Enable a Proxied Access: Activate
a proxied access to enable kubectl access and dashboard observability for the
network-restricted cluster from the Management cluster. For more information,
see Proxied Access to Network-Restricted Clusters on page 510 .

Select Show Advanced. 13. Add a Cluster Proxy Domain.

> **Note:**

- If you previously configured a domain wildcard for your cluster, a Cluster
  Proxy Domain is suggested automatically based on your cluster name. Replace
  the suggestion if you want to assign a different domain for the proxied
  cluster.
- If you want to use the external-dns service, specify a Cluster Proxy Domain
  that is within the zones specified in the --domain-filter argument of the
  external-dns deployment manifest stored on the Management cluster.

For example, if the filter is set to example.com, a possible domain for the
TUNNEL_PROXY_EXTERNAL_DOMAIN is myclusterproxy.example.com. 14. Establish a
DNS record and certificate configuration for the Cluster Proxy Domain. You can
choose between the default and a custom option.

Table 49: Table

Default settings: The Use default settings for proxy-access domain
Certificates and DNS checkbox is selected by default.

Automatic, handled by external- dns

Automatic, handled by kommander-ca

| Col1 | DNS record creation | Certificate Management |
| ---- | ------------------- | ---------------------- |

Custom settings:

Clear the Use default settings for proxy-access domain Certificates and DNS
checkbox.

Manually create a DNS record. The record's A/CNAME value must point to the
Management cluster's Traefik IP address, URL or domain.

OR

Enable external-dns with an annotation that points to the Cluster Proxy Domain.

Select an existing TLS certificate.

OR

Select an existing Issuer or ClusterIssuer. 15. Select Save & Generate
kubeconfig to generate a file required to finish attaching the cluster. A new
window appears with instructions on how to finalize attaching the cluster.

What to do next

##### UI: Finishing Attaching the Existing Cluster

How to apply the kubeconfig file to create the network tunnel to attach a
network-restricted cluster.

About this task

After you have configured your cluster's attachment in UI: Attaching a
Network-Restricted Cluster Using a Tunnel Through the UI on page 495, finalize
attaching the cluster. Now you must apply the generated manifest to create the
network tunnel and complete the attachment process:

Procedure

1. Select the Download Manifest link to download the file you generated
   previously.
2. Copy the kubectl apply command from the UI and paste it into your terminal
   session. Do not run it yet.
3. Ensure you substitute the actual name of the file for the variable. Also
   ensure you use the --

kubeconfig=`<managed_cluster_kubeconfig.conf>` flag to run the command on the
Attached or Managed cluster. Run the
command. Running this command starts the attachment process, which might take
several minutes to complete. The Cluster
details page is appears automatically when the cluster attachment process
completes. 4. (Optional) Select Verify
Connection to Cluster to send a request to Kommander to refresh the connection
information. You can use this option to
check to see if the connection is complete, though the Cluster Details page
displays automatically when the connection
is complete.

```yaml
Note: After the initial connection is made and your cluster becomes viewable as attached in the NKP UI, the
attachment, federated add-ons, and platform services will still need to be completed. This might take several
additional minutes. If a cluster has limited resources to deploy all the federated platform services, the installation
of the federated resources will fail, and the cluster may become unreachable in the NKP UI. If this happens, check
whether any pods are not getting the resources required.
```

What to do next

Using the Network-restricted Cluster on page 503

| Col1 | DNS record creation | Certificate Management |
| ---- | ------------------- | ---------------------- |

##### CLI: Attaching a Network-Restricted Cluster Using a Tunnel Through the CLI

Before you begin

Ensure you have reviewed and followed the steps in Prerequisites for a
Tunneled Attachment on page 494 before proceeding.

Procedure

1. Identify the Management Cluster Endpoint. Run the following command on the
   Management cluster to obtain the hostname and CA certificate.

```bash
hostname=$(kubectl get service -n kommander kommander-traefik -o go-template='{{with
index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}{{end}}')
b64ca_cert=$(kubectl get secret -n cert-manager kommander-ca -o=go-
template='{{index .data "tls.crt"}}')
```

1. Specify a Workspace Namespace

» Obtain the desired workspace namespace on the Management cluster for the
tunnel gateway:

```bash
namespace=$(kubectl get workspace default-workspace -o
jsonpath="{.status.namespaceRef.name}")
```

» Alternatively, you can create a new workspace instead of using an existing
workspace: Run the following command, and replace the `<workspace_name>` with
the new workspace name:

```bash
workspace=<workspace_name>
```

Finish creating the workspace:

```bash
namespace=${workspace}
cat > workspace.yaml <<EOF
apiVersion: workspaces.kommander.mesosphere.io/v1alpha1
kind: Workspace
metadata:
annotations:
kommander.mesosphere.io/display-name: ${workspace}
name: ${workspace}
spec:
namespaceName: ${namespace}
EOF
kubectl apply -f workspace.yaml
```

You can verify the workspace exists using:

```bash
kubectl get workspace ${workspace}
```

1. Create a Tunnel Gateway: Create a tunnel gateway on the Management cluster
   to listen for tunnel agents on remote clusters.

```yaml
Note: Kommander uses Traefik ingress, which requires explicit definition of strip prefix middleware as a
Kubernetes API object, as opposed to a simple annotation. Kommander provides default middleware that supports
creating tunnels only on the /nkp/tunnel URL prefix. This is indicated by using the extra annotation,
traefik.ingress.kubernetes.io/router.middlewares: kommander-stripprefixes-
kubetunnel@kubernetescrd
```

as shown in the code sample that follows. If you want to expose a tunnel on a
different URL prefix, you must manage your own middleware configuration.

a. Establish variables for the certificate secret and gateway. Replace the
`<gateway_name>` placeholder with the name of the gateway.

```bash
cacert_secret=kubetunnel-ca
gateway=<gateway_name>
```

b. Create the Secret and TunnelGateway objects.

```bash
cat > gateway.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
namespace: ${namespace}
name: ${cacert_secret}
data:
ca.crt:
${b64ca_cert}
---
apiVersion: kubetunnel.d2iq.io/v1alpha1
kind: TunnelGateway
metadata:
namespace: ${namespace}
name: ${gateway}
spec:
ingress:
caSecretRef:
namespace: ${namespace}
name: ${cacert_secret}
loadBalancer:
hostname: ${hostname}
urlPathPrefix: /nkp/tunnel
extraAnnotations:
kubernetes.io/ingress.class: kommander-traefik
traefik.ingress.kubernetes.io/router.tls: "true"
traefik.ingress.kubernetes.io/router.middlewares: kommander-stripprefixes-
kubetunnel@kubernetescrd
EOF
kubectl apply -f gateway.yaml
```

c. You can verify the gateway exists using the command.

```bash
kubectl get tunnelgateway -n ${namespace} ${gateway}
```

##### CLI: Creating a Tunnel Connector

Connect a remote, edge, or network-restricted cluster

About this task

Create a tunnel connector on the Management cluster for the remote cluster.

Procedure

1. Establish a variable for the connector. Provide the name of the connector,
   by replacing the `<connector_name>` placeholder:

```bash
connector=<connector_name>
```

1. Create the TunnelConnector object.

```bash
cat > connector.yaml <<EOF
apiVersion: kubetunnel.d2iq.io/v1alpha1
kind: TunnelConnector
metadata:
namespace: ${namespace}
name: ${connector}
spec:
gatewayRef:
name: ${gateway}
EOF
kubectl apply -f connector.yaml
```

After you create the TunnelConnector object, NKP creates a manifest.yaml. This
manifest.yaml contains the configuration information for the components
required by the tunnel for a specific cluster. 3. Verify the connector exists.

```bash
kubectl get tunnelconnector -n ${namespace} ${connector}
```

1. Wait for the tunnel connector to reach the Listening state and export the
   agent manifest.

```bash
while [ "$(kubectl get tunnelconnector -n ${namespace} ${connector} -o
jsonpath="{.status.state}")" != "Listening" ]
do
sleep 5
done
manifest=$(kubectl get tunnelconnector -n ${namespace} ${connector} -o
jsonpath="{.status.tunnelAgent.manifestsRef.name}")
while [ -z ${manifest} ]
do
sleep 5
manifest=$(kubectl get tunnelconnector -n ${namespace} ${connector} -o
jsonpath="{.status.tunnelAgent.manifestsRef.name}")
done
```

The manifest.yaml is applied successfully after the command completes. 5.
Fetch the manifest.yaml to use it in the following section.

```bash
kubectl get secret -n ${namespace} ${manifest} -o jsonpath='{.data.manifests\.yaml}'
| base64 -d > manifest.yaml
Note: When attaching several clusters, ensure that you fetch the manifest.yaml of the cluster you are
attempting to attach. Using the wrong combination of manifest.yaml and cluster will cause the attachment to
fail.
```

##### CLI: Setting Up the Network-restricted Cluster

About this task

In the following commands, the --kubeconfig flag ensures that you set the
context to the Attached or Managed cluster. For alternatives and
recommendations around setting your context, see Commands within a kubeconfig
File on page 31.

Procedure

1. Apply the manifest.yaml file to the Attached or Managed cluster and deploy
   the tunnel agent.

```bash
kubectl apply --kubeconfig=<managed_cluster_kubeconfig.conf> -f manifest.yaml
```

1. Check the status of the created pods using:

```bash
kubectl get pods --kubeconfig=<managed_cluster_kubeconfig.conf> -n kubetunnel
```

After a short time, expect to see a post-kubeconfig pod that reaches Completed
state and a tunnel-agent pod that stays in Running state.

```bash
NAME READY STATUS RESTARTS AGE
post-kubeconfig-j2ghk 0/1 Completed 0 14m
tunnel-agent-f8d9f4cb4-thx8h 1/1 Running 0 14m
```

##### CLI: Adding the Network-restricted Cluster Into Kommander

When you create a cluster using the NKP CLI, it does not attach automatically.

About this task

Procedure

1. On the Management cluster, wait for the tunnel to be connected by the
   tunnel agent.

```bash
while [ "$(kubectl get tunnelconnector -n ${namespace} ${connector} -o
jsonpath="{.status.state}")" != "Connected" ]
do
sleep 5
done
```

1. Establish variables for the managed cluster. Replace the
   `<private_cluster>` placeholder with the name of the managed cluster:

```bash
managed=<private-cluster>
display_name=${managed}
```

1. Update the KommanderCluster object:

```bash
cat > kommander.yaml <<EOF
apiVersion: kommander.mesosphere.io/v1beta1
kind: KommanderCluster
metadata:
namespace: ${namespace}
name: ${managed}
annotations:
kommander.mesosphere.io/display-name: ${display_name}
spec:
clusterTunnelConnectorRef:
name: ${connector}
EOF
kubectl apply -f kommander.yaml
```

1. Wait for the Attached or Managed cluster to join.

```bash
while [ "$(kubectl get kommandercluster -n ${namespace} ${managed} -o
jsonpath='{.status.phase}')" != "Joined" ]
do
sleep 5
done
kubefed=$(kubectl get kommandercluster -n ${namespace} ${managed} -o
jsonpath="{.status.kubefedclusterRef.name}")
while [ -z "${kubefed}" ]
do
sleep 5
kubefed=$(kubectl get kommandercluster -n ${namespace} ${managed} -o
jsonpath="{.status.kubefedclusterRef.name}")
done
kubectl wait --for=condition=ready --timeout=60s kubefedcluster -n kube-federation-
system ${kubefed}
```

After the command is executed, your cluster becomes visible in the NKP UI, and
you can start using it. Its metrics will be accessible through different
dashboards, such as Grafana, Karma, etc.

##### CLI: Creating a Network Policy for the Tunnel Server

About this task

This step is optional but improves security by restricting which remote hosts
can connect to the tunnel.

Procedure

1. Apply a network policy that restricts tunnel access to specific namespaces
   and IP blocks. The following example permits connections from:

- Pods running in the kommander and kube-federation-system namespace.
- Remote clusters with IP addresses in the ranges 192.0.2.0 to 192.0.2.255 and
  203.0.113.0 to 203.0.113.255.
- Pods running in namespaces with a label kubetunnel.d2iq.io/networkpolicy
  that match the tunnel name and namespace.

```bash
cat > net.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
namespace: ${namespace}
name: ${connector}-deny
labels:
kubetunnel.d2iq.io/tunnel-connector: ${connector}
kubetunnel.d2iq.io/networkpolicy-type: "tunnel-server"
spec:
podSelector:
matchLabels:
kubetunnel.d2iq.io/tunnel-connector: ${connector}
policyTypes:
- Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
namespace: ${namespace}
name: ${connector}-allow
labels:
kubetunnel.d2iq.io/tunnel-connector: ${connector}
kubetunnel.d2iq.io/networkpolicy-type: "tunnel-server"
spec:
podSelector:
matchLabels:
kubetunnel.d2iq.io/tunnel-connector: ${connector}
policyTypes:
- Ingress
ingress:
- from:
- namespaceSelector:
matchLabels:
kubernetes.io/metadata.name: "kube-federation-system"
- namespaceSelector:
matchLabels:
kubernetes.io/metadata.name: "kommander"
- namespaceSelector:
matchLabels:
kubetunnel.d2iq.io/networkpolicy: ${connector}-${namespace}
- ipBlock:
cidr: 192.0.2.0/24
- ipBlock:
cidr: 203.0.113.0/24
EOF
kubectl apply -f net.yaml
```

1. To enable applications running in another namespace to access the attached
   cluster, add the label

kubetunnel.d2iq.io/networkpolicy=${connector}-${namespace} to the target
namespace.

```bash
kubectl label ns ${namespace} kubetunnel.d2iq.io/networkpolicy=${connector}-
${namespace}
```

All pods in the target namespace can now reach the attached cluster services.

What to do next

- (Optional): If you want to access the network-restricted attached cluster
  from the Management cluster, Enabling Proxied Access Using the CLI
  (Prerequisites and Preparing the Environment) on page 512

##### Using the Network-restricted Cluster

About this task

To access services running on the remote, edge, or network-restricted cluster
from the Management cluster, connect to the tunnel proxy.

Procedure

1. You can use these three methods.

» If the client program supports the use of a kubeconfig file, use the
network-restricted cluster's kubeconfig.

» If the client program supports SOCKS5 proxies, use the proxy directly.

» Otherwise, deploy a proxy server on the Management cluster. 2. Network-
restricted Cluster Service: These sections require a service to run on the
Attached or Managed network-restricted cluster. As an example, start the
following service.

```bash
service_namespace=test
service_name=webserver
service_port=8888
service_endpoint=${service_name}.${service_namespace}.svc.cluster.local:
${service_port}
cat > nginx.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
name: ${service_namespace}
---
apiVersion: apps/v1
kind: Deployment
metadata:
namespace: ${service_namespace}
name: nginx-deployment
labels:
app: nginx-deployment
spec:
replicas: 3
selector:
matchLabels:
app: nginx-app
template:
metadata:
labels:
app: nginx-app
spec:
containers:
- name: nginx
image: nginx:1.14.2
ports:
- containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
namespace: ${service_namespace}
name: ${service_name}
spec:
selector:
app: nginx-app
type: ClusterIP
ports:
- targetPort: 80
port: ${service_port}
EOF
kubectl apply -f nginx.yaml
kubectl rollout status deploy -n ${service_namespace} nginx-deployment
```

On the Attached or Managed cluster, a client Job can access this service using.

```bash
cat > curl.yaml <<EOF
apiVersion: batch/v1
kind: Job
metadata:
name: curl
spec:
template:
spec:
containers:
- name: curl
image: curlimages/curl:7.76.0
command: ["curl", "--silent", "--show-error", "http://${service_endpoint}"]
restartPolicy: Never
backoffLimit: 4
EOF
kubectl apply -f curl.yaml
kubectl wait --for=condition=complete job curl
podname=$(kubectl get pods --selector=job-name=curl --field-
selector=status.phase=Succeeded -o jsonpath='{.items[0].metadata.name}')
kubectl logs ${podname}
```

The final command returns the default Nginx web page.

```bash
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
body {
width: 35em;
margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif;
}
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>
<p>For online documentation and support, see
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>
<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

What to do next

(Optional): If you want to manage the attached cluster from the Management
cluster, Enabling Proxied Access Using the UI on page 510.

###### Using kubeconfig File

About this task

This is primarily useful for running kubectl commands on the Management
cluster to monitor the network- restricted, Managed or Attached cluster.

On the Management cluster, a kubeconfig file for the Attached or Managed
cluster configured to use the tunnel proxy is available as a Secret.

Procedure

1. The Secret's name can be identified using.

```bash
kubeconfig_secret=$(kubectl get tunnelconnector -n ${namespace} ${connector} -o
jsonpath='{.status.kubeconfigRef.name}')
```

1. After setting service_namespace and service_name to the service resource,
   run this command on the Management cluster.

```bash
cat > get-service.yaml <<EOF
apiVersion: batch/v1
kind: Job
metadata:
name: get-service
spec:
template:
spec:
containers:
- name: kubectl
image: bitnami/kubectl:1.19
command: ["kubectl", "get", "service", "-n", "${service_namespace}",
"${service_name}"]
env:
- name: KUBECONFIG
value: /tmp/kubeconfig/kubeconfig
volumeMounts:
- name: kubeconfig
mountPath: /tmp/kubeconfig
volumes:
- name: kubeconfig
secret:
secretName: "${kubeconfig_secret}"
restartPolicy: Never
backoffLimit: 4
EOF
kubectl apply -n ${namespace} -f get-service.yaml
kubectl wait --for=condition=complete --timeout=5m job -n ${namespace} get-service
podname=$(kubectl get pods -n ${namespace} --selector=job-name=get-service --field-
selector=status.phase=Succeeded -o jsonpath='{.items[0].metadata.name}')
kubectl logs -n ${namespace} ${podname}
```

###### Using SOCKS5 Proxy Directly

Procedure

1. To use the SOCKS5 proxy directly, obtain the SOCKS5 proxy endpoint using.

```bash
proxy_service=$(kubectl get tunnelconnector -n ${namespace} ${connector} -o
jsonpath='{.status.tunnelServer.serviceRef.name}')
socks_proxy=$(kubectl get service -n ${namespace} "${proxy_service}" -o
jsonpath='{.spec.clusterIP}{":"}{.spec.ports[?(@.name=="proxy")].port}')
```

1. Provide the value of ${socks_proxy} as the SOCKS5 proxy to your client. For
   example, since curl supports SOCKS5 proxies, the Attached or Managed service
   started above can be accessed from the Management cluster by adding the
   SOCKS5 proxy to the curl command. After setting service_endpoint to the
   service endpoint, on the Management cluster run.

```bash
cat > curl.yaml <<EOF
apiVersion: batch/v1
kind: Job
metadata:
name: curl
spec:
template:
spec:
containers:
- name: curl
image: curlimages/curl:7.76.0
command: ["curl", "--silent", "--show-error", "--socks5-hostname",
"${socks_proxy}", "http://${service_endpoint}"]
restartPolicy: Never
backoffLimit: 4
EOF
kubectl apply -f curl.yaml
kubectl wait --for=condition=complete --timeout=5m job curl
podname=$(kubectl get pods --selector=job-name=curl --field-
selector=status.phase=Succeeded -o jsonpath='{.items[0].metadata.name}')
kubectl logs ${podname}
```

The final command returns the same output as for the job on the Attached or
Managed cluster, demonstrating that the job on the Management cluster accessed
the service running on the Attached or Managed cluster.

###### Using Deployed Proxy on Management Cluster

Procedure

1. To deploy a proxy on the Management cluster, obtain the SOCKS5 proxy
   endpoint using.

```bash
proxy_service=$(kubectl get tunnelconnector -n ${namespace} ${connector} -o
jsonpath='{.status.tunnelServer.serviceRef.name}')
socks_proxy=$(kubectl get service -n ${namespace} "${proxy_service}" -o
jsonpath='{.spec.clusterIP}{":"}{.spec.ports[?(@.name=="proxy")].port}')
```

1. Provide the value of ${socks_proxy} as the SOCKS5 proxy to a proxy deployed
   on the Management cluster. After setting service_endpoint to the service
   endpoint, on the Management cluster run.

```bash
cat > nginx-proxy.yaml <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
name: nginx-proxy-crt
spec:
secretName: nginx-proxy-crt-secret
dnsNames:
- nginx-proxy-service.${namespace}.svc.cluster.local
issuerRef:
group: cert-manager.io
kind: ClusterIssuer
name: kubernetes-ca
---
apiVersion: apps/v1
kind: Deployment
metadata:
name: nginx-proxy
labels:
app: nginx-proxy-deployment
spec:
replicas: 1
selector:
matchLabels:
app: nginx-proxy-app
template:
metadata:
labels:
app: nginx-proxy-app
spec:
containers:
- name: nginx-proxy
image: mesosphere/ghostunnel:v1.5.3-server-backend-proxy
args:
- "server"
- "--listen=:443"
- "--target=${service_endpoint}"
- "--cert=/etc/certs/tls.crt"
- "--key=/etc/certs/tls.key"
- "--cacert=/etc/certs/ca.crt"
- "--unsafe-target"
- "--disable-authentication"
env:
- name: ALL_PROXY
value: socks5://${socks_proxy}
ports:
- containerPort: 443
volumeMounts:
- name: certs
mountPath: /etc/certs
volumes:
- name: certs
secret:
secretName: nginx-proxy-crt-secret
---
apiVersion: v1
kind: Service
metadata:
name: nginx-proxy-service
spec:
selector:
app: nginx-proxy-app
type: ClusterIP
ports:
- targetPort: 443
port: 8765
EOF
kubectl apply -n ${namespace} -f nginx-proxy.yaml
kubectl rollout status deploy -n ${namespace} nginx-proxy
proxy_port=$(kubectl get service -n ${namespace} nginx-proxy-service -o
jsonpath='{.spec.ports[0].port}')
```

1. Any client running on the Management cluster can now access the service
   running on the Attached or Managed cluster using the proxy service endpoint.
   Note that the curl job runs in the same namespace as the proxy to provide
   access to the CA certificate secret.

```bash
cat > curl.yaml <<EOF
apiVersion: batch/v1
kind: Job
metadata:
name: curl
spec:
template:
spec:
containers:
- name: curl
image: curlimages/curl:7.76.0
command:
- curl
- --silent
- --show-error
- --cacert
- /etc/certs/ca.crt
- https://nginx-proxy-service.${namespace}.svc.cluster.local:${proxy_port}
volumeMounts:
- name: certs
mountPath: /etc/certs
volumes:
- name: certs
secret:
secretName: nginx-proxy-crt-secret
restartPolicy: Never
backoffLimit: 4
EOF
kubectl apply -n ${namespace} -f curl.yaml
kubectl wait --for=condition=complete --timeout=5m job -n ${namespace} curl
podname=$(kubectl get pods -n ${namespace} --selector=job-name=curl --field-
selector=status.phase=Succeeded -o jsonpath='{.items[0].metadata.name}')
kubectl logs -n ${namespace} ${podname}
```

The final command returns the same output as the job on the Attached or
Managed cluster, demonstrating that the job on the Management cluster accessed
the service running on the network-restricted cluster.

##### Proxied Access to Network-Restricted Clusters

Enabling a proxied access allows you to access Attached and Managed clusters
that are network-restricted, in a private network, firewalled, or at the edge.

> **Note: This section only applies to clusters with networking restrictions
> that were attached through a secure tunnel**

You can attach clusters that are in a private network (clusters that have
networking restrictions or are at the edge). Nutanix provides the option of
using a secure tunnel or a tunneled attachment to attach a Kubernetes cluster
to the Management cluster. To access these attached clusters through kubectl
or monitor its resources through the Management cluster, you have to be in the
same network, or enable a proxied access.

Figure 15: Proxied Access

Enabling the proxied access for a network-restricted cluster makes it possible
for NKP to authenticate user requests (regardless of the identity provider)
through the Management cluster's authentication proxy. This is helpful,when
the cluster you are trying to reach is in a different network. The proxied
access allows you to:

- Access and observe the cluster's monitoring and logging services from the
  Management cluster, for example:
- Access the cluster's Grafana, Kubernetes, and OpenCost dashboards from the
  Management cluster.
- Use the CLI to print a cluster's service UR so that you can access the
  cluster's dashboards.
- Access and perform operations on the network-restricted cluster from the
  Management cluster, for example:
- Generate an API token (Generate Token option, from the upper right corner of
  the UI) that allows you to authenticate to the network-restricted cluster.
- Upon authentication, use kubectl to manage the network-restricted cluster.

You can perform the previous actions without being in the same network as the
network-restricted cluster.

##### Enabling Proxied Access Using the UI

Enable proxied access using the UI.

Procedure

For instructions on how to enable a proxied access while you attach a cluster
with the UI, see Cluster Attachment with Networking Restrictions on page 492.
If you attached your Kubernetes cluster to your NKP environment already, it is
not possible to enable the proxied access using the UI. Use the CLI as
explained in Enabling Proxied Access Using the CLI (Prerequisites and
Preparing the Environment) on page 512.

###### Configuring a Wildcard Domain for Your Proxied Cluster

About this task

Wildcard domains are helpful in multi-cluster environments. When you set up a
wildcard domain, every time you attach an additional network-restricted
cluster through a proxy, the NKP UI pre-fills a domain for the cluster
automatically.

After you set up a wildcard domain in the kommander.yaml as explained in the
following section, NKP will suggest domains for attached clusters
automatically based on the wildcard domain + the name of the cluster, for
example:

Procedure

Table 50: Wildcard Domain

\*.example.com development.cluster development.cluster.example.com

\*.example.com janedoe janedoe.example.com

To Set up a wildcard domain:

1. Open the kommander.yaml file.

a. If you have not installed the Kommander component yet, initialize the
configuration file, so you can edit it in the following steps.

> **Warning: Initialize this file only once. Otherwise, you will overwrite
> previous customizations.**

b. If you have installed the Kommander component already, open the existing
kommander.yaml with the editor of your choice. 2. Adjust the apps section of
your kommander.yaml file to include these values.

```yaml
apiVersion: config.kommander.mesosphere.io/v1alpha1
kind: Installation
apps:
[...]
kubetunnel:
enabled: true
values: |
proxiedAccess:
clusterDomainWildcard: "*.example.com"
```

1. Use the configuration file to install or update the Kommander component.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

Whenever you attach a network-restricted cluster, the UI will suggest a new
domain based on the wildcard domain and cluster name.

| Wildcard Domain | Cluster Name | Cluster Domain |
| --------------- | ------------ | -------------- |

1. Configure a DNS Record or DNS Service. The clusters will not be available
   through the established domain until you manually create a DNS record or
   enable external-dns to automatically manage the creation of records.

Nutanix recommends enabling the External DNS service to manage your records
automatically. However, you can choose to create your records manually.

##### Enabling Proxied Access Using the CLI (Prerequisites and Preparing the

Environment)

Enabling a proxied access allows you to access Attached and Managed clusters
that are network- restricted, in a private network, firewalled, or at the
edge.

About this task

This section only applies to clusters with networking restrictions that were
attached through a secure tunnel.

Before you begin

- You have attached a network-restricted cluster.
- The Management and network-restricted cluster are on the same NKP version.
- You have a domain that you can use to put on top of the network-restricted
  cluster's domain to redirect user requests (Cluster Proxy Domain).
- A DNS record to map your domain to your cluster. There are two supported
  options for this:
- Manual DNS record creation:

Create a DNS record manually. The record's A/CNAME value must point to the
Management cluster's Traefik IP address, URL, or domain. Use one record per
proxied cluster.

- Automatic DNS record creation:

A service that creates and maintains your DNS record automatically. For this
method, enable the external- dns service on the Management cluster before
configuring the proxy. For more information, see Configuring External DNS with
the CLI: Management or Pro Cluster on page 1010.

The following pages walk you through enabling the proxied access on the
network-restricted cluster. Establish the following environment variables on
the Management cluster. For more information on switching cluster contexts,
see Commands within a kubeconfig File on page 31.

The following commands allow you to run most commands without replacing the
information manually.

Procedure

1. Set the WORKSPACE_NAMESPACE environment variable to the name of your
   network-restricted cluster's workspace namespace.

```bash
export WORKSPACE_NAMESPACE=<workspace namespace>
```

1. Set the variable to the proxy domain through which your cluster should be
   available. TUNNEL_PROXY_EXTERNAL_DOMAIN=`<myclusterproxy.example.com>`

If you want to use the external-dns service, specify a
TUNNEL_PROXY_EXTERNAL_DOMAIN that is within the zones specified in the
--domain-filter argument of the external-dns deployment manifest stored on the
Management cluster.

For example, if the filter is set to example.com, a possible domain for the
TUNNEL_PROXY_EXTERNAL_DOMAIN is myclusterproxy.example.com. 3. Establish a
variable that points to the name of the network-restricted cluster. The name
of the network-restricted cluster is established in the KommanderCluster
object.

```bash
NETWORK_RESTRICTED_CLUSTER=<name_of_restricted_cluster>
```

1. Given that each cluster can only have one proxy domain, reuse the name of
   the network-restricted cluster for the proxy object.

```bash
TUNNEL_PROXY_NAME=${NETWORK_RESTRICTED_CLUSTER}
```

1. Obtain the name of the connector and set it to a variable.

```bash
TUNNEL_CONNECTOR_NAME=$(kubectl get kommandercluster -n
${WORKSPACE_NAMESPACE} ${NETWORK_RESTRICTED_CLUSTER} -o
template='{{ .spec.clusterTunnelConnectorRef.name }}')
```

###### Creating a TunnelProxy Object

Before you begin

Procedure

1. In the Management cluster, create a TunnelProxy object for your proxied
   cluster and assign it a unique domain. This domain forwards all user
   authentication requests through the Management cluster and is used to
   generate a URL that exposes the cluster's dashboards (clusterProxyDomain).
2. Do one of the following.

» To back the domain, you require both a certificate and a DNS record. If you
choose the default configuration, NKP will handle the certificate creation
(self-signed certificate), but you must create a DNS record manually.

» Alternatively, you can set up a different Certificate Authority to handle
the certificate creation and rotation for your domain. You can also set up the
external-dns service to automatically create a DNS record. 3. Here are some
examples of possible configuration combinations.

> **Note:**

- Ensure you set the required variables.
- Ensure you run the following commands on the Management cluster. For more
  information on switching cluster contexts, Commands within a kubeconfig File
  on page 31.
- Example 1: Example 1: Domain with Default Certificate and Automatic DNS
  Record Creation (Requires External DNS) on page 514
- Example 2: Example 2: Domain with Default Certificate and Default DNS Setup
  (Requires Manually-created DNS) on page 514
- Example 3: Example 3: Domain with Auto-generated ACME Certificate and
  Automatic DNS Record Creation (Requires External DNS) on page 514
- Example 4: Example 4: Domain with Custom Certificate (Requires Certificate
  Secret) and Automatic DNS Record Creation (Requires External DNS) on page
  515

Example 1: Domain with Default Certificate and Automatic DNS Record Creation
(Requires External DNS)

In this example, the following configuration applies:

- Certificate - The domain uses a self-signed certificate created by NKP.
- DNS record - The external-dns manages the creation of a DNS record
  automatically. For it to work, ensure you have enabled Configuring External
  DNS with the CLI: Management or Pro Cluster on page 1010.

```bash
cat > tunnelproxy.yaml <<EOF | kubectl apply -f -
apiVersion: kubetunnel.d2iq.io/v1alpha1
kind: TunnelProxy
metadata:
name: ${TUNNEL_PROXY_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
clusterProxyDomain: ${TUNNEL_PROXY_EXTERNAL_DOMAIN}
tunnelConnectorRef:
name: ${TUNNEL_CONNECTOR_NAME}
ingress:
annotations:
external-dns.alpha.kubernetes.io/hostname: ${TUNNEL_PROXY_EXTERNAL_DOMAIN}
EOF
```

The spec.ingress.annotations field contains the annotation required for DNS
record management. For more information, see DNS Record Creation with External
DNS on page 1010.

Example 2: Domain with Default Certificate and Default DNS Setup (Requires
Manually-created DNS)

In this example, the following configuration applies:

- Certificate - The domain uses a self-signed certificate created by NKP.
- DNS record - For the domain to be recognized by the cluster, ensure you
  manually create a DNS record. The record's A/CNAME value must point to the
  Management cluster's Traefik IP address, URL, or domain. Create a record per
  proxied cluster.

```bash
In this example, the following configuration applies:Certificate - The domain uses a
self-signed certificate created by NKP.DNS record - For the domain to be recognized by
the cluster, ensure you manually create a DNS record. The record's A/CNAME value must
point to the Management cluster's Traefik IP address, URL or domain. Create a record
per proxied cluster.cat > tunnelproxy.yaml <<EOF | kubectl apply -f -
apiVersion: kubetunnel.d2iq.io/v1alpha1
kind: TunnelProxy
metadata:
name: ${TUNNEL_PROXY_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
clusterProxyDomain: ${TUNNEL_PROXY_EXTERNAL_DOMAIN}
tunnelConnectorRef:
name: ${TUNNEL_CONNECTOR_NAME}
EOF
```

Example 3: Domain with Auto-generated ACME Certificate and Automatic DNS
Record Creation (Requires External DNS)

In this example, the following configuration applies:

- Certificate - The domain uses a cert-manager to enable an ACME-based
  Certificate Authority. This CA automatically issues and rotates your
  certificates. By default, NKP uses Let's Encrypt.
- DNS record -

The external-dns manages the creation of a DNS record automatically. For it to
work, ensure you have enabled Configuring External DNS with the CLI:
Management or Pro Cluster on page 1010.

1. Set the environment variable for your issuing object:

This can be a ClusterIssuer or Issuer. For more information, see Advanced
Configuration: ClusterIssuer on page 1007.

```bash
ISSUER_KIND=ClusterIssuer
```

1. Set the environment variable for your CA:

Replace letsEncrypt if you are using another ACME-based certificate authority.

```bash
ISSUER_NAME=letsEncrypt
```

1. Create the TunnelProxy:

```bash
cat > tunnelproxy.yaml <<EOF | kubectl apply -f -
apiVersion: kubetunnel.d2iq.io/v1alpha1
kind: TunnelProxy
metadata:
name: ${TUNNEL_PROXY_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
clusterProxyDomain: ${TUNNEL_PROXY_EXTERNAL_DOMAIN}
tunnelConnectorRef:
name: ${TUNNEL_CONNECTOR_NAME}
ingress:
annotations:
external-dns.alpha.kubernetes.io/hostname: ${TUNNEL_PROXY_EXTERNAL_DOMAIN}
certificate:
issuerRef:
kind: ${ISSUER_KIND}
name: ${ISSUER_NAME}
EOF
```

For more information, see DNS Record Creation with External DNS on page 1010.

Example 4: Domain with Custom Certificate (Requires Certificate Secret) and
Automatic DNS Record Creation (Requires External DNS)

In this example, the following configuration applies:

- Certificate - The domain uses a custom certificate created manually. Ensure
  you reference the `<certificate_secret_name>`.
- DNS record -

The external-dns manages the creation of a DNS record automatically. For it to
work, ensure you have enabled Configuring External DNS with the CLI:
Management or Pro Cluster on page 1010.

1. Set an environment variable for the name of your custom certificate.

For more information, see Configuring the Kommander Installation with a Custom
Domain and Certificate on page 1001.

```bash
CERTIFICATE_SECRET_NAME=<custom_certificate_secret_name>
```

1. (Optional): If you do not have a secret yet and want to create one pointing
   at the certificate, run the following command.

```bash
kubectl create secret tls ${CERTIFICATE_SECRET_NAME} -n ${WORKSPACE_NAMESPACE} --
key="tls.key" --cert="tls.crt"
```

1. Create the TunnelProxy:

```bash
cat > tunnelproxy.yaml <<EOF | kubectl apply -f -
apiVersion: kubetunnel.d2iq.io/v1alpha1
kind: TunnelProxy
metadata:
name: ${TUNNEL_PROXY_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
clusterProxyDomain: ${TUNNEL_PROXY_EXTERNAL_DOMAIN}
tunnelConnectorRef:
name: ${TUNNEL_CONNECTOR_NAME}
ingress:
annotations:
external-dns.alpha.kubernetes.io/hostname: ${TUNNEL_PROXY_EXTERNAL_DOMAIN}
certificate:
certificateSecretRef:
name: ${CERTIFICATE_SECRET_NAME}
EOF
```

For more information, see Configure Custom Domains or Custom Certificates post
Kommander Installation on page 539.

###### Enabling the TunnelProxy Object in KommanderCluster

Enable the TunnelProxy Object in KommanderCluster.

Before you begin

- Ensure to set the required variables as described in Enabling Proxied Access
  Using the CLI (Prerequisites and Preparing the Environment) on page 512 and
  create a TunnelProxy object as described in Creating a TunnelProxy Object on
  page 513 before you run the following commands.
- Ensure you run the following command on the Management cluster.

For more information on switching cluster contexts, see Commands within a
kubeconfig File on page 31.

To enable the TunnelProxy, reference the object in the KommanderCluster object:

Procedure

On the Management cluster, patch the KommanderCluster object with the name of
the TunnelProxy you created on the previous page.

```bash
kubectl patch --type merge kommanderclusters -n ${WORKSPACE_NAMESPACE}
${NETWORK_RESTRICTED_CLUSTER} --patch "{\"spec\": {\"kommanderCluster\": {\"spec\":
{\"clusterTunnelProxyConnectorRef\": { \"name\": \"${TUNNEL_PROXY_NAME}\"}}}"
```

###### Verifying the Proxy

Verify the proxy.

Before you begin

Ensure you run the following command on the Management cluster. For more
information around switching cluster contexts, see Commands within a
kubeconfig File on page 31.

On the Management cluster:

Procedure

1. Verify that the following conditions for the TunnelProxy configuration are
   met.

```bash
kubectl wait --for=condition=ClientAuthReady=true --timeout=300s -n
${WORKSPACE_NAMESPACE} tunnelproxy/${TUNNEL_PROXY_NAME}
kubectl wait --for=condition=ReverseProxyReady=true --timeout=300s -n
${WORKSPACE_NAMESPACE} tunnelproxy/${TUNNEL_PROXY_NAME}
kubectl wait --for=condition=available -n ${WORKSPACE_NAMESPACE} deploy -l control-
plane=${TUNNEL_PROXY_NAME}-kubetunnel-reverse-proxy-rp
```

The output should look like this.

```bash
tunnelproxy.kubetunnel.d2iq.io/test condition met
tunnelproxy.kubetunnel.d2iq.io/test condition met
deployment.apps/${TUNNEL_PROXY_NAME}-kubetunnel-reverse-proxy-rp condition met
```

1. Verify that the TunnelProxy is correctly assigned and connected to your
   cluster.

```bash
curl -Lk -s -o /dev/null -w "%{http_code}" https://${TUNNEL_PROXY_EXTERNAL_DOMAIN}/
nkp/grafana
```

The output should return a successful HTTP response status.

You can access the network-restricted cluster dashboards and use kubectl to
manage its resources from the Management cluster.

#### NKP-created Kubernetes Cluster

When you create a Managed Cluster with the NKP CLI, it attaches automatically
to the Management Cluster after a few moments.

If you have several Pro Clusters and want to turn one of them into a Managed
Cluster to be centrally administrated by a Management Cluster, refer to
Platform Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate
Managed Cluster on page 519

##### Attaching an NKP-created Cluster Using the CLI

About this task

```yaml
Note: These steps are only applicable if you do not set a WORKSPACE_NAMESPACE when creating a cluster. If you
already set a WORKSPACE_NAMESPACE, then you do not need to perform these steps since the cluster is already
attached to the workspace.
```

When you create a Managed Cluster with the NKP CLI, it attaches automatically
to the Management Cluster after a few moments.

However, if you do not set a workspace, the attached cluster will be created
in the default workspace. To ensure that the attached cluster is created in
your desired workspace namespace, follow these instructions:

Procedure

1. Confirm you have your MANAGED_CLUSTER_NAME variable set with the following
   command:

```bash
echo ${MANAGED_CLUSTER_NAME}
```

1. Retrieve your kubeconfig from the cluster you have created without setting
   a workspace.

```bash
nkp get kubeconfig --cluster-name ${MANAGED_CLUSTER_NAME} >
${MANAGED_CLUSTER_NAME}.conf
Caution: Nutanix support is unable to recover forgotten credentials. The following best practices will prevent
Kommander UI lockouts.
```

- Backup the kubeconfig file.
- Save your credentials.
- Configure an IDP (identity provider) instead of using a username and
  password credentials.

1. You can now either [attach it in the UI] (link to attaching it to the
   workspace through UI that was earlier) or attach your cluster to the
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

1. Create this secret in the desired workspace:

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
   confirm its status by running the command below. It might take a few minutes
   to reach "Joined" status.

```bash
kubectl get nkpclusters -A
```

If you have several Pro Clusters and want to turn one of them into a Managed
Cluster to be centrally administrated by a Management Cluster, refer to
Platform Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate
Managed Cluster on page 519.

#### Accessing a Managed or Attached Cluster

About this task

Access your Clusters Using your UI Administrator Credentials.

After the cluster is attached, retrieve a custom kubeconfig file from the UI.

```yaml
Caution: Nutanix support is unable to recover forgotten credentials. Prevent Kommander UI lockouts with the
following best practices.
```

- Backup the kubeconfig file.
- Save your credentials.
- Configure an IDP (identity provider) instead of using a username and
  password credentials.

Procedure

1. Select the username in the top right corner, and then select Generate Token.
2. Select the cluster name and follow the instructions to assemble a
   kubeconfig for accessing its Kubernetes API.

> **Note: If the UI prompts you to log inlog on, use the credentials you
> normally use to access the UI.**

You can also retrieve a custom kubeconfig file by visiting the /token endpoint
on the Kommander cluster domain (example URL: `<<https://your-server-name.your->`
region-2.elb.service.com/token/>. Selecting the cluster's name displays the
instructions to assemble a kubeconfig for accessing its Kubernetes API.

Platform Expansion: Conversion of an NKP Pro Cluster to an NKP Ultimate
Managed Cluster

If you are an NKP Pro customer, you can easily convert your independent
clusters into a multi-cluster environment if you upgrade to an Ultimate
license.

This section provides information on how you can turn your Pro Clusters into
Managed clusters.

#### Prerequisites: General Prerequisites for Your Cluster Conversion

You have the option to convert your NKP Pro Clusters into NKP Managed Ultimate
Clusters.

To convert your NKP Pro clusters into NKP Managed Ultimate clusters, ensure
you meet the following requirements:

- An NKP Management cluster with a valid NKP Ultimate license is installed.
- At least one installed and running standalone NKP Pro cluster.
- All NKP Pro Clusters are upgraded to the same NKP version as the NKP Managed
  Ultimate cluster. For more information, see Upgrade Nutanix Kubernetes
  Platform on page 1042.
- The NKP Pro Cluster you want to convert is self-managed. For more
  information, see Cluster Types on page 19.
- The NKP Pro Cluster you want to convert only contains its own Cluster API
  resources and does not contain Cluster API resources from other clusters

For more information on how you can purchase an NKP Ultimate license, see
Licenses on page 24.

> **Note: Attaching NKP Ultimate clusters is not supported.**

Downtime Considerations

Your NKP Pro cluster will not be accessible externally for several minutes
during the expansion process. Any configuration of the cluster's Ingress that
requires traefik-forward-auth authentication will be affected.

```yaml
Note: Access from within the cluster through Kubernetes service hostname (for example, http://
SERVICE_NAME.NAMESPACE:PORT) is not affected.
```

Affected NKP Services

- nkp-ceph-cluster-dashboard
- grafana-logging
- kube-prometheus-stack-alertmanager
- kube-prometheus-stack-grafana
- kube-prometheus-stack-prometheus
- kubernetes-dashboard
- traefik-dashboard

Other Services

To verify if your services are affected by traefik-forward-auth's downtime,
run the following command:

```bash
kubectl get ingress -n NS <your_customized_ingress_name>
```

Look for the traefik.ingress.kubernetes.io/router.middlewares field in the
output. If this field contains the value kommander-forwardauth@kubernetescrd,
your service will be affected by the downtime.

Duration

The traefik-forward-auth service is affected starting with the
PreAttachmentCleanup conversion stage, and will run normally again after
ResumeFluxOperations is completed. Observe the conversion progress to monitor
your cluster's current status. For more information, see Troubleshooting:
Cluster Management on page 534.

#### Prerequisites: Cluster Configurations

SSO Configuration

After attachment, the SSO configuration of the Management cluster applies to
the Managed (formerly Pro) cluster. Any SSO configuration of the former Pro
cluster will be deleted.

- If the Pro cluster has SSO configured but the Management cluster does not,
  you can copy your Pro cluster's SSO configuration (dex-controller resources)
  to the Management cluster before conversion.
- If your Management cluster has SSO configured and the Pro cluster has
  another SSO configuration, you can choose to keep one or both. To keep the
  configuration of your Pro cluster, manually copy the dex-controller
  resources to the Management cluster before conversion. NKP maintains the SSO
  configuration of your Management cluster automatically unless you manually
  delete it.

Domains and Certificates

Any custom domain or certificate configuration you have set up for your Pro
cluster remains functional after you turn it into a Managed cluster.

```yaml
Warning: After conversion, any domain or certificate customizations you want to apply to your Managed cluster must
be done through the KommanderCluster. This object is now stored in the Management cluster.
```

#### Prerequisites: Cloning Git Repository from Git Operator

About this task

After your NKP Pro Cluster is converted into a NKP Ultimate Managed cluster,
the old instance of Git Operator that is used to host all Git repositories in
the NKP Pro Cluster will not be preserved.

Perform the steps on this page to ensure that you have a local copy of the
Management Git Repository in the state it was in prior to undergoing the
expansion process.

```yaml
Note: All NKP Platform Applications will be migrated from the NKP Pro Cluster to the NKP Ultimate Managed
Cluster.
```

Procedure

1. Prior to turning an NKP Pro cluster to an NKP Ultimate Managed Cluster,
   clone the Management Git Repository using the following command:

```bash
nkp experimental gitops clone
```

1. Verify that the Git Repository has been successfully cloned to your local
   environment.

```bash
cd kommander
git remote -v
# output from git remote -v look like
# origin https://<YOUR_CLUSTER_INGRESS_HOSTNAME>/nkp/kommander/git-operator/
repositories/kommander/kommander.git (fetch)
```

#### Cluster Applications and Persistent Volumes Backup

Back up and restore your cluster's applications before attempting to convert
your NKP Pro cluster into a NKP Ultimate Managed cluster.

The instructions differ depending on the infrastructure provider of your NKP
Pro cluster.

For AWS, see AWS Cluster Backup on page 522.

For Azure, vSphere, GCP, and pre-provisioned environments, see Azure, vSphere,
GCP, or Pre-provisioned Cluster Backup on page 525.

##### AWS Cluster Backup

Use the Nutanix Kubernetes® Platform (NKP) CLI to back up and restore NKP Pro
clusters deployed on AWS infrastructure.

Prepare you environment by installing Velero, enabling the CSI snapshot plug-
in, providing required permissions, and backing up and restoring your cluster
applications when required. You can also capture cluster configuration,
workload data, and metadata, ensuring that you can recover both management and
workload clusters.

###### Preparing Your Cluster for Backup

About this task

This section describes how to prepare your cluster on an AWS environment so
that it can be backed up.

Before you begin

- Ensure Velero is installed on your Pro cluster. Use at least Velero CLI
  version 1.10.1.

For more information, see Velero Installation Using CLI on page 576.

- Ensure kubectl is installed.

For more information, see `<https://kubernetes.io/docs/tasks/tools/>`.

- Ensure you have admin rights to the NKP Pro cluster.

Procedure

Prepare your cluster. Run the following commands in the NKP Pro cluster. For
general guidelines on how to set the context, see Commands within a kubeconfig
File on page 31.

###### Preparing Velero

Enable the CSI snapshotting plug-in by providing a custom configuration of
Velero.

Procedure

1. Create an Override with the custom configuration:

```bash
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
name: velero-overrides
namespace: kommander
data:
values.yaml: |
---
configuration:
features: EnableCSI
initContainers:
- name: velero-plugin-for-aws
image: velero/velero-plugin-for-aws:v1.5.2
imagePullPolicy: IfNotPresent
volumeMounts:
- mountPath: /target
name: plugins
- name: velero-plugin-for-csi
image: velero/velero-plugin-for-csi:v0.4.2
imagePullPolicy: IfNotPresent
volumeMounts:
- mountPath: /target
name: plugins
EOF
```

1. Update the AppDeployment to apply the new configuration.

```bash
cat << EOF | kubectl -n kommander patch appdeployment velero --type='merge' --patch-
file=/dev/stdin
spec:
configOverrides:
name: velero-overrides
EOF
```

1. Verify the configuration has been updated before proceeding with the next
   section.

```bash
kubectl -n kommander wait --for=condition=Ready kustomization velero
```

The output should look similar to this.

```bash
kustomization.kustomize.toolkit.fluxcd.io/velero condition met
```

###### Preparing the AWS IAM Permission

About this task

When creating a cluster on AWS, you must provide additional permission as
specified in AWS Prerequisites on page 815.

For the CSI plugin to function correctly, update the existing IAM role to
include an additional policy.

Procedure

Add the `<https://docs.aws.amazon.com/aws-managed-policy/latest/reference/>`
AmazonEBSCSIDriverPolicy.html policy to the control plane role control-
plane.cluster-api-provider- aws.sigs.k8s.io.

```bash
aws iam attach-role-policy \
--role-name control-plane.cluster-api-provider-aws.sigs.k8s.io \
--policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
```

This will allow the EBS CSI driver, a volume manager, to have enough
permissions to create volume snapshots.

```yaml
Warning: The default control plane role name is control-plane.cluster-api-provider-
aws.sigs.k8s.io. If you customized this name when creating the AWS cluster, replace the default control-plane
role with the name you assigned to it.
```

###### Preparing the CSI Configuration

About this task

Procedure

Configure a VolumeSnapshotClass object on the cluster so that Velero can
create a volume snapshot:

```bash
cat << EOF | kubectl apply -f -
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
name: aws
labels:
velero.io/csi-volumesnapshot-class: "true"
driver: ebs.csi.aws.com
deletionPolicy: Delete
parameters:
EOF
```

###### Backing Up the AWS Cluster

About this task

With this workflow, you can back up and restore your cluster's applications.
The backup contains all Kubernetes objects and the Persistent Volumes of your
NKP applications.

When backing up a cluster that runs on a cloud provider, Velero captures the
state of your cluster in a snapshot. Review Velero's list of cloud providers
for CSI compatibility. For more information, see `<https://velero.io/docs/>`
v1.10/supported-providers/.

```yaml
Warning: Run the following commands in the NKP Pro cluster. For general guidelines on how to set the context, see
Commands within a kubeconfig File on page 31.
```

Procedure

1. Configure Velero to use CSI snapshotting.

```bash
velero client config set features=EnableCSI
```

1. Create a backup with Velero. Use the following flags to reduce the scope of
   the backup and only include the applications that are affected during the
   expansion.

```bash
velero backup create pre-expansion \
--include-namespaces="kommander,kommander-default-workspace,kommander-flux" \
--include-cluster-resources \
--wait
```

After completion, the output should look similar to this.

```bash
Backup request "pre-expansion" submitted successfully.
Waiting for backup to complete. You may safely press ctrl-c to stop waiting - your
backup will continue in the background.
................................................................................................
Backup completed with status: Completed. You may check for more information using
the commands `velero backup describe pre-expansion` and `velero backup logs pre-
expansion`.
```

1. Verify the Backup. Review the backup has been completed successfully.

```bash
velero backup describe pre-expansion
```

The following example output will vary depending on your cloud provider.
Verify that it shows no errors and the Phase is Completed.

```yaml
Name: pre-expansion
Namespace: kommander
Labels: velero.io/storage-location=default
Annotations: velero.io/source-cluster-k8s-gitversion=v<kubernetes-version>
velero.io/source-cluster-k8s-major-version=1
velero.io/source-cluster-k8s-minor-version=25
Phase: Completed
Errors: 0
Warnings: 0
Namespaces:
Included: kommander, kommander-default-workspace, kommander-flux
Excluded: <none>
Resources:
Included: *
Excluded: <none>
Cluster-scoped: included
Label selector: <none>
Storage Location: default
Velero-Native Snapshot PVs: auto
TTL: 720h0m0s
CSISnapshotTimeout: 10m0s
Hooks: <none>
Backup Format Version: 1.1.0
Started: 2023-03-15 10:40:25 -0400 EDT
Completed: 2023-03-15 10:44:39 -0400 EDT
Expiration: 2023-04-14 10:40:24 -0400 EDT
Total items to be backed up: 5188
Items backed up: 5188
Velero-Native Snapshots: <none included>
```

##### Azure, vSphere, GCP, or Pre-provisioned Cluster Backup

Use the Nutanix Kubernetes® Platform (NKP) CLI to back up and restore NKP Pro
clusters deployed on Azure, vSphere, GCP or Pre-provisioned environments.

Prepare you environment by installing Velero, enabling restic backup
capabilities, annotating the pod to ensure restic backs up the persistent
volumes (PVs) of the pods, and backing up and restoring your cluster
applications when required. You can also capture cluster configuration,
workload data, and metadata, ensuring that you can recover both management and
workload clusters.

###### Preparing Your Cluster for Backup (2)

This section describes how to prepare your cluster on AWS, Azure, vSphere,
Google Cloud, or pre- provisioned environment, so it can be backed up.

Before you begin

- Ensure Velero is installed on your Pro cluster. Use at least Velero CLI
  version 1.10.1.

For more information, see Velero Installation Using CLI on page 576.

- Ensure kubectl is installed.

For more information, see `<https://kubernetes.io/docs/tasks/tools/>`.

- Ensure you have admin rights to the NKP Pro cluster.

Procedure

Prepare you cluster. Run the following commands in the NKP Pro cluster. For
general guidelines on how to set the context, see Commands within a kubeconfig
File on page 31.

###### Preparing Velero (2)

Enable restic backup capabilities by providing a custom configuration of Velero.

Procedure

1. Create an Override with a custom configuration for Velero. This custom
   configuration deploys the node-agent service, which enables restic.

```bash
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
name: velero-overrides
namespace: kommander
data:
values.yaml: |
---
deployNodeAgent: true
EOF
```

1. Reference the created Override in Velero's AppDeployment to apply the new
   configuration.

```bash
cat << EOF | kubectl -n kommander patch appdeployment velero --type='merge' --patch-
file=/dev/stdin
spec:
configOverrides:
name: velero-overrides
EOF
```

1. Wait until the node-agent has been deployed:

```bash
until kubectl get daemonset -A | grep -m 1 "node-agent"; do 0.1 ; done
```

The node-agent is ready after a similar output appears:

```bash
kommander node-agent
3 3 0 3 0 <none>
```

1. Verify the configuration has been updated before proceeding with the next
   section.

```bash
kubectl -n kommander wait --for=condition=Ready kustomization velero
```

The output should look similar to this.

```bash
kustomization.kustomize.toolkit.fluxcd.io/velero condition met
```

###### Preparing the Pods for Backup

Annotate the pod to ensure restic backs up the Persistent Volumes (PVs) of the
pods that will be affected during the expansion process. These volumes contain
the Git repository information of your NKP Pro cluster.

About this task

```yaml
Warning: Run the following commands in the NKP Pro cluster. For general guidelines on how to set the context, see
Commands within a kubeconfig File on page 31.
```

Procedure

Run the following command.

```bash
kubectl -n git-operator-system annotate pod git-operator-git-0 backup.velero.io/backup-
volumes=data
```

###### Backing Up the Azure, vSphere, GCP, or Pre-provisioned Cluster

With this workflow, you can back up and restore your cluster's applications.
This backup contains Kubernetes objects and the Persistent Volumes (PVs) of
Git Operator pods. Given that Git Operator's PVs store information on your
cluster's state, you will be able to restore your cluster if required.

About this task

```yaml
Warning: Run the following commands in the NKP Pro cluster. For general guidelines on how to set the context, see
Commands within a kubeconfig File on page 31.
```

Procedure

1. Create a backup with Velero. Use the following flags to reduce the scope of
   the backup and only include the applications that are affected during the
   expansion.

```bash
velero backup create pre-expansion \
--include-namespaces="git-operator-system,kommander,kommander-default-
workspace,kommander-flux" \
--include-cluster-resources \
--snapshot-volumes=false --wait \
--namespace kommander
```

After completion, the output should look similar to this.

```bash
Backup request "pre-expansion" submitted successfully.
Waiting for backup to complete. You may safely press ctrl-c to stop waiting - your
backup will continue in the background.
................................................................................................
Backup completed with status: Completed. You may check for more information using
the commands `velero backup describe pre-expansion` and `velero backup logs pre-
expansion`.
```

1. Verify the Backup. Ensure the backup has been completed successfully.

```bash
velero backup describe pre-expansion --namespace kommander
```

The following example output will vary depending on your cloud provider.
Verify that it shows no errors and the Phase is Completed.

```yaml
Name: pre-expansion
Namespace: kommander
Labels: velero.io/storage-location=default
Annotations: velero.io/source-cluster-k8s-gitversion=v1.25.5
velero.io/source-cluster-k8s-major-version=1
velero.io/source-cluster-k8s-minor-version=25
Phase: Completed
Errors: 0
Warnings: 0
Namespaces:
Included: git-operator-system, kommander, kommander-default-workspace, kommander-
flux
Excluded: <none>
Resources:
Included: *
Excluded: <none>
Cluster-scoped: included
Label selector: <none>
Storage Location: default
Velero-Native Snapshot PVs: auto
TTL: 720h0m0s
CSISnapshotTimeout: 10m0s
Hooks: <none>
Backup Format Version: 1.1.0
Started: 2023-03-15 10:40:25 -0400 EDT
Completed: 2023-03-15 10:44:39 -0400 EDT
Expiration: 2023-04-14 10:40:24 -0400 EDT
Total items to be backed up: 5188
Items backed up: 5188
Velero-Native Snapshots: <none included>
```

1. Ensure that the PodVolumeBackup objects have been created,

```bash
kubectl get podvolumebackups -A
```

The output should look similar to this.

```bash
NAMESPACE NAME STATUS CREATED NAMESPACE POD VOLUME
REPOSITORY ID
UPLOADER TYPE STORAGE LOCATION AGE
kommander ash-5vsbf Completed 42s git-operator-system git-operator-
git-0 data s3:https://a54904d80411e4d64b572b96cb3ddb62-477717230.us-
west-2.elb.amazonaws.com:8085/nkp-velero/restic/kommander restic default
42s
```

#### Converting a Pro Cluster Into a Managed Cluster Using the UI

About this task

```yaml
Warning: Ingress that contains Traefik-Forward-Authentication in NKP (TFA) on page 626
configuration will not be available during the expansion process. Therefore, your NKP Pro cluster will not be accessible
externally for several minutes. Access from within the cluster through Kubernetes service hostname (for example,
http://SERVICE_NAME.NAMESPACE:PORT) is not affected.
```

For more information., see Downtime Considerations on page 520.

To attach an existing cluster that has no additional networking restrictions:

Use this option when you want to attach a cluster that does not require
additional access information.

Procedure

1. From the top menu bar, select your target workspace.
2. On the Dashboard page, select the Add Cluster option in the Actions
   dropdown list on the top right.
3. Select Attach Cluster.
4. Select the No additional networking restrictions card. Alternatively, if
   you must use network restrictions, skip the following steps and perform the
   steps in Cluster Attachment with Networking Restrictions on page 492.
5. In the Cluster Configuration section, paste your kubeconfig file into the
   field or select Upload kubeconfig File to specify the file.
6. The Cluster Name field will automatically populate with the name of the
   cluster in the kubeconfig. You can edit this field using the name you want
   for your cluster.
7. The Context select list is populated from the kubeconfig. Select the
   desired context with admin privileges from the Context select list.
8. Add labels to classify your cluster as needed.
9. Select Create to attach your cluster.
10. Verify the Conversion.

```yaml
Warning: Run the following commands in the Management cluster. For general guidelines on setting the
context, see Commands within a kubeconfig File on page 31.
```

a. Export the environment variable for the workspace namespace.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

b. To verify that the conversion is successful, check the KommanderCluster
object.

```bash
kubectl wait --for=condition=AttachmentCompleted kommandercluster <cluster name>
-n ${WORKSPACE_NAMESPACE} --timeout 30m
```

The following output appears if the conversion is successful.

```bash
kommandercluster.mesosphere.io/<cluster name> condition met
Note: After conversion, all Platform Applications will be in the Kommander Namespace in the Managed
Cluster.
```

What to do next

Post Conversion: Cleaning Clusters Running on Different Cloud Platforms on
page 533

#### Converting a Pro Cluster Into a Managed Cluster Using the CLI

About this task

> **Warning:**

Ingress that contains Traefik-Forward-Authentication in NKP (TFA) on page 626
configuration will not be available during the expansion process, therefore,
your NKP Pro cluster will not be accessible externally for several minutes.
Access from within the cluster through Kubernetes service hostname (for
example, `<http://SERVICE_NAME.NAMESPACE:POR>`T) is not affected.

For more information, see Downtime Considerations on page 520.

Procedure

1. Run the following command in the NKP Ultimate cluster. The cluster name and
   kubeconfig are from the cluster you are attaching and want to convert to
   initiate the process of turning an NKP Pro cluster into an NKP Ultimate
   Managed cluster. The workspace is the workspace name you want the attached
   cluster to go into.

```bash
nkp attach cluster --name <pro-cluster-name> --attached-kubeconfig <kubeconfig-file-
of-pro-cluster> --workspace <workspace-name>
```

1. Verify the conversion.

```yaml
Warning: Run the following commands in the Management cluster. For general guidelines on setting the context,
see Commands within a kubeconfig File on page 31.
```

a. Export the environment variable for the workspace namespace.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

b. To verify that the conversion is successful, check the KommanderCluster
object.

```bash
kubectl wait --for=condition=AttachmentCompleted kommandercluster <cluster name> -
n ${WORKSPACE_NAMESPACE} --timeout 30m
```

The following output appears if the conversion is successful.

```bash
kommandercluster.mesosphere.io/<cluster name> condition met
Note: After conversion, all Platform Applications will be in the Kommander Namespace in the Managed
Cluster.
```

What to do next

#### Post Conversion: Cleaning Up Cluster Autoscaler Configuration

About this task

After converting your cluster from Pro to Ultimate, the Cluster Life cycle
Management responsibilities are moved to a single Management cluster.

The Cluster Autoscaler feature also depends on the same Cluster Life Cycle
Management components. If you are using the Cluster Autoscaler feature in NKP,
you must perform the following steps for this feature to continue to work
correctly:

```yaml
Note: Run the following commands in the Management cluster. For general guidelines on how to set the context, see
Commands within a kubeconfig File on page 31.
```

Procedure

1. Set the following environment variables with your cluster's details.

```bash
export CLUSTER_NAME=<>
export WORKSPACE_NAMESPACE=<>
```

1. Apply the Cluster Autoscaler Deployment and supporting resources.

```bash
cat <<EOF | kubectl apply -f -
---
apiVersion: apps/v1
kind: Deployment
metadata:
labels:
app: cluster-autoscaler-${CLUSTER_NAME}
name: cluster-autoscaler-${CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
spec:
replicas: 1
selector:
matchLabels:
app: cluster-autoscaler-${CLUSTER_NAME}
template:
metadata:
labels:
app: cluster-autoscaler-${CLUSTER_NAME}
spec:
containers:
- args:
- --cloud-provider=clusterapi
- --node-group-auto-discovery=clusterapi:clusterName=${CLUSTER_NAME}
- --kubeconfig=/workload-cluster/kubeconfig
- --clusterapi-cloud-config-authoritative
- -v5
command:
- /cluster-autoscaler
image: us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-
autoscaler:v<kubernetes-version>
name: cluster-autoscaler
volumeMounts:
- mountPath: /workload-cluster
name: kubeconfig
readOnly: true
serviceAccountName: cluster-autoscaler-${CLUSTER_NAME}
terminationGracePeriodSeconds: 10
tolerations:
- effect: NoSchedule
key: node-role.kubernetes.io/master
- effect: NoSchedule
key: node-role.kubernetes.io/control-plane
volumes:
- name: kubeconfig
secret:
items:
- key: value
path: kubeconfig
secretName: ${CLUSTER_NAME}-kubeconfig
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
name: cluster-autoscaler-management-${CLUSTER_NAME}
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: ClusterRole
name: cluster-autoscaler-management-${CLUSTER_NAME}
subjects:
- kind: ServiceAccount
name: cluster-autoscaler-${CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
---
apiVersion: v1
kind: ServiceAccount
metadata:
name: cluster-autoscaler-${CLUSTER_NAME}
namespace: ${WORKSPACE_NAMESPACE}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
name: cluster-autoscaler-management-${CLUSTER_NAME}
rules:
- apiGroups:
- cluster.x-k8s.io
resources:
- machinedeployments
- machinedeployments/scale
- machines
- machinesets
verbs:
- get
- list
- update
- watch
EOF
Note: For more information about the supported Kubernetes version, see Supported Kubernetes Versions section in
the NKP Release Notes.
```

1. Verify the output is similar to the following.

```bash
deployment.apps/cluster-autoscaler-<cluster-name> created
clusterrolebinding.rbac.authorization.k8s.io/cluster-autoscaler-management-<cluster-
name> created
serviceaccount/cluster-autoscaler-<cluster-name> created
clusterrole.rbac.authorization.k8s.io/cluster-autoscaler-management-<cluster-name>
created
```

1. To check that the status of the deployment has the expected AVAILABLE count
   of 1, run the following command and verify that the output is similar.

```bash
$ kubectl get deployment -n $WORKSPACE_NAMESPACE cluster-autoscaler-$CLUSTER_NAME
NAME READY UP-TO-DATE AVAILABLE AGE
cluster-autoscaler-<cluster-name> 1/1 1 1 1m
```

What to do next

#### Post Conversion: Cleaning Clusters Running on Different Cloud Platforms

Before you begin

Prior to running these commands, you must ensure that the NKP Management
Ultimate cluster is configured with the necessary platform specific
permissions to manage the incoming CAPI objects that backs the infrastructure
resources in the target cloud platform.

For example, for the NKP Ultimate Managed cluster to manage CAPI object in
AWS, see `<https://cluster-api->` aws.sigs.k8s.io/topics/iam-permissions.html.

NKP supports expanding your platform in the following scenarios:

Prior to running these commands, you must ensure that the NKP Management
Ultimate cluster is configured with the necessary platform specific
permissions to manage the incoming CAPI objects that backs the infrastructure
resources in the target cloud platform.

For example, for the NKP Ultimate Managed cluster to manage CAPI clusters in
AWS, refer to.

NKP supports expanding your platform in the following scenarios:

Table 51: Table

AWS `<https://cluster-api-aws.sigs.k8s.io/>` topics/iam-permissions.html

AWS, GCP, vSphere, Pre- provisioned

GCP `<https://cloud.google.com/iam/>` docs/overview

AWS, GCP, vSphere, Pre- provisioned

vSphere `<https://docs.vmware.com/en/>` vRealize-Operations/Cloud/
com.vmware.vcom.config.doc/ GUID- F85638E3-937E-4E31-90D0-9D4A5E479292.html

AWS, GCP, vSphere, Pre- provisioned

Azure `<https://learn.microsoft.com/>` en-us/azure/active-directory/
fundamentals/active-directory- ops-guide-iam

Azure

Pre-provisioned NA AWS, GCP, vSphere, Pre- provisioned

To move the CAPI resources:

- NKP Ultimate Management cluster host provider; NKP Ultimate Management
  cluster IAM permissions; NKP Pro cluster host provider

| --- | --- | --- |

Procedure

1. Following the conversion into an NKP Ultimate managed cluster, run the
   following command to move the CAPI Objects.

```bash
nkp move capi-resources --from-kubeconfig <essential_cluster_kubeconfig> --to-
kubeconfig <ultimate_cluster_kubeconfig> --to-namespace ${WORKSPACE_NAMESPACE}
```

1. Verify that the output looks similar to the following.

```bash
# Moving cluster resources
You can now view resources in the moved cluster by using the --kubeconfig flag with
kubectl. For example: kubectl --kubeconfig=<ultimate_cluster_kubeconfig> get nodes
```

1. After moving the resources, run the following command to remove the CAPI
   controller manager deployments.

```bash
nkp delete capi-components --kubeconfig <essential_cluster_kubeconfig>
```

#### Troubleshooting: Cluster Management

Verify the Conversion Status of your Cluster

When an error or failure occurs when converting a NKP Pro cluster to a NKP
Ultimate Managed cluster, NKP automatically keeps retrying the cluster's
conversion and attachment process. You do not need to trigger it manually.

If the state does not improve after a while, here are some ways in which you
can check or troubleshoot the failed conversion:

```yaml
Note: Run the following commands in the Management cluster. For general guidelines on how to set the context, see
Commands within a kubeconfig File on page 31.
```

1. Export the environment variable for the workspace namespace.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

1. To verify that the conversion is successful, check the KommanderCluster
   object:

```bash
kubectl wait --for=condition=AttachmentCompleted kommandercluster <cluster name> -n
${WORKSPACE_NAMESPACE} --timeout 30m
```

The following output appears if the conversion is successful.

```bash
kommandercluster.mesosphere.io/<cluster name> condition met
```

1. If the condition is not met yet, you can observe the conversion process. 4.
   Export the environment variable for the workspace namespace:

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

1. Print the state of your cluster's KommanderCluster object through the CLI
   and observe the cluster conversion process,

```bash
kubectl get kommandercluster -n ${WORKSPACE_NAMESPACE} <essential_cluster_name>
-o go-template='{{range .status.conditions }}type: {{.type}} {{"\n"}}status:
{{.status}} {{"\n"}}reason: {{.reason}} {{"\n"}}lastTxTime: {{.lastTransitionTime}}
{{"\n"}}message: {{.message}} {{"\n\n"}}{{end}}'
```

1. The output looks similar to this.

```yaml
type: IngressAddressReady
status: False
reason: IngressServiceNotFound
lastTxTime: 2023-02-24T14:58:18Z
message: Ingress service object was not found in the cluster
type: IngressCertificateReady
status: True
reason: Ready
lastTxTime: 2023-02-24T14:49:09Z
message: Certificate is up to date and has not expired
type: CAPIResourceMoved
status: True
reason: Succeeded
lastTxTime: 2023-02-24T14:50:56Z
message: Moved CAPI resources from the attached cluster to management cluster
type: PreAttachmentCleanup
status: True
reason: Succeeded
lastTxTime: 2023-02-24T14:54:47Z
message: pre-attach cleanup succeeded
# [...]
```

Errors Related to CAPI Resources

Failed Condition Reason: FailedToIdentifyCAPIResources

kubeconfigRef points to the wrong secret. Verify the KommanderCluster object
of both your Pro and Ultimate clusters. The spec.kubeconfigRef.name of each
object should point to a valid kubeconfig secret.

1. Download the referenced kubeconfig to your local machine:

```bash
kubectl get secret -n <WORKSPACE_NAMESPACE> <cluster_name>-kubeconfig -o
jsonpath='{.data.value}' | base64 --decode > <cluster_name>-kubeconfig
```

1. Verify if the kubeconfig is valid:

```bash
kubectl get namespaces -A --kubeconfig <cluster_name>-kubeconfig
```

1. Verify the output of the previous command:

- No errors in Output: If your output shows no errors, the error message is not
  related to a kubeconfig.
- Errors in Output: If the output shows an error, delete the KommanderCluster
  object through CLI:

```bash
kubectl delete kommandercluster -n <WORKSPACE_NAMESPACE> <WRONG_KOMMANDER_CLUSTER>
```

At this particular stage and in the context of converting your cluster,
deleting your KommanderCluster will not affect your environment. However, DO
NOT delete your KommanderCluster in other scenarios, as it detaches the
referenced cluster from the Management cluster.

Finally, restart the cluster conversion process with the UI. For more
information, see Converting a Pro Cluster Into a Managed Cluster Using the UI
on page 528.

The pro cluster has more than one instance of v1beta1/clusters.cluster.x-k8s.io

```yaml
Warning: Nutanix does not support converting Pro clusters that contain the Cluster API resources of more than one
cluster.
```

Ensure your Pro cluster only contains its own CAPI resources and does not
contain the CAPI resources of other clusters.

Restoring Backup and Retrying Cluster Expansion

When an error or failure occurs when converting a NKP Pro cluster to a NKP
Ultimate Managed cluster, NKP automatically keeps retrying the cluster's
conversion and attachment process. You do not need to trigger it manually.

If you must interrupt the expansion process to restore your cluster and retry
the expansion procedure, follow these instructions:

Restoring Your Cluster

Prerequisites: You have backed up your cluster. The cluster expansion you
attempted was not successful.

```yaml
Warning: Switch between NKP Ultimate Management and NKP Pro clusters for the following commands. For general
guidelines on how to set the context, see Commands within a kubeconfig File on page 31.
```

1. Delete the KommanderCluster object on the NKP Ultimate Management cluster:

```bash
kubectl -n <WORKSPACE_NAMESPACE> delete kommandercluster <KOMMANDER_CLUSTER_NAME> --
wait=false
```

1. Disable the Flux controllers on the NKP Pro cluster to interrupt the
   expansion process:

```bash
kubectl -n kommander-flux delete deployment -l app.kubernetes.io/instance=kommander-
flux
```

1. Delete the kube-federation-system namespace on the NKP Pro cluster:

```bash
kubectl get ns kube-federation-system -o json | jq '.spec.finalizers = []' | kubectl
replace --raw "/api/v1/namespaces/kube-federation-system/finalize" -f -
```

1. Restore your cluster's configuration on the NKP Procluster:

```bash
velero restore create pre-expansion --from-backup pre-expansion --existing-resource-
policy update --wait --namespace kommander
```

Moving the Cluster's CAPI Resources

Because the backup created does not include CAPI resources, you will also have
to move them back to the NKP Pro cluster.

```yaml
Warning: Ensure you replace <CAPI_CLUSTER_NAME> with the name of the NKP Pro cluster you were converting
in the current workflow. If you accidentally provide the CAPI cluster name of another Managed cluster, the command
will move the CAPI resources of the incorrect cluster to the NKP Pro cluster.
```

1. Retrieve your Managed cluster's kubeconfig and write it to the `<pro.conf>`
   file:

```bash
KUBECONFIG=management.conf ./nkp get kubeconfig -n <WORKSPACE_NAMESPACE> -c
<CAPI_CLUSTER_NAME> > pro.conf
```

1. Move your CAPI resources back to the NKP Pro cluster:

```bash
nkp move capi-resources --from-kubeconfig management.conf --to-kubeconfig <pro.conf>
-n <WORKSPACE_NAMESPACE> --to-namespace default
```

Verifying the Restore Process and Retrying the Expansion

1. Verify that you successfully restored your cluster:

```bash
velero restore describe pre-expansion --namespace kommander
```

The output looks similar to this:

```yaml
Name: pre-expansion
Namespace: kommander
Labels: <none>
Annotations: <none>
Phase: Completed
Total items to be restored: 2411
Items restored: 2411
```

1. Retry the Expansion Process.

Run the cluster expansion again, as described in Platform Expansion:
Conversion of an NKP Pro Cluster to an NKP Ultimate Managed Cluster on page 519.

### Creating Advanced CLI Clusters

About this task

```yaml
Warning: This feature is for advanced users and users in unique environments only. We highly recommend using
other documented methods to create clusters whenever possible.
```

Procedure

1. Generate Cluster Objects. You set the target namespace with the name of the
   workspace you are creating the cluster in using the nkp create cluster ...
   --namespace `<WORKSPACE_NAMESPACE>` --dry-run --output=yaml command. In
   other words, the --namespace flag equals the workspace namespace.

Depending on your infrastructure, NKP CLI can generate a set of cluster
objects that can be customized for unusual use cases. For an example of how to
use the --output flags to create a set of cluster objects, see Creating the
NKP Management Cluster on AWS on page 818. 2. In the selected workspace
Dashboard, select the Add Cluster option in the Actions dropdown list on the
top- right. 3. In the Add Cluster page, select Upload YAML to Create a Cluster
and provide advanced cluster details.

» Workspace: The workspace where this cluster belongs (if within the Global
workspace).

» Cluster YAML: Paste or upload your customized set of cluster objects into
this field. Only valid YAML is accepted.

» Add Labels: By default, your cluster has labels that reflect the
infrastructure provider provisioning. For example,
your AWS cluster might have a label for the datacenter region and provider:
aws. Cluster labels are matched to the
selectors created for Projects on page 415. Changing a cluster label might add
or remove the cluster from projects. 4.
To begin provisioning the NKP CLI cluster, click Create. This step takes a few
minutes for the cluster to be ready and
fully deploy its components. The cluster automatically tries to join and
resolves after it is fully provisioned.

### Custom Domains and Certificates Configuration for All Cluster Types

You can perform this configuration on either managed or attached clusters. For
more information, see Cluster Types on page 19.

There are two configuration methods:

Table 52: Configuration Methods

While installing the Kommander component Management cluster

After installing the Kommander component Go to Configuring the Kommander
Installation with a Custom Domain and Certificate on page 1001

NKP supports configuring a custom domain name for accessing the UI and other
platform services, as well as setting up manual or automatic certificate
renewal or rotation. This section provides instructions and examples on how to
configure a customized domain and certificate on your Pro, Managed, or
attached clusters.

#### Reasons For Setting Up a Custom Domain or Certificate

Reasons for Using a Custom DNS Domain

NKP supports the customization of domains to allow you to use your own domain
or hostname for your services. For example, you can set up your NKP UI or any
of your clusters to be accessible with your custom domain name instead of the
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
  cluster. For more information, see Cluster Types on page 19.
- Update your cluster's current domain and certificate configuration as part
  of your cluster management operations. For information, see Cluster
  Operations Management on page 284. You can do this for any cluster type in
  your environment.

```yaml
Note: Using Let's Encrypt or other public ACME certificate authorities does not work in air-gapped scenarios, as these
services require connection to the Internet for their setup. For air-gapped environments, you can either use self-signed
certificates issued by the cluster (the default configuration), or a certificate created manually using a trusted Certificate
Authority.
```

#### KommanderCluster and Certificate Issuer Concepts

This topic provides information about KommanderCluster and Certificate Issuer.

KommanderCluster Object

The KommanderCluster resource is an object that contains key information for
all types of clusters that are part of your environment, such as:

- Cluster access and endpoint information
- Cluster attachment information

| Configuration Methods | Supported cluster types |
| --------------------- | ----------------------- |

- Cluster status and configuration information

Issuer Objects: Issuer, ClusterIssuer or certificateSecret

If you use a certificate issued and managed automatically by cert-manager, you
need an Issuer or ClusterIssuerthat you reference in your KommanderCluster
resource. The referenced object must contain information about your
certificate provider.

If you want to use a manually-created certificate, you need a
certificateSecret that you reference in your KommanderCluster resource.

Location of the KommanderCluster and Issuer Objects: Management, Managed or
Attached Cluster

In the Management or Pro cluster, both the KommanderCluster and issuer objects
are stored on the same cluster. The issuer can be referenced as an Issuer,
ClusterIssuer , or certificateSecret.

In the Managed and attached clusters, the KommanderCluster object is stored on
the Management cluster. The Issuer, ClusterIssuer , or certificateSecret is
stored on the Managed or Attached cluster.

HTTP or DNS Solver

##### Configuration Options

If you are enabling access for a network-restricted cluster, this
configuration is restricted to DNS. For more information, see Proxied Access
to Network-Restricted Clusters on page 510.

#### Configure Custom Domains or Custom Certificates post Kommander Installation

There are two configuration methods:

Table 53: Configuration Methods

While installing the Kommander component Only Pro or Management clusters

While configuring the Kommander Installation with a Custom Domain and
Certificate.

Remain in this page

NKP supports configuring a custom domain name for accessing the UI and other
platform services, as well as setting up manual or automatic certificate
renewal or rotation.

This section provides instructions and examples on how to configure a
customized domain and certificate on Pro, Management, Managed, or Attached
clusters and how to configure the NKP installation to add a customized domain
and certificate on your Pro cluster or your Management cluster.

##### Configuration Options (2)

After you have installed the Kommander component of NKP, you can configure a
custom domain and certificate by modifying the NKPCluster object of your
cluster. You have several options to establish a custom domain and
certificate.

| Issuer, | ClusterIssuer |
| ------- | ------------- |

| Configuration Methods | Supported cluster types |
| --------------------- | ----------------------- |

```yaml
Note: If you want the cert-manager to automatically handle certificate renewal and rotation, choose an ACME-
supported Certificate Authority.
```

###### Using an Automatically-generated Certificate with ACME

About this task

Use a certificate that is managed automatically and supported by cert-manager:

- Update the NKPCluster by referencing the name of the created Issuer or
  ClusterIssuer in the spec.kommanderCluster.spec.ingress.issuerRef field.
  Enter the custom domain name in the
  spec.kommanderCluster.spec.ingress.hostname field:

Procedure

1. Create an Issuer or ClusterIssuer with your certificate provider
   information. Store this object in the cluster where you want to customize
   the certificate and domain.

a. If you want to use NKP's default certificate authority, see Configuring a
Custom Certificate With Let's Encrypt on page 541. 2. Update the NKPCluster by
referencing the name of the created Issuer or ClusterIssuer in the

spec.kommanderCluster.spec.ingress.issuerRef field. Enter the custom domain
name in the spec.kommanderCluster.spec.ingress.hostname field.

```bash
cat <<EOF | kubectl -n <workspace_namespace> --kubeconfig
<management_cluster_kubeconfig> patch \
nkpcluster <cluster_name> --type='merge' --patch-file=/dev/stdin
spec:
kommanderCluster:
spec:
ingress:
hostname: <cluster_hostname>
issuerRef:
name: <issuer_name>
kind: Issuer # or ClusterIssuer depending on the issuer config
EOF
Note: You can also configure a certificate issued by another Certificate Authority. In this case, the Certificate
Authority determines the information to include in the configuration.
```

- For configuration examples, see `<https://cert-manager.io/docs/configuration/>`.
- The ClusterIssuer's name must be kommander-acme-issuer.

###### Using a Manually-generated Certificate

Use a manually created certificate that is customized for your hostname.

Procedure

1. Obtain or create a customized certificate for your hostname and store it in
   the workspace namespace of your workload cluster.
2. Create a secret with your custom domain certificate in the workspace
   namespace of your workload cluster:

```bash
kubectl create secret generic -n "${WORKSPACE_NAMESPACE}" <certificate_secret_name> \
--from-file=ca.crt=$CERT_CA_PATH \
--from-file=tls.crt=$CERT_PATH \
--from-file=tls.key=$CERT_KEY_PATH \
--type=kubernetes.io/tls
```

Replace `<certificate_secret_name>` with a name for the secret.

```yaml
Note: To enable Kommander to access the certificate, you must create a secret in the workspace namespace of your
workload cluster. Even if you define the NKPCluster resource on the management cluster, the corresponding
certificate secret must exist in the workload cluster. Kommander cannot access the certificate if the secret is only
present on the management cluster.
```

1. Update the NKPCluster:

```bash
cat <<EOF | kubectl -n <workspace_namespace> --kubeconfig
<management_cluster_kubeconfig> patch nkpcluster <cluster_name> --type='merge' --
patch-file=/dev/stdin
spec:
kommanderCluster:
spec:
ingress:
hostname: <cluster_hostname>
certificateSecretRef:
name: <certificate_secret_name>
EOF
```

In the spec.kommanderCluster.spec.ingress.certificateSecretRef field, enter a
name of your certificate secret.

In the spec.kommanderCluster.spec.ingress.hostname field, enter your custom
domain name.

##### Configuring a Custom Certificate With Let's Encrypt

About this task

Let's Encrypt is one of the Certificate Authorities (CA) supported by cert-
manager. To set up a Let's Encrypt certificate, create an Issuer or
ClusterIssuer in the target cluster and then reference it in the issuerRef
field of the NKPCluster resource.

Procedure

1. Create the Let's Encrypt ACME cert-manager issuer.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
name: kommander-acme-issuer
spec:
acme:
email: <your_email>
server: https://acme-v02.api.letsencrypt.org/directory
privateKeySecretRef:
name: kommander-acme-issuer-account
solvers:
- dns01:
route53:
region: us-east-1
role: arn:aws:iam::YYYYYYYYYYYY:role/dns-manager
EOF
```

1. Configure the Management cluster to use your custom-domain.example.com with
   a certificate issued by Let's Encrypt by referencing the created
   ClusterIssuer.

```bash
cat <<EOF | kubectl -n kommander --kubeconfig <management_cluster_kubeconfig> patch
nkpcluster \ $(kubectl -n kommander --kubeconfig <management_cluster_kubeconfig> get
nkpcluster -l 'kommander.d2iq.io/host=true' -o jsonpath='{.items[0].metadata.name}')
\ --type='merge' --patch-file=/dev/stdin
spec:
kommanderCluster:
spec:
ingress:
hostname: custom-domain.example.com
issuerRef:
name: custom-acme-issuer
kind: ClusterIssuer
EOF
```

##### Troubleshooting Domain and Certificate Customization

About this task

If you want to ensure the customization for a domain and certificate is
completed, or if you want to obtain more information on the status of the
customization, display the status information for the KommanderCluster. On the
Management cluster:

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

### Disconnecting or Deleting Clusters

About this task

When you attach a cluster that was not created with Kommander, you can later
detach it. This does not alter the cluster's running state but simply removes
it from the NKP UI. User workloads, platform services, and other Kubernetes
resources are not cleaned up at detach.

```yaml
Warning: After successfully detaching the cluster, manually disconnect the attached cluster's Flux installation
from the management Git repository. Otherwise, changes to apps in the managed cluster's workspace will still
be reflected on the cluster you just detached. Ensure your nkp configuration references the target cluster. You
can do this by setting the KUBECONFIG environment variable to the appropriate kubeconfig file location.
For more information, see https://kubernetes.io/docs/tasks/access-application-cluster/configure-
access-multiple-clusters/. An alternative to initializing the KUBECONFIG environment variable is to use the -
kubeconfig=cluster_name.conf flag. Then, run kubectl -n kommander-flux patch gitrepo
management -p '{"spec":{"suspend":true}}' --type merge to make the cluster's workloads not
managed by Kommander, anymore.
```

If you created a managed cluster with Kommander, you cannot disconnect it, but
you can delete it. This completely removes the cluster and all of its cloud
assets.

We recommend deleting a managed cluster through the NKP UI.

```yaml
Warning: If you delete the Management (Konvoy) cluster, you can not use Kommander to delete any Managed
clusters created by Kommander. If you want to delete all clusters, ensure you delete any Managed clusters before finally
deleting the Management cluster.
Statuses: For a list of possible states a cluster can have when it is getting disconnected or deleted, see Cluster
Statuses on page 545.
Troubleshooting: I cannot detach an attached cluster that is "Pending," OR the cluster I deleted through the CLI
still appears in the UI with an "Error" state.
```

Sometimes, detaching or deleting a Kubernetes cluster causes that cluster to
get stuck in a "Pending" or "Error" state. This can happen because the wrong
kubeconfig file is used or the cluster is just not reachable. In order to
detach the cluster so it does not show in the UI, follow these steps:

Procedure

1. Determine the KommanderCluster resource backing the cluster you tried to
   attach/detach.

```bash
kubectl -n WORKSPACE_NAMESPACE get kommandercluster
```

Replace WORKSPACE_NAMESPACE with the actual current workspace name. You can
find this name by going to
`<https://YOUR_CLUSTER_DOMAIN_OR_IP_ADDRESS/nkp/kommander/dashboard/workspaces>`
in your browser. 2. Delete the cluster.

```bash
kubectl -n WORKSPACE_NAMESPACE delete kommandercluster CLUSTER_NAME
```

1. If the resource does not go after a short time, remove its finalizers.

```bash
kubectl -n WORKSPACE_NAMESPACE patch kommandercluster CLUSTER_NAME --type json -p
'[{"op":"remove", "path":"/metadata/finalizers"}]'
```

This removes the cluster from the NKP UI.

### Management Cluster

Editing

Disconnecting

### Cluster Limitations

Clusters have the following limitations:

- Unregistering a cluster on Nutanix Kubernetes Platform (NKP) is not supported.
- Reconfiguring the IP address of the Prism Central VM on Nutanix Kubernetes
  Platform (NKP) is not supported.
- Deploying Objects on the cluster after changing the Prism Central VM IP
  address on Nutanix Kubernetes Platform (NKP) is not supported.
- Changing the Prism Element cluster name after deploying Nutanix Kubernetes
  Platform (NKP) is not supported.
- Changing the Prism Central name after deploying Nutanix Kubernetes Platform
  (NKP) is not supported.

#### IPAM Configuration Change Limitation

Nutanix Kubernetes Platform (NKP) configures IPAM during cluster creation.
Cilium and the Kubernetes controller manager cannot reconcile IPAM changes on
a running cluster, which causes cluster-wide networking issues.

```yaml
Warning: Do not change the IPAM mode, Pod classless inter-domain routing (CIDR), or Service CIDR of an existing,
running NKP cluster.
```

Restriction

On a running NKP cluster, do not perform any of the following actions:

- Change the Cilium IPAM mode. For example, changing from kubernetes to
  cluster-pool.
- Modify the Pod CIDR block.
- Modify the Service CIDR block.
- Expand or shrink the existing Pod or Service CIDR range.

Impact

Any of the preceding changes result in the following outcomes on the cluster:

- Immediate and persistent connectivity disruption for existing workloads.
- Pods that fail to schedule or receive routable IP addresses.
- Cluster networking that cannot be recovered by reverting the change.

Supported Resolution

To change the IPAM configuration, mode, Pod CIDR, or Service CIDR of an NKP
cluster, provision a new Kubernetes cluster with the required IPAM settings.
Then, migrate your workloads to the new cluster.

For more information on creating a cluster with a custom Cilium configuration,
see Creating a Nutanix Cluster With Custom Cilium Configuration on page 748.

### Cluster Statuses

\*: These statuses only appear on Managed clusters.

Table 54: Table

Pending This is the initial state when a cluster is created or connected.

Pending Setup The cluster has networking restrictions that require additional
setup and is not yet connected or attached.

Loading Data The cluster has been added to Kommander, and we are fetching
details about it. This is the status before Active.

Active The cluster is connected to the API server.

Provisioning\* The cluster is being created on your cloud provider. This
process might take some time.

Provisioned\* The cluster's infrastructure has been created and configured.

Joining The cluster is being joined to the management cluster for the
federation.

| Status | Description |
| ------ | ----------- |

Joined The join process is done and waiting for the first data from the
cluster to arrive.

Deleting\* The cluster and its resources are being removed from your cloud
provider. This process might take some time.

Error There has been an error connecting to the cluster or retrieving data
from the cluster.

Join Failed This status can appear when kubefed does not have permission to
create entities in the target cluster.

Unjoining Kubefed is cleaning up after itself, removing all installed
resources on the target cluster.

Unjoined The cluster has been disconnected from the management cluster.

Unjoin Failed The Unjoin from kubefed failed, or there is some other error
with deleting or disconnecting.

Unattached\* The cluster was created manually, and the infrastructure was
configured. However, the cluster is not attached. To resolve this status, see
Attaching an NKP-created Cluster Using the CLI on page 517.

### Cluster Resources

Table 55: Table

CPU Requests The requested portion of the total allocatable CPU resource for
the cluster is measured in number of cores, such as 0.5 cores.

CPU Limits The portion of the total allocatable CPU resource to which the
cluster is limited is measured in number of cores, such as 0.5 cores.

CPU Usage The amount of the allocatable CPU resource being consumed. It cannot
be higher than the configured CPU limit. Measured in number of cores, such as
0.5 cores)

Memory Requests The requested portion of the cluster's total allocatable
memory resource is measured in bytes, such as 64 GiB.

Memory Limits The portion of the allocatable memory resource to which the
cluster is limited is measured in bytes, such as 64 GiB.

| Status | Description |
| ------ | ----------- |

| Resource | Description |
| -------- | ----------- |

Memory Usage The amount of the allocatable memory resource being consumed. It
cannot be higher than the configured memory limit. It is measured in bytes,
such as 64 GiB.

Disk Requests The requested portion of the allocatable ephemeral storage
resource for the cluster is measured in bytes, such as 64 GiB.

Disk Limits The portion of the allocatable ephemeral storage resource to which
the cluster is limited is measured in bytes, such as 64 GiB.

For more detailed information about resources, see the Kubernetes
documentation (`<https://kubernetes.io/docs/>` concepts/configuration/manage-
resources-containers/).

### NKP Platform Applications

Platform Applications are applications that NKP provides pre-built with
functionality such as observability, cost management, monitoring, logging,
making NKP clusters production-ready right from installation.

Platform applications are the applications selected by Nutanix from the open-
source community for use by the NKP platform. You can visit a cluster's detail
page to see which platform applications are enabled under the "Platform
Applications" section.

To ensure that the attached clusters have sufficient resources, see Workspace
Platform Application Defaults and Resource Requirements on page 726. For more
information on platform applications and how to customize them, see Platform
Applications on page 350.

### Cluster Applications and Statuses

The management cluster installs applications. You can visit a cluster's detail
page to see the application dashboards enabled from the deployed applications
under the Application Dashboards section.

Under the Applications section of the cluster's detail page, you can view the
workspace applications enabled for the cluster, grouped by category.

In this section, you can also view the current status of the enabled
applications on the cluster on each application card. Hovering on the status
displays details about the application's status.

To ensure that the attached clusters have sufficient resources, see Workspace
Platform Application Defaults and Resource Requirements on page 726. For more
information on applications and how to customize them, see Workspace Catalog
Applications on page 379

Cluster applications can have one of the following statuses

Table 56: Table

Enabled The application is enabled, but the status on the cluster is not
available.

Pending The application is waiting to be deployed.

Deploying The application is currently being deployed to the cluster.

| Resource | Description |
| -------- | ----------- |

| Status | Description |
| ------ | ----------- |

Deployed The application has successfully been deployed to the cluster.

Error The application failed to deploy to the cluster.

### Custom Cluster Application Dashboard Cards

You can add custom application dashboard cards to the cluster detail page's
Applications section by creating a ConfigMap
on the cluster. The ConfigMap must have a kommander.d2iq.io/application label
applied through the CLI and must contain
both name and dashboardLink data keys to be displayed. Upon creation of the
ConfigMap, the NKP UI displays a card
corresponding to the data provided in the ConfigMap. Custom application cards
have a Kubernetes icon and can link to a
service running in the cluster or use an absolute URL to link to any
accessible URL.

ConfigMap Example

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: "my-app"
namespace: "app-namespace"
labels:
"kommander.d2iq.io/application": "my-app"
data:
name: "My Application"
dashboardLink: "/path/to/app"
```

Table 57: Table

```bash
metadata.labels."kommander.d2iq.io/
application"
```

The application name (ID). X

data.name The display name that describes the application and displays on the
custom application card in the UI.

X

data.dashboardLink The link to the application. This can be an absolute link,
https:// `<www.d2iq.com>` or a relative link, /nkp/kommander/dashboard. If you
use a relative link, the link is built using the cluster's path as the base of
the URL to the application.

X

data.docsLink Link to documentation about the application. This is displayed
on the application card but is omitted if it is not present.

| Status | Description |
| ------ | ----------- |

| Key | Description | Required |
| --- | ----------- | -------- |

data.category Category with which to group the custom application. If not
provided, the application is grouped under the category, "None."

data.version A version string for the application. If not provided, "N/ A" is
displayed on the application card in the UI.

Use a command similar to this to create a new custom application ConfigMap:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
name: "my-app"
namespace: "default"
labels:
"kommander.d2iq.io/application": "my-app"
data:
name: "My Application"
dashboardLink: "/path/to/app"
EOF
```

### Kubernetes Cluster Federation (KubeFed)

For more information, see `<https://github.com/kubernetes-retired/kubefed>`.

NKP uses KubeFed to manage multiple clusters from the management cluster and
also to federate various resources. A KubefedCluster object is automatically
created for each attached cluster and joined to the management cluster. After
they are joined, namespaces can be federated to the clusters - this is how you
get workspace and project namespaces created on the attached clusters. From
here, other resources can be federated into those namespaces, such as
ConfigMaps, RBAC, and so on.

See the following pages for more information:

- `<https://github.com/kubernetes-sigs/kubefed/blob/master/docs/concepts.md>`
- `<https://github.com/kubernetes-sigs/kubefed/blob/master/docs/userguide.md>`

### Stopping an NKP Cluster

Before you begin

- Stop the applications and pods in the NKP cluster. This helps reduce the
  possibility of data corruption.
- Take a backup of the Kubernetes cluster. For more information, see Velero
  Backup.

> **Note:**

| Key | Description | Required |
| --- | ----------- | -------- |

- This procedure is applicable to all infrastructure providers. However, the
  example provided in this topic is based on a Nutanix deployment.
- Steps 2, 3, 4, and 5 are specific to Nutanix AHV environments. However, the
  other infrastructure providers can also use similar steps to shutdown the
  NKP VMs.

About this task

To shut down an NKP cluster, follow these steps:

Procedure

1. Pause remediation of the managed cluster on the management cluster:

```bash
kubectl patch cluster <clustername> -n <namespace> --type merge -p '{"spec":
{"paused": true}}'
```

This annotates the workload cluster to stop remediation. 2. In Prism Central
UI, shut down the nodes.

a. Log in to Prism Central.

b. In the top-left corner, click the menu icon.

c. Select Compute > VMs > Filters.

d. Select the Name checkbox, change the option to Starts with, and type the
following:

```bash
nkp_cluster_name-
```

Where, nkp_cluster_name- is the name of the NKP cluster.

e. Ensure that the filter displays only the desired Kubernetes cluster nodes.

f. Select the virtual machines with the text md in their name. 3. Soft
shutdown the worker node virtual machines.

a. With the worker node virtual machines selected, click Actions > Guest
Shutdown.

b. Click OK to confirm. 4. After the worker node virtual machines are powered
off, perform the following for control plane virtual machines.

a. Clear the selection of worker node virtual machines.

b. Select the control plane virtual machines.

The control plane virtual machines do not have the text md in their name.

c. With the control plane virtual machine selected, click Actions > Guest
Shutdown.

d. Click OK to confirm. 5. Soft shutdown the control plane virtual machine.

a. With the control plane virtual machines selected, click Actions > Guest
Shutdown.

b. Click OK to confirm. 6. Restart the cluster. For more information, see
Starting an NKP Cluster on page 551.

### Starting an NKP Cluster

About this task

To start an NKP cluster, follow these steps:

> **Note:**

- This procedure is applicable to all infrastructure providers. However, the
  example provided in this topic is based on a Nutanix deployment.
- Steps 1, 2, and 4 are specific to Nutanix AHV environments. However, the
  other infrastructure providers can also use similar steps to shutdown the
  NKP VMs.

Procedure

1. Use Prism Central UI to select the control plane virtual machines.

a. Log in to Prism Central.

b. In the top-left corner, click the menu icon.

c. Select Compute > VMs > Filters.

d. Select the Name checkbox, change the option to Starts with, and type the
following:

```bash
nkp_cluster_name-
```

Where, nkp_cluster_name- is the name of the NKP cluster.

e. Ensure that the filter is only displays the desired Kubernetes cluster nodes.

f. Select the virtual machines. 2. Start all control plane virtual machines.

a. Perform Step 1 for control plane virtual machines.

b. Power on the control plane. 3. Use SSH to log on to one of the control
plane virtual machines to check the control plane status.

a. To verify that the control plane virtual machines are up, use the kubectl
to check for the Ready status.

```bash
watch kubectl get nodes
```

b. If the control plane virtual machines display a NotReady status, verify the
etcd health and connectivity within the control plane VMs. 4. Start all the
worker node virtual machines.

a. Perform Step 1 for worker node virtual machines.

- Clear the control plane virtual machines.
- Select the virtual machines with the text md in their name.

b. Power on the workers node virtual machines. 5. Use SSH to log on to one of
the control plane virtual machines to check the cluster status and uncordon
the worker node virtual machines.

a. To verify that all worker node virtual machines are up, use the kubectl to
check for the Ready,

SchedulingDisabled status.

```bash
watch kubectl get nodes
```

b. Verify that all pods are up. Use the kubectl to check for the Running status.

```bash
watch kubectl get pods --all-namespaces
```

1. Re-enable remediation for the cluster on the management cluster:

```bash
kubectl patch cluster <clustername> -n <namespace> --type merge -p '{"spec":
{"paused": false}}'
```

This annotates the cluster to re-enable remediation. 7. In the NKP UI, verify
that the cluster status is healthy.

### Disabling Automatic Onboarding During Cluster Upgrade

About this task

Perform the following steps to disable automatic onboarding of clusters during
an upgrade:

Procedure

1. Generate the upgrade manifest with --dry-run --output flag:

```bash
nkp cluster upgrade nutanix --cluster-name <CLUSTER_NAME> --dry-run --output yaml >
upgrade-manifest.yaml
```

1. Edit the generated manifest and remove the konnectorAgent section from the
   cluster resource's add-ons: Remove or comment out the konnectorAgent section
   from addons:

```bash
# konnectorAgent:
# credentials:
# secretRef:
# name: <CLUSTER_NAME>-pc-credentials-for-konnector-agent
```

1. Remove the konnectorAgent credentials secret from the manifest (if
   present): Remove the Secret with the name:

```bash
<CLUSTER_NAME>-pc-credentials-for-konnector-agent
```

1. Apply the modified manifest:

```bash
kubectl apply -f upgrade-manifest.yaml
```

### Re-Enable Automatic Onboarding During Cluster Upgrade

Before you begin

- You must have access to the Prism Central credentials for the secret.
- kubectl must be configured to connect with the management cluster here the
  cluster resources are available.
- Verify that the konnector-agent is disabled by inspecting the cluster
  resource information. The clusterConfig variable will not contain
  konnectorAgent section in the addons.

About this task

If konnectorAgent was disabled when your cluster was created, perform the
following steps during an upgrade to enable it:

Procedure

1. Run the upgrade command with --dry-run --output yaml to generate the
   Cluster spec and any related resources without applying changes. Use the
   same VM image flags you would use for a real upgrade. For example:

```bash
./nkp upgrade cluster nutanix \
--cluster-name <your-cluster-name> \
--dry-run --output yaml \
<other required params> ...\
--kubeconfig kubeconfig.conf \
> upgrade.yaml
```

Replace:

- `<your-cluster-name>`: with the name of your cluster.
- `<other required params>`: to include other required parameters, such as
  --worker-vm-images, --vm- image.

The upgrade.yaml file generated contains the cluster resources and other
resources that will be applied during the upgrade. 2. Add the konnectorAgent
add-on in the cluster spec: Open the upgrade.yaml and locate the cluster
resource.

```bash
apiVersion: cluster.x-k8s.io/xxx, kind: Cluster
```

Under spec.topology.variables, locate the entry with the name clusterConfig.

Add the konnectorAgent section under value.addons alongside any existing ones
(such as CSI, COSI). If the add-ons section does not exist, you must create
it. The following is a snippet as an example of adding the konnectorAgent in
the cluster resource:

```bash
# Cluster resource (excerpt)
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
name: <cluster-name> # e.g. nkp-test-cluster
namespace: default
spec:
topology:
class: nkp-nutanix-2-18-...
version: v1.3x.x
variables:
- name: clusterConfig
value:
# ... other fields (controlPlane, nutanix, etc.) ...
addons:
```

## ... existing addons (csi, cosi, etc.) if present ... konnectorAgent

credentials: secretRef: name: `<cluster-name>`-pc-credentials-for-konnector-
agent

The secret name must be `<cluster-name>`-pc-credentials-for-konnector-agent,
where `<cluster-name>` is the cluster metadata name. 3. Add the KonnectorAgent
secret to the YAML:

Add a Secret that contains the Prism Central credentials used by the
KonnectorAgent. You must add it to the same upgrade.yaml file as a first
document, or in a separate file and apply both.

The secret name must be `<cluster-name>`-pc-credentials-for-konnector-agent,
where `<cluster-name>` is the cluster metadata name.

The following example is a sample secret:

```bash
---
apiVersion: v1
kind: Secret
metadata:
name: <cluster-name>-pc-credentials-for-konnector-agent
namespace: default
labels:
cluster.x-k8s.io/provider: nutanix
konvoy.d2iq.io/cluster-name: <cluster-name>
konvoy.d2iq.io/provider: nutanix
type: Opaque
data:
username: <base64-encoded-prism-central-username>
password: <base64-encoded-prism-central-password>
```

The following is an example with placeholder base64 values:

```bash
---
apiVersion: v1
data:
password: bGNIQU9DSVVHM1k2NFhSd2FQWjdUTjEwZjI1ZFM4Zzk=
username: Y29lcmqqTlFTV2RN
kind: Secret
metadata:
labels:
cluster.x-k8s.io/provider: nutanix
konvoy.d2iq.io/cluster-name: nkp-test-cluster
konvoy.d2iq.io/provider: nutanix
name: nkp-test-cluster-pc-credentials-for-konnector-agent
namespace: default
type: Opaque
```

To generate base64 values from plain text, run the following:

```bash
echo -n 'your-username' | base64
echo -n 'your-password' | base64
```

1. Apply the modified manifest:

```bash
kubectl apply -f upgrade.yaml
```

If the Secret is in a separate file:

```bash
kubectl apply -f konnector-agent-secret.yaml
kubectl apply -f upgrade.yaml
```

After applying this, the cluster will upgrade and the konnectorAgent add-on
will be installed, registering the cluster with Prism Central.

## Backup and Restore

For production clusters, regular maintenance should include routine backup
operations to ensure data integrity and reduce the risk of data loss due to
unexpected events. Backup operations should include the cluster state,
application state, and the running configuration of both stateless and
stateful applications in the cluster.

NKP stores all data as CRDs in the Kubernetes API, and you can back it up and
restore it. Choose a procedure depending on your infrastructure provider:

### Velero Configuration

- Velero Backup on page 576

## Backup and Restore (2)

NKP offers two primary approaches for configuring Velero backup storage:

- Integrated Rook Ceph: For default installations, NKP deploys Velero
  integrated with Rook Ceph, operating within the same cluster.
- External Object Storage: You can configure Velero to use external S3
  compatible object storage solutions, such as Nutanix Objects or cloud
  provider storage.

For production use cases, use an S3-compatible object store that resides
outside the Kubernetes cluster as the backup storage location for Velero.
Nutanix Objects and AWS S3 provide reliable external storage options.

For more information about Velero, see Velero.

For more information about Rook Ceph, see Rook.

To use Nutanix Objects buckets for Velero backup operations, you configure
Velero with the Nutanix Objects storage plug-in, create backup locations, and
set up credentials. Velero can then back up and restore cluster resources such
as persistent volumes, namespaces, and workloads using the Nutanix Objects
storage plug-in.

For information about configuring Velero with Nutanix Objects buckets when
Rook Ceph is deployed, see Configuring Velero to use Nutanix Objects Bucket as
Default BSL on page 557.

For information about configuring Velero with Nutanix Objects buckets without
Rook Ceph components, see Configuring Velero to use Nutanix Objects Bucket
without Rook Ceph on page 560.

### Preparing Velero to Work with Nutanix Objects

Set up environment variables and credentials to configure Velero with Nutanix
Objects buckets for backup storage.

Before you begin

Ensure that your environment meets the following requirements:

- Velero is installed (included in the default Nutanix Kubernetes® Platform
  (NKP) installation).
- Velero CLI is installed. For more information, see Velero Installation Using
  CLI on page 576.
- You have created an S3 bucket with Nutanix Objects and configured access.
  For more information, see Creating and Configuring Buckets.

> **Note: This is an S3-compliant bucket, and many configuration parameters
> use the S3 style.**

- When using the fully qualified domain name (FQDN) for the Nutanix Objects
  endpoint, ensure it resolves from within the cluster. If the FQDN resolution
  fails, update the cluster DNS (such as CoreDNS) so that the pods can resolve
  the endpoint.
- For NKP management clusters, disable rook-ceph, rook-ceph-cluster, and
  velero immediately after applying the Ultimate License because the license
  automatically deploys these components. If these components are already
  deployed, you must disable or delete them before proceeding.

About this task

Before configuring Velero to work with Nutanix Objects buckets, you must
prepare the environment by setting required variables and creating
credentials. This process involves configuring environment variables for
connectivity and authentication, then creating the necessary Kubernetes
secrets for Velero to access your Nutanix Objects buckets.

Procedure

1. Set the core environment variables for Nutanix Objects connectivity:

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
export S3_REGION=us-east-1
export NUTANIX_OBJECTS_HOST=<nutanix_objects_host_or_ip>
export NUTANIX_OBJECTS_PORT=<nutanix_objects_port>
export NUTANIX_OBJECTS_ACCESS_KEY_ID=<nutanix_objects_key_id>
export NUTANIX_OBJECTS_SECRET_ACCESS_KEY=<nutanix_objects_key_secret>
export AWS_PROFILE=<bucket_name>
export REMOTE_STORE_SECRET=<bucket_name>
export BUCKET=<bucket_name>
export BSL_NAME=<bucket_name>
export CLUSTER_NAME=<target_cluster>
Note: For simplicity and consistency, use the same name for AWS_PROFILE, REMOTE_STORE_SECRET,
BUCKET, and BSL_NAME. Match these names to your bucket name.
```

Example:

```bash
export WORKSPACE_NAMESPACE=kommander
export S3_REGION=us-east-1
export NUTANIX_OBJECTS_HOST=x.x.x.100
export NUTANIX_OBJECTS_PORT=443
export NUTANIX_OBJECTS_ACCESS_KEY_ID=DUMMY_ACCESS_KEY_ID
export NUTANIX_OBJECTS_SECRET_ACCESS_KEY=DUMMY_SECRET_ACCESS_KEY
export AWS_PROFILE=velerobucket1
export REMOTE_STORE_SECRET=velerobucket1
export BUCKET=velerobucket1
export BSL_NAME=velerobucket1
export CLUSTER_NAME=my-target-cluster
```

- WORKSPACE_NAMESPACE: The workspace namespace such as kommander for the
  management cluster or any workspace namespace for attached or managed
  clusters. To list the namespace of a cluster:

```bash
kubectl get nkpcluster -A | grep "NAMESPACE|${CLUSTER_NAME}"
```

- CLUSTER_NAME: The name of the target cluster where you set up Velero.
- BUCKET: The name of the Nutanix Objects bucket that you want to use as a
  backup storage.

1. Prepare your Nutanix Objects bucket credentials. To integrate Velero with
   Nutanix Objects, you need an access key and a secret key.

```yaml
Note: Each cluster must have its own bucket. If you use different credentials to access the BackupStorageLocation
(BSL), you can create multiple secrets that support the creation of more than one BSL. The AWS_PROFILE field
maps each secret to its BSL.
```

For more information about generating access keys, see Generating Access Key
for API Users. 3. Create the Velero secret on the cluster. Export your
credentials as environment variables and create the Kubernetes secret. You
must create this secret on the cluster where you deploy Velero such as
management, managed, or attached.

```yaml
Important: If you are an NKP Pro license user with multiple workload clusters attached to a workspace, create
this secret in each cluster before updating the AppDeployment overrides. For more information, see Configuring
Velero to use Nutanix Objects Bucket as Default BSL on page 557.
```

In this example, the name of the secret is velero-nutanix-credentials, and the
name of the profile is ntnx- object-nkp.

Use the same name for AWS_PROFILE, BUCKET, and BSL_NAME in the next step.

Example:

```bash
export NUTANIX_OBJECTS_SECRET=velero-nutanix-credentials
export AWS_PROFILE=ntnx-object-nkp
export NUTANIX_OBJECTS_ACCESS_KEY_ID=<nutanix-objects-access-key>
export NUTANIX_OBJECTS_SECRET_ACCESS_KEY=<nutanix-objects-secret-key>
kubectl --kubeconfig=${CLUSTER_NAME}.conf apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
name: ${NUTANIX_OBJECTS_SECRET}
namespace: ${WORKSPACE_NAMESPACE}
type: Opaque
stringData:
aws: |
[${AWS_PROFILE}]
aws_access_key_id = ${NUTANIX_OBJECTS_ACCESS_KEY_ID}
aws_secret_access_key = ${NUTANIX_OBJECTS_SECRET_ACCESS_KEY}
EOF
```

#### Configuring Velero to use Nutanix Objects Bucket as Default BSL

Configure Velero to use Nutanix Objects as the default backup location by
overriding the default BackupStorageLocation (BSL) setting with a specified
connection details of Nutanix Objects bucket.

Before you begin

Complete the environment preparation steps described in Preparing Velero to
Work with Nutanix Objects on page 555.

About this task

This procedure overrides the default BackupStorageLocation (BSL) to use the
specified Nutanix Objects bucket.

If overriding the default BSL is not your intended outcome, see Adding
Additional Backup Storage Locations on page 562 or modify the
backupStorageLocation configuration to retain the existing default BSL
configured with Ceph Object store as the backend.

Procedure

1. Create a ConfigMap to configure Velero with Nutanix Objects bucket settings.

The ConfigMap directs Velero to use the Nutanix Objects bucket as the backup
storage location. The configuration includes environment variables that
provide connection details for the Nutanix Objects bucket, and references the
access key secret created in the preparation steps.

The following examples use a bucket named ntnx-object-nkp in the BSL
configuration:

- Configuration with certificate validation:

```bash
export BUCKET=ntnx-object-nkp
export BSL_NAME=ntnx-object-nkp
export NUTANIX_OBJECTS_HOST=<nutanix-objects-hostname-or-ip>
export NUTANIX_OBJECTS_PORT=443
export NUTANIX_OBJECTS_SECRET=velero-nutanix-credentials
export AWS_PROFILE=ntnx-object-nkp
kubectl --kubeconfig ${CLUSTER_NAME}.conf apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
namespace: ${WORKSPACE_NAMESPACE}
name: velero-overrides
data:
values.yaml: |
credentials:
extraSecretRef: ""
configuration:
features: EnableCSI
backupStorageLocation:
- name: ${BSL_NAME}
bucket: ${BUCKET}
provider: "aws"
default: true
caCert:
LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURmekNDQW1lZ0F3SUJBZ0lRRS9OMWcydktjaU5nZVBBd3R5bzNq
config:
region: us-east-1
s3ForcePathStyle: "true"
insecureSkipTLSVerify: "false"
s3Url: "https://${NUTANIX_OBJECTS_HOST}"
# profile should be set to the AWS profile name mentioned in the
secret
profile: ${AWS_PROFILE}
credential:
key: aws
name: ${NUTANIX_OBJECTS_SECRET}
deployNodeAgent: true
nodeAgent:
podVolumePath: /var/lib/kubelet/pods
tolerations:
- operator: Exists
EOF
```

- Configuration without certificate validation:

```bash
export BUCKET=ntnx-object-nkp
export BSL_NAME=ntnx-object-nkp
export NUTANIX_OBJECTS_HOST=<nutanix-objects-hostname-or-ip>
export NUTANIX_OBJECTS_PORT=443
export NUTANIX_OBJECTS_SECRET=velero-nutanix-credentials
export AWS_PROFILE=ntnx-object-nkp
kubectl --kubeconfig ${CLUSTER_NAME}.conf apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
namespace: ${WORKSPACE_NAMESPACE}
name: velero-overrides
data:
values.yaml: |
credentials:
extraSecretRef: ""
configuration:
features: EnableCSI
backupStorageLocation:
- name: ${BSL_NAME}
bucket: ${BUCKET}
provider: "aws"
default: true
config:
region: us-east-1
s3ForcePathStyle: "true"
insecureSkipTLSVerify: "true"
s3Url: "https://${NUTANIX_OBJECTS_HOST}"
# profile should be set to the AWS profile name mentioned in the (2)
secret
profile: ${AWS_PROFILE}
credential:
key: aws
name: ${NUTANIX_OBJECTS_SECRET}
deployNodeAgent: true
nodeAgent:
podVolumePath: /var/lib/kubelet/pods
tolerations:
- operator: Exists
EOF
Note: The BackupStorageLocation field supports multiple BSL configurations. You can also add additional
BSLs later by connecting directly to the cluster, as described in Adding Additional Backup Storage
Locations on page 562.
```

1. Update the Velero AppDeployment to reference the ConfigMap. The
   AppDeployment must reference the ConfigMap that contains the override
   settings.

The following configuration updates Velero across all clusters in a workspace:

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf -n ${WORKSPACE_NAMESPACE} patch
appdeployment velero --type="merge" --patch-file=/dev/stdin <<EOF
spec:
configOverrides:
name: velero-overrides
EOF
```

When the workspace contains multiple clusters, use clusterConfigOverrides and
create multiple override ConfigMaps because each cluster requires its own
Nutanix Objects bucket. For more information, see Customizing an Application
Per Cluster on page 375. 3. Verify the ConfigMap reference in the HelmRelease
object.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get hr -n kommander velero -o
jsonpath='{.spec.valuesFrom[?(@.name=="velero-overrides")]}'
```

After a successful deployment, the following output appears:

```bash
{"kind":"ConfigMap","name":"velero-overrides"}
```

1. Verify that the Velero pod is running.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get pods -A | grep velero
```

1. Verify the BSL status.

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get bsl -n ${WORKSPACE_NAMESPACE} default
```

> **Note: Ensure that the phase displays as Available.**

##### Configuring Velero to use Nutanix Objects Bucket without Rook Ceph

Deploy Velero using Nutanix Objects or another S3-compatible store without
enabling Rook Ceph in the cluster.

Before you begin

Complete the environment preparation steps described in Preparing Velero to
Work with Nutanix Objects on page 555.

```yaml
Note: The following section creates the secret for the BSL connection to Nutanix Objects. You can skip the secret
creation step in the preparation phase. To create the secret directly in the cluster instead, follow the preparation steps
and omit the secretContents section in the configuration.
```

About this task

This procedure configures Velero to use Nutanix Objects buckets as a backup
storage location without deploying Rook Ceph components. This approach is
suitable for environments that use external object storage instead of the
integrated Rook Ceph solution.

> **Important:**

- For Nutanix Kubernetes® Platform (NKP) Management Clusters, disable rook-
  ceph, rook- ceph-cluster, and velero immediately after applying the Ultimate
  License because the license automatically deploys these components. If NKP
  deploys these components, you must disable or delete them before proceeding.
- In the following example the AppDeployent override is set using NKP GUI.
  However, you can set the AppDeployent override using the NKP CLI as shown in
  Configuring Velero to use Nutanix Objects Bucket as Default BSL on page 557.

Procedure

1. Generate the ApplicationDeployment overrides configuration:

```bash
cat <<EOF >/dev/stdout
credentials:
extraSecretRef: ""
name: ${REMOTE_STORE_SECRET}
secretContents:
aws: |
[${AWS_PROFILE}]
aws_access_key_id = ${NUTANIX_OBJECTS_ACCESS_KEY_ID}
aws_secret_access_key = ${NUTANIX_OBJECTS_SECRET_ACCESS_KEY}
configuration:
features: EnableCSI
backupStorageLocation:
- name: ${BSL_NAME}
bucket: ${BUCKET}
provider: "aws"
default: true
config:
region: us-east-1
s3ForcePathStyle: "true"
insecureSkipTLSVerify: "true"
s3Url: https://${NUTANIX_OBJECTS_HOST}:${NUTANIX_OBJECTS_PORT}
profile: ${AWS_PROFILE}
credential:
key: ${AWS_PROFILE}
name: ${REMOTE_STORE_SECRET}
deployNodeAgent: true
nodeAgent:
podVolumePath: /var/lib/kubelet/pods
tolerations:
- operator: Exists
EOF
```

Copy the output for use in the NKP UI. 2. Configure Velero using the NKP UI.

a. Log in to the NKP UI.

b. Navigate to the Applications tab for the workspace where you are
configuring Velero.

c. Search for Velero and click Enable.

d. In the configuration panel, paste the output from the previous command and
click Enable.

```yaml
Note: If there are multiple clusters in the workspace, each cluster requires its own configuration because the
bucket and Nutanix Objects keys are different for each cluster. In this case, set the override values in each
cluster's configuration instead of the global configuration.
```

Ignore the warning about rook-ceph-cluster dependency not being met. This is
expected when deploying Velero without Rook Ceph. 3. (Optional) If the velero-
pre-install job blocks Velero installation for an hour and rook-ceph-cluster
is not deployed, delete the original job and create a new one that completes
successfully. Run the following command from a Linux/Mac terminal that has
access to the target cluster and has kubectl installed:

```bash
kubectl delete job -n ${WORKSPACE_NAMESPACE} velero-pre-install
kubectl apply -f - << EOF
apiVersion: batch/v1
kind: Job
metadata:
labels:
kustomize.toolkit.fluxcd.io/name: velero-pre-install
kustomize.toolkit.fluxcd.io/namespace: ${WORKSPACE_NAMESPACE}
name: velero-pre-install
namespace: ${WORKSPACE_NAMESPACE}
spec:
template:
spec:
containers:
- name: pre-install
command:
- sh
- -c
- "sleep 1"
image: ${IMAGE}
restartPolicy: OnFailure
EOF
```

1. Verify the Velero installation.

a. Verify that the Velero pod is running:

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get pods -A | grep velero
```

b. Verify the BackupStorageLocation (BSL):

```bash
kubectl --kubeconfig=${CLUSTER_NAME}.conf get bsl -n ${WORKSPACE_NAMESPACE}
default
```

> **Note: Ensure that the phase is displayed as Available.**

Velero is now configured to use Nutanix Objects bucket as the backup storage
location without requiring Rook Ceph components. You can now create backups
and restore operations using the external object storage.

##### Adding Additional Backup Storage Locations

Create multiple BackupStorageLocation (BSL) resources that reference different
Nutanix Objects buckets.

Before you begin

Complete the environment preparation steps described in Preparing Velero to
Work with Nutanix Objects on page 555.

About this task

You can create multiple BackupStorageLocation (BSL) resources to reference
different Nutanix Objects buckets. This configuration supports scenarios where
different applications or clusters require separate backup destinations.

Procedure

1. (Optional) Create a secret for buckets that use different credentials or
   key pairs:

```yaml
Note: You can create multiple secrets to support more than one BackupStorageLocation (BSL) when different
credentials are required for bucket access. The AWS_PROFILE field references the secret, and the BSL
configuration links them together.
export NUTANIX_OBJECTS_SECRET=velero-nutanix-two
export AWS_PROFILE=ntnx-objects-two
export NUTANIX_OBJECTS_ACCESS_KEY_ID=<nutanix-objects-access-key>
export NUTANIX_OBJECTS_SECRET_ACCESS_KEY=<nutanix-objects-secret-key>
export BUCKET=ntnx-obj-two
export BSL_NAME=ntnx-obj-two
export NUTANIX_OBJECTS_HOST=<nutanix-objects-hostname-or-ip>
export NUTANIX_OBJECTS_PORT=443
kubectl --kubeconfig=${CLUSTER_NAME}.conf apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
name: ${NUTANIX_OBJECTS_SECRET}
namespace: ${WORKSPACE_NAMESPACE}
type: Opaque
stringData:
aws: |
[${AWS_PROFILE}]
aws_access_key_id = ${NUTANIX_OBJECTS_ACCESS_KEY_ID}
aws_secret_access_key = ${NUTANIX_OBJECTS_SECRET_ACCESS_KEY}
EOF
```

1. Create a Backup Storage Location.

a. Create a backup location that references an existing Nutanix Objects bucket:

```bash
velero --kubeconfig ${CLUSTER_NAME}.conf backup-location create
${BSL_NAME} -n ${WORKSPACE_NAMESPACE} --provider aws --bucket ${BUCKET}
--credential ${NUTANIX_OBJECTS_SECRET}=aws --config region=us-
east-1,insecureSkipTLSVerify="true",s3ForcePathStyle="true",profile=
${AWS_PROFILE},s3Url=https://${NUTANIX_OBJECTS_HOST}:${NUTANIX_OBJECTS_PORT}
```

b. Verify that the backup storage location is Available and references the
correct Nutanix Objects bucket:

```bash
kubectl get backupstoragelocations -n ${WORKSPACE_NAMESPACE} -oyaml
Note: If the BackupStorageLocation is not Available, you can view any error events: kubectl describe
backupstoragelocations -n ${WORKSPACE_NAMESPACE}
```

1. Create a test backup.

a. Create a test backup in the backup location you created:

```bash
velero backup create nutanix-velero-testbackup -n ${WORKSPACE_NAMESPACE} --
kubeconfig=${CLUSTER_NAME}.conf --storage-location <aws-backup-location-name> --
snapshot-volumes=false
```

b. View the backup details:

```bash
velero backup describe nutanix-velero-testbackup
```

#### Usage of Velero with AWS S3 Buckets

You can configure Velero for non-default backup location or modify the
kommander.yaml file for management or Pro clusters based on your
infrastructure needs. By setting up a backup location, you ensure reliable and
scalable data protection using AWS S3 buckets.

##### Velero with AWS: Preparing your Environment

Before you begin

- Ensure you have installed Velero (included in the default NKP installation).
- Ensure you have installed the Velero CLI. For more information, see Velero
  Installation Using CLI on page 576.
- Ensure that you have created an S3 bucket with AWS. For more information,
  `<https://docs.aws.amazon.com/>` AmazonS3/latest/userguide/creating-
  bucket.html.

Procedure

1. Set the environment variables.

a. Set the BUCKET environment variable to the name of the S3 bucket you want
to use as backup storage.

```bash
export BUCKET=<aws-bucket-name>
```

b. Set the WORKSPACE_NAMESPACE environment variable to the name of the
workspace's namespace. Replace

`<workspace_namespace>` with the name of the target workspace.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

This can be the kommander namespace for the Management cluster or any other
additional workspace namespace for attached or managed clusters. To list all
available workspace namespaces, use the kubectl get nkpcluster -A command.

c. Set the CLUSTER_NAME environment variable. Replace `<target_cluster>` with
the name of the cluster where you want to set up Velero.

```bash
export CLUSTER_NAME=<target_cluster>
```

1. Prepare your AWS credentials.

For details on how to use IAM roles instead of static credentials, see
`<https://github.com/vmware-tanzu/velero->` plugin-for-aws.

a. Create a file containing your static AWS credentials. In this example, the
file's name is aws-credentials.

```bash
cat << EOF > aws-credentials
[default]
aws_access_key_id=<REDACTED>
aws_secret_access_key=<REDACTED>
EOF
```

b. Create a secret on the cluster where you are installing and configuring
Velero by referencing the file created in the previous step. This can be the
Management, a Managed, or an Attached cluster. In this example, the secret's
name is velero-aws-credentials.

```bash
kubectl create secret generic -n ${WORKSPACE_NAMESPACE} velero-aws-credentials --
from-file=aws=aws-credentials --kubeconfig=${CLUSTER_NAME}.conf
```

##### Velero with AWS: Configuring Velero

Customize Velero to allow the configuration of a non-default backup location.

Procedure

1. Create a ConfigMap to enable Velero to use AWS S3 buckets as backup storage
   location.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
namespace: ${WORKSPACE_NAMESPACE}
name: velero-overrides
data:
values.yaml: |
credentials:
extraSecretRef: ""
configuration:
backupStorageLocation:
- bucket: ${BUCKET}
name: <YOUR-NEW-BACKUP-STORAGE-LOCATION-NAME> # If you don't specify a unique
name, it will use "default" as the name of the bakcupstoragelocation
provider: "aws"
config:
region: <your-aws-region> # such as us-west-2
s3ForcePathStyle: "false"
insecureSkipTLSVerify: "false"
s3Url: ""
profile: <your-aws-profile> # profile should be set to the AWS profile name
mentioned in the secret
credential:
name: velero-aws-credentials
key: aws
EOF
```

1. Patch the Velero AppDeployment to reference the created ConfigMap with the
   Velero overrides.

a. To update Velero in all clusters in a workspace:

```bash
cat << EOF | kubectl -n ${WORKSPACE_NAMESPACE} patch appdeployment velero --
type="merge" --patch-file=/dev/stdin
spec:
configOverrides:
name: velero-overrides
EOF
```

To update Velero for a specific cluster in a workspace and customize an
application per cluster, see Customizing an Application Per Cluster on page
\375. 3. Check the ConfigMap on the HelmRelease object.

```bash
kubectl get hr -n kommander velero -o jsonpath='{.spec.valuesFrom[?(@.name=="velero-
overrides")]}'
```

The output looks like this if the deployment is successful:

```bash
{"kind":"ConfigMap","name":"velero-overrides"}
```

1. Verify that the Velero pod is running.

```bash
kubectl get pods -A --kubeconfig=${CLUSTER_NAME}.conf |grep velero
```

##### Velero with AWS: Configuring Velero By Editing the kommander.yaml File

This is an alternative configuration path for management or Pro clusters. You
can also configure Velero by editing the kommander.yaml and rerunning the
installation. To follow this alternative configuration path, expand the
following section:

About this task

Configure Velero on the Management Cluster:

Procedure

1. Refresh the kommander.yaml to add the customization of Velero.

```yaml
Warning: Before running this command, ensure the kommander.yaml is the configuration file you are currently
using for your environment. Otherwise, your previous configuration will be lost.
nkp install kommander -o yaml --init > kommander.yaml
```

1. Configure NKP to load the plugins and to include the secret in the
   apps.velero section. This process has been tested to work with plugins for
   AWS v1.1.0 and Azure v1.5.1. More recent versions of these plugins can be
   used, but have not been tested by Nutanix.

```bash
...
velero:
values: |
configuration:
backupStorageLocation:
bucket: ${BUCKET}
config:
region: <AWS_REGION> # such as us-west-2
s3ForcePathStyle: "false"
insecureSkipTLSVerify: "false"
s3Url: ""
# profile should be set to the AWS profile name mentioned in the secret
profile: default
credentials:
# With the proper IAM permissions with access to the S3 bucket,
# you can attach the EC2 instances using the IAM Role, OR fill in
"existingSecret" OR "secretContents" below.
#
# Name of a pre-existing secret (if any) in the Velero namespace
# that should be used to get IAM account credentials.
existingSecret: velero-aws-credentials
# The key must be named "cloud", and the value corresponds to the entire
content of your IAM credentials file.
# For more information, consult the documentation for the velero plugin for
AWS at:
# [AWS] https://github.com/vmware-tanzu/velero-plugin-for-aws/blob/main/
README.md
secretContents:
# cloud: |
# [default]
# aws_access_key_id=<REDACTED>
# aws_secret_access_key=<REDACTED>
...
```

1. Use the modified kommander.yaml configuration to install this Velero
   configuration.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

1. Check the ConfigMap on the HelmRelease object.

```bash
kubectl get hr -n kommander velero -o jsonpath='{.spec.valuesFrom[?(@.name=="velero-
overrides")]}'
```

The output looks like this if the deployment is successful:

```bash
{"kind":"ConfigMap","name":"velero-overrides"}
```

1. Verify that the Velero pod is running.

```bash
kubectl get pods -A --kubeconfig=${CLUSTER_NAME}.conf |grep velero
```

##### Velero with AWS: Establishing a Backup Location

Procedure

1. Create a Backup Storage Location.

a. Create a new backup storage location by specifying a unique name during the
creation of velero-overrides ConfigMap. For creating velero-overrides
ConfigMap, see Velero with AWS: Configuring Velero.

b. Check that the backup storage location is Available and that it references
the correct S3 bucket.

```bash
kubectl get backupstoragelocations -n ${WORKSPACE_NAMESPACE} -oyaml
Note: If the BackupStorageLocation is not Available, view any error events by using: kubectl describe
backupstoragelocations -n ${WORKSPACE_NAMESPACE}
```

1. Create a test backup.

a. Create a test backup that is stored in the location you created in the
previous section.

```bash
velero backup create aws-velero-testbackup -n ${WORKSPACE_NAMESPACE} --kubeconfig=
${CLUSTER_NAME}.conf --storage-location <aws-backup-location-name> --snapshot-
volumes=false
```

b. View your backup.

```bash
velero backup describe aws-velero-testbackup
```

#### Usage of Velero with Azure Blob Containers

First, you must create an Azure storage account, generate access credentials,
and set up the required container. Then, you install Velero with the Azure
plug-in, configure environment variables, and validate the setup to back up
and restore the cluster resources, such as persistent volumes, namespaces, and
workloads, using Azure Blob Containers.

##### Velero with Azure: Preparing your Environment

Before you begin

- Ensure you have installed Velero (included in the default NKP installation).
- Ensure you have installed the Velero CLI.

For more information, see Velero Installation Using CLI on page 576.

- Ensure you have installed the Azure CLI.

For more information, see `<<https://learn.microsoft.com/en->`
us/cli/azure/install-azure-cli?view=azure-cli-> latest.

- Ensure you have sufficient access rights to the Azure storage environment
  and blob container you want to use for backup.

For more information on data authorization and Azure blob storage, see
`<https://learn.microsoft.com/en-us/>` azure/storage/common/authorize-data-
access?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json&bc=
%2Fazure%2Fstorage%2Fblobs%2Fbreadcrumb%2Ftoc.json&tabs=blobs.

Procedure

1. Prepare your Environment.

a. Create a container in Azure blob storage.

For more information, see `<<https://learn.microsoft.com/en->`
us/azure/storage/blobs/storage-quickstart-> blobs-portal#create-a-container.

b. Set the BLOB_CONTAINER environment variable to the name of the blob
container you created to use as backup storage.

```bash
export BLOB_CONTAINER=<Azure-blob-container-name>
```

c. Set up a storage account and resource group.

For more information, see `<<https://learn.microsoft.com/en->`
us/azure/storage/common/storage-account-> create?tabs=azure-cli#create-a-
storage-account-1.

d. Set the AZURE_BACKUP_RESOURCE_GROUP variable to the name of the resource
group you created.

```bash
AZURE_BACKUP_RESOURCE_GROUP=<azure-resource-group-name>
```

e. Set the AZURE_STORAGE_ACCOUNT_ID variable to the unique identifier of the
storage account you want to use for the backup.

To obtain the ID, get the resource ID for a storage account. For more
information, see https:// learn.microsoft.com/en-
us/azure/storage/common/storage-account-get-info?toc=%2Fazure
%2Fstorage%2Fblobs%2Ftoc.json&bc=%2Fazure%2Fstorage%2Fblobs%2Fbreadcrumb

%2Ftoc.json&tabs=azure-cli#get-the-resource-id-for-a-storage-account. The
output shows the entire location path of the storage account. You only need
the last part, or storage account name, to set the variable.

```bash
AZURE_STORAGE_ACCOUNT_ID=<storage-account-name>
```

f. Set the AZURE_BACKUP_SUBSCRIPTION_ID variable to the unique identifier of
the subscription you want to use for the backup.

To obtain the ID and Azure account list , see `<<https://learn.microsoft.com/en->`
us/cli/azure/account>? view=azure-cli-latest#az-account-list.

```bash
AZURE_BACKUP_SUBSCRIPTION_ID=<azure-subscription-id>
```

g. Set the WORKSPACE_NAMESPACE environment variable to the name of the
workspace's namespace. Replace `<workspace_namespace>` with the name of the
target workspace:

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

This can be the kommander namespace for the Management cluster or any other
additional workspace namespace for Attached or Managed clusters. To list all
available workspace namespaces, use the kubectl get nkpcluster -A command.

h. Set the CLUSTER_NAME environment variable. Replace `<target_cluster>` with
the name of the cluster where you want to set up Velero.

```bash
export CLUSTER_NAME=<target_cluster>
```

1. Prepare your Azure credentials.

For more details on authorization, choose how to authorize access to blob data
in the Azure portalhttps:// learn.microsoft.com/en-
us/azure/storage/blobs/authorize-data-operations-portal.

a. Create a credentials-velero file with the information required to create a
secret. Use the same credentials that you employed when creating the cluster.
These credentials should not be Base64 encoded because Velero will not read
them properly. Replace the variables in `<...>` with your environment's
information. See your Microsoft Azure account to look up the values.

```bash
cat << EOF > ./credentials-velero
AZURE_SUBSCRIPTION_ID=${AZURE_BACKUP_SUBSCRIPTION_ID}
AZURE_TENANT_ID=<AZURE_TENANT_ID>
AZURE_CLIENT_ID=<AZURE_CLIENT_ID>
AZURE_CLIENT_SECRET=<AZURE_CLIENT_SECRET>
AZURE_BACKUP_RESOURCE_GROUP=${AZURE_BACKUP_RESOURCE_GROUP}
AZURE_CLOUD_NAME=AzurePublicCloud
EOF
```

b. Use the credentials-velero file to create the secret.

```bash
kubectl create secret generic -n ${WORKSPACE_NAMESPACE} velero-azure-credentials
--from-file=azure=credentials-velero --kubeconfig=${CLUSTER_NAME}.conf
```

##### Velero with Azure: Configuring Velero

Customize Velero to allow the configuration of a non-default backup location.

Procedure

1. Create a ConfigMap to enable Velero to use Azure blob containers as backup
   storage location.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
namespace: ${WORKSPACE_NAMESPACE}
name: velero-overrides
data:
values.yaml: |
initContainers:
- name: velero-plugin-for-microsoft-azure
image: velero/velero-plugin-for-microsoft-azure:v1.5.1
imagePullPolicy: IfNotPresent
volumeMounts:
- mountPath: /target
name: plugins
credentials:
extraSecretRef: velero-azure-credentials
EOF
```

1. Patch the Velero AppDeployment to reference the created ConfigMap with the
   Velero overrides.

a. To update Velero in all clusters in a workspace:

```bash
cat << EOF | kubectl -n ${WORKSPACE_NAMESPACE} patch appdeployment velero --
type="merge" --patch-file=/dev/stdin
spec:
configOverrides:
name: velero-overrides
EOF
```

To update Velero for a specific cluster in a workspace and customize an
application per cluster, see Customizing an Application Per Cluster on page
\375. 3. Check the ConfigMap on the HelmRelease object.

```bash
kubectl get hr -n kommander velero -o jsonpath='{.spec.valuesFrom[?(@.name=="velero-
overrides")]}'
```

The output looks like this if the deployment is successful:

```bash
{"kind":"ConfigMap","name":"velero-overrides"}
```

1. Verify that the Velero pod is running.

```bash
kubectl get pods -A --kubeconfig=${CLUSTER_NAME}.conf |grep velero
```

##### Velero with Azure: Configuring Velero By Editing the kommander.yaml File

This is an alternative configuration path for management or Pro clusters. You
can also configure Velero by editing the kommander.yaml and rerunning the
installation. To follow this alternative configuration path, expand the
following section:

About this task

Configure Velero on the Management Cluster:

Procedure

1. Refresh the kommander.yaml to add the customization of Velero.

```yaml
Warning: Before running this command, ensure the kommander.yaml is the configuration file you are currently
using for your environment. Otherwise, your previous configuration will be lost.
nkp install kommander -o yaml --init > kommander.yaml
```

1. Configure NKP to load the plugins and to include the secret in the
   apps.velero section. This process has been tested to work with plugin Azure
   v1.5.1. More recent versions of these plugins can be used, but Nutanix has
   not tested them.

```bash
...
velero:
values: |
initContainers:
- name: velero-plugin-for-microsoft-azure
image: velero/velero-plugin-for-microsoft-azure:v1.5.1
imagePullPolicy: IfNotPresent
volumeMounts:
- mountPath: /target
name: plugins
credentials:
extraSecretRef: velero-azure-credentials
...
```

1. Use the modified kommander.yaml configuration to install this Velero
   configuration.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

1. Check the ConfigMap on the HelmRelease object.

```bash
kubectl get hr -n kommander velero -o jsonpath='{.spec.valuesFrom[?(@.name=="velero-
overrides")]}'
```

The output looks like this if the deployment is successful:

```bash
{"kind":"ConfigMap","name":"velero-overrides"}
```

1. Verify that the Velero pod is running.

```bash
kubectl get pods -A --kubeconfig=${CLUSTER_NAME}.conf |grep velero
```

##### Velero with Azure: Establishing a Backup Location

Procedure

1. Create a Backup Storage Location.

a. Create a location for the backup by pointing to an existing Azure bucket.
Replace `<azure-backup-location-name>` with a name for the backup location.

```bash
velero backup-location create <azure-backup-location-name> -n
${WORKSPACE_NAMESPACE} \
--provider azure \
--bucket ${BLOB_CONTAINER} \
--config resourceGroup=${AZURE_BACKUP_RESOURCE_GROUP},storageAccount=
${AZURE_STORAGE_ACCOUNT_ID},subscriptionId=${AZURE_BACKUP_SUBSCRIPTION_ID} \
--credential=velero-azure-credentials=azure --kubeconfig=${CLUSTER_NAME}.conf
```

b. Check that the backup storage location is Available and that it references
the correct Azure bucket.

```bash
kubectl get backupstoragelocations -n ${WORKSPACE_NAMESPACE} -oyaml
```

1. Create a test backup.

a. Create a test backup that is stored in the location you created in the
previous section.

```bash
velero backup create azure-velero-testbackup -n ${WORKSPACE_NAMESPACE} \
--kubeconfig=${CLUSTER_NAME}.conf \
--storage-location <azure-backup-location-name> \
--snapshot-volumes=false
```

b. View your backup.

```bash
velero backup describe azure-velero-testbackup
```

> **Note: If your backup wasn't created, Velero might have had an issue
> installing the plugin.**

- 1. If the plugin was not installed, run this command:

```bash
velero plugin add velero/velero-plugin-for-microsoft-azure:v1.5.1 -n
${WORKSPACE_NAMESPACE}
```

1. Confirm your backupstoragelocation was configured correctly.

```bash
kubectl get backupstoragelocations -n ${WORKSPACE_NAMESPACE}
```

If your backup storage location is "Available", proceed to create a test backup.

```bash
NAME PHASE LAST VALIDATED AGE DEFAULT
<azure-backup-location-name> Available 38s 60m
```

#### Usage of Velero with Google Cloud Storage Platform

Follow these procedures to set up Velero with Google Cloud Storage Platform:

##### Velero with GCP: Preparing your Environment

Before you begin

- Ensure you have installed Velero (included in the default NKP installation).
- Ensure you have installed the Velero CLI.

For more information, see Velero Installation Using CLI on page 576.

- You have installed the gcloud CLI.

For more information, see `<https://cloud.google.com/sdk/docs/install>`.

- (Optional) You can install the gsutil CLI or opt to create buckets through
  the GCS Console.

For more information, see
`<https://cloud.google.com/storage/docs/gsutil_install>`.

- Ensure you have created a GCS bucket.

For more information, see `<<https://cloud.google.com/storage/docs/creating->`
buckets>.

- Ensure you have sufficient access rights to the bucket you want to use for
  backup.

For more information on GCP-related access control, see
`<https://cloud.google.com/storage/docs/access->` control.

Procedure

1. Set the environment variables.

a. Set the BUCKET environment variable to the name of the GCS container you
want to use as backup storage.

```bash
export BUCKET=<GCS-bucket-name>
```

b. Set the WORKSPACE_NAMESPACE environment variable to the name of the
workspace's namespace. Replace `<workspace_namespace>` with the name of the
target workspace:

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

This can be the kommander namespace for the Management cluster or any other
additional workspace namespace for Attached or Managed clusters. To list all
available workspace namespaces, use the kubectl get nkpcluster -A command.

c. Set the CLUSTER_NAME environment variable. Replace `<target_cluster>` with
the name of the cluster where you want to set up Velero:

```bash
export CLUSTER_NAME=<target_cluster>
```

1. Prepare your Google Cloud Platform credentials. You can store your backups
   in Google Cloud Platform/GCS buckets. For more information on setting up
   access to your bucket, see `<<https://cloud.google.com/storage/docs/creating->`
   buckets#required-roles>.

a. Create a credentials-velero file with the information required to create a
secret. Use the same credentials that you employed Replace `<service-account-
email>` with the email address you used to grant permissions to your bucket.
The address usually follows the format `<service-account-user>`@`<gcp- project>`.iam.gserviceaccount.com.

```bash
gcloud iam service-accounts keys create credentials-velero \
--iam-account <service-account-email>
```

b. Use the credentials-velero file to create the secret.

```bash
kubectl create secret generic -n ${WORKSPACE_NAMESPACE} velero-gcp-credentials --
from-file=gcp=credentials-velero --kubeconfig=${CLUSTER_NAME}.conf
```

##### Velero with GCP: Configuring Velero

Customize Velero to allow the configuration of a non-default backup location.

Procedure

1. Create a ConfigMap to enable Velero to use GCS buckets as backup storage
   location.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
namespace: ${WORKSPACE_NAMESPACE}
name: velero-overrides
data:
values.yaml: |
initContainers:
- name: velero-plugin-for-gcp
image: velero/velero-plugin-for-gcp:v1.5.0
imagePullPolicy: IfNotPresent
volumeMounts:
- mountPath: /target
name: plugins
credentials:
extraSecretRef: velero-gcp-credentials
EOF
```

1. Patch the Velero AppDeployment to reference the created ConfigMap with the
   Velero overrides.

a. To update Velero in all clusters in a workspace:

```bash
cat << EOF | kubectl -n ${WORKSPACE_NAMESPACE} patch appdeployment velero --
type="merge" --patch-file=/dev/stdin
spec:
configOverrides:
name: velero-overrides
EOF
```

To update Velero for a specific cluster in a workspace and customize an
application per cluster, see Customizing an Application Per Cluster on page
\375. 3. Check the ConfigMap on the HelmRelease object.

```bash
kubectl get hr -n kommander velero -o jsonpath='{.spec.valuesFrom[?(@.name=="velero-
overrides")]}'
```

The output looks like this if the deployment is successful:

```bash
{"kind":"ConfigMap","name":"velero-overrides"}
```

1. Verify that the Velero pod is running.

```bash
kubectl get pods -A --kubeconfig=${CLUSTER_NAME}.conf |grep velero
```

##### Velero with GCP: Configuring Velero By Editing the kommander.yaml File

This is an alternative configuration path for management or Pro clusters. You
can also configure Velero by editing the kommander.yaml and rerunning the
installation.

About this task

Configure Velero on the Management Cluster:

Procedure

1. Refresh the kommander.yaml to add the customization of Velero.

```yaml
Warning: Before running this command, ensure the kommander.yaml is the configuration file you are currently
using for your environment. Otherwise, your previous configuration will be lost.
nkp install kommander -o yaml --init > kommander.yaml
```

1. Configure NKP to load the plugins and to include the secret in the
   apps.velero section. This process has been tested to work with plugin GCP
   v1.5.0. More recent versions of these plugins can be used, but Nutanix has
   not tested them.

```bash
...
velero:
values: |
initContainers:
- name: velero-plugin-for-gcp
image: velero/velero-plugin-for-gcp:v1.5.0
imagePullPolicy: IfNotPresent
volumeMounts:
- mountPath: /target
name: plugins
credentials:
extraSecretRef: velero-gcp-credentials
...
```

1. Use the modified kommander.yaml configuration to install this Velero
   configuration.

```bash
nkp install kommander --installer-config kommander.yaml --kubeconfig=
${CLUSTER_NAME}.conf
```

1. Check the ConfigMap on the HelmRelease object.

```bash
kubectl get hr -n kommander velero -o jsonpath='{.spec.valuesFrom[?(@.name=="velero-
overrides")]}'
```

The output looks like this if the deployment is successful:

```bash
{"kind":"ConfigMap","name":"velero-overrides"}
```

1. Verify that the Velero pod is running.

```bash
kubectl get pods -A --kubeconfig=${CLUSTER_NAME}.conf |grep velero
```

##### Velero with GCP: Establishing a Backup Location

Procedure

1. Create a backup storage location.

a. Create a location for the backup by pointing to an existing GCS bucket.

Ensure you set the required environment variables as specified in Velero with
GCP: Preparing your Environment on page 572.

```bash
velero backup-location create <gcp-backup-location-name> -n ${WORKSPACE_NAMESPACE}
\
--provider gcp \
--bucket $BUCKET \
--credential=velero-gcp-credentials=gcp
```

Replace `<gcp-backup-location-name>` with a name for the backup location.

b. Check that the backup storage location is Available and that it references
the correct GCS bucket.

```bash
kubectl get backupstoragelocations -n ${WORKSPACE_NAMESPACE} -oyaml
```

1. Create a test backup.

a. Create a test backup that is stored in the location you created in the
previous section.

### Velero Backup

b. View your backup.

> **Note: If your backup wasn't created, Velero might have had an issue
> installing the plugin.**

- 1. If the plugin was not installed, run this command:

```bash
velero plugin add velero/velero-plugin-for-gcp:v1.5.0 -n
${WORKSPACE_NAMESPACE}
```

1. Confirm your backupstoragelocation was configured correctly.

```bash
kubectl get backupstoragelocations -n ${WORKSPACE_NAMESPACE}
```

If your backup storage location is "Available", proceed to create a test backup.

```bash
NAME PHASE LAST VALIDATED AGE DEFAULT
<gcp-backup-location-name> Available 38s 60m
```

NKP provides Velero (`<https://velero.io/>`) by default, to support backup and
restore operations for your Kubernetes clusters and persistent volumes.

#### Velero Installation Using CLI

Although installing the Velero command-line interface is optional and
independent of deploying the NKP cluster, having access to it provides several
benefits. For example, you can use it up or, restore a cluster on demand or
modify certain settings without changing the Velero configuration.

- By default, NKP sets up Velero to use Rook Ceph over TLS using a self-signed
  certificate.
- As a result, when using certain commands, you might be asked to use the
  --insecure-skip-tls-verify flag.

Again, the default setup is not suitable for production use cases.

Install the Velero command-line interface. For more information, see
`<https://velero.io/docs/v1.5/basic-install/>` #install-the-cli.

In NKP, the Velero platform application is installed in the kommander
namespace instead of velero. Thus, after installing the CLI, we recommend that
you set the Velero CLI namespace config option so that subsequent Velero CLI
invocations will use the correct namespace:

```bash
velero client config set namespace=kommander
```

#### Backup Operations

Velero provides the following basic administrative functions to back up
production clusters:

> **Note:**

- If you want to back up your cluster in the scope of Platform Expansion:
  Conversion of an NKP Pro Cluster to an NKP Ultimate Managed Cluster on page
  519, that is, from NKP Pro cluster to an NKP Ultimate Managed cluster, see
  Cluster Applications and Persistent Volumes Backup on page 521.
- If you require a custom backup location, see how to create one for Velero
  with AWS: Establishing a Backup Location on page 567, Velero with Azure:
  Establishing a Backup Location on page 571, and Velero with GCP:
  Establishing a Backup Location on page 575.

##### Preparing Your Environment for Backup

About this task

Before you modify a schedule or create an on-demand backup, set the following
environment variables:

Procedure

1. Specify the workspace namespace of the cluster for which you want to
   configure the backup.

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

1. Specify the cluster for which you want to create the backup.

```bash
export CLUSTER_NAME=<target_cluster_name>
```

##### Setting a Backup Schedule

About this task

By default, NKP configures a regular, automatic backup of the cluster's state
in Velero. The default settings do the following:

Procedure

1. Create daily backups.
2. Save the data from all namespaces.

> **Warning: NKP default backups do not support the creation of Volume
> Snapshots.**

These default settings take effect after the cluster is created. If you
install NKP with the default platform services deployed, the initial backup
starts after the cluster is successfully provisioned and ready for use.

##### Creating Backup Schedules

About this task

The Velero CLI provides an easy way to create alternate backup schedules. For
example:

Procedure

Run the following command.

```bash
velero create schedule <backup-schedule-name> -n ${WORKSPACE_NAMESPACE} \
--kubeconfig=${CLUSTER_NAME}.conf \
--snapshot-volumes=false \
--schedule="@every 8h"
```

##### Changing the Default Backup Service Settings

Procedure

1. Check the backup schedules currently configured for the cluster.

```bash
velero get schedules
```

1. Delete the velero-default schedule.

```bash
velero delete schedule velero-default
```

1. Replace the default schedule with your custom settings.

```bash
velero create schedule velero-default -n ${WORKSPACE_NAMESPACE} \
--kubeconfig=${CLUSTER_NAME}.conf \
--snapshot-volumes=false \
--schedule="@every 24h"
```

##### Creating a Backup Schedule for a Specific Namespace

About this task

You can also create backup schedules for specific namespaces.

Procedure

Creating a backup for a specific namespace can be useful for clusters running
multiple apps operated by multiple teams. For example.

```bash
velero create schedule <backup-schedule-name> \
--include-namespaces=kube-system,kube-public,kommander \
--snapshot-volumes=false \
--schedule="@every 24h"
```

The Velero command line interface provides many more options worth exploring.
For more information on disaster recovery, see
`<https://velero.io/docs/v0.11.0/disaster-case/>`. For more information on
cluster migration, see https:// velero.io/docs/v0.11.0/migration-case/.

##### Backing Up Schedule on Demand

About this task

In some cases, you might find it necessary to create a backup outside the
regularly scheduled interval. For example, if you are preparing to upgrade any
components or modify your cluster configuration, perform a backup before
taking that action.

Procedure

Create a backup by running the following command.

```bash
velero backup create <backup-name> -n ${WORKSPACE_NAMESPACE} \
--kubeconfig=${CLUSTER_NAME}.conf \
--snapshot-volumes=false
```

#### Restoring a Cluster from Backup

About this task

When restoring a backup to the management cluster, you must adjust the
configuration to avoid restore errors.

```yaml
Note: When restoring a backup to a cluster, ensure that the backup was created from the same NKP version and from
the same cluster. Restoring a backup from an older version or from another cluster results in an inoperable cluster.
```

Before you begin

Before attempting to restore the cluster state using the Velero command-line
interface, verify that you meet the following requirements:

- The backend storage, Rook Ceph Cluster, is still operational.
- The Velero platform service in the cluster is still operational.
- The Velero platform service is set to a restore-only-mode to avoid having
  backups run while restoring.

Procedure

1. Ensure that the specified ResourceQuota is not configured on your cluster:

```bash
kubectl -n kommander delete resourcequota one-kommandercluster-per-kommander-
workspace
```

> **Note: ResourceQuota is automatically restored from the backup.** 2. Turn
> off the Workspace validation webhooks.

Ensure that workspaces with preconfigured namespaces are restored. If the
validation webhook named kommander-validating is present, modify it by running
the following command:

```bash
kubectl patch validatingwebhookconfigurations kommander-validating \
--type json \
--patch '[
{
"op": "remove",
"path": "/webhooks/0/rules/3/operations/0"
}
]'
```

1. (Optional) List the available backups:

```bash
velero backup get
```

1. (Optional) Verify successful deployment of Velero:

```bash
helm get values -n kommander velero
```

1. Restore the cluster from the selected backup:

```bash
velero restore create --from-backup
```

> **Important:**

- If you are using read only backup storage, this command restores cluster
  data on demand from the selected snapshot.
- When using the default Velero setup (without an external object store),
  describing the restore or viewing restore logs might return an error. This
  error is a known issue when restoring from an object

store that is not accessible from outside your cluster. However, you can
review the success of the backup restore by confirming the Phase is Completed
and by viewing the logs with the command:

```bash
kubectl logs -l name=velero -n kommander --tail -1
```

1. Verify that the ResourceQuota named one-kommandercluster-per-kommander-
   workspace is restored.
2. Add the CREATE webhook rule operation:

```bash
kubectl patch validatingwebhookconfigurations kommander-validating \
--type json \
--patch '[
{
"op": "add",
"path": "/webhooks/0/rules/3/operations/0",
"value": "CREATE"
}
]'
```

#### Backup Service Diagnostics

You can check whether the Velero service is currently running on your cluster
through the Kubernetes dashboard (accessible through the NKP UI on the
Management Cluster), or by running the following kubectl command:

```bash
kubectl get all -A | grep velero
```

If the Velero platform service application is currently running, you can
generate diagnostic information about Velero backup and restore operations.
For example, you can run the following commands to retrieve, back up, and
restore information that you can use to assess the overall health of Velero in
your cluster:

```bash
velero get schedules
velero get backups
velero get restores
velero get backup-locations
velero get snapshot-locations
```

### Prism Central Backup and Recovery (PCBR) for NKP

Prism Central Backup and Recovery (PCBR) is a localized recovery solution that
ensures the availability of your
management plane by replicating Prism Central (PC) data to a recovery site, or
another cluster in the same site. When
your NKP environment is managed by a Prism Central instance protected by PCBR,
the disaster recovery (DR) process
restores the PC entity, its configurations, and the underlying associations
with managed AOS clusters. As NKP relies on
Prism Central for infrastructure orchestration, the stability of these
connections is critical during a failover. While
basic NKP functionality remains intact after a PCBR event, you must perform
certain steps to re- establish NKP OS image
visibility and ensure consistent cluster metadata. If the recovery is with the
same IP address, the NKP cluster is able
to re-establish the connection to the PC once it recovers, but image and
identity checks are still required. If the
recovery is with a new IP address, the NKP cluster must be updated to connect
with the new PC IP address.

Nutanix recommends you to adopt a strategy that begins with Continuous Backup,
and integrates Point-in-Time Backup for comprehensive protection.

For more information on PCBR, see Prism Central Backup, Restore, and Migration.

Before you begin

- You must have a Prism Central instance that manages at least one AOS
  cluster, with PCBR enabled.
- Ensure valid NKP OS images are uploaded and available on the Prism Central
  or AOS cluster before enabling Prism Central backups for the NKP-hosting
  environment.
- Ensure the Prism Central credentials used by NKP remain valid and have the
  same permissions after recovery.

> **Note:**

If the admin credentials are used, it will be factory reset during the
recovery and you must change it to match the previous password to ensure the
NKP Cluster can re-establish the connection with the PC. If a custom user
credentials are used, the recovery process will restore the custom user's
credentials. We recommend you to use custom credentials, rather than admin
credentials.

#### Prism Central Backup and Recovery - with the Same IP Address

About this task

In this scenario, the PC instance is restored using its original IP and
administrative credentials, after a PCBR event. While the connection endpoints
for NKP remain technically valid, you must ensure the credentials match the
pre- recovery state and re-import all NKP OS images to the restored PC, if not
present already. Additionally, the Prism Central Cluster name must be manually
corrected to prevent inconsistent region labeling on new Kubernetes nodes.

Follow these steps, post restoration of the PC instance:

Procedure

1. Re-import NKP OS images in Prism Central.
1. Log in to the Prism Central UI. 2. Go to Images and select Import Image. 3.
   Import all required Rocky out-of-the-box and custom NKP images.

For custom images, use the same image names that were used before the recovery
event. It is recommended to store the images externally in order to protect
them and utilize it in such scenarios. 2. (Optional) Restore the Prism Central
instance name to the pre-disaster value.

After recovery, the Prism Central cluster name can revert to an unnamed or
default value. Restoring the original name ensures that new Kubernetes nodes
receive the expected region labels. 3. Verify credentials used by NKP
integrations.

If the admin account is used, set the password to the exact pre-recovery value
so existing CAPX, CCM, and CSI secrets remain valid.

#### Prism Central Backup and Recovery - with a Different IP Address

About this task

If the PC instance is recreated with a new IP Address and the NKP cluster is
managed by a different local super- admin user, additional reconfiguration is
mandatory. Beyond re-importing images and renaming the PC instance, you must
manually update the PC endpoint IP across all NKP infrastructure providers,
cluster resources, CCM, and CSI configurations. This ensures that the
management and workload clusters continue to communicate with the new Prism
Central endpoint after recovery.

Procedure

1. Re-import NKP OS images in Prism Central.
1. Log in to the Prism Central UI. 2. Go to Images and select Import Image. 3.
   Import all required NKP images.
1. Update the management cluster configuration with the new Prism Central IP
   address.

Update the Cluster resource details with the new IP address in the management
cluster to ensure CAPX can manage node lifecycle operations with the new
endpoint. 3. Update CCM and CSI secrets with the new Prism Central endpoint
information.

Cloud Controller Manager (CCM) and Container Storage Interface (CSI) rely on
stored endpoint and credential data for networking and storage operations.
Update these secrets with the new IP address so workload and management
clusters can continue normal operation.

### NKP Management Cluster Backup and Restore

NKP Management Cluster Backup and Disaster Recovery (DR) provides a
streamlined, platform-independent solution for
safeguarding your core Kubernetes infrastructure. By leveraging the out-of-
the-box (OOTB) Velero, Ceph and Nutanix
Object, bundled within the Nutanix Kubernetes Platform (NKP), efficiently back
up and restore critical cluster states.
This feature supports recovery of the Management Cluster to ensure the
continuity of Cluster Lifecycle and Workload
Management for all associated Managed Clusters.

You can use one of the following backup storage patterns:

- Internal backup storage location: A secondary licensed NKP Management
  Cluster runs in standby mode and stores backups in its internal rook-ceph
  object store. The standby cluster must be reachable from the primary
  cluster.
- External backup storage location: The primary NKP Management Cluster stores
  backups in an external S3- compatible object store, such as Nutanix Objects
  or Amazon S3. In this model, a standby secondary cluster is not required
  when you create backups.

```yaml
Important: Management Cluster backup does not include application volume backups. Use a separate workload
backup procedure for stateful application data.
```

#### Backing Up an NKP Management Cluster

Before you begin

Ensure that you have access to the primary NKP Management Cluster kubeconfig
and a backup storage location. For internal backup storage, you must also have
a reachable standby secondary NKP Management Cluster.

About this task

In a shell session with cluster access tools installed, follow these steps to
create a Management Cluster backup:

Procedure

1. (Optional) This step is to be performed only if you are relying on internal
   Rook-Ceph for object store needs, or you have not Configured Velero with
   Nutanix Objects or another S3 compatible external object store to store the
   Velero backup.)

Use one of the following options:

- Use an internal Backup Storage Location (BSL) that points to the standby
  cluster bucket.
- Create an external backup storage location for Nutanix Objects or another
  S3-compatible store.

» Option 1: Use NKP Internal BSL

Create an External BackupStorageLocation (BSL) in the primary (source) NKP
Management Cluster that points to the dkp-velero bucket in the secondary
(target) NKP Management Cluster:

Set the necessary environment variables:

```bash
export SOURCE_KUBECONFIG=<path-to-source/primary-cluster-kubeconfig>
export TARGET_KUBECONFIG=<path-to-target/secondary-cluster-kubeconfig>
export CEPH_BUCKET=dkp-velero
export AWS_HOST=$(k get --kubeconfig ${TARGET_KUBECONFIG} svc -n kommander
kommander-traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export AWS_PORT=8085
export S3_REGION=dkp-object-store
export AWS_PROFILE=target-ceph
export BUCKET_NAME=$(kubectl --kubeconfig ${TARGET_KUBECONFIG} -n kommander get cm
${CEPH_BUCKET} -o jsonpath='{.data.BUCKET_NAME}')
export BACKUP_STORAGE_LOCATION=target-ceph
export REMOTE_STORE_SECRET=target-ceph-credentials
```

Extract credentials from the secondary (target) cluster and apply them as a
remote Secret on the primary (source) cluster:

```bash
kubectl --kubeconfig ${SOURCE_KUBECONFIG} apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
name: ${REMOTE_STORE_SECRET}
namespace: kommander
type: Opaque
stringData:
aws: |
[${AWS_PROFILE}]
aws_access_key_id=$(kubectl --kubeconfig ${TARGET_KUBECONFIG} -n kommander get
secret ${CEPH_BUCKET} -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode)
aws_secret_access_key=$(kubectl --kubeconfig ${TARGET_KUBECONFIG} -n kommander
get secret ${CEPH_BUCKET} -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --
decode)
```

Apply the BSL resource on the primary cluster:

```bash
kubectl --kubeconfig ${SOURCE_KUBECONFIG} apply -f - <<EOF
apiVersion: velero.io/v1
kind: BackupStorageLocation
metadata:
name: ${BACKUP_STORAGE_LOCATION}
namespace: kommander
spec:
accessMode: ReadWrite
config:
insecureSkipTLSVerify: "true"
region: ${S3_REGION}
s3ForcePathStyle: "true"
s3Url: https://${AWS_HOST}:${AWS_PORT}
profile: ${AWS_PROFILE}
default: false
objectStorage:
bucket: ${CEPH_BUCKET}
credential:
key: aws
name: target-ceph-credentials
provider: aws
```

» Option 2: Create External BSL if one does not already exit

The BackupStorageLocation manifest defined above is identical to creating an
external BSL. If one does not exist and you wish to use it for storing the
backup of the primary NKP Management Cluster. Simply swap the environment
variables with the connection details of an external S3 compatible object
store like Nutanix Objects or AWS S3. The following example is using Nutanix
Objects, you must change it to AWS connection details if you are using AWS S3.
The parameters remain the same.

```bash
export WORKSPACE_NAMESPACE=kommander
export S3_REGION=us-east-1
export NUTANIX_OBJECTS_PUBLIC_IP=<nutanix-objects-public-ip-or-hostname>
export NUTANIX_OBJECTS_ACCESS_KEY_ID=<nutanix-objects-access-key-id>
export NUTANIX_OBJECTS_SECRET_ACCESS_KEY=<nutanix-objects-access-key-secret>
export AWS_PROFILE=<aws-profile>
export REMOTE_STORE_SECRET=<k8s-secret-to-store-keys>
export BUCKET=<existing-bucket-in-nutanix-objects>
export BACKUP_STORAGE_LOCATION=<bsl-to-create>
kubectl apply -f - << EOF
---
apiVersion: v1
kind: Secret
metadata:
name: ${REMOTE_STORE_SECRET}
namespace: ${WORKSPACE_NAMESPACE}
type: Opaque
stringData:
aws: |
[${AWS_PROFILE}]
aws_access_key_id = ${NUTANIX_OBJECTS_ACCESS_KEY_ID}
aws_secret_access_key = ${NUTANIX_OBJECTS_SECRET_ACCESS_KEY}
---
apiVersion: velero.io/v1
kind: BackupStorageLocation
metadata:
name: ${BACKUP_STORAGE_LOCATION}
namespace: ${WORKSPACE_NAMESPACE}
spec:
accessMode: ReadWrite
config:
checksumAlgorithm: ""
insecureSkipTLSVerify: "true" # set to false if using caCert
region: us-east-1
s3ForcePathStyle: "true"
s3Url: https://${NUTANIX_OBJECTS_PUBLIC_IP}
profile: ${AWS_PROFILE}
objectStorage:
bucket: ${BUCKET}
#caCert: <base64 encoded SSL certificate> # Optional. The base64 encoded PEM
certificate
provider: aws
credential:
key: aws
name: ${REMOTE_STORE_SECRET}
EOF
```

1. Backup the primary cluster

To ensure consistent state, all managed clusters must be paused before
initiating the backup.

```yaml
Note: Ensure SOURCE_KUBECONFIG environment variable is set to the primary cluster's kubeconfig even if Step
1 was skipped.
for NS in $(kubectl --kubeconfig ${SOURCE_KUBECONFIG} get clusters -A -o custom-
columns='Namespace:.metadata.namespace' --no-headers)
do
for CLUSTER in $(kubectl --kubeconfig ${SOURCE_KUBECONFIG} get clusters -n ${NS} -o
name)
do
kubectl --kubeconfig ${SOURCE_KUBECONFIG} patch -n ${NS} ${CLUSTER} --type merge
-p '{"spec":{"paused": true}}'
done
done
```

1. Execute the backup

```bash
export BACKUP_NAME=<backup-name>
velero --kubeconfig ${SOURCE_KUBECONFIG} backup create ${BACKUP_NAME} \
-n kommander \
--storage-location ${BACKUP_STORAGE_LOCATION} \
--snapshot-volumes=false -w
```

The BACKUP_STORAGE_LOCATION will point to the BSL configured in step 1, or an
existing external BSL.

```yaml
Note: The Management Cluster backup procedure does not include volume backups. You must not rely on this
procedure for application-level backups.
```

1. Run the following command to verify the backup:

```bash
velero --kubeconfig ${SOURCE_KUBECONFIG} backup get -n kommander ${BACKUP_NAME}
velero --kubeconfig ${SOURCE_KUBECONFIG} backup describe -n kommander ${BACKUP_NAME}
--insecure-skip-tls-verify
velero --kubeconfig ${SOURCE_KUBECONFIG} backup logs -n kommander ${BACKUP_NAME} --
insecure-skip-tls-verify
```

1. Resume clusters in all namespaces:

```bash
for NS in $(kubectl --kubeconfig ${SOURCE_KUBECONFIG} get clusters -A -o custom-
columns='Namespace:.metadata.namespace' --no-headers); do
for CLUSTER in $(kubectl --kubeconfig ${SOURCE_KUBECONFIG} get clusters -n ${NS} -o
name)
do
kubectl --kubeconfig ${SOURCE_KUBECONFIG} patch -n ${NS} ${CLUSTER} --type merge
-p '{"spec":{"paused": false}}'
done
done
```

#### Recovering an NKP Management Cluster After a Disaster

Before you begin

Ensure that you have a backup created from the primary cluster and access to
the target NKP Management Cluster kubeconfig. For more information, see
Backing Up an NKP Management Cluster on page 582.

About this task

Simulate a disaster scenario by shutting down the primary cluster that was
backed up. Restore the secondary cluster in the order listed below to ensure
the desired outcome is achieved.

```yaml
Note: If you do not already have a standby secondary Management Cluster and backups are in an external S3-
compatible store, deploy the target Management Cluster before you restore.
```

Procedure

1. Restore workspaces on the target cluster:

```bash
velero --kubeconfig ${TARGET_KUBECONFIG} restore create -n kommander
${BACKUP_NAME}-ws \
--include-resources workspaces \
--from-backup ${BACKUP_NAME} -w
Note: If a workspace uses a dynamically generated namespace, create the workspace manually with the original
spec.namespaceName value from the source cluster to avoid a mismatch.
```

1. Restore projects on the target cluster:

```bash
velero --kubeconfig ${TARGET_KUBECONFIG} restore create -n kommander
${BACKUP_NAME}-pr \
--include-resources workspaces,projects \
--from-backup ${BACKUP_NAME} -w
```

1. Restore custom application deployment config maps:

```bash
velero --kubeconfig ${TARGET_KUBECONFIG} restore create -n kommander
${BACKUP_NAME}-cm \
--include-resources configmaps \
--from-backup ${BACKUP_NAME} \
-l kommander.d2iq.io/managed-by-kind=AppDeployment -w
```

1. Restore RBAC and additional Management Cluster resources:

```bash
velero --kubeconfig ${TARGET_KUBECONFIG} restore create -n kommander
${BACKUP_NAME}-misc \
--include-resources
appdeployments,kommanderprojectroles,kommanderworkspaceroles,projectroles,virtualgroups,virtua
\
--from-backup ${BACKUP_NAME} -w
```

1. Restore KommanderCluster resources:

```bash
velero --kubeconfig ${TARGET_KUBECONFIG} restore create -n kommander
${BACKUP_NAME}-kc \
--include-resources kommanderclusters \
--from-backup ${BACKUP_NAME} -w
```

1. Restore CAPI secrets that use the cluster-name label, such as kubeadmconfig:

```bash
velero --kubeconfig ${TARGET_KUBECONFIG} restore create -n kommander
${BACKUP_NAME}-secrets \
--include-resources secrets \
--exclude-namespaces default \
--from-backup ${BACKUP_NAME} \
-l cluster.x-k8s.io/cluster-name -w
```

1. Restore CAPI provider secrets that use the provider label, such as PC-
   credentials:

```bash
velero --kubeconfig ${TARGET_KUBECONFIG} restore create -n kommander
${BACKUP_NAME}-provider-secrets \
--include-resources secrets \
--exclude-namespaces default \
--from-backup ${BACKUP_NAME} \
-l cluster.x-k8s.io/provider -w
```

1. Restore provider connection, such as the provider connection:

```bash
velero --kubeconfig ${TARGET_KUBECONFIG} restore create -n kommander
${BACKUP_NAME}-cap-secrets \
--include-resources secrets \
--include-namespaces $(kubectl --kubeconfig ${TARGET_KUBECONFIG} get ns | grep
cap | awk '{print $1}' | tr "\n" ",") \
--from-backup ${BACKUP_NAME} -w
```

1. Restore CAPI resources:

```bash
velero --kubeconfig ${TARGET_KUBECONFIG} restore create -n kommander
${BACKUP_NAME}-capi \
--include-resources $(kubectl --kubeconfig ${TARGET_KUBECONFIG} get crd
| grep cluster.x | awk '{print $1}' | tr '\n' ',')$(kubectl --kubeconfig
${TARGET_KUBECONFIG} get crd | grep preprovisioned | awk '{print $1}' | tr '\n'
',') \
--exclude-namespaces default \
--from-backup ${BACKUP_NAME} -w
Note: URL redirections and pointers to the disaster recovery Management Cluster become available only after
this process completes.
```

1. Resume paused managed clusters in all namespaces on the target cluster.

```bash
for NS in $(kubectl --kubeconfig ${TARGET_KUBECONFIG} get clusters -A -o custom-
columns='Namespace:.metadata.namespace' --no-headers)
do
for CLUSTER in $(kubectl --kubeconfig ${TARGET_KUBECONFIG} get clusters -n ${NS}
-o name)
do
kubectl --kubeconfig ${TARGET_KUBECONFIG} patch -n ${NS} ${CLUSTER} --type
merge -p '{"spec":{"paused": false}}'
done
done
```

What to do next

To validate recovery, sign in to the target NKP dashboard and verify
workspaces, projects, applications, RBAC policies, and nodes in the Kubernetes
/ Compute Resources / Node (Pods) dashboard.

#### Backing Up and Restoring a Prometheus Stateful Workload

Before you begin

Ensure that Velero with Restic integration is deployed on both source and
target clusters. If it is not enabled, add deployNodeAgent: true to your
Velero deployment overrides.

About this task

Efficiently back up and restore stateful workloads, such as Prometheus, across
NKP clusters. This procedure configures Velero to leverage the Restic backend
on a secondary (target) cluster, ensuring the secure storage and recovery of
critical persistent volume data.

Follow these steps to back up and restore Prometheus data:

Procedure

1. Set environment variables for source and target kubeconfig files and for
   the Ceph bucket:

```bash
export SOURCE_KUBECONFIG=path-to-source-cluster-kubeconfig
export TARGET_KUBECONFIG=path-to-target-cluster-kubeconfig
export CEPH_BUCKET=name-of-your-ceph-bucket
```

1. Update the Velero secret with source and target object store credentials:

```yaml
Note: Ensure the profile name matches the profile set in the backup storage location. Use default for the local
profile.
kubectl --kubeconfig ${SOURCE_KUBECONFIG} apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
name: velero
namespace: kommander
type: Opaque
stringData:
cloud: |
[default]
aws_access_key_id = $(kubectl --kubeconfig ${SOURCE_KUBECONFIG} -n kommander get
secret ${CEPH_BUCKET} -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode)
aws_secret_access_key = $(kubectl --kubeconfig ${SOURCE_KUBECONFIG} -n kommander
get secret ${CEPH_BUCKET} -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --
decode)
[target-ceph]
aws_access_key_id = $(kubectl --kubeconfig ${TARGET_KUBECONFIG} -n kommander get
secret ${CEPH_BUCKET} -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode)
aws_secret_access_key = $(kubectl --kubeconfig ${TARGET_KUBECONFIG} -n kommander
get secret ${CEPH_BUCKET} -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --
decode)
EOF
```

1. Remove static envFrom references from Velero and node-agent workloads:

```bash
kubectl patch deploy velero -n kommander --type=json -p='[{"op": "remove", "path": "/
spec/template/spec/containers/0/envFrom"}]'

kubectl patch ds node-agent -n kommander --type=json -p='[{"op": "remove", "path": "/
spec/template/spec/containers/0/envFrom"}]'
```

1. Annotate the Prometheus pod with the volume name that Velero must back up:

> **Note: Use the pod volume name, for example db, and not the persistent
> volume claim (PVC) name.**

```bash
kubectl --kubeconfig ${SOURCE_KUBECONFIG} annotate pod -n kommander prometheus-kube-
prometheus-stack-prometheus-0 backup.velero.io/backup-volumes=db
```

1. Create the Prometheus backup in the remote backup storage location:

```bash
velero --kubeconfig ${SOURCE_KUBECONFIG} backup create restic-prometheus \
--include-namespaces=kommander \
--snapshot-volumes=false \
--namespace kommander \
--selector=app.kubernetes.io/name=prometheus \
--storage-location target-ceph -w
```

To verify that the backup is available before you start restore actions, run:

```bash
velero --kubeconfig ${SOURCE_KUBECONFIG} backup describe restic-prometheus -n
kommander --details
velero --kubeconfig ${SOURCE_KUBECONFIG} backup logs restic-prometheus -n kommander
```

1. Prepare the target cluster by removing existing Prometheus workload
   resources:

a. Scale down the Prometheus operator deployment to 0:

```bash
kubectl --kubeconfig ${TARGET_KUBECONFIG} scale deploy -n kommander kube-
prometheus-stack-operator --replicas 0
```

b. Force-delete the Prometheus statefulset:

```bash
kubectl --kubeconfig ${TARGET_KUBECONFIG} delete sts -n kommander prometheus-kube-
prometheus-stack-prometheus --force
```

c. Delete the existing PVC:

```bash
kubectl --kubeconfig ${TARGET_KUBECONFIG} delete pvc -n kommander db-prometheus-
kube-prometheus-stack-prometheus-0
```

If you are migrating workloads across different infrastructure providers (for
example, moving from AWS to Azure), map the storage class conversion by
creating the following ConfigMap on the target cluster:

```bash
kubectl --kubeconfig ${TARGET_KUBECONFIG} apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
name: change-storage-class-config
namespace: kommander
labels:
velero.io/plugin-config: ""
velero.io/change-storage-class: RestoreItemAction
data:
ebs-sc: azuredisk-sc
EOF
```

1. Restore the Backup:

a. Execute the Velero restore operation:

```bash
velero --kubeconfig ${TARGET_KUBECONFIG} restore create -n kommander --from-backup
restic-prometheus -w
```

b. Force-delete the temporary pod created during the restore operation to
allow the Prometheus operator to properly manage pod initialization:

```bash
kubectl --kubeconfig ${TARGET_KUBECONFIG} delete pod -n kommander prometheus-kube-
prometheus-stack-prometheus-0 --force
```

c. Scale the Prometheus operator deployment back to 1:

```bash
kubectl --kubeconfig ${TARGET_KUBECONFIG} scale deploy -n kommander kube-
prometheus-stack-operator --replicas 1
```

What to do next

To validate restore success, sign in to the target NKP dashboard, open the
Grafana dashboard for the Management Cluster, and confirm data in Kubernetes /
Compute Resources / Node (Pods).

## Logging

Nutanix Kubernetes Platform (NKP) comes with a pre-configured logging stack
that allows you to collect and visualize pod and admin log data at the
Workspace level. The logging stack is also multi-tenant capable, and multi-
tenancy is enabled at the Project level through role-based access control
(RBAC).

By default, logging is disabled on managed and attached clusters. You need to
enable the logging stack applications explicitly on the workspace to make use
of these capabilities.

The primary components of the logging stack include these platform services:

- BanzaiCloud Logging-operator
- Grafana and Grafana Loki
- Fluent Bit and Fluentd

In addition to these platform services, logging relies on other software and
system facilities, including the container runtime, the journal facility, and
system configuration, to collect logs and messages from all the machines in
the cluster.

The following diagram illustrates how different components of the logging
stack collect log data and provide information about clusters:

Figure 16: Logging Architecture

The NKP logging stack aggregates logs from applications and nodes running
inside your cluster.

### Logging Operator

Loki then indexes the log data by label and stores it for querying. Loki
maintains log order integrity but does not index the log messages themselves,
which improves its efficiency and lowers its footprint.

Fluent Bit Buffer Information

Fluent Bit collects container logs from the host filesystem and performs the
following:

- Maintains a small buffer of logs (5 MB in memory)
- Maintains a checkpoint on each host for each file it's consumed, so if it's
  restarted, it can resumed where it left off.
- Flushes the buffer every one second.
- There is a five-second grace period to flush the buffer on exit (along with
  a 30-second termination grace period on the pod).

Every pod restart should result in the buffer being flushed to fluentd(allows
up to five seconds for that flush to happen).

If the buffer is not fully flushed during that five seconds, a small amount of
log data might be dropped, but if fluentdis functional, it is unlikely that
fluent-bit will be unable to flush its logs on pod termination.

Fluent Bit can be configured to use a hostPath volume to store the buffer
information, so it can be picked up again when Fluent Bit restarts.

For more information on Fluent Bit and Fluent Bit log collector, see
`<https://kube-logging.dev/docs/logging->` infrastructure/fluentbit/#hostpath-
volumes-for-buffers-and-positions.

For more information on Logging in relation to how it is used in NKP, refer to
these pages in our Help Center:

- Admin-level Logs on page 598
- Workspace-level Logging on page 599
- Multi-Tenant Logging on page 607
- Fluent Bit on page 613

### Logging Stack Scaling

#### Grafana Loki

- Customizing Logging Stack Applications on page 617

### Logging Stack Scaling (2)

Depending on the application workloads you run on your clusters, you might
find that the default settings for the NKP logging stack do not meet your
needs. In particular, if your workloads produce lots of log traffic, you might
find you need to adjust the logging stack components to capture all the log
traffic properly. Follow the suggestions below to tune the logging stack
components as needed.

#### Logging Operator (2)

According to scaling (see `<https://kube-logging.dev/docs/operation/scaling/>`),
the typical sign of this is when fluentd cannot handle its buffer (see
`<https://kube-logging.dev/docs/configuration/plugins/outputs/buffer/>`
directory size growth for more than the configured or calculated (timekey +
timekey_wait) flush interval.

For metrics to monitor by Prometheus, see
`<https://docs.fluentd.org/monitoring-fluentd/monitoring->` prometheus#metrics-
to-monitor.

Grafana Dashboard

You can also improve Fluentd throughput by turning off the buffering for loki
clusterOutput.

Example Configuration

For more information on performance tuning, Fluentd 1.0, see
`<https://docs.fluentd.org/deployment/performance->` tuning-single-process.

#### Grafana Loki (2)

For more information about microservice mode, see Grafana Loki Deployment modes.

For high log traffic environments, Nutanix recommends the following scaling
approach:

- Scale the ingester components first, as they handle the primary log
  ingestion workload.
- Scale distributor components only when existing distributors experience high
  computing resource usage.

The number of Distributor pods must be much lesser than the number of Ingester
pods.

Grafana Dashboard

When you enable the Prometheus Monitoring (kube-prometheus-stack) platform app
in NKP, you can view Loki dashboards in the Grafana UI.

Example Configuration

For an example configuration of the logging operator, see Logging Stack App
Sizing Recommendations.

For more information about Grafana Loki:

- Loki components: See Grafana Loki architecture components.
- Scaling Loki: See Grafana Loki scalability operations.
- Labeling best practices: See Grafana Loki best practices.

##### Configuring Grafana Loki to Use AWS S3 Storage in NKP

Configure Grafana Loki to store logs in AWS S3 storage instead of local
storage for better scalability and data persistence.

About this task

By default, Grafana Loki stores logs locally. To improve scalability and data
persistence, configure Grafana Loki to use AWS S3 storage for log data.

To set up AWS S3 as the storage for Grafana Loki, follow these steps:

Procedure

1. Get the namespace of your workspace:

```bash
nkp get workspaces
```

1. Set the WORKSPACE_NAMESPACE variable to your workspace namespace:

```bash
export WORKSPACE_NAMESPACE=<WORKSPACE_NAMESPACE>
```

Replace `<WORKSPACE_NAMESPACE>` with the namespace you copied from the output
of the previous step. 3. Create a secret containing your AWS S3 credentials:

```bash
kubectl create secret generic nkp-aws-s3-creds -n${WORKSPACE_NAMESPACE} \
--from-literal=AWS_ACCESS_KEY_ID=<key id> \
--from-literal=AWS_SECRET_ACCESS_KEY=<secret key>
```

This secret mounts into each Grafana Loki pod as environment variables. 4.
Create a ConfigMap that overrides the storage configuration:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
name: grafana-loki-v3-overrides
namespace: ${WORKSPACE_NAMESPACE}
data:
values.yaml: |
loki:
annotations:
secret.reloader.stakater.com/reload: nkp-aws-s3-creds
structuredConfig:
storage_config:
aws:
s3: s3://<region>/<bucket name>
ingester:
extraEnvFrom:
- secretRef:
name: nkp-aws-s3-creds
querier:
extraEnvFrom:
- secretRef:
name: nkp-aws-s3-creds
queryFrontend:
extraEnvFrom:
- secretRef:
name: nkp-aws-s3-creds
compactor:
extraEnvFrom:
- secretRef:
name: nkp-aws-s3-creds
ruler:
extraEnvFrom:
- secretRef:
name: nkp-aws-s3-creds
distributor:
extraEnvFrom:
- secretRef:
name: nkp-aws-s3-creds
EOF
```

If you configure Grafana Loki on the management cluster, you can add this
configuration to the installer configuration instead. 5. Apply the
configuration override to the grafana-loki-v3 AppDeployment:

```bash
cat << EOF | kubectl -n ${WORKSPACE_NAMESPACE} patch appdeployment grafana-loki-v3 --
type="merge" --patch-file=/dev/stdin
spec:
configOverrides:
name: grafana-loki-v3-overrides
EOF
```

> **Note: If you use the Kommander CLI installation configuration file, you
> can skip this step.**

##### Migrating Grafana Loki to Time Series Database Index Type

Grafana Loki currently uses boltdb-shipper as its default index type. However,
you can migrate to the recommended time series database (TSDB) index type by
making configuration changes that automatically switch from boltdb-shipper to
TSDB at a specified future date.

About this task

To migrate Grafana Loki to TSDB index type, follow these steps:

Procedure

1. Log into the NKP UI dashboard.
2. In the top-left corner, click the Global dropdown list and select your
   target workspace.

For example, if your target cluster is a management cluster, select Management
Cluster Workspace. 3. In the cluster widget, click View Details. 4. In the
General Cluster Information page, click the Enabled Applications tab. 5.
Locate Grafana Loki and click View Details. 6. On the Grafana Loki page, click
the Configuration tab. 7. In the top right corner, click Edit. 8. In the
Workspace Application Configuration Override field, paste the override
configuration to begin the migration:

```bash
# Loki configuration
loki:
schemaConfig:
configs:
- from: "2020-09-07"
store: boltdb-shipper
schema: v11
...
- from: "2027-01-01" [1]
store: tsdb [2]
object_store: s3 [3]
schema: v13 [4]
index:
prefix: loki_index_
period: 24h
storage_config:
boltdb_shipper:
...
tsdb_shipper: [5]
active_index_directory: /data/tsdb-index
cache_location: /data/tsdb-cache
```

> **Important: You must add a new period_config entry in your schema_config
> section.**

Configure the migration parameters based on the following guidelines:

- [1] Migration Date: Ensure that the new period begins on a future date. The
  TSDB migration takes place at 00:00:00 UTC on the specified date.
- [2] Index Type: To update the new period to use TSDB as the index type, set
  store to tsdb.
- [3] Object Store: The sample configuration uses filesystem as the storage in
  both periods. To use a different storage for the TSDB index, specify a
  different object_store in the new period.
- [4] Schema Version: Update the schema to the recommended version v13.
- [5] TSDB Shipper Configuration: In the storage_config section, configure the
  tsdb_shipper block by specifying the active index directory and cache
  location.

1. Click Save. The migration from using boltdb-shipper to TSDB as the index
   type, automatically begins at the specified date and time. Ensure that your
   system is prepared for the transition and that you configured adequate
   storage for the new TSDB index.

##### Troubleshooting LoggingStack GrafanaLokiV3Deployed Failure

Resolve LoggingStack condition failures when the logging stack controller
cannot convert existing Grafana Loki v2 override ConfigMaps to Grafana Loki v3
format during platform upgrades.

About this task

During a platform upgrade, the logging stack controller automatically migrates
Grafana Loki from v2 to v3. As part of the migration, the logging stack
controller validates and converts existing Grafana Loki override ConfigMaps
into the v3 format. If the logging stack controller fails to convert one or
more ConfigMaps, the migration is blocked and requires manual resolution.

To detect, diagnose, and resolve conversion failures, follow these steps:

Procedure

1. Check the loggingstack condition:

```bash
kubectl get loggingstack <name> -n <namespace> -o jsonpath='{.status.conditions}' |
jq '.[] | select(.type == "GrafanaLokiV3Deployed")'
```

Sample output:

```bash
{
"type": "GrafanaLokiV3Deployed",
"status": "False",
"reason": "Failed",
"message": "Failed to convert Loki v2 overrides configurations to v3 format for:
workspace 'my-workspace', cluster 'my-cluster' in workspace 'my-workspace'. Please
update the affected override ConfigMaps manually and annotate the LoggingStack with
reconcile.loggingstack.nkp.nutanix.com/requestedAt=<timestamp> to retry."
}
```

The message field lists every scope that failed and identifies the ConfigMaps
that needs attention. 2. (Optional) Check Kubernetes events for additional
diagnostic information:

```bash
kubectl get events -n <namespace> --field-selector reason=GrafanaLokiV3Deployed
```

1. Identify the specific scopes that require attention.

Sample message field:

```bash
Failed to convert Loki v2 overrides configurations to v3 format for:
workspace 'platform-team',
project 'analytics',
cluster 'prod-east-1' in workspace 'platform-team'.
Please update the affected override ConfigMaps manually and annotate the
LoggingStack with reconcile.loggingstack.nkp.nutanix.com/requestedAt=<timestamp> to
retry.
```

The following shows the scope type and name for each failure in the message
field:

- workspace 'platform-team': Workspace-level override
- project 'analytics': Project-level override
- cluster 'prod-east-1' in workspace 'platform-team': Per-cluster override on
  the workspace AppDeployment

1. Prepare valid Grafana Loki v3 configuration values.

For each failing scope that the message field identifies, create a YAML
configuration snippet that works with Grafana Loki v3. Include only the
settings specific to that scope.

```yaml
Important: To find the correct field names and structure, use the Grafana Loki configuration parameters
reference. The values you paste into the Nutanix Kubernetes® Platform (NKP) UI are standard Loki Helm chart
values, not the raw Loki server config file.
```

1. Deploy Grafana Loki using the NKP UI at each failing scope.

The scope type that the failure message shows determines where you deploy the
application in the NKP UI:

- To deploy Grafana Loki at the workspace-level failures for your workspace,
  see Cluster-scoped Application Configuration from the NKP UI on page 371.
- To deploy Grafana Loki at the project-level failures for your project, see
  Enabling the Platform Application Using the UI on page 417.
- To deploy Grafana Loki per-cluster failures for the cluster at workspace
  level or for the cluster at the project level, see Application Management
  Using the UI on page 334.

A per-cluster failure means that the cluster-specific configuration override
on the Loki AppDeployment fails to convert. Deploy Grafana Loki with a
configuration that targets the specific cluster.

```yaml
Note: If the message field lists multiple clusters, repeat these steps for each cluster. Alternatively, deploy once
with a configuration that targets all listed clusters if the values are identical.
```

1. Trigger a reconciliation:

```bash
kubectl annotate loggingstack <name> -n <namespace> \
reconcile.loggingstack.nkp.nutanix.com/requestedAt="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
\
--overwrite
```

1. Verify that the failure resolves and the migration succeeds:

```bash
kubectl get loggingstack <name> -n <namespace> -o jsonpath='{.status.conditions}' | \
jq '.[] | select(.type == "GrafanaLokiV3Deployed")'
```

A successful migration displays the following output:

```bash
{
"type": "GrafanaLokiV3Deployed",
"status": "True",
"reason": "Succeeded",
"message": "Loki v3 deployment completed"
}
```

#### Rook Ceph

Storage

ObjectBucketClaim Storage Limit

ObjectBucketClaim has a storage limit option to prevent your S3 bucket from
growing over a limit. In NKP this is enabled by default.

Thus, after you size up your Rook Ceph Cluster for more storage, it is
important to also increase the storage limit of your ObjectBucketClaims of
your grafana-loki and/or project-grafana-loki.

To change it for grafana-loki , provide an override configmap in rook-ceph-
cluster platform app to override nkp.grafana-loki.maxSize

To change it for project-grafana-loki , provide an override configmap in
project-grafana-loki platform app to override nkp.project-grafana-loki.maxSize

Example Configuration

You can see an example configuration in Rook Ceph Cluster Sizing
Recommendations on page 332.

Ceph OSD CPU Considerations

ceph-osd is the object storage daemon for the Ceph distributed file system. It
is responsible for storing objects on a local file system and providing access
to them over the network.

If you determine that the Ceph OSD component is the bottleneck, then you may
wish to consider increasing the CPU allocated to it.

For more information on Ceph OSD CPU Scaling, see
`<https://ceph.io/en/news/blog/2022/ceph-osd-cpu-scaling/>`.

Grafana Dashboard

In NKP, if the Prometheus Monitoring (kube-prometheus-stack) platform app is
enabled, you can view the Ceph dashboards in the Grafana UI.

#### Audit Log

Overhead

To see the default configuration of Fluent Bit, see NKP Release Notes on the
Nutanix Support Portal.

For more information:

### Admin-level Logs

- On configuration files, see
  `<<https://docs.fluentbit.io/manual/administration/configuring-fluent->`
  bit/classic-> mode/configuration-file.

NKP also includes a Fluentbit instance to collect admin-level log information,
which is sent to the workspace Grafana Loki, which is running on the cluster.
The admin log information includes:

- Logs for host processes managed by systemd
- Kernel logs
- Kubernetes audit logs

This approach helps to isolate the more sensitive logs from the Logging-
operator, eliminating the possibility that users might gain inadvertent access
to that data.

For more information on these logs, see Fluent Bit on page 613.

```yaml
Warning: On the Management cluster, the Fluentbit application is disabled by default. The amount of admin logs
ingested to Loki requires additional disk space to be configured on the rook-ceph-cluster. Enabling admin logs
might take around 2GB/day per node. See
```

For more details on how to configure the Ceph Cluster, see Rook Ceph in NKP on
page 681.

### Workspace-level Logging

Logging is disabled by default on managed and attached clusters. You will need
to enable logging features explicitly at the Workspace level if you want to
capture and view log data.

> **Warning: You must perform these procedures to enable multi-tenant
> logging at the Project level as well.**

#### Logging Architecture

The NKP logging stack architecture provides a comprehensive logging solution
for the NKP platform. It combines Fluent Bit, Fluentd, Loki, and Grafana
components to collect, process, store, and visualize log data. The
architecture establishes a robust logging solution by assigning specific roles
to each of those components.

Components:

- Fluent Bit - Fluent Bit is a lightweight log processor and forwarder that
  collects log data from various sources, such as application logs or
  Kubernetes components. It forwards the collected logs to Fluentd for further
  processing.
- Fluentd - Fluentd is a powerful and flexible log aggregator that receives
  log data from Fluent Bit, processes it, and forwards it to the Loki
  Distributor. Fluentd can handle various log formats and enrich the log data
  with additional metadata before forwarding it.
- Loki - Loki is a horizontally-scalable, highly-available, multi-tenant log
  aggregation system. Loki components include:- Compactor: Responsible for
  compacting index files and chunks to improve query performance and reduce
  storage usage.
- Distributor: Receives log streams, partitions them into chunks, and forwards
  these chunks to the Loki Ingester component.
- Gateway: Acts as a single access point to various Loki components, routing
  requests between the Distributor, Query Frontend, and other components as
  needed.
- Ingester: Compresses, indexes, and persists received log chunks.
- Querier: Fetches log chunks from the Ingester, decompresses and filters them
  based on the query, and returns the results to the Query Frontend.
- Query Frontend: Splits incoming queries into smaller parts, forwards these
  to the Loki Querier component, and combines the results from all Queriers
  before returning the final result.
- Grafana: Grafana is a visualization and analytics platform that supports
  Loki as one of its data sources. Grafana provides a user-friendly interface
  for querying and visualizing log data based on user-defined dashboards and
  panels.
- Grafana - Grafana is a visualization and analytics platform that supports
  Loki as one of its data sources. Grafana provides a user-friendly interface
  for querying and visualizing log data based on user-defined dashboards and
  panels.

Workflow

- Write Path:
- Fluent Bit instances running on each node collect log data from various
  sources, like application logs or Kubernetes components.
- Fluent Bit forwards the collected log data to the Fluentd instance.
- Fluentd processes the received log data and forwards it to the Loki
  Distributor through the Loki Gateway.
- The Loki Distributor receives the log streams, partitions them into chunks,
  and forwards these chunks to the Loki Ingester component.
- Loki Ingesters are responsible for compressing, indexing, and persisting the
  received log chunks.
- Read Path:
- When a user queries logs through Grafana, the request goes to the Loki
  Gateway, which routes it to the Loki Query Frontend.
- The Query Frontend splits the query into smaller parts and forwards these to
  the Loki Querier component.
- Loki Queriers fetch the log chunks from the Loki Ingester, decompress and
  filter them based on the query, and return the results to the Query
  Frontend.
- The Query Frontend combines the results from all Queriers and returns the
  final result to Grafana through the Loki Gateway.
- Grafana visualizes the log data based on the user's dashboard configuration.

#### Enabling Logging Applications Using the UI

Before you begin

You must:

- Be a cluster administrator with permissions to configure cluster-level
  platform services.
- Set a default storage class on each attached cluster for successful Loki
  deployment.

For more information, see Default Storage Providers in NKP .

About this task

You can enable the Workspace logging stack to all attached clusters within the
Workspace through the UI. If you prefer to enable the logging stack with
kubectl, review how you Creating AppDeployments to Enable Workspace Logging on
page 601.

To enable workspace-level logging in NKP using the UI, follow these steps:

Procedure

1. From the top menu bar, select your target workspace.
2. Select Applications from the sidebar menu.
3. Ensure traefik and cert-manager are enabled on your cluster. These are
   deployed by default unless you modify your configuration.
4. Scroll to the Logging applications section.
5. Select the three-dot button from the bottom-right corner of the cards for
   Rook Ceph and Rook Ceph Cluster, then click Enable. On the Enable Workspace
   Platform Application page, you can add a customized configuration for
   settings that best fit your organization. You can leave the configuration
   settings unchanged to enable with default settings.
6. Select Enable at the top right of the page.
7. Repeat the process for the Grafana Loki, Logging Operator, and Grafana
   Logging applications.
8. You can verify the cluster logging stack installation by waiting until the
   cards have a Deployed checkmark on the Cluster Application page, or you can
   verify the Cluster Logging Stack installation through the CLI
9. Then, you can view cluster log data.

```yaml
Warning: We do not recommend installing Fluent Bit, which is responsible for collecting admin logs, unless you
have configured the Grafana Loki Ceph Cluster Bucket with sufficient storage space. The amount of admin logs
ingested to Loki requires additional disk space to be configured on the rook-ceph-cluster. Enabling admin
logs might use around 2GB/day per node. For details on how to configure the Ceph Cluster, see Rook Ceph in
NKP on page 681.
```

#### Creating AppDeployments to Enable Workspace Logging

About this task

Workspace logging AppDeployments enable and deploy the logging stack to all
attached clusters within the workspace. Use the NKP UI to enable the logging
applications, or, alternately, use the CLI to create the AppDeployments.

To enable logging in NKP using the CLI, follow these steps on the management
cluster:

Procedure

1. Execute the following command to get the name and namespace of your
   workspace.

```bash
nkp get workspaces
```

And copy the values under the NAME and NAMESPACE columns for your workspace. 2. Export the WORKSPACE_NAME variable.

```bash
export WORKSPACE_NAME=<WORKSPACE_NAME>
```

1. Export the WORKSPACE_NAMESPACE variable.

```bash
export WORKSPACE_NAMESPACE=<WORKSPACE_NAMESPACE>
```

1. Ensure that Cert-Manager and Traefik are enabled in the workspace. If you
   want to find out if the applications are enabled on the management cluster
   workspace, you can run them.

```bash
nkp get appdeployments --workspace ${WORKSPACE_NAME}
```

1. You can confirm that the applications are deployed on the managed or
   attached cluster by running this kubectl command in that cluster. Ensure you
   switch to the correct context or kubeconfig of the attached cluster for the
   following kubectl command. For more information, see
   `<https://kubernetes.io/docs/tasks/access-application-cluster/configure->`
   access-multiple-clusters/).

```bash
kubectl get helmreleases -n ${WORKSPACE_NAMESPACE}
```

1. Copy these commands and run them on the management cluster from a command
   line to create the Logging- operator, Grafana-loki, and Grafana-logging
   AppDeployments.

```bash
nkp create appdeployment logging-operator --app logging-operator-6.4.0 --workspace
${WORKSPACE_NAME}
nkp create appdeployment rook-ceph --app rook-ceph-1.19.5 --workspace
${WORKSPACE_NAME}
nkp create appdeployment rook-ceph-cluster --app rook-ceph-cluster-1.19.6 --workspace
${WORKSPACE_NAME}
nkp create appdeployment grafana-loki-v3 --app grafana-loki-v3-3.6.7 --workspace
${WORKSPACE_NAME}
nkp create appdeployment grafana-logging --app grafana-logging-11.3.3 --workspace
${WORKSPACE_NAME}
```

Then, you can verify the cluster logging stack installation. For more
information, see Verifying the Cluster Logging Stack Installation on page 605.

To deploy the applications to selected clusters within the workspace, refer to
the Cluster-scoped Application Configuration from the NKP UI on page 371.

```yaml
Warning: We do not recommend installing Fluent Bit, which is responsible for collecting admin logs unless you
have configured the Rook Ceph Cluster with sufficient storage space. Enabling admin logs through Fluent Bit might
use around 2GB/day per node. For more information on how to configure the Rook Ceph Cluster, see Rook Ceph
in NKP on page 681.
```

1. To install Fluent Bit, create the AppDeployment.

```bash
nkp create appdeployment fluent-bit --app fluent-bit-0.57.2 --workspace
${WORKSPACE_NAME}
```

#### Overriding ConfigMap to Restrict Logging

About this task

How to override the logging configMap to restrict logging to specific
namespaces.

As a cluster administrator, you may need to limit or restrict logging
activities to certain namespaces. Kommander allows you to do this by creating
an override configMap that modifies the logging configuration created in
Creating AppDeployments to Enable Workspace Logging on page 601.

Before you begin

- Implement each of the steps listed in Workspace-level Logging on page 599.
- Ensure that log data is available before you run this procedure.

To create and use the override configMap entries, follow these steps:

Procedure

1. Execute the following command to get the namespace of your workspace.

```bash
nkp get workspaces
```

And copy the value under the NAMESPACE column for your workspace. 2. Set the
WORKSPACE_NAMESPACE variable to the namespace copied in the previous step.

```bash
export WORKSPACE_NAMESPACE=<WORKSPACE_NAMESPACE>
```

1. Identify one or more namespaces to which you want to restrict logging.
2. Create a file named logging-operator-logging-overrides.yaml and paste the
   following YAML code into it to create the overrides configMap.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: logging-operator-logging-overrides
namespace: ${WORKSPACE_NAMESPACE}
data:
values.yaml: |
---
clusterFlows:
  - name: cluster-containers
spec:
globalOutputRefs:
  - loki
match:
  - exclude:
namespaces:
  - <your-namespace>
  - <your-other-namespace>
```

1. Add the relevant namespace values for metadata.namespace and the

clusterFlows[0].spec.match[0].exclude.namespaces values at the end of the
file, and save the file. 6. Use the following command to apply the YAML file.

```bash
kubectl apply -f logging-operator-logging-overrides.yaml
```

1. Edit the logging-operator AppDeployment to set the value of
   spec.configOverrides.name to logging-

operator-logging-overrides.

For more information, see AppDeployment Resources on page 327.

```bash
nkp edit appdeployment -n ${WORKSPACE_NAMESPACE} logging-operator
```

After your editing is complete, the AppDeployment resembles this example:

```yaml
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: logging-operator
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: logging-operator-6.4.0
kind: ClusterApp
configOverrides:
name: logging-operator-logging-overrides
```

1. Perform actions that generate log data, both in the specified namespaces
   and the namespaces you mean to exclude.
2. Verify that the log data contains only the data you expected to receive.

#### Overriding ConfigMap to Modify the Storage Retention

About this task

For more information on Compactor, see
`<https://grafana.com/docs/loki/latest/operations/storage/boltdb->`
shipper/#compactor.

The minimum retention period is 24 hours.

To customize the retention policy using configOverrides, run these commands on
the management cluster:

Procedure

1. Execute the following command to get the namespace of your workspace.

```bash
nkp get workspaces
```

Copy the value under the NAMESPACE column for your workspace. 2. Set the
WORKSPACE_NAMESPACE variable to the namespace copied in the previous step.

```bash
export WORKSPACE_NAMESPACE=<WORKSPACE_NAMESPACE>
```

1. Create a ConfigMap with custom configuration values for Grafana Loki. Since
   the retention configuration is nested in a config string, you must copy the
   entire block. The following example sets the retention period to 360 hours
   (15 days). For more information on this field, see https://
   grafana.com/docs/loki/latest/operations/storage/retention/#retention-
   configuration.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
name: grafana-loki-v3-custom-overrides
namespace: ${WORKSPACE_NAMESPACE}
data:
values.yaml: |
loki:
structuredConfig:
limits_config:
retention_period: 360h
EOF
```

1. Edit the grafana-loki AppDeployment to set the value of
   spec.configOverrides.name to grafana-

```bash
loki-v3-custom-overrides
```

For more information on deploying a service with a custom configuration, see
AppDeployment Resources on page 327.

```bash
nkp edit appdeployment -n ${WORKSPACE_NAMESPACE} grafana-loki-v3
```

After your editing is complete, the AppDeployment resembles this example.

```yaml
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: grafana-loki-v3
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: grafana-loki-v3-3.6.7
kind: ClusterApp
configOverrides:
name: grafana-loki-v3-custom-overrides
```

#### Verifying the Cluster Logging Stack Installation

About this task

You must wait for the cluster's logging stack HelmReleases to deploy before
attempting to configure or use the logging features.

Run the following commands on the management cluster:

Procedure

1. Execute the following command to get the namespace of your workspace.

```bash
nkp get workspaces
```

Copy the value under the NAMESPACE column for your workspace. 2. Set the
WORKSPACE_NAMESPACE variable to the namespace copied in the previous step.

```bash
export WORKSPACE_NAMESPACE=<WORKSPACE_NAMESPACE>
```

Run the following commands on the managed or attached cluster. Ensure you
switch to the correct context or kubeconfig of the attached cluster for the
following kubectl commands. For more information, see https://
kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-
clusters/. 3. Check the deployment status using this command on the attached
cluster.

```bash
kubectl get helmreleases -n ${WORKSPACE_NAMESPACE}
Note: It may take some time for these changes to take effect, based on the duration configured for the Flux
GitRepository reconciliation.
```

When the logging stack is successfully deployed, you will see output that
includes the following HelmReleases:

```bash
NAME READY STATUS AGE
grafana-logging True Release reconciliation succeeded 15m
logging-operator True Release reconciliation succeeded 15m
logging-operator-logging True Release reconciliation succeeded 15m
grafana-loki-v3 True Release reconciliation succeeded 15m
rook-ceph True Release reconciliation succeeded 15m
rook-ceph-cluster True Release reconciliation succeeded 15m
object-bucket-claims True Release reconciliation succeeded 15m
```

What to do next

#### Viewing Cluster Log Data

About this task

Though you enable logging at the Workspace level, you can view the log data at
the cluster level using the cluster's Grafana logging URL.

Run the following commands on the management cluster:

Procedure

1. Execute the following command to get the namespace of your workspace.

```bash
nkp get workspaces
```

And copy the value under the NAMESPACE column for your workspace. 2. Set the
WORKSPACE_NAMESPACE variable to the namespace copied in the previous step.

```bash
export WORKSPACE_NAMESPACE=<WORKSPACE_NAMESPACE>
```

Run the following commands on the attached cluster to access the Grafana UI.
Ensure you switch to the correct context or kubeconfig of the attached cluster
for the following kubectl commands. For more information, see Configure Access
to Multiple Clusters. 3. Get the Grafana URL.

```bash
kubectl get ingress -n ${WORKSPACE_NAMESPACE} grafana-logging -o go-
template='https://{{with index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}
{{end}}{{with index .spec.rules 0}}{{with index .http.paths 0}}{{.path }}{{end}}
{{end}}{{"\n"}}'
```

To view logs in Grafana:

- 1. Go to the Explore tab:

```bash
kubectl get ingress -n ${WORKSPACE_NAMESPACE} grafana-logging -o
go-template='https://{{with index .status.loadBalancer.ingress 0}}
{{or .hostname .ip}}{{end}}{{with index .spec.rules 0}}{{with index .http.paths
0}}{{.path }}{{end}}{{end}}/explore{{"\n"}}'
```

1. You might be prompted to log on using the SSO flow. 3. At the top of the
   page, change the data source to Loki.

For more on how to use the interface to view and query logs, see the Grafana
Loki documentation.

```yaml
Warning: Cert-Manager and Traefik must be deployed in the attached cluster to be able to access the Grafana UI.
These are deployed by default on the workspace.
```

### Multi-Tenant Logging

- BanzaiCloud logging-operator
- Grafana Loki
- Grafana

> **Note:**

Access to log data is done at the namespace level through the use of Projects
within Kommander, as shown in the diagram:

Each Project namespace has a logging-operator, "Flow" that sends its pod logs
to its own Loki server. A custom controller deploys corresponding Loki and
Grafana servers in each namespace, and defines a logging-operator Flow in each
namespace that forwards its pod logs to its respective Loki server. There is a
corresponding Grafana server for visualizations for each namespace.

For the convenience of cluster Administrators, a cluster-scoped Loki/Grafana
instance pair is deployed with a corresponding Logging-operator ClusterFlow
that directs pod logs from all namespaces to the pair. A cluster

Administrator can grant access either to none of the logs, or to all logs
collected from all pods in a given namespace. Assigning teams to specific
namespaces enables the team members to see only the logs for the namespaces
they own.

As with any endpoint, if an Ingress controller is in use in the environment,
take care that the ingress rules do not supersede the RBAC permissions and
thus prevent access to the logs.

```yaml
Note: Cluster Administrators will need to monitor and adjust resource usage to prevent operational difficulties or
excessive use on a per namespace basis.
```

#### Enabling Multi-tenant Logging

About this task

Context for the current task

Before you begin

- Enable workspace-level logging before you can configure multi-tenant
  logging. For more information, see Workspace-level Logging on page 599.
- Be a cluster administrator with permissions to configure cluster-level
  platform services.

Multi-tenant Logging Enablement Process

The steps required to enable multi-tenant logging include:

Procedure

#### Creating a Project for Logging

1. Create the required Project-level AppDeployments.
2. Verifying the Project Logging Stack Installation on page 611
3. Viewing Project Log Data on page 611

About this task

To enable multi-tenant logging:

Procedure

1. You must first create a Project and its namespace. Users assigned to this
   namespace will be able to access log data for only that namespace and not
   others.
2. Then, you can create project-level AppDeployments for use in multi-tenant
   logging.

#### Creating the Project-level AppDeployments

About this task

You must create AppDeployments in the Project namespace to enable and deploy
the logging stack to all clusters within a Project. You can use the CLI to do
this, or use the DKP UI to enable the logging applications.

To create the AppDeployments needed for Project-level logging, follow these
steps on the management cluster:

Procedure

1. Determine the namespace of the workspace that your project is in. You can
   use the following command to see the list of workspace names and their
   corresponding namespaces.

```bash
nkp get workspaces
```

Copy the value under the NAMESPACE column for your workspace. 2. Export the
WORKSPACE_NAME variable.

```bash
export WORKSPACE_NAME=<WORKSPACE_NAME>
```

1. Export the WORKSPACE_NAMESPACE variable.

```bash
export WORKSPACE_NAMESPACE=<WORKSPACE_NAMESPACE>
```

1. Execute the following command to get the namespace of your project.

```bash
kubectl get projects -n ${WORKSPACE_NAMESPACE}
```

Copy the value under the PROJECT NAMESPACE column for your project. This might
not be identical to the Display Name of the Project.

. 5. Export the PROJECT_NAME variable.

```bash
export PROJECT_NAME=<PROJECT_NAME >
```

1. Copy these commands and execute them from a command line:

```bash
nkp create appdeployment project-grafana-loki-v3 --app project-grafana-loki-v3-3.6.7
--workspace ${WORKSPACE_NAME} --project ${PROJECT_NAME}
nkp create appdeployment project-grafana-logging --app project-grafana-logging-11.3.3
--workspace ${WORKSPACE_NAME} --project ${PROJECT_NAME}
nkp create appdeployment project-logging --app project-logging-1.1.0 --workspace
${WORKSPACE_NAME} --project ${PROJECT_NAME}
kubectl get helmreleases -n ${PROJECT_NAMESPACE}
```

What to do next

Verifying the Project Logging Stack Installation on page 611

#### Overriding ConfigMap to Modify the Storage Retention (2)

About this task

For more information on Compactor, see
`<https://grafana.com/docs/loki/latest/operations/storage/boltdb->`
shipper/#compactor.

The minimum retention period is 24 hours.

To customize the retention policy using configOverrides, run these commands on
the management cluster:

Procedure

1. Determine the namespace of the workspace that your project is in. You can
   use the nkp get workspaces command to see the list of workspace names and
   their corresponding namespaces.

```bash
nkp get workspaces
```

Copy the value under the NAMESPACE column for your workspace. This might NOT
be identical to the Display Name of the Workspace. 2. Set the
WORKSPACE_NAMESPACE variable to the namespace copied in the previous step.

```bash
export WORKSPACE_NAMESPACE=<WORKSPACE_NAMESPACE>
```

1. Get the namespace of your project.

```bash
kubectl get projects --namespace ${WORKSPACE_NAMESPACE}
```

Copy the value under the PROJECT NAMESPACE column for your workspace. This may
NOT be identical to the Display Name of the Project. 4. Set the
PROJECT_NAMESPACE variable to the namespace copied in the previous step.

```bash
export PROJECT_NAMESPACE=<PROJECT_NAMESPACE>
```

1. Create a ConfigMap with custom configuration values for Grafana Loki. Since
   the retention configuration is nested in a config string, you must copy the
   entire block. The following example sets the retention period to 360 hours
   (15 days). For more information on Grafana Loki's Retention Configuration,
   see
   `<<https://grafana.com/docs/loki/latest/operations/storage/retention/#rete>`
   ntion-> configuration.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
name: project-grafana-loki-v3-custom-overrides
namespace: ${PROJECT_NAMESPACE}
data:
values.yaml: |
loki:
structuredConfig:
limits_config:
retention_period: 360h
EOF
```

1. Run the following command on the management cluster to reference the
   configOverrides in project-

grafana-loki AppDeployment.

```yaml
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: project-grafana-loki-v3
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: project-grafana-loki-v3-3.6.7
kind: ClusterApp
configOverrides:
name: project-grafana-loki-v3-custom-overrides
EOF
```

#### Verifying the Project Logging Stack Installation

About this task

You must wait for the project's logging stack HelmReleases , to deploy before
attempting to configure or use the project-level logging features, including
multi-tenancy.

Run the following commands on the management cluster:

Procedure

1. Determine the namespace of the workspace that your project is in. You can
   use the following command to see the list of workspace names and their
   corresponding namespaces.

```bash
nkp get workspaces
```

Copy the value under the NAMESPACE column for your workspace. 2. Export the
WORKSPACE_NAMESPACE variable.

```bash
export WORKSPACE_NAMESPACE=<WORKSPACE_NAMESPACE>
```

1. Execute the following command to get the namespace of your project.

```bash
kubectl get projects -n ${WORKSPACE_NAMESPACE}
```

Copy the value under the PROJECT NAMESPACE column for your project. This might
not be identical to the Display Name of the Project.

. 4. Export the PROJECT_NAMESPACE variable.

```bash
export PROJECT_NAMESPACE=<PROJECT_NAMESPACE>
```

Run the following commands on the managed or attached cluster. Ensure you
switch to the correct context or kubeconfig of the attached cluster for the
following kubectl commands. For more information, see https://
kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-
clusters/. 5. Check the deployment status using this command on the attached
cluster.

```bash
kubectl get helmreleases -n ${PROJECT_NAMESPACE}
Note: It may take some time for these changes to take effect, based on the duration configured for the Flux
GitRepository reconciliation.
```

When the logging stack is successfully deployed, you will see output that
includes the following HelmReleases:

```bash
NAMESPACE NAME READY STATUS
AGE
${PROJECT_NAMESPACE} project-grafana-logging True Release
reconciliation succeeded 15m
${PROJECT_NAMESPACE} project-grafana-loki-v3 True Release
reconciliation succeeded 11m
${PROJECT_NAMESPACE} project-loki-object-bucket-claims True Release
reconciliation succeeded 11m
```

What to do next

#### Viewing Project Log Data

About this task

You can only view the log data for a Project to which you have been granted
access.

To access Project Grafana's UI:

Run the following commands on the management cluster:

Procedure

1. Determine the namespace of the workspace that your project is in. You can
   use the nkp get workspaces command to see the list of workspace names and
   their corresponding namespaces.

```bash
nkp get workspaces
```

Copy the value under the NAMESPACE column for your workspace. 2. Export the
WORKSPACE_NAMESPACE variable.

```bash
export WORKSPACE_NAMESPACE=<WORKSPACE_NAMESPACE>
```

1. Execute the following command to get the namespace of your project.

```bash
kubectl get projects -n ${WORKSPACE_NAMESPACE}
```

And copy the value under the PROJECT NAMESPACE column for your project. This
might NOT be identical to the Display Name of the Project. 4. Export the
PROJECT_NAMESPACE variable.

```bash
export PROJECT_NAMESPACE=<PROJECT_NAMESPACE>
```

Run the following commands on the attached cluster to access the Grafana UI.
Ensure you switch to the correct context or kubeconfig of the attached cluster
for the following kubectl commands. For more information, see
`<https://kubernetes.io/docs/tasks/access-application-cluster/>` configure-
access-multiple-clusters/. 5. Get the Grafana URL.

```bash
kubectl get ingress -n ${PROJECT_NAMESPACE} ${PROJECT_NAMESPACE}-project-grafana-
logging -o go-template='https://{{with index .status.loadBalancer.ingress 0}}
{{or .hostname .ip}}{{end}}{{with index .spec.rules 0}}{{with index .http.paths 0}}
{{.path }}{{end}}{{end}}{{"\n"}}'
```

To view logs in Grafana:

- 1. Go to the Explore tab:

```bash
kubectl get ingress -n ${PROJECT_NAMESPACE} ${PROJECT_NAMESPACE}-
project-grafana-logging -o go-template='https://{{with
index .status.loadBalancer.ingress 0}}{{or .hostname .ip}}{{end}}{{with
index .spec.rules 0}}{{with index .http.paths 0}}{{.path }}{{end}}{{end}}/
explore{{"\n"}}'
```

1. You might be prompted to log on using the SSO flow.

For more information, see Authentication on page 621 and Authorization. 3. At
the top of the page, change the data source to Loki.

For more on how to use the interface to view and query logs, see
`<https://grafana.com/docs/grafana/v7.5/>` datasources/loki/.

```yaml
Warning: Cert-Manager and Traefik must be deployed in the attached cluster to be able to access the Grafana UI.
These are deployed by default on the workspace.
```

You can configure the workspace policy to restrict access to the Project
logging Grafana UI. For more information, see
Logging on page 590. Each Grafana instance in a Project has a unique URL at
the cluster level. Consider creating a
WorkspaceRoleBinding that maps to a ClusterRoleBinding, on attached
cluster(s), for each Project level Grafana instance.
For example, If you have a group named sample-group and two projects named
first- project and second-project in sample-
workspace workspace, then the Role Bindings will look similar.

Select the correct role bindings for each group for a project at the workspace
level.

### Fluent Bit

For more information, see `<https://fluentbit.io/>`.

```yaml
Warning: The Fluentbit application is disabled by default on the management cluster. To ingest Kubernetes audit,
systemd, and kernel logs, configure Loki with additional disk space. We recommend at least 2GB per node, per day of
log retention. For a 10 node cluster and 7 days retention, configure an additional 140GB of disk space. Enabling admin
logs might use around 2GB/day per node.
```

For more details on how to configure the Rook Ceph Cluster, see Rook Ceph on
page 597.

Audit Log Collection

Auditing in Kubernetes provides a way to document the actions taken on a
cluster chronologically. For more information, see
`<https://kubernetes.io/docs/tasks/debug/debug-cluster/audit/>`.

On Kommander, by default, audit logs are collected and stored for quick
indexing. Viewing and accessing can be done through the Grafana logging UI.

#### Collecting systemd Logs from a Non-default Path

About this task

### Fluent Bit (2)

Procedure

```bash
nkp get workspaces
```

Copy the value under the NAMESPACE column for your workspace. 2. Set the
WORKSPACE_NAMESPACE variable to the namespace copied in the previous step.

```bash
export WORKSPACE_NAMESPACE=<WORKSPACE_NAMESPACE>
```

1. Identify the systemd-journald log data storage path on the nodes of the
   clusters in the workspace by using the OS documentation and examining the
   systemd configuration. Usually, it will be either /var/log/journal
   (typically used when systemd-journald is configured to store logs
   permanently; in this case, the default Fluent Bit configuration should work)
   or /run/log/journal (typically used when systemd-journald is configured to
   use volatile storage).
2. Extract the default Helm values used by the Fluent Bit App.

```bash
kubectl get -n ${WORKSPACE_NAMESPACE} configmaps fluent-bit-0.57.2-config-defaults
-o=jsonpath='{.data.values\.yaml}' > fluent-bit-values.yaml
```

1. Edit the resulting file fluent-bit-values.yaml by removing all sections
   except for extraVolumes, extraVolumeMounts and config.inputs. The result
   should look similar to this.

```bash
extraVolumes:
# we create this to have a persistent tail-db directory an all nodes
# otherwise a restarted fluent-bit would rescrape all tails
- name: tail-db
hostPath:
path: /var/log/tail-db
type: DirectoryOrCreate
# we create this to get rid of error messages that would appear on non control-
plane nodes
- name: kubernetes-audit
hostPath:
path: /var/log/kubernetes/audit
type: DirectoryOrCreate
# needed for kmsg input plugin
- name: uptime
hostPath:
path: /proc/uptime
type: File
- name: kmsg
hostPath:
path: /dev/kmsg
type: CharDevice
extraVolumeMounts:
- name: tail-db
mountPath: /tail-db
- name: kubernetes-audit
mountPath: /var/log/kubernetes/audit
- name: uptime
mountPath: /proc/uptime
- name: kmsg
mountPath: /dev/kmsg
config:
inputs: |
# Collect audit logs, systemd logs, and kernel logs.
# Pod logs are collected by the fluent-bit deployment managed by logging-
operator.
[INPUT]
Name tail
Alias kubernetes_audit
Path /var/log/kubernetes/audit/*.log
Parser kubernetes-audit
DB /tail-db/audit.db
Tag audit.*
Refresh_Interval 10
Rotate_Wait 5
Mem_Buf_Limit 135MB
Buffer_Chunk_Size 5MB
Buffer_Max_Size 20MB
Skip_Long_Lines Off
[INPUT]
Name systemd
Alias kubernetes_host
DB /tail-db/journal.db
Tag host.*
Max_Entries 1000
Read_From_Tail On
Strip_Underscores On
[INPUT]
Name kmsg
Alias kubernetes_host_kernel
Tag kernel
```

1. Add the following item to the list under the extraVolumes key.

```bash
- name: kubernetes-host
hostPath:
path: <path to systemd logs on the node>
type: Directory
```

1. Add the following item to the list under the extraVolumeMounts key.

```bash
- name: kubernetes-host
mountPath: <path to systemd logs on the node>
```

These items will make Kubernetes mount logs into Fluent Bit pods. 8. Add the
following line into the [INPUT] entry identified by Name systemd and Alias
kubernetes_host.

```bash
Path <path to systemd logs on the node>
```

This is needed to make Fluent Bit actually collect the mounted logs. 9.
Assuming that the path to systemd logs on the node is /run/log/journal, the
result will look similar to this.

```bash
extraVolumes:
# we create this to have a persistent tail-db directory an all nodes (2)
# otherwise a restarted fluent-bit would rescrape all tails (2)
- name: tail-db
hostPath:
path: /var/log/tail-db
type: DirectoryOrCreate
# we create this to get rid of error messages that would appear on non control- (2)
plane nodes
- name: kubernetes-audit
hostPath:
path: /var/log/kubernetes/audit
type: DirectoryOrCreate
# needed for kmsg input plugin (2)
- name: uptime
hostPath:
path: /proc/uptime
type: File
- name: kmsg
hostPath:
path: /dev/kmsg
type: CharDevice
- name: kubernetes-host
hostPath:
path: /run/log/journal
type: Directory
extraVolumeMounts:
- name: tail-db
mountPath: /tail-db
- name: kubernetes-audit
mountPath: /var/log/kubernetes/audit
- name: uptime
mountPath: /proc/uptime
- name: kmsg
mountPath: /dev/kmsg
- name: kubernetes-host
mountPath: /run/log/journal
config:
inputs: |
# Collect audit logs, systemd logs, and kernel logs. (2)
# Pod logs are collected by the fluent-bit deployment managed by logging- (2)
operator.
[INPUT]
Name tail
Alias kubernetes_audit
Path /var/log/kubernetes/audit/*.log
Parser kubernetes-audit
DB /tail-db/audit.db
Tag audit.*
Refresh_Interval 10
Rotate_Wait 5
Mem_Buf_Limit 135MB
Buffer_Chunk_Size 5MB
Buffer_Max_Size 20MB
Skip_Long_Lines Off
[INPUT]
Name systemd
Alias kubernetes_host
Path /run/log/journal
DB /tail-db/journal.db
Tag host.*
Max_Entries 1000
Read_From_Tail On
Strip_Underscores On
[INPUT]
Name kmsg
Alias kubernetes_host_kernel
Tag kernel
```

1. Create a ConfigMap manifest with override values from fluent-bit-values.yaml.

```bash
cat <<EOF >fluent-bit-overrides.yaml
apiVersion: v1
kind: ConfigMap
metadata:
namespace: ${WORKSPACE_NAMESPACE}
name: fluent-bit-overrides
data:
values.yaml: |
$(cat fluent-bit-values.yaml | sed 's/^/ /g')
EOF
```

1. Create a ConfigMap from the manifest above.

```bash
kubectl apply -f fluent-bit-overrides.yaml
```

1. Edit the fluent-bit AppDeployment to set the value of
   spec.configOverrides.name to the name of the created ConfigMap. You can use
   the steps in the procedure, and deploy an application with a custom
   configuration.

```bash
nkp edit appdeployment -n ${WORKSPACE_NAMESPACE} fluent-bit
```

After your editing is complete, the AppDeployment resembles this example.

```yaml
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: fluent-bit
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: fluent-bit-0.57.2
kind: ClusterApp
configOverrides:
name: fluent-bit-overrides
```

1. Log in to the Grafana logging UI of your workspace and verify that logs
   with a label log_source=kubernetes_host are now present in Loki.

### Customizing Logging Stack Applications

About this task

This page provides instructions on how you can customize the Logging Stack
Applications in NKP.

Procedure

1. Retrieve the Workspace Namespace

a. On the management cluster, run the following command to get the namespace
of your workspace.

```bash
nkp get workspaces
```

b. Copy the value under the NAMESPACE column for your workspace.

c. Set the WORKSPACE_NAMESPACE variable to the namespace copied in the
previous step.

```bash
export WORKSPACE_NAMESPACE=<WORKSPACE_NAMESPACE>
```

1. Customize Logging Stack applications.

a. On the Attached or Managed Cluster, retrieve the kubeconfig for the cluster.

b. Apply the ConfigMap directly to the managed/attached cluster using the
name, logging-operator-

logging-overrides.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
name: logging-operator-logging-overrides
namespace: ${WORKSPACE_NAMESPACE}
data:
values.yaml: |
<insert config here>
EOF
```

This is an example of a ConfigMap that contains customized resource requests
and limit values for fluentd:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: logging-operator-logging-overrides
namespace: kommander
data:
values.yaml: |
fluentd:
resources:
limits:
cpu: 1
memory: 2000Mi
requests:
cpu: 1
memory: 1500Mi
```

## Security

Details on distributed authentication and authorization between clusters

Authentication

Nutanix Kubernetes Platform (NKP) user interface comes with a pre-configured
authentication Dex identity broker and provider.

```yaml
Warning: Kubernetes, Kommander, and Dex do not store any user identities. The Kommander installation comes with
default admin static credentials. These credentials should only be used to access the NKP UI for configuring an external
identity provider. Currently, there is no way to update these credentials, so they should be treated as backup credentials
and not used for normal access.
```

The NKP user interface admin credentials are stored as a secret. They never
leave the boundary of the user interface cluster and are never shared with any
other cluster.

The Dex service issues an OIDC ID token for successful user authentication.
For more information, see https://
openid.net/specs/openid-connect-core-1_0.html#IDToken. Other platform services
use ID tokens as a proof of
authentication. The kube-oidc-proxy platform service that reads the identity
from an ID token provides user identity to
the Kubernetes API server. The traefik-forward-auth platform service
authenticates the web requests to access the NKP
user interface. For more information, see
`<https://github.com/mesosphere/traefik-forward-auth>`.

```yaml
Note: The kube-oidc-proxy service authenticates kubectl CLI requests using the Kubernetes API Server
Go library. For more information, see https://github.com/jetstack/kube-oidc-proxy. When you configure the
insecureSkipEmailVerified: true flag in Dex connector, the Kubernetes API Server Go library requires
email_verified claim to be present and is set to true. This ensures that the OIDC provider is configured to set the
email_verified field to true.
```

A user identity is shared across a user interface cluster and all other
attached clusters.

Attached Clusters

A newly attached cluster integrates kube-oidc-proxy, dex-k8s-authenticator,
and traefik-forward-auth platform applications. These platform applications
are configured to accept the Management or Pro cluster and the Dex issued ID
tokens. For more information, see Cluster Types on page 19.

When NKP uses the traefik-forward-auth platform service as an authenticator
for Traefik Ingress, it verifies whether the user identity was issued by the
Dex service of the Kommander cluster or the Management or Pro cluster.

| kube-oidc-proxy, | dex-k8s-authenticator |
| ---------------- | --------------------- |

This process ensures proper authentication and confirmation of the user
identity. For more information, see https://
doc.traefik.io/traefik/v2.4/providers/kubernetes-ingress/

The Dex service of the Kommander cluster issues the user identity for the
attached clusters. On the Management or Pro cluster, use the static admin
credentials or an external identity provider (IDP).

Authorization

Kommander does not have a centralized authorization component, and the service
makes its own authorization decisions based on user identity.

### OpenID Connect (OIDC)

All Kubernetes clusters have two categories of users: service accounts and
normal users. Kubernetes manages authentication for service accounts, but the
cluster administrator, or a separate service, manages authentication for
normal users.

To begin, set up an Identity Provider with Dex, then use OIDC as the
Authentication method.

### Identity Providers (2)

If you already use one or more of the following IdPs, you can configure Dex to
use them:

Table 58: Table

LDAP yes yes yes stable

GitHub yes yes yes stable

SAML 2.0 no yes no stable

GitLab yes yes yes beta

OpenID Connect

yes yes yes beta Includes Salesforce, Azure, etc.

Google yes yes yes alpha

LinkedIn yes no no beta

Microsoft yes yes no beta

AuthProxy no no no alpha Authentication proxies such as Apache2 mod_auth, etc.

Bitbucket Cloud yes yes no alpha

- Name; Supports Refresh Tokens; Supports Groups Claim; Supports; Status
  name; Notes

| --- | --- | --- | --- | --- | --- |

- **Name**; **Supports** **Refresh** **Tokens**; **Supports** **Groups
  Claim**; `preferred_user`; `name`; `name`
- **Name**; **Supports** **Refresh** **Tokens**; **Supports** **Groups
  Claim**; Claim; Claim; Claim

OpenShift no yes no stable

> **Note: These are the Identity Providers supported by Dex 2.22.0, the
> version used by NKP.**

### Login Connectors

Kommander uses Dex to provide OpenID Connect single sign-on (SSO) to the
cluster. Dex can be configured to use multiple connectors, including GitHub,
LDAP, and SAML 2.0. The Dex Connector documentation describes how to configure
different connectors. You can add the configuration as the values field in the
Dex application. An example Dex configuration provided to the Kommander CLI's
install command is similar to this:

```yaml
apiVersion: config.kommander.mesosphere.io/v1alpha1
kind: Installation
apps:
dex:
values: |
config:
connectors:
- type: oidc
id: google
name: Google
config:
issuer: https://accounts.google.com/o/oauth2/v2/auth
clientID: YOUR_CLIENT_ID
clientSecret: YOUR_CLIENT_SECRET
redirectURI: https://NKP_CLUSTER_DOMAIN/dex/callback
scopes:
- openid
- profile
- email
insecureSkipEmailVerified: true
insecureEnableGroups: true
userIDKey: email
userNameKey: email
[...]
```

### Access Token Lifetime

For more information on access token expiration and rotation settings, see
`<https://dexidp.io/docs/configuration/>` tokens/#expiration-and-rotation-
settings.

Here is an example configuration for extending the token lifetime to 48 hours
on non-Nutanix infrastructure installation:

```yaml
apiVersion: config.kommander.mesosphere.io/v1alpha1
kind: Installation
apps:
dex:
values: |
config:
expiry:
idTokens: "48h"
[...]
```

- Name; Supports Refresh Tokens; Supports Groups Claim; Supports; Status
  name; Notes

| --- | --- | --- | --- | --- | --- |

- **Name**; **Supports** **Refresh** **Tokens**; **Supports** **Groups
  Claim**; `preferred_user`; `name`; `name`
- **Name**; **Supports** **Refresh** **Tokens**; **Supports** **Groups
  Claim**; Claim; Claim; Claim

For Nutanix installations, you must create the following custom configuration
after the initial installation.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: dex-overrides
namespace: kommander
data:
values.yaml: |
---
config:
expiry:
idTokens: <TIME>
```

Patch the `dex` AppDeployment int the `kommander` namespace

```bash
spec:
configOverrides:
name: dex-overrides
```

### Authentication

Users access Kommander in two ways:

- To interact with Kubernetes API, usually through kubectl.
- To interact with the NKP UI, which has GUI dashboards for Prometheus,
  Grafana, etc.

If the user authenticates successfully, Dex pulls the user's information from
the IdP and forms an OpenID token. The token contains this information and
returns it to the respective client's callback URL. The client or end user
uses this token for communicating with the NKP UI or Kubernetes API
respectively.

This figure illustrates these components and their interaction at a high level:

Figure 18: OIDC Authentication Flow with Dex

### Connecting Kommander to an IdP Using SAML

About this task

Use this procedure to connect Kommander to an external Identity Provider (IdP)
using SAML. Kommander uses Dex as its OpenID Connect (OIDC) provider to
federate authentication across your clusters. Integrating an IdP via SAML
allows your organization's users to log in to the NKP UI using their existing
enterprise credentials.

Procedure

1. Install NKP.
2. Configure the IdP. Provide the issuer URL and the Assertion Consumer
   Service (ACS) or callback URL to your IdP. The issuer URL points to the
   authentication endpoint at the service provider (Dex), which issues a
   request towards the IdP via the user agent.

The issuer URL follows this schema:

```bash
https://<your-cluster-host>/dex
```

The ACS URL points to the service provider (Dex) endpoint that receives SAML
assertions issued by the IdP.

The ACS or callback URL should look like this:

```bash
https://<your-cluster-host>/dex/callback
```

Depending on the IdP, you might be asked to provide the configuration in some
form of an XML snippet. See the following example, making sure to replace
`<your-cluster-host>` with your URL:

```bash
<?xml version="1.0" encoding="UTF-8"?>
<EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata" entityID="https://
<your-cluster-host>/dex">
<SPSSODescriptor AuthnRequestsSigned="false" WantAssertionsSigned="true"
protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
<NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:persistent</
NameIDFormat>
<AssertionConsumerService index="0" isDefault="true"
Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://<your-
cluster-host>/dex/callback" />
</SPSSODescriptor>
</EntityDescriptor>
```

1. Modify the dex configuration. For this step, get the following from your IdP:

- single sign-on URL or SAML URL: ssoURL
- base64 encoded, PEM encoded CA certificate: caData
- username attribute name in SAML response: usernameAttr
- email attribute name in SAML response: emailAttr

From above, you need the following:

- issuer URL: entityIssuer
- callback URL: redirectURI

Ensure you base64 encode the contents of the PEM file. For example, the
contents' prefix will result in this exact base64 prefix.

```bash
LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tC[...]
```

You can add the configuration as values field in the dex application. 4.
Modify the traefik-forward-auth-mgmt
configuration and add a whitelist. This step is required to give a user access
to the NKP UI. For each user, you must
give access to Kubernetes resources (see Access Control on page 285) and add
an entry in the whitelist below. The
following YAML represents the Kommander Installation custom resource. Update
the traefik- forward-auth-mgmt app values
within it to add the allowed user email addresses to the whitelist.

```yaml
apiVersion: config.kommander.mesosphere.io/v1alpha1
kind: Installation
apps:
---
traefik-forward-auth-mgmt:
values: |
traefikForwardAuth:
allowedUser:
valueFrom:
secretKeyRef: null
whitelist:
  - < allowed email addresses >
```

1. Run kommander install --installer-config kommander.yaml to deploy modified
   dex.
2. Visit `<https://`>`<your-cluster-host>`/nkp/kommander/dashboard to login to the
   NKP UI.
3. Select Launch Console and follow the authentication steps to complete the
   procedure.

### Enforcing Policies Using Gatekeeper

About this task

For more information on the OPA Constraint Framework, see
`<https://github.com/open-policy-agent/frameworks/>` tree/master/constraint. The
Gatekeeper repository includes a library of policies to replace Pod Security
Policies, which you will use. For more information, see
`<https://github.com/open-policy-agent/gatekeeper-library/tree/>`
master/library/pod-security-policy.

Learn how to enforce policies using Gatekeeper. Gatekeeper Gatekeeper is the
policy controller for Kubernetes, allowing
organizations to enforce configurable policies using the Open Policy Agent
(See `<https://github.com/open->` policy-
agent/opa), a policy engine for Cloud Native environments hosted by CNCF as a
graduate-level project. This tutorial
describes how to use Gatekeeper to enforce policies by rejecting non-compliant
resources. Specifically, this tutorial
describes two constraints as a way to use Gatekeeper as an alternative to Pod
Security Policies (see https://
kubernetes.io/docs/concepts/policy/pod-security-policy/).

Before you begin

- You must have access to a Linux, macOS, or Windows computer with a supported
  operating system version.
- You must have a properly deployed and running cluster. For information about
  deploying Kubernetes with default settings on different types of
  infrastructures, see the Custom Installation and Infrastructure Tools on
  page 696.
- If you install Kommander with a custom configuration, make sure you enable
  Gatekeeper.

```yaml
Warning: If you intend to disable Gatekeeper, keep in mind that the app is deployed pre-configured with constraint
templates that enforce multi-tenancy in projects.
```

Procedure

#### Preventing the Running of Privileged Pods

1. Preventing the Mounting of Host Path Volumes on page 625

Procedure

1. Define the ConstraintTemplate.

Create the privileged pod policy constraint template k8spspprivilegedcontainer
by running the following command.

```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper-
library/master/library/pod-security-policy/privileged-containers/template.yaml
```

1. Define the Constraint. Constraints are then used to inform The gatekeeper
   that the admin wants to enforce a constraint template he privileged pod
   policy constraint psp- privileged-container by running the following
   command.

```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper-
library/master/library/pod-security-policy/privileged-containers/samples/psp-
privileged-container/constraint.yaml
```

1. Test that the constraint is enforced. Create a privileged pod by running
   the following command:

```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper-
library/master/library/pod-security-policy/privileged-containers/samples/psp-
privileged-container/example_disallowed.yaml
```

You should see the following output:

```bash
Error from server ([denied by psp-privileged-container] Privileged container is
not allowed: nginx, securityContext: {"privileged": true}): error when creating
"https://raw.githubusercontent.com/open-policy-agent/gatekeeper-library/master/
library/pod-security-policy/privileged-containers/samples/psp-privileged-container/
example_disallowed.yaml": admission webhook "validation.gatekeeper.sh" denied the
request: [denied by psp-privileged-container] Privileged container is not allowed:
nginx, securityContext: {"privileged": true}
```

#### Preventing the Mounting of Host Path Volumes

Procedure

1. Define the ConstraintTemplate. Create the host path volume policy
   constraint template k8spsphostfilesystem by running the following command.

```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper-
library/master/library/pod-security-policy/host-filesystem/template.yaml
```

1. Define the Constraint. Constraints are then used to inform Gatekeeper that
   the admin wants to enforce a ConstraintTemplate, and how. Create the host
   path volume policy constraint psp-host-filesystem by running the following
   command to only allow /foo to be mounted as a host path volume.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sPSPHostFilesystem
metadata:
name: psp-host-filesystem
spec:
match:
kinds:
- apiGroups: [""]
kinds: ["Pod"]
parameters:
allowedHostPaths:
- readOnly: true
pathPrefix: "/foo"
EOF
```

1. Test that the constraint is enforced. Create a privileged pod by running
   the following command:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
name: nginx-host-filesystem
labels:
app: nginx-host-filesystem
spec:
containers:
- name: nginx
image: nginx
volumeMounts:
- mountPath: /cache
name: cache-volume
readOnly: true
volumes:
- name: cache-volume
hostPath:
path: /tmp # directory location on host
EOF
```

You should see the following output:

```bash
Error from server ([denied by psp-host-filesystem] HostPath volume {"hostPath":
{"path": "/tmp", "type": ""}, "name": "cache-volume"} is not allowed, pod: nginx-
host-filesystem. Allowed path: [{"readOnly": true, "pathPrefix": "/foo"}]): error
when creating "STDIN": admission webhook "validation.gatekeeper.sh" denied the
request: [denied by psp-host-filesystem] HostPath volume {"hostPath": {"path":
"/tmp", "type": ""}, "name": "cache-volume"} is not allowed, pod: nginx-host-
filesystem. Allowed path: [{"readOnly": true, "pathPrefix": "/foo"}]
```

1. Test that the constraint to check the allowed host paths. Create a pod that
   mounts an allowed host path by running the following command:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
name: nginx-host-filesystem
labels:
app: nginx-host-filesystem
spec:
containers:
- name: nginx
image: nginx
volumeMounts:
- mountPath: /cache
name: cache-volume
readOnly: true
volumes:
- name: cache-volume
hostPath:
path: /foo # directory location on host
EOF
```

You should see the following output:

```bash
pod/nginx-host-filesystem created
```

### Traefik-Forward-Authentication in NKP (TFA)

TFA is one of the standard applications in the Kommander component of NKP. It
is deployed by a controller on all attached, managed, and management clusters.

TFA Authentication Workflow

Figure 19: TFA Authentication Workflow

Default TFA Configuration in NKP

In the default configuration in NKP, TFA stores all authentication information
about users through the browser cookies. When TFA authenticates users, it
stores the user's metadata in encrypted browser cookies. Subsequent requests
following initial authentication will use these cookies to recognize users
without the need to re-authenticate them.

- The cookies are securely encrypted, so they cannot be modified by users.
- The cookies contain the RBAC username.
- The cookies contain a list of groups that users are associated with.

Cluster Storage Option

The browser cookie storage is limited to a maximum of 4Kb per cookie. However,
if a user is assigned to a large number of groups, this limitation can be
exceeded and this will return a response 500-internal server error, meaning
that the user will be unable to access any web services.

To work around the cookie storage size limit, TFA can be configured to store
the metadata claims in the cluster as a Kubernetes secret instead of in the
browser. To do so, the clusterStorage option can be configured in the Traefik
Forward Auth application when installing Kommander.

In order to enable the clusterStorage option, add the following to the
cluster.yaml when installing Kommander:

```bash
traefik-forward-auth-mgmt:
values: |
clusterStorage:
enabled: true
namespace: kommander
```

If the clusterStorage feature is enabled, automatic garbage collection will
delete the secrets after 12 hours. Keep in mind that enabling this feature
will have performance implications for web requests, because TFA needs to load
the secret to retrieve the user groups for each HTTP API request. Because of
this, we recommend first trying to reduce the number of groups associated
users and only enabling this option if that cannot be accomplished.

For more information on traefik-forward-authentication, see
`<https://github.com/mesosphere/traefik-forward-auth>`.

### Local Users

For an overview of the benefits, supported providers, and instructions on how
to configure an external identity provider, see Identity Providers.

About this task

Customize the Dex AppDeployment, and add a configOverrides section.

Procedure

1. Open the Kommander Installer Configuration File or kommander.yaml file. If
   you do not have the

kommander.yaml file, initialize the configuration file so you can edit it in
the subsequent steps.

> **Note: Initialize this file only one time, otherwise you will- overwrite
> previous customizations.** 2. In that file, add the following
> customization for dex and create local users by establishing their
> credentials.

- Replace `<example_email>` with the user's email address or username.
- Replace `<password_bcrypt_hash>` with the bcrypt hash of the password you
  want to assign.

You can use the htpasswd CLI to create the hash of a specific password. For
example, by running htpasswd -bnBC 10 "" password | tr -d ':\n' && echo, you
can generate the hash for the password "password".

```bash
app:
dex:
enabled: true
values: |
config:
staticPasswords:
- email: <example_email>
hash: <password_bcrypt_hash>
- email: <example_email2>
hash: <password_bcrypt_hash2>
```

1. Save the kommander.yaml file.
2. Install Kommander using the customized installation file.

For more information, see Installing Kommander with a Configuration File on
page 997.

After Kommander finishes installing, you have created local users, but you
cannot use them until you have assigned them permissions. To complete the
configuration, see Adding RBAC Roles to Local Users on page 631.

> **Warning: You have created a user that does not have any permissions to
> see or manage your NKP cluster yet.**

You have created a user that does not have any permissions to see or manage
your NKP cluster yet.

#### Creating Local Users After the Kommander Installation

About this task

```yaml
Warning: Nutanix does not recommend creating local users for production clusters. See for instructions on how to
configure an external identity provider to manage your users.
```

Customize the Dex AppDeployment, and add a configOverrides section:

Procedure

1. Fetch the name of the kommandercluster.

```bash
nkp get kommandercluster -n kommander -l 'kommander.d2iq.io/host=true' -o
jsonpath='{.items[0].metadata.name}'
```

1. Create a configMap resource with the credentials of the new local user

- Replace `<example_email>` with the user's email address or username.
- Replace `<password_bcrypt_hash>` with the bcrypt hash of the password you
  want to assign.

You can use the htpasswd CLI, which is provided by the httpd-tools package, to
create the hash of a specific password. Install httpd-tools on the system
where you generate the hash, and then run a command

such as htpasswd -bnBC 10 "" password | tr -d ':\n' && echo to generate the
hash for the password "password".

```yaml
Note: Enclose the bcrypt hash in single quotes and use a quoted heredoc delimiter ('EOF'). A bcrypt hash
contains $ characters (for example, $2y$10$...) that the shell expands in an unquoted heredoc, which corrupts
the hash and causes the dex pod to fail with a malformed bcrypt hash error.
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
name: dex-overrides
namespace: kommander
data:
values.yaml: |
config:
staticPasswords:
- email: <example_email>
hash: '<password_bcrypt_hash>'
EOF
```

1. Open the Dex AppDeployment to edit it.

```bash
kubectl edit -n kommander appdeployment dex
```

The editor displays the AppDeployment. 4. Copy the following values and paste
them in a location in the file where they are nested in the spec field.

```bash
configOverrides:
name: dex-overrides
```

Example:

```yaml
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
...
spec:
appRef:
kind: ClusterApp
name: dex-2.11.1
clusterConfigOverrides:
- clusterSelector:
matchExpressions:
- key: kommander.d2iq.io/cluster-name
operator: In
values:
- management
configMapName: dex-kommander-overrides
configOverrides: # Copy and paste this section.
name: dex-overrides
status:
...
```

Editing the AppDeployment restarts the HelmRelease for Dex. The new users will
be created after the reconciliation. However, the user creation is not
completed until you assign it permissions.

> **Note: You have created a user that does not have any permissions to see
> or manage your NKP cluster yet.**

To complete the configuration, see Adding RBAC Roles to Local Users on page 631.

#### Adding RBAC Roles to Local Users

About this task

If you have not created local users yet, see

Creating Local Users During the Kommander Installation on page 628 or Creating
Local Users After the Kommander Installation on page 629.

To assign a Role:

Procedure

Create the following ClusterRoleBinding resource:.

- Replace `<example_email>` with the user's email address or username.
- Replace `<cluster_admin>` with the RBAC role you want to assign to a user.
- If you have configured an Identity Provider for a specific workspace (see
  Multi-Tenancy in NKP on page 412), configure the subjects.name field to
  `<workspace_ID>`:`<user_email>`. For example, tenant-z:jane.doe@example.com.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
name: cluster-admin
roleRef:
apiGroup: rbac.authorization.k8s.io
kind: ClusterRole
name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
kind: User
name: <example_email>
EOF
```

After assigning the previous role to `<example_email>`, the user is able to
log in to the cluster using the credentials you assigned in Creating Local
Users During the Kommander Installation on page 628 or Creating Local Users
After the Kommander Installation on page 629.

```yaml
Note: The Login page and cluster URL are the same for the default admin user and the local users you create with this
method.
```

For more information on RBAC resources in NKP and granting access to
Kubernetes and Kommander resources, see Access to Kubernetes and Kommander
Resources on page 288.

For general information on RBAC as a Kubernetes resource, see
`<https://kubernetes.io/docs/reference/access->` authn-authz/rbac/.

#### Modifying Local Users

Procedure

1. To change the password or username of a user, edit the dex-overrides
   ConfigMap.
2. If you change the email address or username of a user, ensure you update
   any RoleBindings or RBAC resources associated with this user.

#### Deleting Local Users

Procedure

To delete local users, edit the dex-overrides ConfigMap and remove the email
and hash fields for the user. Also, ensure you delete any RoleBindings or RBAC
resources associated with this user.

## Networking

Kubernetes gives pods their own IP addresses and a single DNS name for a set
of pods. Services are used as entry points to load-balance the traffic across
the pods. A selector determines the set of Pods targeted by a Service.

For example, if you have a set of pods that each listen on TCP port 9191 and
carry a label app=MyKonvoyApp, as configured in the following:

```yaml
apiVersion: v1
kind: Service
metadata:
name: my-konvoy-service
namespace: default
spec:
selector:
app: MyKonvoyApp
ports:
  - protocol: TCP
port: 80
targetPort: 9191
```

This specification creates a new Service object named "my-konvoy-service",
that targets TCP port 9191 on any pod with the app=MyKonvoyApp label.

Kubernetes assigns this Service an IP address. In particular, the kube-proxy
implements a form of virtual IP for Services of type other than ExternalName.

> **Note:**

- The name of a Service object must be a valid DNS label name.
- A Service is not a Platform Service.

### Service Topology

To enable this new feature in your Kubernetes cluster, use the feature gates
--feature- gates="ServiceTopology=true,EndpointSlice=true" flag. After
enabling, you can control Service traffic routing by defining the topologyKeys
field in the Service API object.

In the following example, a Service defines topologyKeys to be routed to
endpoints only in the same zone:

```yaml
apiVersion: v1
kind: Service
metadata:
name: my-konvoy-service
namespace: default
spec:
selector:
app: MyKonvoyApp
ports:
  - protocol: TCP
port: 80
targetPort: 9191
topologyKeys:
  - "topology.kubernetes.io/zone"
```

> **Note: If the value of the topologyKeys field does not match any pattern,
> the traffic is rejected.**

#### EndpointSlices

Like Services, the name of a EndpointSlice object must be a valid DNS
subdomain name.

In this example, here's a sample EndpointSlice resource for the example
Kubernetes Service:

```yaml
apiVersion: discovery.k8s.io/v1beta1
kind: EndpointSlice
metadata:
name: konvoy-endpoint-slice
namespace: default
labels:
kubernetes.io/service-name: my-konvoy-service
addressType: IPv4
ports:
  - name: http
protocol: TCP
port: 80
endpoints:
  - addresses:
  - "192.168.126.168"
conditions:
ready: true
hostname: ip-10-0-135-39.us-west-2.compute.internal
topology:
kubernetes.io/hostname: ip-10-0-135-39.us-west-2.compute.internal
topology.kubernetes.io/zone: us-west2-b
```

#### DNS for Services and Pods

Every new Service object in Kubernetes gets assigned a DNS name. The
Kubernetes DNS component schedules a DNS name for the pods and services
created on the cluster, and then the Kubelets are configured so containers can
resolve these DNS names.

Considering previous examples, assume there is a Service named my-konvoy-
service in the Kubernetes namespace default. A Pod is running in namespace
default can look up this service by performing a DNS query for my-konvoy-
service. A Pod running in namespace kommander can look up this service by
performing a DNS query for my-konvoy-service.default.

In general, a pod has the following DNS resolution:

```bash
pod-ip-address.namespace-name.pod-name.cluster-domain.example.
```

Similarly, a service has the following DNS resolution:

```bash
service-name.namespace-name.svc.cluster-domain.example.
```

#### Ingress and Networking

For information on Ingress, see `<<https://kubernetes.io/docs/concepts/services->`
networking/ingress/#what-is-> ingress.

The traffic policies are controlled by rules as part of the Ingress
definition. Each rule defines the following details:

- An optional host to which to apply the rules.
- A list of paths or routes that has an associated backend defined with a
  Service name, a port name and number.
- A backend is a combo of a Service and port names, or a custom resource
  backend defined as a CRD. Consequently HTTP/HTTPS requests to the Ingress
  that match the host and path of the rule are sent to the listed backend.

In Kommander, you can expose services to the outside world using Ingress
objects.

Ingress Controllers

In contrast with the controllers in the Kubernetes control plane, Ingress
controllers are not started with a cluster so you need to choose the desired
Ingress controller.

An Ingress controller has to be deployed in a cluster for the Ingress
definitions to work.

Kubernetes, as a project, currently supports and maintains GCE controllers.

These are three of the most known Ingress controllers:

- HAProxy Ingress is a highly customizable community-driven ingress controller
  for HAProxy. See https:// haproxy-ingress.github.io/
- Traefik is a fully featured Ingress controller (Let's Encrypt, secrets,
  http2, websocket), and has commercial support. See
  `<https://github.com/containous/traefik>`.
- Ambassador API Gateway EXPERIMENTAL is an Envoy based Ingress controller
  with the community and commercial support. See
  `<https://www.getambassador.io/>`.

In Kommander, Traefik deploys by default as a well-suited Ingress controller.

#### Network Policies (2)

NetworkPolicy is an API resource that controls the traffic flow at port level
3 or 4 or at the IP address level. It enables defining constraints on how a
pod communicates with various network services such as endpoints and services.

A Pod can be restricted to talk to other network services through a selection
of the following identifiers:

- Namespaces that have to be accessed. There can be pods that are not allowed
  to talk to other namespaces.
- Other allowed IP blocks regardless of the node or IP address assigned to the
  targeted Pod.
- Other allowed Pods.

An example of a NetworkPolicy specification is:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
name: network-konvoy-policy
namespace: default
spec:
podSelector:
matchLabels:
role: db
policyTypes:
- Ingress
- Egress
ingress:
- from:
- ipBlock:
cidr: 172.17.0.0/16
except:
- 172.17.1.0/24
- namespaceSelector:
matchLabels:
app: MyKonvoyApp
- podSelector:
matchLabels:
app: MyKonvoyApp
ports:
- protocol: TCP
port: 6379
egress:
- to:
- ipBlock:
cidr: 10.0.0.0/24
ports:
- protocol: TCP
port: 5978
```

As shown in the example, when defining a pod or namespace based NetworkPolicy,
you use a selector to specify what traffic is allowed to and from the Pod(s).

Adding Entries to Pod /etc/hosts with HostAliases

The Pod API resource definition has a HostAliases field that allows adding
entries to the Pod's container /etc/ hosts file. This field overrides the
hostname resolution when DNS and other options are not applicable.

For example, to resolve foo.node.local, bar.node.local to 127.0.0.1 and
foo.node.remote, bar.node.remote to 10.1.2.3, configure the HostAliases values
as follows:

```yaml
apiVersion: v1
kind: Pod
metadata:
name: hostaliases-konvoy-pod
spec:
restartPolicy: Never
hostAliases:
- ip: "127.0.0.1"
hostnames:
- "foo.node.local"
- "bar.node.local"
- ip: "10.1.2.3"
hostnames:
- "foo.node.remote"
- "bar.node.remote"
containers:
- name: cat-hosts
image: busybox
command:
- cat
args:
- "/etc/hosts"
```

### Required Domains

You must have access to the following domains through the customer networking
rules so that Kommander can download all required images.

> **Note: Enable all the listed domains, including redirections and
> subdomains.**

- docker.io
- gcr.io
- k8s.gcr.io
- mcr.microsoft.com
- quay.io
- us.gcr.io
- registry.k8s.io
- nvcr.io
- pkg-containers.githubusercontent.com
- charts.bitnami.com
- charts.jetstack.io
- charts.rook.io
- cloudnative-pg.io
- grafana.github.io
- helm.goharbor.io
- helm.ngc.nvidia.com
- helm.traefik.io
- jaegertracing.github.io
- kiali.io
- kubecost.github.io
- kubernetes.github.io
- mesosphere.github.io
- open-policy-agent.github.io
- prometheus-community.github.io
- fluent.github.io
- kube-logging.github.io
- raw.githubusercontent.com
- insights.nutanix.com

> **Note:**

- In an air-gapped installation, the required domains need not be accessible.
- For the NKP Pulse to send its data to Nutanix, you must have access to the
  following domain through the cluster networking rules: insights.nutanix.com.

### Load Balancing

NKP now supports Cilium as the default CNI. Cilium replaces kube-proxy and
handles Kubernetes Service load balancing. For more information, see
Kubernetes Service.

> **Note: For environments that use Calico instead of Cilium, kube-proxy is
> fully supported and available.**

External traffic destined for the Kubernetes service requires a service of
type LoadBalancer, through which external clients connect to your internal
service. Under the hood, it uses a load balancer provided by the underlying
infrastructure to direct the traffic.

> **Note: In NKP environments, the external load balancer must be configured
> without TLS termination.**

In cloud deployments, the load balancer is provided by the cloud provider. For
example, in AWS, the service controller communicates with the AWS API to
provision an ELB service that targets the cluster nodes.

For an on-premises Pre-provisioned deployment, NKP ships with MetalLB (see
`<https://metallb.universe.tf/>` concepts/), which provides load-balancing
services. The environments that use MetalLB are pre-provisioned, as well as
vSphere infrastructures. For more information on how to configure MetalLB for
these environments, see the following:

- Pre-provisioned: Configuring MetalLB on page 79
- Configure MetalLB for a vSphere infrastructure

Custom Load Balancer for External Traffic

If you want to use a non-NKP load balancer for external traffic, see External
Load Balancer on page 1016.

### Ingress

Traefik Ingress Controller.

Kubernetes Ingress resources expose HTTP and HTTPS routes from outside the
cluster to services within the cluster. In Kommander, the Traefik Ingress
controller is installed by default and provides access to the NKP UI.

An Ingress performs the following:

- Gives Services externally-reachable URLs
- Load balances traffic
- Terminates SSL/TLS sessions
- Offers name-based virtual hosting

An Ingress controller fulfills the Ingress with a load balancer.

A cluster can have multiple Ingress controllers.

Traefik

Traefik is a modern HTTP reverse proxy and load balancer that deploys
microservices with ease. Kommander currently installs Traefik by default on
every cluster. Traefik creates a service of type LoadBalancer. In the cloud,
the cloud provider creates the appropriate load balancer. In an on-premises
deployment, by default, it uses MetalLB.

Traefik listens to the Kubernetes API and automatically generates and updates
the routes without any further configuration or intervention so that the
Services selected by the Ingress resources are connected to the outside world.
Further, Traefik supports a rich set of functionality such as Name-based
routing, Path-based routing, Traffic splitting, etc.

Major features highlighted in the Traefik documentation:

- Continuously updates its configuration (No restarts!)
- Supports multiple load balancing algorithms
- Provides HTTPS to your microservices
- Circuit breakers, retry
- A clean web UI
- Websocket, HTTP/2, GRPC ready
- Provides metrics (Rest, Prometheus, Datadog, StatsD, InfluxDB)
- Keeps access logs (JSON, CLF)
- Exposes a Rest API
- Packaged as a single binary file (made with go) and available as a docker
  image

Related Information: For information on related topics or procedures, see the
following:

- List of Ingress controllers: `<<https://kubernetes.io/docs/concepts/services->`
  networking/ingress-controllers/>
- Traefik Migration Guide: `<https://doc.traefik.io/traefik/migration/v2-to-v3/>`

### Configuring Ingress for Load Balancing

- Load Balancing on page 637

About this task

Ingress is the name used to describe an API object that manages external
access to the services in a cluster. Typically, an Ingress exposes HTTP and
HTTPS routes from outside the cluster to services running within the cluster.

The object is called an Ingress because it acts as a gateway for inbound
traffic. The Ingress receives inbound requests and routes them according to
the rules you defined for the Ingress resource as part of your cluster
configuration.

Expose an application running on your cluster by configuring an Ingress for
load balancing (layer-7).

Before you begin

You must:

- Have access to a Linux, macOS, or Windows computer with a supported
  operating system version.
- Have a properly deployed and running cluster.

To expose a pod using an Ingress (L7)

Procedure

1. Deploy two web application Pods on your Kubernetes cluster by running the
   following command.

```bash
kubectl run --restart=Never --image hashicorp/http-echo --labels app=http-echo-1 --
port 80 http-echo-1 -- -listen=:80 --text="Hello from http-echo-1"
kubectl run --restart=Never --image hashicorp/http-echo --labels app=http-echo-2 --
port 80 http-echo-2 -- -listen=:80 --text="Hello from http-echo-2"
```

1. Expose the Pods with a service type of ClusterIP by running the following
   commands.

```bash
kubectl expose pod http-echo-1 --port 80 --target-port 80 --name "http-echo-1"
kubectl expose pod http-echo-2 --port 80 --target-port 80 --name "http-echo-2"
```

1. Create the Ingress to expose the application to the outside world by
   running the following command.

```bash
cat <<EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
annotations:
kubernetes.io/ingress.class: kommander-traefik
traefik.ingress.kubernetes.io/router.tls: "true"
generation: 7
name: echo
namespace: default
spec:
rules:
- http:
paths:
- backend:
service:
name: http-echo-1
port:
number: 80
path: /echo1
pathType: Prefix
- http:
paths:
- backend:
service:
name: http-echo-2
port:
number: 80
path: /echo2
pathType: Prefix
EOF
```

The configuration settings in this example illustrate:

- setting the kind to Ingress.
- setting the service.name to be exposed as each backend.

1. Run the following command to get the URL of the load balancer created on
   AWS for the Traefik service.

```bash
kubectl get svc kommander-traefik -n kommander
```

This command displays the internal and external IP addresses for the exposed
service. (Note that IP addresses and host names are for illustrative purposes.
Always use the information from your own cluster)

```bash
NAME TYPE CLUSTER-IP EXTERNAL-IP
PORT(S) AGE
kommander-traefik LoadBalancer 10.0.24.215
abf2e5bda6ca811e982140acb7ee21b7-37522315.us-west-2.elb.amazonaws.com 80:31169/
TCP,443:32297/TCP,8080:31923/TCP 4h22m
```

1. Validate that you can access the web application Pods by running the
   following commands: (Note that IP addresses and host names are for
   illustrative purposes. Always use the information from your own cluster)

```bash
curl -k https://abf2e5bda6ca811e982140acb7ee21b7-37522315.us-
west-2.elb.amazonaws.com/echo1
curl -k https://abf2e5bda6ca811e982140acb7ee21b7-37522315.us-
west-2.elb.amazonaws.com/echo2
```

### Istio as a Microservice

By default, Istio-helm application deploys in sidecar mode, where each
application pod in the mesh has a sidecar container attached to it. You need
to enable Istio-Helm in ambient mode, where Istio implements its features
using a per-node layer-4 (L4) proxy, and optionally a per-namespace layer-7
(L7) proxy.

For more information on Istio, see Istio Documentation.

```yaml
Note: Operator-based Istio is deprecated from NKP 2.17. To migrate to Istio-helm, seeMigrating Istio Operator
to Istio-Helm Using Nutanix Kubernetes® Platform on page 643. For more information, see the
Deprecation Notice.
```

#### Istio Prerequisites

Before deploying Istio, ensure that your environment meets the following
requirements:

System Requirements

- Access to a Linux, macOS, or Windows computer with a supported operating
  system version.
- A deployed and running NKP cluster.

Workspace Configuration

1. Identify the workspace name for your deployment:

```bash
nkp get workspaces
```

This command displays the workspace names and their corresponding namespaces. 2. Set the WORKSPACE_NAME environment variable to the workspace where your
cluster is attached:

```bash
export WORKSPACE_NAME=<workspace_name>
```

#### Deploying Istio Using Nutanix Kubernetes® Platform

About this task

To deploy Istio on your cluster, follow these steps:

Procedure

1. Obtain the current APP ID and version for Istio and its dependencies.
   Review the list of available applications and record its information for use
   in the following commands. For more information, see Platform Applications
   Dependencies For All Clusters on page 354.
2. Install Istio dependencies by creating an AppDeployment resource:

```bash
nkp create appdeployment <APPID> --app <APPID-version> --workspace ${WORKSPACE_NAME}
```

Replace `<APPID>` and `<APPID-version>` with the application information. The
--app flag requires the APP ID and version in APPID-version format. 3. Install
Istio:

```bash
nkp create appdeployment istio-helm --app <APPID-version> --workspace
${WORKSPACE_NAME}
```

Replace `<APPID-version>` with the version of Istio you want to deploy. For
the supported istio version, see Supported Applications section in the NKP
Release Notes.

> **Note:**

- Create the resource in the workspace you created, which instructs Kommander
  to deploy the AppDeployment to the KommanderCluster instances in the same
  workspace.
- Run the nkp create command with the WORKSPACE_NAME instead of the
  WORKSPACE_NAMESPACE flag.

#### Enabling Istio Helm in Ambient Mode

About this task

Ambient mode provides a sidecar-free service mesh architecture that reduces
resource overhead and simplifies operations. This procedure works for both new
Istio deployments and existing deployments.

> **Important: For advanced configurations, see Installation guide for Istio
> in Ambient Mode.**

To configure Istio Helm in ambient mode using the NKP UI, follow these steps:

Procedure

1. Log in to the NKP UI dashboard.
2. In the top-left corner, click the Global dropdown list and select your
   target workspace.

For example, if your target cluster is a management cluster, select Management
Cluster Workspace. 3. From the left navigation pane, select Applications. 4.
Locate Service Mesh and click View Details. 5. On the Service Mesh page, click
Istio-Helm Service Mesh. 6. In the Service Mesh section, click Istio-Helm
Service Mesh. 7. In the Overview page, copy the following ConfigMap details:

```bash
ztunnel:
enabled: true
profile: ambient
cni:
profile: ambient
istiod:
profile: ambient
env:
CA_TRUSTED_NODE_ACCOUNTS: "istio-helm-gateway-ns/ztunnel,istio-helm-system/
ztunnel"
```

1. In the top-right corner of the page, click Enable:
2. In the Application Configuration Override section, paste the ConfigMap
   details.
3. Click Enable and verify that the application status shows as Enabled.

- New Istio deployments: After enabling Istio in ambient mode, label the
  namespaces for applications that you plan to include in the ambient mesh:

```bash
kubectl label namespace <namespace-name> istio.io/dataplane-mode=ambient
```

- Existing Istio deployments: Enabling Istio in ambient mode automatically
  migrates existing Istio Helm deployments from sidecar mode to ambient mode.
  Monitor the automatic migration as follows:

```bash
kubectl logs -n istio-helm-gateway-ns -l job-name=istio-helm-ztunnel-ambient-
migration
```

The migration job performs the following actions:

- Discovers namespaces with sidecar injection enabled
- Filters out already migrated namespaces
- Adds the istio.io/dataplane-mode=ambient label
- Removes sidecar injection labels
- Restarts deployments to remove sidecars

1. (Optional) To disable ambient mode and return to sidecar mode, revert the
   ConfigMap overrides:

```bash
ztunnel:
enabled: true
profile: ambient
cni:
profile: ambient
istiod:
profile: ambient
env:
CA_TRUSTED_NODE_ACCOUNTS: "istio-helm-gateway-ns/ztunnel,istio-helm-system/
ztunnel"
```

This configuration returns Istio Helm to sidecar mode. Applications in the
mesh retain their ambient labels. To deploy applications in sidecar mode,
remove the ambient label and follow the steps in Deploying a Sample
Application on Istio on page 646.

#### Migrating Istio Operator to Istio-Helm Using Nutanix Kubernetes® Platform

About this task

To migrate existing workloads and mesh configurations from operator-based
Istio to Helm-based Istio application on NKP, follow these steps:

Procedure

1. Extract your Istio operator configuration to YAML format:

```bash
kubectl get IstioOperator <name> -o yaml > istio.yaml
```

Example of the istio.yaml spec field when installation uses default
configurations:

```bash
spec:
components:
cni:
enabled: true
k8s:
priorityClassName: dkp-critical-priority
namespace: kube-system
ingressGateways:
k8s:
hpaSpec:
minReplicas: 2
pilot:
k8s:
hpaSpec:
minReplicas: 2
priorityClassName: dkp-critical-priority
hub: docker.io/istio
profile: default
tag: 1.23.6
```

Individual components such as CNI, IngressGateways, and pilot have their
default and global values. Overridden configurations appear in the
spec:components field. 2. Deploy Istio Helm and extract the default Helm
values:

```bash
kubectl get -n ${WORKSPACE_NAMESPACE} configmaps istio-helm-1.23.6-config-defaults -
o=jsonpath='{.data.values\.yaml}' > istio-helm-values.yaml
```

1. Edit the resulting istio-helm-values.yaml file. Example of overridden
   configurations to increase replica count for the existing ingress gateway:

```bash
gateway:
revision: "istio-helm"
- name: istio-helm-ingressgateway
autoscaling:
enabled: true
minReplicas: 3
maxReplicas: 3
labels:
istio: istio-helm-ingressgateway
service:
ports:
```

1. Create a ConfigMap manifest with the override values from the istio-helm-
   values.yaml file:

```bash
cat <<EOF >istio-helm-config-overrides.yaml
apiVersion: v1
kind: ConfigMap
metadata:
namespace: ${WORKSPACE_NAMESPACE}
name: istio-helm-config-overrides
data:
values.yaml: |
$(cat istio-helm-values.yaml | sed 's/^/ /g')
EOF
```

1. Create the ConfigMap from the manifest:

```bash
kubectl apply -f istio-helm-config-overrides.yaml
```

1. Edit the istio-helm AppDeployment resource. Set the
   spec.configOverrides.name to the name of the created ConfigMap and deploy
   the application with custom configuration:

```bash
nkp edit appdeployment -n ${WORKSPACE_NAMESPACE} istio-helm
```

Example of the AppDeployment resource after the change:

```yaml
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: istio-helm
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: istio-helm-1.23.6
kind: ClusterApp
configOverrides:
name: istio-helm-config-overrides
```

1. Relabel the namespaces and reinject the workloads:

```bash
kubectl label namespace <ns> istio.io/rev=istio-helm -overwrite
kubectl rollout restart deployment -n <ns>
```

Label each target namespace with the appropriate Istio revision to associate
workloads with the correct Istio control
plane. This step is essential because Istio uses namespace labels to determine
which revision of the sidecar injector to
apply. Without relabeling, existing workloads continue to use the old or
default revision. If you updated the revision
using config overrides, use the config override revision instead of the
default istio- helm. 8. Deploy the new ingress
gateways and reapply the gateway manifests:

```bash
kubectl get gateway,virtualservice,destinationrule,serviceentry -A -o yaml > istio-
networking-configs.yaml
sed 's/istio: ingressgateway/istio: istio-helm-ingressgateway/g' \ istio-networking-
configs.yaml > istio2-networking-configs.yaml
kubectl apply -f istio2-networking-configs.yaml
```

Export existing Istio networking resources to update references to the
deployed ingress gateways. This step binds Gateway, VirtualService,
DestinationRule, and ServiceEntry resources to ingress gateways through
labels. Without updating these references, traffic continues to route through
the old gateway instances. 9. After successful migration, disable the Istio
operator:

For detailed steps, see Uninstalling Istio Operator on page 650.

#### Downloading the Istio Command Line Utility

About this task

To download and configure Istio, follow these steps:

Procedure

1. Download the Istio command line utility to your system:

```bash
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=<your_istio_version_here> sh -
```

Replace `<your_istio_version_here>` with the Istio version you want to deploy. 2. Navigate to the Istio directory and set the PATH environment variable:

```bash
cd istio*
export PATH=$PWD/bin:$PATH
```

1. Verify the installation by checking the istioctl version:

```bash
istioctl version
```

Sample Output:

```bash
client version: <your_istio_version_here>
control plane version: <your_istio_version_here>
data plane version: <your_istio_version_here> (1 proxies)
```

#### Deploying a Sample Application on Istio

About this task

The Istio bookinfo sample application consists of four separate microservices
that demonstrate various Istio features.

Procedure

1. Deploy the sample bookinfo application on the Kubernetes cluster:

```yaml
Important: Ensure that your nkp configuration references the cluster where you deployed Istio by setting
the KUBECONFIG environment variable or using the --kubeconfig flag, in accordance with Kubernetes
conventions (see https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-
multiple-clusters/).
istioctl kube-inject \
--revision istio-helm \
-f samples/bookinfo/platform/kube/bookinfo.yaml | kubectl apply -f -
sed 's/istio: ingressgateway/istio: istio-helm-ingressgateway/g' \
samples/bookinfo/networking/bookinfo-gateway.yaml \
| kubectl apply -f -
```

1. Retrieve the URL of the load balancer created for this service:

```bash
kubectl get svc istio-helm-ingressgateway -n istio-helm-gateway-ns
```

Sample Output:

```bash
NAME TYPE CLUSTER-IP EXTERNAL-IP
PORT(S)

AGE
istio-helm-ingressgateway LoadBalancer 10.0.29.241
a682d13086ccf11e982140acb7ee21b7-2083182676.us-west-2.elb.amazonaws.com
15020:30380/TCP,80:31380/TCP,443:31390/TCP,31400:31400/TCP,15029:30756/
TCP,15030:31420/TCP,15031:31948/TCP,15032:32061/TCP,15443:31232/TCP 110s
```

1. Open a browser and navigate to the external IP address for the load
   balancer to access the application: For example, the external IP address in
   the sample output is a682d13086ccf11e982140acb7-2083182676.us-
   west-2.elb.amazonaws.com. Access the

application using the following URL:
`<http://a682d13086ccf11e982140acb7ee21b7-2083182676.us->`
west-2.elb.amazonaws.com/productpage

Explore Istio features using the BookInfo application. For more information on
different Istio features, see the Istio BookInfo Application documentation.

#### Verifying the Istio Installation

About this task

To verify your Istio installation, follow these steps:

Procedure

Validate the Istio installation and check the version using one of the
following method:

» Check the Istio version:

```bash
istioctl version --revision istio-helm
```

Sample Output:

```bash
client version: 1.28.1
control plane version: 1.23.6
data plane version: 1.23.6 (2 proxies)
```

» Check the proxy status:

```bash
istioctl proxy-status --revision istio-helm
```

Sample Output:

```bash
NAME CLUSTER ISTIOD
VERSION SUBSCRIBED TYPES
istio-helm-ingressgateway-79df9868c8-pm6bj.istio-helm-gateway-ns Kubernetes
istiod-istio-helm-545d9895f9-46hnb 1.23.6 3 (CDS,LDS,EDS)
istio-helm-ingressgateway-79df9868c8-tp6gs.istio-helm-gateway-ns Kubernetes
istiod-istio-helm-545d9895f9-4pz2w 1.23.6 3 (CDS,LDS,EDS)
```

If both commands return version information and proxy status details, Istio is
successfully installed and running on your cluster.

#### Modifying Istio Configuration in NKP

About this task

NKP uses Flux to manage platform applications through GitOps practices. This
architecture prevents manual modification of Istio downstream resources such
as directly editing deployments or pods using kubectl edit to change resource
limits or replicas. Flux automatically reverts these manual changes during its
next reconciliation loop, potentially causing unexpected downtime.

To persist configuration changes such as replicas, CPU and memory requests and
limits, or horizontal pod autoscaler (HPA) settings as Day-2 operations, you
must provide configuration overrides using a ConfigMap and attach it to the
respective AppDeployment resource.

Alternatively, you can use the NKP UI to apply these configuration overrides.
For more information, see Application Management Using the UI.

To apply custom configuration overrides for Istio Operator deployments
(supported in NKP version 2.16 and earlier), follow these steps:

Procedure

1. Create a file named istio-operator-overrides.yaml containing the
   values.yaml payload with your desired Istio Operator component
   configurations:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: istio-config-overrides
namespace: <workspace-namespace>
data:
values.yaml: |
istioOperator:
components:
ingressGateways:
- name: istio-ingressgateway
enabled: true
label:
istio: ingressgateway
k8s:
hpaSpec:
minReplicas: 3
maxReplicas: 5
replicaCount: 3
resources:
requests:
cpu: 500m
memory: 1Gi
limits:
cpu: 4000m
memory: 2Gi
- name: istio-ingressgateway-httpv1
enabled: true
label:
istio: ingressgateway-httpv1
k8s:
service:
type: LoadBalancer
hpaSpec:
minReplicas: 3
maxReplicas: 5
replicaCount: 3
resources:
requests:
cpu: 500m
memory: 1Gi
limits:
cpu: 4000m
memory: 2Gi
pilot:
k8s:
resources:
limits:
cpu: 2000m
memory: 2Gi
Tip: Replace <workspace-namespace> with your actual workspace namespace. The configuration above
indicates common customizations including replica scaling, resource limits, and HPA settings for ingress gateways
and the Istio control plane (pilot).
```

1. Apply the ConfigMap to your cluster:

```bash
kubectl apply -f istio-operator-overrides.yaml -n <workspace-namespace>
```

Kubernetes creates the ConfigMap in the specified workspace namespace, making
the configuration overrides available for the AppDeployment resource. 3. Edit
the Istio AppDeployment resource to reference the configuration override:

```bash
nkp edit appdeployment istio -n <workspace-namespace>
```

1. Set the configOverrides field to reference your ConfigMap: Add or modify
   the configOverrides section in the AppDeployment specification to point to
   your new ConfigMap:

```bash
spec:
configOverrides:
name: istio-config-overrides
```

Save and exit the editor. NKP applies the configuration changes, and Flux
reconciles the updated settings across your Istio deployment.

#### Configuration Overrides for Istio-Dependent Applications

Several applications in NKP depend on Istio and are configured by default to
work with Istio Operator installations. When you use Istio-Helm instead, you
must create ConfigMap overrides to ensure that these applications can locate
and interact with the correct Istio components and namespaces.

The following applications require configuration overrides when using Istio-
Helm:

- Knative
- Kiali

Knative Configuration Override

Knative is configured by default to work with Istio Operator installed ingress
gateway. When using Istio-Helm, create a ConfigMap override to update the
ingress gateway configuration and selector:

```bash
knativeIngressGateway:
spec:
selector:
istio: istio-helm-ingressgateway
serving:
manifest:
spec:
ingress:
istio:
enabled: true
knative-ingress-gateway:
selector:
istio: istio-helm-ingressgateway
config:
istio:
external-gateways: |
- name: knative-ingress-gateway
namespace: knative-serving
service: istio-helm-ingressgateway.istio-helm-gateway-
ns.svc.cluster.local
```

Kiali Configuration Override

Kiali is configured by default to work with Istio Operator installation in the
istio-system namespace. When using Istio-Helm, create a ConfigMap override to
point Kiali to the correct Istio namespace and components:

```bash
cr:
spec:
istio_namespace: istio-helm-system
external_services:
istio:
component_status:
components:
- app_label: "istiod"
is_core: true
is_proxy: false
namespace: istio-helm-system
- app_label: "istio-helm-ingressgateway"
is_core: true
is_proxy: true
namespace: istio-helm-gateway-ns
Note: These configuration overrides are essential when migrating from Istio Operator to Istio-Helm. For more
information, see Migrating Istio Operator to Istio-Helm Using Nutanix Kubernetes® Platform on
page 643.
```

#### Uninstalling Istio Operator

About this task

To manually uninstall Istio using Nutanix Kubernetes® Platform (NKP) UI,
follow these steps:

Procedure

1. Log in to the NKP UI dashboard.
2. Select Management Cluster Workspace from the dropdown menu.
3. From the left navigation pane, select Applications.
4. Select the triple dot horizontal icon in the application tile for Istio
   Operator and click Disable. A prompt appears to confirm your decision to
   disable the application.
5. Follow the instructions in the prompt and select Disable.
6. Refresh the page to confirm that the application has been removed from the
   cluster.

This process only removes the application from the specific cluster. To remove
this application from other clusters, navigate to the Clusters page and repeat
the process. 7. After uninstalling the AppDeployment and operator, remove the
remaining Istio Operator custom resource (CR) and existing control plane and
gateway deployments:

```bash
kubectl delete istioOperator istio-default -n kommander &
kubectl patch istioOperator -n kommander istio-default --type=merge --
patch='{"metadata":{"finalizers":null}}'
kubectl delete deployments istiod, istio-ingressgateway -n istio-system
kubectl delete svc istio-ingressgateway -n istio-system
```

#### Uninstalling Istio-Helm

About this task

To manually uninstall Istio-Helm using Nutanix Kubernetes® Platform (NKP) UI,
follow these steps:

Procedure

1. Log in to the NKP UI dashboard.
2. Select Management Cluster Workspace from the dropdown menu.
3. From the left navigation pane, select Applications.
4. Select the triple dot horizontal icon in the application tile for Istio-
   Helm and click Disable. A prompt appears to confirm your decision to disable
   the application.
5. Follow the instructions in the prompt and click Disable.
6. Refresh the page to confirm that the application has been removed from the
   cluster.

This process only removes the application from the specific cluster. To remove
this application from other clusters, navigate to the Clusters page and repeat
the process.

## GPU Management

Nutanix Kubernetes Platform (NKP) supports GPU passthrough and virtual GPU
(vGPU) through the NVIDIA operator. NKP configures the container runtime to
run GPU containers using the NVIDIA GPU operator application, which installs
the necessary components to enable NVIDIA GPU devices.

- NVIDIA GPU Passthrough: In NKP, nodes that use NVIDIA GPU passthrough are
  configured with nvidia- gpu-operator and NVIDIA drivers to support the
  container runtime. For more information, see Nutanix GPU Passthrough.
- NVIDIA GRID Virtual GPU: NVIDIA Virtual GPU (vGPU) enables multiple virtual
  machines (VMs) to access a single physical GPU concurrently and directly. By
  sharing a single GPU among multiple workloads, NVIDIA vGPU provides VMs with
  exceptional graphics and compute performance, application compatibility,
  cost-efficiency, and scalability. For more information, see NVIDIA GRID
  Virtual GPU.

If you deploy NKP on Nutanix AHV, verify GPU compatibility by checking the
list of supported GPUs. For more information about compatible GPUs, see NVIDIA
Drivers in the Compatibility and Interoperability Matrix.

If you deploy NKP on bare metal instances or on pre-provisioned
infrastructure, ensure GPU compatibility by verifying the list of GPUs that
NVIDIA GPU operators support. For more information, see Supported NVIDIA Data
Center GPUs and Systems for your specific NVIDIA GPU Operator version.

The supported NVIDIA driver version is 580.x and NKP does not support AMD GPUs.

Operating System Compatibility

GPU support varies by operating system and infrastructure platform. Verify
that your chosen operating system supports GPU functionality for your
deployment type before configuring GPU workloads.

For comprehensive information about GPU support across all supported operating
systems and infrastructure platforms, including air-gapped and FIPS
configurations, see Supported Infrastructure Operating Systems.

GPU Driver Deployment Options

NKP provides the following options for deploying NVIDIA GPU drivers on your
clusters:

- Custom OS image with GPU drivers: Create a custom operating system image
  that includes pre-installed NVIDIA GPU drivers. You can build custom images
  using the Nutanix Image Builder and include the specific

NVIDIA driver version required for your workloads. For more information, see
Nutanix Image Builder on page 51.

- Pre-compiled drivers for out-of-the-box images: Use the NVIDIA GPU operator
  with pre-compiled drivers on standard operating system images. This approach
  eliminates the need to compile drivers during deployment, reducing
  installation time compared to runtime compilation. For more information
  about configuring pre- compiled drivers, see Enable NVIDIA GPU Operator
  Using the Nutanix Kubernetes Platform UI on page 654 or Enable NVIDIA GPU
  Operator Using Nutanix Kubernetes Platform CLI on page 657.

GPU Support Components

The following components provide NVIDIA GPU support on NKP:

- libnvidia-container and nvidia-container-runtime: GPU support in NKP depends
  on the containerd runtime. These components fit between containerd and runc
  to simplify GPU integration with the container runtime.
- NVIDIA Device Plugin: It is Kubernetes device plugin that enables GPU-
  enabled containers to run on NKP. The plugin monitors the number of
  available GPUs on each node and their health status. For more information,
  see NVIDIA Device Plugin.
- NVIDIA Data Center GPU Manager: Contains a Prometheus exporter that provides
  NVIDIA GPU metrics. For more information, see NVIDIA Data Center GPU
  Manager.

NKP runs these components as daemon sets, which simplifies management and
upgrades across all GPU nodes. For more information, see the Getting Started
Guide from NVIDIA.

### Creating GPU-Enabled Operating System Images

Before you begin

- (For vGPU images only) Access to the NVIDIA licensing portal.
- (For vGPU images only) NVIDIA vGPU host drivers installed on your
  infrastructure provider.
- (For vGPU images only) Guest driver runfile corresponding to your NVIDIA
  vGPU host driver.
- Compatible NVIDIA driver version for your deployment. For more information,
  see Compatibility and Interoperability Matrix in the Nutanix Support Portal.
- Operating system that supports GPU functionality for your deployment type.
  For more information, see Supported Infrastructure Operating Systems.

> **Note: vGPU support requires NKP version 2.16.0 or later.**

About this task

Create GPU-enabled operating system images for worker nodes on Nutanix
infrastructure using the NKP image builder. The following commands are
specific to Nutanix deployments and allow you to create images with basic GPU
passthrough support or custom images with pre-installed vGPU drivers.

```yaml
Note: For information about creating custom images on other supported infrastructure providers, see Nutanix Image
Builder on page 51.
```

Procedure

1. Open a terminal with access to the NKP CLI.
2. Create a GPU passthrough image:

```bash
nkp create image nutanix --gpu-name=${GPU_NAME} --cluster=${NUTANIX_CLUSTER_NAME} --
endpoint=${NUTANIX_PC_ENDPOINT} --subnet=${NUTANIX_SUBNET} OS_TYPE-OS_VERSION
```

For example:

```bash
nkp create image nutanix --gpu-name=RTX-A6000 --cluster=graphics-cluster --
endpoint=pc.datacenter.local --subnet=infra-subnet rocky-9.6
Note: Verify that the subnet has external connectivity to configure the machine. For restricted network
environments, use the bastion host configuration.
```

The command returns output similar to the following: --> nutanix.nib_image:
`<Name of the GPU OS image created by NKP CLI>` 3. If your environment requires
a bastion host, create the image using bastion host configuration:

```bash
nkp create image nutanix \
--gpu-name=${GPU_NAME} \
--cluster=${NUTANIX_CLUSTER_NAME} \
--endpoint=${NUTANIX_PC_ENDPOINT} \
--subnet=${NUTANIX_SUBNET} \
--bastion-host=${BASTION_IP} \
--bastion-username=${BASTION_SSH_USERNAME} \
--bastion-private-key-file=path/to/private_key.pem \
OS_TYPE-OS_VERSION
```

1. Create a custom VM image with pre-installed vGPU driver runfiles:

```bash
nkp create image nutanix \
--vgpu-runfile=/path/to/NVIDIA-Linux-x86_64-580.126.18-grid.run \
--subnet="${NUTANIX_SUBNET}" \
--gpu-name="${VGPU_PROFILE}" \
--cluster cluster-name \
--endpoint prism-central-endpoint \
--output-directory=output_dir/ \
OS_TYPE-OS_VERSION
```

### GPU Management Using Nutanix Kubernetes Platform UI

The typical GPU management workflow using the UI involves the following steps:

#### Adding GPU Node Pools Using the Nutanix Kubernetes Platform UI

- Enable NVIDIA GPU Operator Using the Nutanix Kubernetes Platform UI on page
  654
- Disabling NVIDIA GPU Operator Using Nutanix Kubernetes Platform UI on page 655

Before you begin

Before adding GPU node pools, verify that you have a Nutanix cluster with
NVIDIA GPU passthrough or vGPU capabilities configured.

About this task

To add a GPU passthrough or vGPU node pool to an existing NKP clusters using
UI, follow these steps:

Procedure

1. Log in to the NKP dashboard.

The Dashboard displays both management and managed clusters by default. 2. In
the top-left corner, click the Global dropdown and select your target
workspace.

For example, if your target cluster is a management cluster, select Management
Cluster Workspace. 3. In the left navigation menu, click Clusters and select
your target cluster. 4. In the cluster widget, click View Details. 5. On the
General Cluster Information page, click Nodepools. 6. Select a worker node
pool and click the vertical three-dot menu icon.

> **Note: GPUs can only be added to worker node pools, not control plane
> nodes.** 7. Click Edit. 8. In the Edit Node Pool window, navigate to the
> GPU section and select Passthrough or vGPU.

```yaml
Note: Before creating vGPU node pools to run the GPU-enabled applications on clusters, ensure that you enable
the vGPU token operator and add your client secret configuration token. For more information, see Enabling
the VGPU Token Operator on a Management, Attached or Managed Clusters on page 659.
```

1. Select a GPU type and specify the number of GPUs per node.
2. To set the MIG profile, apply labels to your GPU nodes, click Add a Label
   and enter key-value pairs for every node in the node pool. For example, to
   configure an A30 GPU with 1g.6gb profiles on all instances, enter
   nvidia.com/mig.config as the key and all-1g.6gb as the value. Labels help
   you select specific nodes for pod scheduling.
3. Click Save.

#### Enable NVIDIA GPU Operator Using the Nutanix Kubernetes Platform UI

Before you begin

Before enabling the NVIDIA GPU operator, verify that you meet the following
requirements:

- An existing NKP cluster on a supported infrastructure provider
- A VM image with NVIDIA GPU drivers installed. For more information, see
  Nutanix Image Builder on page 51.
- A node pool with NVIDIA GPUs configured for your environment. For more
  information, see Adding GPU Node Pools Using the Nutanix Kubernetes Platform
  UI on page 653 or Adding GPU Node Pools Using the Nutanix Kubernetes
  Platform CLI on page 656 based on your infrastructure provider.
- GPU-enabled nodes in your cluster with compatible NVIDIA GPUs. For supported
  NVIDIA driver information, see NVIDIA Drivers in the Compatibility and
  Interoperability Matrix.

About this task

Enable GPU support on existing NKP clusters after installation is complete.
The NKP UI allows you to configure advanced GPU features such as pre-compiled
drivers and Multi-Instance GPU (MIG).

Procedure

1. Log in to the NKP dashboard.

The Dashboard displays both management and managed clusters by default. 2. In
the top-left corner, click the Global dropdown and select your target
workspace.

For example, if your target cluster is a management cluster, select Management
Cluster Workspace. 3. In the left navigation menu, click Applications. 4.
Locate NVIDIA GPU Operator and click View Details. 5. On the NVIDIA GPU
Operator page, click Enable. 6. In the Workspace Application Configuration
Override section, enter the workspace application configuration for all
clusters in this workspace using the code editor.

For GPU operator with pre-compiled drivers (recommended for production):

```bash
driver:
enabled: true
usePrecompiled: true
version: 580
```

> **Note: You do not need to configure overrides for a basic GPU operator
> installation.** 7. To use MIG functionality, add the MIG configuration:

```bash
mig:
strategy: single
```

> **Note:**

- Set strategy: mixed when MIG mode is not enabled on all GPUs in a node. Set
  strategy: single when MIG is enabled on all GPUs with the same device types.
- Starting with Nutanix AOS 7.3 and AHV 10.3, MIG profiles are hidden in the
  NKP UI and CLI to prevent accidental assignments. MIG supports only VMs
  configured with GPU passthrough. Nutanix does not support MIG profiles for
  vGPU-attached VMs. To remove a MIG vGPU profile from a VM, see Prism Central
  Infrastructure Guide: Updating a VM through Prism Central (AHV).

1. Click Enable.

#### Disabling NVIDIA GPU Operator Using Nutanix Kubernetes Platform UI

About this task

To disable NVIDIA GPU operator platform application in NKP UI, follow these
steps:

Procedure

1. Log in to NKP dashboard.

By default, the Dashboard displays both management and managed clusters. 2. In
the top-left corner, click the Global dropdown list and select your target
workspace.

For example, if your target cluster is management cluster, select Management
Cluster Workspace. 3. In the left navigation menu, click Cluster and choose
your target cluster. 4. In the Management Cluster, managed, or attached
clusters widget, click View Details. 5. In the General Cluster Information
page, click Enabled Application. 6. Navigate to NVIDIA GPU Operator and click
the dropdown menu next to Dashboard. 7. Select Disable.

### GPU Management Using Nutanix Kubernetes Platform CLI

The typical GPU management workflow using the CLI involves the following steps:

#### Adding GPU Node Pools Using the Nutanix Kubernetes Platform CLI

- Enable NVIDIA GPU Operator Using Nutanix Kubernetes Platform CLI on page 657
- Disabling NVIDIA GPU Operator Using Nutanix Kubernetes Platform CLI on page
  659

Before you begin

Before adding GPU node pools, verify that you have an NKP cluster with NVIDIA
GPU passthrough or vGPU capabilities configured on your infrastructure
provider.

About this task

Add GPU node pools to existing NKP clusters using the CLI that supports both
GPU passthrough and vGPU configurations across all infrastructure providers.

Procedure

1. Open a terminal with access to the NKP CLI. Verify that the NKP CLI is
   configured to point to your management cluster. For more information about
   configuring the CLI context, see Commands within a kubeconfig File on page
2.
3. Create a node pool with GPU passthrough. Run the following command,
   replacing the variables with your specific values:

```bash
nkp create nodepool nutanix \
-c ${NKP_CLUSTER_NAME} \
--gpu-name "${GPU_NAME}" \
--vm-image ${GPU_VM_IMAGE_NAME} \
--prism-element-cluster ${PE_CLUSTER_WITH_GPU} \
--subnets ${SUBNET_NAME} \
--replicas=1 \
${GPU_NODEPOOL_NAME}
Note: Use the --gpu-count flag to specify the number of GPUs per machine. The default gpu-count is 1.
For Nutanix deployments, the command fails when the required number of GPUs (calculated as gpu-count *
replicas) exceeds the available GPUs in your Prism Element cluster.
```

The command creates a node pool with one worker node and one GPU passthrough
device. 3. Create a node pool with vGPU support. Run the following command,
replacing the variables with your specific values:

```bash
nkp create nodepool nutanix \
-c ${NKP_CLUSTER_NAME} \
--gpu-name "${GPU_NAME}" \
--vm-image vgpu-enabled-image-name \
--subnets subnet-name \
--prism-element-cluster PE-cluster-name \
${GPU_NODEPOOL_NAME}
Note: Before creating vGPU node pools to run the GPU-enabled applications on clusters, ensure that you enable
the vGPU token operator and add your client secret configuration token. For more information, see Enabling the
VGPU Token Operator on a Management, Attached or Managed Clusters on page 659.
```

The command creates a node pool with one worker node and one vGPU device. 4.
To set the MIG profile, label the node ${NODE} with the following profile:

```bash
kubectl label nodes ${NODE} nvidia.com/mig.config=all-1g.6gb --overwrite
```

For example, to configure an A30 GPU with 1g.6gb profiles on all instances,
enter nvidia.com/mig.config as the key and all-1g.6gb as the value. 5. Check
the node labels to confirm that the MIG configurations is applied to the GPU-
enabled node:

```bash
kubectl get no -o json | jq .items[0].metadata.labels
```

Sample output:

```bash
"nvidia.com/mig.config": "all-1g.6gb",
"nvidia.com/mig.config.state": "success",
"nvidia.com/mig.strategy": "single"
```

#### Enable NVIDIA GPU Operator Using Nutanix Kubernetes Platform CLI

Before you begin

Before enabling the NVIDIA GPU operator, verify that you meet the following
requirements:

- Create a VM image with NVIDIA GPU drivers installed. For more information,
  see Nutanix Image Builder on page 51.
- Create a node pool with NVIDIA GPUs for your environments. For more
  information, see Adding GPU Node Pools Using the Nutanix Kubernetes Platform
  UI on page 653 or Adding GPU Node Pools Using the Nutanix Kubernetes
  Platform CLI on page 656 based on your infrastructure provider.
- An existing NKP cluster on any supported infrastructure provider.
- GPU-enabled nodes in your cluster with compatible NVIDIA GPUs. For the
  supported NVIDIA driver information, see NVIDIA Drivers in the Compatibility
  and Interoperability Matrix
- The NKP CLI configured to point to your management cluster.

About this task

Use this method to enable GPU support on existing NKP clusters after
installation is complete. The CLI method allows you to configure advanced GPU
features such as pre-compiled drivers and Multi-Instance GPU (MIG).

```yaml
Important: Ensure that your cluster has GPU-enabled nodes before enabling the NVIDIA GPU operator. For
information about creating GPU node pools, see the documentation specific to your infrastructure provider.
```

Procedure

1. Create a ConfigMap with the GPU operator configuration.

For GPU operator with pre-compiled drivers (recommended for production):

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
namespace: kommander
name: nvidia-gpu-operator-overrides
data:
values.yaml: |
driver:
enabled: true
usePrecompiled: true
version: 580
EOF
```

> **Note: You do not need to configure overrides for a basic GPU operator
> installation.** 2. To use MIG functionality, add the MIG configuration to
> the values.yaml:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
namespace: kommander
name: nvidia-gpu-operator-overrides
data:
values.yaml: |
---
mig:
strategy: single
```

> **Note:**

- Set strategy: mixed when MIG mode is not enabled on all GPUs in a node. Set
  strategy: single when MIG is enabled on all GPUs with the same device types.
- Starting with Nutanix AOS 7.3 and AHV 10.3, MIG profiles are hidden in the
  NKP UI and CLI to prevent accidental assignments. MIG supports only VMs
  configured with GPU passthrough. Nutanix

does not support MIG profiles for vGPU-attached VMs. To remove a MIG vGPU
profile from a VM, see Prism Central Infrastructure Guide: Updating a VM
through Prism Central (AHV). 3. Create the NVIDIA GPU operator AppDeployment
that references the ConfigMap:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: nvidia-gpu-operator
namespace: kommander
spec:
appRef:
name: nvidia-gpu-operator-gpu-operator-version
kind: ClusterApp
configOverrides:
name: nvidia-gpu-operator-overrides
EOF
```

For the supported NVIDIA GPU operator version, see the Supported Applications
section in the NKP Release Notes. 4. Verify that the GPU operator is installed
and running:

```bash
kubectl get pods -n nvidia-gpu-operator
```

The command returns a list of running GPU operator pods, including the device
plugin, driver, and operator components.

#### Disabling NVIDIA GPU Operator Using Nutanix Kubernetes Platform CLI

About this task

To disable NVIDIA GPU operator platform application in NKP CLI, follow these
steps:

Procedure

1. Delete all GPU workloads running on the GPU nodes where the NVIDIA GPU
   Operator platform application is active.
2. Delete the existing NVIDIA GPU operator AppDeployment:

```bash
kubectl delete appdeployment -n kommander nvidia-gpu-operator
```

1. To check the pod status, monitor the cleanup of NVIDIA-specific resources
   in the Terminating state:

```bash
kubectl get pods -A | grep nvidia
```

For more information, see Pre-provisioned: Deleting Node Pools on page 813.

### Enabling the VGPU Token Operator on a Management, Attached or Managed

Clusters

Before you begin

Before enabling the vGPU token operator, ensure that you meet the following
requirements:

- Access to the NVIDIA licensing portal.
- A valid .tok file to access the license. For example,
  client_configuration_token.tok.

For more information, see Generating a Client Configuration Token.

- A cloud licensing server or delegated license server is available.

About this task

To enable the VGPU token operator on a management, attached or managed
clusters, follow these steps:

Procedure

1. Log in to the Nutanix Kubernetes Platform (NKP) dashboard.
2. In the top-left corner, from the dropdown list, select your target workspace.

By default, the Global workspace is displayed. 3. From the left navigation
pane, click Clusters. 4. In the cluster (management, attached, or managed)
widget, click View Details. 5. In the Enabled Applications tab, locate VGPU
Token Operator and click View Details.

You can also filter the applications by its name, category, and type. 6. On
the VGPU Token Operator page, click Edit. The Edit VGPU Token Operator
(v1.0.7) page is displayed. 7. In the Workspace Application Configuration
field, update the client secret configuration token for your cluster. 8. Click
Enable.

### Validating the Application

About this task

To validate your application, follow these steps:

Procedure

1. Validate that your application is started.

```bash
kubectl get pods -A | grep nvidia
```

Sample output:

```bash
nvidia-container-toolkit-daemonset-7h2l5 1/1 Running 0 150m
nvidia-container-toolkit-daemonset-mm65g 1/1 Running 0 150m
nvidia-container-toolkit-daemonset-mv7xj 1/1 Running 0 150m
nvidia-cuda-validator-pdlz8 0/1 Completed 0 150m
nvidia-cuda-validator-r7qc4 0/1 Completed 0 150m
nvidia-cuda-validator-xvtqm 0/1 Completed 0 150m
nvidia-dcgm-exporter-9r6rl 1/1 Running 1 (149m ago) 150m
nvidia-dcgm-exporter-hn6hn 1/1 Running 1 (149m ago) 150m
nvidia-dcgm-exporter-j7g7g 1/1 Running 0 150m
nvidia-dcgm-jpr57 1/1 Running 0 150m
nvidia-dcgm-jwldh 1/1 Running 0 150m
nvidia-dcgm-qg2vc 1/1 Running 0 150m
nvidia-device-plugin-daemonset-2gv8h 1/1 Running 0 150m
nvidia-device-plugin-daemonset-tcmgk 1/1 Running 0 150m
nvidia-device-plugin-daemonset-vqj88 1/1 Running 0 150m
nvidia-device-plugin-validator-9xdqr 0/1 Completed 0 149m
nvidia-device-plugin-validator-jjhdr 0/1 Completed 0 149m
nvidia-device-plugin-validator-llxjk 0/1 Completed 0 149m
nvidia-operator-validator-9kzv4 1/1 Running 0 150m
nvidia-operator-validator-fvsr7 1/1 Running 0 150m
nvidia-operator-validator-qr9cj 1/1 Running 0 150m
```

1. To validate whether the vGPU is set up, check the node labels.

```bash
kubectl get nodes -o json | jq '.items[].metadata.labels' | grep -i nvidia
```

Sample output:

```bash
"nvidia.com/gpu.product": "NVIDIA-A40-4C",
"nvidia.com/gpu.replicas": "1",
"nvidia.com/gpu.sharing-strategy": "none",
"nvidia.com/mig.capable": "true",
"nvidia.com/mig.strategy": "single",
"nvidia.com/mps.capable": "false",
"nvidia.com/vgpu.host-driver-branch": "r538_67",
"nvidia.com/vgpu.host-driver-version": "580.126.18",
"nvidia.com/vgpu.present": "true"
```

The presence of nvidia.com/vgpu.present: "true" confirms that vGPU is
configured. 3. To validate whether the vGPU is set up, follow these steps:

a. To verify the vGPU access, create a test pod.

```bash
# https://catalog.ngc.nvidia.com/orgs/nvidia/teams/k8s/containers/cuda-sample
apiVersion: v1
kind: Pod
metadata:
generateName: gpu-pod-
labels:
test: gpu-pod
spec:
restartPolicy: OnFailure
containers:
- name: gpu-pod
image: nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda12.5.0
command: ["/bin/bash", "-c"]
args:
- "sleep inf"
resources:
limits:
nvidia.com/gpu: 1
nodeSelector:
"nvidia.com/gpu.present": "true"
```

b. Apply the YAML.

```bash
kubectl apply -f gpu-test-pod.yaml
```

c. Run nvidia-smi in the pod that you created and check the status of the
license.

```bash
kubectl exec <generated-pod-name> -- nvidia-smi -q
```

Sample output:

```bash
$ kubectl exec gpu-pod-6z7vj -- nvidia-smi
Wed Apr 2 15:51:38 2025
+---------------------------------------------------------------------------------------
+
| NVIDIA-SMI 580.126.18 Driver Version: 580.126.18 CUDA Version:
12.2 |
```

### NVIDIA GPU Metrics Monitoring

By default, Kommander has a Grafana dashboard named NVIDIA DCGM Exporter
Dashboard, which displays the GPU performance and health data. You can access
this dashboard from the Kommander Grafana user interface to monitor GPU
metrics across your clusters. For information, see NVIDIA DCGM.

### Troubleshooting NVIDIA GPU Operator on Nutanix Kubernetes Platform

About this task

To troubleshoot the common errors with NVIDIA GPU Operator on NKP, follow
these steps:

Procedure

1. Connect to your GPU-enabled nodes using SSH or similar and run nvidia-smi.

Sample output:

```bash
[ec2-user@ip-10-0-0-241 ~]$ nvidia-smi
Thu Nov 3 22:52:59 2022
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 580.126.18 Driver Version: 580.126.18 CUDA Version: 12.2.2 |
|-------------------------------+----------------------+----------------------+
| GPU Name Persistence-M| Bus-Id Disp.A | Volatile Uncorr. ECC |
| Fan Temp Perf Pwr:Usage/Cap| Memory-Usage | GPU-Util Compute M. |
| | | MIG M. |
|===============================+======================+======================|
| 0 Tesla T4 On | 00000000:00:1E.0 Off | 0 |
| N/A 54C P8 11W / 70W | 0MiB / 15109MiB | 0% Default |
| | | N/A |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes: |
| GPU GI CI PID Type Process name GPU Memory |
| ID ID Usage |
|=============================================================================|
| No running processes found |
+-----------------------------------------------------------------------------+
```

1. If you misconfigure the toolkit version, NVIDIA pods enter in a bad state.

Sample output:

```bash
nvidia-container-toolkit-daemonset-jrqt2 1/1 Running
0 29s
nvidia-dcgm-exporter-b4mww 0/1 Error
1 (9s ago) 16s
nvidia-dcgm-pqsz8 0/1
CrashLoopBackOff 1 (13s ago) 27s
nvidia-device-plugin-daemonset-7fkzr 0/1 Init:0/1
0 14s
nvidia-operator-validator-zxn4w 0/1
Init:CrashLoopBackOff 1 (7s ago) 11s
```

To modify the toolkit version, follow these steps:

a. Apply AppDeployment for the nvidia-gpu-operator application.

b. Provide the name of a ConfigMap with the custom configuration in
AppDeployment.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: nvidia-gpu-operator
namespace: kommander
spec:
appRef:
kind: ClusterApp
name: nvidia-gpu-operator-gpu-operator-version
EOF
```

1. If a node includes NVIDIA GPU and the nvidia-gpu-operator application is
   enabled on the cluster, but the node still rejects the GPU workloads, it is
   possible that the nodes do not have the required label that indicates the
   NVIDIA GPU presence. By default, the GPU operator attempts to configure
   nodes with the following labels:

```bash
"feature.node.kubernetes.io/pci-10de.present": "true",
"feature.node.kubernetes.io/pci-0302_10de.present": "true",
"feature.node.kubernetes.io/pci-0300_10de.present": "true",
```

The node feature discovery component applies these labels.

If the labels are not available in a node that contains an NVIDIA GPU,
manually label the node:

```bash
kubectl label node ${NODE} feature.node.kubernetes.io/pci-0302_10de.present=true
```

## Monitoring and Alerts

Using NKP you can monitor the state of the cluster and the health and
availability of the processes running on the cluster. By default, Kommander
provides monitoring services using a pre-configured monitoring stack based on
the Prometheus open-source project and its broader ecosystem.

The default NKP monitoring stack:

- Provides in-depth monitoring of Kubernetes components and platform services.
- Includes a default set of Grafana dashboards to visualize the status of the
  cluster and its platform services.
- Supports predefined critical error and warning alerts. These alerts notify
  immediately if there is a problem with cluster operations or availability.

By incorporating Prometheus, Kommander visualizes all the metrics that are
exposed from your different nodes, Kubernetes objects, and platform service
applications running in your cluster. The default monitoring stack also
enables you to add metrics from any of your deployed applications, making
those applications part of the overall Prometheus metrics stream.

### Recommendations

Nutanix conducts routine performance testing of Kommander. The following table
provides recommended settings, based on cluster size and increasing workloads,
that maintain a healthy Prometheus monitoring deployment.

```yaml
Note: The resource settings reflect some settings but do not represent the exact structure to be used in the platform
service configuration.
```

Table 59: Prometheus

10 1k 250 resources: limits: cpu: 500m memory: 2192Mi requests: cpu: 100m
memory: 500Mi storage: 35Gi

25 1k 250 resources: limits: cpu: 2 memory: 6Gi requests: cpu: 1 memory: 3Gi
storage: 60Gi

50 1.5k 500 resources: limits: cpu: 7 memory: 28Gi requests: cpu: 2 memory:
8Gi storage: 100Gi

100 3k 1k resources: limits: cpu: 12 memory: 50Gi requests: cpu: 10 memory:
48Gi storage: 100Gi

200 10k 3k resources: limits: cpu: 20 memory: 80Gi requests: cpu: 15 memory:
50Gi storage: 100Gi

300 15k 6k resources: limits: cpu: 35 memory: 150Gi requests: cpu: 25 memory:
120Gi storage: 100Gi

| Cluster Size | Number of Pods | Number of Services | Resource settings |
| ------------ | -------------- | ------------------ | ----------------- |

### Grafana Dashboards

With Grafana, you can query and view collected metrics in easy-to-read graphs.
Kommander ships with a set of default dashboards, including:

- Kubernetes Components: API Server, Nodes, Pods, Kubelet, Scheduler,
  StatefulSets and Persistent Volumes
- Kubernetes USE method: Cluster and Nodes
- Calico
- etcd
- Prometheus

Find the complete list of default-enabled dashboards on GitHub. For more
information, see `<https://github.com/>` prometheus-community/helm-
charts/tree/main/charts/kube-prometheus-stack/templates/grafana/
dashboards-1.14.

#### Disabling Default Dashboards

About this task

To disable all of the default dashboards, follow these steps to define an
overrides ConfigMap:

Procedure

1. Create a file named kube-prometheus-stack-overrides.yaml and paste the
   following YAML code into it to create the overrides ConfigMap.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: kube-prometheus-stack-overrides
namespace: <your-workspace-namespace>
data:
values.yaml: |
---
grafana:
defaultDashboardsEnabled: false
```

1. Use the following command to apply the YAML file.

```bash
kubectl apply -f kube-prometheus-stack-overrides.yaml
```

1. Edit the kube-prometheus-stack AppDeployment to replace the
   spec.configOverrides.name value with

kube-prometheus-stack-overrides.

To deploy an application with a custom configuration, see Customizing an
Application Per Cluster on page 375. When your editing is complete, the
AppDeployment will resemble this code sample.

```yaml
apiVersion: apps.kommander.d2iq.io/v1alpha2
kind: AppDeployment
metadata:
name: kube-prometheus-stack
namespace: <your-workspace-namespace>
spec:
appRef:
name: kube-prometheus-stack-your-kube-prometheus-stack-version
kind: ClusterApp
configOverrides:
name: kube-prometheus-stack-overrides
```

To access the Grafana UI, browse to the landing page and then search for the
Grafana dashboard, for example, `<https://`>`<CLUSTER_URL>`/dkp/grafana.

#### Adding Custom Dashboards

About this task

In Kommander, you can define your own custom dashboards. You can use a few
methods to import dashboards to Grafana. For more information, see
`<https://github.com/grafana/helm-charts/tree/main/charts/grafana#import->`
dashboards.

Procedure

1. One method is to use ConfigMaps to import dashboards. Below are steps on
   how to create a ConfigMap with your dashboard definition.

For more information, see `<<https://github.com/grafana/helm->`
charts/tree/main/charts/grafana#sidecar-for-> dashboards. For simplicity, this
section assumes the desired dashboard definition is in json format.

```bash
{
"annotations": {
"list": []
},
"description": "etcd sample Grafana dashboard with Prometheus",
"editable": true,
"gnetId": null,
"hideControls": false,
"id": 6,
"links": [],
"refresh": false,
...
}
```

1. After creating your custom dashboard json, insert it into a ConfigMap and
   save it as etcd-custom-

dashboard.yaml.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: etcd-custom-dashboard
labels:
grafana_dashboard: "1"
data:
etcd.json: |
{
"annotations": {
"list": []
},
"description": "etcd sample Grafana dashboard with Prometheus",
"editable": true,
"gnetId": null,
"hideControls": false,
"id": 6,
"links": [],
"refresh": false,
...
}
```

Apply the ConfigMap, which automatically gets imported to Grafana using the
Grafana dashboard sidecar (see `<<https://github.com/grafana/helm->`
charts/tree/main/charts/grafana#sidecar-for-dashboards>).

```bash
kubectl apply -f etcd-custom-dashboard.yaml
```

### Cluster Metrics

The kube-prometheus-stack is deployed by default on the management cluster and
attached clusters. This stack deploys the following Prometheus components to
expose metrics from nodes, Kubernetes units, and running apps:

- prometheus-operator: orchestrates various components in the monitoring
  pipeline.
- prometheus: collects metrics, saves them in a time series database, and
  serves queries.
- alertmanager: handles alerts sent by client applications such as the
  Prometheus server.
- node-exporter: deployed on each node to collect the machine hardware and OS
  metrics.
- kube-state-metrics: simple service that listens to the Kubernetes API server
  and generates metrics about the state of the objects.
- grafana: monitors and visualizes metrics.
- service monitors: collects internal Kubernetes components.

```yaml
Note: NKP has a listener on the metrics.k8s.io/v1beta1/nodes resource, which updates your backend store
when that value changes. We then poll that backend store every 5 seconds, so the metrics are updated in real time every
5 seconds without the need to refresh your view.
```

For a detailed description of the exposed metrics, see
`<https://github.com/kubernetes/kube-state-metrics/tree/>` main/docs#exposed-
metrics. The service-monitors collect internal Kubernetes components but can
also be extended to monitor customer applications.

### Alerts Using AlertManager

> **Important:**

- Before you configure email or Slack alert notifications, enable the
  Prometheus Monitoring application in the NKP UI. For more information, see
  the topic for your licence type: Ultimate: Enabling an Application Using the
  UI on page 334 or Pro: Enabling an Application Using the UI on page 336
- The NKP Starter license does not include this application. For the license
  tiers that support it, see Feature Support Matrix on page 24.

Kommander is configured with predefined alerts to monitor four specific
events. You receive alerts related to:

- State of your nodes
- System services managing the Kubernetes cluster
- Resource events from specific system services
- Prometheus expressions exceeding some predefined thresholds

Some examples of the currently available alerts are:

- CPUThrottlingHigh
- TargetDown
- KubeletNotReady
- KubeAPIDown
- CoreDNSDown
- KubeVersionMismatch

For a complete list of all the predefined alerts on GitHub, see Prometheus
Rules.

#### Configuring Alert Rules

About this task

Use an overrides ConfigMap to configure alert rules.

You can enable or disable the default alert rules by providing the
configuration in an overrides ConfigMap. To turn off the default node alert
rules, follow these steps to define an overrides ConfigMap:

Before you begin

1. Determine the name of the workspace where you want to configure the alert
   rules:

```bash
nkp get workspaces
```

The command lists the workspace names and their corresponding namespaces. 2.
Set the WORKSPACE_NAMESPACE environment variable to the namespace of the
workspace where the cluster is attached:

```bash
export WORKSPACE_NAMESPACE=<workspace_namespace>
```

Procedure

1. Create a file named kube-prometheus-stack-overrides.yaml and paste the
   following YAML code into it to create the override ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: kube-prometheus-stack-overrides
namespace: ${WORKSPACE_NAMESPACE}
data:
values.yaml: |
---
defaultRules:
rules:
node: false
```

1. Apply the YAML file:

```bash
kubectl apply -f kube-prometheus-stack-overrides.yaml
```

1. Edit the kube-prometheus-stack AppDeployment to replace the
   spec.configOverrides.name value with

kube-prometheus-stack-overrides.

```bash
nkp edit appdeployment -n ${WORKSPACE_NAMESPACE} kube-prometheus-stack
```

After you complete the edits, the AppDeployment resembles the following example:

```yaml
apiVersion: apps.kommander.d2iq.io/v1alpha2
kind: AppDeployment
metadata:
name: kube-prometheus-stack
namespace: ${WORKSPACE_NAMESPACE}
spec:
appRef:
name: kube-prometheus-stack-your-kube-prometheus-stack-version
kind: ClusterApp
configOverrides:
name: kube-prometheus-stack-overrides
```

1. To disable all the rules, create an overrides ConfigMap with the following
   YAML code:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: kube-prometheus-stack-overrides
namespace: ${WORKSPACE_NAMESPACE}
data:
values.yaml: |
---
defaultRules:
create: false
```

1. Alert rules for the Velero platform service are turned off by default. You
   can enable them with the following overrides ConfigMap, but only if the
   velero platform service is enabled:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: kube-prometheus-stack-overrides
namespace: ${WORKSPACE_NAMESPACE}
data:
values.yaml: |
---
mesosphereResources:
rules:
velero: true
```

If platform services are disabled, disable the alert rules to avoid alert
misfires. 6. To add a custom alert rule named my-rule-name, create an
overrides ConfigMap with the following YAML code:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: kube-prometheus-stack-overrides
namespace: ${WORKSPACE_NAMESPACE}
data:
values.yaml: |
---
additionalPrometheusRulesMap:
my-rule-name:
groups:
  - name: my_group
rules:
  - record: my_record
expr: 100 * my_record
```

After you set up your alerts, you can manage each alert using the Prometheus
web console to mute or unmute firing alerts, and perform other operations. For
more information on configuring alertmanager, see https://
prometheus.io/docs/alerting/latest/configuration/.

To access the Prometheus Alertmanager UI, go to the landing page and then
search for the Prometheus Alertmanager dashboard, for example
`<https://`>`<CLUSTER_URL>`/dkp/alertmanager

#### Configuring Prometheus Alerts in Slack

About this task

To hook up the Prometheus alertmanager notification system, you need to
overwrite the existing configuration.

Procedure

1. The following file, named alertmanager.yaml, configures alertmanager to use
   the Incoming Webhooks feature of Slack (slack_api_url:
   <https://hooks.slack.com/services/>`<HOOK_ID>`) to fire all the alerts to a
   specific channel #MY-SLACK-CHANNEL-NAME.

```bash
global:
resolve_timeout: 5m
slack_api_url: https://hooks.slack.com/services/<HOOK_ID>
route:
group_by: ['alertname']
group_wait: 2m
group_interval: 5m
repeat_interval: 1h
# If an alert isn't caught by a route, send it to slack.
receiver: slack_general
routes:
- match:
alertname: Watchdog
receiver: "null"
receivers:
- name: "null"
- name: slack_general
slack_configs:
- channel: '#MY-SLACK-CHANNEL-NAME'
icon_url: https://avatars3.githubusercontent.com/u/3380462
send_resolved: true
color: '{{ if eq .Status "firing" }}danger{{ else }}good{{ end }}'
title: '{{ template "slack.default.title" . }}'
title_link: '{{ template "slack.default.titlelink" . }}'
pretext: '{{ template "slack.default.pretext" . }}'
text: '{{ template "slack.default.text" . }}'
fallback: '{{ template "slack.default.fallback" . }}'
icon_emoji: '{{ template "slack.default.iconemoji" . }}'
templates:
- '*.tmpl'
```

1. The following file, named notification.tmpl, is a template that defines a
   pretty format for the fired notifications.

```bash
{{ define "__titlelink" }}
{{ .ExternalURL }}/#/alerts?receiver={{ .Receiver }}
{{ end }}
{{ define "__title" }}
[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}
{{ end }}] {{ .GroupLabels.SortedPairs.Values | join " " }}
{{ end }}
{{ define "__text" }}
{{ range .Alerts }}
{{ range .Labels.SortedPairs }}*{{ .Name }}*: `{{ .Value }}`
{{ end }} {{ range .Annotations.SortedPairs }}*{{ .Name }}*: {{ .Value }}
{{ end }} *source*: {{ .GeneratorURL }}
{{ end }}
{{ end }}
{{ define "slack.default.title" }}{{ template "__title" . }}{{ end }}
{{ define "slack.default.username" }}{{ template "__alertmanager" . }}{{ end }}
{{ define "slack.default.fallback" }}{{ template "slack.default.title" . }} |
{{ template "slack.default.titlelink" . }}{{ end }}
{{ define "slack.default.pretext" }}{{ end }}
{{ define "slack.default.titlelink" }}{{ template "__titlelink" . }}{{ end }}
{{ define "slack.default.iconemoji" }}{{ end }}
{{ define "slack.default.iconurl" }}{{ end }}
{{ define "slack.default.text" }}{{ template "__text" . }}{{ end }}
```

1. Finally, apply these changes to alertmanager as follows. Set
   ${WORKSPACE_NAMESPACE} to the workspace namespace that kube-prometheus-stack
   is deployed in.

```bash
kubectl create secret generic -n ${WORKSPACE_NAMESPACE} \
alertmanager-kube-prometheus-stack-alertmanager \
--from-file=alertmanager.yaml \
--from-file=notification.tmpl \
--dry-run=client --save-config -o yaml | kubectl apply -f -
```

#### Configuring Prometheus Alerts in Emails

About this task

To configure the Prometheus alertmanager notification system to send an email
for alerts, you need to overwrite the existing configuration. The steps below
configure Alertmanager to send all configured alerts to a Gmail account. For
example, `<test@gmail.com>`.

Procedure

1. Create a file named alertmanager.yaml with the following contents.

```bash
global:
resolve_timeout: 5m
inhibit_rules: []
receivers:
- name: "null"
- name: test_gmail
email_configs:
- to: test@gmail.com
from: test@gmail.com
auth_username: test@gmail.com
auth_password: password
send_resolved: true
require_tls: true
smarthost: smtp.gmail.com:587
route:
receiver: test_gmail
group_by:
- namespace
group_interval: 5m
group_wait: 30s
repeat_interval: 12h
routes:
- matchers:
- alertname =~ "InfoInhibitor|Watchdog"
receiver: "null"
templates:
- /etc/alertmanager/config/*.tmpl
```

1. Apply these changes to alertmanager as follows. Set ${WORKSPACE_NAMESPACE}
   to the workspace namespace that kube-prometheus-stack is deployed in
   (typically the kommander namespace).

```bash
kubectl create secret generic -n ${WORKSPACE_NAMESPACE} \

alertmanager-kube-prometheus-stack-alertmanager \
--from-file=alertmanager.yaml \
--dry-run=client --save-config -o yaml | kubectl apply -f -
```

1. Allow some time for the configuration to take affect. You can then use the
   following command to verify that the configuration took effect.

```bash
kubectl exec -it alertmanager-kube-prometheus-stack-alertmanager-0 -n kommander --
cat /etc/alertmanager/config_out/alertmanager.env.yaml
```

For more information on configuring email alerting, see
`<https://prometheus.io/docs/alerting/latest/>` configuration/.

### Centralized Monitoring

Managed or attached clusters are distinguished by a monitoring ID. The
monitoring ID corresponds to the kube- system namespace UID of the cluster. To
find a cluster's monitoring ID, you can go to the Clusters tab on the NKP UI
(in the relevant workspace), or go to the Clusters page in the Global
workspace:

```bash
https://<CLUSTER_URL>/dkp/kommander/dashboard/clusters
```

Select the View Details link on the attached cluster card, and then select the
Configuration tab, and find the monitoring ID under Monitoring ID (clusterId).

You might also search or filter by monitoring IDs on the Clusters page, linked
above.

You can also run this kubectl command, using the correct cluster's context or
kubeconfig, to look up the cluster's kube-system namespace UID to determine
which cluster the metrics and alerts correspond to:

```bash
kubectl get namespace kube-system -o jsonpath='{.metadata.uid}'
```

#### Adding Custom Dashboards (2)

About this task

You can also define custom dashboards for centralized monitoring on Kommander.
There are a few methods to import dashboards to Grafana. For more information,
see `<https://github.com/mesosphere/charts/tree/master/>` stable/grafana#import-
dashboards.

Procedure

1. For simplicity, assume the desired dashboard definition is in json format.

```bash
{
"annotations":
...
# Complete json file here
...
"title": "Some Dashboard",
"uid": "abcd1234",
"version": 1
}
```

1. After creating your custom dashboard json, insert it into a ConfigMap and
   save it as some-dashboard.yaml.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: some-dashboard
labels:
grafana_dashboard_kommander: "1"
data:
some_dashboard.json: |
{
"annotations":
...
# Complete json file here (2)
...
"title": "Some Dashboard",
"uid": "abcd1234",
"version": 1
}
```

1. Apply the ConfigMap, which will automatically get imported to Grafana
   through the Grafana dashboard sidecar.

```bash
kubectl apply -f some-dashboard.yaml
```

### Centralized Metrics

Managed and attached clusters, collects and presents metrics from all attached
clusters remotely using Thanos. You can visualize these metrics in Grafana
using a set of provided dashboards.

The Thanos Query (see `<https://thanos.io/v0.5/components/query/#query>`)
component is installed on attached and managed
clusters. Thanos Query queries the Prometheus instances on the attached
clusters, using a Thanos sidecar running
alongside each Prometheus container. Grafana is configured with Thanos Query
as its data source and comes with pre-
installed dashboards for a global view of all attached clusters. The Thanos
Query dashboard is also installed, by
default, to monitor the Thanos Query component.

```yaml
Note: Cluster metrics are read remotely from Kommander; they are not backed up. If an attached cluster goes down,
Kommander no longer collects or presents its metrics, including past data.
```

You can access the centralized Grafana UI at:

```bash
https://<CLUSTER_URL>/dkp/kommander/monitoring/grafana
Note: This is a separate Grafana instance from the one installed on all attached clusters. It is dedicated specifically to
components related to centralized monitoring.
```

Optionally, if you want to access the Thanos Query UI (essentially the
Prometheus UI), the UI is accessible at:

```bash
https://<CLUSTER_URL>/dkp/kommander/monitoring/query/
```

You can also check that the attached cluster's Thanos sidecars are
successfully added to Thanos Query by going to:

```bash
https://<CLUSTER_URL>/dkp/kommander/monitoring/query/stores
```

The preferred method to view the metrics for a specific cluster is to go
directly to that cluster's Grafana UI.

### Centralized Alerts

A centralized view of alerts from attached clusters, is provided using an
alert dashboard called Karma (see https:// github.com/prymitive/karma). Karma
aggregates all alerts from the Alertmanagers running in the attached clusters,
allowing you to visualize these alerts on one page. Using the Karma dashboard,
you can get an overview of each alert and filter by alert type, cluster, and
more.

> **Note: Silencing alerts using the Karma UI is currently not supported.**

You can access the Karma dashboard UI at:

```bash
https://<CLUSTER_URL>/dkp/kommander/monitoring/karma
Note: When there are no attached clusters, the Karma UI displays an error message Get https://
placeholder.invalid/api/v2/status: dial tcp: lookup placeholder.invalid on
10.0.0.10:53: no such host. This is expected, and the error disappears when clusters are connected.
```

### Federating Prometheus Alerting Rules

About this task

You can define additional Prometheus alerting rules (see
`<https://prometheus.io/docs/prometheus/latest/>` configuration/alerting_rules/)
on attached and managed clusters and federate them to all of the attached
clusters by following these instructions. To use these instructions you must
install the kubefedctl CLI (`<https://github.com/>` kubernetes-
retired/kubefed/blob/master/docs/installation.md#kubefedctl-cli).

Procedure

1. Enable the PrometheusRule type for federation.

```bash
kubefedctl enable PrometheusRules --kubefed-namespace kommander
```

1. Modify the existing alertmanager configuration.

```bash
kubectl edit PrometheusRules/kube-prometheus-stack-alertmanager.rules -n kommander
```

1. Append a sample rule.

```bash
- alert: MyFederatedAlert
annotations:
message: A custom alert that will always fire.
expr: vector(1)
labels:
severity: warning
```

1. Federate the rules you just modified.

```bash
kubefedctl federate PrometheusRules kube-prometheus-stack-alertmanager.rules --
kubefed-namespace kommander -n kommander
```

1. Ensure that the cluster selection (status.clusters) is appropriately set
   for your desired federation strategy and check the propagation status.

```bash
kubectl get federatedprometheusrules kube-prometheus-stack-alertmanager.rules -n
kommander -oyaml
```

### Cost Monitoring

OpenCost integrates directly with the Kubernetes API and cloud billing APIs to
provide real-time visibility into Kubernetes spending and cost allocation. It
continuously monitors resource usage across clusters to:

- Detect and prevent overspend caused by mis-configurations, bugs, or
  overlooked workloads.
- Understand the true cost of Kubernetes resources and improve utilization.
- Reuse over-provisioning by aligning resource requests with actual usage.

For more information, see OpenCost.

About this task

In earlier NKP versions, Kubecost provides cost visibility for individual
clusters. Starting with NKP 2.17, OpenCost replaces Kubecost and the NKP UI
provides robust cost observability features, ensuring a seamless transition
when you upgrade from version 2.16.

NKP enables OpenCost in the management cluster and collects cost metrics
remotely from each workload cluster. The NKP UI displays the costs from the
last day and the last seven days across each clusters, workspaces, and
projects.

To launch the OpenCost application in the NKP UI:

Procedure

1. Log in to the NKP UI dashboard.
2. In the workspace header drop-down list, select your target workspace.
3. In the cluster widget, click View Details.
4. On the General Cluster Information page, open the Enabled Applications tab.
5. Navigate to OpenCost and click Dashboard.

NKP launches the OpenCost application, which provides the following views:

- Cost Allocation tab: Displays the allocation of cloud resource costs to your
  NKP cluster. Costs are broken down by cluster, node, namespace, controller
  kind, controller, service, pod, and container over the past seven days.
- Cloud Costs tab: Displays actual billing data from your public cloud
  provider using their billing and pricing APIs. OpenCost supports multiple
  cloud providers and requires configuration of billing data access. In some
  cases, the default pricing from your cloud infrastructure provider might not
  reflect your actual rates. To ensure accurate reporting, you can override
  provider pricing by updating the local OpenCost Helm values file. The
  override must match the name of the cloud provider you are customizing. For
  more information, see Cloud Costs.
- External Costs tab: Provides visibility into external expenses that are not
  directly tied to Kubernetes resources but are relevant to overall cost
  reporting.

1. (Optional) To make the cost data accurate, provide a custom pricing model,
   see Providing Custom Pricing Overrides for OpenCost on page 677.

#### Providing Custom Pricing Overrides for OpenCost

About this task

In some cases, the default pricing from your cloud provider might not reflect
your actual rates. For example, you might:

- Negotiate custom pricing with your cloud infrastructure provider.
- Act as an intermediary with rates that differ from list prices.

To ensure accurate reporting, you can override cloud infrastructure provider
pricing by updating the local OpenCost Helm values file. The override must
match the name of the cloud provider you are customizing.

To provide a custom overrides pricing model, follow these steps:

Procedure

1. Create an override with the custom pricing model for your cloud
   infrastructure provider:

```bash
opencost:
customPricing:
enabled: true
provider: custom
costModel:
description: <Modified prices based on your actual pricing>
CPU: 1.25
RAM: 0.50
storage: 0.25
GPU: 1.9
```

For more information, see Custom Pricing. 2. Log in to the Nutanix Kubernetes
Platform (NKP) UI dashboard. 3. In the
workspace header drop-down list, select your target workspace. 4. In the
cluster widget, click View Details. 5. On the
General Cluster Information page, open the Enabled Applications tab. 6.
Navigate to OpenCost and click View Details. 7.
In the OpenCost application page, click the Configuration tab. 8. In the top
right corner, click Edit. 9. In the
Workspace Application Configuration Override field, paste the custom pricing
model for your cloud infrastructure
provider. 10. Click Save. NKP accurately calculates and displays the
Kubernetes resource consumption of your cloud
infrastructure in the OpenCost dashboard.

#### Transitioning from Kubecost to OpenCost in NKP

About this task

To transition existing clusters to use OpenCost, follow these steps:

Procedure

1. Upgrade the NKP Kommander and all the platform applications in the
   management cluster to NKP version 2.17.

When you upgrade to NKP 2.17, the default behavior of the NKP CLI is:

- If no active, non#trial Kubecost license is found, the NKP CLI uninstalls
  Kubecost from all clusters.
- If an active Kubecost license is detected, the upgrade aborts automatically
  to prevent disruption.

1. To proceed with an upgrade when a valid Kubecost license exists, you must
   orphan all the Kubecost resources from NKP by adding the flags in the nkp
   upgrade kommander command.

For more information, see Kubecost Resources Preservation in Upgrading
Kommander on page 1049.

### Application Monitoring using Prometheus

Before attempting to monitor your own applications, you must be familiar with
the Prometheus conventions for exposing metrics. In general, there are two key
recommendations:

- You must expose metrics using an HTTP endpoint named /metrics.
- The metrics you expose must be in a format that Prometheus can consume.

By following these conventions, you ensure that your application metrics can
be consumed by Prometheus itself or by any Prometheus-compatible tool that can
retrieve metrics, using the Prometheus client endpoint.

The kube-prometheus-stack for Kubernetes provides easy monitoring definitions
for Kubernetes services and deployment and management of Prometheus instances.
It provides a Kubernetes resource called ServiceMonitor.

By default, the kube-prometheus-stack provides the following service monitors
to collect internal Kubernetes components:

- kube-apiserver
- kube-scheduler
- kube-controller-manager
- etcd
- kube-dns/coredns
- kube-proxy

The operator is in charge of iterating over all of these ServiceMonitor
objects and collecting the metrics from these defined components.

The following example illustrates how to retrieve application metrics. In this
example, there are:

- Three instances of a simple app named my-app
- The sample app listens and exposes metrics on port 8080
- The app is assumed to already be running

To prepare for monitoring of the sample app, create a service that selects the
pods that have my-app as the value defined for their app label setting.

The service object also specifies the port on which the metrics are exposed.
The ServiceMonitor has a label selector to select services and their
underlying endpoint objects. For example:

```yaml
kind: Service
apiVersion: v1
metadata:
name: my-app
namespace: my-namespace
labels:
app: my-app
spec:
selector:
app: my-app
ports:
- name: metrics
port: 8080
```

This service object is discovered by a ServiceMonitor, which defines the
selector to match the labels with those defined in the service. The app label
must have the value my-app.

In this example, in order for kube-prometheus-stack to discover this
ServiceMonitor, add a specific label prometheus.kommander.d2iq.io/select:
"true" in the yaml:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
name: my-app-service-monitor
namespace: my-namespace
labels:
prometheus.kommander.d2iq.io/select: "true"
spec:
selector:
matchLabels:
app: my-app
endpoints:
  - port: metrics
```

In this example, you can modify the Prometheus settings to have the operator
collect metrics from the service monitor by appending the following
configuration to the overrides ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: kube-prometheus-stack-overrides
namespace: ${WORKSPACE_NAMESPACE}
data:
values.yaml: |
---
prometheus:
additionalServiceMonitors:
  - name: my-app-service-monitor
selector:
matchLabels:
app: my-app
namespaceSelector:
matchNames:
  - my-namespace
endpoints:
  - port: metrics
interval: 30s
```

Official documentation about using a ServiceMonitor to monitor an app with the
Prometheus-operator on Kubernetes can be found on the GitHub repository.

### Setting Storage Capacity for Prometheus

About this task

Follow the steps on this page to set a specific storage capacity for Prometheus.

Procedure

When defining the requirements of a cluster, you can specify the capacity and
resource requirements of Prometheus by modifying the settings in the overrides
ConfigMap definition, as shown below.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: kube-prometheus-stack-overrides
namespace: ${WORKSPACE_NAMESPACE}
data:
values.yaml: |
---
prometheus:
prometheusSpec:
resources:
limits:
cpu: "4"
memory: "8Gi"
requests:
cpu: "2"
memory: "6Gi"
storageSpec:
volumeClaimTemplate:
spec:
resources:
requests:
storage: "100Gi"
```

## Storage for Applications

NKP ships with a Rook Ceph cluster that is used as the primary blob storage
for various NKP components in the logging stack and backups.

The pages in this section provide an overview of the Rook Ceph application in
NKP, including information about its components, resource requirements,
storage configuration information, and dashboard.

### Rook Ceph in NKP

- Bring Your Own Storage (BYOS) to NKP Clusters on page 686

NKP ships with a Rook Ceph cluster, that is used as the primary blob storage
for various NKP components in the logging stack, backups, cost monitoring, and
NKP Insights.

The pages in this section provide an overview of the Rook Ceph application in
NKP, including information about its components, resource requirements,
storage configuration information, and dashboard.

```yaml
Note: The Ceph instance installed by NKP is intended only for use by Nutanix Kubernetes Platform Insights, the
logging stack, velero, harbor and opencost platform applications. For more information, see the Nutanix
Kubernetes Platform Insights Guide on page 1111.
```

If you have an instance of Ceph that is managed outside of the NKP life cycle,
see Bring Your Own Storage (BYOS) to NKP Clusters on page 686.

```yaml
Note: The Ceph instance installed by NKP is intended only for use by the logging stack, opencost, and velero
platform applications.
```

If you have an instance of Ceph that is managed outside of the NKP life cycle,
see Bring Your Own Storage (BYOS) to NKP Clusters on page 686

If you do not plan on using any of the platform applications such as grafana-
loki, logging stack, and velero for backups and opencost for cost metrics.
Then you do not need Rook Ceph for your installation and you can disable it by
adding the following to your installer config file:

```yaml
apiVersion: config.kommander.mesosphere.io/v1alpha1
kind: Installation
apps:
...
...
grafana-loki:
enabled: false
opencost:
enabled: false
...
rook-ceph:
enabled: false
rook-ceph-cluster:
enabled: false
...
velero:
enabled: false
...
```

You must enable rook-ceph and rook-ceph-cluster if any of the following is true:

- If you enable grafana-loki.
- If you enable opencost and apply configuration overrides to use storage that
  is not backed by Ceph, you do not need to install Ceph.

| velero, | harbor |
| ------- | ------ |

- If you enable velero and apply configuration overrides to use storage that
  is external to your cluster, you do not need to install Ceph. For more
  information, see Usage of Velero with AWS S3 Buckets on page 563.

For more information on Rook Ceph, see `<https://rook.io/>`.

#### Rook Ceph: Configuration

```yaml
Note: The Ceph instance installed by NKP is intended only for use by the logging stack, opencost, and velero
platform applications.
```

If you have an instance of Ceph that is managed outside of the NKP life cycle,
see Bring Your Own Storage (BYOS) to NKP Clusters on page 686.

If you intend to use Ceph in conjunction with NKP Insights, see NKP Insights
Bring Your Own Storage (BYOS) to Insights on page 1120.

Components of a Rook Ceph Cluster

Ceph supports creating clusters in different modes as listed in CephCluster
CRD Rook Ceph Documentation (see
`<https://rook.io/docs/rook/v1.10/CRDs/Cluster/ceph-cluster-crd/>`). NKP,
specifically, is shipped with a PVC Cluster, as
documented in PVC Storage Cluster Rook Ceph Documentation (see
`<https://rook.io/docs/rook/latest/>` CRDs/Cluster/pvc-
cluster/#pvc-storage-only-for-monitors). It is recommended that the PVC mode
be used to keep the deployment and upgrades
simple and agnostic to technicalities with node draining.

Ceph cannot be your CSI Provisioner when installing in PVC mode as Ceph relies
on an existing CSI provisioner to bind the PVCs created by it. It is possible
to use Ceph as your CSI provisioner, but that is outside the scope of this
document. If you have an instance of Ceph that acts as the CSI Provisioner,
then it is possible to reuse it for your NKP Storage needs. See Bring Your Own
Storage (BYOS) to NKP Clusters on page 686 for information on reusing existing
Ceph.

When you create AppDeployments for rook-ceph and rook-ceph-cluster platform
applications, it results in the deployment of various components as listed in
the following diagram

Figure 20: Rook Ceph Cluster Components

Items highlighted in green are user-facing and configurable.

For an in-depth explanation of the inner workings of the components outlined
in the above diagram, see https:// rook.io/docs/rook/latest/Getting-
Started/storage-architecture/ and `<https://docs.ceph.com/en/quincy/>`
architecture/.

For additional details about the data model, see
`<https://github.com/rook/rook/blob/release-1.16/design/ceph/>` data-model.md.

#### Rook Ceph: Resource Requirements

Table 60: Table

CPUs 100m x # of mgr instances (default 2)

250m x # of mon instances (default 3)

250m x # of osd instances (default 4)

100m x # of crashcollector instances (Daemonset that is., # of nodes)

250m x # of rados gateway replicas (default 2)

~2000m CPU

Memory 512Mi x # of mgr instances (default 2)

512Gi x # of mon instances (default 3)

1Gi x # of osd instances (default 4)

500Mi x # of rados gateway replicas (default 2)

~8Gi Memory

Disk 4 x 40Gi PVCs with Block mode for ObjectStorageDaemons (see https://
rook.io/docs/rook/latest/CRDs/ Cluster/ceph-cluster-crd/#storage- selection-
settings).

3 x 10Gi PVCs with Block or FileSystem mode for Mons (see
`<https://rook.io/docs/rook/latest/>` CRDs/Cluster/ceph-cluster-crd/ #mon-
settings).).

190Gi

Nodes 4 x nodes to satisfy the requirement of 4 x 40Gi PVCs with Block mode
for ObjectStorageDaemons (see `<https://rook.io/docs/rook/latest/>`
CRDs/Cluster/ceph-cluster-crd/ #storage-selection-settings).

Each PVC has a toleration and a dynamic affinity.

4 Nodes

Your default StorageClass should support creation of PersistentVolumes created
by Ceph with that satisfy the volumeMode: Block.

#### Rook Ceph: Storage Configuration

For more information on data durability, see
`<https://en.wikipedia.org/wiki/Durability_(database_systems)>`.

| Type | Resources | Total |
| ---- | --------- | ----- |

The default configuration creates a CephCluster that creates 4 x
PersistentVolumeClaims of 40G each, resulting in 160G of raw storage. Erasure
coding ensures durability with k=3 data bits and m=1 parity bits. This gives a
storage efficiency of 75% (refer to the Primer on Replication Strategies
section below for calculation), which means 120G of disk space is available
for consumption by services like grafana-loki, project-grafana-loki, and
velero.

It is possible to override the replication strategy for the logging stack
(grafana-loki) and velero backups. Refer to the default configmap for the
CephObjectStore at `<https://github.com/mesosphere/kommander->`
applications/blob/v2.14.0/services/rook-ceph-
cluster/1.16.2/defaults/cm.yaml#L134-L180 and override the replication
strategy according to your needs by referring to CephObjectStore CRD
documentation (see https:// `<www.rook.io/docs/rook/latest/CRDs/Object- Storage/ceph-object-store-crd/>`).

For more information on configuring storage in Rook Ceph, refer to the
following pages:

- For general information on how to configure Object Storage Daemons (OSDs),
  see `<https://www.rook.io/docs/>` rook/v1.11/Storage-
  Configuration/Advanced/ceph-osd-mgmt/.
- For information on how to set up auto-expansion of OSDs,
  `<https://www.rook.io/docs/rook/v1.11/Storage->` Configuration/Advanced/ceph-
  configuration/?h=expa#auto-expansion-of-osds.

Primer on Replication Strategies

Replication and Erasure Coding are the two primary methods for storing data in
a durable fashion in any distributed system.

Replication

- For a replication factor of N, data has N copies (including the original copy)
- Smallest possible replication factor is 2 (usually this means two storage
  nodes).
- With replication factor of 2, data has 2 copies and this tolerates loss of
  one copy of data.
- Storage efficiency : (1/N) \* 100 percentage. For example,
- If N=2, then efficiency is 50%.
- If N=3, then efficiency is 33% so on.
- Fault Tolerance : N-1 nodes can be lost without loss of data. For example,
- If N=2, then atmost 1 node can be lost without data loss.
- If N=3, then atmost 2 nodes can be lost without data loss and so on.

Erasure Coding

- Slices an object into k data fragments and computes m parity fragments. The
  erasure coding scheme guarantees that data can be recreated using any k
  fragments out of k+m fragments.
- The k + m = n fragments are spread across (>=n) Storage Nodes to offer
  durability.
- Since k out of n fragments (parity or data fragments) are needed for the
  recreation of data, at most m fragments can be lost without loss of data.
- The smallest possible count is k = 2, m = 1 that is., n = k + m = 3. This
  works only if there are at least n = 3 storage nodes.
- Storage efficiency: k/(k+m) \* 100 percentage. For example,
- If k=2, m=1, then efficiency is 67%
- If k=3, m=1, then efficiency is 75% and so on.
- Fault Tolerance: m nodes can be lost without loss of data. For example:
- If k=3, m=1 then atmost 1 out of 4 nodes can be lost without data loss.
- If k=4, m=2 then atmost 2 out of 6 nodes can be lost without data loss, and
  so on.

#### Accessing the Rook Ceph Dashboard

About this task

The Rook Ceph dashboard can be used to view current cluster health and logs.

To access the Rook Ceph dashboard, perform the following steps:

Procedure

1. Go to the applications dashboard
2. Select the Dashboard button.
3. Enter the Username is admin.
4. To retrieve your password, in the command line and using the kubeconfig of
   the Kubernetes cluster you have Rook Ceph deployed to, run the following
   command:

```yaml
Note: Set the NAMESPACE variable according to your environment (kommander on management cluster or
workspace namespace on attached clusters and managed clusters).
kubectl get secret -n ${NAMESPACE} rook-ceph-dashboard-password -ogo-
template='{{ .data.password | base64decode | printf "%s\n" }}'
```

1. Copy the password and paste it into the UI to access the dashboard. After
   successful login, the Rook Ceph Cluster dashboard is displayed.

### Bring Your Own Storage (BYOS) to NKP Clusters

You can use Ceph as the CSI Provisioner in some environments. For environments
where Ceph was installed before installing NKP, you can reuse your existing
Ceph installation to satisfy the storage requirements of NKP Applications.

> **Note: This guide assumes you have a Ceph cluster that is not managed by
> NKP.**

For information on how to configure the Ceph instance installed by NKP for use
by NKP platform applications, see Rook Ceph: Configuration on page 682.

#### Disabling NKP-managed Ceph

About this task

To uninstall a healthy rook-ceph instance on any cluster (applicable for all
infrastructures) you must delete the rook-ceph-cluster followed by rook-ceph
operator. The deletion order is important to ensure that no resources are left
behind.

Procedure

1. Remove rook-ceph-cluster AppDeployment on management cluster.

```bash
# Delete rook-ceph-cluster appdeployment
kubectl delete appdeployment -n <WORKSPACE_NAMESPACE> rook-ceph-cluster
```

1. Wait for the CephCluster to be removed. Run the following command on the
   workload cluster, or management cluster if you are running this against it.

```bash
kubectl wait --for=delete cephclusters --all -n <WORKSPACE_NAMESPACE> --timeout=1200s
--kubeconfig <kubeconfig-of-your-cluster>
```

1. After CephCluster resource is removed, proceed to removal of rook-ceph-
   cluster AppDeployment on management cluster.

```bash
# Delete the operator
kubectl delete appdeployment -n <WORKSPACE_NAMESPACE> rook-ceph
Note: If you have an installation configuration file (which is the case for non-Nutanix infra), to disable rook-
ceph in the installer config to prevent NKP from installing a Ceph Cluster, edit your installation config file:
apiVersion: config.kommander.mesosphere.io/v1alpha1
kind: Installation
apps:
rook-ceph:
enabled: false
rook-ceph-cluster:
enabled: false
...
...
```

The NKP instances of velero and grafana-loki rely on the storage provided by
Ceph. Before installing the Kommander component of NKP, be sure to configure
appropriate Ceph resources for their usage as detailed in the next section.

#### Creating NKP-compatible Ceph Resources

About this task

This section walks you through the creation of CephObjectStore and then a set
of ObjectBucketClaims, which can be consumed by either velero and grafana-
loki.

Typically, Ceph is installed in the rook-ceph namespace, which is the default
namespace if you have followed the Quickstart - Rook Ceph Documentation guide.
For more information, see `<https://www.rook.io/docs/rook/v1.10/>` Getting-
Started/quickstart/#create-a-ceph-cluster.

```yaml
Note: This guide assumes your Ceph instance is installed in the rook-ceph namespace. In subsequent steps,
configure the variable CEPH_NAMESPACE as it applies to your environment.
```

Procedure

1. Create CephObjectStore. There are two ways to install Ceph:

» Using Helm Charts (For more information on Helm Chart, see
`<https://www.rook.io/docs/rook/v1.10/Helm->` Charts/operator-chart/#release).

This section is relevant if you have installed Ceph using helm install or some
other managed Helm resource mechanism.

If you have applied any configuration overrides to your Rook Ceph operator,
ensure it was deployed with currentNamespaceOnly set to false (It is the
default value, so unless you have applied any overrides, it will be false by
default). This ensures that the Ceph Operator in the rook-ceph namespace is
able to monitor and manage resources in other namespaces such as kommander.

> **Note:**

- 1. Ensure the following configuration for rook-ceph Helm Chart is completed.
     See https:// `<www.rook.io/docs/rook/v1.10/Helm-Charts/operator- chart/#configuration>`.

```bash
# This is the default value, so need to overwrite if you are just
using the defaults as-is
currentNamespaceOnly: false
```

1. You must enable the following configuration overrides for the rook-ceph-
   cluster. See

`<<https://www.rook.io/docs/rook/v1.10/Helm-Charts/ceph-cluster-chart/#ceph->`
object-> stores.

```bash
cephObjectStores:
- name: nkp-object-store
# see https://github.com/rook/rook/blob/master/Documentation/
CRDs/Object-Storage/ceph-object-store-crd.md#object-store-settings
for available configuration
spec:
metadataPool:
# The failure domain: osd/host/(region or zone if available)
- technically also any type in the crush map
failureDomain: osd
# Must use replicated pool ONLY. Erasure coding is not
supported.
replicated:
size: 3
dataPool:
# The failure domain: osd/host/(region or zone if available) (2)
- technically also any type in the crush map
failureDomain: osd
# Data pool can use either replication OR erasure coding.
Consider the following example scenarios:
# Erasure Coding is used here with 3 data chunks and 1 parity
chunks which assumes 4 OSDs exist.
# Configure this according to your CephCluster specification.
erasureCoded:
dataChunks: 3
codingChunks: 1
preservePoolsOnDelete: false
gateway:
port: 80
instances: 2
priorityClassName: system-cluster-critical
resources:
limits:
cpu: "750m"
memory: "1Gi"
requests:
cpu: "250m"
memory: "500Mi"
healthCheck:
bucket:
interval: 60s
storageClass:
enabled: true
name: nkp-object-store
reclaimPolicy: Delete
```

» By directly applying Kubernetes manifests (For more information, see Bring
Your Own Storage (BYOS) to NKP Clusters on page 686:

> **Note:**

Managing resources directly

- 1. Set a variable to refer to the namespace the AppDeployments are created in.

```yaml
Note: This is the kommander namespace on the management cluster or Workspace
namespace on all other clusters.
export CEPH_NAMESPACE=rook-ceph
export NAMESPACE=kommander
```

1. Create CephObjectStore in the same namespace as the CephCluster:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: ceph.rook.io/v1
kind: CephObjectStore
metadata:
name: nkp-object-store
namespace: ${CEPH_NAMESPACE}
spec:
metadataPool:
# The failure domain: osd/host/(region or zone if available) -
technically, any type in the crush map
failureDomain: osd
# Must use replicated pool ONLY. Erasure coding is not supported.
replicated:
size: 3
dataPool:
# The failure domain: osd/host/(region or zone if available) - (2)
technically, any type in the crush map
failureDomain: osd
# Data pool can use either replication OR erasure coding. (2)
Consider the following example scenarios:
# Erasure Coding is used here with 3 data chunks and 1 parity (2)
chunks which assumes 4 OSDs exist.
# Configure this according to your CephCluster specification. (2)
erasureCoded:
dataChunks: 3
codingChunks: 1
preservePoolsOnDelete: false
gateway:
port: 80
instances: 2
priorityClassName: system-cluster-critical
resources:
limits:
cpu: "750m"
memory: "1Gi"
requests:
cpu: "250m"
memory: "500Mi"
healthCheck:
bucket:
interval: 60s
EOF
```

1. Wait for the CephObjectStore to be Connected:

```bash
$ kubectl get cephobjectstore -A
NAMESPACE NAME PHASE
rook-ceph nkp-object-store Progressing
...
...
rook-ceph nkp-object-store Connected
```

1. Create a StorageClass to consume the object storage:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
name: nkp-object-store
parameters:
objectStoreName: nkp-object-store
objectStoreNamespace: ${CEPH_NAMESPACE}
provisioner: ${CEPH_NAMESPACE}.ceph.rook.io/bucket
reclaimPolicy: Delete
volumeBindingMode: Immediate
EOF
```

1. Create ObjectBucketClaims.

After connecting the Object Store, create the ObjectBucketClaim in the same
namespace as velero and grafana-loki.

This results in the creation of ObjectBucket , that then creates Secrets that
are consumed by velero and grafana-loki.

a. For grafana-loki.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
name: nkp-loki
namespace: ${NAMESPACE}
spec:
additionalConfig:
maxSize: 80G
bucketName: nkp-loki
storageClassName: nkp-object-store
EOF
```

b. For velero.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
name: nkp-velero
namespace: ${NAMESPACE}
spec:
additionalConfig:
maxSize: 10G
bucketName: nkp-velero
storageClassName: nkp-object-store
EOF
```

1. Wait for the ObjectBuckets to be Bound by executing the following command:

```bash
kubectl get objectbucketclaim -n${NAMESPACE} -ocustom-
columns='NAME:.metadata.name,PHASE:.status.phase'
```

which should display something similar to:

```bash
NAME PHASE
nkp-loki Bound
nkp-velero Bound
```

#### Configuring Loki to Use S3 Compatible Storage

About this task

If you want to use your own storage in NKP that is S3 compatible, create a
secret that contains your AWS secret credentials.

Procedure

Run the following command.

```yaml
apiVersion: v1
data:
AWS_ACCESS_KEY_ID: base64EncodedValue
AWS_SECRET_ACCESS_KEY: base64EncodedValue
kind: Secret
metadata:
name: nkp-loki #If you want to configure a custom name here, also use it in the step
below
namespace: kommander
```

#### Overriding velero and grafana-loki Configuration

About this task

After all the buckets are in the Bound state, NKP applications are now ready
to be installed with the following configuration overrides populated in the
installer config.

Procedure

Run the following command.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: config.kommander.mesosphere.io/v1alpha1
kind: Installation
apps:
grafana-loki-v3:
enabled: true
values: |
loki:
structuredConfig:
storage_config:
aws:
s3: "http://rook-ceph-rgw-nkp-object-store.${CEPH_NAMESPACE}.svc:80/nkp-
loki"
ingester:
extraEnvFrom:
- secretRef:
name: nkp-loki # Optional: This is the default value
querier:
extraEnvFrom:
- secretRef:
name: nkp-loki # Optional: This is the default value
queryFrontend:
extraEnvFrom:
- secretRef:
name: nkp-loki # Optional: This is the default value
compactor:
extraEnvFrom:
- secretRef:
name: nkp-loki # Optional: This is the default value
ruler:
extraEnvFrom:
- secretRef:
name: nkp-loki # Optional: This is the default value
distributor:
extraEnvFrom:
- secretRef:
name: nkp-loki # Optional: This is the default value
velero:
enabled: true
values: |
configuration:
backupStorageLocation:
- bucket: nkp-velero
provider: "aws"
config:
region: nkp-object-store
s3Url: http://rook-ceph-rgw-nkp-object-store.${CEPH_NAMESPACE}.svc:80/
credentials:
# This secret is owned by the ObjectBucketClaim. A ConfigMap and a Secret with
the same name as a bucket are created.
extraSecretRef: nkp-velero
EOF
```

This installer config can be merged with your installer config with any other
relevant configuration before installing NKP.

#### Overriding project-grafana-loki Configuration

About this task

When installing project level grafana loki, its configuration needs to be
overridden similarly to workspace level grafana loki, so that the project logs
can be persisted in Ceph storage.

Procedure

1. The following overrides need to be applied to project-grafana-loki-v3:

```bash
loki:
structuredConfig:
storage_config:
aws:
s3: "http://rook-ceph-rgw-nkp-object-store.${CEPH_NAMESPACE}.svc:80/nkp-loki"
```

These overrides can be applied from the UI directly while substituting the
${CEPH_NAMESPACE} appropriately. 2. If you are using CLI, follow these steps:
Set NAMESPACE to project namespace and CEPH_NAMESPACE to Ceph install
namespace.

> **Note: Run these commands if you are using CLI.**

```bash
export CEPH_NAMESPACE=rook-ceph
export NAMESPACE=my-project
```

1. Create a ConfigMap to apply the configuration overrides.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
data:
values.yaml: |
loki:
structuredConfig:
storage_config:
aws:
s3: "http://rook-ceph-rgw-nkp-object-store.${CEPH_NAMESPACE}.svc:80/proj-
loki-${NAMESPACE}"
kind: ConfigMap
metadata:
name: project-grafana-loki-v3-ceph
namespace: ${NAMESPACE}
EOF
```

1. Create the AppDeployment with a reference to the above ConfigMap.

> **Note: The clusterSelector can be adjusted according to your needs.**

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps.kommander.d2iq.io/v1alpha3
kind: AppDeployment
metadata:
name: project-grafana-loki-v3
namespace: ${NAMESPACE}
spec:
appRef:
kind: ClusterApp
name: project-grafana-loki-v3-3.6.7
clusterSelector: {}
configOverrides:
name: project-grafana-loki-v3-ceph
EOF
```

The project level Grafana Loki creates an ObjectBucketClaim and assumes that
the Ceph operator is monitoring the project namespace, so there is no need to
create ObjectBucketClaim manually.

## Pulse Telemetry in NKP

Pulse telemetry collects data to improve and optimize Nutanix Kubernetes
Platform (NKP). When you enable Pulse, you share data about your application
usage with Nutanix. The information collected helps Nutanix understand how you
are using NKP to help us improve the product.

For more information on the data that Pulse gathers from NKP see NKP Data
share with Nutanix on page 695.

Nutanix processes data that Pulse sends in a manner consistent with your
agreement with Nutanix and, where applicable, by the Nutanix Privacy
Statement. For more information, see Nutanix Privacy Statement.

### Configuring Pulse

About this task

#### Disabling Pulse

Procedure

#### Enabling Pulse

#### Disabling Pulse (2)

#### Enabling Pulse (2)

About this task

> **Note:**

- The Pulse tab is visible only to the global admin user.
- You see the Pulse tab only if you are using the following licenses: Starter,
  Pro and Ultimate.

Procedure

1. Log in to NKP UI dashboard.
2. In the workspace header drop-down, select Global.
3. In the sidebar menu, select Settings > Pulse. Screen to enable Pulse is
   displayed.
4. Select Enable. A message confirms that the Pulse enablement is in progress.
   The Pulse Status will be displayed after a few minutes.

> **Note: If the Pulse enablement fails, disable and re-enable the Pulse.**

#### Disabling Pulse (3)

About this task

To disable Pulse in NKP using UI.

Procedure

1. Log in to NKPUI dashboard.
2. In the workspace header drop-down, select Global.
3. In the sidebar menu, select Settings > Pulse.
4. Click Disable Pulse A message is displayed confirming that the Pulse
   disablement is in progress. Pulse is disabled after a few minutes.

### NKP Data share with Nutanix

For more information, see Nutanix Privacy Statement. This topic lists the
entities and the data shared from NKP with Nutanix through Pulse telemetry.

Table 61:

NKP Information Version of NKP, License type (example NKP Starter, NKP Pro,
NKP Ultimate)

NKP Kubernetes Cluster Information Kubernetes version of the cluster, type of
NKP cluster (example Management, Managed or Attached), infrastructure provider
(example NKP, EKS or AKS)

Nodepool Information Number of nodes (ready, available, etc)

Operating System on the node

Number of CPU's on the node

Memory on the node

Node Information

Containerd, Kubelet and Kube-proxy version running on this node

NKP Applications Name and version of application enabled from NKP application
catalog

CSI Drivers CSI driver version, name, and the kinds of volumes the CSI driver
supports

GPU NVIDIA GPU driver version, memory and capacity

| Category | Description |
| -------- | ----------- |
