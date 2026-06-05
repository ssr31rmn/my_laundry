import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  // Fungsi internal untuk memunculkan Pop-up pilihan status saat kartu pesanan diklik
  void _showStatusDialog(
    BuildContext context,
    OrderModel order,
    OrderProvider orderProvider,
  ) {
    List<String> statuses = ['Antrean', 'Dicuci', 'Disetrika', 'Selesai'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Perbarui Status\n${order.packageType}'),
          content: const Text(
            'Pilih status terbaru untuk cucian milik customer ini:',
          ),
          actions: [
            // Membikin daftar tombol pilihan status ke bawah
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: statuses.map((String status) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // Jika status di tombol sama dengan status sekarang, warnai oranye
                      backgroundColor: order.status == status
                          ? const Color(0xFFFF9C0A)
                          : Colors.grey.shade100,
                      foregroundColor: order.status == status
                          ? Colors.white
                          : Colors.black87,
                    ),
                    onPressed: () async {
                      // Panggil fungsi update di order_provider
                      String? error = await orderProvider.updateOrderStatus(
                        order.orderId,
                        status,
                      );

                      if (context.mounted) {
                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal: $error')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Status berhasil diperbarui!'),
                            ),
                          );
                        }
                        Navigator.pop(context); // Tutup pop-up dialog
                      }
                    },
                    child: Text(status),
                  ),
                );
              }).toList(),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Center(
                child: Text('Batal', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'MyLaundry Admin Panel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF9C0A), // Tema Oranye untuk Admin
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header Admin
            const Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 50,
                  color: Color(0xFFFF9C0A),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode Pemilik / Admin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Kelola semua antrean masuk di sini',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Semua Antrean Laundry Masuk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9C0A),
              ),
            ),
            const SizedBox(height: 10),

            // STREAM DATA UNTUK MELIHAT SEMUA ORDER SECARA REAL-TIME
            Expanded(
              child: StreamBuilder<List<OrderModel>>(
                stream: orderProvider.getAllOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF9C0A),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada orderan masuk dari customer.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  List<OrderModel> allOrders = snapshot.data!;

                  // =========================================================
                  // TAMBAHKAN BLOK KODE PERHITUNGAN INI:
                  // =========================================================
                  int totalPendapatanPasti =
                      0; // Hanya yang statusnya 'Selesai'
                  int totalTargetPendapatan = 0; // Semua pesanan yang masuk

                  for (var order in allOrders) {
                    totalTargetPendapatan += order.totalPrice;
                    if (order.status == 'Selesai') {
                      totalPendapatanPasti += order.totalPrice;
                    }
                  }
                  // =========================================================
                  // Kita bungkus dengan Column agar kotak keuangan berada di atas daftar antrean
                  return Column(
                    children: [
                      // KOTAK RINGKASAN LAPORAN KEUANGAN
                      Row(
                        children: [
                          // 1. Kotak Pendapatan Masuk (Selesai)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Uang Masuk (Selesai)', style: TextStyle(fontSize: 12, color: Colors.green)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp $totalPendapatanPasti',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 2. Kotak Total Omzet (Semua Status)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9C0A).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFF9C0A).withOpacity(0.5)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Target Omzet', style: TextStyle(fontSize: 12, color: Color(0xFFFF9C0A))),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp $totalTargetPendapatan',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF9C0A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16), // Jarak antara kotak keuangan dengan list di bawahnya
                      
                      // DAFTAR ANTREAN LAUNDRY MASUK
                      Expanded(
                        child: ListView.builder(
                          itemCount: allOrders.length,
                          itemBuilder: (context, index) {
                            OrderModel order = allOrders[index];

                            // Penentuan warna badge status
                            Color statusColor = Colors.grey;
                            if (order.status == 'Antrean') statusColor = const Color(0xFFFF9C0A);
                            if (order.status == 'Dicuci') statusColor = Colors.blue;
                            if (order.status == 'Disetrika') statusColor = Colors.purple;
                            if (order.status == 'Selesai') statusColor = Colors.green;

                            return Card(
                              color: Colors.white,
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => _showStatusDialog(context, order, orderProvider),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.packageType,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('Pelanggan: ${order.customerName}', style: const TextStyle(color: Colors.black54)),
                                          Text('Jumlah: ${order.weightOrQuantity} Kg/unit', style: const TextStyle(color: Colors.black54)),
                                          Text(
                                            'Total: Rp ${order.totalPrice}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: statusColor),
                                            ),
                                            child: Text(
                                              order.status,
                                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const Icon(Icons.edit_note_rounded, color: Colors.grey, size: 20),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ); // <--- Penutup return Column baru
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
