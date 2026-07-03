output "network_id" { value = google_compute_network.this.id }
output "network_name" { value = google_compute_network.this.name }
output "subnet_ids" { value = { for name, subnet in google_compute_subnetwork.this : name => subnet.id } }
