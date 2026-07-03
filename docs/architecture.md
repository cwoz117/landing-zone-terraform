# Architecture decisions

## State boundaries

Root, identity, network, security, compute, data, workload hierarchy, and every application environment use separate state. A malformed application change therefore cannot directly replace the organization hierarchy or network. Downstream live configurations consume only explicit remote-state outputs.

The `live/` directories are conventional Terraform root configurations, not Terraform Stacks. Each leaf directory maps directly to one independently managed state and one HCP Terraform workspace working directory.

Application environments do not share state. For example, `live/workloads/scan-service/dev` and `live/workloads/scan-service/prod` are separate configurations and workspaces. The platform-owned `live/platform/workloads` configuration creates only the parent workload and environment folders.

Compute and data use separate projects, workspaces, automation identities, and reusable modules. Compute provides a private regional GKE cluster; data provides a private regional high-availability Cloud SQL for PostgreSQL instance. Both consume the production Shared VPC but have independent lifecycle and approval boundaries.

The services workspace provisions only shared cloud primitives: Artifact Registry, GitHub workload identity and runner service accounts, Secret Manager metadata, and Pub/Sub/log-export plumbing for observability collectors. Kubernetes operators, controllers, extensions, and collectors remain owned by the separate Argo/GitOps repository.

Network, compute, data, and services live configurations are currently commented reference designs and are excluded from the initial landing-zone deployment. Enable them only after the foundational organization, folders, IAM, security, and workload projects are established and reviewed.

## Modules versus instances

The separation between `modules/` and `live/` is an architectural rule:

- A reusable child module belongs under `modules/`. It accepts variables, encapsulates resources, and publishes outputs that form a stable contract.
- A deployed instance belongs under `live/`. It selects concrete project IDs, regions, CIDRs, groups, enabled APIs, and module versions at the module call site.
- A live configuration must not create pass-through variables merely to forward them unchanged into a child module. That indirection hides the actual deployment and increases the number of files required to understand a workspace.
- A live configuration publishes outputs only when another workspace requires them. Foundation folder/project IDs, network IDs, and workload folder IDs are such interfaces.
- One `.tf` file is not one workspace. Terraform merges all `.tf` files in a directory into one root module. A new state boundary therefore requires a new leaf directory, not another file.

This convention makes reusable API design visually distinct from tenant-specific infrastructure decisions and keeps workspace review focused on live values.

Organization-root and workload-folder creation are deliberate exceptions to module extraction. Both are single-use configurations with no expected second caller, so their resources live directly in their respective live roots. A child module is introduced only when reuse, meaningful encapsulation, or a stable abstraction justifies its variable plumbing.

There is no Terraform-managed remote-state bootstrap. HCP Terraform owns workspace state. The root workspace requires an initial dynamic GCP trust relationship configured out of band; it then creates the scoped automation identities used by downstream workspaces.

The workload roots in this repository stop at project vending, IAM, API enablement, and Shared VPC attachment. Application-specific repositories consume those landing zones and manage resources inside them; they do not recreate or own the GCP projects themselves.

## Resource hierarchy

Folders are policy and delegation boundaries. Platform resources are separate from workload resources; workload folders are split by lifecycle environment. GCP projects are the primary isolation, quota, billing, API, and workload boundary—the closest equivalent to accounts in the referenced AWS pattern.

## Networking

Each environment receives a distinct Shared VPC host project and custom-mode VPC. Workload service projects attach to the environment host. Subnets enable Private Google Access and VPC Flow Logs. Cloud NAT supplies controlled outbound connectivity without external VM addresses.

The network live configuration is currently commented out for the foundation-only demonstration. Network host projects remain visible in the landing-zone hierarchy, but no VPCs, subnets, routes, routers, NAT gateways, or Shared VPC attachments are created. The complete configuration remains as a Phase 2 reference.

The module intentionally does not allow traffic with broad firewall rules. Add explicit hierarchical firewall policies, DNS, hybrid connectivity, inspection, and service perimeters for the target threat model.

## Governance

Organization policies enforce controls on every API path, while CI checks Terraform before deployment. Organization policies are the GCP analogue of AWS SCP guardrails; neither replaces resource-level IAM.

The initial constraints prevent service-account keys, default networks, and external VM addresses. Region restriction is opt-in because applying the wrong location set at organization scope can block platform services.

## Identity

Human administrators impersonate a dedicated Terraform service account. Workload IAM accepts groups and service accounts as additive bindings. Avoid direct user grants and authoritative IAM policies unless ownership of the entire policy is deliberate.

Active Terraform automation is split across root, identity, network, security, and workload-vending service accounts. Compute, data, and services identities will be introduced when those deferred live configurations are enabled. Each workload project also receives its own `terraform-deployer` service account for its application repository; that identity is separate from the organization-level workload-vending identity.
