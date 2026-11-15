import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Akun'),
        content: const Text('Yakin ingin keluar dari WarungKu?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ya, Keluar',
                  style: TextStyle(
                      color: AppColors.red, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<AppState>().logout();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Profil & Pengaturan',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Sistem Siap',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Kelola data warung dan konfigurasi inventaris',
                style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 14),

            // ---- kartu warung ----
            Container(
              padding: const EdgeInsets.all(16),
              decoration: cardDeco(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.sand,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.storefront,
                            size: 36, color: AppColors.maroon),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Warung Berkah Jaya',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w800)),
                            Text('Pak Joko Sudarsono',
                                style: TextStyle(color: AppColors.muted)),
                            Text('Jl. Merpati No. 14, Batam',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.muted)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.maroon),
                        onPressed: () => showSnack(
                            context, 'Edit profil belum tersedia di versi demo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _info('Total Barang', '${app.items.length} Item',
                              AppColors.text)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _info(
                              'Status Data',
                              app.offline ? 'Offline' : 'Tersimpan',
                              app.offline ? AppColors.red : AppColors.green)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ---- ambang stok ----
            Container(
              padding: const EdgeInsets.all(16),
              decoration: cardDeco(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pengaturan Inventaris',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBEEE3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ambang Batas Stok Menipis',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          'Barang dengan stok kurang dari atau sama dengan ${app.ambang} otomatis berlabel "Stok Menipis" di Dashboard.',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.muted),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _bulat(Icons.remove,
                                () => context.read<AppState>().setAmbang(app.ambang - 1)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  Text('${app.ambang}',
                                      style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.maroon)),
                                  const Text('Barang',
                                      style: TextStyle(fontSize: 11)),
                                ],
                              ),
                            ),
                            _bulat(Icons.add,
                                () => context.read<AppState>().setAmbang(app.ambang + 1)),
                            const Spacer(),
                            for (final n in [3, 5, 10])
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: ChoiceChip(
                                  label: Text('$n'),
                                  selected: app.ambang == n,
                                  showCheckmark: false,
                                  selectedColor: AppColors.maroon,
                                  backgroundColor: AppColors.sand,
                                  side: BorderSide.none,
                                  labelStyle: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: app.ambang == n
                                          ? Colors.white
                                          : AppColors.text),
                                  onSelected: (_) =>
                                      context.read<AppState>().setAmbang(n),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ---- sinkronisasi / offline ----
            Container(
              padding: const EdgeInsets.all(16),
              decoration: cardDeco(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Aplikasi & Koneksi',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.maroon,
                    title: const Text('Simulasi Mode Tanpa Internet',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: const Text(
                        'Uji penanganan koneksi terputus pada aplikasi',
                        style: TextStyle(fontSize: 12)),
                    value: app.offline,
                    onChanged: (v) {
                      context.read<AppState>().setOffline(v);
                      showSnack(
                        context,
                        v
                            ? 'Mode offline aktif: koneksi internet terputus'
                            : 'Koneksi internet kembali terhubung',
                        error: v,
                      );
                    },
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Versi Perangkat Lunak',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.muted)),
                      Text('v1.0.0 (Flutter)',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ---- akun ----
            Container(
              padding: const EdgeInsets.all(16),
              decoration: cardDeco(),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_reset, color: AppColors.maroon),
                    title: const Text('Ganti Kata Sandi Warung',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showSnack(
                        context, 'Ganti sandi belum tersedia di versi demo'),
                  ),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar dari Akun'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.red,
                      backgroundColor: AppColors.redSoft,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String nilai, Color warna) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEEE3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(nilai,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: warna)),
        ],
      ),
    );
  }

  Widget _bulat(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.sand,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppColors.maroon),
        ),
      ),
    );
  }
}
