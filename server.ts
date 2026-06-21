import express from "express";
import { createServer as createViteServer } from "vite";
import path from "path";
import { fileURLToPath } from "url";
import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || "super-secret-laundry-key";

// ─── Helper: generate kode order ────────────────────────────────────────────
function generateKodeOrder(): string {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  let code = "";
  for (let i = 0; i < 8; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

async function startServer() {
  const app = express();
  const PORT = 3000;

  app.use(express.json());

  // ─── CORS untuk Flutter ─────────────────────────────────────────────────
  app.use((req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization");
    res.header("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS");
    if (req.method === "OPTIONS") return res.sendStatus(200);
    next();
  });

  // ─── Auth Middleware ─────────────────────────────────────────────────────
  const authenticateToken = (req: any, res: any, next: any) => {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];
    if (!token) return res.status(401).json({ error: "Access denied. Token tidak ditemukan." });
    jwt.verify(token, JWT_SECRET, (err: any, user: any) => {
      if (err) return res.status(403).json({ error: "Token tidak valid atau sudah kedaluwarsa." });
      req.user = user;
      next();
    });
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH ROUTES
  // ═══════════════════════════════════════════════════════════════════════════

  // POST /api/auth/register
  app.post("/api/auth/register", async (req, res) => {
    try {
      const { nama, email, no_telp, alamat, username, password, role } = req.body;
      if (!nama || !email || !username || !password) {
        return res.status(400).json({ error: "Nama, email, username, dan password wajib diisi." });
      }
      const existing = await prisma.user.findFirst({
        where: { OR: [{ email }, { username }] },
      });
      if (existing) {
        return res.status(400).json({ error: "Email atau username sudah terdaftar." });
      }
      const hashedPassword = await bcrypt.hash(password, 10);
      
      const requestedRole = (role === "KURIR" || role === "ADMIN") ? role : "USER";
      const user = await prisma.user.create({
        data: {
          nama,
          email,
          no_telp: no_telp || "",
          alamat: alamat || "",
          username,
          password: hashedPassword,
          role: requestedRole,
        },
      });

      if (requestedRole === "KURIR") {
        await prisma.kurir.create({
          data: {
            nama_kurir: nama,
            email,
            no_telp: no_telp || "",
            username,
            password: hashedPassword,
          }
        });
      }

      res.json({ message: "Registrasi berhasil!", userId: user.id_user });
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  });

  // POST /api/auth/login
  app.post("/api/auth/login", async (req, res) => {
    try {
      const { identifier, password } = req.body;
      if (!identifier || !password) {
        return res.status(400).json({ error: "Identifier dan password wajib diisi." });
      }
      const user = await prisma.user.findFirst({
        where: {
          OR: [{ email: identifier }, { username: identifier }],
        },
      });
      if (!user) return res.status(401).json({ error: "Email/username atau password salah." });
      const validPassword = await bcrypt.compare(password, user.password);
      if (!validPassword) return res.status(401).json({ error: "Email/username atau password salah." });
      let id_kurir = null;
      if (user.role === "KURIR") {
        let kurirRecord = await prisma.kurir.findUnique({ where: { email: user.email } });
        // Jika ada kurir dari seed yang belum punya record Kurir, buat on the fly
        if (!kurirRecord) {
          kurirRecord = await prisma.kurir.create({
            data: {
              nama_kurir: user.nama,
              email: user.email,
              no_telp: user.no_telp,
              username: user.username,
              password: user.password,
            }
          });
        }
        id_kurir = kurirRecord.id_kurir;
      }

      const token = jwt.sign({ userId: user.id_user, role: user.role, id_kurir }, JWT_SECRET, { expiresIn: "7d" });
      res.json({
        token,
        user: { id: user.id_user, nama: user.nama, role: user.role, id_kurir },
      });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // LAYANAN ROUTES
  // ═══════════════════════════════════════════════════════════════════════════

  // GET /api/layanan
  app.get("/api/layanan", async (req, res) => {
    try {
      const layanan = await prisma.layanan.findMany({ orderBy: { id_layanan: "asc" } });
      // Map ke format yang diharapkan Flutter
      const mapped = layanan.map((l) => ({
        id_layanan: l.id_layanan,
        nama_layanan: l.nama_layanan,
        deskripsi: l.deskripsi,
        harga_per_kg: l.harga_per_kg,
        estimasi_hari: l.estimasi_hari,
        foto_layanan: l.foto_layanan,
      }));
      res.json(mapped);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // ORDER ROUTES
  // ═══════════════════════════════════════════════════════════════════════════

  // ─── Helper: format order sesuai Flutter OrderModel ──────────────────────
  function formatOrder(order: any) {
    return {
      id_order: order.id_order,
      id_user: order.id_user,
      id_layanan: order.id_layanan,
      id_kurir: order.id_kurir,
      kode_order: order.kode_order,
      berat_kg: order.berat_kg,
      subtotal: order.subtotal,
      ongkir: order.ongkir,
      total_bayar: order.total_bayar,
      alamat_pickup: order.alamat_pickup,
      alamat_delivery: order.alamat_delivery,
      tanggal_pickup: order.tanggal_pickup,
      jam_pickup: order.jam_pickup,
      catatan: order.catatan,
      status_order: order.status_order,
      created_at: order.created_at,
      layanan: order.layanan
        ? {
            id_layanan: order.layanan.id_layanan,
            nama_layanan: order.layanan.nama_layanan,
            deskripsi: order.layanan.deskripsi,
            harga_per_kg: order.layanan.harga_per_kg,
            estimasi_hari: order.layanan.estimasi_hari,
            foto_layanan: order.layanan.foto_layanan,
          }
        : null,
      tracking: (order.tracking || []).map((t: any) => ({
        id_tracking: t.id_tracking,
        id_order: t.id_order,
        status_tracking: t.status_tracking,
        waktu_update: t.waktu_update,
        keterangan: t.keterangan,
      })),
    };
  }

  // GET /api/promo/check — Cek validitas promo
  app.get("/api/promo/check", authenticateToken, async (req: any, res) => {
    try {
      const { kode } = req.query;
      if (!kode) return res.status(400).json({ error: "Kode promo diperlukan." });

      const promo = await (prisma as any).promo.findUnique({
        where: { kode_promo: String(kode).toUpperCase() },
      });

      if (!promo) {
        return res.status(404).json({ error: "Kode promo tidak ditemukan." });
      }

      if (!promo.status_promo) {
        return res.status(400).json({ error: "Kode promo tidak aktif." });
      }

      const now = new Date();
      if (now < promo.tanggal_mulai || now > promo.tanggal_berakhir) {
        return res.status(400).json({ error: "Kode promo sudah kadaluarsa." });
      }

      res.json(promo);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Gagal memverifikasi promo." });
    }
  });

  // GET /api/orders — User: order sendiri | Admin: semua order | Kurir: order relevan
  app.get("/api/orders", authenticateToken, async (req: any, res) => {
    try {
      const { userId, role } = req.user;

      if (role === "ADMIN") {
        const orders = await prisma.order.findMany({
          include: {
            layanan: true,
            tracking: { orderBy: { waktu_update: "desc" } },
          },
          orderBy: { created_at: "desc" },
        });
        return res.json(orders.map(formatOrder));
      }

      if (role === "KURIR") {
        const { id_kurir } = req.user;
        const orders = await prisma.order.findMany({
          where: {
            OR: [
              { status_order: "menunggu pickup", id_kurir: null },
              { id_kurir: id_kurir }
            ]
          },
          include: {
            layanan: true,
            tracking: { orderBy: { waktu_update: "desc" } },
          },
          orderBy: { created_at: "desc" },
        });
        return res.json(orders.map(formatOrder));
      }

      // USER: hanya order milik sendiri
      const orders = await prisma.order.findMany({
        where: { id_user: userId },
        include: {
          layanan: true,
          tracking: { orderBy: { waktu_update: "desc" } },
        },
        orderBy: { created_at: "desc" },
      });
      res.json(orders.map(formatOrder));
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  // GET /api/admin/stats/revenue — Statistik Pendapatan Admin
  app.get("/api/admin/stats/revenue", authenticateToken, async (req: any, res) => {
    try {
      if (req.user.role !== "ADMIN") {
        return res.status(403).json({ error: "Akses ditolak. Hanya Admin." });
      }

      // Hitung dari order yang sudah selesai
      const completedStatuses = ["selesai", "selesai diterima"];
      const orders = await prisma.order.findMany({
        where: { status_order: { in: completedStatuses } },
        select: { total_bayar: true, created_at: true },
      });

      const now = new Date();
      const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      
      const startOfWeek = new Date(today);
      startOfWeek.setDate(today.getDate() - today.getDay()); 

      const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

      let harian = 0;
      let mingguan = 0;
      let bulanan = 0;

      for (const order of orders) {
        const orderDate = new Date(order.created_at);
        if (orderDate >= today) harian += order.total_bayar;
        if (orderDate >= startOfWeek) mingguan += order.total_bayar;
        if (orderDate >= startOfMonth) bulanan += order.total_bayar;
      }

      res.json({
        harian,
        mingguan,
        bulanan,
      });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  // POST /api/orders — Buat order baru
  app.post("/api/orders", authenticateToken, async (req: any, res) => {
    try {
      const { id_layanan, berat_kg, alamat_pickup, alamat_delivery, tanggal_pickup, jam_pickup, catatan, metode_pembayaran, kode_promo } = req.body;
      if (!id_layanan || !alamat_pickup || !alamat_delivery || !tanggal_pickup || !jam_pickup) {
        return res.status(400).json({ error: "Data order tidak lengkap." });
      }

      const berat = parseFloat(berat_kg) || 0;
      if (berat <= 0) {
        return res.status(400).json({ error: "Berat cucian harus lebih dari 0 Kg." });
      }

      const layanan = await prisma.layanan.findUnique({ where: { id_layanan: Number(id_layanan) } });
      if (!layanan) {
        return res.status(404).json({ error: "Layanan tidak ditemukan." });
      }

      let diskon = 0;
      if (kode_promo) {
        const promo = await (prisma as any).promo.findUnique({ where: { kode_promo: String(kode_promo).toUpperCase() } });
        if (promo && promo.status_promo) {
          const now = new Date();
          if (now >= promo.tanggal_mulai && now <= promo.tanggal_berakhir) {
            diskon = promo.diskon;
          }
        }
      }

      const subtotal = berat * layanan.harga_per_kg;
      const ongkir = 0; // default ongkir
      let total_bayar = subtotal + ongkir - diskon;
      if (total_bayar < 0) total_bayar = 0;

      // Pastikan kode_order unik
      let kode_order = generateKodeOrder();
      let attempts = 0;
      while (attempts < 5) {
        const existing = await prisma.order.findUnique({ where: { kode_order } });
        if (!existing) break;
        kode_order = generateKodeOrder();
        attempts++;
      }

      const order = await prisma.order.create({
        data: {
          id_user: req.user.userId,
          id_layanan: Number(id_layanan),
          kode_order,
          berat_kg: berat,
          subtotal,
          ongkir,
          kode_promo: diskon > 0 ? String(kode_promo).toUpperCase() : null,
          diskon,
          total_bayar,
          alamat_pickup,
          alamat_delivery,
          tanggal_pickup: new Date(tanggal_pickup),
          jam_pickup,
          catatan: catatan || null,
          status_order: "menunggu pickup",
        },
        include: {
          layanan: true,
          tracking: true,
        },
      });

      // Payment record
      await prisma.pembayaran.create({
        data: {
          id_order: order.id_order,
          metode_pembayaran: metode_pembayaran || "BAYAR DI TEMPAT",
          jumlah: 0,
          status_pembayaran: "belum bayar",
        },
      });

      // Initial tracking
      const tracking = await prisma.tracking.create({
        data: {
          id_order: order.id_order,
          status_tracking: "Order Dibuat",
          keterangan: "Pesanan Anda telah berhasil dibuat dan sedang menunggu kurir.",
        },
      });

      // Return dengan tracking yang baru dibuat
      res.json(
        formatOrder({
          ...order,
          tracking: [tracking],
        })
      );
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  // PATCH /api/orders/:id/status — Update status order (Admin/Kurir)
  app.patch("/api/orders/:id/status", authenticateToken, async (req: any, res) => {
    try {
      const { id } = req.params;
      const { status_order, keterangan } = req.body;
      const { role } = req.user;

      if (role !== "ADMIN" && role !== "KURIR") {
        return res.status(403).json({ error: "Hanya Admin atau Kurir yang dapat mengubah status." });
      }
      if (!status_order) {
        return res.status(400).json({ error: "status_order wajib diisi." });
      }

      const orderId = parseInt(id);

      const currentOrder = await prisma.order.findUnique({ where: { id_order: orderId } });
      if (!currentOrder) return res.status(404).json({ error: "Order tidak ditemukan." });

      const updateData: any = { status_order };
      
      // Jika Kurir mengambil order yang belum di-assign
      if (role === "KURIR" && req.user.id_kurir && currentOrder.id_kurir === null && status_order !== "menunggu pickup") {
        updateData.id_kurir = req.user.id_kurir;
      }

      await prisma.order.update({
        where: { id_order: orderId },
        data: updateData,
      });

      // Tambah tracking entry
      await prisma.tracking.create({
        data: {
          id_order: orderId,
          status_tracking: status_order,
          keterangan: keterangan || null,
        },
      });

      // Return order lengkap dengan layanan + tracking terbaru
      const updatedOrder = await prisma.order.findUnique({
        where: { id_order: orderId },
        include: {
          layanan: true,
          tracking: { orderBy: { waktu_update: "desc" } },
        },
      });

      res.json(formatOrder(updatedOrder));
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // TRACKING ROUTES
  // ═══════════════════════════════════════════════════════════════════════════

  // GET /api/tracking/:kode — Public tracking by kode_order
  app.get("/api/tracking/:kode", async (req, res) => {
    try {
      const { kode } = req.params;
      const order = await prisma.order.findUnique({
        where: { kode_order: kode },
        include: {
          layanan: true,
          tracking: { orderBy: { waktu_update: "desc" } },
        },
      });
      if (!order) return res.status(404).json({ error: "Order tidak ditemukan. Periksa kembali kode order Anda." });
      res.json(formatOrder(order));
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // KURIR LOKASI ROUTES (untuk Maps — Tahap 2)
  // ═══════════════════════════════════════════════════════════════════════════

  // POST /api/kurir/lokasi — Kurir kirim lokasi terbaru
  app.post("/api/kurir/lokasi", authenticateToken, async (req: any, res) => {
    try {
      const { role, userId } = req.user;
      if (role !== "KURIR" && role !== "ADMIN") {
        return res.status(403).json({ error: "Hanya Kurir yang dapat mengirim lokasi." });
      }
      const { latitude, longitude, id_order } = req.body;
      if (latitude === undefined || longitude === undefined) {
        return res.status(400).json({ error: "latitude dan longitude wajib diisi." });
      }

      // Upsert ke KurirLokasi (update jika sudah ada, insert jika belum)
      const lokasi = await (prisma as any).kurirLokasi.upsert({
        where: { id_kurir: userId },
        update: {
          latitude: parseFloat(latitude),
          longitude: parseFloat(longitude),
          id_order: id_order ? parseInt(id_order) : null,
          updated_at: new Date(),
        },
        create: {
          id_kurir: userId,
          latitude: parseFloat(latitude),
          longitude: parseFloat(longitude),
          id_order: id_order ? parseInt(id_order) : null,
        },
      });

      res.json({ message: "Lokasi berhasil diperbarui.", lokasi });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  // GET /api/kurir/lokasi/:id_kurir — Ambil lokasi kurir (polling dari user)
  app.get("/api/kurir/lokasi/:id_kurir", async (req, res) => {
    try {
      const { id_kurir } = req.params;
      const lokasi = await (prisma as any).kurirLokasi.findUnique({
        where: { id_kurir: parseInt(id_kurir) },
      });
      if (!lokasi) {
        return res.status(404).json({ error: "Lokasi kurir belum tersedia." });
      }
      res.json({
        id_kurir: lokasi.id_kurir,
        latitude: lokasi.latitude,
        longitude: lokasi.longitude,
        id_order: lokasi.id_order,
        updated_at: lokasi.updated_at,
      });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  // GET /api/kurir/lokasi-by-order/:id_order — Ambil lokasi kurir by order (polling user dari tracking screen)
  app.get("/api/kurir/lokasi-by-order/:id_order", async (req, res) => {
    try {
      const { id_order } = req.params;
      const lokasi = await (prisma as any).kurirLokasi.findFirst({
        where: { id_order: parseInt(id_order) },
        orderBy: { updated_at: "desc" },
      });
      if (!lokasi) {
        return res.status(404).json({ error: "Lokasi kurir belum tersedia." });
      }
      res.json({
        id_kurir: lokasi.id_kurir,
        latitude: lokasi.latitude,
        longitude: lokasi.longitude,
        id_order: lokasi.id_order,
        updated_at: lokasi.updated_at,
      });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // LBS — MITRA LAUNDRY ROUTES (Location Based Service)
  // ═══════════════════════════════════════════════════════════════════════════

  // GET /api/laundry-mitra — Ambil semua mitra laundry aktif
  app.get("/api/laundry-mitra", async (req, res) => {
    try {
      const mitraList = await (prisma as any).mitraLaundry.findMany({
        orderBy: { id: "asc" },
      });
      res.json(mitraList);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  // GET /api/laundry-mitra/:id — Ambil detail satu mitra laundry
  app.get("/api/laundry-mitra/:id", async (req, res) => {
    try {
      const { id } = req.params;
      const mitra = await (prisma as any).mitraLaundry.findUnique({
        where: { id: parseInt(id) },
      });
      if (!mitra) {
        return res.status(404).json({ error: "Mitra laundry tidak ditemukan." });
      }
      res.json(mitra);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // VITE MIDDLEWARE (Web frontend — biarkan tidak berubah)
  // ═══════════════════════════════════════════════════════════════════════════

  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    app.use(express.static(path.join(__dirname, "dist")));
    app.get("*", (req, res) => {
      res.sendFile(path.join(__dirname, "dist", "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`\n🚀 RAVLaundry Backend running on http://localhost:${PORT}`);
    console.log(`📡 API tersedia di http://localhost:${PORT}/api`);
    console.log(`\nDefault accounts:`);
    console.log(`  ADMIN   : admin@laundryku.com / admin123`);
    console.log(`  KURIR 1 : kurir@laundryku.com / kurir123`);
    console.log(`  KURIR 2 : kurir2@laundryku.com / kurir123`);
    console.log(`  USER    : budi@gmail.com / user123\n`);
  });
}

startServer();
