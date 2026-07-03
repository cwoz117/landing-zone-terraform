# resource "google_pubsub_topic" "platform_logs" {
#   project = google_project.service["observability"].project_id
#   name    = "platform-logs"
# 
#   message_retention_duration = "604800s"
#   depends_on                 = [google_project_service.service]
# }
# 
# resource "google_pubsub_subscription" "observability_collectors" {
#   project = google_project.service["observability"].project_id
#   name    = "observability-collectors"
#   topic   = google_pubsub_topic.platform_logs.id
# 
#   ack_deadline_seconds       = 30
#   message_retention_duration = "604800s"
#   expiration_policy { ttl = "" }
# }
# 
# resource "google_logging_organization_sink" "platform_logs" {
#   name             = "platform-observability"
#   org_id           = local.organization_id
#   destination      = "pubsub.googleapis.com/${google_pubsub_topic.platform_logs.id}"
#   include_children = true
#   filter           = "NOT log_id(\"cloudaudit.googleapis.com/activity\") AND NOT log_id(\"cloudaudit.googleapis.com/system_event\")"
# }
# 
# resource "google_pubsub_topic_iam_member" "log_sink" {
#   project = google_project.service["observability"].project_id
#   topic   = google_pubsub_topic.platform_logs.name
#   role    = "roles/pubsub.publisher"
#   member  = google_logging_organization_sink.platform_logs.writer_identity
# }
# 
# resource "google_service_account" "observability_collector" {
#   project      = google_project.service["observability"].project_id
#   account_id   = "observability-collector"
#   display_name = "Observability collectors"
#   depends_on   = [google_project_service.service]
# }
# 
# resource "google_pubsub_subscription_iam_member" "collector" {
#   project      = google_project.service["observability"].project_id
#   subscription = google_pubsub_subscription.observability_collectors.name
#   role         = "roles/pubsub.subscriber"
#   member       = google_service_account.observability_collector.member
# }
# 
# resource "google_project_iam_member" "observability_collector" {
#   for_each = toset(["roles/logging.logWriter", "roles/monitoring.metricWriter"])
# 
#   project = google_project.service["observability"].project_id
#   role    = each.value
#   member  = google_service_account.observability_collector.member
# }
