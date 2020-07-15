# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "resource_group_name" {
  description = "The name of the resource group for the deployment."
  type        = string
}

variable "location" {
  description = "The location of the deployment."
  type        = string
}

variable "cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
}

variable "domain_name" {
  description = "The domain name to be used for AKS ingress."
  type        = string
}

variable "acr_name" {
  description = "The name of the ACR."
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

variable "acr_sp_object_id" {
  description = "The service principal object id for ACR role assignment."
  type        = string
}

variable "cert_manager_sp_object_id" {
  description = "The service principal object id to be used by the certificate manager."
  type        = string
}

variable "vnet_sp_object_id" {
  description = "The service principal object id that has access to the virtual network."
  type        = string
}

variable "environment" {
  description = "The environment of the deployment."
  type        = string
}
