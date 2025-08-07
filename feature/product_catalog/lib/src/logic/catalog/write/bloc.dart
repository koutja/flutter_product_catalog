import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:product_catalog/export.dart';
import 'package:product_catalog/src/domain/model/product.dart';

part 'bloc.freezed.dart';

final class WriteProductCatalogBloc
    extends Bloc<WriteProductCatalogEvent, WriteProductCatalogState> {
  WriteProductCatalogBloc(
    this._productCatalogRepository,
    this._logger, {
    required WriteProductCatalogState initialState,
  }) : super(initialState) {
    on<WriteProductCatalogEvent>(
      (e, emit) => switch (e) {
        _ExecuteEvent() => _onExecuteEvent(e, emit),
      },
    );
  }

  final ProductCatalogRepository _productCatalogRepository;
  final Logger _logger;

  Future<void> _onExecuteEvent(_ExecuteEvent e, Emitter<WriteProductCatalogState> emit) async {
    try {
      emit(const WriteProductCatalogState.busy());
      await _productCatalogRepository.write(
        products: e.products,
      );
      emit(const WriteProductCatalogState.idle());
    } catch (e, st) {
      _logger.error('[WriteProductCatalogBloc._onExecuteEvent]', e, st);
      emit(WriteProductCatalogState.error(error: e));
    } finally {
      emit(const WriteProductCatalogState.idle());
    }
  }
}

@Freezed(copyWith: false)
sealed class WriteProductCatalogState with _$WriteProductCatalogState {
  const factory WriteProductCatalogState.idle() = _Idle;

  const factory WriteProductCatalogState.busy() = _Busy;

  const factory WriteProductCatalogState.error({required Object error}) = _Error;
}

@freezed
sealed class WriteProductCatalogEvent with _$WriteProductCatalogEvent {
  const factory WriteProductCatalogEvent.execute({
    required Iterable<Product> products,
  }) = _ExecuteEvent;
}
