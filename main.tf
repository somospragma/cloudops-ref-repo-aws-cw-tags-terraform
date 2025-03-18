###########################################################
# Dasboard Consolidado
###########################################################
resource "aws_cloudwatch_dashboard" "unified_dashboard" {
  count = (
    (try(var.ec2 != null && var.ec2.create_dashboard, false) && try(length(try(data.aws_instances.ec2_tagged[0].ids, [])), 0) > 0) ||
    (try(var.rds != null && var.rds.create_dashboard, false) && length(local.rds_instances_filtered) > 0) ||
    (try(var.lambda != null && var.lambda.create_dashboard, false) && length(local.lambda_functions_filtered) > 0) ||
    (try(var.alb != null && var.alb.create_dashboard, false) && length(local.alb_instances_filtered) > 0) ||
    (try(var.nlb != null && var.nlb.create_dashboard, false) && length(local.nlb_filtered) > 0) ||
    (try(var.s3 != null && var.s3.create_dashboard, false) && length(local.s3_buckets_filtered) > 0) ||
    (try(var.apigateway != null && var.apigateway.create_dashboard, false) && length(local.apigateway_filtered) > 0) ||
    (try(var.dynamodb != null && var.dynamodb.create_dashboard, false) && length(local.dynamodb_filtered) > 0)
  ) ? 1 : 0

  dashboard_name = "${var.client}-${var.project}-${var.environment}-${var.application}-unified"
  dashboard_body = jsonencode({
    "widgets" = local.all_widgets
  })
}

###########################################################
# Alarma CloudWatch EC2
###########################################################
resource "aws_cloudwatch_metric_alarm" "ec2_alarms" {
  for_each = var.ec2 != null && try(var.ec2.create_alarms, false) && length(local.ec2_alarms) > 0 ? {
    for alarm in local.ec2_alarms : alarm.alarm_name => alarm
  } : {}
  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = "AWS/EC2"
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description
  dimensions          = each.value.dimensions
  alarm_actions       = each.value.actions
  datapoints_to_alarm = each.value.datapoints_to_alarm
  treat_missing_data  = each.value.treat_missing_data
}

###########################################################
# Alarma CloudWatch RDS/Aurora
###########################################################
resource "aws_cloudwatch_metric_alarm" "rds_alarm" {
  for_each = var.rds != null && try(var.rds.create_alarms, false) && length(local.rds_alarms) > 0 ? {
    for alarm in local.rds_alarms : alarm.alarm_name => alarm
  } : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = "AWS/RDS"
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description
  dimensions          = each.value.dimensions
  alarm_actions       = each.value.actions
  datapoints_to_alarm = each.value.datapoints_to_alarm
  treat_missing_data  = each.value.treat_missing_data
}

###########################################################
# Alarma CloudWatch Lambdas
###########################################################
resource "aws_cloudwatch_metric_alarm" "lambda_alarm" {
  for_each = var.lambda != null && try(var.lambda.create_alarms, false) && length(local.lambda_alarms) > 0 ? {
    for alarm in local.lambda_alarms : alarm.alarm_name => alarm
  } : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = "AWS/Lambda"
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description
  dimensions          = each.value.dimensions
  alarm_actions       = each.value.actions
  datapoints_to_alarm = each.value.datapoints_to_alarm
  treat_missing_data  = each.value.treat_missing_data
}

###########################################################
# Alarma CloudWatch ALB
###########################################################
resource "aws_cloudwatch_metric_alarm" "alb_alarms" {
  for_each = var.alb != null && try(var.alb.create_alarms, false) && length(local.alb_alarms) > 0 ? {
    for alarm in local.alb_alarms : alarm.alarm_name => alarm
  } : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = "AWS/ApplicationELB"
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description
  dimensions          = each.value.dimensions
  alarm_actions       = each.value.actions
  datapoints_to_alarm = each.value.datapoints_to_alarm
  treat_missing_data  = each.value.treat_missing_data
}

###########################################################
# Alarma CloudWatch NLB
###########################################################
resource "aws_cloudwatch_metric_alarm" "nlb_alarm" {
  for_each = var.nlb != null && try(var.nlb.create_alarms, false) && length(local.nlb_alarms) > 0 ? {
    for alarm in local.nlb_alarms : alarm.alarm_name => alarm
  } : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = "AWS/NetworkELB"
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description
  dimensions          = each.value.dimensions
  alarm_actions       = each.value.actions
  datapoints_to_alarm = each.value.datapoints_to_alarm
  treat_missing_data  = each.value.treat_missing_data
}

###########################################################
# Alarma CloudWatch S3
###########################################################
resource "aws_cloudwatch_metric_alarm" "s3_alarm" {
  for_each = var.s3 != null && try(var.s3.create_alarms, false) && length(local.s3_alarms) > 0 ? {
    for alarm in local.s3_alarms : alarm.alarm_name => alarm
  } : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = "AWS/S3"
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description
  dimensions          = each.value.dimensions
  alarm_actions       = each.value.actions
  datapoints_to_alarm = each.value.datapoints_to_alarm
  treat_missing_data  = each.value.treat_missing_data
}

###########################################################
# Alarma CloudWatch Api Gateway
###########################################################
resource "aws_cloudwatch_metric_alarm" "apigateway_alarm" {
  for_each = var.apigateway != null && try(var.apigateway.create_alarms, false) && length(local.apigateway_alarms) > 0 ? {
    for alarm in local.apigateway_alarms : alarm.alarm_name => alarm
  } : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = "AWS/ApiGateway"
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description
  dimensions          = each.value.dimensions
  alarm_actions       = each.value.actions
  datapoints_to_alarm = each.value.datapoints_to_alarm
  treat_missing_data  = each.value.treat_missing_data
}

###########################################################
# Alarma CloudWatch Dynamodb
###########################################################
resource "aws_cloudwatch_metric_alarm" "dynamodb_alarm" {
  for_each = var.dynamodb != null && try(var.dynamodb.create_alarms, false) && length(local.dynamodb_alarms) > 0 ? {
    for alarm in local.dynamodb_alarms : alarm.alarm_name => alarm
  } : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = "AWS/DynamoDB"
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description
  dimensions          = each.value.dimensions
  alarm_actions       = each.value.actions
  datapoints_to_alarm = each.value.datapoints_to_alarm
  treat_missing_data  = each.value.treat_missing_data
}
