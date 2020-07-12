# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "resource_group_name" {
  description = "The name of the resource group for network resources."
  type        = string
}

variable "location" {
  description = "The location of for network resources."
  type        = string
}

variable "cluster_name" {
  description = "The name of the AKS cluster that will ingress from the public domain."
  type        = string
}

variable "domain_name" {
  description = "The domain name for the AKS cluster."
  type        = string
}

variable "cert_manager_sp_object_id" {
  description = "The service principal object ID to be used by the cert manager."
  type        = string
}

variable "vnet_sp_object_id" {
  description = "The service principal object ID that has access to the virtual network."
  type        = string
}

variable "environment" {
  description = "The environment for network resources."
  type        = string
}
