import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/screens/notifikasi/notifikasi_page.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 17) return 'Selamat Siang';
    return 'Selamat Malam';
  }

  String _getFormattedDate() {
    return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(DateTime.now());
  }

  String _getFormattedTime() {
    return DateFormat('HH:mm').format(DateTime.now());
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
              _buildSectionTitle('Dashboard ', isSmallScreen),
              _buildMainContent(
                context,
                isSmallScreen,
                isMediumScreen,
                isLargeScreen,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, bool isSmallScreen) {
    return SliverAppBar(
      expandedHeight: isSmallScreen ? 180 : 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.1),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                            const SizedBox(height: 8),
                            Text(
                              'Inventory Pro',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 26 : 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _buildIconButton(
                            icon: Icons.notifications,
                            isSmallScreen: isSmallScreen,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NotificationPage()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildIconButton(
                            icon: Icons.person,
                            isSmallScreen: isSmallScreen,
                            onTap: () => _navigateTo(context, RoutesName.profile),
                          ),
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
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isSmallScreen ? 14 : 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).animate().fadeIn(delay: 500.ms),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Text(
                          _getFormattedTime(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 14 : 15,
                            fontWeight: FontWeight.w600,
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

  SliverToBoxAdapter _buildSectionTitle(String title, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          left: isSmallScreen ? 16 : 20,
          right: isSmallScreen ? 16 : 20,
          top: 24,
          bottom: 12,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1D1F),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  SliverPadding _buildMainContent(
    BuildContext context,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isLargeScreen,
  ) {
    const actionCards = [
      {
        'icon': Icons.inventory_2,
        'title': 'Satuan',
        'subtitle': 'Kelola satuan',
        'gradient': LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4338CA)]),
        'route': RoutesName.satuanList,
        'delay': 0,
      },
      {
        'icon': Icons.category,
        'title': 'Kategori',
        'subtitle': 'Kategori barang',
        'gradient': LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEA580C)]),
        'route': RoutesName.barangCategoryList,
        'delay': 200,
      },
      {
        'icon': Icons.warehouse,
        'title': 'Gudang',
        'subtitle': 'Lokasi penyimpanan',
        'gradient': LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
        'route': RoutesName.gudangList,
        'delay': 300,
      },
      {
        'icon': Icons.straighten,
        'title': 'Barang',
        'subtitle': 'Kelola barang',
        'gradient': LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
        'route': RoutesName.barangList,
        'delay': 400,
      },
      {
        'icon': Icons.swap_horiz,
        'title': 'Jenis Transaksi',
        'subtitle': 'Atur operasi',
        'gradient': LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)]),
        'route': RoutesName.transactionTypeList,
        'delay': 500,
      },
      {
        'icon': Icons.label,
        'title': 'Jenis Barang',
        'subtitle': 'Klasifikasi barang',
        'gradient': LinearGradient(colors: [Color(0xFFD946EF), Color(0xFFC026D3)]),
        'route': RoutesName.jenisBarangList,
        'delay': 600,
      },
      {
        'icon': Icons.receipt,
        'title': 'Transaksi',
        'subtitle': 'Pergerakan barang',
        'gradient': LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF0D9488)]),
        'route': RoutesName.transactionList,
        'delay': 700,
      },
    ];

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isLargeScreen ? 4 : isMediumScreen ? 3 : 2,
          crossAxisSpacing: isSmallScreen ? 12 : 14,
          mainAxisSpacing: isSmallScreen ? 12 : 14,
          childAspectRatio: isSmallScreen ? 0.85 : 0.95,
        ),
        delegate: SliverChildListDelegate(
          actionCards.map((card) {
            return _buildActionCard(
              context: context,
              icon: card['icon'] as IconData,
              title: card['title'] as String,
              subtitle: card['subtitle'] as String,
              gradient: card['gradient'] as LinearGradient,
              isSmallScreen: isSmallScreen,
              onTap: () => _navigateTo(context, card['route'] as String),
              delay: card['delay'] as int,
            );
          }).toList(),
        ),
      ),
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
        width: isSmallScreen ? 40 : 46,
        height: isSmallScreen ? 40 : 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isSmallScreen ? 20 : 22,
        ),
      ).animate().fadeIn(delay: 300.ms).scale(duration: 300.ms),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required bool isSmallScreen,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradient.colors.first.withOpacity(0.05),
                        gradient.colors.last.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: isSmallScreen ? 40 : 46,
                      height: isSmallScreen ? 40 : 46,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: gradient.colors.last.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: isSmallScreen ? 20 : 22,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1D1F),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                        color: const Color(0xFF6F767E),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.2, duration: 300.ms).then().scale(
            begin: Offset(1.0, 1.0),
            end: Offset(0.98, 0.98),
            duration: 100.ms,
            curve: Curves.easeIn,
          ).scale(
            begin: Offset(0.98, 0.98),
            end: Offset(1.0, 1.0),
            duration: 100.ms,
            curve: Curves.easeOut,
         ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    try {
      Navigator.pushNamed(context, route);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal navigasi ke $route')),
      );
    }
  }
}