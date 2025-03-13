# Variables Globales
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

# Categorías de Dashboard (opcional)
variable "categories" {
  description = "Habilitar o deshabilitar categorías de dashboard"
  type = object({
    compute = optional(bool, true)
    serverless = optional(bool, true)
    database = optional(bool, true)
    storage = optional(bool, true)
    networking = optional(bool, true)
  })
  default = {
    compute = true
    serverless = true
    database = true
    storage = true
    networking = true
  }
}

# EC2
variable "ec2" {
  description = "Configuración para dashboards y alarmas de EC2"
  type = object({
    functionality    = optional(string,"computo")
    create_dashboard = optional(bool,false)
    create_alarms    = optional(bool,false)
    tag_key          = optional(string,"EnableObservability")
    tag_value        = optional(string, "true")
    metrics          = optional(list(string), ["CPUUtilization", "NetworkIn", "NetworkOut"])
    alarm_thresholds = optional(map(number), {})
  })
  validation {
    condition = (!try(var.ec2.create_alarms, false) || length(try(var.ec2.alarm_thresholds, {})) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_thresholds' con al menos un umbral."
  }
  default = null
}

#RDS
variable "rds" {
  description = "Configuración para dashboards y alarmas de RDS"
  type = object({
    functionality    = optional(string,"data")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string,"EnableObservability")
    tag_value        = optional(string, "true")
    metrics          = optional(list(string), ["CPUUtilization", "DatabaseConnections", "FreeableMemory"])
    alarm_thresholds = optional(map(number), {})
  })
  validation {
    condition     = (!try(var.rds.create_alarms, false) || length(try(var.rds.alarm_thresholds, {})) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_thresholds' con al menos un umbral."
  }
  default = null
}

#Lambda
variable "lambda" {
  description = "Configuración para dashboards y alarmas de AWS Lambda"
  type = object({
    functionality    = optional(string, "lambda")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")
    metrics          = optional(list(string), ["Invocations", "Duration", "Errors", "Throttles"])
    alarm_thresholds = optional(map(number), {})
  })
  validation {
    condition     = (!try(var.lambda.create_alarms, false) || length(try(var.lambda.alarm_thresholds, {})) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_thresholds' con al menos un umbral."
  }
  default = null
}

#ALB
variable "alb" {
  description = "Configuración para dashboards y alarmas del Application Load Balancer"
  type = object({
    functionality    = optional(string, "alb")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")
    metrics          = optional(list(string), ["RequestCount", "TargetResponseTime", "HTTPCode_ELB_5XX_Count"])
    alarm_thresholds = optional(map(number), {})
  })
  validation {
    condition     = (!try(var.alb.create_alarms, false) || length(try(var.alb.alarm_thresholds, {})) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_thresholds' con al menos un umbral."
  }
  default = null
}

#NLB
variable "nlb" {
  description = "Configuración para dashboards y alarmas de AWS NLB"
  type = object({
    functionality    = optional(string, "nlb")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")
    metrics          = optional(list(string), ["ProcessedBytes", "NewFlowCount", "ActiveFlowCount", "HealthyHostCount"])
    alarm_thresholds = optional(map(number), {})
  })
  validation {
    condition     = (!try(var.nlb.create_alarms, false) || length(try(var.nlb.alarm_thresholds, {})) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_thresholds' con al menos un umbral."
  }
  default = null
}

#S3
variable "s3" {
  description = "Configuración para dashboards y alarmas de AWS S3"
  type = object({
    functionality    = optional(string, "s3")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")
    metrics          = optional(list(string), ["NumberOfObjects", "BucketSizeBytes"])
    alarm_thresholds = optional(map(number), {})
  })
  validation {
    condition     = (!try(var.s3.create_alarms, false) || length(try(var.s3.alarm_thresholds, {})) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_thresholds' con al menos un umbral."
  }
  default = null
}

#API
variable "apigateway" {
  description = "Configuración para dashboards y alarmas de API Gateway"
  type = object({
    functionality    = optional(string, "apigateway")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")
    metrics          = optional(list(string), ["Latency", "5XXError", "4XXError", "IntegrationLatency"])
    alarm_thresholds = optional(map(number), {})
  })
  default = null
}

#Dynamo
variable "dynamodb" {
  description = "Configuración para dashboards y alarmas de DynamoDB"
  type = object({
    functionality    = optional(string, "dynamodb")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")
    metrics          = optional(list(string), ["ConsumedReadCapacityUnits", "ConsumedWriteCapacityUnits", "ThrottledRequests", "ReadThrottleEvents", "WriteThrottleEvents"])
    alarm_thresholds = optional(map(number), {})
  })
  default = null
}