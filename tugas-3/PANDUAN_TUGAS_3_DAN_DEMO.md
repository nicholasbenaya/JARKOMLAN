# Panduan Praktis & Naskah Demonstrasi Tugas 3 (Host 1, Host 2, & HP)
## Praktikum Jaringan Komputer dan LAN (JARKOMLAN)
### Topik: Cached Proxy (Squid) & Reverse Proxy Load Balancing (Nginx)

Dokumen ini disusun sebagai **panduan operasional teknis** bagi seluruh anggota kelompok agar paham tugas masing-masing dan siap mendemokan sistem secara mulus di hadapan Dosen Penguji dan Asisten Laboratorium.

---

## 1. Persiapan Konektivitas & Alamat IP (SOP Awal)

Agar kedua laptop dan smartphone dapat berkomunikasi tanpa gangguan firewall kampus:
1. **Gunakan 1 Hotspot Bersama:** Salah satu anggota menyalakan hotspot HP (misal: "HOTSPOT-JARKOM").
2. Hubungkan **Laptop Host 1**, **Laptop Host 2**, dan **Smartphone HP** ke hotspot tersebut.
3. Catat alamat IP masing-masing:
   * **Host 1 (PowerShell):** `ipconfig` $\rightarrow$ catat IPv4 Wireless LAN (contoh: `192.168.43.10`).
   * **Host 2 (PowerShell):** `ipconfig` $\rightarrow$ catat IPv4 Wireless LAN (contoh: `192.168.43.20`).
4. **Uji Ping Lintas Host:**
   * Di Host 2, buka terminal: `ping 192.168.43.10`
   * Pastikan status `Reply from ...` dengan loss 0%.
   *(Jika Request Timed Out, nonaktifkan sementara Windows Defender Firewall pada profil Jaringan Privat).*

---

## 2. Pelaksanaan Sub-Tugas 1: Cached Proxy (Squid)

### Tujuan Demonstrasi
Membuktikan bahwa Squid Proxy di Host 1 mampu memotong jalur komunikasi ke Origin Server di Host 2 setelah permintaan pertama berhasil di-cache (*Cache Hit*).

### Langkah Operasional

#### A. Di Host 2 (Origin Server):
1. Masuk ke direktori origin web:
   ```bash
   cd tugas-3/host2/origin_web
   python origin_server.py
   ```
2. Server akan aktif di port `8080`. Perhatikan terminal ini, setiap kali ada request langsung dari luar, terminal akan mencetak `[ORIGIN HIT]`.

#### B. Di Host 1 (Squid Proxy):
1. Jalankan Squid Proxy via Docker Compose:
   ```bash
   cd tugas-3/host1/squid
   docker compose up -d
   ```
2. Monitor log akses Squid secara real-time:
   ```bash
   docker exec -it jarkom-squid-proxy tail -f /var/log/squid/access.log
   ```

#### C. Di Smartphone (HP):
1. Buka menu **Settings** $\rightarrow$ **Wi-Fi** $\rightarrow$ klik tanda ikon info/gear pada Wi-Fi yang terhubung.
2. Pilih menu **Proxy** $\rightarrow$ ubah dari *None* menjadi **Manual**.
3. Isi parameter:
   * **Proxy Host Name:** Alamat IP Host 1 (contoh: `192.168.43.10`)
   * **Proxy Port:** `3128`
4. Simpan konfigurasi.

#### D. Skenario Pembuktian saat Demo:
1. **Akses Pertama (Cache MISS):**
   * Di browser HP, buka: `http://192.168.43.20:8080/index.html` (ganti dengan IP Host 2).
   * **Amati Terminal Host 2:** Muncul baris log `[ORIGIN HIT] ... GET /index.html`.
   * **Amati Terminal Squid Host 1:** Muncul log berlabel **`TCP_MISS/200`**. Artinya Squid belum punya datanya, sehingga harus mendownload dari Host 2.
