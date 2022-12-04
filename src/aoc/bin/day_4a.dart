import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

class Pair{
  int start1;
  int start2;
  int end1;
  int end2;
  Pair(this.start1, this.end1, this.start2, this.end2);
  bool overlaps(){
    if(start1 <= end2 && end1 >= start2) return true;
    if(start2 <= end1 && end2 >= start1) return true;
    return false;
  }
  bool fullyContains(){
    if(start1 <= start2 && end1 >= end2) return true;
    if(start2 <= start1 && end2 >= end1) return true;
    return false;
  }
}
void main(List<String> arguments) async {
  final rig = Rig(4, (raw) async {
    var items = parseToObjects(raw, RegExp(r'(\d+)-(\d+),(\d+)-(\d+)'), (matches) {
      return Pair(int.parse(matches[0]), int.parse(matches[1]), int.parse(matches[2]), int.parse(matches[3]));
    });
    return items.where((pair) => pair.overlaps()).length;
  });

  await rig.testSnippet("sample", 4);
  await rig.runPrint();
}
