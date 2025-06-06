#!/bin/bash
# Script de limpieza y seguridad diaria 

BASE_DIR="/home/tuUser/scripts"
LOG_DIR="$BASE_DIR/logs"
FECHA_HOY=$(date +%F)
LOG_FILE="$LOG_DIR/limpieza_seguridad_diaria_$FECHA_HOY.log"

mkdir -p "$LOG_DIR"

# Mantener solo los últimos 7 logs
find "$LOG_DIR" -type f -name 'limpieza_seguridad_diaria*.log' | sort | head -n -7 | xargs -r rm

echo "🕒 Fecha: $(date)" > "$LOG_FILE"
echo "🔐 Iniciando escaneo de seguridad..." >> "$LOG_FILE"

# Actualizar RKHunter
echo "📥 Actualizando RKHunter..." >> "$LOG_FILE"
sudo rkhunter --update >> /dev/null 2>&1
sudo rkhunter --propupd -q

# Escanear con RKHunter
echo "🔎 Analizando con RKHunter..." >> "$LOG_FILE"
sudo rkhunter --check --sk --nocolors > /tmp/rkhunter_check.txt 2>&1
grep -E "Warning|Possible rootkits" /tmp/rkhunter_check.txt >> "$LOG_FILE" || echo "✔ Sin advertencias de RKHunter." >> "$LOG_FILE"

# Escanear con chkrootkit
echo "🔍 Ejecutando chkrootkit..." >> "$LOG_FILE"
sudo chkrootkit | grep -v "not found" | grep -v "not infected" >> "$LOG_FILE"

# Limpieza del sistema
echo "🧹 Limpiando sistema..." >> "$LOG_FILE"
sudo apt autoremove -y >> /dev/null
sudo apt autoclean >> /dev/null
sudo journalctl --vacuum-time=7d >> "$LOG_FILE"

echo "✅ Escaneo completado correctamente." >> "$LOG_FILE"