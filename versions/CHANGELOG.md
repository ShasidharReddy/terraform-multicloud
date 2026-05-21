# Changelog

## [v1.2.0] - 2026-05-21
### Added
- Optional database deployment across all AWS, Azure, and GCP environments via `enable_database`
- Optional Redis deployment across all AWS, Azure, and GCP environments via `enable_redis`
- Redis modules for AWS ElastiCache, Azure Cache for Redis, and GCP Memorystore
- Redis outputs across environment stacks and a Redis security group output in the AWS security-groups module

### Changed
- Updated `scripts/deploy.sh` to prompt for database and Redis deployment choices and pass the new Terraform variables
- Made environment database and Redis outputs safe when optional modules are disabled

### Fixed
- GKE now uses the private subnet self link instead of the subnet ID
- AKS now skips `linux_profile` when no SSH public key is provided
- Azure PostgreSQL flexible server now supports delegated subnet and private DNS integration
- GCP Cloud SQL backup configuration now supports MySQL and PostgreSQL correctly
- AWS security-groups now includes a Redis security group for app-tier access

## [v1.1.0] - 2026-05-21
### Added
- Kubernetes modules for EKS, AKS, and GKE with node scaling up to 50
- Bastion host modules for AWS, Azure, and GCP
- AWS security-groups module for web, app, database, and EKS worker tiers
- Remote backend bootstrap script and backend templates for AWS, Azure, and GCP
- Enhanced environment variables for compute switching, database engines, and bastion access

### Changed
- Increased VM count validation from 10 to 50 across AWS, Azure, GCP, environments, and deploy workflow
- Expanded AWS VPC networking with NACLs and an S3 gateway endpoint
- Expanded Azure VNet networking with a public route table
- Expanded GCP networking with additional firewall rules and a default internet route
- Reworked database modules to support multiple database engines per cloud
- Replaced README with comprehensive deployment and operations guidance

## [v1.0.0] - Initial Release
### Added
- Multi-cloud support: AWS, Azure, GCP
- Environments: dev, qa, stage, prod
- Resources: VPC/VNet, Compute VMs, PostgreSQL Database, Object Storage
- Interactive deployment script with multi-select
- VM count scaling (1-10)

## [v1.0.3] - 2026-05-21

### Added
- `Jenkinsfile`: Full declarative Jenkins pipeline with parameterized builds, tfsec, SonarQube, approval gates for stage/prod, and auto-tagging
- `sonar-project.properties`: SonarQube project configuration for Terraform code quality analysis
- `.pre-commit-config.yaml`: Pre-commit hooks (terraform_fmt, terraform_validate, tfsec, checkov, shellcheck)
- `scripts/bump-version.sh`: Semantic version bump script (patch/minor/major)
- `scripts/ci-check.sh`: Local CI runner (fmt + validate + tfsec + checkov)
- `versions/VERSION`: Machine-readable version file
- Makefile: Expanded with 18 targets including `all-checks`, `tfsec`, `checkov`, `sonar`, `tag-patch`, `tag-minor`, `tag-major`, `pre-commit-install`, `docs`, `clean`

### Changed
- Re-tagged version history to patch versioning: v1.1.0 → v1.0.1, v1.2.0 → v1.0.2

### Fixed
- Verified the v1.0.2 audit checklist with no additional code defects remaining
