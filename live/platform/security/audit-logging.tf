resource "google_storage_bucket" "audit_logs" {
  project                     = data.terraform_remote_state.root.outputs.project_ids["logging"]
  name                        = "wozware-audit-logs"
  location                    = "northamerica-northeast1"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning { enabled = true }

  lifecycle_rule {
    condition { age = 365 }
    action { type = "Delete" }
  }
}

resource "google_logging_organization_sink" "audit" {
  name             = "central-audit-logs"
  org_id           = "748235834085"
  destination      = "storage.googleapis.com/${google_storage_bucket.audit_logs.name}"
  include_children = true
  filter           = "log_id(\"cloudaudit.googleapis.com/activity\") OR log_id(\"cloudaudit.googleapis.com/system_event\") OR log_id(\"cloudaudit.googleapis.com/policy\")"
}

resource "google_storage_bucket_iam_member" "audit_writer" {
  bucket = google_storage_bucket.audit_logs.name
  role   = "roles/storage.objectCreator"
  member = google_logging_organization_sink.audit.writer_identity
}
