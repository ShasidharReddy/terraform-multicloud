# Local state is used by default.
# Uncomment and customize the block below to use Azure Blob Storage remote state.
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-tfstate"
#     storage_account_name = "tfstatestorage"
#     container_name       = "tfstate"
#     key                  = "stage/azure/terraform.tfstate"
#   }
# }
