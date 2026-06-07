# 💾 Script de Backup Automatizado

Este proyecto consiste en un script automatizado para realizar copias de seguridad, empaquetar los datos y subirlos de forma segura a la nube de MEGA. Además, incluye la configuración para ejecutarse como un servicio del sistema mediante `systemd`.

---

## 🚀 Requisitos Previos & Dependencias

Antes de comenzar, asegúrate de tener instaladas las siguientes herramientas en tu sistema:

*   **Docker & Docker Compose** (en caso de que tu base de datos o servicios corran en contenedores).
*   **MEGA CMD** (La herramienta de línea de comandos de MEGA para la sincronización).
*   **Git** (para clonar el repositorio).

### Instalación de dependencias básicas (Ejemplo en Ubuntu/Debian):
```bash
# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker (si no lo tienes)
sudo apt install docker.io docker-compose -y

# Instalar MEGA CMD
# Nota: Descarga el paquete adecuado para tu distribución desde la página oficial de MEGA
wget [https://mega.nz/linux/repo/xUbuntu_22.04/amd64/megacmd-xUbuntu_22.04_amd64.deb](https://mega.nz/linux/repo/xUbuntu_22.04/amd64/megacmd-xUbuntu_22.04_amd64.deb)
sudo apt install ./megacmd-xUbuntu_22.04_amd64.deb -y


mega-login tu_correo@email.com tu_contraseña_segura

# Configuracion del servcio

sudo nano /etc/systemd/system/backup.service

[Unit]
Description=Servicio de Backup Automatizado
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/ruta/a/tu/proyecto
ExecStart=/bin/bash /ruta/a/tu/proyecto/backup.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target

# Habilitar el servicio 
# Recargar systemd para reconocer el nuevo servicio
sudo systemctl daemon-reload

# Iniciar el backup manualmente para probar que funcione
sudo systemctl start backup.service

# Habilitar para que inicie automáticamente
sudo systemctl enable backup.service

#asegurate que el scrit tenga permisos de ejecutcion 