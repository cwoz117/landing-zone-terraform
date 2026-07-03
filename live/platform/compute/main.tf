# provider "google" {
#   impersonate_service_account = "terraform-compute@wozware-terraform-automation.iam.gserviceaccount.com"
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
# module "gke_platform" {
#   source = "../../../modules/gke-platform"
# 
#   project_id          = "wozware-compute-prod"
#   folder_id           = data.terraform_remote_state.root.outputs.folder_ids["platform"]
#   billing_account_id  = "017013-B52A7F-45A636"
#   host_project_id     = data.terraform_remote_state.network.outputs.host_project_ids["prod"]
#   network_id          = data.terraform_remote_state.network.outputs.network_ids["prod"]
#   subnetwork_id       = data.terraform_remote_state.network.outputs.subnet_ids["prod"]["prod-ca-central1"]
#   region              = "northamerica-northeast1"
#   cluster_name        = "platform-prod"
#   master_ipv4_cidr    = "172.16.0.0/28"
#   pods_range_name     = "pods"
#   services_range_name = "services"
#   min_node_count      = 1
#   max_node_count      = 10
#   labels              = { owner = "platform-compute", cost-center = "platform" }
# }
