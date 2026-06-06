import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // Wajib ditambahkan di baris paling atas
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class AuthProvider with ChangeNotifier {
  // Hubungan ke layanan Firebase Authentication dan Firestore Database
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _userModel;
  bool _isLoading = false;

  // Getter agar variabel di atas bisa dibaca oleh halaman UI (tampilan)
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  // ==========================================
  // 1. FUNGSI DAFTAR AKUN (REGISTRASI CUSTOMER)
  // ==========================================
  Future<String?> registerCustomer(
    String name,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners(); // Memberitahu UI untuk memunculkan animasi loading

    try {
      // Membuat akun baru di Firebase Authentication (Email & Password)
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Membuat objek data pengguna baru dengan role otomatis "customer"
      UserModel newUser = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        role: 'customer',
      );

      // Menyimpan detail data pengguna ke Firestore Database di koleksi 'users'
      await _db
          .collection('users')
          .doc(credential.user!.uid)
          .set(newUser.toMap());

      _userModel = newUser;
      _isLoading = false;
      notifyListeners(); // Memberitahu UI bahwa loading selesai
      return null; // Mengembalikan null artinya sukses (tidak ada error)
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString(); // Jika gagal, kirim pesan error-nya ke UI
    }
  }

  // ==========================================
  // 2. FUNGSI MASUK AKUN (LOGIN CUSTOMER & ADMIN)
  // ==========================================
  Future<String?> loginUser(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Melakukan proses cek email & password di Firebase Authentication
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mengambil data pengguna dari Firestore Database berdasarkan UID akun
      DocumentSnapshot doc = await _db
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id; // Memastikan UID terisi dari dokumen ID Firestore
        _userModel = UserModel.fromMap(data);
      } else {
        // KHUSUS ADMIN DUMMY:
        // Jika admin@gmail.com login untuk pertama kali, datanya belum ada di Firestore.
        // Maka kita buatkan otomatis data admin-nya di database agar sinkron.
        if (email == 'admin@gmail.com') {
          _userModel = UserModel(
            uid: credential.user!.uid,
            name: 'Admin Laundry',
            email: email,
            role: 'admin', // Set sebagai admin
          );
          await _db
              .collection('users')
              .doc(credential.user!.uid)
              .set(_userModel!.toMap());
        }
      }

      _isLoading = false;
      notifyListeners();
      return null; // Sukses
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString(); // Gagal, kirim pesan error
    }
  }

  // ==========================================
  // 3. FUNGSI KELUAR AKUN (LOGOUT)
  // ==========================================
  Future<void> logout() async {
    await _auth.signOut();
    _userModel = null; // Menghapus data pengguna yang sedang aktif di aplikasi
    notifyListeners();
  }

  // Instance Firebase Storage
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fungsi untuk memilih gambar dari galeri dan langsung mengunggahnya
  Future<String?> uploadProfilePicture() async {
    if (_userModel == null) return null;

    final ImagePicker picker = ImagePicker();
    
    // 1. Pilih gambar dari galeri
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30, // Kompres ke 30% agar ukuran teks Base64 hemat & muat di Firestore
    );

    if (image == null) return null;

    try {
      // 2. Baca file gambar menjadi bytes
      final Uint8List imageBytes = await image.readAsBytes();

      // 3. Ubah bytes gambar menjadi teks String Base64
      String base64String = base64Encode(imageBytes);

      // 4. Update langsung ke Cloud Firestore pada dokumen user yang sama
      await _db.collection('users').doc(_userModel!.uid).update({
        'profilePicture': base64String,
      });

      // 5. Update data lokal di aplikasi
      _userModel = UserModel(
        uid: _userModel!.uid,
        name: _userModel!.name,
        email: _userModel!.email,
        role: _userModel!.role,
        profilePicture: base64String, // Sekarang berisi teks Base64
      );

      notifyListeners();
      return base64String;
    } catch (e) {
      print("Eror Base64: $e");
      return null;
    }
  }
}
