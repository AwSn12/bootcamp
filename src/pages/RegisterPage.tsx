import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Link, useNavigate } from "react-router-dom";
import { WashingMachine, UserPlus, Loader2, User, Phone, MapPin, Mail, Lock } from "lucide-react";
import api from "@/lib/api";
import { toast } from "sonner";
import { motion } from "framer-motion";

const formSchema = z.object({
  nama: z.string().min(3, { message: "Nama minimal 3 karakter" }),
  email: z.string().email({ message: "Email tidak valid" }),
  no_telp: z.string().min(10, { message: "Nomor telepon minimal 10 digit" }),
  alamat: z.string().min(5, { message: "Alamat minimal 5 karakter" }),
  username: z.string().min(3, { message: "Username minimal 3 karakter" }),
  password: z.string().min(6, { message: "Password minimal 6 karakter" }),
});

export default function RegisterPage() {
  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      nama: "",
      email: "",
      no_telp: "",
      alamat: "",
      username: "",
      password: "",
    },
  });

  async function onSubmit(values: z.infer<typeof formSchema>) {
    setIsLoading(true);
    try {
      await api.post("/auth/register", values);
      toast.success("Registrasi berhasil! Silakan login untuk melanjutkan.");
      navigate("/login");
    } catch (error: any) {
      toast.error(error.response?.data?.error || "Terjadi kesalahan saat registrasi");
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <div className="flex items-center justify-center min-h-[calc(100vh-120px)] p-4 bg-slate-50 relative overflow-hidden">
      {/* Decorative background atoms */}
      <div className="absolute top-0 left-0 -translate-y-1/2 -translate-x-1/2 w-96 h-96 bg-blue-100 rounded-full blur-3xl opacity-30" />
      <div className="absolute bottom-0 right-0 translate-y-1/2 translate-x-1/2 w-96 h-96 bg-blue-200 rounded-full blur-3xl opacity-20" />

      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5 }}
        className="w-full max-w-2xl relative z-10"
      >
        <Card className="border-slate-100 shadow-2xl bg-white/90 backdrop-blur-sm overflow-hidden">
          <div className="h-2 bg-blue-600" />
          <div className="grid grid-cols-1 md:grid-cols-5">
            <div className="md:col-span-2 bg-slate-900 p-8 text-white flex flex-col justify-between items-center text-center">
              <div className="space-y-6">
                <div className="inline-flex p-4 bg-blue-600 rounded-2xl shadow-xl shadow-blue-500/20">
                  <WashingMachine className="w-12 h-12" />
                </div>
                <h2 className="text-3xl font-black italic tracking-tighter">LAUNDRY<span className="text-blue-500">KU</span></h2>
                <p className="text-slate-400 text-sm font-medium">Bebaskan diri Anda dari urusan cucian yang menumpuk. Gabung sekarang!</p>
              </div>
              <div className="hidden md:block">
                <div className="p-4 bg-slate-800 rounded-xl flex items-center space-x-3 text-left">
                  <div className="w-10 h-10 rounded-full bg-slate-700 overflow-hidden">
                     <img src="https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=1374&auto=format&fit=crop" alt="avatar" />
                  </div>
                  <div>
                    <p className="text-xs font-bold">Andi Wijaya</p>
                    <p className="text-[10px] text-slate-500 italic">"Layanan laundry terbaik yang pernah saya coba!"</p>
                  </div>
                </div>
              </div>
            </div>

            <div className="md:col-span-3 p-8">
              <div className="mb-8 space-y-2">
                <CardTitle className="text-2xl font-black text-slate-900 tracking-tight">Daftar Akun Baru</CardTitle>
                <CardDescription className="text-slate-500">Lengkapi data diri Anda untuk memulai.</CardDescription>
              </div>

              <Form {...form}>
                <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <FormField
                      control={form.control}
                      name="nama"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel className="text-[10px] font-black uppercase tracking-widest text-slate-400">Nama Lengkap</FormLabel>
                          <div className="relative">
                            <FormControl>
                              <Input placeholder="Budi Santoso" {...field} className="bg-slate-50 border-slate-100 pl-10" />
                            </FormControl>
                            <User className="absolute left-3 top-2.5 w-4 h-4 text-slate-400" />
                          </div>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                    <FormField
                      control={form.control}
                      name="email"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel className="text-[10px] font-black uppercase tracking-widest text-slate-400">Email</FormLabel>
                          <div className="relative">
                            <FormControl>
                              <Input type="email" placeholder="budi@example.com" {...field} className="bg-slate-50 border-slate-100 pl-10" />
                            </FormControl>
                            <Mail className="absolute left-3 top-2.5 w-4 h-4 text-slate-400" />
                          </div>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <FormField
                      control={form.control}
                      name="no_telp"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel className="text-[10px] font-black uppercase tracking-widest text-slate-400">No. Telepon</FormLabel>
                          <div className="relative">
                            <FormControl>
                              <Input placeholder="0812XXXXXXXX" {...field} className="bg-slate-50 border-slate-100 pl-10" />
                            </FormControl>
                            <Phone className="absolute left-3 top-2.5 w-4 h-4 text-slate-400" />
                          </div>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                    <FormField
                      control={form.control}
                      name="username"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel className="text-[10px] font-black uppercase tracking-widest text-slate-400">Username</FormLabel>
                          <div className="relative">
                            <FormControl>
                              <Input placeholder="budi_s" {...field} className="bg-slate-50 border-slate-100 pl-10" />
                            </FormControl>
                            <UserPlus className="absolute left-3 top-2.5 w-4 h-4 text-slate-400" />
                          </div>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                  </div>

                  <FormField
                    control={form.control}
                    name="alamat"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel className="text-[10px] font-black uppercase tracking-widest text-slate-400">Alamat Lengkap</FormLabel>
                        <div className="relative">
                          <FormControl>
                            <Input placeholder="Jl. Merdeka No. 123, Jakarta" {...field} className="bg-slate-50 border-slate-100 pl-10" />
                          </FormControl>
                          <MapPin className="absolute left-3 top-2.5 w-4 h-4 text-slate-400" />
                        </div>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="password"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel className="text-[10px] font-black uppercase tracking-widest text-slate-400">Password</FormLabel>
                        <div className="relative">
                          <FormControl>
                            <Input type="password" placeholder="••••••••" {...field} className="bg-slate-50 border-slate-100 pl-10" />
                          </FormControl>
                          <Lock className="absolute left-3 top-2.5 w-4 h-4 text-slate-400" />
                        </div>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <Button 
                    type="submit" 
                    className="w-full h-12 bg-blue-600 hover:bg-blue-700 text-white font-bold transition-all shadow-lg shadow-blue-100 mt-4" 
                    disabled={isLoading}
                  >
                    {isLoading ? (
                      <Loader2 className="w-5 h-5 animate-spin" />
                    ) : (
                      "Daftar Sekarang"
                    )}
                  </Button>
                </form>
              </Form>

              <div className="mt-8 pt-6 border-t border-slate-100 text-center">
                <p className="text-sm text-slate-500 font-medium">
                  Sudah punya akun?{" "}
                  <Link to="/login" className="text-blue-600 font-bold hover:underline">
                    Login di sini
                  </Link>
                </p>
              </div>
            </div>
          </div>
        </Card>
      </motion.div>
    </div>
  );
}
