# Panduan Demonstrasi Online (Akses Internet Jarak Jauh)
## Praktikum Jaringan Komputer dan LAN (JARKOMLAN) - Tugas 3
### Topik: Cached Proxy (Squid) & Reverse Proxy Load Balancing (Nginx) via Pinggy Tunneling

Panduan ini disusun khusus untuk **Demonstrasi 100% ONLINE (Jarak Jauh)**:
* Anggota kelompok dapat berada di **rumah/lokasi masing-masing**.
* Pengujian dari **Smartphone (HP)** menggunakan **paket data seluler (4G/5G)** tanpa perlu Wi-Fi lokal atau tethering hotspot.
* Dosen / Asisten Lab dapat **langsung membuka link publik di HP mereka sendiri** atau melalui tautan di chat **Zoom / Google Meet**.

---

## 🌐 Ikhtisar Arsitektur Online (Model Host 1 Proxy & Host 2 Server)

Dengan memanfaatkan **Pinggy SSH Reverse Tunneling** (port 443 outbound yang kebal blokir ISP), seluruh layanan diekspos ke internet publik:

```mermaid
flowchart TB
    subgraph Internet["🌍 Jaringan Internet Publik (Anywhere / 4G / 5G / Zoom)"]
        direction TB
        Dosen["👨‍🏫 Dosen / Aslab di Zoom (Buka Link Publik)"]
        HP["📱 Smartphone HP Klien (Koneksi Seluler 4G/5G)"]
        Tester["💻 Laptop Penguji Beban (run_load_test.bat)"]
    end

    subgraph PinggyCloud["☁️ Pinggy Edge Cloud Relay"]
        PublicHTTP["URL Publik HTTPS\n(https://xxxx.free.pinggy.link)"]
        PublicTCP["Host & Port TCP Publik\n(tcp.pinggy.io:XXXXX)"]
    end

    subgraph Host1Machine["💻 Host 1 (Laptop 1 - Pusat Proxy Server)"]
        direction TB
        Tunnel1["start_tunnel_online.bat"]
        RP["Reverse Proxy & Load Balancer (Port 80)"]
        Squid["Squid Caching Proxy (Port 3128)"]
    end

    subgraph Host2Machine["💻 Host 2 (Laptop 2 - Pusat Server Backend)"]
        direction TB
        Tunnel2["start_tunnel_online.bat"]
        Origin["Origin Web Server (Port 8080)"]
        Cluster["Kluster 4 Backend Server:\n• Windows Native (:5001)\n• VirtualBox VM 1 (:5002)\n• VirtualBox VM 2 (:5003)\n• Docker Container (:5004)"]
    end

    %% Alur Reverse Proxy Online
    HP -->|"1. Request HTTPS Publik"| PublicHTTP
    Dosen -->|"1. Request HTTPS Publik"| PublicHTTP
    PublicHTTP <==|"2. Encrypted Tunnel (Port 443)"|== Tunnel1
    Tunnel1 -->|"3. Forward ke Port 80"| RP
    RP -->|"4. Round Robin Balancing"| Cluster

    %% Alur Cached Proxy Online
    HP -.->|"Request via Proxy TCP"| PublicTCP
    PublicTCP <==.-> Tunnel1
    Tunnel1 -.-> Squid
    Squid -.-> Origin
```

---

## 🛠️ TAHAP 0: Persiapan Awal Jarak Jauh (2 Menit)

