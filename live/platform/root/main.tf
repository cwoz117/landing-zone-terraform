provider "google" {}

locals {
  organization_id    = "748235834085"
  billing_account_id = "017013-B52A7F-45A636"
  project_id_prefix  = "wozware"

  platform_projects = {
    meridian-platform = {
      name = "Meridian Platform"
      services = [
        "cloudbilling.googleapis.com",
        "cloudkms.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "dns.googleapis.com",
        "essentialcontacts.googleapis.com",
        "iam.googleapis.com",
        "iamcredentials.googleapis.com",
        "logging.googleapis.com",
        "orgpolicy.googleapis.com",
        "secretmanager.googleapis.com",
        "securitycenter.googleapis.com",
        "serviceusage.googleapis.com",
        "servicenetworking.googleapis.com",
        "storage.googleapis.com",
      ]
    }
  }

  terraform_service_accounts = {
    root             = "Organization root and project creation"
    identity         = "IAM and access management"
    security         = "Organization policy and security management"
    workload-vending = "Workload project vending"
  }

  organization_roles = {
    root             = ["roles/resourcemanager.folderAdmin", "roles/resourcemanager.projectCreator", "roles/resourcemanager.projectIamAdmin", "roles/serviceusage.serviceUsageAdmin"]
    identity         = ["roles/resourcemanager.folderAdmin", "roles/resourcemanager.organizationAdmin", "roles/resourcemanager.projectIamAdmin"]
    security         = ["roles/essentialcontacts.admin", "roles/logging.configWriter", "roles/orgpolicy.policyAdmin"]
    workload-vending = [
      "roles/billing.projectManager",
      "roles/iam.serviceAccountAdmin",
      "roles/resourcemanager.projectCreator",
      "roles/resourcemanager.projectIamAdmin",
      "roles/serviceusage.serviceUsageAdmin",
    ]
  }

  terraform_workspace_ids = {
    root     = ["ws-KpC9VP64YMPomaBt"]
    identity = ["ws-swkzrJaDLa3NKBLV"]
    security = ["ws-ww6SYZjkVHZvu982"]
    workload-vending = [
      "ws-UFujonJy987NPZ2f",
      "ws-psNw7J2A5wnxAsVR",
      "ws-DubQjmSt2Qt2rRTo",
      "ws-UY3MxGMWCCDXWmRH",
      "ws-8zrerh77PKhqrw2s",
      "ws-ekPdDHUmEVX69Rmt",
    ]
  }
}

moved {
  from = google_folder.platform
  to   = google_folder.meridian
}

resource "google_folder" "meridian" {
  display_name = "Meridian"
  parent       = "organizations/${local.organization_id}"
}

resource "google_folder" "platform_projects" {
  display_name = "Platform"
  parent       = google_folder.meridian.name
}

resource "google_project" "platform" {
  for_each = local.platform_projects

  project_id      = "${local.project_id_prefix}-${each.key}"
  name            = each.value.name
  folder_id       = google_folder.platform_projects.name
  billing_account = local.billing_account_id
  labels          = { managed-by = "terraform", layer = "foundation", owner = "cloud-platform" }
  deletion_policy = "PREVENT"
}

resource "google_project_service" "platform" {
  for_each = merge([
    for project_key, project in local.platform_projects : {
      for service in project.services : "${project_key}/${service}" => {
        project_key = project_key
        service     = service
      }
    }
  ]...)

  project            = google_project.platform[each.value.project_key].project_id
  service            = each.value.service
  disable_on_destroy = false
}

resource "google_service_account" "terraform" {
  for_each = local.terraform_service_accounts

  project      = google_project.platform["meridian-platform"].project_id
  account_id   = "terraform-${each.key}"
  display_name = "Terraform: ${each.value}"
  depends_on   = [google_project_service.platform]
}

resource "google_service_account_iam_member" "platform_admins" {
  for_each = google_service_account.terraform

  service_account_id = each.value.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:chris@wozware.com"
}

resource "google_service_account_iam_member" "terraform_workspaces" {
  for_each = merge([
    for account, workspace_ids in local.terraform_workspace_ids : {
      for workspace_id in workspace_ids : "${account}/${workspace_id}" => {
        account      = account
        workspace_id = workspace_id
      }
    }
  ]...)

  service_account_id = google_service_account.terraform[each.value.account].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/162163785431/locations/global/workloadIdentityPools/tfc-pool/attribute.terraform_workspace_id/${each.value.workspace_id}"
}

resource "google_organization_iam_member" "terraform" {
  for_each = merge([
    for account, roles in local.organization_roles : {
      for role in roles : "${account}/${role}" => { account = account, role = role }
    }
  ]...)

  org_id = local.organization_id
  role   = each.value.role
  member = google_service_account.terraform[each.value.account].member
}

resource "google_billing_account_iam_member" "terraform" {
  for_each = toset(["root", "workload-vending"])

  billing_account_id = local.billing_account_id
  role               = "roles/billing.user"
  member             = google_service_account.terraform[each.value].member
}

resource "google_billing_account_iam_member" "identity" {
  billing_account_id = local.billing_account_id
  role               = "roles/billing.admin"
  member             = google_service_account.terraform["identity"].member
}

# These outputs are the published interface for downstream HCP Terraform workspaces.
output "folder_ids" {
  value = {
    meridian = google_folder.meridian.folder_id
    platform = google_folder.platform_projects.folder_id
  }
}

output "project_ids" {
  value = { for name, project in google_project.platform : name => project.project_id }
}
