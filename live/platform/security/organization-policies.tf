locals {
  organization_parent = "organizations/748235834085"
  allowed_regions = [
    "northamerica-northeast1",
    "northamerica-northeast2"
  ]
}

resource "google_org_policy_policy" "disable_service_account_keys" {
  name   = "${local.organization_parent}/policies/iam.disableServiceAccountKeyCreation"
  parent = local.organization_parent
  spec {
    rules { enforce = "TRUE" }
  }
}

resource "google_org_policy_policy" "disable_default_network" {
  name   = "${local.organization_parent}/policies/compute.skipDefaultNetworkCreation"
  parent = local.organization_parent
  spec {
    rules { enforce = "TRUE" }
  }
}

resource "google_org_policy_policy" "restrict_external_ips" {
  name   = "${local.organization_parent}/policies/compute.vmExternalIpAccess"
  parent = local.organization_parent
  spec {
    rules { deny_all = "TRUE" }
  }
}

resource "google_org_policy_policy" "allowed_locations" {
  name   = "${local.organization_parent}/policies/gcp.resourceLocations"
  parent = local.organization_parent
  spec {
    rules {
      values {
        allowed_values = [for region in local.allowed_regions : "in:${region}-locations"]
      }
    }
  }
}
