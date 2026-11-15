import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const WarungKuApp(),
    ),
  );
}

class WarungKuApp extends StatelessWidget {
  const WarungKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WarungKu',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const MainShell(),
      },
    );
  }
}
