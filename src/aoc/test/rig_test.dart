import 'package:aoc/rig.dart';
import 'package:test/test.dart';

void main() {
  test('calculate', () async {
    final before = DateTime.now();
    var r = Rig<DateTime>(3, (raw) async => before);
    final res = await r.test("", before);
    expect(res, true);
  });
}
