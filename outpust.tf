output "ecs_clusters_filtered_debug" {
  value = local.ecs_clusters_filtered
}

output "ecs_services_filtered_debug" {
  value = local.ecs_services_filtered
}

output "ecs_resource_tag_mapping_debug" {
  value = try(data.aws_resourcegroupstaggingapi_resources.ecs_clusters_filtered[0].resource_tag_mapping_list, [])
}

output "ecs_widgets_debug" {
  value = local.ecs_metric_widgets
}

output "all_widgets_count" {
  value = length(local.all_widgets)
}

output "dashboard_body_excerpt" {
  value = try(jsondecode(aws_cloudwatch_dashboard.unified_dashboard[0].dashboard_body).widgets, [])
}