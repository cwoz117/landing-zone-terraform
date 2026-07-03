# GCP Terraform Landing Zone

An opinionated Google Cloud landing zone based on the separation and governance model in HashiCorp's AWS landing-zone pattern and Google's Enterprise Foundations Blueprint.

The initial deployment creates a governed resource hierarchy, central audit logging, baseline organization policies, and application landing-zone projects. Network, GKE, PostgreSQL, and shared-service configurations are retained as commented Phase 2 references.

## Architecture

```text
Google Cloud Organization
├── Platform
│   ├── Central Logging project
│   ├── Central Security project
│   ├── Shared DNS project
│   ├── Network host project per environment
│   └── Services project (private GKE and Cloud SQL)
├── Workloads
│   ├── Dev
│   ├── Test
│   └── Prod
└── Sandbox
```

Terraform is split into ordered live root configurations with independent state. Every leaf directory under `live/` is exactly one workspace working directory and one state boundary. These are traditional Terraform configurations, not Terraform Stacks.

| Live configuration | Responsibility | Intended HCP workspace |
|---|---|---|
| `live/platform/root` | Organization foundation, automation identities, and platform projects | `gcp-platform-root` |
| `live/platform/identity` | Organization-level group access | `gcp-platform-identity` |
| `live/platform/network` | Deferred Shared VPC, subnet, routing, and NAT example | Not deployed initially |
| `live/platform/security` | Guardrails, audit export and security contacts | `gcp-platform-security` |
| `live/platform/compute` | Deferred GKE compute platform example | Not deployed initially |
| `live/platform/data` | Deferred PostgreSQL Cloud SQL example | Not deployed initially |
| `live/platform/services` | Deferred registry, runners, secrets, and observability example | Not deployed initially |
| `live/platform/workloads` | Workloads and environment folder hierarchy | `gcp-platform-workloads` |
| `live/workloads/<app>/<env>` | One application project | `gcp-<app>-<env>` |

## Repository contract

This repository intentionally separates reusable Terraform modules from deployable Terraform instances:

- `modules/` contains reusable implementations. Modules expose deliberate input and output contracts through `variables.tf` and `outputs.tf`.
- `live/` contains concrete instances of those modules. Values are written directly at module call sites; live configurations do not proxy every module input through another variable layer.
- One leaf directory in `live/` equals one independently initialized root configuration, state, and workspace. File boundaries inside a directory never imply workspace boundaries.
- Live outputs exist only when they form a required, documented interface for a downstream workspace.
- This repository owns landing-zone GCP projects and their workspace boundaries. Application repositories such as `scan-service-terraform` own resources inside those projects and authenticate against the corresponding workspace/project contract.
- Small, inherently single-use configurations such as organization root and the workload folder hierarchy remain directly in `live/`; wrapping them in one-use modules would add an interface without adding reuse or encapsulation value.

## Prerequisites

- A Google Cloud organization and billing account
- Terraform 1.7 or newer
- An HCP Terraform organization and a root workspace connected to `live/platform/root`
- An initial dynamic GCP credential for the root workspace with organization and billing bootstrap authority
- Globally unique project IDs and Cloud Storage bucket names

The root workspace is the trust bootstrap boundary. Its initial HCP Terraform dynamic credential must be established out of band. Root then creates the narrower automation identities impersonated by downstream live configurations.

## Deploy

Replace the example tenant values directly in each `live/*` configuration before applying it. Reusable inputs belong in `modules/`; deployment decisions belong at the live module call site.

```bash
terraform -chdir=live/platform/root init
terraform -chdir=live/platform/root apply
terraform -chdir=live/platform/workloads init
terraform -chdir=live/platform/workloads apply
terraform -chdir=live/platform/identity init
terraform -chdir=live/platform/identity apply

terraform -chdir=live/platform/security init
terraform -chdir=live/platform/security apply
# Network, compute, data, and services are intentionally commented out for the initial landing-zone deployment.

terraform -chdir=live/workloads/scan-service/dev init
terraform -chdir=live/workloads/scan-service/dev apply
# Repeat for each application/environment workspace.
```

State is owned by the corresponding HCP Terraform workspace; this repository does not create or manage a GCS state backend.

## Security defaults

- Service-account key creation is disabled.
- Default VPC creation is disabled.
- VM external IP addresses are denied by default.
- Audit logs are exported to a versioned, private bucket.
- VPC Flow Logs and Cloud NAT error logging are enabled.
- Workload projects have deletion prevention and inherit folder/organization policies.
- Terraform automation uses service-account impersonation instead of downloaded keys.

These are foundation defaults, not a complete compliance program. Review exceptions, data residency, VPC Service Controls, IAM groups, Security Command Center tier, retention, KMS, hybrid connectivity, DNS, and break-glass access before production use.

## Validation

```bash
make fmt
make validate
```

See [architecture decisions](docs/architecture.md) and the [operations runbook](docs/operations.md).
