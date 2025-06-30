import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:inventory_tsth2/controller/Auth/auth_controller.dart';
import 'package:inventory_tsth2/controller/profile_controller.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/screens/notifikasi/notifikasi_page.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Data model for Action Card
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

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  final AuthController _authController = Get.find<AuthController>();
  final ProfileController _profileController = Get.find<ProfileController>();

  final Color primaryColor = const Color(0xFF4F46E5);
  final Color accentColor = const Color(0xFF34D399);
  final Color backgroundColor = const Color(0xFFF9FAFB);

  final List<ActionCardData> _actionCards = [
    const ActionCardData(
      icon: Icons.inventory_2_outlined,
      title: 'Satuan',
      subtitle: 'Kelola satuan',
      gradient:
          const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4338CA)]),
      route: RoutesName.satuanList,
      delay: 200,
    ),
    const ActionCardData(
      icon: Icons.category_outlined,
      title: 'Kategori',
      subtitle: 'Kategori barang',
      gradient:
          const LinearGradient(colors: [Color(0xFFF472B6), Color(0xFFDB2777)]),
      route: RoutesName.barangCategoryList,
      delay: 300,
    ),
    ActionCardData(
      icon: Icons.warehouse_outlined,
      title: 'Gudang',
      subtitle: 'Lokasi penyimpanan',
      gradient:
          const LinearGradient(colors: [Color(0xFF22D3EE), Color(0xFF06B6D4)]),
      route: RoutesName.gudangList,
      delay: 400,
    ),
    ActionCardData(
      icon: Icons.straighten_outlined,
      title: 'Barang',
      subtitle: 'Kelola barang',
      gradient:
          const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
      route: RoutesName.barangList,
      delay: 500,
    ),
    ActionCardData(
      icon: Icons.swap_horiz_outlined,
      title: 'Jenis Transaksi',
      subtitle: 'Atur operasi',
      gradient:
          const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
      route: RoutesName.transactionTypeList,
      delay: 600,
    ),
    ActionCardData(
      icon: Icons.label_outline,
      title: 'Jenis Barang',
      subtitle: 'Klasifikasi barang',
      gradient:
          const LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF0D9488)]),
      route: RoutesName.jenisBarangList,
      delay: 700,
    ),
    ActionCardData(
      icon: Icons.receipt_long_outlined,
      title: 'Transaksi',
      subtitle: 'Pergerakan barang',
      gradient:
          const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
      route: RoutesName.transactionList,
      delay: 800,
    ),
  ];

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
    WidgetsBinding.instance.addObserver(this);
    _checkAuthStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAuthStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _authController.isLoggedIn();
    if (!isLoggedIn) {
      Get.offAllNamed(RoutesName.login);
      Get.snackbar(
        'Sesi Berakhir',
        'Silakan masuk kembali',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: backgroundColor,
      ),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = screenWidth < 400;
          final isMediumScreen = screenWidth >= 400 && screenWidth <= 600;
          final isLargeScreen = screenWidth > 600;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, isSmallScreen),
              _buildSectionTitle('Menu Utama', isSmallScreen),
              _buildMainContent(context, isSmallScreen, isMediumScreen, isLargeScreen),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, bool isSmallScreen) {
    return SliverAppBar(
      expandedHeight: isSmallScreen ? 130 : 150,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, primaryColor.withOpacity(0.6)],
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.white.withOpacity(0.08),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(isSmallScreen ? 10 : 14, 6, isSmallScreen ? 10 : 14, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Obx(() => Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AutoSizeText(
                                          '${_getGreeting()}, ${_authController.user.value?['name'] ?? 'Guest'}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: isSmallScreen ? 14 : 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          minFontSize: 10,
                                          overflow: TextOverflow.ellipsis,
                                        ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
                                        const SizedBox(height: 2),
                                        AutoSizeText(
                                          'Inventory TSTH2',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white.withOpacity(0.85),
                                            fontSize: isSmallScreen ? 9 : 11,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: 1,
                                          minFontSize: 7,
                                          overflow: TextOverflow.ellipsis,
                                        ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2),
                                      ],
                                    )),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildIconButton(
                                    icon: Icons.notifications_outlined,
                                    isSmallScreen: isSmallScreen,
                                    onTap: () => Get.to(() => const NotificationPage()),
                                  ),
                                  const SizedBox(width: 6),
                                  _buildProfileButton(isSmallScreen),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: AutoSizeText(
                                  _getFormattedDate(),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: isSmallScreen ? 9 : 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 7,
                                  overflow: TextOverflow.ellipsis,
                                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                              ),
                              _buildGlassTimeChip(isSmallScreen),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTimeChip(bool isSmallScreen) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                size: isSmallScreen ? 10 : 12,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 3),
              AutoSizeText(
                _getFormattedTime(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 9 : 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                minFontSize: 7,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildProfileButton(bool isSmallScreen) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.toNamed(RoutesName.profile)?.then((result) {
          if (result == true) {
            setState(() {}); // Force rebuild after profile update
          }
        });
      },
      child: Obx(() => Container(
            width: isSmallScreen ? 36 : 42,
            height: isSmallScreen ? 36 : 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                _profileController.getPhotoUrl(
                    _authController.user.value?['avatar'] ?? ''),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Asset image load error: $error');
                  return Image.asset(
                    'assets/images/person.png',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ))
          .animate()
          .fadeIn(delay: 400.ms)
          .scale(duration: 600.ms, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: isSmallScreen ? 36 : 42,
        height: isSmallScreen ? 36 : 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accentColor.withOpacity(0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isSmallScreen ? 16 : 20,
        ),
      ).animate().fadeIn(delay: 400.ms).scale(duration: 600.ms, curve: Curves.easeOutCubic),
    );
  }

  SliverToBoxAdapter _buildSectionTitle(String title, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(isSmallScreen ? 12 : 16, 20, isSmallScreen ? 12 : 16, 10),
        child: AutoSizeText(
          title,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
          maxLines: 1,
          minFontSize: 12,
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isLargeScreen,
  ) {
    final double horizontalPadding = isSmallScreen ? 12 : 16;
    final double spacing = isSmallScreen ? 8 : 12;
    final int crossAxisCount = isLargeScreen ? 4 : (isMediumScreen ? 3 : 2);
    final screenWidth = MediaQuery.of(context).size.width;

    final double cardWidth =
        (screenWidth - (horizontalPadding * 2) - (spacing * (crossAxisCount - 1))) /
            crossAxisCount;

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _actionCards.map((card) {
            return _buildActionCard(
              context: context,
              data: card,
              isSmallScreen: isSmallScreen,
              width: cardWidth,
              onTap: () => Get.toNamed(card.route),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required ActionCardData data,
    required bool isSmallScreen,
    required double width,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: SizedBox(
        width: width,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        data.gradient.colors.first.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: isSmallScreen ? 38 : 44,
                        height: isSmallScreen ? 38 : 44,
                        decoration: BoxDecoration(
                          gradient: data.gradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: data.gradient.colors.first.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(1, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          data.icon,
                          color: Colors.white,
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AutoSizeText(
                        data.title,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                        maxLines: 2,
                        minFontSize: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      AutoSizeText(
                        data.subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 10 : 11,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        minFontSize: 8,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (data.delay).ms).scale(
          duration: 400.ms,
          curve: Curves.easeOutCubic,
          begin: const Offset(0.95, 0.95),
        );
  }
}