variable "project_id" { type = string }
variable "folder_id" { type = string }
variable "billing_account_id" { type = string }
variable "host_project_id" { type = string }
variable "network_id" { type = string }
variable "region" { type = string }
variable "instance_name" { type = string }
variable "database_version" {
  type    = string
  default = "POSTGRES_16"
}
variable "tier" {
  type    = string
  default = "db-custom-2-7680"
}
variable "private_service_range_prefix_length" {
  type    = number
  default = 20
}
variable "labels" {
  type    = map(string)
  default = {}
}
