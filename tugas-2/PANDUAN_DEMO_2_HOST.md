# Panduan & Naskah Demonstrasi Kolaboratif (Host 1 & Host 2)
## Tugas 2 Praktikum Jaringan Komputer dan Komunikasi Data (JARKOMLAN)

Dokumen ini disusun sebagai panduan operasional dan naskah presentasi duet saat mendemokan arsitektur IoT terdistribusi di hadapan Dosen Penguji dan Asisten Laboratorium.

---

## 1. Pembagian Peran & Topologi

```
┌────────────────────────────────────────────────────────┐       ┌──────────────────────────────────────┐
│                    HOST 1 (LAPTOP 1)                   │       │          HOST 2 (LAPTOP 2)           │
│                                                        │       │                                      │
│  [VirtualBox VM: Alpine Linux]                         │  LAN  │  [Docker Container / Local Python]   │
│   └── Web Server Dashboard (Port 8080)                 │  atau │   └── IoT Sensor Publisher Node      │
│        │ (10.0.2.2:3306)                               │Tunnel │        │                             │
│        ▼                                               │ ◄───  │        ▼                             │
│  [Docker WSL 2 Engine]                                 │       │   MQTT Publish (Port 1883/TCP)       │
│   ├── MQTT Broker Mosquitto (Port 1883) ◄──────────────┼───────┘                                      │
│   ├── MySQL 8.0 Database (Port 3306)                   │       │  [Browser Laptop 2]                  │
│   └── MQTT Subscriber Worker (Bridge Ingest)           │ ────► │   └── Akses Dashboard (Port 8080)    │
└────────────────────────────────────────────────────────┘       └──────────────────────────────────────┘
```

| Atribut | Host 1 (Hub & Sink Data) | Host 2 (Edge IoT Source) |
| :--- | :--- | :--- |
| **Peran Utama** | Pusat Server, Broker, DB, & Web Dashboard di VM | Edge IoT Publisher & Consumer Client |
| **Komponen Aktif** | • Docker: `mosquitto`, `mysql`, `subscriber`<br>• VirtualBox: `VM1-Jarkom` (Flask Web Server) | • Docker: `jarkom-mqtt-publisher-host2` (atau skrip `publisher.py`)<br>• Browser Chrome / Firefox |
| **Port Listening** | • `1883` (MQTT Broker TCP)<br>• `3306` (MySQL TCP)<br>• `8080` (Web Server VM via NAT) | Tidak membuka port listening (hanya outbound client) |

---

## 2. Persiapan Konektivitas (Pilih Salah Satu Skenario)

### Skenario A: Offline (Tatap Muka / Hotspot HP Bersama)
> **Gunakan skenario ini** jika demo dilakukan langsung di lab/kelas menggunakan tethering hotspot HP (menghindari port blocking pada Wi-Fi kampus).

1. Salah satu host menyalakan **Hotspot HP**. Kedua laptop wajib terhubung ke Wi-Fi Hotspot yang sama.
2. Di **Host 1**, buka PowerShell dan cek IP Wi-Fi:
   ```powershell
   ipconfig
   # Catat IPv4 Wireless LAN, misalnya: 192.168.43.15
   ```
