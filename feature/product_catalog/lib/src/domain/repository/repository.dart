import 'package:common/common.dart';
import 'package:product_catalog/src/domain/model/product.dart';

abstract interface class ProductCatalogRepository {
  Future<PagingList<Product>> read({
    required OrderingPriceMode priceOrder,
    required int page,
    required int pageSize,
  });

  Future<void> write({
    required Iterable<Product> products,
  });

  Future<void> deleteById({
    required int id,
  });

  Future<Product?> readById({
    required int id,
  });
}

/// Describes how to order rows
enum OrderingPriceMode {
  /// Ascending ordering mode (lowest items first)
  asc,

  /// Descending ordering mode (highest items first)
  desc,

  /// None ordering
  none,
}
