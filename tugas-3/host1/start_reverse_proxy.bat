@echo off
title Reverse Proxy & Load Balancer (Host 1 - Port 80)
color 0B
echo ========================================================
echo   REVERSE PROXY & LOAD BALANCER (HOST 1 - PORT 80)
echo   Meneruskan lalu lintas ke 4 Backend Server di Host 2
echo ========================================================
echo.
set /p HOST2_IP="Masukkan Alamat IP Host 2 (contoh 192.168.1.20): "
if "%HOST2_IP%"=="" set HOST2_IP=127.0.0.1

echo.
echo Pilih mode eksekusi:
echo   [1] Python Native Reverse Proxy (Praktis, Tanpa Perlu Docker)
echo   [2] Nginx via Docker Compose
echo.
set /p PILIHAN="Pilihan [1/2] (Default: 1): "
if "%PILIHAN%"=="" set PILIHAN=1

if "%PILIHAN%"=="2" (
    echo.
    echo [*] Mengupdate target IP Host 2 di nginx\nginx.conf...
    powershell -Command "(Get-Content nginx\nginx.conf) -replace 'server .*?:5001', ('server ' + '%HOST2_IP%' + ':5001') -replace 'server .*?:5002', ('server ' + '%HOST2_IP%' + ':5002') -replace 'server .*?:5003', ('server ' + '%HOST2_IP%' + ':5003') -replace 'server .*?:5004', ('server ' + '%HOST2_IP%' + ':5004') | Set-Content nginx\nginx.conf"
    cd nginx
    docker compose up -d
    echo [*] Nginx Reverse Proxy aktif pada port 80!
    pause
) else (
    echo.
    echo [*] Menjalankan Python Native Reverse Proxy pada port 80...
    python reverse_proxy_native.py --port 80 --host2-ip %HOST2_IP%
    pause
)
