# provider "google" {
#   impersonate_service_account = "terraform-data@wozware-terraform-automation.iam.gserviceaccount.com"
# }
# 
# data "terraform_remote_state" "root" {
#   backend = "remote"
#   config  = { organization = "wozware", workspaces = { name = "gcp-platform-root" } }
# }
# 
# data "terraform_remote_state" "network" {
#   backend = "remote"
#   config  = { organization = "wozware", workspaces = { name = "gcp-platform-network" } }
# }
# 
# module "postgres" {
#   source = "../../../modules/cloud-sql-postgres"
# 
#   project_id         = "wozware-data-prod"
#   folder_id          = data.terraform_remote_state.root.outputs.folder_ids["platform"]
#   billing_account_id = "017013-B52A7F-45A636"
#   host_project_id    = data.terraform_remote_state.network.outputs.host_project_ids["prod"]
#   network_id         = data.terraform_remote_state.network.outputs.network_ids["prod"]
#   region             = "northamerica-northeast1"
#   instance_name      = "platform-postgres-prod"
#   labels             = { owner = "platform-data", cost-center = "platform" }
# }
