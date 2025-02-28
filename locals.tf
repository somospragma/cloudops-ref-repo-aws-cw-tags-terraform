locals {
  common_widget_properties = {
    "view"    = "timeSeries",
    "stacked" = false,
    "region"  = "us-east-1",
    "period"  = 300
  }


  # Metricas de recursos
  ec2_metrics = try(var.ec2.metrics, [])
  rds_metrics = try(var.rds.metrics, [])
  lambda_metrics = try(var.lambda.metrics, [])
  alb_metrics = try(var.alb.metrics, [])
  nlb_metrics = try(var.nlb.metrics, [])
  s3_metrics = try(var.s3.metrics, [])
  apigateway_metrics = try(var.apigateway.metrics, [])
  dynamodb_metrics = try(var.dynamodb.metrics, [])






  # Encabezado del Dashboard
  # ec2
  ec2_header_widgets = try(var.ec2.create_dashboard, false) ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "# **Monitoreo Comportamiento Computo**" }
    },
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "## [**Amazon EC2**](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#Home:)" }
    }
  ] : []


  # Creación de metricas EC2
  ec2_metric_widgets = try(var.ec2.create_dashboard, false) && try(length(data.aws_instances.ec2_tagged.ids), 0) > 0 ? [
  for metric in try(local.ec2_metrics, []) :  {
      "type"   = "metric",
      "width"  = 12,
      "height" = 6,
      "properties" = merge(local.common_widget_properties, {
        "title"   = "${metric} por Instancia EC2",
        "metrics" = [
          for instance_id in data.aws_instances.ec2_tagged.ids : ["AWS/EC2", metric, "InstanceId", instance_id]
        ]
      })
    }
  ] : []

  # Concatenación de metricas y encabezado
  ec2_widgets = concat(local.ec2_header_widgets, local.ec2_metric_widgets)

  # EC2 Alarma
  ec2_alarms = try(var.ec2.create_alarms, false) && try(length(data.aws_instances.ec2_tagged.ids), 0) > 0 ? flatten([
  for instance_id in try(data.aws_instances.ec2_tagged.ids, []) : [
    for metric in try(local.ec2_metrics, []) : {
        alarm_name  = "ec2-${metric}-${instance_id}",
        metric_name = metric,
        threshold   = var.ec2.alarm_thresholds[metric],
        instance_id = instance_id
      }
    ]
  ]) : []

  # Encabezado del Dashboard
  # rds
  rds_header_widgets = try(var.rds.create_dashboard, false) ? [
  {
    "type"   = "text",
    "width"  = 24,
    "height" = 1,
    "properties" = { "markdown" = "# **Monitoreo Comportamiento Data**" }
  },
  {
    "type"   = "text",
    "width"  = 24,
    "height" = 1,
    "properties" = { "markdown" = "## [**Amazon Relational Database Service (Amazon RDS)**](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#Home:)" }
  }
  ] : []

  # Creación de metricas RDS
  rds_metric_widgets = try(var.rds.create_dashboard, false) && length(local.rds_instances_filtered) > 0 ? [
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

  # Concatenación de metricas y encabezado
  rds_widgets = concat(local.rds_header_widgets, local.rds_metric_widgets)

  # RDS Alarma
  rds_alarms = try(var.rds.create_alarms, false) && length(local.rds_instances_filtered) > 0 ? flatten([
    for id in local.rds_instances_filtered : [
      for metric in local.rds_metrics : {
        alarm_name  = "rds-${metric}-${id}",
        metric_name = metric,
        threshold   = var.rds.alarm_thresholds[metric],
        id          = id
      }
    ]
  ]) : []

#Lambda
# Encabezado del Dashboard
lambda_header_widgets = try(var.lambda.create_dashboard, false) ? [
  {
    "type"   = "text",
    "width"  = 24,
    "height" = 1,
    "properties" = { "markdown" = "# **Monitoreo Comportamiento Lambda**" }
  },
  {
    "type"   = "text",
    "width"  = 24,
    "height" = 1,
    "properties" = { "markdown" = "## [**AWS Lambda Dashboard**](https://console.aws.amazon.com/lambda/home)" }
  }
] : []

# Creación de métricas Lambda
lambda_metric_widgets = try(var.lambda.create_dashboard, false) && length(local.lambda_functions_filtered) > 0 ? [
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

# Concatenación de métricas y encabezado
lambda_widgets = concat(local.lambda_header_widgets, local.lambda_metric_widgets)

# Lambda Alarmas
lambda_alarms = try(var.lambda.create_alarms, false) && length(local.lambda_functions_filtered) > 0 ? flatten([
  for function_name in local.lambda_functions_filtered : [
    for metric in local.lambda_metrics : {
      alarm_name    = "lambda-${metric}-${function_name}",
      metric_name   = metric,
      threshold     = var.lambda.alarm_thresholds[metric]
      function_name = function_name
    }
  ]
]) : []

#ALB
#Encabezado del Dashboard
alb_header_widgets = try(var.alb.create_dashboard, false) ? [
  {
    "type"   = "text",
    "width"  = 24,
    "height" = 1,
    "properties" = { "markdown" = "# **Monitoreo Application Load Balancer**" }
  },
  {
    "type"   = "text",
    "width"  = 24,
    "height" = 1,
    "properties" = { "markdown" = "## [**AWS ALB Dashboard**](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:)" }
  }
] : []

#Métricas en el Dashboard
alb_metric_widgets = try(var.alb.create_dashboard, false) && length(local.alb_instances_filtered) > 0 ? [
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

#Concatenación de Widgets
alb_widgets = concat(local.alb_header_widgets, local.alb_metric_widgets)

#Alarmas para ALB
alb_alarms = try(var.alb.create_alarms, false) && length(local.alb_instances_filtered) > 0 ? flatten([
  for alb in local.alb_instances_filtered : [
    for metric in local.alb_metrics : {
      alarm_name  = "alb-${metric}-${alb}",
      metric_name = metric,
      threshold   = var.alb.alarm_thresholds[metric],
      alb_arn     = alb
    }
  ]
]) : []

# NLB
#Encabezado del Dashboard
nlb_header_widgets = try(var.nlb.create_dashboard, false) ? [
  {
    "type"   = "text",
    "width"  = 24,
    "height" = 1,
    "properties" = { "markdown" = "# **Monitoreo Comportamiento NLB**" }
  },
  {
    "type"   = "text",
    "width"  = 24,
    "height" = 1,
    "properties" = { "markdown" = "## [**AWS NLB Dashboard**](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:)" }
  }
] : []

#Creación de métricas
nlb_metric_widgets = try(var.nlb.create_dashboard, false) && length(local.nlb_filtered) > 0 ? [
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

# Concatenación de widgets
nlb_widgets = concat(local.nlb_header_widgets, local.nlb_metric_widgets)

#Alarmas
nlb_alarms = try(var.nlb.create_alarms, false) && length(local.nlb_filtered) > 0 ? flatten([
  for nlb_name in local.nlb_filtered : [
    for metric in local.nlb_metrics : {
      alarm_name    = "nlb-${metric}-${nlb_name}",
      metric_name   = metric,
      threshold     = var.nlb.alarm_thresholds[metric]
      nlb_name      = nlb_name
    }
  ]
]) : []

#S3

# Encabezado del Dashboard
  s3_header_widgets = try(var.s3.create_dashboard, false) ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "# **Monitoreo de S3 Buckets**" }
    },
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "## [**AWS S3 Dashboard**](https://console.aws.amazon.com/s3/home)" }
    }
  ] : []

  # Creación de métricas S3
  s3_metric_widgets = try(var.s3.create_dashboard, false) && length(local.s3_buckets_filtered) > 0 ? [
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

  # Concatenación de métricas y encabezado
  s3_widgets = concat(local.s3_header_widgets, local.s3_metric_widgets)

  # Alarmas
  s3_alarms = try(var.s3.create_alarms, false) && length(local.s3_buckets_filtered) > 0 ? flatten([
    for bucket in local.s3_buckets_filtered : [
      for metric in local.s3_metrics : {
        alarm_name  = "s3-${metric}-${bucket}",
        metric_name = metric,
        threshold   = var.s3.alarm_thresholds[metric],
        bucket_name = bucket
      }
    ]
  ]) : []


  #API
  apigateway_header_widgets = try(var.apigateway.create_dashboard, false) ? [
  {
    "type"   = "text",
    "width"  = 24,
    "height" = 1,
    "properties" = { "markdown" = "# **Monitoreo API Gateway**" }
  },
  {
    "type"   = "text",
    "width"  = 24,
    "height" = 1,
    "properties" = { "markdown" = "## [**API Gateway Dashboard**](https://console.aws.amazon.com/apigateway/home)" }
  }
] : []

apigateway_metric_widgets = try(var.apigateway.create_dashboard, false) && length(local.apigateway_filtered) > 0 ? [
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

apigateway_widgets = concat(local.apigateway_header_widgets, local.apigateway_metric_widgets)

apigateway_alarms = try(var.apigateway.create_alarms, false) && length(local.apigateway_filtered) > 0 ? flatten([
  for api_id in local.apigateway_filtered : [
    for metric in local.apigateway_metrics : {
      alarm_name  = "apigateway-${metric}-${api_id}"
      metric_name = metric
      threshold   = var.apigateway.alarm_thresholds[metric]
      api_id      = api_id
    }
  ]
]) : []

#Dynamo
dynamodb_header_widgets = try(var.dynamodb.create_dashboard, false) ? [
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "# **Monitoreo DynamoDB**" }
    },
    {
      "type"   = "text",
      "width"  = 24,
      "height" = 1,
      "properties" = { "markdown" = "## [**DynamoDB Dashboard**](https://console.aws.amazon.com/dynamodb/home)" }
    }
  ] : []

  dynamodb_metric_widgets = try(var.dynamodb.create_dashboard, false) && length(local.dynamodb_filtered) > 0 ? [
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

  dynamodb_widgets = concat(local.dynamodb_header_widgets, local.dynamodb_metric_widgets)

  dynamodb_alarms = try(var.dynamodb.create_alarms, false) && length(local.dynamodb_filtered) > 0 ? flatten([
    for table in local.dynamodb_filtered : [
      for metric in local.dynamodb_metrics : {
        alarm_name  = "dynamodb-${metric}-${table}"
        metric_name = metric
        threshold   = var.dynamodb.alarm_thresholds[metric]
        table_name  = table
      }
    ]
  ]) : []

}

