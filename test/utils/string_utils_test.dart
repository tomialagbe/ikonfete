import 'package:ikonfetemobile/utils/strings.dart';
import 'package:test/test.dart';

void main() {
  test("Test StringUtils.abbreviateNumber", () {
    var result = StringUtils.abbreviateNumber(1000);
    expect(result, "1k");

    result = StringUtils.abbreviateNumber(100000);
    expect(result, "100k");

    result = StringUtils.abbreviateNumber(1000000);
    expect(result, "1M");

    result = StringUtils.abbreviateNumber(1200000, 1);
    expect(result, "1.2M");

    result = StringUtils.abbreviateNumber(1230500, 1);
    expect(result, "1.2M");

    result = StringUtils.abbreviateNumber(1000000000);
    expect(result, "1G");

    result = StringUtils.abbreviateNumber(1000000, 1);
    expect(result, "1M");

    result = StringUtils.abbreviateNumber(0, 1);
    expect(result, "0");

    result = StringUtils.abbreviateNumber(100, 1);
    expect(result, "100");
  });
}
