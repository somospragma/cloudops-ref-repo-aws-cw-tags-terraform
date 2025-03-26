#!/bin/bash

# Configuración
CLOUDFRONT_URL="https://d2wgwippvo9ibu.cloudfront.net"
TOTAL_REQUESTS=100
DELAY=0.2

# Colores para la salida (eliminados para compatibilidad)
echo "=== Prueba de WAF Rate Limiting ==="
echo "URL objetivo: $CLOUDFRONT_URL"
echo "Total de peticiones: $TOTAL_REQUESTS"
echo "Intervalo entre peticiones: $DELAY segundos"
echo "Tiempo estimado: $(echo "$TOTAL_REQUESTS * $DELAY" | bc) segundos"
echo "Presiona Ctrl+C para detener"
echo ""

# Contadores
success=0
blocked=0
other_errors=0

# Tiempo de inicio
start_time=$(date +%s)

# Añadir un encabezado aleatorio para evitar caché
random_string=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

# Bucle para enviar peticiones
i=1
while [ $i -le $TOTAL_REQUESTS ]
do
    # Mostrar progreso
    echo -n "Petición $i de $TOTAL_REQUESTS: "
    
    # Enviar petición con curl
    response=$(curl -s -o /dev/null -w "%{http_code}" "$CLOUDFRONT_URL?nocache=$i-$random_string" \
        -H "User-Agent: WAFTest/1.0" \
        -H "X-Test-Header: TestValue-$i" \
        --connect-timeout 5)
    
    # Verificar respuesta
    if [ "$response" = "200" ]; then
        echo "OK"
        success=$((success + 1))
    elif [ "$response" = "403" ] || [ "$response" = "429" ]; then
        echo "BLOQUEADO (código $response)"
        blocked=$((blocked + 1))
        
        # Si es la primera petición bloqueada, registrar el tiempo
        if [ $blocked -eq 1 ]; then
            block_time=$(date +%s)
            time_to_block=$((block_time - start_time))
            echo "Primera petición bloqueada después de $time_to_block segundos"
        fi
    else
        echo "ERROR (código $response)"
        other_errors=$((other_errors + 1))
    fi
    
    # Incrementar contador
    i=$((i + 1))
    
    # Esperar antes de la siguiente petición
    sleep $DELAY
done

# Tiempo de finalización
end_time=$(date +%s)
duration=$((end_time - start_time))

echo "\n=== Resultados de la prueba ==="
echo "Duración total: $duration segundos"
echo "Peticiones exitosas: $success"
echo "Peticiones bloqueadas por WAF: $blocked"
echo "Otros errores: $other_errors"

# Análisis de resultados
if [ $blocked -gt 0 ]; then
    echo "\nEl WAF está funcionando correctamente."
    echo "Se detectaron $blocked peticiones bloqueadas después de superar el límite de tasa."
    
    if [ $time_to_block -gt 0 ]; then
        requests_before_block=$((success + blocked + other_errors - (TOTAL_REQUESTS - i)))
        echo "Aproximadamente $requests_before_block peticiones antes del primer bloqueo."
        echo "Tiempo hasta el primer bloqueo: $time_to_block segundos."
    fi
else
    echo "\nNo se detectaron bloqueos por parte del WAF."
    echo "Posibles razones:"
    echo "  - El límite de tasa puede ser mayor a $TOTAL_REQUESTS peticiones"
    echo "  - La regla puede no estar aplicándose correctamente"
    echo "  - Las peticiones pueden estar siendo enviadas a un endpoint no protegido"
    echo "  - CloudFront puede estar cacheando las respuestas"
fi

echo "\nRecomendación: Verifica las métricas de WAF en CloudWatch para confirmar."

