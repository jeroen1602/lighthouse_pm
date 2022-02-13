import 'package:drift/web.dart';

import '../database.dart';

LighthouseDatabase constructDb({final bool logStatements = false}) {
  return LighthouseDatabase(
      WebDatabase('LighthouseDatabase', logStatements: logStatements));
}
