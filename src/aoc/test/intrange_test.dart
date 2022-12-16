import 'package:aoc/intrange.dart';
import 'package:test/test.dart';

void main() {
  test('generates', () async {
    var result = IntRange(12, 25);
    expect(result.values.length, 14);
    expect(result.values.first, 12);
    expect(result.values.last, 25);
  });
  test('removed from middle', () async {
    var result = IntRange(12, 25);
    result.remove(19, 21);
    expect(result.values.length, 11);
    expect(result.values.first, 12);
    expect(result.values.last, 25);
  });
  test('union correctly combines', () async {
    var result = IntRange(12, 25);
    result.remove(13, 15);
    result.union(IntRange(15, 26));
    expect(result.values.length, 13);
    expect(result.parts.length, 2);
    expect(result.values.last, 26);
  });
}
