import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/barang.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils.dart';

class FormScreen extends StatefulWidget {
  final Barang? barang; // null = mode Tambah, isi = mode Edit
  const FormScreen({super.key, this.barang});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _beli;
  late final TextEditingController _jual;
  late final TextEditingController _stok;
  late String _kategori;
  late String _satuan;

  bool get _edit => widget.barang != null;

  @override
  void initState() {
    super.initState();
    final b = widget.barang;
    _nama = TextEditingController(text: b?.nama ?? '');
    _beli = TextEditingController(text: b?.hargaBeli.toString() ?? '');
    _jual = TextEditingController(text: b?.hargaJual.toString() ?? '');
    _stok = TextEditingController(text: b?.stok.toString() ?? '0');
    _kategori = b?.kategori ?? AppState.kategoriList.first;
    _satuan = b?.satuan ?? AppState.satuanList.first;
    for (final c in [_nama, _beli, _jual, _stok]) {
      c.addListener(_refresh);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in [_nama, _beli, _jual, _stok]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- validasi ----------
  String? _vAngka(String? v, String label) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return '$label wajib diisi';
    final n = int.tryParse(t);
    if (n == null) return 'Masukkan angka yang valid';
    if (n < 0) return '$label tidak boleh negatif';
    return null;
  }

  String? _vJual(String? v) {
    final dasar = _vAngka(v, 'Harga jual');
    if (dasar != null) return dasar;
    final jual = int.parse(v!.trim());
    final beli = int.tryParse(_beli.text.trim());
    if (beli != null && jual < beli) {
      return 'Harga jual lebih kecil dari harga beli (rugi)';
    }
    return null;
  }

  void _ubahStok(int d) {
    final sekarang = int.tryParse(_stok.text.trim()) ?? 0;
    final baru = sekarang + d;
    if (baru < 0) {
      showSnack(context, 'Stok tidak boleh kurang dari 0', error: true);
      return;
    }
    _stok.text = '$baru';
  }

  void _simpan() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      showSnack(context, 'Periksa kembali isian form', error: true);
      return;
    }
    try {
      final app = context.read<AppState>();
      final messenger = ScaffoldMessenger.of(context);
      final b = Barang(
        id: _edit ? widget.barang!.id : app.nextId,
        nama: _nama.text.trim(),
        kategori: _kategori,
        hargaBeli: int.parse(_beli.text.trim()),
        hargaJual: int.parse(_jual.text.trim()),
        stok: int.parse(_stok.text.trim()),
        satuan: _satuan,
        lokasi: widget.barang?.lokasi ?? 'Rak Utama',
        tanggal: widget.barang?.tanggal ?? tanggalSekarang(),
      );
      if (_edit) {
        app.update(b);
      } else {
        app.tambah(b);
      }
      Navigator.pop(context);
      snack(messenger,
          _edit ? 'Perubahan "${b.nama}" disimpan' : '"${b.nama}" berhasil ditambahkan');
    } catch (e) {
      showSnack(context, 'Gagal menyimpan: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ambang = context.watch<AppState>().ambang;

    // data untuk live preview (aman walau input belum valid)
    final pNama = _nama.text.trim().isEmpty ? 'Nama barang' : _nama.text.trim();
    final pBeli = int.tryParse(_beli.text.trim()) ?? 0;
    final pJual = int.tryParse(_jual.text.trim()) ?? 0;
    final pStok = int.tryParse(_stok.text.trim()) ?? 0;
    final pMargin = pJual - pBeli;
    final pPersen = pBeli == 0 ? 0.0 : pMargin / pBeli * 100;
    final pMenipis = pStok <= ambang;

    return Scaffold(
      appBar: AppBar(
        title: Text(_edit ? 'Edit Barang' : 'Tambah Barang',
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(_edit ? 'Edit Data Barang Terdaftar' : 'Tambah Barang Baru',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),

                  _label('Nama Barang *'),
                  TextFormField(
                    controller: _nama,
                    maxLength: 50,
                    textInputAction: TextInputAction.next,
                    decoration: inputDeco(
                        hint: 'Contoh: Teh Botol Sosro',
                        icon: Icons.inventory_2_outlined),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama barang tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 8),

                  _label('Kategori Barang *'),
                  _dropdown(
                    value: _kategori,
                    items: AppState.kategoriList,
                    icon: Icons.category_outlined,
                    onChanged: (v) => setState(() => _kategori = v),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Harga Modal (Beli) *'),
                            TextFormField(
                              controller: _beli,
                              keyboardType: TextInputType.number,
                              decoration: inputDeco(hint: '0', prefixText: 'Rp '),
                              validator: (v) => _vAngka(v, 'Harga beli'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Harga Jual Kasir *'),
                            TextFormField(
                              controller: _jual,
                              keyboardType: TextInputType.number,
                              decoration: inputDeco(hint: '0', prefixText: 'Rp '),
                              validator: _vJual,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Jumlah Stok *'),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _tombolKecil(Icons.remove, () => _ubahStok(-1)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextFormField(
                                    controller: _stok,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: inputDeco(hint: '0'),
                                    validator: (v) => _vAngka(v, 'Stok'),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _tombolKecil(Icons.add, () => _ubahStok(1)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Satuan'),
                            _dropdown(
                              value: _satuan,
                              items: AppState.satuanList,
                              onChanged: (v) => setState(() => _satuan = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ---- live preview ----
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: cardDeco(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.visibility_outlined,
                                    size: 16, color: AppColors.muted),
                                SizedBox(width: 6),
                                Text('LIVE PREVIEW KARTU KASIR',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.muted)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: pMenipis
                                    ? AppColors.redSoft
                                    : AppColors.greenSoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                  pMenipis ? 'Stok Menipis ($pStok)' : 'Stok Aman',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: pMenipis
                                          ? AppColors.red
                                          : AppColors.green)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.sand,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(iconKategori(_kategori),
                                  color: AppColors.maroon),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pNama,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800)),
                                  Text('${rupiah(pJual)} • per $_satuan',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.maroon)),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text('$pStok',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800)),
                                const Text('Tersedia',
                                    style: TextStyle(
                                        fontSize: 11, color: AppColors.muted)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: pMargin >= 0
                                ? AppColors.greenSoft
                                : AppColors.redSoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Margin: ${rupiah(pMargin)} (${pMargin >= 0 ? 'Untung' : 'Rugi'} ${pPersen.toStringAsFixed(1)}%)',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: pMargin >= 0
                                    ? AppColors.green
                                    : AppColors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  ElevatedButton.icon(
                    onPressed: _simpan,
                    icon: const Icon(Icons.save, size: 20),
                    label: Text(_edit ? 'Simpan Perubahan Barang' : 'Simpan Barang'),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Batal & Kembali'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.maroon,
                      backgroundColor: AppColors.sand,
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
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      );

  Widget _tombolKecil(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.sand,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 54,
          child: Icon(icon, color: AppColors.maroon),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    IconData? icon,
  }) {
    return InputDecorator(
      decoration: inputDeco(hint: '', icon: icon).copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
