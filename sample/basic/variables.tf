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

