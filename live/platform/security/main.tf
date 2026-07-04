provider "google" {}

data "terraform_remote_state" "root" {
  backend = "remote"
  config = {
    organization = "wozware"
    workspaces   = { name = "gcp-platform-root" }
  }
}
