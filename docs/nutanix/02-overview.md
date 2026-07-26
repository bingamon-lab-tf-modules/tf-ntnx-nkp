# Nutanix Kubernetes Platform Overview

NUTANIX KUBERNETES® PLATFORM OVERVIEW

As the leading independent Kubernetes® Management Platform in production, the
Nutanix Kubernetes® Platform (NKP)
provides a holistic approach and a complete set of enterprise-grade
technologies, services, training, and support to
build and run applications in production at scale. Built around the open-
source Cluster API, the new version of NKP
becomes the single, centralized point of control for an organization's
application infrastructure, empowering
organizations to more easily deploy, manage, and scale Kubernetes workloads in
the production environments.

Table 1: Features and Benefits

Container Orchestration Leverage an industry standard distribution of open-
source Kubernetes for cluster and container management.

Application Management and Deployment Deploy applications and services within
Kubernetes clusters with Helm.

Observability Gain deep insight into your Kubernetes clusters and applications
with open source metrics leveraging Prometheus, and Grafana.

Cluster API Automate cluster lifecycle management using CAPI Concepts and
Terms on page 21 to simplify the provisioning, upgrading, and operating many
Kubernetes clusters across a wide range of distributions and virtual and
physical environments.

Cluster Autoscaling Save operational costs by automatically scaling down
(Scaling Node Pools Using the Cluster Autoscaler on page 821) capacity when
it's not needed and adding capability when there is greater demand, with CAPI
enabled autoscaling groups.

Logging Collect and analyze logs and metrics (Logging on page 590) to ensure
optimal performance and troubleshooting with Grafana Dashboards on page 666,
Loki, and Fluent Bit on page 613.

Cloud-Native Scale Testing Extensive integration and workload testing at
massive scale with a wide range of workloads to ensure real-world
preparedness.

| Features | Benefits |
| -------- | -------- |

Networking and Routing Easily automate and expose application endpoints
(Networking on page 632) with Cilium, Calico, Traefik-Forward-Authentication
in NKP (TFA) on page 626, and CoreDNS.

Fine-Grained Cluster Upgrades reduce operational overhead with non-disruptive
patching or parallel worker node upgrades. See (Upgrade Nutanix Kubernetes
Platform on page 1042).

Backup and Recovery Ensure business continuity and disaster recovery (Backup
and Restore on page 555) with Velero.

Declarative Automated Installer With Day 2 Platform Services

Accelerate time-to-production on any infrastructure (Basic Installations by
Infrastructure on page 72) with consistency and reliability with the required
Platform Applications on page 350 needed for Cluster Operations Management on
page 284.

Operate in AWS Air-gapped Installation Leverage declarative APIs to optimize
cluster resources for cost, resilience, and performance.

End-to-End Support Enterprise-grade support and services for both Kubernetes
and its supported platform applications.

## Architecture

Kubernetes® is a registered trademark of The Linux Foundation in the United
States and other countries and is used according to a license from The Linux
Foundation.

Components of the Kubernetes Control Plane

The native Kubernetes cluster consists of components in the cluster's control
plane and worker nodes that run containers and maintain the runtime
environment.

NKP supplements the native Kubernetes cluster by including a pre-defined and
pre-configured set of applications. The pre-defined set of applications
critical for managing a Kubernetes cluster in a production environment are
identified as the NKP platform applications.

To view the full set of NKP platform services, see Platform Applications on
page 350.

| Features | Benefits |
| -------- | -------- |

Figure 1: NKP Architecture

Related Information

For information on related topics or procedures, see the Kubernetes
documentation.

## Supported Infrastructure Operating Systems

This topic contains all the operating systems (OS) that are currently tested
and supported for use with Nutanix Kubernetes Platform(NKP).

> **Note:**

- Arm-based systems are not supported. Only x86/amd64 architectures are
  supported.
- Ubuntu 22.04 GPU deployments in air#gapped environments are not supported
  when using NVIDIA Installer Bundles (NIB). However, GPU deployments are
  supported in air#gapped environments when using precompiled NVIDIA drivers.

Table 2: Nutanix

Rocky Linux 9.7

5.14.0-611.55.1.el9_7.x86_64 Yes - Yes - - - - Yes

Ubuntu 22.04

5.15.0-185- generic

Yes - Yes - Yes Yes - Yes

- Operating System; Kernel; Default Config; FIPS; Air- gapped; FIPS Air-
  gapped; GPU; GPU Air- gapped; vGPU; Nutanix Image Builder

| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

Ubuntu 24.04

6.8.0-107- generic

Yes - Yes - Yes Yes - Yes

RHEL 8.10 8.10 4.18.0-553.el8_10.x86_64

Yes Yes Yes Yes Yes Yes Yes Yes

RHEL 9.6 9.6 5.14.0-570.39.1.el9_6.x86_64

Yes Yes Yes Yes Yes Yes Yes Yes

Table 3: Amazon Web Services (AWS)

RHEL 8.10 4.18.0-553.120.1.el8_10.x86_64 Yes Yes Yes Yes Yes Yes Yes

RHEL 9.6 5.14.0-570.106.1.el9_6.x86_64 Yes Yes Yes Yes Yes Yes Yes

Ubuntu 22.04

6.8.0-1055-aws Yes - Yes - Yes - Yes

Ubuntu 24.04

6.17.0-1017-aws Yes - Yes - Yes - Yes

Oracle Linux 8.9

5.15.0-200.131.27.el8uek.x86_64 Yes Yes Yes Yes - - Yes

