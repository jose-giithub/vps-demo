#!/bin/bash

# Script para actualizar el servidor automáticamente
# Notifica por correo si hay errores o si se completa correctamente
# Rotación de logs, solo se guardan 7 días de logs

DESTINATARIO="ejemplo@gmail.com"
#Ruta del .msmtprc explícitamente, esto obliga a msmtp a usar tu configuración aunque el script lo ejecute root,
MSMTP_CONFIG="/home/tuUser/.msmtprc"
LOG_DIR="/home/tuUser/scripts/logs" # Ubicación de los archivos .log
FECHA_HOY=$(date +%F)  # formato: 2025-06-05
LOG_FILE="$LOG_DIR/actualizar_sistema_$FECHA_HOY.log"  # formato: del log actualizar_sistema_2025-06-05.log

# Asegurarse de que el directorio de logs existe ANTES de hacer el mkdir para el log del día
mkdir -p "$LOG_DIR"

# Limitar a los últimos 7 logs (los más recientes)
# Nota: La lógica de rotación debe ejecutarse ANTES de crear o escribir en el LOG_FILE del día actual
find "$LOG_DIR" -type f -name 'actualizar_sistema*.log' | sort | head -n -7 | xargs -r rm

# --- Iniciar la captura de la salida a un archivo de log y a la consola ---
# Todas las líneas siguientes se enviarán tanto al LOG_FILE como a la salida estándar
# `exec > >(tee -a "$LOG_FILE") 2>&1` redirige stdout y stderr al tee, que a su vez lo envía al archivo y a la consola.
# Esto debe ir al principio del script, después de definir LOG_FILE, para capturar toda la salida.
exec > >(tee -a "$LOG_FILE") 2>&1

echo "📦 Actualizando lista de paquetes..."
echo "🕒 Fecha de inicio: $(date)" # Muestra la fecha de inicio en el log y en la consola

if ! apt-get update; then
    echo "❌ ERROR: Fallo actualización (apt-get update)."
    # Envía el correo con el error, incluyendo el contenido del log hasta ese punto
    echo -e "Subject: ❌ ERROR: Fallo actualización (apt-get update)\n\nFalló la actualización de paquetes. Ver log adjunto." | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"
    exit 1
fi

echo "⬆️ Actualizando paquetes instalados..."
if ! apt-get upgrade -y; then
    echo "❌ ERROR: Fallo actualización (apt-get upgrade)."
    # Envía el correo con el error, incluyendo el contenido del log hasta ese punto
    echo -e "Subject: ❌ ERROR: Fallo actualización (apt-get upgrade)\n\nFalló la actualización de paquetes instalados. Ver log adjunto." | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"
    exit 1
fi

echo "🧹 Limpiando paquetes innecesarios..."
apt-get autoremove -y
apt-get autoclean

echo "---Fin de la actualización del sistema---"

# Notificación de éxito (esta notificación se envía por correo, el contenido de la salida de apt-get ya está en el log)
echo -e "Subject: ✅ Sistema actualizado\n\nEl sistema se actualizó correctamente el $(date)" | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"

exit 0 # Asegura una salida exitosa si todo va bien