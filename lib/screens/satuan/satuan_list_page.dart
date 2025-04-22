import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/Auth/auth_controller.dart';
import 'package:inventory_tsth2/controller/satuan_controller.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/screens/satuan/satuan_form_page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class SatuanListPage extends StatelessWidget {
  SatuanListPage({super.key});

  final SatuanController _controller = Get.put(SatuanController());
  final AuthController _authController = Get.find<AuthController>();
  final RefreshController _refreshController = RefreshController();

  // State untuk melacak satuan yang dipilih untuk tampilan detail
  final RxnInt _selectedSatuanId = RxnInt();

  @override
  Widget build(BuildContext context) {
    _controller.resetErrorForListPage();
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _refreshData,
        enablePullDown: _selectedSatuanId.value == null,
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
              if (_selectedSatuanId.value == null) {
                return _buildDaftarView(context, isSmallScreen);
              } else {
                return _buildDetailView(context, _selectedSatuanId.value!, isSmallScreen);
              }
            }),
          ],
        ),
      ),
      floatingActionButton: Obx(() => _selectedSatuanId.value == null
          ? Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4E6AFF),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    _controller.clearForm();
                    Get.to(() => SatuanFormPage(isEdit: false));
                  },
                  label: const Text('Tambah Satuan'),
                  icon: const Icon(Icons.add),
                  backgroundColor: const Color(0xFF4E6AFF),
                  elevation: 0,
                  highlightElevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  extendedPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  splashColor: Colors.white.withOpacity(0.3),
                  foregroundColor: Colors.white,
                  extendedTextStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms),
              ),
            )
          : const SizedBox.shrink()),
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
          onPressed: () => Get.back(),
          tooltip: 'Kembali',
        ).animate().fadeIn(delay: 300.ms).scale(),
      ),
      actions: [
        if (_selectedSatuanId.value == null)
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
                        Icons.inventory_2,
                        color: Colors.white,
                        size: 28,
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Manajemen Satuan',
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
                    'Kelola satuan Anda dengan mudah',
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller.searchController,
                decoration: InputDecoration(
                  hintText: 'Cari satuan...',
                  hintStyle: const TextStyle(color: Color(0xFF6F767E)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF4E6AFF)),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1D1F)),
                onChanged: (value) => _controller.filterSatuan(),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
          ),
          Obx(() {
            if (_controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF4E6AFF)),
                ),
              ).animate().fadeIn(delay: 200.ms);
            }
            if (_controller.listErrorMessage.value.isNotEmpty) {
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
                      _controller.listErrorMessage.value.contains('No token found')
                          ? 'Sesi Anda telah berakhir. Silakan masuk kembali.'
                          : _controller.listErrorMessage.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: const Color(0xFF1A1D1F),
                      ),
                    ),
                    if (_controller.listErrorMessage.value.contains('No token found'))
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
            if (_controller.filteredSatuan.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada satuan ditemukan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambah satuan baru untuk memulai',
                      style: TextStyle(
                        fontSize: 14,
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
                  Padding(
                    padding: EdgeInsets.only(left: isSmallScreen ? 4 : 8, bottom: 8),
                    child: Text(
                      'Daftar Satuan',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 17 : 19,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1D1F),
                      ),
                    ),
                  ),
                  ..._controller.filteredSatuan.asMap().entries.map((entry) {
                    final index = entry.key;
                    final satuan = entry.value;
                    return GestureDetector(
                      onTap: () {
                        _selectedSatuanId.value = satuan.id;
                        _controller.getSatuanById(satuan.id);
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
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Semantics(
                            label: 'Satuan ${satuan.name}',
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      const Color(0xFF4E6AFF).withOpacity(0.1),
                                  radius: 24,
                                  child: Text(
                                    satuan.name.substring(0, 1).toUpperCase(),
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
                                        satuan.name,
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 16 : 18,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1A1D1F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        satuan.description ?? 'Tidak ada deskripsi',
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
              ),
            );
          }),
          const SizedBox(height: 80), // Prevent FAB overlap
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildDetailView(BuildContext context, int satuanId, bool isSmallScreen) {
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
        final satuan = _controller.selectedSatuan.value;
        if (satuan == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Satuan tidak ditemukan',
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
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF4E6AFF).withOpacity(0.1),
                            radius: 28,
                            child: Text(
                              satuan.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF4E6AFF),
                                fontSize: 24,
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
                                  satuan.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1D1F),
                                    fontSize: isSmallScreen ? 18 : 20,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  satuan.description ?? 'Tidak ada deskripsi',
                                  style: TextStyle(
                                    color: const Color(0xFF6F767E),
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: satuan.deletedAt == null
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          satuan.deletedAt == null ? 'Aktif' : 'Dihapus',
                          style: TextStyle(
                            color: satuan.deletedAt == null ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      ).animate().scale(duration: 300.ms),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 24),
              _buildTombolAksi(
                icon: Icons.edit,
                label: 'Ubah Satuan',
                color: const Color(0xFF4E6AFF),
                onPressed: () {
                  _controller.nameController.text = satuan.name;
                  _controller.descriptionController.text = satuan.description ?? '';
                  Get.to(() => SatuanFormPage(isEdit: true, satuanId: satuan.id));
                },
                isSmallScreen: isSmallScreen,
              ),
              if (satuan.deletedAt == null)
                _buildTombolAksi(
                  icon: Icons.delete,
                  label: 'Hapus Satuan',
                  color: Colors.red,
                  onPressed: () => _tampilkanKonfirmasiHapus(context, satuan.id),
                  isSmallScreen: isSmallScreen,
                ),
              if (satuan.deletedAt != null)
                _buildTombolAksi(
                  icon: Icons.restore,
                  label: 'Pulihkan Satuan',
                  color: Colors.green,
                  onPressed: () => _tampilkanKonfirmasiPulihkan(context, satuan.id),
                  isSmallScreen: isSmallScreen,
                ),
              if (satuan.deletedAt != null)
                _buildTombolAksi(
                  icon: Icons.delete_forever,
                  label: 'Hapus Permanen',
                  color: Colors.red[900]!,
                  onPressed: () => _tampilkanKonfirmasiHapusPermanen(context, satuan.id),
                  isSmallScreen: isSmallScreen,
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTombolAksi({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.all(4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white;
            }
            return Colors.white;
          }),
        ),
        onPressed: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: isSmallScreen ? 20 : 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 0.3, end: 0, duration: 400.ms);
  }

  void _tampilkanKonfirmasiHapus(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Hapus Satuan'),
        content: const Text('Apakah Anda yakin ingin menghapus satuan ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF6F767E)),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _controller.deleteSatuan(id);
              Get.back();
              if (_controller.errorMessage.value.isEmpty) {
                _selectedSatuanId.value = null;
                _controller.selectedSatuan.value = null;
                _controller.resetErrorForListPage();
                Get.snackbar(
                  'Berhasil',
                  'Satuan berhasil dihapus',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              } else {
                Get.snackbar(
                  'Gagal',
                  _controller.errorMessage.value,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _tampilkanKonfirmasiPulihkan(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Pulihkan Satuan'),
        content: const Text('Apakah Anda yakin ingin memulihkan satuan ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF6F767E)),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _controller.restoreSatuan(id);
              Get.back();
              if (_controller.errorMessage.value.isEmpty) {
                _controller.getSatuanById(id);
                Get.snackbar(
                  'Berhasil',
                  'Satuan berhasil dipulihkan',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              } else {
                Get.snackbar(
                  'Gagal',
                  _controller.errorMessage.value,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              }
            },
            child: const Text(
              'Pulihkan',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _tampilkanKonfirmasiHapusPermanen(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Hapus Satuan Secara Permanen'),
        content: const Text(
            'Tindakan ini tidak dapat dibatalkan. Apakah Anda yakin ingin menghapus satuan ini secara permanen?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF6F767E)),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _controller.forceDeleteSatuan(id);
              Get.back();
              if (_controller.errorMessage.value.isEmpty) {
                _selectedSatuanId.value = null;
                _controller.selectedSatuan.value = null;
                _controller.resetErrorForListPage();
                Get.snackbar(
                  'Berhasil',
                  'Satuan berhasil dihapus secara permanen',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              } else {
                Get.snackbar(
                  'Gagal',
                  _controller.errorMessage.value,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              }
            },
            child: const Text(
              'Hapus Permanen',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    try {
      _controller.resetErrorForListPage();
      await _controller.fetchAllSatuan();
      _refreshController.refreshCompleted();
      Get.snackbar(
        'Berhasil',
        'Daftar satuan diperbarui',
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
        'Gagal memperbarui daftar satuan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
}
