# Repositori Praktikum Jaringan Komputer & LAN (JARKOMLAN)

Repositori ini memuat seluruh implementasi, arsitektur sistem, dokumentasi teknis, dan laporan formal praktikum pada mata kuliah **Jaringan Komputer dan LAN (JARKOMLAN)**.

---

## Identitas Kelompok
- **Mata Kuliah:** Jaringan Komputer dan LAN
- **Anggota Kelompok:**
  1. **Nicholas Benaya** — NRP: `5024241050`
  2. **Dzaky Haady** — NRP: `5024241076`
  3. **Alvis Shohan Fawwaz Nizar** — NRP: `5024241019`
  4. **Muhammad Sayyid Tsabit** — NRP: `5024241013`

---

## Daftar Modul Tugas

### 📂 [Tugas 1: Virtualisasi Hypervisor Tipe 2 & Implementasi Komunikasi IPv6](LAPORAN_TUGAS_1_JARKOMLAN.md)
* **Topik:** Perancangan lingkungan virtualisasi multi-node (minimal 2 Virtual Machine) dan evaluasi komunikasi jaringan berbasis protokol **IPv6 ULA** (`fd00:db8:1::/64`).
* **Dokumentasi Terkait:**
  - 📄 **[LAPORAN_TUGAS_1_JARKOMLAN.md](LAPORAN_TUGAS_1_JARKOMLAN.md)** — Laporan akademik formal dan landasan teori komparasi OS & Hypervisor.
  - 📘 **[PANDUAN_TUGAS_DAN_DEMO.md](PANDUAN_TUGAS_DAN_DEMO.md)** — Decision matrix, packet flow, dan panduan presentasi Tugas 1.

---

### 📂 [Tugas 2: Sistem Terdistribusi IoT (Multi-Host, Docker WSL 2, & Linux VM Web Server)](tugas-2/README.md)
* **Topik:** Arsitektur terdistribusi telemetri IoT multi-device yang mengintegrasikan kontainerisasi (**Docker WSL 2** untuk Mosquitto MQTT Broker, MySQL Database, dan Subscriber Ingestion) dengan virtualisasi (**Alpine Linux VM** sebagai Web Server) serta pertukaran data ternormalisasi.
* **Dokumentasi Terkait:**
  - 📘 **[tugas-2/README.md](tugas-2/README.md)** — Dokumentasi arsitektur sistem, topologi jaringan, skema 3NF, dan bukti hasil pengujian.
  - 📋 **[tugas-2/PANDUAN_DEMO_HOST1.md](tugas-2/PANDUAN_DEMO_HOST1.md)** — Panduan langkah demi langkah demonstrasi Host 1 lengkap dengan skenario presentasi 6 tahap.
  - 📄 **[tugas-2/PANDUAN_DELEGASI_HOST2.pdf](tugas-2/PANDUAN_DELEGASI_HOST2.pdf)** — Dokumen SOP formal delegasi pengerjaan dan kontrak data anti-konflik untuk Host 2.
  - 📁 **`tugas-2/host1/`** — Kode sumber Docker, skrip startup VM, dan firewall rule untuk Host 1.
  - 📁 **`tugas-2/host2/`** — Kode sumber Docker Publisher dan Web Client untuk Host 2.
  - 📁 **`tugas-2/screenshots/`** — Arsip bukti tangkapan layar pengujian jaringan dan web server di VM.
