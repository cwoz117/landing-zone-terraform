variable "project_id" { type = string }
variable "network_name" { type = string }
variable "routing_mode" {
  type    = string
  default = "GLOBAL"
}
variable "subnets" {
  type = map(object({
    region                = string
    ip_cidr_range         = string
    private_google_access = optional(bool, true)
    secondary_ranges      = optional(map(string), {})
  }))
}
variable "enable_nat" {
  type    = bool
  default = true
}
