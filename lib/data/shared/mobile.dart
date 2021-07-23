import 'dart:ffi';
import 'dart:io';

import 'package:lighthouse_pm/data/Database.dart';
import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as paths;
import 'package:sqlite3/open.dart';

import '../Database.dart';

LighthouseDatabase constructDb({bool logStatements = false}) {
  open.overrideFor(OperatingSystem.windows, _openOnWindows);
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
  if (Platform.isWindows) {
    final executor = LazyDatabase(() async {
      final dbFolder = await paths.getApplicationSupportDirectory();
      final file = File(p.join(dbFolder.path, 'settings.sqlite'));
      return VmDatabase(file, logStatements: logStatements);
    });
    return LighthouseDatabase(executor);
  }
  return LighthouseDatabase(VmDatabase.memory(logStatements: logStatements));
}

DynamicLibrary _openOnWindows() {
  try {
    final script = File(Platform.script.toFilePath());
    final libraryNextToScript = File(p.join(script.parent.path, "sqlite3.dll"));
    return DynamicLibrary.open(libraryNextToScript.path);
  } catch (e, s) {
    print('$e');
    print('$s');
    throw e;
  }
}
