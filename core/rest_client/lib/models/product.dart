// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'category.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@Freezed()
abstract class Product with _$Product {
  const factory Product({
    required dynamic id,
    required String name,
    required String description,
    required double price,
    required String material,
    required Category category,
  }) = _Product;

  factory Product.fromJson(Map<String, Object?> json) => _$ProductFromJson(json);
}
