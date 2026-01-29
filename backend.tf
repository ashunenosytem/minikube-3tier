terraform {
  backend "s3" {
    bucket         = "my-terraform-states-3tier"
    key            = "minikube-3tier/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
