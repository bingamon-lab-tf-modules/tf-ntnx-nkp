##################################################
# NKP Cluster Variables
##################################################

variable "clusters" {
  description = "Map of NKP clusters to create. Each cluster supports Nutanix Kubernetes Platform configurations."
  type = map(object({
    name               = string
    description        = optional(string, "")
    kubernetes_version = string
    control_plane = object({
      num_instances              = number
      cpu                        = number
      memory_mib                 = number
      disk_gib                   = number
      network_uuid               = string
      prism_element_cluster_uuid = string
    })
  }))
  default = {}
}

##################################################
# NKP Node Pool Variables
##################################################

variable "node_pools" {
  description = "Map of NKP node pools to create. Each node pool is associated with a cluster."
  type = map(object({
    name                       = string
    cluster_key                = string
    num_instances              = number
    cpu                        = number
    memory_mib                 = number
    disk_gib                   = number
    network_uuid               = string
    prism_element_cluster_uuid = string
    labels                     = optional(map(string), {})
  }))
  default = {}
}

##################################################
# NKP Registry Variables
##################################################

variable "registries" {
  description = "Map of NKP container registries to configure. Registries allow NKP clusters to pull images from private repositories."
  type = map(object({
    name     = string
    url      = string
    port     = optional(number, 443)
    username = optional(string, "")
    password = optional(string, "")
    cert     = optional(string, "")
  }))
  default   = {}
  sensitive = true
}
