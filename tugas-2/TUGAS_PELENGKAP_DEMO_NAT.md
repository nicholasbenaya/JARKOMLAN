# MEKANISME AKSES WEB SERVER PADA HOST 1 OLEH HOST 2 MELALUI NETWORK ADDRESS TRANSLATION (NAT) DAN PORT FORWARDING

**Mata Kuliah:** Jaringan Komputer Lanjut (Kelas A)  
**Tugas:** Pelengkap Demonstrasi Virtualisasi Jaringan (Tugas 2)  
**Kelompok:** Dzaky Haady & Nicholas Benaya  

---

### 1. Topologi dan Lingkungan Sistem
Arsitektur sistem terdiri dari dua komputer fisik pada jaringan lokal (LAN) yang sama serta sebuah mesin virtual di dalam Host 1:
1. **Host 2 (Klien):** Perangkat laptop yang mengirimkan permintaan HTTP ke Web Server. Terhubung ke LAN dengan alamat IP fisik (misal: `172.20.10.5`).
2. **Host 1 (Server Fisik):** Menjalankan sistem operasi Windows dengan antarmuka Wi-Fi fisik ber-IP `172.20.10.8`. Host 1 menjalankan hypervisor VirtualBox dan daemon Docker WSL 2.
3. **Guest VM (`VM1-Jarkom`):** Mesin virtual berbasis Alpine Linux yang berjalan di atas VirtualBox dengan antarmuka virtual `eth0` ber-IP privat `10.0.2.15/24`. Di dalam VM ini berjalan Web Server Flask pada port TCP `8080`.

```
[ Host 2: Klien ] (172.20.10.5)
       │ HTTP Request: GET http://172.20.10.8:8080
       ▼
[ Host 1: Windows Fisik ] (172.20.10.8)
       │ VirtualBox NAT Engine (Listening pada 0.0.0.0:8080)
       │ Translasi DNAT: Ubah Dst IP:Port -> 10.0.2.15:8080
       │ Translasi SNAT: Ubah Src IP:Port -> 10.0.2.2:PortVirtual
       ▼
[ Guest VM: Alpine Linux ] (10.0.2.15:8080) -> Web Server Flask
```

---

### 2. Batasan Akses Langsung pada Mode NAT
Secara *default*, VirtualBox mode NAT (*Network Address Translation*) mengisolasi mesin virtual di dalam jaringan privat virtual tersendiri (`10.0.2.0/24`). Alamat IP `10.0.2.15` yang dimiliki oleh VM berstatus *non-routable* di jaringan fisik luar (LAN). 

Router fisik maupun Host 2 di jaringan LAN tidak memiliki entri tabel rute (*routing table*) menuju subnet `10.0.2.0/24`. Akibatnya, paket data yang dikirim langsung dari Host 2 menuju alamat `10.0.2.15` akan dibuang (*dropped*) oleh gateway LAN karena ketiadaan rute pengiriman.

---

### 3. Prinsip Kerja Port Forwarding (Destination NAT)
Untuk menjembatani keterisolasian tersebut, diterapkan teknik **Port Forwarding** pada VirtualBox. Port forwarding bertindak sebagai *Destination NAT* (DNAT) pada Layer 4 (Transport Layer):
* **Aturan Forwarding:** `TCP | Host IP: 0.0.0.0 | Host Port: 8080 | Guest IP: 10.0.2.15 | Guest Port: 8080`.
* Saat aturan ini aktif, proses VirtualBox di Host 1 membuka *socket listening* pada port `8080` di seluruh antarmuka jaringan Windows (`0.0.0.0`). Setiap paket TCP yang menyasar port `8080` pada IP fisik Host 1 (`172.20.10.8`) akan langsung dicegat (*intercepted*) oleh driver jaringan VirtualBox.

---

### 4. Siklus Alur Perjalanan Paket Data (Packet Walkthrough)

1. **Pengiriman Permintaan (Request Outbound dari Host 2):**  
   Pengguna di Host 2 mengakses URL `http://172.20.10.8:8080` melalui peramban web. Host 2 mengirimkan paket TCP SYN dengan struktur:  
   `[Src: 172.20.10.5:54321, Dst: 172.20.10.8:8080]`.
2. **Penerimaan dan Translasi oleh Host 1 (DNAT & SNAT):**  
   Paket tiba di kartu jaringan fisik Host 1 dan lolos dari aturan *Windows Inbound Firewall*. VirtualBox NAT engine membaca paket tersebut dan melakukan dua tahap translasi alamat:
   * **Destination NAT (DNAT):** Mengubah alamat tujuan dari `172.20.10.8:8080` menjadi IP internal VM `10.0.2.15:8080`.
   * **Source NAT (SNAT):** Mengubah alamat sumber dari `172.20.10.5` menjadi alamat virtual gateway VirtualBox, yaitu `10.0.2.2`. Hal ini dilakukan agar paket balasan dari VM diarahkan kembali ke gateway NAT VirtualBox, bukan mencari rute langsung ke Host 2.
3. **Eksekusi pada Web Server VM:**  
   Paket masuk melalui antarmuka `eth0` VM. Kernel Linux Alpine meneruskan segmen TCP tersebut ke proses Flask yang sedang mendengarkan port `8080`. Web server memproses query ke database MySQL di Host 1 (`10.0.2.2:3306`), menyusun dokumen HTML/JSON, lalu mengirimkan respons HTTP 200 OK.
4. **Jalur Pengembalian Respons (Inbound Reverse NAT):**  
   Paket balasan (`Src: 10.0.2.15:8080, Dst: 10.0.2.2:PortVirtual`) dikirim VM ke gateway `10.0.2.2`. NAT engine VirtualBox memeriksa tabel translasi koneksi (*state table*), mengembalikan alamat sumber menjadi `172.20.10.8:8080`, dan mengarahkan alamat tujuan ke `172.20.10.5:54321`.
5. **Penyajian pada Host 2:**  
   Paket balasan tiba di Host 2. Peramban web merender antarmuka dashboard IoT tanpa menyadari bahwa web server sebenarnya berada di dalam mesin virtual yang terisolasi.

---

### 5. Kesimpulan
Akses Web Server Host 1 oleh Host 2 berhasil dilakukan tanpa mengubah mode jaringan VM menjadi *Bridged Adapter*. Kombinasi socket binding pada Host fisik dan mekanisme translasi alamat ganda (DNAT untuk port tujuan serta SNAT untuk rute balik) memungkinkan mesin virtual privat melayani permintaan dari jaringan publik/LAN secara transparan, aman, dan efisien.