2. **Akses Kedua (Cache HIT):**
   * Di browser HP, tekan tombol **Refresh**.
   * **Amati Terminal Host 2:** **TIDAK ADA LOG BARU YANG MASUK!** (Host 2 tidak dihubungi sama sekali).
   * **Amati Terminal Squid Host 1:** Muncul log berlabel **`TCP_MEM_HIT/200`** atau **`TCP_HIT/200`**. Artinya konten disuplai 100% dari cache lokal Squid di Host 1!
3. **Uji Ekstrem (Matikan Origin Server):**
   * Di terminal Host 2, matikan `origin_server.py` dengan menekan `Ctrl + C`.
   * Di browser HP, tekan **Refresh** lagi $\rightarrow$ **Halaman tetap berhasil terbuka secara instan!**
   * Jelaskan ke dosen: *"Pak/Mas, server aslinya sudah kami matikan, tetapi klien HP tetap bisa mengakses website karena Squid menyajikannya dari cache lokal."*

> [!TIP]
> Setelah demo Cached Proxy selesai, kembalikan pengaturan Proxy di Wi-Fi HP menjadi **None / Off** sebelum melanjutkan ke Sub-Tugas 2.

---

## 3. Pelaksanaan Sub-Tugas 2: Reverse Proxy & Load Balancing (Nginx)

### Tujuan Demonstrasi
Membuktikan bahwa Reverse Proxy (Nginx / Python Native) di Host 1 mampu mendistribusikan lalu lintas dari klien luar (HP & Host 2) secara merata ke 4 backend lokal (**Windows, VM 1, VM 2, dan Docker**).

### Langkah Operasional

#### A. Di Host 1 (Laptop Anda - Backend Cluster & Reverse Proxy):
1. Buka folder `tugas-3/host1/`, double-click:
   👉 [`start_cluster.bat`](host1/start_cluster.bat)
   *Skrip ini akan otomatis menyalakan Node 1 (Windows: port 5001), Node 4 (Docker: port 5004), dan Reverse Proxy (Port 80).*
2. Nyalakan VirtualBox:
   * Di **VM 1**, jalankan terminal:
     ```bash
     sh server_vm.sh 5002 "Node 2 - Linux VM 1" "#22c55e"
     ```
   * Di **VM 2**, jalankan terminal:
     ```bash
     sh server_vm.sh 5003 "Node 3 - Linux VM 2" "#eab308"
     ```
3. *Pastikan VirtualBox Port Forwarding sudah aktif (sudah dikonfigurasi via `setup_vbox_network.ps1`):*
   * VM 1: Host Port `5002` $\rightarrow$ Guest Port `5002`.
   * VM 2: Host Port `5003` $\rightarrow$ Guest Port `5003`.

#### B. Di Host 2 (Laptop Teman - Traffic Generator):
Teman Anda tidak perlu menjalankan server atau konfigurasi berat! Cukup gunakan skrip penguji:
* Buka folder `tugas-3/host2/`, double-click:
  👉 [`run_load_test.bat`](host2/run_load_test.bat)
* Masukkan IP Host 1 Anda (contoh: `192.168.43.10`).

#### C. Skenario Pembuktian saat Demo:

##### 1. Demonstrasi Visual Menggunakan Smartphone (HP):
1. Pastikan Wi-Fi HP terhubung ke hotspot yang sama (Proxy Wi-Fi dalam kondisi **Off**).
2. Buka browser HP (Google Chrome / Safari).
3. Ketik alamat URL: `http://192.168.43.10/` (IP Host 1 Port 80).
4. **Tunjukkan layar HP ke Dosen/Aslab sambil menekan tombol Refresh:**
   * **Refresh 1:** Kartu biru menyala $\rightarrow$ `"Node 1: Windows 11 Native"`.
   * **Refresh 2:** Kartu hijau menyala $\rightarrow$ `"Node 2: VirtualBox Linux VM 1"`.
   * **Refresh 3:** Kartu kuning menyala $\rightarrow$ `"Node 3: VirtualBox Linux VM 2"`.
   * **Refresh 4:** Kartu ungu menyala $\rightarrow$ `"Node 4: Docker Container (WSL 2)"`.
   * **Refresh 5:** Kembali ke Node 1 (siklus *Round Robin* terbukti!).

