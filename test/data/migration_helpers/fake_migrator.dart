import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeGenerator extends Fake implements GenerationContext {
  @override
  SqlDialect get dialect => SqlDialect.sqlite;
}

class MigrationError extends Error {
  MigrationError(this.message);

  final String message;

  @override
  String toString() {
    return message;
  }
}

class FakeMigrator extends Fake implements Migrator {
  FakeMigrator(this.seedSchema);

  int seedSchema;
  TestSchema? currentSchema;
  int? toHint;
  FakeGenerator generator = FakeGenerator();

  @override
  Future<void> createAll() async {
    currentSchema = FinalSchemas.schemas[seedSchema]!.copy();
  }

  @override
  Future<void> renameColumn(
    final TableInfo<Table, dynamic> table,
    final String oldName,
    final GeneratedColumn column,
  ) async {
    final testTable = currentSchema!.testTables.cast<TestTable?>().firstWhere(
      (final element) => element!.tableName == table.actualTableName,
      orElse: () => null,
    );
    if (testTable == null) {
      throw MigrationError("Could not find table ${table.actualTableName}");
    }

    final testColumn = testTable.columns.cast<TestColumn?>().firstWhere(
      (final element) => element!.columnName == oldName,
      orElse: () => null,
    );
    if (testColumn == null) {
      throw MigrationError(
        "Could not find column '$oldName' in table: '${testTable.tableName}'",
      );
    }

    testColumn.columnName = column.name;
  }

  @override
  Future<void> createTable(final TableInfo<Table, dynamic> table) async {
    final String tableName =
        (toHint != null
            ? (FinalSchemas.tableRename[toHint]?[table.actualTableName])
            : null) ??
        table.actualTableName;

    final testTable = currentSchema!.testTables.cast<TestTable?>().firstWhere(
      (final element) => element!.tableName == tableName,
      orElse: () => null,
    );
    if (testTable != null) {
      throw MigrationError("Table already exists! $tableName");
    }

    if (toHint != null) {
      final testTable = FinalSchemas.schemas[toHint]?.testTables
          .cast<TestTable?>()
          .firstWhere(
            (final element) => element!.tableName == tableName,
            orElse: () => null,
          );
      if (testTable != null) {
        currentSchema!.testTables.add(testTable.copy());
        return;
      }
      debugPrint(
        "Warning: could not find table $tableName in final schema version $toHint",
      );
    }

    final columns =
        table.columnsByName.entries.map((final entry) {
          return TestColumn(
            entry.key,
            TestColumn.columnTypeFromDriftTypeString(
              entry.value.type.sqlTypeName(generator),
            ),
          );
        }).toList();

    currentSchema!.testTables.add(TestTable(tableName, columns));
  }

  @override
  Future<void> deleteTable(final String name) async {
    final index = currentSchema!.testTables.indexWhere(
      (final element) => element.tableName == name,
    );
    if (index < 0) {
      throw MigrationError(
        "Can't remove table because it doesn't exists ($name)",
      );
    }
    currentSchema!.testTables.removeAt(index);
  }

  @override
  Future<void> alterTable(final TableMigration migration) async {
    final testTable = currentSchema!.testTables.cast<TestTable?>().firstWhere(
      (final element) =>
          element!.tableName == migration.affectedTable.actualTableName,
      orElse: () => null,
    );
    if (testTable == null) {
      throw MigrationError(
        "Table doesn't exists, so it can't be altered! ${migration.affectedTable.actualTableName}",
      );
    }

    if (toHint != null) {
      final testTable = FinalSchemas.schemas[toHint]?.testTables
          .cast<TestTable?>()
          .firstWhere(
            (final element) =>
                element!.tableName == migration.affectedTable.actualTableName,
            orElse: () => null,
          );
      if (testTable != null) {
        currentSchema!.testTables.add(testTable.copy());
        return;
      }
      debugPrint(
        "Warning: could not find table ${migration.affectedTable.actualTableName} in final schema version $toHint",
      );
    }

    final columns =
        migration.affectedTable.columnsByName.entries.map((final entry) {
          return TestColumn(
            entry.key,
            TestColumn.columnTypeFromDriftTypeString(
              entry.value.type.sqlTypeName(generator),
            ),
          );
        }).toList();

    testTable.columns = columns;
  }

