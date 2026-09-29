# PANDUAN LENGKAP TUGAS VIRTUALISASI & KOMUNIKASI ANTAR-VM (IPv6)
**Mata Kuliah:** Jaringan Komputer & LAN (JARKOMLAN)  
**Tugas 1:** Komunikasi Antar Virtual Machine Menggunakan IPv6  
**Format Kelompok:** 4 Orang  

---

## 1. Konsep Dasar & Teori Virtualisasi

### A. Apa itu Virtualisasi?
Virtualisasi adalah teknologi yang memungkinkan kita membuat representasi virtual (berbasis perangkat lunak) dari perangkat keras fisik, seperti server, sistem operasi, media penyimpanan, atau jaringan. Dengan virtualisasi, sebuah komputer fisik (*Host*) dapat menjalankan beberapa sistem operasi (*Guest OS*) secara independen dan terisolasi dalam satu waktu.

### B. Arsitektur Hypervisor Tipe 2 (Hosted Hypervisor)
Sesuai dengan modul praktikum:
```text
+-------------------------------------------------------+
|  [Guest OS 1 (VM 1)]        [Guest OS 2 (VM 2)]       |
|  (Linux/Ubuntu/Debian)      (Linux/Ubuntu/Debian)     |
+-------------------------------------------------------+
|                 Virtual Machine Layer                 |
+-------------------------------------------------------+
|     Hypervisor (Tipe 2: VirtualBox / VMware Workstation) |
+-------------------------------------------------------+
|            Host OS (Windows 10/11 / macOS / Linux)     |
+-------------------------------------------------------+
|                    Hardware Fisik                     |
|           (CPU, RAM, Harddisk, Network Card)          |
+-------------------------------------------------------+
```

**Karakteristik Hypervisor Tipe 2:**
1. **Berjalan di atas Host OS:** Berbeda dengan Hypervisor Tipe 1 (*Bare-Metal* seperti VMware ESXi atau Proxmox VE yang langsung terpasang pada hardware), Hypervisor Tipe 2 berjalan sebagai aplikasi perangkat lunak di dalam Host OS (misal: Oracle VirtualBox di atas Windows 11).
2. **Cocok untuk Pembelajaran & Lab:** Mudah diinstal, memiliki antarmuka grafis (GUI) yang ramah pengguna, dan tidak memerlukan server khusus.
3. **Overhead Sumber Daya:** Karena harus melewati Host OS sebelum mengakses hardware fisik, performanya sedikit lebih rendah dibanding Tipe 1, namun sangat cukup dan ideal untuk simulasi jaringan.

---

## 2. Konsep Jaringan Virtual & IPv6

### A. Pemilihan Mode Jaringan VirtualBox: *Internal Network*
VirtualBox menyediakan beberapa tipe adapter jaringan:
1. **NAT (Network Address Translation):** VM mendapat internet dari host, tetapi VM1 dan VM2 tidak bisa saling ping secara langsung karena berada di subnet terisolasi masing-masing.
2. **Bridged Adapter:** VM langsung menempel ke Wi-Fi/LAN host. Kelemahannya: Jika Wi-Fi kampus/rumah memblokir komunikasi antar-perangkat (*AP Isolation*) atau tidak mendukung IPv6, komunikasi antar VM akan gagal.
3. **Internal Network (`intnet`) [DIREKOMENDASIKAN]:**
   - Menghubungkan VM1 dan VM2 ke dalam sebuah *virtual switch* terisolasi di dalam hypervisor.
   - Bebas dari gangguan Wi-Fi luar, tidak butuh koneksi internet, dan 100% stabil untuk demo.

### B. Konsep Pengalamatan IPv6
IPv6 berukuran **128-bit** (dibandingkan IPv4 yang hanya 32-bit), ditulis dalam 8 kelompok heksadesimal yang dipisahkan titik dua (`:`).

Untuk tugas ini, ada 2 jenis alamat IPv6 yang wajib dipahami:
1. **Unique Local Address (ULA) - Prefix `fd00::/8`:**
   - Padanan dari *Private IP* pada IPv4 (seperti `192.168.x.x`).
   - Alamat ini tidak dirutekan di internet publik, sangat ideal untuk jaringan lokal/lab virtual.
   - Contoh skema yang kita gunakan:
     - **Subnet:** `fd00:db8:1::/64`
     - **VM 1:** `fd00:db8:1::10/64`
     - **VM 2:** `fd00:db8:1::20/64`
2. **Link-Local Address - Prefix `fe80::/10`:**
   - Otomatis dibuat oleh sistem operasi begitu antarmuka jaringan (*interface*) aktif.
   - Hanya berlaku dalam satu segmen jaringan lokal (*single link*).
   - Catatan demo: Saat melakukan ping ke alamat link-local, wajib menyertakan identitas interface (misal: `ping fe80::1%eth0` di Linux atau `ping fe80::1%12` di Windows).

