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
# variable "categories" {
#   description = "Habilitar o deshabilitar categorías de dashboard"
#   type = object({
#     compute = optional(bool, true)
#     serverless = optional(bool, true)
#     database = optional(bool, true)
#     storage = optional(bool, true)
#     networking = optional(bool, true)
#   })
#   default = {
#     compute = true
#     serverless = true
#     database = true
#     storage = true
#     networking = true
#   }
# }

###########################################################
# Variables EC2
###########################################################
variable "ec2" {
  description = "Configuración para dashboards y alarmas de EC2"
  type = object({
    functionality    = optional(string,"computo")
    create_dashboard = optional(bool,false)
    create_alarms    = optional(bool,false)
    tag_key          = optional(string,"EnableObservability")
    tag_value        = optional(string, "true")
    metrics          = optional(list(string), ["CPUUtilization", "NetworkIn", "NetworkOut"])
    alarm_config     = optional(list(object({
      metric_name        = string
      threshold          = number
      severity           = optional(string, "warning")
      comparison         = optional(string, "GreaterThanOrEqualToThreshold")
      description        = optional(string)
      actions            = optional(list(string), [])
      evaluation_periods = optional(number, 2)
      period             = optional(number, 300)
      statistic          = optional(string, "Average")
      datapoints_to_alarm = optional(number, 2)
      treat_missing_data  = optional(string, "missing")
    })), [])
  })
  validation {
    condition = (!try(var.ec2.create_alarms, false) || length(try(var.ec2.alarm_config, [])) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración de alarma."
  }
 validation {
    condition = (!try(var.ec2.create_dashboard, false) || length(try(var.ec2.metrics, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'metrics' con al menos una métrica para visualizar."
  }
  
  default = null
}

###########################################################
# Variables RDS/Aurora
###########################################################
variable "rds" {
  description = "Configuración para dashboards y alarmas de RDS"
  type = object({
    functionality    = optional(string,"data")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string,"EnableObservability")
    tag_value        = optional(string, "true")
    metrics          = optional(list(string), ["CPUUtilization", "DatabaseConnections", "FreeableMemory"])
    alarm_config     = optional(list(object({
      metric_name        = string
      threshold          = number
      severity           = optional(string, "warning")
      comparison         = optional(string, "GreaterThanOrEqualToThreshold")
      description        = optional(string)
      actions            = optional(list(string), [])
      evaluation_periods = optional(number, 2)
      period             = optional(number, 300)
      statistic          = optional(string, "Average")
      datapoints_to_alarm = optional(number, 2)
      treat_missing_data  = optional(string, "missing")
    })), [])
  })
  validation {
    condition = (!try(var.rds.create_alarms, false) || length(try(var.rds.alarm_config, [])) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración de alarma."
  }
  
  validation {
    condition = (!try(var.rds.create_dashboard, false) || length(try(var.rds.metrics, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'metrics' con al menos una métrica para visualizar."
  }
  
  default = null
}

###########################################################
# Variables Lambdas
###########################################################
variable "lambda" {
  description = "Configuración para dashboards y alarmas de AWS Lambda"
  type = object({
    functionality    = optional(string, "lambda")
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    metrics          = optional(list(string), ["Invocations", "Duration", "Errors", "Throttles"])
    alarm_config     = optional(list(object({
      metric_name        = string
      threshold          = number
      severity           = optional(string, "warning")
      comparison         = optional(string, "GreaterThanOrEqualToThreshold")
      evaluation_periods = optional(number, 2)
      period             = optional(number, 300)
      statistic          = optional(string, "Average")
      datapoints_to_alarm = optional(number, 2)
      treat_missing_data  = optional(string, "missing")
    })), [])
  })
  validation {
    condition = (!try(var.lambda.create_alarms, false) || length(try(var.lambda.alarm_config, [])) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración."
  }
  validation {
    condition = (!try(var.lambda.create_dashboard, false) || length(try(var.lambda.metrics, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'metrics' con al menos una métrica para visualizar."
  }
  default = null
}

###########################################################
# Variables ALB
###########################################################
variable "alb" {
  description = "Configuración para dashboards y alarmas del Application Load Balancer"
  type = object({
    functionality    = optional(string, "alb")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")
    metrics          = optional(list(string), ["RequestCount", "TargetResponseTime", "HTTPCode_ELB_5XX_Count"])
    alarm_config     = optional(list(object({
      metric_name        = string
      threshold          = number
      severity           = optional(string, "warning")
      comparison         = optional(string, "GreaterThanOrEqualToThreshold")
      evaluation_periods = optional(number, 2)
      period             = optional(number, 300)
      statistic          = optional(string, "Average")
      datapoints_to_alarm = optional(number, 2)
      treat_missing_data  = optional(string, "missing")
    })), [])
  })
  validation {
    condition = (!try(var.alb.create_alarms, false) || length(try(var.alb.alarm_config, [])) > 0 )
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración."
  }

 validation {
    condition = (!try(var.alb.create_dashboard, false) || length(try(var.alb.metrics, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'metrics' con al menos una métrica para visualizar."
  }
  default = null
}

###########################################################
# Variables NLB
###########################################################
variable "nlb" {
  description = "Configuración para dashboards y alarmas de AWS NLB"
  type = object({
    functionality    = optional(string, "nlb")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")
    metrics          = optional(list(string), ["ProcessedBytes", "NewFlowCount", "ActiveFlowCount", "HealthyHostCount"])
    alarm_config     = optional(list(object({
      metric_name        = string
      threshold          = number
      severity           = optional(string, "warning")
      comparison         = optional(string, "GreaterThanOrEqualToThreshold")
      evaluation_periods = optional(number, 2)
      period             = optional(number, 300)
      statistic          = optional(string, "Average")
      datapoints_to_alarm = optional(number, 2)
      treat_missing_data  = optional(string, "missing")
    })), [])
  })
  validation {
    condition = (!try(var.nlb.create_alarms, false) || length(try(var.nlb.alarm_config, [])) > 0 )
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración."
  }
  validation {
    condition = (!try(var.nlb.create_dashboard, false) || length(try(var.nlb.metrics, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'metrics' con al menos una métrica para visualizar."
  }
  default = null
}

###########################################################
# Variables S3
###########################################################
variable "s3" {
  description = "Configuración para dashboards y alarmas de AWS S3"
  type = object({
    functionality    = optional(string, "s3")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")
    metrics          = optional(list(string), ["NumberOfObjects", "BucketSizeBytes"])
    alarm_config     = optional(list(object({
      metric_name        = string
      threshold          = number
      severity           = optional(string, "warning")
      comparison         = optional(string, "GreaterThanOrEqualToThreshold")
      evaluation_periods = optional(number, 2)
      period             = optional(number, 300)
      statistic          = optional(string, "Average")
      datapoints_to_alarm = optional(number, 2)
      treat_missing_data  = optional(string, "missing")
    })), [])
  })
  validation {
    condition = (!try(var.s3.create_alarms, false) || length(try(var.s3.alarm_config, [])) > 0 )
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración."
  }
  validation {
    condition = (!try(var.s3.create_dashboard, false) || length(try(var.s3.metrics, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'metrics' con al menos una métrica para visualizar."
  }
  default = null
}

###########################################################
# Variables Api Gateway
###########################################################
variable "apigateway" {
  description = "Configuración para dashboards y alarmas de API Gateway"
  type = object({
    functionality    = optional(string, "apigateway")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")
    metrics          = optional(list(string), ["Latency", "5XXError", "4XXError", "IntegrationLatency"])
    alarm_config     = optional(list(object({
      metric_name        = string
      threshold          = number
      severity           = optional(string, "warning")
      comparison         = optional(string, "GreaterThanOrEqualToThreshold")
      evaluation_periods = optional(number, 2)
      period             = optional(number, 300)
      statistic          = optional(string, "Average")
      datapoints_to_alarm = optional(number, 2)
      treat_missing_data  = optional(string, "missing")
    })), [])
  })
  validation {
    condition = (!try(var.apigateway.create_alarms, false) || length(try(var.apigateway.alarm_config, [])) > 0 )
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración."
  }
  validation {
    condition = (!try(var.apigateway.create_dashboard, false) || length(try(var.apigateway.metrics, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'metrics' con al menos una métrica para visualizar."
  }
  default = null
}

###########################################################
# Variables Dynamodb
###########################################################
variable "dynamodb" {
  description = "Configuración para dashboards y alarmas de DynamoDB"
  type = object({
    functionality    = optional(string, "dynamodb")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")
    metrics          = optional(list(string), ["ConsumedReadCapacityUnits", "ConsumedWriteCapacityUnits", "ThrottledRequests", "ReadThrottleEvents", "WriteThrottleEvents"])
    # Nuevo campo para configuraciones de alarmas más flexibles
    alarm_config     = optional(list(object({
      metric_name        = string
      threshold          = number
      severity           = optional(string, "warning")
      comparison         = optional(string, "GreaterThanOrEqualToThreshold")
      evaluation_periods = optional(number, 2)
      period             = optional(number, 300)
      statistic          = optional(string, "Average")
      datapoints_to_alarm = optional(number, 2)
      treat_missing_data  = optional(string, "missing")
    })), [])
  })
  validation {
    condition = (!try(var.dynamodb.create_alarms, false) || length(try(var.apigateway.alarm_config, [])) > 0 )
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración."
  }
  validation {
    condition = (!try(var.dynamodb.create_dashboard, false) || length(try(var.apigateway.metrics, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'metrics' con al menos una métrica para visualizar."
  }
  default = null
}