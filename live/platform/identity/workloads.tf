locals {
  workload_folder_role_members = {
    dev = {
      "roles/browser"                        = ["user:chris@wozware.com"]
      "roles/resourcemanager.projectCreator" = ["serviceAccount:terraform-workload-vending@wozware-terraform-automation.iam.gserviceaccount.com"]
    }
    test = {
      "roles/browser"                        = ["user:chris@wozware.com", "user:chris@wozware.com"]
      "roles/resourcemanager.projectCreator" = ["serviceAccount:terraform-workload-vending@wozware-terraform-automation.iam.gserviceaccount.com"]
    }
    prod = {
      "roles/browser"                        = ["user:chris@wozware.com"]
      "roles/viewer"                         = ["user:chris@wozware.com"]
      "roles/resourcemanager.projectCreator" = ["serviceAccount:terraform-workload-vending@wozware-terraform-automation.iam.gserviceaccount.com"]
    }
  }
}

resource "google_folder_iam_member" "workloads" {
  for_each = merge(flatten([
    for environment, roles in local.workload_folder_role_members : [
      for role, members in roles : {
        for member in members : "${environment}/${role}/${member}" => {
          environment = environment
          role        = role
          member      = member
        }
      }
    ]
  ])...)

  folder = data.terraform_remote_state.workloads.outputs.folder_ids[each.value.environment]
  role   = each.value.role
  member = each.value.member
}