### C. Neighbor Discovery Protocol (NDP) vs ARP
Pada IPv4, perangkat mencari MAC address tujuan menggunakan **ARP (Address Resolution Protocol)** dengan cara *broadcast*.  
Pada IPv6:
- **TIDAK ADA BROADCAST.**
- Pencarian MAC address menggunakan **NDP (Neighbor Discovery Protocol)** via **ICMPv6 Multicast** (*Solicited-Node Multicast*).
- Paket yang dipertukarkan:
  - **Neighbor Solicitation (NS):** Menanyakan "Siapa pemilik alamat IPv6 ini?".
  - **Neighbor Advertisement (NA):** Menjawab "Ini MAC address saya".
- Untuk melihat tabel tetangga (padanan tabel ARP):
  - Linux: `ip -6 neigh`
  - Windows: `netsh interface ipv6 show neighbors`

---

## 3. Desain Topologi & Rencana Alokasi IP

```text
       +---------------------------------------------+
       |         VirtualBox Internal Network         |
       |             Nama: "jarkom-v6"               |
       +---------------------------------------------+
                     |                         |
                     |                         |
          [enp0s3 / eth0]             [enp0s3 / eth0]
       +--------------------+      +--------------------+
       |       VM 1         |      |       VM 2         |
       |  (Debian/Ubuntu)   |      |  (Debian/Ubuntu)   |
       |                    |      |                    |
       | ULA IPv6:          |      | ULA IPv6:          |
       | fd00:db8:1::10/64  | <--> | fd00:db8:1::20/64  |
       +--------------------+      +--------------------+
```

### Tabel Alamat:
| Komponen | Virtual Machine 1 (VM1) | Virtual Machine 2 (VM2) |
| :--- | :--- | :--- |
| **Hostname** | `vm1-node` | `vm2-node` |
| **Network Adapter** | Adapter 1: Internal Network (`jarkom-v6`) | Adapter 1: Internal Network (`jarkom-v6`) |
| **Promiscuous Mode** | Allow All | Allow All |
| **IPv6 Statis (ULA)** | `fd00:db8:1::10/64` | `fd00:db8:1::20/64` |
| **Target Pengujian** | `ping -6 fd00:db8:1::20` | `ping -6 fd00:db8:1::10` |

---

## 4. Langkah-Langkah Pembuatan (Step-by-Step)

### Tahap 1: Setup di Oracle VirtualBox
1. Buka **Oracle VirtualBox**.
2. Buat VM 1:
   - Klik **New**.
   - Beri nama: `VM1-Jarkom`.
   - Pilih OS (misal: Linux / Ubuntu 64-bit atau Debian).
   - Alokasikan RAM (misal 1024 MB atau 2048 MB) dan Disk (misal 10-20 GB).
3. Buat VM 2:
   - Ulangi langkah di atas untuk `VM2-Jarkom` (atau lakukan fitur **Clone** dari VM1).
4. Atur Jaringan untuk **KEDUA VM**:
   - Klik pada VM -> Pilih **Settings** -> Tab **Network**.
   - Pada **Adapter 1**:
     - Centang **Enable Network Adapter**.
     - Attached to: Ubah menjadi **Internal Network**.
     - Name: Isi dengan nama yang sama, misalnya: `jarkom-v6`.
     - Klik **Advanced**, ubah *Promiscuous Mode* menjadi **Allow All**.
   - Klik **OK**.
5. Nyalakan kedua VM.

---

### Tahap 2: Konfigurasi IPv6 di Guest OS

#### Skenario A: Jika Menggunakan Linux (Ubuntu / Debian)

##### Pada VM 1:
1. Cek nama interface jaringan:
   ```bash
   ip link
   ```
   *(Misalkan nama interface adalah `enp0s3` atau `eth0`)*.
2. Tambahkan alamat IPv6 statis secara cepat:
   ```bash
   sudo ip -6 addr add fd00:db8:1::10/64 dev enp0s3
   sudo ip link set enp0s3 up
   ```
3. Verifikasi apakah IP sudah terpasang:
   ```bash
   ip -6 addr show enp0s3
   ```

##### Pada VM 2:
1. Cek nama interface jaringan:
   ```bash
   ip link
   ```
2. Tambahkan alamat IPv6 statis:
   ```bash
   sudo ip -6 addr add fd00:db8:1::20/64 dev enp0s3
   sudo ip link set enp0s3 up
   ```
3. Verifikasi:
   ```bash
   ip -6 addr show enp0s3
   ```

---

#### Skenario B: Jika Menggunakan Netplan (Ubuntu Server 20.04/22.04/24.04) agar IP Permanen
Edit file konfigurasi Netplan di `/etc/netplan/01-netcfg.yaml`:

**VM 1 (`/etc/netplan/01-netcfg.yaml`):**
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: no
      dhcp6: no
      addresses:
        - fd00:db8:1::10/64
```
Terapkan: `sudo netplan apply`

**VM 2 (`/etc/netplan/01-netcfg.yaml`):**
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: no
      dhcp6: no
      addresses:
        - fd00:db8:1::20/64
```
Terapkan: `sudo netplan apply`

---

