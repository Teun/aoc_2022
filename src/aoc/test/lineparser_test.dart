import 'package:aoc/lineparser.dart' as lp;
import 'package:collection/collection.dart';
import 'package:test/test.dart';

const String numbers =
'''
234
456
56767
8
''';
const String two_numbers =
'''
234 88
456 1
56767 1
8 888
''';

class Ab { 
  Ab(this.a, this.b);
  String a;
  int b;
}

void main() {
  test('splits', () async {
    var result = lp.parseToObjects(numbers, RegExp(r'(\w+)'), (s) => s[0]);
    expect(result.length, 4);
  });
  test('finds numbers', () async {
    var result = lp.parseToObjects(numbers, RegExp(r'(\w+)'), (s) => int.parse(s[0]));
    expect(result.first, 234);
    expect(result.last, 8);
  });
  test('create objects', () {
    var result = lp.parseToObjects(two_numbers, RegExp(r'(\d+)\s(\d+)'), (s) => Ab(s[0], int.parse(s[1])));
    expect(result.length, 4);
    expect(result.last.a, "8");
    expect(result.last.b, 888);
  });
}
