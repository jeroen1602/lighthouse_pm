import 'dart:io';

import 'package:lighthouse_pm/data/Database.dart';
import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as paths;

import '../Database.dart';

LighthouseDatabase constructDb({bool logStatements = false}) {
  if (Platform.isIOS || Platform.isAndroid) {
    final executor = LazyDatabase(() async {
      final dbFolder = await paths.getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      return VmDatabase(file, logStatements: logStatements);
    });
    return LighthouseDatabase(executor);
  }
  if (Platform.isMacOS || Platform.isLinux) {
    final executor = LazyDatabase(() async {
      final dbFolder = await paths.getApplicationSupportDirectory();
      final file = File(p.join(dbFolder.path, 'settings.sqlite'));
      return VmDatabase(file, logStatements: logStatements);
    });
    return LighthouseDatabase(executor);
  }
  // if (Platform.isWindows) {
  //   final file = File('db.sqlite');
  //   return Database(VMDatabase(file, logStatements: logStatements));
  // }
  return LighthouseDatabase(VmDatabase.memory(logStatements: logStatements));
}
