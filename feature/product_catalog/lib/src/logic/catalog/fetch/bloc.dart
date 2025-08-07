import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:product_catalog/export.dart';
import 'package:product_catalog/src/domain/model/product.dart';

part 'bloc.freezed.dart';

final class FetchProductCatalogBloc
    extends Bloc<FetchProductCatalogEvent, FetchProductCatalogState> {
  FetchProductCatalogBloc(
    this._productCatalogRepository,
    this._logger, {
    required FetchProductCatalogState initialState,
  }) : super(initialState) {
    on<FetchProductCatalogEvent>(
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

  Future<void> _onExecuteEvent(_ExecuteEvent e, Emitter<FetchProductCatalogState> emit) async {
    try {
      emit(FetchProductCatalogState.busy(payload: state.payloadOrNull));
      final payload = await _productCatalogRepository.read(
        priceOrder: e.priceOrder,
        page: e.page,
        pageSize: e.pageSize,
      );
      emit(FetchProductCatalogState.success(payload: payload));
      final products = payload.data;
      if (products.isEmpty) {
        return;
      }
      _writeProductCatalogBloc.add(WriteProductCatalogEvent.execute(products: products));
    } catch (e, st) {
      _logger.error('[FetchProductCatalogBloc._onExecuteEvent]', e, st);
      emit(FetchProductCatalogState.error(error: e, payload: state.payloadOrNull));
    } finally {
      emit(FetchProductCatalogState.idle(payload: state.payloadOrNull));
    }
  }
}

@Freezed(copyWith: false)
sealed class FetchProductCatalogState with _$FetchProductCatalogState {
  const factory FetchProductCatalogState.idle({
    PagingList<Product>? payload,
  }) = _Idle;

  const factory FetchProductCatalogState.busy({
    PagingList<Product>? payload,
  }) = _Busy;
  const factory FetchProductCatalogState.success({
    required PagingList<Product> payload,
  }) = _Success;

  const factory FetchProductCatalogState.error({
    required Object error,
    PagingList<Product>? payload,
  }) = _Error;

  const FetchProductCatalogState._();

  PagingList<Product>? get payloadOrNull => switch (this) {
    _Idle(:final payload) => payload,
    _Success(:final payload) => payload,
    _Busy(:final payload) => payload,
    _Error(:final payload) => payload,
  };

  Object? get errorOrNull => switch (this) {
    _Idle() => null,
    _Busy() => null,
    _Success() => null,
    _Error(:final error) => error,
  };

  bool get isSuccess => this is _Success;
}

@freezed
sealed class FetchProductCatalogEvent with _$FetchProductCatalogEvent {
  const factory FetchProductCatalogEvent.execute({
    required OrderingPriceMode priceOrder,
    required int page,
    required int pageSize,
  }) = _ExecuteEvent;
}
