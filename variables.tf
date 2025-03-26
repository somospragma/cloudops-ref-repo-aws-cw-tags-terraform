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

###########################################################
# Variables EC2
###########################################################
variable "ec2" {
  description = "Configuración para dashboards y alarmas de EC2"
  type = object({
    functionality    = optional(string, "computo")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")

    # Configuración para los widgets del dashboard
    dashboard_config = optional(list(object({
      metric_name = string
      period      = optional(number, 300)
      statistic   = optional(string, "Average")
      width       = optional(number, 12)
      height      = optional(number, 6)
      title       = optional(string)
    })), [])

    alarm_config = optional(list(object({
      metric_name               = string
      threshold                 = number
      severity                  = optional(string, "warning")
      comparison                = optional(string, "GreaterThanOrEqualToThreshold")
      description               = optional(string)
      actions                   = optional(list(string), [])
      alarm_actions             = optional(list(string), [])
      insufficient_data_actions = optional(list(string), [])
      ok_actions                = optional(list(string), [])
      evaluation_periods        = optional(number, 2)
      period                    = optional(number, 300)
      statistic                 = optional(string, "Average")
      datapoints_to_alarm       = optional(number, 2)
      treat_missing_data        = optional(string, "missing")
    })), [])
  })

  validation {
    condition     = (!try(var.ec2.create_alarms, false) || length(try(var.ec2.alarm_config, [])) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración de alarma."
  }

  validation {
    condition     = (!try(var.ec2.create_dashboard, false) || length(try(var.ec2.dashboard_config, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'dashboard_config' con al menos una métrica para visualizar."
  }

  default = null
}

###########################################################
# Variables RDS/Aurora
###########################################################
variable "rds" {
  description = "Configuración para dashboards y alarmas de RDS"
  type = object({
    functionality    = optional(string, "data")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")

    # Configuración para los widgets del dashboard
    dashboard_config = optional(list(object({
      metric_name = string
      period      = optional(number, 300)
      statistic   = optional(string, "Average")
      width       = optional(number, 12)
      height      = optional(number, 6)
      title       = optional(string)
    })), [])

    # Configuración para las alarmas
    alarm_config = optional(list(object({
      metric_name               = string
      threshold                 = number
      severity                  = optional(string, "warning")
      comparison                = optional(string, "GreaterThanOrEqualToThreshold")
      description               = optional(string)
      actions                   = optional(list(string), [])
      alarm_actions             = optional(list(string), [])
      insufficient_data_actions = optional(list(string), [])
      ok_actions                = optional(list(string), [])
      evaluation_periods        = optional(number, 2)
      period                    = optional(number, 300)
      statistic                 = optional(string, "Average")
      datapoints_to_alarm       = optional(number, 2)
      treat_missing_data        = optional(string, "missing")
    })), [])
  })

  validation {
    condition     = (!try(var.rds.create_alarms, false) || length(try(var.rds.alarm_config, [])) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración de alarma."
  }

  validation {
    condition     = (!try(var.rds.create_dashboard, false) || length(try(var.rds.dashboard_config, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'dashboard_config' con al menos una métrica para visualizar."
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

    # Configuración para los widgets del dashboard
    dashboard_config = optional(list(object({
      metric_name = string
      period      = optional(number, 300)
      statistic   = optional(string, "Average")
      width       = optional(number, 12)
      height      = optional(number, 6)
      title       = optional(string)
    })), [])

    # Configuración para las alarmas
    alarm_config = optional(list(object({
      metric_name               = string
      threshold                 = number
      severity                  = optional(string, "warning")
      comparison                = optional(string, "GreaterThanOrEqualToThreshold")
      description               = optional(string)
      actions                   = optional(list(string), [])
      alarm_actions             = optional(list(string), [])
      insufficient_data_actions = optional(list(string), [])
      ok_actions                = optional(list(string), [])
      evaluation_periods        = optional(number, 2)
      period                    = optional(number, 300)
      statistic                 = optional(string, "Average")
      datapoints_to_alarm       = optional(number, 2)
      treat_missing_data        = optional(string, "missing")
    })), [])
  })

  validation {
    condition     = (!try(var.lambda.create_alarms, false) || length(try(var.lambda.alarm_config, [])) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración."
  }

  validation {
    condition     = (!try(var.lambda.create_dashboard, false) || length(try(var.lambda.dashboard_config, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'dashboard_config' con al menos una métrica para visualizar."
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

    dashboard_config = optional(list(object({
      metric_name = string
      period      = optional(number, 300)
      statistic   = optional(string, "Average")
      width       = optional(number, 12)
      height      = optional(number, 6)
      title       = optional(string)
    })), [])

    alarm_config = optional(list(object({
      metric_name               = string
      threshold                 = number
      severity                  = optional(string, "warning")
      comparison                = optional(string, "GreaterThanOrEqualToThreshold")
      description               = optional(string)
      actions                   = optional(list(string), [])
      alarm_actions             = optional(list(string), [])
      insufficient_data_actions = optional(list(string), [])
      ok_actions                = optional(list(string), [])
      evaluation_periods        = optional(number, 2)
      period                    = optional(number, 300)
      statistic                 = optional(string, "Average")
      datapoints_to_alarm       = optional(number, 2)
      treat_missing_data        = optional(string, "missing")
    })), [])
  })

  validation {
    condition     = (!try(var.alb.create_alarms, false) || length(try(var.alb.alarm_config, [])) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración."
  }

  validation {
    condition     = (!try(var.alb.create_dashboard, false) || length(try(var.alb.dashboard_config, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'dashboard_config' con al menos una métrica para visualizar."
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

    # Configuración para los widgets del dashboard
    dashboard_config = optional(list(object({
      metric_name = string
      period      = optional(number, 300)
      statistic   = optional(string, "Average")
      width       = optional(number, 12)
      height      = optional(number, 6)
      title       = optional(string)
    })), [])

    # Configuración para las alarmas
    alarm_config = optional(list(object({
      metric_name               = string
      threshold                 = number
      severity                  = optional(string, "warning")
      comparison                = optional(string, "GreaterThanOrEqualToThreshold")
      description               = optional(string)
      actions                   = optional(list(string), [])
      alarm_actions             = optional(list(string), [])
      insufficient_data_actions = optional(list(string), [])
      ok_actions                = optional(list(string), [])
      evaluation_periods        = optional(number, 2)
      period                    = optional(number, 300)
      statistic                 = optional(string, "Average")
      datapoints_to_alarm       = optional(number, 2)
      treat_missing_data        = optional(string, "missing")
    })), [])
  })

  validation {
    condition     = (!try(var.nlb.create_alarms, false) || length(try(var.nlb.alarm_config, [])) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración."
  }

  validation {
    condition     = (!try(var.nlb.create_dashboard, false) || length(try(var.nlb.dashboard_config, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'dashboard_config' con al menos una métrica para visualizar."
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

    # Configuración para los widgets del dashboard
    dashboard_config = optional(list(object({
      metric_name  = string
      period       = optional(number, 300)
      statistic    = optional(string, "Average")
      storage_type = optional(string) # Solo para S3
      width        = optional(number, 12)
      height       = optional(number, 6)
      title        = optional(string)
    })), [])

    # Configuración para las alarmas
    alarm_config = optional(list(object({
      metric_name               = string
      threshold                 = number
      severity                  = optional(string, "warning")
      comparison                = optional(string, "GreaterThanOrEqualToThreshold")
      description               = optional(string)
      actions                   = optional(list(string), [])
      alarm_actions             = optional(list(string), [])
      insufficient_data_actions = optional(list(string), [])
      ok_actions                = optional(list(string), [])
      evaluation_periods        = optional(number, 2)
      period                    = optional(number, 300)
      statistic                 = optional(string, "Average")
      datapoints_to_alarm       = optional(number, 2)
      treat_missing_data        = optional(string, "missing")
    })), [])
  })

  validation {
    condition     = (!try(var.s3.create_alarms, false) || length(try(var.s3.alarm_config, [])) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración."
  }

  validation {
    condition     = (!try(var.s3.create_dashboard, false) || length(try(var.s3.dashboard_config, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'dashboard_config' con al menos una métrica para visualizar."
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

    # Configuración para los widgets del dashboard
    dashboard_config = optional(list(object({
      metric_name = string
      period      = optional(number, 300)
      statistic   = optional(string, "Average")
      width       = optional(number, 12)
      height      = optional(number, 6)
      title       = optional(string)
    })), [])

    # Configuración para las alarmas
    alarm_config = optional(list(object({
      metric_name               = string
      threshold                 = number
      severity                  = optional(string, "warning")
      comparison                = optional(string, "GreaterThanOrEqualToThreshold")
      description               = optional(string)
      actions                   = optional(list(string), [])
      alarm_actions             = optional(list(string), [])
      insufficient_data_actions = optional(list(string), [])
      ok_actions                = optional(list(string), [])
      evaluation_periods        = optional(number, 2)
      period                    = optional(number, 300)
      statistic                 = optional(string, "Average")
      datapoints_to_alarm       = optional(number, 2)
      treat_missing_data        = optional(string, "missing")
    })), [])
  })

  validation {
    condition     = (!try(var.apigateway.create_alarms, false) || length(try(var.apigateway.alarm_config, [])) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración."
  }

  validation {
    condition     = (!try(var.apigateway.create_dashboard, false) || length(try(var.apigateway.dashboard_config, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'dashboard_config' con al menos una métrica para visualizar."
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

    # Configuración para los widgets del dashboard
    dashboard_config = optional(list(object({
      metric_name = string
      period      = optional(number, 300)
      statistic   = optional(string, "Average")
      width       = optional(number, 12)
      height      = optional(number, 6)
      title       = optional(string)
    })), [])

    # Configuración para las alarmas
    alarm_config = optional(list(object({
      metric_name               = string
      threshold                 = number
      severity                  = optional(string, "warning")
      comparison                = optional(string, "GreaterThanOrEqualToThreshold")
      description               = optional(string)
      actions                   = optional(list(string), [])
      alarm_actions             = optional(list(string), [])
      insufficient_data_actions = optional(list(string), [])
      ok_actions                = optional(list(string), [])
      evaluation_periods        = optional(number, 2)
      period                    = optional(number, 300)
      statistic                 = optional(string, "Average")
      datapoints_to_alarm       = optional(number, 2)
      treat_missing_data        = optional(string, "missing")
    })), [])
  })

  validation {
    condition     = (!try(var.dynamodb.create_alarms, false) || length(try(var.dynamodb.alarm_config, [])) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración."
  }

  validation {
    condition     = (!try(var.dynamodb.create_dashboard, false) || length(try(var.dynamodb.dashboard_config, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'dashboard_config' con al menos una métrica para visualizar."
  }

  default = null
}

###########################################################
# Variables ECS
###########################################################

variable "ecs" {
  description = "Configuración para dashboards y alarmas de ECS (métricas estándar)"
  type = object({
    functionality    = optional(string, "ecs")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")

    dashboard_config = optional(list(object({
      metric_name    = string
      dimension_name = optional(string, "ClusterName") # ClusterName o ServiceName
      period         = optional(number, 300)
      statistic      = optional(string, "Average")
      width          = optional(number, 12)
      height         = optional(number, 6)
      title          = optional(string)
    })), [])

    # Configuración para alarmas específicas
    alarm_config = optional(list(object({
      metric_name               = string
      dimension_name            = optional(string, "ClusterName")
      dimension_value           = string
      threshold                 = number
      severity                  = optional(string, "warning")
      comparison                = optional(string, "GreaterThanOrEqualToThreshold")
      description               = optional(string)
      alarm_actions             = optional(list(string), [])
      insufficient_data_actions = optional(list(string), [])
      ok_actions                = optional(list(string), [])
      evaluation_periods        = optional(number, 2)
      period                    = optional(number, 300)
      statistic                 = optional(string, "Average")
      datapoints_to_alarm       = optional(number, 2)
      treat_missing_data        = optional(string, "missing")
    })), []),

    # Plantillas de alarmas que se aplicarán a todos los servicios descubiertos
    service_alarm_templates = optional(list(object({
      metric_name               = string
      threshold                 = number
      severity                  = optional(string, "warning")
      comparison                = optional(string, "GreaterThanOrEqualToThreshold")
      description               = optional(string)
      alarm_actions             = optional(list(string), [])
      insufficient_data_actions = optional(list(string), [])
      ok_actions                = optional(list(string), [])
      evaluation_periods        = optional(number, 2)
      period                    = optional(number, 300)
      statistic                 = optional(string, "Average")
      datapoints_to_alarm       = optional(number, 2)
      treat_missing_data        = optional(string, "missing")
    })), [])
  })

  validation {
    condition = (!try(var.ecs.create_alarms, false) ||
      length(try(var.ecs.alarm_config, [])) > 0 ||
    length(try(var.ecs.service_alarm_templates, [])) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' o 'service_alarm_templates' con al menos una configuración."
  }

  validation {
    condition     = (!try(var.ecs.create_dashboard, false) || length(try(var.ecs.dashboard_config, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'dashboard_config' con al menos una métrica para visualizar."
  }

  default = null
}

###########################################################
# Variables ECS Insights
###########################################################

variable "ecs_insights" {
  description = "Configuración para dashboards y alarmas de ECS Container Insights (métricas avanzadas)"
  type = object({
    functionality    = optional(string, "ecs_insights")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    tag_key          = optional(string, "EnableObservability")
    tag_value        = optional(string, "true")

    dashboard_config = optional(list(object({
      metric_name    = string
      dimension_name = optional(string, "ClusterName")
      period         = optional(number, 300)
      statistic      = optional(string, "Average")
      width          = optional(number, 12)
      height         = optional(number, 6)
      title          = optional(string)
    })), [])

    # Configuración para alarmas específicas
    alarm_config = optional(list(object({
      metric_name               = string
      dimension_name            = optional(string, "ClusterName")
      dimension_value           = string
      threshold                 = number
      severity                  = optional(string, "warning")
      comparison                = optional(string, "GreaterThanOrEqualToThreshold")
      description               = optional(string)
      alarm_actions             = optional(list(string), [])
      insufficient_data_actions = optional(list(string), [])
      ok_actions                = optional(list(string), [])
      evaluation_periods        = optional(number, 2)
      period                    = optional(number, 300)
      statistic                 = optional(string, "Average")
      datapoints_to_alarm       = optional(number, 2)
      treat_missing_data        = optional(string, "missing")
      cluster_name              = optional(string)
    })), [])

    # Plantillas de alarmas que se aplicarán a todos los servicios descubiertos
    service_alarm_templates = optional(list(object({
      metric_name               = string
      threshold                 = number
      severity                  = optional(string, "warning")
      comparison                = optional(string, "GreaterThanOrEqualToThreshold")
      description               = optional(string)
      alarm_actions             = optional(list(string), [])
      insufficient_data_actions = optional(list(string), [])
      ok_actions                = optional(list(string), [])
      evaluation_periods        = optional(number, 2)
      period                    = optional(number, 300)
      statistic                 = optional(string, "Average")
      datapoints_to_alarm       = optional(number, 2)
      treat_missing_data        = optional(string, "missing")
    })), [])
  })

  validation {
    condition = (!try(var.ecs_insights.create_alarms, false) ||
      length(try(var.ecs_insights.alarm_config, [])) > 0 ||
    length(try(var.ecs_insights.service_alarm_templates, [])) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' o 'service_alarm_templates' con al menos una configuración."
  }

  validation {
    condition     = (!try(var.ecs_insights.create_dashboard, false) || length(try(var.ecs_insights.dashboard_config, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'dashboard_config' con al menos una métrica para visualizar."
  }

  default = null
}


###########################################################
# Variables WAF
###########################################################
variable "waf" {
  description = "Configuración para dashboards y alarmas de AWS WAF"
  type = object({
    functionality    = optional(string, "waf")
    create_dashboard = optional(bool, false)
    create_alarms    = optional(bool, false)
    
    # Lista de Web ACLs a monitorear
    web_acls = list(object({
      name  = string               # Nombre de la Web ACL
      id    = optional(string)     # ID de la Web ACL (si se omite, se usará el nombre)
      scope = string               # "REGIONAL" o "CLOUDFRONT"
      region = optional(string)    # Región (requerido solo para REGIONAL)
    }))
    
    # Configuración para los widgets del dashboard
    dashboard_config = optional(list(object({
      metric_name  = string
      period       = optional(number, 300)
      statistic    = optional(string, "Sum")
      width        = optional(number, 12)
      height       = optional(number, 6)
      title        = optional(string)
    })), [])
    
    # Configuración para las alarmas
    alarm_config = optional(list(object({
      metric_name               = string
      threshold                 = number
      severity                  = optional(string, "warning")
      comparison                = optional(string, "GreaterThanOrEqualToThreshold")
      description               = optional(string)
      actions                   = optional(list(string), [])
      alarm_actions             = optional(list(string), [])
      insufficient_data_actions = optional(list(string), [])
      ok_actions                = optional(list(string), [])
      evaluation_periods        = optional(number, 2)
      period                    = optional(number, 300)
      statistic                 = optional(string, "Sum")
      datapoints_to_alarm       = optional(number, 2)
      treat_missing_data        = optional(string, "missing")
    })), [])
  })
  
  validation {
    condition     = (!try(var.waf.create_alarms, false) || length(try(var.waf.alarm_config, [])) > 0)
    error_message = "Si 'create_alarms' es 'true', debes proporcionar 'alarm_config' con al menos una configuración de alarma."
  }
  
  validation {
    condition     = (!try(var.waf.create_dashboard, false) || length(try(var.waf.dashboard_config, [])) > 0)
    error_message = "Si 'create_dashboard' es 'true', debes proporcionar 'dashboard_config' con al menos una métrica para visualizar."
  }

  validation {
    condition     = var.waf == null || length(try(var.waf.web_acls, [])) > 0
    error_message = "Debes proporcionar al menos una Web ACL para monitorear."
  }
  
  validation {
    condition     = var.waf == null || length([for acl in try(var.waf.web_acls, []) : acl if acl.scope == "REGIONAL" && try(acl.region, "") == ""]) == 0
    error_message = "Para Web ACLs con scope 'REGIONAL', debes especificar la región."
  }

  default = null
}