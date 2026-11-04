# ==============================================================================
# Script Startup Cluster Node & Reverse Proxy Host 1 (JARKOMLAN Tugas 3 - Model A)
# ==============================================================================

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  MEMULAI CLUSTER BACKEND & PROXY HOST 1 (MODEL A)       " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Tampilkan IP Host 1
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch "vEthernet|Loopback" -and $_.IPAddress -notmatch "^169\.254\." } | Select-Object -ExpandProperty IPAddress
Write-Host "`n[i] Alamat IP Host 1 yang terdeteksi di jaringan:" -ForegroundColor Yellow
foreach ($ip in $ipAddresses) {
    Write-Host "    - $ip" -ForegroundColor Green
}

# 2. Jalankan Node 1 (Windows Native) di jendela terpisah
Write-Host "`n[1/4] Menjalankan Node 1 (Windows Native di Port 5001)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "python server_node.py --port 5001 --name 'Node 1 - Windows Native' --platform 'Windows 11 Native' --color '#38bdf8'"

# 3. Jalankan Node 4 (Docker Container)
Write-Host "[2/4] Menjalankan Node 4 (Docker Container di Port 5004)..." -ForegroundColor Yellow
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Set-Location "$PSScriptRoot\docker"
    docker compose up -d --build
    Set-Location $PSScriptRoot
    Write-Host "      -> Node 4 Docker berhasil aktif di port 5004!" -ForegroundColor Green
} else {
    Write-Host "      [!] Docker tidak aktif. Jalankan Docker Desktop atau jalankan server_node.py --port 5004." -ForegroundColor Red
}

# 4. Jalankan Reverse Proxy (Port 80) di jendela terpisah
Write-Host "[3/4] Menjalankan Reverse Proxy & Load Balancer di Port 80..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "python reverse_proxy_native.py --port 80"
Write-Host "      -> Reverse Proxy aktif mendengarkan di http://0.0.0.0:80" -ForegroundColor Green

# 5. Petunjuk untuk VM 1 dan VM 2
Write-Host "`n[4/4] Petunjuk Menjalankan Node 2 dan Node 3 di VirtualBox:" -ForegroundColor Yellow
Write-Host "      Pastikan kedua VM sudah berjalan di VirtualBox." -ForegroundColor White
Write-Host "      - Di VM 1 jalankan : sh server_vm.sh 5002 'Node 2 - Linux VM 1' '#22c55e'" -ForegroundColor Cyan
Write-Host "      - Di VM 2 jalankan : sh server_vm.sh 5003 'Node 3 - Linux VM 2' '#eab308'" -ForegroundColor Cyan

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host " Host 1 siap menerima request dari HP atau Host 2!        " -ForegroundColor Green
Write-Host " Akses via Browser : http://localhost/ atau http://<IP>/   " -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Green
