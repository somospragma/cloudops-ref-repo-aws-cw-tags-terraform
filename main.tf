# Un único dashboard consolidado para todos los servicios
resource "aws_cloudwatch_dashboard" "unified_dashboard" {
  count = (try(var.ec2 != null && var.ec2.create_dashboard, false) || 
           try(var.rds != null && var.rds.create_dashboard, false) || 
           try(var.lambda != null && var.lambda.create_dashboard, false) || 
           try(var.alb != null && var.alb.create_dashboard, false) || 
           try(var.nlb != null && var.nlb.create_dashboard, false) || 
           try(var.s3 != null && var.s3.create_dashboard, false) || 
           try(var.apigateway != null && var.apigateway.create_dashboard, false) || 
           try(var.dynamodb != null && var.dynamodb.create_dashboard, false)) ? 1 : 0
           
  dashboard_name = "${var.client}-${var.project}-${var.environment}-${var.application}-unified"
  dashboard_body = jsonencode({
    "widgets" = local.all_widgets
  })
}

# EC2 Alarms
resource "aws_cloudwatch_metric_alarm" "ec2_alarms" {
  for_each = var.ec2 != null && try(var.ec2.create_alarms, false) && length(local.ec2_alarms) > 0 ? {
    for alarm in local.ec2_alarms : alarm.alarm_name => alarm
  } : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = each.value.metric_name
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = each.value.threshold
  alarm_description   = "Alarma para ${each.value.metric_name} en instancia ${each.value.instance_id}"
  dimensions = {
    InstanceId = each.value.instance_id
  }
}

# RDS Alarms
resource "aws_cloudwatch_metric_alarm" "rds_alarm" {
  for_each = var.rds != null && try(var.rds.create_alarms, false) && length(local.rds_alarms) > 0 ? {
    for alarm in local.rds_alarms : alarm.alarm_name => alarm
  } : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = each.value.metric_name
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = each.value.threshold
  alarm_description   = "Alarma para ${each.value.metric_name} en rds ${each.value.id}"
  dimensions = {
    DBInstanceIdentifier = each.value.id
  }
}

# Lambda Alarms
resource "aws_cloudwatch_metric_alarm" "lambda_alarm" {
  for_each = var.lambda != null && try(var.lambda.create_alarms, false) && length(local.lambda_alarms) > 0 ? {
    for alarm in local.lambda_alarms : alarm.alarm_name => alarm
  } : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = each.value.metric_name
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Average"
  threshold           = each.value.threshold
  alarm_description   = "Alarma para ${each.value.metric_name} en Lambda ${each.value.function_name}"
  dimensions = {
    FunctionName = each.value.function_name
  }
}

# ALB Alarms
resource "aws_cloudwatch_metric_alarm" "alb_alarms" {
  for_each = var.alb != null && try(var.alb.create_alarms, false) && length(local.alb_alarms) > 0 ? {
    for alarm in local.alb_alarms : alarm.alarm_name => alarm
  } : {}
  
  alarm_name          = each.value.alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = each.value.metric_name
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = each.value.threshold
  alarm_description   = "Alarma para ${each.value.metric_name} en ALB ${each.value.alb_arn}"
  dimensions = {
    LoadBalancer = each.value.alb_arn
  }
}

# NLB Alarms
resource "aws_cloudwatch_metric_alarm" "nlb_alarm" {
  for_each = var.nlb != null && try(var.nlb.create_alarms, false) && length(local.nlb_alarms) > 0 ? {
    for alarm in local.nlb_alarms : alarm.alarm_name => alarm
  } : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = each.value.metric_name
  namespace           = "AWS/NetworkELB"
  period              = 300
  statistic           = "Average"
  threshold           = each.value.threshold
  alarm_description   = "Alarma para ${each.value.metric_name} en NLB ${each.value.nlb_name}"
  dimensions = {
    LoadBalancer = each.value.nlb_name
  }
}

# S3 Alarms
resource "aws_cloudwatch_metric_alarm" "s3_alarm" {
  for_each = var.s3 != null && try(var.s3.create_alarms, false) && length(local.s3_alarms) > 0 ? {
    for alarm in local.s3_alarms : alarm.alarm_name => alarm
  } : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = each.value.metric_name
  namespace           = "AWS/S3"
  period              = 300
  statistic           = "Average"
  threshold           = each.value.threshold
  alarm_description   = "Alarma para ${each.value.metric_name} en S3 ${each.value.bucket_name}"
  dimensions = {
    BucketName  = each.value.bucket_name
    StorageType = "Standard"
  }
}

# API Gateway Alarms
resource "aws_cloudwatch_metric_alarm" "apigateway_alarm" {
  for_each = var.apigateway != null && try(var.apigateway.create_alarms, false) && length(local.apigateway_alarms) > 0 ? {
    for alarm in local.apigateway_alarms : alarm.alarm_name => alarm
  } : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = each.value.metric_name
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Average"
  threshold           = each.value.threshold
  alarm_description   = "Alarma para ${each.value.metric_name} en API Gateway ${each.value.api_id}"
  dimensions = {
    ApiId = each.value.api_id
  }
}

# DynamoDB Alarms
resource "aws_cloudwatch_metric_alarm" "dynamodb_alarm" {
  for_each = var.dynamodb != null && try(var.dynamodb.create_alarms, false) && length(local.dynamodb_alarms) > 0 ? {
    for alarm in local.dynamodb_alarms : alarm.alarm_name => alarm
  } : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = each.value.metric_name
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Average"
  threshold           = each.value.threshold
  alarm_description   = "Alarma para ${each.value.metric_name} en la tabla DynamoDB ${each.value.table_name}"
  dimensions = {
    TableName = each.value.table_name
  }
}