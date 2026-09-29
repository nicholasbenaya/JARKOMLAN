# LAPORAN TUGAS 1 - VIRTUALISASI & KOMUNIKASI JARINGAN IPv6
**Mata Kuliah:** Jaringan Komputer dan LAN (JARKOMLAN)  
**Topik:** Implementasi Komunikasi Antar Virtual Machine Berbasis Hypervisor Tipe 2 Menggunakan Protokol IPv6  

---

## IDENTITAS KELOMPOK
- **Kelompok:** [Isi Nomor/Nama Kelompok]
- **Anggota:**
  1. [Nama Anggota 1] - [NIM]
  2. [Nama Anggota 2] - [NIM]
  3. [Nama Anggota 3] - [NIM]
  4. [Nama Anggota 4] - [NIM]

---

## 1. PENDAHULUAN & LANDASAN TEORI

### 1.1 Konsep Virtualisasi
Virtualisasi merupakan teknologi abstraksi yang memisahkan perangkat keras fisik (*Hardware*) dari sistem operasi dan aplikasi yang berjalan di atasnya. Dalam konteks jaringan komputer, virtualisasi memungkinkan pembuatan beberapa komputer virtual (*Virtual Machine* / VM) di dalam satu komputer fisik tunggal (*Host*), di mana setiap VM memiliki sistem operasi *Guest* mandiri, CPU virtual (vCPU), RAM virtual, dan antarmuka jaringan virtual (vNIC).

### 1.2 Hypervisor Tipe 2 (Hosted Hypervisor)
Berdasarkan materi pada bab Perkembangan Teknologi Virtualisasi Modern, sistem virtualisasi terbagi menjadi dua:
- **Hypervisor Tipe 1 (Bare-Metal):** Berjalan langsung di atas perangkat keras fisik (contoh: Proxmox VE, VMware ESXi).
- **Hypervisor Tipe 2 (Hosted):** Berjalan sebagai aplikasi perangkat lunak di atas sistem operasi utama (*Host OS*).

Pada tugas praktikum ini digunakan **Oracle VirtualBox** sebagai Hypervisor Tipe 2 yang berjalan di atas Host OS Windows 11. Diagram arsitektur:
```
+-------------------------------------------------------------+
|   Guest OS 1 (VM 1)                 Guest OS 2 (VM 2)       |
|   (Alpine Linux 3.20)               (Alpine Linux 3.20)     |
+-------------------------------------------------------------+
|                     Virtual Machine Layer                   |
+-------------------------------------------------------------+
|             Hypervisor Tipe 2 (Oracle VirtualBox)           |
+-------------------------------------------------------------+
|                      Host OS (Windows 11)                   |
+-------------------------------------------------------------+
|                         Hardware                            |
|             (Intel Core Ultra 7 155H, 32 GB RAM)            |
+-------------------------------------------------------------+
```

### 1.3 Protokol Internet Versi 6 (IPv6)
IPv6 adalah protokol pengalamatan generasi baru berukuran 128-bit yang dirancang untuk mengatasi kehabisan alamat pada IPv4 (32-bit). Keunggulan utama IPv6 dalam praktikum ini:
- **Format Alamat:** 8 blok heksadesimal 16-bit (contoh: `fd00:db8:1::10/64`).
- **Unique Local Address (ULA - `fd00::/8`):** Rentang alamat privat yang diatur dalam RFC 4193 untuk komunikasi lokal dalam subnet terisolasi (padanan dari IPv4 Private IP `192.168.x.x`).
- **Neighbor Discovery Protocol (NDP):** Pengganti protokol ARP pada IPv4. NDP memanfaatkan pesan ICMPv6 *Neighbor Solicitation* (NS) dan *Neighbor Advertisement* (NA) menggunakan multicast (*Solicited-Node Multicast*), sehingga menghapus kebutuhan paket *broadcast* yang membebani jaringan.

---

## 2. METODOLOGI & TOPOLOGI PERANCANGAN

### 2.1 Topologi Jaringan Virtual
Kedua Virtual Machine dihubungkan menggunakan kartu jaringan virtual dengan mode **Internal Network** bernama `jarkom-v6`.

```
                    +-----------------------------+
                    | Virtual Switch: "jarkom-v6" |
                    +-----------------------------+
                            |             |
           +----------------+             +----------------+
           |                                               |
+-----------------------+                       +-----------------------+
|      VM1-Jarkom       |                       |      VM2-Jarkom       |
| Hostname: localhost   |                       | Hostname: localhost   |
| IPv6: fd00:db8:1::10  | <===================> | IPv6: fd00:db8:1::20  |
| Prefix: /64           |      ICMPv6 Ping      | Prefix: /64           |
| MAC: 08:00:27:DA:40:82|   (0% Packet Loss)    | MAC: 08:00:27:E7:03:A5|
+-----------------------+                       +-----------------------+
```

### 2.2 Tabel Pengalamatan Jaringan (Addressing Table)
| Parameter | Virtual Machine 1 (VM1) | Virtual Machine 2 (VM2) |
| :--- | :--- | :--- |
| **Nama Mesin (VM Name)** | `VM1-Jarkom` | `VM2-Jarkom` |
| **Sistem Operasi Guest** | Alpine Linux 3.20 (x86_64) | Alpine Linux 3.20 (x86_64) |
| **Interface Jaringan** | `eth0` | `eth0` |
| **Tipe Adapter Jaringan** | Internal Network (`jarkom-v6`) | Internal Network (`jarkom-v6`) |
| **MAC Address** | `08:00:27:DA:40:82` | `08:00:27:E7:03:A5` |
| **IPv6 ULA (Statis)** | `fd00:db8:1::10/64` | `fd00:db8:1::20/64` |
| **IPv6 Link-Local** | `fe80::a00:27ff:feda:4082/64` | `fe80::a00:27ff:fee7:3a5/64` |
| **Target Pengujian Ping** | `ping -6 -c 4 fd00:db8:1::20` | `ping -6 -c 4 fd00:db8:1::10` |

