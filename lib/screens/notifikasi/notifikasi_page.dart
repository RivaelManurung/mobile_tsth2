import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 16),
        children: [
          _buildNotificationItem(
            icon: Icons.add_circle,
            title: 'Barang Baru Ditambahkan',
            description: 'Laptop ASUS TUF Gaming A15 telah ditambahkan ke inventaris.',
            time: '10 menit lalu',
            color: const Color(0xFF4E6AFF),
            isSmallScreen: isSmallScreen,
            delay: 0,
          ),
          _buildNotificationItem(
            icon: Icons.swap_horiz,
            title: 'Barang Dipindahkan',
            description: 'Proyektor dipindahkan ke Gudang B.',
            time: '2 jam lalu',
            color: const Color(0xFF00C4A3),
            isSmallScreen: isSmallScreen,
            delay: 100,
          ),
          _buildNotificationItem(
            icon: Icons.remove_circle,
            title: 'Barang Dihapus',
            description: 'Kursi kantor - 2 unit telah dihapus dari inventaris.',
            time: '5 jam lalu',
            color: const Color(0xFFFF5252),
            isSmallScreen: isSmallScreen,
            delay: 200,
          ),
          _buildNotificationItem(
            icon: Icons.warning,
            title: 'Stok Rendah',
            description: 'Stok Printer HP DeskJet hanya tersisa 3 unit.',
            time: 'Hari ini, 09:15',
            color: const Color(0xFFFFA726),
            isSmallScreen: isSmallScreen,
            delay: 300,
          ),
          _buildNotificationItem(
            icon: Icons.check_circle,
            title: 'Transaksi Berhasil',
            description: 'Transaksi pengeluaran barang untuk proyek A selesai.',
            time: 'Kemarin, 14:30',
            color: const Color(0xFF4CAF50),
            isSmallScreen: isSmallScreen,
            delay: 400,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required Color color,
    required bool isSmallScreen,
    required int delay,
  }) {
    return Container(
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
              icon,
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
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.1, duration: 300.ms);
  }
}