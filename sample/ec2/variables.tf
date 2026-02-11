######################################################################
# Variable Provider
######################################################################

######################################################################
# Region Produccion - Virginia
######################################################################
variable "aws_region" {
  type = string
  description = "AWS region where resources will be deployed"
}

######################################################################
# Profile
######################################################################

variable "profile" {
  type = string
  description = "AWS Profile"
}

######################################################################
# Variable Globales 
######################################################################
variable "common_tags" {
  type = map(string)
  description = "Common tags to be applied to the resources"
}

variable "client" {
  type = string
}

variable "environment" {
  type = string
}

variable "project" {
  type = string  
}


variable "application" {
  type = string  
}

###########################################################
# Variables SNS Topics (Opcional)
###########################################################

variable "sns_topic_warning" {
  type        = string
  description = "ARN del SNS topic para alarmas de severidad WARNING"
  default     = "arn:aws:sns:us-east-1:123456789012:alert-warning"
}

variable "sns_topic_critical" {
  type        = string
  description = "ARN del SNS topic para alarmas de severidad CRITICAL"
  default     = "arn:aws:sns:us-east-1:123456789012:alert-critical"
}

###########################################################
# Variables CloudWatch Agent (Disco) - OPCIONAL
###########################################################

variable "monitor_disks" {
  type = list(object({
    path   = string  # Path del disco (ej: /, /data, /var)
    device = string  # Device (ej: nvme0n1p1, nvme1n1, xvda1)
    fstype = string  # Filesystem type (ej: xfs, ext4)
  }))
  description = <<-EOT
    Lista de discos a monitorear con CloudWatch Agent.
    Si está vacía, NO se crearán alarmas de disco (solo CPU y Memoria).
    
    Para obtener los valores, ejecuta en tu EC2:
      df -h        # Ver path y device
      lsblk -f     # Ver fstype
    
    Ejemplos:
      - EC2 modernas (Nitro): device = "nvme0n1p1", fstype = "xfs"
      - EC2 antiguas:         device = "xvda1", fstype = "ext4"
  EOT
  default = [
    {
      path   = "/"
      device = "nvme0n1p1"
      fstype = "xfs"
    }
  ]
}

