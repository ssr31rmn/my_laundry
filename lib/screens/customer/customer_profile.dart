import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_laundry/screens/login_screen.dart'; // Pastikan paket ini ada di pubspec.yaml

class CustomerAkun extends StatefulWidget {
  const CustomerAkun({super.key});

  @override
  State<CustomerAkun> createState() => _CustomerAkunState();
}

class _CustomerAkunState extends State<CustomerAkun> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controller untuk input teks form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // State untuk menyimpan string gambar Base64 yang baru dipilih (jika ada)
  String? _base64ImageStr; 
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Fungsi untuk memicu kamera/galeri smartphone menggunakan Image Picker
  Future<void> _pickImage(StateSetter modalState) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500, // Batasi resolusi agar string Base64 tidak terlalu raksasa
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        // Konversi file gambar mentah menjadi Bytes, lalu ubah ke String Base64
        Uint8List imageBytes = await pickedFile.readAsBytes();
        String base64String = base64Encode(imageBytes);

        // Update state lokal dan state di dalam bottom sheet
        setState(() {
          _base64ImageStr = base64String;
        });
        modalState(() {
          _base64ImageStr = base64String;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  // Fungsi helper untuk merender foto profil (Mendukung Base64 maupun URL Network)
  Widget _renderProfileImage(String dbPhotoData) {
    // Jika data foto kosong
    if (dbPhotoData.isEmpty) {
      return const Icon(Icons.person_rounded, size: 60, color: Colors.grey);
    }
    
    // Jika data berformat Base64 string (Ciri khasnya tidak diawali http)
    if (!dbPhotoData.startsWith('http')) {
      try {
        return ClipOval(
          child: Image.memory(
            base64Decode(dbPhotoData),
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.broken_image_rounded, size: 60, color: Colors.grey),
          ),
        );
      } catch (e) {
        return const Icon(Icons.person_rounded, size: 60, color: Colors.grey);
      }
    }

    // Fallback jika ternyata berbentuk URL internet biasa
    return ClipOval(
      child: Image.network(
        dbPhotoData,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => 
            const Icon(Icons.person_rounded, size: 60, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Akun Saya', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0091BD),
        elevation: 0,
      ),
      body: currentUser == null
          ? const Center(child: Text('Pengguna tidak ditemukan.'))
          : StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('users').doc(currentUser.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Gagal memuat data profil.'));
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                String name = userData['name'] ?? 'Tanpa Nama';
                String email = userData['email'] ?? currentUser.email ?? '-';
                String phone = userData['phone'] ?? '';
                String address = userData['address'] ?? '';
                String profilePic = userData['profilePicture'] ?? '';

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // KARTU UTAMA ATAS
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade200,
                              child: _renderProfileImage(profilePic),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              name,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            Text(email, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                            const SizedBox(height: 16),
                            
                            OutlinedButton.icon(
                              onPressed: () {
                                // Reset penampung lokal foto sebelum membuka edit panel
                                _base64ImageStr = profilePic; 
                                _showEditProfileBottomSheet(context, userData, currentUser.uid);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF0091BD), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              icon: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF0091BD)),
                              label: const Text('Edit Profil', style: TextStyle(color: Color(0xFF0091BD), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // PANEL INFORMASI DETAIL
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Informasi Pribadi',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0091BD)),
                                ),
                                const Divider(height: 24, thickness: 1),
                                _buildInfoTile(Icons.person_outline_rounded, 'Nama Lengkap', name, false),
                                _buildInfoTile(Icons.email_rounded, 'Email Anda (Permanen)', email, false),
                                _buildInfoTile(
                                  Icons.phone_android_rounded, 
                                  'Nomor Telepon', 
                                  phone.isEmpty ? 'Belum diatur (Klik Edit Profil)' : phone,
                                  phone.isEmpty
                                ),
                                _buildInfoTile(
                                  Icons.location_on_outlined, 
                                  'Alamat Pengiriman Laundry', 
                                  address.isEmpty ? 'Belum diatur (Klik Edit Profil)' : address,
                                  address.isEmpty
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // TOMBOL KELUAR
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
  onPressed: () async {
    // 1. Proses keluar dari Firebase Auth
    await _auth.signOut();
    
    // 2. Navigasi kembali ke halaman Login (menggunakan pushAndRemoveUntil agar tidak bisa di-back)
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(), // 🟢 Pastikan nama class Login kamu sudah sesuai (misal: LoginScreen)
        ),
        (Route<dynamic> route) => false, // Menghapus semua tumpukan history page sebelumnya
      );
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFF9800),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
  ),
  icon: const Icon(Icons.logout_rounded, color: Colors.white),
  label: const Text(
    'Keluar dari Akun', 
    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
  ),
)
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value, bool isWarning) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: const Color(0xFF0091BD)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w600, 
                    color: isWarning ? Colors.red.shade400 : Colors.black87,
                    fontStyle: isWarning ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FORM EDIT PROFIL DENGAN FITUR PILIH GAMBAR DARI GALERI HP
  void _showEditProfileBottomSheet(BuildContext context, Map<String, dynamic> data, String uid) {
    _nameController.text = data['name'] ?? '';
    _phoneController.text = data['phone'] ?? '';
    _addressController.text = data['address'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        // Menggunakan StatefulBuilder agar perubahan foto lokal langsung merender ulang isi modal
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24, left: 24, right: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Edit Profil Akun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0091BD))),
                    const SizedBox(height: 20),
                    
                    // 📸 KLIK AVATAR INI UNTUK MEMBUKA GALERI HP ASLI
                    GestureDetector(
                      onTap: () => _pickImage(setModalState),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade100,
                            child: _renderProfileImage(_base64ImageStr ?? ''),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Color(0xFF0091BD), shape: BoxShape.circle),
                            child: const Icon(Icons.add_a_photo_rounded, size: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Ketuk foto untuk ganti dari galeri', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Nomor Telepon/WA', prefixIcon: Icon(Icons.phone)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Alamat Rumah Lengkap', prefixIcon: Icon(Icons.home_work_rounded)),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0091BD),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (_nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong!')));
                            return;
                          }

                          // Menyimpan data final, termasuk konversi Base64 foto ke Firestore
                          await _firestore.collection('users').doc(uid).update({
                            'name': _nameController.text.trim(),
                            'phone': _phoneController.text.trim(),
                            'address': _addressController.text.trim(),
                            'profilePicture': _base64ImageStr ?? '',
                          });

                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}