import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admin/main_page_admin.dart'; 
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

  // State untuk menyembunyikan atau melihat ketikan password (fitur mata toggle)
  bool _obscurePassword = true;

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
      backgroundColor: Colors.white, // Latar belakang dominan putih bersih
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Menggunakan SingleChildScrollView agar tidak error overflow saat keyboard HP muncul
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🟢 LOGO UTAMA: Menggunakan file gambar asli dari folder assets
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20), // Membuat sudut logo sedikit tumpul halus
                      child: Image.asset(
                        'assets/App_Logo_MyLaundry.jpg',
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        // Jika gambar gagal dimuat/salah nama, sistem otomatis mengembalikan ikon fallback biar tidak crash
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.local_laundry_service_rounded,
                            size: 90,
                            color: Color(0xFF0091BD),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Judul Aplikasi
                  const Text(
                    'MyLaundry',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0091BD),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Digitalisasi Laundry Rumahan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14, 
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Kotak Input Email dengan Gaya OutlineInputBorder Modern
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'masukkan email Anda',
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF0091BD)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0091BD), width: 2),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Email tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 18),

                  // Kotak Input Password Modern dengan Fitur Show/Hide Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword, 
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'masukkan password Anda',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF0091BD)),
                      // Tombol ikon mata di ujung kanan untuk melihat/menyembunyikan password
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0091BD), width: 2),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Password tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 30),

                  // Tombol Masuk / Login
                  authProvider.isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: CircularProgressIndicator(color: Color(0xFF0091BD)),
                          ),
                        ) 
                      : SizedBox(
                          height: 52, // Menentukan tinggi tombol agar terlihat solid
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0091BD), // Warna tombol biru utama
                              foregroundColor: Colors.white, // Warna tulisan putih
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), // Sudut melengkung modern senada dengan input
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                String? error = await authProvider.loginUser(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );

                                if (error != null) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(error),
                                        backgroundColor: Colors.red.shade600,
                                      ),
                                    );
                                  }
                                } else {
                                  if (authProvider.userModel?.role == 'admin') {
                                    if (context.mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const MainPageAdmin(), 
                                        ),
                                      );
                                    }
                                  } else {
                                    if (context.mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const CustomerMainNav(),
                                        ), 
                                      );
                                    }
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
                        ),
                  const SizedBox(height: 20),

                  // Tautan Teks untuk Pindah ke Halaman Daftar Akun (Warna Oranye)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF9C0A),
                    ),
                    child: const Text(
                      'Belum punya akun? Daftar di sini',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}