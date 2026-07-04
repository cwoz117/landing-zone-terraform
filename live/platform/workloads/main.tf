provider "google" {}

data "terraform_remote_state" "root" {
  backend = "remote"
  config = {
    organization = "wozware"
    workspaces   = { name = "gcp-platform-root" }
  }
}

resource "google_folder" "workloads" {
  display_name = "Workloads"
  parent       = "folders/${data.terraform_remote_state.root.outputs.folder_ids["meridian"]}"
}

resource "google_folder" "environment" {
  for_each = toset(["dev", "test", "prod"])

  display_name = title(each.value)
  parent       = google_folder.workloads.name
}

# Project Creator does not include resourcemanager.projects.update. Project
# Mover is the narrowest predefined role containing that permission; scoping it
# to Workloads prevents the vending identity from moving platform projects.
resource "google_folder_iam_member" "workload_project_manager" {
  folder = google_folder.workloads.name
  role   = "roles/resourcemanager.projectMover"
  member = "serviceAccount:terraform-workload-vending@wozware-meridian-platform.iam.gserviceaccount.com"
}

# This is a deliberate cross-workspace interface consumed by workload projects.
output "folder_ids" {
  value = merge(
    { workloads = google_folder.workloads.folder_id },
    { for name, folder in google_folder.environment : name => folder.folder_id }
  )
}
