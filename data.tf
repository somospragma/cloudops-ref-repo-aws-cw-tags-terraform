###########################################################
# Data Obtiene Instancias EC2 segun el Tag
###########################################################
data "aws_instances" "ec2_tagged" {
  count = var.ec2 != null ? 1 : 0

  filter {
    name   = "tag:${try(var.ec2.tag_key, "EnableObservability")}"
    values = [try(var.ec2.tag_value, "true")]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

###########################################################
# Data Obtiene Instancias RDS/Aurora segun el Tag
###########################################################
data "aws_db_instances" "all_rds" {
  count = var.rds != null ? 1 : 0
}

data "aws_db_instance" "rds_filtered" {
  for_each = var.rds != null ? toset(try(data.aws_db_instances.all_rds[0].instance_identifiers, [])) : []
  db_instance_identifier = each.value
}

##########################################################
# Data Obtiene Instancias Lambda segun el Tag
##########################################################
data "aws_resourcegroupstaggingapi_resources" "lambda_filtered" {
  count = var.lambda != null ? 1 : 0
  
  tag_filter {
    key    = try(var.lambda.tag_key, "EnableObservability")
    values = [try(var.lambda.tag_value, "true")]
  }
  resource_type_filters = ["lambda:function"]
}

##########################################################
# Data Obtiene Instancias ALB segun el Tag
##########################################################
data "aws_resourcegroupstaggingapi_resources" "alb_filtered" {
  count = var.alb != null ? 1 : 0
  
  tag_filter {
    key    = try(var.alb.tag_key, "EnableObservability")
    values = [try(var.alb.tag_value, "true")]
  }
  resource_type_filters = ["elasticloadbalancing:loadbalancer"]
}

data "aws_lb" "tagged" {
  for_each = var.alb != null ? {
    for alb in try(data.aws_resourcegroupstaggingapi_resources.alb_filtered[0].resource_tag_mapping_list, []) :
    alb.resource_arn => alb
    if can(regex("/app/", alb.resource_arn))  # Filtrar solo ALBs
  } : {}

  arn = each.key
}

##########################################################
# Data Obtiene Instancias NLB segun el Tag
##########################################################
data "aws_resourcegroupstaggingapi_resources" "nlb_filtered" {
  count = var.nlb != null ? 1 : 0
  
  resource_type_filters = ["elasticloadbalancing:loadbalancer"]

  tag_filter {
    key    = try(var.nlb.tag_key, "EnableObservability")
    values = [try(var.nlb.tag_value, "true")]
  }
}

data "aws_lb" "tagged_nlb" {
  for_each = var.nlb != null ? {
    for lb in try(data.aws_resourcegroupstaggingapi_resources.nlb_filtered[0].resource_tag_mapping_list, []) :
    lb.resource_arn => lb
    if startswith(lb.resource_arn, "arn:aws:elasticloadbalancing") &&
       can(regex("/net/", lb.resource_arn))  # Filtrar solo NLBs
  } : {}
  
  arn = each.key
}

##########################################################
# Data Obtiene Instancias S3 segun el Tag
##########################################################
data "aws_resourcegroupstaggingapi_resources" "s3_filtered" {
  count = var.s3 != null ? 1 : 0
  
  tag_filter {
    key    = try(var.s3.tag_key, "EnableObservability")  
    values = [try(var.s3.tag_value, "true")]
  }
  resource_type_filters = ["s3"]
}

##########################################################
# Data Obtiene Instancias Api Gateway segun el Tag
##########################################################
data "aws_resourcegroupstaggingapi_resources" "api_filtered" {
  count = var.apigateway != null ? 1 : 0
  
  tag_filter {
    key    = try(var.apigateway.tag_key, "EnableObservability")    
    values = [try(var.apigateway.tag_value, "true")]
  }
  resource_type_filters = ["apigateway"] 
}

##########################################################
# Data Obtiene Instancias Dynamodb segun el Tag
##########################################################
data "aws_resourcegroupstaggingapi_resources" "dynamodb_filtered" {
  count = var.dynamodb != null ? 1 : 0
  
  tag_filter {
    key    = try(var.dynamodb.tag_key, "EnableObservability")    
    values = [try(var.dynamodb.tag_value, "true")] 
  }
  resource_type_filters = ["dynamodb"]
}

##########################################################
# Data Obtiene Recursos ECS segun el Tag
##########################################################
data "aws_resourcegroupstaggingapi_resources" "ecs_clusters_filtered" {
  count = var.ecs != null || var.ecs_insights != null ? 1 : 0
  
  tag_filter {
    key    = try(var.ecs != null ? var.ecs.tag_key : var.ecs_insights.tag_key, "EnableObservability")
    values = [try(var.ecs != null ? var.ecs.tag_value : var.ecs_insights.tag_value, "true")]
  }
  resource_type_filters = ["ecs:cluster"]
}

data "aws_resourcegroupstaggingapi_resources" "ecs_services_filtered" {
  count = var.ecs != null || var.ecs_insights != null ? 1 : 0
  
  tag_filter {
    key    = try(var.ecs != null ? var.ecs.tag_key : var.ecs_insights.tag_key, "EnableObservability")
    values = [try(var.ecs != null ? var.ecs.tag_value : var.ecs_insights.tag_value, "true")]
  }
  resource_type_filters = ["ecs:service"]
}