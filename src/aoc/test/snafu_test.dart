import 'package:test/test.dart';

import '../bin/day_25.dart';

void main() {
  test('parse', () async {
    expect(Snafu.parse("1="), 3);
    expect(Snafu.parse("10"), 5);
    expect(Snafu.parse("1-1"), 21);
    expect(Snafu.parse("1121-1110-1=0"), 314159265);
  });
  test('toString', () async {
    expect(Snafu.asString(3), "1=");
    expect(Snafu.asString(21), "1-1");
    expect(Snafu.asString(314159265), "1121-1110-1=0");
  });
}
