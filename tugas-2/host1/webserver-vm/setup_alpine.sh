#!/bin/sh
# Skrip Setup Otomatis Web Server di Alpine Linux VM (VirtualBox NAT)
set -e

echo "============================================================"
echo "   JARKOMLAN: Setup Web Server di Alpine Linux VM           "
echo "============================================================"

# 1. Konfigurasi repositori online Alpine resmi (v3.20)
echo "[*] Mengaktifkan repositori online Alpine Linux v3.20..."
cat <<EOF > /etc/apk/repositories
https://dl-cdn.alpinelinux.org/alpine/v3.20/main
https://dl-cdn.alpinelinux.org/alpine/v3.20/community
EOF

# 2. Update repositori & pasang python3 dan modul
echo "[*] Mengunduh & menginstal Python3, Flask, dan PyMySQL via APK..."
apk update
apk add python3 py3-flask py3-pymysql py3-dotenv curl

# 3. Buat direktori kerja
mkdir -p /root/webserver/templates
cd /root/webserver

# 4. Unduh berkas aplikasi dari server staging Windows Host (10.0.2.2:9999)
echo "[*] Mengunduh berkas app.py dan template dari Windows Host (10.0.2.2:9999)..."
curl -s http://10.0.2.2:9999/app.py -o app.py
curl -s http://10.0.2.2:9999/templates/index.html -o templates/index.html

# 5. Konfigurasi .env (di bawah NAT VirtualBox, IP Windows Host adalah 10.0.2.2)
cat <<EOF > .env
DB_HOST=10.0.2.2
DB_PORT=3306
DB_USER=jarkom
DB_PASSWORD=jarkom123
DB_NAME=jarkom_iot
PORT=8080
EOF

echo ""
echo "============================================================"
echo "[OK] Web Server siap dijalankan!"
echo "Target MySQL Database: 10.0.2.2:3306 (Docker Host 1)"
echo "Port Web Server VM: 8080"
echo "============================================================"
python3 app.py
