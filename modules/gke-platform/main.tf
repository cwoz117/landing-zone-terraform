resource "google_project" "this" {
  project_id      = var.project_id
  name            = "GKE Platform"
  folder_id       = var.folder_id
  billing_account = var.billing_account_id
  labels          = merge(var.labels, { managed-by = "terraform", layer = "compute" })
  deletion_policy = "PREVENT"
}

resource "google_project_service" "this" {
  for_each           = toset(["compute.googleapis.com", "container.googleapis.com", "logging.googleapis.com", "monitoring.googleapis.com"])
  project            = google_project.this.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_compute_shared_vpc_service_project" "this" {
  host_project    = var.host_project_id
  service_project = google_project.this.project_id
  depends_on      = [google_project_service.this]
}

resource "google_project_iam_member" "host_service_agent" {
  project    = var.host_project_id
  role       = "roles/container.hostServiceAgentUser"
  member     = "serviceAccount:service-${google_project.this.number}@container-engine-robot.iam.gserviceaccount.com"
  depends_on = [google_project_service.this]
}

resource "google_project_iam_member" "network_user" {
  for_each = toset([
    "serviceAccount:service-${google_project.this.number}@container-engine-robot.iam.gserviceaccount.com",
    "serviceAccount:${google_project.this.number}@cloudservices.gserviceaccount.com"
  ])
  project    = var.host_project_id
  role       = "roles/compute.networkUser"
  member     = each.value
  depends_on = [google_project_service.this]
}

resource "google_container_cluster" "this" {
  project  = google_project.this.project_id
  name     = var.cluster_name
  location = var.region

  network    = var.network_id
  subnetwork = var.subnetwork_id

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = true
  networking_mode          = "VPC_NATIVE"
  enable_shielded_nodes    = true

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr
  }

  release_channel { channel = "REGULAR" }
  workload_identity_config { workload_pool = "${google_project.this.project_id}.svc.id.goog" }

  depends_on = [google_compute_shared_vpc_service_project.this, google_project_iam_member.host_service_agent, google_project_iam_member.network_user]
}

resource "google_container_node_pool" "primary" {
  project  = google_project.this.project_id
  name     = "primary"
  location = var.region
  cluster  = google_container_cluster.this.name

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    workload_metadata_config { mode = "GKE_METADATA" }
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
