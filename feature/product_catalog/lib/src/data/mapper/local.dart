import 'dart:convert';

import 'package:database/database.dart' as db;
import 'package:product_catalog/src/domain/model/product.dart' as domain;

class ProductLocalDecoder extends Converter<db.ProductTableData, domain.Product> {
  const ProductLocalDecoder();

  @override
  domain.Product convert(db.ProductTableData input) {
    return domain.Product(
      id: input.id,
      name: input.name,
      description: input.description,
      price: input.price,
      material: input.material,
    );
  }
}

class ProductLocalEncoder extends Converter<domain.Product, db.ProductTableData> {
  const ProductLocalEncoder();

  @override
  db.ProductTableData convert(domain.Product input) {
    return db.ProductTableData(
      id: input.id,
      name: input.name,
      description: input.description,
      price: input.price,
      material: input.material,
    );
  }
}