##### 2. Demonstrasi Kuantitatif dengan Skrip Dummy Benchmark dari Host 2:
1. Di laptop Host 2, jalankan `run_load_test.bat` (atau terminal):
   ```bash
   python test_dummy_requests.py --url http://192.168.43.10/ -n 40
   ```
2. Skrip akan mengirim 40 permintaan secara cepat dan menampilkan tabel distribusi:
   ```
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
   *Hasil ini memberikan bukti kuantitatif bahwa pembagian beban berjalan presisi 1:1:1:1.*
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
   *Hasil ini memberikan bukti matematis bahwa pembagian beban berjalan sempurna 1:1:1:1.*

---

## 4. Naskah Presentasi (Elevator Pitch untuk Demo)

Ketika giliran kelompok Anda dipanggil untuk demo, gunakan naskah terstruktur ini:

> **Salam & Pengantar:**
> *"Selamat pagi/siang Bapak/Ibu Dosen dan Mas/Mbak Asisten. Pada Tugas 3 ini, kelompok kami mengimplementasikan dua arsitektur perantara jaringan: **Cached Proxy** menggunakan Squid dan **Reverse Proxy Load Balancer** menggunakan Nginx, yang diuji secara langsung menggunakan smartphone sebagai end-user client."*

> **Penjelasan Tugas 1 (Cached Proxy):**
> *"Pertama, untuk Cached Proxy, kami menempatkan Squid di Host 1 dan Origin Web Server di Host 2. Ketika smartphone kami mengakses web pertama kali, terjadi **Cache MISS**, di mana Squid mengambil file dari Host 2 lalu menyimpannya di direktori cache. Pada akses kedua, terjadi **Cache HIT** dengan latensi mendekati 0 milidetik, di mana Squid langsung menyajikan dari memori lokal. Kami juga membuktikan dengan mematikan Origin Server di Host 2, halaman web tetap berhasil dimuat dari HP."*

> **Penjelasan Tugas 2 (Reverse Proxy):**
> *"Kedua, untuk Reverse Proxy dan Load Balancing, Host 2 bertindak sebagai gerbang tunggal Nginx. Di belakangnya, Host 1 mengorkestrasikan 4 node backend di 4 lingkungan komputasi berbeda: Windows Native, VM 1 Alpine, VM 2 Alpine, dan Docker Container. Melalui browser HP yang di-refresh berulang kali, terlihat algoritma **Round Robin** membagi beban secara bergantian ke tiap node. Saat kami jalankan benchmark 40 requests, beban terdistribusi presisi masing-masing 25% tanpa ada server yang mengalami bottleneck."*

---

## 5. Pertanyaan Kritis yang Sering Ditanyakan Asisten Lab (FAQ)

1. **T: Mengapa klien diarahkan ke port 80 Host 2, bukan langsung ke port 5001–5004 di Host 1?**
   * *Jawab:* Itulah fungsi utama **Reverse Proxy**. Klien tidak boleh mengetahui topologi dan port internal backend demi alasan keamanan dan skalabilitas (*single entry point*). Klien hanya berurusan dengan Reverse Proxy, dan Reverse Proxy-lah yang bertugas mendistribusikan beban.

2. **T: Apa bedanya Forward Proxy dengan Reverse Proxy?**
   * *Jawab:* **Forward Proxy** (seperti Squid) bertindak mewakili **klien** untuk mengakses server di luar/internet. Sebaliknya, **Reverse Proxy** (seperti Nginx) bertindak mewakili **server backend** untuk melayani klien luar.

3. **T: Mengapa di VirtualBox harus menggunakan Port Forwarding NAT?**
   * *Jawab:* Karena mode NAT mengisolasi VM di dalam subnet privat VirtualBox (`10.0.2.0/24`) yang tidak bisa di-routing langsung dari jaringan luar. Dengan Port Forwarding, port Host fisik (misal 5002) dipetakan ke port internal VM (5002), sehingga Nginx di Host 2 bisa menjangkaunya melalui IP Host 1.
