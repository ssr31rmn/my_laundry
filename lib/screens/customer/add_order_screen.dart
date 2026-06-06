import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  String? _selectedPackage;
  String _selectedPayment = 'Simulasi E-Wallet (Dana/Gopay)';
  int _calculatedTotal = 0;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  // Fungsi internal untuk menghitung total harga secara real-time saat diketik
  void _updateTotalPrice(String weightText, OrderProvider orderProvider) {
    if (weightText.isEmpty || _selectedPackage == null) {
      setState(() {
        _calculatedTotal = 0;
      });
      return;
    }

    double? weight = double.tryParse(weightText);
    int pricePerUnit = orderProvider.priceList[_selectedPackage] ?? 0;

    if (weight != null) {
      setState(() {
        _calculatedTotal = (pricePerUnit * weight).round();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    // Ambil daftar paket yang tersedia dari OrderProvider
    List<String> packages = orderProvider.priceList.keys.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Buat Pesanan Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0091BD),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Formulir Pesanan Laundry',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0091BD),
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Dropdown Pilihan Paket
                DropdownButtonFormField<String>(
                  value: _selectedPackage,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Jenis Paket',
                    prefixIcon: Icon(
                      Icons.local_laundry_service,
                      color: Color(0xFF0091BD),
                    ),
                  ),
                  items: packages.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        '$value (Rp ${orderProvider.priceList[value]}/unit)',
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPackage = newValue;
                    });
                    _updateTotalPrice(_weightController.text, orderProvider);
                  },
                  validator: (value) =>
                      value == null ? 'Silakan pilih jenis paket' : null,
                ),
                const SizedBox(height: 16),

                // 2. Input Berat atau Jumlah Satuan
                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Berat (Kg) / Jumlah Satuan',
                    prefixIcon: Icon(
                      Icons.scale_outlined,
                      color: Color(0xFF0091BD),
                    ),
                    hintText: 'Contoh: 3.5 atau 2',
                  ),
                  onChanged: (text) => _updateTotalPrice(text, orderProvider),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Jumlah tidak boleh kosong';
                    if (double.tryParse(value) == null)
                      return 'Masukkan angka yang valid';
                    if (double.parse(value) <= 0)
                      return 'Jumlah harus lebih dari 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 3. Dropdown Metode Pembayaran
                DropdownButtonFormField<String>(
                  value: _selectedPayment,
                  decoration: const InputDecoration(
                    labelText: 'Metode Pembayaran',
                    prefixIcon: Icon(
                      Icons.payment_rounded,
                      color: Color(0xFF0091BD),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Simulasi E-Wallet (Dana/Gopay)',
                      child: Text('Simulasi E-Wallet (Dana/Gopay)'),
                    ),
                    DropdownMenuItem(
                      value: 'Tunai / Cash saat Antar',
                      child: Text('Tunai / Cash saat Antar'),
                    ),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPayment = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 30),

                // 4. Kotak Informasi Total Harga (Warna Aksen Oranye)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9C0A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFF9C0A),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp $_calculatedTotal',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF9C0A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 5. Tombol Kirim Pesanan
                orderProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0091BD),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Kirim pesanan ke Firebase lewat OrderProvider
                            // KODE PERBAIKAN (Ganti bagian ini):
                            String? error = await orderProvider.createOrder(
                              customerId: authProvider.userModel!.uid,
                              customerName: authProvider.userModel!.name,
                              packageType: _selectedPackage!.split(
                                ' ',
                              )[0], // Mengambil kata depan saja, misal 'Kiloan' atau 'Satuan'
                              itemDetail: _selectedPackage!
                                  .replaceFirst(
                                    _selectedPackage!.split(' ')[0],
                                    '',
                                  )
                                  .trim(), // Mengambil sisa teksnya, misal 'Regular (3 Hari)' atau 'Bedcover'
                              weightOrQuantity: double.parse(
                                _weightController.text,
                              ),
                              perfumeVariant:
                                  'Reguler / Standar', // Nilai default karena input belum ada di Form UI
                              paymentMethod: _selectedPayment,
                            );

                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal membuat pesanan: $error',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pesanan berhasil dibuat!'),
                                ),
                              );
                              Navigator.pop(
                                context,
                              ); // Kembali ke dashboard customer
                            }
                          }
                        },
                        child: const Text(
                          'Kirim Pesanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
