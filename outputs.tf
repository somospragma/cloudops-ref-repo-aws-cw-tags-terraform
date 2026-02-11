###########################################################
# Outputs - Dashboard
###########################################################

output "dashboard_name" {
  description = "Nombre del dashboard de CloudWatch creado"
  value       = try(aws_cloudwatch_dashboard.unified_dashboard[0].dashboard_name, null)
}

output "dashboard_arn" {
  description = "ARN del dashboard de CloudWatch creado"
  value       = try(aws_cloudwatch_dashboard.unified_dashboard[0].dashboard_arn, null)
}

output "dashboard_url" {
  description = "URL del dashboard en la consola de AWS CloudWatch"
  value = try(
    "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.id}#dashboards:name=${aws_cloudwatch_dashboard.unified_dashboard[0].dashboard_name}",
    null
  )
}

output "all_widgets_count" {
  description = "Número total de widgets en el dashboard"
  value       = length(local.all_widgets)
}

###########################################################
# Outputs - Recursos Descubiertos
###########################################################

output "resources_discovered" {
  description = "Resumen de recursos descubiertos por servicio mediante tags"
  value = {
    ec2         = length(try(data.aws_instances.ec2_tagged[0].ids, []))
    rds         = length(local.rds_instances_filtered)
    lambda      = length(local.lambda_functions_filtered)
    alb         = length(local.alb_instances_filtered)
    nlb         = length(local.nlb_filtered)
    s3          = length(local.s3_buckets_filtered)
    apigateway  = length(local.apigateway_filtered)
    dynamodb    = length(local.dynamodb_filtered)
    ecs_clusters = length(local.ecs_clusters_filtered)
    ecs_services = length(local.ecs_services_filtered)
    waf         = length(local.waf_webacls_filtered)
  }
}

###########################################################
# Outputs - Alarmas EC2
###########################################################

output "ec2_alarm_names" {
  description = "Nombres de las alarmas de EC2 creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.ec2_alarms : alarm.alarm_name]
}

output "ec2_alarm_arns" {
  description = "ARNs de las alarmas de EC2 creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.ec2_alarms : alarm.arn]
}

###########################################################
# Outputs - Alarmas RDS
###########################################################

output "rds_alarm_names" {
  description = "Nombres de las alarmas de RDS creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.rds_alarm : alarm.alarm_name]
}

output "rds_alarm_arns" {
  description = "ARNs de las alarmas de RDS creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.rds_alarm : alarm.arn]
}

###########################################################
# Outputs - Alarmas Lambda
###########################################################

output "lambda_alarm_names" {
  description = "Nombres de las alarmas de Lambda creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.lambda_alarm : alarm.alarm_name]
}

output "lambda_alarm_arns" {
  description = "ARNs de las alarmas de Lambda creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.lambda_alarm : alarm.arn]
}

###########################################################
# Outputs - Alarmas ALB
###########################################################

output "alb_alarm_names" {
  description = "Nombres de las alarmas de ALB creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.alb_alarms : alarm.alarm_name]
}

output "alb_alarm_arns" {
  description = "ARNs de las alarmas de ALB creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.alb_alarms : alarm.arn]
}

###########################################################
# Outputs - Alarmas NLB
###########################################################

output "nlb_alarm_names" {
  description = "Nombres de las alarmas de NLB creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.nlb_alarm : alarm.alarm_name]
}

output "nlb_alarm_arns" {
  description = "ARNs de las alarmas de NLB creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.nlb_alarm : alarm.arn]
}

###########################################################
# Outputs - Alarmas S3
###########################################################

output "s3_alarm_names" {
  description = "Nombres de las alarmas de S3 creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.s3_alarm : alarm.alarm_name]
}

output "s3_alarm_arns" {
  description = "ARNs de las alarmas de S3 creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.s3_alarm : alarm.arn]
}

###########################################################
# Outputs - Alarmas API Gateway
###########################################################

output "apigateway_alarm_names" {
  description = "Nombres de las alarmas de API Gateway creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.apigateway_alarm : alarm.alarm_name]
}

output "apigateway_alarm_arns" {
  description = "ARNs de las alarmas de API Gateway creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.apigateway_alarm : alarm.arn]
}

###########################################################
# Outputs - Alarmas DynamoDB
###########################################################

output "dynamodb_alarm_names" {
  description = "Nombres de las alarmas de DynamoDB creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.dynamodb_alarm : alarm.alarm_name]
}

