# LBS_TEST_GUIDE.md — Panduan Pengujian Location Based Service

> **RAVLaundry — Fitur Location Based Service (LBS)**  
> Panduan ini digunakan untuk keperluan pengujian dan dokumentasi jurnal ilmiah.

---

## 1. Gambaran Umum Fitur LBS

Fitur LBS pada aplikasi RAVLaundry menampilkan daftar mitra laundry yang diurutkan berdasarkan jarak terdekat dari lokasi pengguna. Perhitungan jarak menggunakan **Rumus Haversine**.

### Rumus Haversine

```
a = sin²(Δlat/2) + cos(φ₁) · cos(φ₂) · sin²(Δλ/2)
c = 2 · atan2(√a, √(1−a))
d = R · c
```

**Keterangan:**
- `φ₁`, `φ₂` = latitude titik 1 dan 2 (radian)
- `Δlat` = selisih latitude (radian)
- `Δλ` = selisih longitude (radian)
- `R` = jari-jari bumi = **6371 km**
- `d` = jarak dalam kilometer

---

## 2. Data Dummy Mitra Laundry (Area Cikarang)

Berikut koordinat GPS mitra laundry yang tersimpan di database:

| No | Nama Laundry | Alamat | Latitude | Longitude | Harga/kg | Status |
|----|------|------|----------|-----------|----------|--------|
| 1 | Laundry Berkah Cikarang | Jl. Industri Raya No. 12, Cikarang Utara | -6.2641 | 107.1480 | Rp 6.000 | Aktif |
| 2 | Laundry Kilat Jababeka | Jl. Jababeka Raya Blok C No. 8 | -6.2804 | 107.1623 | Rp 8.000 | Aktif |
| 3 | Laundry Express Delta Mas | Jl. Delta Mas Raya No. 5 | -6.3122 | 107.1532 | Rp 10.000 | Aktif |
| 4 | Laundry Bersih Cikarang Baru | Perum. Cikarang Baru Blok D No. 15 | -6.2967 | 107.1348 | Rp 7.000 | Aktif |
| 5 | Laundry Segar Grand Cikarang | Jl. Grand Cikarang No. 21 | -6.3215 | 107.1680 | Rp 7.500 | Aktif |
| 6 | Laundry Wangi Lippo Cikarang | Jl. Lippo Cikarang Raya No. 3 | -6.2520 | 107.1390 | Rp 9.000 | Aktif |
| 7 | Laundry Cepat Hyundai | Jl. Hyundai No. 7, Cikarang Timur | -6.3045 | 107.1800 | Rp 8.500 | Aktif |
| 8 | Laundry Murah Cikarang Pusat | Jl. Alternatif Cikarang No. 10 | -6.2890 | 107.1555 | Rp 5.500 | Aktif |
| 9 | Laundry Premium Galaxy | Perum. Galaxy Bekasi Barat No. 22 | -6.3350 | 107.1450 | Rp 12.000 | Aktif |
| 10 | Laundry Nusa Cikarang Selatan | Jl. Nusa Cikarang No. 4 | -6.3180 | 107.1290 | Rp 6.500 | Non-aktif |

---

## 3. Cara Menguji GPS Real Device

### 3.1 Persiapan
1. Pastikan **GPS / Lokasi** aktif di perangkat Android
2. Setting **Akurasi Lokasi** ke **Tinggi (High Accuracy)**
3. Berikan izin lokasi ke aplikasi RAVLaundry saat diminta

### 3.2 Langkah Pengujian
1. Login ke aplikasi sebagai **USER**
2. Di dashboard user, tekan banner **"Laundry Terdekat 📍"**
3. Aplikasi akan meminta izin GPS → tekan **Izinkan**
4. Tunggu GPS mendapatkan koordinat
5. Daftar laundry akan muncul, **diurutkan dari terdekat ke terjauh**

### 3.3 Membaca Hasil
- Koordinat user ditampilkan di **GPS Info Card** (hijau jika berhasil)
- Setiap card laundry menampilkan **jarak dalam km**
- Tekan **"Detail"** untuk melihat tabel perhitungan Haversine lengkap

---

## 4. Cara Menggunakan Fake GPS (Pengujian Jurnal)

Untuk pengujian dengan lokasi spesifik di area Cikarang tanpa harus ke sana secara fisik:

### 4.1 Aplikasi Fake GPS yang Direkomendasikan
- **Fake GPS Location** (Lexa) — Play Store
- **GPS Joystick** — Play Store
- **Mock GPS** (Developer Options)

### 4.2 Langkah Penggunaan Fake GPS
1. Di Android, aktifkan **Developer Options**:
   - Buka **Pengaturan → Tentang Ponsel**
   - Tekan **Nomor Build** 7 kali
2. Masuk ke **Pengaturan → Opsi Pengembang**
3. Aktifkan **"Mock Location App"** / **"Izinkan Lokasi Palsu"**
4. Pilih aplikasi Fake GPS sebagai mock location app
5. Buka aplikasi Fake GPS, masukkan koordinat:
   - **Titik Uji 1:** `-6.2700, 107.1500` (dekat Cikarang Utara)
   - **Titik Uji 2:** `-6.3000, 107.1600` (dekat Cikarang Pusat)
   - **Titik Uji 3:** `-6.2500, 107.1300` (dekat Lippo Cikarang)
6. Tekan **Play/Start** di Fake GPS
7. Buka RAVLaundry → Laundry Terdekat
8. Tekan ikon **refresh GPS** (ikon target di pojok kanan atas)
9. Lihat urutan laundry berubah sesuai lokasi fake GPS