  @override
  Future<void> renameTable(
    final TableInfo<Table, dynamic> table,
    final String oldName,
  ) async {
    final testTable = currentSchema!.testTables.cast<TestTable?>().firstWhere(
      (final element) => element!.tableName == oldName,
      orElse: () => null,
    );
    if (testTable == null) {
      throw MigrationError(
        "Table doesn't exists, so it can't be renamed! $oldName",
      );
    }

    testTable.tableName = table.actualTableName;
  }
}

enum ColumnType { integer, string, dateTime }

class TestColumnIncorrectError extends Error {
  TestColumnIncorrectError(this.sample, this.truth);

  final TestColumn sample;
  final TestColumn truth;

  bool incorrectType() {
    return sample.type != truth.type;
  }

  bool incorrectName() {
    return sample.columnName != truth.columnName;
  }

  @override
  String toString() {
    String output = "";
    if (incorrectName()) {
      output +=
          "Name incorrect for column '${truth.columnName}', was '${sample.columnName}'\n";
    }
    if (incorrectType()) {
      if (output.isEmpty) {
        output += "Type incorrect for column '${truth.columnName}'. ";
      } else {
        output +=
            "Type incorrect for column (truth '${truth.columnName}' actual '${sample.columnName}'). ";
      }
      output +=
          "Expected ${TestColumn.columnTypeToString(truth.type)}, was "
          "${TestColumn.columnTypeToString(truth.type)}.\n";
    }

    if (output.isEmpty) {
      return "Not sure what is wrong with column (truth '${truth.columnName}' actual '${sample.columnName}').";
    }
    return output;
  }
}

class TestTableIncorrectError extends Error {
  TestTableIncorrectError(
    this.sample,
    this.truth,
    this.extraColumns,
    this.missingColumns,
    this.incorrectColumnErrors,
  );

  final TestTable sample;
  final TestTable truth;
  final List<TestColumn> extraColumns;
  final List<TestColumn> missingColumns;
  final List<TestColumnIncorrectError> incorrectColumnErrors;

  @override
  String toString() {
    String output = "Error for table ${truth.tableName}.\n";
    if (extraColumns.isNotEmpty) {
      output += "Extra columns:\n";
      output += extraColumns.fold(
        "",
        (final previousValue, final element) =>
            "$previousValue\t${element.toString()}\n",
      );
    }
    if (missingColumns.isNotEmpty) {
      output += "Missing columns:\n";
      output += missingColumns.fold(
        "",
        (final previousValue, final element) =>
            "$previousValue\t${element.toString()}\n",
      );
    }
    if (incorrectColumnErrors.isNotEmpty) {
      output += "Incorrect columns:\n";
      output += incorrectColumnErrors.fold(
        "",
        (final previousValue, final element) =>
            "$previousValue\t${element.toString()}\n",
      );
    }

    return output;
  }
}

class TestSchemaIncorrectError extends Error {
  TestSchemaIncorrectError(
    this.sample,
    this.truth,
    this.extraTables,
    this.missingTables,
    this.incorrectTableErrors,
  );

  final TestSchema sample;
  final TestSchema truth;
  final List<TestTable> extraTables;
  final List<TestTable> missingTables;
  final List<TestTableIncorrectError> incorrectTableErrors;

  @override
  String toString() {
    String output = "Error for schema!\n";
    if (extraTables.isNotEmpty) {
      output += "Extra tables:\n";
      output += extraTables.fold(
        "",
        (final previousValue, final element) =>
            "$previousValue\t${element.tableName}\n",
      );
    }
    if (missingTables.isNotEmpty) {
      output += "Missing tables:\n";
      output += missingTables.fold(
        "",
        (final previousValue, final element) =>
            "$previousValue\t${element.tableName}\n",
      );
    }
    if (incorrectTableErrors.isNotEmpty) {
      output += "Incorrect tables:\n";
      for (final tableError in incorrectTableErrors) {
        output += tableError
            .toString()
            .split("\n")
            .where((final element) => element.trim().isNotEmpty)
            .fold(
              "",
              (final previousValue, final element) =>
                  "$previousValue\t$element\n",
            );
      }
    }

    return output;
  }
}

class TestColumn {
  TestColumn(this.columnName, this.type);

  String columnName;
  ColumnType type;

