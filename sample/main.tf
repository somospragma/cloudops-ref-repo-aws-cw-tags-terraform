module "observability" {
  source = "../"

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
        actions            = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
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
        actions            = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
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
        actions            = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
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
        actions            = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        evaluation_periods = 3
        period             = 300
        statistic          = "Average"
      }
    ]

    # alarm_config = [
    #   {
    #     metric_name     = "RunningTaskCount"
    #     dimension_name  = "ServiceName"
    #     dimension_value = "servicio-especial"
    #     cluster_name    = "mi-cluster"
    #     threshold       = 1
    #     severity        = "critical"
    #     comparison      = "LessThanThreshold"
    #     description     = "Alerta si el servicio especial no tiene tareas en ejecución"
    #     actions         = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
    #   }
    # ]
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
}


# Cloudfront
# SQS
# ECS OK
# Aurora OK
# WAF Pendinete
#Textract Pendiente 
#SQS Pendiente
#ECR Pendiente
#S3 OK
#API GATEWAY OK
# DynamoDB OK
# Lambda OK
# CloudFront Pendiente

# Cloudfront
# SQS
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
# CloudFront


