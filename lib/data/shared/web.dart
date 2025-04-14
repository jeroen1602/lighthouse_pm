import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

import '../database.dart';

LighthouseDatabase constructDb({final bool logStatements = false}) {
  final connection = DatabaseConnection.delayed(
    Future(() async {
      final result = await WasmDatabase.open(
        databaseName: 'LighthouseDatabase',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );

      if (result.missingFeatures.isNotEmpty) {
        // Depending how central local persistence is to your app, you may want
        // to show a warning to the user if only unreliable implementations
        // are available.
        databaseLogger.info(
          'Using ${result.chosenImplementation} due to missing browser '
          'features: ${result.missingFeatures}',
        );
      }

      return result.resolvedExecutor;
    }),
  );

  return LighthouseDatabase(connection);
}
