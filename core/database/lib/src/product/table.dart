// Таблица для хранения Product
import 'package:drift/drift.dart';

class ProductTable extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  RealColumn get price => real()();
  TextColumn get material => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
