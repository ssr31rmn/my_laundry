import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_laundry/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  // Pastikan sistem internal Flutter sudah siap sebelum memanggil Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Menghubungkan aplikasi ke Firebase sesuai dengan file firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // TAMBAHKAN BARIS INI DI BAWAH AUTH_PROVIDER:
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyLaundry',
      debugShowCheckedModeBanner: false,
      
      // Pengaturan Tema Warna Aplikasi
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Latar belakang utama putih bersih
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0091BD), // Warna dasar biru utama
          primary: const Color(0xFF0091BD),    // Tombol-tombol utama akan berwarna biru ini
          secondary: const Color(0xFFFF9C0A),  // Warna aksen oranye
        ),
        useMaterial3: true,
        
        // Pengaturan seragam untuk semua kotak input (TextField) di aplikasi
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // Kotak input berwarna putih
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0091BD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey), // Garis abu-abu saat tidak diklik
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0091BD), width: 2), // Garis biru tebal saat diklik
          ),
        ),
      ),
      
      // Halaman pertama yang otomatis terbuka saat aplikasi dinyalakan
      home: const LoginScreen(), 
    );
  }
}