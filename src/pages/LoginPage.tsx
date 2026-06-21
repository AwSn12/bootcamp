import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Link, useNavigate } from "react-router-dom";
import { WashingMachine, ArrowRight, Loader2, Mail, Lock } from "lucide-react";
import api from "@/lib/api";
import { toast } from "sonner";
import { motion } from "framer-motion";

const formSchema = z.object({
  identifier: z.string().min(3, { message: "Email atau username minimal 3 karakter" }),
  password: z.string().min(6, { message: "Password minimal 6 karakter" }),
});

export default function LoginPage() {
  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      identifier: "",
      password: "",
    },
  });

  async function onSubmit(values: z.infer<typeof formSchema>) {
    setIsLoading(true);
    try {
      const response = await api.post("/auth/login", values);
      localStorage.setItem("token", response.data.token);
      localStorage.setItem("user", JSON.stringify(response.data.user));
      
      toast.success(`Selamat datang kembali, ${response.data.user.nama}!`);
      
      if (response.data.user.role === "ADMIN") {
        navigate("/admin");
      } else if (response.data.user.role === "KURIR") {
        navigate("/kurir");
      } else {
        navigate("/dashboard");
      }
    } catch (error: any) {
      toast.error(error.response?.data?.error || "Terjadi kesalahan saat login");
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <div className="flex items-center justify-center min-h-[calc(100vh-120px)] p-4 bg-slate-50 relative overflow-hidden">
      {/* Decorative background atoms */}
      <div className="absolute top-0 right-0 -translate-y-1/2 translate-x-1/2 w-96 h-96 bg-blue-100 rounded-full blur-3xl opacity-30" />
      <div className="absolute bottom-0 left-0 translate-y-1/2 -translate-x-1/2 w-96 h-96 bg-blue-200 rounded-full blur-3xl opacity-20" />

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <Card className="w-full max-w-md border-slate-100 shadow-2xl relative z-10 bg-white/90 backdrop-blur-sm overflow-hidden">
          <div className="h-2 bg-blue-600" />
          <CardHeader className="space-y-4 pt-10">
            <div className="flex justify-center">
              <div className="p-3 bg-blue-600 rounded-2xl shadow-lg shadow-blue-200">
                <WashingMachine className="w-10 h-10 text-white" />
              </div>
            </div>
            <div className="text-center space-y-2">
              <CardTitle className="text-3xl font-black tracking-tight text-slate-900 leading-none">Login Akun</CardTitle>
              <CardDescription className="text-slate-500 font-medium">Masuk untuk mengelola laundry Anda.</CardDescription>
            </div>
          </CardHeader>
          <CardContent>
            <Form {...form}>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-5">
                <FormField
                  control={form.control}
                  name="identifier"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="text-slate-700 font-bold uppercase text-[10px] tracking-widest">Email atau Username</FormLabel>
                      <div className="relative">
                        <FormControl>
                          <Input 
                            placeholder="admin@laundryku.com" 
                            {...field} 
                            className="bg-slate-50 border-slate-100 h-12 pl-10 focus:ring-blue-500 font-medium"
                          />
                        </FormControl>
                        <Mail className="absolute left-3 top-3.5 w-5 h-5 text-slate-400" />
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
                      <FormLabel className="text-slate-700 font-bold uppercase text-[10px] tracking-widest">Password</FormLabel>
                      <div className="relative">
                        <FormControl>
                          <Input 
                            type="password" 
                            placeholder="••••••••" 
                            {...field} 
                            className="bg-slate-50 border-slate-100 h-12 pl-10 focus:ring-blue-500 font-medium"
                          />
                        </FormControl>
                        <Lock className="absolute left-3 top-3.5 w-5 h-5 text-slate-400" />
                      </div>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <Button 
                  type="submit" 
                  className="w-full h-12 bg-blue-600 hover:bg-blue-700 text-white font-bold transition-all shadow-lg shadow-blue-100" 
                  disabled={isLoading}
                >
                  {isLoading ? (
                    <Loader2 className="w-5 h-5 animate-spin" />
                  ) : (
                    <span className="flex items-center">
                      Masuk <ArrowRight className="ml-2 w-4 h-4" />
                    </span>
                  )}
                </Button>
              </form>
            </Form>
          </CardContent>
          <CardFooter className="flex flex-col space-y-4 pb-10">
            <div className="relative w-full">
              <div className="absolute inset-0 flex items-center">
                <span className="w-full border-t border-slate-100" />
              </div>
              <div className="relative flex justify-center text-xs uppercase">
                <span className="bg-white px-4 text-slate-400 font-bold tracking-widest">Belum punya akun?</span>
              </div>
            </div>
            <Link to="/register" className="w-full">
              <Button variant="outline" className="w-full h-12 border-slate-200 text-slate-600 font-bold hover:bg-slate-50">
                Buat Akun Sekarang
              </Button>
            </Link>
          </CardFooter>
        </Card>
      </motion.div>
    </div>
  );
}
