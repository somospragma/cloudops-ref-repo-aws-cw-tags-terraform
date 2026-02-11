# Ejemplo de configuración de EC2 con CloudWatch Agent
# Este ejemplo muestra cómo monitorear CPU (nativa), Memoria y Disco (CWAgent)

module "observability_ec2_complete" {
  source = "../"

  client      = "pragma"
  project     = "myproject"
  environment = "production"
  application = "webserver"

  ec2 = {
    functionality    = "compute"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"

    # Configuración del dashboard
    dashboard_config = [
      # CPU - Métrica nativa de AWS/EC2 (no requiere CloudWatch Agent)
      {
        metric_name = "CPUUtilization"
        namespace   = "AWS/EC2"  # Namespace por defecto
        period      = 300
        statistic   = "Average"
        width       = 12
        height      = 6
        title       = "EC2 - CPU Utilization (%)"
      },
      
      # Memoria - Requiere CloudWatch Agent
      {
        metric_name = "mem_used_percent"
        namespace   = "CWAgent"  # Namespace del CloudWatch Agent
        period      = 300
        statistic   = "Average"
        width       = 12
        height      = 6
        title       = "EC2 - Memory Usage (%)"
        # No se requieren dimensiones adicionales para memoria
        additional_dimensions = {}
      },
      
      # Disco - Requiere CloudWatch Agent
      {
        metric_name = "disk_used_percent"
        namespace   = "CWAgent"  # Namespace del CloudWatch Agent
        period      = 300
        statistic   = "Average"
        width       = 12
        height      = 6
        title       = "EC2 - Disk Usage (/) (%)"
        # Dimensiones adicionales para especificar el disco/partición
        additional_dimensions = {
          path   = "/"           # Punto de montaje
          device = "nvme0n1p1"   # Dispositivo (ajustar según tu configuración)
          fstype = "xfs"         # Tipo de sistema de archivos
        }
      }
    ]

    # Configuración de alarmas
    alarm_config = [
      # ========================================
      # Alarmas de CPU (métricas nativas)
      # ========================================
      {
        metric_name         = "CPUUtilization"
        namespace           = "AWS/EC2"
        threshold           = 80
        severity            = "warning"
        comparison          = "GreaterThanOrEqualToThreshold"
        description         = "CPU utilization is above 80%"
        alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
        evaluation_periods  = 3
        period              = 300
        statistic           = "Average"
        datapoints_to_alarm = 2
        treat_missing_data  = "notBreaching"
      },
      {
        metric_name         = "CPUUtilization"
        namespace           = "AWS/EC2"
        threshold           = 90
        severity            = "critical"
        comparison          = "GreaterThanOrEqualToThreshold"
        description         = "CPU utilization is above 90%"
        alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        evaluation_periods  = 2
        period              = 300
        statistic           = "Average"
        datapoints_to_alarm = 2
        treat_missing_data  = "notBreaching"
      },

      # ========================================
      # Alarmas de Memoria (requiere CWAgent)
      # ========================================
      {
        metric_name         = "mem_used_percent"
        namespace           = "CWAgent"
        threshold           = 80
        severity            = "warning"
        comparison          = "GreaterThanOrEqualToThreshold"
        description         = "Memory usage is above 80%"
        alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
        evaluation_periods  = 3
        period              = 300
        statistic           = "Average"
        datapoints_to_alarm = 2
        treat_missing_data  = "notBreaching"
        # No se requieren dimensiones adicionales para memoria
        additional_dimensions = {}
      },
      {
        metric_name         = "mem_used_percent"
        namespace           = "CWAgent"
        threshold           = 90
        severity            = "critical"
        comparison          = "GreaterThanOrEqualToThreshold"
        description         = "Memory usage is above 90%"
        alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        evaluation_periods  = 2
        period              = 300
        statistic           = "Average"
        datapoints_to_alarm = 2
        treat_missing_data  = "notBreaching"
        additional_dimensions = {}
      },

      # ========================================
      # Alarmas de Disco (requiere CWAgent)
      # ========================================
      {
        metric_name         = "disk_used_percent"
        namespace           = "CWAgent"
        threshold           = 85
        severity            = "warning"
        comparison          = "GreaterThanOrEqualToThreshold"
        description         = "Disk usage on / is above 85%"
        alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:alert-warning"]
        evaluation_periods  = 2
        period              = 300
        statistic           = "Average"
        datapoints_to_alarm = 2
        treat_missing_data  = "notBreaching"
        # Dimensiones adicionales para especificar el disco
        additional_dimensions = {
          path   = "/"
          device = "nvme0n1p1"
          fstype = "xfs"
        }
      },
      {
        metric_name         = "disk_used_percent"
        namespace           = "CWAgent"
        threshold           = 95
        severity            = "critical"
        comparison          = "GreaterThanOrEqualToThreshold"
        description         = "Disk usage on / is above 95%"
        alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:alert-critical"]
        evaluation_periods  = 2
        period              = 300
        statistic           = "Average"
        datapoints_to_alarm = 2
        treat_missing_data  = "notBreaching"
        additional_dimensions = {
          path   = "/"
          device = "nvme0n1p1"
          fstype = "xfs"
        }
      }
    ]
  }
}

# Outputs
output "dashboard_name" {
  description = "Nombre del dashboard creado"
  value       = module.observability_ec2_complete.dashboard_name
}

output "ec2_alarms" {
  description = "Alarmas de EC2 creadas"
  value       = module.observability_ec2_complete.ec2_alarm_names
}
