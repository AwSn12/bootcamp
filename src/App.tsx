import { BrowserRouter as Router, Routes, Route, Link, useNavigate } from "react-router-dom";
import { useState, useEffect } from "react";
import { Toaster } from "@/components/ui/sonner";
import LandingPage from "./pages/LandingPage";
import LoginPage from "./pages/LoginPage";
import RegisterPage from "./pages/RegisterPage";
import UserDashboard from "./pages/UserDashboard";
import AdminDashboard from "./pages/AdminDashboard";
import KurirDashboard from "./pages/KurirDashboard";
import OrderPage from "./pages/OrderPage";
import TrackingPage from "./pages/TrackingPage";
import { Button } from "./components/ui/button";
import { WashingMachine, User as UserIcon, LogOut, Menu, X } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";

function Navbar() {
  const [isOpen, setIsOpen] = useState(false);
  const token = localStorage.getItem("token");
  const user = JSON.parse(localStorage.getItem("user") || "null");
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem("token");
    localStorage.removeItem("user");
    navigate("/login");
  };

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-md border-b border-slate-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <Link to="/" className="flex items-center space-x-2">
            <div className="p-2 bg-blue-600 rounded-lg shadow-sm shadow-blue-200">
              <WashingMachine className="w-6 h-6 text-white" />
            </div>
            <span className="text-xl font-extrabold tracking-tight text-[#0F172A]">LAUNDRY<span className="text-blue-600">KU</span></span>
          </Link>

          {/* Desktop Menu */}
          <div className="hidden md:flex items-center space-x-8">
            <Link to="/" className="text-sm font-semibold text-slate-500 hover:text-blue-600 transition-colors">Home</Link>
            <Link to="/#services" className="text-sm font-semibold text-slate-500 hover:text-blue-600 transition-colors">Layanan</Link>
            {token ? (
              <>
                <Link 
                  to={user?.role === "ADMIN" ? "/admin" : user?.role === "KURIR" ? "/kurir" : "/dashboard"} 
                  className="text-sm font-semibold text-slate-500 hover:text-blue-600 transition-colors"
                >
                  Dashboard
                </Link>
                <div className="flex items-center space-x-4 ml-4 pl-4 border-l border-slate-200">
                  <div className="flex flex-col items-end mr-2">
                    <span className="text-xs font-bold text-slate-900 leading-none">{user?.nama}</span>
                    <span className="text-[10px] font-bold text-blue-600 tracking-wider uppercase">{user?.role}</span>
                  </div>
                  <div className="w-9 h-9 rounded-full bg-blue-600 flex items-center justify-center shadow-md shadow-blue-100">
                    <span className="text-sm font-bold text-white uppercase">{user?.nama?.substring(0,2)}</span>
                  </div>
                  <Button variant="ghost" size="icon" onClick={handleLogout} className="text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-xl">
                    <LogOut className="w-5 h-5" />
                  </Button>
                </div>
              </>
            ) : (
              <div className="flex items-center space-x-4">
                <Link to="/login">
                  <Button variant="ghost" className="text-slate-600">Login</Button>
                </Link>
                <Link to="/register">
                  <Button className="bg-blue-600 hover:bg-blue-700 text-white">Join Now</Button>
                </Link>
              </div>
            )}
          </div>

          {/* Mobile Menu Button */}
          <div className="md:hidden flex items-center">
            <button onClick={() => setIsOpen(!isOpen)} className="text-slate-600">
              {isOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Menu */}
      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            className="md:hidden bg-white border-b border-slate-100 overflow-hidden"
          >
            <div className="px-4 pt-2 pb-6 space-y-4">
              <Link to="/" onClick={() => setIsOpen(false)} className="block text-sm font-medium text-slate-600">Home</Link>
              <Link to="/#services" onClick={() => setIsOpen(false)} className="block text-sm font-medium text-slate-600">Layanan</Link>
              {token ? (
                <>
                  <Link to="/dashboard" onClick={() => setIsOpen(false)} className="block text-sm font-medium text-slate-600">Dashboard</Link>
                  <Button onClick={handleLogout} variant="outline" className="w-full justify-start text-red-500 border-red-200">
                    <LogOut className="mr-2 w-4 h-4" /> Logout
                  </Button>
                </>
              ) : (
                <div className="grid grid-cols-2 gap-4">
                  <Link to="/login" onClick={() => setIsOpen(false)}>
                    <Button variant="outline" className="w-full">Login</Button>
                  </Link>
                  <Link to="/register" onClick={() => setIsOpen(false)}>
                    <Button className="w-full bg-blue-600">Join</Button>
                  </Link>
                </div>
              )}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </nav>
  );
}

export default function App() {
  return (
    <Router>
      <div className="min-h-screen bg-slate-50 font-sans selection:bg-blue-100 selection:text-blue-900">
        <Navbar />
        <main className="pt-16 pb-12">
          <Routes>
            <Route path="/" element={<LandingPage />} />
            <Route path="/login" element={<LoginPage />} />
            <Route path="/register" element={<RegisterPage />} />
            <Route path="/dashboard" element={<UserDashboard />} />
            <Route path="/admin" element={<AdminDashboard />} />
            <Route path="/kurir" element={<KurirDashboard />} />
            <Route path="/order" element={<OrderPage />} />
            <Route path="/tracking/:kode" element={<TrackingPage />} />
          </Routes>
        </main>
        <footer className="bg-slate-900 text-slate-400 py-12 px-4 shadow-[0_-1px_0_0_rgba(255,255,255,0.05)]">
          <div className="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="space-y-4">
              <div className="flex items-center space-x-2">
                <WashingMachine className="w-6 h-6 text-blue-500" />
                <span className="text-xl font-bold tracking-tight text-white italic">LAUNDRY<span className="text-blue-500">KU</span></span>
              </div>
              <p className="text-sm leading-relaxed">Penyedia layanan laundry online profesional nomor satu di Indonesia. Kami menjamin kebersihan dan kerapihan pakaian Anda.</p>
            </div>
            <div>
              <h4 className="text-white font-semibold mb-4">Layanan</h4>
              <ul className="space-y-2 text-sm">
                <li>Laundry Kiloan</li>
                <li>Laundry Satuan</li>
                <li>Laundry Sepatu</li>
                <li>Laundry Karpet</li>
              </ul>
            </div>
            <div>
              <h4 className="text-white font-semibold mb-4">Perusahaan</h4>
              <ul className="space-y-2 text-sm">
                <li>Tentang Kami</li>
                <li>Kontak</li>
                <li>Karir</li>
                <li>Promo</li>
              </ul>
            </div>
            <div>
              <h4 className="text-white font-semibold mb-4">Bantuan</h4>
              <ul className="space-y-2 text-sm">
                <li>FAQ</li>
                <li>Syarat & Ketentuan</li>
                <li>Kebijakan Privasi</li>
                <li>Hubungi Admin</li>
              </ul>
            </div>
          </div>
          <div className="max-w-7xl mx-auto mt-12 pt-8 border-t border-slate-800 text-center text-xs">
            <p>© 2026 LAUNDRYKU. All rights reserved. Dibuat dengan ❤️ untuk kenyamanan Anda.</p>
          </div>
        </footer>
        <Toaster position="top-center" richColors />
      </div>
    </Router>
  );
}