1. Pastikan kedua laptop (Host 1 dan Host 2) sudah terhubung ke internet (Wi-Fi rumah / kosan masing-masing).
2. Pastikan `ssh` aktif di Windows (bawaan Windows 10/11 sudah ada).
3. **Konektivitas Host 1 $\leftrightarrow$ Host 2:**
   * **Jika berada di rumah masing-masing (Beda Jaringan):**
     * Pasang **[Tailscale](https://tailscale.com)** gratis di Host 1 dan Host 2 (login dengan 1 akun Google). Masing-masing laptop akan mendapat IP virtual `100.x.y.z` yang bisa saling ping dari mana saja.
   * **Jika berada di ruangan yang sama:**
     * Cukup gunakan IP Wi-Fi lokal Host 2 (misal `192.168.x.x`), sedangkan **klien (HP & Dosen) tetap mengakses secara online via internet publik**.

---

## 🚀 TAHAP 1: Eksekusi Sub-Tugas 2 (Reverse Proxy & Load Balancing)
> 💡 **Rekomendasi:** Tunjukkan Sub-Tugas 2 terlebih dahulu karena link HTTPS publiknya bisa langsung diklik oleh Dosen di chat Zoom/Google Meet!

### Langkah 1.1: Nyalakan 4 Server Backend di Host 2
1. Di Laptop Host 2, buka folder `tugas-3\host2\`
2. Double-click file:
   👉 **`start_cluster.bat`**
   * *Otomatis menyalakan:*
     - **Node 1** (Windows Native di port `5001`)
     - **Node 4** (Docker Container di port `5004`)
     - **Node 2 & Node 3** (Otomatis menginjeksi dan menyalakan server di VM 1 & VM 2 via script `start_vms_automatically.bat`)
3. *(Alternatif Manual jika VM dibuka tersendiri di VirtualBox):*
   * Di terminal **VM 1**: `sh server_vm.sh 5002 'Node 2 - Linux VM 1' '#22c55e'`
   * Di terminal **VM 2**: `sh server_vm.sh 5003 'Node 3 - Linux VM 2' '#eab308'`
4. Catat IP Host 2 (IP Tailscale `100.x.y.z` jika beda rumah, atau IP lokal jika satu ruangan), lalu kirim ke Host 1 via chat.

---

### Langkah 1.2: Nyalakan Reverse Proxy di Host 1
1. Di Laptop Host 1, buka folder `tugas-3\host1\`
2. Double-click file:
   👉 **`start_reverse_proxy.bat`**
3. Masukkan IP Host 2 tadi saat diminta.
4. Pilih opsi **`1`** (Python Native). Reverse Proxy langsung aktif di port `80`.

---

### Langkah 1.3: Buka Link Online Publik via Pinggy Tunnel (Host 1)
1. Di Laptop Host 1, buka folder `tugas-3\`
2. Double-click file:
   👉 **`start_tunnel_online.bat`**
3. Pilih opsi **`1`** (*Reverse Proxy & Load Balancer - Port 80*).
   > 💡 **Catatan Mengenai Password:** Pinggy **TIDAK memerlukan password**. Pinggy menggunakan sistem SSH Key gratis. Script `start_tunnel_online.bat` sudah otomatis membuat SSH key di laptop Host 1 jika belum ada. Jika sebelumnya muncul pertanyaan password, cukup tarik update terbaru (`git pull`) atau jalankan perintah `ssh-keygen -t ed25519 -N "" -f "%USERPROFILE%\.ssh\id_ed25519"`.
4. Jendela CMD Pinggy akan muncul menampilkan URL publik HTTPS, misalnya:
   ```text
   ==============================================================
   URL Publik: https://rxyz-123-456.free.pinggy.link
   ==============================================================
   ```
   *(Biarkan jendela CMD ini tetap terbuka selama sesi demo).*

---

### Langkah 1.4: Pembuktian Online di Hadapan Dosen & Aslab
1. **Bagikan URL Publik ke Chat Zoom / Google Meet:**
   * Bagikan link `https://rxyz-123-456.free.pinggy.link` ke dosen dan asisten lab.
2. **Uji dari HP Anda (Koneksi Seluler 4G/5G):**
   * Matikan Wi-Fi di HP Anda (murni gunakan paket data seluler).
   * Buka link tersebut di browser HP.
   * **Perlihatkan layar HP ke kamera/share screen sambil menekan Refresh:**
     * **Refresh 1:** Muncul kartu Biru $\rightarrow$ `Node 1 - Windows Native`
     * **Refresh 2:** Muncul kartu Hijau $\rightarrow$ `Node 2 - VirtualBox VM 1`
     * **Refresh 3:** Muncul kartu Kuning $\rightarrow$ `Node 3 - VirtualBox VM 2`
     * **Refresh 4:** Muncul kartu Ungu $\rightarrow$ `Node 4 - Docker Container`
     * **Refresh 5:** Kembali ke Node 1 (*Algoritma Round Robin terbukti bekerja secara live online!*).
3. **Uji Kuantitatif (Benchmark Otomatis):**
   * Di laptop mana saja (Host 2 atau laptop anggota lain di rumahnya), jalankan:
     ```bash
     python test_dummy_requests.py --url https://rxyz-123-456.free.pinggy.link -n 40
     ```
   * Terminal akan menampilkan respon 40 request dari internet dan tabel persentase rata **25.00%** per node!

---

## ⚡ TAHAP 2: Eksekusi Sub-Tugas 1 (Cached Proxy Squid Online)

### Langkah 2.1: Nyalakan Origin Web Server di Host 2
1. Di Laptop Host 2, buka folder `tugas-3\host2\`
2. Double-click file:
   👉 **`start_origin_server.bat`** (aktif di port `8080`).
3. Jika Host 2 di rumah terpisah, buka tunnel untuk port 8080 di Host 2:
   * Double-click `start_tunnel_online.bat` $\rightarrow$ pilih opsi `3`.
   * Salin URL Origin publik yang muncul (misal: `https://origin-jarkom.free.pinggy.link`).

---

### Langkah 2.2: Nyalakan Squid Proxy & Tunnel TCP di Host 1
1. Di Laptop Host 1, buka folder `tugas-3\host1\`
2. Double-click file:
   👉 **`start_squid.bat`** (Squid aktif di port `3128` + streaming log).
3. Di folder `tugas-3\`, double-click:
   👉 **`start_tunnel_online.bat`** $\rightarrow$ pilih opsi **`2`** (*Squid Caching Proxy - Port 3128*).
4. Jendela CMD Pinggy akan menampilkan Host dan Port TCP publik, misalnya:
   ```text
   ==============================================================
   TCP Relay:
   Host : a.pinggy.io
   Port : 43210
   ==============================================================
   ```

---

### Langkah 2.3: Konfigurasi Proxy di Smartphone (HP)
1. Buka menu **Settings** di HP $\rightarrow$ **Wi-Fi** $\rightarrow$ klik ikon Wi-Fi yang sedang tersambung.
2. Pilih menu **Proxy** $\rightarrow$ ubah ke **Manual**.
3. Isi sesuai output Pinggy tadi:
   * **Host Proxy:** `a.pinggy.io`
   * **Port:** `43210`
4. Klik **Simpan (Save)**.

---

### Langkah 2.4: Pembuktian Caching Online di Hadapan Dosen
1. **Akses Pertama (Cache MISS):**
   * Di browser HP, buka URL Origin Server (misal `http://origin-jarkom.free.pinggy.link/index.html` atau IP Host 2 port 8080).
   * **Host 2:** Terminal Origin mencatat log `[ORIGIN HIT]`.
   * **Host 1:** Terminal Squid mencatat **`TCP_MISS/200`** (Squid belum punya file dan mendownload dari Origin).
2. **Akses Kedua (Cache HIT):**
   * Di browser HP, tekan tombol **Refresh**.
   * **Host 2:** **TIDAK ADA LOG BARU YANG MASUK!**
   * **Host 1:** Terminal Squid mencatat **`TCP_MEM_HIT/200`** atau **`TCP_HIT/200`** (halaman disajikan instan 0ms dari cache lokal Squid di Host 1).
3. **Uji Ekstrem (Matikan Origin Server):**
   * Di Host 2, matikan `origin_server.py` (`Ctrl + C`).
   * Di HP, tekan **Refresh** lagi $\rightarrow$ **Halaman web tetap berhasil terbuka!**
   * Jelaskan ke dosen: *"Pak/Mas, server aslinya di Host 2 sudah dimatikan, namun klien HP dari internet tetap bisa mengakses website karena disuplai oleh cache Squid di Host 1."*

> [!IMPORTANT]
> Setelah demo selesai, matikan kembali proxy manual di Wi-Fi HP (ubah ke *Off/None*) agar HP dapat mengakses internet biasa lagi.

---

## 🎙️ TAHAP 3: Naskah Presentasi Siap Pakai saat Share Screen di Zoom / Google Meet

### 👤 Anggota 1 (Host 1 - Membuka Presentasi):
> *"Selamat pagi/siang Bapak/Ibu Dosen dan Mas/Mbak Asisten. Pada demonstrasi Tugas 3 ini, kelompok kami mengimplementasikan arsitektur **Reverse Proxy Load Balancer** dan **Cached Proxy** yang telah kami online-kan ke internet publik menggunakan encrypted tunneling, sehingga dapat diakses secara live lintas jaringan."*

### 👤 Anggota 2 (Host 2 - Menjelaskan Kluster Server):
> *"Di Laptop Host 2, kami mengorkestrasikan 4 instance backend di 4 lingkungan komputasi yang terisolasi:*
> * *Node 1 berjalan di Windows Native (port 5001).*
> * *Node 2 berjalan di VirtualBox VM 1 Alpine Linux (port 5002 via NAT port forward).*
> * *Node 3 berjalan di VirtualBox VM 2 Alpine Linux (port 5003 via NAT port forward).*
> * *Node 4 berjalan di Docker Container WSL 2 (port 5004).*
> 
> *Seluruh server ini terhubung ke Reverse Proxy di Host 1."*

### 👤 Anggota 3 (Memperagakan Akses Online & Benchmark):
> *(Share screen browser atau arahkan kamera ke HP)*
> *"Kami membuka link publik HTTPS Pinggy ini langsung dari smartphone yang menggunakan paket data seluler 4G mandiri tanpa Wi-Fi lokal. Bapak/Ibu dosen juga dapat ikut mengklik link yang kami kirimkan di chat Zoom.*
> 
> *Ketika kami refresh, algoritma Round Robin secara bergiliran mendistribusikan beban ke Windows, VM 1, VM 2, dan Docker.*
> 
> *Saat kami jalankan stress test 40 requests dari terminal, beban terbagi seimbang sempurna masing-masing tepat 25%."*

### 👤 Anggota 4 (Menjelaskan Cached Proxy Squid):
> *"Selanjutnya untuk Cached Proxy, Squid di Host 1 kami hubungkan ke internet melalui relay TCP. Ketika klien luar mengakses web pertama kali terjadi **Cache MISS**, dan pada akses kedua terjadi **Cache HIT** dengan latensi 0ms.*
> 
> *Bahkan saat Origin Server di Host 2 dimatikan, website tetap berhasil diakses dari internet karena disajikan langsung dari memori cache Squid."*

---

## 🧠 Cheatsheet Tanya-Jawab Pengujian Online (FAQ)

1. **T: Mengapa kelompok Anda memilih menggunakan port tunneling (Pinggy) untuk demo?**
   * **Jawab:** Karena di dunia industri nyata, server aplikasi berada di data center privat. Port tunneling merepresentasikan bagaimana sebuah edge gateway mengekspos layanan internal ke internet publik secara aman tanpa harus membuka port router fisik (*NAT traversal / zero firewall configuration*).

2. **T: Mengapa klien diarahkan ke URL Reverse Proxy Host 1, bukan langsung ke IP Host 2?**
   * **Jawab:** Itulah esensi **Reverse Proxy**. Tujuannya menyembunyikan arsitektur internal backend demi keamanan (*security through obscurity*), menyediakan *single entry point* publik, dan mendistribusikan beban secara merata (*load balancing*). Klien tidak perlu tahu IP privat dari 4 server di Host 2.

3. **T: Apa bedanya Forward Proxy (Squid) dan Reverse Proxy (Nginx)?**
   * **Jawab:** 
     * **Forward Proxy (Squid)** bertindak mewakili **klien** untuk keluar mengakses internet/server lain (caching, penghematan bandwidth, filtering).
     * **Reverse Proxy (Nginx)** bertindak mewakili **server backend** untuk menerima request dari klien luar (load balancing, SSL termination, proteksi backend).
