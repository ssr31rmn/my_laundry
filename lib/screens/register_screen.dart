import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk menangkap input data pendaftaran teks
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); // 🟢 Tambahan baru
  final _addressController = TextEditingController(); // 🟢 Tambahan baru
  final _passwordController = TextEditingController();
  
  // Kunci form untuk validasi input
  final _formKey = GlobalKey<FormState>();

  // State untuk melihat/menyembunyikan password mata toggle
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Membersihkan semua controller dari memori HP saat halaman ditutup
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose(); // 🟢 Tambahan baru
    _addressController.dispose(); // 🟢 Tambahan baru
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  // Judul Halaman
                  const Text(
                    'Buat Akun Customer',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0091BD)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Silakan lengkapi data di bawah ini untuk memulai.', 
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  
                  // 1. Input Nama Lengkap
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap', 
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF0091BD)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0091BD), width: 2)),
                    ),
                    validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 18),
                  
                  // 2. Input Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email', 
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF0091BD)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0091BD), width: 2)),
                    ),
                    validator: (value) => value!.isEmpty ? 'Email tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 18),

                  // 3. 🟢 Input Nomor Telepon/WA Baru
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon / WhatsApp', 
                      hintText: 'Contoh: 0856xxxxxx',
                      prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF0091BD)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0091BD), width: 2)),
                    ),
                    validator: (value) => value!.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 18),

                  // 4. 🟢 Input Alamat Lengkap Rumah Baru
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2, // Memberikan ruang ketik lebih besar agar alamat panjang muat nyaman
                    decoration: InputDecoration(
                      labelText: 'Alamat Rumah Lengkap', 
                      hintText: 'Nama jalan, nomor rumah, RT/RW, kecamatan',
                      prefixIcon: const Icon(Icons.home_work_outlined, color: Color(0xFF0091BD)),
                      alignLabelWithHint: true, // Menyeimbangkan posisi label teks di atas saat maxLines > 1
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0091BD), width: 2)),
                    ),
                    validator: (value) => value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 18),
                  
                  // 5. Input Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password', 
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0091BD)),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0091BD), width: 2)),
                    ),
                    // Validasi minimal password demi keamanan akun di Firebase Auth
                    validator: (value) => value!.length < 6 ? 'Password minimal harus 6 karakter' : null,
                  ),
                  const SizedBox(height: 32),
                  
                  // Tombol Daftar Sekarang
                  authProvider.isLoading
                      ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: Color(0xFF0091BD))))
                      : SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0091BD), // Warna biru utama
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // 🟢 Mengirimkan data nama, email, password, No.HP, dan Alamat ke fungsi AuthProvider
                                String? error = await authProvider.registerCustomer(
                                  _nameController.text.trim(),
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                  phone: _phoneController.text.trim(),       // Tambahkan parameter bernama ini jika dibutuhkan
                                  address: _addressController.text.trim(),   // Tambahkan parameter bernama ini jika dibutuhkan
                                );
                                
                                if (error != null) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error), backgroundColor: Colors.red.shade600)
                                    );
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Registrasi Berhasil! Silakan masuk dengan akun Anda.')),
                                    );
                                    Navigator.pop(context); // Menutup halaman register, kembali ke login_screen
                                  }
                                }
                              }
                            },
                            child: const Text('Daftar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}