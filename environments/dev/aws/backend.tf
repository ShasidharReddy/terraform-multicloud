# Local state is used by default.
# Uncomment and customize the block below to use S3 remote state.
# terraform {
#   backend "s3" {
#     bucket         = "my-terraform-state-bucket"
#     key            = "dev/aws/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }
