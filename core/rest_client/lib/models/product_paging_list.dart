// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'product.dart';

part 'product_paging_list.freezed.dart';
part 'product_paging_list.g.dart';

@Freezed()
abstract class ProductPagingList with _$ProductPagingList {
  const factory ProductPagingList({
    required int first,
    required int? prev,
    required int? next,
    required int last,
    required int pages,
    required int items,
    required List<Product> data,
  }) = _ProductPagingList;

  factory ProductPagingList.fromJson(Map<String, Object?> json) =>
      _$ProductPagingListFromJson(json);
}
