# PANDUAN TEKNIS PENGERJAAN TUGAS & MATERI DEMONSTRASI
**Mata Kuliah:** Jaringan Komputer & LAN (JARKOMLAN)  
**Tugas 1:** Implementasi Komunikasi Virtual Machine Menggunakan Protokol IPv6  

---

## Identitas Kelompok
- **Nicholas Benaya** — NIM: `5024241050`
- **Dzaky Haady** — NIM: `5024241076`
- **Alvis Shohan Fawwaz Nizar** — NIM: `5024241019`
- **Muhammad Sayyid Tsabit** — NIM: `5024241013`

---

## 1. MATRIKS KEPUTUSAN ARSITEKTUR (MENGAPA MEMILIH INI DARIPADA ITU)

Dokumen ini disusun untuk memberikan pemahaman menyeluruh terhadap dasar pertimbangan teknis di balik setiap keputusan rekayasa sistem yang diambil dalam pengerjaan tugas.

---

### A. Komparasi Hypervisor: Mengapa Hypervisor Tipe 2 daripada Tipe 1 atau Container?

Dalam rekayasa sistem komputer, terdapat tiga pendekatan utama untuk menjalankan lingkungan komputasi terisolasi:

```
+---------------------------+---------------------------+---------------------------+
| HYPERVISOR TIPE 1         | HYPERVISOR TIPE 2         | TEKNOLOGI KONTAINER       |
| (Bare-Metal / Native)     | (Hosted Virtualization)   | (OS-Level Virtualization) |
+---------------------------+---------------------------+---------------------------+
| Contoh: VMware ESXi,      | Contoh: Oracle VirtualBox,| Contoh: Docker, Podman,   |
| Proxmox VE, KVM           | VMware Workstation        | LXC                       |
|                           |                           |                           |
| Arsitektur:               | Arsitektur:               | Arsitektur:               |
| Berjalan langsung di atas | Berjalan sebagai program  | Berbagi kernel dengan     |
| hardware fisik tanpa Host | aplikasi di atas Host OS  | Host OS; hanya isolasi    |
| OS perantara.             | (Windows 11).             | user space/cgroups.       |
|                           |                           |                           |
| Target Use Case:          | Target Use Case:          | Target Use Case:          |
| Data center enterprise,   | Lingkungan laboratorium   | Deployment aplikasi web,  |
| server cloud (AWS/GCP),   | pengujian, simulasi       | arsitektur microservices, |
| produksi dengan utilisasi | jaringan, edukasi, dan    | CI/CD pipeline yang hemat |
| resource maksimal 24/7.   | demonstrasi portabel.     | beban memori.             |
+---------------------------+---------------------------+---------------------------+
```

#### Analisis Kekontrasan Karakteristik:
1. **Mengapa tidak memilih Hypervisor Tipe 1?**  
   Hypervisor Tipe 1 dirancang khusus untuk mesin server tanpa antarmuka desktop personal. Memasang Tipe 1 pada laptop akan menghapus sistem operasi Windows 11 host secara menyeluruh (*bare-metal wipe*). Hal ini tidak dapat diterapkan untuk laptop harian mahasiswa yang membutuhkan portabilitas dan fungsionalitas sistem operasi harian.
2. **Mengapa tidak memilih Kontainer (Docker)?**  
   Kontainer tidak mengemulasikan perangkat keras fisik secara penuh; kontainer berbagi satu kernel Linux yang sama dengan host. Tugas ini secara eksplisit menuntut evaluasi komunikasi antar-*Virtual Machine* sejati yang memiliki kernel, tumpukan driver perangkat keras virtual, dan siklus hidup sistem operasi mandiri.
3. **Mengapa Hypervisor Tipe 2 (VirtualBox) adalah Pilihan Tepat?**  
   Tipe 2 menyediakan abstraksi perangkat keras lengkap (vCPU, vRAM, vNIC) dalam ruang pengguna (*user space*) Windows. Penguji dapat merancang topologi jaringan virtual mandiri secara terisolasi tanpa risiko mengganggu stabilitas sistem operasi utama laptop.

---

### B. Komparasi Jaringan: Mengapa Mode *Internal Network* daripada Bridged Adapter atau NAT?

Oracle VirtualBox menyediakan beberapa mekanisme perutean paket virtual:

