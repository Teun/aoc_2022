import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

class Bag {
  String first;
  String second;
  Bag(this.first, this.second);
}
void main(List<String> arguments) async {
  final rig = Rig(3, (raw) async {
    var items = parseToObjects(raw, RegExp(r'(\w+)'), (matches) {
      var len = (matches[0].length~/2);
      return Bag(matches[0].substring(0, len), matches[0].substring(len));
    });
    var scores = items.map((bag) {
      var charsinFirst = bag.first.split('');
      var duplicate = charsinFirst.firstWhere((c) => bag.second.contains(c));
      return scoreFor(duplicate);
    });
    return scores.fold(0, (acc, val) => acc + val);
  });

  await rig.testSnippet("sample", 157);
  await rig.runPrint();
}

int scoreFor(String duplicate) {
  final asciiValue =  duplicate.codeUnitAt(0);
  return asciiValue < 91 ? asciiValue - (65 - 27) : asciiValue - 96;
}
