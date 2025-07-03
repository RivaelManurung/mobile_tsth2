import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_tsth2/features/barang/domain/entities/barang.dart';
import 'package:inventory_tsth2/features/barang/presentation/bloc/barang_bloc.dart';
import 'package:inventory_tsth2/features/barang/presentation/bloc/barang_event.dart';
import 'package:inventory_tsth2/features/barang/presentation/bloc/barang_state.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class BarangListPage extends StatefulWidget {
  const BarangListPage({Key? key}) : super(key: key);

  @override
  State<BarangListPage> createState() => _BarangListPageState();
}

class _BarangListPageState extends State<BarangListPage> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    // Fetch data when the page loads
    context.read<BarangBloc>().add(FetchAllBarangEvent());
  }

  Future<void> _refreshData() async {
    context.read<BarangBloc>().add(FetchAllBarangEvent());
  }

  void _handleBackPress(BarangState state) {
    if (state is BarangDetailLoaded) {
      context.read<BarangBloc>().add(ClearBarangSelectionEvent());
    } else {
      // Replace with your app's navigation logic
      Navigator.of(context).pop();
      // Get.offAllNamed(RoutesName.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return BlocConsumer<BarangBloc, BarangState>(
      listener: (context, state) {
        if (state is BarangError) {
          _refreshController.refreshFailed();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          if (state.message.contains('Unauthenticated')) {
             // Replace with your app's navigation logic
             // Get.offAllNamed(RoutesName.login);
          }
        } else if (state is BarangListLoaded) {
          if (_refreshController.isRefresh) {
            _refreshController.refreshCompleted();
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Daftar barang diperbarui'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            _handleBackPress(state);
            return false; // We handle navigation manually
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFF),
            body: SmartRefresher(
              controller: _refreshController,
              onRefresh: _refreshData,
              enablePullDown: state is! BarangDetailLoaded,
              header: const ClassicHeader(
                idleText: 'Tarik untuk memperbarui',
                releaseText: 'Lepas untuk memperbarui',
                refreshingText: 'Memperbarui...',
                completeText: 'Pembaruan selesai',
                failedText: 'Pembaruan gagal',
                textStyle: TextStyle(color: Color(0xFF6F767E)),
              ),
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  _buildAppBar(isSmallScreen, state),
                  _buildBody(context, isSmallScreen, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(bool isSmallScreen, BarangState state) {
    // Same AppBar logic as before, just using the new state model
    return SliverAppBar(
       expandedHeight: isSmallScreen ? 120 : 140,
        floating: false,
        pinned: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => _handleBackPress(state),
                tooltip: 'Kembali',
            ).animate().fadeIn(delay: 300.ms).scale(),
        ),
        actions: [
            Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                    onPressed: _refreshData,
                    tooltip: 'Segarkan Data',
                ).animate().fadeIn(delay: 300.ms).scale(),
            ),
        ],
        flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Container(
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
                child: SafeArea(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16 : 24,
                            vertical: 12,
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Row(
                                    children: [
                                        const Icon(
                                            Icons.inventory_2,
                                            color: Colors.white,
                                            size: 28,
                                        ).animate().fadeIn(delay: 400.ms),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child: Text(
                                                'Manajemen Barang',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: isSmallScreen ? 24 : 28,
                                                    fontWeight: FontWeight.w800,
                                                    shadows: [
                                                        Shadow(
                                                            color: Colors.black.withOpacity(0.2),
                                                            offset: Offset(1, 1),
                                                            blurRadius: 4,
                                                        ),
                                                    ],
                                                ),
                                            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    'Kelola barang Anda dengan mudah',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: isSmallScreen ? 14 : 16,
                                        fontWeight: FontWeight.w500,
                                    ),
                                ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2),
                            ],
                        ),
                    ),
                ),
            ),
        ),
    );
  }

  Widget _buildBody(BuildContext context, bool isSmallScreen, BarangState state) {
    if (state is BarangLoading && state is! BarangDetailLoaded && state is! BarangListLoaded) {
       return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    }
    if (state is BarangError) {
       return SliverFillRemaining(child: Center(child: Text(state.message)));
    }
    if (state is BarangDetailLoaded) {
      return _buildDetailView(context, isSmallScreen, state.selectedBarang);
    }
    if (state is BarangListLoaded || (state is BarangDetailLoaded && state.barangList.isNotEmpty)) {
      final list = state is BarangListLoaded ? state.barangList : (state as BarangDetailLoaded).barangList;
      return _buildListView(context, isSmallScreen, list);
    }
     // Fallback for initial state
    return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
  }

  SliverToBoxAdapter _buildListView(BuildContext context, bool isSmallScreen, List<Barang> barangList) {
    if (barangList.isEmpty) {
        return SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0),
              child: Text('Tidak ada barang ditemukan'),
            ),
          ),
        );
    }
    return SliverToBoxAdapter(
        child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: 16,
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Padding(
                        padding: EdgeInsets.only(left: isSmallScreen ? 4 : 8, bottom: 8),
                        child: Text(
                            'Daftar Barang',
                            style: TextStyle(
                                fontSize: isSmallScreen ? 17 : 19,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1D1F),
                            ),
                        ),
                    ),
                    ...barangList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final barang = entry.value;
                        return GestureDetector(
                            onTap: () => context.read<BarangBloc>().add(FetchBarangDetailEvent(barang.id)),
                            child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                        ),
                                    ],
                                    border: Border.all(
                                        color: const Color(0xFF4E6AFF).withOpacity(0.1),
                                        width: 1,
                                    ),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                        children: [
                                            GestureDetector(
                                                onTap: () => _showImageDialog(context, barang.barangGambar),
                                                child: _buildItemImage(barang.barangGambar),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Text(
                                                            barang.barangNama,
                                                            style: TextStyle(
                                                                fontSize: isSmallScreen ? 16 : 18,
                                                                fontWeight: FontWeight.w700,
                                                                color: const Color(0xFF1A1D1F),
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                            'Kode: ${barang.barangKode}',
                                                            style: TextStyle(
                                                                fontSize: isSmallScreen ? 12 : 13,
                                                                color: const Color(0xFF6F767E),
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                        ),
                                                        Text(
                                                            'Harga: Rp${barang.barangHarga.toStringAsFixed(2)}',
                                                            style: TextStyle(
                                                                fontSize: isSmallScreen ? 12 : 13,
                                                                color: const Color(0xFF6F767E),
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                        ),
                                                        Text(
                                                            'Stok Tersedia: ${barang.totalStokTersedia} Unit',
                                                            style: TextStyle(
                                                                fontSize: isSmallScreen ? 12 : 13,
                                                                color: const Color(0xFF4E6AFF),
                                                                fontWeight: FontWeight.w600,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                                color: Color(0xFF6F767E),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                        ).animate().fadeIn(delay: (200 + index * 100).ms).slideY(
                                begin: 0.2,
                                duration: 400.ms,
                            );
                    }).toList(),
                ],
            ),
        ),
    );
  }

   SliverToBoxAdapter _buildDetailView(BuildContext context, bool isSmallScreen, Barang barang) {
     // Your original _buildDetailView logic here, using the 'barang' object
     // I've copied it below for completeness
     final gudangs = barang.gudangs;

    return SliverToBoxAdapter(
        child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: 16,
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF6A82FB), Color(0xFF4C60DB)],
                            ),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(14),
                                topRight: Radius.circular(14),
                            ),
                            boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                ),
                            ],
                        ),
                        child: Row(
                            children: [
                                CircleAvatar(
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    radius: 30,
                                    child: Text(
                                        barang.barangNama.substring(0, 1).toUpperCase(),
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
                                                barang.barangNama,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                    fontSize: isSmallScreen ? 20 : 24,
                                                    shadows: [
                                                        Shadow(
                                                            color: Colors.black.withOpacity(0.2),
                                                            offset: const Offset(1, 1),
                                                            blurRadius: 4,
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                                'Detail Barang',
                                                style: TextStyle(
                                                    color: Colors.white.withOpacity(0.9),
                                                    fontSize: isSmallScreen ? 14 : 16,
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () => context.read<BarangBloc>().add(ClearBarangSelectionEvent()),
                                ),
                            ],
                        ),
                    ).animate().fadeIn(duration: 400.ms),
                    Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(14),
                                bottomRight: Radius.circular(14),
                            ),
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
                                Center(
                                    child: GestureDetector(
                                        onTap: () => _showImageDialog(context, barang.barangGambar),
                                        child: Container(
                                            margin: const EdgeInsets.only(bottom: 16),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(14),
                                                boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black.withOpacity(0.05),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                    ),
                                                ],
                                            ),
                                            child: _buildDetailImage(barang.barangGambar),
                                        ),
                                    ),
                                ),
                                _buildDetailRow(
                                    label: 'Nama Barang',
                                    value: barang.barangNama,
                                    isSmallScreen: isSmallScreen,
                                ),
                                const Divider(height: 24),
                                _buildDetailRow(
                                    label: 'Kode',
                                    value: barang.barangKode,
                                    isSmallScreen: isSmallScreen,
                                ),
                                const Divider(height: 24),
                                _buildDetailRow(
                                    label: 'Harga',
                                    value: 'Rp${barang.barangHarga.toStringAsFixed(2)}',
                                    isSmallScreen: isSmallScreen,
                                ),
                                const Divider(height: 24),
                                _buildDetailRow(
                                    label: 'Jenis Barang',
                                    value: barang.jenisbarangNama ?? 'Tidak diketahui',
                                    isSmallScreen: isSmallScreen,
                                ),
                                const Divider(height: 24),
                                _buildDetailRow(
                                    label: 'Satuan',
                                    value: barang.satuanNama ?? 'Tidak diketahui',
                                    isSmallScreen: isSmallScreen,
                                ),
                                const Divider(height: 24),
                                _buildDetailRow(
                                    label: 'Kategori',
                                    value: barang.barangcategoryNama ?? 'Tidak diketahui',
                                    isSmallScreen: isSmallScreen,
                                ),
                                const Divider(height: 24),
                                const Text(
                                    'Stok di Gudang',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1D1F),
                                    ),
                                ),
                                const SizedBox(height: 8),
                                if (gudangs.isEmpty)
                                    const Text(
                                        'Tidak ada data gudang',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF6F767E),
                                        ),
                                    )
                                else
                                    ...gudangs.map((gudang) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: Colors.grey[200]!,
                                                    width: 1,
                                                ),
                                            ),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    Text(
                                                        gudang.gudangName ?? 'Gudang ID: ${gudang.gudangId}',
                                                        style: TextStyle(
                                                            fontSize: isSmallScreen ? 14 : 15,
                                                            fontWeight: FontWeight.w600,
                                                            color: const Color(0xFF1A1D1F),
                                                        ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _buildStockRow(
                                                        label: 'Stok Tersedia',
                                                        value: '${gudang.stokTersedia} Unit',
                                                        isSmallScreen: isSmallScreen,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    _buildStockRow(
                                                        label: 'Stok Dipinjam',
                                                        value: '${gudang.stokDipinjam} Unit',
                                                        isSmallScreen: isSmallScreen,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    _buildStockRow(
                                                        label: 'Stok Maintenance',
                                                        value: '${gudang.stokMaintenance} Unit',
                                                        isSmallScreen: isSmallScreen,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    _buildStockRow(
                                                        label: 'Operator',
                                                        value: gudang.operatorName ?? 'Tidak diketahui',
                                                        isSmallScreen: isSmallScreen,
                                                    ),
                                                ],
                                            ),
                                        ),
                                    )),
                            ],
                        ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                ],
            ),
        ),
    );
   }

  // NOTE: Helper methods like _showImageDialog, _buildDetailRow, etc.,
  // can be kept as they are, since they are pure UI functions.
  // I have included them here for completeness.
  
  void _showImageDialog(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tidak ada gambar untuk ditampilkan'),
           backgroundColor: Colors.grey,
           margin: const EdgeInsets.all(16),
           behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.8),
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.1,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.8,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required bool isSmallScreen,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1D1F),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: valueColor ?? const Color(0xFF6F767E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockRow({
    required String label,
    required String value,
    required bool isSmallScreen,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 13,
            color: const Color(0xFF6F767E),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 13,
            color: const Color(0xFF1A1D1F),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildItemImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF4E6AFF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.inventory,
          size: 24,
          color: Color(0xFF4E6AFF),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.broken_image,
            size: 24,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory,
              size: 80,
              color: Color(0xFF6F767E),
            ),
            SizedBox(height: 8),
            Text(
              'No Image Available',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6F767E),
              ),
            ),
          ],
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 200,
        height: 200,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.broken_image,
            size: 80,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}