1. **Mode NAT (Network Address Translation):**  
   Setiap VM disembunyikan di balik router virtual internal dengan alamat gateway default `10.0.2.2`. Mode ini memutus konektivitas langsung Layer 3 antar-VM, sehingga VM 1 tidak dapat menjangkau alamat IP VM 2 secara langsung.
2. **Mode Bridged Adapter:**  
   Menautkan kartu antarmuka virtual langsung ke adapter fisik (Wi-Fi/LAN laptop).  
   *Kelemahan Kritis:* Konektivitas sangat bergantung pada jaringan fisik di luar laptop. Jika laptop terhubung ke Wi-Fi kampus yang mengaktifkan fitur keamanan *Client Isolation* (memblokir lalu lintas antar-klien nirkabel) atau access point tidak mendistribusikan prefix IPv6, maka komunikasi antar-VM akan gagal total di luar kendali penguji.
3. **Mode Internal Network (`jarkom-v6`) [PILIHAN TERBAIK]:**  
   Menciptakan saklar jaringan virtual (*virtual switch*) murni di dalam alokasi memori hypervisor.  
   *Keunggulan Teknis:* Jaringan bersifat sepenuhnya tertutup, deterministik, tidak membutuhkan gateway internet luar, dan kebal terhadap perubahan status koneksi Wi-Fi fisik laptop penguji.

---

### C. Komparasi Protokol: Keunggulan IPv6 Dibandingkan IPv4 dalam Studi Kasus Ini

Penerapan protokol **IPv6** pada tugas ini memberikan perbedaan arsitektural yang fundamental dibandingkan IPv4:

1. **Eliminasi Broadcast Storming via Neighbor Discovery Protocol (NDP):**  
   * *Pada IPv4:* Setiap kali VM 1 ingin mengetahui MAC address VM 2, VM 1 harus mengirimkan paket **ARP Request** secara *broadcast* (`FF:FF:FF:FF:FF:FF`). Pada switch virtual, paket broadcast harus disalin dan dikirimkan ke seluruh port antarmuka yang ada.
   * *Pada IPv6:* ARP dihapus total dan digantikan oleh **NDP** yang beroperasi di atas protokol **ICMPv6**. NDP menggunakan alamat *Solicited-Node Multicast* (contoh: `ff02::1:ffxx:xxxx`). Switch virtual hanya meneruskan frame ke port tujuan yang terdaftar dalam grup multicast tersebut. Ini menghasilkan transmisi frame yang jauh lebih terarah dan bersih dari gangguan latensi.
2. **Rasionalitas Pemilihan Alamat ULA (`fd00::/8`) vs Link-Local (`fe80::/10`):**  
   * Alamat **Link-Local** (`fe80::`) secara otomatis dibuat oleh sistem operasi begitu antarmuka aktif. Namun, saat melakukan pengujian *ping*, pengguna wajib menyertakan identitas interface scope/zone ID (contoh: `ping fe80::...%eth0`), karena alamat link-local tidak memiliki informasi perutean global di tabel routing kernel.
   * Alamat **Unique Local Address (ULA - `fd00::/8`)** adalah padanan IPv6 untuk alamat privat IPv4 (RFC 1918) yang diatur dalam RFC 4193. Alamat ULA memiliki cakupan perutean lokal yang jelas tanpa membutuhkan zone ID, menghasilkan sintaks pengujian yang deterministik, bersih, dan sesuai dengan standar perancangan topologi jaringan profesional.

---

### D. Komparasi Sistem Operasi: Mengapa Berpindah dari Debian ke Alpine Linux?

Dalam pengujian awal, tim mendapati proses instalasi **Debian Netinst** terhenti permanen pada tahap partisi disk (13%).

#### Analisis Kegagalan Teknis:
* Laptop penguji ditenagai prosesor **Intel Core Ultra 7 155H** dengan arsitektur inti hibrida (P-core berkecepatan tinggi dan E-core hemat daya).
* Di Windows 11 dengan fitur keamanan VBS aktif, VirtualBox terpaksa beroperasi dalam lapisan emulasi *Windows Hypervisor Platform (NEM)*.
* Pada progres 13%, skrip Debian mengeksekusi modul kriptografi `dm-crypt`. Penjadwalan prosesor virtual di bawah lapisan NEM mengalami keterlambatan interupsi pewaktu (terekam dalam log: `TM: Giving up catch-up attempt ... lag`), yang memicu mekanisme keamanan kernel Linux melaporkan `watchdog: BUG: soft lockup - CPU stuck` dan membekukan proses instalasi.

