import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;
  List<OrderModel> _customerOrders = [];

  bool get isLoading => _isLoading;
  List<OrderModel> get customerOrders => _customerOrders;

  // Daftar Harga Layanan per Kg / per Satuan
  final Map<String, int> _priceList = {
    'Kiloan Regular (3 Hari)': 6000,
    'Kiloan Kilat (1 Hari)': 10000,
    'Satuan Bedcover': 25000,
    'Satuan Sepatu': 30000,
  };

  Map<String, int> get priceList => _priceList;

  // ==========================================
  // 1. FUNGSI MEMBUAT PESANAN BARU (CUSTOMER)
  // ==========================================
  Future<String?> createOrder({
    required String customerId,
    required String customerName,
    required String packageType,
    required double weightOrQuantity,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Hitung total harga otomatis: (Harga Paket x Jumlah/Berat)
      int pricePerUnit = _priceList[packageType] ?? 0;
      int calculatedTotalPrice = (pricePerUnit * weightOrQuantity).round();

      // Membuat dokumen baru kosong di Firestore untuk mendapatkan ID unik otomatis
      DocumentReference docRef = _db.collection('orders').doc();

      // Menyusun data pesanan berdasarkan Model yang sudah dibuat kemarin
      OrderModel newOrder = OrderModel(
        orderId: docRef.id,
        customerId: customerId,
        customerName: customerName,
        packageType: packageType,
        weightOrQuantity: weightOrQuantity,
        totalPrice: calculatedTotalPrice,
        paymentMethod: paymentMethod,
        status: 'Antrean', // Status awal saat order baru dibuat
        createdAt: DateTime.now(),
      );

      // Simpan data objek ke dalam koleksi 'orders' di Firestore
      await docRef.set(newOrder.toMap());

      _isLoading = false;
      notifyListeners();
      return null; // Sukses, tidak ada error
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  // ==========================================
  // 2. FUNGSI MENGAMBIL RIWAYAT PESANAN CUSTOMER (REAL-TIME)
  // ==========================================
  // Fungsi ini menggunakan Stream agar ketika status diubah oleh admin,
  // halaman customer otomatis berubah sendiri tanpa perlu di-refresh manual.
  Stream<List<OrderModel>> getOrdersByCustomer(String customerId) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy(
          'createdAt',
          descending: true,
        ) // <--- PASTIKAN BARIS INI ADA LAGI
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return OrderModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // ==========================================
  // 3. FUNGSI MENGAMBIL SEMUA PESANAN MASUK (ADMIN)
  // ==========================================
  // Mengambil semua data pesanan dari seluruh customer tanpa filter customerId
  Stream<List<OrderModel>> getAllOrders() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return OrderModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // ==========================================
  // 4. FUNGSI UPDATE STATUS PESANAN (ADMIN)
  // ==========================================
  // Digunakan admin untuk mengubah status laundry (Antrean -> Dicuci -> Disetrika -> Selesai)
  Future<String?> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _db.collection('orders').doc(orderId).update({'status': newStatus});
      return null; // Sukses
    } catch (e) {
      return e.toString(); // Mengembalikan pesan jika gagal
    }
  }

  Stream<List<OrderModel>> getCustomerOrdersStream(String uid) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
