# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "resource_group_name" {
  description = "The name of the resource group for the AKS cluster."
  type        = string
}

variable "location" {
  description = "The location of the AKS cluster."
  type        = string
}

variable "cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
}

variable "node_count" {
  description = "The number of nodes to provision for the AKS cluster."
  type        = number
  default     = 2
}

variable "aks_sp_client_id" {
  description = "The service principal client id for AKS operations."
  type        = string
}

variable "aks_sp_client_secret" {
  description = "The service principal client secret for AKS operations."
  type        = string
}

variable "vnet_sp_object_id" {
  description = "The service principal object ID that has access to the virtual network."
  type        = string
}

variable "environment" {
  description = "The environment of the AKS cluster."
  type        = string
}
