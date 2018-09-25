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
}
