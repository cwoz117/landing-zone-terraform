provider "google" { impersonate_service_account = "terraform-workload-vending@wozware-terraform-automation.iam.gserviceaccount.com" }
data "terraform_remote_state" "folders" {
  backend = "remote"
  config = {
    organization = "wozware"
    workspaces   = { name = "gcp-platform-workloads" }
  }
}
module "project" {
  source              = "../../../../modules/workload-project"
  project_id          = "wozware-scan-service-prod"
  name                = "Scan Service Prod"
  folder_id           = data.terraform_remote_state.folders.outputs.folder_ids["prod"]
  billing_account_id  = "017013-B52A7F-45A636"
  services            = ["run.googleapis.com", "artifactregistry.googleapis.com"]
  labels              = { application = "scan-service", environment = "prod", owner = "scan-team" }
  deployer_principals = ["user:chris@wozware.com"]
  iam                 = { "roles/viewer" = ["user:chris@wozware.com"] }
}
