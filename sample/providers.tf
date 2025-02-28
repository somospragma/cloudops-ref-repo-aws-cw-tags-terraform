######################################################################
# Provaider AWS
######################################################################

provider "aws" {
  region  = var.aws_region
  profile = var.profile

  default_tags {
    tags = var.common_tags
  }
}
