import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCustomer extends StatefulWidget {
  const AdminCustomer({super.key});

  @override
  State<AdminCustomer> createState() => _AdminCustomerState();
}

class _AdminCustomerState extends State<AdminCustomer> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔍 State untuk Fitur Cari
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // 🔠 State untuk Sorting Abjad
  bool _isAscending = true; // true = A-Z, false = Z-A

  // 📄 State untuk Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // ==========================================
          // BAR PENCARIAN & SORTING ABJAD
          // ==========================================
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Input Lapisan Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama customer',
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0091BD)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                                _currentPage = 1; // Reset ke page 1
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0091BD), width: 1.5),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase().trim();
                      _currentPage = 1; // Reset ke page 1 setiap kali mengetik
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Kontrol Pengurutan Abjad
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Urutan Abjad:',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF0091BD)),
                      onPressed: () {
                        setState(() {
                          _isAscending = !_isAscending;
                        });
                      },
                      icon: Icon(_isAscending ? Icons.sort_by_alpha_rounded : Icons.sort_by_alpha_outlined),
                      label: Text(
                        _isAscending ? 'A ke Z (Ascending)' : 'Z ke A (Descending)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // ==========================================
          // STREAM DATA & LOGIKA FILTER/SORT/PAGINATION
          // ==========================================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0091BD)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada data customer.', style: TextStyle(color: Colors.grey)));
                }

                // 1. FILTER BERDASARKAN ROLE & QUERY PENCARIAN NAMA
                final allDocs = snapshot.data!.docs;
                List<Map<String, dynamic>> filteredCustomers = [];

                for (var doc in allDocs) {
                  final data = doc.data() as Map<String, dynamic>;
                  String role = data['role']?.toString().toLowerCase() ?? '';
                  String name = data['name']?.toString().toLowerCase() ?? '';

                  // Validasi: Harus ber-role customer DAN mengandung kata kunci pencarian
                  if (role == 'customer' && name.contains(_searchQuery)) {
                    // Masukkan id dokumen ke dalam map data agar tidak kehilangan reference
                    data['id'] = doc.id; 
                    filteredCustomers.add(data);
                  }
                }

                if (filteredCustomers.isEmpty) {
                  return const Center(
                    child: Text('Customer tidak ditemukan.', style: TextStyle(color: Colors.grey)),
                  );
                }

                // 2. LOGIKA SORTING BERDASARKAN ABJAD NAMA
                filteredCustomers.sort((a, b) {
                  String nameA = (a['name'] ?? '').toString().toLowerCase();
                  String nameB = (b['name'] ?? '').toString().toLowerCase();
                  
                  int compare = nameA.compareTo(nameB);
                  return _isAscending ? compare : -compare;
                });

                // 3. LOGIKA PAGINATION (5 DATA PER HALAMAN)
                int totalItems = filteredCustomers.length;
                int totalPages = (totalItems / _itemsPerPage).ceil();
                if (totalPages == 0) totalPages = 1;

                // Cek berjaga-jaga jika halaman aktif melampaui total halaman baru akibat filter
                if (_currentPage > totalPages) _currentPage = totalPages;

                int startIndex = (_currentPage - 1) * _itemsPerPage;
                int endIndex = startIndex + _itemsPerPage;
                if (endIndex > totalItems) endIndex = totalItems;

                // Potong list data untuk halaman aktif saja
                List<Map<String, dynamic>> paginatedCustomers = 
                    filteredCustomers.sublist(startIndex, endIndex);

                // ==========================================
                // LIST VIEW CUSTOMER HASIL FILTER
                // ==========================================
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: paginatedCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = paginatedCustomers[index];
                          
                          String name = customer['name'] ?? 'Tanpa Nama';
                          String email = customer['email'] ?? 'Tidak ada email';
                          String phone = customer['phone'] ?? '-';
                          String address = customer['address'] ?? 'Alamat belum diatur';
                          String initialLetter = name.isNotEmpty ? name[0].toUpperCase() : 'C';

                          return Card(
                            color: Colors.white,
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200, width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0091BD),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        initialLetter,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(email, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Icon(Icons.phone_android_rounded, size: 14, color: Colors.grey.shade400),
                                            const SizedBox(width: 4),
                                            Text(phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.location_on_rounded, size: 14, color: Colors.grey.shade400),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                address,
                                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ==========================================
                    // FOOTER NAVIGASI HALAMAN (PAGINATION PANEL)
                    // ==========================================
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0091BD),
                              elevation: 0,
                              side: BorderSide(color: _currentPage > 1 ? const Color(0xFF0091BD) : Colors.grey.shade300),
                            ),
                            onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                            child: const Text('Prev'),
                          ),
                          Text(
                            'Halaman $_currentPage dari $totalPages',
                            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0091BD),
                              elevation: 0,
                              side: BorderSide(color: _currentPage < totalPages ? const Color(0xFF0091BD) : Colors.grey.shade300),
                            ),
                            onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}