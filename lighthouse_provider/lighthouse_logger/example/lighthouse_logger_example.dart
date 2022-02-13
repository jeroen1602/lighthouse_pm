import 'package:lighthouse_logger/lighthouse_logger.dart';
import 'package:logging/logging.dart';

void main() {
  lighthouseLogger.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  lighthouseLogger.log(Level.SHOUT, "Bark!");
}
