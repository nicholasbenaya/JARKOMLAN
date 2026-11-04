# Panduan Langkah demi Langkah & Naskah Demonstrasi Tugas 3
## Praktikum Jaringan Komputer dan LAN (JARKOMLAN)
### Topik: Cached Proxy (Squid) & Reverse Proxy Load Balancing (Nginx)

Dokumen ini adalah **SOP Operasional Demo Langkah demi Langkah** yang dirancang agar seluruh anggota kelompok (4 orang) memiliki instruksi yang sangat jelas, terstruktur, dan percaya diri saat maju di depan Dosen Penguji dan Asisten Laboratorium.

---

## 📋 Ikhtisar Peran Perangkat

| Perangkat | Peran Sistem | Komponen yang Dijalankan |
| :--- | :--- | :--- |
| **Laptop 1 (Host 1)** | **Pusat Proxy Server (Gateway)** | • **Squid Caching Proxy** (Port `3128`)<br>• **Reverse Proxy Load Balancer** (Port `80`) |
| **Laptop 2 (Host 2)** | **Pusat Aplikasi (Server Backend)**| • **Origin Web Server** (Port `8080`)<br>• **Kluster 4 Backend Server** (Port `5001`–`5004`) |
| **Smartphone (HP)** | **Klien Nyata (*End-User Client*)**| • Browser Chrome/Safari (Uji visual & Caching) |

---

## 🛠️ TAHAP 0: Persiapan Sebelum Maju Demo (Checklist 2 Menit)

Lakukan tahap ini sebelum dipanggil ke meja dosen:

1. **Nyalakan Hotspot Seluler di HP:**
   * Nama Wi-Fi (SSID): misalnya `HOTSPOT-JARKOM`.
2. **Sambungkan Semua Perangkat ke Hotspot Tersebut:**
   * Laptop Host 1 $\rightarrow$ Connect ke `HOTSPOT-JARKOM`.
   * Laptop Host 2 $\rightarrow$ Connect ke `HOTSPOT-JARKOM`.
   * Smartphone HP $\rightarrow$ Tetap terhubung ke jaringan lokal hotspot tersebut.
3. **Catat Alamat IPv4 Masing-Masing:**
   * Di **Host 1** (buka CMD): ketik `ipconfig` $\rightarrow$ catat IPv4 Wireless LAN (contoh: `192.168.43.10`).
   * Di **Host 2** (buka CMD): ketik `ipconfig` $\rightarrow$ catat IPv4 Wireless LAN (contoh: `192.168.43.20`).
4. **Tes Konektivitas Lintas Laptop (Ping Test):**
   * Di Host 1, buka CMD: `ping 192.168.43.20`
   * Pastikan output `Reply from 192.168.43.20: bytes=32 ... Loss = 0%`.
   *(Jika Request Timed Out, matikan sementara Windows Defender Firewall pada Private Network).*

---

## 🚀 TAHAP 1: Eksekusi Sub-Tugas 2 (Reverse Proxy & Load Balancing)
> 💡 **Rekomendasi:** Tunjukkan Sub-Tugas 2 terlebih dahulu karena sangat visual di browser HP dan tidak membutuhkan konfigurasi proxy manual di HP!

