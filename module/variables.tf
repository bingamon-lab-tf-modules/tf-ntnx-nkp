##################################################
# Cluster Configuration
##################################################

variable "cluster_name" {
  type        = string
  description = "Name of the NKP management cluster"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cluster_name))
    error_message = "Cluster name must contain only lowercase alphanumeric characters and hyphens."
  }
}

variable "profile" {
  type        = string
  description = "Environment profile ('small' for lab 3-worker footprint, 'full' for 4-worker Ultimate footprint)"
  default     = "small"

  validation {
    condition     = contains(["small", "full"], var.profile)
    error_message = "Profile must be either 'small' or 'full'."
  }
}

##################################################
# Nutanix Infrastructure Prerequisites
##################################################

variable "prism_central_endpoint" {
  type        = string
  description = "Prism Central FQDN or IP address"
}

variable "control_plane_vip" {
  type        = string
  description = "Static VIP for Kubernetes control plane"

  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.control_plane_vip))
    error_message = "Control plane VIP must be a valid IPv4 address."
  }
}

variable "prism_element_cluster" {
  type        = string
  description = "Name of the target Prism Element cluster"
}

variable "control_plane_subnet" {
  type        = string
  description = "Nutanix subnet name/UUID for control plane nodes"
}

variable "worker_subnet" {
  type        = string
  description = "Nutanix subnet name/UUID for worker nodes"
}

variable "csi_storage_container" {
  type        = string
  description = "Nutanix Storage Container name for CSI persistent volumes"
}

variable "load_balancer_ip_range" {
  type        = string
  description = "MetalLB IP range (e.g. 192.168.82.20-192.168.82.39)"

  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}-(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.load_balancer_ip_range))
    error_message = "Load balancer IP range must be in start_ip-end_ip format."
  }
}

variable "control_plane_vm_image" {
  type        = string
  description = "Nutanix OS VM Image name for control plane nodes"
}

variable "worker_vm_image" {
  type        = string
  description = "Nutanix OS VM Image name for worker nodes"
}

##################################################
# Network Configuration
##################################################

variable "pod_cidr" {
  type        = string
  description = "Kubernetes Pod Network CIDR (must match 172.20.0.0/16)"
  default     = "172.20.0.0/16"

  validation {
    condition     = can(regex("^172\\.20\\.0\\.0/16$", var.pod_cidr))
    error_message = "Pod CIDR must be 172.20.0.0/16 to avoid collision with lab network."
  }
}

variable "service_cidr" {
  type        = string
  description = "Kubernetes Service Network CIDR"
  default     = "10.96.0.0/12"

  validation {
    condition     = can(cidrnetmask(var.service_cidr))
    error_message = "Service CIDR must be a valid IPv4 CIDR prefix."
  }
}

##################################################
# Deployment & Credentials
##################################################

variable "bundle_paths" {
  type        = list(string)
  description = "List of local tarball bundle paths for air-gapped deployment"
  default     = []
}

# REQUIRED, deliberately no default.
#
# `nkp create cluster` builds its KIND bootstrap cluster from
# `docker.io/mesosphere/konvoy-bootstrap:<version>` unless told otherwise. This module
# hardcodes --airgapped=true, so that pull cannot succeed — KIND fails before any Nutanix
# resource is touched, with an error that points at Docker Hub rather than at the air gap.
#
# The flag accepts a local path, and the tarball ships in the air-gapped bundle at
# `nkp-<version>/konvoy-bootstrap-image-<version>.tar`. Making this required forces the
# caller to supply it rather than discovering the failure during a 45-minute bootstrap.
variable "bootstrap_cluster_image" {
  type        = string
  description = "Path on the bastion to konvoy-bootstrap-image-<version>.tar. Required: the module is air-gapped, so the default Docker Hub pull cannot work."

  validation {
    condition     = length(trimspace(var.bootstrap_cluster_image)) > 0
    error_message = "bootstrap_cluster_image must be a non-empty path to the konvoy-bootstrap image tarball on the bastion."
  }
}

variable "ca_certificates" {
  type        = list(string)
  description = "List of PEM-encoded CA certificates to inject into the Bastion host trust store"
  default     = []
}

variable "bastion_ssh_keys" {
  type        = list(string)
  description = "List of SSH public keys for Bastion host access"
  default     = []
}

variable "nutanix_username" {
  type        = string
  description = "Nutanix Prism Central Username"
  sensitive   = true
  default     = null
}

variable "nutanix_password" {
  type        = string
  description = "Nutanix Prism Central Password"
  sensitive   = true
  default     = null
}
