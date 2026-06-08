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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Perbarui Status\n${order.packageType}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Pilih status terbaru untuk cucian milik customer ini:',
          ),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: statuses.map((String status) {
                bool isCurrentStatus = order.status == status;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: isCurrentStatus
                          ? const Color(
                              0xFF0091BD,
                            ) // Menggunakan Biru Utama saat terpilih
                          : Colors.grey.shade100,
                      foregroundColor: isCurrentStatus
                          ? Colors.white
                          : Colors.black87,
                      elevation: isCurrentStatus ? 2 : 0,
                    ),
                    onPressed: () async {
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
                              backgroundColor: Color(0xFF0091BD),
                            ),
                          );
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      status,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Center(
                child: Text(
                  'Batal',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
      // appBar: AppBar(
      //   title: const Text(
      //     'MyLaundry Admin Panel',
      //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   ),
      //   backgroundColor: const Color(
      //     0xFF0091BD,
      //   ), // 1. UPGRADE APPBAR: Menjadi Biru Utama
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.logout_rounded, color: Colors.white),
      //       onPressed: () async {
      //         await authProvider.logout();
      //         if (context.mounted) {
      //           Navigator.pushReplacement(
      //             context,
      //             MaterialPageRoute(builder: (_) => const LoginScreen()),
      //           );
      //         }
      //       },
      //     ),
      //   ],
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // INFO HEADER ADMIN (LOGO & WELCOME TEXT)
            // ==========================================
            Row(
              children: [
                // MENGUBAH JADI PERSEGI DENGAN SUDUT MEMBULAT
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    shape:
                        BoxShape.rectangle, // 1. Ubah shape menjadi rectangle
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // 2. Atur tingkat kelengkungan sudut (makin besar makin bulat)
                    border: Border.all(
                      color: const Color.fromARGB(255, 218, 218, 218),
                      width: 2,
                    ), // Tetap pertahankan border biru
                    image: const DecorationImage(
                      image: AssetImage('assets/App_Logo_MyLaundry.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang, Admin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0091BD),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Kelola semua antrean masuk di sini',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
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
                color: Color(0xFF0091BD),
              ),
            ),
            const SizedBox(height: 12),

            // STREAM DATA UNTUK MELIHAT SEMUA ORDER SECARA REAL-TIME
            Expanded(
              child: StreamBuilder<List<OrderModel>>(
                stream: orderProvider.getAllOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0091BD),
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

                  int totalPendapatanPasti =
                      0; // Hanya yang statusnya 'Selesai'
                  int totalTargetPendapatan = 0; // Semua pesanan yang masuk

                  for (var order in allOrders) {
                    totalTargetPendapatan += order.totalPrice;
                    if (order.status == 'Selesai') {
                      totalPendapatanPasti += order.totalPrice;
                    }
                  }

                  return Column(
                    children: [
                      // ==========================================
                      // KOTAK RINGKASAN KEUANGAN (UPGRADE VISUAL)
                      // ==========================================
                      Row(
                        children: [
                          // 1. Kotak Uang Masuk / Selesai (Tema Biru Utama)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF0091BD,
                                ).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF0091BD),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Uang Masuk (Selesai)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF0091BD),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Rp $totalPendapatanPasti',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0091BD),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 2. Kotak Total Target Omzet (Tema Aksen Oranye)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFF9C0A,
                                ).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFF9C0A),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Target Omzet',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFFF9C0A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Rp $totalTargetPendapatan',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF9C0A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ==========================================
                      // DAFTAR LIST ANTREAN LAUNDRY
                      // ==========================================
                      Expanded(
                        child: ListView.builder(
                          itemCount: allOrders.length,
                          itemBuilder: (context, index) {
                            OrderModel order = allOrders[index];

                            // Penentuan warna badge status agar serasi
                            Color statusColor = Colors.grey;
                            if (order.status == 'Antrean')
                              statusColor = const Color(0xFFFF9C0A);
                            if (order.status == 'Dicuci')
                              statusColor = const Color(0xFF0091BD);
                            if (order.status == 'Disetrika')
                              statusColor = Colors.purple;
                            if (order.status == 'Selesai')
                              statusColor = Colors.green;

                            return Card(
                              color: Colors.white,
                              elevation:
                                  0, // Mengurangi elevation berlebih agar terkesan flat-modern
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ), //  Menggunakan 'side' dan 'BorderSide'
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _showStatusDialog(
                                  context,
                                  order,
                                  orderProvider,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.packageType,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Pelanggan: ${order.customerName}',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            'Jumlah: ${order.weightOrQuantity} Kg/unit',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Total: Rp ${order.totalPrice}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: statusColor,
                                                width: 1.2,
                                              ),
                                            ),
                                            child: Text(
                                              order.status,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Colors.grey.shade400,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
