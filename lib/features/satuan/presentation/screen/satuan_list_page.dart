import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_tsth2/features/satuan/presentation/bloc/satuan_bloc.dart';
import 'package:inventory_tsth2/features/satuan/presentation/bloc/satuan_event.dart';
import 'package:inventory_tsth2/features/satuan/presentation/bloc/satuan_state.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class SatuanListPage extends StatefulWidget {
  const SatuanListPage({super.key});

  @override
  State<SatuanListPage> createState() => _SatuanListPageState();
}

class _SatuanListPageState extends State<SatuanListPage> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    context.read<SatuanBloc>().add(FetchAllSatuanEvent());
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<SatuanBloc>().add(FetchAllSatuanEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Satuan')),
      body: BlocConsumer<SatuanBloc, SatuanState>(
        listener: (context, state) {
          if (state is! SatuanLoading) {
            _refreshController.refreshCompleted();
          }
          if (state is SatuanError) {
            _refreshController.refreshFailed();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is SatuanInitial || state is SatuanLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SatuanError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is SatuanLoaded) {
            return _buildListView(state);
          }
          if (state is SatuanDetailLoaded) {
            return _buildDetailView(state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildListView(SatuanLoaded state) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: ListView.builder(
        itemCount: state.satuanList.length,
        itemBuilder: (context, index) {
          final satuan = state.satuanList[index];
          return Card(
            child: ListTile(
              title: Text(satuan.name),
              subtitle: Text(satuan.description ?? 'No description'),
              onTap: () => context.read<SatuanBloc>().add(SelectSatuanEvent(satuan.id)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailView(SatuanDetailLoaded state) {
    final satuan = state.satuan;
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => context.read<SatuanBloc>().add(ClearSatuanSelectionEvent()),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(satuan.name, style: Theme.of(context).textTheme.headlineMedium),
            const Divider(height: 24),
            Text('ID: ${satuan.id}'),
            Text('Slug: ${satuan.slug}'),
            Text('Deskripsi: ${satuan.description ?? '-'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.read<SatuanBloc>().add(ClearSatuanSelectionEvent()),
              child: const Text('Kembali ke Daftar'),
            )
          ],
        ),
      ),
    );
  }
}