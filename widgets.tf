locals {
###########################################################
# Sesion Computo
###########################################################
###########################################################
# Dasboard Header - Widget CloudWatch EC2
###########################################################
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

###########################################################
# Sesion Serverless
###########################################################
###########################################################
# Dasboard Header - Widget CloudWatch Lambdas
###########################################################
  serverless_section_header = ((var.lambda != null && try(var.lambda.create_dashboard, false) && length(local.lambda_functions_filtered) > 0) || 
                             (var.apigateway != null && try(var.apigateway.create_dashboard, false) && length(local.apigateway_filtered) > 0)) ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "## **Sección de Serverless**" }
    }
  ] : []

  lambda_section_header = var.lambda != null && try(var.lambda.create_dashboard, false) && length(local.lambda_functions_filtered) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "### [**AWS Lambda**](https://console.aws.amazon.com/lambda/home)" }
    }
  ] : []

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

###########################################################
# Dasboard Header - Widget CloudWatch Apigateway
###########################################################
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

###########################################################
# Sesion Database
###########################################################
###########################################################
# Dasboard Header - Widget CloudWatch RDS
###########################################################
  database_section_header = ((var.rds != null && try(var.rds.create_dashboard, false) && length(local.rds_instances_filtered) > 0) || 
                           (var.dynamodb != null && try(var.dynamodb.create_dashboard, false) && length(local.dynamodb_filtered) > 0)) ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "## **Sección de Bases de Datos**" }
    }
  ] : []

  rds_section_header = var.rds != null && try(var.rds.create_dashboard, false) && length(local.rds_instances_filtered) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "### [**Amazon RDS**](https://console.aws.amazon.com/rds/home)" }
    }
  ] : []

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

###########################################################
# Dasboard Header - Widget CloudWatch Dynamodb
###########################################################
  dynamodb_section_header = var.dynamodb != null && try(var.dynamodb.create_dashboard, false) && length(local.dynamodb_filtered) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "### [**DynamoDB**](https://console.aws.amazon.com/dynamodb/home)" }
    }
  ] : []

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

###########################################################
# Sesion Storage
###########################################################
###########################################################
# Dasboard Header - Widget CloudWatch S3
###########################################################
  storage_section_header = var.s3 != null && try(var.s3.create_dashboard, false) && length(local.s3_buckets_filtered) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "## **Sección de Almacenamiento**" }
    }
  ] : []

  s3_section_header = var.s3 != null && try(var.s3.create_dashboard, false) && length(local.s3_buckets_filtered) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "### [**Amazon S3**](https://console.aws.amazon.com/s3/home)" }
    }
  ] : []

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

###########################################################
# Sesion Networking
###########################################################
###########################################################
# Dasboard Header - Widget CloudWatch ALB
###########################################################
  networking_section_header = ((var.alb != null && try(var.alb.create_dashboard, false) && length(local.alb_instances_filtered) > 0) || 
                             (var.nlb != null && try(var.nlb.create_dashboard, false) && length(local.nlb_filtered) > 0)) ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "## **Sección de Redes**" }
    }
  ] : []

  alb_section_header = var.alb != null && try(var.alb.create_dashboard, false) && length(local.alb_instances_filtered) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "### [**Application Load Balancer**](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:)" }
    }
  ] : []

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

###########################################################
# Dasboard Header - Widget CloudWatch NLB
###########################################################
  nlb_section_header = var.nlb != null && try(var.nlb.create_dashboard, false) && length(local.nlb_filtered) > 0 ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "### [**Network Load Balancer**](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:)" }
    }
  ] : []

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
  
###########################################################
# Widgets Consoliddos
###########################################################
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
}