module "observability" {
  source = "../"

  client      = "acme"
  project     = "ecommerce"
  environment = "production"
  application = "webstore"

  s3 = {
    functionality    = "s3"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"

    # Nueva configuración de dashboard usando dashboard_config
    dashboard_config = [
      {
        metric_name = "NumberOfObjects"
        period      = 86400 # 1 día en segundos
        statistic   = "Average"
        title       = "Total de Objetos por Bucket (Promedio Diario)"
        width       = 12
        height      = 6
      },
      {
        metric_name  = "BucketSizeBytes"
        period       = 3600 # 1 hora en segundos
        statistic    = "Maximum"
        storage_type = "StandardStorage"
        title        = "Tamaño de Bucket - Almacenamiento Estándar (Máximo Horario)"
        width        = 12
        height       = 6
      },
      {
        metric_name  = "BucketSizeBytes"
        period       = 3600 # 1 hora en segundos
        statistic    = "Maximum"
        storage_type = "StandardIAStorage"
        title        = "Tamaño de Bucket - Standard-IA (Máximo Horario)"
        width        = 12
        height       = 6
      }
    ],

    # Configuración de alarmas
    alarm_config = [
      # NumberOfObjects - Warning
      {
        metric_name = "NumberOfObjects"
        threshold   = 1000000
        severity    = "warning"
        description = "Más de 1 millón de objetos en el bucket"
        statistic   = "Average"
        period      = 86400 # 1 día en segundos
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },

      # NumberOfObjects - Critical
      {
        metric_name = "NumberOfObjects"
        threshold   = 5000000
        severity    = "critical"
        description = "Más de 5 millones de objetos en el bucket - Posible problema de gestión"
        statistic   = "Average"
        period      = 86400 # 1 día en segundos
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # BucketSizeBytes para almacenamiento Standard - Warning
      {
        metric_name  = "BucketSizeBytes"
        threshold    = 10737418240 # 10 GB
        severity     = "warning"
        description  = "Tamaño del bucket Standard superior a 10 GB"
        statistic    = "Average"
        storage_type = "StandardStorage"
        actions      = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      }
    ]
  }
  ec2 = {
    functionality    = "computo"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"

    # Configuración del dashboard
    dashboard_config = [
      {
        metric_name = "CPUUtilization"
        period      = 300
        statistic   = "Average"
        title       = "Utilización de CPU por Instancia"
        width       = 12
        height      = 6
      },
      {
        metric_name = "NetworkIn"
        period      = 300
        statistic   = "Sum"
        title       = "Tráfico de Red Entrante por Instancia"
        width       = 12
        height      = 6
      },
      {
        metric_name = "NetworkOut"
        period      = 300
        statistic   = "Sum"
        title       = "Tráfico de Red Saliente por Instancia"
        width       = 12
        height      = 6
      },
      {
        metric_name = "DiskReadOps"
        period      = 3600
        statistic   = "Sum"
        title       = "Operaciones de Lectura en Disco (1 hora)"
        width       = 12
        height      = 6
      }
    ],

    # Configuración de alarmas
    alarm_config = [
      {
        metric_name = "CPUUtilization"
        threshold   = 80
        severity    = "warning"
        description = "CPU alta en instancia EC2"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      {
        metric_name = "StatusCheckFailed"
        threshold   = 1
        severity    = "critical"
        description = "La verificación de estado ha fallado"
        statistic   = "Maximum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      }
    ]
  }
  rds = {
    functionality    = "data"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"

    # Configuración del dashboard
    dashboard_config = [
      {
        metric_name = "CPUUtilization"
        period      = 300
        statistic   = "Average"
        title       = "Utilización de CPU en RDS"
        width       = 12
        height      = 6
      },
      {
        metric_name = "DatabaseConnections"
        period      = 300
        statistic   = "Average"
        title       = "Conexiones a Base de Datos"
        width       = 12
        height      = 6
      },
      {
        metric_name = "FreeableMemory"
        period      = 300
        statistic   = "Average"
        title       = "Memoria Disponible"
        width       = 12
        height      = 6
      },
      {
        metric_name = "ReadIOPS"
        period      = 300
        statistic   = "Average"
        title       = "IOPS de Lectura"
        width       = 12
        height      = 6
      }
    ],

    # Configuración de alarmas
    alarm_config = [
      {
        metric_name = "CPUUtilization"
        threshold   = 80
        severity    = "warning"
        description = "Utilización de CPU alta en instancia RDS"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      {
        metric_name = "FreeStorageSpace"
        threshold   = 10737418240 # 10 GB
        severity    = "critical"
        comparison  = "LessThanOrEqualToThreshold"
        description = "Espacio de almacenamiento libre bajo"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      }
    ]
  }
  lambda = {
    functionality    = "lambda"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"

    # Configuración del dashboard
    dashboard_config = [
      {
        metric_name = "Invocations"
        period      = 300
        statistic   = "Sum"
        title       = "Invocaciones de Lambda"
        width       = 12
        height      = 6
      },
      {
        metric_name = "Duration"
        period      = 300
        statistic   = "Average"
        title       = "Duración de Ejecución (ms)"
        width       = 12
        height      = 6
      },
      {
        metric_name = "Errors"
        period      = 300
        statistic   = "Sum"
        title       = "Errores de Lambda"
        width       = 12
        height      = 6
      },
      {
        metric_name = "Throttles"
        period      = 300
        statistic   = "Sum"
        title       = "Limitaciones de Lambda"
        width       = 12
        height      = 6
      }
    ],

    # Configuración de alarmas
    alarm_config = [
      {
        metric_name = "Errors"
        threshold   = 5
        severity    = "warning"
        description = "Errores en función Lambda"
        statistic   = "Sum"
        period      = 300
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      {
        metric_name = "Duration"
        threshold   = 5000
        severity    = "warning"
        description = "Duración de ejecución alta en Lambda"
        statistic   = "Average"
        period      = 300
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      }
    ]
  }
  alb = {
    functionality    = "alb"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"

    # Configuración del dashboard
    dashboard_config = [
      {
        metric_name = "RequestCount"
        period      = 300
        statistic   = "Sum"
        title       = "Número de Solicitudes"
        width       = 12
        height      = 6
      },
      {
        metric_name = "TargetResponseTime"
        period      = 300
        statistic   = "Average"
        title       = "Tiempo de Respuesta del Target (ms)"
        width       = 12
        height      = 6
      },
      {
        metric_name = "HTTPCode_ELB_5XX_Count"
        period      = 300
        statistic   = "Sum"
        title       = "Errores 5XX del ALB"
        width       = 12
        height      = 6
      },
      {
        metric_name = "HTTPCode_Target_4XX_Count"
        period      = 300
        statistic   = "Sum"
        title       = "Errores 4XX de los Targets"
        width       = 12
        height      = 6
      }
    ],

    # Configuración de alarmas
    alarm_config = [
      {
        metric_name = "HTTPCode_ELB_5XX_Count"
        threshold   = 10
        severity    = "warning"
        description = "Errores 5XX en el ALB"
        statistic   = "Sum"
        period      = 300
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      {
        metric_name = "TargetResponseTime"
        threshold   = 5
        severity    = "warning"
        description = "Tiempo de respuesta alto en targets"
        statistic   = "Average"
        period      = 300
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      }
    ]
  }
  nlb = {
    functionality    = "nlb"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"

    # Configuración del dashboard
    dashboard_config = [
      {
        metric_name = "ProcessedBytes"
        period      = 300
        statistic   = "Sum"
        title       = "Bytes Procesados"
        width       = 12
        height      = 6
      },
      {
        metric_name = "NewFlowCount"
        period      = 300
        statistic   = "Sum"
        title       = "Nuevos Flujos"
        width       = 12
        height      = 6
      },
      {
        metric_name = "ActiveFlowCount"
        period      = 300
        statistic   = "Average"
        title       = "Flujos Activos"
        width       = 12
        height      = 6
      },
      {
        metric_name = "HealthyHostCount"
        period      = 300
        statistic   = "Average"
        title       = "Hosts Saludables"
        width       = 12
        height      = 6
      }
    ],

    # Configuración de alarmas
    alarm_config = [
      {
        metric_name = "HealthyHostCount"
        threshold   = 1
        severity    = "critical"
        comparison  = "LessThanOrEqualToThreshold"
        description = "Hosts saludables críticos en NLB"
        statistic   = "Minimum"
        period      = 300
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },
      {
        metric_name = "ProcessedBytes"
        threshold   = 1000000000 # 1 GB
        severity    = "warning"
        description = "Alto volumen de tráfico en NLB"
        statistic   = "Sum"
        period      = 300
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      }
    ]
  }
  apigateway = {
    functionality    = "apigateway"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"

    # Configuración del dashboard
    dashboard_config = [
      {
        metric_name = "Latency"
        period      = 300
        statistic   = "Average"
        title       = "Latencia de API Gateway"
        width       = 12
        height      = 6
      },
      {
        metric_name = "5XXError"
        period      = 300
        statistic   = "Sum"
        title       = "Errores 5XX"
        width       = 12
        height      = 6
      },
      {
        metric_name = "4XXError"
        period      = 300
        statistic   = "Sum"
        title       = "Errores 4XX"
        width       = 12
        height      = 6
      },
      {
        metric_name = "IntegrationLatency"
        period      = 300
        statistic   = "Average"
        title       = "Latencia de Integración"
        width       = 12
        height      = 6
      }
    ],

    # Configuración de alarmas
    alarm_config = [
      {
        metric_name = "5XXError"
        threshold   = 10
        severity    = "critical"
        description = "Errores 5XX en API Gateway"
        statistic   = "Sum"
        period      = 300
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },
      {
        metric_name = "Latency"
        threshold   = 1000
        severity    = "warning"
        description = "Latencia alta en API Gateway"
        statistic   = "Average"
        period      = 300
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      }
    ]
  }
  dynamodb = {
    functionality    = "dynamodb"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"

    # Configuración del dashboard
    dashboard_config = [
      {
        metric_name = "ConsumedReadCapacityUnits"
        period      = 300
        statistic   = "Sum"
        title       = "Unidades de Capacidad de Lectura Consumidas"
        width       = 12
        height      = 6
      },
      {
        metric_name = "ConsumedWriteCapacityUnits"
        period      = 300
        statistic   = "Sum"
        title       = "Unidades de Capacidad de Escritura Consumidas"
        width       = 12
        height      = 6
      },
      {
        metric_name = "ThrottledRequests"
        period      = 300
        statistic   = "Sum"
        title       = "Solicitudes Limitadas"
        width       = 12
        height      = 6
      },
      {
        metric_name = "ReadThrottleEvents"
        period      = 300
        statistic   = "Sum"
        title       = "Eventos de Limitación de Lectura"
        width       = 12
        height      = 6
      }
    ],

    # Configuración de alarmas
    alarm_config = [
      {
        metric_name = "ThrottledRequests"
        threshold   = 10
        severity    = "warning"
        description = "Solicitudes limitadas en DynamoDB"
        statistic   = "Sum"
        period      = 300
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      {
        metric_name = "SystemErrors"
        threshold   = 5
        severity    = "critical"
        description = "Errores del sistema en DynamoDB"
        statistic   = "Sum"
        period      = 300
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      }
    ]
  }
  # ECS estándar
  ecs = {
    functionality    = "ecs"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    
    # Configuración del dashboard
    dashboard_config = [
      # Métricas de Cluster
      {
        metric_name    = "CPUUtilization"
        dimension_name = "ClusterName"
        period         = 300
        statistic      = "Average"
        title          = "Utilización de CPU por Cluster"
        width          = 12
        height         = 6
      },
      {
        metric_name    = "MemoryUtilization"
        dimension_name = "ClusterName"
        period         = 300
        statistic      = "Average"
        title          = "Utilización de Memoria por Cluster"
        width          = 12
        height         = 6
      },
      
      # Métricas de Servicio
      {
        metric_name    = "CPUUtilization"
        dimension_name = "ServiceName"
        period         = 300
        statistic      = "Average"
        title          = "Utilización de CPU por Servicio"
        width          = 12
        height         = 6
      },
      {
        metric_name    = "MemoryUtilization"
        dimension_name = "ServiceName"
        period         = 300
        statistic      = "Average"
        title          = "Utilización de Memoria por Servicio"
        width          = 12
        height         = 6
      }
    ],
    
    # Configuración de alarmas
    alarm_config = [
      {
        metric_name     = "CPUUtilization"
        dimension_name  = "ClusterName"
        dimension_value = "production-cluster"
        threshold       = 80
        severity        = "warning"
        description     = "Utilización de CPU alta en cluster ECS"
        actions         = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      {
        metric_name     = "MemoryUtilization"
        dimension_name  = "ClusterName"
        dimension_value = "production-cluster"
        threshold       = 80
        severity        = "warning"
        description     = "Utilización de memoria alta en cluster ECS"
        actions         = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      }
    ]
  }
  
  # Container Insights
  ecs_insights = {
    functionality    = "ecs_insights"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    
    # Configuración del dashboard
    dashboard_config = [
      {
        metric_name    = "RunningTaskCount"
        dimension_name = "ClusterName"
        period         = 300
        statistic      = "Average"
        title          = "Tareas en Ejecución por Cluster"
        width          = 12
        height         = 6
      },
      {
        metric_name    = "PendingTaskCount"
        dimension_name = "ClusterName"
        period         = 300
        statistic      = "Average"
        title          = "Tareas Pendientes por Cluster"
        width          = 12
        height         = 6
      },
      {
        metric_name    = "TaskCPUUtilization"
        dimension_name = "ServiceName"
        period         = 300
        statistic      = "Average"
        title          = "Utilización de CPU por Tarea"
        width          = 12
        height         = 6
      },
      {
        metric_name    = "TaskMemoryUtilization"
        dimension_name = "ServiceName"
        period         = 300
        statistic      = "Average"
        title          = "Utilización de Memoria por Tarea"
        width          = 12
        height         = 6
      }
    ],
    
    # Configuración de alarmas
    alarm_config = [
      {
        metric_name     = "RunningTaskCount"
        dimension_name  = "ServiceName"
        dimension_value = "web-service"
        threshold       = 1
        comparison      = "LessThanOrEqualToThreshold"
        severity        = "critical"
        description     = "Servicio con pocas tareas en ejecución"
        actions         = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },
      {
        metric_name     = "TaskCPUUtilization"
        dimension_name  = "ServiceName"
        dimension_value = "web-service"
        threshold       = 90
        severity        = "warning"
        description     = "Utilización de CPU alta en tareas"
        actions         = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      }
    ]
  }
}


#ECS - Service - Task - OK
#ECR

#Textra
#Cloudfront
#WAF
#SQS 
