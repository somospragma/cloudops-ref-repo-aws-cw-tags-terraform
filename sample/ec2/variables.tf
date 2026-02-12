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
  description = "ARN del SNS topic para alarmas de severidad WARNING (opcional, dejar vacío para no enviar notificaciones)"
  default     = ""
}

variable "sns_topic_critical" {
  type        = string
  description = "ARN del SNS topic para alarmas de severidad CRITICAL (opcional, dejar vacío para no enviar notificaciones)"
  default     = ""
}

###########################################################
# Variables CloudWatch Agent (Disco)
###########################################################

variable "disk_path" {
  type        = string
  description = "Path del disco a monitorear (ej: /, /data)"
  default     = "/"
}

variable "disk_device" {
  type        = string
  description = "Device del disco (ej: nvme0n1p1 para EC2 modernas, xvda1 para antiguas)"
  default     = "nvme0n1p1"
}

variable "disk_fstype" {
  type        = string
  description = "Tipo de filesystem (ej: xfs, ext4)"
  default     = "xfs"
}

