# 🌍 Terraform Multi-Cloud Infrastructure

## Overview
Terraform scaffolding for AWS, Azure, and GCP across `dev`, `qa`, `stage`, and `prod`. Each stack can deploy VMs, Kubernetes, databases, storage, networking, and optional bastion access using reusable modules.

## Architecture
```text
                         ┌────────────────────────────────────────────────────────┐
                         │                Terraform Environments                 │
                         │        dev | qa | stage | prod per cloud stack       │
                         └────────────────────────────────────────────────────────┘
                                       │
          ┌────────────────────────────┼────────────────────────────┐
          │                            │                            │
          ▼                            ▼                            ▼
   ┌───────────────┐            ┌───────────────┐            ┌───────────────┐
   │      AWS      │            │     Azure     │            │      GCP      │
   │ VPC + subnets │            │ VNet + subnets│            │ VPC + subnets │
   │ NACLs + S3 EP │            │ NSGs + route  │            │ FW + NAT + RT │
   │ Bastion       │            │ Bastion       │            │ Bastion       │
   │ EC2 or EKS    │            │ VM or AKS     │            │ VM or GKE     │
   │ RDS/Aurora    │            │ PG/MySQL/SQL  │            │ Cloud SQL     │
   │ S3            │            │ Blob Storage  │            │ GCS           │
   └───────────────┘            └───────────────┘            └───────────────┘
```

## Prerequisites
- Terraform >= 1.5.0: https://developer.hashicorp.com/terraform/downloads
- AWS CLI: `aws configure`
- Azure CLI: `az login`
- Google Cloud SDK: `gcloud auth application-default login`
- Optional remote-state tools: `gsutil`, `make`, `git`

### Authentication setup
```bash
# AWS
aws configure

# Azure
az login

# GCP
gcloud auth application-default login
gcloud config set project <PROJECT_ID>
```

## Quick Start
```bash
cd ~/Git-Infoblox/REPOS/terraform-multicloud
terraform fmt -recursive
make deploy
```

## Project Structure
```text
terraform-multicloud/
├── backend-configs/
│   ├── aws-backend.tf.tpl
│   ├── azure-backend.tf.tpl
│   └── gcp-backend.tf.tpl
├── environments/
│   ├── dev|qa|stage|prod/
│   │   ├── aws/    # env-specific AWS stack
│   │   ├── azure/  # env-specific Azure stack
│   │   └── gcp/    # env-specific GCP stack
├── logs/           # deploy logs
├── modules/
│   ├── aws/
│   │   ├── bastion/
│   │   ├── compute/
│   │   ├── database/
│   │   ├── eks/
│   │   ├── security-groups/
│   │   ├── storage/
│   │   └── vpc/
│   ├── azure/
│   │   ├── aks/
│   │   ├── bastion/
│   │   ├── compute/
│   │   ├── database/
│   │   ├── storage/
│   │   └── vnet/
│   └── gcp/
│       ├── bastion/
│       ├── compute/
│       ├── database/
│       ├── gke/
│       ├── storage/
│       └── vpc/
├── scripts/
│   ├── bootstrap-backend.sh
│   ├── deploy.sh
│   ├── destroy.sh
│   └── validate.sh
├── versions/
│   └── CHANGELOG.md
├── Makefile
└── README.md
```

## Environment Defaults
| env | clouds | vm_count | instance_size | db_class | multi_az | k8s_nodes |
|---|---|---:|---|---|---|---:|
| dev | aws / azure / gcp | 1 | t3.micro / Standard_B1s / e2-micro | db.t3.micro / Burstable / db-custom-1-3840 | no | 2 |
| qa | aws / azure / gcp | 2 | t3.small / Standard_B2s / e2-small | db.t3.micro / Burstable / db-custom-1-3840 | no | 2 |
| stage | aws / azure / gcp | 3 | t3.medium / Standard_B2ms / e2-medium | db.t3.small / General Purpose / db-custom-2-7680 | yes | 2 |
| prod | aws / azure / gcp | 5 | t3.large / Standard_D4s_v5 / e2-standard-2 | db.t3.medium / General Purpose / db-custom-4-15360 | yes | 2 |

## Deployment Guide

### Option A: Interactive Deploy (Recommended)
```bash
make deploy
# or
./scripts/deploy.sh
```
Prompts cover environment selection, cloud selection, compute mode (VMs / Kubernetes / Both), database engine, VM scaling (1-50), Kubernetes node count (1-50), and action (`plan`, `apply`, or `destroy`).

### Option B: Manual Per-Environment Deploy
```bash
./scripts/bootstrap-backend.sh
cd environments/dev/aws
terraform init
terraform plan -var="vm_count=2" -var="compute_type=vm" -var="db_engine=postgresql"
terraform apply -var="vm_count=2" -var="compute_type=vm" -var="db_engine=postgresql"
```

### Option C: Kubernetes Deployment (EKS/GKE/AKS)
```bash
cd environments/dev/aws
terraform apply -var="compute_type=kubernetes" -var="node_count=3"
aws eks update-kubeconfig --region us-east-1 --name terraform-multicloud-dev-eks
```

