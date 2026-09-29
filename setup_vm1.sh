#!/bin/bash
# Script Konfigurasi IPv6 untuk VM 1 (Linux: Debian/Ubuntu)
# Alamat IPv6 ULA: fd00:db8:1::10/64

# Deteksi interface jaringan yang aktif selain 'lo'
IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v 'lo' | head -n 1)

if [ -z "$IFACE" ]; then
    echo "[!] Interface jaringan tidak ditemukan."
    exit 1
fi

echo "[*] Menggunakan interface: $IFACE"
echo "[*] Mengaktifkan interface..."
sudo ip link set "$IFACE" up

echo "[*] Memasang alamat IPv6 fd00:db8:1::10/64..."
sudo ip -6 addr add fd00:db8:1::10/64 dev "$IFACE" 2>/dev/null || echo "[i] Alamat mungkin sudah ada."

echo "[✓] Status Interface saat ini:"
ip -6 addr show "$IFACE"

echo ""
echo "[*] Untuk menguji ping ke VM 2, jalankan:"
echo "    ping -6 -c 4 fd00:db8:1::20"