output "dynamodb_alarm_arns" {
  description = "ARNs de las alarmas de DynamoDB creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.dynamodb_alarm : alarm.arn]
}

###########################################################
# Outputs - Alarmas ECS
###########################################################

output "ecs_alarm_names" {
  description = "Nombres de las alarmas de ECS creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.ecs_alarm : alarm.alarm_name]
}

output "ecs_alarm_arns" {
  description = "ARNs de las alarmas de ECS creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.ecs_alarm : alarm.arn]
}

###########################################################
# Outputs - Alarmas ECS Container Insights
###########################################################

output "ecs_insights_alarm_names" {
  description = "Nombres de las alarmas de ECS Container Insights creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.ecs_insights_alarm : alarm.alarm_name]
}

output "ecs_insights_alarm_arns" {
  description = "ARNs de las alarmas de ECS Container Insights creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.ecs_insights_alarm : alarm.arn]
}

###########################################################
# Outputs - Alarmas WAF
###########################################################

output "waf_alarm_names" {
  description = "Nombres de las alarmas de WAF creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.waf_alarm : alarm.alarm_name]
}

output "waf_alarm_arns" {
  description = "ARNs de las alarmas de WAF creadas"
  value       = [for alarm in aws_cloudwatch_metric_alarm.waf_alarm : alarm.arn]
}

###########################################################
# Outputs - Resumen de Alarmas
###########################################################

output "total_alarms_created" {
  description = "Número total de alarmas creadas por servicio"
  value = {
    ec2         = length(aws_cloudwatch_metric_alarm.ec2_alarms)
    rds         = length(aws_cloudwatch_metric_alarm.rds_alarm)
    lambda      = length(aws_cloudwatch_metric_alarm.lambda_alarm)
    alb         = length(aws_cloudwatch_metric_alarm.alb_alarms)
    nlb         = length(aws_cloudwatch_metric_alarm.nlb_alarm)
    s3          = length(aws_cloudwatch_metric_alarm.s3_alarm)
    apigateway  = length(aws_cloudwatch_metric_alarm.apigateway_alarm)
    dynamodb    = length(aws_cloudwatch_metric_alarm.dynamodb_alarm)
    ecs         = length(aws_cloudwatch_metric_alarm.ecs_alarm)
    ecs_insights = length(aws_cloudwatch_metric_alarm.ecs_insights_alarm)
    waf         = length(aws_cloudwatch_metric_alarm.waf_alarm)
    total       = (
      length(aws_cloudwatch_metric_alarm.ec2_alarms) +
      length(aws_cloudwatch_metric_alarm.rds_alarm) +
      length(aws_cloudwatch_metric_alarm.lambda_alarm) +
      length(aws_cloudwatch_metric_alarm.alb_alarms) +
      length(aws_cloudwatch_metric_alarm.nlb_alarm) +
      length(aws_cloudwatch_metric_alarm.s3_alarm) +
      length(aws_cloudwatch_metric_alarm.apigateway_alarm) +
      length(aws_cloudwatch_metric_alarm.dynamodb_alarm) +
      length(aws_cloudwatch_metric_alarm.ecs_alarm) +
      length(aws_cloudwatch_metric_alarm.ecs_insights_alarm) +
      length(aws_cloudwatch_metric_alarm.waf_alarm)
    )
  }
}

###########################################################
# Outputs - Debug (ECS)
###########################################################

output "ecs_clusters_filtered_debug" {
  description = "Debug: Lista de clusters ECS descubiertos"
  value       = local.ecs_clusters_filtered
}

output "ecs_services_filtered_debug" {
  description = "Debug: Lista de servicios ECS descubiertos"
  value       = local.ecs_services_filtered
}

output "ecs_resource_tag_mapping_debug" {
  description = "Debug: Resource tag mapping de ECS"
  value       = try(data.aws_resourcegroupstaggingapi_resources.ecs_clusters_filtered[0].resource_tag_mapping_list, [])
}

output "ecs_widgets_debug" {
  description = "Debug: Widgets de ECS generados"
  value       = local.ecs_metric_widgets
}

output "dashboard_body_excerpt" {
  description = "Debug: Contenido del dashboard para inspección"
  value       = try(jsondecode(aws_cloudwatch_dashboard.unified_dashboard[0].dashboard_body).widgets, [])
}