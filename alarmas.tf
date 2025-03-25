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
          alarm_name          = "ec2-${alarm.metric_name}-${try(alarm.severity, "warning")}-${instance_id}"
          metric_name         = alarm.metric_name
          threshold           = alarm.threshold
          instance_id         = instance_id
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en instancia ${instance_id}")
          dimensions = {
            InstanceId = instance_id
          }
          actions                   = try(alarm.actions, [])
          alarm_actions             = try(alarm.alarm_actions, try(alarm.actions, []))
          insufficient_data_actions = try(alarm.insufficient_data_actions, [])
          ok_actions                = try(alarm.ok_actions, [])
          datapoints_to_alarm       = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data        = try(alarm.treat_missing_data, "missing")
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
          alarm_name          = "rds-${alarm.metric_name}-${try(alarm.severity, "warning")}-${id}"
          metric_name         = alarm.metric_name
          threshold           = alarm.threshold
          id                  = id
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en RDS ${id}")
          dimensions = {
            DBInstanceIdentifier = id
          }
          actions                   = try(alarm.actions, [])
          alarm_actions             = try(alarm.alarm_actions, try(alarm.actions, []))
          insufficient_data_actions = try(alarm.insufficient_data_actions, [])
          ok_actions                = try(alarm.ok_actions, [])
          datapoints_to_alarm       = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data        = try(alarm.treat_missing_data, "missing")
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
          alarm_name          = "lambda-${alarm.metric_name}-${try(alarm.severity, "warning")}-${function_name}"
          metric_name         = alarm.metric_name
          threshold           = alarm.threshold
          function_name       = function_name
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en Lambda ${function_name}")
          dimensions = {
            FunctionName = function_name
          }
          actions                   = try(alarm.actions, [])
          alarm_actions             = try(alarm.alarm_actions, try(alarm.actions, []))
          insufficient_data_actions = try(alarm.insufficient_data_actions, [])
          ok_actions                = try(alarm.ok_actions, [])
          datapoints_to_alarm       = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data        = try(alarm.treat_missing_data, "missing")
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
          alarm_name          = "alb-${alarm.metric_name}-${try(alarm.severity, "warning")}-${alb}"
          metric_name         = alarm.metric_name
          threshold           = alarm.threshold
          alb_arn             = alb
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en ALB ${alb}")
          dimensions = {
            LoadBalancer = alb
          }
          actions                   = try(alarm.actions, [])
          alarm_actions             = try(alarm.alarm_actions, try(alarm.actions, []))
          insufficient_data_actions = try(alarm.insufficient_data_actions, [])
          ok_actions                = try(alarm.ok_actions, [])
          datapoints_to_alarm       = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data        = try(alarm.treat_missing_data, "missing")
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
          alarm_name          = "nlb-${alarm.metric_name}-${try(alarm.severity, "warning")}-${nlb_name}"
          metric_name         = alarm.metric_name
          threshold           = alarm.threshold
          nlb_name            = nlb_name
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en NLB ${nlb_name}")
          dimensions = {
            LoadBalancer = nlb_name
          }
          actions                   = try(alarm.actions, [])
          alarm_actions             = try(alarm.alarm_actions, try(alarm.actions, []))
          insufficient_data_actions = try(alarm.insufficient_data_actions, [])
          ok_actions                = try(alarm.ok_actions, [])
          datapoints_to_alarm       = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data        = try(alarm.treat_missing_data, "missing")
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
          alarm_name = (
            alarm.metric_name == "NumberOfObjects"
            ? "s3-${alarm.metric_name}-${try(alarm.severity, "warning")}-${bucket}"
            : "s3-${alarm.metric_name}-${try(alarm.severity, "warning")}-${try(alarm.storage_type, "Standard")}-${bucket}"
          )
          metric_name         = alarm.metric_name
          threshold           = alarm.threshold
          bucket_name         = bucket
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en S3 ${bucket}")
          dimensions = (
            alarm.metric_name == "NumberOfObjects"
            ? {
              BucketName  = bucket
              StorageType = "AllStorageTypes"
            }
            : {
              BucketName  = bucket
              StorageType = try(alarm.storage_type, "Standard")
            }
          )
          actions                   = try(alarm.actions, [])
          alarm_actions             = try(alarm.alarm_actions, try(alarm.actions, []))
          insufficient_data_actions = try(alarm.insufficient_data_actions, [])
          ok_actions                = try(alarm.ok_actions, [])
          datapoints_to_alarm       = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data        = try(alarm.treat_missing_data, "missing")
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
          alarm_name          = "apigateway-${alarm.metric_name}-${try(alarm.severity, "warning")}-${api_id}"
          metric_name         = alarm.metric_name
          threshold           = alarm.threshold
          api_id              = api_id
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en API Gateway ${api_id}")
          dimensions = {
            ApiId = api_id
          }
          actions                   = try(alarm.actions, [])
          alarm_actions             = try(alarm.alarm_actions, try(alarm.actions, []))
          insufficient_data_actions = try(alarm.insufficient_data_actions, [])
          ok_actions                = try(alarm.ok_actions, [])
          datapoints_to_alarm       = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data        = try(alarm.treat_missing_data, "missing")
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
          alarm_name          = "dynamodb-${alarm.metric_name}-${try(alarm.severity, "warning")}-${table}"
          metric_name         = alarm.metric_name
          threshold           = alarm.threshold
          table_name          = table
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en tabla DynamoDB ${table}")
          dimensions = {
            TableName = table
          }
          actions                   = try(alarm.actions, [])
          alarm_actions             = try(alarm.alarm_actions, try(alarm.actions, []))
          insufficient_data_actions = try(alarm.insufficient_data_actions, [])
          ok_actions                = try(alarm.ok_actions, [])
          datapoints_to_alarm       = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data        = try(alarm.treat_missing_data, "missing")
        }
      ]
    ])
  ) : []

  ###########################################################
  # Alarmas - CloudWatch ECS Estándar
  ###########################################################
  ecs_alarms = var.ecs != null && try(var.ecs.create_alarms, false) && (length(local.ecs_clusters_filtered) > 0 || length(local.ecs_services_filtered) > 0) ? concat(
    # Alarmas configuradas manualmente
    flatten([
      for alarm in try(var.ecs.alarm_config, []) : {
        alarm_name          = "ecs-${alarm.metric_name}-${try(alarm.severity, "warning")}-${alarm.dimension_value}"
        metric_name         = alarm.metric_name
        namespace           = "AWS/ECS"
        threshold           = alarm.threshold
        comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
        evaluation_periods  = try(alarm.evaluation_periods, 2)
        period              = try(alarm.period, 300)
        statistic           = try(alarm.statistic, "Average")
        alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en ECS ${alarm.dimension_value}")
        dimensions = {
          "${try(alarm.dimension_name, "ClusterName")}" = alarm.dimension_value
        }
        actions                   = try(alarm.actions, [])
        alarm_actions             = try(alarm.alarm_actions, try(alarm.actions, []))
        insufficient_data_actions = try(alarm.insufficient_data_actions, [])
        ok_actions                = try(alarm.ok_actions, [])
        datapoints_to_alarm       = try(alarm.datapoints_to_alarm, 2)
        treat_missing_data        = try(alarm.treat_missing_data, "missing")
      }
    ]),

    # Alarmas para todos los servicios etiquetados
    flatten([
      for service in local.ecs_services_filtered : [
        for template in try(var.ecs.service_alarm_templates, []) : {
          alarm_name          = "ecs-${template.metric_name}-${try(template.severity, "warning")}-${service.service_name}"
          metric_name         = template.metric_name
          namespace           = "AWS/ECS"
          threshold           = template.threshold
          comparison_operator = try(template.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(template.evaluation_periods, 2)
          period              = try(template.period, 300)
          statistic           = try(template.statistic, "Average")
          alarm_description   = try(template.description, "Alarma ${try(template.severity, "warning")} para ${template.metric_name} en servicio ${service.service_name}")
          dimensions = {
            "ServiceName" = service.service_name
            "ClusterName" = service.cluster_name
          }
          actions                   = try(template.actions, [])
          alarm_actions             = try(template.alarm_actions, try(template.actions, []))
          insufficient_data_actions = try(template.insufficient_data_actions, [])
          ok_actions                = try(template.ok_actions, [])
          datapoints_to_alarm       = try(template.datapoints_to_alarm, 2)
          treat_missing_data        = try(template.treat_missing_data, "missing")
        }
      ]
    ])
  ) : []

  ###########################################################
  # Alarmas - CloudWatch ECS Container Insights
  ###########################################################
  ecs_insights_alarms = var.ecs_insights != null && try(var.ecs_insights.create_alarms, false) && (length(local.ecs_clusters_filtered) > 0 || length(local.ecs_services_filtered) > 0) ? concat(
    # Configuraciones de alarmas estándar definidas manualmente
    flatten([
      for alarm in try(var.ecs_insights.alarm_config, []) : {
        alarm_name          = "ecs-insights-${alarm.metric_name}-${try(alarm.severity, "warning")}-${alarm.dimension_value}"
        metric_name         = alarm.metric_name
        namespace           = "ECS/ContainerInsights"
        threshold           = alarm.threshold
        comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
        evaluation_periods  = try(alarm.evaluation_periods, 2)
        period              = try(alarm.period, 300)
        statistic           = try(alarm.statistic, "Average")
        alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en Container Insights ${alarm.dimension_value}")
        dimensions = (
          try(alarm.dimension_name, "ClusterName") == "ServiceName" ?
          {
            "ServiceName" = alarm.dimension_value
            "ClusterName" = try(alarm.cluster_name, local.default_cluster_name)
          } :
          {
            "${try(alarm.dimension_name, "ClusterName")}" = alarm.dimension_value
          }
        )
        actions                   = try(alarm.actions, [])
        alarm_actions             = try(alarm.alarm_actions, try(alarm.actions, []))
        insufficient_data_actions = try(alarm.insufficient_data_actions, [])
        ok_actions                = try(alarm.ok_actions, [])
        datapoints_to_alarm       = try(alarm.datapoints_to_alarm, 2)
        treat_missing_data        = try(alarm.treat_missing_data, "missing")
      }
    ]),

    # Alarmas auto-generadas para todos los servicios etiquetados basados en plantillas
    flatten([
      for service in local.ecs_services_filtered : [
        for template in try(var.ecs_insights.service_alarm_templates, []) : {
          alarm_name          = "ecs-insights-${template.metric_name}-${try(template.severity, "warning")}-${service.service_name}"
          metric_name         = template.metric_name
          namespace           = "ECS/ContainerInsights"
          threshold           = template.threshold
          comparison_operator = try(template.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(template.evaluation_periods, 2)
          period              = try(template.period, 300)
          statistic           = try(template.statistic, "Average")
          alarm_description   = try(template.description, "Alarma ${try(template.severity, "warning")} para ${template.metric_name} en servicio ${service.service_name}")
          dimensions = {
            "ServiceName" = service.service_name
            "ClusterName" = service.cluster_name
          }
          actions                   = try(template.actions, [])
          alarm_actions             = try(template.alarm_actions, try(template.actions, []))
          insufficient_data_actions = try(template.insufficient_data_actions, [])
          ok_actions                = try(template.ok_actions, [])
          datapoints_to_alarm       = try(template.datapoints_to_alarm, 2)
          treat_missing_data        = try(template.treat_missing_data, "missing")
        }
      ]
    ])
  ) : []

  ###########################################################
  # Alarmas - CloudWatch WAF
  ###########################################################
  waf_alarms = var.waf != null && try(var.waf.create_alarms, false) && length(local.waf_webacls_filtered) > 0 ? concat(
    flatten([
      for webacl in local.waf_webacls_filtered : [
        for alarm in try(var.waf.alarm_config, []) : {
          alarm_name          = "waf-${alarm.metric_name}-${try(alarm.severity, "warning")}-${webacl.name}"
          metric_name         = alarm.metric_name
          threshold           = alarm.threshold
          webacl_name         = webacl.name
          webacl_id           = webacl.id
          scope               = webacl.scope
          comparison_operator = try(alarm.comparison, "GreaterThanOrEqualToThreshold")
          evaluation_periods  = try(alarm.evaluation_periods, 2)
          period              = try(alarm.period, 300)
          statistic           = try(alarm.statistic, "Average")
          alarm_description   = try(alarm.description, "Alarma ${try(alarm.severity, "warning")} para ${alarm.metric_name} en WAF WebACL ${webacl.name}")
          dimensions = {
            WebACL = webacl.name
            Region = webacl.scope == "REGIONAL" ? data.aws_region.current.name : "Global"
            Rule   = "ALL"
          }
          actions                   = try(alarm.actions, [])
          alarm_actions             = try(alarm.alarm_actions, try(alarm.actions, []))
          insufficient_data_actions = try(alarm.insufficient_data_actions, [])
          ok_actions                = try(alarm.ok_actions, [])
          datapoints_to_alarm       = try(alarm.datapoints_to_alarm, 2)
          treat_missing_data        = try(alarm.treat_missing_data, "missing")
        }
      ]
    ])
  ) : []
}
