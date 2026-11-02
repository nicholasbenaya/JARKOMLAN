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

### 📂 [Tugas 1: Virtualisasi Hypervisor Tipe 2 & Implementasi Komunikasi IPv6](tugas-1/README.md)
* **Topik:** Perancangan lingkungan virtualisasi multi-node (minimal 2 Virtual Machine) dan evaluasi komunikasi jaringan berbasis protokol **IPv6 ULA** (`fd00:db8:1::/64`).
* **Dokumentasi Terkait:**
  - 📘 **[tugas-1/README.md](tugas-1/README.md)** — Dokumentasi arsitektur, topologi jaringan internal, dan rekap hasil pengujian.
  - 📄 **[tugas-1/LAPORAN_TUGAS_1_JARKOMLAN.md](tugas-1/LAPORAN_TUGAS_1_JARKOMLAN.md)** — Laporan akademik formal dan landasan teori komparasi OS & Hypervisor.
  - 📋 **[tugas-1/PANDUAN_TUGAS_DAN_DEMO.md](tugas-1/PANDUAN_TUGAS_DAN_DEMO.md)** — Decision matrix, packet flow, dan materi presentasi demonstrasi lab.
  - 📁 **`tugas-1/scripts/`** — Skrip otomasi antarmuka jaringan Shell (`setup_vm1.sh`, `setup_vm2.sh`) dan PowerShell (`setup_vm1.ps1`, `setup_vm2.ps1`).
  - 📁 **`tugas-1/screenshots/`** — Bukti tangkapan layar pengujian ping ICMPv6 antar-VM.

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

---

### 📂 [Tugas 3: Cached Proxy (Squid) & Reverse Proxy Load Balancer (Nginx)](tugas-3/README.md)
* **Topik:** Perancangan dua sistem perantara jaringan (*network proxy*):
  1. **Cached Proxy (Forward Proxy)** menggunakan **Squid Proxy Server** dengan strategi caching file, analisis `TCP_HIT` vs `TCP_MISS`, dan evaluasi ketersediaan saat origin offline.
  2. **Reverse Proxy & Load Balancer** menggunakan **Nginx** di depan kluster 4 backend multi-platform (**Windows Native, 2 VirtualBox Linux VM, dan Docker Container**) dengan distribusi beban *Round Robin* yang diuji secara langsung melalui smartphone client.
* **Dokumentasi Terkait:**
  - 📘 **[tugas-3/README.md](tugas-3/README.md)** — Dokumentasi komprehensif, topologi sistem 2-Host + Smartphone, matriks port, dan pembagian tugas kelompok 4 orang.
  - 📋 **[tugas-3/PANDUAN_TUGAS_3_DAN_DEMO.md](tugas-3/PANDUAN_TUGAS_3_DAN_DEMO.md)** — Panduan operasional langkah demi langkah, SOP uji coba smartphone, naskah demo, dan FAQ evaluasi lab.
  - 📁 **`tugas-3/host1/`** — Script backend cluster (`server_node.py`, `start_cluster.ps1`), Docker Node 4, dan Squid Proxy.
  - 📁 **`tugas-3/host2/`** — Konfigurasi Nginx Reverse Proxy, Origin Web Server, dan skrip benchmarking dummy load test.
