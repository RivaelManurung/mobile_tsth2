import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/notifikasi_controller.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Kembali',
          ).animate().fadeIn(delay: 300.ms).scale(),
        ),
        flexibleSpace: Container(
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
        ),
        title: Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.w800,
          ),
        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
        actions: [
          Obx(() => controller.notifications.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.done_all, color: Colors.white),
                  onPressed: () async {
                    await controller.markAllAsRead();
                  },
                  tooltip: 'Tandai Semua Dibaca',
                ).animate().fadeIn(delay: 400.ms)
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : controller.notifications.isEmpty
                ? const Center(child: Text('Tidak ada notifikasi'))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 16),
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = controller.notifications[index];
                      return _buildNotificationItem(
                        id: notification['id'],
                        title: notification['title'] ?? 'No Title',
                        description: notification['message'] ?? 'No Message',
                        time: _formatTime(notification['created_at']),
                        color: _getColorForNotification(notification['title']),
                        isSmallScreen: isSmallScreen,
                        delay: index * 100,
                        onTap: () => controller.markAsRead(notification['id']),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required int id,
    required String title,
    required String description,
    required String time,
    required Color color,
    required bool isSmallScreen,
    required int delay,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: isSmallScreen ? 40 : 44,
            height: isSmallScreen ? 40 : 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                _getIconForNotification(title),
                color: color,
                size: isSmallScreen ? 20 : 22,
              ),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1D1F),
            ),
          ),
          subtitle: Text(
            description,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 13,
              color: const Color(0xFF6F767E),
            ),
          ),
          trailing: Text(
            time,
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.1, duration: 300.ms);
  }

  // Helper to format time (you can use a package like `timeago` for better formatting)
  String _formatTime(String? createdAt) {
    if (createdAt == null) return 'Baru saja';
    final dateTime = DateTime.parse(createdAt).toLocal();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 2) {
      return 'Kemarin, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${difference.inDays} hari lalu';
    }
  }

  // Helper to assign icons based on notification title
  IconData _getIconForNotification(String title) {
    if (title.contains('Stok Barang Habis') || title.contains('Stok Barang Minimum')) {
      return Icons.warning;
    } else if (title.contains('Barang Ditambahkan')) {
      return Icons.add_circle;
    } else if (title.contains('Barang Dipindahkan')) {
      return Icons.swap_horiz;
    } else if (title.contains('Barang Dihapus')) {
      return Icons.remove_circle;
    } else if (title.contains('Transaksi Berhasil')) {
      return Icons.check_circle;
    } else {
      return Icons.notifications;
    }
  }

  // Helper to assign colors based on notification title
  Color _getColorForNotification(String title) {
    if (title.contains('Stok Barang Habis') || title.contains('Stok Barang Minimum')) {
      return const Color(0xFFFFA726);
    } else if (title.contains('Barang Ditambahkan')) {
      return const Color(0xFF4E6AFF);
    } else if (title.contains('Barang Dipindahkan')) {
      return const Color(0xFF00C4A3);
    } else if (title.contains('Barang Dihapus')) {
      return const Color(0xFFFF5252);
    } else if (title.contains('Transaksi Berhasil')) {
      return const Color(0xFF4CAF50);
    } else {
      return const Color(0xFF6A82FB);
    }
  }
}