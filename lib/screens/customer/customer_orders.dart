import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';

class CustomerOrders extends StatelessWidget {
  const CustomerOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String currentUid = authProvider.userModel?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.white, // 1. WARNA DOMINAN: Putih
      appBar: AppBar(
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0091BD), // 2. WARNA PRIMER: Biru Utama
        elevation: 0,
        automaticallyImplyLeading: false, // Menghilangkan tombol back karena sudah ada navbar di bawah
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderProvider.getCustomerOrdersStream(currentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0091BD)),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late_rounded, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada pesanan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Yuk, buat pesanan laundry pertama kamu di Beranda!',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          List<OrderModel> myOrders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myOrders.length,
            itemBuilder: (context, index) {
              OrderModel order = myOrders[index];

              // Penentuan warna badge status dinamis (Menggunakan Oranye sebagai aksen utama perhatian)
              Color statusColor = Colors.grey;
              if (order.status == 'Antrean') statusColor = const Color(0xFFFF9C0A); // 3. WARNA AKSEN: Oranye
              if (order.status == 'Dicuci') statusColor = Colors.blue;
              if (order.status == 'Disetrika') statusColor = Colors.purple;
              if (order.status == 'Selesai') statusColor = Colors.green;

              return Card(
                color: Colors.white,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.packageType,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Berat/Jumlah: ${order.weightOrQuantity} Kg/unit',
                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total Harga: Rp ${order.totalPrice}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: Color(0xFF0091BD), // Teks harga menggunakan warna Biru Utama
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor, width: 1.5),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}