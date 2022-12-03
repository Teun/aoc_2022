import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

class Bag {
  String first;
  String second;
  String get all => first + second;
  Bag(this.first, this.second);
  bool contains(String item) {
    return first.contains(item) || second.contains(item);
  }
}
void main(List<String> arguments) async {
  final rig = Rig(3, (raw) async {
    var items = parseToObjects(raw, RegExp(r'(\w+)'), (matches) {
      var len = (matches[0].length~/2);
      return Bag(matches[0].substring(0, len), matches[0].substring(len));
    });
    var sum = 0;
    for (var i = 0; i < items.length; i = i + 3) {
      var charsInFirst = items[i].all.split('');
      var common = charsInFirst.firstWhere((c) => items[i+1].contains(c) && items[i+2].contains(c));
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

