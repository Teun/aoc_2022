import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(13, (raw) async {
    var items =
        parseToObjects(raw, RegExp(r'(.*)\n(.*)', multiLine: false), (matches) {
      return matches.map((e) => parseString(e));
    }, splitter: RegExp(r'\n\n'));
    return 0;
  });

  var allOK = await rig.testSnippet("sample", 13);
  if (allOK) await rig.runPrint();
}

List parseString(String input) {
  var stack = [[]];
  var current = stack[0];
  var number = '';

  for (var ch in input.split('')) {
    if (ch == '[') {
      var newList = [];
      current.add(newList);
      stack.insert(0, newList);
      current = newList;
    } else if (ch == ']') {
      stack.removeAt(0);
      current = stack[0];
    } else if (ch == ',') {
      if (number.isNotEmpty) {
        current.add(int.parse(number));
        number = '';
      }
    } else {
      number += ch;
    }
  }

  if (number.isNotEmpty) {
    current.add(int.parse(number));
  }

  return stack[0];
}
