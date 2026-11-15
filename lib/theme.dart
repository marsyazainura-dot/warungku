import 'package:flutter/material.dart';

class AppColors {
  static const maroon = Color(0xFF7A0019);
  static const cream = Color(0xFFFFF6F0);
  static const sand = Color(0xFFF6E9DC);
  static const red = Color(0xFFD64560);
  static const redSoft = Color(0xFFFCE4E8);
  static const green = Color(0xFF2E7D32);
  static const greenSoft = Color(0xFFE3F4E5);
  static const text = Color(0xFF2B1B1B);
  static const muted = Color(0xFF7A6B6B);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.maroon)
        .copyWith(primary: AppColors.maroon),
    scaffoldBackgroundColor: AppColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.maroon,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.maroon,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

InputDecoration inputDeco({
  required String hint,
  IconData? icon,
  Widget? suffix,
  String? prefixText,
}) {
  OutlineInputBorder b(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: 1.2),
      );
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppColors.sand,
    prefixIcon: icon == null ? null : Icon(icon, color: AppColors.muted),
    suffixIcon: suffix,
    prefixText: prefixText,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: b(Colors.transparent),
    enabledBorder: b(Colors.transparent),
    focusedBorder: b(AppColors.maroon),
    errorBorder: b(AppColors.red),
    focusedErrorBorder: b(AppColors.red),
  );
}

BoxDecoration cardDeco({Color color = Colors.white}) => BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(15),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
