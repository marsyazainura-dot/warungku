import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _sisa = 3;
  Timer? _timer;
  bool _selesai = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _sisa = _sisa > 0 ? _sisa - 1 : 0);
      if (_sisa <= 0) _masuk();
    });
  }

  void _masuk() {
    if (_selesai) return;
    _selesai = true;
    _timer?.cancel();
    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.sand,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, size: 10, color: AppColors.maroon),
                      const SizedBox(width: 8),
                      Text(
                        'Otomatis beralih ke login dalam $_sisa detik',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.maroon),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: 130,
                  height: 130,
                  decoration: cardDeco(),
                  child: const Icon(Icons.storefront,
                      size: 72, color: AppColors.maroon),
                ),
                const SizedBox(height: 24),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                    children: [
                      TextSpan(text: 'Warung', style: TextStyle(color: AppColors.text)),
                      TextSpan(text: 'Ku', style: TextStyle(color: AppColors.maroon)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Inventaris Stok Warung UMKM',
                    style: TextStyle(fontSize: 16, color: AppColors.muted)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.sand,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('V1.0.0 UMKM EDITION',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _Fitur(icon: Icons.bolt, label: 'Cepat'),
                    SizedBox(width: 10),
                    _Fitur(icon: Icons.inventory_2, label: 'Akurat'),
                    SizedBox(width: 10),
                    _Fitur(icon: Icons.notifications_active, label: 'Siaga'),
                  ],
                ),
                const SizedBox(height: 28),
                TextButton.icon(
                  onPressed: _masuk,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Langsung Masuk',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: TextButton.styleFrom(foregroundColor: AppColors.maroon),
                ),
                const SizedBox(height: 8),
                const Text('Sahabat Setia Kelontong & Warung Indonesia',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Fitur extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Fitur({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: cardDeco(),
      child: Column(
        children: [
          Icon(icon, color: AppColors.maroon),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
