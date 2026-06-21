-- ============================================================
-- RAVLaundry - MySQL Database Schema
-- Referensi jika ingin migrasi dari SQLite ke MySQL
-- Gunakan: mysql -u root -p < database.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS ravlaundry
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE ravlaundry;

-- ─── USERS ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id_user       INT           AUTO_INCREMENT PRIMARY KEY,
  nama          VARCHAR(100)  NOT NULL,
  email         VARCHAR(100)  NOT NULL UNIQUE,
  no_telp       VARCHAR(20)   NOT NULL DEFAULT '',
  alamat        TEXT          NOT NULL DEFAULT '',
  username      VARCHAR(50)   NOT NULL UNIQUE,
  password      VARCHAR(255)  NOT NULL,
  foto_profil   VARCHAR(255)  NULL,
  role          ENUM('USER','KURIR','ADMIN') NOT NULL DEFAULT 'USER',
  created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ─── LAYANAN ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS layanan (
  id_layanan    INT           AUTO_INCREMENT PRIMARY KEY,
  nama_layanan  VARCHAR(100)  NOT NULL,
  deskripsi     TEXT          NOT NULL,
  harga_per_kg  DECIMAL(10,2) NOT NULL,
  estimasi_hari INT           NOT NULL DEFAULT 1,
  foto_layanan  VARCHAR(255)  NULL
);

-- ─── ORDERS ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
  id_order        INT           AUTO_INCREMENT PRIMARY KEY,
  id_user         INT           NOT NULL,
  id_layanan      INT           NOT NULL,
  id_kurir        INT           NULL,
  kode_order      VARCHAR(20)   NOT NULL UNIQUE,
  berat_kg        DECIMAL(10,2) NOT NULL DEFAULT 0,
  subtotal        DECIMAL(10,2) NOT NULL DEFAULT 0,
  ongkir          DECIMAL(10,2) NOT NULL DEFAULT 0,
  total_bayar     DECIMAL(10,2) NOT NULL DEFAULT 0,
  alamat_pickup   TEXT          NOT NULL,
  alamat_delivery TEXT          NOT NULL,
  tanggal_pickup  DATE          NOT NULL,
  jam_pickup      VARCHAR(10)   NOT NULL,
  catatan         TEXT          NULL,
  status_order    VARCHAR(50)   NOT NULL DEFAULT 'menunggu pickup',
  created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (id_user)    REFERENCES users(id_user),
  FOREIGN KEY (id_layanan) REFERENCES layanan(id_layanan),
  FOREIGN KEY (id_kurir)   REFERENCES users(id_user)
);

-- ─── TRACKING ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tracking (
  id_tracking     INT           AUTO_INCREMENT PRIMARY KEY,
  id_order        INT           NOT NULL,
  status_tracking VARCHAR(100)  NOT NULL,
  waktu_update    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  keterangan      TEXT          NULL,
  
  FOREIGN KEY (id_order) REFERENCES orders(id_order)
);

-- ─── PEMBAYARAN ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pembayaran (
  id_pembayaran     INT           AUTO_INCREMENT PRIMARY KEY,
  id_order          INT           NOT NULL UNIQUE,
  metode_pembayaran VARCHAR(50)   NOT NULL DEFAULT 'BAYAR DI TEMPAT',
  jumlah            DECIMAL(10,2) NOT NULL DEFAULT 0,
  bukti_transfer    VARCHAR(255)  NULL,
  status_pembayaran VARCHAR(50)   NOT NULL DEFAULT 'belum bayar',
  tanggal_bayar     DATETIME      NULL,
  
  FOREIGN KEY (id_order) REFERENCES orders(id_order)
);

-- ─── KURIR LOKASI (untuk Maps Realtime) ────────────────────────────────────
CREATE TABLE IF NOT EXISTS kurir_lokasi (
  id          INT           AUTO_INCREMENT PRIMARY KEY,
  id_kurir    INT           NOT NULL UNIQUE,
  latitude    DOUBLE        NOT NULL,
  longitude   DOUBLE        NOT NULL,
  id_order    INT           NULL,
  updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (id_kurir) REFERENCES users(id_user)
);

-- ─── SEED DATA ──────────────────────────────────────────────────────────────
-- Password: admin123 (bcrypt hash)
INSERT INTO users (nama, email, no_telp, alamat, username, password, role)
VALUES (
  'Administrator',
  'admin@laundryku.com',
  '08123456789',
  'Pusat LaundryKu',
  'admin',
  '$2b$10$XOPbrlUPQdwdJUpSrIF6X.LbE96/Zv1GW59mnGRFBq6NJ1InRg5Ge', -- admin123
  'ADMIN'
);

-- Password: kurir123
INSERT INTO users (nama, email, no_telp, alamat, username, password, role)
VALUES (
  'Driver Laundry',
  'kurir@laundryku.com',
  '081222333444',
  'Jl. Pengiriman No. 1',
  'kurir',
  '$2b$10$rFMfSewLRK0T9ogjjYdFhu2IwmNuQM1v1YnLYFi8bIFgVJxaJy5bS', -- kurir123
  'KURIR'
);

-- Password: user123
INSERT INTO users (nama, email, no_telp, alamat, username, password, role)
VALUES (
  'Budi Pelanggan',
  'budi@gmail.com',
  '08555666777',
  'Perumahan Elite Blok A',
  'budi',
  '$2b$10$dIFPdQNa0i3rvbxB7wYcLepX7jgBCUAtjQ18NtMjYX6tHX4Fx0ANq', -- user123
  'USER'
);

-- Layanan
INSERT INTO layanan (nama_layanan, deskripsi, harga_per_kg, estimasi_hari) VALUES
  ('Laundry Reguler', 'Cuci lipat rapi, pengerjaan 2-3 hari.', 6000, 3),
  ('Laundry Express', 'Cuci lipat rapi, pengerjaan 1 hari.', 10000, 1),
  ('Cuci Setrika', 'Cuci dan setrika rapi, pengerjaan 2-3 hari.', 8000, 3),
  ('Setrika Saja', 'Setrika rapi tanpa cuci.', 4000, 2),
  ('Laundry Sepatu', 'Pembersihan khusus untuk berbagai jenis sepatu.', 25000, 3),
  ('Laundry Karpet', 'Cuci karpet bersih dan wangi.', 15000, 5);

-- ============================================================
-- CATATAN MIGRASI:
-- 1. Ganti prisma/schema.prisma datasource ke mysql
-- 2. Update DATABASE_URL di .env ke MySQL connection string
-- 3. Jalankan: npx prisma db push
-- 4. Jalankan: npx prisma db seed
-- ============================================================
