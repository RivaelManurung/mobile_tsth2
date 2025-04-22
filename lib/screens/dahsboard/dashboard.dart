import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showSearchField = false;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 17) return 'Selamat Siang';
    return 'Selamat Malam';
  }

  String _getFormattedDate() {
    return DateFormat('EEEE, d MMM yyyy').format(DateTime.now());
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
              _buildSearchBar(context, isSmallScreen),
              _buildStatisticCards(context, isSmallScreen),
              _buildSectionTitle('Quick Actions', isSmallScreen),
              _buildMainContent(
                context,
                isSmallScreen,
                isMediumScreen,
                isLargeScreen,
              ),
              _buildSectionTitle('Recent Activities', isSmallScreen),
              _buildRecentActivities(context, isSmallScreen),
              SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RoutesName.transactionList);
        },
        backgroundColor: const Color(0xFF4E6AFF),
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scale(delay: 500.ms, duration: 300.ms),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, bool isSmallScreen) {
    return SliverAppBar(
      expandedHeight: isSmallScreen ? 200 : 220,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.1),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 5),
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
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, duration: 400.ms),
                            const SizedBox(height: 6),
                            Text(
                              'Inventory Pro',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 24 : 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, duration: 400.ms),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showSearchField = !_showSearchField;
                                if (_showSearchField) {
                                  _controller.forward();
                                } else {
                                  _controller.reverse();
                                }
                              });
                            },
                            child: Container(
                              width: isSmallScreen ? 40 : 46,
                              height: isSmallScreen ? 40 : 46,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: isSmallScreen ? 20 : 22,
                              ),
                            ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms, duration: 300.ms),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, RoutesName.profile),
                            child: Container(
                              width: isSmallScreen ? 40 : 46,
                              height: isSmallScreen ? 40 : 46,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: isSmallScreen ? 20 : 22,
                              ),
                            ).animate().fadeIn(delay: 400.ms).scale(delay: 400.ms, duration: 300.ms),
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
                            fontSize: isSmallScreen ? 13 : 14,
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
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getFormattedTime(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 13 : 14,
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

  SliverToBoxAdapter _buildSearchBar(BuildContext context, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizeTransition(
            sizeFactor: _controller,
            axisAlignment: -1,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: 12,
              ),
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
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search items, categories...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: isSmallScreen ? 14 : 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                    size: isSmallScreen ? 20 : 22,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey.shade400,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildStatisticCards(BuildContext context, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Container(
        height: isSmallScreen ? 110 : 120,
        margin: const EdgeInsets.only(top: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
          children: [
            _buildStatCard(
              icon: Icons.inventory_2,
              title: 'Items',
              value: '347',
              color: const Color(0xFF4E6AFF),
              isSmallScreen: isSmallScreen,
              delay: 0,
            ),
            _buildStatCard(
              icon: Icons.category,
              title: 'Categories',
              value: '12',
              color: const Color(0xFF00C4A3),
              isSmallScreen: isSmallScreen,
              delay: 100,
            ),
            _buildStatCard(
              icon: Icons.warehouse,
              title: 'Warehouses',
              value: '5',
              color: const Color(0xFFFF7043),
              isSmallScreen: isSmallScreen,
              delay: 200,
            ),
            _buildStatCard(
              icon: Icons.swap_horiz,
              title: 'Transactions',
              value: '128',
              color: const Color(0xFF9C27B0),
              isSmallScreen: isSmallScreen,
              delay: 300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isSmallScreen,
    required int delay,
  }) {
    return Container(
      width: isSmallScreen ? 130 : 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: isSmallScreen ? 18 : 20,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1D1F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: const Color(0xFF6F767E),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.2, duration: 400.ms);
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1D1F),
                letterSpacing: 0.2,
              ),
            ),
            if (title == 'Recent Activities')
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4E6AFF),
                  ),
                ),
              ),
          ],
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
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isLargeScreen
              ? 4
              : isMediumScreen
                  ? 3
                  : 2,
          crossAxisSpacing: isSmallScreen ? 12 : 14,
          mainAxisSpacing: isSmallScreen ? 12 : 14,
          childAspectRatio: isSmallScreen ? 0.85 : 0.95,
        ),
        delegate: SliverChildListDelegate([
          _buildActionCard(
            context: context,
            icon: Icons.inventory_2,
            title: 'Satuan',
            subtitle: 'Manage units',
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
            ),
            isSmallScreen: isSmallScreen,
            onTap: () => Navigator.pushNamed(context, RoutesName.satuanList),
            delay: 0,
          ),
          _buildActionCard(
            context: context,
            icon: Icons.qr_code,
            title: 'QR Tools',
            subtitle: 'Scan & generate',
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
            ),
            isSmallScreen: isSmallScreen,
            onTap: () => Navigator.pushNamed(context, RoutesName.qrTools),
            delay: 100,
          ),
          _buildActionCard(
            context: context,
            icon: Icons.category,
            title: 'Categories',
            subtitle: 'Item categories',
            gradient: const LinearGradient(
              colors: [Color(0xFFF97316), Color(0xFFEA580C)],
            ),
            isSmallScreen: isSmallScreen,
            onTap: () => Navigator.pushNamed(context, RoutesName.barangCategoryList),
            delay: 200,
          ),
          _buildActionCard(
            context: context,
            icon: Icons.warehouse,
            title: 'Warehouses',
            subtitle: 'Storage locations',
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            isSmallScreen: isSmallScreen,
            onTap: () => Navigator.pushNamed(context, RoutesName.gudangList),
            delay: 300,
          ),
          _buildActionCard(
            context: context,
            icon: Icons.straighten,
            title: 'Barang',
            subtitle: 'Manage items',
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            ),
            isSmallScreen: isSmallScreen,
            onTap: () => Navigator.pushNamed(context, RoutesName.barangList),
            delay: 400,
          ),
          _buildActionCard(
            context: context,
            icon: Icons.swap_horiz,
            title: 'Transaction Types',
            subtitle: 'Define operations',
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
            ),
            isSmallScreen: isSmallScreen,
            onTap: () => Navigator.pushNamed(context, RoutesName.transactionTypeList),
            delay: 500,
          ),
          _buildActionCard(
            context: context,
            icon: Icons.label,
            title: 'Item Types',
            subtitle: 'Item classifications',
            gradient: const LinearGradient(
              colors: [Color(0xFFD946EF), Color(0xFFC026D3)],
            ),
            isSmallScreen: isSmallScreen,
            onTap: () => Navigator.pushNamed(context, RoutesName.jenisBarangList),
            delay: 600,
          ),
          _buildActionCard(
            context: context,
            icon: Icons.receipt,
            title: 'Transactions',
            subtitle: 'Item movements',
            gradient: const LinearGradient(
              colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
            ),
            isSmallScreen: isSmallScreen,
            onTap: () => Navigator.pushNamed(context, RoutesName.transactionList),
            delay: 700,
          ),
        ]),
      ),
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
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
                            color: gradient.colors.last.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: isSmallScreen ? 20 : 22,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 15 : 16,
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
                        fontSize: isSmallScreen ? 12 : 13,
                        color: const Color(0xFF6F767E),
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
      ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.2, duration: 300.ms),
    );
  }

  SliverToBoxAdapter _buildRecentActivities(BuildContext context, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 4),
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
        child: Column(
          children: [
            _buildActivityItem(
              icon: Icons.add_circle,
              title: 'New item added',
              description: 'Laptop ASUS TUF Gaming A15',
              time: '10 minutes ago',
              color: const Color(0xFF4E6AFF),
              isSmallScreen: isSmallScreen,
              delay: 0,
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
            _buildActivityItem(
              icon: Icons.swap_horiz,
              title: 'Item transferred',
              description: 'Projector moved to Warehouse B',
              time: '2 hours ago',
              color: const Color(0xFF00C4A3),
              isSmallScreen: isSmallScreen,
              delay: 100,
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
            _buildActivityItem(
              icon: Icons.remove_circle,
              title: 'Item removed',
              description: 'Office chair - 2 units',
              time: '5 hours ago',
              color: const Color(0xFFFF5252),
              isSmallScreen: isSmallScreen,
              delay: 200,
            ),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, duration: 300.ms),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required Color color,
    required bool isSmallScreen,
    required int delay,
  }) {
    return ListTile(
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
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.1, duration: 300.ms);
  }
}