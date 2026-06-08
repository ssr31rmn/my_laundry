import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart'; // Pastikan import model ini sudah benar

class AdminPesanan extends StatefulWidget {
  const AdminPesanan({super.key});

  @override
  State<AdminPesanan> createState() => _AdminPesananState();
}

class _AdminPesananState extends State<AdminPesanan> {
  // State untuk Sorting
  String _sortBy = 'waktu'; // Pilihan: waktu, status, harga, jenis
  bool _isAscending = false; // false = Terbaru/Terbesar, true = Terlama/Terkecil

  // State untuk Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // 🟢 MENGGUNAKAN STREAMBUILDER UNTUK DATA REAL-TIME FIRESTORE
      body: StreamBuilder<List<OrderModel>>(
        stream: orderProvider.getAllOrders(), // Memanggil fungsi stream dari provider
        builder: (context, snapshot) {
          // Kondisi saat loading mengambil data dari Firestore
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Kondisi jika terjadi error sistem
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          // Jika data kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data pesanan laundry.'));
          }

          List<OrderModel> allOrders = snapshot.data!;

          // ==========================================
          // PROSES SORTING DATA (REAL-TIME)
          // ==========================================
          List<OrderModel> sortedOrders = List.from(allOrders);
          sortedOrders.sort((a, b) {
            int compare = 0;
            if (_sortBy == 'waktu') {
              compare = a.createdAt.compareTo(b.createdAt);
            } else if (_sortBy == 'status') {
              compare = a.status.compareTo(b.status);
            } else if (_sortBy == 'harga') {
              compare = a.totalPrice.compareTo(b.totalPrice);
            } else if (_sortBy == 'jenis') {
              // Menyortir gabungan packageType + itemDetail (Kiloan/Satuan)
              String jenisA = '${a.packageType} ${a.itemDetail}';
              String jenisB = '${b.packageType} ${b.itemDetail}';
              compare = jenisA.compareTo(jenisB);
            }
            return _isAscending ? compare : -compare;
          });

          // ==========================================
          // PROSES PAGINATION DATA (5 ITEM PER HALAMAN)
          // ==========================================
          int totalItems = sortedOrders.length;
          int totalPages = (totalItems / _itemsPerPage).ceil();
          if (totalPages == 0) totalPages = 1;

          // Mengatur batas index pemotongan list
          int startIndex = (_currentPage - 1) * _itemsPerPage;
          int endIndex = startIndex + _itemsPerPage;
          if (endIndex > totalItems) endIndex = totalItems;

          // Mengambil potongan 5 data untuk halaman aktif
          List<OrderModel> paginatedOrders = sortedOrders.sublist(startIndex, endIndex);

          return Column(
            children: [
              // 📊 HEADER KONTROL: FILTERS & SORTING
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sort_rounded, color: Color(0xFF0091BD)),
                        const SizedBox(width: 8),
                        Text(
                          'Urutkan:',
                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: _sortBy,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF0091BD)),
                      style: const TextStyle(color: Color(0xFF0091BD), fontWeight: FontWeight.bold),
                      items: const [
                        DropdownMenuItem(value: 'waktu', child: Text('Waktu Masuk')),
                        DropdownMenuItem(value: 'status', child: Text('Status Progres')),
                        DropdownMenuItem(value: 'harga', child: Text('Total Biaya')),
                        DropdownMenuItem(value: 'jenis', child: Text('Jenis Kiloan/Satuan')),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _sortBy = newValue;
                            _currentPage = 1; // Reset ke halaman 1 jika filter diganti
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _isAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        color: const Color(0xFF0091BD),
                      ),
                      onPressed: () {
                        setState(() {
                          _isAscending = !_isAscending;
                        });
                      },
                    )
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),

              // 📦 LIST DATA PESANAN LAUNDRY
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: paginatedOrders.length,
                  itemBuilder: (context, index) {
                    final order = paginatedOrders[index];

                    // Penentuan skema warna indikator status secara dinamis
                    Color statusColor = Colors.orange;
                    if (order.status == 'Dicuci') statusColor = const Color(0xFF0091BD);
                    if (order.status == 'Selesai' || order.status == 'Selesai & Diarsipkan') {
                      statusColor = Colors.green;
                    }

                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${order.packageType} (${order.itemDetail})',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: statusColor, width: 1),
                                  ),
                                  child: Text(
                                    order.status,
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Pelanggan: ${order.customerName}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            Text('Jumlah/Bobot: ${order.weightOrQuantity}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total: Rp ${order.totalPrice}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0091BD), fontSize: 15),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF0091BD)),
                                  onPressed: () {
                                    // Panggil fungsi pembuka dialog ubah status di sini
                                    _showStatusUpdateDialog(context, order, orderProvider);
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 🎛️ PANEL NAVIGASI HALAMAN (PAGINATION FOOTER)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0091BD),
                        elevation: 0,
                        side: BorderSide(color: _currentPage > 1 ? const Color(0xFF0091BD) : Colors.grey.shade300),
                      ),
                      onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                      child: const Text('Prev'),
                    ),
                    Text(
                      'Halaman $_currentPage dari $totalPages',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0091BD),
                        elevation: 0,
                        side: BorderSide(color: _currentPage < totalPages ? const Color(0xFF0091BD) : Colors.grey.shade300),
                      ),
                      onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 📝 DIALOG AKSI UNTUK MERUBAH STATUS PROGRESS PESANAN CUSTOMER
  void _showStatusUpdateDialog(BuildContext context, OrderModel order, OrderProvider provider) {
    String selectedStatus = order.status;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Status Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return DropdownButton<String>(
                value: selectedStatus,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'Belum Bayar', child: Text('Belum Bayar')),
                  DropdownMenuItem(value: 'Antrean', child: Text('Antrean')),
                  DropdownMenuItem(value: 'Dicuci', child: Text('Sedang Dicuci')),
                  DropdownMenuItem(value: 'Selesai', child: Text('Selesai (Siap Ambil)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedStatus = value);
                  }
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0091BD)),
              onPressed: () async {
                await provider.updateOrderStatus(order.orderId, selectedStatus);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}