### Option D: Deploy Only Specific Cloud
```bash
./scripts/deploy.sh
# choose one cloud interactively

cd environments/prod/gcp
terraform apply
```

## Resources Created Per Cloud

### AWS
| Resource | Module | Variable |
|---|---|---|
| VPC + Subnets + NACLs | `vpc` | `vpc_cidr` |
| Security Groups | `security-groups` | - |
| EC2 Instances | `compute` | `vm_count` (1-50) |
| EKS Cluster | `eks` | `node_count` (1-50) |
| RDS / Aurora | `database` | `db_engine` |
| S3 Bucket | `storage` | `bucket_name_suffix` |
| Bastion Host | `bastion` | `create_bastion=true` |

### Azure
| Resource | Module | Variable |
|---|---|---|
| VNet + subnets + route table | `vnet` | `vnet_cidr` |
| Linux VMs | `compute` | `vm_count` (1-50) |
| AKS Cluster | `aks` | `node_count` (1-50) |
| PostgreSQL / MySQL / Azure SQL | `database` | `db_engine` |
| Storage Account + container | `storage` | `account_tier` |
| Bastion VM | `bastion` | `create_bastion=true` |

### GCP
| Resource | Module | Variable |
|---|---|---|
| VPC + subnets + firewalls + NAT | `vpc` | `vpc_cidr` |
| Compute Engine VMs | `compute` | `vm_count` (1-50) |
| GKE Cluster | `gke` | `node_count` (1-50) |
| Cloud SQL | `database` | `db_engine` |
| GCS Bucket | `storage` | `bucket_name_suffix` |
| Bastion VM | `bastion` | `create_bastion=true` |

## Database Engine Selection
| Cloud | Engines |
|---|---|
| AWS | PostgreSQL, MySQL, SQL Server, Aurora PostgreSQL, Aurora MySQL |
| Azure | PostgreSQL Flexible, MySQL Flexible, Azure SQL |
| GCP | PostgreSQL, MySQL, SQL Server |

## VM / Node Count Scaling
- VMs: set `vm_count` in tfvars or pass `-var="vm_count=25"` (max 50)
- Kubernetes: set `node_count` (max 50)
- Autoscaling knobs: `node_min_count`, `node_max_count`, `enable_auto_scaling`

## SSH Access
When `create_bastion=true`, Terraform provisions a public bastion per cloud.

```bash
# AWS output example
terraform output bastion_ssh_command

# Azure output example
ssh azureadmin@<bastion_public_ip>

# GCP output example
ssh debian@<bastion_public_ip>
```

## State Backend Setup
1. **Local state (default)**: every `backend.tf` starts with a local backend.
2. **Remote state with locking**: run `./scripts/bootstrap-backend.sh`.
3. **Manual backend config**: copy a template from `backend-configs/`, replace values, then run:
```bash
terraform init -migrate-state
```

## State Versioning
- AWS S3 backend bootstrap enables bucket versioning and SSE.
- Azure bootstrap stores state in a blob container inside a dedicated storage account.
- GCP bootstrap enables bucket versioning for rollback-friendly state history.

## Version Control & Tagging
```bash
git tag -a v1.1.0 -m "Added EKS support"
make tag version=v1.2.0
```

## Variable Reference
### Common environment variables
| Variable | Purpose |
|---|---|
| `compute_type` | `vm` or `kubernetes` primary deployment mode |
| `use_kubernetes` | deploy Kubernetes in addition to `compute_type=vm` |
| `create_bastion` | toggles bastion host creation |
| `db_engine` | selects the database engine per cloud |
| `vm_count` | VM count, validated from 1 to 50 |
| `node_count` | Kubernetes node count, validated from 1 to 50 |
| `ssh_allowed_cidrs` | SSH ingress CIDRs for bastion resources |

### AWS-specific additions
`vm_public_key`, `bastion_public_key`, `node_instance_type`, `public_api_access`, `api_allowed_cidrs`

### Azure-specific additions
`bastion_public_key`, `kubernetes_public_key`, `node_vm_size`, `aks_admin_username`, `mysql_version`, `mssql_sku`

### GCP-specific additions
`bastion_public_key`, `node_machine_type`, `release_channel`, `cluster_ipv4_cidr`, `services_ipv4_cidr`, `master_ipv4_cidr_block`

## Makefile Targets
| Target | Description |
|---|---|
| `make deploy` | Run interactive deployment |
| `make destroy` | Run destroy helper |
| `make validate` | Execute validation script |
| `make fmt` | Run `terraform fmt -recursive` |
| `make docs` | Placeholder docs target |
| `make tag version=vX.Y.Z` | Create annotated tag |

## Troubleshooting
- **Aurora selected with non-AWS clouds**: use AWS only, or switch to PostgreSQL/MySQL.
- **AKS / bastion SSH key errors**: set `bastion_public_key` and/or `kubernetes_public_key` in tfvars or CLI overrides.
- **Cloud SQL private networking errors**: ensure the selected project and VPC allow private service access.
- **Remote backend auth failures**: verify `aws`, `az`, or `gcloud/gsutil` authentication before running `bootstrap-backend.sh`.
- **Large deployments**: scale `vm_count` and `node_count` gradually and use `terraform plan` first.
