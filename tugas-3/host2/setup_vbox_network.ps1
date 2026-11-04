# ==============================================================================
# Script Otomasi Konfigurasi Port Forwarding VirtualBox Host 1
# Mengatur VM1-Jarkom (Node 2: Port 5002) dan VM2-Jarkom (Node 3: Port 5003)
# ==============================================================================

$vboxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

if (-not (Test-Path $vboxManage)) {
    Write-Host "[!] VBoxManage.exe tidak ditemukan di lokasi standar!" -ForegroundColor Red
    Write-Host "    Silakan pastikan Oracle VirtualBox terinstal." -ForegroundColor Yellow
    exit 1
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  MENGONFIGURASI JARINGAN VIRTUALBOX HOST 1              " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Konfigurasi VM1-Jarkom
Write-Host "`n[1/2] Memeriksa VM1-Jarkom..." -ForegroundColor Yellow
try {
    # Pastikan nic1 adalah NAT
    & $vboxManage modifyvm "VM1-Jarkom" --nic1 nat
    # Hapus rule lama jika ada agar tidak duplikat
    & $vboxManage modifyvm "VM1-Jarkom" --natpf1 delete "node2_http" 2>$null
    # Tambahkan rule port forwarding Host 5002 -> Guest 5002
    & $vboxManage modifyvm "VM1-Jarkom" --natpf1 "node2_http,tcp,,5002,,5002"
    Write-Host "      -> Berhasil! Port Forwarding VM1-Jarkom: Host 5002 -> Guest 5002" -ForegroundColor Green
} catch {
    Write-Host "      [!] Gagal mengonfigurasi VM1-Jarkom: $_" -ForegroundColor Red
}

# 2. Konfigurasi VM2-Jarkom
Write-Host "`n[2/2] Memeriksa VM2-Jarkom..." -ForegroundColor Yellow
try {
    # Ubah nic1 dari intnet ke NAT
    & $vboxManage modifyvm "VM2-Jarkom" --nic1 nat
    # Hapus rule lama jika ada
    & $vboxManage modifyvm "VM2-Jarkom" --natpf1 delete "node3_http" 2>$null
    & $vboxManage modifyvm "VM2-Jarkom" --natpf1 delete "ssh" 2>$null
    # Tambahkan rule port forwarding Host 5003 -> Guest 5003 & SSH 2223
    & $vboxManage modifyvm "VM2-Jarkom" --natpf1 "node3_http,tcp,,5003,,5003"
    & $vboxManage modifyvm "VM2-Jarkom" --natpf1 "ssh,tcp,,2223,,22"
    Write-Host "      -> Berhasil! Port Forwarding VM2-Jarkom: Host 5003 -> Guest 5003" -ForegroundColor Green
} catch {
    Write-Host "      [!] Gagal mengonfigurasi VM2-Jarkom: $_" -ForegroundColor Red
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host " Konfigurasi VirtualBox selesai!                         " -ForegroundColor Green
Write-Host " Kedua VM siap menerima koneksi dari Host 1 pada:        " -ForegroundColor Green
Write-Host " - VM 1: http://localhost:5002                           " -ForegroundColor White
Write-Host " - VM 2: http://localhost:5003                           " -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Green