### Langkah 1.1: Menyalakan 4 Server Backend di Laptop Host 2
1. Di Laptop Host 2, buka folder: `tugas-3\host2\`
2. Double-click file:
   👉 **`start_cluster.bat`**
   * *Jendela PowerShell akan otomatis menyalakan:*
     * **Node 1:** Windows Native Web Server pada port `5001`.
     * **Node 4:** Docker Container Web Server pada port `5004`.
3. Buka Oracle VirtualBox di Host 2, jalankan **VM1** dan **VM2**:
   * Di terminal **VM 1**, ketik:
     ```bash
     sh server_vm.sh 5002 "Node 2 - Linux VM 1" "#22c55e"
     ```
   * Di terminal **VM 2**, ketik:
     ```bash
     sh server_vm.sh 5003 "Node 3 - Linux VM 2" "#eab308"
     ```
   *(Node 2 aktif di port 5002, Node 3 aktif di port 5003 via NAT Port Forwarding).*
4. Beritahukan alamat IP Host 2 ke pemegang Host 1 (misal: `192.168.43.20`).

---

### Langkah 1.2: Menyalakan Reverse Proxy di Laptop Host 1
1. Di Laptop Host 1, buka folder: `tugas-3\host1\`
2. Double-click file:
   👉 **`start_reverse_proxy.bat`**
3. Masukkan IP Host 2 saat diminta di terminal:
   ```text
   Masukkan Alamat IP Host 2: 192.168.43.20
   ```
4. Pilih mode eksekusi: ketik **`1`** (Python Native) lalu tekan Enter.
5. Terminal akan menampilkan konfirmasi:
   ```text
   REVERSE PROXY & LOAD BALANCER (HOST 1) AKTIF
   Listening: http://0.0.0.0:80
   Target Upstream Cluster Host 2:
     - http://192.168.43.20:5001
     - http://192.168.43.20:5002
     - http://192.168.43.20:5003
     - http://192.168.43.20:5004
   ```

---

### Langkah 1.3: Pembuktian Visual di Hadapan Dosen (Menggunakan HP)
1. Pastikan Wi-Fi HP terhubung ke hotspot (Proxy Wi-Fi dalam kondisi **Off/None**).
2. Buka browser di HP (Google Chrome / Safari), ketik URL:
   ```text
   http://192.168.43.10/
   ```
   *(Gunakan alamat IP Host 1 port 80).*
3. **Pegang HP Anda dan perlihatkan ke Dosen sambil menekan tombol Refresh:**
   * **Refresh ke-1:** Muncul kartu Biru $\rightarrow$ `Node 1 - Windows Native (:5001)`
   * **Refresh ke-2:** Muncul kartu Hijau $\rightarrow$ `Node 2 - VirtualBox VM 1 (:5002)`
   * **Refresh ke-3:** Muncul kartu Kuning $\rightarrow$ `Node 3 - VirtualBox VM 2 (:5003)`
   * **Refresh ke-4:** Muncul kartu Ungu $\rightarrow$ `Node 4 - Docker Container (:5004)`
   * **Refresh ke-5:** Kembali ke Node 1 (*Siklus Round Robin terbukti bekerja sempurna!*)

---

### Langkah 1.4: Pembuktian Kuantitatif (Automated Dummy Load Test)
1. Di Laptop Host 2 (atau Host 1), buka folder `tugas-3\host2\`
2. Double-click file:
   👉 **`run_load_test.bat`**
3. Masukkan target URL Host 1: `http://192.168.43.10/` dan jumlah request: `40`.
4. Skrip akan mengirim 40 permintaan secara simultan dan mencetak tabel distribusi beban:
   ```text
   ==================================================
     HASIL DISTRIBUSI LOAD BALANCING (ROUND ROBIN)   
   ==================================================
    Nama Node                      | Jumlah Request | Persentase
    -------------------------------+----------------+------------
    Node 1 - Windows Native        | 10             |  25.00%
    Node 2 - Linux VM 1            | 10             |  25.00%
    Node 3 - Linux VM 2            | 10             |  25.00%
    Node 4 - Docker Container      | 10             |  25.00%
   ==================================================
   ```
   *Tunjukkan tabel 25% rata ini sebagai bukti matematis bahwa pembagian beban seimbang.*

---

## ⚡ TAHAP 2: Eksekusi Sub-Tugas 1 (Cached Proxy Squid)

