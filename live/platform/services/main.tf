# provider "google" {
#   impersonate_service_account = "terraform-services@wozware-terraform-automation.iam.gserviceaccount.com"
# }
# 
# data "terraform_remote_state" "root" {
#   backend = "remote"
#   config = {
#     organization = "wozware"
#     workspaces   = { name = "gcp-platform-root" }
#   }
# }
# 
# locals {
#   organization_id    = "748235834085"
#   billing_account_id = "017013-B52A7F-45A636"
#   region             = "northamerica-northeast1"
# 
#   projects = {
#     registry = {
#       project_id = "wozware-platform-registry"
#       name       = "Platform Registry"
#       services   = ["artifactregistry.googleapis.com", "iam.googleapis.com"]
#     }
#     runners = {
#       project_id = "wozware-github-runners"
#       name       = "GitHub Actions Runners"
#       services   = ["compute.googleapis.com", "iam.googleapis.com", "iamcredentials.googleapis.com", "logging.googleapis.com", "monitoring.googleapis.com", "sts.googleapis.com"]
#     }
#     secrets = {
#       project_id = "wozware-platform-secrets"
#       name       = "Platform Secrets"
#       services   = ["iam.googleapis.com", "secretmanager.googleapis.com"]
#     }
#     observability = {
#       project_id = "wozware-observability"
#       name       = "Platform Observability"
#       services   = ["iam.googleapis.com", "logging.googleapis.com", "monitoring.googleapis.com", "pubsub.googleapis.com"]
#     }
#   }
# }
# 
# resource "google_project" "service" {
#   for_each = local.projects
# 
#   project_id      = each.value.project_id
#   name            = each.value.name
#   folder_id       = data.terraform_remote_state.root.outputs.folder_ids["platform"]
#   billing_account = local.billing_account_id
#   labels          = { managed-by = "terraform", layer = "services", service = each.key }
#   deletion_policy = "PREVENT"
# }
# 
# resource "google_project_service" "service" {
#   for_each = merge([
#     for project_key, project in local.projects : {
#       for service in project.services : "${project_key}/${service}" => {
#         project_key = project_key
#         service     = service
#       }
#     }
#   ]...)
# 
#   project            = google_project.service[each.value.project_key].project_id
#   service            = each.value.service
#   disable_on_destroy = false
# }
