import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk menangkap input nama, email, dan password
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Kunci form untuk validasi input
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Membersihkan semua controller dari memori HP saat halaman ditutup
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang dominan putih
      appBar: AppBar(
        title: const Text('Daftar Akun Baru', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Mengubah tombol panah kembali menjadi hitam
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // Menggunakan SingleChildScrollView agar layar bisa dikesampingkan/di-scroll saat keyboard HP muncul
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Judul Halaman
                const Text(
                  'Buat Akun Customer',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0091BD)),
                ),
                const Text(
                  'Silakan lengkapi data di bawah ini untuk memulai.', 
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                
                // Input Nama Lengkap
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap', 
                    prefixIcon: Icon(Icons.person_outline, color: Color(0xFF0091BD)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                
                // Input Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email', 
                    prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF0091BD)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Email tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                
                // Input Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password', 
                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF0091BD)),
                  ),
                  // Validasi minimal password demi keamanan akun di Firebase Auth
                  validator: (value) => value!.length < 6 ? 'Password minimal harus 6 karakter' : null,
                ),
                const SizedBox(height: 30),
                
                // Tombol Daftar Sekarang
                authProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0091BD), // Warna biru utama
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Memanggil fungsi register dari AuthProvider
                            String? error = await authProvider.registerCustomer(
                              _nameController.text.trim(),
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                            
                            if (error != null) {
                              // Jika gagal mendaftar (misal email sudah terpakai), munculkan error
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                            } else {
                              // Jika sukses, beri tahu user lalu kembali ke halaman login
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Registrasi Berhasil! Silakan masuk dengan akun Anda.')),
                              );
                              Navigator.pop(context); // Menutup halaman register, kembali ke login_screen
                            }
                          }
                        },
                        child: const Text('Daftar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}