import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String customerId;
  final String customerName;
  final String packageType; // Contoh: "Kiloan Biasa", "Kiloan Kilat", "Satuan Bedcover"
  final double weightOrQuantity; // Berat dalam Kg atau jumlah satuan
  final int totalPrice;
  final String paymentMethod; // Contoh: "Simulasi E-Wallet (Dana/Gopay)"
  final String status; // "Antrean", "Dicuci", "Disetrika", "Selesai"
  final DateTime createdAt;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.packageType,
    required this.weightOrQuantity,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  // Mengubah data dari Firestore (Map) menjadi Objek Dart agar bisa dibaca Flutter
  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      packageType: map['packageType'] ?? '',
      weightOrQuantity: (map['weightOrQuantity'] ?? 0.0).toDouble(),
      totalPrice: map['totalPrice'] ?? 0,
      paymentMethod: map['paymentMethod'] ?? '',
      status: map['status'] ?? 'Antrean',
      createdAt: (map['createdAt'] != null) 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  // Mengubah Objek Dart menjadi Map sebelum disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'packageType': packageType,
      'weightOrQuantity': weightOrQuantity,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt,
    };
  }
}