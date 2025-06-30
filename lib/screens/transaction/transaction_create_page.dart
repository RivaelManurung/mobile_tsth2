import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/transaction_controller.dart';

// Kelas untuk halaman pembuatan transaksi baru
class TransactionCreatePage extends StatefulWidget {
  const TransactionCreatePage({super.key});

  @override
  _TransactionCreatePageState createState() => _TransactionCreatePageState();
}

class _TransactionCreatePageState extends State<TransactionCreatePage> {
  // Controller untuk kolom pencarian
  final TextEditingController _searchTextController = TextEditingController();
  // FocusNode untuk mengelola fokus pada kolom pencarian
  final FocusNode _searchFocusNode = FocusNode();

  // Deklarasi controller untuk mengelola logika transaksi, diinisialisasi di initState
  late final TransactionController _controller;

  @override
  void initState() {
    super.initState();
    try {
      // Mengambil instance TransactionController menggunakan GetX
      _controller = Get.find<TransactionController>();
      print('TransactionController berhasil diinisialisasi');
    } catch (e, stackTrace) {
      // Menangani error jika controller gagal diinisialisasi
      print('Gagal menginisialisasi TransactionController: $e');
      print(stackTrace);
      // Menampilkan snackbar untuk notifikasi error setelah build selesai
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Error', 'Gagal menginisialisasi controller: $e',
            snackPosition: SnackPosition.BOTTOM);
      });
      return; // Keluar dari initState jika controller tidak ditemukan
    }

    // Menyinkronkan teks awal dari TextEditingController dengan searchQuery di controller
    _searchTextController.text = _controller.searchQuery.value;

    // Mendengarkan perubahan pada TextEditingController lokal untuk memperbarui searchQuery
    _searchTextController.addListener(() {
      if (_searchTextController.text != _controller.searchQuery.value) {
        _controller.searchQuery.value = _searchTextController.text;
        print(
            'TextController mendeteksi perubahan: teks=${_searchTextController.text}');
      }
    });

    // Mendengarkan perubahan pada searchController di TransactionController
    _controller.searchController.addListener(() {
      if (_searchTextController.text != _controller.searchController.text) {
        _searchTextController.text = _controller.searchController.text;
        // Mengatur posisi kursor ke akhir teks setelah pembaruan
        _searchTextController.selection = TextSelection.fromPosition(
          TextPosition(offset: _searchTextController.text.length),
        );
        print(
            'Teks diperbarui dari controller: ${_controller.searchController.text}');
      }
    });

    // Mendengarkan perubahan fokus pada kolom pencarian
    _searchFocusNode.addListener(() {
      print(
          'Search FocusNode: hasFocus=${_searchFocusNode.hasFocus}, hasPrimaryFocus=${_searchFocusNode.hasPrimaryFocus}');
      if (_searchFocusNode.hasFocus) {
        print('Kolom pencarian mendapat fokus');
      } else {
        print('Kolom pencarian kehilangan fokus');
      }
    });
  }

  @override
  void dispose() {
    // Membersihkan TextEditingController dan FocusNode untuk mencegah kebocoran memori
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    // Tidak perlu dispose _controller karena dikelola oleh GetX
    super.dispose();
  }

  // Menentukan warna berdasarkan tipe transaksi
  Color _getTransactionTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'barang masuk':
        return const Color(0xFF4CAF50);
      case 'peminjaman':
        return const Color(0xFFFFC107);
      case 'barang keluar':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF6F767E);
    }
  }

  // Mendapatkan nama tipe transaksi berdasarkan ID
  String _getTransactionTypeName(int? typeId) {
    if (typeId == null || typeId == 0) return 'Pilih Tipe';
    final type = _controller.transactionTypes
        .firstWhereOrNull((t) => t.id == typeId)
        ?.name;
    return type ?? 'Tidak Diketahui';
  }

  @override
  Widget build(BuildContext context) {
    // Memeriksa apakah controller telah diinisialisasi
    try {
      _controller;
    } catch (e) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error: Controller belum diinisialisasi. Silakan restart aplikasi.',
            style: const TextStyle(color: Colors.red, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Menentukan apakah layar kecil berdasarkan lebar perangkat
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    // Membangun tampilan utama dengan Scaffold
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Mengizinkan penyesuaian saat keyboard muncul
      backgroundColor: const Color(0xFFF8FAFF),
      body: GestureDetector(
        onTap: () {
          // Menghilangkan fokus dari kolom pencarian saat mengetuk area luar
          if (_searchFocusNode.hasFocus) {
            FocusScope.of(context).unfocus();
            print('Mengetuk luar, menghilangkan fokus kolom pencarian');
          }
        },
        behavior: HitTestBehavior.opaque,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(), // Mengatur perilaku scroll
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          slivers: [
            _buildAppBar(isSmallScreen), // Membuat AppBar
            _buildAddTransactionView(
                isSmallScreen), // Membuat tampilan form transaksi
          ],
        ),
      ),
    );
  }

  // Membuat AppBar dengan efek gradien dan animasi / header
  SliverAppBar _buildAppBar(bool isSmallScreen) {
    return SliverAppBar(
      expandedHeight: isSmallScreen ? 120 : 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Get.back(),
          tooltip: 'Kembali',
        ).animate().fadeIn(delay: 300.ms).scale(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5A67D8), Color(0xFF4C51BF)],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Buat Transaksi Baru',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(1, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tambahkan transaksi baru dengan mudah',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Membuat tampilan utama untuk form pembuatan transaksi
  SliverToBoxAdapter _buildAddTransactionView(bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF4CAF50),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Buat Transaksi Baru',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 22 : 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1D1F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFF6F767E),
              thickness: 1,
              height: 24,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Cari barang berdasarkan nama atau kode barcode.',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 15,
                  color: const Color(0xFF6F767E),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Material(
              color: Colors.white,
              elevation: 2,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchSection(isSmallScreen), // Bagian pencarian
                    const SizedBox(height: 24),
                    _buildItemsSection(
                        isSmallScreen: isSmallScreen), // Daftar barang
                    const SizedBox(height: 24),
                    _buildSubmitSection(isSmallScreen), // Tombol submit
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }

  // Membuat bagian pencarian barang
  Widget _buildSearchSection(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300] ?? Colors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Cari Barang',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchField(isSmallScreen), // Kolom pencarian
          const SizedBox(height: 16),
          _buildTransactionTypeDropdown(
              isSmallScreen), // Dropdown tipe transaksi
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child:
                    _buildManualCheckButton(isSmallScreen), // Tombol cek manual
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScanButton(isSmallScreen), // Tombol pindai barcode
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchResults(isSmallScreen), // Hasil pencarian
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  // Membuat kolom pencarian
  Widget _buildSearchField(bool isSmallScreen) {
    return Obx(
      () => TextFormField(
        controller: _searchTextController,
        focusNode: _searchFocusNode,
        autofocus: false,
        decoration: InputDecoration(
          labelText: 'Cari Nama Barang atau Kode Barcode',
          labelStyle: TextStyle(
            color: const Color(0xFF6F767E),
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 14 : 15,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _controller.searchQuery.value.isEmpty
                  ? Colors.grey.withOpacity(0.5)
                  : const Color(0xFF4CAF50),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF4CAF50),
              width: 1.5,
            ),
          ),
          suffixIcon: _controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                  onPressed: () {
                    try {
                      _searchTextController.clear();
                      _controller.searchController.clear();
                      _controller.searchQuery.value = '';
                      _controller.searchResults.clear();
                      _searchFocusNode.unfocus();
                      print(
                          'Tombol hapus ditekan, teks dihapus dan fokus dihilangkan');
                    } catch (e, stackTrace) {
                      print('Gagal saat menghapus teks: $e');
                      print(stackTrace);
                      Get.snackbar('Error', 'Gagal menghapus pencarian: $e');
                    }
                  },
                )
              : const SizedBox.shrink(),
          prefixIcon: Icon(
            Icons.search,
            color: _controller.searchQuery.value.isNotEmpty
                ? const Color(0xFF4CAF50)
                : const Color(0xFF6F767E),
            size: 22,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        style: TextStyle(
          fontSize: isSmallScreen ? 15 : 16,
          color: const Color(0xFF1A1D1F),
        ),
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.text,
        onTap: () {
          print('Kolom teks ditekan, meminta fokus');
          _searchFocusNode.requestFocus();
        },
        onFieldSubmitted: (value) {
          try {
            print('Kolom teks disubmit: nilai=$value');
            if (value.isNotEmpty) {
              _controller.searchItems(value);
              _searchFocusNode.unfocus();
              print('Pencarian disubmit dan fokus dihilangkan');
            }
          } catch (e, stackTrace) {
            print('Gagal saat submit pencarian: $e');
            print(stackTrace);
            Get.snackbar('Error', 'Gagal melakukan pencarian: $e');
          }
        },
      ),
    );
  }

  // Membuat dropdown untuk memilih tipe transaksi
  Widget _buildTransactionTypeDropdown(bool isSmallScreen) {
    return Obx(
      () => DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: 'Tipe Transaksi',
          hintText: 'Pilih Tipe Transaksi',
          labelStyle: TextStyle(
            color: const Color(0xFF6F767E),
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 14 : 15,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _controller.selectedTransactionTypeId.value == 0
                  ? Colors.grey.withOpacity(0.5)
                  : const Color(0xFF4CAF50),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF4CAF50),
              width: 1.5,
            ),
          ),
          prefixIcon: const Icon(
            Icons.swap_horiz_rounded,
            color: Color(0xFF4CAF50),
            size: 22,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        value: _controller.selectedTransactionTypeId.value == 0
            ? null
            : _controller.selectedTransactionTypeId.value,
        items: _controller.transactionTypes
            .map((type) => DropdownMenuItem(
                  value: type.id,
                  child: Text(type.name ?? 'Tidak Diketahui'),
                ))
            .toList(),
        onChanged: (value) {
          try {
            if (value != null) {
              _controller.selectedTransactionTypeId.value = value;
              _searchFocusNode.unfocus();
              print('Dropdown diubah, menghilangkan fokus kolom pencarian');
            }
          } catch (e, stackTrace) {
            print('Gagal saat mengubah dropdown: $e');
            print(stackTrace);
            Get.snackbar('Error', 'Gagal memilih tipe transaksi: $e');
          }
        },
        validator: (value) =>
            value == null ? 'Tipe Transaksi wajib dipilih' : null,
        style: TextStyle(
          fontSize: isSmallScreen ? 15 : 16,
          color: const Color(0xFF1A1D1F),
        ),
        dropdownColor: Colors.white,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color(0xFF4CAF50),
          size: 24,
        ),
      ),
    );
  }

  // Membuat tombol untuk cek manual barcode
  Widget _buildManualCheckButton(bool isSmallScreen) {
    return Obx(() => ElevatedButton(
          onPressed: _controller.isLoading.value ||
                  _controller.searchQuery.value.isEmpty
              ? null
              : () {
                  try {
                    _controller
                        .checkManualBarcode(_controller.searchQuery.value);
                    _searchFocusNode.unfocus();
                    print('Tombol cek manual ditekan, menghilangkan fokus');
                  } catch (e, stackTrace) {
                    print('Gagal saat cek manual: $e');
                    print(stackTrace);
                    Get.snackbar('Error', 'Gagal memeriksa barcode: $e');
                  }
                },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFF4CAF50),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: _controller.isLoading.value ||
                      _controller.searchQuery.value.isEmpty
                  ? Colors.grey[400]
                  : const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _controller.isLoading.value ? 'MEMPROSES...' : 'TAMBAH BARANG',
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ));
  }

  // Membuat tombol untuk memindai barcode
  Widget _buildScanButton(bool isSmallScreen) {
    return Obx(() => ElevatedButton(
          onPressed: _controller.isLoading.value ||
                  !_controller.isScanningAllowed.value
              ? null
              : () {
                  try {
                    _controller.scanBarcode();
                    _searchFocusNode.unfocus();
                    print('Tombol pindai ditekan, menghilangkan fokus');
                  } catch (e, stackTrace) {
                    print('Gagal saat memindai barcode: $e');
                    print(stackTrace);
                    Get.snackbar('Error', 'Gagal memindai barcode: $e');
                  }
                },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFF2196F3),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: _controller.isLoading.value ||
                      !_controller.isScanningAllowed.value
                  ? Colors.grey[400]
                  : const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _controller.isLoading.value ? 'MEMPROSES...' : 'PINDAI BARCODE',
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ));
  }

  // Membuat daftar hasil pencarian
  Widget _buildSearchResults(bool isSmallScreen) {
    return Obx(() => _controller.searchResults.isEmpty
        ? const SizedBox.shrink()
        : Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.grey[300] ?? Colors.grey, width: 1),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: _controller.searchResults.length,
              itemBuilder: (context, index) {
                final item = _controller.searchResults[index];
                return ListTile(
                  title: Text(
                    item['barang_nama']?.toString() ?? 'Tidak Diketahui',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Kode: ${item['barang_kode']?.toString() ?? 'Tidak Diketahui'}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: const Color(0xFF6F767E),
                    ),
                  ),
                  onTap: () {
                    try {
                      _controller.addSearchResultToScannedItems(item);
                      _searchTextController.clear();
                      _controller.searchController.clear();
                      _controller.searchQuery.value = '';
                      _controller.searchResults.clear();
                      _searchFocusNode.unfocus();
                      print('Hasil pencarian ditekan, menghilangkan fokus');
                    } catch (e, stackTrace) {
                      print('Gagal saat menambah barang: $e');
                      print(stackTrace);
                      Get.snackbar('Error', 'Gagal menambah barang: $e');
                    }
                  },
                );
              },
            ),
          ));
  }

  // Membuat bagian daftar barang yang dipindai
  Widget _buildItemsSection({required bool isSmallScreen}) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300] ?? Colors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Daftar Barang (${_controller.scannedItems.length})',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Obx(() {
                  final typeName = _getTransactionTypeName(
                      _controller.selectedTransactionTypeId.value);
                  final typeColor = _getTransactionTypeColor(typeName);
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: typeColor, width: 1),
                    ),
                    child: Text(
                      typeName,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: typeColor,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Expanded(
            child: Obx(() => _controller.scannedItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum Ada Barang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6F767E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cari atau pindai barang untuk ditambahkan',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : _buildItemsList(isSmallScreen)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  // Membuat daftar barang yang dipindai
  Widget _buildItemsList(bool isSmallScreen) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _controller.scannedItems.length,
      itemBuilder: (context, index) {
        final item = _controller.scannedItems[index];
        return _buildItemCard(index, item, isSmallScreen);
      },
    );
  }

  // Membuat kartu untuk setiap barang yang dipindai
  Widget _buildItemCard(
      int index, Map<String, dynamic> item, bool isSmallScreen) {
    final barcode = item['barang_kode']?.toString() ??
        'unknown_${item['barang_id'] ?? index}';
    return Dismissible(
      key: ValueKey(barcode),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      onDismissed: (_) {
        try {
          _controller.removeScannedItem(index);
          _searchFocusNode.unfocus();
          print('Barang dihapus, menghilangkan fokus');
        } catch (e, stackTrace) {
          print('Gagal menghapus barang: $e');
          print(stackTrace);
          Get.snackbar('Error', 'Gagal menghapus barang: $e');
        }
      },
      child: GestureDetector(
        onTap: () {
          try {
            _showEditItemDialog(index, item, isSmallScreen);
            _searchFocusNode.unfocus();
            print('Kartu barang ditekan, menghilangkan fokus');
          } catch (e, stackTrace) {
            print('Gagal saat mengedit barang: $e');
            print(stackTrace);
            Get.snackbar('Error', 'Gagal mengedit barang: $e');
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: Colors.grey[200] ?? Colors.grey, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['barang_nama']?.toString() ??
                                'Tidak Diketahui',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 15 : 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1D1F),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kode: ${item['barang_kode']?.toString() ?? 'Tidak Diketahui'}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: const Color(0xFF6F767E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Gudang: ${item['gudang_name']?.toString() ?? 'Tidak Diketahui'}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: const Color(0xFF6F767E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildQuantityControls(index, item, isSmallScreen),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (200 + index * 100).ms);
  }

  // Menampilkan dialog untuk mengedit jumlah barang
  void _showEditItemDialog(
      int index, Map<String, dynamic> item, bool isSmallScreen) {
    final quantityController =
        TextEditingController(text: item['quantity'].toString());
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Barang: ${item['barang_nama']?.toString() ?? 'Tidak Diketahui'}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kode: ${item['barang_kode']?.toString() ?? 'Tidak Diketahui'}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6F767E)),
            ),
            const SizedBox(height: 4),
            Text(
              'Gudang: ${item['gudang_name']?.toString() ?? 'Tidak Diketahui'}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6F767E)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Jumlah (${item['satuan']?.toString() ?? 'Unit'})',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              onEditingComplete: () {
                try {
                  final newQty = int.tryParse(quantityController.text) ??
                      item['quantity'] as int;
                  if (newQty > 0) {
                    _controller.updateItemQuantity(index, newQty);
                    Get.back();
                  } else {
                    Get.snackbar(
                        'Peringatan', 'Jumlah harus lebih besar dari 0');
                  }
                  print('Dialog edit disubmit, menutup dialog');
                } catch (e, stackTrace) {
                  print('Gagal saat submit dialog edit: $e');
                  print(stackTrace);
                  Get.snackbar('Error', 'Gagal memperbarui jumlah: $e');
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              print('Dialog edit dibatalkan, menutup dialog');
            },
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF6F767E)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final newQty = int.tryParse(quantityController.text) ??
                    item['quantity'] as int;
                if (newQty > 0) {
                  _controller.updateItemQuantity(index, newQty);
                  Get.back();
                } else {
                  Get.snackbar('Peringatan', 'Jumlah harus lebih besar dari 0');
                }
                print('Dialog edit disimpan, menutup dialog');
              } catch (e, stackTrace) {
                print('Gagal saat menyimpan dialog edit: $e');
                print(stackTrace);
                Get.snackbar('Error', 'Gagal menyimpan jumlah: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Simpan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Membuat kontrol untuk mengatur jumlah barang
  Widget _buildQuantityControls(
      int index, Map<String, dynamic> item, bool isSmallScreen) {
    final quantity = item['quantity'] as int? ?? 1;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200] ?? Colors.grey, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              size: 20,
              color: Color(0xFF4CAF50),
            ),
            onPressed: () {
              try {
                final newQty = quantity - 1;
                if (newQty > 0) {
                  _controller.updateItemQuantity(index, newQty);
                  _searchFocusNode.unfocus();
                  print('Jumlah dikurangi, menghilangkan fokus');
                } else {
                  Get.snackbar('Peringatan', 'Jumlah harus lebih besar dari 0');
                }
              } catch (e, stackTrace) {
                print('Gagal mengurangi jumlah: $e');
                print(stackTrace);
                Get.snackbar('Error', 'Gagal mengurangi jumlah: $e');
              }
            },
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity ${item['satuan']?.toString() ?? 'Unit'}',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1D1F),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              size: 20,
              color: Color(0xFF4CAF50),
            ),
            onPressed: () {
              try {
                final newQty = quantity + 1;
                _controller.updateItemQuantity(index, newQty);
                _searchFocusNode.unfocus();
                print('Jumlah ditambah, menghilangkan fokus');
              } catch (e, stackTrace) {
                print('Gagal menambah jumlah: $e');
                print(stackTrace);
                Get.snackbar('Error', 'Gagal menambah jumlah: $e');
              }
            },
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // Membuat bagian untuk tombol submit transaksi
  Widget _buildSubmitSection(bool isSmallScreen) {
    return Obx(() {
      final isButtonEnabled =
          _controller.selectedTransactionTypeId.value != 0 &&
              _controller.scannedItems.isNotEmpty &&
              !_controller.isLoading.value;
      final typeName =
          _getTransactionTypeName(_controller.selectedTransactionTypeId.value);
      final typeColor = _getTransactionTypeColor(typeName);

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: typeColor, width: 1),
            ),
            child: Text(
              'Tipe Transaksi: $typeName',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: typeColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isButtonEnabled
                ? () {
                    try {
                      _searchFocusNode.unfocus();
                      print('Tombol submit ditekan, menghilangkan fokus');
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: const Text(
                            'Konfirmasi',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          content: Text(
                            'Apakah Anda yakin ingin menyimpan transaksi $typeName ini?',
                            style: const TextStyle(
                                fontSize: 15, color: Color(0xFF6F767E)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                                print(
                                    'Dialog submit dibatalkan, menutup dialog');
                              },
                              child: const Text(
                                'Batal',
                                style: TextStyle(color: Color(0xFF6F767E)),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                try {
                                  Get.back();
                                  _controller.submitTransaction();
                                  print(
                                      'Dialog submit dikonfirmasi, memulai penyimpanan transaksi');
                                } catch (e, stackTrace) {
                                  print('Gagal menyimpan transaksi: $e');
                                  print(stackTrace);
                                  Get.snackbar(
                                      'Error', 'Gagal menyimpan transaksi: $e');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Ya, Simpan',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    } catch (e, stackTrace) {
                      print('Gagal membuka dialog submit: $e');
                      print(stackTrace);
                      Get.snackbar('Error', 'Gagal membuka dialog submit: $e');
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor:
                  isButtonEnabled ? const Color(0xFF4CAF50) : Colors.grey,
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_controller.isLoading.value) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else ...[
                  const Icon(
                    Icons.save,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  _controller.isLoading.value
                      ? 'MEMPROSES...'
                      : 'SIMPAN TRANSAKSI',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(delay: 400.ms).scale(
            begin:
                isButtonEnabled ? const Offset(0.98, 0.98) : const Offset(1, 1),
            end:
                isButtonEnabled ? const Offset(1, 1) : const Offset(0.98, 0.98),
            duration: 300.ms,
            curve: Curves.easeInOut,
          );
    });
  }
}
