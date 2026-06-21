# RAVLaundry - Panduan Fitur Lengkap (FITUR GUIDE)

Dokumen ini menjelaskan secara rinci seluruh fitur yang tersedia di dalam aplikasi RAVLaundry, yang mencakup dari sisi Pelanggan (User), Kurir, Admin, hingga dukungan integrasi teknologi terkini seperti Location Based Services (LBS).

---

## 1. Sistem Multi-Role (Role-Based Access Control)
Sistem memiliki kontrol akses yang membedakan hak dan tampilan untuk 3 jenis peran utama:
- **USER (Pelanggan)**: Dapat membuat pesanan, melacak pesanan, melihat promo, dan memberikan ulasan.
- **KURIR**: Bertanggung jawab untuk melakukan *pickup* (penjemputan) dan *delivery* (pengantaran) pesanan, serta mengupdate lokasi GPS secara real-time.
- **ADMIN**: Mengelola data master (layanan, promo), memantau seluruh transaksi, dan memperbarui status pesanan saat dicuci atau disetrika.

---

## 2. Fitur Sisi USER (Pelanggan)
Aplikasi memberikan pengalaman UI/UX yang dinamis (Glassmorphism) dan interaktif:
*   **Dynamic Dashboard**: Menampilkan sapaan dinamis berdasarkan waktu, ringkasan fitur, serta daftar Promo/Diskon yang sedang aktif.
*   **Pemesanan Layanan (Create Order)**:
    *   Pemilihan layanan laundry (Cuci Komplit, Setrika Saja, Cuci Kering, dll).
    *   **Kalkulasi Real-Time**: Subtotal dan total bayar langsung terhitung otomatis saat pengguna memasukkan estimasi berat cucian (kg).
    *   Fitur Promo (Kode Diskon).
*   **Sistem Pembayaran**: 
    *   Dukungan untuk mencatat metode pembayaran dan upload bukti transfer.
*   **Layanan Berbasis Lokasi (LBS) & GPS Auto-Fill**:
    *   Tombol "Gunakan Lokasi Saat Ini" secara otomatis meminta izin GPS (*Geolocator*) dan mengubah kordinat lintang/bujur menjadi teks alamat (*Reverse Geocoding*).
    *   Mencari mitra laundry terdekat dari lokasi user (Fitur LBS `MitraLaundry`).
*   **Detail & Tracking Pesanan Real-Time**:
    *   Melihat riwayat status pesanan dari "Menunggu Pickup" hingga "Selesai Diterima".
*   **Ulasan & Rating**: Memberikan penilaian terhadap layanan.
*   **Notifikasi**: Notifikasi in-app untuk mengabarkan update pesanan.

---

## 3. Fitur Sisi KURIR
Dirancang untuk efisiensi penjemputan dan pengantaran:
*   **Kurir Dashboard**: Daftar pesanan yang masuk dan siap untuk di-pickup (status "Menunggu Pickup") atau diantar (status "Selesai Dicuci").
*   **Konfirmasi Tugas**: 
    *   Satu klik untuk mengubah status pesanan dari "Menunggu Pickup" menjadi "Dijemput Kurir".
    *   Satu klik untuk menyelesaikan pengantaran ke pelanggan.
*   **Update Lokasi Real-Time (GPS Tracking)**:
    *   Kurir dapat mengirimkan kordinat (Latitude & Longitude) terbaru mereka ke backend sehingga posisi mereka dapat terlacak di database (`KurirLokasi`).

---

## 4. Fitur Sisi ADMIN (Manajemen Dashboard)
Sebagai pengelola utama dari bisnis laundry:
*   **Monitoring Transaksi Keseluruhan**: Melihat statistik dan detail semua pesanan (Aktif, Pending, Selesai).
*   **Manajemen Status Pesanan**: 
    *   Mengubah status operasional pesanan seperti "Sedang Dicuci", "Sedang Disetrika", hingga "Selesai" (siap diantar).
*   **Manajemen Master Data**: Pengelolaan daftar Layanan, Harga Per Kg, Estimasi Waktu, dan Promo diskon.
*   **Verifikasi Pembayaran**: Menerima dan memverifikasi bukti transfer pembayaran dari pelanggan.

---

## 5. Fitur Backend & Database (Node.js + Prisma)
*   **Relational Database Mapping**: Menggunakan Prisma ORM yang stabil dengan relasi kompleks (User, Order, Tracking, Pembayaran, Kurir).
*   **Database Seeding**: Tersedia skrip otomatis (`seed_promo.ts`, `seed_lbs.ts`) untuk langsung mengisi data dummy saat demonstrasi.
*   **Location Based Services**: Algoritma backend siap mencari dan menghitung jarak antara pelanggan dengan mitra laundry terdekat.
*   **Real-time Tracking Schema**: Memisahkan log tracking ke tabel `Tracking` dan histori lokasi kurir ke tabel `KurirLokasi` guna mencegah data yang bercampur dan mempercepat query.

---

> **Tip Presentasi**: Saat mendemokan aplikasi, Anda bisa menyoroti fitur **Kalkulasi Real-time**, **Auto GPS Geocoding** di aplikasi Flutter, serta **Dashboard Multi-Role** yang tidak tertukar berkat validasi session/token yang kuat.
