# AWS CloudWatch Observability Module

Módulo de Terraform para automatizar la creación de dashboards y alarmas de CloudWatch basándose en tags de recursos AWS. Permite implementar observabilidad de forma estandarizada y escalable en toda tu infraestructura.

## Características

- **Descubrimiento Automático**: Identifica recursos mediante tags personalizables
- **Dashboard Unificado**: Crea un dashboard consolidado con todas las métricas
- **Alarmas Configurables**: Define alarmas con múltiples niveles de severidad
- **Multi-Servicio**: Soporta 11 servicios AWS diferentes
- **Plantillas de Alarmas**: Aplica configuraciones a múltiples recursos automáticamente
- **Organización por Secciones**: Dashboard estructurado por categorías (Cómputo, Serverless, Bases de Datos, etc.)

## Servicios Soportados

| Servicio | Dashboard | Alarmas | Estado |
|----------|-----------|---------|--------|
| Amazon EC2 | ✅ | ✅ | Completo |
| Amazon RDS/Aurora | ✅ | ✅ | Completo |
| AWS Lambda | ✅ | ✅ | Completo |
| Application Load Balancer | ✅ | ✅ | Completo |
| Network Load Balancer | ✅ | ✅ | Completo |
| Amazon S3 | ✅ | ✅ | Completo |
| API Gateway | ✅ | ✅ | Completo |
| Amazon DynamoDB | ✅ | ✅ | Completo |
| Amazon ECS | ✅ | ✅ | Completo |
| ECS Container Insights | ✅ | ✅ | Completo |
| AWS WAF | ✅ | ✅ | Completo |

## Requisitos

- Terraform >= 1.0
- AWS Provider >= 4.0
- Permisos IAM para:
  - CloudWatch (dashboards, alarmas, métricas)
  - Resource Groups Tagging API
  - Servicios específicos que desees monitorear

## Uso Básico

```hcl
module "observability" {
  source = "git::https://github.com/tu-org/cloudops-ref-repo-aws-cw-tags-terraform.git"

  # Variables globales
  client      = "acme"
  project     = "ecommerce"
  environment = "production"
  application = "webstore"

  # Configuración de EC2
  ec2 = {
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"

    dashboard_config = [
      {
        metric_name = "CPUUtilization"
        title       = "CPU Utilization por Instancia"
      }
    ]

    alarm_config = [
      {
        metric_name    = "CPUUtilization"
        threshold      = 80
        severity       = "warning"
        alarm_actions  = ["arn:aws:sns:us-east-1:123456789012:alerts"]
      }
    ]
  }
}
```

## Variables Globales

| Variable | Tipo | Descripción | Requerido |
|----------|------|-------------|-----------|
| `client` | string | Nombre del cliente | Sí |
| `project` | string | Nombre del proyecto | Sí |
| `environment` | string | Ambiente (dev, staging, prod) | Sí |
| `application` | string | Nombre de la aplicación | Sí |

## Configuración por Servicio

Cada servicio sigue la misma estructura de configuración:

```hcl
<servicio> = {
  functionality    = string           # Opcional: categoría funcional
  create_dashboard = bool             # Crear dashboard
  create_alarms    = bool             # Crear alarmas
  tag_key          = string           # Tag key para filtrar recursos
  tag_value        = string           # Tag value para filtrar recursos
  
  dashboard_config = list(object({    # Configuración de widgets
    metric_name = string
    period      = number              # Opcional: 300 por defecto
    statistic   = string              # Opcional: "Average" por defecto
    width       = number              # Opcional: 12 por defecto
    height      = number              # Opcional: 6 por defecto
    title       = string              # Opcional
  }))
  
  alarm_config = list(object({        # Configuración de alarmas
    metric_name               = string
    threshold                 = number
    severity                  = string  # "warning" o "critical"
    comparison                = string  # Opcional: "GreaterThanOrEqualToThreshold"
    description               = string  # Opcional
    alarm_actions             = list(string)
    insufficient_data_actions = list(string)  # Opcional
    ok_actions                = list(string)  # Opcional
    evaluation_periods        = number  # Opcional: 2
    period                    = number  # Opcional: 300
    statistic                 = string  # Opcional: "Average"
    datapoints_to_alarm       = number  # Opcional: 2
    treat_missing_data        = string  # Opcional: "missing"
  }))
}
```

## Ejemplos por Servicio

### Amazon EC2

```hcl
ec2 = {
  create_dashboard = true
  create_alarms    = true
  tag_key          = "EnableObservability"
  tag_value        = "true"

  dashboard_config = [
    {
      metric_name = "CPUUtilization"
      title       = "CPU Utilization"
    },
    {
      metric_name = "NetworkIn"
      title       = "Network In"
      statistic   = "Sum"
    }
  ]

  alarm_config = [
    {
      metric_name    = "CPUUtilization"
      threshold      = 80
      severity       = "warning"
      alarm_actions  = ["arn:aws:sns:us-east-1:123456789012:alerts"]
    }
  ]
}
```

### Amazon RDS/Aurora

