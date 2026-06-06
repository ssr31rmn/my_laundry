import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Daftar Harga Fix Sesuai Jenis Pakaian/Layanan
  final Map<String, int> _priceList = {
    'Kiloan Regular (3 Hari)': 6000,
    'Kiloan Kilat (1 Hari)': 10000,
    'Satuan Bedcover': 25000,
    'Satuan Sepatu': 30000,
    'Satuan Sprei': 15000,
    'Satuan Selimut': 20000,
    'Satuan Jas': 35000,
  };

  Map<String, int> get priceList => _priceList;

  // ==========================================
  // 1. FUNGSI BUAT PESANAN (STATUS: BELUM BAYAR)
  // ==========================================
  Future<String?> createOrder({
    required String customerId,
    required String customerName,
    required String packageType,
    required String itemDetail,
    required double weightOrQuantity,
    required String perfumeVariant,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Menggabungkan kunci untuk mengambil harga dari map _priceList
      String priceKey = packageType == 'Kiloan'
          ? '$packageType $itemDetail'
          : '$packageType $itemDetail';

      int pricePerUnit = _priceList[priceKey] ?? 0;
      int calculatedTotalPrice = (pricePerUnit * weightOrQuantity).round();

      DocumentReference docRef = _db.collection('orders').doc();

      OrderModel newOrder = OrderModel(
        orderId: docRef.id,
        customerId: customerId,
        customerName: customerName,
        packageType: packageType,
        itemDetail: itemDetail,
        weightOrQuantity: weightOrQuantity,
        totalPrice: calculatedTotalPrice,
        perfumeVariant: perfumeVariant,
        paymentMethod: paymentMethod,
        paymentVendor:
            '', // Kosong dulu, diisi saat fungsi pembayaran dijalankan
        status: 'Belum Bayar', // WAJIB dimulai dari Belum Bayar
        createdAt: DateTime.now(),
      );

      await docRef.set(newOrder.toMap());

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  // ==========================================
  // 2. FUNGSI PROSES PEMBAYARAN
  // ==========================================
  Future<String?> processPayment(String orderId, String vendorName) async {
    try {
      // Setelah klik bayar, status diubah ke 'Antrean' menunggu konfirmasi admin
      await _db.collection('orders').doc(orderId).update({
        'paymentVendor': vendorName,
        'status': 'Antrean',
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================================
  // 3. FUNGSI BATALKAN PESANAN (HANYA JIKA BELUM BAYAR)
  // ==========================================
  Future<String?> cancelOrder(String orderId) async {
    try {
      await _db.collection('orders').doc(orderId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================================
  // 4. FUNGSI SELESAI & ARSIPKAN PESANAN BY CUSTOMER
  // ==========================================
  Future<String?> completeOrder(String orderId) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': 'Selesai & Diarsipkan',
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================================
  // 5. STREAM MONITORING STATUS AKTIF (PANTAU PESANAN)
  // ==========================================
  Stream<List<OrderModel>> getActiveCustomerOrders(String uid) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              // Filter agar status 'Selesai & Diarsipkan' tidak ikut terbawa ke halaman pantau
              .where((order) => order.status != 'Selesai & Diarsipkan')
              .toList();
        });
  }

  // ==========================================
  // 6. FUNGSI UPDATE STATUS PESANAN OLEH ADMIN
  // ==========================================
  Future<String?> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _db.collection('orders').doc(orderId).update({'status': newStatus});
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================================
  // 7. STREAM SEMUA PESANAN UNTUK DASHBOARD ADMIN
  // ==========================================
  Stream<List<OrderModel>> getAllOrders() {
    return _db
        .collection('orders')
        .orderBy(
          'createdAt',
          descending: true,
        ) // Menampilkan pesanan terbaru di atas
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
