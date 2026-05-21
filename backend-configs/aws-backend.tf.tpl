terraform {
  backend "s3" {
    bucket         = "REPLACE_WITH_YOUR_BUCKET"
    key            = "ENV/CLOUD/terraform.tfstate"
    region         = "REPLACE_WITH_YOUR_REGION"
    dynamodb_table = "REPLACE_WITH_YOUR_TABLE"
    encrypt        = true
  }
}
