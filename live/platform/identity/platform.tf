locals {
  platform_folder_role_members = {
    "roles/resourcemanager.folderAdmin" = [
      "user:chris@wozware.com"
    ]
    "roles/viewer" = [
      "user:chris@wozware.com"
    ]
  }

  security_project_role_members = {
    security = {
      "roles/securitycenter.admin"           = ["user:chris@wozware.com"]
      "roles/serviceusage.serviceUsageAdmin" = ["serviceAccount:terraform-security@wozware-terraform-automation.iam.gserviceaccount.com"]
      "roles/viewer"                         = ["user:chris@wozware.com"]
    }
    logging = {
      "roles/logging.admin"  = ["user:chris@wozware.com"]
      "roles/logging.viewer" = ["user:chris@wozware.com"]
      "roles/storage.admin"  = ["serviceAccount:terraform-security@wozware-terraform-automation.iam.gserviceaccount.com"]
    }
  }

}

resource "google_folder_iam_member" "platform" {
  for_each = merge([
    for role, members in local.platform_folder_role_members : {
      for member in members : "${role}/${member}" => {
        role   = role
        member = member
      }
    }
  ]...)

  folder = data.terraform_remote_state.root.outputs.folder_ids["platform"]
  role   = each.value.role
  member = each.value.member
}

resource "google_project_iam_member" "security" {
  for_each = merge(flatten([
    for project, roles in local.security_project_role_members : [
      for role, members in roles : {
        for member in members : "${project}/${role}/${member}" => {
          project = project
          role    = role
          member  = member
        }
      }
    ]
  ])...)

  project = data.terraform_remote_state.root.outputs.project_ids[each.value.project]
  role    = each.value.role
  member  = each.value.member
}
