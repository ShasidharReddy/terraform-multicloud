# Local backend (default - no state locking)
# To use remote backend with locking, replace this block with the appropriate
# template from backend-configs/ directory, then run: terraform init -migrate-state
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# ── GCP REMOTE BACKEND (uncomment and fill values after running bootstrap-backend.sh) ──
# terraform {
#   backend "gcs" {
#     bucket = "your-tfstate-bucket-name"
#     prefix = "dev/gcp/terraform.tfstate"
#   }
# }
