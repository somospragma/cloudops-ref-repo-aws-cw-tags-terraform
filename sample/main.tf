module "observability" {
  source = "../"

  client      = var.client
  project     = var.project
  environment = var.environment
  application = var.application

  ec2 = {
    functionality    = "ec2"
    tag_key          = "EnableObservability"
    tag_value        = "true"
    create_dashboard = true
    metrics          = ["CPUUtilization", "NetworkIn", "NetworkOut"]
    create_alarms    = true
    alarm_thresholds = {
      "CPUUtilization" = 75,
      "NetworkIn"      = 60000000,
      "NetworkOut"     = 60000000
    }
  }

  lambda = {
    functionality = "lambda"
    tag_key       = "EnableObservability"
    tag_value     = "true"
    create_dashboard = true
    metrics         = ["Invocations", "Duration", "Errors"]
    create_alarms = true
    alarm_thresholds = {
      "Invocations" = 1000
      "Duration"    = 2000
      "Errors"      = 5
    }
  }

  rds = {
    functionality    = "rds"
    tag_key          = "EnableObservability"
    tag_value        = "true"
    create_dashboard = true
    metrics          = ["CPUUtilization", "DatabaseConnections", "FreeableMemory"]
    create_alarms    = true
    alarm_thresholds = {
      "CPUUtilization"      = 75,
      "DatabaseConnections" = 80,
      "FreeableMemory"      = 1500000000
    }
  }

  alb = {
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["RequestCount", "TargetResponseTime", "HTTPCode_ELB_5XX_Count", "4xx_count"]
    alarm_thresholds = {
      RequestCount           = 50000
      TargetResponseTime     = 2
      HTTPCode_ELB_5XX_Count = 5
      "4xx_count"            = 3
    }
  }

  nlb = {
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["ProcessedBytes", "NewFlowCount", "ActiveFlowCount"]
    alarm_thresholds = {
      ProcessedBytes  = 1000000000
      NewFlowCount    = 5000
      ActiveFlowCount = 2000
    }
  }

  s3 = {
    functionality    = "s3"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["NumberOfObjects", "BucketSizeBytes"]
    alarm_thresholds = {
      "NumberOfObjects" = 10000
      "BucketSizeBytes" = 5000000000
    }
  }

  apigateway = {
    functionality    = "apigateway"
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    metrics          = ["Latency", "5XXError", "4XXError", "IntegrationLatency"]
    alarm_thresholds = {
      "Latency"            = 500
      "5XXError"           = 5
      "4XXError"           = 10
      "IntegrationLatency" = 1000
    }
  }

  # dynamodb = {
  #   functionality    = "dynamodb"
  #   create_dashboard = true
  #   create_alarms    = true
  #   tag_key          = "EnableObservability"
  #   tag_value        = "true"
  #   metrics          = ["ConsumedReadCapacityUnits", "ConsumedWriteCapacityUnits", "ThrottledRequests", "ReadThrottleEvents", "WriteThrottleEvents"]
  #   alarm_thresholds = {
  #     "ConsumedReadCapacityUnits"  = 1000
  #     "ConsumedWriteCapacityUnits" = 500
  #     "ThrottledRequests"          = 5
  #     "ReadThrottleEvents"         = 3
  #     "WriteThrottleEvents"        = 3
  #   }
  # }
}
