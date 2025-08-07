import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_catalog/export.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    required this.productId,
    required this.fetchProductBloc,
    required this.deleteProductBloc,
    super.key,
  });

  final int productId;
  final FetchProductBloc fetchProductBloc;
  final DeleteProductBloc deleteProductBloc;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Product: ${widget.productId}'),
    ),
    body: RefreshIndicator(
      onRefresh: _refresh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SingleChildScrollView(
          child: BlocConsumer<FetchProductBloc, FetchProductState>(
            bloc: widget.fetchProductBloc,
            listener: (_, state) {
              final error = state.errorOrNull;
              if (error != null) {
                _showDetailError();
                return;
              }
            },
            builder: (_, state) {
              if (state.isBusy) {
                return const RepaintBoundary(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final product = state.productOrNull;
              if (product == null) {
                return const RepaintBoundary(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'название2: ${product.name}',
                          maxLines: 2,
                        ),
                        Text(
                          'описание: ${product.description}',
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text('цена: ${product.price}'),
                      ],
                    ),
                  ),
                  BlocConsumer<DeleteProductBloc, DeleteProductState>(
                    bloc: widget.deleteProductBloc,
                    listener: (context, state) {
                      final error = state.errorOrNull;
                      if (error != null) {
                        _showDeleteError();
                        return;
                      }
                      if (state.isSuccess) {
                        // TODO: обновить список в странице каталога
                        Navigator.maybePop(context);
                        return;
                      }
                    },
                    builder: (context, state) {
                      return IconButton(
                        onPressed: state.isBusy ? null : _showDeleteConfirm,
                        icon: const Icon(Icons.delete),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );

  Future<void> _showDetailError() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Something went wrong while fetching a product.',
        ),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _refresh,
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirm() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Are you sure?',
        ),
        action: SnackBarAction(
          label: 'Yes',
          onPressed: _deleteHandler,
        ),
      ),
    );
  }

  Future<void> _showDeleteError() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Something went wrong while deleting a product.',
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    widget.fetchProductBloc.add(FetchProductEvent.execute(productId: widget.productId));
  }

  Future<void> _deleteHandler() async {
    widget.deleteProductBloc.add(DeleteProductEvent.execute(productId: widget.productId));
  }
}
