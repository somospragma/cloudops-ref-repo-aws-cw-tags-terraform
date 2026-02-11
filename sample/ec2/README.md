# Ejemplo EC2 - Alarmas de CPU, Memoria y Disco

Este ejemplo muestra cómo crear alarmas de CloudWatch para instancias EC2 monitoreando:
- **CPU** (métricas nativas de AWS/EC2)
- **Memoria** (requiere CloudWatch Agent)
- **Disco** (requiere CloudWatch Agent)

## 📋 Prerequisitos

### 1. CloudWatch Agent Instalado

Las métricas de **memoria** y **disco** requieren el CloudWatch Agent instalado en tus instancias EC2.

**Instalación rápida:**
```bash
# Descargar e instalar el agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm

# O usando SSM
aws ssm send-command \
  --document-name "AWS-ConfigureAWSPackage" \
  --parameters '{"action":["Install"],"name":["AmazonCloudWatchAgent"]}' \
  --targets "Key=tag:EnableObservability,Values=true"
```

**Configuración del agent** (`/opt/aws/amazon-cloudwatch-agent/etc/config.json`):
```json
{
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {"name": "cpu_usage_idle"},
          {"name": "cpu_usage_iowait"}
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          {"name": "disk_used_percent"}
        ],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": [
          {"name": "mem_used_percent"}
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
```

**Iniciar el agent:**
```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json
```

### 2. Tags en Instancias EC2

Tus instancias EC2 deben tener el tag:
```hcl
tags = {
  EnableObservability = "true"
}
```

### 3. SNS Topics Creados

Crea SNS topics para recibir notificaciones:
```bash
# Topic para warnings
aws sns create-topic --name alert-warning

# Topic para critical
aws sns create-topic --name alert-critical

# Suscribir tu email
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:123456789012:alert-critical \
  --protocol email \
  --notification-endpoint tu-email@empresa.com
```

## 🚀 Uso Rápido

### Paso 1: Configurar Variables

Edita `terraform.tfvars`:

```hcl
# Provider
aws_region = "us-east-1"
profile    = "tu-perfil-aws"

# Identificación
client      = "pragma"
project     = "hefesto"
environment = "dev"
application = "dashboard"

# SNS Topics (REEMPLAZAR CON TUS ARNs REALES)
sns_topic_warning  = "arn:aws:sns:us-east-1:TU-ACCOUNT-ID:alert-warning"
sns_topic_critical = "arn:aws:sns:us-east-1:TU-ACCOUNT-ID:alert-critical"

# Configuración de Disco (ajustar según tu EC2)
disk_path   = "/"
disk_device = "nvme0n1p1"  # o "xvda1" para EC2 antiguas
disk_fstype = "xfs"        # o "ext4"
```

### Paso 2: Obtener Configuración de Disco

**Conecta a tu EC2 y ejecuta:**

```bash
# Ver discos montados
df -h

# Salida ejemplo:
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/nvme0n1p1   20G   5G   15G  25% /

# Ver tipo de filesystem
lsblk -f

# Salida ejemplo:
# NAME        FSTYPE LABEL UUID                                 MOUNTPOINT
# nvme0n1                                                       
# └─nvme0n1p1 xfs          12345678-1234-1234-1234-123456789012 /
```

**Actualiza las variables:**
- `disk_path`: El MOUNTPOINT (ej: `/`, `/data`)
- `disk_device`: El NAME sin `/dev/` (ej: `nvme0n1p1`, `xvda1`)
- `disk_fstype`: El FSTYPE (ej: `xfs`, `ext4`)

### Paso 3: Desplegar

```bash
# Inicializar
terraform init

# Ver plan
terraform plan

# Aplicar
terraform apply
```

## 📊 Alarmas Creadas

El módulo creará **6 alarmas** por cada instancia EC2 descubierta:

### CPU (Métricas Nativas)
| Alarma | Threshold | Severidad | Descripción |
|--------|-----------|-----------|-------------|
| `ec2-CPUUtilization-warning-{instance-id}` | 80% | Warning | CPU > 80% por 2 de 3 períodos |
| `ec2-CPUUtilization-critical-{instance-id}` | 90% | Critical | CPU > 90% por 2 de 2 períodos |

### Memoria (CloudWatch Agent)
| Alarma | Threshold | Severidad | Descripción |
|--------|-----------|-----------|-------------|
| `ec2-mem_used_percent-warning-{instance-id}` | 80% | Warning | Memoria > 80% por 2 de 3 períodos |
| `ec2-mem_used_percent-critical-{instance-id}` | 90% | Critical | Memoria > 90% por 2 de 2 períodos |

### Disco (CloudWatch Agent)
| Alarma | Threshold | Severidad | Descripción |
|--------|-----------|-----------|-------------|
| `ec2-disk_used_percent-warning-{instance-id}` | 85% | Warning | Disco > 85% por 2 de 2 períodos |
| `ec2-disk_used_percent-critical-{instance-id}` | 95% | Critical | Disco > 95% por 2 de 2 períodos |

## 🔍 Verificación

### Ver Recursos Descubiertos

```bash
terraform output resources_discovered
```

**Salida esperada:**
```hcl
resources_discovered = {
  ec2 = 3
  # ... otros servicios en 0
}
```

### Ver Alarmas Creadas

```bash
terraform output ec2_alarm_names
```

**Salida esperada:**
```hcl
ec2_alarm_names = [
  "ec2-CPUUtilization-warning-i-1234567890abcdef0",
  "ec2-CPUUtilization-critical-i-1234567890abcdef0",
  "ec2-mem_used_percent-warning-i-1234567890abcdef0",
  "ec2-mem_used_percent-critical-i-1234567890abcdef0",
  "ec2-disk_used_percent-warning-i-1234567890abcdef0",
  "ec2-disk_used_percent-critical-i-1234567890abcdef0",
  # ... repetir para cada instancia
]
```

