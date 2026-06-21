import { useState, useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { 
  Package, 
  MapPin, 
  Clock, 
  Plus, 
  Truck, 
  ChevronRight, 
  CheckCircle2, 
  Search,
  LayoutGrid,
  History,
  Bell,
  Settings,
  Star
} from "lucide-react";
import api from "@/lib/api";
import { motion } from "framer-motion";
import { format } from "date-fns";
import { id } from "date-fns/locale";
import { Badge } from "@/components/ui/badge";

export default function UserDashboard() {
  const [orders, setOrders] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const user = JSON.parse(localStorage.getItem("user") || "null");
  const navigate = useNavigate();

  useEffect(() => {
    if (!localStorage.getItem("token")) {
      navigate("/login");
      return;
    }
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      const response = await api.get("/orders");
      setOrders(response.data);
    } catch (error) {
      console.error("Failed to fetch orders", error);
    } finally {
      setIsLoading(false);
    }
  };

  const activeOrders = orders.filter(o => o.status_order !== "selesai diterima");
  const historyOrders = orders.filter(o => o.status_order === "selesai diterima");

  const getStatusColor = (status: string) => {
    switch (status) {
      case "menunggu pickup": return "bg-orange-100 text-orange-600";
      case "dijemput kurir": return "bg-blue-100 text-blue-600";
      case "sedang dicuci": return "bg-indigo-100 text-indigo-600";
      case "sedang disetrika": return "bg-purple-100 text-purple-600";
      case "selesai": return "bg-emerald-100 text-emerald-600";
      case "diantar": return "bg-sky-100 text-sky-600";
      default: return "bg-slate-100 text-slate-600";
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-8">
      {/* Welcome Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 pb-6 border-b border-slate-200">
        <div className="space-y-1">
          <h1 className="text-2xl font-extrabold text-[#0F172A] tracking-tight">Halo, {user?.nama}! 👋</h1>
          <p className="text-sm text-slate-500 font-medium">Pakaian bersih Anda sedang kami proses.</p>
        </div>
        <div className="flex items-center space-x-3">
          <Link to="/order">
            <Button className="bg-blue-600 hover:bg-blue-700 h-10 px-5 font-bold shadow-lg shadow-blue-100 rounded-xl group transition-all">
              <Plus className="mr-2 w-4 h-4" />
              Pesanan Baru
            </Button>
          </Link>
        </div>
      </div>

      {/* Stats Overview */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { label: "Order Aktif", value: activeOrders.length, icon: Package, color: "bg-white border-slate-200" },
          { label: "Tuntas", value: historyOrders.length, icon: CheckCircle2, color: "bg-white border-slate-200" },
          { label: "Saldo PayKu", value: "Rp 0", icon: LayoutGrid, color: "bg-white border-slate-200" },
          { label: "Poin", value: "120 pts", icon: Star, color: "bg-white border-slate-200" },
        ].map((stat, i) => (
          <div key={i} className={`p-5 rounded-xl border border-slate-200 bg-white flex flex-col gap-2 shadow-sm`}>
            <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">{stat.label}</span>
            <span className="text-2xl font-bold text-slate-900">{stat.value}</span>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Active Orders List */}
        <div className="lg:col-span-2 space-y-6">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-black text-slate-900 flex items-center">
              <Clock className="mr-2 w-5 h-5 text-blue-600" /> Order Berjalan
            </h2>
            <Badge variant="secondary" className="bg-blue-50 text-blue-700 border-none font-bold">
              {activeOrders.length} Aktif
            </Badge>
          </div>

          {isLoading ? (
            <div className="space-y-4">
              {[1, 2].map(i => <div key={i} className="h-32 bg-slate-100 rounded-2xl animate-pulse" />)}
            </div>
          ) : activeOrders.length > 0 ? (
            <div className="space-y-4">
              {activeOrders.map((order) => (
                <motion.div 
                  key={order.id_order}
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  className="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm hover:border-blue-200 transition-all group"
                >
                  <div className="flex flex-col md:flex-row justify-between gap-6">
                    <div className="flex items-start space-x-4">
                      <div className={`p-3 rounded-2xl ${getStatusColor(order.status_order)}`}>
                        <Package className="w-6 h-6" />
                      </div>
                      <div className="space-y-1">
                        <div className="flex items-center space-x-2">
                          <span className="text-xs font-bold text-slate-400 font-mono select-all">#{order.kode_order}</span>
                          <Badge className={`${getStatusColor(order.status_order)} border-none font-bold uppercase text-[10px]`}>
                            {order.status_order}
                          </Badge>
                        </div>
                        <h3 className="text-lg font-black text-slate-900">{order.layanan?.nama_layanan}</h3>
                        <div className="flex items-center space-x-3 text-sm text-slate-500 font-medium">
                          <span className="flex items-center"><MapPin className="mr-1 w-3 h-3" /> {order.alamat_pickup.substring(0, 20)}...</span>
                          <span className="flex items-center"><Clock className="mr-1 w-3 h-3" /> {format(new Date(order.tanggal_pickup), "dd MMM yyyy", { locale: id })}</span>
                        </div>
                      </div>
                    </div>
                    <div className="flex flex-row md:flex-col justify-between items-end gap-2">
                      <div className="text-right">
                        <p className="text-sm font-bold text-slate-400 capitalize">Total Bayar</p>
                        <p className="text-xl font-black text-blue-600">Rp {order.total_bayar.toLocaleString()}</p>
                      </div>
                      <Link to={`/tracking/${order.kode_order}`}>
                        <Button variant="ghost" size="sm" className="text-blue-600 font-bold hover:bg-blue-50 group-hover:px-4 transition-all">
                          Track Status <ChevronRight className="ml-1 w-4 h-4" />
                        </Button>
                      </Link>
                    </div>
                  </div>
                </motion.div>
              ))}
            </div>
          ) : (
            <div className="text-center py-20 bg-white rounded-[40px] border border-dashed border-slate-200">
               <div className="mx-auto w-24 h-24 bg-slate-50 rounded-full flex items-center justify-center mb-6">
                  <Package className="w-10 h-10 text-slate-300" />
               </div>
               <h3 className="text-xl font-bold text-slate-900">Belum ada order aktif</h3>
               <p className="text-slate-500 max-w-xs mx-auto mt-2">Cucian sudah menumpuk? Yuk, buat order laundry sekarang dan rasakan kemudahannya.</p>
               <Link to="/order" className="mt-8 block">
                  <Button variant="outline" className="border-blue-200 text-blue-600 font-bold hover:bg-blue-50">Order Sekarang</Button>
               </Link>
            </div>
          )}
        </div>

        {/* Sidebar Widgets */}
        <div className="space-y-8">
           {/* Sidebar Promo */}
           <div className="bg-slate-900 rounded-[32px] p-8 text-white relative overflow-hidden group">
              <div className="absolute -top-10 -right-10 w-40 h-40 bg-blue-600 rounded-full blur-3xl opacity-30 group-hover:scale-150 transition-transform duration-700" />
              <div className="relative z-10 space-y-6">
                 <div className="inline-block px-3 py-1 bg-white/10 rounded-full text-xs font-bold uppercase tracking-widest text-blue-400">Limited Promo</div>
                 <h3 className="text-2xl font-black tracking-tight leading-tight">Dapatkan Diskon 30% Liburan Musim Panas!</h3>
                 <p className="text-slate-400 text-sm leading-relaxed font-medium">Bawa 5kg laundry atau lebih dan gunakan kode <span className="text-white font-mono font-bold">SUMMER30</span>.</p>
                 <Button className="w-full bg-blue-600 hover:bg-blue-700 text-white font-black py-6">Klaim Promo</Button>
              </div>
           </div>

           {/* Quick Actions / Profile */}
           <Card className="border-slate-100 shadow-sm rounded-[32px] overflow-hidden">
             <CardHeader className="bg-slate-50 border-b border-slate-100 pb-4">
                <CardTitle className="text-lg font-black text-slate-900 flex items-center uppercase tracking-wider text-xs opacity-50">
                   <Settings className="mr-2 w-4 h-4" /> Pengaturan Cepat
                </CardTitle>
             </CardHeader>
             <CardContent className="p-0">
                <div className="divide-y divide-slate-100">
                  <button className="w-full p-6 flex items-center justify-between hover:bg-slate-50 transition-colors">
                    <div className="flex items-center space-x-4">
                      <div className="w-10 h-10 rounded-full bg-blue-50 flex items-center justify-center">
                        <History className="w-5 h-5 text-blue-600" />
                      </div>
                      <div className="text-left">
                        <p className="font-bold text-slate-900">Riwayat Transaksi</p>
                        <p className="text-xs text-slate-500 font-medium">Lihat pesanan lama Anda</p>
                      </div>
                    </div>
                    <ChevronRight className="w-5 h-5 text-slate-300" />
                  </button>
                  <button className="w-full p-6 flex items-center justify-between hover:bg-slate-50 transition-colors">
                    <div className="flex items-center space-x-4">
                      <div className="w-10 h-10 rounded-full bg-orange-50 flex items-center justify-center">
                        <Star className="w-5 h-5 text-orange-600" />
                      </div>
                      <div className="text-left">
                        <p className="font-bold text-slate-900">Kupon Saya</p>
                        <p className="text-xs text-slate-500 font-medium">3 Kupon aktif tersedia</p>
                      </div>
                    </div>
                    <ChevronRight className="w-5 h-5 text-slate-300" />
                  </button>
                </div>
             </CardContent>
           </Card>
        </div>
      </div>
    </div>
  );
}
