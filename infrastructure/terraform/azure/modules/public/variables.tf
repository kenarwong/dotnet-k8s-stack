# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "resource_group_name" {
  description = "The name of the resource group for the public IP and DNS."
  type        = string
}

variable "location" {
  description = "The location of the public IP and DNS."
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

variable "environment" {
  description = "The environment of the public IP and DNS."
  type        = string
}
