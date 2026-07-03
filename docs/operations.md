# Operations runbook

## Initial trust

Create the `gcp-platform-root` HCP Terraform workspace with `live/platform/root` as its working directory. Configure an out-of-band GCP Workload Identity Federation trust for its first run. Root creates the automation project and scoped service accounts used by downstream workspaces.

## Deployment order

1. Apply `gcp-platform-root`.
2. Apply `gcp-platform-workloads`.
3. Configure federation for the created identity, security, and workload-vending service accounts.
4. Apply `gcp-platform-identity`.
5. Apply `gcp-platform-security`.
6. Apply each application environment workspace.

Configure state sharing narrowly:

- Root outputs → identity and security
- Workload-folder outputs → identity and application workspaces

## Add an application project

Create one directory per environment, such as `live/workloads/orders/dev`, and one matching HCP workspace. The workspace calls `modules/workload-project` to create the project, APIs, labels, IAM, and application deployment identity.

## Recovery and deletion

HCP Terraform owns state history. Foundation and workload projects use `deletion_policy = "PREVENT"`. Intentional deletion requires a reviewed code change before destroy.

## Phase 2

Switch to the `phase-2` branch to continue development of network, compute, data, and shared platform services. Those resources are absent from `main` and cannot appear in demo plans.
