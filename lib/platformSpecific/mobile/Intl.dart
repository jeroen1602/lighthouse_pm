import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_standalone.dart';

Future<void> loadIntlStrings() async {
  final locale = await findSystemLocale();
  await initializeDateFormatting();
}