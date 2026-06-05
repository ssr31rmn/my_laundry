import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'add_order_screen.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // Mengambil data URL foto profil dari database (jika ada)
    final String? profilePicUrl = authProvider.userModel?.profilePicture;

    return Scaffold(
      backgroundColor: Colors.white, // 1. WARNA DOMINAN: Putih Bersih
      appBar: AppBar(
        title: const Text(
          'MyLaundry',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0091BD), // 2. WARNA PRIMER: Biru Utama
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // HEADER SAPAAN PENGGUNA & FOTO PROFIL
            // ==========================================
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Color(0xFF0091BD), // Background header mengikuti AppBar (Biru)
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  // Widget Lingkaran Foto Profil Dinamis
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    // Jika URL foto ada dan tidak kosong, tampilkan gambar internet. Jika kosong, tampilkan ikon default.
                    backgroundImage: profilePicUrl != null && profilePicUrl.isNotEmpty
                        ? NetworkImage(profilePicUrl)
                        : null,
                    child: profilePicUrl == null || profilePicUrl.isEmpty
                        ? const Icon(Icons.person_rounded, size: 35, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${authProvider.userModel?.name ?? "Customer"}!',
                          style: const TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cucian menumpuk? Yuk laundry sekarang!',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==========================================
                  // KARTU AKSEN ORANYE: BANNER PROMO / INFO LAUNDRY
                  // ==========================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // 3. WARNA AKSEN: Oranye Cerah
                      color: const Color(0xFFFF9C0A), 
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9C0A).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PROMO KILAT WEEKEND!',
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Diskon Rp 5.000 untuk paket Kiloan Kilat setiap hari Sabtu & Minggu.',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.local_fire_department_rounded, size: 50, color: Colors.white.withOpacity(0.9)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // ==========================================
                  // MENU LAYANAN UTAMA
                  // ==========================================
                  const Text(
                    'Layanan Utama Kami',
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF0091BD), // Label sub-judul Biru
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tombol Utama Pesan Laundry (Desain Kombinasi Biru dengan detail rapi)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddOrderScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF0091BD).withOpacity(0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade100,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF0091BD), // Ikon Biru Utama
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.local_laundry_service_rounded, color: Colors.white, size: 28),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Buat Pesanan Laundry',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Pilih paket kiloan atau satuan sesuai kebutuhanmu',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF0091BD), size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}