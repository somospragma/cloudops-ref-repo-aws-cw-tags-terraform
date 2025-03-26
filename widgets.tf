locals {
  ###########################################################
  # Sesion Computo
  ###########################################################
  ###########################################################
  # Dasboard Header - Widget CloudWatch EC2
  ###########################################################
  compute_section_header = var.ec2 != null && try(var.ec2.create_dashboard, false) && try(length(try(data.aws_instances.ec2_tagged[0].ids, [])), 0) > 0 ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "## **Sección de Cómputo**" }
    }
  ] : []

  ec2_section_header = var.ec2 != null && try(var.ec2.create_dashboard, false) && try(length(try(data.aws_instances.ec2_tagged[0].ids, [])), 0) > 0 && length(try(var.ec2.dashboard_config, [])) > 0 ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "### [**Amazon EC2**](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#Home:)" }
    }
  ] : []

  ec2_metric_widgets = var.ec2 != null && try(var.ec2.create_dashboard, false) && try(length(try(data.aws_instances.ec2_tagged[0].ids, [])), 0) > 0 && length(try(var.ec2.dashboard_config, [])) > 0 ? [
    for config in var.ec2.dashboard_config : {
      "type"   = "metric",
      "width"  = try(config.width, 12),
      "height" = try(config.height, 6),
      "properties" = merge(
        local.common_widget_properties,
        {
          "title"  = try(config.title, "${config.metric_name} por Instancia EC2"),
          "period" = try(config.period, 300),
          "metrics" = [
            for instance_id in try(data.aws_instances.ec2_tagged[0].ids, []) : ["AWS/EC2", config.metric_name, "InstanceId", instance_id]
          ],
          "statistic" = try(config.statistic, "Average")
        }
      )
    }
  ] : []

  ###########################################################
  # Sesion Serverless
  ###########################################################
  ###########################################################
  # Dasboard Header - Widget CloudWatch Lambdas
  ###########################################################
  serverless_section_header = ((var.lambda != null && try(var.lambda.create_dashboard, false) && length(local.lambda_functions_filtered) > 0 && length(try(var.lambda.dashboard_config, [])) > 0) ||
    (var.apigateway != null && try(var.apigateway.create_dashboard, false) && length(local.apigateway_filtered) > 0)) ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "## **Sección de Serverless**" }
    }
  ] : []

  lambda_section_header = var.lambda != null && try(var.lambda.create_dashboard, false) && length(local.lambda_functions_filtered) > 0 && length(try(var.lambda.dashboard_config, [])) > 0 ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "### [**AWS Lambda**](https://console.aws.amazon.com/lambda/home)" }
    }
  ] : []

  lambda_metric_widgets = var.lambda != null && try(var.lambda.create_dashboard, false) && length(local.lambda_functions_filtered) > 0 && length(try(var.lambda.dashboard_config, [])) > 0 ? [
    for config in var.lambda.dashboard_config : {
      "type"   = "metric",
      "width"  = try(config.width, 12),
      "height" = try(config.height, 6),
      "properties" = merge(
        local.common_widget_properties,
        {
          "title"  = try(config.title, "${config.metric_name} Lambda"),
          "period" = try(config.period, 300),
          "metrics" = [
            for function_name in local.lambda_functions_filtered : ["AWS/Lambda", config.metric_name, "FunctionName", function_name]
          ],
          "statistic" = try(config.statistic, "Average")
        }
      )
    }
  ] : []

  ###########################################################
  # Dasboard Header - Widget CloudWatch Apigateway
  ###########################################################
  ###########################################################
  # Dasboard Header - Widget CloudWatch Apigateway
  ###########################################################
  apigateway_section_header = var.apigateway != null && try(var.apigateway.create_dashboard, false) && length(local.apigateway_filtered) > 0 && length(try(var.apigateway.dashboard_config, [])) > 0 ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "### [**API Gateway**](https://console.aws.amazon.com/apigateway/home)" }
    }
  ] : []

  # API Gateway metrics
  apigateway_metric_widgets = var.apigateway != null && try(var.apigateway.create_dashboard, false) && length(local.apigateway_filtered) > 0 && length(try(var.apigateway.dashboard_config, [])) > 0 ? [
    for config in var.apigateway.dashboard_config : {
      "type"   = "metric",
      "width"  = try(config.width, 12),
      "height" = try(config.height, 6),
      "properties" = merge(
        local.common_widget_properties,
        {
          "title"  = try(config.title, "${config.metric_name} API Gateway"),
          "period" = try(config.period, 300),
          "metrics" = [
            for api_id in local.apigateway_filtered : ["AWS/ApiGateway", config.metric_name, "ApiId", api_id]
          ],
          "statistic" = try(config.statistic, "Average")
        }
      )
    }
  ] : []

  ###########################################################
  # Sesion Database
  ###########################################################
  ###########################################################
  # Dasboard Header - Widget CloudWatch RDS
  ###########################################################
  database_section_header = ((var.rds != null && try(var.rds.create_dashboard, false) && length(local.rds_instances_filtered) > 0 && length(try(var.rds.dashboard_config, [])) > 0) ||
    (var.dynamodb != null && try(var.dynamodb.create_dashboard, false) && length(local.dynamodb_filtered) > 0)) ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "## **Sección de Bases de Datos**" }
    }
  ] : []

  rds_section_header = var.rds != null && try(var.rds.create_dashboard, false) && length(local.rds_instances_filtered) > 0 && length(try(var.rds.dashboard_config, [])) > 0 ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "### [**Amazon RDS**](https://console.aws.amazon.com/rds/home)" }
    }
  ] : []

  rds_metric_widgets = var.rds != null && try(var.rds.create_dashboard, false) && length(local.rds_instances_filtered) > 0 && length(try(var.rds.dashboard_config, [])) > 0 ? [
    for config in var.rds.dashboard_config : {
      "type"   = "metric",
      "width"  = try(config.width, 12),
      "height" = try(config.height, 6),
      "properties" = merge(
        local.common_widget_properties,
        {
          "title"  = try(config.title, "${config.metric_name} RDS"),
          "period" = try(config.period, 300),
          "metrics" = [
            for id in local.rds_instances_filtered : ["AWS/RDS", config.metric_name, "DBInstanceIdentifier", id]
          ],
          "statistic" = try(config.statistic, "Average")
        }
      )
    }
  ] : []

  ###########################################################
  # Dasboard Header - Widget CloudWatch Dynamodb
  ###########################################################
  ###########################################################
  # Dasboard Header - Widget CloudWatch Dynamodb
  ###########################################################
  dynamodb_section_header = var.dynamodb != null && try(var.dynamodb.create_dashboard, false) && length(local.dynamodb_filtered) > 0 && length(try(var.dynamodb.dashboard_config, [])) > 0 ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "### [**DynamoDB**](https://console.aws.amazon.com/dynamodb/home)" }
    }
  ] : []

  dynamodb_metric_widgets = var.dynamodb != null && try(var.dynamodb.create_dashboard, false) && length(local.dynamodb_filtered) > 0 && length(try(var.dynamodb.dashboard_config, [])) > 0 ? [
    for config in var.dynamodb.dashboard_config : {
      "type"   = "metric",
      "width"  = try(config.width, 12),
      "height" = try(config.height, 6),
      "properties" = merge(
        local.common_widget_properties,
        {
          "title"  = try(config.title, "${config.metric_name} DynamoDB"),
          "period" = try(config.period, 300),
          "metrics" = [
            for table in local.dynamodb_filtered : ["AWS/DynamoDB", config.metric_name, "TableName", table]
          ],
          "statistic" = try(config.statistic, "Average")
        }
      )
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
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "## **Sección de Almacenamiento**" }
    }
  ] : []

  s3_section_header = var.s3 != null && try(var.s3.create_dashboard, false) && length(local.s3_buckets_filtered) > 0 && length(try(var.s3.dashboard_config, [])) > 0 ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "### [**Amazon S3**](https://console.aws.amazon.com/s3/home)" }
    }
  ] : []

  s3_metric_widgets = var.s3 != null && try(var.s3.create_dashboard, false) && length(local.s3_buckets_filtered) > 0 && length(try(var.s3.dashboard_config, [])) > 0 ? [
    for config in var.s3.dashboard_config : {
      "type"   = "metric",
      "width"  = try(config.width, 12),
      "height" = try(config.height, 6),
      "properties" = merge(
        local.common_widget_properties,
        {
          "title"  = try(config.title, "${config.metric_name} S3"),
          "period" = try(config.period, 300),
          "metrics" = [
            for bucket in local.s3_buckets_filtered : ["AWS/S3", config.metric_name, "BucketName", bucket, "StorageType",
            config.metric_name == "NumberOfObjects" ? "AllStorageTypes" : try(config.storage_type, "Standard")]
          ],
          "statistic" = try(config.statistic, "Average")
        }
      )
    }
  ] : []

  ###########################################################
  # Sesion Networking
  ###########################################################
  ###########################################################
  # Dasboard Header - Widget CloudWatch ALB
  ###########################################################
  ###########################################################
  # Dasboard Header - Widget CloudWatch ALB
  ###########################################################
  networking_section_header = ((var.alb != null && try(var.alb.create_dashboard, false) && length(local.alb_instances_filtered) > 0 && length(try(var.alb.dashboard_config, [])) > 0) ||
    (var.nlb != null && try(var.nlb.create_dashboard, false) && length(local.nlb_filtered) > 0)) ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "## **Sección de Redes**" }
    }
  ] : []

  alb_section_header = var.alb != null && try(var.alb.create_dashboard, false) && length(local.alb_instances_filtered) > 0 && length(try(var.alb.dashboard_config, [])) > 0 ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "### [**Application Load Balancer**](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:)" }
    }
  ] : []

  alb_metric_widgets = var.alb != null && try(var.alb.create_dashboard, false) && length(local.alb_instances_filtered) > 0 && length(try(var.alb.dashboard_config, [])) > 0 ? [
    for config in var.alb.dashboard_config : {
      "type"   = "metric",
      "width"  = try(config.width, 12),
      "height" = try(config.height, 6),
      "properties" = merge(
        local.common_widget_properties,
        {
          "title"  = try(config.title, "${config.metric_name} ALB"),
          "period" = try(config.period, 300),
          "metrics" = [
            for alb in local.alb_instances_filtered : ["AWS/ApplicationELB", config.metric_name, "LoadBalancer", alb]
          ],
          "statistic" = try(config.statistic, "Average")
        }
      )
    }
  ] : []

  ###########################################################
  # Dasboard Header - Widget CloudWatch NLB
  ###########################################################
  ###########################################################
  # Dasboard Header - Widget CloudWatch NLB
  ###########################################################
  nlb_section_header = var.nlb != null && try(var.nlb.create_dashboard, false) && length(local.nlb_filtered) > 0 && length(try(var.nlb.dashboard_config, [])) > 0 ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "### [**Network Load Balancer**](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:)" }
    }
  ] : []

  nlb_metric_widgets = var.nlb != null && try(var.nlb.create_dashboard, false) && length(local.nlb_filtered) > 0 && length(try(var.nlb.dashboard_config, [])) > 0 ? [
    for config in var.nlb.dashboard_config : {
      "type"   = "metric",
      "width"  = try(config.width, 12),
      "height" = try(config.height, 6),
      "properties" = merge(
        local.common_widget_properties,
        {
          "title"  = try(config.title, "${config.metric_name} NLB"),
          "period" = try(config.period, 300),
          "metrics" = [
            for nlb_name in local.nlb_filtered : ["AWS/NetworkELB", config.metric_name, "LoadBalancer", nlb_name]
          ],
          "statistic" = try(config.statistic, "Average")
        }
      )
    }
  ] : []

  ###########################################################
  # Sesion Containers
  ###########################################################
  ###########################################################
  # Dasboard Header - Widget CloudWatch ECS
  ###########################################################
  container_section_header = ((var.ecs != null && try(var.ecs.create_dashboard, false) && (length(local.ecs_clusters_filtered) > 0 || length(local.ecs_services_filtered) > 0) && length(try(var.ecs.dashboard_config, [])) > 0) ||
    (var.ecs_insights != null && try(var.ecs_insights.create_dashboard, false) && (length(local.ecs_clusters_filtered) > 0 || length(local.ecs_services_filtered) > 0) && length(try(var.ecs_insights.dashboard_config, [])) > 0)) ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "## **Sección de Contenedores**" }
    }
  ] : []

  ecs_section_header = var.ecs != null && try(var.ecs.create_dashboard, false) && (length(local.ecs_clusters_filtered) > 0 || length(local.ecs_services_filtered) > 0) && length(try(var.ecs.dashboard_config, [])) > 0 ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "### [**Amazon ECS**](https://console.aws.amazon.com/ecs/home)" }
    }
  ] : []

  ecs_metric_widgets = var.ecs != null && try(var.ecs.create_dashboard, false) && (length(local.ecs_clusters_filtered) > 0 || length(local.ecs_services_filtered) > 0) && length(try(var.ecs.dashboard_config, [])) > 0 ? [
    for config in var.ecs.dashboard_config : {
      "type"   = "metric",
      "width"  = try(config.width, 12),
      "height" = try(config.height, 6),
      "properties" = merge(
        local.common_widget_properties,
        {
          "title"  = try(config.title, "${config.metric_name} ECS"),
          "period" = try(config.period, 300),
          "metrics" = try(config.dimension_name, "ClusterName") == "ClusterName" ? [
            for cluster in local.ecs_clusters_filtered : [
              "AWS/ECS", config.metric_name, "ClusterName", cluster
            ]
            ] : try(config.dimension_name, "ClusterName") == "ServiceName" ? [
            for service in local.ecs_services_filtered : [
              "AWS/ECS", config.metric_name, "ClusterName", service.cluster_name, "ServiceName", service.service_name
            ]
          ] : [],
          "statistic" = try(config.statistic, "Average")
        }
      )
    }
  ] : []

  ###########################################################
  # Dasboard Header - Widget CloudWatch ECS Container Insights
  ###########################################################
  ecs_insights_section_header = var.ecs_insights != null && try(var.ecs_insights.create_dashboard, false) && (length(local.ecs_clusters_filtered) > 0 || length(local.ecs_services_filtered) > 0) && length(try(var.ecs_insights.dashboard_config, [])) > 0 ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "### [**ECS Container Insights**](https://console.aws.amazon.com/cloudwatch/home?#container-insights:)" }
    }
  ] : []

  ecs_insights_metric_widgets = var.ecs_insights != null && try(var.ecs_insights.create_dashboard, false) && (length(local.ecs_clusters_filtered) > 0 || length(local.ecs_services_filtered) > 0) && length(try(var.ecs_insights.dashboard_config, [])) > 0 ? [
    for config in var.ecs_insights.dashboard_config : {
      "type"   = "metric",
      "width"  = try(config.width, 12),
      "height" = try(config.height, 6),
      "properties" = merge(
        local.common_widget_properties,
        {
          "title"  = try(config.title, "${config.metric_name} Container Insights"),
          "period" = try(config.period, 300),
          "metrics" = try(config.dimension_name, "ClusterName") == "ClusterName" ? [
            for cluster in local.ecs_clusters_filtered : [
              "ECS/ContainerInsights", config.metric_name, "ClusterName", cluster
            ]
            ] : try(config.dimension_name, "ClusterName") == "ServiceName" ? [
            for service in local.ecs_services_filtered : [
              "ECS/ContainerInsights", config.metric_name, "ClusterName", service.cluster_name, "ServiceName", service.service_name
            ]
          ] : [],
          "statistic" = try(config.statistic, "Average")
        }
      )
    }
  ] : []

  ###########################################################
  # Sección Seguridad
  ###########################################################
  security_section_header = var.waf != null && try(var.waf.create_dashboard, false) && length(local.waf_webacls_filtered) > 0 ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "## **Sección de Seguridad**" }
    }
  ] : []

  ###########################################################
  # Dasboard Header - Widget CloudWatch WAF
  ###########################################################
  waf_section_header = var.waf != null && try(var.waf.create_dashboard, false) && length(local.waf_webacls_filtered) > 0 && length(try(var.waf.dashboard_config, [])) > 0 ? [
    {
      "type"       = "text",
      "width"      = 24,
      "height"     = 1,
      "properties" = { "markdown" = "### [**AWS WAF**](https://console.aws.amazon.com/wafv2/homev2)" }
    }
  ] : []

  waf_metric_widgets = var.waf != null && try(var.waf.create_dashboard, false) && length(local.waf_webacls_filtered) > 0 && length(try(var.waf.dashboard_config, [])) > 0 ? [
    for config in var.waf.dashboard_config : {
      "type"   = "metric",
      "width"  = try(config.width, 12),
      "height" = try(config.height, 6),
      "properties" = merge(
        local.common_widget_properties,
        {
          "title"  = try(config.title, "${config.metric_name} WAF"),
          "period" = try(config.period, 300),
          "metrics" = [
            for webacl in local.waf_webacls_filtered : [
              webacl.scope == "REGIONAL" ? "AWS/WAFV2" : "AWS/WAF",
              config.metric_name,
              "WebACL",
              webacl.name,
              "Region",
              webacl.scope == "REGIONAL" ? webacl.region : "Global",
              "Rule",
              "ALL"
            ]
          ],
          "statistic" = try(config.statistic, "Sum")
        }
      )
    }
  ] : []
  ###########################################################
  # Widgets Consolidados
  ###########################################################
  all_widgets = concat(
    local.dashboard_header,

    # Compute section
    local.compute_section_header,
    local.ec2_section_header,
    local.ec2_metric_widgets,

    # Container section
    local.container_section_header,
    local.ecs_insights_section_header,
    local.ecs_insights_metric_widgets,
    local.ecs_section_header,
    local.ecs_metric_widgets,


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
    local.nlb_metric_widgets,

    # Security section
    local.security_section_header,
    local.waf_section_header,
    local.waf_metric_widgets
  )
}
