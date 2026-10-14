# Panduan & Skenario Demonstrasi Host 1 (JARKOMLAN Tugas 2)

Dokumen ini memuat skenario lengkap, daftar perintah eksekusi, serta poin-poin penjelasan teknis saat mendemokan **Host 1** kepada dosen dan asisten laboratorium.

---

## 1. Persiapan Sebelum Demo (Jika VM Dinyalakan dari Awal)

Karena Alpine Linux beroperasi di atas **RAM (*Live RAM / tmpfs*)**, saat mesin baru dinyalakan (*Power On*), jalankan 2 perintah berikut di terminal VM Alpine:

```sh
# 1. Aktifkan interface jaringan eth0 & minta IP ke router VirtualBox:
ip link set eth0 up && udhcpc -i eth0

# 2. Impor kode dan jalankan Web Server secara otomatis:
wget -qO- http://10.0.2.2:9999/setup_alpine.sh | sh
```
*Web Server akan langsung aktif di dalam VM dan melayani di port 8080.*

---

## 2. Alur Demonstrasi 6 Tahap (Skenario Presentasi)

### Tahap 1: Menunjukkan Interface `eth0` dan IP yang Terpasang
Buka terminal VM Alpine dan ketik:
```sh
ip addr show eth0
```
> **Poin yang Dibicarakan:**  
> *"Dapat dilihat pada antarmuka `eth0`, VM Linux ini telah menerima alamat IPv4 privat `10.0.2.15/24` yang dialokasikan oleh server DHCP internal VirtualBox dalam mode jaringan NAT."*

---

### Tahap 2: Menunjukkan IP Gateway Host Windows (`10.0.2.2`)
Ketik di terminal VM Alpine:
```sh
ip route show
```
Hasil: `default via 10.0.2.2 dev eth0`
> **Poin yang Dibicarakan:**  
> *"Melalui tabel perutean kernel Linux (`ip route show`), kita dapat membuktikan bahwa default gateway VM ini mengarah ke `10.0.2.2`. Di VirtualBox NAT, alamat `10.0.2.2` adalah representasi standar dari sistem operasi Windows Host tempat container database berada."*

---

### Tahap 3: Menjelaskan Port Service & Perbedaan Ping vs Port Check
> **Catatan Teknis Jarkom:**  
> Ping menggunakan protokol **ICMP (Layer 3)** sehingga hanya menyasar alamat IP, bukan port. Sedangkan service aplikasi berjalan di **Layer 4 (Transport Layer TCP)**.

1. **Uji Keterjangkauan Kabel/Gateway (Layer 3 - ICMP):**
   ```sh
   ping -c 3 10.0.2.2
   ```
   > *"Pertama, kami menguji konektivitas Layer 3 ke gateway host. RTT stabil di bawah 1 ms dengan 0% packet loss."*

2. **Uji Keterbukaan Port Service (Layer 4 - TCP Netcat):**
   ```sh
   nc -zv 10.0.2.2 3306
   nc -zv 10.0.2.2 1883
   ```
   > *"Kedua, kami memverifikasi keterbukaan port TCP Layer 4 menggunakan utilitas `nc` (Netcat). Terlihat bahwa port 3306 untuk MySQL dan port 1883 untuk Broker Mosquitto berstatus `open` dan siap melayani koneksi dari dalam VM."*  
   > *(Tambahan: Jelaskan bahwa Subscriber tidak membuka port masuk, melainkan bertindak sebagai worker TCP client yang menyambungkan Broker ke MySQL).*

---

### Tahap 4: Menjalankan Web Server di VM & Alur Akses (Lokal vs Host 2)
Jalankan Web Server di terminal VM (jika belum berjalan):
```sh
cd /root/webserver && python3 app.py
```
> **Poin yang Dibicarakan:**  
> *"Web Server Flask ini berjalan murni di dalam kernel Linux VM pada port 8080. Konfigurasinya membaca database MySQL di `10.0.2.2:3306`."*  
> *"Untuk pengujian lokal di Host 1, kami mengakses `http://localhost:8080` karena kami menyetel Port Forwarding di VirtualBox (port 8080 Windows diteruskan ke port 8080 VM)."*  
> *"Sedangkan untuk Host 2 minggu depan, Host 2 cukup membuka browser ke alamat IP fisik Host 1 di LAN, yaitu `http://192.168.100.6:8080`. Paket tersebut akan otomatis dibelokkan oleh VirtualBox masuk ke Web Server di dalam VM ini."*

---

### Tahap 5: Simulasi Push dari Publisher & Pembaruan Dashboard UI
Buka browser di laptop Host 1 pada alamat **`http://localhost:8080`**.  
Lalu buka terminal PowerShell baru di Windows dan jalankan:
```powershell
python tugas-2/host1/test_local_publisher.py
```

**Konsep yang Terjadi di Balik Layar:**
1. Skrip Python bertindak sebagai sensor simulasi: menghasilkan data acak suhu (°C), kelembapan (%), dan tegangan (V).
2. Data dikemas ke dalam format JSON yang telah dinormalisasi.
3. Paket di-*publish* via protokol MQTT ke Broker Mosquitto (`localhost:1883`).
4. Container Subscriber mendengarkan topik tersebut, mem-parsing JSON, dan menjalankan perintah SQL `INSERT INTO sensor_telemetry` ke MySQL.
5. Web Server di dalam VM (yang melakukan auto-polling AJAX setiap 3 detik) langsung membaca record baru tersebut dari MySQL dan menampilkannya di dashboard browser.

> **Poin yang Dibicarakan:**  
> *"Saat publisher mengirim paket, di layar dashboard browser dapat kita lihat bahwa angka total data dan baris tabel sensor bertambah secara real-time tanpa perlu me-refresh halaman. Dan di layar terminal VM, kita bisa melihat access log HTTP 200 OK tercetak secara dinamis."*

---

### Tahap 6: Penutup & Rencana Integrasi Host 2 (Minggu Depan)
Tunjukkan file **`tugas-2/PANDUAN_DELEGASI_HOST2.pdf`** di laptop Anda:
> *"Sebagai langkah persiapan untuk menghubungkan Host 2 minggu depan, kelompok kami telah menyusun SOP dan kontrak normalisasi data formal dalam bentuk dokumen PDF ini. Dokumen ini memastikan bahwa ketika rekan kami di Host 2 mengirim payload JSON dari Docker miliknya, struktur datanya sudah terstandarisasi dan tidak akan menimbulkan konflik parsing di sisi Host 1."*  
> *"Dengan demikian, seluruh arsitektur Host 1—mulai dari isolasi Web Server di dalam Virtual Machine, hingga orkestrasi Broker, Database, dan Subscriber di Docker WSL 2—telah terintegrasi dan berfungsi penuh. Terima kasih."*