### Langkah 2.1: Menyalakan Origin Web Server di Laptop Host 2
1. Di Laptop Host 2, buka folder: `tugas-3\host2\`
2. Double-click file:
   👉 **`start_origin_server.bat`**
3. Terminal akan aktif menampilkan:
   ```text
   ORIGIN WEB SERVER (HOST 2) AKTIF
   Listening: http://0.0.0.0:8080
   Caching Header: max-age=3600 (1 Jam)
   ```
   *(Biarkan jendela ini tetap terlihat di layar Laptop 2).*

---

### Langkah 2.2: Menyalakan Squid Caching Proxy di Laptop Host 1
1. Di Laptop Host 1, buka folder: `tugas-3\host1\`
2. Double-click file:
   👉 **`start_squid.bat`**
3. Squid akan aktif pada port `3128` dan terminal otomatis menampilkan streaming log `access.log`.

---

### Langkah 2.3: Mengonfigurasi Manual Proxy di Smartphone (HP)
1. Buka menu **Settings** di HP $\rightarrow$ pilih **Wi-Fi**.
2. Klik tanda ikon info `(i)` atau ikon roda gigi pada Wi-Fi hotspot yang terhubung.
3. Gulir ke bawah ke menu **Proxy** $\rightarrow$ ubah dari *None / Tidak Ada* menjadi **Manual**.
4. Isi parameter:
   * **Host / Nama Host Proxy:** Masukkan IP Host 1 (contoh: `192.168.43.10`).
   * **Port:** `3128`.
5. Klik **Simpan (Save)**.

---

### Langkah 2.4: Pembuktian Caching di Hadapan Dosen

1. **Uji Coba 1 - Permintaan Pertama (Cache MISS):**
   * Di browser HP, buka alamat Origin Server Host 2:
     ```text
     http://192.168.43.20:8080/index.html
     ```
   * **Tunjukkan Layar Host 2:** Muncul baris log `[ORIGIN HIT] GET /index.html`. Artinya server asal dihubungi.
   * **Tunjukkan Layar Host 1:** Terminal Squid mencatat **`TCP_MISS/200`**. Artinya Squid belum punya datanya dan mengunduh dari Host 2.
2. **Uji Coba 2 - Permintaan Kedua (Cache HIT):**
   * Di browser HP, tekan tombol **Refresh / Muat Ulang**.
   * **Tunjukkan Layar Host 2:** **TIDAK ADA LOG BARU YANG MASUK!** (Host 2 tidak disentuh sama sekali).
   * **Tunjukkan Layar Host 1:** Terminal Squid mencatat **`TCP_MEM_HIT/200`** atau **`TCP_HIT/200`**. Halaman langsung disajikan dari memori cache Squid di Host 1!
3. **Uji Coba 3 - Pembuktian Ekstrem (Matikan Origin Server):**
   * Di terminal Host 2, matikan Origin Server dengan menekan tombol **`Ctrl + C`**.
   * Di browser HP, tekan tombol **Refresh** sekali lagi.
   * **Hasil:** Halaman web **tetap berhasil terbuka secara instan!**
   * Sampaikan ke dosen: *"Pak/Mas, server aslinya di Host 2 sudah kami matikan, namun HP kami tetap bisa mengakses konten web karena disuplai langsung oleh cache lokal Squid di Host 1."*

> [!IMPORTANT]
> Setelah demonstrasi selesai, kembalikan pengaturan Proxy di Wi-Fi HP menjadi **None / Off** agar HP dapat browsing internet normal kembali.

---

## 🎙️ TAHAP 3: Naskah Presentasi Siap Pakai saat Maju Demo

Gunakan pembagian peran dan kalimat ini saat berbicara di depan dosen/asisten lab:

### 👤 Anggota 1 (Host 1 - Pembuka & Penjelasan Proxy):
> *"Selamat pagi/siang Bapak/Ibu Dosen dan Mas/Mbak Asisten. Pada Tugas 3 ini, kelompok kami mengimplementasikan dua arsitektur perantara jaringan:*
> 1. *Pertama, **Reverse Proxy Load Balancer** di mana Host 1 bertindak sebagai single gateway yang membagi beban ke 4 server di Host 2.*
> 2. *Kedua, **Cached Proxy** menggunakan Squid di Host 1 untuk menyimpan objek web asal Host 2 di cache lokal.*
> 
> *Sekarang kami akan mendemonstrasikan Sub-Tugas 2 terlebih dahulu menggunakan smartphone sebagai real-client."*

### 👤 Anggota 2 (Host 2 - Menjelaskan 4 Backend Server):
> *"Di Laptop Host 2, kami mengorkestrasikan 4 instance server web di 4 lingkungan komputasi yang terisolasi:*
> * *Node 1 berjalan secara native di OS Windows (port 5001).*
> * *Node 2 berjalan di VirtualBox VM 1 Alpine Linux (port 5002 via NAT port forward).*
> * *Node 3 berjalan di VirtualBox VM 2 Alpine Linux (port 5003 via NAT port forward).*
> * *Node 4 berjalan di dalam kontainer Docker WSL 2 (port 5004).*
> 
> *Seluruh server ini menunggu instruksi dari Reverse Proxy Host 1."*

### 👤 Anggota 3 (Memperagakan HP & Dummy Test):
> *(Sambil memperlihatkan layar smartphone HP ke dosen)*
> *"Klien HP kami hanya mengakses IP Host 1 di port 80. Ketika saya menekan refresh, dapat dilihat kartu identitas server berganti warna dan nama secara bergiliran: Windows, VM 1, VM 2, dan Docker.*
> 
> *Ketika kami menembakkan 40 permintaan otomatis melalui script benchmark, algoritma Round Robin membagi beban secara seimbang masing-masing tepat 25% (10 request per node) tanpa bottleneck."*

### 👤 Anggota 4 (Menjelaskan Cached Proxy Squid):
> *"Selanjutnya untuk Cached Proxy, kami menyalakan Squid di Host 1 dan Origin Server di Host 2. Melalui pengaturan manual proxy port 3128 di HP:*
> * *Pada request pertama terjadi **Cache MISS** (tercatat di terminal Squid dan Origin Server).*
> * *Pada request kedua terjadi **Cache HIT** dengan latensi 0ms karena disajikan dari cache memori Squid.*
> * *Bahkan ketika Origin Server di Host 2 kami matikan, klien HP tetap dapat mengakses halaman web secara utuh."*

---

## 🧠 Cheatsheet Tanya-Jawab Kuis Dosen/Aslab (FAQ)

1. **T: Mengapa klien luar (HP) diarahkan ke port 80 Host 1, bukan langsung ke port 5001–5004 di Host 2?**
   * **Jawab:** Itulah esensi arsitektur **Reverse Proxy**. Tujuannya adalah menyembunyikan infrastruktur internal backend demi keamanan (*security through obscurity*), menyediakan satu gerbang tunggal (*single entry point*), dan membagi beban lalu lintas secara dinamis (*load balancing*). Klien tidak perlu tahu berapa banyak server di belakangnya.

2. **T: Apa perbedaan mendasar antara Forward Proxy (Squid) dan Reverse Proxy (Nginx)?**
   * **Jawab:** 
     * **Forward Proxy (Squid)** bertindak mewakili **klien** untuk mengakses web server luar/internet (fokus: caching, penghematan bandwidth, filter akses klien).
     * **Reverse Proxy (Nginx)** bertindak mewakili **server backend** untuk melayani klien luar (fokus: load balancing, SSL termination, failover, proteksi server).

3. **T: Mengapa di VirtualBox harus menggunakan Port Forwarding NAT?**
   * **Jawab:** Karena mode NAT menempatkan VM di subnet privat VirtualBox (`10.0.2.0/24`) yang terisolasi dari jaringan Wi-Fi luar. Dengan aturan Port Forwarding, paket dari Host fisik (port 5002/5003) dipetakan masuk ke interface internal VM, sehingga Reverse Proxy di Host 1 dapat menjangkaunya melalui IP Host 2.

4. **T: Bagaimana Squid mengetahui bahwa suatu halaman web boleh di-cache?**
   * **Jawab:** Melalui HTTP response header `Cache-Control: public, max-age=3600` yang dikirimkan oleh Origin Server, serta aturan `refresh_pattern` pada file konfigurasi `squid.conf`.
