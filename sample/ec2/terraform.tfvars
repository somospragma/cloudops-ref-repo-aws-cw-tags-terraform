###########################################################
# Provider Configuration
###########################################################
aws_region = "us-east-1"
profile    = "pra_chaptercloudops_lab"

###########################################################
# Global Variables
###########################################################
client      = "pragma"
project     = "hefesto"
environment = "dev"
application = "dashboard"

###########################################################
# Common Tags
###########################################################
common_tags = {
  environment  = "dev"
  project-name = "Modulos Referencia"
  cost-center  = "-"
  owner        = "cristian.noguera@pragma.com.co"
  area         = "KCCC"
  provisioned  = "terraform"
  datatype     = "interno"
}

###########################################################
# SNS Topics para Alarmas
# IMPORTANTE: Reemplazar con tus ARNs reales de SNS
###########################################################
sns_topic_warning  = "arn:aws:sns:us-east-1:123456789012:alert-warning"
sns_topic_critical = "arn:aws:sns:us-east-1:123456789012:alert-critical"

###########################################################
# CloudWatch Agent - Configuración de Disco
# 
# Para obtener los valores correctos, ejecuta en tu EC2:
#   df -h        # Para ver path y device
#   lsblk -f     # Para ver fstype
#
# Ejemplos comunes:
#   - EC2 modernas (Nitro): device = "nvme0n1p1", fstype = "xfs"
#   - EC2 antiguas:         device = "xvda1", fstype = "ext4"
###########################################################
disk_path   = "/"
disk_device = "nvme0n1p1"
disk_fstype = "xfs"
