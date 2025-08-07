import 'package:database/database.dart';
import 'package:logger/logger.dart';
import 'package:product_catalog/export.dart';
import 'package:product_catalog/src/data/repository/repository_impl.dart';
import 'package:rest_client/main_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

ProductCatalogRepository _createProductCatalogRepository(
  MainApiClient mainApiClient,
  AppDatabase db,
) {
  return ProductCatalogRepositoryImpl(
    mainApiClient,
    db,
  );
}

Future<FetchProductCatalogBloc> _createFetchProductCatalogBloc(
  ProductCatalogRepository productCatalogRepository,
  Logger logger,
) async {
  return FetchProductCatalogBloc(
    productCatalogRepository,
    logger,
    initialState: const FetchProductCatalogState.idle(),
  );
}

/// Container with global settings state.
class ProductCatalogContainer {
  ProductCatalogContainer({
    required this.productCatalogRepository,
    required this.fetchProductCatalogBloc,
  });

  final ProductCatalogRepository productCatalogRepository;

  final FetchProductCatalogBloc fetchProductCatalogBloc;

  static Future<ProductCatalogContainer> create(
    MainApiClient mainApiClient,
    AppDatabase db,
    Logger logger,
  ) async {
    final productCatalogRepository = _createProductCatalogRepository(mainApiClient, db);
    final fetchProductCatalogBloc = await _createFetchProductCatalogBloc(
      productCatalogRepository,
      logger,
    );

    return ProductCatalogContainer(
      productCatalogRepository: productCatalogRepository,
      fetchProductCatalogBloc: fetchProductCatalogBloc,
    );
  }
}
