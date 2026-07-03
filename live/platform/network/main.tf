# provider "google" {
#   impersonate_service_account = "terraform-network@wozware-terraform-automation.iam.gserviceaccount.com"
# }
# 
# data "terraform_remote_state" "foundation" {
#   backend = "remote"
#   config = {
#     organization = "wozware"
#     workspaces   = { name = "gcp-platform-root" }
#   }
# }
# 
# module "network" {
#   for_each = {
#     dev = {
#       subnets = {
#         dev-ca-central1 = {
#           region           = "northamerica-northeast1", ip_cidr_range = "10.10.0.0/20"
#           secondary_ranges = { pods = "10.100.0.0/16", services = "10.110.0.0/20" }
#         }
#       }
#     }
#     test = {
#       subnets = {
#         test-ca-central1 = {
#           region           = "northamerica-northeast1", ip_cidr_range = "10.20.0.0/20"
#           secondary_ranges = { pods = "10.120.0.0/16", services = "10.130.0.0/20" }
#         }
#       }
#     }
#     prod = {
#       subnets = {
#         prod-ca-central1 = {
#           region           = "northamerica-northeast1", ip_cidr_range = "10.30.0.0/20"
#           secondary_ranges = { pods = "10.140.0.0/16", services = "10.150.0.0/20" }
#         }
#       }
#     }
#   }
#   source = "../../../modules/network"
# 
#   project_id   = data.terraform_remote_state.foundation.outputs.project_ids["network-${each.key}"]
#   network_name = "${each.key}-shared-vpc"
#   subnets      = each.value.subnets
#   enable_nat   = true
# }
