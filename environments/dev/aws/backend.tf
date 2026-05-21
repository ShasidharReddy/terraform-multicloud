# Local backend (default - no state locking)
# To use remote backend with locking, replace this block with the appropriate
# template from backend-configs/ directory, then run: terraform init -migrate-state
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# ── AWS REMOTE BACKEND (uncomment and fill values after running bootstrap-backend.sh) ──
# terraform {
#   backend "s3" {
#     bucket         = "your-tfstate-bucket-name"
#     key            = "dev/aws/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "your-tfstate-lock-table"
#     encrypt        = true
#   }
# }
