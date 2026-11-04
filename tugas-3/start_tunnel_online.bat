@echo off
TITLE JARKOMLAN Tugas 3 - Port Tunneling Online (Pinggy)
color 0B

:: Pastikan SSH Key sudah ada (Pinggy login gratis via SSH Key, bukan password)
if not exist "%USERPROFILE%\.ssh" mkdir "%USERPROFILE%\.ssh" >nul 2>&1
if not exist "%USERPROFILE%\.ssh\id_ed25519" if not exist "%USERPROFILE%\.ssh\id_rsa" (
    echo [i] Membuat SSH key gratis untuk Pinggy (tanpa password)...
    ssh-keygen -t ed25519 -N "" -f "%USERPROFILE%\.ssh\id_ed25519" -q >nul 2>&1
    echo [OK] SSH key berhasil disiapkan.
    echo.
)

echo ============================================================
echo   JARKOMLAN TUGAS 3: MEMBUKA AKSES ONLINE VIA INTERNET
echo ============================================================
echo.
echo Layanan ini memungkinkan pengujian Tugas 3 dari mana saja:
echo - Dari HP menggunakan paket data seluler (4G/5G).
echo - Dari laptop teman yang berada di rumah/lokasi berbeda.
echo - Langsung dibagikan ke Dosen/Asisten Lab saat demo daring.
echo.
echo Pilih layanan yang ingin dibuka ke internet publik:
echo   [1] Reverse Proxy & Load Balancer (Port 80) --^> URL Publik HTTPS
echo   [2] Squid Caching Proxy (Port 3128)         --^> Host & Port TCP Publik
echo   [3] Origin Web Server (Port 8080)           --^> URL Publik HTTPS
echo   [4] Buka Semua Tunnel Sekaligus (Port 80, 3128, & 8080)
echo.
set /p PILIHAN="Masukkan pilihan [1-4] (Default: 1): "
if "%PILIHAN%"=="" set PILIHAN=1

if "%PILIHAN%"=="1" goto tunnel_reverse_proxy
if "%PILIHAN%"=="2" goto tunnel_squid
if "%PILIHAN%"=="3" goto tunnel_origin
if "%PILIHAN%"=="4" goto tunnel_all

:tunnel_reverse_proxy
echo.
echo [*] Membuka Tunnel HTTPS untuk Reverse Proxy (Port 80)...
echo     Jendela baru akan menampilkan link HTTPS publik (contoh: https://xxxx.free.pinggy.link).
echo.
start "Reverse Proxy Online Tunnel (Port 80)" cmd /k "ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=15 -p 443 -R0:127.0.0.1:80 free.pinggy.io"
goto selesai

:tunnel_squid
echo.
echo [*] Membuka Tunnel TCP untuk Squid Proxy (Port 3128)...
echo     Jendela baru akan menampilkan Host & Port TCP publik (contoh: tcp.pinggy.io:49152).
echo.
start "Squid Proxy Online Tunnel (Port 3128)" cmd /k "ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=15 -p 443 -R0:127.0.0.1:3128 tcp@free.pinggy.io"
goto selesai

:tunnel_origin
echo.
echo [*] Membuka Tunnel HTTPS untuk Origin Web Server (Port 8080)...
echo     Jendela baru akan menampilkan link HTTPS publik untuk server sumber cache.
echo.
start "Origin Web Server Tunnel (Port 8080)" cmd /k "ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=15 -p 443 -R0:127.0.0.1:8080 free.pinggy.io"
goto selesai

:tunnel_all
echo.
echo [*] Membuka semua tunnel ke internet publik di jendela terpisah...
start "Reverse Proxy Online Tunnel (Port 80)" cmd /k "ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=15 -p 443 -R0:127.0.0.1:80 free.pinggy.io"
start "Squid Proxy Online Tunnel (Port 3128)" cmd /k "ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=15 -p 443 -R0:127.0.0.1:3128 tcp@free.pinggy.io"
start "Origin Web Server Tunnel (Port 8080)" cmd /k "ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=15 -p 443 -R0:127.0.0.1:8080 free.pinggy.io"
goto selesai

:selesai
echo.
echo ============================================================
echo   Tunnel berhasil diluncurkan!
echo   Biarkan jendela tunnel CMD yang muncul tetap TERBUKA.
echo   Salin URL / Host & Port yang muncul ke HP atau teman Anda.
echo ============================================================
pause
