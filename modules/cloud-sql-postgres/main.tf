resource "google_project" "this" {
  project_id      = var.project_id
  name            = "PostgreSQL Data Platform"
  folder_id       = var.folder_id
  billing_account = var.billing_account_id
  labels          = merge(var.labels, { managed-by = "terraform", layer = "data" })
  deletion_policy = "PREVENT"
}

resource "google_project_service" "this" {
  for_each           = toset(["compute.googleapis.com", "servicenetworking.googleapis.com", "sqladmin.googleapis.com"])
  project            = google_project.this.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_compute_shared_vpc_service_project" "this" {
  host_project    = var.host_project_id
  service_project = google_project.this.project_id
  depends_on      = [google_project_service.this]
}

resource "google_compute_global_address" "private_services" {
  project       = var.host_project_id
  name          = "postgres-private-service-access"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.private_service_range_prefix_length
  network       = var.network_id
}

resource "google_service_networking_connection" "private_services" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services.name]
}

resource "google_sql_database_instance" "this" {
  project             = google_project.this.project_id
  name                = var.instance_name
  region              = var.region
  database_version    = var.database_version
  deletion_protection = true

  settings {
    tier              = var.tier
    availability_type = "REGIONAL"
    disk_autoresize   = true
    disk_type         = "PD_SSD"

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_id
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 14
        retention_unit   = "COUNT"
      }
    }

    insights_config {
      query_insights_enabled  = true
      record_application_tags = true
      record_client_address   = false
    }
  }

  depends_on = [google_service_networking_connection.private_services, google_compute_shared_vpc_service_project.this]
}
