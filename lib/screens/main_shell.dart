import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils.dart';
import 'dashboard_screen.dart';
import 'form_screen.dart';
import 'profil_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0; // 0 = Stok, 2 = Warung (1 = tombol Tambah)

  void _bukaForm() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const FormScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.sand,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storefront, color: AppColors.maroon),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('WarungKu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text(_tab == 0 ? 'Dashboard Stok' : 'Profil Warung',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: app.jumlahMenipis > 0,
              label: Text('${app.jumlahMenipis}'),
              child: const Icon(Icons.notifications_none),
            ),
            onPressed: () => showSnack(
              context,
              app.jumlahMenipis > 0
                  ? '${app.jumlahMenipis} barang stok menipis, segera kulakan!'
                  : 'Semua stok aman',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _tab = 2),
              child: const CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.maroon,
                child: Icon(Icons.person, size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab == 2 ? 1 : 0,
        children: const [DashboardScreen(), ProfilScreen()],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: _bukaForm,
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Barang',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.sand,
        selectedIndex: _tab,
        onDestinationSelected: (i) {
          if (i == 1) {
            _bukaForm();
          } else {
            setState(() => _tab = i);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: AppColors.maroon),
            label: 'Stok',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'Tambah',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: AppColors.maroon),
            label: 'Warung',
          ),
        ],
      ),
    );
  }
}
