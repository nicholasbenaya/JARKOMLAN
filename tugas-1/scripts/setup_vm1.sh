#!/bin/sh
# Skrip Konfigurasi Alamat IPv6 untuk VM 1
# Alamat IPv6 ULA: fd00:db8:1::10/64

# Deteksi nama interface jaringan selain 'lo'
IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v 'lo' | head -n 1)

if [ -z "$IFACE" ]; then
    IFACE="eth0"
fi

echo "[*] Menggunakan interface: $IFACE"
echo "[*] Mengaktifkan interface..."
ip link set "$IFACE" up

echo "[*] Memasang alamat IPv6 fd00:db8:1::10/64..."
ip -6 addr add fd00:db8:1::10/64 dev "$IFACE" 2>/dev/null || echo "[i] Alamat sudah terpasang."

echo "[✓] Status Interface $IFACE:"
ip -6 addr show "$IFACE"

echo ""
echo "[*] Untuk menguji ping ke VM 2, jalankan:"
echo "    ping -c 4 fd00:db8:1::20"
