class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String phone;          // 🟢 Tambahan baru untuk Nomor Telepon
  final String address;        // 🟢 Tambahan baru untuk Alamat Rumah
  final String profilePicture; 

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',           // 🟢 Diberi default value teks kosong agar akun lama tidak error
    this.address = '',         // 🟢 Diberi default value teks kosong agar akun lama tidak error
    this.profilePicture = '', 
  });

  // Fungsi untuk mengubah Map dari Firestore menjadi Objek UserModel di Flutter
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      phone: map['phone'] ?? '',           // 🟢 Mengambil data phone dari Firestore
      address: map['address'] ?? '',       // 🟢 Mengambil data address dari Firestore
      profilePicture: map['profilePicture'] ?? '', 
    );
  }

  // Fungsi untuk mengubah Objek UserModel menjadi Map sebelum dikirim ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,                     // 🟢 Menyimpan data phone ke Firestore
      'address': address,                 // 🟢 Menyimpan data address ke Firestore
      'profilePicture': profilePicture, 
    };
  }
}