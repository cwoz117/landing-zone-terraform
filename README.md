# GCP Terraform Landing Zone Demo

An opinionated Google Cloud landing-zone demonstration based on the separation and governance model in HashiCorp's validated AWS and Azure landing-zone patterns.

This `main` branch intentionally deploys only the landing-zone control plane: organization hierarchy, platform projects, IAM, security guardrails, audit logging, and isolated application projects. Network, compute, data, and shared platform services are deferred to the `phase-2` branch.

## Architecture

```text
Google Cloud Organization: wozware.com
├── Platform
│   ├── Terraform Automation project
│   ├── Central Logging project
│   ├── Central Security project
│   └── Shared DNS project
├── Workloads
│   ├── Dev
│   │   ├── Scan Service project
│   │   └── Web UI project
│   ├── Test
│   │   ├── Scan Service project
│   │   └── Web UI project
│   └── Prod
│       ├── Scan Service project
│       └── Web UI project
└── Sandbox
```

## Live workspaces

Every leaf directory under `live/` is one HCP Terraform workspace working directory and state boundary.

| Working directory | HCP workspace |
|---|---|
| `live/platform/root` | `gcp-platform-root` |
| `live/platform/workloads` | `gcp-platform-workloads` |
| `live/platform/identity` | `gcp-platform-identity` |
| `live/platform/security` | `gcp-platform-security` |
| `live/workloads/<app>/<env>` | `gcp-<app>-<env>` |

## Repository contract

- `modules/` contains genuinely reusable Terraform implementations.
- `live/` contains concrete workspace instances and tenant values.
- Live configurations do not add pass-through variables solely to resemble modules.
- Live outputs exist only as documented cross-workspace interfaces.
- Application repositories own resources inside workload projects; this repository owns project vending and guardrails.

## Deployment order

1. Platform root
2. Workload folder hierarchy
3. Identity
4. Security
5. Application environment projects

HCP Terraform owns state. The root workspace requires an initial GCP Workload Identity Federation trust configured out of band. Root then creates the scoped identities used by downstream workspaces.

## Validation

```bash
make fmt
make validate
```

See [architecture decisions](docs/architecture.md) and the [operations runbook](docs/operations.md).
