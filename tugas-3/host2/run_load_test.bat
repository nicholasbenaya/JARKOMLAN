@echo off
title Dummy Load Test Benchmark (Host 2)
color 0E
echo ========================================================
echo   UJI BEBAN DUMMY LOAD TEST KE REVERSE PROXY
echo ========================================================
echo.
set /p TARGET_URL="Target URL Reverse Proxy (Default: http://localhost/): "
if "%TARGET_URL%"=="" set TARGET_URL=http://localhost/

set /p NUM_REQ="Jumlah Permintaan (Default: 40): "
if "%NUM_REQ%"=="" set NUM_REQ=40

echo.
python test_dummy_requests.py --url %TARGET_URL% -n %NUM_REQ%
pause
