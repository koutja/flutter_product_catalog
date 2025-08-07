import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:product_catalog/export.dart';
import 'package:product_catalog/src/domain/model/product.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({
    required this.fetchProductCatalogBloc, required this.onProductTap,
    super.key,
  });

  final FetchProductCatalogBloc fetchProductCatalogBloc;

  final ValueSetter<int> onProductTap;

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  late final _kPageSize = 50;
  var _state = PagingState<int, Product>();
  late final _orderingPriceModNotifier = ValueNotifier(OrderingPriceMode.none);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  /// The controller needs to be disposed when the widget is removed.
  @override
  void dispose() {
    _orderingPriceModNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(
          title: const Text('Catalog'),
          actions: [
            ValueListenableBuilder(
              valueListenable: _orderingPriceModNotifier,
              builder: (_, mode, __) {
                final icon = switch (mode) {
                  OrderingPriceMode.none => const Icon(Icons.arrow_downward),
                  OrderingPriceMode.asc => const Icon(Icons.cancel),
                  OrderingPriceMode.desc => const Icon(Icons.cancel),
                };
                return IconButton(
                  onPressed: _toggleTapHandler,
                  icon: icon,
                );
              },
            ),
          ],
        ),
        body: BlocListener<FetchProductCatalogBloc, FetchProductCatalogState>(
          bloc: widget.fetchProductCatalogBloc,
          listener: (context, state) {
            final payload = state.payloadOrNull;
            if (state.isSuccess && payload != null) {
              _successPageFetchHandler(payload);
              return;
            }
            if (state.errorOrNull case final Object error) {
              _failurePageFetchHandler(error);
              _showError();
              return;
            }
          },
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: PagedListView<int, Product>(
              state: _state,
              fetchNextPage: _fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate(
                itemBuilder: (context, item, index) =>
                    InkWell(
                      onTap: () {
                        widget.onProductTap(item.id);
                      },
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.price.toString()),
                      ),
                    ),
              ),
            ),
          ),
        ),
      );

  Future<void> _showError() async {
    if (_state.status == PagingStatus.subsequentPageError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Something went wrong while fetching a new page.',
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _fetchNextPage,
          ),
        ),
      );
    }
  }

  OrderingPriceMode _toggleOrderingPriceMode() {
    final prev = _orderingPriceModNotifier.value;
    if (prev == OrderingPriceMode.none) {
      return OrderingPriceMode.asc;
    }
    return OrderingPriceMode.none;
  }

  void _toggleTapHandler() {
    final mode = _toggleOrderingPriceMode();
    _orderingPriceModNotifier.value = mode;
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _state = PagingState<int, Product>(isLoading: true);
      widget.fetchProductCatalogBloc.add(
        FetchProductCatalogEvent.execute(
          priceOrder: _orderingPriceModNotifier.value,
          page: 1,
          pageSize: _kPageSize,
        ),
      );
    });
  }

  Future<void> _fetchNextPage() async {
    if (_state.isLoading) {
      return;
    }
    if (!_state.hasNextPage) {
      return;
    }

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
      widget.fetchProductCatalogBloc.add(
        FetchProductCatalogEvent.execute(
          priceOrder: _orderingPriceModNotifier.value,
          page: _state.nextIntPageKey,
          pageSize: _kPageSize,
        ),
      );
    });
  }

  Future<void> _successPageFetchHandler(PagingList<Product> newItems) async {
    final current = _state.keys?.last ?? 0;
    final newKey = current + 1;
    final isLastPage = newItems.next == null;
    print('newKey: $newKey isLastPage: $isLastPage');
    setState(() {
      _state = _state.copyWith(
        pages: [...?_state.pages, newItems.data.toList()],
        keys: [...?_state.keys, newKey],
        hasNextPage: !isLastPage,
        isLoading: false,
      );
    });
  }

  Future<void> _failurePageFetchHandler(Object error) async {
    setState(() {
      _state = _state.copyWith(
        error: error,
        isLoading: false,
      );
    });
  }
}
