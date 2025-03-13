module "observability" {
  source = "../"

  client      = "pragma"
  project     = "ecommerce"
  environment = "production"
  application = "webstore"

  # Configuración de EC2 mezclando alarmas críticas y de advertencia
  ec2 = {
    functionality    = "ec2"
    tag_key          = "EnableObservability"
    tag_value        = "true"
    create_dashboard = true
    metrics          = ["CPUUtilization", "NetworkIn", "NetworkOut", "StatusCheckFailed", "DiskReadBytes"]
    create_alarms    = true
    
    # Mantenemos algunos umbrales en el formato antiguo para compatibilidad
    alarm_thresholds = {
      "DiskReadBytes" = 100000000  # 100 MB
    }
    
    # Formato nuevo con múltiples alarmas por métrica y opciones personalizadas
    alarm_config = [
      # CPU con diferentes niveles de severidad
      {
        metric_name = "CPUUtilization"
        threshold   = 70
        severity    = "warning"
        description = "CPU por encima del 70% - Considerar escalar"
        comparison  = "GreaterThanThreshold"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
      },
      {
        metric_name = "CPUUtilization"
        threshold   = 85
        severity    = "high"
        description = "CPU por encima del 85% - Rendimiento degradado"
        comparison  = "GreaterThanThreshold"
        period      = 300
        evaluation_periods = 3  # Más períodos para reducir falsos positivos
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-high"]
      },
      {
        metric_name = "CPUUtilization"
        threshold   = 95
        severity    = "critical"
        description = "CPU por encima del 95% - Incidente crítico"
        comparison  = "GreaterThanThreshold"
        period      = 60  # Evaluación más frecuente para criticidad
        evaluation_periods = 2
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },
      
      # Tráfico de red con diferentes umbrales
      {
        metric_name = "NetworkIn"
        threshold   = 50000000  # 50 MB
        severity    = "info"
        description = "Entrada de red elevada - Información"
        statistic   = "Sum"
      },
      {
        metric_name = "NetworkOut"
        threshold   = 100000000  # 100 MB
        severity    = "warning"
        description = "Salida de red elevada - Posible exfiltración de datos"
        statistic   = "Maximum"  # Usar máximo en lugar de promedio
        #actions     = ["arn:aws:sns:us-east-1:123456789012:security-alerts"]
      },
      
      # Verificación de estado - usar LessThan para detectar cuando está bien (0 = éxito)
      {
        metric_name = "StatusCheckFailed"
        threshold   = 1
        severity    = "critical"
        description = "Verificación de estado fallida - Instancia no responde"
        comparison  = "GreaterThanOrEqualToThreshold"
        period      = 60
        evaluation_periods = 1  # Alertar inmediatamente
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      }
    ]
  }

  # RDS con diferentes métricas y umbrales
  rds = {
    functionality    = "rds"
    tag_key          = "EnableObservability"
    tag_value        = "true"
    create_dashboard = true
    metrics          = ["CPUUtilization", "DatabaseConnections", "FreeableMemory", "ReadIOPS", "WriteIOPS", "BurstBalance"]
    create_alarms    = true
    
    alarm_config = [
      # CPU con diferentes niveles
      {
        metric_name = "CPUUtilization"
        threshold   = 75
        severity    = "warning"
        comparison  = "GreaterThanThreshold"
      },
      {
        metric_name = "CPUUtilization"
        threshold   = 90
        severity    = "critical"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },
      
      # Conexiones a la base de datos
      {
        metric_name = "DatabaseConnections"
        threshold   = 80
        severity    = "warning"
        description = "Conexiones por encima del 80% del máximo"
        statistic   = "Maximum"
      },
      {
        metric_name = "DatabaseConnections"
        threshold   = 95
        severity    = "critical"
        description = "Conexiones casi al límite - Riesgo de denegación de servicio"
      },
      
      # Memoria - usar LessThan para detectar problemas de memoria baja
      {
        metric_name = "FreeableMemory"
        threshold   = 1500000000  # 1.5 GB
        severity    = "warning"
        comparison  = "LessThanThreshold"
        description = "Memoria libereable por debajo de 1.5 GB"
      },
      
      # IOPS de lectura/escritura
      {
        metric_name = "ReadIOPS"
        threshold   = 10000
        severity    = "warning"
        description = "Alto número de operaciones de lectura"
      },
      {
        metric_name = "WriteIOPS"
        threshold   = 5000
        severity    = "warning"
        description = "Alto número de operaciones de escritura"
      },
      
      # Créditos de ráfaga - alerta cuando se están agotando
      {
        metric_name = "BurstBalance"
        threshold   = 20
        severity    = "warning"
        comparison  = "LessThanOrEqualToThreshold"
        description = "Menos del 20% de créditos de ráfaga restantes"
      },
      {
        metric_name = "BurstBalance"
        threshold   = 10
        severity    = "critical"
        comparison  = "LessThanOrEqualToThreshold"
        description = "Menos del 10% de créditos de ráfaga restantes - Riesgo inminente"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      }
    ]
  }

  # Lambda con estadísticas específicas
  lambda = {
    functionality    = "lambda"
    tag_key          = "EnableObservability"
    tag_value        = "true"
    create_dashboard = true
    metrics          = ["Invocations", "Duration", "Errors", "Throttles", "ConcurrentExecutions", "IteratorAge"]
    create_alarms    = true
    
    alarm_config = [
      # Errores - diferentes niveles
      {
        metric_name = "Errors"
        threshold   = 5
        severity    = "warning"
        statistic   = "Sum"  # Total de errores, no promedio
        description = "Más de 5 errores detectados"
        period      = 300
      },
      {
        metric_name = "Errors"
        threshold   = 20
        severity    = "critical"
        statistic   = "Sum"
        description = "Más de 20 errores detectados - Fallo importante"
        period      = 300
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },
      
      # Duración de ejecución
      {
        metric_name = "Duration"
        threshold   = 3000  # 3 segundos
        severity    = "warning"
        description = "Tiempo de ejecución superior a 3 segundos"
        statistic   = "Average"
      },
      {
        metric_name = "Duration"
        threshold   = 5000  # 5 segundos
        severity    = "critical"
        description = "Tiempo de ejecución superior a 5 segundos - Posible timeout"
        statistic   = "p90"  # Percentil 90 de duración
      },
      
      # Invocaciones - estadísticas diferentes para detectar patrones
      {
        metric_name = "Invocations"
        threshold   = 1000
        severity    = "info"
        statistic   = "Sum"
        description = "Más de 1000 invocaciones - Carga alta"
      },
      
      # Throttling - uso de SampleCount para contar eventos
      {
        metric_name = "Throttles"
        threshold   = 1
        severity    = "warning"
        statistic   = "SampleCount"
        description = "Función limitada por throttling"
        comparison  = "GreaterThanThreshold"
      },
      
      # Ejecuciones concurrentes
      {
        metric_name = "ConcurrentExecutions"
        threshold   = 500
        severity    = "warning"
        description = "Más de 500 ejecuciones concurrentes - Considerar aumentar límite"
      },
      
      # Edad del iterador para funciones con origen de eventos
      {
        metric_name = "IteratorAge"
        threshold   = 600000  # 10 minutos en ms
        severity    = "warning"
        description = "Retraso en procesamiento de eventos mayor a 10 minutos"
        comparison  = "GreaterThanThreshold"
      }
    ]
  }

  # ALB con monitoreo de latencia y códigos de error
  alb = {
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["RequestCount", "TargetResponseTime", "HTTPCode_ELB_5XX_Count", "HTTPCode_Target_4XX_Count", "TargetConnectionErrorCount", "RejectedConnectionCount"]
    
    alarm_config = [
      # Tiempo de respuesta - diferentes niveles
      {
        metric_name = "TargetResponseTime"
        threshold   = 1
        severity    = "warning"
        description = "Tiempo de respuesta superior a 1 segundo"
        statistic   = "p90"  # Usar percentil 90 para latencia
      },
      {
        metric_name = "TargetResponseTime"
        threshold   = 3
        severity    = "critical"
        description = "Tiempo de respuesta crítico superior a 3 segundos"
        statistic   = "p95"  # Percentil más alto para criticidad
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },
      
      # Errores 5XX del balanceador
      {
        metric_name = "HTTPCode_ELB_5XX_Count"
        threshold   = 5
        severity    = "warning"
        statistic   = "Sum"
        period      = 300
        description = "Balanceador devolviendo errores 5XX"
      },
      {
        metric_name = "HTTPCode_ELB_5XX_Count"
        threshold   = 20
        severity    = "critical"
        statistic   = "Sum"
        period      = 300
        description = "Alto número de errores 5XX en el balanceador"
      },
      
      # Errores 4XX del target
      {
        metric_name = "HTTPCode_Target_4XX_Count"
        threshold   = 50
        severity    = "warning"
        statistic   = "Sum"
        period      = 300
        description = "Alto número de errores 4XX en los targets"
      },
      
      # Errores de conexión y conexiones rechazadas
      {
        metric_name = "TargetConnectionErrorCount"
        threshold   = 10
        severity    = "critical"
        statistic   = "Sum"
        period      = 300
        description = "Error en conexiones a targets"
      },
      {
        metric_name = "RejectedConnectionCount"
        threshold   = 1
        severity    = "critical"
        statistic   = "Sum"
        period      = 300
        description = "Balanceador rechazando conexiones - Posible sobrecarga"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      }
    ]
  }

  # S3 con monitoreo de tamaño y operaciones
  s3 = {
    functionality    = "s3"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["NumberOfObjects", "BucketSizeBytes", "4xxErrors", "5xxErrors", "AllRequests"]
    
    # Usando solo el formato antiguo para demostrar compatibilidad
    alarm_thresholds = {
      "NumberOfObjects" = 1000000  # Alerta cuando hay más de 1 millón de objetos
      "BucketSizeBytes" = 10737418240  # 10 GB
      "4xxErrors" = 100
      "5xxErrors" = 10
    }
  }

  # DynamoDB con monitoreo de capacidad y throttling
  dynamodb = {
    functionality    = "dynamodb"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["ConsumedReadCapacityUnits", "ConsumedWriteCapacityUnits", "ThrottledRequests", "ReadThrottleEvents", "WriteThrottleEvents", "SuccessfulRequestLatency"]
    
    # Mezclando formatos antiguo y nuevo
    alarm_thresholds = {
      "ConsumedReadCapacityUnits" = 800  # 80% de 1000 RCU
      "ConsumedWriteCapacityUnits" = 800  # 80% de 1000 WCU
    }
    
    alarm_config = [
      # Eventos de throttling con mayor criticidad
      {
        metric_name = "ThrottledRequests"
        threshold   = 10
        severity    = "warning"
        statistic   = "Sum"
        period      = 300
        description = "Solicitudes limitadas por throttling"
      },
      {
        metric_name = "ThrottledRequests"
        threshold   = 50
        severity    = "critical"
        statistic   = "Sum"
        period      = 300
        description = "Alto número de solicitudes limitadas por throttling"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },
      
      # Throttling específico para lectura/escritura
      {
        metric_name = "ReadThrottleEvents"
        threshold   = 5
        severity    = "warning"
        statistic   = "Sum"
        period      = 300
        description = "Eventos de throttling en lecturas"
      },
      {
        metric_name = "WriteThrottleEvents"
        threshold   = 5
        severity    = "warning"
        statistic   = "Sum"
        period      = 300
        description = "Eventos de throttling en escrituras"
      },
      
      # Latencia
      {
        metric_name = "SuccessfulRequestLatency"
        threshold   = 100  # 100 ms
        severity    = "warning"
        description = "Latencia elevada en solicitudes"
        statistic   = "p90"
      }
    ]
  }

  # API Gateway con monitoreo completo
  apigateway = {
    functionality    = "apigateway"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["Latency", "IntegrationLatency", "5XXError", "4XXError", "Count", "CacheHitCount", "CacheMissCount"]
    
    alarm_config = [
      # Latencia de la API
      {
        metric_name = "Latency"
        threshold   = 500  # 500 ms
        severity    = "warning"
        statistic   = "p90"
        description = "Latencia de API superior a 500 ms"
      },
      {
        metric_name = "Latency"
        threshold   = 1000  # 1 segundo
        severity    = "critical"
        statistic   = "p95"
        description = "Latencia crítica de API superior a 1 segundo"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },
      
      # Latencia de integración
      {
        metric_name = "IntegrationLatency"
        threshold   = 400  # 400 ms
        severity    = "warning"
        statistic   = "p90"
        description = "Latencia de integración backend superior a 400 ms"
      },
      
      # Errores 5XX
      {
        metric_name = "5XXError"
        threshold   = 5
        severity    = "warning"
        statistic   = "Sum"
        period      = 300
        description = "API devolviendo errores 5XX"
      },
      {
        metric_name = "5XXError"
        threshold   = 20
        severity    = "critical"
        statistic   = "Sum"
        period      = 300
        description = "Alto número de errores 5XX en la API"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },
      
      # Errores 4XX
      {
        metric_name = "4XXError"
        threshold   = 50
        severity    = "warning"
        statistic   = "Sum"
        period      = 300
        description = "Alto número de errores 4XX en la API"
      },
      
      # Cache metrics - usando LessThan para eficiencia de caché
      {
        metric_name = "CacheHitCount"
        threshold   = 100
        severity    = "info"
        statistic   = "Sum"
        period      = 3600  # 1 hora
        description = "Baja tasa de aciertos de caché por hora"
        comparison  = "LessThanThreshold"
      }
    ]
  }

  # Network Load Balancer
  nlb = {
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["ProcessedBytes", "NewFlowCount", "ActiveFlowCount", "TCP_Client_Reset_Count", "TCP_Target_Reset_Count", "HealthyHostCount", "UnHealthyHostCount"]
    
    alarm_config = [
      # Tráfico de red
      {
        metric_name = "ProcessedBytes"
        threshold   = 1000000000  # 1 GB
        severity    = "info"
        statistic   = "Sum"
        period      = 300
        description = "Alto volumen de tráfico procesado"
      },
      
      # Hosts saludables/no saludables
      {
        metric_name = "HealthyHostCount"
        threshold   = 1
        severity    = "critical"
        description = "Menos de 2 hosts saludables disponibles"
        comparison  = "LessThanOrEqualToThreshold"
        #actions     = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
      },
      {
        metric_name = "UnHealthyHostCount"
        threshold   = 1
        severity    = "warning"
        description = "Hosts no saludables detectados"
        comparison  = "GreaterThanOrEqualToThreshold"
      },
      
      # Resets TCP
      {
        metric_name = "TCP_Client_Reset_Count"
        threshold   = 50
        severity    = "warning"
        statistic   = "Sum"
        period      = 300
        description = "Alto número de resets TCP desde clientes"
      },
      {
        metric_name = "TCP_Target_Reset_Count"
        threshold   = 50
        severity    = "warning"
        statistic   = "Sum"
        period      = 300
        description = "Alto número de resets TCP desde targets"
      }
    ]
  }
}