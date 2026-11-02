@echo off
title Squid Caching Proxy (Host 1 - Port 3128)
color 0D
echo ========================================================
echo   SQUID CACHING PROXY SERVER (HOST 1 - PORT 3128)
echo ========================================================
echo.
cd squid
echo [*] Menjalankan Squid Proxy via Docker Container...
docker compose up -d
echo.
echo [*] Menampilkan log akses Squid real-time (TCP_HIT / TCP_MISS)...
echo     Tekan Ctrl+C untuk keluar dari log.
docker exec -it jarkom-squid-proxy tail -f /var/log/squid/access.log
pause
