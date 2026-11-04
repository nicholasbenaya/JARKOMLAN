# Panduan Demonstrasi Online (Akses Internet Jarak Jauh) - Model A
## Praktikum Jaringan Komputer dan LAN (JARKOMLAN) - Tugas 3
### Topik: Cached Proxy (Squid) & Reverse Proxy Load Balancer (Nginx) via Pinggy Tunneling

Panduan ini disusun khusus untuk skenario pengujian dan demonstrasi **jarak jauh (online)** dengan arsitektur **Model A**:
* **Host 1 (Laptop 1):** Pusat Server, Reverse Proxy Load Balancer, Squid Proxy, dan Kluster 4 Backend.
* **Host 2 (Laptop 2):** Partner Luar / Origin Web Server & Penguji Beban (*Traffic Generator*).
* **Smartphone (HP):** Pengujian dari browser HP menggunakan **paket data seluler (4G/5G)** tanpa perlu tethering Wi-Fi.

---

## 1. Arsitektur Jaringan Online Model A (Port Tunneling)

Dengan memanfaatkan **Pinggy SSH Reverse Tunneling** (melalui port 443 outbound yang kebal blokir firewall), port lokal Host 1 diekspos secara aman ke *edge server* publik:

```mermaid
flowchart TB
    subgraph Internet["Jaringan Internet Publik (Anywhere / 4G / 5G / Zoom)"]
        direction TB
        HP["📱 Smartphone HP (Paket Data 4G/5G)\nAkses Browser: https://xxxx.free.pinggy.link"]
        H2["💻 HOST 2 (Laptop Teman Remote)\nPenguji Beban: run_load_test.bat"]
    end

    subgraph PinggyCloud["Pinggy Edge Cloud Infrastructure"]
        EdgeHTTP["Public HTTPS Edge Gateway\n(free.pinggy.link:443)"]
        EdgeTCP["Public TCP Proxy Relay\n(a.pinggy.io:XXXXX)"]
    end

    subgraph LocalSetup["Lingkungan Praktikum (Model A)"]
        subgraph H1["Host 1 (Laptop 1 - Server Utama, Backend Cluster & Proxy)"]
            Tunnel["SSH Reverse Tunnel Client\n(start_tunnel_online.bat)"]
            Proxy["Reverse Proxy / Load Balancer\n(Port 80)"]
            Squid["Squid Proxy Cache\n(Port 3128)"]
            Cluster["Kluster 4 Node Backend:\n• Port 5001 (Windows Native)\n• Port 5002 (VirtualBox VM 1)\n• Port 5003 (VirtualBox VM 2)\n• Port 5004 (Docker Container)"]
        end

        subgraph H2Local["Host 2 (Laptop 2 - Origin Server)"]
            Origin["Origin Web Server\n(Port 8080)"]
        end
    end

    HP -->|"1. Request via Internet (HTTPS)"| EdgeHTTP
    H2 -->|"1. Request via Internet (HTTPS)"| EdgeHTTP
    EdgeHTTP <==|"2. Encrypted SSH Tunnel (Port 443)"|== Tunnel
    Tunnel -->|"3. Forward ke Port 80"| Proxy
    Proxy -->|"4. Round Robin Balancing"| Cluster
```

---

## 2. Cara Kerja Sub-Tugas 2: Reverse Proxy Online (Paling Direkomendasikan untuk Demo)

Skenario ini membuktikan ke Dosen/Aslab bahwa arsitektur cluster Anda bisa diakses secara publik layaknya aplikasi cloud modern.

### Langkah demi Langkah:

