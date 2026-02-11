# Ejemplo de Uso - AWS CloudWatch Observability Module

Este directorio contiene un ejemplo completo de cómo usar el módulo de observabilidad de CloudWatch.

## Contenido

- `main.tf` - Configuración del módulo con ejemplos de ECS, RDS y WAF
- `variables.tf` - Definición de variables
- `terraform.tfvars` - Valores de las variables
- `providers.tf` - Configuración del provider AWS

## Prerequisitos

1. **Terraform instalado** (>= 1.0)
2. **AWS CLI configurado** con credenciales válidas
3. **Recursos AWS existentes** con los tags apropiados:
   ```hcl
   tags = {
     EnableObservability = "true"
   }
   ```

## Recursos de Ejemplo Incluidos

Este ejemplo configura monitoreo para:

### 1. Amazon ECS
- Dashboard con métricas de CPU y Memoria por servicio
- Alarmas automáticas para todos los servicios descubiertos
- Niveles: warning (80%) y critical (90%)

### 2. Amazon RDS/Aurora
- Dashboard con 5 métricas clave
- Alarmas para CPU, memoria y conexiones
- Múltiples umbrales por métrica

### 3. AWS WAF
- Monitoreo de Web ACLs (Regional y CloudFront)
- Dashboard de solicitudes permitidas/bloqueadas
- Alarmas por tráfico excesivo

## Configuración Rápida

### Paso 1: Clonar y Navegar

```bash
git clone <repository-url>
cd cloudops-ref-repo-aws-cw-tags-terraform/sample
```

### Paso 2: Configurar Variables

Edita `terraform.tfvars` con tus valores:

```hcl
aws_region  = "us-east-1"
profile     = "tu-perfil-aws"
environment = "dev"
client      = "tu-cliente"
project     = "tu-proyecto"
application = "tu-aplicacion"

common_tags = {
  environment  = "dev"
  project-name = "Tu Proyecto"
  cost-center  = "CC-123"
  owner        = "tu-email@empresa.com"
  area         = "DevOps"
  provisioned  = "terraform"
  datatype     = "interno"
}
```

### Paso 3: Ajustar Configuración del Módulo

Edita `main.tf` según tus necesidades:

#### Habilitar/Deshabilitar Servicios

```hcl
module "observability" {
  source = "../"
  
  # ... variables globales ...
  
  # Comentar servicios que no necesites
  # ecs = { ... }
  # rds = { ... }
  # waf = { ... }
}
```

#### Actualizar ARNs de SNS

Reemplaza los ARNs de ejemplo con tus SNS topics reales:

```hcl
alarm_actions = ["arn:aws:sns:us-east-1:TU-ACCOUNT-ID:tu-topic"]
```

#### Configurar Web ACLs de WAF

Si usas WAF, actualiza con tus Web ACLs:

```hcl
waf = {
  web_acls = [
    {
      name   = "tu-waf-regional"
      id     = "tu-webacl-id"
      scope  = "REGIONAL"
      region = "us-east-1"
    }
  ]
}
```

### Paso 4: Inicializar y Aplicar

```bash
# Inicializar Terraform
terraform init

# Ver el plan
terraform plan

# Aplicar cambios
terraform apply
```

## Estructura del Ejemplo

```
sample/
├── README.md           # Este archivo
├── main.tf            # Configuración del módulo
├── variables.tf       # Definición de variables
├── terraform.tfvars   # Valores de variables
├── providers.tf       # Configuración del provider
└── outputs.tf         # Outputs (opcional)
```

## Configuraciones de Ejemplo Detalladas

