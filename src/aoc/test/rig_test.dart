import 'package:aoc/rig.dart';
import 'package:test/test.dart';

void main() {
  
  test('calculate', () async {
    final before = DateTime.now();
    var r = Rig<DateTime>(3, (raw) async => before);
    final res = await r.test("", before);
    expect(res, (DateTime r) => r.isBefore(DateTime.now()));
    expect(res, (DateTime r) => r.isAtSameMomentAs(before));
  });
}
