import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userC = TextEditingController();
  final _passC = TextEditingController();
  bool _sembunyi = true;
  bool _ingat = false;
  bool _loading = false;

  @override
  void dispose() {
    _userC.dispose();
    _passC.dispose();
    super.dispose();
  }

  void _isiDemo() {
    setState(() {
      _userC.text = 'admin';
      _passC.text = 'admin123';
    });
    _formKey.currentState?.validate();
  }

  Future<void> _masuk() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      final ok = context.read<AppState>().login(_userC.text, _passC.text);
      if (ok) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        showSnack(context, 'Username atau password salah', error: true);
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Terjadi kesalahan: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _lupaSandi() {
    if (context.read<AppState>().offline) {
      showSnack(context, 'Tidak ada koneksi internet. Coba lagi nanti.',
          error: true);
    } else {
      showSnack(context, 'Tautan reset sandi dikirim (simulasi)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final offline = context.watch<AppState>().offline;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // status koneksi
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: offline ? AppColors.redSoft : AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(offline ? Icons.cloud_off : Icons.circle,
                            size: offline ? 16 : 10,
                            color: offline ? AppColors.red : AppColors.green),
                        const SizedBox(width: 8),
                        Text(
                          offline
                              ? 'Status: Tidak Ada Internet (Offline)'
                              : 'Status: Terhubung (Online)',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: offline ? AppColors.red : AppColors.green),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // sambutan
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: cardDeco(),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.sand,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.storefront,
                              size: 44, color: AppColors.maroon),
                        ),
                        const SizedBox(height: 14),
                        const Text('Selamat Datang di WarungKu 👋',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        const Text(
                          'Kelola stok barang dagangan warung Anda dengan mudah, cepat, dan akurat.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // akun demo
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: cardDeco(color: const Color(0xFFFBEEE3)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.shield_outlined,
                                size: 18, color: AppColors.maroon),
                            SizedBox(width: 6),
                            Text('Akses Cepat Pengujian',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.maroon)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text('Akun demo: admin / admin123',
                            style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: _isiDemo,
                            icon: const Icon(Icons.bolt, size: 18),
                            label: const Text('Gunakan Akun Demo'),
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.sand,
                              foregroundColor: AppColors.maroon,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // form
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: cardDeco(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nama Pengguna (Username)',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _userC,
                            textInputAction: TextInputAction.next,
                            decoration: inputDeco(
                                hint: 'Contoh: admin', icon: Icons.person_outline),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Username tidak boleh kosong'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Kata Sandi (Password)',
                                  style: TextStyle(fontWeight: FontWeight.w700)),
                              GestureDetector(
                                onTap: _lupaSandi,
                                child: const Text('Lupa Sandi?',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.maroon)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passC,
                            obscureText: _sembunyi,
                            onFieldSubmitted: (_) => _masuk(),
                            decoration: inputDeco(
                              hint: 'Masukkan password',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(_sembunyi
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () =>
                                    setState(() => _sembunyi = !_sembunyi),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (v.length < 6) return 'Password minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Checkbox(
                                value: _ingat,
                                activeColor: AppColors.maroon,
                                onChanged: (v) => setState(() => _ingat = v ?? false),
                              ),
                              const Expanded(
                                  child: Text('Ingat warung saya di perangkat ini',
                                      style: TextStyle(fontSize: 13))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loading ? null : _masuk,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5, color: Colors.white))
                                : const Text('Masuk ke Dashboard  →'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text('Butuh bantuan kasir atau stok?',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        if (offline) {
                          showSnack(context, 'Tidak ada koneksi internet.',
                              error: true);
                        } else {
                          showSnack(context, 'Menghubungi +62 812-3456-789 (simulasi)');
                        }
                      },
                      child: const Text('Hubungi Bantuan WarungKu (+62 812-3456-789)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.maroon, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
