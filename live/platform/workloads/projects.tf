locals {
  environments = toset(["dev", "test", "prod"])

  # Add an application once; project vending expands it into one isolated
  # project per environment. Application repositories consume the outputs but
  # own all resources deployed inside these projects.
  workloads = {
    scan-service = {
      labels = {
        owner   = "scan-team"
        team    = "scan-team"
        manager = "unassigned"
      }
      services = [
        "artifactregistry.googleapis.com",
        "run.googleapis.com",
      ]
    }
  }

  workload_projects = merge([
    for workload, config in local.workloads : {
      for environment in local.environments :
      "${workload}-${environment}" => {
        workload    = workload
        environment = environment
        project_id  = "wozware-${workload}-${environment}"
        name        = "${title(replace(workload, "-", " "))} ${title(environment)}"
        labels = merge(config.labels, {
          application = workload
          environment = environment
        })
        services = config.services
      }
    }
  ]...)
}

module "workload_project" {
  for_each = local.workload_projects
  source   = "../../../modules/workload-project"

  project_id         = each.value.project_id
  name               = each.value.name
  folder_id          = google_folder.environment[each.value.environment].name
  billing_account_id = "017013-B52A7F-45A636"
  services           = each.value.services
  labels             = each.value.labels

  deployer_principals = ["user:chris@wozware.com"]
  iam = {
    (each.value.environment == "prod" ? "roles/viewer" : "roles/editor") = ["user:chris@wozware.com"]
  }

  depends_on = [google_folder_iam_member.workload_project_manager]
}

output "projects" {
  description = "Application project contract consumed by application infrastructure workspaces."
  value = {
    for name, project in module.workload_project : name => {
      project_id                         = project.project_id
      project_number                     = project.project_number
      terraform_deployer_service_account = project.terraform_deployer_service_account
    }
  }
}
