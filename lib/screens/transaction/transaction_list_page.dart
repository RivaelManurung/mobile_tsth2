import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/transaction_model.dart';
import 'package:inventory_tsth2/controller/transaction_controller.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:collection/collection.dart';
import 'transaction_create_page.dart';

class TransactionListPage extends StatelessWidget {
  TransactionListPage({super.key});

  final TransactionController _controller = Get.put(TransactionController());
  final RefreshController _refreshController = RefreshController();
  final RxnInt _selectedTransactionId = RxnInt();
  final ValueNotifier<bool> _isSearchNotEmpty = ValueNotifier<bool>(false);

  // Fungsi untuk menentukan warna berdasarkan tipe transaksi
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

  String _getTransactionTypeName(int? typeId) {
    if (typeId == null || typeId == 0) return 'Pilih Tipe';
    final type = _controller.transactionTypes
        .firstWhereOrNull((t) => t.id == typeId)
        ?.name;
    return type ?? 'Tidak Diketahui';
  }

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
        if (_controller.searchFocusNode.hasFocus) {
          _controller.searchFocusNode.unfocus();
          return false;
        }
        if (_selectedTransactionId.value != null) {
          _selectedTransactionId.value = null;
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
              !_controller.searchFocusNode.hasFocus,
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
                if (_selectedTransactionId.value != null) {
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
            } else {
              Get.back();
            }
          },
          tooltip: 'Kembali',
        ).animate().fadeIn(delay: 300.ms).scale(),
      ),
      actions: [
        if (_selectedTransactionId.value == null)
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

  SliverToBoxAdapter _buildDaftarView(
      BuildContext context, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.grey[300] ?? Colors.grey, width: 1),
                    ),
                    child: TextField(
                      controller: _controller.searchController,
                      focusNode: _controller.searchFocusNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Cari transaksi...',
                        hintStyle: const TextStyle(color: Color(0xFF6F767E)),
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF5A67D8)),
                        suffixIcon: ValueListenableBuilder<bool>(
                          valueListenable: _isSearchNotEmpty,
                          builder: (context, isNotEmpty, child) {
                            if (isNotEmpty) {
                              return IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Color(0xFF5A67D8)),
                                onPressed: () {
                                  _controller.searchController.clear();
                                  _controller.searchQuery.value = '';
                                  _controller.filterTransactions();
                                  _controller.searchFocusNode.requestFocus();
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
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 16),
                      ),
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF1A1D1F)),
                      onTap: () {
                        _controller.searchFocusNode.requestFocus();
                      },
                      onChanged: (value) {
                        _controller.searchQuery.value = value;
                        // Debounce in controller handles filtering
                      },
                      onSubmitted: (value) {
                        _controller.filterTransactions();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 1,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _controller.searchFocusNode.unfocus();
                      Get.bottomSheet(
                        _buildFilterBottomSheet(context),
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24)),
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
                    ).animate().fadeIn(delay: 500.ms).scale(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16, vertical: 8),
            child: GestureDetector(
              onTap: () {
                _controller.searchFocusNode.unfocus();
                Get.to(() => TransactionCreatePage());
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
              print(
                  'Rendering TransactionListPage with ${_controller.filteredTransactionList.length} transactions: ${_controller.filteredTransactionList.map((t) => t.transactionCode).toList()}');
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
                    border: Border.all(
                        color: Colors.grey[300] ?? Colors.grey, width: 1),
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
                )
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .scale(delay: 200.ms, duration: 400.ms);
              }
              if (_controller.filteredTransactionList.isEmpty) {
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
                )
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .scale(delay: 200.ms, duration: 400.ms);
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _controller.filteredTransactionList.length,
                itemBuilder: (context, index) {
                  final transaction =
                      _controller.filteredTransactionList[index];
                  return _buildTransactionCard(
                      transaction, index, isSmallScreen);
                },
              );
            }),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterBottomSheet(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: SingleChildScrollView(
        child: Padding(
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
                    icon: const Icon(Icons.close,
                        color: Color(0xFF6F767E), size: 28),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Tipe Transaksi',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3),
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  value: _controller.selectedTransactionTypeId.value == 0
                      ? null
                      : _controller.selectedTransactionTypeId.value,
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('Semua Tipe'),
                    ),
                    ..._controller.transactionTypes
                        .map((type) => DropdownMenuItem(
                              value: type.id,
                              child: Text(type.name ?? 'Tidak Diketahui'),
                            )),
                  ],
                  onChanged: (value) {
                    _controller.selectedTransactionTypeId.value = value ?? 0;
                  },
                );
              }),
              const SizedBox(height: 16),
              const Text(
                'Rentang Waktu',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3),
              ),
              const SizedBox(height: 10),
              Obx(() => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    value: _controller.selectedDateRange.value,
                    items: [
                      'Semua',
                      'Hari Ini',
                      'Minggu Ini',
                      'Bulan Ini',
                      'Custom'
                    ]
                        .map((range) => DropdownMenuItem(
                              value: range,
                              child: Text(range),
                            ))
                        .toList(),
                    onChanged: (value) {
                      _controller.selectedDateRange.value = value ?? 'Semua';
                      if (value != 'Custom') {
                        _controller.dateStartController.clear();
                        _controller.dateEndController.clear();
                      }
                    },
                  )),
              const SizedBox(height: 16),
              Obx(() => _controller.selectedDateRange.value == 'Custom'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanggal Mulai',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _controller.dateStartController,
                          readOnly: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Pilih tanggal mulai',
                            suffixIcon: const Icon(Icons.calendar_today,
                                color: Color(0xFF5A67D8)),
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              _controller.dateStartController.text =
                                  DateFormat('yyyy-MM-dd').format(picked);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tanggal Selesai',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _controller.dateEndController,
                          readOnly: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Pilih tanggal selesai',
                            suffixIcon: const Icon(Icons.calendar_today,
                                color: Color(0xFF5A67D8)),
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              _controller.dateEndController.text =
                                  DateFormat('yyyy-MM-dd').format(picked);
                            }
                          },
                        ),
                      ],
                    )
                  : const SizedBox.shrink()),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _controller.transactionTypes.isEmpty ||
                        (_controller.selectedDateRange.value == 'Custom' &&
                            (_controller.dateStartController.text.isEmpty ||
                                _controller.dateEndController.text.isEmpty))
                    ? null
                    : () {
                        if (_controller.selectedDateRange.value == 'Custom') {
                          final startDate = DateTime.tryParse(
                              _controller.dateStartController.text);
                          final endDate = DateTime.tryParse(
                              _controller.dateEndController.text);
                          if (startDate == null || endDate == null) {
                            _controller.showErrorSnackbar('Error',
                                'Tanggal mulai atau selesai tidak valid');
                            return;
                          }
                          if (endDate.isBefore(startDate)) {
                            _controller.showErrorSnackbar('Error',
                                'Tanggal selesai tidak boleh sebelum tanggal mulai');
                            return;
                          }
                        }
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
        ),
      ),
    );
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
        _controller.searchFocusNode.unfocus();
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