import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

class Bag {
  late Set<String> first;
  late Set<String> second;
  Set<String> get all => first.union(second);
  Bag(String full){
    var len = (full.length~/2);
    first = Set.from(full.substring(0, len).split(''));
    second = Set.from(full.substring(len).split(''));
  }
}
void main(List<String> arguments) async {
  final rig = Rig(3, (raw) async {
    var items = parseToObjects(raw, RegExp(r'(\w+)'), (matches) {
      return Bag(matches[0]);
    });
    var sum = 0;
    for (var i = 0; i < items.length; i = i + 3) {
      var common = items[i].all
        .intersection(items[i+1].all)
        .intersection(items[i+2].all)
        .first;
      sum += scoreFor(common);
    }
    return sum;
  });

  await rig.testSnippet("sample", 70);
  await rig.runPrint();
}

int scoreFor(String duplicate) {
  final asciiValue =  duplicate.codeUnitAt(0);
  return asciiValue < 91 ? asciiValue - (65 - 27) : asciiValue - 96;
}

