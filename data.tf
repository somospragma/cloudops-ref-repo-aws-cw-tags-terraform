# Obtener instancias EC2 basadas en el tag proporcionado
data "aws_instances" "ec2_tagged" {

  filter {
    name   = "tag:${try(var.ec2.tag_key, "dummy")}"
    values = [try(var.ec2.tag_value, "dummy")]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

#Para RDS
data "aws_db_instances" "all_rds" {}

data "aws_db_instance" "rds_filtered" {
  for_each = toset(data.aws_db_instances.all_rds.instance_identifiers)
  db_instance_identifier = each.value
}

#Para Lambda
data "aws_lambda_functions" "all_lambdas" {}


data "aws_lambda_function" "tagged" {
  for_each       = toset(data.aws_lambda_functions.all_lambdas.function_names)
  function_name  = each.value
}

#Para ALB
data "aws_resourcegroupstaggingapi_resources" "alb_filtered" {
  tag_filter {
    key    = "EnableObservability"
    values = ["true"]
  }
  resource_type_filters = ["elasticloadbalancing:loadbalancer"]
}

data "aws_lb" "tagged" {
  for_each = {
    for alb in data.aws_resourcegroupstaggingapi_resources.alb_filtered.resource_tag_mapping_list :
    alb.resource_arn => alb
    if can(regex("/app/", alb.resource_arn))  # Filtrar solo ALBs
  }

  arn = each.key
}

#NLB
data "aws_resourcegroupstaggingapi_resources" "nlb_filtered" {
  resource_type_filters = ["elasticloadbalancing:loadbalancer"]

  tag_filter {
    key    = var.nlb.tag_key
    values = [var.nlb.tag_value]
  }
}

data "aws_lb" "tagged_nlb" {
  for_each = {
    for lb in data.aws_resourcegroupstaggingapi_resources.nlb_filtered.resource_tag_mapping_list :
    lb.resource_arn => lb
    if startswith(lb.resource_arn, "arn:aws:elasticloadbalancing") &&
       can(regex("/net/", lb.resource_arn))  # Filtrar solo NLBs
  }
  arn = each.key
}

#Para S3

data "aws_resourcegroupstaggingapi_resources" "s3_filtered" {
  tag_filter {
    key    = var.s3.tag_key  
    values = [var.s3.tag_value]
  }
  resource_type_filters = ["s3"]
}

#Para API

data "aws_resourcegroupstaggingapi_resources" "api_filtered" {
  tag_filter {
    key    = var.apigateway.tag_key    
    values = [var.apigateway.tag_value]
  }
  resource_type_filters = ["apigateway"] 
}

#Para Dynamo
data "aws_resourcegroupstaggingapi_resources" "dynamodb_filtered" {
  tag_filter {
    key    = var.dynamodb.tag_key    
    values = [var.dynamodb.tag_value] 
  }
  resource_type_filters = ["dynamodb"]
}