  TestColumn copy() {
    return TestColumn(columnName, type);
  }

  bool compare(final TestColumn truth, [final bool shouldThrow = true]) {
    final bool nameIncorrect = columnName != truth.columnName;
    final bool typeIncorrect = type != truth.type;
    if (nameIncorrect || typeIncorrect) {
      if (shouldThrow) {
        throw TestColumnIncorrectError(this, truth);
      }
      return false;
    }

    return true;
  }

  @override
  String toString() {
    return 'Column {"columnName": "$columnName", "type": "${columnTypeToString(type)}"}';
  }

  static String columnTypeToString(final ColumnType type) {
    switch (type) {
      case ColumnType.integer:
        return 'integer';
      case ColumnType.string:
        return 'string';
      case ColumnType.dateTime:
        return 'dateTime';
    }
  }

  static ColumnType columnTypeFromDriftTypeString(final String type) {
    switch (type) {
      case 'INTEGER':
        return ColumnType.integer;
      case 'TEXT':
        return ColumnType.string;
      case 'DATETIME':
        return ColumnType.dateTime;
    }
    throw UnsupportedError('I don\'t know the type $type');
  }
}

class TestTable {
  TestTable(this.tableName, this.columns);

  String tableName;
  List<TestColumn> columns;

  TestTable copy() {
    return TestTable(tableName, columns.map((final e) => e.copy()).toList());
  }

  bool compare(final TestTable truth, [final bool shouldThrow = true]) {
    final List<TestColumn> extraColumns = [];
    final List<TestColumn> missingColumns = [];
    // Look for extra columns.
    for (final column in columns) {
      if (truth.columns.indexWhere(
            (final element) => element.columnName == column.columnName,
          ) <
          0) {
        // we've got an extra column.
        extraColumns.add(column);
      }
    }

    // Look for missing columns.
    for (final column in truth.columns) {
      if (columns.indexWhere(
            (final element) => element.columnName == column.columnName,
          ) <
          0) {
        // we've got a missing column.
        missingColumns.add(column);
      }
    }

    final List<TestColumn> incorrectColumns = [];
    final List<TestColumnIncorrectError> incorrectColumnErrors = [];

    for (final column in columns) {
      final index = truth.columns.indexWhere(
        (final element) => element.columnName == column.columnName,
      );
      if (index >= 0) {
        try {
          if (!column.compare(truth.columns[index], shouldThrow)) {
            incorrectColumns.add(column);
          }
        } catch (e) {
          if (e is TestColumnIncorrectError) {
            incorrectColumnErrors.add(e);
          } else {
            rethrow;
          }
        }
      }
    }

    if (extraColumns.isNotEmpty ||
        missingColumns.isNotEmpty ||
        incorrectColumns.isNotEmpty ||
        incorrectColumnErrors.isNotEmpty) {
      if (shouldThrow) {
        throw TestTableIncorrectError(
          this,
          truth,
          extraColumns,
          missingColumns,
          incorrectColumnErrors,
        );
      }
      return false;
    }

    return true;
  }
}

class TestSchema {
  TestSchema(this.testTables);

  List<TestTable> testTables;

  TestSchema copy() {
    return TestSchema(testTables.map((final e) => e.copy()).toList());
  }

  bool compare(final TestSchema truth, [final bool shouldThrow = true]) {
    final List<TestTable> extraTables = [];
    final List<TestTable> missingTables = [];
    // Look for extra tables.
    for (final table in testTables) {
      if (truth.testTables.indexWhere(
            (final element) => element.tableName == table.tableName,
          ) <
          0) {
        // we've got an extra table.
        extraTables.add(table);
      }
    }
    // Look for missing tables.
    for (final table in truth.testTables) {
      if (testTables.indexWhere(
            (final element) => element.tableName == table.tableName,
          ) <
          0) {
        // we've got an missing table.
        missingTables.add(table);
      }
    }

    final List<TestTable> incorrectTables = [];
    final List<TestTableIncorrectError> incorrectTableErrors = [];

    for (final table in testTables) {
      final index = truth.testTables.indexWhere(
        (final element) => element.tableName == table.tableName,
      );
      if (index >= 0) {
        try {
          if (!table.compare(truth.testTables[index], shouldThrow)) {
            incorrectTables.add(table);
          }
        } catch (e) {
          if (e is TestTableIncorrectError) {
            incorrectTableErrors.add(e);
          } else {
            rethrow;
          }
        }
      }
    }

    if (extraTables.isNotEmpty ||
        missingTables.isNotEmpty ||
        incorrectTables.isNotEmpty ||
        incorrectTableErrors.isNotEmpty) {
      if (shouldThrow) {
        throw TestSchemaIncorrectError(
          this,
          truth,
          extraTables,
          missingTables,
          incorrectTableErrors,
        );
      }
      return false;
    }

    return true;
  }
}

