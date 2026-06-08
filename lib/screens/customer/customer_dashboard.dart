import 'package:flutter/material.dart';
import 'package:my_laundry/models/order_model.dart';
import 'package:my_laundry/screens/customer/customer_orders.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  // State untuk form dialog Pesan Laundry
  String _selectedType = 'Kiloan'; // Kiloan atau Satuan
  String _selectedDetail = 'Regular (3 Hari)'; // Sub-jenis layanan
  double _quantity = 1.0;
  String _selectedPerfume = 'Tanpa Parfum';
  String _selectedMethod = 'Cash';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = authProvider.userModel;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'MyLaundry',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0091BD),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // HEADER SAPAAN PENGGUNA & LOGO APLIKASI
            // ==========================================
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Color(0xFF0091BD),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/App_Logo_MyLaundry.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${user?.name ?? "Customer"}!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cucian menumpuk? Yuk laundry sekarang!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ==========================================
            // MENU UTAMA: 3 TOMBOL FUNGSI UTAMA
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu Utama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. TOMBOL PESAN LAUNDRY
                  _buildMenuButton(
                    context: context,
                    title: 'Pesan Laundry',
                    subtitle: 'Mulai order pakaian kiloan atau satuan',
                    icon: Icons.local_laundry_service_rounded,
                    color: const Color(0xFF0091BD),
                    onTap: () => _openOrderSheet(
                      context,
                      orderProvider,
                      user?.uid,
                      user?.name,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. TOMBOL PEMBAYARAN
                  _buildMenuButton(
                    context: context,
                    title: 'Pembayaran',
                    subtitle: 'Selesaikan transaksi Belum Bayar kamu',
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFFFF9C0A), // Warna Aksen Utama
                    onTap: () =>
                        _openPaymentSheet(context, orderProvider, user?.uid),
                  ),
                  const SizedBox(height: 12),

                  // 3. TOMBOL PANTAU PESANAN
                  _buildMenuButton(
                    context: context,
                    title: 'Pantau Pesanan',
                    subtitle: 'Cek status cucian kamu secara real-time',
                    icon: Icons.track_changes_rounded,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CustomerOrders(onlyActive: true),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BUILDER UNTUK TOMBOL MENU
  // ==========================================
  Widget _buildMenuButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FUNGSI BOTTOM SHEET ALUR: PESAN LAUNDRY
  // ==========================================
  void _openOrderSheet(
    BuildContext context,
    OrderProvider provider,
    String? uid,
    String? name,
  ) {
    // Reset state ke nilai default setiap kali form baru dibuka agar tidak membawa data lama
    _selectedType = 'Kiloan';
    _selectedDetail = 'Regular (3 Hari)';
    _quantity = 1.0;
    _selectedPerfume = 'Tanpa Parfum';
    _selectedMethod = 'Cash';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // ========================================================
            // KALKULASI ESTIMASI TOTAL HARGA REAL-TIME DI DALAM MODAL
            // ========================================================
            String priceKey = '$_selectedType $_selectedDetail';
            int pricePerUnit = provider.priceList[priceKey] ?? 0;
            int currentTotalPrice = (pricePerUnit * _quantity).round();

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Form Pesan Laundry',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0091BD),
                    ),
                  ),
                  const Divider(),

                  // 1. Pilih Jenis Layanan (Kiloan / Satuan)
                  const Text(
                    'Jenis Layanan:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Kiloan',
                        groupValue: _selectedType,
                        onChanged: (val) => setModalState(() {
                          _selectedType = val!;
                          _selectedDetail = 'Regular (3 Hari)';
                          _quantity =
                              1.0; // Reset kuantitas ke 1 jika pindah jenis
                        }),
                      ),
                      const Text('Kiloan'),
                      Radio<String>(
                        value: 'Satuan',
                        groupValue: _selectedType,
                        onChanged: (val) => setModalState(() {
                          _selectedType = val!;
                          _selectedDetail = 'Sprei';
                          _quantity =
                              1.0; // Reset kuantitas ke 1 jika pindah jenis
                        }),
                      ),
                      const Text('Satuan'),
                    ],
                  ),

                  // 2. Pilih Detail Pakaian (Dinamis sesuai Jenis Layanan)
                  Text(
                    _selectedType == 'Kiloan'
                        ? 'Pilih Paket Kiloan:'
                        : 'Pilih Item Satuan:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedDetail,
                    items:
                        (_selectedType == 'Kiloan'
                                ? ['Regular (3 Hari)', 'Kilat (1 Hari)']
                                : [
                                    'Sprei',
                                    'Selimut',
                                    'Jas',
                                    'Bedcover',
                                    'Sepatu',
                                  ])
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (val) =>
                        setModalState(() => _selectedDetail = val!),
                  ),
                  const SizedBox(height: 12),

                  // 3. Input Berat atau Jumlah Unit
                  Text(
                    _selectedType == 'Kiloan'
                        ? 'Berat (Kg):'
                        : 'Jumlah (Unit):',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Color(0xFF0091BD),
                        ),
                        onPressed: () {
                          if (_quantity > 1) {
                            setModalState(
                              () => _quantity -= _selectedType == 'Kiloan'
                                  ? 0.5
                                  : 1.0,
                            );
                          }
                        },
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFF0091BD),
                        ),
                        onPressed: () => setModalState(
                          () => _quantity += _selectedType == 'Kiloan'
                              ? 0.5
                              : 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedType == 'Kiloan' ? 'Kg' : 'Unit',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4. Pilihan Varian Parfum
                  const Text(
                    'Pilihan Parfum:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedPerfume,
                    items:
                        ['Fresh', 'Floral', 'Exotic', 'Ocean', 'Tanpa Parfum']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (val) =>
                        setModalState(() => _selectedPerfume = val!),
                  ),
                  const SizedBox(height: 12),

                  // 5. Pilihan Metode Pembayaran
                  const Text(
                    'Metode Pembayaran:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedMethod,
                    items: ['Cash', 'Transfer Bank', 'E-Wallet / QRIS']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) =>
                        setModalState(() => _selectedMethod = val!),
                  ),
                  const SizedBox(height: 16),

                  // ========================================================
                  // PENAMBAHAN INFORMASI DETAIL HARGA DI ATAS TOMBOL UTAMA
                  // ========================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Rp $currentTotalPrice',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0091BD),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tombol Buat Pesanan
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0091BD),
                      ),
                      onPressed: () async {
                        String? err = await provider.createOrder(
                          customerId: uid ?? '',
                          customerName: name ?? 'Customer',
                          packageType: _selectedType,
                          itemDetail: _selectedDetail,
                          weightOrQuantity: _quantity,
                          perfumeVariant: _selectedPerfume,
                          paymentMethod: _selectedMethod,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                err == null
                                    ? 'Pesanan berhasil dibuat! Lanjut ke menu Pembayaran.'
                                    : 'Gagal: $err',
                              ),
                              backgroundColor: err == null
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Konfirmasi & Buat Pesanan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // FUNGSI BOTTOM SHEET ALUR: PEMBAYARAN
  // ==========================================
  void _openPaymentSheet(
    BuildContext context,
    OrderProvider provider,
    String? customerId,
  ) {
    String _selectedVendor = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StreamBuilder<List<OrderModel>>(
          stream: provider.getAllCustomerOrders(
            customerId ?? '',
          ), // Ubah ke getAllCustomerOrders
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0091BD),
                    ),
                  ),
                ),
              );
            }

            //  TEMPELKAN KODE INI SEBAGAI GANTINYA:
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Belum ada riwayat transaksi untuk kalkulasi laporan.',
                  ),
                ),
              );
            }

            final allOrders = snapshot.data!;
            int totalBiaya = 0;
            int totalTransaksi = 0;

            // Menghitung data laporan hanya dari cucian yang sudah selesai diproses & diambil
            for (var order in allOrders) {
              if (order.status == 'Selesai') {
                totalBiaya += order.totalPrice;
                totalTransaksi++;
              }
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Bulan Ini',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0091BD),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Card Ringkasan Statistik Dinamis
                  Row(
                    children: [
                      // Box Total Pendapatan / Pengeluaran User
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9C0A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFF9C0A)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Biaya',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp $totalBiaya', // Menggunakan variabel looping yang kita buat sebelumnya
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
                      const SizedBox(width: 12),

                      // Box Total Transaksi Jasa Laundry
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0091BD).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF0091BD)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Cucian',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$totalTransaksi Transaksi', // Menggunakan variabel looping
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
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Grafik Penggunaan Jasa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0091BD),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Wadah Visualisasi Grafik Kontainer (Placeholder)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Data grafik siap dipetakan dari $totalTransaksi transaksi.',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ); // StatefulBuilder <--- Gunakan koma atau titik koma tergantung posisi
          }, // Akhir dari builder: (context, snapshot)
        ); // StreamBuilder
      }, // Akhir dari builder milik showModalBottomSheet
    ); // Akhir dari showModalBottomSheet
  } // Akhir dari void _openOrderSheet
} // Akhir dari class _CustomerDashboardState
