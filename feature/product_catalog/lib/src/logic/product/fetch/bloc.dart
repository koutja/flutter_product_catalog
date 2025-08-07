import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:product_catalog/export.dart';
import 'package:product_catalog/src/domain/model/product.dart';

part 'bloc.freezed.dart';

class FetchProductBloc extends Bloc<FetchProductEvent, FetchProductState> {
  FetchProductBloc(
    this._productCatalogRepository,
    this._logger, {
    required FetchProductState initialState,
  }) : super(initialState) {
    on<FetchProductEvent>(
      (e, emit) => switch (e) {
        _ExecuteEvent() => _onExecuteEvent(e, emit),
      },
    );
  }

  final ProductCatalogRepository _productCatalogRepository;
  final Logger _logger;

  late final _writeProductCatalogBloc = WriteProductCatalogBloc(
    _productCatalogRepository,
    _logger,
    initialState: const WriteProductCatalogState.idle(),
  );

  Future<void> _onExecuteEvent(_ExecuteEvent e, Emitter<FetchProductState> emit) async {
    try {
      emit(FetchProductState.busy(product: state.productOrNull));
      final product = await _productCatalogRepository.readById(
        id: e.productId,
      );
      emit(FetchProductState.success(product: product));
      if (product == null) {
        return;
      }
      _writeProductCatalogBloc.add(WriteProductCatalogEvent.execute(products: [product]));
    } catch (e, st) {
      _logger.error('[FetchProductCatalogBloc._onExecuteEvent]', e, st);
      emit(FetchProductState.error(error: e, product: state.productOrNull));
    } finally {
      emit(FetchProductState.idle(product: state.productOrNull));
    }
  }
}

@Freezed(copyWith: false)
sealed class FetchProductState with _$FetchProductState {
  const factory FetchProductState.idle({Product? product}) = _Idle;

  const factory FetchProductState.busy({Product? product}) = _Busy;

  const factory FetchProductState.success({Product? product}) = _Success;

  const factory FetchProductState.error({required Object error, Product? product}) = _Error;

  const FetchProductState._();

  Product? get productOrNull => switch (this) {
    _Idle(:final product) => product,
    _Busy(:final product) => product,
    _Success(:final product) => product,
    _Error(:final product) => product,
  };

  Object? get errorOrNull => switch (this) {
    _Idle() => null,
    _Busy() => null,
    _Success() => null,
    _Error(:final error) => error,
  };

  bool get isBusy => this is _Busy;
}

@freezed
sealed class FetchProductEvent with _$FetchProductEvent {
  const factory FetchProductEvent.execute({
    required int productId,
  }) = _ExecuteEvent;
}
