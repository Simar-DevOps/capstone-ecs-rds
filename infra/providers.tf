provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "capstone-ecs-rds"
      Owner       = "simar"
      Environment = var.env
    }
  }
}
