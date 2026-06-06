import 'package:flutter/material.dart';

class CustomerReports extends StatelessWidget {
  const CustomerReports({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 1. WARNA DOMINAN: Putih Bersih
      appBar: AppBar(
        title: const Text(
          'Laporan & Statistik',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0091BD), // 2. WARNA PRIMER: Biru Utama
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Bulan Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0091BD)),
            ),
            const SizedBox(height: 16),

            // ==========================================
            // KOTAK STATISTIK UTAMA (KOMBINASI WARNA)
            // ==========================================
            Row(
              children: [
                // Kotak Pengeluaran (Aksen Oranye)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9C0A).withOpacity(0.1), // Oranye transparan
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF9C0A), width: 1.5),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Biaya', style: TextStyle(color: Colors.black54, fontSize: 12)),
                        SizedBox(height: 4),
                        Text(
                          'Rp 0', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF9C0A)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Kotak Jumlah Transaksi (Aksen Biru)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0091BD).withOpacity(0.1), // Biru transparan
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0091BD), width: 1.5),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Cucian', style: TextStyle(color: Colors.black54, fontSize: 12)),
                        SizedBox(height: 4),
                        Text(
                          '0 Transaksi', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0091BD)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ==========================================
            // GRAFIK / ILUSTRASI DUMMY 
            // ==========================================
            const Text(
              'Grafik Penggunaan Jasa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0091BD)),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_rounded, size: 50, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada data visualisasi',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}