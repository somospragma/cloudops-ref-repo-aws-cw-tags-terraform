locals {
  common_widget_properties = {
    "view"    = "timeSeries",
    "stacked" = false,
    "region"  = "us-east-1",
    "period"  = 300
  }

  # Métricas de recursos
  ec2_metrics = try(var.ec2 != null ? var.ec2.metrics : [], [])
  rds_metrics = try(var.rds != null ? var.rds.metrics : [], [])
  lambda_metrics = try(var.lambda != null ? var.lambda.metrics : [], [])
  alb_metrics = try(var.alb != null ? var.alb.metrics : [], [])
  nlb_metrics = try(var.nlb != null ? var.nlb.metrics : [], [])
  s3_metrics = try(var.s3 != null ? var.s3.metrics : [], [])
  apigateway_metrics = try(var.apigateway != null ? var.apigateway.metrics : [], [])
  dynamodb_metrics = try(var.dynamodb != null ? var.dynamodb.metrics : [], [])

  # Dashboard principal header
  dashboard_header = [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "# **Dashboard Unificado de Monitoreo**" }
    }
  ]

  # COMPUTE SECTION
  # EC2 section header - solo si hay instancias EC2
  compute_section_header = var.ec2 != null && try(var.ec2.create_dashboard, false) && try(length(try(data.aws_instances.ec2_tagged[0].ids, [])), 0) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "## **Sección de Cómputo**" }
    }
  ] : []

  ec2_section_header = var.ec2 != null && try(var.ec2.create_dashboard, false) && try(length(try(data.aws_instances.ec2_tagged[0].ids, [])), 0) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "### [**Amazon EC2**](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#Home:)" }
    }
  ] : []

  # EC2 metrics
  ec2_metric_widgets = var.ec2 != null && try(var.ec2.create_dashboard, false) && try(length(try(data.aws_instances.ec2_tagged[0].ids, [])), 0) > 0 ? [
    for metric in try(local.ec2_metrics, []) : {
      "type"   = "metric",
      "width"  = 12,
      "height" = 6,
      "properties" = merge(local.common_widget_properties, {
        "title"   = "${metric} por Instancia EC2",
        "metrics" = [
          for instance_id in try(data.aws_instances.ec2_tagged[0].ids, []) : ["AWS/EC2", metric, "InstanceId", instance_id]
        ]
      })
    }
  ] : []

  # SERVERLESS SECTION
  # Serverless section header - solo si hay funciones Lambda o API Gateway
  serverless_section_header = ((var.lambda != null && try(var.lambda.create_dashboard, false) && length(local.lambda_functions_filtered) > 0) || 
                             (var.apigateway != null && try(var.apigateway.create_dashboard, false) && length(local.apigateway_filtered) > 0)) ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "## **Sección de Serverless**" }
    }
  ] : []

  # Lambda section header - solo si hay funciones Lambda
  lambda_section_header = var.lambda != null && try(var.lambda.create_dashboard, false) && length(local.lambda_functions_filtered) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "### [**AWS Lambda**](https://console.aws.amazon.com/lambda/home)" }
    }
  ] : []

  # Lambda metrics
  lambda_metric_widgets = var.lambda != null && try(var.lambda.create_dashboard, false) && length(local.lambda_functions_filtered) > 0 ? [
    for metric in local.lambda_metrics : {
      "type"   = "metric",
      "width"  = 12,
      "height" = 6,
      "properties" = merge(local.common_widget_properties, {
        "title"   = "${metric} Lambda",
        "metrics" = [
          for function_name in local.lambda_functions_filtered : ["AWS/Lambda", metric, "FunctionName", function_name]
        ]
      })
    } 
  ] : []

  # API Gateway section header - solo si hay APIs
  apigateway_section_header = var.apigateway != null && try(var.apigateway.create_dashboard, false) && length(local.apigateway_filtered) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "### [**API Gateway**](https://console.aws.amazon.com/apigateway/home)" }
    }
  ] : []

  # API Gateway metrics
  apigateway_metric_widgets = var.apigateway != null && try(var.apigateway.create_dashboard, false) && length(local.apigateway_filtered) > 0 ? [
    for metric in local.apigateway_metrics : {
      "type"   = "metric",
      "width"  = 12,
      "height" = 6,
      "properties" = merge(local.common_widget_properties, {
        "title"   = "${metric} API Gateway",
        "metrics" = [
          for api_id in local.apigateway_filtered : ["AWS/ApiGateway", metric, "ApiId", api_id]
        ]
      })
    } 
  ] : []

  # DATABASE SECTION
  # Database section header - solo si hay instancias RDS o tablas DynamoDB
  database_section_header = ((var.rds != null && try(var.rds.create_dashboard, false) && length(local.rds_instances_filtered) > 0) || 
                           (var.dynamodb != null && try(var.dynamodb.create_dashboard, false) && length(local.dynamodb_filtered) > 0)) ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "## **Sección de Bases de Datos**" }
    }
  ] : []

  # RDS section header - solo si hay instancias RDS
  rds_section_header = var.rds != null && try(var.rds.create_dashboard, false) && length(local.rds_instances_filtered) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "### [**Amazon RDS**](https://console.aws.amazon.com/rds/home)" }
    }
  ] : []

  # RDS metrics
  rds_metric_widgets = var.rds != null && try(var.rds.create_dashboard, false) && length(local.rds_instances_filtered) > 0 ? [
    for metric in local.rds_metrics : {
      "type"   = "metric",
      "width"  = 12,
      "height" = 6,
      "properties" = merge(local.common_widget_properties, {
        "title"   = "${metric} RDS",
        "metrics" = [
          for id in local.rds_instances_filtered : ["AWS/RDS", metric, "DBInstanceIdentifier", id]
        ]
      })
    } 
  ] : []

  # DynamoDB section header - solo si hay tablas DynamoDB
  dynamodb_section_header = var.dynamodb != null && try(var.dynamodb.create_dashboard, false) && length(local.dynamodb_filtered) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "### [**DynamoDB**](https://console.aws.amazon.com/dynamodb/home)" }
    }
  ] : []

  # DynamoDB metrics
  dynamodb_metric_widgets = var.dynamodb != null && try(var.dynamodb.create_dashboard, false) && length(local.dynamodb_filtered) > 0 ? [
    for metric in local.dynamodb_metrics : {
      "type"   = "metric",
      "width"  = 12,
      "height" = 6,
      "properties" = merge(local.common_widget_properties, {
        "title"   = "${metric} DynamoDB",
        "metrics" = [
          for table in local.dynamodb_filtered : ["AWS/DynamoDB", metric, "TableName", table]
        ]
      })
    } 
  ] : []

  # STORAGE SECTION
  # Storage section header - solo si hay buckets S3
  storage_section_header = var.s3 != null && try(var.s3.create_dashboard, false) && length(local.s3_buckets_filtered) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "## **Sección de Almacenamiento**" }
    }
  ] : []

  # S3 section header - solo si hay buckets S3
  s3_section_header = var.s3 != null && try(var.s3.create_dashboard, false) && length(local.s3_buckets_filtered) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "### [**Amazon S3**](https://console.aws.amazon.com/s3/home)" }
    }
  ] : []

  # S3 metrics
  s3_metric_widgets = var.s3 != null && try(var.s3.create_dashboard, false) && length(local.s3_buckets_filtered) > 0 ? [
    for metric in local.s3_metrics : {
      "type"   = "metric",
      "width"  = 12,
      "height" = 6,
      "properties" = merge(local.common_widget_properties, {
        "title"   = "${metric} S3",
        "metrics" = [
          for bucket in local.s3_buckets_filtered : ["AWS/S3", metric, "BucketName", bucket, "StorageType", "Standard"]
        ]
      })
    } 
  ] : []

  # NETWORKING SECTION
  # Networking section header - solo si hay ALBs o NLBs
  networking_section_header = ((var.alb != null && try(var.alb.create_dashboard, false) && length(local.alb_instances_filtered) > 0) || 
                             (var.nlb != null && try(var.nlb.create_dashboard, false) && length(local.nlb_filtered) > 0)) ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "## **Sección de Redes**" }
    }
  ] : []

  # ALB section header - solo si hay ALBs
  alb_section_header = var.alb != null && try(var.alb.create_dashboard, false) && length(local.alb_instances_filtered) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "### [**Application Load Balancer**](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:)" }
    }
  ] : []

  # ALB metrics
  alb_metric_widgets = var.alb != null && try(var.alb.create_dashboard, false) && length(local.alb_instances_filtered) > 0 ? [
    for metric in local.alb_metrics : {
      "type"   = "metric",
      "width"  = 12,
      "height" = 6,
      "properties" = merge(local.common_widget_properties, {
        "title"   = "${metric} ALB",
        "metrics" = [
          for alb in local.alb_instances_filtered : ["AWS/ApplicationELB", metric, "LoadBalancer", alb]
        ]
      })
    }
  ] : []

  # NLB section header - solo si hay NLBs
  nlb_section_header = var.nlb != null && try(var.nlb.create_dashboard, false) && length(local.nlb_filtered) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "### [**Network Load Balancer**](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:)" }
    }
  ] : []

  # NLB metrics
  nlb_metric_widgets = var.nlb != null && try(var.nlb.create_dashboard, false) && length(local.nlb_filtered) > 0 ? [
    for metric in local.nlb_metrics : {
      "type"   = "metric",
      "width"  = 12,
      "height" = 6,
      "properties" = merge(local.common_widget_properties, {
        "title"   = "${metric} NLB",
        "region"  = "us-east-1",
        "metrics" = [
          for nlb_name in local.nlb_filtered : ["AWS/NetworkELB", metric, "LoadBalancer", nlb_name]
        ]
      })
    }
  ] : []

  # Widgets Unificados
  all_widgets = concat(
    local.dashboard_header,
    
    # Compute section
    local.compute_section_header,
    local.ec2_section_header,
    local.ec2_metric_widgets,
    
    # Serverless section
    local.serverless_section_header,
    local.lambda_section_header,
    local.lambda_metric_widgets,
    local.apigateway_section_header,
    local.apigateway_metric_widgets,
    
    # Database section
    local.database_section_header,
    local.rds_section_header,
    local.rds_metric_widgets,
    local.dynamodb_section_header,
    local.dynamodb_metric_widgets,
    
    # Storage section
    local.storage_section_header,
    local.s3_section_header,
    local.s3_metric_widgets,
    
    # Networking section
    local.networking_section_header,
    local.alb_section_header,
    local.alb_metric_widgets,
    local.nlb_section_header,
    local.nlb_metric_widgets
  )

  # Mantener las definiciones de las alarmas originales
  ec2_alarms = var.ec2 != null && try(var.ec2.create_alarms, false) && try(length(try(data.aws_instances.ec2_tagged[0].ids, [])), 0) > 0 ? flatten([
    for instance_id in try(data.aws_instances.ec2_tagged[0].ids, []) : [
      for metric in try(local.ec2_metrics, []) : {
        alarm_name  = "ec2-${metric}-${instance_id}",
        metric_name = metric,
        threshold   = var.ec2.alarm_thresholds[metric],
        instance_id = instance_id
      } if contains(keys(try(var.ec2.alarm_thresholds, {})), metric)
    ]
  ]) : []

  rds_alarms = var.rds != null && try(var.rds.create_alarms, false) && length(local.rds_instances_filtered) > 0 ? flatten([
    for id in local.rds_instances_filtered : [
      for metric in local.rds_metrics : {
        alarm_name  = "rds-${metric}-${id}",
        metric_name = metric,
        threshold   = var.rds.alarm_thresholds[metric],
        id          = id
      } if contains(keys(try(var.rds.alarm_thresholds, {})), metric)
    ]
  ]) : []

  lambda_alarms = var.lambda != null && try(var.lambda.create_alarms, false) && length(local.lambda_functions_filtered) > 0 ? flatten([
    for function_name in local.lambda_functions_filtered : [
      for metric in local.lambda_metrics : {
        alarm_name    = "lambda-${metric}-${function_name}",
        metric_name   = metric,
        threshold     = var.lambda.alarm_thresholds[metric],
        function_name = function_name
      } if contains(keys(try(var.lambda.alarm_thresholds, {})), metric)
    ]
  ]) : []

  alb_alarms = var.alb != null && try(var.alb.create_alarms, false) && length(local.alb_instances_filtered) > 0 ? flatten([
    for alb in local.alb_instances_filtered : [
      for metric in local.alb_metrics : {
        alarm_name  = "alb-${metric}-${alb}",
        metric_name = metric,
        threshold   = var.alb.alarm_thresholds[metric],
        alb_arn     = alb
      } if contains(keys(try(var.alb.alarm_thresholds, {})), metric)
    ]
  ]) : []

  nlb_alarms = var.nlb != null && try(var.nlb.create_alarms, false) && length(local.nlb_filtered) > 0 ? flatten([
    for nlb_name in local.nlb_filtered : [
      for metric in local.nlb_metrics : {
        alarm_name  = "nlb-${metric}-${nlb_name}",
        metric_name = metric,
        threshold   = var.nlb.alarm_thresholds[metric],
        nlb_name    = nlb_name
      } if contains(keys(try(var.nlb.alarm_thresholds, {})), metric)
    ]
  ]) : []

  s3_alarms = var.s3 != null && try(var.s3.create_alarms, false) && length(local.s3_buckets_filtered) > 0 ? flatten([
    for bucket in local.s3_buckets_filtered : [
      for metric in local.s3_metrics : {
        alarm_name  = "s3-${metric}-${bucket}",
        metric_name = metric,
        threshold   = var.s3.alarm_thresholds[metric],
        bucket_name = bucket
      } if contains(keys(try(var.s3.alarm_thresholds, {})), metric)
    ]
  ]) : []

  apigateway_alarms = var.apigateway != null && try(var.apigateway.create_alarms, false) && length(local.apigateway_filtered) > 0 ? flatten([
    for api_id in local.apigateway_filtered : [
      for metric in local.apigateway_metrics : {
        alarm_name  = "apigateway-${metric}-${api_id}",
        metric_name = metric,
        threshold   = var.apigateway.alarm_thresholds[metric],
        api_id      = api_id
      } if contains(keys(try(var.apigateway.alarm_thresholds, {})), metric)
    ]
  ]) : []

  dynamodb_alarms = var.dynamodb != null && try(var.dynamodb.create_alarms, false) && length(local.dynamodb_filtered) > 0 ? flatten([
    for table in local.dynamodb_filtered : [
      for metric in local.dynamodb_metrics : {
        alarm_name  = "dynamodb-${metric}-${table}",
        metric_name = metric,
        threshold   = var.dynamodb.alarm_thresholds[metric],
        table_name  = table
      } if contains(keys(try(var.dynamodb.alarm_thresholds, {})), metric)
    ]
  ]) : []
}

