#!/bin/sh
# Skrip Otomasi Deployment Web Server di VM Linux (Ubuntu/Debian & Alpine Linux)
# Menjalankan Flask Web Server untuk membaca database MySQL di Host 1

set -e

echo "============================================================"
echo "   JARKOMLAN: Setup Web Server di Guest VM Linux            "
echo "============================================================"

# 1. Deteksi Sistem Operasi & Pasang Paket Esensial
if command -v apt-get >/dev/null 2>&1; then
    echo "[*] Mendeteksi Debian/Ubuntu. Memperbarui apt dan memasang paket..."
    sudo apt-get update -y
    sudo apt-get install -y python3 python3-pip python3-venv curl
elif command -v apk >/dev/null 2>&1; then
    echo "[*] Mendeteksi Alpine Linux. Memasang paket via apk..."
    sudo apk update
    sudo apk add python3 py3-pip py3-virtualenv curl
else
    echo "[!] Distro Linux tidak didukung secara otomatis. Pastikan python3 dan pip terpasang."
fi

# 2. Setup Virtual Environment Python
CURRENT_DIR=$(pwd)
echo "[*] Direktori kerja: $CURRENT_DIR"

if [ ! -d ".venv" ]; then
    echo "[*] Membuat virtual environment Python (.venv)..."
    python3 -m venv .venv
fi

echo "[*] Mengaktifkan virtual environment & menginstal dependencies..."
# shellcheck disable=SC1091
. .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 3. Konfigurasi File .env
if [ ! -f ".env" ]; then
    echo ""
    echo "------------------------------------------------------------"
    echo "[?] Konfigurasi Alamat IP Windows Host 1 (Tempat MySQL Berada):"
    echo "    - Jika VM menggunakan mode Bridged Adapter: masukkan IP LAN Windows Host 1 (misal 192.168.1.10)"
    echo "    - Jika VM menggunakan mode NAT VirtualBox: gunakan gateway 10.0.2.2"
    echo "------------------------------------------------------------"
    printf "Masukkan IP Host 1 [Default: 192.168.1.10]: "
    read -r HOST_IP
    if [ -z "$HOST_IP" ]; then
        HOST_IP="192.168.1.10"
    fi

    cat <<EOF > .env
DB_HOST=$HOST_IP
DB_PORT=3306
DB_USER=jarkom
DB_PASSWORD=jarkom123
DB_NAME=jarkom_iot
PORT=8080
EOF
    echo "[✓] File .env berhasil dibuat dengan DB_HOST=$HOST_IP"
else
    echo "[i] File .env sudah ada, menggunakan konfigurasi yang ada."
fi

echo ""
echo "============================================================"
echo "[✓] Persiapan Selesai!"
echo "Untuk menjalankan Web Server sekarang, jalankan perintah:"
echo "    .venv/bin/python app.py"
echo ""
echo "Web server akan melayani di port 8080."
echo "============================================================"
