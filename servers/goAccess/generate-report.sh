# Script para generar reportes de GoAccess
# Optimizado para ser ejecutado por cron
echo "📦 Actualizando html lo GoAccess"
LOG_DIR="/opt/log"
REPORT_DIR="/srv/report"
CONFIG_FILE="/etc/goaccess/goaccess.conf"


# Crear directorio de reportes si no existe
mkdir -p "$REPORT_DIR/data"


# Función para generar reporte
generate_report() {
    echo "$(date): Generando reporte de GoAccess..."


    # Encontrar todos los archivos de log de proxy-host
    # Asegúrate de que esta ruta sea correcta dentro del contenedor
    LOG_FILES=$(find "$LOG_DIR" -name "proxy-host-*_access.log" -type f)


    if [ -z "$LOG_FILES" ]; then
        echo "$(date): No se encontraron archivos de log en $LOG_DIR"
        # Salir con un código de error para que cron lo detecte si no hay logs
        exit 1
    fi


    # Ejecutar GoAccess con los logs encontrados y la configuración
    # Ya no es necesario pasar todas las opciones aquí, ya que están en goaccess.conf
    goaccess $LOG_FILES --config-file="$CONFIG_FILE"


    if [ $? -eq 0 ]; then
        echo "$(date): Reporte generado exitosamente en $REPORT_DIR/index.html"
        # Actualizar timestamp del último reporte
        echo "$(date)" > "$REPORT_DIR/last_update.txt"
    else
        echo "$(date): Error al generar el reporte de GoAccess. Revisar logs."
        exit 1 # Salir con un código de error
    fi
}


# Ejecutar la función principal
generate_report
echo "✅ Html actualizado correctamente"