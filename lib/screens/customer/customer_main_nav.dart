import 'package:flutter/material.dart';
import 'customer_dashboard.dart'; // Halaman 1: Beranda
import 'customer_orders.dart';    // Halaman 2: Pesanan (TAMBAHKAN IMPORT INI)

class CustomerMainNav extends StatefulWidget {
  const CustomerMainNav({super.key});

  @override
  State<CustomerMainNav> createState() => _CustomerMainNavState();
}

class _CustomerMainNavState extends State<CustomerMainNav> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const CustomerDashboard(), // Tab 1: Beranda yang baru (Kombinasi 3 Warna)
      const CustomerOrders(),    // Tab 2: Halaman Pesanan yang baru (GANTI DI SINI)
      const Center(child: Text('Halaman Laporan (Soon)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), // Tab 3
      const Center(child: Text('Halaman Akun (Soon)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),    // Tab 4
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0091BD), // Biru Utama aktif
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}