locals {
  baseline_services = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "serviceusage.googleapis.com"
  ])
}

resource "google_project" "this" {
  project_id      = var.project_id
  name            = var.name
  folder_id       = var.folder_id
  billing_account = var.billing_account_id
  labels          = merge(var.labels, { managed-by = "terraform" })
  deletion_policy = "PREVENT"
}

resource "google_project_service" "this" {
  for_each           = setunion(local.baseline_services, var.services)
  project            = google_project.this.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_compute_shared_vpc_service_project" "this" {
  count = var.host_project_id == null ? 0 : 1

  host_project    = var.host_project_id
  service_project = google_project.this.project_id
  depends_on      = [google_project_service.this]
}

resource "google_project_iam_member" "this" {
  for_each = merge([
    for role, members in var.iam : {
      for member in members : "${role}/${member}" => { role = role, member = member }
    }
  ]...)
  project = google_project.this.project_id
  role    = each.value.role
  member  = each.value.member
}

resource "google_service_account" "terraform_deployer" {
  project      = google_project.this.project_id
  account_id   = "terraform-deployer"
  display_name = "Terraform workload deployer"

  depends_on = [google_project_service.this]
}

resource "google_service_account_iam_member" "terraform_deployer" {
  for_each = var.deployer_principals

  service_account_id = google_service_account.terraform_deployer.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
}

resource "google_project_iam_member" "terraform_deployer" {
  for_each = var.deployer_roles

  project = google_project.this.project_id
  role    = each.value
  member  = google_service_account.terraform_deployer.member
}
