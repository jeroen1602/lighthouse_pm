import 'dart:io';

import 'package:lighthouse_pm/data/database.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as paths;

LighthouseDatabase constructDb({final bool logStatements = false}) {
  if (Platform.isIOS ||
      Platform.isAndroid ||
      Platform.isMacOS ||
      Platform.isLinux) {
    final executor = LazyDatabase(() async {
      final file = await getDatabaseFile();
      return NativeDatabase(file!, logStatements: logStatements);
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

Future<File?> getDatabaseFile() async {
  if (Platform.isIOS || Platform.isAndroid) {
    final dbFolder = await paths.getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, 'db.sqlite'));
  }
  if (Platform.isMacOS || Platform.isLinux) {
    final dbFolder = await paths.getApplicationSupportDirectory();
    return File(p.join(dbFolder.path, 'settings.sqlite'));
  }
  return null;
}
