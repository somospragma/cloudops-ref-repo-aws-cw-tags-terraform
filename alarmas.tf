###########################################################
# Locals Definicion de Alarmas.
###########################################################
locals {

###########################################################
# Alarmas - CloudWatch EC2
###########################################################
  ec2_alarms = var.ec2 != null && try(var.ec2.create_alarms, false) && try(length(try(data.aws_instances.ec2_tagged[0].ids, [])), 0) > 0 ? concat(
    flatten([
      for instance_id in try(data.aws_instances.ec2_tagged[0].ids, []) : [
        for alarm in try(var.ec2.alarm_config, []) : {
          alarm_name  = "ec2-${alarm.metric_name}-${try(alarm.severity, "warning")}-${instance_id}"
          metric_name = alarm.metric_name
          threshold   = alarm.threshold
          instance_id = instance_id
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en instancia ${instance_id}")
          dimensions = {
            InstanceId = instance_id
          }
          actions = try(alarm.actions, [])
          datapoints_to_alarm = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data = try(alarm.treat_missing_data, "missing")
        }
      ]
    ])
  ) : []

###########################################################
# Alarmas - CloudWatch RDS
###########################################################
  rds_alarms = var.rds != null && try(var.rds.create_alarms, false) && length(local.rds_instances_filtered) > 0 ? concat(
    flatten([
      for id in local.rds_instances_filtered : [
        for alarm in try(var.rds.alarm_config, []) : {
          alarm_name  = "rds-${alarm.metric_name}-${try(alarm.severity, "warning")}-${id}"
          metric_name = alarm.metric_name
          threshold   = alarm.threshold
          id          = id
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en RDS ${id}")
          dimensions = {
            DBInstanceIdentifier = id
          }
          actions = try(alarm.actions, [])
          datapoints_to_alarm = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data = try(alarm.treat_missing_data, "missing")          
        }
      ]
    ])
  ) : []

###########################################################
# Alarmas - CloudWatch Lambdas
###########################################################  
  lambda_alarms = var.lambda != null && try(var.lambda.create_alarms, false) && length(local.lambda_functions_filtered) > 0 ? concat(
    flatten([
      for function_name in local.lambda_functions_filtered : [
        for alarm in try(var.lambda.alarm_config, []) : {
          alarm_name  = "lambda-${alarm.metric_name}-${try(alarm.severity, "warning")}-${function_name}"
          metric_name = alarm.metric_name
          threshold   = alarm.threshold
          function_name = function_name
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en Lambda ${function_name}")
          dimensions = {
            FunctionName = function_name
          }
          actions = try(alarm.actions, [])
          datapoints_to_alarm = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data = try(alarm.treat_missing_data, "missing")
        }
      ]
    ])
  ) : []

###########################################################
# Alarmas - CloudWatch alb
###########################################################  
  alb_alarms = var.alb != null && try(var.alb.create_alarms, false) && length(local.alb_instances_filtered) > 0 ? concat(
    flatten([
      for alb in local.alb_instances_filtered : [
        for alarm in try(var.alb.alarm_config, []) : {
          alarm_name  = "alb-${alarm.metric_name}-${try(alarm.severity, "warning")}-${alb}"
          metric_name = alarm.metric_name
          threshold   = alarm.threshold
          alb_arn     = alb
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en ALB ${alb}")
          dimensions = {
            LoadBalancer = alb
          }
          actions = try(alarm.actions, [])
          datapoints_to_alarm = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data = try(alarm.treat_missing_data, "missing")
        }
      ]
    ])
  ) : []

###########################################################
# Alarmas - CloudWatch NLB
###########################################################  
  nlb_alarms = var.nlb != null && try(var.nlb.create_alarms, false) && length(local.nlb_filtered) > 0 ? concat(
    flatten([
      for nlb_name in local.nlb_filtered : [
        for alarm in try(var.nlb.alarm_config, []) : {
          alarm_name  = "nlb-${alarm.metric_name}-${try(alarm.severity, "warning")}-${nlb_name}"
          metric_name = alarm.metric_name
          threshold   = alarm.threshold
          nlb_name    = nlb_name
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en NLB ${nlb_name}")
          dimensions = {
            LoadBalancer = nlb_name
          }
          actions = try(alarm.actions, [])
          datapoints_to_alarm = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data = try(alarm.treat_missing_data, "missing")
        }
      ]
    ])
  ) : []

###########################################################
# Alarmas - CloudWatch S3
########################################################### 
  s3_alarms = var.s3 != null && try(var.s3.create_alarms, false) && length(local.s3_buckets_filtered) > 0 ? concat(
    flatten([
      for bucket in local.s3_buckets_filtered : [
        for alarm in try(var.s3.alarm_config, []) : {
          alarm_name  = "s3-${alarm.metric_name}-${try(alarm.severity, "warning")}-${bucket}"
          metric_name = alarm.metric_name
          threshold   = alarm.threshold
          bucket_name = bucket
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en S3 ${bucket}")
          dimensions = {
            BucketName  = bucket
            StorageType = "Standard"
          }
          actions = try(alarm.actions, [])
          datapoints_to_alarm = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data = try(alarm.treat_missing_data, "missing")
        }
      ]
    ])
  ) : []

###########################################################
# Alarmas - CloudWatch Api Gateway
###########################################################
  apigateway_alarms = var.apigateway != null && try(var.apigateway.create_alarms, false) && length(local.apigateway_filtered) > 0 ? concat(
    flatten([
      for api_id in local.apigateway_filtered : [
        for alarm in try(var.apigateway.alarm_config, []) : {
          alarm_name  = "apigateway-${alarm.metric_name}-${try(alarm.severity, "warning")}-${api_id}"
          metric_name = alarm.metric_name
          threshold   = alarm.threshold
          api_id      = api_id
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en API Gateway ${api_id}")
          dimensions = {
            ApiId = api_id
          }
          actions = try(alarm.actions, [])
          datapoints_to_alarm = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data = try(alarm.treat_missing_data, "missing")
        }
      ]
    ])
  ) : []

###########################################################
# Alarmas - CloudWatch Dynamodb
###########################################################
  dynamodb_alarms = var.dynamodb != null && try(var.dynamodb.create_alarms, false) && length(local.dynamodb_filtered) > 0 ? concat(
    flatten([
      for table in local.dynamodb_filtered : [
        for alarm in try(var.dynamodb.alarm_config, []) : {
          alarm_name  = "dynamodb-${alarm.metric_name}-${try(alarm.severity, "warning")}-${table}"
          metric_name = alarm.metric_name
          threshold   = alarm.threshold
          table_name  = table
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en tabla DynamoDB ${table}")
          dimensions = {
            TableName = table
          }
          actions = try(alarm.actions, [])
          datapoints_to_alarm = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data = try(alarm.treat_missing_data, "missing")
        }
      ]
    ])
  ) : []
}