@echo off
TITLE JARKOMLAN - Port Tunneling (Akses Online via Internet)
echo ============================================================
echo   JARKOMLAN: Membuka Port Tunneling ke Internet Publik
echo ============================================================
echo.
echo [1/2] Membuka Tunnel TCP untuk Broker MQTT (Port 1883)...
echo       Jendela ini akan menampilkan alamat Host & Port publik untuk Host 2.
echo.
start "MQTT Broker Tunnel (Port 1883)" cmd /k "ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=15 -p 443 -R0:127.0.0.1:1883 tcp@free.pinggy.io"

echo.
echo [2/2] Membuka Tunnel HTTPS untuk Web Server Dashboard (Port 8080)...
echo       Jendela ini akan menampilkan URL web publik untuk browser.
echo.
start "Web Dashboard Tunnel (Port 8080)" cmd /k "ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=15 -p 443 -R0:127.0.0.1:8080 free.pinggy.io"

echo ============================================================
echo   Tunnel berhasil diluncurkan di 2 jendela terpisah!
echo   Salin alamat publik yang muncul ke teman pemegang Host 2.
echo ============================================================
pause
