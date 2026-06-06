import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';

class CustomerProfile extends StatelessWidget {
  const CustomerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;
    final String? profilePicUrl = user?.profilePicture;

    return Scaffold(
      backgroundColor: Colors.white, // 1. WARNA DOMINAN: Putih Bersih
      appBar: AppBar(
        title: const Text(
          'Akun Saya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0091BD), // 2. WARNA PRIMER: Biru Utama
        elevation: 0,
        automaticallyImplyLeading:
            false, // Menghilangkan tombol back karena nempel di navbar bawah
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // ==========================================
            // BAGIAN FOTO PROFIL & CIRI VISUAL UTAMA
            // ==========================================
            // ==========================================
            // BAGIAN FOTO PROFIL & CIRI VISUAL UTAMA
            // ==========================================
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(
                          0xFF0091BD,
                        ), // Border lingkaran Biru Utama
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      // Menggunakan MemoryImage untuk membaca string Base64 yang di-decode kembali ke bytes
                      backgroundImage:
                          profilePicUrl != null && profilePicUrl.isNotEmpty
                          ? MemoryImage(base64Decode(profilePicUrl))
                          : null,
                      child: profilePicUrl == null || profilePicUrl.isEmpty
                          ? Icon(
                              Icons.person_rounded,
                              size: 70,
                              color: Colors.grey.shade400,
                            )
                          : null,
                    ),
                  ),

                  // TOMBOL KAMERA UNTUK UPLOAD FOTO PROFIL
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: () async {
                        // Tampilkan loading singkat / snackbar pemberitahuan proses dimulai
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Membuka galeri...'),
                            duration: Duration(seconds: 1),
                          ),
                        );

                        // Memanggil fungsi upload dari AuthProvider
                        String? uploadedUrl = await authProvider
                            .uploadProfilePicture();

                        if (uploadedUrl != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Foto profil berhasil diperbarui!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Batal memilih foto atau terjadi kesalahan.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0091BD), // Tombol kamera Biru Utama
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nama & Email Pengguna
            Text(
              user?.name ?? 'Nama Pengguna',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'email@laundry.com',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),

            const Divider(thickness: 1, indent: 20, endIndent: 20),

            // ==========================================
            // DETAIL INFORMASI AKUN (LIST MENU)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.badge_rounded,
                    title: 'ID Pengguna',
                    subtitle: user?.uid ?? '-',
                  ),
                  _buildProfileTile(
                    icon: Icons.manage_accounts_rounded,
                    title: 'Peran Akun',
                    subtitle: user?.role ?? 'customer',
                  ),
                  const SizedBox(height: 40),

                  // ==========================================
                  // TOMBOL LOGOUT (AKSEN ORANYE) - VERSI AMAN
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Memanggil fungsi logout dari AuthProvider
                        await authProvider.logout();
                        if (context.mounted) {
                          // Lempar kembali ke halaman Login Screen
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFFF9C0A,
                        ), // 3. WARNA AKSEN: Oranye
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Keluar dari Akun',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ), // Tutup SizedBox
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk membuat list info profil yang rapi
  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF0091BD),
            size: 28,
          ), // Ikon berwarna Biru Utama
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