### ECS con Container Insights

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
      width          = 12
      height         = 6
    },
    {
      metric_name    = "MemoryUtilization"
      dimension_name = "ServiceName"
      title          = "Memoria por Servicio"
      width          = 12
      height         = 6
    }
  ]

  # Estas alarmas se crean para CADA servicio descubierto
  service_alarm_templates = [
    {
      metric_name        = "CPUUtilization"
      threshold          = 80
      severity           = "warning"
      comparison         = "GreaterThanOrEqualToThreshold"
      description        = "CPU por encima del 80%"
      alarm_actions      = ["arn:aws:sns:us-east-1:123456789012:alerts"]
      evaluation_periods = 3
      period             = 300
      statistic          = "Average"
    }
  ]
}
```

### RDS/Aurora Completo

```hcl
rds = {
  create_dashboard = true
  create_alarms    = true
  tag_key          = "EnableObservability"
  tag_value        = "true"

  dashboard_config = [
    {
      metric_name = "CPUUtilization"
      title       = "Aurora RDS - CPU Utilization (%)"
    },
    {
      metric_name = "FreeableMemory"
      title       = "Aurora RDS - Freeable Memory (Bytes)"
    },
    {
      metric_name = "DatabaseConnections"
      title       = "Aurora RDS - Database Connections"
    },
    {
      metric_name = "ReadIOPS"
      title       = "Aurora RDS - Read IOPS"
    },
    {
      metric_name = "WriteIOPS"
      title       = "Aurora RDS - Write IOPS"
    }
  ]

  alarm_config = [
    # CPU Warning
    {
      metric_name               = "CPUUtilization"
      threshold                 = 75
      severity                  = "warning"
      comparison                = "GreaterThanOrEqualToThreshold"
      description               = "CPU por encima del 75%"
      alarm_actions             = ["arn:aws:sns:us-east-1:123456789012:alerts"]
      insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:alerts"]
      ok_actions                = ["arn:aws:sns:us-east-1:123456789012:alerts"]
      evaluation_periods        = 3
      datapoints_to_alarm       = 3
    },
    # CPU Critical
    {
      metric_name         = "CPUUtilization"
      threshold           = 90
      severity            = "critical"
      comparison          = "GreaterThanOrEqualToThreshold"
      description         = "CPU por encima del 90%"
      alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:alerts"]
      evaluation_periods  = 3
      datapoints_to_alarm = 2
    },
    # Memoria Warning
    {
      metric_name         = "FreeableMemory"
      threshold           = 2000000000  # 2 GB
      severity            = "warning"
      comparison          = "LessThanOrEqualToThreshold"
      description         = "Memoria disponible menor a 2GB"
      alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:alerts"]
      evaluation_periods  = 3
      datapoints_to_alarm = 3
    },
    # Conexiones Warning
    {
      metric_name         = "DatabaseConnections"
      threshold           = 450
      severity            = "warning"
      comparison          = "GreaterThanOrEqualToThreshold"
      description         = "Conexiones por encima de 450"
      alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:alerts"]
      evaluation_periods  = 3
    }
  ]
}
```

### WAF Regional y CloudFront

```hcl
waf = {
  create_dashboard = true
  create_alarms    = true
  
  web_acls = [
    # WAF Regional (ALB, API Gateway)
    {
      name   = "waf-regional"
      id     = "39a849f8-213b-477f-8e1f-00f944fe4c01"
      scope  = "REGIONAL"
      region = "us-east-1"
    },
    # WAF Global (CloudFront)
    {
      name  = "waf-global"
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
      metric_name            = "BlockedRequests"
      threshold              = 100
      severity               = "warning"
      comparison             = "GreaterThanThreshold"
      description            = "Alto número de solicitudes bloqueadas"
      alarm_actions          = ["arn:aws:sns:us-east-1:123456789012:alerts"]
      statistic              = "Sum"
      period                 = 300
      treat_missing_data     = "notBreaching"
    },
    {
      metric_name        = "AllowedRequests"
      threshold          = 5000
      severity           = "critical"
      comparison         = "GreaterThanThreshold"
      description        = "Tráfico excesivo"
      alarm_actions      = ["arn:aws:sns:us-east-1:123456789012:alerts"]
      statistic          = "Sum"
      treat_missing_data = "notBreaching"
    }
  ]
}
```

## Personalización

### Agregar Más Servicios

Para agregar Lambda, por ejemplo:

```hcl
module "observability" {
  source = "../"
  