3. Di **Host 2**, buka file [`tugas-2/host2/docker/docker-compose.yml`](file:///c:/Users/kegz/Desktop/Folder%20iko/Projects%20Local/JARKOMLAN/tugas-2/host2/docker/docker-compose.yml):
   ```yaml
   environment:
     MQTT_BROKER_HOST: "192.168.43.15"  # Ganti dengan IP Host 1
     MQTT_BROKER_PORT: "1883"
   ```
4. Dashboard diakses oleh Host 2 melalui: `http://192.168.43.15:8080`.

---

### Skenario B: Online (Jarak Jauh / Port Tunneling Pinggy)
> **Gunakan skenario ini** jika demo dilakukan secara daring (Zoom / Google Meet) atau jika port lokal dibatasi.

1. Di **Host 1**, buka File Explorer lalu double-click:
   [`tugas-2\start_internet_tunnel.bat`](file:///c:/Users/kegz/Desktop/Folder%20iko/Projects%20Local/JARKOMLAN/tugas-2/start_internet_tunnel.bat)
   *Dua jendela CMD akan muncul dan tetap aktif.*
2. Salin alamat yang muncul di jendela CMD Host 1:
   * **Tunnel MQTT (TCP):** misal `tcp://gcdyg-182-8-97-149.run.pinggy-free.link:36219`
   * **Tunnel Web (HTTPS):** misal `https://kqaem-2404-c0-b601.run.pinggy-free.link`
3. Di **Host 2**, buka [`tugas-2/host2/docker/docker-compose.yml`](file:///c:/Users/kegz/Desktop/Folder%20iko/Projects%20Local/JARKOMLAN/tugas-2/host2/docker/docker-compose.yml):
   ```yaml
   environment:
     MQTT_BROKER_HOST: "gcdyg-182-8-97-149.run.pinggy-free.link"
     MQTT_BROKER_PORT: "36219"
   ```
4. Dashboard diakses oleh Host 2 dan Penguji melalui URL HTTPS tunnel Web di atas.

---

## 3. Skenario Demonstrasi Duet (Step-by-Step)

### Babak 1: Pembukaan & Penjelasan Arsitektur Sistem
* **Durasi:** ~1 Menit
* **Presenter:** Host 1 & Host 2 bergantian

> **Host 1:**  
> *"Selamat pagi/siang Bapak/Ibu Dosen dan Mas/Mbak Asisten. Pada Tugas 2 JARKOMLAN ini, kelompok kami mengimplementasikan arsitektur pipeline IoT terdistribusi multi-host. Host 1 bertindak sebagai sentral backend yang mengelola MQTT Broker Mosquitto, Database MySQL, Subscriber Worker pada Docker WSL 2, serta Web Server Dashboard yang diisolasi di dalam Virtual Machine Linux Alpine."*

> **Host 2:**  
> *"Sedangkan Host 2 bertindak sebagai Edge IoT Node yang menjalankan container Docker Publisher untuk mengirimkan telemetri sensor lingkungan seperti suhu, kelembapan, dan tegangan secara periodik ke Host 1 menggunakan protokol MQTT."*

---

### Babak 2: Pembuktian Jaringan & Isolasi Web Server di VM Linux (Host 1)
* **Durasi:** ~2 Menit
* **Presenter:** Host 1
* **Tindakan di Layar Laptop 1:**

1. **Buka jendela VirtualBox VM Alpine (`VM1-Jarkom`):**
   ```sh
   ip addr show eth0
   ```
   > **Host 1 Bicara:**  
   > *"Dapat dilihat pada interface `eth0`, VM Linux kami menerima IP privat `10.0.2.15/24` dari DHCP VirtualBox mode NAT."*

2. **Tunjukkan Gateway Host (`10.0.2.2`):**
   ```sh
   ip route show
   ```
   > **Host 1 Bicara:**  
   > *"Default gateway VM mengarah ke `10.0.2.2`. Di VirtualBox NAT, IP `10.0.2.2` adalah alamat gateway standar yang memetakan koneksi langsung ke Host Windows tempat database Docker berjalan."*

3. **Uji Layer 3 (ICMP) vs Layer 4 (TCP Netcat):**
   ```sh
   ping -c 2 10.0.2.2
   nc -zv 10.0.2.2 3306
   nc -zv 10.0.2.2 1883
   ```
   > **Host 1 Bicara:**  
   > *"Ping membuktikan konektivitas kabel/Layer 3 ke host dengan RTT di bawah 1 ms. Selanjutnya dengan perintah `nc -zv`, kami memverifikasi keterbukaan port TCP Layer 4. Port 3306 (MySQL) dan Port 1883 (Mosquitto) berstatus open dan siap melayani permintaan."*

4. **Tunjukkan Web Server aktif di dalam VM:**
   ```sh
   ps | grep python
   ```
   *(Terlihat proses `python3 app.py` sedang berjalan di port 8080).*

---

### Babak 3: Pembuktian Container Docker & Standardisasi Kontrak (Host 2)
* **Durasi:** ~1.5 Menit
* **Presenter:** Host 2
* **Tindakan di Layar Laptop 2:**

1. **Buka file `docker-compose.yml` di VS Code / Terminal:**
   ```bash
   cat docker-compose.yml
   ```
   > **Host 2 Bicara:**  
   > *"Pada Host 2, service publisher kami dikemas dalam Dockerfile berbasis `python:3.11-slim`. Di sini kami mengarahkan target broker ke alamat Host 1 dengan topic `jarkom/sensor/telemetry` dan interval transmisi 3 detik."*

2. **Jelaskan Kontrak JSON & Normalisasi 3NF:**
   > **Host 2 Bicara:**  
   > *"Sebelum integrasi, kelompok kami telah menyusun SOP kontrak data. Payload dikirim dalam format JSON terstruktur:*
   > ```json
   > {
   >   \"device_id\": \"HOST2-IOT-NODE\",
   >   \"seq\": 12,
   >   \"temperature\": 29.4,
   >   \"humidity\": 65.2,
   >   \"voltage\": 3.3
   > }
   > ```
   > *"Struktur ini telah memenuhi normalisasi database di Host 1 sehingga tidak menimbulkan parsing conflict maupun integritas data yang terganggu."*

---

### Babak 4: Demonstrasi Live Integrasi Real-Time (Duet)
* **Durasi:** ~2.5 Menit
* **Presenter:** Host 1 & Host 2 serentak

1. **Tampilan Awal Dashboard:**
   * **Host 1** membuka browser di Laptop 1: `http://localhost:8080`
   * **Host 2** membuka browser di Laptop 2: alamat URL Web Dashboard Host 1
   * *Tunjukkan:* Badge status database berwarna hijau **"DB Terhubung (Latency ~100 ms)"**.
   * *Tunjukkan:* Tabel telemetri sebelum Host 2 aktif.

2. **Host 2 Mengaktifkan Publisher:**
   Di terminal Laptop 2, jalankan:
   ```bash
   docker compose up -d
   docker logs -f jarkom-mqtt-publisher-host2
   ```
   *Layar Laptop 2 mencetak log transmisi paket setiap 3 detik:*
   `[INFO] [MQTT-PUBLISHER-HOST2] Terkirim paket seq #1 ke broker...`

3. **Host 1 Membuktikan Ingestion di Subscriber:**
   Di PowerShell Laptop 1, jalankan:
   ```powershell
   docker logs -f jarkom-mqtt-subscriber
   ```
   *Layar Laptop 1 mencetak seketika:*
   `[INFO] [MQTT-SUBSCRIBER] Menerima pesan pada topik [jarkom/sensor/telemetry]: {"device_id": "HOST2-IOT-NODE", ...}`  
   `[INFO] [MQTT-SUBSCRIBER] Berhasil menyimpan data dari [HOST2-IOT-NODE] ke MySQL.`

4. **Verifikasi Real-Time di Dashboard Browser (Kedua Laptop):**
   > **Host 1 & Host 2 Bicara:**  
   > *"Dapat dilihat pada layar browser Laptop 1 dan Laptop 2 secara serentak, tanpa perlu me-refresh halaman (menggunakan background auto-polling AJAX 3 detik), total record langsung bertambah dan baris data terbaru dengan Device ID `HOST2-IOT-NODE` langsung muncul di urutan teratas tabel."*

---

### Babak 5: Simulasi Penanganan Gangguan / Fault Tolerance (Opsional)
* **Durasi:** ~1 Menit
* Jika diminta oleh penguji:
  1. **Host 2** mematikan container: `docker compose stop`
  2. Tunjukkan bahwa Web Dashboard tetap responsif dan status koneksi database tetap **Healthy**.
  3. **Host 2** menyalakan kembali container: `docker compose start`
  4. Pengiriman data langsung pulih otomatis tanpa perlu me-restart service di Host 1.

---

### Babak 6: Penutup
> **Host 1 & Host 2:**  
> *"Demikian demonstrasi integrasi 2 Host pada Tugas 2 JARKOMLAN kami. Seluruh kriteria penugasan—mulai dari isolasi Web Server di dalam kernel Linux VM, manajemen multi-container di Docker WSL 2, komunikasi lintas-jaringan via MQTT Broker, hingga standardisasi database 3NF—telah teruji dan berfungsi secara end-to-end. Terima kasih atas perhatian Bapak/Ibu dan Mas/Mbak Asisten."*

---

## 4. Antisipasi Pertanyaan Dosen / Penguji

| Pertanyaan Penguji | Jawaban Teknis Tepat |
| :--- | :--- |
| **Q1: Kenapa Web Server harus diletakkan di VM Linux, kenapa tidak di Docker Windows saja?** | *"Sesuai spesifikasi tugas, penempatan Web Server di VM menguji kemampuan administrasi jaringan sistem operasi Linux murni (Alpine), manajemen antarmuka kernel `eth0`, perutean IP melalui NAT Gateway `10.0.2.2`, serta isolasi lingkungan service yang berbeda dari host fisik."* |
| **Q2: Bagaimana Web Server di VM (IP 10.0.2.15) bisa mengakses MySQL (3306) di Windows Host?** | *"VirtualBox mode NAT secara arsitektural menetapkan IP `10.0.2.2` sebagai alias host fisik. Di Windows Host, port 3306 Docker di-bind ke `0.0.0.0:3306`, dan Windows Firewall telah kami izinkan untuk port tersebut, sehingga request TCP dari kernel VM diteruskan langsung ke container MySQL."* |
| **Q3: Kenapa Host 2 tidak langsung konek dan insert ke MySQL Host 1 saja?** | *"Dalam prinsip arsitektur IoT modern dan keamanan jaringan, database tidak boleh diekspos langsung ke perangkat edge/klien luar. Menggunakan Message Broker (MQTT) memberikan decoupling (loose coupling), skalabilitas tinggi, antrean asinkron, dan konsumsi bandwidth yang jauh lebih hemat dibandingkan koneksi langsung ke DBMS."* |
| **Q4: Apa perbedaan fungsi Ping dengan Netcat saat pengujian dari VM?** | *"Ping beroperasi pada Network Layer (Layer 3) menggunakan protokol ICMP untuk menguji keterjangkauan host, namun tidak bisa memeriksa status port. Netcat (`nc`) beroperasi pada Transport Layer (Layer 4) menggunakan handshaking TCP untuk memastikan port service spesifik (3306 dan 1883) benar-benar berstatus OPEN dan siap menerima koneksi soket."* |
| **Q5: Mengapa tadi saat port tunneling harus menggunakan `127.0.0.1` bukan `localhost`?** | *"Di sistem operasi Windows, OpenSSH me-resolve nama `localhost` ke alamat IPv6 loopback (`::1`). Karena port forwarding VirtualBox dan Docker hanya listen pada IPv4 (`0.0.0.0`), forwarding ke IPv6 ditolak (connection refused). Penggunaan `127.0.0.1` secara eksplisit memaksa rute IPv4 sehingga koneksi socket berhasil sempurna."* |
