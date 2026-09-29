# LAPORAN TUGAS 1 - VIRTUALISASI & KOMUNIKASI JARINGAN IPv6
**Mata Kuliah:** Jaringan Komputer dan LAN (JARKOMLAN)  
**Topik:** Pembuatan Mesin Virtual (Hypervisor Tipe 2) dan Uji Komunikasi Jaringan Menggunakan Protokol IPv6  

---

## IDENTITAS KELOMPOK
- **Mata Kuliah:** Jaringan Komputer dan LAN
- **Tugas:** Tugas 1 - Virtualisasi & Komunikasi Antar-VM (IPv6)
- **Anggota Kelompok:**
  1. **Nicholas Benaya** — NIM: `5024241050`
  2. **Dzaky Haady** — NIM: `5024241076`
  3. **Alvis Shohan Fawwaz Nizar** — NIM: `5024241019`
  4. **Muhammad Sayyid Tsabit** — NIM: `5024241013`

---

## 1. PENDAHULUAN & LANDASAN TEORI

### 1.1 Apa itu Virtualisasi?
Virtualisasi adalah teknologi yang memungkinkan sebuah komputer fisik (seperti laptop kita) untuk menjalankan beberapa komputer tiruan berbasis perangkat lunak secara bersamaan. Komputer tiruan ini disebut sebagai **Virtual Machine (VM)**. Masing-masing VM memiliki prosesor, memori RAM, media penyimpanan, dan kartu jaringan tersendiri yang terisolasi dari sistem utama.

### 1.2 Hypervisor Tipe 2 (Hosted Hypervisor)
Sesuai materi perkuliahan pada materi *Perkembangan Teknologi Virtualisasi Modern*, hypervisor terbagi menjadi dua tipe:
1. **Hypervisor Tipe 1 (Bare-Metal):** Terpasang langsung pada perangkat keras tanpa sistem operasi perantara (biasanya digunakan pada data center dan server besar).
2. **Hypervisor Tipe 2 (Hosted):** Berjalan sebagai program aplikasi biasa di atas sistem operasi utama (*Host OS*).

Pada tugas ini, kami menggunakan **Oracle VirtualBox** sebagai Hypervisor Tipe 2 yang dipasang di atas sistem operasi Windows 11.

```
+-------------------------------------------------------------+
|   Mesin Virtual 1 (VM 1)            Mesin Virtual 2 (VM 2)  |
|   (Alpine Linux Virtual)            (Alpine Linux Virtual)  |
+-------------------------------------------------------------+
|                     Virtual Machine Layer                   |
+-------------------------------------------------------------+
|             Hypervisor Tipe 2 (Oracle VirtualBox)           |
+-------------------------------------------------------------+
|               Sistem Operasi Utama (Windows 11)             |
+-------------------------------------------------------------+
|                     Perangkat Keras Laptop                  |
|             (Intel Core Ultra 7 155H, 32 GB RAM)            |
+-------------------------------------------------------------+
```

### 1.3 Pengenalan Protokol IPv6
IPv6 adalah sistem pengalamatan perangkat di jaringan komputer yang dirancang untuk menggantikan IPv4. Jika IPv4 hanya menggunakan 32-bit (sekitar 4,3 miliar alamat unik), IPv6 menggunakan **128-bit** yang dituliskan dalam deretan angka dan huruf heksadesimal.
* **Unique Local Address (ULA - `fd00::/8`):** Pada tugas ini, kami menggunakan rentang alamat ULA. Alamat ini berfungsi seperti *Private IP* pada IPv4 (misalnya `192.168.x.x`), yang khusus dipakai untuk jaringan lokal tertutup dan tidak akan bentrok dengan alamat internet publik.
* **Neighbor Discovery Protocol (NDP):** Pada IPv4, komputer mencari alamat fisik (MAC address) temannya menggunakan metode *broadcast* (berteriak ke seluruh jaringan via protokol ARP). Di IPv6, cara ini dihilangkan dan diganti dengan protokol **NDP** yang lebih efisien karena hanya mengirimkan pesan langsung ke grup target (*multicast*).

