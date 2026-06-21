import "dotenv/config";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
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

  console.log("✅ Seed MitraLaundry selesai! " + mitraLaundry.length + " records.");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
