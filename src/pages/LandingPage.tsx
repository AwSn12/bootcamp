import { Button } from "@/components/ui/button";
import { Link } from "react-router-dom";
import { motion } from "framer-motion";
import { 
  CheckCircle2, 
  Clock, 
  MapPin, 
  ShieldCheck, 
  Truck, 
  WashingMachine, 
  ChevronRight,
  TrendingUp,
  Star
} from "lucide-react";

const fadeIn = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.6 }
};

const stagger = {
  animate: {
    transition: {
      staggerChildren: 0.1
    }
  }
};

export default function LandingPage() {
  const services = [
    { name: "Laundry Kiloan", price: "Rp 6.000/kg", icon: WashingMachine, color: "bg-blue-100 text-blue-600" },
    { name: "Cuci Satuan", price: "Mulai Rp 15.000", icon: CheckCircle2, color: "bg-indigo-100 text-indigo-600" },
    { name: "Laundry Sepatu", price: "Mulai Rp 25.000", icon: Star, color: "bg-orange-100 text-orange-600" },
    { name: "Laundry Karpet", price: "Rp 15.000/m", icon: MapPin, color: "bg-emerald-100 text-emerald-600" },
  ];

  const features = [
    { title: "Pickup & Delivery", desc: "Kurir jemput dan antar jemput langsung ke depan pintu rumah Anda.", icon: Truck },
    { title: "Selesai 1 Hari", desc: "Nikmati layanan Express yang siap pakai hanya dalam 24 jam.", icon: Clock },
    { title: "Higienis & Wangi", desc: "Menggunakan deterjen premium dan parfum yang tahan lama.", icon: ShieldCheck },
    { title: "Tracking Real-time", desc: "Pantau status cucian Anda lewat aplikasi secara otomatis.", icon: TrendingUp },
  ];

  return (
    <div className="space-y-24">
      {/* Hero Section */}
      <section className="relative overflow-hidden pt-12 pb-24 md:pt-24 md:pb-32 bg-white">
        <div className="absolute top-0 right-0 -translate-y-1/4 translate-x-1/4 w-[600px] h-[600px] bg-blue-50 rounded-full blur-3xl opacity-50" />
        <div className="absolute bottom-0 left-0 translate-y-1/4 -translate-x-1/4 w-[400px] h-[400px] bg-indigo-50 rounded-full blur-3xl opacity-30" />
        
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 text-center">
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="flex flex-col items-center space-y-8"
          >
            <div className="inline-flex items-center space-x-2 px-4 py-2 rounded-full bg-blue-50 text-blue-700 text-xs font-bold uppercase tracking-widest border border-blue-100">
              <TrendingUp className="w-3 h-3" />
              <span>Modern Laundry Experience</span>
            </div>
            
            <h1 className="text-6xl md:text-8xl font-extrabold text-[#0F172A] tracking-tighter leading-[1] max-w-5xl">
              Cucian <span className="text-blue-600">Bersih</span>, Hidup Lebih <span className="text-blue-600">Ringan.</span>
            </h1>
            
            <p className="text-xl md:text-2xl text-slate-500 max-w-2xl mx-auto font-medium leading-relaxed">
              Solusi laundry satu atap untuk keluarga modern. Urusan mencuci, biarkan kami yang menangani.
            </p>

            <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-6">
              <Link to="/register">
                <Button className="h-16 px-12 text-lg font-bold bg-blue-600 hover:bg-blue-700 text-white rounded-2xl shadow-xl shadow-blue-100 transition-all hover:scale-105 active:scale-95">
                  Mulai Sekarang
                  <ChevronRight className="ml-2 w-5 h-5" />
                </Button>
              </Link>
              <Button variant="outline" className="h-16 px-12 text-lg font-bold border-slate-200 text-slate-700 rounded-2xl hover:bg-slate-50 transition-all">
                Cek Harga
              </Button>
            </div>
          </motion.div>

          <motion.div 
            className="mt-20 relative max-w-4xl mx-auto"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 1, delay: 0.2 }}
          >
            <div className="relative z-10 rounded-3xl overflow-hidden shadow-2xl border-8 border-white">
              <img 
                src="https://images.unsplash.com/photo-1545173168-9f1947e8017e?q=80&w=1470&auto=format&fit=crop" 
                alt="Modern Laundry" 
                className="w-full h-auto object-cover"
              />
              <div className="absolute inset-0 bg-blue-600/5 mix-blend-multiply" />
            </div>
            {/* Decorative elements */}
            <div className="absolute -top-12 -right-12 w-48 h-48 bg-blue-400 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-pulse" />
            <div className="absolute -bottom-12 -left-12 w-48 h-48 bg-indigo-400 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-pulse delay-700" />
          </motion.div>
        </div>
      </section>

      {/* Services Section */}
      <section id="services" className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center space-y-4 mb-16">
          <h2 className="text-sm font-bold text-blue-600 uppercase tracking-widest">Our Specialties</h2>
          <h3 className="text-3xl md:text-5xl font-extrabold text-slate-900">Layanan Unggulan Kami</h3>
          <p className="text-slate-500 max-w-2xl mx-auto">Kami menyediakan berbagai macam layanan laundry dengan standar kualitas hotel bintang lima.</p>
        </div>

        <motion.div 
          className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6"
          variants={stagger}
          initial="initial"
          whileInView="animate"
          viewport={{ once: true }}
        >
          {services.map((service, index) => (
            <motion.div 
              key={index}
              variants={fadeIn}
              className="p-8 bg-white rounded-3xl border border-slate-100 hover:border-blue-200 hover:shadow-xl hover:shadow-blue-50/50 transition-all group flex flex-col items-center text-center space-y-4"
            >
              <div className={`p-4 rounded-2xl ${service.color} group-hover:scale-110 transition-transform`}>
                <service.icon className="w-8 h-8" />
              </div>
              <h4 className="text-lg font-bold text-slate-900">{service.name}</h4>
              <p className="text-blue-600 font-extrabold">{service.price}</p>
              <p className="text-sm text-slate-500">Pengerjaan cepat dan hasil maksimal dijamin bersih.</p>
              <Button variant="ghost" size="sm" className="text-blue-600 hover:text-blue-700 font-bold">
                Detail Layanan <ChevronRight className="ml-1 w-4 h-4" />
              </Button>
            </motion.div>
          ))}
        </motion.div>
      </section>

      {/* Features Section */}
      <section className="bg-slate-900 py-32 overflow-hidden">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-20 items-center">
            <div className="space-y-12">
              <div className="space-y-4">
                <h2 className="text-blue-500 font-bold uppercase tracking-widest text-sm">Kenapa LaundryKu?</h2>
                <h3 className="text-4xl md:text-5xl font-extrabold text-white leading-tight">Solusi Modern<br />Cucian Masa Kini</h3>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-8">
                {features.map((feature, index) => (
                  <div key={index} className="space-y-4 group">
                    <div className="w-12 h-12 bg-slate-800 rounded-xl flex items-center justify-center group-hover:bg-blue-600 transition-colors">
                      <feature.icon className="w-6 h-6 text-blue-500 group-hover:text-white" />
                    </div>
                    <h4 className="text-xl font-bold text-white">{feature.title}</h4>
                    <p className="text-slate-400 text-sm leading-relaxed">{feature.desc}</p>
                  </div>
                ))}
              </div>
            </div>
            <div className="relative">
              <div className="aspect-square bg-blue-600/20 absolute -inset-4 rounded-full blur-3xl opacity-50" />
              <div className="relative z-10 border-8 border-slate-800 rounded-2xl overflow-hidden shadow-2xl">
                <img 
                  src="https://images.unsplash.com/photo-1517677208171-0bc6725a3e60?q=80&w=1470&auto=format&fit=crop" 
                  alt="App interface" 
                  className="w-full h-auto"
                />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-32">
        <div className="bg-blue-600 rounded-[40px] p-12 md:p-24 text-center relative overflow-hidden">
          <div className="absolute top-0 left-0 w-full h-full opacity-10 pointer-events-none">
             <div className="grid grid-cols-10 h-full w-full">
                {Array.from({length: 100}).map((_, i) => (
                  <div key={i} className="border border-white/20 aspect-square" />
                ))}
             </div>
          </div>
          <motion.div 
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            className="space-y-8 relative z-10"
          >
            <h2 className="text-4xl md:text-6xl font-black text-white px-4">Siap Mencuci Lebih Hemat & Nyaman?</h2>
            <p className="text-blue-50 text-lg max-w-2xl mx-auto opacity-80">
              Dapatkan diskon 20% untuk order pertama Anda dengan kode promo <span className="font-mono bg-white/20 px-2 py-0.5 rounded text-white font-bold select-all">WELCOME20</span>. Bergabunglah dengan ribuan keluarga yang sudah beralih ke LaundryKu.
            </p>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              <Link to="/register">
                <Button size="lg" variant="secondary" className="h-14 px-10 text-lg font-bold group">
                  Daftar Sekarang
                  <ChevronRight className="ml-2 group-hover:translate-x-1 transition-all" />
                </Button>
              </Link>
              <Link to="/login">
                <Button variant="ghost" size="lg" className="h-14 px-10 text-lg text-white hover:bg-white/10 font-bold border border-white/20">
                  Masuk ke Akun
                </Button>
              </Link>
            </div>
          </motion.div>
        </div>
      </section>
    </div>
  );
}
