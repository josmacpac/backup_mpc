#!/bin/bash

# ==========================================
# CONFIGURACIÓN DE RUTAS Y CREDENCIALES
# ==========================================
RESPALDO_DIR="$HOME/backups"
FECHA=$(date +%Y-%m-%d_%H%M%S)


# Ruta de la carpeta dentro de MEGA (Se creará en tu cuenta automáticamente)
MEGA_DIR="/Backups_MyPetCare"

# ==========================================
# AUTO-VERIFICACIÓN DE PAQUETES (Raspberry Pi / Debian)
# ==========================================
echo "Verificando dependencias en el sistema..."

# 1. Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "⚠️ Docker no está instalado. Instalándolo ahora..."
    sudo apt update && sudo apt install docker.io -y
    sudo systemctl enable --now docker
else
    echo "✅ Docker detectado."
fi

# 2. Verificar MEGAcmd
if ! command -v mega-put &> /dev/null; then
    echo "⚠️ MEGAcmd no está instalado. Instalándolo ahora..."
    sudo apt update && sudo apt install megacmd -y
else
    echo "✅ MEGAcmd detectado."
fi

echo "--------------------------------------------"

# ==========================================
# 1. CREACIÓN DEL RESPALDO LOCAL
# ==========================================
# Crear la carpeta de respaldos si no existe
mkdir -p $RESPALDO_DIR

echo "Iniciando respaldo de MyPetCare con Docker (Postgres 17)..."

# Correr pg_dump desde un contenedor oficial de Postgres 17
docker run --rm -i --network host postgres:17-alpine pg_dump "$URL_SUPABASE" > "$RESPALDO_DIR/mypetcare_$FECHA.sql"

# ==========================================
# 2. VALIDACIÓN Y SUBIDA A MEGA
# ==========================================
if [ $? -eq 0 ] && [ -s "$RESPALDO_DIR/mypetcare_$FECHA.sql" ]; then
    echo "¡Respaldo local creado con éxito! Guardado en: $RESPALDO_DIR/mypetcare_$FECHA.sql"
    
    # Verificar si el usuario ya inició sesión en MEGA localmente
    if ! mega-whoami &> /dev/null; then
        echo "❌ Error: MEGAcmd está instalado pero no has iniciado sesión."
        echo "Por favor, ejecuta en tu terminal: mega-login tu_correo tu_contraseña"
        echo "El respaldo local se mantendrá a salvo."
        exit 1
    fi

    echo "Conectando con MEGA y preparando subida..."
    # Asegurar que exista la carpeta en la nube
    mega-mkdir -p "$MEGA_DIR"
    # Subir el archivo .sql
    mega-put "$RESPALDO_DIR/mypetcare_$FECHA.sql" "$MEGA_DIR/"
    
    if [ $? -eq 0 ]; then
        echo "¡Copia de seguridad subida a MEGA correctamente!"
    else
        echo "⚠️ Alerta: El respaldo local se hizo, pero falló la subida a MEGA."
    fi

else
    echo "Hubo un error al realizar el respaldo o el archivo quedó vacío."
    # Limpiar archivo fallido si existe
    rm -f "$RESPALDO_DIR/mypetcare_$FECHA.sql"
fi

echo "--------------------------------------------"

# ==========================================
# 3. LIMPIEZA DE ARCHIVOS VIEJOS
# ==========================================
# Limpieza local: Borrar de la Raspberry respaldos de más de 7 días para ahorrar espacio
echo "Limpiando respaldos locales antiguos..."
find $RESPALDO_DIR -type f -name "*.sql" -mtime +7 -delete

# Limpieza en la nube: Borrar de MEGA los archivos de más de 30 días para no saturar los 20GB gratis
# Nota: Esta línea analiza tu carpeta de MEGA y remueve respaldos con más de un mes de antigüedad
# mega-find "$MEGA_DIR" -type f -mtime +30 -exec mega-rm {} \;

echo "¡Proceso terminado!"