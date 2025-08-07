import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@Freezed()
abstract class Product with _$Product {
  const factory Product({
    required int id,
    required String name,
    required String description,
    required double price,
    required String material,
  }) = _Product;

  const Product._();
}
