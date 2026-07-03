# resource "google_secret_manager_secret" "github" {
#   for_each = toset(["github-app-id", "github-app-private-key"])
# 
#   project   = google_project.service["secrets"].project_id
#   secret_id = each.value
# 
#   replication {
#     auto {}
#   }
# 
#   depends_on = [google_project_service.service]
# }
# 
# # Secret payloads are populated out of band and never stored in Terraform state.
# resource "google_secret_manager_secret_iam_member" "github_runner" {
#   for_each = google_secret_manager_secret.github
# 
#   project   = each.value.project
#   secret_id = each.value.secret_id
#   role      = "roles/secretmanager.secretAccessor"
#   member    = google_service_account.github_runner.member
# }
