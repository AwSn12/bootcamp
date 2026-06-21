import { useState, useEffect } from "react";
import { useParams, Link } from "react-router-dom";
import { 
  Package, 
  Truck, 
  CheckCircle2, 
  MapPin, 
  Clock, 
  ChevronLeft,
  Search,
  WashingMachine,
  History,
  Phone,
  User as UserIcon
} from "lucide-react";
import api from "@/lib/api";
import { motion } from "framer-motion";
import { format } from "date-fns";
import { id } from "date-fns/locale";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";

export default function TrackingPage() {
  const { kode } = useParams();
  const [order, setOrder] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchTracking();
  }, [kode]);

  const fetchTracking = async () => {
    try {
      const response = await api.get(`/tracking/${kode}`);
      setOrder(response.data);
    } catch (error) {
      console.error("Gagal mengambil tracking data", error);
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] space-y-4">
        <div className="w-16 h-16 border-4 border-blue-600 border-t-transparent rounded-full animate-spin" />
        <p className="text-slate-500 font-bold tracking-widest uppercase text-xs animate-pulse">Menghubungkan ke satelit...</p>
      </div>
    );
  }

  if (!order) {
    return (
      <div className="max-w-md mx-auto text-center py-20 px-4">
        <div className="w-24 h-24 bg-red-50 text-red-500 rounded-full flex items-center justify-center mx-auto mb-6">
           <Search className="w-12 h-12" />
        </div>
        <h2 className="text-2xl font-black text-slate-900 leading-tight">Order Tidak Ditemukan</h2>
        <p className="text-slate-500 mt-2 font-medium">Mohon periksa kembali kode order Anda atau hubungi customer service kami.</p>
        <Link to="/dashboard" className="block mt-8">
           <Button className="bg-slate-900 w-full h-12 rounded-xl font-bold">Kembali ke Dashboard</Button>
        </Link>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-8 space-y-8 pb-20">
      <Link to="/dashboard" className="inline-flex items-center text-sm font-bold text-slate-400 hover:text-slate-900 transition-colors group">
         <ChevronLeft className="mr-2 w-4 h-4 group-hover:-translate-x-1 transition-all" /> Kembali
      </Link>

      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6 pb-8 border-b border-slate-100">
         <div>
            <div className="flex items-center space-x-3 mb-2">
               <h1 className="text-3xl font-black text-slate-900 tracking-tight leading-none italic uppercase">Tracking <span className="text-blue-600">Order</span></h1>
               <Badge className="bg-blue-600 text-white border-none font-black px-3 py-1">#{order.kode_order}</Badge>
            </div>
            <p className="text-slate-400 font-medium italic">Update status terakhir: {order.tracking[0] ? format(new Date(order.tracking[0].waktu_update), "dd MMM yyyy, HH:mm", { locale: id }) : "-"}</p>
         </div>
         <div className="flex items-center space-x-2">
            <Button variant="outline" className="border-slate-200 h-12 px-6 rounded-xl font-bold group">
               <Phone className="mr-2 w-4 h-4 text-emerald-500" /> Hubungi Admin
            </Button>
         </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
        {/* Timeline Column */}
        <div className="lg:col-span-2 space-y-8">
          <div className="bg-white p-8 rounded-2xl border border-slate-200 shadow-sm space-y-0 relative">
             <div className="card-title text-18 font-bold mb-8 flex justify-between">Status Laundry Saat Ini <Badge className="bg-blue-100 text-blue-800 font-bold">#{order.kode_order}</Badge></div>
             
             <div className="flex flex-col relative pl-8">
             {order.tracking.map((track: any, index: number) => (
                <motion.div 
                  key={track.id_tracking}
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: index * 0.1 }}
                  className={`relative pb-8 ${index !== order.tracking.length - 1 ? "border-l-2 border-dashed border-slate-200" : ""}`}
                >
                   <div className={`absolute -left-[11px] top-0 w-[20px] h-[20px] rounded-full border-2 bg-white flex items-center justify-center ${index === 0 ? "border-blue-600 bg-blue-600 ring-4 ring-blue-50" : "border-slate-200"}`}>
                      {index === 0 ? <CheckCircle2 className="w-3 h-3 text-white" /> : <div className="w-1.5 h-1.5 rounded-full bg-slate-300" />}
                   </div>
                   <div className="pl-6 -translate-y-1">
                      <div className="flex items-center space-x-2">
                         <h4 className={`text-sm font-bold uppercase tracking-tight ${index === 0 ? "text-slate-900" : "text-slate-400"}`}>{track.status_tracking}</h4>
                         <span className="text-[10px] font-bold text-slate-400">{format(new Date(track.waktu_update), "HH:mm 'WIB'", { locale: id })}</span>
                      </div>
                      <p className={`text-xs mt-1 ${index === 0 ? "text-slate-600" : "text-slate-400"}`}>{track.keterangan}</p>
                   </div>
                </motion.div>
             ))}
             </div>

             <div className="mt-8 bg-slate-50 border border-slate-200 rounded-xl p-6">
                <p className="text-[11px] font-bold text-slate-500 uppercase mb-2 tracking-widest">Detail Paket:</p>
                <div className="text-sm font-bold text-slate-900">{order.layanan?.nama_layanan} ({order.berat_kg}kg)</div>
                <div className="text-xs text-slate-500 mt-1 italic">Catatan: {order.catatan || "-"}</div>
             </div>
          </div>
        </div>

        {/* Info Column */}
        <div className="space-y-8">
           <motion.div 
             initial={{ opacity: 0, y: 20 }}
             animate={{ opacity: 1, y: 0 }}
             className="bg-slate-900 p-8 rounded-[40px] text-white space-y-8 relative overflow-hidden"
           >
              <div className="absolute top-0 right-0 -translate-y-1/2 translate-x-1/2 w-48 h-48 bg-blue-600 rounded-full blur-3xl opacity-20" />
              <div className="relative z-10 space-y-6">
                 <div>
                    <h5 className="text-[10px] font-black uppercase tracking-widest text-slate-500 mb-2">Kurir Pengantar</h5>
                    <div className="flex items-center space-x-4">
                       <div className="w-12 h-12 bg-slate-800 rounded-2xl flex items-center justify-center border border-slate-700">
                          <UserIcon className="w-6 h-6 text-blue-400" />
                       </div>
                       <div>
                          <p className="font-bold text-lg">{order.kurir?.nama_kurir || "Sedang Mencari..."}</p>
                          <p className="text-xs text-slate-500 font-medium italic">Driver LaundryKu ID #{order.kurir?.id_kurir || "N/A"}</p>
                       </div>
                    </div>
                 </div>
                 <div className="w-full h-px bg-slate-800" />
                 <div className="space-y-4">
                    <div>
                       <h5 className="text-[10px] font-black uppercase tracking-widest text-slate-500 mb-1">Alamat Penjemputan</h5>
                       <p className="text-xs font-medium text-slate-300 leading-relaxed italic">{order.alamat_pickup}</p>
                    </div>
                    <div>
                       <h5 className="text-[10px] font-black uppercase tracking-widest text-slate-500 mb-1">Alamat Pengantaran</h5>
                       <p className="text-xs font-medium text-slate-300 leading-relaxed italic">{order.alamat_delivery}</p>
                    </div>
                 </div>
                 <div className="pt-2">
                    <Button variant="secondary" className="w-full bg-blue-600 hover:bg-blue-700 text-white font-black h-12 shadow-xl shadow-blue-500/20">
                       <Phone className="mr-2 w-4 h-4" /> Hubungi Kurir
                    </Button>
                 </div>
              </div>
           </motion.div>

           <div className="bg-white p-8 rounded-[40px] border border-slate-100 shadow-sm space-y-6">
              <h5 className="text-[10px] font-black uppercase tracking-widest text-slate-400">Ringkasan Layanan</h5>
              <div className="flex items-center space-x-4">
                 <div className="p-4 bg-blue-100 text-blue-600 rounded-2xl">
                    <WashingMachine className="w-6 h-6" />
                 </div>
                 <div>
                    <p className="font-black text-slate-900 tracking-tight uppercase leading-none">{order.layanan?.nama_layanan}</p>
                    <p className="text-xs text-slate-500 mt-1 font-bold">Rp {order.layanan?.harga_per_kg.toLocaleString()}/kg</p>
                 </div>
              </div>
              <div className="bg-slate-50 p-6 rounded-3xl space-y-3">
                 <div className="flex justify-between text-xs font-bold text-slate-500 uppercase tracking-wider">
                    <span>Estimasi Selesai</span>
                    <span className="text-slate-900">{order.layanan?.estimasi_hari} Hari</span>
                 </div>
                 <div className="flex justify-between text-xs font-bold text-slate-500 uppercase tracking-wider">
                    <span>Berat</span>
                    <span className="text-slate-900">{order.berat_kg} KG</span>
                 </div>
                 <div className="pt-3 border-t border-slate-200 flex justify-between items-end">
                    <span className="text-sm font-black italic uppercase text-slate-900">Total</span>
                    <span className="text-2xl font-black text-blue-600">Rp {order.total_bayar.toLocaleString()}</span>
                 </div>
              </div>
           </div>
        </div>
      </div>
    </div>
  );
}
