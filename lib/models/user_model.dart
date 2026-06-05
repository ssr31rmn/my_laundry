class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String profilePicture; 

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    // TAMBAHKAN BARIS INI (Beri nilai default teks kosong agar tidak merusak data lama):
    this.profilePicture = '', 
  });

  // Jika kamu menggunakan factory dari Firestore, sesuaikan juga bagian mapping-nya:
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      // TAMBAHKAN BARIS INI:
      profilePicture: map['profilePicture'] ?? '', 
    );
  }

  // Jika ada fungsi toMap() untuk menyimpan ke Firebase, tambahkan juga:
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      // TAMBAHKAN BARIS INI:
      'profilePicture': profilePicture, 
    };
  }
}