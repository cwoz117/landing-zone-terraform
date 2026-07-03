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
  project_id          = "wozware-web-ui-dev"
  name                = "Web UI Dev"
  folder_id           = data.terraform_remote_state.folders.outputs.folder_ids["dev"]
  billing_account_id  = "017013-B52A7F-45A636"
  services            = ["run.googleapis.com", "artifactregistry.googleapis.com"]
  labels              = { application = "web-ui", environment = "dev", owner = "web-team" }
  deployer_principals = ["user:chris@wozware.com"]
  iam                 = { "roles/editor" = ["user:chris@wozware.com"] }
}
