# PowerShell Script Konfigurasi IPv6 untuk VM 1 (Windows Guest)
# Jalankan PowerShell sebagai Administrator

$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1

if (-not $adapter) {
    Write-Host "[!] Tidak ada adapter jaringan aktif." -ForegroundColor Red
    exit
}

Write-Host "[*] Menggunakan adapter: $($adapter.Name)" -ForegroundColor Cyan
New-NetIPAddress -InterfaceAlias $adapter.Name -IPAddress "fd00:db8:1::10" -PrefixLength 64 -AddressFamily IPv6 -ErrorAction SilentlyContinue

Write-Host "[*] Membuka firewall untuk ICMPv6 (Ping)..." -ForegroundColor Cyan
New-NetFirewallRule -DisplayName "Allow ICMPv6-In" -Direction Inbound -Protocol ICMPv6 -IcmpType 128 -Action Allow -ErrorAction SilentlyContinue

Write-Host "[✓] Konfigurasi VM 1 Selesai!" -ForegroundColor Green
Get-NetIPAddress -InterfaceAlias $adapter.Name -AddressFamily IPv6 | Format-Table IPAddress, PrefixLength
