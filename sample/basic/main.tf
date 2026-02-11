module "observability" {
  source = "../../"

  client      = "acme"
  project     = "ecommerce"
  environment = "production"
  application = "webstore"

  # Container Insights para monitoreo completo de ECS
  ecs = {
    functionality    = "ecs_insights"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"

    dashboard_config = [
      # Métricas a nivel de Cluster
      {
        metric_name    = "CPUUtilization"
        dimension_name = "ServiceName"
        period         = 300
        statistic      = "Average"
        title          = "Utilización de CPU por Servicio (CI)"
        width          = 12
        height         = 6
      },
      {
        metric_name    = "MemoryUtilization"
        dimension_name = "ServiceName"
        period         = 300
        statistic      = "Average"
        title          = "Utilización de Memoria por Servicio (CI)"
        width          = 12
        height         = 6
      }
    ]

    service_alarm_templates = [
      {
        metric_name        = "CPUUtilization"
        threshold          = 80
        severity           = "warning"
        comparison         = "GreaterThanOrEqualToThreshold"
        description        = "Porcentaje de CPU por encima del 80% (warning)"
        alarm_actions             = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        ok_actions                = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        evaluation_periods = 3
        period             = 300
        statistic          = "Average"
      },
      {
        metric_name        = "CPUUtilization"
        threshold          = 90
        severity           = "critical"
        comparison         = "GreaterThanOrEqualToThreshold"
        description        = "Porcentaje de CPU por encima del 90% (critical)"
        alarm_actions             = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        ok_actions                = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        evaluation_periods = 3
        period             = 300
        statistic          = "Average"
      },

      {
        metric_name        = "MemoryUtilization"
        threshold          = 80
        severity           = "warning"
        comparison         = "GreaterThanOrEqualToThreshold"
        description        = "Porcentaje de memoria por encima del 80% (warning)"
        alarm_actions             = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        ok_actions                = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        evaluation_periods = 3
        period             = 300
        statistic          = "Average"
      },
      {
        metric_name        = "MemoryUtilization"
        threshold          = 90
        severity           = "critical"
        comparison         = "GreaterThanOrEqualToThreshold"
        description        = "Porcentaje de memoria por encima del 90% (critical)"
        alarm_actions             = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        ok_actions                = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        evaluation_periods = 3
        period             = 300
        statistic          = "Average"
      }
    ]
  }
  ecs_insights = {
    create_dashboard = true
    create_alarms    = false
    tag_key          = "EnableObservability"
    tag_value        = "true"

    dashboard_config = [
      {
        metric_name    = "CpuUtilized"
        dimension_name = "ClusterName"
        period         = 300
        statistic      = "Average"
        title          = "CPU Utilizada por Cluster"
        width          = 12
        height         = 6
      },
      {
        metric_name    = "MemoryUtilized"
        dimension_name = "ClusterName"
        period         = 300
        statistic      = "Average"
        title          = "Memoria Utilizada por Cluster"
        width          = 12
        height         = 6
      }
    ]
  }
  rds = {
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"

    # Configuración del dashboard de Aurora RDS
    dashboard_config = [
      # CPU Utilization
      {
        metric_name = "CPUUtilization"
        period      = 300
        statistic   = "Average"
        width       = 12
        height      = 6
        title       = "Aurora RDS - CPU Utilization (%)"
      },
      # Freeable Memory
      {
        metric_name = "FreeableMemory"
        period      = 300
        statistic   = "Average"
        width       = 12
        height      = 6
        title       = "Aurora RDS - Freeable Memory (Bytes)"
      },
      # Database Connections
      {
        metric_name = "DatabaseConnections"
        period      = 300
        statistic   = "Average"
        width       = 12
        height      = 6
        title       = "Aurora RDS - Database Connections"
      },
      # Read IOPs
      {
        metric_name = "ReadIOPS"
        period      = 300
        statistic   = "Average"
        width       = 12
        height      = 6
        title       = "Aurora RDS - Read IOPS"
      },
      # Write IOPs
      {
        metric_name = "WriteIOPS"
        period      = 300
        statistic   = "Average"
        width       = 12
        height      = 6
        title       = "Aurora RDS - Write IOPS"
      }
    ],

    # Configuración de alarmas para Aurora RDS
    alarm_config = [
      # CPU Utilization - Warning
      {
        metric_name         = "CPUUtilization"
        threshold           = 75
        severity            = "warning"
        comparison          = "GreaterThanOrEqualToThreshold"
        description         = "Aurora RDS CPU utilization is above 75%"
        alarm_actions             = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        ok_actions                = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        evaluation_periods  = 3
        period              = 300
        statistic           = "Average"
        datapoints_to_alarm = 3
        treat_missing_data  = "missing"
      },
      # CPU Utilization - Critical
      {
        metric_name         = "CPUUtilization"
        threshold           = 90
        severity            = "critical"
        comparison          = "GreaterThanOrEqualToThreshold"
        description         = "Aurora RDS CPU utilization is above 90%"
        alarm_actions             = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        ok_actions                = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        evaluation_periods  = 3
        period              = 300
        statistic           = "Average"
        datapoints_to_alarm = 2
        treat_missing_data  = "missing"
      },
      # Freeable Memory - Warning
      {
        metric_name         = "FreeableMemory"
        threshold           = 2000000000 # 2 GB en bytes
        severity            = "warning"
        comparison          = "LessThanOrEqualToThreshold"
        description         = "Aurora RDS Freeable Memory is below 2GB"
        alarm_actions             = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        ok_actions                = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        evaluation_periods  = 3
        period              = 300
        statistic           = "Average"
        datapoints_to_alarm = 3
        treat_missing_data  = "missing"
      },
      # Freeable Memory - Critical
      {
        metric_name               = "FreeableMemory"
        threshold                 = 1000000000 # 1 GB en bytes
        severity                  = "critical"
        comparison                = "LessThanOrEqualToThreshold"
        description               = "Aurora RDS Freeable Memory is below 1GB"
        alarm_actions             = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        ok_actions                = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        evaluation_periods        = 3
        period                    = 300
        statistic                 = "Average"
        datapoints_to_alarm       = 2
        treat_missing_data        = "missing"
      },
      # Database Connections - Warning
      {
        metric_name         = "DatabaseConnections"
        threshold           = 450 # Ajusta según los límites de tu instancia
        severity            = "warning"
        comparison          = "GreaterThanOrEqualToThreshold"
        description         = "Aurora RDS Database Connections are above 450"
        alarm_actions             = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        ok_actions                = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        evaluation_periods  = 3
        period              = 300
        statistic           = "Average"
        datapoints_to_alarm = 3
        treat_missing_data  = "missing"
      },
      # Database Connections - Critical
      {
        metric_name         = "DatabaseConnections"
        threshold           = 500 # Ajusta según los límites de tu instancia
        severity            = "critical"
        comparison          = "GreaterThanOrEqualToThreshold"
        description         = "Aurora RDS Database Connections are above 500"
        alarm_actions             = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        ok_actions                = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        evaluation_periods  = 3
        period              = 300
        statistic           = "Average"
        datapoints_to_alarm = 2
        treat_missing_data  = "missing"
      }
    ]
  }

  waf = {
    create_dashboard = true
    create_alarms    = true
    
    # Especificar explícitamente las Web ACLs a monitorear
    web_acls = [
      {
        name  = "waf-regional"
        id    = "39a849f8-213b-477f-8e1f-00f944fe4c01"
        scope = "REGIONAL"
        region = "us-east-1"
        # No se necesita 'region' para scope CLOUDFRONT
      },
      # Ejemplo WAF Regional
      {
        name   = "waf-global"
        id     = "27cfea59-8029-414e-9778-a1249d34565f"
        scope  = "GLOBAL"
        #region = "us-east-1"
      }
    ]
    
    # Configuración del dashboard para WAF
    dashboard_config = [
      {
        metric_name = "AllowedRequests",
        statistic   = "Sum",
        title       = "Solicitudes Permitidas"
      },
      {
        metric_name = "BlockedRequests",
        statistic   = "Sum",
        title       = "Solicitudes Bloqueadas"
      }
    ]
    
    # Configuración de alarmas para WAF
    alarm_config = [
      {
        metric_name   = "BlockedRequests"
        threshold     = 100
        severity      = "warning"
        comparison    = "GreaterThanThreshold"
        description   = "Alto número de solicitudes bloqueadas"
        alarm_actions = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
        insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:alert-insufficient-data"]
        ok_actions    = ["arn:aws:sns:us-east-1:123456789012:alert-recovery"]
        statistic     = "Sum"
        period        = 300
        treat_missing_data = "notBreaching" 
      },
      {
        metric_name   = "BlockedRequests"
        threshold     = 200
        severity      = "critical"
        comparison    = "GreaterThanThreshold"
        description   = "Alto número de solicitudes bloqueadas"
        alarm_actions = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
        insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:alert-insufficient-data"]
        ok_actions    = ["arn:aws:sns:us-east-1:123456789012:alert-recovery"]
        statistic     = "Sum"
        period        = 300
        treat_missing_data = "notBreaching" 
      },
      {
        metric_name   = "AllowedRequests"
        threshold     = 5000
        severity      = "critical"
        comparison    = "GreaterThanThreshold"
        description   = "Tráfico excesivo al sitio web"
        alarm_actions = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
        insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:alert-insufficient-data"]
        ok_actions    = ["arn:aws:sns:us-east-1:123456789012:alert-recovery"]
        statistic     = "Sum"
        period        = 300
        treat_missing_data = "notBreaching" 
      },
            {
        metric_name   = "AllowedRequests"
        threshold     = 4000
        severity      = "warning"
        comparison    = "GreaterThanThreshold"
        description   = "Tráfico excesivo al sitio web"
        alarm_actions = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
        insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:alert-insufficient-data"]
        ok_actions    = ["arn:aws:sns:us-east-1:123456789012:alert-recovery"]
        statistic     = "Sum"
        period        = 300
        treat_missing_data = "notBreaching" 
      }
    ]
  }
}

# Cloudfront    Pendiente
# ECS           OK
# Aurora        OK
# WAF           OK
# Textract      Pendiente 
# SQS           Pendiente
# ECR           Pendiente
# S3            OK
# API GATEWAY   OK
# DynamoDB      OK
# Lambda        OK


# Cloudfront
# ECS
# Aurora
# WAF
# Textract
# SQS
# ECR
# S3
# API GATEWAY
# DynamoDB
# Lambda



