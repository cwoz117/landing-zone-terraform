# resource "google_artifact_registry_repository" "platform" {
#   project       = google_project.service["registry"].project_id
#   location      = local.region
#   repository_id = "platform"
#   description   = "Shared platform container images and deployment artifacts"
#   format        = "DOCKER"
# 
#   docker_config {
#     immutable_tags = true
#   }
# 
#   cleanup_policies {
#     id     = "delete-untagged"
#     action = "DELETE"
#     condition {
#       tag_state  = "UNTAGGED"
#       older_than = "2592000s"
#     }
#   }
# 
#   depends_on = [google_project_service.service]
# }
# 
# resource "google_artifact_registry_repository_iam_member" "readers" {
#   for_each = toset([
#     "user:chris@wozware.com",
#     "serviceAccount:${google_service_account.github_runner.email}"
#   ])
# 
#   project    = google_artifact_registry_repository.platform.project
#   location   = google_artifact_registry_repository.platform.location
#   repository = google_artifact_registry_repository.platform.name
#   role       = "roles/artifactregistry.reader"
#   member     = each.value
# }
