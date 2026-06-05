import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

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
}
