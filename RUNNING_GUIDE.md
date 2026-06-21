PANDUAN MENJALANKAN APLIKASI RAVLaundry
(Backend + Aplikasi Mobile Flutter)


SYARAT UTAMA SEBELUM MULAI:
- Komputer (yang menjalankan backend) dan HP (yang menjalankan aplikasi Flutter) HARUS TERHUBUNG KE JARINGAN WI-FI YANG SAMA. Kalau beda Wi-Fi atau salah satu pakai data seluler, aplikasi di HP tidak akan bisa konek ke server di komputer.
- Pastikan Node.js sudah terinstall di komputer. Kalau belum, download dan install dulu dari https://nodejs.org (pilih versi LTS).
- Pastikan Flutter SDK sudah terinstall di komputer. Kalau belum, ikuti panduan di https://docs.flutter.dev/get-started/install


1. INFORMASI DATABASE (APAKAH BUTUH XAMPP?)

TIDAK PERLU XAMPP!
Aplikasi ini menggunakan database SQLite. SQLite itu database yang datanya tersimpan dalam satu file saja (file-nya bernama dev.db di dalam folder prisma). Jadi tidak perlu install MySQL, tidak perlu nyalakan Apache, tidak perlu buka XAMPP sama sekali. Semua sudah otomatis ditangani oleh Prisma ORM.


2. MENJALANKAN BACKEND DAN WEB ADMIN

Backend adalah server yang menyediakan data untuk aplikasi mobile. Tanpa menyalakan backend, aplikasi Flutter tidak bisa login, ambil data layanan, atau membuat order.