locals {
  # Referencias a recursos filtrados
  rds_instances_filtered = var.rds != null ? [
    for id, instance in data.aws_db_instance.rds_filtered :
    id if lookup(instance.tags, try(var.rds.tag_key, "EnableObservability"), "false") == try(var.rds.tag_value, "true")
  ] : []

  # Corregido para usar resourcegroupstaggingapi para Lambda
  lambda_functions_filtered = var.lambda != null ? [
    for function in try(data.aws_resourcegroupstaggingapi_resources.lambda_filtered[0].resource_tag_mapping_list, []) :
    element(split(":", function.resource_arn), length(split(":", function.resource_arn)) - 1)
  ] : []
  
  alb_instances_filtered = var.alb != null ? [
    for alb in data.aws_lb.tagged : alb.name
  ] : []
  
  nlb_filtered = var.nlb != null ? [
    for nlb in data.aws_lb.tagged_nlb : nlb.name
  ] : []

  # Uso seguro de data resources con count
  s3_buckets_filtered = var.s3 != null ? [
    for bucket in try(data.aws_resourcegroupstaggingapi_resources.s3_filtered[0].resource_tag_mapping_list, []) :
    replace(bucket.resource_arn, "arn:aws:s3:::", "")
  ] : []

  apigateway_filtered = var.apigateway != null ? [
    for api in try(data.aws_resourcegroupstaggingapi_resources.api_filtered[0].resource_tag_mapping_list, []) :
    element(split("/", api.resource_arn), length(split("/", api.resource_arn)) - 1)
  ] : []

  dynamodb_filtered = var.dynamodb != null ? [
    for table in try(data.aws_resourcegroupstaggingapi_resources.dynamodb_filtered[0].resource_tag_mapping_list, []) :
    element(split("/", table.resource_arn), length(split("/", table.resource_arn)) - 1)
  ] : []
}