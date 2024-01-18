provider "aws" {
  region  = var.aws_region
#   profile = default
  
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.33.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "mediawikirohit"
    key    = "path/tf.state"
    region =  "ap-south-1"
    encrypt = true
  }
}
resource "aws_ecs_cluster" "mediawiki_cluster" {
  name = "mediaiwiki-cluster"
}
resource "aws_ecs_cluster" "foo" {
  name = "snipe-cluster"
}
module "mediawiki-alb" {
  source = "./module/aws_alb_tg"
  alb_name = "alb-with-terra"
  tg_name = "tg-with-terra"
  
}
