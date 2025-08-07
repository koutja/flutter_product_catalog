import 'package:app/src/widget/dependencies_scope.dart';
import 'package:app/src/widget/media_query_override.dart';
import 'package:flutter/material.dart';
import 'package:product_catalog/export.dart';

/// Entry point for the application that uses [MaterialApp].
class MaterialContext extends StatelessWidget {
  const MaterialContext({super.key});

  /// This global key is needed for Flutter to work properly
  /// when Widgets Inspector is enabled.
  static final _globalKey = GlobalKey(debugLabel: 'MaterialContext');

  @override
  Widget build(BuildContext context) {
    const seedColor = Colors.blue;
    final darkTheme = ThemeData(colorSchemeSeed: seedColor, brightness: Brightness.dark);
    final lightTheme = ThemeData(colorSchemeSeed: seedColor, brightness: Brightness.light);

    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const _Home(),
      builder: (context, child) {
        return KeyedSubtree(
          key: _globalKey,
          child: MediaQueryRootOverride(child: child!),
        );
      },
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    final deps = DependenciesScope.of(context);
    final productCatalogDeps = deps.productCatalogContainer;

    return ProductCatalogScreen(
      fetchProductCatalogBloc: productCatalogDeps.fetchProductCatalogBloc,
      onProductTap: (productId) => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => ProductDetailScreen(
            productId: productId,
            fetchProductBloc: FetchProductBloc(
              productCatalogDeps.productCatalogRepository,
              deps.logger,
              initialState: const FetchProductState.idle(),
            ),
            deleteProductBloc: DeleteProductBloc(
              productCatalogDeps.productCatalogRepository,
              deps.logger,
            ),
          ),
        ),
      ),
    );
  }
}
