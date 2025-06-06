docker run --rm \
    -e LANG=es_ES.UTF-8 \
    --name goaccess_cron_runner \
    --network proxiable \
    -v "/home/jose/servers/nginx/data/logs:/opt/log:ro" \
    -v "$GOACCESS_DIR/goaccess.conf:/etc/goaccess/goaccess.conf:ro" \
    -v "$GOACCESS_DIR/reports:/srv/report" \
    -v "$GOACCESS_DIR/generate-report.sh:/usr/local/bin/generate-report.sh:ro" \
    --entrypoint sh \
    allinurl/goaccess:latest \
    -c "/usr/local/bin/generate-report.sh" # Comando principal del contenedor para ejecutar el script


# Actualizar el archivo last_update.txt con la fecha y hora de la última generación del reporte
date +"Última actualización del reporte GoAccess: %Y-%m-%d %H:%M:%S %Z" > "$GOACCESS_DIR/reports/last_update.txt"

EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
    echo "Comando docker run para GoAccess finalizado. Salida del script interno:" >> "$LOG_FILE"

else
    echo "ERROR: Fallo en el comando docker run para GoAccess. Código de salida: $EXIT_CODE" >> "$LOG_FILE"
fi

echo "--- Fin ---" >> "$LOG_FILE"