import 'package:drift/drift.dart'
    show
        MigrationStrategy,
        OpeningDetails,
        QueryExecutor,
        QueryExecutorUser,
        TransactionExecutor,
        driftRuntimeOptions;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/data/database.dart';

import 'migration_helpers/fake_migrator.dart';

class FakeQueryExecutor extends Fake implements TransactionExecutor {
  @override
  Future<bool> ensureOpen(final QueryExecutorUser user) async {
    return true;
  }

  String? lastStatement;

  @override
  Future<void> runCustom(final String statement,
      [final List<Object?>? args]) async {
    lastStatement = statement;
  }

  @override
  TransactionExecutor beginTransaction() {
    return this;
  }

  @override
  Future<void> send() async {
    // doing nothing is nice.
  }

  @override
  Future<void> rollback() async {
    throw MigrationError("Got to a rollback, which shouldn't happen!");
  }
}

class FakeOpeningDetails extends Fake implements OpeningDetails {}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('Final schemas shouldn\'t match each other', () {
    final schemas = FinalSchemas.schemas;
    for (final schema1 in schemas.entries) {
      for (final schema2 in schemas.entries) {
        if (schema1.key == schema2.key) {
          final value = schema1.value.compare(schema2.value);
          expect(value, isTrue,
              reason:
                  "Schema version ${schema1.key} should match version ${schema2.key}");
        } else {
          try {
            schema1.value.compare(schema2.value);
            fail('Should throw!');
          } catch (e) {
            expect(e, isA<TestSchemaIncorrectError>());
            final String key = '${schema1.key}to${schema2.key}';
            debugPrint('Checking error for: $key');
            expect(e.toString(), FinalSchemas.expectedErrors[key]);
          }
        }
      }
    }
  });

  test('Should create correct schemas', () async {
    final strategy = getMigrationStrategy();

    for (final finalSchema in FinalSchemas.schemas.entries) {
      final migrator = FakeMigrator(finalSchema.key);

      await strategy.onCreate(migrator);

      expect(migrator.currentSchema, isNotNull,
          reason:
              'Current schema should not be null for schema version ${finalSchema.key}');
      expect(migrator.currentSchema!.compare(finalSchema.value), isTrue,
          reason:
              'Current schema should match final schema version ${finalSchema.key}');
    }
  });

  test('Should upgrade from lower schemas to higher schemas', () async {
    final strategy = getMigrationStrategy();

    for (final schemaStart in FinalSchemas.schemas.entries) {
      for (final schemaEnd in FinalSchemas.schemas.entries) {
        if (schemaEnd.key <= schemaStart.key) {
          continue;
        }
        debugPrint(
            "Test migrating from schema version ${schemaStart.key} to ${schemaEnd.key}");
        final migrator = FakeMigrator(schemaStart.key);
        migrator.toHint = schemaEnd.key;

        await strategy.onCreate(migrator);

        expect(migrator.currentSchema, isNotNull,
            reason: 'Should have a starting schema');
        await strategy.onUpgrade(migrator, schemaStart.key, schemaEnd.key);

        expect(migrator.currentSchema!.compare(schemaEnd.value), isTrue,
            reason: 'Should have migrated to the new schema');
      }
    }
  });

  test('Current schema version should exist', () async {
    final db = getDatabase();

    expect(FinalSchemas.schemas[db.schemaVersion], isNotNull,
        reason:
            'There should be a known schema available for the current schema version.');
  });

  test('Before open should enable foreign keys', () async {
    final executor = FakeQueryExecutor();
    final db = getDatabase(executor);
    final strategy = getMigrationStrategy(db);
    final details = FakeOpeningDetails();

    await strategy.beforeOpen!(details);

    expect(executor.lastStatement, 'PRAGMA foreign_keys = ON');
  });
}

LighthouseDatabase getDatabase([QueryExecutor? executor]) {
  executor ??= FakeQueryExecutor();
  return LighthouseDatabase(executor);
}

MigrationStrategy getMigrationStrategy([LighthouseDatabase? database]) {
  database ??= getDatabase();
  return database.migration;
}
