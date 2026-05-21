# Changelog

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
