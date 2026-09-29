# Tugas Jaringan Komputer & LAN (JARKOMLAN): Virtualisasi & Komunikasi IPv6

Proyek ini dibuat untuk memenuhi **Tugas 1** pada mata kuliah **Jaringan Komputer dan LAN (JARKOMLAN)** mengenai pembuatan minimal 2 mesin virtual (*Virtual Machine*) yang saling terhubung dan mampu berkomunikasi menggunakan alamat **IPv6**.

---

## 👥 Anggota Kelompok
1. **Nicholas Benaya** — `5024241050`
2. **Dzaky Haady** — `5024241076`
3. **Alvis Shohan Fawwaz Nizar** — `5024241019`
4. **Muhammad Sayyid Tsabit** — `5024241013`

---

## 💡 Konsep Sederhana (Mudah Dipahami Orang Awam)

### 1. Apa itu Virtualisasi?
Bayangkan Anda memiliki satu laptop fisik, tetapi di dalamnya Anda ingin menjalankan dua komputer terpisah secara bersamaan. Virtualisasi memungkinkan kita membagi sumber daya laptop (seperti RAM dan prosesor) untuk membuat "komputer mini buatan" di dalam layar laptop kita. Komputer buatan ini disebut **Virtual Machine (VM)**.

### 2. Mengapa Menggunakan Oracle VirtualBox?
VirtualBox adalah aplikasi **Hypervisor Tipe 2**. Artinya, aplikasi ini berjalan di atas sistem operasi utama (Windows 11) laptop kita, mirip seperti membuka software biasa. Di dalam VirtualBox, kita bisa membuat, menyalakan, dan mematikan beberapa komputer virtual dengan aman tanpa khawatir merusak Windows laptop kita.

### 3. Bagaimana Kedua VM Bisa Saling Terhubung?
Di VirtualBox, kita memilih mode jaringan bernama **Internal Network** (diberi nama `jarkom-v6`). 
* **Analoginya:** Mode ini seperti menghubungkan kedua komputer virtual tersebut menggunakan satu kabel LAN tak kasat mata di dalam memori laptop. 
* Jaringan ini terisolasi murni di dalam laptop kita, sehingga koneksinya tidak akan terganggu meskipun laptop berpindah Wi-Fi atau tidak ada internet.

### 4. Apa itu IPv6 dan Kenapa Pakai Alamat `fd00::`?
* **IPv6** adalah standar alamat internet generasi terbaru. Jika IPv4 berbentuk angka familiar seperti `192.168.1.1`, IPv6 memiliki format yang lebih panjang dengan campuran angka dan huruf (128-bit) agar dunia tidak kehabisan alamat IP.
* Alamat berawalan **`fd00::` (Unique Local Address)** diibaratkan seperti **nomor ekstensi telepon internal kantor**. Alamat ini bebas kita tentukan sendiri untuk menghubungkan komputer di jaringan lokal tanpa perlu terhubung ke internet global.

### 5. Apa itu Ping?
Ping bekerja mirip permainan lempar tangkap bola. Komputer pertama melempar pesan tanya (*Echo Request*), dan komputer kedua menangkap lalu melempar balik pesan jawaban (*Echo Reply*). Jika bola berhasil kembali dengan catatan waktu cepat dan tanpa ada yang hilang (*0% packet loss*), artinya kedua komputer sudah berhasil terhubung dan dapat saling menyapa.

---

## 🛠️ Catatan Pemilihan Sistem Operasi (Debian $\rightarrow$ Alpine Linux)

Pada awal pengerjaan tugas, tim mencoba menggunakan sistem operasi **Debian (Netinst)**. Namun, saat proses pemasangan sistem operasi berlangsung, installer Debian mengalami kendala macet total (*stuck* di 13% pada tahap partisi disk). 

Setelah dianalisis, hal ini disebabkan oleh adanya **ketidakcocokan (*incompatibility*) antara arsitektur prosesor laptop (Intel Core Ultra)** yang memiliki pembagian core khusus (*Performance Core* dan *Efficient Core*) dengan modul enkripsi installer Debian saat berjalan di atas virtualisasi Windows 11.

Sebagai solusi yang cerdas, cepat, dan stabil:
* Sistem operasi dialihkan ke **Alpine Linux Virtual 3.20 (x86_64)**.
* **Keunggulan:** Alpine Linux adalah distro Linux resmi yang sangat ringan (hanya berukuran $\approx 60$ MB). Sistem ini langsung berjalan dari memori (Live RAM) dalam hitungan **3 detik** tanpa perlu melewati proses instalasi yang macet, serta tetap memiliki dukungan jaringan dan fitur **IPv6** yang lengkap 100%.

---

## 🌐 Rincian Alamat Jaringan (IPv6)

| Mesin Virtual | Nama Interface | Alamat IPv6 (Statis) | Alamat Fisik (MAC Address) | Status Pengujian |
| :--- | :--- | :--- | :--- | :--- |
| **VM 1 (`VM1-Jarkom`)** | `eth0` | `fd00:db8:1::10/64` | `08:00:27:DA:40:82` | Terhubung & Berhasil Ping |
| **VM 2 (`VM2-Jarkom`)** | `eth0` | `fd00:db8:1::20/64` | `08:00:27:E7:03:A5` | Terhubung & Berhasil Ping |

---

## 📸 Bukti Hasil Pengujian (Ping IPv6)

### 1. Uji Ping dari VM 1 ke VM 2 (`fd00:db8:1::20`)
Hasil pengujian mengirim 4 paket data dengan respon sukses seketika (**0% packet loss**):
![Bukti Ping VM 1 ke VM 2](screenshots/bukti_ping_vm1_ke_vm2.png)

### 2. Uji Ping Balik dari VM 2 ke VM 1 (`fd00:db8:1::10`)
Hasil pengujian balasan dari VM 2 ke VM 1 juga sukses sempurna (**0% packet loss**):
![Bukti Ping VM 2 ke VM 1](screenshots/bukti_ping_vm2_ke_vm1.png)

---

## 📂 Struktur Berkas Repositori
* **[LAPORAN_TUGAS_1_JARKOMLAN.md](LAPORAN_TUGAS_1_JARKOMLAN.md):** Berkas dokumen laporan resmi lengkap untuk dikumpulkan ke dosen.
* **[PANDUAN_TUGAS_DAN_DEMO.md](PANDUAN_TUGAS_DAN_DEMO.md):** Panduan teknis langkah demi langkah dan contekan tanya-jawab saat demonstrasi di depan dosen.
* **`screenshots/`:** Folder gambar bukti pengujian ping dua arah asli dari layar virtual machine.
* **`setup_vm1.sh` & `setup_vm2.sh`:** Skrip perintah kilat untuk mengatur alamat IPv6 di sistem Linux.
* **`setup_vm1.ps1` & `setup_vm2.ps1`:** Skrip alternatif untuk PowerShell Windows.
