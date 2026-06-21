# RAVLaundry - Panduan Demo Lengkap

Dokumen ini adalah panduan lengkap (*walkthrough*) untuk mendemonstrasikan aplikasi RAVLaundry secara menyeluruh, dari sisi User, Kurir, dan Admin.

## 1. Persiapan Awal

Sebelum memulai demo, pastikan:
1. Emulator Android berjalan.
2. Lokasi/GPS Emulator aktif (untuk fitur titik kordinat dan map tracking).
3. Jalankan backend:
   ```bash
   npm run dev
   ```
4. Jalankan aplikasi Flutter:
   ```bash
   cd flutter_laundry
   flutter run
   ```

## 2. Kredensial Akun (Default)
Terdapat 3 role yang bisa Anda gunakan untuk demo:

* **ADMIN**: `admin@laundryku.com` / `admin123`
* **KURIR**: `kurir@laundryku.com` / `kurir123`
* **USER**: `budi@gmail.com` / `user123`

---

## 3. Alur Demonstrasi Utama

### A. Sisi USER (Pelanggan)
1. Buka aplikasi, masuk sebagai **USER**.
2. **Dashboard User**: Tunjukkan tampilan modern, sapaan dinamis, serta ringkasan promo yang ada.
3. **Membuat Pesanan (Crucial Step)**:
   - Tekan tombol `+ Pesanan Baru`.
   - Pilih salah satu Layanan (misal: "Cuci + Setrika Reguler").
   - **Tunjukkan Estimasi Berat**: Isi berat cucian dengan angka (contoh: `2.5`). Sistem otomatis menghitung *Subtotal* secara *real-time* di bagian bawah.
   - **Tunjukkan Fitur GPS**: Alih-alih mengetik manual, klik tombol `Gunakan Lokasi Saat Ini`. Aplikasi otomatis meminta izin akses lokasi, mendeteksi kordinat via GPS, lalu mengubahnya menjadi alamat tulisan (Reverse Geocoding) ke kolom *Alamat Pickup* dan *Alamat Delivery*.
   - Tekan `Konfirmasi & Pesan`.
4. **Detail & Tracking**:
   - Kembali ke Dashboard, tap pesanan yang baru saja dibuat.
   - Akan muncul **Bottom Sheet** cantik berisi detail alamat lengkap, harga, berat, dan status.
   - Tekan opsi Tracking untuk melihat riwayat status pesanan.

### B. Sisi KURIR
1. Logout dari akun User, login sebagai **KURIR**.
2. **Dashboard Kurir**:
   - Di sini, Kurir bisa melihat pesanan yang baru saja dibuat oleh pelanggan dengan status *"Menunggu Pickup"*.
   - **Update Lokasi GPS**: Buka tab `Update Lokasi Saya`. Klik `Gunakan Lokasi Saat Ini` agar backend RAVLaundry tahu kordinat kurir secara *real-time*. (Sangat cocok didemokan jika juri bertanya soal pelacakan lokasi).
3. **Aksi Kurir**:
   - Tap pesanan tersebut, tekan tombol `Konfirmasi Pickup`.
   - Status pesanan berubah menjadi *"Dijemput Kurir"*.

### C. Sisi ADMIN (Manajemen Laundry)
1. Logout dari akun Kurir, masuk sebagai **ADMIN**.
2. **Dashboard Admin**:
   - Admin dapat memantau **Seluruh Transaksi** (Statistik Aktif, Pending, Selesai).
   - Cari pesanan yang baru saja di-pickup oleh kurir.
   - Tap pesanan untuk mengecek *Detail Pesanan* secara utuh (termasuk total bayar).
   - **Ubah Status**: Tap icon tiga titik (titik opsi) pada pesanan, dan ubah statusnya menjadi *"Sedang Dicuci"*, lalu *"Selesai"*.

### D. Penutup (Kembali ke Kurir & User)
1. **Kurir Mengantar**: Login lagi sebagai Kurir. Pesanan yang statusnya sudah *"Selesai"* akan muncul lagi sebagai tugas antar. Kurir dapat menandai *"Ambil & Antar"*, lalu setelah sampai, tandai *"Selesaikan Pengantaran"*.
2. **User Mengecek Riwayat**: Login sebagai User, cek bahwa pesanan tadi sudah masuk ke daftar *Riwayat Transaksi* dengan status centang hijau `Selesai Diterima`.

---

## 4. Selling Point untuk Ditekankan saat Presentasi

- **Aesthetic UI/UX**: Tampilan sangat responsif, menggunakan *Glassmorphism*, gradien warna halus, dan Google Fonts.
- **Validasi Solid & Dinamis**: Form tidak akan *crash* saat kosong; sistem otomatis menghitung Total Harga berdasarkan berat kg saat pengguna mengetik.
- **GPS Otomatis Terintegrasi**: Menggunakan *Geolocator* dan *Geocoding* tanpa harus ketik manual.
- **Real-time Tracking Database**: Integrasi Prisma (SQLite/MySQL) sangat mulus; perubahan status oleh Admin langsung terpantau di sisi User.
- **Role-Based Access Control (RBAC)**: Login tidak tertukar, aplikasi mencegah *back-button exploit* setelah user *logout*.

Selamat melakukan demonstrasi! Aplikasi Anda kini sudah lengkap dan stabil.
