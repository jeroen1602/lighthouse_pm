import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_browser.dart';

Future<void> loadIntlStrings() async {
  await findSystemLocale();
  await initializeDateFormatting();
}
