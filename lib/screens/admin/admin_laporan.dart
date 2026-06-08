import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

class AdminLaporan extends StatefulWidget {
  const AdminLaporan({super.key});

  @override
  State<AdminLaporan> createState() => _AdminLaporanState();
}

class _AdminLaporanState extends State<AdminLaporan> {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<OrderModel>>(
        stream: orderProvider.getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          List<OrderModel> allOrders = snapshot.data ?? [];

          // 1. HITUNG STATISTIK (Filter Berdasarkan Bulan Ini)
          final now = DateTime.now();
          List<OrderModel> thisMonthOrders = allOrders.where((order) {
            return order.createdAt.month == now.month && 
                   order.createdAt.year == now.year;
          }).toList();

          // Hitung Total Biaya/Omzet dari pesanan yang sudah bayar/selesai
          int totalOmzet = 0;
          for (var order in thisMonthOrders) {
            if (order.status != 'Belum Bayar') {
              totalOmzet += order.totalPrice;
            }
          }

          int totalTransaksi = thisMonthOrders.length;

          // 2. HITUNG DATA GRAFIK (Menghitung frekuensi jenis laundry)
          int jumlahKiloan = 0;
          int jumlahSatuan = 0;

          for (var order in thisMonthOrders) {
            if (order.packageType.toLowerCase().contains('kiloan')) {
              jumlahKiloan++;
            } else {
              jumlahSatuan++;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📊 RINGKASAN BULAN INI
                const Text(
                  'Ringkasan Bulan Ini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0091BD),
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    // Box Total Biaya/Omzet
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFedd5), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Biaya', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              'Rp $totalOmzet',
                              style: const TextStyle(
                                color: Color(0xFFFF8C00), // Warna Oranye
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Box Total Cucian/Transaksi
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFCCFBF1), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Cucian', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              '$totalTransaksi Transaksi',
                              style: const TextStyle(
                                color: Color(0xFF0091BD),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 📈 GRAFIK PENGGUNAAN JASA
                const Text(
                  'Grafik Penggunaan Jasa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0091BD),
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: totalTransaksi == 0
                      ? const Column(
                          children: [
                            Icon(Icons.bar_chart_rounded, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Belum ada data visualisasi', style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : Column(
                          children: [
                            Text(
                              'Berhasil memetakan $totalTransaksi data transaksi laundry.',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 24),
                            
                            // VISUALISASI BATANG GRAFIK LOKAL Sederhana
                            _buildBarChartRow('Kiloan', jumlahKiloan, totalTransaksi),
                            const SizedBox(height: 16),
                            _buildBarChartRow('Satuan', jumlahSatuan, totalTransaksi),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget Helper untuk membuat batang grafik persentase
  Widget _buildBarChartRow(String label, int value, int total) {
    double percentage = total > 0 ? (value / total) : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage == 0 ? 0.01 : percentage,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0091BD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 30,
          child: Text(
            '$value',
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}