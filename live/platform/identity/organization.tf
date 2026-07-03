locals {
  organization_id    = "748235834085"
  billing_account_id = "017013-B52A7F-45A636"

  organization_role_members = {
    "roles/browser" = [
      "user:chris@wozware.com"
    ]
    "roles/iam.securityReviewer" = [
      "user:chris@wozware.com"
    ]
    "roles/logging.viewer" = [
      "user:chris@wozware.com"
    ]
  }
}

resource "google_organization_iam_member" "organization" {
  for_each = merge([
    for role, members in local.organization_role_members : {
      for member in members : "${role}/${member}" => {
        role   = role
        member = member
      }
    }
  ]...)

  org_id = local.organization_id
  role   = each.value.role
  member = each.value.member
}

resource "google_billing_account_iam_member" "viewer" {
  billing_account_id = local.billing_account_id
  role               = "roles/billing.viewer"
  member             = "user:chris@wozware.com"
}
