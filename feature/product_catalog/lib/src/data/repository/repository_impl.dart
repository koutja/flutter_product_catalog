import 'package:common/common.dart';
import 'package:database/database.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show OrderingMode;
import 'package:product_catalog/src/data/mapper/local.dart';
import 'package:product_catalog/src/data/mapper/remote.dart';
import 'package:product_catalog/src/domain/model/product.dart';
import 'package:product_catalog/src/domain/repository/repository.dart';
import 'package:rest_client/main_api_client.dart';

final class ProductCatalogRepositoryImpl implements ProductCatalogRepository {
  ProductCatalogRepositoryImpl(this._apiClient, this._db);

  final MainApiClient _apiClient;
  final AppDatabase _db;
  late final _productLocalDecoder = const ProductLocalDecoder();
  late final _productLocalEncoder = const ProductLocalEncoder();
  late final _productRemoteDecoder = const ProductRemoteDecoder();

  @override
  Future<PagingList<Product>> read({
    required OrderingPriceMode priceOrder,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _apiClient.client.getAllProducts(
        privatePage: page,
        privatePerPage: pageSize,
        privateSort: switch (priceOrder) {
          OrderingPriceMode.asc => 'price',
          OrderingPriceMode.desc => '-price',
          OrderingPriceMode.none => null,
        },
      );
      final remote = response.data;
      return PagingList<Product>(
        first: remote.first,
        prev: remote.prev,
        next: remote.next,
        last: remote.last,
        pages: remote.pages,
        items: remote.items,
        data: remote.data.map(_productRemoteDecoder.convert),
      );
    } on DioException catch (e) {
      if ([DioExceptionType.connectionError].contains(e.type)) {
        final local = await _db.productDao.getPaginatedAndSortedProducts(
          priceOrderingMode: switch (priceOrder) {
            OrderingPriceMode.asc => OrderingMode.asc,
            OrderingPriceMode.desc => OrderingMode.desc,
            OrderingPriceMode.none => null,
          },
          page: page,
          pageSize: pageSize,
        );

        return PagingList<Product>(
          first: local.first,
          prev: local.prev,
          next: local.next,
          last: local.last,
          pages: local.pages,
          items: local.items,
          data: local.data.map(_productLocalDecoder.convert),
        );
      }
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Product?> readById({required int id}) async {
    try {
      final response = await _apiClient.client.getProduct(id: id);
      final remote = response.data;
      return _productRemoteDecoder.convert(remote);
    } on DioException catch (e) {
      if ([DioExceptionType.connectionError].contains(e.type)) {
        final local = await _db.productDao.getProduct(id: id);
        if (local == null) {
          return null;
        }
        return _productLocalDecoder.convert(local);
      }
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> write({required Iterable<Product> products}) async {
    for (final product in products) {
      await _db.productDao.insertProduct(_productLocalEncoder.convert(product));
    }
  }

  @override
  Future<void> deleteById({required int id}) async {
    await Future.wait([
      _apiClient.client.deleteProduct(id: id),
      _db.productDao.deleteProductById(id: id),
    ]);
  }
}