#### Skenario C: Jika Menggunakan Windows sebagai Guest OS
1. Buka **Control Panel** -> **Network and Internet** -> **Network and Sharing Center** -> **Change adapter settings**.
2. Klik kanan pada Ethernet Adapter -> **Properties**.
3. Pilih **Internet Protocol Version 6 (TCP/IPv6)** -> Klik **Properties**.
4. Pilih **Use the following IPv6 address**:
   - **VM 1:**
     - IPv6 address: `fd00:db8:1::10`
     - Subnet prefix length: `64`
   - **VM 2:**
     - IPv6 address: `fd00:db8:1::20`
     - Subnet prefix length: `64`
5. *Penting untuk Windows:* Matikan Windows Firewall atau izinkan ICMPv6 Echo Request agar bisa di-ping.
   Jalankan di PowerShell (Run as Administrator):
   ```powershell
   netsh advfirewall firewall add rule name="Allow ICMPv6-In" protocol=icmpv6:any,any dir=in action=allow
   ```

---

## 5. Pengujian & Bukti Komunikasi (Pinging)

### A. Uji Ping dari VM 1 ke VM 2:
Jalankan di terminal VM 1:
```bash
ping -6 -c 4 fd00:db8:1::20
```
*Hasil yang diharapkan (Output Sukses):*
```text
PING fd00:db8:1::20(fd00:db8:1::20) 56 data bytes
64 bytes from fd00:db8:1::20: icmp_seq=1 ttl=64 time=0.823 ms
64 bytes from fd00:db8:1::20: icmp_seq=2 ttl=64 time=0.612 ms
64 bytes from fd00:db8:1::20: icmp_seq=3 ttl=64 time=0.589 ms
64 bytes from fd00:db8:1::20: icmp_seq=4 ttl=64 time=0.640 ms

--- fd00:db8:1::20 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3045ms
rtt min/avg/max/mdev = 0.589/0.666/0.823/0.092 ms
```

### B. Uji Ping dari VM 2 ke VM 1:
Jalankan di terminal VM 2:
```bash
ping -6 -c 4 fd00:db8:1::10
```
*Hasil yang diharapkan:* `0% packet loss`.

### C. Verifikasi Tabel Tetangga (NDP / Neighbor Table):
Jalankan di VM 1:
```bash
ip -6 neigh show
```
*Output yang muncul:*
```text
fd00:db8:1::20 dev enp0s3 lladdr 08:00:27:xx:xx:xx REACHABLE
```
*(Menunjukkan alamat IPv6 VM2 berhasil dipetakan ke MAC address virtualnya via Neighbor Discovery Protocol)*.

---

## 6. Lembar Tanya-Jawab Demo Dosen / Asisten Praktikum (Cheat Sheet)

Ketika mendemokan tugas ini di depan Dosen atau Aslab, persiapkan jawaban untuk pertanyaan-pertanyaan berikut:

**Q1: Mengapa kalian menggunakan Hypervisor Tipe 2 untuk tugas ini?**
> **Jawaban:** "Kami menggunakan Hypervisor Tipe 2 (Oracle VirtualBox) karena hypervisor ini berjalan di atas Host OS (Windows). Hal ini sangat ideal untuk lingkungan praktikum dan pembelajaran pada laptop tanpa perlu mengorbankan atau memformat sistem operasi utama, serta memudahkan konfigurasi virtual networking secara fleksibel."

**Q2: Mengapa memilih mode 'Internal Network' di VirtualBox dan bukan NAT atau Bridged?**
> **Jawaban:** "Mode Internal Network mengisolasi komunikasi jaringan hanya di antara VM yang berada dalam segmen yang sama (`jarkom-v6`). Mode ini mencegah ketergantungan pada koneksi fisik/Wi-Fi host, mencegah IP conflict dengan jaringan luar, dan menjamin komunikasi IPv6 antar-VM berjalan 100% stabil."

**Q3: Kenapa menggunakan format IP `fd00:db8:1::10`? Mengapa tidak pakai `192.168.x.x`?**
> **Jawaban:** "Karena tugas mewajibkan penggunaan IPv6 (128-bit). Alamat `fd00::/8` adalah Unique Local Address (ULA) yang merupakan standar RFC 4193, setara dengan Private IP pada IPv4. Ini digunakan khusus untuk jaringan lokal non-internet."

**Q4: Di mana letak perbedaan proses 'Ping' pada IPv4 vs IPv6?**
> **Jawaban:** 
> 1. Pada IPv4, ping menggunakan protokol **ICMP** dan resolusi MAC address menggunakan **ARP** (broadcast).
> 2. Pada IPv6, ping menggunakan **ICMPv6** dan resolusi MAC address menggunakan **Neighbor Discovery Protocol (NDP)** dengan mekanisme multicast (*Solicited-Node Multicast*), sehingga tidak membebani jaringan dengan broadcast flooding.

**Q5: Apa fungsi tabel yang muncul saat mengetik `ip -6 neigh`?**
> **Jawaban:** "Perintah tersebut menampilkan cache Neighbor Discovery Protocol (NDP). Tabel tersebut memetakan alamat IPv6 VM lawan dengan MAC Address perangkat keras virtualnya, dengan status `REACHABLE` yang membuktikan bahwa kedua host berhasil berjabat tangan di layer 2 dan layer 3."
