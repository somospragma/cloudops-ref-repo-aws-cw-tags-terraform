# Ejemplo de configuración de EC2 con CloudWatch Agent
# Este ejemplo muestra cómo crear SOLO ALARMAS para CPU (nativa), Memoria y Disco (CWAgent)
# NO crea dashboards, solo alarmas

module "observability_ec2_alarms_only" {
  source = "../"

  client      = "pragma"
  project     = "myproject"
  environment = "production"
  application = "webserver"

  ec2 = {
    functionality    = "compute"
    create_dashboard = false  # NO crear dashboard
    create_alarms    = true   # SOLO crear alarmas
    tag_key          = "EnableObservability"
    tag_value        = "true"

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
output "ec2_alarms" {
  description = "Alarmas de EC2 creadas"
  value       = module.observability_ec2_alarms_only.ec2_alarm_names
}
