import 'package:app/src/model/application_config.dart';
import 'package:app/src/model/dependencies_container.dart';
import 'package:clock/clock.dart';
import 'package:database/database.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:product_catalog/export.dart';
import 'package:rest_client/main_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A place where Application-Wide dependencies are initialized.
///
/// Application-Wide dependencies are dependencies that have a global scope,
/// used in the entire application and have a lifetime that is the same as the application.
/// Composes dependencies and returns the result of composition.
Future<CompositionResult> composeDependencies({
  required ApplicationConfig config,
  required Logger logger,
}) async {
  final stopwatch = clock.stopwatch()..start();

  logger.info('Initializing dependencies...');

  // Create the dependencies container using functions.
  final dependencies = await createDependenciesContainer(config, logger);

  stopwatch.stop();
  logger.info('Dependencies initialized successfully in ${stopwatch.elapsedMilliseconds} ms.');

  return CompositionResult(
    dependencies: dependencies,
    millisecondsSpent: stopwatch.elapsedMilliseconds,
  );
}

final class CompositionResult {
  const CompositionResult({required this.dependencies, required this.millisecondsSpent});

  final DependenciesContainer dependencies;
  final int millisecondsSpent;

  @override
  String toString() =>
      'CompositionResult('
      'dependencies: $dependencies, '
      'millisecondsSpent: $millisecondsSpent'
      ')';
}

/// Creates the initialized [DependenciesContainer].
Future<DependenciesContainer> createDependenciesContainer(
  ApplicationConfig config,
  Logger logger,
) async {
  final db = AppDatabase.defaults(name: 'main');

  // Get package info.
  final packageInfo = await PackageInfo.fromPlatform();

  final mainApiClient = createMainApiClient(config, logger);

  final productCatalogContainer = await ProductCatalogContainer.create(mainApiClient, db, logger);

  return DependenciesContainer(
    logger: logger,
    config: config,
    packageInfo: packageInfo,
    productCatalogContainer: productCatalogContainer,
  );
}

/// Creates the [Logger] instance and attaches any provided observers.
Logger createAppLogger() {
  final logger = Logger();

  return logger;
}

MainApiClient createMainApiClient(
  ApplicationConfig config,
    Logger  logger,
) {
  final dio = Dio(BaseOptions(baseUrl: config.baseApiUrl));
  dio.interceptors.add(logger.createDioLogger(logger.createDioLoggerSettings()));
  return MainApiClient(dio);
}
