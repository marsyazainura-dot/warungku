import 'package:flutter/foundation.dart';

import '../models/barang.dart';

class AppState extends ChangeNotifier {
  static const kategoriList = ['Makanan', 'Minuman', 'Sembako', 'Lainnya'];
  static const satuanList = ['pcs', 'kg', 'btl', 'pch', 'sct', 'pck', 'liter'];

  final List<Barang> _items = [
    const Barang(
      id: 1,
      nama: 'Indomie Goreng',
      kategori: 'Makanan',
      hargaBeli: 2800,
      hargaJual: 3500,
      stok: 40,
      satuan: 'pcs',
      lokasi: 'Rak Mie 01',
      tanggal: '10 Okt 2026',
    ),
    const Barang(
      id: 2,
      nama: 'Beras 5 kg',
      kategori: 'Sembako',
      hargaBeli: 62000,
      hargaJual: 68000,
      stok: 12,
      satuan: 'kg',
      lokasi: 'Gudang Belakang',
      tanggal: '10 Okt 2026',
    ),
    const Barang(
      id: 3,
      nama: 'Teh Botol',
      kategori: 'Minuman',
      hargaBeli: 3500,
      hargaJual: 5000,
      stok: 4,
      satuan: 'btl',
      lokasi: 'Kulkas Pendingin 01',
      tanggal: '12 Okt 2026',
    ),
    const Barang(
      id: 4,
      nama: 'Minyak Goreng 1 L',
      kategori: 'Sembako',
      hargaBeli: 16000,
      hargaJual: 18000,
      stok: 3,
      satuan: 'pch',
      lokasi: 'Rak Sembako 02',
      tanggal: '12 Okt 2026',
    ),
    const Barang(
      id: 5,
      nama: 'Kopi Sachet',
      kategori: 'Minuman',
      hargaBeli: 1200,
      hargaJual: 2000,
      stok: 60,
      satuan: 'sct',
      lokasi: 'Rak Depan',
      tanggal: '14 Okt 2026',
    ),
    const Barang(
      id: 6,
      nama: 'Telur 1 kg',
      kategori: 'Sembako',
      hargaBeli: 26000,
      hargaJual: 29000,
      stok: 8,
      satuan: 'kg',
      lokasi: 'Rak Sembako 01',
      tanggal: '15 Okt 2026',
    ),
    const Barang(
      id: 7,
      nama: 'Roti Tawar',
      kategori: 'Makanan',
      hargaBeli: 13000,
      hargaJual: 16000,
      stok: 5,
      satuan: 'pck',
      lokasi: 'Rak Roti',
      tanggal: '18 Okt 2026',
    ),
    const Barang(
      id: 8,
      nama: 'Gula 1 kg',
      kategori: 'Sembako',
      hargaBeli: 15000,
      hargaJual: 17500,
      stok: 15,
      satuan: 'kg',
      lokasi: 'Rak Sembako 01',
      tanggal: '18 Okt 2026',
    ),
  ];

  int _nextId = 9;
  String _query = '';
  String _kategori = 'Semua';
  int _ambang = 5;
  bool _offline = false;
  bool _loggedIn = false;

  // ---- getter ----
  List<Barang> get items => List.unmodifiable(_items);
  String get query => _query;
  String get kategori => _kategori;
  int get ambang => _ambang;
  bool get offline => _offline;
  bool get loggedIn => _loggedIn;
  int get nextId => _nextId;

  List<Barang> get filtered {
    final q = _query.trim().toLowerCase();
    return _items.where((b) {
      final cocokKategori = _kategori == 'Semua' || b.kategori == _kategori;
      final cocokNama = q.isEmpty || b.nama.toLowerCase().contains(q);
      return cocokKategori && cocokNama;
    }).toList();
  }

  int countKategori(String k) => k == 'Semua'
      ? _items.length
      : _items.where((b) => b.kategori == k).length;

  bool isMenipis(Barang b) => b.stok <= _ambang;
  int get jumlahMenipis => _items.where(isMenipis).length;
  int get nilaiStok => _items.fold(0, (s, b) => s + b.hargaBeli * b.stok);

  Barang? byId(int id) {
    for (final b in _items) {
      if (b.id == id) return b;
    }
    return null;
  }

  // ---- auth ----
  bool login(String user, String pass) {
    if (user.trim() == 'marsya' && pass == '12345678') {
      _loggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _loggedIn = false;
    notifyListeners();
  }

  // ---- filter ----
  void setQuery(String v) {
    _query = v;
    notifyListeners();
  }

  void setKategori(String v) {
    _kategori = v;
    notifyListeners();
  }

  // ---- pengaturan ----
  void setAmbang(int v) {
    _ambang = v.clamp(1, 99);
    notifyListeners();
  }

  void setOffline(bool v) {
    _offline = v;
    notifyListeners();
  }

  // ---- CRUD ----
  void tambah(Barang b) {
    _items.insert(0, b);
    _nextId++;
    notifyListeners();
  }

  void update(Barang b) {
    final i = _items.indexWhere((e) => e.id == b.id);
    if (i != -1) {
      _items[i] = b;
      notifyListeners();
    }
  }

  void hapus(int id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Mengubah stok. Mengembalikan false jika hasilnya negatif.
  bool ubahStok(int id, int delta) {
    final b = byId(id);
    if (b == null) return false;
    final baru = b.stok + delta;
    if (baru < 0) return false;
    update(b.copyWith(stok: baru));
    return true;
  }
}
