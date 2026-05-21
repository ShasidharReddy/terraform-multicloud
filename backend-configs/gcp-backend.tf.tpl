terraform {
  backend "gcs" {
    bucket = "REPLACE_WITH_YOUR_BUCKET"
    prefix = "ENV/CLOUD/terraform.tfstate"
  }
}
