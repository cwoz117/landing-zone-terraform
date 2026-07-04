provider "google" {}

resource "google_folder" "workloads" {
  display_name = "Workloads"
  parent       = "organizations/748235834085"
}

resource "google_folder" "environment" {
  for_each = toset(["dev", "test", "prod"])

  display_name = title(each.value)
  parent       = google_folder.workloads.name
}

# This is a deliberate cross-workspace interface consumed by workload projects.
output "folder_ids" {
  value = merge(
    { workloads = google_folder.workloads.folder_id },
    { for name, folder in google_folder.environment : name => folder.folder_id }
  )
}
