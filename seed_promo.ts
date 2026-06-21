import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  await prisma.promo.upsert({
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
  console.log('✅ Promo RAV10 seeded successfully!');
}

main()
  .catch(e => console.error(e))
  .finally(() => prisma.$disconnect());
