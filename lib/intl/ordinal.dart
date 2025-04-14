import 'package:intl/intl.dart';

class Ordinal {
  ///
  /// Return the ordinal for the number given. (th, st, nd, and rd in English).
  /// This does not do translations yet, but it might someday.
  ///
  /// This wil only return the ordinal and not the number itself, if the number
  /// itself is also needed then use [ordinalWithNumber].
  ///
  static String ordinal(final int number) {
    return Intl.plural(
      number,
      zero: 'th',
      one: 'st',
      two: 'nd',
      few: 'rd',
      many: 'th',
      other: 'th',
    );
  }

  ///
  /// Return the original number + the ordinal for the number given.
  /// (th, st, nd, and rd in English).
  /// This does not do translations yet, but it might someday.
  ///
  /// This wil only return the ordinal and and the original number, if only the
  /// ordinal is required use [ordinal].
  ///
  static String ordinalWithNumber(final int number) {
    return '$number${ordinal(number)}';
  }
}
