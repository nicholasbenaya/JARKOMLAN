# Tugas Virtualisasi & Komunikasi Jaringan IPv6 (JARKOMLAN)

Repository ini berisi implementasi dan dokumentasi tugas praktikum Jaringan Komputer dan LAN (JARKOMLAN) mengenai **Virtualisasi Antar Mesin Virtual (Hypervisor Tipe 2) Menggunakan Protokol IPv6**.

## 📌 Ringkasan Implementasi
- **Hypervisor:** Oracle VirtualBox 7.2 (Hypervisor Tipe 2 / Hosted)
- **Guest OS:** Alpine Linux Virtual 3.20 (x86_64)
- **Mode Jaringan:** VirtualBox Internal Network (`jarkom-v6`)
- **Protokol:** IPv6 (ICMPv6 Echo Request / Reply)
- **Resolusi Layer 2:** Neighbor Discovery Protocol (NDP)

## 🌐 Alokasi Pengalamatan IPv6 (Unique Local Address - ULA)
| Node | Hostname | Interface | IPv6 ULA (Statis) | MAC Address |
| :--- | :--- | :--- | :--- | :--- |
| **VM 1** | `localhost` | `eth0` | `fd00:db8:1::10/64` | `08:00:27:DA:40:82` |
| **VM 2** | `localhost` | `eth0` | `fd00:db8:1::20/64` | `08:00:27:E7:03:A5` |

## 🚀 Hasil Pengujian Ping
- **VM 1 $\rightarrow$ VM 2 (`fd00:db8:1::20`):** `4 packets transmitted, 4 received, 0% packet loss` (RTT min/avg/max = 1.711 / 2.844 / 5.523 ms)
- **VM 2 $\rightarrow$ VM 1 (`fd00:db8:1::10`):** `4 packets transmitted, 4 received, 0% packet loss` (RTT min/avg/max = 1.344 / 1.738 / 2.015 ms)
- **NDP Cache:** Berhasil memetakan MAC address virtual lawan dengan status `REACHABLE`.

## 📁 Struktur Direktori
- `LAPORAN_TUGAS_1_JARKOMLAN.md`: Laporan resmi lengkap untuk tugas kelompok 4 orang.
- `PANDUAN_PRAKTIKUM_DAN_DEMO.md`: Panduan teknis dan materi tanya-jawab demo dosen.
- `screenshots/`: Tangkapan layar bukti pengujian ping dua arah dan tabel NDP.
- `setup_vm1.sh` & `setup_vm2.sh`: Skrip konfigurasi antarmuka IPv6 Linux.
- `setup_vm1.ps1` & `setup_vm2.ps1`: Skrip konfigurasi antarmuka IPv6 Windows.