```hcl
rds = {
  create_dashboard = true
  create_alarms    = true
  tag_key          = "EnableObservability"
  tag_value        = "true"

  dashboard_config = [
    {
      metric_name = "CPUUtilization"
      title       = "RDS CPU Utilization"
    },
    {
      metric_name = "DatabaseConnections"
      title       = "Database Connections"
    },
    {
      metric_name = "FreeableMemory"
      title       = "Freeable Memory"
    }
  ]

  alarm_config = [
    {
      metric_name    = "CPUUtilization"
      threshold      = 75
      severity       = "warning"
      alarm_actions  = ["arn:aws:sns:us-east-1:123456789012:alerts"]
    },
    {
      metric_name    = "FreeableMemory"
      threshold      = 2000000000  # 2GB en bytes
      severity       = "critical"
      comparison     = "LessThanOrEqualToThreshold"
      alarm_actions  = ["arn:aws:sns:us-east-1:123456789012:alerts"]
    }
  ]
}
```

### AWS Lambda

```hcl
lambda = {
  create_dashboard = true
  create_alarms    = true
  tag_key          = "EnableObservability"
  tag_value        = "true"

  dashboard_config = [
    {
      metric_name = "Invocations"
      title       = "Lambda Invocations"
      statistic   = "Sum"
    },
    {
      metric_name = "Errors"
      title       = "Lambda Errors"
      statistic   = "Sum"
    },
    {
      metric_name = "Duration"
      title       = "Lambda Duration"
    }
  ]

  alarm_config = [
    {
      metric_name    = "Errors"
      threshold      = 10
      severity       = "critical"
      statistic      = "Sum"
      alarm_actions  = ["arn:aws:sns:us-east-1:123456789012:alerts"]
    }
  ]
}
```

### Amazon ECS con Container Insights

```hcl
ecs = {
  create_dashboard = true
  create_alarms    = true
  tag_key          = "EnableObservability"
  tag_value        = "true"

  dashboard_config = [
    {
      metric_name    = "CPUUtilization"
      dimension_name = "ServiceName"
      title          = "CPU por Servicio"
    }
  ]

  # Plantillas que se aplican a TODOS los servicios descubiertos
  service_alarm_templates = [
    {
      metric_name    = "CPUUtilization"
      threshold      = 80
      severity       = "warning"
      alarm_actions  = ["arn:aws:sns:us-east-1:123456789012:alerts"]
    },
    {
      metric_name    = "MemoryUtilization"
      threshold      = 85
      severity       = "critical"
      alarm_actions  = ["arn:aws:sns:us-east-1:123456789012:alerts"]
    }
  ]
}

ecs_insights = {
  create_dashboard = true
  create_alarms    = false
  tag_key          = "EnableObservability"
  tag_value        = "true"

  dashboard_config = [
    {
      metric_name    = "CpuUtilized"
      dimension_name = "ClusterName"
      title          = "CPU Utilizada por Cluster"
    },
    {
      metric_name    = "MemoryUtilized"
      dimension_name = "ClusterName"
      title          = "Memoria Utilizada por Cluster"
    }
  ]
}
```

### AWS WAF

```hcl
waf = {
  create_dashboard = true
  create_alarms    = true
  
  # Especificar Web ACLs manualmente
  web_acls = [
    {
      name   = "my-regional-waf"
      id     = "39a849f8-213b-477f-8e1f-00f944fe4c01"
      scope  = "REGIONAL"
      region = "us-east-1"
    },
    {
      name  = "my-cloudfront-waf"
      id    = "27cfea59-8029-414e-9778-a1249d34565f"
      scope = "CLOUDFRONT"
    }
  ]
  
  dashboard_config = [
    {
      metric_name = "AllowedRequests"
      statistic   = "Sum"
      title       = "Solicitudes Permitidas"
    },
    {
      metric_name = "BlockedRequests"
      statistic   = "Sum"
      title       = "Solicitudes Bloqueadas"
    }
  ]
  
  alarm_config = [
    {
      metric_name   = "BlockedRequests"
      threshold     = 100
      severity      = "warning"
      statistic     = "Sum"
      alarm_actions = ["arn:aws:sns:us-east-1:123456789012:alerts"]
    }
  ]
}
```

## Métricas Disponibles por Servicio

### EC2
- CPUUtilization
- NetworkIn / NetworkOut
- DiskReadBytes / DiskWriteBytes
- StatusCheckFailed

### RDS/Aurora
- CPUUtilization
- DatabaseConnections
- FreeableMemory
- ReadIOPS / WriteIOPS
- ReadLatency / WriteLatency

### Lambda
- Invocations
- Errors
- Duration
- Throttles
- ConcurrentExecutions

### ALB
- RequestCount
- TargetResponseTime
- HTTPCode_Target_2XX_Count
- HTTPCode_Target_4XX_Count
- HTTPCode_Target_5XX_Count
- UnHealthyHostCount

### NLB
- ActiveFlowCount
- ProcessedBytes
- TCP_Client_Reset_Count
- TCP_Target_Reset_Count
- HealthyHostCount / UnHealthyHostCount

