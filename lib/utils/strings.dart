import 'dart:math';

class StringUtils {
  static bool isNullOrEmpty(String s, [bool ignoreTrailingSpace = false]) {
    if (s == null) {
      return true;
    }

    if (!ignoreTrailingSpace && s.trim().isEmpty) {
      return true;
    }

    return s.isEmpty;
  }

  /// Abbreviates large number to thousands, millions, billions, etc.
  /// number is the number to abbreviate
  /// digits is the number of digits to appear after the decimal point
  ///
  /// `E.g
  /// abbreviateNumber(1000) returns 1k
  /// abbreviateNumber(1000000) returns 1M
  /// abbreviateNumber(12345, 1) returns 12.5k
  /// `
  static String abbreviateNumber(num number, [int digits = 0]) {
    final units = ['k', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'];
    var decimal;
    for (var i = units.length - 1; i >= 0; i--) {
      decimal = pow(1000, i + 1);
      if (number <= -decimal || number >= decimal) {
        final r = (number / decimal).abs();
        if (1.0 - r != 0) {
          return r.toStringAsFixed(digits) + units[i];
        } else {
          return r.toStringAsFixed(0) + units[i];
        }
      }
    }
    return number.toString();
  }
}
