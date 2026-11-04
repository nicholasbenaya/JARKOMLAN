@echo off
title Reverse Proxy & Load Balancer (Host 1 - Port 80)
color 0B
echo ========================================================
echo   REVERSE PROXY & LOAD BALANCER (HOST 1 - PORT 80)
echo ========================================================
echo.
echo Pilih mode eksekusi:
echo   [1] Python Native Reverse Proxy (Praktis, Tanpa Perlu Docker)
echo   [2] Nginx via Docker Compose
echo.
set /p PILIHAN="Pilihan [1/2] (Default: 1): "
if "%PILIHAN%"=="" set PILIHAN=1

if "%PILIHAN%"=="2" (
    cd nginx
    docker compose up -d
    echo [*] Nginx Reverse Proxy aktif pada port 80!
    pause
) else (
    echo.
    echo [*] Menjalankan Python Native Reverse Proxy pada port 80...
    python reverse_proxy_native.py --port 80
    pause
)