---

## 3. LANGKAH IMPLEMENTASI & KONFIGURASI

### 3.1 Pembuatan dan Konfigurasi VM di VirtualBox
1. Membuat dua Virtual Machine: `VM1-Jarkom` dan `VM2-Jarkom` dengan memori 1024 MB dan 2 vCPU.
2. Mengonfigurasi adapter jaringan kedua mesin ke mode **Internal Network** dengan nama yang identik: `jarkom-v6`.
3. Memasang image OS dan menyalakan kedua mesin virtual.

### 3.2 Konfigurasi Alamat IPv6
**Pada VM 1:**
```bash
ip link set eth0 up
ip -6 addr add fd00:db8:1::10/64 dev eth0
```

**Pada VM 2:**
```bash
ip link set eth0 up
ip -6 addr add fd00:db8:1::20/64 dev eth0
```

---

## 4. HASIL PENGUJIAN & ANALISIS

### 4.1 Uji Ping dari VM 1 ke VM 2 (`fd00:db8:1::20`)
Perintah yang dijalankan pada VM 1:
```bash
ping -6 -c 4 fd00:db8:1::20
```
**Hasil Output:**
```text
localhost:~# ping -6 -c 4 fd00:db8:1::20
PING fd00:db8:1::20 (fd00:db8:1::20): 56 data bytes
64 bytes from fd00:db8:1::20: seq=0 ttl=64 time=5.523 ms
64 bytes from fd00:db8:1::20: seq=1 ttl=64 time=2.250 ms
64 bytes from fd00:db8:1::20: seq=2 ttl=64 time=1.893 ms
64 bytes from fd00:db8:1::20: seq=3 ttl=64 time=1.711 ms

--- fd00:db8:1::20 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 1.711/2.844/5.523 ms
```
![Bukti Ping VM1 ke VM2](screenshots/bukti_ping_vm1_ke_vm2.png)

---

### 4.2 Uji Ping dari VM 2 ke VM 1 (`fd00:db8:1::10`)
Perintah yang dijalankan pada VM 2:
```bash
ping -6 -c 4 fd00:db8:1::10
```
**Hasil Output:**
```text
localhost:~# ping -6 -c 4 fd00:db8:1::10
PING fd00:db8:1::10 (fd00:db8:1::10): 56 data bytes
64 bytes from fd00:db8:1::10: seq=0 ttl=64 time=1.955 ms
64 bytes from fd00:db8:1::10: seq=1 ttl=64 time=1.638 ms
64 bytes from fd00:db8:1::10: seq=2 ttl=64 time=2.015 ms
64 bytes from fd00:db8:1::10: seq=3 ttl=64 time=1.344 ms

--- fd00:db8:1::10 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 1.344/1.738/2.015 ms
```
![Bukti Ping VM2 ke VM1](screenshots/bukti_ping_vm2_ke_vm1.png)

---

### 4.3 Verifikasi Neighbor Table (NDP Cache Layer 2)
Perintah yang dijalankan pada VM 1:
```bash
ip -6 neigh
```
**Hasil Output:**
```text
fd00:db8:1::20 dev eth0 lladdr 08:00:27:e7:03:a5 ref 1 used 0/0/0 probes 4 REACHABLE
fe80::a00:27ff:fee7:3a5 dev eth0 lladdr 08:00:27:e7:03:a5 ref 1 used 0/0/0 probes 0 DELAY
```

Perintah yang dijalankan pada VM 2:
```bash
ip -6 neigh
```
**Hasil Output:**
```text
fd00:db8:1::10 dev eth0 lladdr 08:00:27:da:40:82 ref 1 used 0/0/0 probes 1 REACHABLE
fe80::a00:27ff:feda:4082 dev eth0 lladdr 08:00:27:da:40:82 ref 1 used 0/0/0 probes 1 REACHABLE
```

### 4.4 Analisis Hasil
1. **Konektivitas Layer 3 (IPv6):** Pertukaran paket ICMPv6 Echo Request dan Echo Reply berlangsung lancar dengan **0% packet loss** dan rata-rata waktu tempuh (RTT) berkisar antara **1.7 ms - 2.8 ms**. Hal ini membuktikan bahwa Virtual Switch `jarkom-v6` pada VirtualBox berhasil merutekan paket IPv6 secara terisolasi dengan sempurna.
2. **Resolusi Alamat Layer 2 (NDP):** Tidak ada protokol ARP yang digunakan. Tabel Neighbor Discovery Protocol berhasil mencatat pemetaan alamat IPv6 target ke MAC Address virtual lawan dengan status `REACHABLE`.

---

## 5. KESIMPULAN
1. Hypervisor Tipe 2 (Oracle VirtualBox) berhasil memfasilitasi pembuatan dan komunikasi dua mesin virtual secara simultan di atas sistem operasi host tunggal.
2. Pemilihan mode jaringan *Internal Network* memberikan isolasi jaringan lokal yang stabil, mandiri, dan bebas dari interferensi jaringan luar.
3. Protokol IPv6 dengan skema pengalamatan *Unique Local Address* (ULA `fd00::/8`) dan resolusi tetangga berbasis *Neighbor Discovery Protocol* (NDP) telah terbukti berhasil diimplementasikan dengan konektivitas dua arah 100% reliabel.
