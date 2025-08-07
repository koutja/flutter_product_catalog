import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:app/src/logic/composition_root.dart';
import 'package:app/src/model/application_config.dart';
import 'package:app/src/widget/initialization_failed_app.dart';
import 'package:app/src/widget/root_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

/// Initializes dependencies and runs app
Future<void> startup() async {
  const config = ApplicationConfig();

  final logger = createAppLogger();

  await runZonedGuarded(
    () async {
      // Ensure Flutter is initialized
      WidgetsFlutterBinding.ensureInitialized();

      // Configure global error interception
      FlutterError.onError = logger.logFlutterError;
      WidgetsBinding.instance.platformDispatcher.onError = logger.logPlatformDispatcherError;

      // Setup bloc observer and transformer
      Bloc.observer = logger.createBlocObserver();
      Bloc.transformer = bloc_concurrency.sequential();

      Future<void> composeAndRun() async {
        try {
          final compositionResult = await composeDependencies(
            config: config,
            logger: logger,
          );

          runApp(RootContext(compositionResult: compositionResult));
        } on Object catch (e, st) {
          logger.error('Initialization failed', e, st);
          runApp(
            InitializationFailedApp(
              error: e,
              stackTrace: st,
              onRetryInitialization: composeAndRun,
            ),
          );
        }
      }

      // Launch the application
      await composeAndRun();
    },
    logger.logZoneError,
  );
}
