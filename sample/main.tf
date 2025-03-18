module "observability" {
  source = "../"

  client      = "acme"
  project     = "ecommerce"
  environment = "production"
  application = "webstore"

  ###########################################################
  # Configuración de EC2
  ###########################################################
  ec2 = {
    functionality    = "ec2"
    tag_key          = "EnableObservability"
    tag_value        = "true"
    create_dashboard = true
    metrics          = ["CPUUtilization", "StatusCheckFailed", "NetworkIn", "NetworkOut", "DiskReadOps", "DiskWriteOps"]
    create_alarms    = true
    alarm_config = [
      # CPU - Warning
      {
        metric_name = "CPUUtilization"
        threshold   = 70
        severity    = "warning"
        description = "CPU utilization por encima del 70%"
        actions     = ["arn:aws:sns:us-east-1:840021737375:test"]
      },
      # CPU - Critical
      {
        metric_name = "CPUUtilization"
        threshold   = 90
        severity    = "critical"
        description = "CPU utilization por encima del 90% - Rendimiento degradado"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # StatusCheckFailed - Warning
      {
        metric_name = "StatusCheckFailed"
        threshold   = 0.5
        severity    = "warning"
        description = "La verificación de estado está fallando intermitentemente"
        comparison  = "GreaterThanThreshold"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # StatusCheckFailed - Critical
      {
        metric_name = "StatusCheckFailed"
        threshold   = 1
        severity    = "critical"
        description = "La verificación de estado está fallando constantemente"
        comparison  = "GreaterThanOrEqualToThreshold"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # NetworkIn - Warning
      {
        metric_name = "NetworkIn"
        threshold   = 50000000  # 50 MB
        severity    = "warning"
        description = "Tráfico de entrada superior a 50 MB"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # NetworkIn - Critical
      {
        metric_name = "NetworkIn"
        threshold   = 100000000  # 100 MB
        severity    = "critical"
        description = "Tráfico de entrada superior a 100 MB - Posible sobrecarga"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # NetworkOut - Warning
      {
        metric_name = "NetworkOut"
        threshold   = 50000000  # 50 MB
        severity    = "warning"
        description = "Tráfico de salida superior a 50 MB"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # NetworkOut - Critical
      {
        metric_name = "NetworkOut"
        threshold   = 100000000  # 100 MB
        severity    = "critical"
        description = "Tráfico de salida superior a 100 MB - Posible exfiltración de datos"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # DiskReadOps - Warning
      {
        metric_name = "DiskReadOps"
        threshold   = 5000
        severity    = "warning"
        description = "Operaciones de lectura de disco superiores a 5000"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # DiskReadOps - Critical
      {
        metric_name = "DiskReadOps"
        threshold   = 10000
        severity    = "critical"
        description = "Operaciones de lectura de disco superiores a 10000 - Posible problema de rendimiento"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # DiskWriteOps - Warning
      {
        metric_name = "DiskWriteOps"
        threshold   = 5000
        severity    = "warning"
        description = "Operaciones de escritura de disco superiores a 5000"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # DiskWriteOps - Critical
      {
        metric_name = "DiskWriteOps"
        threshold   = 10000
        severity    = "critical"
        description = "Operaciones de escritura de disco superiores a 10000 - Posible problema de rendimiento"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      }
    ]
  }

  ###########################################################
  # Configuración de RDS
  ###########################################################
  rds = {
    functionality    = "rds"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["CPUUtilization", "FreeStorageSpace", "FreeableMemory", "ReadIOPS", "WriteIOPS", "DatabaseConnections"]
    
    alarm_config = [
      # CPU - Warning
      {
        metric_name = "CPUUtilization"
        threshold   = 70
        severity    = "warning"
        description = "CPU utilization por encima del 70%"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # CPU - Critical
      {
        metric_name = "CPUUtilization"
        threshold   = 90
        severity    = "critical"
        description = "CPU utilization por encima del 90% - Rendimiento degradado"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # FreeStorageSpace - Warning
      {
        metric_name = "FreeStorageSpace"
        threshold   = 10737418240  # 10 GB
        severity    = "warning"
        description = "Espacio de almacenamiento libre inferior a 10 GB"
        comparison  = "LessThanOrEqualToThreshold"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # FreeStorageSpace - Critical
      {
        metric_name = "FreeStorageSpace"
        threshold   = 5368709120  # 5 GB
        severity    = "critical"
        description = "Espacio de almacenamiento libre inferior a 5 GB - Riesgo de quedarse sin espacio"
        comparison  = "LessThanOrEqualToThreshold"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # FreeableMemory - Warning
      {
        metric_name = "FreeableMemory"
        threshold   = 1073741824  # 1 GB
        severity    = "warning"
        description = "Memoria liberable inferior a 1 GB"
        comparison  = "LessThanOrEqualToThreshold"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # FreeableMemory - Critical
      {
        metric_name = "FreeableMemory"
        threshold   = 536870912  # 512 MB
        severity    = "critical"
        description = "Memoria liberable inferior a 512 MB - Riesgo de swapping"
        comparison  = "LessThanOrEqualToThreshold"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # ReadIOPS - Warning
      {
        metric_name = "ReadIOPS"
        threshold   = 1000
        severity    = "warning"
        description = "Operaciones de lectura por segundo superiores a 1000"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # ReadIOPS - Critical
      {
        metric_name = "ReadIOPS"
        threshold   = 3000
        severity    = "critical"
        description = "Operaciones de lectura por segundo superiores a 3000 - Posible problema de rendimiento"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # WriteIOPS - Warning
      {
        metric_name = "WriteIOPS"
        threshold   = 1000
        severity    = "warning"
        description = "Operaciones de escritura por segundo superiores a 1000"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # WriteIOPS - Critical
      {
        metric_name = "WriteIOPS"
        threshold   = 3000
        severity    = "critical"
        description = "Operaciones de escritura por segundo superiores a 3000 - Posible problema de rendimiento"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # DatabaseConnections - Warning
      {
        metric_name = "DatabaseConnections"
        threshold   = 80
        severity    = "warning"
        description = "Número de conexiones a la base de datos superior a 80"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # DatabaseConnections - Critical
      {
        metric_name = "DatabaseConnections"
        threshold   = 100
        severity    = "critical"
        description = "Número de conexiones a la base de datos superior a 100 - Acercándose al límite"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      }
    ]
  }

  ###########################################################
  # Configuración de Lambda
  ###########################################################
  lambda = {
    functionality    = "lambda"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["Invocations", "Errors", "Duration", "Throttles"]
    
    alarm_config = [
      # Invocations - Warning
      {
        metric_name = "Invocations"
        threshold   = 1000
        severity    = "warning"
        description = "Número de invocaciones superior a 1000 por minuto"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # Invocations - Critical
      {
        metric_name = "Invocations"
        threshold   = 5000
        severity    = "critical"
        description = "Número de invocaciones superior a 5000 por minuto - Posible sobrecarga"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # Errors - Warning
      {
        metric_name = "Errors"
        threshold   = 5
        severity    = "warning"
        description = "Número de errores superior a 5 por minuto"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # Errors - Critical
      {
        metric_name = "Errors"
        threshold   = 20
        severity    = "critical"
        description = "Número de errores superior a 20 por minuto - Fallo grave"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # Duration - Warning
      {
        metric_name = "Duration"
        threshold   = 3000
        severity    = "warning"
        description = "Duración de la ejecución superior a 3000 ms"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # Duration - Critical
      {
        metric_name = "Duration"
        threshold   = 5000
        severity    = "critical"
        description = "Duración de la ejecución superior a 5000 ms - Riesgo de timeout"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # Throttles - Warning
      {
        metric_name = "Throttles"
        threshold   = 1
        severity    = "warning"
        description = "Se están produciendo throttles"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # Throttles - Critical
      {
        metric_name = "Throttles"
        threshold   = 10
        severity    = "critical"
        description = "Se están produciendo muchos throttles - Necesario aumentar cuota"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      }
    ]
  }

  ###########################################################
  # Configuración de ALB
  ###########################################################
  alb = {
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["RequestCount", "HTTPCode_Target_4XX_Count", "HTTPCode_ELB_5XX_Count", "TargetResponseTime", "UnHealthyHostCount", "HealthyHostCount", "ActiveConnectionCount", "ProcessedBytes"]
    
    alarm_config = [
      # RequestCount - Warning
      {
        metric_name = "RequestCount"
        threshold   = 5000
        severity    = "warning"
        description = "Número de peticiones superior a 5000 por minuto"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # RequestCount - Critical
      {
        metric_name = "RequestCount"
        threshold   = 10000
        severity    = "critical"
        description = "Número de peticiones superior a 10000 por minuto - Posible sobrecarga"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # HTTPCode_Target_4XX_Count - Warning
      {
        metric_name = "HTTPCode_Target_4XX_Count"
        threshold   = 100
        severity    = "warning"
        description = "Número de errores 4XX superior a 100 por minuto"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # HTTPCode_Target_4XX_Count - Critical
      {
        metric_name = "HTTPCode_Target_4XX_Count"
        threshold   = 500
        severity    = "critical"
        description = "Número de errores 4XX superior a 500 por minuto - Posible problema con la aplicación"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # HTTPCode_ELB_5XX_Count - Warning
      {
        metric_name = "HTTPCode_ELB_5XX_Count"
        threshold   = 10
        severity    = "warning"
        description = "Número de errores 5XX superior a 10 por minuto"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # HTTPCode_ELB_5XX_Count - Critical
      {
        metric_name = "HTTPCode_ELB_5XX_Count"
        threshold   = 50
        severity    = "critical"
        description = "Número de errores 5XX superior a 50 por minuto - Problema grave"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # TargetResponseTime - Warning
      {
        metric_name = "TargetResponseTime"
        threshold   = 1
        severity    = "warning"
        description = "Tiempo de respuesta superior a 1 segundo"
        statistic   = "Average"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # TargetResponseTime - Critical
      {
        metric_name = "TargetResponseTime"
        threshold   = 3
        severity    = "critical"
        description = "Tiempo de respuesta superior a 3 segundos - Problema grave de rendimiento"
        statistic   = "Average"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # UnHealthyHostCount - Warning
      {
        metric_name = "UnHealthyHostCount"
        threshold   = 1
        severity    = "warning"
        description = "Al menos un host no está saludable"
        statistic   = "Maximum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # UnHealthyHostCount - Critical
      {
        metric_name = "UnHealthyHostCount"
        threshold   = 2
        severity    = "critical"
        description = "Múltiples hosts no están saludables - Problema grave"
        statistic   = "Maximum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # HealthyHostCount - Warning
      {
        metric_name = "HealthyHostCount"
        threshold   = 2
        severity    = "warning"
        description = "Apenas 2 hosts saludables - Poca capacidad"
        comparison  = "LessThanOrEqualToThreshold"
        statistic   = "Minimum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # HealthyHostCount - Critical
      {
        metric_name = "HealthyHostCount"
        threshold   = 1
        severity    = "critical"
        description = "Solo 1 host saludable - Riesgo de fallo completo"
        comparison  = "LessThanOrEqualToThreshold"
        statistic   = "Minimum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # ActiveConnectionCount - Warning
      {
        metric_name = "ActiveConnectionCount"
        threshold   = 1000
        severity    = "warning"
        description = "Más de 1000 conexiones activas"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # ActiveConnectionCount - Critical
      {
        metric_name = "ActiveConnectionCount"
        threshold   = 5000
        severity    = "critical"
        description = "Más de 5000 conexiones activas - Posible sobrecarga"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # ProcessedBytes - Warning
      {
        metric_name = "ProcessedBytes"
        threshold   = 100000000  # 100 MB
        severity    = "warning"
        description = "Procesados más de 100 MB por minuto"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # ProcessedBytes - Critical
      {
        metric_name = "ProcessedBytes"
        threshold   = 500000000  # 500 MB
        severity    = "critical"
        description = "Procesados más de 500 MB por minuto - Alto consumo de ancho de banda"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      }
    ]
  }

  ###########################################################
  # Configuración de NLB
  ###########################################################
  nlb = {
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["ActiveFlowCount", "ProcessedBytes", "NewFlowCount", "HealthyHostCount"]
    
    alarm_config = [
      # ActiveFlowCount - Warning
      {
        metric_name = "ActiveFlowCount"
        threshold   = 1000
        severity    = "warning"
        description = "Más de 1000 flujos activos"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # ActiveFlowCount - Critical
      {
        metric_name = "ActiveFlowCount"
        threshold   = 5000
        severity    = "critical"
        description = "Más de 5000 flujos activos - Posible sobrecarga"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # ProcessedBytes - Warning
      {
        metric_name = "ProcessedBytes"
        threshold   = 100000000  # 100 MB
        severity    = "warning"
        description = "Procesados más de 100 MB por minuto"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # ProcessedBytes - Critical
      {
        metric_name = "ProcessedBytes"
        threshold   = 500000000  # 500 MB
        severity    = "critical"
        description = "Procesados más de 500 MB por minuto - Alto consumo de ancho de banda"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # NewFlowCount - Warning
      {
        metric_name = "NewFlowCount"
        threshold   = 500
        severity    = "warning"
        description = "Más de 500 nuevos flujos por minuto"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # NewFlowCount - Critical
      {
        metric_name = "NewFlowCount"
        threshold   = 2000
        severity    = "critical"
        description = "Más de 2000 nuevos flujos por minuto - Posible ataque"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # HealthyHostCount - Warning
      {
        metric_name = "HealthyHostCount"
        threshold   = 2
        severity    = "warning"
        description = "Apenas 2 hosts saludables - Poca capacidad"
        comparison  = "LessThanOrEqualToThreshold"
        statistic   = "Minimum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # HealthyHostCount - Critical
      {
        metric_name = "HealthyHostCount"
        threshold   = 1
        severity    = "critical"
        description = "Solo 1 host saludable - Riesgo de fallo completo"
        comparison  = "LessThanOrEqualToThreshold"
        statistic   = "Minimum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      }
    ]
  }

  ###########################################################
  # Configuración de S3
  ###########################################################
  s3 = {
    functionality    = "s3"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["NumberOfObjects", "BucketSizeBytes"]
    
    alarm_config = [
      # NumberOfObjects - Warning
      {
        metric_name = "NumberOfObjects"
        threshold   = 1000000
        severity    = "warning"
        description = "Más de 1 millón de objetos en el bucket"
        statistic   = "Average"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # NumberOfObjects - Critical
      {
        metric_name = "NumberOfObjects"
        threshold   = 5000000
        severity    = "critical"
        description = "Más de 5 millones de objetos en el bucket - Posible problema de gestión"
        statistic   = "Average"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # BucketSizeBytes - Warning
      {
        metric_name = "BucketSizeBytes"
        threshold   = 10737418240  # 10 GB
        severity    = "warning"
        description = "Tamaño del bucket superior a 10 GB"
        statistic   = "Average"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # BucketSizeBytes - Critical
      {
        metric_name = "BucketSizeBytes"
        threshold   = 53687091200  # 50 GB
        severity    = "critical"
        description = "Tamaño del bucket superior a 50 GB - Considerar política de retención"
        statistic   = "Average"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      }
    ]
  }

  ###########################################################
  # Configuración de API Gateway
  ###########################################################
  apigateway = {
    functionality    = "apigateway"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["Count", "4XXError", "5XXError", "Latency"]
    
    alarm_config = [
      # Count - Warning
      {
        metric_name = "Count"
        threshold   = 1000
        severity    = "warning"
        description = "Más de 1000 peticiones por minuto"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # Count - Critical
      {
        metric_name = "Count"
        threshold   = 5000
        severity    = "critical"
        description = "Más de 5000 peticiones por minuto - Posible sobrecarga"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # 4XXError - Warning
      {
        metric_name = "4XXError"
        threshold   = 50
        severity    = "warning"
        description = "Más de 50 errores 4XX por minuto"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # 4XXError - Critical
      {
        metric_name = "4XXError"
        threshold   = 200
        severity    = "critical"
        description = "Más de 200 errores 4XX por minuto - Posible problema con los clientes"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # 5XXError - Warning
      {
        metric_name = "5XXError"
        threshold   = 10
        severity    = "warning"
        description = "Más de 10 errores 5XX por minuto"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # 5XXError - Critical
      {
        metric_name = "5XXError"
        threshold   = 50
        severity    = "critical"
        description = "Más de 50 errores 5XX por minuto - Problema grave con el servicio"
        period      = 60
        statistic   = "Sum"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # Latency - Warning
      {
        metric_name = "Latency"
        threshold   = 500
        severity    = "warning"
        description = "Latencia superior a 500 ms"
        statistic   = "Average"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # Latency - Critical
      {
        metric_name = "Latency"
        threshold   = 1000
        severity    = "critical"
        description = "Latencia superior a 1000 ms - Problema grave de rendimiento"
        statistic   = "Average"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      }
    ]
  }
  dynamodb = {
    functionality    = "dynamodb"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["ConsumedReadCapacityUnits", "ConsumedWriteCapacityUnits", "ThrottledRequests", "SuccessfulRequestLatency"]
    
    alarm_config = [
      # ConsumedReadCapacityUnits - Warning
      {
        metric_name = "ConsumedReadCapacityUnits"
        threshold   = 800
        severity    = "warning"
        description = "Unidades de capacidad de lectura consumidas por encima del 80% del provisionamiento"
        statistic   = "Sum"
        period      = 60
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # ConsumedReadCapacityUnits - Critical
      {
        metric_name = "ConsumedReadCapacityUnits"
        threshold   = 950
        severity    = "critical"
        description = "Unidades de capacidad de lectura consumidas por encima del 95% del provisionamiento - Riesgo de throttling"
        statistic   = "Sum"
        period      = 60
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # ConsumedWriteCapacityUnits - Warning
      {
        metric_name = "ConsumedWriteCapacityUnits"
        threshold   = 800
        severity    = "warning"
        description = "Unidades de capacidad de escritura consumidas por encima del 80% del provisionamiento"
        statistic   = "Sum"
        period      = 60
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # ConsumedWriteCapacityUnits - Critical
      {
        metric_name = "ConsumedWriteCapacityUnits"
        threshold   = 950
        severity    = "critical"
        description = "Unidades de capacidad de escritura consumidas por encima del 95% del provisionamiento - Riesgo de throttling"
        statistic   = "Sum"
        period      = 60
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # ThrottledRequests - Warning
      {
        metric_name = "ThrottledRequests"
        threshold   = 5
        severity    = "warning"
        description = "Más de 5 solicitudes limitadas por throttling por minuto"
        statistic   = "Sum"
        period      = 60
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # ThrottledRequests - Critical
      {
        metric_name = "ThrottledRequests"
        threshold   = 20
        severity    = "critical"
        description = "Más de 20 solicitudes limitadas por throttling por minuto - Necesario aumentar capacidad"
        statistic   = "Sum"
        period      = 60
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },

      # SuccessfulRequestLatency - Warning
      {
        metric_name = "SuccessfulRequestLatency"
        threshold   = 50
        severity    = "warning"
        description = "Latencia de solicitudes exitosas superior a 50 ms"
        statistic   = "Average"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      # SuccessfulRequestLatency - Critical
      {
        metric_name = "SuccessfulRequestLatency"
        threshold   = 100
        severity    = "critical"
        description = "Latencia de solicitudes exitosas superior a 100 ms - Problema grave de rendimiento"
        statistic   = "Average"
        actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      }
    ]
  }
}