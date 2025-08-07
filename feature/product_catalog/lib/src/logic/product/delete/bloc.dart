import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:product_catalog/export.dart';

part 'bloc.freezed.dart';

class DeleteProductBloc extends Bloc<DeleteProductEvent, DeleteProductState> {
  DeleteProductBloc(this._productCatalogRepository, this._logger) : super(const DeleteProductState.idle()) {
    on<DeleteProductEvent>((e, emit) => switch (e) {
      _ExecuteEvent() => _onExecuteEvent(e, emit),
    },);
  }

  final ProductCatalogRepository _productCatalogRepository;
  final Logger _logger;

  Future<void> _onExecuteEvent(_ExecuteEvent e, Emitter<DeleteProductState> emit) async {
    try {
      emit(const DeleteProductState.busy());
      await _productCatalogRepository.deleteById(
        id: e.productId,
      );
      emit(const DeleteProductState.success());
    } catch (e, st) {
      _logger.error('[WriteProductCatalogBloc._onExecuteEvent]', e, st);
      emit(DeleteProductState.error(error: e));
    } finally {
      emit(const DeleteProductState.idle());
    }
  }
}

@Freezed(copyWith: false)
sealed class DeleteProductState with _$DeleteProductState {
  const factory DeleteProductState.idle() = _Idle;

  const factory DeleteProductState.busy() = _Busy;

  const factory DeleteProductState.success() = _Success;

  const factory DeleteProductState.error({required Object error}) = _Error;

  const DeleteProductState._();

  Object? get errorOrNull => switch (this) {
    _Idle() => null,
    _Busy() => null,
    _Success() => null,
    _Error(:final error) => error,
  };

  bool get isBusy => this is _Busy;

  bool get isSuccess => this is _Success;
}

@freezed
sealed class DeleteProductEvent with _$DeleteProductEvent {
  const factory DeleteProductEvent.execute({
    required int productId,
  }) = _ExecuteEvent;
}
