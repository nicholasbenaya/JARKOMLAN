@echo off
title Cluster Backend Server (Host 1)
color 0B
echo ========================================================
echo   CLUSTER BACKEND SERVER (HOST 1 - 4 ENVIRONMENT)
echo ========================================================
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0start_cluster.ps1"
pause
