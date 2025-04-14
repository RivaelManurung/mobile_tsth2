import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/core/routes/routes.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory TSTH2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E6AFF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFF),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.w700),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      // routes: Routes.routes,
      initialRoute: RoutesName.main,
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // Helper to get greeting based on time
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 17) return 'Selamat Siang';
    return 'Selamat Malam';
  }

  // Helper to get formatted date and time
  String _getFormattedDate() {
    return DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
  }

  String _getFormattedTime() {
    return DateFormat('h:mm a').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isSmallScreen = screenWidth < 400;
          final isMediumScreen = screenWidth >= 400 && screenWidth <= 600;
          final isLargeScreen = screenWidth > 600;

          final cardWidth = isSmallScreen
              ? screenWidth * 0.42
              : isMediumScreen
                  ? screenWidth * 0.32
                  : 180.0;
          final cardHeight = isSmallScreen ? 110.0 : 130.0;

          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              _buildAppBar(context, isSmallScreen),
              _buildMainContent(
                context,
                isSmallScreen,
                isMediumScreen,
                isLargeScreen,
                cardWidth,
                cardHeight,
              ),
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
      backgroundColor: const Color(0xFFF8FAFF),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.1),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4E6AFF), Color(0xFF3A56E6)],
            ),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _getGreeting(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: isSmallScreen ? 18 : 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Inventory Pro',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 26 : 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, RoutesName.profile),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isSmallScreen ? 44 : 52,
                          height: isSmallScreen ? 44 : 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: isSmallScreen ? 24 : 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _getFormattedDate(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getFormattedTime(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  SliverPadding _buildMainContent(
    BuildContext context,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isLargeScreen,
    double cardWidth,
    double cardHeight,
  ) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: 20,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1D1F),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isLargeScreen
                ? 4
                : isMediumScreen
                    ? 3
                    : 2,
            crossAxisSpacing: isSmallScreen ? 12 : 16,
            mainAxisSpacing: isSmallScreen ? 12 : 16,
            childAspectRatio:
                isLargeScreen ? 1.3 : (isSmallScreen ? 0.95 : 1.1),
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
            children: [
              _buildActionCard(
                context: context,
                icon: Icons.inventory_2,
                title: 'Satuan',
                gradient: const LinearGradient(
                  colors: [Color(0xFF4E6AFF), Color(0xFF3A56E6)],
                ),
                isSmallScreen: isSmallScreen,
                onTap: () =>
                    Navigator.pushNamed(context, RoutesName.satuanList),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.qr_code,
                title: 'QR Tools',
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C4A3), Color(0xFF00A383)],
                ),
                isSmallScreen: isSmallScreen,
                onTap: () => Navigator.pushNamed(context, RoutesName.qrTools),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.category,
                title: 'Categories',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7043), Color(0xFFE65A30)],
                ),
                isSmallScreen: isSmallScreen,
                onTap: () =>
                    Navigator.pushNamed(context, RoutesName.barangCategoryList),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.warehouse,
                title: 'Warehouses',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF5252), Color(0xFFE63C3C)],
                ),
                isSmallScreen: isSmallScreen,
                onTap: () =>
                    Navigator.pushNamed(context, RoutesName.gudangList),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.straighten,
                title: 'Barang',
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B61FF), Color(0xFF5F4BE6)],
                ),
                isSmallScreen: isSmallScreen,
                onTap: () =>
                    Navigator.pushNamed(context, RoutesName.barangList),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.swap_horiz,
                title: 'Transaction Types',
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B8D9), Color(0xFF009BB6)],
                ),
                isSmallScreen: isSmallScreen,
                onTap: () => Navigator.pushNamed(
                    context, RoutesName.transactionTypeList),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.label,
                title: 'Item Types',
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFF7B1F8E)],
                ),
                isSmallScreen: isSmallScreen,
                onTap: () =>
                    Navigator.pushNamed(context, RoutesName.jenisBarangList),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _buildStatCard({
    required double width,
    required double height,
    required String title,
    required String value,
    required IconData icon,
    required LinearGradient gradient,
    required bool isSmallScreen,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: isSmallScreen ? 16 : 18,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isSmallScreen ? 18 : 20,
                ),
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.2, duration: 400.ms);
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required LinearGradient gradient,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: isSmallScreen ? 18 : 20,
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: gradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isSmallScreen ? 20 : 22,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1D1F),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'View details',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 13,
                  color: const Color(0xFF6F767E),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms);
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required LinearGradient gradient,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: isSmallScreen ? 18 : 20,
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: gradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isSmallScreen ? 18 : 20,
                    ),
                  ),
                ),
              ),
              if (!isSmallScreen)
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey.withOpacity(0.2),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1D1F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: const Color(0xFF6F767E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 12,
                      color: const Color(0xFF6F767E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, duration: 400.ms);
  }
}