  # ... configuración existente ...
  
  lambda = {
    create_dashboard = true
    create_alarms    = true
    tag_key          = "EnableObservability"
    tag_value        = "true"
    
    dashboard_config = [
      {
        metric_name = "Invocations"
        statistic   = "Sum"
        title       = "Lambda Invocations"
      },
      {
        metric_name = "Errors"
        statistic   = "Sum"
        title       = "Lambda Errors"
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
}
```

### Cambiar Tags de Descubrimiento

Si tus recursos usan tags diferentes:

```hcl
ecs = {
  tag_key   = "Monitoring"
  tag_value = "enabled"
  # ...
}
```

### Ajustar Umbrales

Modifica los thresholds según tus necesidades:

```hcl
alarm_config = [
  {
    metric_name = "CPUUtilization"
    threshold   = 60  # Más conservador
    severity    = "warning"
  }
]
```

## Verificación

### 1. Verificar Recursos Descubiertos

```bash
terraform output ecs_clusters_filtered_debug
terraform output ecs_services_filtered_debug
```

### 2. Ver Dashboard en AWS Console

Después del apply, ve a:
```
CloudWatch → Dashboards → {client}-{project}-{environment}-{application}-unified
```

### 3. Verificar Alarmas

```
CloudWatch → Alarms → All alarms
```

Busca alarmas con el patrón: `{servicio}-{metrica}-{severity}-{recurso}`

## Limpieza

Para eliminar todos los recursos creados:

```bash
terraform destroy
```

Esto eliminará:
- Dashboard de CloudWatch
- Todas las alarmas configuradas

**Nota**: No eliminará los recursos monitoreados (EC2, RDS, etc.), solo la observabilidad.

## Troubleshooting

### No se crean alarmas

**Problema**: `terraform apply` no crea alarmas

**Solución**:
1. Verifica que `create_alarms = true`
2. Verifica que `alarm_config` no esté vacío
3. Verifica que los recursos tengan el tag correcto
4. Revisa los outputs de debug

### Dashboard vacío

**Problema**: El dashboard se crea pero no tiene widgets

**Solución**:
1. Verifica que existan recursos con el tag `EnableObservability = "true"`
2. Verifica que `dashboard_config` no esté vacío
3. Para EC2, verifica que las instancias estén en estado `running`
4. Usa los outputs de debug:
   ```bash
   terraform output all_widgets_count
   ```

### Errores de SNS

**Problema**: Error al crear alarmas por ARN de SNS inválido

**Solución**:
1. Verifica que los SNS topics existan
2. Verifica que los ARNs sean correctos
3. Verifica permisos IAM para publicar en SNS

### WAF no aparece

**Problema**: WAF no aparece en el dashboard

**Solución**:
1. Verifica que los Web ACL IDs sean correctos
2. Para REGIONAL, verifica que la región sea correcta
3. Para CLOUDFRONT, debe ser scope "CLOUDFRONT" (no "GLOBAL")

## Mejores Prácticas

1. **Usa workspaces de Terraform** para diferentes ambientes:
   ```bash
   terraform workspace new dev
   terraform workspace new prod
   ```

2. **Separa SNS topics por severidad**:
   - `alerts-critical` para alarmas críticas
   - `alerts-warning` para advertencias
   - `alerts-info` para información

3. **Documenta tus umbrales**: Agrega comentarios explicando por qué elegiste cada threshold

4. **Versiona tu configuración**: Usa Git para trackear cambios

5. **Revisa regularmente**: Ajusta umbrales basándote en el comportamiento real

## Recursos Adicionales

- [Documentación del módulo](../README.md)
- [AWS CloudWatch Metrics](https://docs.aws.amazon.com/cloudwatch/index.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## Soporte

Para preguntas o issues, contactar a [equipo de soporte].
