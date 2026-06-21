import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { 
  Truck, 
  MapPin, 
  Package, 
  ChevronRight, 
  CheckCircle,
  Clock,
  Navigation,
  Phone,
  Camera
} from "lucide-react";
import api from "@/lib/api";
import { Badge } from "@/components/ui/badge";
import { toast } from "sonner";
import { motion } from "framer-motion";

export default function KurirDashboard() {
  const [orders, setOrders] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const user = JSON.parse(localStorage.getItem("user") || "null");

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      const response = await api.get("/orders");
      // For courier, filter relevant orders (menunggu pickup, dijemput, diantar)
      const relevant = response.data.filter((o: any) => 
        ["menunggu pickup", "dijemput kurir", "selesai", "diantar"].includes(o.status_order)
      );
      setOrders(relevant);
    } catch (error) {
      toast.error("Gagal mengambil tugas");
    } finally {
      setIsLoading(false);
    }
  };

  const updateStatus = async (id: number, status: string, keterangan: string) => {
    try {
      await api.patch(`/orders/${id}/status`, { status_order: status, keterangan });
      toast.success("Tugas diupdate!");
      fetchOrders();
    } catch (error) {
      toast.error("Gagal update tugas");
    }
  };

  return (
    <div className="max-w-4xl mx-auto px-4 py-8 space-y-10">
      <div className="flex flex-col md:flex-row justify-between items-center gap-6">
         <div className="text-center md:text-left space-y-2">
            <h1 className="text-4xl font-black text-slate-900 italic tracking-tighter uppercase leading-none">Kurir <span className="text-blue-600 underline">Dashboard</span></h1>
            <p className="text-slate-500 font-bold italic tracking-wide uppercase text-xs opacity-60">Drive. Pickup. Deliver. Repeat.</p>
         </div>
         <div className="bg-slate-900 text-white p-4 rounded-3xl flex items-center space-x-4 shadow-xl">
            <div className="w-12 h-12 bg-blue-600 rounded-2xl flex items-center justify-center">
               <Truck className="w-6 h-6" />
            </div>
            <div>
               <p className="text-xs uppercase font-black text-slate-500 tracking-widest">Courier Mode</p>
               <p className="font-bold">{user?.nama}</p>
            </div>
         </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
         <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm text-center">
            <p className="text-[11px] font-bold uppercase tracking-wider text-slate-500 mb-1">Pickup Hari Ini</p>
            <p className="text-3xl font-bold text-slate-900">{orders.filter(o => o.status_order === "menunggu pickup").length}</p>
         </div>
         <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm text-center">
            <p className="text-[11px] font-bold uppercase tracking-wider text-slate-500 mb-1">Delivery Hari Ini</p>
            <p className="text-3xl font-bold text-slate-900">{orders.filter(o => o.status_order === "selesai").length}</p>
         </div>
      </div>

      <div className="space-y-6">
         <h2 className="text-xl font-black text-slate-900 uppercase italic flex items-center">
            <Navigation className="mr-3 w-6 h-6 text-blue-600" /> Tugas Aktif
         </h2>

         {isLoading ? (
            <div className="space-y-4">
               {[1, 2].map(i => <div key={i} className="h-48 bg-slate-100 rounded-[32px] animate-pulse" />)}
            </div>
         ) : orders.length > 0 ? (
            <div className="space-y-6">
               {orders.map((order) => (
                  <motion.div 
                    key={order.id_order}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="bg-white rounded-[40px] border border-slate-100 shadow-xl overflow-hidden group"
                  >
                     <div className="p-8 space-y-8">
                        <div className="flex justify-between items-start">
                           <div className="space-y-1">
                              <Badge className="bg-slate-900 text-white border-none font-mono text-[10px] mb-2 px-3">ORD-#{order.kode_order}</Badge>
                              <h3 className="text-2xl font-black text-slate-900 tracking-tight leading-none uppercase italic">{order.layanan?.nama_layanan}</h3>
                              <div className="flex items-center text-blue-600 font-bold uppercase text-[10px] tracking-widest">
                                 <Clock className="w-3 h-3 mr-1" /> {order.jam_pickup} WIB
                              </div>
                           </div>
                           <div className={`p-4 rounded-2xl ${order.status_order.includes("pickup") ? "bg-orange-100 text-orange-600" : "bg-blue-100 text-blue-600"}`}>
                              {order.status_order.includes("pickup") ? <Package className="w-6 h-6" /> : <Truck className="w-6 h-6" />}
                           </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 pt-8 border-t border-slate-50">
                           <div className="space-y-4">
                              <h4 className="text-[10px] font-black uppercase tracking-widest text-slate-400">Titik Koordinat</h4>
                              <div className="flex items-start space-x-3">
                                 <MapPin className="w-5 h-5 text-red-500 shrink-0 mt-1" />
                                 <p className="text-sm font-bold text-slate-600 leading-relaxed italic">{order.status_order.includes("pickup") ? order.alamat_pickup : order.alamat_delivery}</p>
                              </div>
                           </div>
                           <div className="space-y-4">
                              <h4 className="text-[10px] font-black uppercase tracking-widest text-slate-400">Kontak Pelanggan</h4>
                              <div className="p-4 bg-slate-50 rounded-2xl flex items-center justify-between">
                                 <div className="flex items-center space-x-3">
                                    <div className="w-10 h-10 rounded-full bg-white flex items-center justify-center border border-slate-100">
                                       <Phone className="w-4 h-4 text-blue-600" />
                                    </div>
                                    <p className="font-bold text-slate-900">{order.user?.nama}</p>
                                 </div>
                                 <Button size="sm" variant="outline" className="rounded-xl border-slate-200">Chat & Call</Button>
                              </div>
                           </div>
                        </div>

                        <div className="pt-4 flex flex-col sm:flex-row gap-3">
                           {order.status_order === "menunggu pickup" && (
                              <Button onClick={() => updateStatus(order.id_order, "dijemput kurir", "Kurir sudah mengambil pakaian. Sedang menuju workshop.")} className="flex-1 bg-orange-500 hover:bg-orange-600 text-white font-black h-14 rounded-2xl shadow-lg shadow-orange-100">
                                 Konfirmasi Pickup <CheckCircle className="ml-2 w-5 h-5" />
                              </Button>
                           )}
                           {order.status_order === "dijemput kurir" && (
                              <Button onClick={() => updateStatus(order.id_order, "sedang dicuci", "Pakaian telah sampai di workshop dan mulai diproses.")} className="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-black h-14 rounded-2xl shadow-lg shadow-blue-100 uppercase italic tracking-tighter">
                                 Serahkan ke Workshop <ChevronRight className="ml-2 w-5 h-5" />
                              </Button>
                           )}
                           {order.status_order === "selesai" && (
                              <Button onClick={() => updateStatus(order.id_order, "diantar", "Laundry bersih Anda sedang dalam perjalanan ke alamat tujuan.")} className="flex-1 bg-indigo-600 hover:bg-indigo-700 text-white font-black h-14 rounded-2xl shadow-lg shadow-indigo-100">
                                 Ambil & Antar Laundry <Truck className="ml-2 w-5 h-5" />
                              </Button>
                           )}
                           {order.status_order === "diantar" && (
                              <Button onClick={() => updateStatus(order.id_order, "selesai diterima", "Paket telah diterima dengan baik. Terima kasih!")} className="flex-1 bg-emerald-600 hover:bg-emerald-700 text-white font-black h-14 rounded-2xl shadow-lg shadow-emerald-100">
                                 Selesaikan Pengantaran <Package className="ml-2 w-5 h-5" />
                              </Button>
                           )}
                           <Button variant="ghost" className="h-14 w-14 rounded-2xl bg-slate-50 text-slate-400">
                              <Camera className="w-5 h-5" />
                           </Button>
                        </div>
                     </div>
                  </motion.div>
               ))}
            </div>
         ) : (
            <div className="text-center py-20 bg-white rounded-[40px] border border-slate-100 shadow-sm border-dashed">
               <div className="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-6">
                  <CheckCircle className="w-10 h-10 text-slate-200" />
               </div>
               <h3 className="text-lg font-black text-slate-900 uppercase">Semua Tugas Selesai!</h3>
               <p className="text-sm text-slate-500 font-medium italic mt-2">Waktunya istirahat sejenak sebelum tugas berikutnya datang.</p>
            </div>
         )}
      </div>
    </div>
  );
}
