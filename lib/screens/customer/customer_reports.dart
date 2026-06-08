import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart'; // Import library grafik baru
import 'package:my_laundry/providers/order_provider.dart';
import 'package:my_laundry/models/order_model.dart';

class CustomerReports extends StatelessWidget {
  const CustomerReports({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Laporan & Statistik',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0091BD),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: uid == null
          ? const Center(child: Text('Gagal memuat data pengguna. Silakan login kembali.'))
          : StreamBuilder<List<OrderModel>>(
              stream: Provider.of<OrderProvider>(context, listen: false)
                  .getAllCustomerOrders(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0091BD)),
                    ),
                  );
                }

                int totalBiaya = 0;
                int totalTransaksi = 0;
                
                // Variabel untuk menghitung jumlah tiap jenis paket untuk grafik
                double jumlahKiloan = 0;
                double jumlahSatuan = 0;

                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final listPesanan = snapshot.data!;
                  totalTransaksi = listPesanan.length;

                  for (var order in listPesanan) {
                    if (order.status != 'Belum Bayar') {
                      totalBiaya += order.totalPrice;
                    }
                    
                    // Kelompokkan data untuk grafik berdasarkan jenis paket
                    if (order.packageType == 'Kiloan') {
                      jumlahKiloan += 1;
                    } else {
                      jumlahSatuan += 1;
                    }
                  }
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Bulan Ini',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0091BD)),
                      ),
                      const SizedBox(height: 16),

                      // ==========================================
                      // KOTAK STATISTIK UTAMA
                      // ==========================================
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9C0A).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFFF9C0A), width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Biaya',
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp $totalBiaya',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFF9C0A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0091BD).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFF0091BD), width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Cucian',
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$totalTransaksi Transaksi',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0091BD)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ==========================================
                      // GRAFIK DENGAN FL_CHART (SUNGUHAN)
                      // ==========================================
                      const Text(
                        'Grafik Penggunaan Jasa',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0091BD)),
                      ),
                      const SizedBox(height: 16),
                      
                      totalTransaksi == 0
                          ? Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Center(child: Text('Belum ada data visualisasi')),
                            )
                          : Container(
                              height: 220,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: (jumlahKiloan > jumlahSatuan ? jumlahKiloan : jumlahSatuan) + 2,
                                  barTouchData: BarTouchData(enabled: true),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          switch (value.toInt()) {
                                            case 0:
                                              return const Text('Paket Kiloan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
                                            case 1:
                                              return const Text('Paket Satuan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
                                            default:
                                              return const Text('');
                                          }
                                        },
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                                    ),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  barGroups: [
                                    // Batang Pertama: Paket Kiloan (Warna Oranye)
                                    BarChartGroupData(
                                      x: 0,
                                      barRods: [
                                        BarChartRodData(
                                          toY: jumlahKiloan,
                                          color: const Color(0xFFFF9C0A),
                                          width: 30,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            topRight: Radius.circular(6),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Batang Kedua: Paket Satuan (Warna Biru)
                                    BarChartGroupData(
                                      x: 1,
                                      barRods: [
                                        BarChartRodData(
                                          toY: jumlahSatuan,
                                          color: const Color(0xFF0091BD),
                                          width: 30,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            topRight: Radius.circular(6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}