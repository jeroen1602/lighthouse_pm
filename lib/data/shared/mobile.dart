import 'dart:io';

import 'package:lighthouse_pm/data/database.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as paths;

LighthouseDatabase constructDb({final bool logStatements = false}) {
  if (Platform.isIOS || Platform.isAndroid) {
    final executor = LazyDatabase(() async {
      final dbFolder = await paths.getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      return NativeDatabase(file, logStatements: logStatements);
    });
    return LighthouseDatabase(executor);
  }
  if (Platform.isMacOS || Platform.isLinux) {
    final executor = LazyDatabase(() async {
      final dbFolder = await paths.getApplicationSupportDirectory();
      final file = File(p.join(dbFolder.path, 'settings.sqlite'));
      return NativeDatabase(file, logStatements: logStatements);
    });
    return LighthouseDatabase(executor);
  }
  // if (Platform.isWindows) {
  //   final file = File('db.sqlite');
  //   return Database(VMDatabase(file, logStatements: logStatements));
  // }
  return LighthouseDatabase(
    NativeDatabase.memory(logStatements: logStatements),
  );
}
