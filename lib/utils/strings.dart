class StringUtils {
  static bool isNullOrEmpty(String s, [bool removeTrailingSpace]) {
    if (s == null) {
      return true;
    }

    if (!removeTrailingSpace && s.trim().isEmpty) {
      return true;
    }

    return s.isEmpty;
  }
}
