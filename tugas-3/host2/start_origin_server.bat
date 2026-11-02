@echo off
title Origin Web Server (Host 2 - Port 8080)
color 0A
echo ========================================================
echo   ORIGIN WEB SERVER (HOST 2) UNTUK CACHED PROXY SQUID
echo ========================================================
echo.
cd origin_web
python origin_server.py
pause
