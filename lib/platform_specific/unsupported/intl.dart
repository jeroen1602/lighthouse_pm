import 'package:flutter/foundation.dart';

Future<void> loadIntlStrings() async {
  if (!kReleaseMode) {
    throw UnsupportedError('Unsupported platform for loading intl');
  }
}