1. **Jalankan Backend Cluster & Reverse Proxy di Host 1:**
   * Di Host 1, double-click [`tugas-3/host1/start_cluster.bat`](file:///c:/Users/kegz/Desktop/Folder%20iko/Projects%20Local/JARKOMLAN/tugas-3/host1/start_cluster.bat).
   * Skrip akan otomatis menyalakan Node 1 (Windows: 5001), Node 4 (Docker: 5004), dan Reverse Proxy (Port 80).
   * Jalankan VM 1 dan VM 2 di VirtualBox:
     ```bash
     sh server_vm.sh 5002 "Node 2 - Linux VM 1" "#22c55e" # Di VM 1
     sh server_vm.sh 5003 "Node 3 - Linux VM 2" "#eab308" # Di VM 2
     ```
2. **Buka Akses Online via Tunnel di Host 1:**
   * Di Host 1, double-click file:
     👉 [`tugas-3/start_tunnel_online.bat`](file:///c:/Users/kegz/Desktop/Folder%20iko/Projects%20Local/JARKOMLAN/tugas-3/start_tunnel_online.bat)
   * Pilih opsi `[1]` (*Reverse Proxy & Load Balancer - Port 80*).
   * Sebuah jendela CMD baru akan muncul menampilkan URL publik, contohnya:
     ```
     ==============================================================
     URL Publik: https://rxyz-123-456.free.pinggy.link
     ==============================================================
     ```
   *(Biarkan jendela CMD ini tetap terbuka selama sesi pengujian).*
3. **Pengujian Langsung dari HP (Paket Data 4G/5G):**
   * Matikan Wi-Fi di HP Anda (pastikan murni memakai kuota seluler / data internet).
   * Buka browser Chrome / Safari di HP, lalu ketik URL publik dari Pinggy tersebut.
   * **Hasil:** Halaman web langsung muncul!
   * Tekan tombol **Refresh** di HP:
     * Refresh 1 $\rightarrow$ Kartu Biru: `Node 1 - Windows 11 Native`
     * Refresh 2 $\rightarrow$ Kartu Hijau: `Node 2 - VirtualBox VM 1`
     * Refresh 3 $\rightarrow$ Kartu Kuning: `Node 3 - VirtualBox VM 2`
     * Refresh 4 $\rightarrow$ Kartu Ungu: `Node 4 - Docker Container`
     * Refresh 5 $\rightarrow$ Kembali ke Node 1.
4. **Uji Beban Dummy (Benchmark) dari Laptop Teman (Host 2 Jarak Jauh):**
   * Teman Anda di rumahnya membuka folder `tugas-3/host2/` dan menjalankan:
     👉 `run_load_test.bat`
   * Masukkan URL publik: `https://rxyz-123-456.free.pinggy.link`
   * Terminal Host 2 akan mencetak respon 40 request secara real-time dan menunjukkan persentase distribusi tepat 25% untuk setiap node!

---

## 3. Cara Kerja Sub-Tugas 1: Cached Proxy Squid Online

Skenario ini membuktikan fitur caching Squid bekerja meskipun klien mengakses dari jaringan luar.

### Langkah demi Langkah:

1. **Jalankan Origin Server di Host 2:**
   * Di Host 2, double-click `start_origin_server.bat` (aktif di port `8080`).
   * *(Jika Host 2 terpisah jarak jauh, Host 2 juga bisa membuka tunnel port 8080 via `start_tunnel_online.bat` opsi [3]).*
2. **Jalankan Squid Proxy di Host 1:**
   * Di Host 1, double-click [`tugas-3/host1/start_squid.bat`](file:///c:/Users/kegz/Desktop/Folder%20iko/Projects%20Local/JARKOMLAN/tugas-3/host1/start_squid.bat) (aktif di port `3128`).
3. **Buka Tunnel TCP untuk Squid di Host 1:**
   * Di Host 1, double-click [`tugas-3/start_tunnel_online.bat`](file:///c:/Users/kegz/Desktop/Folder%20iko/Projects%20Local/JARKOMLAN/tugas-3/start_tunnel_online.bat) $\rightarrow$ pilih opsi `[2]`.
   * Di jendela CMD akan muncul alamat TCP publik, contohnya:
     ```
     Host: a.pinggy.io
     Port: 43210
     ```
4. **Pengaturan di Klien Luar (HP / Laptop Teman):**
   * Masuk ke pengaturan Wi-Fi HP / Laptop teman $\rightarrow$ set Manual Proxy:
     * **Proxy Host:** `a.pinggy.io`
     * **Proxy Port:** `43210`
   * Buka URL web dari browser.
5. **Pembuktian Caching:**
   * Permintaan pertama tercatat **`TCP_MISS`** di terminal log Squid Host 1.
   * Permintaan kedua (refresh) tercatat **`TCP_HIT`** secara instan dari cache lokal Squid!

---

## 4. Naskah Presentasi Demo Online (Untuk Google Meet / Zoom)

Gunakan alur dan naskah ini saat giliran kelompok Anda presentasi daring:

> **1. Pembukaan (Share Screen Terminal & Browser HP):**
> *"Selamat pagi/siang Bapak/Ibu Dosen dan Rekan Asisten. Pada demonstrasi Tugas 3 ini, kelompok kami mengimplementasikan sistem **Reverse Proxy Load Balancer** dan **Cached Proxy** yang telah kami online-kan ke internet publik.*
> 
> *Saat ini di Host 1, kami mengorkestrasikan 4 node backend di 4 lingkungan berbeda: Windows Native, VM 1 Alpine, VM 2 Alpine, dan Docker WSL 2. Di Host 1 juga berjalan Reverse Proxy sebagai gateway tunggal yang kami buka ke publik via encrypted tunnel.*
> 
> *Untuk membuktikan sistem ini dapat diakses secara live oleh end-user, saya membuka URL publik ini langsung dari smartphone saya menggunakan koneksi seluler 4G mandiri.*
> 
> *(Sambil me-refresh layar HP di depan kamera/share screen)* *Dapat dilihat bahwa algoritma Round Robin membagi beban secara merata melayani request saya bergantian ke Windows, VM 1, VM 2, dan Docker tanpa bottleneck.*
> 
> *Ketika rekan saya menjalankan load test 40 requests dari rumahnya (Host 2), seluruh beban terdistribusi presisi masing-masing 25%."*

> **2. Memperagakan Cached Proxy (Squid):**
> *"Selanjutnya untuk Cached Proxy, Squid aktif di Host 1 port 3128 dan Origin Web Server aktif di Host 2 port 8080. Ketika klien luar mengakses data pertama kali, terjadi **Cache MISS** di mana data diunduh dari Origin Server Host 2. Pada akses kedua, terjadi **Cache HIT** dengan latensi 0ms karena disuplai langsung dari disk cache Squid. Jika Origin Server di Host 2 kami matikan, halaman tetap bisa dibuka oleh klien dari internet."*

---

## 5. Tips & Pertanyaan Seputar Online Tunneling (FAQ)

1. **T: Berapa lama masa aktif link publik Pinggy gratis?**
   * *Jawab:* Sesi gratis bertahan selama 60 menit per koneksi. Jika sesi habis, cukup tutup jendela tunnel CMD dan jalankan kembali `start_tunnel_online.bat` untuk mendapatkan link baru.
2. **T: Apakah aman membuka port laptop ke internet publik?**
   * *Jawab:* Sangat aman. Tunnel hanya meneruskan lalu lintas HTTP/TCP ke port spesifik (port 80 atau 3128) yang kita definisikan. Seluruh sistem file, dokumen pribadi, dan port sistem lainnya di Windows tetap tertutup dan terlindungi.
3. **T: Apakah butuh registrasi atau kartu kredit?**
   * *Jawab:* Tidak perlu sama sekali. Pinggy memanfaatkan port 443 SSH bawaan Windows tanpa perlu API key atau akun.
