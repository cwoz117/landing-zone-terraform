# resource "google_service_account" "github_runner" {
#   project      = google_project.service["runners"].project_id
#   account_id   = "github-actions-runner"
#   display_name = "GitHub Actions runner"
#   depends_on   = [google_project_service.service]
# }
# 
# resource "google_project_iam_member" "github_runner" {
#   for_each = toset([
#     "roles/logging.logWriter",
#     "roles/monitoring.metricWriter"
#   ])
# 
#   project = google_project.service["runners"].project_id
#   role    = each.value
#   member  = google_service_account.github_runner.member
# }
