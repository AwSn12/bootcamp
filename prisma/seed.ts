import "dotenv/config";
import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  // Clear existing data
  await prisma.layanan.deleteMany({});
  await prisma.user.deleteMany({});

  const hashedPassword = await bcrypt.hash("admin123", 10);

  // Admin
  await prisma.user.create({
    data: {
      nama: "Administrator",
      email: "admin@laundryku.com",
      no_telp: "08123456789",
      alamat: "Pusat LaundryKu",
      username: "admin",
      password: hashedPassword,
      role: "ADMIN",
    },
  });

  // Kurir 1
  const hashedKurirPassword = await bcrypt.hash("kurir123", 10);
  await prisma.user.create({
    data: {
      nama: "Driver Laundry 1",
      email: "kurir@laundryku.com",
      no_telp: "081222333444",
      alamat: "Jl. Pengiriman No. 1",
      username: "kurir",
      password: hashedKurirPassword,
      role: "KURIR",
    },
  });

  // Kurir 2
  await prisma.user.create({
    data: {
      nama: "Driver Laundry 2",
      email: "kurir2@laundryku.com",
      no_telp: "081222333555",
      alamat: "Jl. Pengiriman No. 2",
      username: "kurir2",
      password: hashedKurirPassword,
      role: "KURIR",
    },
  });

  // Regular User
  const hashedUserPassword = await bcrypt.hash("user123", 10);
  await prisma.user.create({
    data: {
      nama: "Budi Pelanggan",
      email: "budi@gmail.com",
      no_telp: "08555666777",
      alamat: "Perumahan Elite Blok A",
      username: "budi",
      password: hashedUserPassword,
      role: "USER",
    },
  });

  // Services
  const services = [
    {
      nama_layanan: "Laundry Reguler",
      deskripsi: "Cuci lipat rapi, pengerjaan 2-3 hari.",
      harga_per_kg: 6000,
      estimasi_hari: 3,
    },
    {
      nama_layanan: "Laundry Express",
      deskripsi: "Cuci lipat rapi, pengerjaan 1 hari.",
      harga_per_kg: 10000,
      estimasi_hari: 1,
    },
    {
      nama_layanan: "Cuci Setrika",
      deskripsi: "Cuci dan setrika rapi, pengerjaan 2-3 hari.",
      harga_per_kg: 8000,
      estimasi_hari: 3,
    },
    {
      nama_layanan: "Setrika Saja",
      deskripsi: "Setrika rapi tanpa cuci.",
      harga_per_kg: 4000,
      estimasi_hari: 2,
    },
    {
      nama_layanan: "Laundry Sepatu",
      deskripsi: "Pembersihan khusus untuk berbagai jenis sepatu.",
      harga_per_kg: 25000,
      estimasi_hari: 3,
    },
    {
      nama_layanan: "Laundry Karpet",
      deskripsi: "Cuci karpet bersih dan wangi.",
      harga_per_kg: 15000,
      estimasi_hari: 5,
    },
  ];

  for (const service of services) {
    await prisma.layanan.create({
      data: service,
    });
  }

  const ulasanData = [
    { id_user: user1.id, id_order: 1, rating: 5, komentar: 'Cucian bersih, wangi banget!' },
  ];

  for (const u of ulasanData) {
    await (prisma as any).ulasan.create({ data: u });
  }

  // 7. Seed Promo
  await (prisma as any).promo.upsert({
    where: { kode_promo: 'RAV10' },
    update: {},
    create: {
      kode_promo: 'RAV10',
      diskon: 10000,
      tanggal_mulai: new Date(),
      tanggal_berakhir: new Date(new Date().setFullYear(new Date().getFullYear() + 1)),
      status_promo: true,
    },
  });

  // ─── Mitra Laundry (LBS Data Dummy — Area Cikarang) ──────────────────────
  // Clear existing mitra laundry data
  await (prisma as any).mitraLaundry.deleteMany({});

  const mitraLaundry = [
    {
      nama_laundry: "Laundry Berkah Cikarang",
      alamat: "Jl. Industri Raya No. 12, Cikarang Utara, Bekasi",
      latitude: -6.2641,
      longitude: 107.1480,
      harga_per_kg: 6000,
      status_aktif: true,
    },
    {
      nama_laundry: "Laundry Kilat Jababeka",
      alamat: "Jl. Jababeka Raya Blok C No. 8, Cikarang, Bekasi",
      latitude: -6.2804,
      longitude: 107.1623,
      harga_per_kg: 8000,
      status_aktif: true,
    },
    {
      nama_laundry: "Laundry Express Delta Mas",
      alamat: "Jl. Delta Mas Raya No. 5, Cikarang Pusat, Bekasi",
      latitude: -6.3122,
      longitude: 107.1532,
      harga_per_kg: 10000,
      status_aktif: true,
    },
    {
      nama_laundry: "Laundry Bersih Cikarang Baru",
      alamat: "Perum. Cikarang Baru Blok D No. 15, Bekasi",
      latitude: -6.2967,
      longitude: 107.1348,
      harga_per_kg: 7000,
      status_aktif: true,
    },
    {
      nama_laundry: "Laundry Segar Grand Cikarang",
      alamat: "Jl. Grand Cikarang No. 21, Cikarang Selatan, Bekasi",
      latitude: -6.3215,
      longitude: 107.1680,
      harga_per_kg: 7500,
      status_aktif: true,
    },
    {
      nama_laundry: "Laundry Wangi Lippo Cikarang",
      alamat: "Jl. Lippo Cikarang Raya No. 3, Bekasi",
      latitude: -6.2520,
      longitude: 107.1390,
      harga_per_kg: 9000,
      status_aktif: true,
    },
    {
      nama_laundry: "Laundry Cepat Hyundai",
      alamat: "Jl. Hyundai No. 7, Cikarang Timur, Bekasi",
      latitude: -6.3045,
      longitude: 107.1800,
      harga_per_kg: 8500,
      status_aktif: true,
    },
    {
      nama_laundry: "Laundry Murah Cikarang Pusat",
      alamat: "Jl. Alternatif Cikarang No. 10, Bekasi",
      latitude: -6.2890,
      longitude: 107.1555,
      harga_per_kg: 5500,
      status_aktif: true,
    },
    {
      nama_laundry: "Laundry Premium Galaxy",
      alamat: "Perum. Galaxy Bekasi Barat No. 22",
      latitude: -6.3350,
      longitude: 107.1450,
      harga_per_kg: 12000,
      status_aktif: true,
    },
    {
      nama_laundry: "Laundry Nusa Cikarang Selatan",
      alamat: "Jl. Nusa Cikarang No. 4, Cikarang Selatan, Bekasi",
      latitude: -6.3180,
      longitude: 107.1290,
      harga_per_kg: 6500,
      status_aktif: false, // non-aktif untuk demo
    },
  ];

  for (const mitra of mitraLaundry) {
    await (prisma as any).mitraLaundry.create({
      data: mitra,
    });
  }

  console.log("Seeding completed! MitraLaundry: " + mitraLaundry.length + " records.");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
