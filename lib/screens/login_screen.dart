import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admin/admin_dashboard.dart';
import 'customer/customer_dashboard.dart';
import 'customer/customer_main_nav.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk menangkap teks yang diketik oleh pengguna
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Kunci penanda form untuk validasi input kosong atau tidak
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Membersihkan controller saat halaman ditutup agar tidak membebani memori HP
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menyambungkan halaman UI dengan logika di AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang dominan putih
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ikon Utama aplikasi (Mesin Cuci) warna Biru
                const Icon(
                  Icons.local_laundry_service_rounded,
                  size: 90,
                  color: Color(0xFF0091BD),
                ),
                const SizedBox(height: 10),

                // Judul Aplikasi
                const Text(
                  'MyLaundry',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0091BD),
                  ),
                ),
                const Text(
                  'Digitalisasi Laundry Rumahan',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Kotak Input Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Color(0xFF0091BD),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Email tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),

                // Kotak Input Password
                TextFormField(
                  controller: _passwordController,
                  obscureText:
                      true, // Menyembunyikan ketikan password menjadi bintang/bulat
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Color(0xFF0091BD),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Password tidak boleh kosong' : null,
                ),
                const SizedBox(height: 24),

                // Tombol Masuk / Login
                authProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      ) // Menampilkan loading berputar jika sedang diproses
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF0091BD,
                          ), // Warna tombol biru
                          foregroundColor: Colors.white, // Warna tulisan putih
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          // Jalankan cek validasi input terlebih dahulu
                          if (_formKey.currentState!.validate()) {
                            String? error = await authProvider.loginUser(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );

                            if (error != null) {
                              // Jika ada error (misal password salah), munculkan pesan di bawah layar
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(error)));
                            } else {
                              // Jika sukses, periksa role-nya untuk mengarahkan halaman
                              if (authProvider.userModel?.role == 'admin') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AdminDashboard(),
                                  ),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CustomerMainNav(),
                                  ), // Arahkan ke Main Nav induk
                                );
                              }
                            }
                          }
                        },
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                const SizedBox(height: 16),

                // Tautan Teks untuk Pindah ke Halaman Daftar Akun (Warna Oranye)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'Belum punya akun? Daftar di sini',
                    style: TextStyle(
                      color: Color(0xFFFF9C0A),
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
