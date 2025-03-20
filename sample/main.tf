module "observability" {
  source = "../"

  client      = "acme"
  project     = "ecommerce"
  environment = "production"
  application = "webstore"
  
  # Container Insights para monitoreo completo de ECS
  ecs_insights = {
    functionality    = "ecs_insights"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    
    dashboard_config = [
      # Métricas a nivel de Cluster
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
      },
      {
        metric_name    = "CpuReserved"
        dimension_name = "ClusterName"
        period         = 300
        statistic      = "Average"
        title          = "CPU Reservada por Cluster"
        width          = 12
        height         = 6
      },
      {
        metric_name    = "MemoryReserved"
        dimension_name = "ClusterName"
        period         = 300
        statistic      = "Average"
        title          = "Memoria Reservada por Cluster"
        width          = 12
        height         = 6
      },
      
      # Métricas a nivel de Servicio
      {
        metric_name    = "CpuUtilized"
        dimension_name = "ServiceName"
        period         = 300
        statistic      = "Average"
        title          = "Utilización de CPU por Servicio (CI)"
        width          = 12
        height         = 6
      },
      {
        metric_name    = "MemoryUtilized"
        dimension_name = "ServiceName"
        period         = 300
        statistic      = "Average"
        title          = "Utilización de Memoria por Servicio (CI)"
        width          = 12
        height         = 6
      },
      
      # # Métricas a nivel de Tarea
      # {
      #   metric_name    = "TaskCPUUtilization"
      #   dimension_name = "ServiceName"
      #   period         = 300
      #   statistic      = "Average"
      #   title          = "Utilización de CPU por Tarea"
      #   width          = 12
      #   height         = 6
      # },
      # {
      #   metric_name    = "TaskMemoryUtilization"
      #   dimension_name = "ServiceName"
      #   period         = 300
      #   statistic      = "Average"
      #   title          = "Utilización de Memoria por Tarea"
      #   width          = 12
      #   height         = 6
      # },
      # {
      #   metric_name    = "RunningTaskCount"
      #   dimension_name = "ServiceName"
      #   period         = 300
      #   statistic      = "Average"
      #   title          = "Número de Tareas en Ejecución"
      #   width          = 12
      #   height         = 6
      # }
    ],
    
    alarm_config = [
      # Alarmas a nivel de Cluster
      {
        metric_name     = "CpuUtilized"
        dimension_name  = "ClusterName"
        dimension_value = "pragma-idp-dev-cluster-bs-01"
        threshold       = 80
        severity        = "warning"
        description     = "Alta utilización de CPU en cluster"
        actions         = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      {
        metric_name     = "MemoryUtilized"
        dimension_name  = "ClusterName"
        dimension_value = "pragma-idp-dev-cluster-bs-01"
        threshold       = 80
        severity        = "warning"
        description     = "Alta utilización de memoria en cluster"
        actions         = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      
      # Alarmas a nivel de Servicio
      {
        metric_name     = "CpuUtilized"
        dimension_name  = "ServiceName"
        dimension_value = "pragma-idp-dev-service-bs-pe"
        threshold       = 85
        severity        = "warning"
        description     = "Utilización de CPU alta en el servicio ECS"
        actions         = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      {
        metric_name     = "MemoryUtilized"
        dimension_name  = "ServiceName"
        dimension_value = "pragma-idp-dev-service-bs-pe"
        threshold       = 85
        severity        = "warning"
        description     = "Utilización de memoria alta en el servicio ECS"
        actions         = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      
      # Alarmas a nivel de Tarea
      {
        metric_name     = "CpuUtilized"
        dimension_name  = "ServiceName"
        dimension_value = "pragma-idp-dev-service-bs-pe"
        threshold       = 90
        severity        = "critical"
        description     = "CPU de tareas muy alta en el servicio"
        actions         = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },
      {
        metric_name     = "MemoryUtilized"
        dimension_name  = "ServiceName"
        dimension_value = "pragma-idp-dev-service-bs-pe"
        threshold       = 90
        severity        = "critical"
        description     = "Memoria de tareas muy alta en el servicio"
        actions         = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      }
    ]
  }
}