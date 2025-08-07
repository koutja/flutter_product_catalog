import 'package:common/common.dart';
import 'package:database/database.dart';
import 'package:database/src/product/table.dart';
import 'package:drift/drift.dart';

part 'dao.g.dart';

@DriftAccessor(tables: [ProductTable])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.attachedDatabase);

  $ProductTableTable get _table => productTable;

  // Получить список товаров с пагинацией и сортировкой
  Future<PagingList<ProductTableData>> getPaginatedAndSortedProducts({
    required int page,
    required int pageSize,
    OrderingMode? priceOrderingMode,
  }) async {
    final totalItems = await _countAllProducts();
    final totalPages = (totalItems / pageSize).ceil();
    final offset = (page - 1) * pageSize;

    final query = select(_table)
      ..orderBy([
        if (priceOrderingMode case final OrderingMode mode)
          (p) => OrderingTerm(
            expression: p.price,
            mode: mode,
          ),
      ])
      ..limit(pageSize, offset: offset);
    final data = await query.get();

    return PagingList(
      first: 1,
      prev: page > 1 ? page - 1 : null,
      next: page < totalPages ? page + 1 : null,
      last: totalPages,
      pages: totalPages,
      items: totalItems,
      data: data,
    );
  }

  Future<ProductTableData?> getProduct({required int id}) async {
    final stmt = select(_table)..where((t) => t.id.equals(id));
    final result = await stmt.get();
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> insertProduct(ProductTableData product) async {
    await into(_table).insertOnConflictUpdate(product);
    return;
  }

  Future<void> deleteProductById({required int id}) async {
    final stmt = delete(_table)..where((t) => t.id.equals(id));
    await stmt.go();
    return;
  }

  Future<int> _countAllProducts() async {
    final stmt = _table.count();
    final result = await stmt.getSingleOrNull();
    return result ?? 0;
  }
}
