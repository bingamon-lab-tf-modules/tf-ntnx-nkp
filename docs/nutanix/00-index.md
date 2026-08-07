# Nutanix Kubernetes Platform (NKP) v2.18 Documentation Index

This directory contains the complete cleaned documentation for Nutanix
Kubernetes Platform (NKP) v2.18 and NKP Insights, converted from PDF to
structured, AI-agent readable Markdown.

## Documentation Modules

1. **[01-release-notes.md](./01-release-notes.md)**
   - NKP v2.18.0 Release Notes, new features, component versions, Prism
     Central & AOS compatibility matrix, ports, and NKP Insights Release Notes.
2. **[02-overview.md](./02-overview.md)**
   - NKP Platform Overview, architecture, supported infrastructure operating
     systems, control plane, and node components.
3. **[03-downloading-and-getting-started.md](./03-downloading-and-getting-
   started.md)**
   - Downloading NKP binaries, core concepts & terms, cluster types, license
     tiers, kubeconfig management, and storage setup.
4. **[04-requirements.md](./04-requirements.md)**
   - General NKP cluster requirements, Konvoy component requirements, and
     Kommander resource requirements.
5. **[05-image-builder.md](./05-image-builder.md)**
   - Nutanix Image Builder (NIB), custom OS image creation for Nutanix, AWS,
     Azure, GCP, vSphere, pre-provisioned hosts, and RHEL subscription
     management.
6. **[06-basic-installations.md](./06-basic-installations.md)**
   - Quickstart and basic cluster installation procedures across all
     providers: Nutanix NCI, Pre-provisioned, AWS, EKS, vSphere, Azure, AKS, and
     GCP.
7. **[07-cluster-operations.md](./07-cluster-operations.md)**
   - Comprehensive cluster management: Operations, applications, workspaces,
     projects, cluster lifecycle, backup & restore (Velero), logging (Loki),
     security (Gatekeeper/Kyverno), networking (Calico/Cilium), GPU management,
     monitoring (Prometheus/Grafana), storage, and Pulse telemetry.
8. **[08-custom-installation-and-tools.md](./08-custom-installation-and-
   tools.md)**
   - Advanced custom installations: Universal configurations, air-gapped
     deployments, custom network topologies, and provider-specific custom
     installs
     for Nutanix, AWS, EKS, vSphere, Azure, AKS, and GCP.
9. **[09-kommander-and-konvoy-configurations.md](./09-kommander-and-konvoy-
   configurations.md)**
   - Advanced component configurations: FIPS 140-3 compliance, registry mirror
     tools, air-gapped registry seeding, control plane tuning, Pod Disruption
     Budgets (PDB), and GPU setup for Konvoy.
10. **[10-upgrade-guide.md](./10-upgrade-guide.md)** - Upgrading NKP: Upgrade
    planning, step-by-step management cluster and
    workload cluster upgrades, GitOps-managed clusters, verification, and
    upgrade
    troubleshooting.
11. **[11-troubleshooting.md](./11-troubleshooting.md)** - Troubleshooting
    guide: Diagnostic data gathering (`nkp get
diagnostics`), discovery commands, application troubleshooting, object
    locations, and Rook Ceph troubleshooting.
12. **[12-ai-navigator.md](./12-ai-navigator.md)** - AI Navigator
    architecture, installation, disabling, usage guidelines,
    NKP Model Context Protocol (MCP) server overview, and Azure OpenAI
    integration.
13. **[13-nkp-insights-guide.md](./13-nkp-insights-guide.md)** - NKP Insights
    setup, architecture, uninstallation, Bring Your Own Storage
    (BYOS) configuration, and alert rules for customer workloads.