Rocky Linux 9.7

5.14.0-611.5.1.el9_7.x86_64 Yes - Yes - - - Yes

Flatcar 4081.3.8 (LTS 2022)

6.6.141-flatcar Yes - - - - - Yes

Table 4: Microsoft Azure

RHEL 9.6 5.14.0-570.58.1.el9_6.x86_64 Yes Yes - - - - Yes

Ubuntu 22.04

6.8.0-1052- azure

Yes - - - - - Yes

Ubuntu 24.04

6.17.0-1015- azure

Yes - - - - - Yes

Rocky Linux 9.7 (Rocky 9)

5.14.0-570.17.1.el9_6.x86_64 Yes - - - - - Yes

- Operating System; Kernel; Default Config; FIPS; Air- gapped; FIPS Air-
  gapped; GPU; GPU Air- gapped; vGPU; Nutanix Image Builder

| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

- Operating System; Kernel; Default Config; FIPS; Air- gapped; FIPS Air-
  gapped; GPU Support; GPU Air- gapped; Nutanix Image Builder

| --- | --- | --- | --- | --- | --- | --- | --- | --- |

- Operating System; Kernel; Default Config; FIPS; Air- gapped; FIPS Air-
  gapped; GPU Support; GPU Air- gapped; Nutanix Image Builder

| --- | --- | --- | --- | --- | --- | --- | --- | --- |

Table 5: Google Cloud Platform (GCP)

Ubuntu 22.04

6.8.0-1020-gcp Yes - - - - - Yes

Ubuntu 24.04

6.14.0-1016-gcp Yes - - - - - Yes

Table 6: Pre-provisioned

RHEL 8.10 4.18.0-553.81.1.el8_10.x86_64 Yes Yes Yes Yes Yes Yes Yes

RHEL 9.6 5.14.0-570.58.1.el9_6.x86_64 Yes Yes Yes Yes Yes Yes Yes

Flatcar 4081.3.8

6.6.141-flatcar Yes - - - - - Yes

Ubuntu 22.04

6.8.0-1055 Yes - Yes - Yes - Yes

Ubuntu 24.04

6.17.0-1015 Yes - Yes - Yes - Yes

Oracle Linux 8.9

5.15.0-200.131.27.el8uek.x86_64 Yes Yes Yes Yes - - Yes

Rocky Linux 9.7

5.14.0-611.5.1.el9_7.x86_64 Yes - Yes - - - Yes

Table 7: Pre-provisioned on Azure

RHEL 8.10 4.18.0-553.81.1.el8_10.x86_64 Yes Yes Yes Yes - - -

RHEL 9.6 Yes Yes Yes Yes - - -

Table 8: vSphere

RHEL 8.10 4.18.0-553.el8_10.x86_64 Yes Yes Yes Yes - - Yes

- Operating System; Kernel; Default Config; FIPS; Air- gapped; FIPS Air-
  gapped; GPU Support; GPU Air- gapped; Nutanix Image Builder

| --- | --- | --- | --- | --- | --- | --- | --- | --- |

- Operating System; Kernel; Default Config; FIPS; Air- gapped; FIPS Air-
  gapped; GPU Support; GPU Air- gapped; Nutanix Image Builder

| --- | --- | --- | --- | --- | --- | --- | --- | --- |

- Operating System; Kernel; Default Config; FIPS; Air- gapped; FIPS Air-
  gapped; GPU Support; GPU Air- gapped; Nutanix Image Builder

| --- | --- | --- | --- | --- | --- | --- | --- | --- |

- Operating System; Kernel; Default Config; FIPS; Air- gapped; FIPS Air-
  gapped; GPU Support; GPU Air- gapped; Nutanix Image Builder

| --- | --- | --- | --- | --- | --- | --- | --- | --- |

RHEL 9.6 5.14.0-570.12.1.el9_6.x86_64 Yes Yes Yes Yes - - Yes

Ubuntu 22.04

5.15.0-170- generic

Yes - Yes - - - Yes

Ubuntu 24.04

6.8.0-100- generic

Yes - Yes - - - Yes

Rocky Linux 9.7

5.14.0-611.5.1.el9_7.x86_64 Yes - Yes - - - Yes

Flatcar 4081.3.8 (LTS 2022)

6.6.106-flatcar Yes - - - - - Yes

Oracle Linux 9.4

5.15.0-205.149.5.1.el9uek.x86_64 Yes - Yes - - - Yes

Table 9: Amazon Elastic Kubernetes (EKS)

Amazon Linux 2

Amazon Linux 2023.11.20260526

Yes - - - - - -

Table 10: Azure Kubernetes Service (AKS)

Ubuntu 24.04 LTS

6.8.0-1054- azure

Yes - - - - - -

- Operating System; Kernel; Default Config; FIPS; Air- gapped; FIPS Air-
  gapped; GPU Support; GPU Air- gapped; Nutanix Image Builder

| --- | --- | --- | --- | --- | --- | --- | --- | --- |

- Operating System; Kernel; Default Config; FIPS; Air- gapped; FIPS Air-
  gapped; GPU Support; GPU Air- gapped; Konvoy Image Builder

| --- | --- | --- | --- | --- | --- | --- | --- | --- |

- Operating System; Kernel; Default Config; FIPS; Air- gapped; FIPS Air-
  gapped; GPU Support; GPU Air- gapped; Konvoy Image Builder

| --- | --- | --- | --- | --- | --- | --- | --- | --- |
