# Ejemplo de configuración de EC2 con CloudWatch Agent
# Este ejemplo muestra cómo crear SOLO ALARMAS para CPU (nativa), Memoria y Disco (CWAgent)
# NO crea dashboards, solo alarmas

module "observability_ec2_alarms_only" {
  source = "../../"

  client      = var.client
  project     = var.project
  environment = var.environment
  application = var.application

  ec2 = {
    functionality    = "compute"
    create_dashboard = false # NO crear dashboard
    create_alarms    = true  # SOLO crear alarmas
    tag_key          = "EnableObservability"
    tag_value        = "true"

    # Configuración de alarmas: CPU + Memoria + Disco
    alarm_config = [
      # ========================================
      # Alarmas de CPU (métricas nativas AWS/EC2)
      # No requiere CloudWatch Agent
      # ========================================
      {
        metric_name         = "CPUUtilization"
        namespace           = "AWS/EC2"
        threshold           = 80
        severity            = "warning"
        comparison          = "GreaterThanOrEqualToThreshold"
        description         = "CPU utilization is above 80%"
        alarm_actions       = [var.sns_topic_warning]
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
        alarm_actions       = [var.sns_topic_critical]
        evaluation_periods  = 2
        period              = 300
        statistic           = "Average"
        datapoints_to_alarm = 2
        treat_missing_data  = "notBreaching"
      },

      # ========================================
      # Alarmas de Memoria (requiere CloudWatch Agent)
      # Namespace: CWAgent
      # Métrica: mem_used_percent
      # ========================================
      {
        metric_name           = "mem_used_percent"
        namespace             = "CWAgent"
        threshold             = 80
        severity              = "warning"
        comparison            = "GreaterThanOrEqualToThreshold"
        description           = "Memory usage is above 80%"
        alarm_actions         = [var.sns_topic_warning]
        evaluation_periods    = 3
        period                = 300
        statistic             = "Average"
        datapoints_to_alarm   = 2
        treat_missing_data    = "notBreaching"
        additional_dimensions = {}
      },
      {
        metric_name           = "mem_used_percent"
        namespace             = "CWAgent"
        threshold             = 90
        severity              = "critical"
        comparison            = "GreaterThanOrEqualToThreshold"
        description           = "Memory usage is above 90%"
        alarm_actions         = [var.sns_topic_critical]
        evaluation_periods    = 2
        period                = 300
        statistic             = "Average"
        datapoints_to_alarm   = 2
        treat_missing_data    = "notBreaching"
        additional_dimensions = {}
      },

      # ========================================
      # Alarmas de Disco (requiere CloudWatch Agent)
      # Namespace: CWAgent
      # Métrica: disk_used_percent
      # Dimensiones: path, device, fstype
      # 
      # NOTA: Puedes agregar más discos copiando estos bloques
      # y cambiando los valores de path, device, fstype
      # ========================================
      
      # Disco 1: / (raíz)
      {
        metric_name         = "disk_used_percent"
        namespace           = "CWAgent"
        threshold           = 85
        severity            = "warning"
        comparison          = "GreaterThanOrEqualToThreshold"
        description         = "Disk usage on ${var.disk_path} is above 85%"
        alarm_actions       = [var.sns_topic_warning]
        evaluation_periods  = 2
        period              = 300
        statistic           = "Average"
        datapoints_to_alarm = 2
        treat_missing_data  = "notBreaching"
        additional_dimensions = {
          path   = var.disk_path
          device = var.disk_device
          fstype = var.disk_fstype
        }
      },
      {
        metric_name         = "disk_used_percent"
        namespace           = "CWAgent"
        threshold           = 95
        severity            = "critical"
        comparison          = "GreaterThanOrEqualToThreshold"
        description         = "Disk usage on ${var.disk_path} is above 95%"
        alarm_actions       = [var.sns_topic_critical]
        evaluation_periods  = 2
        period              = 300
        statistic           = "Average"
        datapoints_to_alarm = 2
        treat_missing_data  = "notBreaching"
        additional_dimensions = {
          path   = var.disk_path
          device = var.disk_device
          fstype = var.disk_fstype
        }
      }

      # ========================================
      # EJEMPLO: Agregar más discos (comentado)
      # Descomenta y ajusta si necesitas monitorear /data o /var
      # ========================================
      
      # # Disco 2: /data
      # {
      #   metric_name         = "disk_used_percent"
      #   namespace           = "CWAgent"
      #   threshold           = 85
      #   severity            = "warning"
      #   comparison          = "GreaterThanOrEqualToThreshold"
      #   description         = "Disk usage on /data is above 85%"
      #   alarm_actions       = [var.sns_topic_warning]
      #   evaluation_periods  = 2
      #   period              = 300
      #   statistic           = "Average"
      #   datapoints_to_alarm = 2
      #   treat_missing_data  = "notBreaching"
      #   additional_dimensions = {
      #     path   = "/data"
      #     device = "nvme1n1"
      #     fstype = "xfs"
      #   }
      # },
      # {
      #   metric_name         = "disk_used_percent"
      #   namespace           = "CWAgent"
      #   threshold           = 95
      #   severity            = "critical"
      #   comparison          = "GreaterThanOrEqualToThreshold"
      #   description         = "Disk usage on /data is above 95%"
      #   alarm_actions       = [var.sns_topic_critical]
      #   evaluation_periods  = 2
      #   period              = 300
      #   statistic           = "Average"
      #   datapoints_to_alarm = 2
      #   treat_missing_data  = "notBreaching"
      #   additional_dimensions = {
      #     path   = "/data"
      #     device = "nvme1n1"
      #     fstype = "xfs"
      #   }
      # }
    ]
  }
}

###########################################################
# Outputs
###########################################################

output "ec2_alarms" {
  description = "Alarmas de EC2 creadas"
  value       = module.observability_ec2_alarms_only.ec2_alarm_names
}

output "summary" {
  description = "Resumen de recursos y alarmas creadas"
  value = {
    ec2_instances_discovered = module.observability_ec2_alarms_only.resources_discovered.ec2
    total_alarms_created     = module.observability_ec2_alarms_only.total_alarms_created.ec2
    alarm_names              = module.observability_ec2_alarms_only.ec2_alarm_names
  }
}
