import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';

// Import ke-4 halaman admin yang sudah kamu buat
import 'admin_dashboard.dart';
import 'admin_pesanan.dart';
import 'admin_laporan.dart';
import 'admin_customer.dart';

class MainPageAdmin extends StatefulWidget {
  const MainPageAdmin({super.key});

  @override
  State<MainPageAdmin> createState() => _MainPageAdminState();
}

class _MainPageAdminState extends State<MainPageAdmin> {
  int _currentIndex = 0;

  // Daftar halaman yang akan ditampilkan sesuai index tab yang dipilih
  final List<Widget> _pages = [
    const AdminDashboard(),
    const AdminPesanan(),
    const AdminLaporan(),
    const AdminCustomer(),
  ];

  // Daftar judul AppBar yang berubah dinamis mengikuti halaman aktif
  final List<String> _titles = [
    'MyLaundry Admin Panel',
    'Kelola Pesanan',
    'Laporan Keuangan',
    'Daftar Pelanggan',
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar diletakkan di sini agar konsisten di semua halaman admin
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0091BD), // Warna Biru Utama
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      // Menampilkan halaman aktif sesuai index
      body: _pages[_currentIndex],
      
      // KONFIGURASI BOTTOM NAVBAR UTAMA ADMIN
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0091BD), // Biru Utama untuk item aktif
        unselectedItemColor: Colors.grey.shade400,   // Abu-abu untuk item mati
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_rounded),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Customer',
          ),
        ],
      ),
    );
  }
}