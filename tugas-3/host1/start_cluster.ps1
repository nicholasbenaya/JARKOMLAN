# ==============================================================================
# Script Startup Cluster Node Host 1 (JARKOMLAN Tugas 3)
# ==============================================================================

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  MEMULAI CLUSTER BACKEND HOST 1 (JARKOMLAN TUGAS 3)     " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Tampilkan IP Host 1
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch "vEthernet|Loopback" -and $_.IPAddress -notmatch "^169\.254\." } | Select-Object -ExpandProperty IPAddress
Write-Host "`n[i] Alamat IP Host 1 yang terdeteksi di jaringan:" -ForegroundColor Yellow
foreach ($ip in $ipAddresses) {
    Write-Host "    - $ip" -ForegroundColor Green
}

# 2. Jalankan Node 1 (Windows Native) di jendela terpisah
Write-Host "`n[1/3] Menjalankan Node 1 (Windows Native di Port 5001)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "python server_node.py --port 5001 --name 'Node 1 - Windows Native' --platform 'Windows 11 Native' --color '#38bdf8'"

# 3. Jalankan Node 4 (Docker Container)
Write-Host "[2/3] Menjalankan Node 4 (Docker Container di Port 5004)..." -ForegroundColor Yellow
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Set-Location "$PSScriptRoot\docker"
    docker compose up -d --build
    Set-Location $PSScriptRoot
    Write-Host "      -> Node 4 Docker berhasil aktif di port 5004!" -ForegroundColor Green
} else {
    Write-Host "      [!] Docker tidak ditemukan, jalankan secara manual atau gunakan server_node.py port 5004." -ForegroundColor Red
}

# 4. Petunjuk untuk VM 1 dan VM 2
Write-Host "`n[3/3] Petunjuk Menjalankan Node 2 dan Node 3 di VirtualBox:" -ForegroundColor Yellow
Write-Host "      Pastikan Port Forwarding di VirtualBox diaktifkan:" -ForegroundColor White
Write-Host "      - VM 1: Host Port 5002 -> Guest Port 5002" -ForegroundColor Gray
Write-Host "      - VM 2: Host Port 5003 -> Guest Port 5003" -ForegroundColor Gray
Write-Host "      Di dalam terminal VM 1, jalankan:" -ForegroundColor White
Write-Host "      python3 server_node.py --port 5002 --name 'Node 2 - Linux VM 1' --platform 'VirtualBox Alpine/Ubuntu' --color '#22c55e'" -ForegroundColor Cyan
Write-Host "      Di dalam terminal VM 2, jalankan:" -ForegroundColor White
Write-Host "      python3 server_node.py --port 5003 --name 'Node 3 - Linux VM 2' --platform 'VirtualBox Alpine/Ubuntu' --color '#eab308'" -ForegroundColor Cyan

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host " Cluster Host 1 siap dihubungkan ke Reverse Proxy (Host 2)!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