### Ver Resumen

```bash
terraform output summary
```

**Salida esperada:**
```hcl
summary = {
  ec2_instances_discovered = 3
  total_alarms_created     = 18  # 6 alarmas × 3 instancias
  alarm_names              = [...]
}
```

### Verificar en AWS Console

1. **CloudWatch → Alarms**
   - Busca alarmas con prefijo `ec2-`
   - Verifica que estén en estado `OK` o `ALARM`

2. **CloudWatch → Metrics → CWAgent**
   - Verifica que aparezcan métricas de `mem_used_percent` y `disk_used_percent`
   - Si no aparecen, el CloudWatch Agent no está enviando métricas

## 🔧 Personalización

### Cambiar Thresholds

Edita `main.tf` y ajusta los valores de `threshold`:

```hcl
alarm_config = [
  {
    metric_name = "CPUUtilization"
    threshold   = 70  # Cambiar de 80 a 70
    severity    = "warning"
    # ...
  }
]
```

### Monitorear Múltiples Discos

Para monitorear `/data` además de `/`:

```hcl
alarm_config = [
  # ... alarmas existentes ...
  
  # Disco /data
  {
    metric_name = "disk_used_percent"
    namespace   = "CWAgent"
    threshold   = 85
    severity    = "warning"
    description = "Disk usage on /data is above 85%"
    alarm_actions = [var.sns_topic_warning]
    additional_dimensions = {
      path   = "/data"
      device = "nvme1n1"
      fstype = "xfs"
    }
  }
]
```

### Cambiar Períodos de Evaluación

```hcl
{
  metric_name         = "CPUUtilization"
  threshold           = 80
  evaluation_periods  = 5      # Evaluar 5 períodos
  datapoints_to_alarm = 3      # Alarmar si 3 de 5 están en alarma
  period              = 60     # Períodos de 1 minuto
}
```

## 🐛 Troubleshooting

### No se crean alarmas

**Síntoma**: `terraform apply` completa pero no crea alarmas

**Soluciones**:
1. Verifica que las instancias tengan el tag `EnableObservability = "true"`
2. Verifica que las instancias estén en estado `running`
3. Ejecuta: `terraform output resources_discovered`
4. Si `ec2 = 0`, revisa los tags de tus instancias

### Alarmas de memoria/disco en INSUFFICIENT_DATA

**Síntoma**: Alarmas creadas pero en estado `INSUFFICIENT_DATA`

**Causa**: CloudWatch Agent no está enviando métricas

**Soluciones**:
1. Verifica que el agent esté instalado:
   ```bash
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
     -a query -m ec2 -c default -s
   ```

2. Verifica métricas en CloudWatch:
   ```bash
   aws cloudwatch list-metrics \
     --namespace CWAgent \
     --dimensions Name=InstanceId,Value=i-1234567890abcdef0
   ```

3. Revisa logs del agent:
   ```bash
   sudo tail -f /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
   ```

4. Verifica permisos IAM del rol de la instancia:
   - Debe tener `CloudWatchAgentServerPolicy`

### Dimensiones de disco incorrectas

**Síntoma**: Alarmas de disco en `INSUFFICIENT_DATA`

**Causa**: `device`, `path` o `fstype` incorrectos

**Solución**:
1. Conéctate a la instancia
2. Ejecuta: `df -h` y `lsblk -f`
3. Actualiza las variables en `terraform.tfvars`
4. Ejecuta: `terraform apply`

### SNS no envía emails

**Síntoma**: Alarmas se disparan pero no recibes emails

**Soluciones**:
1. Verifica que confirmaste la suscripción al SNS topic
2. Revisa la carpeta de spam
3. Verifica el ARN del SNS topic en `terraform.tfvars`
4. Prueba manualmente:
   ```bash
   aws sns publish \
     --topic-arn arn:aws:sns:us-east-1:123456789012:alert-critical \
     --message "Test"
   ```

## 📚 Configuraciones Comunes

### EC2 Modernas (Nitro - t3, m5, c5, etc.)

```hcl
disk_device = "nvme0n1p1"
disk_fstype = "xfs"
```

### EC2 Antiguas (t2, m4, c4, etc.)

```hcl
disk_device = "xvda1"
disk_fstype = "ext4"
```

### Amazon Linux 2

```hcl
disk_device = "nvme0n1p1"
disk_fstype = "xfs"
```

### Ubuntu

```hcl
disk_device = "nvme0n1p1"  # o "xvda1"
disk_fstype = "ext4"
```

## 🧹 Limpieza

Para eliminar todas las alarmas:

```bash
terraform destroy
```

**Nota**: Esto NO eliminará:
- Las instancias EC2
- El CloudWatch Agent
- Los SNS topics

## 📖 Referencias

- [CloudWatch Agent - Documentación AWS](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html)
- [Métricas del CloudWatch Agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/metrics-collected-by-CloudWatch-agent.html)
- [CloudWatch Alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html)
- [Módulo Principal - README](../../README.md)

## 💡 Mejores Prácticas

1. **Usa diferentes SNS topics por severidad** para priorizar notificaciones
2. **Ajusta thresholds** basándote en el comportamiento real de tus aplicaciones
3. **Monitorea múltiples discos** si tu aplicación usa volúmenes adicionales
4. **Documenta cambios** en los thresholds con comentarios en el código
5. **Revisa alarmas regularmente** y ajusta según sea necesario
6. **Usa `treat_missing_data = "notBreaching"`** para evitar falsos positivos durante mantenimiento

## 🆘 Soporte

Para preguntas o issues:
- Revisa la [documentación del módulo](../../README.md)
- Contacta al equipo de CloudOps
