aws_region         = "us-east-1"
profile            = "pra_chaptercloudops_lab"
environment        = "dev"
client             = "pragma"
project            = "hefesto"
application        = "dashboard"

common_tags = {
  environment  = "dev"
  project-name = "Modulos Referencia"
  cost-center  = "-"
  owner        = "cristian.noguera@pragma.com.co"
  area         = "KCCC"
  provisioned  = "terraform"
  datatype     = "interno"
}
