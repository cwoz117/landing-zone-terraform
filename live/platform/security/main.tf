provider "google" {
  impersonate_service_account = "terraform-security@wozware-terraform-automation.iam.gserviceaccount.com"
}

data "terraform_remote_state" "root" {
  backend = "remote"
  config = {
    organization = "wozware"
    workspaces   = { name = "gcp-platform-root" }
  }
}
