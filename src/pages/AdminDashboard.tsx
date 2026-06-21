import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from "@/components/ui/table";
import { 
  BarChart, 
  Users, 
  Package, 
  TrendingUp, 
  MoreVertical, 
  CheckCircle, 
  Clock, 
  Truck,
  RotateCcw,
  Search,
  Filter,
  Download
} from "lucide-react";
import api from "@/lib/api";
import { Badge } from "@/components/ui/badge";
import { toast } from "sonner";
import { Input } from "@/components/ui/input";
import { 
  DropdownMenu, 
  DropdownMenuContent, 
  DropdownMenuItem, 
  DropdownMenuLabel, 
  DropdownMenuSeparator, 
  DropdownMenuTrigger 
} from "@/components/ui/dropdown-menu";

export default function AdminDashboard() {
  const [orders, setOrders] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [stats, setStats] = useState({ totalOrders: 0, pending: 0, active: 0, completed: 0 });

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      const response = await api.get("/orders");
      setOrders(response.data);
      
      const completed = response.data.filter((o: any) => o.status_order === "selesai diterima").length;
      const pending = response.data.filter((o: any) => o.status_order === "menunggu pickup").length;
      
      setStats({
        totalOrders: response.data.length,
        pending: pending,
        active: response.data.length - completed - pending,
        completed: completed,
      });
    } catch (error) {
      toast.error("Gagal mengambil data pesanan");
    } finally {
      setIsLoading(false);
    }
  };

  const updateStatus = async (id: number, status: string, keterangan: string) => {
    try {
      await api.patch(`/orders/${id}/status`, { status_order: status, keterangan });
      toast.success("Status pesanan berhasil diperbarui");
      fetchOrders();
    } catch (error) {
      toast.error("Gagal memperbarui status");
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "menunggu pickup": return <Badge className="bg-orange-100 text-orange-600 border-none font-bold">MENUNGGU</Badge>;
      case "dijemput kurir": return <Badge className="bg-blue-100 text-blue-600 border-none font-bold">DIJEMPUT</Badge>;
      case "sedang dicuci": return <Badge className="bg-indigo-100 text-indigo-600 border-none font-bold">DICUCI</Badge>;
      case "selesai": return <Badge className="bg-emerald-100 text-emerald-600 border-none font-bold">SELESAI</Badge>;
      case "diantar": return <Badge className="bg-sky-100 text-sky-600 border-none font-bold">DIANTAR</Badge>;
      case "selesai diterima": return <Badge className="bg-slate-100 text-slate-500 border-none font-bold">SELESAI DITERIMA</Badge>;
      default: return <Badge variant="outline">{status}</Badge>;
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-4 py-8 space-y-8">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6 pb-6 border-b border-slate-100">
         <div>
            <h1 className="text-3xl font-black text-slate-900 tracking-tight leading-none italic uppercase">Admin <span className="text-blue-600">Console</span></h1>
            <p className="text-slate-400 font-medium italic mt-2">Kelola semua operasional laundry dalam satu dasbor terpusat.</p>
         </div>
         <div className="flex items-center space-x-3">
            <Button variant="outline" className="border-slate-200 h-11 px-6 rounded-xl font-bold">
               <Download className="mr-2 w-4 h-4" /> Export Report
            </Button>
            <Button onClick={fetchOrders} variant="ghost" size="icon" className="h-11 w-11 hover:bg-slate-100">
               <RotateCcw className="w-5 h-5 text-slate-500" />
            </Button>
         </div>
      </div>

      {/* Admin Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
         {[
           { label: "Order Aktif", value: stats.active, icon: Package, color: "border-slate-200" },
           { label: "Pending Pickup", value: stats.pending, icon: Clock, color: "border-slate-200" },
           { label: "Selesai", value: stats.completed, icon: CheckCircle, color: "border-slate-200" },
           { label: "Growth", value: "+12%", icon: TrendingUp, color: "border-slate-200" },
         ].map((stat, i) => (
           <div key={i} className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm flex flex-col gap-2">
              <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">{stat.label}</span>
              <span className="text-2xl font-bold text-slate-900">{stat.value}</span>
           </div>
         ))}
      </div>

      {/* Main Table Card */}
      <Card className="border-slate-100 shadow-xl rounded-[40px] overflow-hidden bg-white">
        <CardHeader className="p-8 bg-slate-50 border-b border-slate-100">
          <div className="flex flex-col md:flex-row justify-between items-center gap-6">
             <div className="space-y-1">
                <CardTitle className="text-xl font-black text-slate-900 tracking-tight uppercase italic">Manajemen Pesanan</CardTitle>
                <CardDescription className="font-medium italic">Anda mengelola total {orders.length} pesanan hari ini.</CardDescription>
             </div>
             <div className="flex items-center space-x-3 w-full md:w-auto">
                <div className="relative flex-1 md:w-64">
                   <Search className="absolute left-3 top-3 w-4 h-4 text-slate-400" />
                   <Input placeholder="Cari Kode Order..." className="pl-10 h-10 rounded-xl bg-white border-slate-200" />
                </div>
                <Button variant="outline" size="icon" className="h-10 w-10 border-slate-200">
                   <Filter className="w-4 h-4 text-slate-500" />
                </Button>
             </div>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader className="bg-slate-50/50">
              <TableRow className="border-slate-100">
                <TableHead className="w-[150px] font-black uppercase tracking-widest text-[10px] text-slate-400 px-8">Kode Order</TableHead>
                <TableHead className="font-black uppercase tracking-widest text-[10px] text-slate-400">Pelanggan</TableHead>
                <TableHead className="font-black uppercase tracking-widest text-[10px] text-slate-400">Layanan</TableHead>
                <TableHead className="font-black uppercase tracking-widest text-[10px] text-slate-400">Status</TableHead>
                <TableHead className="font-black uppercase tracking-widest text-[10px] text-slate-400">Total</TableHead>
                <TableHead className="text-right font-black uppercase tracking-widest text-[10px] text-slate-400 px-8">Aksi</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {orders.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-20 text-slate-400 font-medium italic">
                    Belum ada pesanan masuk.
                  </TableCell>
                </TableRow>
              ) : (
                orders.map((order) => (
                  <TableRow key={order.id_order} className="border-slate-50 hover:bg-slate-50/50 transition-colors group">
                    <TableCell className="px-8 font-mono text-xs font-bold text-slate-400">#{order.kode_order}</TableCell>
                    <TableCell>
                      <div className="flex items-center space-x-3">
                        <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center">
                          <Users className="w-4 h-4 text-slate-400" />
                        </div>
                        <div>
                          <p className="font-bold text-slate-900 text-sm">{order.user?.nama}</p>
                          <p className="text-[10px] text-slate-500 font-medium">{order.user?.no_telp}</p>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell className="font-bold text-slate-600 text-sm">{order.layanan?.nama_layanan}</TableCell>
                    <TableCell>{getStatusBadge(order.status_order)}</TableCell>
                    <TableCell className="font-black text-blue-600">Rp {order.total_bayar.toLocaleString()}</TableCell>
                    <TableCell className="text-right px-8">
                       <DropdownMenu>
                         <DropdownMenuTrigger>
                           <Button variant="ghost" size="icon" className="h-8 w-8 text-slate-400 hover:text-slate-900">
                             <MoreVertical className="w-4 h-4" />
                           </Button>
                         </DropdownMenuTrigger>
                         <DropdownMenuContent align="end" className="w-56 rounded-xl border-slate-100 shadow-xl p-2">
                           <DropdownMenuLabel className="text-[10px] font-black uppercase tracking-widest text-slate-400 px-4 py-2">Update Progres</DropdownMenuLabel>
                           <DropdownMenuSeparator />
                           <DropdownMenuItem onClick={() => updateStatus(order.id_order, "dijemput kurir", "Kurir sedang dalam perjalanan menjemput pakaian Anda.")} className="rounded-lg font-bold text-blue-600 focus:text-blue-700">Tandai Dijemput</DropdownMenuItem>
                           <DropdownMenuItem onClick={() => updateStatus(order.id_order, "sedang dicuci", "Pakaian Anda sedang dalam proses pencucian intensif.")} className="rounded-lg font-bold text-indigo-600 focus:text-indigo-700">Mulai Mencuci</DropdownMenuItem>
                           <DropdownMenuItem onClick={() => updateStatus(order.id_order, "sedang disetrika", "Proses penyetrikaan agar pakaian rapi dan wangi.")} className="rounded-lg font-bold text-orange-600 focus:text-orange-700">Mulai Menyetrika</DropdownMenuItem>
                           <DropdownMenuItem onClick={() => updateStatus(order.id_order, "selesai", "Laundry sudah bersih dan rapi, siap untuk diantar.")} className="rounded-lg font-bold text-emerald-600 focus:text-emerald-700">Tandai Selesai</DropdownMenuItem>
                           <DropdownMenuItem onClick={() => updateStatus(order.id_order, "diantar", "Kurir sedang mengantar laundry Anda ke lokasi tujuan.")} className="rounded-lg font-bold text-sky-600 focus:text-sky-700">Antarkan Laundry</DropdownMenuItem>
                           <DropdownMenuSeparator />
                           <DropdownMenuItem onClick={() => updateStatus(order.id_order, "selesai diterima", "Paket laundry telah diterima oleh pelanggan. Terima kasih!")} className="rounded-lg font-black text-slate-900 bg-slate-50 focus:bg-slate-100">Selesai Diterima</DropdownMenuItem>
                         </DropdownMenuContent>
                       </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
