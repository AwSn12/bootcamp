import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { 
  WashingMachine, 
  MapPin, 
  Calendar as CalendarIcon, 
  Clock, 
  ChevronRight, 
  ChevronLeft,
  Loader2,
  PackageCheck,
  CreditCard,
  History
} from "lucide-react";
import api from "@/lib/api";
import { toast } from "sonner";
import { motion, AnimatePresence } from "framer-motion";
import { format } from "date-fns";

const formSchema = z.object({
  id_layanan: z.string().min(1, { message: "Pilih layanan laundry" }),
  berat_kg: z.string().optional(),
  alamat_pickup: z.string().min(10, { message: "Alamat pickup minimal 10 karakter" }),
  alamat_delivery: z.string().min(10, { message: "Alamat delivery minimal 10 karakter" }),
  tanggal_pickup: z.string().min(1, { message: "Pilih tanggal pickup" }),
  jam_pickup: z.string().min(1, { message: "Pilih jam pickup" }),
  metode_pembayaran: z.string().min(1, { message: "Pilih metode pembayaran" }),
  catatan: z.string().optional(),
});

export default function OrderPage() {
  const [step, setStep] = useState(1);
  const [isLoading, setIsLoading] = useState(false);
  const [layanan, setLayanan] = useState<any[]>([]);
  const navigate = useNavigate();

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      id_layanan: "",
      berat_kg: "0",
      alamat_pickup: "",
      alamat_delivery: "",
      tanggal_pickup: format(new Date(), "yyyy-MM-dd"),
      jam_pickup: "10:00",
      metode_pembayaran: "BAYAR DI TEMPAT",
      catatan: "",
    },
  });

  useEffect(() => {
    fetchLayanan();
  }, []);

  const fetchLayanan = async () => {
    try {
      const response = await api.get("/layanan");
      setLayanan(response.data);
    } catch (error) {
      toast.error("Gagal mengambil data layanan");
    }
  };

  const selectedLayanan = layanan.find(l => l.id_layanan.toString() === form.watch("id_layanan"));

  async function onSubmit(values: z.infer<typeof formSchema>) {
    setIsLoading(true);
    try {
      await api.post("/orders", {
        ...values,
        id_layanan: parseInt(values.id_layanan),
        berat_kg: parseFloat(values.berat_kg || "0"),
      });
      toast.success("Order berhasil dibuat! Kurir akan segera menjemput laundry Anda.");
      navigate("/dashboard");
    } catch (error: any) {
      toast.error(error.response?.data?.error || "Gagal membuat order");
    } finally {
      setIsLoading(false);
    }
  }

  const nextStep = () => {
    const fieldsToValidate = 
      step === 1 ? ["id_layanan"] : 
      step === 2 ? ["alamat_pickup", "alamat_delivery", "tanggal_pickup", "jam_pickup"] :
      step === 3 ? ["metode_pembayaran"] : [];
    
    form.trigger(fieldsToValidate as any).then(isValid => {
      if (isValid) setStep(step + 1);
    });
  };

  const prevStep = () => setStep(step - 1);

  return (
    <div className="max-w-4xl mx-auto px-4 py-12 relative overflow-hidden">
      <div className="absolute top-0 right-0 -translate-y-1/2 translate-x-1/2 w-64 h-64 bg-blue-100 rounded-full blur-3xl opacity-30" />
      
      <div className="mb-12 space-y-4 text-center">
        <h1 className="text-4xl font-black text-slate-900 tracking-tight leading-none uppercase italic">Buat Pesanan <span className="text-blue-600 underline">Baru</span></h1>
        <div className="flex items-center justify-center space-x-4">
           {[1, 2, 3, 4].map((s) => (
             <div key={s} className="flex items-center">
               <div className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-xs transition-all duration-500 ${step === s ? "bg-blue-600 text-white scale-115 shadow-lg shadow-blue-200" : step > s ? "bg-emerald-500 text-white" : "bg-slate-200 text-slate-500"}`}>
                  {s}
               </div>
               {s < 4 && <div className={`w-12 h-0.5 mx-2 transition-colors duration-500 ${step > s ? "bg-emerald-500" : "bg-slate-200"}`} />}
             </div>
           ))}
        </div>
      </div>

      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
          <AnimatePresence mode="wait">
            {step === 1 && (
              <motion.div
                key="step1"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                className="space-y-6"
              >
                <Card className="border-slate-100 shadow-xl overflow-hidden rounded-[32px]">
                  <CardHeader className="bg-slate-900 text-white p-8">
                    <CardTitle className="text-2xl font-black flex items-center">
                       <WashingMachine className="mr-3 w-8 h-8 text-blue-500" /> Pilih Jenis Layanan
                    </CardTitle>
                    <CardDescription className="text-slate-400 font-medium italic">Tentukan jenis laundry yang Anda butuhkan hari ini.</CardDescription>
                  </CardHeader>
                  <CardContent className="p-8">
                    <FormField
                      control={form.control}
                      name="id_layanan"
                      render={({ field }) => (
                        <FormItem className="space-y-6">
                          <FormControl>
                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                              {layanan.map((l) => (
                                <div 
                                  key={l.id_layanan}
                                  onClick={() => field.onChange(l.id_layanan.toString())}
                                  className={`p-6 rounded-[24px] border-2 cursor-pointer transition-all duration-300 flex flex-col space-y-4 hover:shadow-lg ${field.value === l.id_layanan.toString() ? "border-blue-600 bg-blue-50 shadow-inner" : "border-slate-100 bg-white hover:border-blue-200 shadow-sm"}`}
                                >
                                  <div className="flex justify-between items-start">
                                     <div className={`p-4 rounded-2xl ${field.value === l.id_layanan.toString() ? "bg-blue-600 text-white" : "bg-slate-100 text-slate-400"}`}>
                                        <WashingMachine className="w-6 h-6" />
                                     </div>
                                     <div className={`w-6 h-6 rounded-full border-2 flex items-center justify-center ${field.value === l.id_layanan.toString() ? "border-blue-600" : "border-slate-300"}`}>
                                        {field.value === l.id_layanan.toString() && <div className="w-3 h-3 rounded-full bg-blue-600" />}
                                     </div>
                                  </div>
                                  <div>
                                    <h4 className="font-black text-slate-900 text-lg uppercase tracking-tight">{l.nama_layanan}</h4>
                                    <p className="text-xs text-slate-500 font-medium leading-relaxed italic mt-1">{l.deskripsi}</p>
                                  </div>
                                  <div className="pt-4 border-t border-slate-100 flex items-center justify-between">
                                     <span className="text-blue-600 font-black text-lg">Rp {l.harga_per_kg.toLocaleString()}</span>
                                     <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">{l.estimasi_hari} Hari Estimasi</span>
                                  </div>
                                </div>
                              ))}
                            </div>
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                  </CardContent>
                </Card>
              </motion.div>
            )}

            {step === 2 && (
              <motion.div
                key="step2"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                className="space-y-6"
              >
                <Card className="border-slate-100 shadow-xl rounded-[32px] overflow-hidden">
                  <CardHeader className="bg-slate-50 border-b border-slate-100 p-8">
                     <CardTitle className="text-2xl font-black flex items-center text-slate-900">
                        <MapPin className="mr-3 w-8 h-8 text-blue-600" /> Detail Penjemputan
                     </CardTitle>
                     <CardDescription className="text-slate-500 font-medium italic">Pastikan alamat dan waktu benar agar kurir tidak tersasar.</CardDescription>
                  </CardHeader>
                  <CardContent className="p-8 space-y-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                      <FormField
                        control={form.control}
                        name="alamat_pickup"
                        render={({ field }) => (
                          <FormItem className="space-y-3">
                            <FormLabel className="text-[10px] font-black uppercase tracking-widest text-slate-400">Alamat Penjemputan</FormLabel>
                            <FormControl>
                              <Textarea placeholder="Jl. Raya No. 123, Kelurahan, Kecamatan..." {...field} className="min-h-[120px] rounded-2xl bg-slate-50 border-slate-100 resize-none focus:ring-blue-600 font-medium" />
                            </FormControl>
                            <FormMessage />
                          </FormItem>
                        )}
                      />
                      <FormField
                        control={form.control}
                        name="alamat_delivery"
                        render={({ field }) => (
                          <FormItem className="space-y-3">
                             <div className="flex justify-between items-center">
                                <FormLabel className="text-[10px] font-black uppercase tracking-widest text-slate-400">Alamat Pengantaran</FormLabel>
                                <button type="button" onClick={() => form.setValue("alamat_delivery", form.getValues("alamat_pickup"))} className="text-[10px] font-bold text-blue-600 hover:underline">Sama dengan pickup</button>
                             </div>
                            <FormControl>
                              <Textarea placeholder="Jl. Raya No. 123, Kelurahan, Kecamatan..." {...field} className="min-h-[120px] rounded-2xl bg-slate-50 border-slate-100 resize-none focus:ring-blue-600 font-medium" />
                            </FormControl>
                            <FormMessage />
                          </FormItem>
                        )}
                      />
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 pt-4 border-t border-slate-100">
                      <FormField
                        control={form.control}
                        name="tanggal_pickup"
                        render={({ field }) => (
                          <FormItem className="space-y-3">
                            <FormLabel className="text-[10px] font-black uppercase tracking-widest text-slate-400">Tanggal Pickup</FormLabel>
                            <FormControl>
                              <Input type="date" {...field} className="rounded-xl bg-slate-50 border-slate-100 h-12 font-bold" />
                            </FormControl>
                            <FormMessage />
                          </FormItem>
                        )}
                      />
                      <FormField
                        control={form.control}
                        name="jam_pickup"
                        render={({ field }) => (
                          <FormItem className="space-y-3">
                            <FormLabel className="text-[10px] font-black uppercase tracking-widest text-slate-400">Jam Pickup</FormLabel>
                            <Select onValueChange={field.onChange} defaultValue={field.value}>
                              <FormControl>
                                <SelectTrigger className="h-12 rounded-xl bg-slate-50 border-slate-100 font-bold">
                                  <SelectValue placeholder="Pilih Jam" />
                                </SelectTrigger>
                              </FormControl>
                              <SelectContent>
                                {["09:00", "10:00", "11:00", "13:00", "14:00", "15:00", "16:00", "17:00", "19:00"].map((time) => (
                                  <SelectItem key={time} value={time}>{time} WIB</SelectItem>
                                ))}
                              </SelectContent>
                            </Select>
                            <FormMessage />
                          </FormItem>
                        )}
                      />
                       <FormField
                        control={form.control}
                        name="catatan"
                        render={({ field }) => (
                          <FormItem className="space-y-3">
                            <FormLabel className="text-[10px] font-black uppercase tracking-widest text-slate-400">Catatan Khusus</FormLabel>
                            <FormControl>
                              <Input placeholder="Contoh: Titip di satpam" {...field} className="h-12 rounded-xl bg-slate-50 border-slate-100 font-medium italic" />
                            </FormControl>
                          </FormItem>
                        )}
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            )}

            {step === 3 && (
              <motion.div
                key="step3"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                className="space-y-6"
              >
                <Card className="border-slate-100 shadow-xl rounded-[32px] overflow-hidden">
                  <CardHeader className="bg-slate-50 border-b border-slate-100 p-8">
                     <CardTitle className="text-2xl font-black flex items-center text-slate-900">
                        <CreditCard className="mr-3 w-8 h-8 text-blue-600" /> Metode Pembayaran
                     </CardTitle>
                     <CardDescription className="text-slate-500 font-medium italic">Pilih cara pembayaran yang paling nyaman bagi Anda.</CardDescription>
                  </CardHeader>
                  <CardContent className="p-8">
                    <FormField
                      control={form.control}
                      name="metode_pembayaran"
                      render={({ field }) => (
                        <FormItem className="space-y-6">
                          <FormControl>
                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                              {[
                                { id: "BAYAR DI TEMPAT", label: "Bayar di Tempat (COD)", icon: <PackageCheck className="w-5 h-5" />, desc: "Bayar tunai saat kurir mengambil/mengantar." },
                                { id: "QRIS", label: "QRIS", icon: <CreditCard className="w-5 h-5" />, desc: "Scan kode QR (OVO, GoPay, Dana, LinkAja)." },
                                { id: "E-WALLET", label: "E-Wallet", icon: <History className="w-5 h-5" />, desc: "Transfer saldo E-Wallet favorit Anda." },
                                { id: "CREDIT CARD", label: "Credit Card", icon: <CreditCard className="w-5 h-5" />, desc: "Visa, Mastercard, atau JCB." }
                              ].map((method) => (
                                <div 
                                  key={method.id}
                                  onClick={() => field.onChange(method.id)}
                                  className={`p-6 rounded-[24px] border-2 cursor-pointer transition-all duration-300 flex flex-col space-y-3 hover:shadow-lg ${field.value === method.id ? "border-blue-600 bg-blue-50" : "border-slate-100 bg-white hover:border-blue-200"}`}
                                >
                                  <div className="flex justify-between items-center">
                                     <div className={`p-3 rounded-xl ${field.value === method.id ? "bg-blue-600 text-white" : "bg-slate-100 text-slate-400"}`}>
                                        {method.icon}
                                     </div>
                                     <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${field.value === method.id ? "border-blue-600" : "border-slate-300"}`}>
                                        {field.value === method.id && <div className="w-2.5 h-2.5 rounded-full bg-blue-600" />}
                                     </div>
                                  </div>
                                  <div>
                                    <h4 className="font-black text-slate-900 text-sm uppercase tracking-tight">{method.label}</h4>
                                    <p className="text-[10px] text-slate-500 font-medium italic">{method.desc}</p>
                                  </div>
                                </div>
                              ))}
                            </div>
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                  </CardContent>
                </Card>
              </motion.div>
            )}

            {step === 4 && (
              <motion.div
                key="step4"
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.95 }}
                className="space-y-6"
              >
                <Card className="border-slate-100 shadow-xl rounded-[32px] overflow-hidden">
                  <CardHeader className="bg-emerald-500 text-white p-12 text-center relative overflow-hidden group">
                     {/* Atoms decor */}
                     <div className="absolute top-0 left-0 w-full h-full opacity-10 pointer-events-none">
                        <div className="grid grid-cols-10 h-full w-full">
                           {Array.from({length: 40}).map((_, i) => (
                             <div key={i} className="border border-white/20 aspect-square" />
                           ))}
                        </div>
                     </div>
                     <div className="relative z-10 space-y-4">
                        <div className="mx-auto w-20 h-20 bg-white rounded-full flex items-center justify-center mb-4">
                           <PackageCheck className="w-10 h-10 text-emerald-500" />
                        </div>
                        <CardTitle className="text-4xl font-black uppercase tracking-tighter italic">Review Pesanan</CardTitle>
                        <CardDescription className="text-emerald-50 font-bold opacity-80 uppercase tracking-widest text-xs">Pastikan semua data sudah benar sebelum checkout.</CardDescription>
                     </div>
                  </CardHeader>
                  <CardContent className="p-12">
                     <div className="grid grid-cols-1 md:grid-cols-2 gap-12">
                        <div className="space-y-8">
                           <div className="space-y-4">
                              <h4 className="text-[10px] font-black uppercase tracking-widest text-slate-400">Layanan & Alamat</h4>
                              <div className="space-y-4">
                                 <div className="flex items-center space-x-4">
                                    <div className="p-3 bg-blue-50 rounded-xl text-blue-600">
                                       <WashingMachine className="w-5 h-5" />
                                    </div>
                                    <div className="font-bold text-lg text-slate-900">{selectedLayanan?.nama_layanan}</div>
                                 </div>
                                 <div className="flex items-start space-x-4">
                                    <div className="p-3 bg-orange-50 rounded-xl text-orange-600">
                                       <MapPin className="w-5 h-5" />
                                    </div>
                                    <div className="text-sm">
                                       <p className="font-black text-[10px] uppercase text-slate-400">Pickup:</p>
                                       <p className="font-medium text-slate-700 leading-snug">{form.getValues("alamat_pickup")}</p>
                                    </div>
                                 </div>
                                 <div className="flex items-center space-x-4">
                                    <div className="p-3 bg-indigo-50 rounded-xl text-indigo-600">
                                       <Clock className="w-5 h-5" />
                                    </div>
                                    <div className="text-sm">
                                       <p className="font-black text-[10px] uppercase text-slate-400">Waktu:</p>
                                       <p className="font-bold text-slate-900">{form.getValues("tanggal_pickup")}, {form.getValues("jam_pickup")} WIB</p>
                                    </div>
                                 </div>
                              </div>
                           </div>
                        </div>

                        <div className="bg-slate-50 rounded-3xl p-8 space-y-6">
                           <h4 className="text-[10px] font-black uppercase tracking-widest text-slate-400">Rincian Estimasi</h4>
                           <div className="space-y-4">
                              <div className="flex justify-between items-center text-slate-600 font-medium">
                                 <span>Subtotal Layanan</span>
                                 <span>Rp {selectedLayanan?.harga_per_kg.toLocaleString()} / kg</span>
                              </div>
                              <div className="flex justify-between items-center text-slate-600 font-medium">
                                 <span>Ongkos Kirim</span>
                                 <span>Rp 5.000</span>
                              </div>
                              <div className="pt-4 border-t border-slate-200">
                                 <div className="flex justify-between items-center">
                                    <span className="font-black text-slate-900 uppercase italic tracking-tighter text-sm">Total Estimasi</span>
                                    <span className="text-3xl font-black text-blue-600">Rp {(selectedLayanan?.harga_per_kg + 5000).toLocaleString()}</span>
                                 </div>
                                 <p className="text-[10px] text-slate-400 italic text-right mt-2">*Berat aktual akan diupdate setelah kurir menimbang cucian.</p>
                              </div>
                           </div>
                           <div className="pt-4 flex items-center space-x-2 text-emerald-600">
                              <CreditCard className="w-4 h-4" />
                              <span className="text-xs font-bold uppercase tracking-widest">Metode: {form.getValues("metode_pembayaran")}</span>
                           </div>
                        </div>
                     </div>
                  </CardContent>
                </Card>
              </motion.div>
            )}
          </AnimatePresence>

          <div className="flex justify-between items-center pt-8 bg-white/50 backdrop-blur sticky bottom-0 border-t border-white p-4 rounded-t-3xl shadow-[0_-10px_20px_rgba(0,0,0,0.05)]">
            <Button
              type="button"
              variant="outline"
              onClick={step === 1 ? () => navigate("/dashboard") : prevStep}
              className="h-14 px-8 rounded-2xl border-slate-200 font-bold text-slate-600 group"
              disabled={isLoading}
            >
              <ChevronLeft className="mr-2 w-5 h-5 group-hover:-translate-x-1 transition-all" />
              {step === 1 ? "Batal" : "Kembali"}
            </Button>

            {step < 4 ? (
              <Button
                type="button"
                onClick={nextStep}
                className="h-14 px-10 rounded-2xl bg-slate-900 hover:bg-black text-white font-black group transition-all"
              >
                Selanjutnya <ChevronRight className="ml-2 w-5 h-5 group-hover:translate-x-1 transition-all" />
              </Button>
            ) : (
              <Button
                type="submit"
                className="h-14 px-12 rounded-2xl bg-blue-600 hover:bg-blue-700 text-white font-black shadow-xl shadow-blue-200 group relative overflow-hidden"
                disabled={isLoading}
              >
                {isLoading ? (
                  <Loader2 className="w-5 h-5 animate-spin" />
                ) : (
                  <span className="flex items-center">
                    Konfirmasi & Checkout <ChevronRight className="ml-2 w-5 h-5 group-hover:translate-x-1 transition-all" />
                  </span>
                )}
              </Button>
            )}
          </div>
        </form>
      </Form>
    </div>
  );
}
