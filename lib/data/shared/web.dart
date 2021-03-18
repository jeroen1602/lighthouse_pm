import 'package:moor/moor_web.dart';

import '../Database.dart';

LighthouseDatabase constructDb({bool logStatements = false}) {
  return LighthouseDatabase(WebDatabase('db', logStatements: logStatements));
}
