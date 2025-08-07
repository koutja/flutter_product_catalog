import 'package:flutter/foundation.dart';
import 'package:logger/src/wrap_stack_trace.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_observer.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';
import 'package:talker_flutter/talker_flutter.dart';

class Logger {
  factory Logger() {
    final talker = TalkerFlutter.init(
      logger: TalkerLogger(
        settings: TalkerLoggerSettings(
          enableColors: ![TargetPlatform.iOS].contains(defaultTargetPlatform),
        ),
      ),
    );
    return Logger._(talker);
  }

  Logger._(this._talker);

  final Talker _talker;

  @visibleForTesting
  Talker get talker => _talker;

  TalkerDioLoggerSettings createDioLoggerSettings() {
    return const TalkerDioLoggerSettings(printResponseData: false);
  }

  TalkerDioLogger createDioLogger([TalkerDioLoggerSettings? settings]) => TalkerDioLogger(
    talker: _talker,
    settings: settings ?? const TalkerDioLoggerSettings(),
  );

  TalkerRouteObserver createRouteObserver() => TalkerRouteObserver(_talker);

  TalkerBlocObserver createBlocObserver() => TalkerBlocObserver(talker: _talker);

  void handle(Object exception, [StackTrace? stackTrace, dynamic msg]) =>
      _talker.handle(exception, stackTrace, msg);

  void log(
    dynamic msg, {
    LogLevel logLevel = LogLevel.debug,
    Object? exception,
    StackTrace? stackTrace,
    AnsiPen? pen,
  }) =>
      _talker.log(msg, logLevel: logLevel, exception: exception, stackTrace: stackTrace, pen: pen);

  MessagePrinter get critical => _wrapStackTrace(_talker.critical);

  MessagePrinter get debug => _wrapStackTrace(_talker.debug);

  MessagePrinter get error => _wrapStackTrace(_talker.error);

  MessagePrinter get info => _wrapStackTrace(_talker.info);

  MessagePrinter get verbose => _wrapStackTrace(_talker.verbose);

  MessagePrinter get warning => _wrapStackTrace(_talker.warning);

  /// Logs a zone error with [LogLevel.error].
  void logZoneError(Object throwable, StackTrace stackTrace) {
    handle(throwable, wrapStackTrace(stackTrace), '[Zone.onError]');
  }

  /// Logs a flutter error with [LogLevel.error].
  void logFlutterError(FlutterErrorDetails details) =>
      handle(details.exception, wrapStackTrace(details.stack), '[Flutter.onError]');

  /// Logs a platform dispatcher error with [LogLevel.error].
  bool logPlatformDispatcherError(Object throwable, StackTrace stackTrace) {
    handle(throwable, wrapStackTrace(stackTrace), '[Platform.onError]');

    return true;
  }
}

typedef MessagePrinter = void Function(dynamic msg, [Object? exception, StackTrace? stackTrace]);

MessagePrinter _wrapStackTrace(MessagePrinter inner) {
  return (dynamic msg, [Object? exception, StackTrace? stackTrace]) =>
      inner(msg, exception, stackTrace == null ? null : wrapStackTrace(stackTrace));
}

final l = Logger();
