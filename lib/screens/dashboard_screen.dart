import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/barang.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils.dart';
import 'detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: context.read<AppState>().query);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.filtered;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _status(app),
                const SizedBox(height: 12),
                _ringkasan(app),
                const SizedBox(height: 14),
                TextField(
                  controller: _search,
                  onChanged: (v) {
                    context.read<AppState>().setQuery(v);
                    setState(() {});
                  },
                  decoration: inputDeco(
                    hint: 'Cari barang dagangan...',
                    icon: Icons.search,
                    suffix: _search.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _search.clear();
                              context.read<AppState>().setQuery('');
                              setState(() {});
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                _chips(app),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (list.isEmpty)
          SliverToBoxAdapter(child: _kosong())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _ItemCard(
                  barang: list[i],
                  menipis: app.isMenipis(list[i]),
                ),
                childCount: list.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _status(AppState app) {
    final off = app.offline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: off ? AppColors.redSoft : AppColors.greenSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(off ? Icons.cloud_off : Icons.cloud_done,
              size: 18, color: off ? AppColors.red : AppColors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              off
                  ? 'Mode Offline: perubahan disimpan di perangkat'
                  : 'Status Sistem: Data Lokal Tersimpan (Siap Offline)',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: off ? AppColors.red : AppColors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ringkasan(AppState app) {
    return Row(
      children: [
        Expanded(
          child: _kartu(Icons.inventory_2, 'Jenis Barang',
              '${app.items.length} Produk', 'Terdaftar', AppColors.maroon, false),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _kartu(Icons.warning_amber_rounded, 'Stok Menipis',
              '${app.jumlahMenipis}', 'Perlu Belanja', AppColors.red, true),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _kartu(Icons.payments, 'Nilai Stok',
              ringkasRupiah(app.nilaiStok), 'Estimasi Modal', AppColors.green, false),
        ),
      ],
    );
  }

  Widget _kartu(IconData icon, String label, String nilai, String sub,
      Color warna, bool warn) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: cardDeco(color: warn ? AppColors.redSoft : Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: warna, size: 22),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: warn ? AppColors.red : AppColors.muted)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(nilai,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: warn ? AppColors.red : AppColors.text)),
          ),
          Text(sub, style: TextStyle(fontSize: 11, color: warna)),
        ],
      ),
    );
  }

  Widget _chips(AppState app) {
    final semua = ['Semua', ...AppState.kategoriList];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: semua.map((k) {
          final aktif = app.kategori == k;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('$k (${app.countKategori(k)})'),
              selected: aktif,
              showCheckmark: false,
              selectedColor: AppColors.maroon,
              backgroundColor: AppColors.sand,
              side: BorderSide.none,
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: aktif ? Colors.white : AppColors.text),
              onSelected: (_) => context.read<AppState>().setKategori(k),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _kosong() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: const [
          Icon(Icons.search_off, size: 64, color: AppColors.muted),
          SizedBox(height: 12),
          Text('Barang tidak ditemukan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text('Coba kata kunci atau kategori lain.',
              style: TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Barang barang;
  final bool menipis;
  const _ItemCard({required this.barang, required this.menipis});

  @override
  Widget build(BuildContext context) {
    final warna = menipis ? AppColors.red : AppColors.green;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => DetailScreen(barangId: barang.id))),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: menipis ? AppColors.redSoft : AppColors.sand,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconKategori(barang.kategori),
                      color: menipis ? AppColors.red : AppColors.maroon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(barang.nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700)),
                      Text(
                          '${barang.kategori} • Beli: ${rupiah(barang.hargaBeli)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.muted)),
                      Text('Jual: ${rupiah(barang.hargaJual)}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.maroon)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: menipis ? AppColors.red : AppColors.text),
                        children: [
                          TextSpan(
                              text: '${barang.stok}',
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w800)),
                          TextSpan(
                              text: ' ${barang.satuan}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: menipis ? AppColors.redSoft : AppColors.greenSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              menipis
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle_outline,
                              size: 13,
                              color: warna),
                          const SizedBox(width: 3),
                          Text(menipis ? 'Stok Menipis' : 'Aman',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: warna)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
