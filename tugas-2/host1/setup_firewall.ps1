# PowerShell Script untuk Membuka Port Inbound di Windows Firewall (Host 1)
# Wajib dijalankan dengan hak akses "Run as Administrator" di Host 1 Windows

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   JARKOMLAN: Konfigurasi Windows Firewall untuk Host 1     " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# 1. Port 1883 (MQTT Broker Mosquitto)
Write-Host "[*] Membuka port TCP 1883 (MQTT Broker Mosquitto)..." -ForegroundColor Yellow
New-NetFirewallRule -DisplayName "JARKOMLAN - MQTT Broker (Port 1883)" `
    -Direction Inbound `
    -LocalPort 1883 `
    -Protocol TCP `
    -Action Allow `
    -Profile Any `
    -ErrorAction SilentlyContinue

# 2. Port 3306 (MySQL Database Server)
Write-Host "[*] Membuka port TCP 3306 (MySQL Server untuk VM Linux)..." -ForegroundColor Yellow
New-NetFirewallRule -DisplayName "JARKOMLAN - MySQL Server (Port 3306)" `
    -Direction Inbound `
    -LocalPort 3306 `
    -Protocol TCP `
    -Action Allow `
    -Profile Any `
    -ErrorAction SilentlyContinue

# 3. Port 8080 / 80 (Jika Web Server di-forward ke Host Windows)
Write-Host "[*] Membuka port TCP 8080 (Web Server Dashboard)..." -ForegroundColor Yellow
New-NetFirewallRule -DisplayName "JARKOMLAN - Web Server (Port 8080)" `
    -Direction Inbound `
    -LocalPort 8080 `
    -Protocol TCP `
    -Action Allow `
    -Profile Any `
    -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "[OK] Konfigurasi Firewall Selesai! Port 1883, 3306, dan 8080 siap menerima koneksi LAN." -ForegroundColor Green
