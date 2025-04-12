import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/BarangCategory/barang_category_controller.dart';
import 'package:inventory_tsth2/controller/Auth/auth_controller.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/screens/barang_category/barang_category_form_page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class BarangCategoryListPage extends StatelessWidget {
  BarangCategoryListPage({super.key});

  final BarangCategoryController _controller =
      Get.put(BarangCategoryController());
  final AuthController _authController = Get.find<AuthController>();
  final RefreshController _refreshController = RefreshController();

  // State untuk melacak kategori yang dipilih untuk tampilan detail
  final RxnInt _selectedCategoryId = RxnInt();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Obx(() => Text(
              _selectedCategoryId.value == null
                  ? 'Manajemen Kategori Barang'
                  : 'Detail Kategori',
              style: const TextStyle(
                color: Color(0xFF1A1D1F),
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            )),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: Obx(() => _selectedCategoryId.value != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0066FF)),
                onPressed: () {
                  _selectedCategoryId.value = null;
                  _controller.selectedBarangCategory.value = null;
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0066FF)),
                onPressed: () => Get.back(),
              )),
        actions: [
          if (_selectedCategoryId.value == null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF0066FF)),
              onPressed: () => _refreshData(),
            ),
        ],
      ),
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
        child: Obx(() {
          if (_selectedCategoryId.value == null) {
            return _buildDaftarView(context);
          } else {
            return _buildDetailView(context, _selectedCategoryId.value!);
          }
        }),
      ),
      floatingActionButton: Obx(() => _selectedCategoryId.value == null
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF0066FF),
              onPressed: () {
                _controller.clearForm();
                Get.to(() => BarangCategoryFormPage(isEdit: true,));
              },
              child: const Icon(Icons.add, color: Colors.white),
              elevation: 4,
            )
          : const SizedBox.shrink()),
    );
  }

  Widget _buildDaftarView(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _controller.searchController,
              decoration: const InputDecoration(
                hintText: 'Cari kategori...',
                hintStyle: TextStyle(color: Color(0xFF6F767E)),
                prefixIcon: Icon(Icons.search, color: Color(0xFF6F767E)),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) => _controller.filterBarangCategory(),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (_controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF0066FF)),
                ),
              );
            }
            if (_controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _controller.errorMessage.value.contains('No token found')
                          ? 'Sesi Anda telah berakhir. Silakan masuk kembali.'
                          : _controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    if (_controller.errorMessage.value
                        .contains('No token found'))
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Get.offAllNamed(RoutesName.login),
                          child: const Text(
                            'Ke Halaman Masuk',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }
            if (_controller.filteredBarangCategory.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada kategori ditemukan',
                  style: TextStyle(
                    color: Color(0xFF6F767E),
                    fontSize: 16,
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: _controller.filteredBarangCategory.length,
              itemBuilder: (context, index) {
                final category = _controller.filteredBarangCategory[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFF0066FF).withOpacity(0.1),
                        radius: 24,
                        child: Text(
                          category.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF0066FF),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1D1F),
                        ),
                      ),
                      subtitle: Text(
                        category.slug ?? 'Tidak ada slug',
                        style: const TextStyle(color: Color(0xFF6F767E)),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Color(0xFF6F767E),
                      ),
                      onTap: () {
                        _selectedCategoryId.value = category.id;
                        _controller.getBarangCategoryById(category.id);
                      },
                    ),
                  ),
                ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.2);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDetailView(BuildContext context, int categoryId) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF0066FF)),
          ),
        );
      }
      if (_controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _controller.errorMessage.value.contains('No token found')
                    ? 'Sesi Anda telah berakhir. Silakan masuk kembali.'
                    : _controller.errorMessage.value,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              if (_controller.errorMessage.value.contains('No token found'))
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Get.offAllNamed(RoutesName.login),
                    child: const Text(
                      'Ke Halaman Masuk',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      }
      final category = _controller.selectedBarangCategory.value;
      if (category == null) {
        return const Center(
          child: Text(
            'Kategori tidak ditemukan',
            style: TextStyle(
              color: Color(0xFF6F767E),
              fontSize: 16,
            ),
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Kategori
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              const Color(0xFF0066FF).withOpacity(0.1),
                          radius: 28,
                          child: Text(
                            category.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF0066FF),
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
                                category.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1D1F),
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.slug ?? 'Tidak ada slug',
                                style: const TextStyle(
                                  color: Color(0xFF6F767E),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Indikator Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: category.deletedAt == null
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category.deletedAt == null ? 'Aktif' : 'Dihapus',
                        style: TextStyle(
                          color: category.deletedAt == null
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // Tombol Aksi
            _buildTombolAksi(
              icon: Icons.edit,
              label: 'Ubah Kategori',
              color: const Color(0xFF0066FF),
              onPressed: () {
                _controller.nameController.text = category.name;
                _controller.slugController.text = category.slug ?? '';
                Get.to(() => BarangCategoryFormPage(
                    isEdit: true, categoryId: category.id));
              },
            ),

            if (category.deletedAt == null)
              _buildTombolAksi(
                icon: Icons.delete,
                label: 'Hapus Kategori',
                color: Colors.red,
                onPressed: () =>
                    _tampilkanKonfirmasiHapus(context, category.id),
              ),

            if (category.deletedAt != null)
              _buildTombolAksi(
                icon: Icons.restore,
                label: 'Pulihkan Kategori',
                color: Colors.green,
                onPressed: () =>
                    _tampilkanKonfirmasiPulihkan(context, category.id),
              ),

            if (category.deletedAt != null)
              _buildTombolAksi(
                icon: Icons.delete_forever,
                label: 'Hapus Permanen',
                color: Colors.red[900]!,
                onPressed: () =>
                    _tampilkanKonfirmasiHapusPermanen(context, category.id),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildTombolAksi({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: onPressed,
      ),
    ).animate().slideY(begin: 0.3, end: 0, duration: 400.ms);
  }

  void _tampilkanKonfirmasiHapus(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Hapus Kategori'),
        content: const Text('Apakah Anda yakin ingin menghapus kategori ini?'),
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
              await _controller.deleteBarangCategory(id);
              Get.back(); // Tutup dialog
              if (_controller.errorMessage.value.isEmpty) {
                _selectedCategoryId.value = null; // Kembali ke daftar
                _controller.selectedBarangCategory.value = null;
                Get.snackbar(
                  'Berhasil',
                  'Kategori berhasil dihapus',
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
        title: const Text('Pulihkan Kategori'),
        content: const Text('Apakah Anda yakin ingin memulihkan kategori ini?'),
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
              await _controller.restoreBarangCategory(id);
              Get.back(); // Tutup dialog
              if (_controller.errorMessage.value.isEmpty) {
                _controller
                    .getBarangCategoryById(id); // Tetap di tampilan detail
                Get.snackbar(
                  'Berhasil',
                  'Kategori berhasil dipulihkan',
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
        title: const Text('Hapus Kategori Secara Permanen'),
        content: const Text(
            'Tindakan ini tidak dapat dibatalkan. Apakah Anda yakin ingin menghapus kategori ini secara permanen?'),
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
              await _controller.forceDeleteBarangCategory(id);
              Get.back(); // Tutup dialog
              if (_controller.errorMessage.value.isEmpty) {
                _selectedCategoryId.value = null; // Kembali ke daftar
                _controller.selectedBarangCategory.value = null;
                Get.snackbar(
                  'Berhasil',
                  'Kategori berhasil dihapus secara permanen',
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
