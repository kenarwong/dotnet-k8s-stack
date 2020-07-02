# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "resource_group_name" {
  description = "The name of the resource group for the Azure Container Registry."
  type        = string
}

variable "acr_name" {
  description = "The name of the Azure Container Registry."
  type        = string
}

variable "sku" {
  description = "The SKU for the Azure Container Registry ."
  default     = "Basic"
  type        = string
}

variable "service_principal" {
  description = "The service principal to perform ACR operations."
  type        = string
}

variable "environment" {
  description = "The environment of the public IP and DNS."
  type        = string
}
