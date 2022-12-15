import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

class Bag {
  late Set<String> first;
  late Set<String> second;
  Bag(String full) {
    var len = (full.length ~/ 2);
    first = Set.from(full.substring(0, len).split(''));
    second = Set.from(full.substring(len).split(''));
  }
}

void main(List<String> arguments) async {
  final rig = Rig(3, (raw, {dynamic extra}) async {
    var items = parseToObjects(raw, RegExp(r'(\w+)'), (matches) {
      return Bag(matches[0]);
    });
    var scores = items.map((bag) {
      var duplicate = bag.first.intersection(bag.second).first;
      return scoreFor(duplicate);
    });
    return scores.fold(0, (acc, val) => acc + val);
  });

  await rig.testSnippet("sample", 157);
  await rig.runPrint();
}

int scoreFor(String duplicate) {
  final asciiValue = duplicate.codeUnitAt(0);
  return asciiValue < 91 ? asciiValue - (65 - 27) : asciiValue - 96;
}
