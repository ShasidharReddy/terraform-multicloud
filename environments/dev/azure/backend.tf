# Local backend (default - no state locking)
# To use remote backend with locking, replace this block with the appropriate
# template from backend-configs/ directory, then run: terraform init -migrate-state
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# ── AZURE REMOTE BACKEND (uncomment and fill values after running bootstrap-backend.sh) ──
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "your-backend-rg"
#     storage_account_name = "yourstorageaccount"
#     container_name       = "tfstate"
#     key                  = "dev/azure/terraform.tfstate"
#   }
# }
