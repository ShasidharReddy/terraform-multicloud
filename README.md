# Terraform Multi-Cloud Project

A complete Terraform starter project for AWS, Azure, and GCP across `dev`, `qa`, `stage`, and `prod` environments. Each environment/cloud stack provisions networking, compute, PostgreSQL, and object storage using reusable modules.

## Features

- Multi-cloud modules for AWS, Azure, and GCP
- Four environments: `dev`, `qa`, `stage`, `prod`
- Network tiers per cloud: public, private, and database
- VM scaling with `vm_count` from 1 to 10
- Interactive deployment and destroy workflows
- Validation and formatting automation
- Git repository bootstrapped with `v1.0.0`

## Prerequisites

- Terraform `>= 1.5.0`
- AWS CLI / credentials for AWS deployments
- Azure CLI / `az login` for Azure deployments
- Google Cloud SDK / `gcloud auth application-default login` for GCP deployments
- Bash on macOS or Linux

## Quick Start

```bash
cd ~/Git-Infoblox/REPOS/terraform-multicloud
make validate
make deploy
```

## Interactive Deployment Guide

Run the deploy workflow:

```bash
./scripts/deploy.sh
```

Example interaction:

```text
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ Terraform Multi-Cloud Deployment Tool ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

1) dev
2) qa
3) stage
4) prod
Select environments: 1 2

1) aws
2) azure
3) gcp
Select clouds: 1 3

Override VM count? (press Enter to use env defaults):
Action: 2

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Deployment Plan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Environments : dev, qa
  Clouds       : aws, gcp
  Action       : apply
  VM Count     : dev=1, qa=2
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Proceed? [y/N]
```

The script supports:

- multi-select environments
- multi-select clouds
- optional per-environment `vm_count` override
- `plan`, `apply`, or `destroy`
- consolidated logging under `logs/`

## Destroy Guide

```bash
./scripts/destroy.sh
```

The destroy script asks for environments and clouds, then requires the exact word `destroy` before execution.

## Validation Guide

```bash
./scripts/validate.sh
```

This script loops through all 12 environment directories and runs:

- `terraform fmt -check`
- `terraform init -backend=false`
- `terraform validate`

## Environment Differences

| Environment | Default VM Count | AWS Instance | Azure VM Size | GCP Machine Type | DB HA |
|-------------|------------------|--------------|---------------|------------------|-------|
| dev         | 1                | t3.micro     | Standard_B1s  | e2-micro         | No    |
| qa          | 2                | t3.small     | Standard_B2s  | e2-small         | No    |
| stage       | 3                | t3.medium    | Standard_B2ms | e2-medium        | Yes   |
| prod        | 5                | t3.large     | Standard_D4s_v5 | e2-standard-2 | Yes   |

## VM Scaling Guide

`vm_count` defaults by environment:

- `dev = 1`
- `qa = 2`
- `stage = 3`
- `prod = 5`

You can override each selected environment during deployment. The scripts validate that overrides stay between `1` and `10`.

## Backend Configuration Guide

Each environment/cloud directory includes a `backend.tf` file with commented remote-state examples:

- AWS uses `s3`
- Azure uses `azurerm`
- GCP uses `gcs`

By default, local state is used until you uncomment and customize the backend block.

## Version Control and Tagging

Initialize and tag the project:

```bash
git init
git add -A
git commit -m "feat: initial multi-cloud Terraform project"
git tag -a v1.0.0 -m "v1.0.0: Initial multi-cloud Terraform project"
```

Use the helper target to add future tags:

```bash
make tag version=v1.1.0
```

## Directory Structure

```text
terraform-multicloud/
├── modules/
│   ├── aws/
│   ├── azure/
│   └── gcp/
├── environments/
│   ├── dev/
│   ├── qa/
│   ├── stage/
│   └── prod/
├── scripts/
├── versions/
├── .gitignore
├── Makefile
└── README.md
```

## Makefile Targets

- `make deploy` - run the interactive deployment workflow
- `make destroy` - run the interactive destroy workflow
- `make validate` - validate all environment directories
- `make fmt` - run `terraform fmt -recursive`
- `make docs` - placeholder target
- `make tag version=v1.1.0` - create an annotated git tag

## Notes

- Replace placeholder passwords and project IDs in `terraform.tfvars` before deployment.
- Remote backends are intentionally commented out so the project works locally by default.
- Logs are excluded from version control.
