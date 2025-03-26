locals {
  common_widget_properties = {
    "view"    = "timeSeries",
    "stacked" = false,
    "region"  = "us-east-1",
    "period"  = 300
  }

  ###########################################################
  # Dasboard Header - General CloudWatch
  ###########################################################
  dashboard_header = [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "# **Dashboard Monitoreo Infraestructura**" }
    }
  ]
  
  ###########################################################
  # Local Default Cluster Name
  ###########################################################

  default_cluster_name = length(local.ecs_clusters_filtered) > 0 ? local.ecs_clusters_filtered[0] : ""

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

  ###########################################################
  # Filtros ECS
  ###########################################################
  ecs_clusters_filtered = var.ecs != null || var.ecs_insights != null ? [
    for cluster in try(data.aws_resourcegroupstaggingapi_resources.ecs_clusters_filtered[0].resource_tag_mapping_list, []) :
    element(split("/", cluster.resource_arn), length(split("/", cluster.resource_arn)) - 1)
  ] : []

  ecs_services_filtered = var.ecs != null || var.ecs_insights != null ? [
    for service in try(data.aws_resourcegroupstaggingapi_resources.ecs_services_filtered[0].resource_tag_mapping_list, []) : {
      service_name = element(split("/", service.resource_arn), length(split("/", service.resource_arn)) - 1)
      cluster_name = element(split("/", service.resource_arn), length(split("/", service.resource_arn)) - 2)
    }
  ] : []

###########################################################
# Filtros WAF
###########################################################
waf_webacls_filtered = var.waf != null ? [
  for webacl in var.waf.web_acls : {
    name   = webacl.name
    id     = try(webacl.id, webacl.name)
    scope  = webacl.scope
    region = webacl.scope == "REGIONAL" ? try(webacl.region, data.aws_region.current.name) : "us-east-1"
    arn    = webacl.scope == "REGIONAL" ? (
      "arn:aws:wafv2:${try(webacl.region, data.aws_region.current.name)}:${data.aws_caller_identity.current.account_id}:regional/webacl/${webacl.name}/${try(webacl.id, webacl.name)}"
    ) : (
      "arn:aws:wafv2:us-east-1:${data.aws_caller_identity.current.account_id}:global/webacl/${webacl.name}/${try(webacl.id, webacl.name)}"
    )
  }
] : []
}
