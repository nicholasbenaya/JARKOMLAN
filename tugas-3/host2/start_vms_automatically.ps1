# ==============================================================================
# Script Otomatisasi Injeksi Server Node ke VirtualBox VM (Host 2)
# Menjalankan server_vm.sh di VM1-Jarkom (:5002) dan VM2-Jarkom (:5003) secara otomatis
# ==============================================================================

$vboxPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
if (-not (Test-Path $vboxPath)) {
    Write-Host "[!] VBoxManage.exe tidak ditemukan di $vboxPath" -ForegroundColor Red
    exit 1
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  AUTO-INJECT & START NODE SERVER KE VIRTUALBOX VM       " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Cek VM yang sedang berjalan
$running = & $vboxPath list runningvms
$vm1Running = $running -match "VM1-Jarkom"
$vm2Running = $running -match "VM2-Jarkom"

if (-not $vm1Running) {
    Write-Host "[!] VM1-Jarkom tidak sedang berjalan. Menyalakan headless..." -ForegroundColor Yellow
    & $vboxPath startvm "VM1-Jarkom" --type headless
    Start-Sleep -Seconds 5
}
if (-not $vm2Running) {
    Write-Host "[!] VM2-Jarkom tidak sedang berjalan. Menyalakan headless..." -ForegroundColor Yellow
    & $vboxPath startvm "VM2-Jarkom" --type headless
    Start-Sleep -Seconds 5
}

# 1. Jalankan Node 2 di VM1-Jarkom
Write-Host "`n[1/2] Mengaktifkan Node 2 di VM1-Jarkom (Port 5002)..." -ForegroundColor Yellow
& $vboxPath controlvm "VM1-Jarkom" keyboardputscancode 1d 2e ae 9d # Ctrl+C
Start-Sleep -Milliseconds 300
& $vboxPath controlvm "VM1-Jarkom" keyboardputscancode 1c 9c
Start-Sleep -Milliseconds 300
& $vboxPath controlvm "VM1-Jarkom" keyboardputstring "ifconfig eth0 10.0.2.15 netmask 255.255.255.0 up && route add default gw 10.0.2.2"
Start-Sleep -Milliseconds 300
& $vboxPath controlvm "VM1-Jarkom" keyboardputscancode 1c 9c
Start-Sleep -Milliseconds 500
& $vboxPath controlvm "VM1-Jarkom" keyboardputstring "sh server_vm.sh 5002 'Node 2 - Linux VM 1' '#22c55e'"
Start-Sleep -Milliseconds 300
& $vboxPath controlvm "VM1-Jarkom" keyboardputscancode 1c 9c

# 2. Jalankan Node 3 di VM2-Jarkom
Write-Host "[2/2] Mengaktifkan Node 3 di VM2-Jarkom (Port 5003)..." -ForegroundColor Yellow
& $vboxPath controlvm "VM2-Jarkom" keyboardputscancode 1d 2e ae 9d # Ctrl+C
Start-Sleep -Milliseconds 300
& $vboxPath controlvm "VM2-Jarkom" keyboardputscancode 1c 9c
Start-Sleep -Milliseconds 300
& $vboxPath controlvm "VM2-Jarkom" keyboardputstring "ifconfig eth0 10.0.2.15 netmask 255.255.255.0 up && route add default gw 10.0.2.2"
Start-Sleep -Milliseconds 300
& $vboxPath controlvm "VM2-Jarkom" keyboardputscancode 1c 9c
Start-Sleep -Milliseconds 500
& $vboxPath controlvm "VM2-Jarkom" keyboardputstring "sh server_vm.sh 5003 'Node 3 - Linux VM 2' '#eab308'"
Start-Sleep -Milliseconds 300
& $vboxPath controlvm "VM2-Jarkom" keyboardputscancode 1c 9c

Write-Host "`nMenunggu 2 detik untuk inisialisasi server..." -ForegroundColor Gray
Start-Sleep -Seconds 2

# Verifikasi koneksi HTTP
Write-Host "`n=== HASIL VERIFIKASI KONEKSI DARI HOST ===" -ForegroundColor Cyan
try {
    $res1 = Invoke-RestMethod -Uri "http://localhost:5002/api" -TimeoutSec 3 -ErrorAction Stop
    Write-Host " [OK] VM1 (Port 5002): $($res1.node_name) [$($res1.node_platform)] - Hits: $($res1.hit_count)" -ForegroundColor Green
} catch {
    Write-Host " [GAGAL] VM1 (Port 5002) belum merespons HTTP!" -ForegroundColor Red
}

try {
    $res2 = Invoke-RestMethod -Uri "http://localhost:5003/api" -TimeoutSec 3 -ErrorAction Stop
    Write-Host " [OK] VM2 (Port 5003): $($res2.node_name) [$($res2.node_platform)] - Hits: $($res2.hit_count)" -ForegroundColor Green
} catch {
    Write-Host " [GAGAL] VM2 (Port 5003) belum merespons HTTP!" -ForegroundColor Red
}

Write-Host "==========================================================" -ForegroundColor Cyan
