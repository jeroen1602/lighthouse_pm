import 'package:drift/web.dart';

import '../database.dart';

LighthouseDatabase constructDb({bool logStatements = false}) {
  return LighthouseDatabase(
      WebDatabase('LighthouseDatabase', logStatements: logStatements));
}
