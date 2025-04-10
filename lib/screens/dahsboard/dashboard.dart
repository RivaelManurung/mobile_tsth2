import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/core/routes/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E6AFF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFF),
      ),
      initialRoute: RoutesName.main, // Set initial route
      onGenerateRoute: Routes.onGenerateRoute, // Use routing system
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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

          // Calculate responsive values
          final cardWidth = isSmallScreen
              ? screenWidth * 0.4
              : isMediumScreen
                  ? screenWidth * 0.3
                  : 160.0;
          final cardHeight = isSmallScreen ? 100.0 : 120.0;

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
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4E6AFF),
                Color(0xFF3A56E6),
              ],
            ),
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Inventory Pro',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, RoutesName.profile),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: isSmallScreen ? 40 : 48,
                          height: isSmallScreen ? 40 : 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'AJ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.white.withOpacity(0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Search inventory...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.tune,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
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
        horizontal: isSmallScreen ? 12 : 16,
        vertical: 16,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          SizedBox(
            height: cardHeight + 20,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
              ),
              children: [
                _buildStatCard(
                  width: cardWidth,
                  height: cardHeight,
                  title: 'Total Items',
                  value: '1,248',
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xFF4E6AFF),
                  isSmallScreen: isSmallScreen,
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                _buildStatCard(
                  width: cardWidth,
                  height: cardHeight,
                  title: 'Categories',
                  value: '24',
                  icon: Icons.category_outlined,
                  color: const Color(0xFF00C4A3),
                  isSmallScreen: isSmallScreen,
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                _buildStatCard(
                  width: cardWidth,
                  height: cardHeight,
                  title: 'Warehouses',
                  value: '5',
                  icon: Icons.warehouse_outlined,
                  color: const Color(0xFFFF7043),
                  isSmallScreen: isSmallScreen,
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                _buildStatCard(
                  width: cardWidth,
                  height: cardHeight,
                  title: 'Low Stock',
                  value: '18',
                  icon: Icons.warning_amber_outlined,
                  color: const Color(0xFFFF5252),
                  isSmallScreen: isSmallScreen,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 4 : 8,
            ),
            child: Row(
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D1F),
                  ),
                ),
                const Spacer(),
                Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF4E6AFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: const Color(0xFF4E6AFF),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isLargeScreen ? 3 : 2,
            crossAxisSpacing: isSmallScreen ? 8 : 12,
            mainAxisSpacing: isSmallScreen ? 8 : 12,
            childAspectRatio: isLargeScreen ? 1.25 : (isSmallScreen ? 0.9 : 1.05),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 4 : 8,
            ),
            children: [
              _buildActionCard(
                context: context,
                icon: Icons.inventory_2,
                title: 'Items',
                color: const Color(0xFF4E6AFF),
                isSmallScreen: isSmallScreen,
                onTap: () => Navigator.pushNamed(context, RoutesName.barangList),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.qr_code,
                title: 'QR Tools',
                color: const Color(0xFF00C4A3),
                isSmallScreen: isSmallScreen,
                onTap: () => Navigator.pushNamed(context, RoutesName.qrTools),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.category,
                title: 'Categories',
                color: const Color(0xFFFF7043),
                isSmallScreen: isSmallScreen,
                onTap: () => Navigator.pushNamed(context, RoutesName.barangCategoryList),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.warehouse,
                title: 'Warehouses',
                color: const Color(0xFFFF5252),
                isSmallScreen: isSmallScreen,
                onTap: () => Navigator.pushNamed(context, RoutesName.gudangList),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.straighten,
                title: 'Units',
                color: const Color(0xFF7B61FF),
                isSmallScreen: isSmallScreen,
                onTap: () => Navigator.pushNamed(context, RoutesName.units),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.swap_horiz,
                title: 'Transaction Types',
                color: const Color(0xFF00B8D9),
                isSmallScreen: isSmallScreen,
                onTap: () => Navigator.pushNamed(context, RoutesName.transactionTypeList),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.label,
                title: 'Item Types',
                color: const Color(0xFF9C27B0),
                isSmallScreen: isSmallScreen,
                onTap: () => Navigator.pushNamed(context, RoutesName.jenisBarangList),
              ),
              if (isLargeScreen) ...[
                _buildActionCard(
                  context: context,
                  icon: Icons.settings,
                  title: 'Settings',
                  color: const Color(0xFF607D8B),
                  isSmallScreen: isSmallScreen,
                  onTap: () {},
                ),
                _buildActionCard(
                  context: context,
                  icon: Icons.analytics,
                  title: 'Reports',
                  color: const Color(0xFFFFC107),
                  isSmallScreen: isSmallScreen,
                  onTap: () {},
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 4 : 8,
            ),
            child: Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1D1F),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildActivityItem(
            icon: Icons.inventory,
            title: 'New items added',
            subtitle: '15 new products in Electronics',
            time: '2 hours ago',
            color: const Color(0xFF4E6AFF),
            isSmallScreen: isSmallScreen,
          ),
          _buildActivityItem(
            icon: Icons.edit,
            title: 'Inventory updated',
            subtitle: 'Stock levels adjusted',
            time: '5 hours ago',
            color: const Color(0xFF00C4A3),
            isSmallScreen: isSmallScreen,
          ),
          _buildActivityItem(
            icon: Icons.warning,
            title: 'Low stock alert',
            subtitle: '3 items below minimum',
            time: 'Yesterday',
            color: const Color(0xFFFF7043),
            isSmallScreen: isSmallScreen,
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
    required Color color,
    required bool isSmallScreen,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
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
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isSmallScreen ? 32 : 36,
                height: isSmallScreen ? 32 : 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: color,
                    size: isSmallScreen ? 16 : 18,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1D1F),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 11 : 12,
                  color: const Color(0xFF6F767E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 20);
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
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
                Container(
                  width: isSmallScreen ? 36 : 40,
                  height: isSmallScreen ? 36 : 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: isSmallScreen ? 18 : 20,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1D1F),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'View details',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF6F767E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 20);
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 36 : 40,
            height: isSmallScreen ? 36 : 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: isSmallScreen ? 16 : 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1D1F),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12,
                    color: const Color(0xFF6F767E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 11,
              color: const Color(0xFF6F767E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}