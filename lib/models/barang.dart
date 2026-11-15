class Barang {
  final int id;
  final String nama;
  final String kategori;
  final int hargaBeli;
  final int hargaJual;
  final int stok;
  final String satuan;
  final String lokasi;
  final String tanggal;

  const Barang({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.hargaBeli,
    required this.hargaJual,
    required this.stok,
    required this.satuan,
    this.lokasi = 'Rak Utama',
    required this.tanggal,
  });

  String get sku => 'WK-${id.toString().padLeft(3, '0')}';
  int get margin => hargaJual - hargaBeli;
  double get marginPersen => hargaBeli == 0 ? 0 : margin / hargaBeli * 100;

  Barang copyWith({int? stok}) => Barang(
        id: id,
        nama: nama,
        kategori: kategori,
        hargaBeli: hargaBeli,
        hargaJual: hargaJual,
        stok: stok ?? this.stok,
        satuan: satuan,
        lokasi: lokasi,
        tanggal: tanggal,
      );
}
