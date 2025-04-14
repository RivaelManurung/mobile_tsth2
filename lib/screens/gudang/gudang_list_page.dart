// lib/screens/gudang/gudang_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/Auth/auth_controller.dart';
import 'package:inventory_tsth2/controller/Gudang/gudang_controller.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/screens/gudang/gudang_form_page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class GudangListPage extends StatelessWidget {
  GudangListPage({super.key});

  final GudangController _controller = Get.put(GudangController());
  final AuthController _authController = Get.find<AuthController>();
  final RefreshController _refreshController = RefreshController();

  final RxnInt _selectedGudangId = RxnInt();

  void _showSnackbar(String title, String message, {required bool isSuccess}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    _controller.resetErrorForListPage();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Obx(() => Text(
              _selectedGudangId.value == null
                  ? 'Manajemen Gudang'
                  : 'Detail Gudang',
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
        leading: Obx(() => _selectedGudangId.value != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0066FF)),
                onPressed: () {
                  _selectedGudangId.value = null;
                  _controller.selectedGudang.value = null;
                  _controller.resetErrorForListPage();
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0066FF)),
                onPressed: () => Get.offNamed(RoutesName
                    .dashboard), // Ganti Get.back() dengan navigasi ke Dashboard
              )),
        actions: [
          if (_selectedGudangId.value == null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF0066FF)),
              onPressed: () => _refreshData(),
            ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _refreshData,
        enablePullDown: _selectedGudangId.value == null,
        header: const ClassicHeader(
          idleText: 'Tarik untuk memperbarui',
          releaseText: 'Lepas untuk memperbarui',
          refreshingText: 'Memperbarui...',
          completeText: 'Pembaruan selesai',
          failedText: 'Pembaruan gagal',
          textStyle: TextStyle(color: Color(0xFF6F767E)),
        ),
        child: Obx(() {
          if (_selectedGudangId.value == null) {
            return _buildDaftarView(context);
          } else {
            return _buildDetailView(context, _selectedGudangId.value!);
          }
        }),
      ),
      floatingActionButton: Obx(() => _selectedGudangId.value == null
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF0066FF),
              onPressed: () async {
                _controller.clearForm();
                final result = await Get.to(() => GudangFormPage());
                if (result != null) {
                  _showSnackbar(
                    result['success'] ? 'Berhasil' : 'Gagal',
                    result['message'],
                    isSuccess: result['success'],
                  );
                  if (result['success']) {
                    await _controller.fetchAllGudang(); // Refresh daftar gudang
                  }
                }
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
                hintText: 'Cari gudang...',
                hintStyle: TextStyle(color: Color(0xFF6F767E)),
                prefixIcon: Icon(Icons.search, color: Color(0xFF6F767E)),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) => _controller.filterGudang(),
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
            if (_controller.filteredGudang.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada gudang ditemukan',
                  style: TextStyle(
                    color: Color(0xFF6F767E),
                    fontSize: 16,
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: _controller.filteredGudang.length,
              itemBuilder: (context, index) {
                final gudang = _controller.filteredGudang[index];
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
                          gudang.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF0066FF),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        gudang.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1D1F),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gudang.description ?? 'Tidak ada deskripsi',
                            style: const TextStyle(color: Color(0xFF6F767E)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tersedia: ${gudang.stokTersedia} | Dipinjam: ${gudang.stokDipinjam} | Maintenance: ${gudang.stokMaintenance}',
                            style: const TextStyle(
                              color: Color(0xFF6F767E),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Color(0xFF6F767E),
                      ),
                      onTap: () {
                        _selectedGudangId.value = gudang.id;
                        _controller.getGudangById(gudang.id);
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

  Widget _buildDetailView(BuildContext context, int gudangId) {
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
      final gudang = _controller.selectedGudang.value;
      if (gudang == null) {
        return const Center(
          child: Text(
            'Gudang tidak ditemukan',
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
            // Header Card dengan Gradien
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFF00B0FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        radius: 30,
                        child: Text(
                          gudang.name.substring(0, 1).toUpperCase(),
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
                              gudang.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gudang.description ?? 'Tidak ada deskripsi',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 16),

            // Informasi Gudang
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
                    // Operator
                    const Text(
                      'Operator',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1D1F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: Color(0xFF0066FF),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _controller.selectedUser.value?.name ??
                                    'Tidak ada operator',
                                style: const TextStyle(
                                  color: Color(0xFF1A1D1F),
                                  fontSize: 14,
                                ),
                              ),
                              if (_controller.selectedUser.value?.email != null)
                                Text(
                                  'Email: ${_controller.selectedUser.value!.email}',
                                  style: const TextStyle(
                                    color: Color(0xFF6F767E),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Stok
                    const Text(
                      'Stok',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1D1F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory,
                          color: Color(0xFF0066FF),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tersedia: ${gudang.stokTersedia}',
                          style: const TextStyle(
                            color: Color(0xFF1A1D1F),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.outbox,
                          color: Color(0xFF0066FF),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dipinjam: ${gudang.stokDipinjam}',
                          style: const TextStyle(
                            color: Color(0xFF1A1D1F),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.build,
                          color: Color(0xFF0066FF),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Maintenance: ${gudang.stokMaintenance}',
                          style: const TextStyle(
                            color: Color(0xFF1A1D1F),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Waktu Pembuatan dan Pembaruan
                    const Text(
                      'Informasi Waktu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1D1F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (gudang.createdAt != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF0066FF),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Dibuat: ${gudang.createdAt!.toLocal().toString().split('.')[0]}',
                            style: const TextStyle(
                              color: Color(0xFF1A1D1F),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    if (gudang.updatedAt != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.update,
                            color: Color(0xFF0066FF),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Diperbarui: ${gudang.updatedAt!.toLocal().toString().split('.')[0]}',
                            style: const TextStyle(
                              color: Color(0xFF1A1D1F),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 24),

            // Tombol Aksi
            _buildTombolAksi(
              icon: Icons.edit,
              label: 'Ubah Gudang',
              color: const Color(0xFF0066FF),
              onPressed: () async {
                _controller.nameController.text = gudang.name;
                _controller.descriptionController.text =
                    gudang.description ?? '';
                final result = await Get.to(
                  () => GudangFormPage(isEdit: true, gudangId: gudang.id),
                );
                if (result != null) {
                  _showSnackbar(
                    result['success'] ? 'Berhasil' : 'Gagal',
                    result['message'],
                    isSuccess: result['success'],
                  );
                  if (result['success']) {
                    await _controller
                        .getGudangById(gudang.id); // Refresh detail gudang
                  }
                }
              },
            ),
            _buildTombolAksi(
              icon: Icons.delete_forever,
              label: 'Hapus Gudang',
              color: Colors.redAccent,
              onPressed: () => _tampilkanKonfirmasiHapus(context, gudang.id),
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
        title: const Text('Hapus Gudang'),
        content: const Text('Apakah Anda yakin ingin menghapus gudang ini?'),
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
              try {
                await _controller.deleteGudang(id);
                Get.back();
                _showSnackbar('Berhasil', 'Gudang berhasil dihapus',
                    isSuccess: true);
                _selectedGudangId.value = null;
                _controller.selectedGudang.value = null;
              } catch (e) {
                Get.back();
                _showSnackbar('Gagal', e.toString(), isSuccess: false);
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

  Future<void> _refreshData() async {
    try {
      await _controller.fetchAllGudang();
      _refreshController.refreshCompleted();
      _showSnackbar('Berhasil', 'Daftar gudang diperbarui', isSuccess: true);
    } catch (e) {
      _refreshController.refreshFailed();
      _showSnackbar('Gagal', 'Gagal memperbarui daftar gudang',
          isSuccess: false);
    }
  }
}