---

## 2. CATATAN PEMILIHAN SISTEM OPERASI (DEBIAN $\rightarrow$ ALPINE LINUX)

Dalam pengerjaan tugas ini, tim kami pada awalnya mencoba menggunakan distro **Debian (Netinst)**. Namun, dalam pelaksanaannya ditemukan kendala teknis nyata di lapangan:
1. **Kendala Inkompatibilitas Prosesor:**  
   Laptop yang digunakan memakai prosesor generasi baru, yaitu **Intel Core Ultra 7 155H**. Prosesor ini menggunakan arsitektur *hybrid* yang membagi inti pemrosesan menjadi inti berkinerja tinggi (*Performance Cores*) dan inti hemat daya (*Efficient Cores*).
2. **Gejala Kendala pada Debian:**  
   Ketika proses instalasi Debian sampai pada tahap partisi harddisk (persis di angka 13%), installer Debian mencoba menjalankan modul pengujian enkripsi (*dm-crypt*). Karena berjalan di atas virtualisasi Windows 11, terjadi *soft lockup* (prosesor virtual terhenti dan tidak sinkron) sehingga installer macet total lebih dari 10 menit.

### Solusi Cerdas yang Diambil:
Untuk menyelesaikan tugas dengan cepat, tepat, dan stabil, kami beralih menggunakan **Alpine Linux Virtual 3.20 (x86_64)**:
* **Ukuran Sangat Ringan:** File image Alpine Linux hanya berukuran $\approx 60$ MB (dibandingkan OS lain yang mencapai bergiga-giga).
* **Eksekusi Kilat (Live RAM):** Alpine Linux dapat langsung menyala dan siap pakai dalam waktu **3 detik** tanpa perlu melewati tahapan instalasi partisi disk yang rentan macet.
* **Fitur Jaringan Lengkap:** Meskipun berukuran mini, Alpine Linux memiliki fitur perintah jaringan lengkap, mendukung kernel Linux 6.6 modern, dan sepenuhnya kompatibel dengan konfigurasi IPv6.

---

## 3. PERANCANGAN JARINGAN & TOPOLOGI

Kedua mesin virtual dihubungkan menggunakan virtual switch bawaan VirtualBox dengan mode **Internal Network** bernama `jarkom-v6`.

```
                    +-----------------------------+
                    | Virtual Switch: "jarkom-v6" |
                    +-----------------------------+
                            |             |
           +----------------+             +----------------+
           |                                               |
+-----------------------+                       +-----------------------+
|      VM1-Jarkom       |                       |      VM2-Jarkom       |
| OS: Alpine Linux 3.20 |                       | OS: Alpine Linux 3.20 |
| Interface: eth0       |                       | Interface: eth0       |
| IPv6: fd00:db8:1::10  | <===================> | IPv6: fd00:db8:1::20  |
| Prefix: /64           |      ICMPv6 Ping      | Prefix: /64           |
| MAC: 08:00:27:DA:40:82|   (0% Packet Loss)    | MAC: 08:00:27:E7:03:A5|
+-----------------------+                       +-----------------------+
```

### Tabel Alokasi Pengalamatan (Addressing Table)
| Pengaturan | Virtual Machine 1 (VM 1) | Virtual Machine 2 (VM 2) |
| :--- | :--- | :--- |
| **Nama Mesin** | `VM1-Jarkom` | `VM2-Jarkom` |
| **Sistem Operasi** | Alpine Linux Virtual 3.20 | Alpine Linux Virtual 3.20 |
| **Alokasi Sumber Daya**| RAM 1024 MB, 2 vCPU | RAM 1024 MB, 2 vCPU |
| **Mode Kartu Jaringan**| Internal Network (`jarkom-v6`) | Internal Network (`jarkom-v6`) |
| **Nama Interface** | `eth0` | `eth0` |
| **MAC Address** | `08:00:27:DA:40:82` | `08:00:27:E7:03:A5` |
| **Alamat IPv6 (ULA)** | `fd00:db8:1::10/64` | `fd00:db8:1::20/64` |
| **Perintah Uji Koneksi**| `ping -6 -c 4 fd00:db8:1::20` | `ping -6 -c 4 fd00:db8:1::10` |