#### Keunggulan Penggunaan Alpine Linux Virtual:
* **Efisiensi Arsitektur:** Alpine Linux berukuran $\approx 63$ MB, berbasis pustaka C minimalis **`musl-libc`** dan utilitas inti **`BusyBox`**.
* **Operasional Live RAM:** Berjalan langsung dari memori kerja komputer (*tmpfs*), melewati sepenuhnya tahapan pembuatan partisi disk berat yang memicu modul enkripsi bermasalah.
* **Waktu Inisialisasi:** Menyala secara instan dalam **3 detik**, dengan tetap menyediakan tumpukan protokol jaringan Linux yang sepenuhnya mematuhi standar RFC untuk ICMPv6 dan NDP.

---

## 2. SPESIFIKASI PENGALAMATAN & DATA EVALUASI

```
       +---------------------------------------------+
       |   Virtual Switch VirtualBox: "jarkom-v6"    |
       +---------------------------------------------+
                     |                         |
               [vNIC: eth0]              [vNIC: eth0]
       +--------------------+      +--------------------+
       |     VM1-Jarkom     |      |     VM2-Jarkom     |
       |  (Alpine Linux)    |      |  (Alpine Linux)    |
       |                    |      |                    |
       | MAC Address:       |      | MAC Address:       |
       | 08:00:27:DA:40:82  |      | 08:00:27:E7:03:A5  |
       |                    |      |                    |
       | IPv6 ULA Statis:   | <--> | IPv6 ULA Statis:   |
       | fd00:db8:1::10/64  | Ping | fd00:db8:1::20/64  |
       +--------------------+      +--------------------+
```

### Tabel Parameter Sistem
| Parameter Teknis | VM 1 (`VM1-Jarkom`) | VM 2 (`VM2-Jarkom`) |
| :--- | :--- | :--- |
| **Sistem Operasi** | Alpine Linux Virtual 3.20 (x86_64) | Alpine Linux Virtual 3.20 (x86_64) |
| **Interface Jaringan** | `eth0` | `eth0` |
| **MAC Address (Layer 2)** | `08:00:27:DA:40:82` | `08:00:27:E7:03:A5` |
| **Alamat IPv6 ULA** | `fd00:db8:1::10/64` | `fd00:db8:1::20/64` |
| **Hasil Transmisi ICMPv6**| 4 paket dikirim, 4 diterima (**0% loss**) | 4 paket dikirim, 4 diterima (**0% loss**) |
| **Rentang Latensi (RTT)** | 1.711 ms – 5.523 ms | 1.344 ms – 2.015 ms |
| **Status Validasi NDP** | `REACHABLE` | `REACHABLE` |

---

## 3. PROSEDUR DEMONSTRASI DI DEPAN DOSEN / TIM EVALUASI

Lakukan demonstrasi secara runtut dan sistematis:

### Tahap 1: Verifikasi Topologi VirtualBox
1. Buka antarmuka utama Oracle VirtualBox.
2. Perlihatkan bahwa terdapat dua instance VM yang aktif: **`VM1-Jarkom`** dan **`VM2-Jarkom`**.
3. Buka menu **Settings $\rightarrow$ Network** pada salah satu VM untuk memverifikasi bahwa adapter berada pada mode **Internal Network** dengan penamaan segmen: `jarkom-v6`.

### Tahap 2: Verifikasi Alokasi Alamat Lapisan Jaringan
Buka konsol terminal kedua VM berdampingan pada layar laptop:
* **Pada VM 1:** Ketik `ip -6 addr show eth0`  
  *(Perlihatkan bahwa alamat statis `fd00:db8:1::10/64` terpasang aktif pada interface `eth0`)*.
* **Pada VM 2:** Ketik `ip -6 addr show eth0`  
  *(Perlihatkan bahwa alamat statis `fd00:db8:1::20/64` terpasang aktif pada interface `eth0`)*.

### Tahap 3: Eksekusi Uji Transmisi Paket (ICMPv6 Ping)
1. **Kirim paket dari VM 1 ke VM 2:**
   ```bash
   ping -c 4 fd00:db8:1::20
   ```
   *Tunjukkan statistik:* `4 packets transmitted, 4 packets received, 0% packet loss`. Jelaskan bahwa paket ICMPv6 Echo Request berhasil dijawab oleh VM 2 dengan latensi rendah.
