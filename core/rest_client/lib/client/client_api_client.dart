// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/product.dart';
import '../models/product_paging_list.dart';

part 'client_api_client.g.dart';

@RestApi()
abstract class ClientApiClient {
  factory ClientApiClient(Dio dio, {String? baseUrl}) = _ClientApiClient;

  /// Get all products.
  ///
  /// [privateStart] - Start index for pagination.
  ///
  /// [privateEnd] - End index for pagination.
  ///
  /// [privateLimit] - Limit the number of results.
  ///
  /// [privatePage] - Page number for pagination.
  ///
  /// [privatePerPage] - Number of items per page.
  ///
  /// [privateSort] - Sort by field(s), prefix with `-` for descending.
  ///
  /// [privateEmbed] - Embed related resources (e.g., categories).
  ///
  /// [id] - Filter by product ID.
  ///
  /// [name] - Filter by product name.
  ///
  /// [priceGt] - Filter by price greater than.
  ///
  /// [priceGte] - Filter by price greater than or equal to.
  ///
  /// [priceLt] - Filter by price less than.
  ///
  /// [priceLte] - Filter by price less than or equal to.
  ///
  /// [material] - Filter by material.
  ///
  /// [categoryId] - Filter by category ID.
  @GET('/products')
  Future<HttpResponse<ProductPagingList>> getAllProducts({
    @Query('_start') int? privateStart,
    @Query('_end') int? privateEnd,
    @Query('_limit') int? privateLimit,
    @Query('_page') int? privatePage,
    @Query('_per_page') int? privatePerPage,
    @Query('_sort') String? privateSort,
    @Query('_embed') String? privateEmbed,
    @Query('id') int? id,
    @Query('name') String? name,
    @Query('price_gt') num? priceGt,
    @Query('price_gte') num? priceGte,
    @Query('price_lt') num? priceLt,
    @Query('price_lte') num? priceLte,
    @Query('material') String? material,
    @Query('category.id') int? object0,
  });

  /// Create a new product
  @POST('/products')
  Future<HttpResponse<Product>> createProduct({
    @Body() required Product body,
  });

  /// Get a specific product by ID.
  ///
  /// [id] - ID of the product.
  @GET('/products/{id}')
  Future<HttpResponse<Product>> getProduct({
    @Path('id') required int id,
  });

  /// Update a product by ID.
  ///
  /// [id] - ID of the product.
  @PUT('/products/{id}')
  Future<HttpResponse<Product>> putProduct({
    @Path('id') required int id,
    @Body() required Product body,
  });

  /// Partially update a product by ID.
  ///
  /// [id] - ID of the product.
  @PATCH('/products/{id}')
  Future<HttpResponse<Product>> patchProduct({
    @Path('id') required int id,
    @Body() required Product body,
  });

  /// Delete a product by ID.
  ///
  /// [id] - ID of the product.
  @DELETE('/products/{id}')
  Future<HttpResponse<void>> deleteProduct({
    @Path('id') required int id,
  });
}