Langkah-langkah:
   1. Buka folder proyek Bootcamp di VS Code atau text editor lain.
   2. Buka Terminal di VS Code (tekan Ctrl + ` atau klik menu Terminal > New Terminal di atas).
   3. Ketik perintah berikut satu per satu lalu tekan Enter setiap selesai:

      npm install
      (Fungsinya: Mendownload semua library/package yang dibutuhkan project. Tunggu sampai selesai, mungkin butuh beberapa menit.)

      npx prisma generate
      (Fungsinya: Menyiapkan koneksi ke database SQLite supaya server bisa baca/tulis data.)

      npx prisma db seed
      (Fungsinya: Mengisi database dengan data awal seperti akun admin, kurir, pelanggan, daftar layanan, dll. Tanpa langkah ini, database kosong dan tidak ada akun yang bisa dipakai login.)

      npm run dev
      (Fungsinya: Menyalakan server backend. Setelah dijalankan akan muncul tulisan bahwa server berjalan di http://localhost:3000)

   PENTING: Jangan tutup terminal ini! Kalau terminal ditutup, server mati dan aplikasi Flutter tidak bisa konek.

   Untuk mengakses Web Admin, buka browser di komputer dan ketik: http://localhost:3000


3. KONFIGURASI IP ADDRESS UNTUK APLIKASI FLUTTER

Kenapa perlu ganti IP?
Aplikasi Flutter di HP tidak bisa mengakses "localhost" karena localhost itu merujuk ke HP itu sendiri, bukan ke komputer. Makanya kita perlu tahu alamat IP komputer yang menjalankan server, lalu memasukkannya ke kode Flutter agar HP bisa konek ke server di komputer melalui jaringan Wi-Fi yang sama.

LANGKAH A - Cek IP Address Komputer:
   1. Pastikan komputer sudah terhubung ke Wi-Fi (jaringan yang SAMA dengan HP).
   2. Tekan tombol Windows + R di keyboard, ketik cmd, lalu tekan Enter. Akan terbuka jendela Command Prompt.
   3. Di Command Prompt, ketik perintah berikut lalu tekan Enter:
      ipconfig
   4. Akan muncul banyak teks. Cari bagian yang bertuliskan "Wireless LAN adapter Wi-Fi" (kalau pakai Wi-Fi) atau "Ethernet adapter" (kalau pakai kabel LAN).
   5. Di bagian itu, cari baris "IPv4 Address". Angka di sebelah kanannya adalah IP komputer kamu.
      Contoh: IPv4 Address . . . . . . . . . . : 192.168.1.15
      Berarti IP komputer kamu adalah 192.168.1.15
      (Angka ini berbeda-beda di setiap komputer dan bisa berubah kalau pindah Wi-Fi)

LANGKAH B - Masukkan IP ke Kode Flutter:
   1. Buka file berikut di VS Code:
      flutter_laundry/lib/core/constants/api_constants.dart
   2. Di baris paling atas, cari kode yang bertuliskan:
      const String baseUrl = 'http://xxx.xxx.xxx.xxx:3000';
   3. Ganti angka xxx.xxx.xxx.xxx dengan IP komputer yang kamu dapat dari Langkah A.
      Contoh kalau IP kamu 192.168.1.15, maka ubah menjadi:
      const String baseUrl = 'http://192.168.1.15:3000';
   4. Simpan file (Ctrl + S).

PENTING: Port 3000 jangan diubah! Yang diubah cuma angka IP-nya saja.


4. MENJALANKAN APLIKASI MOBILE (FLUTTER)

Setelah backend sudah menyala dan IP sudah diatur, sekarang jalankan aplikasi Flutter-nya.

Menggunakan HP Fisik (Android):
   1. Di HP, masuk ke Settings > About Phone > tekan "Build Number" 7 kali sampai muncul tulisan "You are now a developer".
   2. Kembali ke Settings > Developer Options > aktifkan "USB Debugging".
   3. Sambungkan HP ke komputer menggunakan kabel USB.
   4. Di HP akan muncul pop-up "Allow USB Debugging?" > tekan "Allow" atau "Izinkan".

Menggunakan Emulator Android:
   1. Buka Android Studio.
   2. Klik "Device Manager" atau "AVD Manager".
   3. Jalankan salah satu emulator yang sudah ada, atau buat baru.
   Catatan: Kalau pakai emulator, IP-nya bisa tetap pakai IP komputer yang didapat dari ipconfig, ATAU bisa juga pakai 10.0.2.2 sebagai pengganti localhost (karena 10.0.2.2 adalah alias localhost di emulator Android).

Menjalankan Aplikasi:
   1. Buka terminal BARU (jangan pakai terminal yang sedang menjalankan backend).
   2. Masuk ke folder flutter_laundry. Ketik:
      cd flutter_laundry
   3. Download semua package Flutter yang dibutuhkan:
      flutter pub get
   4. Jalankan aplikasi:
      flutter run
   5. Tunggu sampai proses build selesai dan aplikasi terbuka di HP/emulator.
      (Proses pertama kali biasanya agak lama, bisa 2-5 menit. Selanjutnya akan lebih cepat.)


5. DAFTAR AKUN LOGIN (SUDAH ADA DI DATABASE)

Setelah menjalankan npx prisma db seed di langkah 2, database akan terisi data awal. Berikut akun-akun yang bisa dipakai untuk login:

ADMIN (bisa login di Web Admin dan Aplikasi Mobile):
   Username: admin
   Password: admin123

KURIR / DRIVER (login di Aplikasi Mobile):
   Username: kurir
   Password: kurir123

   Username: kurir2
   Password: kurir123

PELANGGAN / USER (login di Aplikasi Mobile):
   Username: budi
   Password: user123


6. TROUBLESHOOTING (KALAU ADA MASALAH)

Masalah: Aplikasi Flutter tidak bisa konek / error "Connection refused"
   - Pastikan backend masih menyala (terminal npm run dev masih terbuka dan tidak ada error).
   - Pastikan HP dan komputer terhubung ke Wi-Fi YANG SAMA.
   - Pastikan IP Address di file api_constants.dart sudah benar dan sudah disimpan.
   - Coba matikan Windows Firewall sementara (Settings > Windows Security > Firewall > Turn off) karena firewall kadang memblokir koneksi dari HP ke komputer.

Masalah: npx prisma db seed error
   - Jalankan dulu: npx prisma db push (untuk memastikan tabel-tabel sudah dibuat)
   - Lalu jalankan lagi: npx prisma db seed

Masalah: Ganti Wi-Fi / pindah tempat
   - Setiap kali ganti koneksi Wi-Fi, IP Address komputer kemungkinan besar akan berubah.
   - Cek ulang IP dengan menjalankan ipconfig di Command Prompt.
   - Update IP baru di file api_constants.dart, simpan, lalu restart aplikasi Flutter.

Masalah: flutter run error "No connected devices"
   - Pastikan HP sudah tersambung via kabel USB dan USB Debugging sudah diaktifkan.
   - Coba cabut lalu colokkan kembali kabel USB.
   - Ketik flutter devices di terminal untuk cek apakah HP sudah terdeteksi.

Masalah: DioException [receive timeout] - "The request took longer than 0:00:10.000000 to receive data"
   Artinya: Aplikasi Flutter sudah mencoba menghubungi server, tapi server tidak memberikan balasan dalam waktu 10 detik, jadi koneksinya diputus otomatis.
   Penyebab dan solusi:
   - IP Address di api_constants.dart SALAH atau sudah berubah. Cek ulang IP komputer dengan ipconfig di CMD dan pastikan angkanya sama persis di kode Flutter.
   - HP dan komputer TIDAK terhubung ke Wi-Fi yang sama. Pastikan keduanya pakai jaringan Wi-Fi yang sama.
   - Windows Firewall memblokir koneksi dari HP. Coba matikan Firewall sementara (Settings > Windows Security > Firewall & network protection > pilih jaringan yang aktif > matikan).
   - Server backend belum menyala atau sudah mati. Cek terminal yang menjalankan npm run dev, pastikan masih jalan dan tidak ada pesan error.

Masalah: DioException [bad response] - Status code 500 "Server error"
   Artinya: Aplikasi Flutter BERHASIL konek ke server (IP dan jaringan sudah benar), tapi server mengalami error saat memproses permintaan. Masalahnya ada di sisi server, bukan di aplikasi Flutter.
   Penyebab dan solusi:
   - Database belum di-seed (belum diisi data awal). Jalankan npx prisma db seed di terminal folder Bootcamp, lalu coba lagi di aplikasi.
   - Tabel database belum dibuat atau strukturnya rusak. Jalankan npx prisma db push terlebih dahulu, baru npx prisma db seed.
   - Server crash di tengah jalan. Cek terminal backend (yang menjalankan npm run dev), biasanya ada pesan error merah yang menunjukkan baris kode mana yang bermasalah. Coba restart server dengan menekan Ctrl + C di terminal lalu jalankan npm run dev lagi.