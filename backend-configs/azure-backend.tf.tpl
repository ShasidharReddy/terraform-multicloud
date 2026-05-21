terraform {
  backend "azurerm" {
    resource_group_name  = "REPLACE_WITH_RG"
    storage_account_name = "REPLACE_WITH_SA"
    container_name       = "tfstate"
    key                  = "ENV/CLOUD/terraform.tfstate"
  }
}
