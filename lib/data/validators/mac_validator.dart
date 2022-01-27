///
/// A validator for validating if mac addresses are entered correctly by the user.
class MacValidator {
  MacValidator._();

  static String? macValidator(final String? input) {
    if (input == null || input.trim() == '') {
      return null;
    }
    if (input.length != 17) {
      return 'Mac address should be 6 hexadecimal bytes split by :';
    }
    final value = input.toUpperCase();
    // I could have used a regular expression, but they scare me.
    for (var i = 0; i < value.codeUnits.length; i++) {
      if (i % 3 == 2) {
        if (value.codeUnitAt(i) != 0x3a /*:*/) {
          return 'Expected a : at position $i saw ${value[i]}';
        }
        continue;
      }
      final code = value.codeUnitAt(i);
      // code must be a valid hexadecimal digit. (only have to check for uppercase because we made it uppercase.
      if ((code < 0x30 /*0*/ || code > 0x39 /*9*/) &&
          (code < 0x41 /*A*/ || code > 0x46 /*F*/)) {
        return 'Unexpected file digit at position $i saw ${value[i]}';
      }
    }

    return null;
  }
}
