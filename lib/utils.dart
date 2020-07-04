class Utils {
  static bool isIsbn(String value) {
    if (value.length != 13) {
      return false;
    }
    if (!value.startsWith("978")) {
      return false;
    }
    return int.tryParse(value) != null;
  }

  static   String isbn13(String isbn) {
    if (isbn.length == 13) {
      return isbn;
    }
    const NUMVALUES = "0123456789";
    final digits = "978$isbn".split('');
    var sum = 0;
    for (int i = 0; i < 12; i++) {
      final val = NUMVALUES.indexOf(digits[i]);
      sum += val * (i % 2 == 0 ? 1 : 3);
    }
    final chk = (sum % 10 == 0) ? "0" : (10 - (sum % 10)).toString();
    return "978$isbn$chk";
  }

}