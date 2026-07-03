variable "project_id" { type = string }
variable "folder_id" { type = string }
variable "billing_account_id" { type = string }
variable "host_project_id" { type = string }
variable "network_id" { type = string }
variable "subnetwork_id" { type = string }
variable "region" { type = string }
variable "cluster_name" { type = string }
variable "master_ipv4_cidr" { type = string }
variable "pods_range_name" { type = string }
variable "services_range_name" { type = string }
variable "machine_type" {
  type    = string
  default = "e2-standard-4"
}
variable "min_node_count" {
  type    = number
  default = 1
}
variable "max_node_count" {
  type    = number
  default = 5
}
variable "labels" {
  type    = map(string)
  default = {}
}