---

## 5. Cara Mengambil Screenshot untuk Jurnal

### Screenshot yang diperlukan:

1. **Screenshot 1: Halaman Laundry Terdekat**
   - Tampilkan daftar laundry dengan jarak terdekat
   - GPS Info Card harus menampilkan koordinat (warna hijau)

2. **Screenshot 2: Panel Debug (aktifkan ikon 🐛)**
   - Tekan ikon bug di AppBar untuk memunculkan panel debug
   - Screenshot menampilkan lat/lng user yang jelas

3. **Screenshot 3: Halaman Detail Laundry**
   - Tekan "Detail" pada salah satu laundry
   - Scroll ke bawah untuk melihat **Tabel Perhitungan Haversine**
   - Screenshot tabel dengan semua nilai (a, c, d, km)

4. **Screenshot 4: Perbandingan dengan Google Maps**
   - Buka Google Maps di browser
   - Cari koordinat laundry → klik kanan → "Ukur Jarak"
   - Bandingkan hasil km dari aplikasi vs Google Maps

---

## 6. Cara Membandingkan dengan Google Maps

### Langkah Verifikasi Manual:

1. Buka **Google Maps** di browser: https://maps.google.com
2. Klik kanan pada **lokasi user** (koordinat dari aplikasi) → **"Ukur Jarak"**
3. Klik titik koordinat laundry yang ingin diukur
4. Google Maps akan menampilkan jarak dalam **km**
5. Bandingkan dengan jarak yang ditampilkan aplikasi

### Contoh Perbandingan:
| Mitra Laundry | Lat Laundry | Lng Laundry | Jarak Haversine (App) | Jarak Google Maps | Selisih |
|------|------------|------------|----------------------|-------------------|---------|
| Laundry Berkah | -6.2641 | 107.1480 | _isi dari app_ | _isi dari gmaps_ | ± _x_ m |
| Laundry Kilat | -6.2804 | 107.1623 | _isi dari app_ | _isi dari gmaps_ | ± _x_ m |

> **Catatan:** Haversine mengukur jarak garis lurus (as the crow flies), sedangkan Google Maps dapat mengukur jarak jalan. Perbedaan wajar terjadi karena ini bukan hal yang sama.

---

## 7. Contoh Tabel Pengujian Jarak (Template Jurnal)

### Tabel 1: Data Pengujian LBS — Titik Uji: [Koordinat User]

| No | Nama Laundry | Lat Laundry | Lng Laundry | Lat User | Lng User | Jarak Haversine (km) | Ranking |
|----|------|----------|----------|---------|---------|----------------------|---------|
| 1 | Laundry Berkah Cikarang | -6.2641 | 107.1480 | _lat user_ | _lng user_ | _x.xxxx_ | 1 |
| 2 | Laundry Kilat Jababeka | -6.2804 | 107.1623 | _lat user_ | _lng user_ | _x.xxxx_ | 2 |
| 3 | Laundry Express Delta Mas | -6.3122 | 107.1532 | _lat user_ | _lng user_ | _x.xxxx_ | 3 |
| ... | ... | ... | ... | ... | ... | ... | ... |

### Tabel 2: Detail Perhitungan Haversine — [Nama Laundry]

| Parameter | Nilai |
|-----------|-------|
| Latitude User (φ₁) | _nilai_ |
| Longitude User (λ₁) | _nilai_ |
| Latitude Laundry (φ₂) | _nilai_ |
| Longitude Laundry (λ₂) | _nilai_ |
| ΔLat (derajat) | _nilai_ |
| ΔLng (derajat) | _nilai_ |
| ΔLat (radian) | _nilai_ |
| ΔLng (radian) | _nilai_ |
| Nilai a | _nilai_ |
| Nilai c | _nilai_ |
| R (jari-jari bumi) | 6371 km |
| **Jarak (d)** | **_x.xxxx km_** |

---

## 8. API Endpoint Backend (untuk pengujian manual)

```
GET /api/laundry-mitra
→ Mengembalikan semua data mitra laundry

GET /api/laundry-mitra/:id
→ Detail satu mitra laundry berdasarkan ID
```

### Contoh Response:
```json
[
  {
    "id": 1,
    "nama_laundry": "Laundry Berkah Cikarang",
    "alamat": "Jl. Industri Raya No. 12, Cikarang Utara, Bekasi",
    "latitude": -6.2641,
    "longitude": 107.1480,
    "harga_per_kg": 6000,
    "status_aktif": true
  }
]
```

Test menggunakan browser atau Postman:
```
http://localhost:3000/api/laundry-mitra
```

---

## 9. Checklist Pengujian Jurnal

- [ ] GPS berhasil mendapatkan koordinat user
- [ ] Daftar laundry tampil setelah GPS aktif
- [ ] Laundry diurutkan dari terdekat ke terjauh ✓
- [ ] Jarak ditampilkan dalam km dengan format benar
- [ ] Panel debug menampilkan lat/lng user
- [ ] Halaman detail menampilkan lat/lng laundry
- [ ] Tabel Haversine menampilkan semua nilai perhitungan
- [ ] Hasil mendekati jarak Google Maps (±5% toleransi)
- [ ] Fake GPS mengubah urutan daftar laundry
- [ ] Screenshot diambil untuk semua skenario uji

---

*Dibuat untuk keperluan jurnal ilmiah — RAVLaundry LBS Feature*  
*Menggunakan Flutter + Express + Prisma + SQLite*