locals {

  rds_instances_filtered = [
    for id, instance in data.aws_db_instance.rds_filtered :
    id if lookup(instance.tags, "EnableObservability", "false") == "true"
  ]

  lambda_functions_filtered = [
    for fn in data.aws_lambda_function.tagged :
    fn.function_name if lookup(fn.tags, var.lambda.tag_key, "false") == var.lambda.tag_value
  ]
  
  alb_instances_filtered = [
    for alb in data.aws_lb.tagged : alb.name
  ]
  

  nlb_filtered = [
    for nlb in data.aws_lb.tagged_nlb : nlb.name
  ]

  s3_buckets_filtered = [for bucket in data.aws_resourcegroupstaggingapi_resources.s3_filtered.resource_tag_mapping_list :
    replace(bucket.resource_arn, "arn:aws:s3:::", "")
  ]

  apigateway_filtered = [for api in data.aws_resourcegroupstaggingapi_resources.api_filtered.resource_tag_mapping_list :
    element(split("/", api.resource_arn), length(split("/", api.resource_arn)) - 1)
  ]

  dynamodb_filtered = [for table in data.aws_resourcegroupstaggingapi_resources.dynamodb_filtered.resource_tag_mapping_list :
    element(split("/", table.resource_arn), length(split("/", table.resource_arn)) - 1)
  ]


}
