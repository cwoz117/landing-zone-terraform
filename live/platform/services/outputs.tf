# output "project_ids" {
#   value = { for name, project in google_project.service : name => project.project_id }
# }
# 
# output "artifact_registry_repository" {
#   value = google_artifact_registry_repository.platform.name
# }
# 
# output "github_runner_service_account" {
#   value = google_service_account.github_runner.email
# }
# 
# output "observability_collector_service_account" {
#   value = google_service_account.observability_collector.email
# }
