class StringUtils {
  static bool isNullOrEmpty(String s, [bool removeTrailingSpace = false]) {
    if (s == null) {
      return true;
    }

    if (!removeTrailingSpace && s.trim().isEmpty) {
      return true;
    }

    return s.isEmpty;
  }
}