abstract class FinalSchemas {
  static final tableRename = {
    1: {},
    2: {},
    3: {"groups": "\"\"groups\"\""},
    4: {},
  };

  static final schemas = {
    1: TestSchema([
      TestTable('last_seen_devices', [
        TestColumn('mac_address', ColumnType.string),
        TestColumn('lastSeen', ColumnType.dateTime),
      ]),
      TestTable('nicknames', [
        TestColumn('mac_address', ColumnType.string),
        TestColumn('nickname', ColumnType.string),
      ]),
      TestTable('simple_settings', [
        TestColumn('id', ColumnType.integer),
        TestColumn('data', ColumnType.string),
      ]),
      TestTable('vive_base_station_ids', [
        TestColumn('id', ColumnType.integer),
      ]),
    ]),
    2: TestSchema([
      TestTable('last_seen_devices', [
        TestColumn('mac_address', ColumnType.string),
        TestColumn('lastSeen', ColumnType.dateTime),
      ]),
      TestTable('nicknames', [
        TestColumn('mac_address', ColumnType.string),
        TestColumn('nickname', ColumnType.string),
      ]),
      TestTable('simple_settings', [
        TestColumn('settings_id', ColumnType.integer),
        TestColumn('data', ColumnType.string),
      ]),
      TestTable('vive_base_station_ids', [
        TestColumn('id', ColumnType.integer),
      ]),
    ]),
    3: TestSchema([
      TestTable('""groups""', [
        TestColumn('id', ColumnType.integer),
        TestColumn('name', ColumnType.string),
      ]),
      TestTable('group_entries', [
        TestColumn('mac_address', ColumnType.string),
        TestColumn('group_id', ColumnType.integer),
      ]),
      TestTable('last_seen_devices', [
        TestColumn('mac_address', ColumnType.string),
        TestColumn('lastSeen', ColumnType.dateTime),
      ]),
      TestTable('nicknames', [
        TestColumn('mac_address', ColumnType.string),
        TestColumn('nickname', ColumnType.string),
      ]),
      TestTable('simple_settings', [
        TestColumn('settings_id', ColumnType.integer),
        TestColumn('data', ColumnType.string),
      ]),
      TestTable('vive_base_station_ids', [
        TestColumn('id', ColumnType.integer),
      ]),
    ]),
    4: TestSchema([
      TestTable('groups', [
        TestColumn('id', ColumnType.integer),
        TestColumn('name', ColumnType.string),
      ]),
      TestTable('group_entries', [
        TestColumn('device_id', ColumnType.string),
        TestColumn('group_id', ColumnType.integer),
      ]),
      TestTable('last_seen_devices', [
        TestColumn('device_id', ColumnType.string),
        TestColumn('lastSeen', ColumnType.dateTime),
      ]),
      TestTable('nicknames', [
        TestColumn('device_id', ColumnType.string),
        TestColumn('nickname', ColumnType.string),
      ]),
      TestTable('simple_settings', [
        TestColumn('settings_id', ColumnType.integer),
        TestColumn('data', ColumnType.string),
      ]),
      TestTable('vive_base_station_ids', [
        TestColumn('device_id', ColumnType.string),
        TestColumn('base_station_id', ColumnType.integer),
      ]),
    ]),
  };

