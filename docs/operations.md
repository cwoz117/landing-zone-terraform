# Operations runbook

## Deployment order

For the initial landing zone, deploy in this order: platform root; platform workload hierarchy; identity; security; then application environment workspaces. Network, compute, data, and services are commented reference designs and are not part of the initial deployment. Workload project vending leaves Shared VPC attachment unset until Phase 2. Identity consumes the root and workload-folder outputs and grants the scoped automation identities access required by later configurations. Review saved plans before applying. Platform changes require platform-team approval; workload changes can use application-owner plus platform approval.

The services workspace creates Secret Manager resources but never secret versions. Populate payloads through an approved out-of-band process so credentials do not enter Terraform state. Replace the example GitHub organization and repository in `github-runners.tf` before deployment.

## Establish root trust

Create the `gcp-platform-root` HCP Terraform workspace with `live/platform/root` as its working directory. Configure its initial dynamic GCP credential out of band with the organization and billing permissions required to create folders, projects, service accounts, and IAM bindings. After its first apply, downstream workspaces impersonate the scoped identities created by root.

## Add an application workspace

Create one leaf directory per application environment, such as `live/workloads/orders/dev`. Its concrete `workload-project` module call creates one GCP project and attaches it to the matching environment Shared VPC. Create separate `test` and `prod` directories rather than combining their state. Use labels for ownership and cost allocation, and grant access to groups rather than users.

When using HCP Terraform, create one workspace for each leaf directory and set its working directory to that path. A `.tf` file within an existing directory does not create a workspace.

## Recovery and deletion

State bucket versioning provides state recovery. Foundation and workload projects use `deletion_policy = "PREVENT"`; intentional project deletion requires a reviewed code change to that setting before destroy. The audit bucket also refuses non-empty deletion.

## Production readiness decisions

Before the first production workload, decide and implement:

- Cloud Identity federation, group ownership, and break-glass access
- Hierarchical firewall policies and private DNS
- Security Command Center tier and finding export
- VPC Service Controls and Access Context Manager
- Customer-managed encryption keys and key separation
- Log retention, SIEM export, and audit-log coverage
- Dedicated Interconnect or HA VPN requirements
- Budget alerts, quotas, and chargeback labels
- CI identity federation and approval policy
