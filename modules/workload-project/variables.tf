variable "project_id" { type = string }
variable "name" { type = string }
variable "folder_id" { type = string }
variable "billing_account_id" { type = string }
variable "host_project_id" {
  description = "Optional Shared VPC host project. Null leaves the workload project unattached during foundation-only deployments."
  type        = string
  default     = null
  nullable    = true
}
variable "services" {
  type    = set(string)
  default = []
}
variable "labels" {
  type    = map(string)
  default = {}
}
variable "iam" {
  description = "Additive project IAM members keyed by role."
  type        = map(set(string))
  default     = {}
}

variable "deployer_principals" {
  description = "Principals allowed to impersonate the project's Terraform deployer service account."
  type        = set(string)
  default     = []
}

variable "deployer_roles" {
  description = "Project roles granted to the Terraform deployer service account."
  type        = set(string)
  default = [
    "roles/artifactregistry.writer",
    "roles/run.admin"
  ]
}
