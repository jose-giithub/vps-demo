# Script para actualizar el servidor automáticamente
# Notifica por correo si hay errores o si se completa correctamente
# Rotación de logs, solo se guardan 7 días de logs

DESTINATARIO="ejemplo@gmail.com"
MSMTP_CONFIG="/home/tuUser/.msmtprc"
LOG_DIR="/home/tuUser/scripts/logs"
FECHA_HOY=$(date +%F)
LOG_FILE="$LOG_DIR/actualizar_sistema_$FECHA_HOY.log"

# Crear directorio de logs
mkdir -p "$LOG_DIR"

# Mantener solo los últimos 7 logs
find "$LOG_DIR" -type f -name 'actualizar_sistema*.log' | sort | head -n -7 | xargs -r rm

# Capturar salida tanto en archivo como en consola
exec > >(tee -a "$LOG_FILE") 2>&1

echo "📦 Actualizando lista de paquetes..."
echo "🕒 Fecha de inicio: $(date)"

if ! apt update; then
    echo "❌ ERROR: Fallo actualización (apt update)."
    echo -e "Subject: ❌ ERROR: Fallo actualización (apt update)\n\nFalló la actualización de paquetes. Ver log adjunto." | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"
    exit 1
fi

echo "⬆️ Actualizando paquetes instalados..."
if ! apt upgrade -y; then
    echo "❌ ERROR: Fallo actualización (apt upgrade)."
    echo -e "Subject: ❌ ERROR: Fallo actualización (apt upgrade)\n\nFalló la actualización de paquetes instalados. Ver log adjunto." | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"
    exit 1
fi

echo "🧹 Limpiando paquetes innecesarios..."
apt autoremove -y
apt autoclean

echo "---Fin de la actualización del sistema---"

# Notificación de éxito
echo -e "Subject: ✅ Sistema actualizado\n\nEl sistema se actualizó correctamente el $(date)" | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"

echo "🔎 Resumen de advertencias (Warnings) del día:"
grep -i "Warning" "$LOG_FILE" | tail -n 5 || echo "✔ Sin advertencias importantes."

exit 0