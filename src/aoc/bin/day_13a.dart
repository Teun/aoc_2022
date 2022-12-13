import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(13, (raw) async {
    var items = parseToObjects(raw, RegExp(r'(.*)'), (matches) {
      return parseNumberList(matches.first);
    });
    var divider1 = [
      [2]
    ];
    var divider2 = [
      [6]
    ];
    items.addAll([divider1, divider2]);
    items.sort((a, b) => a.compareTo(b));
    var ixDiv1 = items.indexWhere((l) => l.compareTo(divider1) == 0);
    var ixDiv2 = items.indexWhere((l) => l.compareTo(divider2) == 0);
    return (ixDiv1 + 1) * (ixDiv2 + 1);
  });

  var allOK = await rig.testSnippet("sample", 140);
  if (allOK) await rig.runPrint();
}

extension Comparing on List<dynamic> {
  int compareTo(List<dynamic> other) {
    for (var i = 0; i < length; i++) {
      if (other.length <= i) return 1; // other runs out, list1 is larger
      var val1 = this[i];
      var val2 = other[i];
      if (val1 is int && val2 is int) {
        if (val1.compareTo(val2) != 0) {
          return val1.compareTo(val2);
        }
      } else {
        List list1 = (val1 is List) ? val1 : [val1];
        List list2 = (val2 is List) ? val2 : [val2];
        if (list1.compareTo(list2) != 0) {
          return list1.compareTo(list2);
        }
      }
    }
    if (other.length > length) return -1;
    return 0;
  }
}

List parseNumberList(String input) {
  var current = [];
  var stack = [current];
  var number = '';
  flush() {
    if (number.isNotEmpty) {
      current.add(int.parse(number));
      number = '';
    }
  }

  for (var ch in input.split('')) {
    if (ch == '[') {
      var newList = [];
      current.add(newList);
      stack.insert(0, newList);
      current = newList;
    } else if (ch == ']') {
      flush();
      stack.removeAt(0);
      current = stack[0];
    } else if (ch == ',') {
      flush();
    } else {
      number += ch;
    }
  }
  return stack[0];
}
