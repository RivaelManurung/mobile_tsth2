import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:inventory_tsth2/controller/Auth/auth_controller.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/screens/notifikasi/notifikasi_page.dart';

// Data model untuk Action Card
class ActionCardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final String route;
  final int delay;

  const ActionCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.route,
    required this.delay,
  });
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();

  // Data untuk Action Cards
  final List<ActionCardData> _actionCards = const [
    ActionCardData(
      icon: Icons.inventory_2_outlined,
      title: 'Satuan',
      subtitle: 'Kelola satuan',
      gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
      route: RoutesName.satuanList,
      delay: 200,
    ),
    ActionCardData(
      icon: Icons.category_outlined,
      title: 'Kategori',
      subtitle: 'Kategori barang',
      gradient: LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEA580C)]),
      route: RoutesName.barangCategoryList,
      delay: 300,
    ),
    ActionCardData(
      icon: Icons.warehouse_outlined,
      title: 'Gudang',
      subtitle: 'Lokasi penyimpanan',
      gradient: LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
      route: RoutesName.gudangList,
      delay: 400,
    ),
    ActionCardData(
      icon: Icons.straighten_outlined,
      title: 'Barang',
      subtitle: 'Kelola barang',
      gradient: LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
      route: RoutesName.barangList,
      delay: 500,
    ),
    ActionCardData(
      icon: Icons.swap_horiz_outlined,
      title: 'Jenis Transaksi',
      subtitle: 'Atur operasi',
      gradient: LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)]),
      route: RoutesName.transactionTypeList,
      delay: 600,
    ),
    ActionCardData(
      icon: Icons.label_outline,
      title: 'Jenis Barang',
      subtitle: 'Klasifikasi barang',
      gradient: LinearGradient(colors: [Color(0xFFD946EF), Color(0xFFC026D3)]),
      route: RoutesName.jenisBarangList,
      delay: 700,
    ),
    ActionCardData(
      icon: Icons.receipt_long_outlined,
      title: 'Transaksi',
      subtitle: 'Pergerakan barang',
      gradient: LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF0D9488)]),
      route: RoutesName.transactionList,
      delay: 800,
    ),
  ];

  // Helper Functions
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 19) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _getFormattedDate() {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
  }

  String _getFormattedTime() {
    return DateFormat('HH:mm').format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _authController.isLoggedIn();
    if (!isLoggedIn) {
      Get.offAllNamed(RoutesName.login);
      Get.snackbar('Sesi Berakhir', 'Silakan masuk kembali', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      extendBodyBehindAppBar: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isSmallScreen = screenWidth < 400;
          final isMediumScreen = screenWidth >= 400 && screenWidth <= 600;
          final isLargeScreen = screenWidth > 600;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, isSmallScreen),
              _buildSectionTitle('Menu Utama', isSmallScreen),
              _buildMainContent(context, isSmallScreen, isMediumScreen, isLargeScreen),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, bool isSmallScreen) {
    return SliverAppBar(
      expandedHeight: isSmallScreen ? 200 : 220,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(isSmallScreen ? 16 : 24, 16, isSmallScreen ? 16 : 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_getGreeting()}, ${_authController.user.value?['name'] ?? 'Pengguna'}',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 18 : 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                                const SizedBox(height: 4),
                                Text(
                                  'Inventory TSTH2',
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                              ],
                            )),
                      ),
                      Row(
                        children: [
                          _buildIconButton(
                            icon: Icons.notifications_outlined,
                            isSmallScreen: isSmallScreen,
                            onTap: () => Get.to(() => const NotificationPage()),
                          ),
                          const SizedBox(width: 8),
                          _buildProfileButton(isSmallScreen),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _getFormattedDate(),
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isSmallScreen ? 14 : 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).animate().fadeIn(delay: 500.ms),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Text(
                              _getFormattedTime(),
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 14 : 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms).scale(delay: 500.ms),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(bool isSmallScreen) {
    return GestureDetector(
      onTap: () => Get.toNamed(RoutesName.profile),
      child: Obx(() => Container(
            width: isSmallScreen ? 42 : 48,
            height: isSmallScreen ? 42 : 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(
                  _authController.user.value?['avatar'] ??
                      'https://i.pravatar.cc/150?u=a042581f4e29026704d',
                ),
                fit: BoxFit.cover,
              ),
            ),
          )).animate().fadeIn(delay: 400.ms).scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isSmallScreen ? 42 : 48,
        height: isSmallScreen ? 42 : 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isSmallScreen ? 22 : 24,
        ),
      ).animate().fadeIn(delay: 400.ms).scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  SliverToBoxAdapter _buildSectionTitle(String title, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(isSmallScreen ? 20 : 24, 24, isSmallScreen ? 20 : 24, 16),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1D1F),
          ),
        ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
      ),
    );
  }

  SliverPadding _buildMainContent(
    BuildContext context,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isLargeScreen,
  ) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isLargeScreen ? 4 : (isMediumScreen ? 3 : 2),
          crossAxisSpacing: isSmallScreen ? 12 : 16,
          mainAxisSpacing: isSmallScreen ? 12 : 16,
          childAspectRatio: isSmallScreen ? 0.85 : 0.9,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final card = _actionCards[index];
            return _buildActionCard(
              context: context,
              data: card,
              isSmallScreen: isSmallScreen,
              onTap: () => Get.toNamed(card.route),
            );
          },
          childCount: _actionCards.length,
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required ActionCardData data,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: data.gradient.colors.last.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        data.gradient.colors.last.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: isSmallScreen ? 42 : 48,
                      height: isSmallScreen ? 42 : 48,
                      decoration: BoxDecoration(
                        gradient: data.gradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: data.gradient.colors.last.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        data.icon,
                        color: Colors.white,
                        size: isSmallScreen ? 22 : 24,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 16 : 17,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1D1F),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 13 : 14,
                            color: const Color(0xFF6F767E),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate(
        effects: [
          FadeEffect(delay: data.delay.ms, duration: 400.ms),
          SlideEffect(
            begin: const Offset(0, 0.3),
            delay: data.delay.ms,
            duration: 400.ms,
            curve: Curves.easeOut,
          ),
        ],
      ),
    );
  }
}