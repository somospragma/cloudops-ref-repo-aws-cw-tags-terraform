locals {
  common_widget_properties = {
    "view"    = "timeSeries",
    "stacked" = false,
    "region"  = "us-east-1",
    "period"  = 300
  }

  ec2_metrics = try(var.ec2 != null ? var.ec2.metrics : [], [])
  rds_metrics = try(var.rds != null ? var.rds.metrics : [], [])
  lambda_metrics = try(var.lambda != null ? var.lambda.metrics : [], [])
  alb_metrics = try(var.alb != null ? var.alb.metrics : [], [])
  nlb_metrics = try(var.nlb != null ? var.nlb.metrics : [], [])
  s3_metrics = try(var.s3 != null ? var.s3.metrics : [], [])
  apigateway_metrics = try(var.apigateway != null ? var.apigateway.metrics : [], [])
  dynamodb_metrics = try(var.dynamodb != null ? var.dynamodb.metrics : [], [])

###########################################################
# Dasboard Header - General CloudWatch
###########################################################
  dashboard_header = [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "# **Dashboard Monitoreo Infraestructura**" }
    }
  ]

###########################################################
# Filtros RDS 
###########################################################
  rds_instances_filtered = var.rds != null ? [
    for id, instance in data.aws_db_instance.rds_filtered :
    id if lookup(instance.tags, try(var.rds.tag_key, "EnableObservability"), "false") == try(var.rds.tag_value, "true")
  ] : []

###########################################################
# Filtros Lambdas
###########################################################
  lambda_functions_filtered = var.lambda != null ? [
    for function in try(data.aws_resourcegroupstaggingapi_resources.lambda_filtered[0].resource_tag_mapping_list, []) :
    element(split(":", function.resource_arn), length(split(":", function.resource_arn)) - 1)
  ] : []

###########################################################
# Filtros ALB
###########################################################
  alb_instances_filtered = var.alb != null ? [
    for alb in data.aws_lb.tagged : alb.name
  ] : []
  
###########################################################
# Filtros NLB
###########################################################
  nlb_filtered = var.nlb != null ? [
    for nlb in data.aws_lb.tagged_nlb : nlb.name
  ] : []

###########################################################
# Filtros S3
###########################################################
  s3_buckets_filtered = var.s3 != null ? [
    for bucket in try(data.aws_resourcegroupstaggingapi_resources.s3_filtered[0].resource_tag_mapping_list, []) :
    replace(bucket.resource_arn, "arn:aws:s3:::", "")
  ] : []

###########################################################
# Filtros Api Gateway
###########################################################
  apigateway_filtered = var.apigateway != null ? [
    for api in try(data.aws_resourcegroupstaggingapi_resources.api_filtered[0].resource_tag_mapping_list, []) :
    element(split("/", api.resource_arn), length(split("/", api.resource_arn)) - 1)
  ] : []

###########################################################
# Filtros Dynamodb
###########################################################
  dynamodb_filtered = var.dynamodb != null ? [
    for table in try(data.aws_resourcegroupstaggingapi_resources.dynamodb_filtered[0].resource_tag_mapping_list, []) :
    element(split("/", table.resource_arn), length(split("/", table.resource_arn)) - 1)
  ] : []
}