  static const expectedErrors = {
    '1to2':
        'Error for schema!\n'
        'Incorrect tables:\n'
        '\tError for table simple_settings.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "id", "type": "integer"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "settings_id", "type": "integer"}\n',
    '1to3':
        'Error for schema!\n'
        'Missing tables:\n'
        '\t""groups""\n'
        '\tgroup_entries\n'
        'Incorrect tables:\n'
        '\tError for table simple_settings.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "id", "type": "integer"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "settings_id", "type": "integer"}\n',
    '1to4':
        'Error for schema!\n'
        'Missing tables:\n'
        '\tgroups\n'
        '\tgroup_entries\n'
        'Incorrect tables:\n'
        '\tError for table last_seen_devices.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "mac_address", "type": "string"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\tError for table nicknames.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "mac_address", "type": "string"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\tError for table simple_settings.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "id", "type": "integer"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "settings_id", "type": "integer"}\n'
        '\tError for table vive_base_station_ids.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "id", "type": "integer"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\t\tColumn {"columnName": "base_station_id", "type": "integer"}\n',
    '2to1':
        'Error for schema!\n'
        'Incorrect tables:\n'
        '\tError for table simple_settings.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "settings_id", "type": "integer"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "id", "type": "integer"}\n',
    '2to3':
        'Error for schema!\n'
        'Missing tables:\n'
        '\t""groups""\n'
        '\tgroup_entries\n',
    '2to4':
        'Error for schema!\n'
        'Missing tables:\n'
        '\tgroups\n'
        '\tgroup_entries\n'
        'Incorrect tables:\n'
        '\tError for table last_seen_devices.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "mac_address", "type": "string"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\tError for table nicknames.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "mac_address", "type": "string"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\tError for table vive_base_station_ids.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "id", "type": "integer"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\t\tColumn {"columnName": "base_station_id", "type": "integer"}\n',
    '3to1':
        'Error for schema!\n'
        'Extra tables:\n'
        '\t""groups""\n'
        '\tgroup_entries\n'
        'Incorrect tables:\n'
        '\tError for table simple_settings.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "settings_id", "type": "integer"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "id", "type": "integer"}\n',
    '3to2':
        'Error for schema!\n'
        'Extra tables:\n'
        '\t""groups""\n'
        '\tgroup_entries\n',
    '3to4':
        'Error for schema!\n'
        'Extra tables:\n'
        '\t""groups""\n'
        'Missing tables:\n'
        '\tgroups\n'
        'Incorrect tables:\n'
        '\tError for table group_entries.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "mac_address", "type": "string"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\tError for table last_seen_devices.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "mac_address", "type": "string"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\tError for table nicknames.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "mac_address", "type": "string"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\tError for table vive_base_station_ids.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "id", "type": "integer"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\t\tColumn {"columnName": "base_station_id", "type": "integer"}\n',
    '4to1':
        'Error for schema!\n'
        'Extra tables:\n'
        '\tgroups\n'
        '\tgroup_entries\n'
        'Incorrect tables:\n'
        '\tError for table last_seen_devices.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "mac_address", "type": "string"}\n'
        '\tError for table nicknames.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "mac_address", "type": "string"}\n'
        '\tError for table simple_settings.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "settings_id", "type": "integer"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "id", "type": "integer"}\n'
        '\tError for table vive_base_station_ids.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\t\tColumn {"columnName": "base_station_id", "type": "integer"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "id", "type": "integer"}\n',
    '4to2':
        'Error for schema!\n'
        'Extra tables:\n'
        '\tgroups\n'
        '\tgroup_entries\n'
        'Incorrect tables:\n'
        '\tError for table last_seen_devices.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "mac_address", "type": "string"}\n'
        '\tError for table nicknames.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "mac_address", "type": "string"}\n'
        '\tError for table vive_base_station_ids.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\t\tColumn {"columnName": "base_station_id", "type": "integer"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "id", "type": "integer"}\n',
    '4to3':
        'Error for schema!\n'
        'Extra tables:\n'
        '\tgroups\n'
        'Missing tables:\n'
        '\t""groups""\n'
        'Incorrect tables:\n'
        '\tError for table group_entries.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "mac_address", "type": "string"}\n'
        '\tError for table last_seen_devices.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "mac_address", "type": "string"}\n'
        '\tError for table nicknames.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "mac_address", "type": "string"}\n'
        '\tError for table vive_base_station_ids.\n'
        '\tExtra columns:\n'
        '\t\tColumn {"columnName": "device_id", "type": "string"}\n'
        '\t\tColumn {"columnName": "base_station_id", "type": "integer"}\n'
        '\tMissing columns:\n'
        '\t\tColumn {"columnName": "id", "type": "integer"}\n',
  };
}
