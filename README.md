# Tugas Jaringan Komputer & LAN (JARKOMLAN): Virtualisasi & Komunikasi IPv6

Repositori ini memuat implementasi, dokumentasi teknis, dan laporan formal **Tugas 1** pada mata kuliah **Jaringan Komputer dan LAN (JARKOMLAN)** mengenai perancangan lingkungan virtualisasi multi-node (minimal 2 Virtual Machine) dan evaluasi komunikasi jaringan berbasis protokol **IPv6**.

---

## Identitas Kelompok
- **Mata Kuliah:** Jaringan Komputer dan LAN
- **Topik:** Virtualisasi Hypervisor Tipe 2 & Implementasi Komunikasi IPv6
- **Anggota Kelompok:**
  1. **Nicholas Benaya** — NIM: `5024241050`
  2. **Dzaky Haady** — NIM: `5024241076`
  3. **Alvis Shohan Fawwaz Nizar** — NIM: `5024241019`
  4. **Muhammad Sayyid Tsabit** — NIM: `5024241013`

---

## Ringkasan Proyek

Tugas ini mengimplementasikan komunikasi jaringan komputer skala lokal antara dua mesin virtual independen yang beroperasi di dalam satu sistem komputasi fisik. Sistem dirancang untuk menguji keandalan pengalamatan generasi berikutnya (**IPv6**) dengan mekanisme resolusi perangkat keras modern tanpa bergantung pada protokol lawas (IPv4/ARP).

### Spesifikasi Arsitektur
* **Hypervisor:** Oracle VirtualBox 7.2 (Hosted / Hypervisor Tipe 2)
* **Sistem Operasi Tamu (Guest OS):** Alpine Linux Virtual 3.20 (x86_64, Kernel 6.6)
* **Topologi Jaringan:** VirtualBox Internal Network (`jarkom-v6`)
* **Protokol Lapisan Jaringan:** IPv6 — Unique Local Address (ULA, RFC 4193)
* **Protokol Resolusi Lapisan Data-Link:** Neighbor Discovery Protocol (NDP, RFC 4861)
* **Pengujian Konektivitas:** ICMPv6 Echo Request / Reply (Ping6)

---

## Rencana Pengalamatan (Addressing Plan)

| Entitas | Interface | Alamat IPv6 ULA (Statis) | Alamat Link-Local | MAC Address |
| :--- | :--- | :--- | :--- | :--- |
| **VM 1 (`VM1-Jarkom`)** | `eth0` | `fd00:db8:1::10/64` | `fe80::a00:27ff:feda:4082/64` | `08:00:27:DA:40:82` |
| **VM 2 (`VM2-Jarkom`)** | `eth0` | `fd00:db8:1::20/64` | `fe80::a00:27ff:fee7:3a5/64` | `08:00:27:E7:03:A5` |

---

## Bukti Pengujian Konektivitas

### 1. Uji Transmisi VM 1 ke VM 2 (`fd00:db8:1::20`)
Pengujian transmisi paket ICMPv6 dari node pengirim pertama menunjukkan keberhasilan mutlak dengan **0% packet loss** dan latensi Round-Trip Time (RTT) berkisar 1.7 ms – 5.5 ms.
![Bukti Ping VM 1 ke VM 2](screenshots/bukti_ping_vm1_ke_vm2.png)

### 2. Uji Transmisi Dua Arah VM 2 ke VM 1 (`fd00:db8:1::10`)
Verifikasi komunikasi timbal-balik mengonfirmasi jalur transmisi dua arah berfungsi stabil dengan **0% packet loss** dan rata-rata RTT 1.7 ms.
![Bukti Ping VM 2 ke VM 1](screenshots/bukti_ping_vm2_ke_vm1.png)

---

## Navigasi Dokumen Repositori

Untuk mempelajari latar belakang perancangan, landasan teori, analisis komparasi, dan pedoman teknis secara mendalam, silakan merujuk pada berkas dokumentasi berikut:

* 📄 **[LAPORAN_TUGAS_1_JARKOMLAN.md](LAPORAN_TUGAS_1_JARKOMLAN.md)**  
  Dokumen laporan akademik komprehensif yang memuat dasar teori virtualisasi, perbandingan tipe hypervisor (Tipe 1 vs Tipe 2), analisis keunggulan IPv6 vs IPv4, rasionalitas teknis transisi OS (Debian ke Alpine Linux), metodologi implementasi, serta pembahasan hasil evaluasi pengujian jaringan.

* 📘 **[PANDUAN_TUGAS_DAN_DEMO.md](PANDUAN_TUGAS_DAN_DEMO.md)**  
  Bahan telaah teknis dan panduan presentasi yang memuat penjabaran mendalam alasan pemilihan teknologi (*decision matrix*), alur transmisi paket (*packet flow*), cara kerja NDP, serta daftar tanya-jawab teknis (*technical Q&A*) untuk sesi demonstrasi.

* 📁 **`screenshots/`**  
  Arsip tangkapan layar autentik hasil eksekusi perintah antarmuka baris perintah (CLI) pada kedua node virtual.
