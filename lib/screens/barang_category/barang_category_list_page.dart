import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/barang_category_controller.dart';
import 'package:inventory_tsth2/controller/Auth/auth_controller.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class BarangCategoryListPage extends StatelessWidget {
  BarangCategoryListPage({super.key});

  final BarangCategoryController _controller = Get.put(BarangCategoryController());
  final AuthController _authController = Get.find<AuthController>();
  final RefreshController _refreshController = RefreshController();
  final RxnInt _selectedCategoryId = RxnInt();

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return WillPopScope(
      onWillPop: () async {
        if (_selectedCategoryId.value != null) {
          _selectedCategoryId.value = null;
          _controller.selectedBarangCategory.value = null;
          return false;
        }
        Get.offAllNamed(RoutesName.dashboard);
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: SmartRefresher(
          controller: _refreshController,
          onRefresh: _refreshData,
          enablePullDown: _selectedCategoryId.value == null,
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
                if (_selectedCategoryId.value == null) {
                  return _buildDaftarView(context, isSmallScreen);
                } else {
                  return _buildDetailView(context, _selectedCategoryId.value!, isSmallScreen);
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
            if (_selectedCategoryId.value != null) {
              _selectedCategoryId.value = null;
              _controller.selectedBarangCategory.value = null;
            } else {
              Get.offAllNamed(RoutesName.dashboard);
            }
          },
          tooltip: 'Kembali',
        ).animate().fadeIn(delay: 300.ms).scale(),
      ),
      actions: [
        if (_selectedCategoryId.value == null)
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
              colors: [Color(0xFF6A82FB), Color(0xFF4C60DB)],
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
                      const Icon(
                        Icons.category,
                        color: Colors.white,
                        size: 28,
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Manajemen Kategori Barang',
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
                    'Lihat daftar kategori barang Anda',
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
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: 16,
        ),
        child: Obx(() {
          if (_controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF4E6AFF)),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: isSmallScreen ? 40 : 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _controller.errorMessage.value.contains('No token found')
                        ? 'Sesi Anda telah berakhir. Silakan masuk kembali.'
                        : _controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: const Color(0xFF1A1D1F),
                    ),
                  ),
                  if (_controller.errorMessage.value.contains('No token found'))
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4E6AFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () => Get.offAllNamed(RoutesName.login),
                        child: Text(
                          'Ke Halaman Masuk',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms, duration: 400.ms);
          }
          if (_controller.barangCategoryList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada kategori ditemukan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
                  'Daftar Kategori',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 17 : 19,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D1F),
                  ),
                ),
              ),
              ..._controller.barangCategoryList.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                return GestureDetector(
                  onTap: () {
                    _selectedCategoryId.value = category.id;
                    _controller.getBarangCategoryById(category.id);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF4E6AFF).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Semantics(
                        label: 'Kategori ${category.name}',
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF4E6AFF).withOpacity(0.1),
                              radius: 24,
                              child: Text(
                                category.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF4E6AFF),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A1D1F),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category.slug ?? 'Tidak ada slug',
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
                  ),
                ).animate().fadeIn(delay: (200 + index * 100).ms).slideY(
                      begin: 0.2,
                      duration: 400.ms,
                    );
              }).toList(),
            ],
          );
        }),
      ),
    );
  }

  SliverToBoxAdapter _buildDetailView(BuildContext context, int categoryId, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF4E6AFF)),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: isSmallScreen ? 40 : 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _controller.errorMessage.value.contains('No token found')
                      ? 'Sesi Anda telah berakhir. Silakan masuk kembali.'
                      : _controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: const Color(0xFF1A1D1F),
                  ),
                ),
                if (_controller.errorMessage.value.contains('No token found'))
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E6AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () => Get.offAllNamed(RoutesName.login),
                      child: Text(
                        'Ke Halaman Masuk',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms, duration: 400.ms);
        }
        final category = _controller.selectedBarangCategory.value;
        if (category == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Kategori tidak ditemukan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms, duration: 400.ms);
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6A82FB), Color(0xFF4C60DB)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      radius: 30,
                      child: Text(
                        category.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
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
                            category.name,
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
                            'Detail Kategori Barang',
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
                    _buildDetailRow(
                      label: 'Nama Kategori',
                      value: category.name,
                      isSmallScreen: isSmallScreen,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      label: 'Slug',
                      value: category.slug ?? 'Tidak ada slug',
                      isSmallScreen: isSmallScreen,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      label: 'Status',
                      value: category.deletedAt == null ? 'Aktif' : 'Dihapus',
                      isSmallScreen: isSmallScreen,
                      valueColor: category.deletedAt == null ? Colors.green : Colors.red,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      label: 'Dibuat Pada',
                      value: category.createdAt?.toString() ?? '-',
                      isSmallScreen: isSmallScreen,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      label: 'Diperbarui Pada',
                      value: category.updatedAt?.toString() ?? '-',
                      isSmallScreen: isSmallScreen,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
            ],
          ),
        );
      }),
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

  Future<void> _refreshData() async {
    try {
      await _controller.fetchAllBarangCategory();
      _refreshController.refreshCompleted();
      Get.snackbar(
        'Berhasil',
        'Daftar kategori diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      _refreshController.refreshFailed();
      Get.snackbar(
        'Gagal',
        'Gagal memperbarui daftar kategori',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
}