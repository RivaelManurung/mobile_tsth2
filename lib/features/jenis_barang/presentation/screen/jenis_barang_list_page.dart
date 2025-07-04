import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_tsth2/features/jenis_barang/presentation/bloc/jenis_barang_bloc.dart';
import 'package:inventory_tsth2/features/jenis_barang/presentation/bloc/jenis_barang_event.dart';
import 'package:inventory_tsth2/features/jenis_barang/presentation/bloc/jenis_barang_state.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class JenisBarangListPage extends StatefulWidget {
  const JenisBarangListPage({super.key});

  @override
  State<JenisBarangListPage> createState() => _JenisBarangListPageState();
}

class _JenisBarangListPageState extends State<JenisBarangListPage> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    context.read<JenisBarangBloc>().add(FetchAllJenisBarangEvent());
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<JenisBarangBloc>().add(FetchAllJenisBarangEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jenis Barang')),
      body: BlocConsumer<JenisBarangBloc, JenisBarangState>(
        listener: (context, state) {
          if (state is! JenisBarangLoading) {
            _refreshController.refreshCompleted();
          }
          if (state is JenisBarangError) {
            _refreshController.refreshFailed();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is JenisBarangInitial || state is JenisBarangLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is JenisBarangError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is JenisBarangLoaded) {
            return _buildListView(state);
          }
          if (state is JenisBarangDetailLoaded) {
            return _buildDetailView(state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildListView(JenisBarangLoaded state) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: ListView.builder(
        itemCount: state.jenisBarangList.length,
        itemBuilder: (context, index) {
          final item = state.jenisBarangList[index];
          return Card(
            child: ListTile(
              title: Text(item.name),
              subtitle: Text(item.description ?? 'No description'),
              onTap: () => context
                  .read<JenisBarangBloc>()
                  .add(SelectJenisBarangEvent(item.id)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailView(JenisBarangDetailLoaded state) {
    final item = state.jenisBarang;
    return PopScope(
      canPop: false,
      onPopInvoked: (_) =>
          context.read<JenisBarangBloc>().add(ClearJenisBarangSelectionEvent()),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: Theme.of(context).textTheme.headlineMedium),
            const Divider(height: 24),
            Text('ID: ${item.id}'),
            Text('Slug: ${item.slug}'),
            Text('Description: ${item.description ?? '-'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context
                  .read<JenisBarangBloc>()
                  .add(ClearJenisBarangSelectionEvent()),
              child: const Text('Kembali ke Daftar'),
            )
          ],
        ),
      ),
    );
  }
}
