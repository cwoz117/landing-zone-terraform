resource "google_compute_shared_vpc_host_project" "this" {
  project = var.project_id
}

resource "google_compute_network" "this" {
  project                         = var.project_id
  name                            = var.network_name
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "this" {
  for_each = var.subnets

  project                  = var.project_id
  name                     = each.key
  region                   = each.value.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = each.value.ip_cidr_range
  private_ip_google_access = each.value.private_google_access

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ranges
    content {
      range_name    = secondary_ip_range.key
      ip_cidr_range = secondary_ip_range.value
    }
  }

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_route" "private_google_access" {
  project          = var.project_id
  name             = "${var.network_name}-private-google-apis"
  network          = google_compute_network.this.name
  dest_range       = "199.36.153.8/30"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

resource "google_compute_route" "default_egress" {
  project          = var.project_id
  name             = "${var.network_name}-default-egress"
  network          = google_compute_network.this.name
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

resource "google_compute_router" "nat" {
  for_each = var.enable_nat ? toset(distinct([for subnet in var.subnets : subnet.region])) : []
  project  = var.project_id
  name     = "${var.network_name}-${each.value}-router"
  region   = each.value
  network  = google_compute_network.this.id
}

resource "google_compute_router_nat" "this" {
  for_each                           = google_compute_router.nat
  project                            = var.project_id
  name                               = "${var.network_name}-${each.key}-nat"
  router                             = each.value.name
  region                             = each.key
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
