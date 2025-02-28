# EC2
resource "aws_cloudwatch_dashboard" "ec2_dashboard" {
  count = try(var.ec2.create_dashboard, false) && length(local.ec2_widgets) > 0 ? 1 : 0
  dashboard_name = "${var.client}-${var.project}-${var.environment}-${var.application}-${var.ec2.functionality}"
  dashboard_body = jsonencode({
    "widgets" = local.ec2_widgets
  })
}

resource "aws_cloudwatch_metric_alarm" "ec2_alarms" {
  for_each = try(var.ec2.create_alarms, false) && length(local.ec2_alarms) > 0 ? {
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

# RDS
resource "aws_cloudwatch_dashboard" "rds_dashboard" {
  count = try(var.rds.create_dashboard, false) && length(local.rds_widgets) > 0 ? 1 : 0
  dashboard_name = "${var.client}-${var.project}-${var.environment}-${var.application}-${var.rds.functionality}"
  dashboard_body = jsonencode({
    "widgets" = local.rds_widgets
  })
}

resource "aws_cloudwatch_metric_alarm" "rds_alarm" {
  for_each = try(var.rds.create_alarms, false) && length(local.rds_alarms) > 0 ? {
  for alarm in local.rds_alarms : alarm.alarm_name => alarm} : {}
  alarm_name          = each.value.alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = each.value.metric_name
  namespace          = "AWS/RDS"
  period             = 300
  statistic          = "Average"
  threshold          = each.value.threshold
  alarm_description  = "Alarma para ${each.value.metric_name} en rds ${each.value.id}"
  dimensions = {
    DBInstanceIdentifier = each.value.id
  }
  # actions_enabled = true
  # alarm_actions   = []
}

#Lambda
resource "aws_cloudwatch_dashboard" "lambda_dashboard" {
  count = try(var.lambda.create_dashboard, false) && length(local.lambda_widgets) > 0 ? 1 : 0
  dashboard_name = "${var.client}-${var.project}-${var.environment}-${var.application}-${var.lambda.functionality}"
  dashboard_body = jsonencode({
    "widgets" = local.lambda_widgets
  })
}

resource "aws_cloudwatch_metric_alarm" "lambda_alarm" {
  for_each = try(var.lambda.create_alarms, false) && length(local.lambda_alarms) > 0 ? {
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

# ALB
resource "aws_cloudwatch_dashboard" "alb_dashboard" {
  count = try(var.alb.create_dashboard, false) && length(local.alb_widgets) > 0 ? 1 : 0
  dashboard_name = "${var.client}-${var.project}-${var.environment}-${var.application}-${var.alb.functionality}"
  dashboard_body = jsonencode({
    "widgets" = local.alb_widgets
  })
}

resource "aws_cloudwatch_metric_alarm" "alb_alarms" {
  for_each = try(var.alb.create_alarms, false) && length(local.alb_alarms) > 0 ? {
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

#NLB
resource "aws_cloudwatch_dashboard" "nlb_dashboard" {
  count = try(var.nlb.create_dashboard, false) && length(local.nlb_widgets) > 0 ? 1 : 0
  dashboard_name = "${var.client}-${var.project}-${var.environment}-${var.application}-${var.nlb.functionality}"
  dashboard_body = jsonencode({
    "widgets" = local.nlb_widgets
  })
}

resource "aws_cloudwatch_metric_alarm" "nlb_alarm" {
  for_each = try(var.nlb.create_alarms, false) && length(local.nlb_alarms) > 0 ? {
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

#S3
resource "aws_cloudwatch_dashboard" "s3_dashboard" {
  count = try(var.s3.create_dashboard, false) && length(local.s3_widgets) > 0 ? 1 : 0
  dashboard_name = "${var.client}-${var.project}-${var.environment}-${var.application}-${var.s3.functionality}"
  dashboard_body = jsonencode({
    "widgets" = local.s3_widgets
  })
}

resource "aws_cloudwatch_metric_alarm" "s3_alarm" {
  for_each = try(var.s3.create_alarms, false) && length(local.s3_alarms) > 0 ? {
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

#API Gateway
resource "aws_cloudwatch_dashboard" "apigateway_dashboard" {
  count = try(var.apigateway.create_dashboard, false) && length(local.apigateway_widgets) > 0 ? 1 : 0
  dashboard_name = "${var.client}-${var.project}-${var.environment}-${var.application}-${var.apigateway.functionality}"
  dashboard_body = jsonencode({
    "widgets" = local.apigateway_widgets
  })
}

resource "aws_cloudwatch_metric_alarm" "apigateway_alarm" {
  for_each = try(var.apigateway.create_alarms, false) && length(local.apigateway_alarms) > 0 ? {
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

resource "aws_cloudwatch_dashboard" "dynamodb_dashboard" {
  count = try(var.dynamodb.create_dashboard, false) && length(local.dynamodb_widgets) > 0 ? 1 : 0
  dashboard_name = "${var.client}-${var.project}-${var.environment}-${var.application}-${var.dynamodb.functionality}"
  dashboard_body = jsonencode({
    "widgets" = local.dynamodb_widgets
  })
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_alarm" {
  for_each = try(var.dynamodb.create_alarms, false) && length(local.dynamodb_alarms) > 0 ? {
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