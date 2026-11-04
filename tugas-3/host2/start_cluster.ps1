# ==============================================================================
# Script Startup Cluster 4 Backend Server Host 2 (JARKOMLAN Tugas 3)
# ==============================================================================

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  MEMULAI KLUSTER 4 BACKEND SERVER HOST 2                " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Tampilkan IP Host 2
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch "vEthernet|Loopback" -and $_.IPAddress -notmatch "^169\.254\." } | Select-Object -ExpandProperty IPAddress
Write-Host "`n[i] Alamat IP Host 2 yang terdeteksi di jaringan (Berikan IP ini ke Host 1):" -ForegroundColor Yellow
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
    Write-Host "      [!] Docker tidak aktif. Jalankan Docker Desktop atau jalankan server_node.py --port 5004 di jendela lain." -ForegroundColor Red
}

# 4. Injeksi Otomatis ke VirtualBox VM 1 dan VM 2
Write-Host "`n[3/3] Memeriksa dan Menjalankan Node 2 dan Node 3 di VirtualBox VM..." -ForegroundColor Yellow
$autoScript = Join-Path $PSScriptRoot "start_vms_automatically.ps1"
if (Test-Path $autoScript) {
    & $autoScript
} else {
    Write-Host "      - Di terminal VM 1 jalankan : sh server_vm.sh 5002 'Node 2 - Linux VM 1' '#22c55e'" -ForegroundColor Cyan
    Write-Host "      - Di terminal VM 2 jalankan : sh server_vm.sh 5003 'Node 3 - Linux VM 2' '#eab308'" -ForegroundColor Cyan
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host " Seluruh 4 Node Server di Host 2 Siap Menerima Beban!     " -ForegroundColor Green
Write-Host " Host 1 (Reverse Proxy) akan mendistribusikan traffic ke:  " -ForegroundColor Green
Write-Host " Port 5001, 5002, 5003, dan 5004                         " -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Green
