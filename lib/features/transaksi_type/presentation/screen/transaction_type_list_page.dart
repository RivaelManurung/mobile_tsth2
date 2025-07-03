import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_tsth2/features/transaksi_type/presentation/bloc/transaction_type_bloc.dart';
import 'package:inventory_tsth2/features/transaksi_type/presentation/bloc/transaction_type_event.dart';
import 'package:inventory_tsth2/features/transaksi_type/presentation/bloc/transaction_type_state.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class TransactionTypeListPage extends StatefulWidget {
  const TransactionTypeListPage({super.key});

  @override
  State<TransactionTypeListPage> createState() =>
      _TransactionTypeListPageState();
}

class _TransactionTypeListPageState extends State<TransactionTypeListPage> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    context.read<TransactionTypeBloc>().add(FetchAllTransactionTypesEvent());
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<TransactionTypeBloc>().add(FetchAllTransactionTypesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tipe Transaksi')),
      body: BlocConsumer<TransactionTypeBloc, TransactionTypeState>(
        listener: (context, state) {
          if (state is! TransactionTypeLoading) {
            _refreshController.refreshCompleted();
          }
          if (state is TransactionTypeError) {
            _refreshController.refreshFailed();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is TransactionTypeInitial ||
              state is TransactionTypeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransactionTypeError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is TransactionTypeLoaded) {
            return _buildListView(state);
          }
          if (state is TransactionTypeDetailLoaded) {
            return _buildDetailView(state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildListView(TransactionTypeLoaded state) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: ListView.builder(
        itemCount: state.transactionTypes.length,
        itemBuilder: (context, index) {
          final type = state.transactionTypes[index];
          return Card(
            child: ListTile(
              title: Text(type.name),
              subtitle: Text(type.slug ?? '-'),
              onTap: () => context
                  .read<TransactionTypeBloc>()
                  .add(SelectTransactionTypeEvent(type.id)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailView(TransactionTypeDetailLoaded state) {
    final type = state.transactionType;
    return PopScope(
      canPop: false,
      onPopInvoked: (_) =>
          context.read<TransactionTypeBloc>().add(ClearSelectionEvent()),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(type.name, style: Theme.of(context).textTheme.headlineMedium),
            const Divider(height: 24),
            Text('ID: ${type.id}'),
            Text('Slug: ${type.slug}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context
                  .read<TransactionTypeBloc>()
                  .add(ClearSelectionEvent()),
              child: const Text('Kembali ke Daftar'),
            )
          ],
        ),
      ),
    );
  }
}
