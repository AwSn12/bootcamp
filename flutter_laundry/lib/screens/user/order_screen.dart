import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/order_provider.dart';
import '../../data/models/layanan_model.dart';
import '../../data/services/api_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupCtrl = TextEditingController();
  final _deliveryCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  final _beratCtrl = TextEditingController();
  final _promoCtrl = TextEditingController();

  LayananModel? _selectedLayanan;
  DateTime? _selectedDate;
  String _selectedJam = '08:00';
  String _metodePembayaran = 'BAYAR DI TEMPAT';
  bool _isGettingGps = false;
  bool _isSubmitting = false; // ← guard dobel submit
  bool _isCheckingPromo = false;
  double _diskonPromo = 0;
  String? _appliedPromo;

  final List<String> _jamOptions = ['08:00', '09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00', '17:00'];


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchLayanan();
    });
  }

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _deliveryCtrl.dispose();
    _catatanCtrl.dispose();
    _beratCtrl.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  Future<void> _getGpsAddress() async {
    setState(() => _isGettingGps = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('GPS tidak aktif. Nyalakan lokasi di pengaturan.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi diblokir permanen.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.postalCode}';
        
        setState(() {
          _pickupCtrl.text = address;
          // Opsional: otomatis copy ke delivery
          if (_deliveryCtrl.text.isEmpty) {
            _deliveryCtrl.text = address;
          }
        });
        
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('✅ Alamat berhasil diisi dari GPS'), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Gagal mengambil lokasi: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingGps = false);
    }
  }

  Future<void> _checkPromo() async {
    final kode = _promoCtrl.text.trim();
    if (kode.isEmpty) return;

    setState(() => _isCheckingPromo = true);
    try {
      final res = await ApiService.checkPromo(kode);
      setState(() {
        _diskonPromo = (res['diskon'] as num).toDouble();
        _appliedPromo = kode;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 Promo berhasil diterapkan!'), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      setState(() {
        _diskonPromo = 0;
        _appliedPromo = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kode promo tidak valid atau kadaluarsa'), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) setState(() => _isCheckingPromo = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return; // ← blok jika sedang proses
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLayanan == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih layanan terlebih dahulu'), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating));
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih tanggal pickup'), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating));
      return;
    }

    // Langsung disable tombol sebelum request
    setState(() => _isSubmitting = true);

    final kodeOrder = await context.read<OrderProvider>().createOrder(
      idLayanan: _selectedLayanan!.idLayanan,
      beratKg: double.parse(_beratCtrl.text),
      alamatPickup: _pickupCtrl.text.trim(),
      alamatDelivery: _deliveryCtrl.text.trim(),
      tanggalPickup: _selectedDate!.toIso8601String(),
      jamPickup: _selectedJam,
      catatan: _catatanCtrl.text.trim().isEmpty ? null : _catatanCtrl.text.trim(),
      metodePembayaran: _metodePembayaran,
      kodePromo: _appliedPromo,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (kodeOrder != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibuat!'), backgroundColor: AppTheme.success));
      if (_metodePembayaran != 'BAYAR DI TEMPAT') {
        context.go('/payment/$kodeOrder?method=${Uri.encodeComponent(_metodePembayaran)}');
      } else {
        context.go('/dashboard');
      }
    } else {
      setState(() => _isSubmitting = false);
      final err = context.read<OrderProvider>().error ?? 'Gagal membuat pesanan';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppTheme.textDark), onPressed: () => context.pop()),
        title: Text('Buat Pesanan Baru', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.textDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step 1: Pilih Layanan
              _sectionHeader('1', 'PILIH LAYANAN'),
              const SizedBox(height: 12),
              if (orders.layanan.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.primary)))
              else
                ...orders.layanan.map((l) => _LayananCard(
                  layanan: l,
                  isSelected: _selectedLayanan?.idLayanan == l.idLayanan,
                  onTap: () => setState(() => _selectedLayanan = l),
                )),

              const SizedBox(height: 24),

              // Step 2: Berat Cucian
              _sectionHeader('2', 'ESTIMASI BERAT CUCIAN'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _beratCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'BERAT (Kg)', hintText: 'Contoh: 3.5', prefixIcon: Icon(Icons.scale, color: AppTheme.primary)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Berat cucian wajib diisi';
                  final berat = double.tryParse(v);
                  if (berat == null || berat <= 0) return 'Berat harus berupa angka lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Step 3: Alamat
              _sectionHeader('3', 'INFORMASI PICKUP & DELIVERY'),
              const SizedBox(height: 12),
              // Tombol GPS
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isGettingGps ? null : _getGpsAddress,
                  icon: _isGettingGps
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.gps_fixed, size: 18),
                  label: Text(_isGettingGps ? 'Mengambil GPS...' : 'Gunakan Lokasi Saat Ini', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pickupCtrl,
                decoration: const InputDecoration(labelText: 'ALAMAT PICKUP', hintText: 'Jl. Merdeka No. 1...', prefixIcon: Icon(Icons.location_on, color: Colors.red)),
                validator: (v) => (v?.isEmpty ?? true) ? 'Alamat pickup wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deliveryCtrl,
                decoration: const InputDecoration(labelText: 'ALAMAT DELIVERY', hintText: 'Sama dengan pickup atau beda?', prefixIcon: Icon(Icons.local_shipping_outlined, color: AppTheme.primary)),
                validator: (v) => (v?.isEmpty ?? true) ? 'Alamat delivery wajib diisi' : null,
              ),

              const SizedBox(height: 24),

              // Step 4: Jadwal
              _sectionHeader('4', 'JADWAL PICKUP'),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedDate != null ? AppTheme.primary : AppTheme.border, width: _selectedDate != null ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: _selectedDate != null ? AppTheme.primary : AppTheme.textLight, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDate != null ? DateFormat('EEEE, dd MMMM yyyy', 'id').format(_selectedDate!) : 'Pilih tanggal pickup',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: _selectedDate != null ? FontWeight.w700 : FontWeight.w400,
                            color: _selectedDate != null ? AppTheme.textDark : AppTheme.textLight,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppTheme.textLight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Jam Picker
              Text('JAM PICKUP', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textMid, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _jamOptions.map((jam) {
                  final selected = jam == _selectedJam;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedJam = jam),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: selected ? AppTheme.primary : AppTheme.border),
                      ),
                      child: Text(jam, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppTheme.textMid)),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Step 4: Catatan & Pembayaran
              _sectionHeader('4', 'CATATAN & PEMBAYARAN'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _catatanCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'CATATAN (OPSIONAL)', hintText: 'Mis: ada noda merah di kemeja, jangan dicampur...'),
              ),
              const SizedBox(height: 12),
              // Promo Section
              Text('KODE PROMO / KUPON', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textMid, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _promoCtrl,
                      decoration: const InputDecoration(hintText: 'Masukkan kode promo (mis. RAV10)', prefixIcon: Icon(Icons.local_offer_outlined, color: AppTheme.primary)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isCheckingPromo ? null : _checkPromo,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isCheckingPromo
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Terapkan', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              if (_appliedPromo != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text('✅ Promo $_appliedPromo diterapkan! (Diskon Rp ${NumberFormat('#,###').format(_diskonPromo)})', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.success, fontWeight: FontWeight.w700)),
                ),
              const SizedBox(height: 16),

              // Payment
              ...['BAYAR DI TEMPAT', 'TRANSFER BANK', 'DOMPET DIGITAL'].map((method) {
                final selected = method == _metodePembayaran;
                return GestureDetector(
                  onTap: () => setState(() => _metodePembayaran = method),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primaryBg : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? AppTheme.primary : AppTheme.border, width: selected ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected ? AppTheme.primary : AppTheme.textLight, size: 20),
                        const SizedBox(width: 12),
                        Text(method, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: selected ? AppTheme.primary : AppTheme.textDark)),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 32),

              // Summary
              if (_selectedLayanan != null)
                Builder(
                  builder: (context) {
                    final berat = double.tryParse(_beratCtrl.text) ?? 0.0;
                    final subtotal = _selectedLayanan!.hargaPerKg * berat;
                    final total = (subtotal - _diskonPromo) < 0 ? 0.0 : (subtotal - _diskonPromo);
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RINGKASAN PESANAN', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedLayanan!.namaLayanan, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                              Text('Rp ${NumberFormat('#,###').format(_selectedLayanan!.hargaPerKg)}/kg', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.primary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal ($berat Kg)', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textMid, fontSize: 13)),
                              Text('Rp ${NumberFormat('#,###').format(subtotal)}', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.textDark, fontSize: 13)),
                            ],
                          ),
                          if (_diskonPromo > 0) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Diskon Promo', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.success, fontSize: 13)),
                                Text('- Rp ${NumberFormat('#,###').format(_diskonPromo)}', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.success, fontSize: 13)),
                              ],
                            ),
                          ],
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TOTAL BAYAR', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                              Text('Rp ${NumberFormat('#,###').format(total)}', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Estimasi: ${_selectedLayanan!.estimasiHari} hari', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
                        ],
                      ),
                    );
                  }
                ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check, size: 20),
                            const SizedBox(width: 8),
                            Text('Konfirmasi & Pesan', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String number, String title) {
    return Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
          child: Center(child: Text(number, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white))),
        ),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.5)),
      ],
    );
  }
}

class _LayananCard extends StatelessWidget {
  final LayananModel layanan;
  final bool isSelected;
  final VoidCallback onTap;

  const _LayananCard({required this.layanan, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.bgLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.local_laundry_service, color: isSelected ? Colors.white : AppTheme.textLight, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(layanan.namaLayanan, style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.textDark, fontSize: 14)),
                  Text(layanan.deskripsi, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMid), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Rp ${NumberFormat('#,###').format(layanan.hargaPerKg)}/kg', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 13)),
                Text('${layanan.estimasiHari} hari', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMid)),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
