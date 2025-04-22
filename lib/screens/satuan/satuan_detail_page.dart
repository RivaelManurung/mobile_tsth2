import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/satuan_controller.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/screens/satuan/satuan_form_page.dart';

class SatuanDetailPage extends StatelessWidget {
  SatuanDetailPage({super.key});

  final SatuanController _controller = Get.find<SatuanController>();

  @override
  Widget build(BuildContext context) {
    // Safely handle Get.arguments
    final dynamic arguments = Get.arguments;
    if (arguments == null || arguments is! int) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: AppBar(
          title: const Text(
            'Unit Details',
            style: TextStyle(
              color: Color(0xFF1A1D1F),
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4E6AFF)),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(
          child: Text(
            'Invalid unit ID',
            style: TextStyle(
              color: Color(0xFF6F767E),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final int satuanId = arguments;
    _controller.getSatuanById(satuanId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          'Unit Details',
          style: TextStyle(
            color: Color(0xFF1A1D1F),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4E6AFF)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF4E6AFF)),
            ),
          );
        }
        if (_controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                if (_controller.errorMessage.value.contains('No token found'))
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E6AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.offAllNamed(RoutesName.login),
                      child: const Text('Go to Login'),
                    ),
                  ),
              ],
            ),
          );
        }
        final satuan = _controller.selectedSatuan.value;
        if (satuan == null) {
          return const Center(
            child: Text(
              'Unit not found',
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
              // Unit Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4E6AFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              satuan.name.isNotEmpty
                                  ? satuan.name.substring(0, 1).toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Color(0xFF4E6AFF),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
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
                                satuan.name.isNotEmpty
                                    ? satuan.name
                                    : 'Unnamed Unit',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1D1F),
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                satuan.description ?? 'No description',
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
                    // Status Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: satuan.deletedAt == null
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        satuan.deletedAt == null ? 'Active' : 'Deleted',
                        style: TextStyle(
                          color: satuan.deletedAt == null
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButton(
                icon: Icons.edit,
                label: 'Edit Unit',
                color: const Color(0xFF4E6AFF),
                onPressed: () {
                  _controller.nameController.text = satuan.name;
                  _controller.descriptionController.text =
                      satuan.description ?? '';
                  Get.to(() => SatuanFormPage(isEdit: true, satuanId: satuan.id));
                },
              ),

              if (satuan.deletedAt == null)
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'Delete Unit',
                  color: Colors.red,
                  onPressed: () => _showDeleteConfirmation(context, satuan.id),
                ),

              if (satuan.deletedAt != null)
                _buildActionButton(
                  icon: Icons.restore,
                  label: 'Restore Unit',
                  color: Colors.green,
                  onPressed: () => _showRestoreConfirmation(context, satuan.id),
                ),

              if (satuan.deletedAt != null)
                _buildActionButton(
                  icon: Icons.delete_forever,
                  label: 'Permanent Delete',
                  color: Colors.red[900]!,
                  onPressed: () =>
                      _showForceDeleteConfirmation(context, satuan.id),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionButton({
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
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: onPressed,
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  void _showDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Unit'),
        content: const Text('Are you sure you want to delete this unit?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6F767E)),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _controller.deleteSatuan(id);
              if (_controller.errorMessage.value.isEmpty) {
                Get.back(); // Close dialog
                Get.back(); // Return to list page
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showRestoreConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Restore Unit'),
        content: const Text('Are you sure you want to restore this unit?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6F767E)),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _controller.restoreSatuan(id);
              if (_controller.errorMessage.value.isEmpty) {
                Get.back(); // Close dialog
                _controller.getSatuanById(id); // Refresh detail view
              }
            },
            child: const Text(
              'Restore',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _showForceDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Permanently Delete Unit'),
        content: const Text(
            'This action cannot be undone. Are you sure you want to permanently delete this unit?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6F767E)),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _controller.forceDeleteSatuan(id);
              if (_controller.errorMessage.value.isEmpty) {
                Get.back(); // Close dialog
                Get.back(); // Return to list page
              }
            },
            child: const Text(
              'Delete Permanently',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}