import 'package:flutter/material.dart';
import 'theme.dart';

String rupiah(int v) {
  final s = v.abs().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp ${v < 0 ? '-' : ''}$b';
}

String ringkasRupiah(int v) {
  if (v >= 1000000) {
    return '${(v / 1000000).toStringAsFixed(2).replaceAll('.', ',')} jt';
  }
  if (v >= 1000) {
    return '${(v / 1000).toStringAsFixed(0)} rb';
  }
  return '$v';
}

String tanggalSekarang() {
  const bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  final n = DateTime.now();
  return '${n.day} ${bulan[n.month - 1]} ${n.year}';
}

IconData iconKategori(String k) {
  switch (k) {
    case 'Makanan':
      return Icons.ramen_dining;
    case 'Minuman':
      return Icons.local_cafe;
    case 'Sembako':
      return Icons.shopping_basket;
    default:
      return Icons.inventory_2;
  }
}

void snack(ScaffoldMessengerState m, String msg, {bool error = false}) {
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: error ? AppColors.red : AppColors.maroon,
    behavior: SnackBarBehavior.floating,
  ));
}

void showSnack(BuildContext context, String msg, {bool error = false}) {
  snack(ScaffoldMessenger.of(context), msg, error: error);
}
