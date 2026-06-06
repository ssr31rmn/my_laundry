import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String customerId;
  final String customerName;
  final String packageType;      // "Kiloan" atau "Satuan"
  final String itemDetail;        // Jika kiloan: "Biasa"/"Kilat". Jika satuan: "Sprei"/"Selimut"/"Jas"/"Sepatus"/"Bedcover"
  final double weightOrQuantity;
  final int totalPrice;
  final String perfumeVariant;    // "Fresh", "Floral", "Exotic", "Ocean", "Tanpa Parfum"
  final String paymentMethod;     // "Cash", "Transfer Bank", "E-Wallet / QRIS"
  final String paymentVendor;     // Nama Bank (BCA/BNI/dll) atau E-Wallet (DANA/OVO/dll). Kosong jika Cash.
  final String status;            // "Belum Bayar", "Antrean", "Proses", "Selesai", "Selesai & Diarsipkan"
  final DateTime createdAt;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.packageType,
    required this.itemDetail,
    required this.weightOrQuantity,
    required this.totalPrice,
    required this.perfumeVariant,
    required this.paymentMethod,
    required this.paymentVendor,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      packageType: map['packageType'] ?? '',
      itemDetail: map['itemDetail'] ?? '',
      weightOrQuantity: (map['weightOrQuantity'] ?? 0.0).toDouble(),
      totalPrice: map['totalPrice'] ?? 0,
      perfumeVariant: map['perfumeVariant'] ?? 'Tanpa Parfum',
      paymentMethod: map['paymentMethod'] ?? '',
      paymentVendor: map['paymentVendor'] ?? '',
      status: map['status'] ?? 'Belum Bayar',
      createdAt: (map['createdAt'] != null)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'packageType': packageType,
      'itemDetail': itemDetail,
      'weightOrQuantity': weightOrQuantity,
      'totalPrice': totalPrice,
      'perfumeVariant': perfumeVariant,
      'paymentMethod': paymentMethod,
      'paymentVendor': paymentVendor,
      'status': status,
      'createdAt': createdAt,
    };
  }
}