2. **Kirim paket balasan dari VM 2 ke VM 1:**
   ```bash
   ping -c 4 fd00:db8:1::10
   ```
   *Tunjukkan statistik:* Jalur transmisi timbal-balik terbukti reliabel secara penuh.

### Tahap 4: Pembuktian Resolusi Alamat Layer 2 (Tabel Tetangga NDP)
Ketik pada terminal VM 1:
```bash
ip -6 neigh
```
*Tunjukkan keluaran baris:*
`fd00:db8:1::20 dev eth0 lladdr 08:00:27:e7:03:a5 ref 1 used 0/0/0 probes 4 REACHABLE`

*Poin Evaluasi:* Jelaskan bahwa status **`REACHABLE`** memverifikasi protokol NDP telah berhasil memetakan alamat IPv6 target langsung ke alamat MAC fisik perangkat lawan tanpa memerlukan mekanisme broadcast ARP.

---

## 4. TANYA-JAWAB TEKNIS PENGUJIAN (*TECHNICAL Q&A CHEAT SHEET*)

**Q1: Apa pertimbangan utama memilih Hypervisor Tipe 2 dibanding Tipe 1 pada tugas ini?**
> **Jawaban:** "Hypervisor Tipe 1 (seperti Proxmox atau VMware ESXi) dirancang untuk infrastruktur bare-metal di pusat data dan memerlukan komputer server terdedikasi tanpa Host OS. Sebaliknya, Hypervisor Tipe 2 (VirtualBox) berjalan di atas sistem operasi host yang ada, memungkinkan perancangan dan pengujian topologi jaringan virtual secara terisolasi tanpa perlu memformat ulang perangkat keras utama laptop penguji."

**Q2: Mengapa memilih mode Internal Network daripada Bridged Adapter?**
> **Jawaban:** "Mode Internal Network mengisolasi domain transmisi Layer 2 sepenuhnya di dalam alokasi memori hypervisor. Mode Bridged menautkan VM ke adapter fisik host, yang sangat rentan gagal jika access point Wi-Fi kampus mengaktifkan Client Isolation (mencegah komunikasi antar-perangkat nirkabel) atau tidak menyediakan alokasi prefix IPv6."

**Q3: Di mana letak perbedaan mendasar antara mekanisme resolusi alamat pada IPv4 dan IPv6?**
> **Jawaban:** "Pada IPv4, pemetaan MAC address dilakukan oleh protokol ARP menggunakan paket broadcast ke seluruh jaringan (`FF:FF:FF:FF:FF:FF`), yang menimbulkan overhead switching pada switch virtual. Pada IPv6, ARP dieliminasi dan digantikan oleh Neighbor Discovery Protocol (NDP) berbasis ICMPv6 yang memanfaatkan transmisi multicast terarah (*Solicited-Node Multicast*), sehingga pemrosesan frame menjadi jauh lebih efisien."

**Q4: Mengapa menggunakan prefix `fd00::/8` dan bukan alamat Link-Local (`fe80::`)?**
> **Jawaban:** "Alamat `fd00::/8` adalah standar Unique Local Address (ULA) berdasarkan RFC 4193 yang setara dengan IP Privat pada IPv4. Alamat ULA memiliki cakupan perutean subnet lokal yang terdefinisi secara utuh tanpa memerlukan penentuan interface scope identifier (seperti `%eth0`), sehingga menghasilkan sintaks perutean dan pengujian yang deterministik."

**Q5: Mengapa beralih dari Debian Netinst ke Alpine Linux Virtual?**
> **Jawaban:** "Prosesor laptop penguji (Intel Core Ultra 7 155H) memiliki arsitektur core hybrid. Saat menjalankan installer Debian di bawah mode virtualisasi Windows NEM, pengujian modul enkripsi *dm-crypt* pada tahap partisi memicu desinkronisasi pewaktu virtual (*soft lockup*). Alpine Linux Virtual dipilih karena beroperasi langsung di memori kerja (Live RAM), menghindari proses partisi disk berat, dan memangkas waktu inisialisasi menjadi 3 detik dengan tetap mempertahankan dukungan penuh tumpukan protokol IPv6."
