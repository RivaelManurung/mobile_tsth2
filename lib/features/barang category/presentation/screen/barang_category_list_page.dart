import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_tsth2/features/barang%20category/presentation/bloc/barang_category_bloc.dart';
import 'package:inventory_tsth2/features/barang%20category/presentation/bloc/barang_category_event.dart';
import 'package:inventory_tsth2/features/barang%20category/presentation/bloc/barang_category_state.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class BarangCategoryListPage extends StatefulWidget {
  const BarangCategoryListPage({super.key});

  @override
  State<BarangCategoryListPage> createState() => _BarangCategoryListPageState();
}

class _BarangCategoryListPageState extends State<BarangCategoryListPage> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    context.read<BarangCategoryBloc>().add(FetchAllBarangCategoriesEvent());
  }
  
  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
     context.read<BarangCategoryBloc>().add(FetchAllBarangCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori Barang')),
      body: BlocConsumer<BarangCategoryBloc, BarangCategoryState>(
        listener: (context, state) {
          if (state is! BarangCategoryLoading) {
            _refreshController.refreshCompleted();
          }
          if (state is BarangCategoryError) {
             _refreshController.refreshFailed();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
          }
        },
        builder: (context, state) {
          if (state is BarangCategoryInitial || state is BarangCategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BarangCategoryError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is BarangCategoryLoaded) {
            return SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: ListView.builder(
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return Card(
                    child: ListTile(
                      title: Text(category.name),
                      subtitle: Text(category.slug),
                      onTap: () {
                         context.read<BarangCategoryBloc>().add(SelectBarangCategoryEvent(category.id));
                      },
                    ),
                  );
                },
              ),
            );
          }
           if (state is BarangCategoryDetailLoaded) {
            final category = state.category;
            return PopScope(
              canPop: false,
              onPopInvoked: (_) => context.read<BarangCategoryBloc>().add(ClearBarangCategorySelectionEvent()),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(category.name, style: Theme.of(context).textTheme.headlineMedium),
                     Text('Slug: ${category.slug}'),
                     const SizedBox(height: 20),
                     ElevatedButton(
                      onPressed: () => context.read<BarangCategoryBloc>().add(ClearBarangCategorySelectionEvent()), 
                      child: const Text('Kembali ke Daftar'),
                    )
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('State tidak dikenal.'));
        },
      ),
    );
  }
}