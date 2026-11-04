@echo off
title Dummy Load Test Benchmark (Host 2 -> Host 1)
color 0E
echo ========================================================
echo   UJI BEBAN DUMMY LOAD TEST DARI HOST 2 KE HOST 1
echo ========================================================
echo.
echo Masukkan Alamat IP Host 1 atau URL Publik:
echo   - Jika jaringan lokal LAN : 192.168.x.x
echo   - Jika via tunnel online  : https://xxxx.free.pinggy.link
echo.
set /p TARGET_INPUT="Target (Default: 127.0.0.1): "
if "%TARGET_INPUT%"=="" set TARGET_INPUT=127.0.0.1

:: Format URL jika pengguna hanya mengetik IP
echo %TARGET_INPUT% | findstr /i "^http" >nul
if %errorlevel%==0 (
    set TARGET_URL=%TARGET_INPUT%
) else (
    set TARGET_URL=http://%TARGET_INPUT%/
)

set /p NUM_REQ="Jumlah Permintaan (Default: 40): "
if "%NUM_REQ%"=="" set NUM_REQ=40

echo.
echo [*] Mengirim %NUM_REQ% permintaan ke %TARGET_URL%...
python test_dummy_requests.py --url %TARGET_URL% -n %NUM_REQ%
pause
