#!/bin/bash
# Script para limpieza y seguridad diaria (ejecutar como root)
# Guarda logs diarios, mantiene solo los últimos 7 días, y envía notificaciones inteligentes.

DESTINATARIO="ejemplo@gmail.com"
# Ruta del .msmtprc explícitamente, para que funcione con cron/root
MSMTP_CONFIG="/home/tuUSer/.msmtprc"
BASE_DIR="/home/tuUSer/scripts"
LOG_DIR="$BASE_DIR/logs"
FECHA_HOY=$(date +%F) # Ej: 2025-06-09
LOG_FILE="$LOG_DIR/limpieza_seguridad_diaria_$FECHA_HOY.log"

# --- INICIO DE LA EJECUCIÓN ---
# Verifico si msmtp está disponible y la ruta es correcta
if [ ! -x "$(command -v msmtp)" ]; then
    echo "❌ ERROR: El comando 'msmtp' no está instalado o no es ejecutable."
    exit 1
fi

S
# Asegura que existe el directorio de logs
mkdir -p "$LOG_DIR"

# Borra los logs más antiguos, dejando solo los últimos 7
find "$LOG_DIR" -type f -name 'limpieza_seguridad_diaria*.log' | sort | head -n -7 | xargs -r rm

# Captura todo lo que se imprime en el log Y en la consola
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🕒 Fecha de inicio: $(date)"
echo "🔐 Iniciando escaneo de seguridad..."

# --- ARCHIVOS TEMPORALES ---
# 1. Un único archivo para acumular TODAS las advertencias que encontremos.
WARNINGS_FILE=$(mktemp /tmp/security_warnings.XXXXXX)
# 2. Archivos temporales para logs de cada herramienta
RKHUNTER_LOG=$(mktemp /tmp/rkhunter_log.XXXXXX)
CHKROOTKIT_LOG=$(mktemp /tmp/chkrootkit_log.XXXXXX)

# ------------------ RKHUNTER -------------------
echo "📥 Actualizando RKHunter..."
# Simplificado: si falla, el error se registrará en el log principal gracias a 'tee'
if ! rkhunter --update > /dev/null 2>&1; then
    echo "❌ ERROR: Falló la actualización de RKHunter. Comprueba /var/log/rkhunter/rkhunter.log"
fi

echo "📦 Guardando propiedades actuales del sistema..."
if ! rkhunter --propupd -q; then
    echo "⚠️ ERROR: Falló guardar propiedades de archivos (propupd)"
fi

echo "🔎 Escaneando con RKHunter..."
rkhunter --check --sk --nocolors > "$RKHUNTER_LOG" 2>&1
# Mostramos las advertencias en el log principal para que queden registradas
grep -E "Warning|Possible rootkits" "$RKHUNTER_LOG" || echo "✔️ Sin advertencias de RKHunter."
# Y las añadimos a nuestro archivo centralizado de advertencias
grep -E "Warning|Possible rootkits" "$RKHUNTER_LOG" >> "$WARNINGS_FILE"

# ------------------ CHKROOTKIT -------------------
echo "🔍 Ejecutando chkrootkit..."
# Ejecutamos chkrootkit en modo silencioso para evitar los "not found/infected"
chkrootkit -q > "$CHKROOTKIT_LOG" 2>&1
# Mostramos el resultado en el log principal
cat "$CHKROOTKIT_LOG"
# Añadimos solo las líneas que contienen "WARNING" a nuestro archivo centralizado
grep "WARNING" "$CHKROOTKIT_LOG" >> "$WARNINGS_FILE"

# ------------------ LIMPIEZA -------------------
echo "🧹 Limpiando sistema (paquetes y cachés)..."
apt-get autoremove -y > /dev/null
apt-get autoclean -y > /dev/null

echo "🧹 Limpiando /tmp y /var/tmp (archivos con más de 7 días)..."
find /tmp -type f -atime +7 -delete
find /var/tmp -type f -atime +7 -delete

# ------------------ LOGS -------------------
echo "🧻 Borrando logs del sistema (más de 7 días)..."
journalctl --vacuum-time=7d

# ------------------ LÓGICA DE NOTIFICACIÓN -------------------
echo "📊 Analizando resultados para notificación..."

# 3. Patrón de expresiones regulares para ignorar todas las advertencias conocidas y seguras.
#    AÑADIMOS los encabezados de 'chkrootkit' y el resumen de 'rkhunter' para un silencio total.
IGNORE_PATTERN=$(cat <<'EOP'
\.gitignore
\.htaccess
\.htpasswd
\.document
\.build-id
PACKET SNIFFER
SSH root access
hidden files and directories
Possible rootkits: 0
WARNING: The following suspicious files and directories were found:
WARNING: Output from ifpromisc:
EOP
)

# 4. Filtramos el archivo de advertencias: buscamos cualquier advertencia y le quitamos las que conocemos.
#    El resultado solo contendrá advertencias NUEVAS o DESCONOCIDAS.
ADVERTENCIAS_REALES=$(grep -v -E "$IGNORE_PATTERN" "$WARNINGS_FILE")


# 5. Verificamos si, después de filtrar, queda alguna advertencia real.
if [ -n "$ADVERTENCIAS_REALES" ]; then
    # Si la variable NO está vacía, es que hay una advertencia real.
    echo "🚨 ¡ADVERTENCIA REAL DETECTADA! Enviando correo de alerta."
    (
        echo "Subject:⚠️ [Limpieza diaria del servidor] Se detectaron NUEVAS advertencias"
        echo
        echo "Revisa el log del día $FECHA_HOY. Se encontraron las siguientes advertencias no reconocidas:"
        echo "------------------------------------------------------------------"
        echo "$ADVERTENCIAS_REALES"
        echo "------------------------------------------------------------------"
        echo "Log completo en: $LOG_FILE"
    ) | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"
else
    # Si la variable está vacía, todo está en orden.
    echo "✔️ No se encontraron advertencias nuevas. Enviando correo de éxito."
    (
        echo "Subject: ✅ [Limpieza diaria del servidor] Limpieza de sistema realizada sin incidentes"
        echo
        echo "La limpieza y el escaneo de seguridad se llevaron a cabo satisfactoriamente el $FECHA_HOY."
        echo "Todas las advertencias detectadas fueron falsos positivos conocidos."
    ) | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"
fi


# ------------------ FINAL -------------------
echo "✅ Escaneo completado correctamente a las: $(date)"
echo "---Fin---"

# Elimina los archivos temporales
rm -f "$WARNINGS_FILE" "$RKHUNTER_LOG" "$CHKROOTKIT_LOG"

exit 0