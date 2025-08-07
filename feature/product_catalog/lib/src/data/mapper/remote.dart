import 'dart:convert';

import 'package:product_catalog/src/domain/model/product.dart' as domain;
import 'package:rest_client/models/product.dart' as api;

class ProductRemoteDecoder extends Converter<api.Product, domain.Product> {
  const ProductRemoteDecoder();

  @override
  domain.Product convert(api.Product input) {
    final id = switch (input.id) {
      final String id => int.parse(id),
      final int id => id,
      _ => null,
    };
    if (id == null) {
      throw ArgumentError.value(id, 'Id should be string or int');
    }
    return domain.Product(
      id: id,
      name: input.name,
      description: input.description,
      price: input.price,
      material: input.material,
    );
  }
}