---

## 4. LANGKAH PENGERJAAN & KONFIGURASI

1. **Pembuatan Mesin di VirtualBox:**  
   Membuat dua mesin virtual baru bernama `VM1-Jarkom` dan `VM2-Jarkom`, masing-masing diberi memori 1 GB dan 2 CPU.
2. **Penyambungan Jaringan Virtual:**  
   Pada menu pengaturan kartu jaringan (*Network*), kedua mesin diatur ke mode **Internal Network** dengan nama yang persis sama, yaitu `jarkom-v6`.
3. **Pemberian Alamat IPv6 di Terminal:**  
   * **Pada VM 1:**
     ```bash
     ip link set eth0 up
     ip -6 addr add fd00:db8:1::10/64 dev eth0
     ```
   * **Pada VM 2:**
     ```bash
     ip link set eth0 up
     ip -6 addr add fd00:db8:1::20/64 dev eth0
     ```

---

## 5. HASIL PENGUJIAN & BUKTI KOMUNIKASI

### 5.1 Uji Ping dari VM 1 ke VM 2 (`fd00:db8:1::20`)
Perintah yang dijalankan pada terminal VM 1:
```bash
ping -6 -c 4 fd00:db8:1::20
```

**Hasil Keluaran Terminal:**
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

**Tangkapan Layar:**
![Bukti Ping VM 1 ke VM 2](screenshots/bukti_ping_vm1_ke_vm2.png)

---

### 5.2 Uji Ping dari VM 2 ke VM 1 (`fd00:db8:1::10`)
Perintah yang dijalankan pada terminal VM 2:
```bash
ping -6 -c 4 fd00:db8:1::10
```

**Hasil Keluaran Terminal:**
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

**Tangkapan Layar:**
![Bukti Ping VM 2 ke VM 1](screenshots/bukti_ping_vm2_ke_vm1.png)

---

### 5.3 Pembuktian Protokol Pengganti ARP (Tabel Tetangga / NDP Cache)
Untuk membuktikan bahwa kedua komputer berhasil mengenali alamat fisik satu sama lain melalui protokol IPv6, kami memeriksa tabel *neighbor* dengan mengetikkan `ip -6 neigh`:

* **Keluaran pada VM 1:**
  ```text
  localhost:~# ip -6 neigh
  fd00:db8:1::20 dev eth0 lladdr 08:00:27:e7:03:a5 ref 1 used 0/0/0 probes 4 REACHABLE
  ```
* **Keluaran pada VM 2:**
  ```text
  localhost:~# ip -6 neigh
  fd00:db8:1::10 dev eth0 lladdr 08:00:27:da:40:82 ref 1 used 0/0/0 probes 1 REACHABLE
  ```

Status **`REACHABLE`** membuktikan bahwa jabat tangan pertukaran pesan tetangga (*Neighbor Solicitation* dan *Neighbor Advertisement*) telah sukses 100%.

---

## 6. KESIMPULAN

1. Konsep **Hypervisor Tipe 2** menggunakan Oracle VirtualBox berhasil diterapkan untuk menjalankan dua sistem operasi independen di atas satu laptop fisik.
2. Keputusan beralih dari Debian ke **Alpine Linux Virtual** terbukti sangat efektif untuk mengatasi kendala inkompatibilitas arsitektur prosesor laptop (Intel Core Ultra), sehingga sistem operasi dapat menyala secara instan tanpa mengorbankan fungsionalitas jaringan.
3. Komunikasi jaringan lokal menggunakan protokol **IPv6 (Unique Local Address)** dan pembuktian melalui perintah **Ping (ICMPv6)** berjalan sempurna dengan tingkat keberhasilan pengiriman paket **100% (0% packet loss)** serta tercatat dengan baik pada tabel *Neighbor Discovery Protocol*.
