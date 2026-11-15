import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/barang.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils.dart';
import 'form_screen.dart';

class DetailScreen extends StatelessWidget {
  final int barangId;
  const DetailScreen({super.key, required this.barangId});

  void _ubahStok(BuildContext context, int delta) {
    final ok = context.read<AppState>().ubahStok(barangId, delta);
    if (!ok) {
      showSnack(context, 'Stok tidak boleh kurang dari 0', error: true);
    }
  }

  Future<void> _hapus(BuildContext context, Barang b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Yakin hapus barang ini?\n\n${b.nama}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ya, Hapus',
                  style: TextStyle(
                      color: AppColors.red, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      context.read<AppState>().hapus(b.id);
      Navigator.pop(context);
      snack(messenger, '"${b.nama}" berhasil dihapus');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final b = app.byId(barangId);

    // jaga-jaga: barang sudah terhapus
    if (b == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Barang')),
        body: const Center(child: Text('Barang tidak ditemukan')),
      );
    }

    final menipis = app.isMenipis(b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barang',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ---- info utama ----
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: cardDeco(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.sand,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(iconKategori(b.kategori),
                                    size: 14, color: AppColors.maroon),
                                const SizedBox(width: 4),
                                Text(b.kategori,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.maroon)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('SKU: ${b.sku}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(b.nama,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                      Text('Satuan: ${b.satuan}',
                          style: const TextStyle(color: AppColors.muted)),
                      if (menipis) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.redSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: AppColors.red),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Peringatan: Stok Menipis',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.red)),
                                    Text('Tersisa ${b.stok} ${b.satuan} di rak warung',
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _ubahStok(context, 10);
                                  showSnack(context, '+10 ${b.satuan} stok masuk (kulakan)');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.red,
                                  minimumSize: const Size(0, 36),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                child: const Text('Kulakan'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ---- update stok ----
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: cardDeco(),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Perbarui Jumlah Stok',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBEEE3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const Text('SISA STOK SEKARANG',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: AppColors.muted)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _bulat(Icons.remove,
                                    () => _ubahStok(context, -1)),
                                Column(
                                  children: [
                                    Text('${b.stok}',
                                        style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.maroon)),
                                    Text(menipis ? 'Menipis' : 'Aman',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: menipis
                                                ? AppColors.red
                                                : AppColors.green)),
                                  ],
                                ),
                                _bulat(Icons.add, () => _ubahStok(context, 1)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _ubahStok(context, -1),
                                    icon: const Icon(Icons.shopping_cart_outlined,
                                        size: 18),
                                    label: const Text('Terjual (-1)'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.maroon,
                                      backgroundColor: Colors.white,
                                      minimumSize: const Size.fromHeight(44),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _ubahStok(context, 10),
                                    icon: const Icon(Icons.inventory, size: 18),
                                    label: const Text('+10 Masuk'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(44),
                                      textStyle: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Perubahan stok langsung memperbarui data di Dashboard.',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ---- margin ----
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: cardDeco(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Analisis Harga & Margin',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: b.margin >= 0
                                  ? AppColors.greenSoft
                                  : AppColors.redSoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              b.margin >= 0 ? 'Untung Sehat' : 'Rugi',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: b.margin >= 0
                                      ? AppColors.green
                                      : AppColors.red),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: _hargaBox('Modal / Beli',
                                  rupiah(b.hargaBeli), AppColors.text)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _hargaBox('Harga Jual',
                                  rupiah(b.hargaJual), AppColors.maroon)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: b.margin >= 0
                              ? AppColors.greenSoft
                              : AppColors.redSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Margin Keuntungan Bersih',
                                    style: TextStyle(fontSize: 11)),
                                Text('${b.margin >= 0 ? '+' : ''}${rupiah(b.margin)} / ${b.satuan}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: b.margin >= 0
                                            ? AppColors.green
                                            : AppColors.red)),
                              ],
                            ),
                            Text(
                                '${b.marginPersen >= 0 ? '+' : ''}${b.marginPersen.toStringAsFixed(1)}%',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: b.margin >= 0
                                        ? AppColors.green
                                        : AppColors.red)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _baris(Icons.calendar_today_outlined, 'Tanggal Ditambahkan',
                          b.tanggal),
                      const SizedBox(height: 8),
                      _baris(Icons.shelves, 'Lokasi Rak', b.lokasi),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => FormScreen(barang: b)),
                  ),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Data Barang'),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => _hapus(context, b),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus Barang'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.red,
                    backgroundColor: AppColors.redSoft,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bulat(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.sand,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: AppColors.maroon, size: 28),
        ),
      ),
    );
  }

  Widget _hargaBox(String label, String nilai, Color warna) {
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(nilai,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: warna)),
          ),
        ],
      ),
    );
  }

  Widget _baris(IconData icon, String label, String nilai) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.muted),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: AppColors.muted))),
        Text(nilai,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
