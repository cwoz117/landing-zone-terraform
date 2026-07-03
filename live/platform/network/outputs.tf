# output "host_project_ids" {
#   value = { for environment, network in module.network : environment => data.terraform_remote_state.foundation.outputs.project_ids["network-${environment}"] }
# }
# output "network_ids" { value = { for environment, network in module.network : environment => network.network_id } }
# output "subnet_ids" { value = { for environment, network in module.network : environment => network.subnet_ids } }
