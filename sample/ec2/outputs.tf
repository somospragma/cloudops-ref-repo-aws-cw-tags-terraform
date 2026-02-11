###########################################################
# Outputs - EC2 Alarms
###########################################################

output "ec2_alarm_names" {
  description = "Nombres de las alarmas de EC2 creadas"
  value       = module.observability_ec2_alarms_only.ec2_alarm_names
}

output "ec2_alarm_arns" {
  description = "ARNs de las alarmas de EC2 creadas"
  value       = module.observability_ec2_alarms_only.ec2_alarm_arns
}

output "resources_discovered" {
  description = "Recursos EC2 descubiertos con el tag EnableObservability=true"
  value       = module.observability_ec2_alarms_only.resources_discovered
}

output "total_alarms_created" {
  description = "Total de alarmas creadas por servicio"
  value       = module.observability_ec2_alarms_only.total_alarms_created
}

###########################################################
# Outputs - Información Útil
###########################################################

output "dashboard_url" {
  description = "URL del dashboard en la consola de AWS (si se creó)"
  value       = module.observability_ec2_alarms_only.dashboard_url
}

output "summary" {
  description = "Resumen de la configuración aplicada"
  value = {
    client      = var.client
    project     = var.project
    environment = var.environment
    application = var.application
    region      = var.aws_region
    ec2_instances_found = module.observability_ec2_alarms_only.resources_discovered.ec2
    total_alarms        = module.observability_ec2_alarms_only.total_alarms_created.total
  }
}