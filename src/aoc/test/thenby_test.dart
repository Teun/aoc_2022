import 'package:aoc/thenby.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';


void main() {
  
  test('strings', () {
    var toSort = ["akjwkj", "safjnvskdvjn", "fgfnjavn", " wfuasfhi"];
    toSort.sort(firstBy<String, String>((s) => s));
    expect((ListEquality()).equals(toSort, [" wfuasfhi", "akjwkj", "fgfnjavn", "safjnvskdvjn"]), isTrue);
  });
  test('strings reverse', () {
    var toSort = ["akjwkj", "safjnvskdvjn", "fgfnjavn", " wfuasfhi"];
    toSort.sort(firstBy<String, String>((s) => s, dir: Direction.desc));
    expect((ListEquality()).equals(toSort, ["safjnvskdvjn",  "fgfnjavn", "akjwkj", " wfuasfhi" ]), isTrue);
  });
  test('strings, first on length, then alpha', () {
    var toSort = ["akjwkj", "safjnvsk", "fgfnjavn", "wfuasfhi"];
    toSort.sort(
      firstBy<String, int>((s) => s.length, dir: Direction.desc)
      .thenBy((s) => s));
    expect((ListEquality()).equals(toSort, ["fgfnjavn", "safjnvsk", "wfuasfhi", "akjwkj"]), isTrue);
  });
  test('objects, first on num1, then num2 desc', () {
    List<A> toSort = [
      A(5, -0.1),
      A(0, 2e3),
      A(0, 2001),
      A(4, -1)
    ];
    toSort.sort(
      firstBy<A, int>((A e) => e.num1, dir: Direction.asc)
      .thenBy((A e) => e.num2, dir: Direction.desc));
    expect((ListEquality()).equals(toSort.map((a) => a.num2).toList(), [2001, 2000, -1, -0.1]), isTrue);
  });

}
class A {
  A(this.num1, this.num2);
  int num1;
  double num2;
}
