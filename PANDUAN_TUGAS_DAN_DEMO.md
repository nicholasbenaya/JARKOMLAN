# PANDUAN PENGERJAAN TUGAS & CONTEKAN DEMO KELOMPOK
**Mata Kuliah:** Jaringan Komputer & LAN (JARKOMLAN)  
**Tugas 1:** Komunikasi Antar Virtual Machine Menggunakan IPv6  
**Format Kelompok:** 4 Orang  

---

## 👥 Anggota Kelompok
1. **Nicholas Benaya** — `5024241050`
2. **Dzaky Haady** — `5024241076`
3. **Alvis Shohan Fawwaz Nizar** — `5024241019`
4. **Muhammad Sayyid Tsabit** — `5024241013`

---

## 1. PENJELASAN KONSEP (VERSI SEDERHANA & MUDAH DIPAHAMI)

Ketika Anda diminta menjelaskan tugas ini kepada dosen atau rekan lainnya, gunakan penjelasan sederhana berikut:

### A. Konsep Virtualisasi & Hypervisor Tipe 2
* **Apa intinya?**  
  Virtualisasi adalah cara membagi kemampuan satu laptop fisik agar bisa menjalankan beberapa komputer tiruan (*Virtual Machine*) di dalamnya secara bersamaan.
* **Hypervisor Tipe 2 (Oracle VirtualBox):**  
  Adalah aplikasi yang terpasang di atas sistem operasi utama (Windows 11) laptop kita. Kita tidak perlu merusak atau menghapus Windows utama kita. VirtualBox bertindak seperti "manajer" yang mengatur jatah RAM dan CPU untuk masing-masing komputer tiruan tersebut.

### B. Konsep Sambungan Jaringan: *Internal Network*
* Di VirtualBox, kita memilih mode jaringan **Internal Network** (diberi nama `jarkom-v6`).
* **Analoginya:** Seperti menghubungkan dua laptop menggunakan seutas kabel LAN langsung di dalam memori laptop, tanpa melalui router internet luar.
* **Keuntungannya:** Koneksi antar-VM ini 100% stabil, tidak terpengaruh Wi-Fi kampus yang sering mati atau membatasi koneksi antar-laptop.

### C. Konsep Pengalamatan IPv6 (Alamat ULA)
* Jika IPv4 adalah nomor rumah lama yang pendek (seperti `192.168.1.1`), maka IPv6 adalah sistem penomoran modern yang jauh lebih panjang (128-bit) dengan campuran angka dan huruf heksadesimal.
* Alamat berawalan **`fd00::`** disebut **Unique Local Address (ULA)**. 
* **Analoginya:** Seperti nomor ekstensi telepon antar-ruangan di dalam kantor. Nomor ini bebas kita pakai secara lokal dan tidak akan pernah bentrok dengan alamat internet publik di luar.

### D. Mengapa Tidak Memakai ARP di IPv6?
* Pada IPv4, komputer mencari alamat fisik (MAC address) temannya dengan cara berteriak ke seluruh ruangan (*broadcast* via protokol ARP). Ini membuat jaringan berisik dan boros data.
* Pada IPv6, metode berteriak ini dihapus total. Komputer menggunakan protokol **NDP (Neighbor Discovery Protocol)** yang langsung mengirimkan pesan secara terarah (*multicast*) ke komputer tujuan.

---

## 2. KRONOLOGI PEMILIHAN OS: DARI DEBIAN KE ALPINE LINUX

Jika dosen bertanya mengapa menggunakan **Alpine Linux** dan bukan Debian atau Ubuntu:

> **Penjelasan ke Dosen:**  
> *"Awalnya kami mencoba menginstal Debian Netinst. Namun, saat proses instalasi berjalan, terjadi kendala macet total (*stuck* di 13% pada tahap partisi disk). Hal ini terjadi karena adanya ketidakcocokan antara prosesor laptop kami yang berarsitektur modern (Intel Core Ultra dengan sistem core hybrid) saat memproses modul enkripsi installer Debian di atas virtualisasi Windows 11.  
>  
> Sebagai solusinya, kami beralih menggunakan **Alpine Linux Virtual**. Alpine Linux sangat ringan (hanya sekitar 60 MB), langsung siap pakai dari memori dalam 3 detik tanpa risiko macet pada instalasi disk, dan tetap memiliki dukungan perintah jaringan serta protokol IPv6 yang lengkap sesuai kebutuhan tugas."*

---

## 3. RANGKUMAN ALOKASI IP & DATA PENGUJIAN

