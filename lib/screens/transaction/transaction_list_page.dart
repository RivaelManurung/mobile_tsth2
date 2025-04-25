import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/transaction_model.dart';
import 'package:inventory_tsth2/controller/transaction_controller.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class TransactionListPage extends StatelessWidget {
  TransactionListPage({super.key});

  final TransactionController _controller = Get.put(TransactionController());
  final RefreshController _refreshController = RefreshController();
  final RxnInt _selectedTransactionId = RxnInt();
  final RxBool _isAddingTransaction = false.obs;
  final ValueNotifier<bool> _isSearchNotEmpty = ValueNotifier<bool>(false);
  final TextEditingController _barcodeTextController = TextEditingController();

  // Fungsi untuk menentukan warna berdasarkan tipe transaksi
  Color _getTransactionTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'barang masuk':
        return const Color(0xFF4CAF50); // Hijau
      case 'peminjaman':
        return const Color(0xFFFFC107); // Kuning
      case 'barang keluar':
        return const Color(0xFFF44336); // Merah
      default:
        return const Color(0xFF6F767E); // Abu-abu
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

  // Format tanggal dengan penanganan error
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Tanggal Tidak Diketahui';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return 'Format Tanggal Salah';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    _controller.searchController.addListener(() {
      _isSearchNotEmpty.value = _controller.searchController.text.isNotEmpty;
    });

    return WillPopScope(
      onWillPop: () async {
        if (_selectedTransactionId.value != null) {
          _selectedTransactionId.value = null;
          return false;
        }
        if (_isAddingTransaction.value) {
          _isAddingTransaction.value = false;
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: SmartRefresher(
          controller: _refreshController,
          onRefresh: _refreshData,
          enablePullDown: _selectedTransactionId.value == null &&
              !_isAddingTransaction.value,
          header: const ClassicHeader(
            idleText: 'Tarik untuk memperbarui',
            releaseText: 'Lepas untuk memperbarui',
            refreshingText: 'Memperbarui...',
            completeText: 'Pembaruan selesai',
            failedText: 'Pembaruan gagal',
            textStyle: TextStyle(color: Color(0xFF6F767E)),
          ),
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              _buildAppBar(isSmallScreen),
              Obx(() {
                if (_isAddingTransaction.value) {
                  return _buildAddTransactionView(isSmallScreen);
                } else if (_selectedTransactionId.value != null) {
                  return _buildDetailView(
                      context, _selectedTransactionId.value!, isSmallScreen);
                } else {
                  return _buildDaftarView(context, isSmallScreen);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

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
          onPressed: () {
            if (_selectedTransactionId.value != null) {
              _selectedTransactionId.value = null;
            } else if (_isAddingTransaction.value) {
              _isAddingTransaction.value = false;
            } else {
              Get.back();
            }
          },
          tooltip: 'Kembali',
        ).animate().fadeIn(delay: 300.ms).scale(),
      ),
      actions: [
        if (_selectedTransactionId.value == null && !_isAddingTransaction.value)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
              onPressed: () => _refreshData(),
              tooltip: 'Segarkan Data',
            ).animate().fadeIn(delay: 300.ms).scale(),
          ),
      ],
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
                          'Daftar Transaksi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(1, 1),
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
                    'Pantau dan kelola transaksi Anda',
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

SliverToBoxAdapter _buildDaftarView(BuildContext context, bool isSmallScreen) {
  return SliverToBoxAdapter(
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300] ?? Colors.grey, width: 1),
                  ),
                  child: TextField(
                    controller: _controller.searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari transaksi...',
                      hintStyle: const TextStyle(color: Color(0xFF6F767E)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF5A67D8)),
                      suffixIcon: ValueListenableBuilder<bool>(
                        valueListenable: _isSearchNotEmpty,
                        builder: (context, isNotEmpty, child) {
                          if (isNotEmpty) {
                            return IconButton(
                              icon: const Icon(Icons.clear, color: Color(0xFF5A67D8)),
                              onPressed: () {
                                _controller.searchController.clear();
                                _controller.searchQuery.value = '';
                                _controller.filterTransactions();
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1A1D1F)),
                    onChanged: (value) {
                      _controller.searchQuery.value = value;
                      _controller.filterTransactions();
                    },
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                elevation: 1,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Get.bottomSheet(
                      _buildFilterBottomSheet(),
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      color: Color(0xFF5A67D8),
                      size: 24,
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).scale(),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 8),
          child: GestureDetector(
            onTap: () {
              _isAddingTransaction.value = true;
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF5A67D8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4C51BF), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      SizedBox(width: 12),
                      Text(
                        'Tambah Transaksi Baru',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).scale(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: 16,
          ),
          child: Obx(() {
            if (_controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF5A67D8)),
                ),
              ).animate().fadeIn(delay: 200.ms);
            }
            if (_controller.errorMessage.value.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[300] ?? Colors.grey, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Terjadi Kesalahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF44336),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: const Color(0xFF1A1D1F),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms, duration: 400.ms);
            }
            if (_controller.transactionList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Tidak Ada Transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6F767E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambah transaksi untuk memulai',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms, duration: 400.ms);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: isSmallScreen ? 4 : 8, bottom: 8),
                  child: Text(
                    'Daftar Transaksi',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 17 : 19,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1D1F),
                    ),
                  ),
                ),
                ..._controller.transactionList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final transaction = entry.value;
                  return _buildTransactionCard(transaction, index, isSmallScreen);
                }).toList(),
              ],
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}
  Widget _buildFilterBottomSheet() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Transaksi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1D1F),
                ),
              ),
              IconButton(
                icon:
                    const Icon(Icons.close, color: Color(0xFF6F767E), size: 28),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tipe Transaksi',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (_controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF5A67D8)),
                ),
              );
            }
            if (_controller.transactionTypes.isEmpty) {
              return const Text(
                'Tidak ada tipe transaksi tersedia',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6F767E),
                ),
              );
            }
            return DropdownButtonFormField<int>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              value: _controller.selectedTransactionTypeId.value == 0
                  ? null
                  : _controller.selectedTransactionTypeId.value,
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('Semua Tipe'),
                ),
                ..._controller.transactionTypes.map((type) => DropdownMenuItem(
                      value: type.id,
                      child: Text(type.name ?? 'Tidak Diketahui'),
                    )),
              ],
              onChanged: (value) {
                _controller.selectedTransactionTypeId.value = value ?? 0;
              },
            );
          }),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _controller.transactionTypes.isEmpty
                ? null
                : () {
                    _controller.applyFilter();
                    Get.back();
                  },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: const Color(0xFF5A67D8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Terapkan Filter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                'Tambahkan barang dengan memindai barcode atau masukkan secara manual.',
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
                    _buildScannerSection(isSmallScreen),
                    const SizedBox(height: 24),
                    _buildItemsSection(isSmallScreen: isSmallScreen),
                    const SizedBox(height: 24),
                    _buildSubmitSection(isSmallScreen),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerSection(bool isSmallScreen) {
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
                  'Input Barang',
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
          _buildBarcodeField(isSmallScreen),
          const SizedBox(height: 16),
          _buildTransactionTypeDropdown(isSmallScreen),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildManualCheckButton(isSmallScreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScanButton(isSmallScreen),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildBarcodeField(bool isSmallScreen) {
    final formKey = GlobalKey<FormState>();

    return Obx(() {
      if (_barcodeTextController.text != _controller.scannedBarcode.value) {
        _barcodeTextController.text = _controller.scannedBarcode.value;
      }

      return Form(
        key: formKey,
        child: TextFormField(
          controller: _barcodeTextController,
          decoration: InputDecoration(
            labelText: 'Kode Barcode',
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
                color: _controller.scannedBarcode.value.isEmpty
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
            suffixIcon: _controller.scannedBarcode.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                    onPressed: () {
                      _controller.scannedBarcode.value = '';
                      _controller.quantityController.text = '1';
                      _barcodeTextController.clear();
                    },
                  )
                : null,
            prefixIcon: Icon(
              Icons.qr_code_rounded,
              color: _controller.scannedBarcode.value.isNotEmpty
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
          onChanged: (value) {
            _controller.scannedBarcode.value = value;
          },
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (value) {
            if (value.isNotEmpty) {
              _controller.checkManualBarcode(value);
            } else {
              Get.snackbar(
                'Peringatan',
                'Kode Barcode tidak boleh kosong',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            }
          },
          validator: (value) => value == null || value.isEmpty
              ? 'Kode Barcode wajib diisi'
              : null,
        ),
      );
    });
  }

  Widget _buildTransactionTypeDropdown(bool isSmallScreen) {
    final formKey = GlobalKey<FormState>();

    return Obx(() => Form(
          key: formKey,
          child: DropdownButtonFormField<int>(
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
              if (value != null) {
                _controller.selectedTransactionTypeId.value = value;
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
        ));
  }

  Widget _buildManualCheckButton(bool isSmallScreen) {
    return Obx(() => ElevatedButton(
          onPressed: _controller.isLoading.value ||
                  _controller.scannedBarcode.value.isEmpty
              ? null
              : () => _controller
                  .checkManualBarcode(_controller.scannedBarcode.value),
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
                      _controller.scannedBarcode.value.isEmpty
                  ? Colors.grey[400]
                  : const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _controller.isLoading.value ? 'MEMPROSES...' : 'CEK BARCODE',
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

  Widget _buildScanButton(bool isSmallScreen) {
    return Obx(() => ElevatedButton(
          onPressed:
              _controller.isLoading.value ? null : _controller.scanBarcode,
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
              color: _controller.isLoading.value
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
                          'Pindai atau masukkan kode barang',
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

  Widget _buildItemCard(
      int index, Map<String, dynamic> item, bool isSmallScreen) {
    final barcode = item['barang_kode']?.toString() ?? 'unknown_$index';
    return Dismissible(
      key: Key(barcode),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => _controller.removeScannedItem(index),
      child: GestureDetector(
        onTap: () => _showEditItemDialog(index, item, isSmallScreen),
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
                        Text(
                          item['barang_nama']?.toString() ?? 'Tidak Diketahui',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 15 : 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1D1F),
                          ),
                          overflow: TextOverflow.ellipsis,
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
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF6F767E)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newQty = int.tryParse(quantityController.text) ??
                  item['quantity'] as int;
              _controller.updateItemQuantity(index, newQty);
              Get.back();
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
              final newQty = quantity - 1;
              if (newQty > 0) {
                _controller.updateItemQuantity(index, newQty);
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
              final newQty = quantity + 1;
              _controller.updateItemQuantity(index, newQty);
            },
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

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
                            onPressed: () => Get.back(),
                            child: const Text(
                              'Batal',
                              style: TextStyle(color: Color(0xFF6F767E)),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              _controller.submitTransaction();
                              _isAddingTransaction.value = false;
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

  SliverToBoxAdapter _buildDetailView(
      BuildContext context, int transactionId, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: 16,
        ),
        child: Obx(() {
          Transaction? transaction;
          try {
            transaction = _controller.transactionList
                .firstWhere((t) => t.id == transactionId);
          } catch (e) {
            transaction = null;
          }

          if (transaction == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Transaksi Tidak Ditemukan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6F767E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kembali untuk melihat daftar transaksi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms)
                .scale(delay: 200.ms, duration: 400.ms);
          }

          final formattedDate = _formatDate(transaction.transactionDate);
          final typeColor =
              _getTransactionTypeColor(transaction.transactionType?.name);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A67D8),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  border: Border.all(color: const Color(0xFF4C51BF), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction.transactionType?.name
                                ?.substring(0, 1)
                                .toUpperCase() ??
                            'T',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.transactionCode ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: isSmallScreen ? 20 : 24,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(1, 1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Detail Transaksi',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  border: Border.all(
                      color: Colors.grey[300] ?? Colors.grey, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      label: 'Kode Transaksi',
                      value: transaction.transactionCode ?? 'Unknown',
                      isSmallScreen: isSmallScreen,
                    ),
                    const Divider(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Tipe Transaksi',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1D1F),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: typeColor, width: 1),
                            ),
                            child: Text(
                              transaction.transactionType?.name ??
                                  'Tidak Diketahui',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      label: 'Operator',
                      value: transaction.user?.name ?? 'Tidak Diketahui',
                      isSmallScreen: isSmallScreen,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      label: 'Tanggal',
                      value: formattedDate,
                      isSmallScreen: isSmallScreen,
                    ),
                    const Divider(height: 24),
                    Text(
                      'Daftar Barang',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1D1F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...transaction.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey[200] ?? Colors.grey,
                                  width: 1),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5A67D8)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.barang?.barangNama
                                            ?.substring(0, 1)
                                            .toUpperCase() ??
                                        'B',
                                    style: const TextStyle(
                                      color: Color(0xFF5A67D8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.barang?.barangNama ??
                                            'Tidak Diketahui',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 15 : 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1A1D1F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Kode: ${item.barang?.barangKode ?? 'Tidak Diketahui'}',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 12 : 13,
                                          color: const Color(0xFF6F767E),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Gudang: ${item.gudang?.name ?? 'Tidak Diketahui'}',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 12 : 13,
                                          color: const Color(0xFF6F767E),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5A67D8)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Jumlah: ${item.quantity ?? 0}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF5A67D8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required bool isSmallScreen,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1D1F),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: valueColor ?? const Color(0xFF6F767E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(
      Transaction transaction, int index, bool isSmallScreen) {
    final formattedDate = _formatDate(transaction.transactionDate);
    final typeColor =
        _getTransactionTypeColor(transaction.transactionType?.name);

    return GestureDetector(
      onTap: () {
        _selectedTransactionId.value = transaction.id;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: typeColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: typeColor,
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
                        Text(
                          transaction.transactionCode ?? 'Unknown',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1D1F),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: typeColor, width: 1),
                          ),
                          child: Text(
                            transaction.transactionType?.name ??
                                'Tidak Diketahui',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tanggal: $formattedDate',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: const Color(0xFF6F767E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Operator: ${transaction.user?.name ?? 'Tidak Diketahui'}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: const Color(0xFF6F767E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF6F767E),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (200 + index * 100).ms).slideY(
          begin: 0.2,
          duration: 400.ms,
        );
  }

  Future<void> _refreshData() async {
    try {
      _controller.refreshData();
      _refreshController.refreshCompleted();
      Get.snackbar(
        'Berhasil',
        'Daftar transaksi diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      _refreshController.refreshFailed();
      Get.snackbar(
        'Gagal',
        'Gagal memperbarui daftar transaksi: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
}