### S3
- BucketSizeBytes
- NumberOfObjects
- AllRequests
- 4xxErrors / 5xxErrors

### API Gateway
- Count (requests)
- Latency
- 4XXError / 5XXError
- IntegrationLatency

### DynamoDB
- ConsumedReadCapacityUnits
- ConsumedWriteCapacityUnits
- UserErrors
- SystemErrors

### ECS (Estándar)
- CPUUtilization
- MemoryUtilization

### ECS Container Insights
- CpuUtilized / CpuReserved
- MemoryUtilized / MemoryReserved
- NetworkRxBytes / NetworkTxBytes
- StorageReadBytes / StorageWriteBytes

### WAF
- AllowedRequests
- BlockedRequests
- CountedRequests

## Outputs

El módulo proporciona varios outputs para debugging:

```hcl
output "ecs_clusters_filtered_debug" {
  description = "Lista de clusters ECS descubiertos"
}

output "ecs_services_filtered_debug" {
  description = "Lista de servicios ECS descubiertos"
}

output "all_widgets_count" {
  description = "Número total de widgets en el dashboard"
}

output "dashboard_body_excerpt" {
  description = "Contenido del dashboard para inspección"
}
```

## Estructura del Dashboard

El dashboard se organiza en las siguientes secciones:

1. **Cómputo**: EC2
2. **Contenedores**: ECS, ECS Container Insights
3. **Serverless**: Lambda, API Gateway
4. **Bases de Datos**: RDS/Aurora, DynamoDB
5. **Almacenamiento**: S3
6. **Redes**: ALB, NLB
7. **Seguridad**: WAF

Cada sección incluye un header con link directo a la consola AWS del servicio.

## Convenciones de Nombres

### Dashboard
```
{client}-{project}-{environment}-{application}-unified
```
Ejemplo: `acme-ecommerce-production-webstore-unified`

### Alarmas
```
{servicio}-{metrica}-{severity}-{recurso}
```
Ejemplos:
- `ec2-CPUUtilization-warning-i-1234567890abcdef0`
- `rds-DatabaseConnections-critical-mydb-instance`
- `lambda-Errors-critical-my-function`

## Tagging de Recursos

Para que los recursos sean descubiertos automáticamente, deben tener el tag configurado:

```hcl
tags = {
  EnableObservability = "true"
}
```

Puedes personalizar el tag key y value por servicio:

```hcl
ec2 = {
  tag_key   = "Monitoring"
  tag_value = "enabled"
  # ...
}
```

## Mejores Prácticas

1. **Usa SNS Topics separados por severidad**:
   ```hcl
   alarm_actions = [
     "arn:aws:sns:us-east-1:123456789012:critical-alerts",
     "arn:aws:sns:us-east-1:123456789012:warning-alerts"
   ]
   ```

2. **Define múltiples umbrales para la misma métrica**:
   ```hcl
   alarm_config = [
     { metric_name = "CPUUtilization", threshold = 75, severity = "warning" },
     { metric_name = "CPUUtilization", threshold = 90, severity = "critical" }
   ]
   ```

3. **Usa plantillas para ECS**:
   ```hcl
   service_alarm_templates = [...]  # Se aplica a todos los servicios
   ```

4. **Configura treat_missing_data apropiadamente**:
   - `"missing"`: No evalúa la alarma (default)
   - `"notBreaching"`: Trata datos faltantes como OK
   - `"breaching"`: Trata datos faltantes como alarma
   - `"ignore"`: Mantiene el estado actual

5. **Ajusta datapoints_to_alarm para reducir falsos positivos**:
   ```hcl
   evaluation_periods  = 3
   datapoints_to_alarm = 2  # 2 de 3 períodos deben estar en alarma
   ```

## Limitaciones

- WAF requiere especificar Web ACLs manualmente (no hay auto-descubrimiento por tags)
- Dashboard único consolidado (no separado por servicio)
- Algunos servicios aún no están implementados (CloudFront, SQS, ECR, Textract)

## Troubleshooting

### No se crean recursos

Verifica que:
1. Los recursos tengan el tag correcto
2. Los recursos estén en estado activo (ej: EC2 running)
3. `create_dashboard` o `create_alarms` estén en `true`
4. Exista al menos una configuración en `dashboard_config` o `alarm_config`

### Alarmas no se disparan

Verifica:
1. El threshold sea apropiado para la métrica
2. El comparison operator sea correcto
3. Los SNS topics existan y tengan suscriptores
4. La métrica esté generando datos

### Dashboard vacío

Verifica:
1. Que existan recursos con el tag configurado
2. Que `dashboard_config` no esté vacío
3. Los outputs de debug para ver qué recursos se descubrieron

## Contribuir

Para agregar un nuevo servicio:

1. Agregar variable en `variables.tf`
2. Agregar data source en `data.tf`
3. Agregar filtros en `filtros.tf`
4. Agregar alarmas en `alarmas.tf`
5. Agregar widgets en `widgets.tf`
6. Agregar recurso en `main.tf`

## Licencia

[Especificar licencia]

## Soporte

Para reportar issues o solicitar features, contactar a [equipo de soporte].