| Pengaturan | VM 1 | VM 2 |
| :--- | :--- | :--- |
| **Nama Mesin Virtual** | `VM1-Jarkom` | `VM2-Jarkom` |
| **Sistem Operasi** | Alpine Linux Virtual 3.20 | Alpine Linux Virtual 3.20 |
| **Antarmuka (Interface)** | `eth0` | `eth0` |
| **Alamat IPv6 (ULA)** | `fd00:db8:1::10/64` | `fd00:db8:1::20/64` |
| **MAC Address** | `08:00:27:DA:40:82` | `08:00:27:E7:03:A5` |
| **Hasil Ping** | Sukses (0% packet loss, RTT $\approx$ 1.7 - 2.8 ms) | Sukses (0% packet loss, RTT $\approx$ 1.3 - 2.0 ms) |

---

## 4. URUTAN TAHAPAN DEMO DI DEPAN DOSEN

Ikuti urutan langkah berikut agar demonstrasi berjalan tenang, rapi, dan meyakinkan:

### Langkah 1: Perlihatkan Pengaturan Jaringan VirtualBox
1. Buka aplikasi VirtualBox di laptop.
2. Tunjukkan bahwa ada 2 mesin: **`VM1-Jarkom`** dan **`VM2-Jarkom`**.
3. Buka menu **Settings $\rightarrow$ Network** pada salah satu mesin, dan perlihatkan bahwa pengaturannya adalah **Internal Network** dengan nama yang sama: `jarkom-v6`.

### Langkah 2: Buka Layar Kedua VM Berdampingan
1. Buka jendela kedua mesin virtual di layar Anda secara berdampingan (kiri dan kanan).
2. Tunjukkan alamat IP masing-masing dengan mengetikkan perintah:
   ```bash
   ip -6 addr show eth0
   ```
   * Di VM 1 akan tampil: `fd00:db8:1::10/64`
   * Di VM 2 akan tampil: `fd00:db8:1::20/64`

### Langkah 3: Eksekusi Perintah Ping Dua Arah
1. **Di terminal VM 1, tes sapa ke VM 2:**
   ```bash
   ping -c 4 fd00:db8:1::20
   ```
   Tunjukkan ke dosen bahwa 4 paket terkirim dan 4 paket diterima (**0% packet loss**).
2. **Di terminal VM 2, tes sapa balik ke VM 1:**
   ```bash
   ping -c 4 fd00:db8:1::10
   ```
   Tunjukkan bahwa komunikasi dua arah berlangsung lancar.

### Langkah 4: Tunjukkan Tabel Tetangga (Poin Nilai Tambah)
Ketik di VM 1:
```bash
ip -6 neigh
```
Tunjukkan baris yang muncul:
`fd00:db8:1::20 dev eth0 lladdr 08:00:27:e7:03:a5 ... REACHABLE`

> **Sampaikan kalimat ini ke dosen:**  
> *"Pak/Bu, status REACHABLE ini membuktikan bahwa kedua mesin virtual berhasil saling mengenali alamat fisik kartu jaringannya secara otomatis menggunakan protokol Neighbor Discovery Protocol (NDP)."*

---

## 5. TANYA-JAWAB UMUM SAAT DEMO (*FAQ CHEAT SHEET*)

**Q1: Apa fungsi mode Internal Network di VirtualBox?**
> **Jawaban:** "Mode Internal Network membuat saklar virtual (*virtual switch*) terisolasi di dalam memori komputer host. Mode ini menghubungkan antar-VM tanpa menghubungkannya ke kartu jaringan fisik host, sehingga aman dan bebas gangguan jaringan luar."

**Q2: Mengapa memilih alamat `fd00::/8` dan bukan alamat internet publik?**
> **Jawaban:** "Karena alamat `fd00::/8` adalah standar Unique Local Address (ULA) berdasarkan RFC 4193. Fungsinya sama seperti IP Privat pada IPv4, khusus dialokasikan untuk kebutuhan lokal agar tidak bertabrakan dengan alamat internet publik."

**Q3: Apa perbedaan mendasar Ping pada IPv4 dan IPv6?**
> **Jawaban:** "Pada IPv4, pencarian alamat fisik perangkat lawan menggunakan protokol ARP yang menyebarkan sinyal ke semua perangkat (*broadcast*). Sedangkan pada IPv6, tidak ada sistem broadcast, melainkan menggunakan protokol NDP (Neighbor Discovery Protocol) yang memanfaatkan pesan *multicast* secara lebih terarah dan efisien."

**Q4: Jika VM ini dimatikan total (*Power off*), apakah pengaturannya hilang?**
> **Jawaban:** "Karena Alpine Linux dijalankan secara *Live RAM* agar ringan dan cepat, pengaturan IP berada di memori sementara. Namun jika ditutup dengan opsi *Save the machine state* di VirtualBox, seluruh kondisi memori akan dibekukan sehingga saat dibuka kembali pengaturannya langsung aktif seketika."
