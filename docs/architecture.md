# Architecture decisions

## Demo scope

The `main` branch demonstrates the landing-zone control plane without runtime infrastructure or chargeable network appliances. Network, GKE, Cloud SQL, registry, runner, secret, and observability implementations are retained on the `phase-2` branch.

## Modules versus instances

A reusable implementation belongs under `modules/`. A deployed workspace instance belongs under `live/` and expresses concrete organization, billing, project, IAM, and environment values directly at the call site. One `.tf` file is not a state boundary; one leaf directory under `live/` is.

Single-use organization root, workload hierarchy, identity, and security resources remain directly in their live configurations. The centralized workload workspace instantiates the reusable workload-project module once per generated application environment.

## State boundaries

Root, centralized workload vending, identity, and security use separate HCP Terraform state. Application repositories use separate application-infrastructure workspaces and consume only explicit outputs from the centralized workload workspace and other platform workspaces.

## Resource hierarchy

Platform resources are separate from workload resources. Workload folders are divided into dev, test, and prod policy boundaries. A single application declaration expands into one GCP project per environment. Application HCP Terraform workspaces do not own project vending; they own resources inside their assigned projects.

## Identity

The root workspace creates scoped automation identities for root, identity, security, and workload vending. Workload projects receive separate deployment service accounts for their future application repositories. Direct grants to `chris@wozware.com` are demo substitutions for Cloud Identity groups and must be replaced before team adoption.

## Security

Organization policies disable service-account keys, default networks, and VM external IPs and restrict resource locations. Organization audit logs are exported to private storage. These cloud API controls complement future OPA plan policies; they do not replace them.
