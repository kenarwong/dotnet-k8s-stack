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

variable "node_count" {
  description = "The number of nodes to provision for the AKS cluster."
  type        = number
  default     = 2
}

variable "client_id" {
  description = "The service principal client id for AKS operations."
  type        = string
}

variable "client_secret" {
  description = "The service principal client secret for AKS operations."
  type        = string
}

variable "environment" {
  description = "The environment of the deployment."
  type        = string
}
