variable "resource_group_name" {}
variable "location" {}

variable "cluster_name" {
  default = "k-cluster"
}

variable "node_count" {
  default = 2
}

variable "client_id" {}
variable "client_secret" {}

variable "environment" {}
