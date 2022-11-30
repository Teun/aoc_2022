import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';
import 'package:collection/collection.dart';

int depthSum(List<int> all, int from, int to){
  var res = 0;
  for (var i = from; i <= to; i++) {
    res += all[i];
  }
  return res;
}
void main(List<String> arguments) async {
  final rig = Rig(20211, (raw) async {
    final depths = parseToObjects(raw, RegExp(r'^(\d+)$'), (gr)=> int.parse(gr[0]));
    final indexes = depths.mapIndexed((i, e) => i);
    return indexes.where((i) => i > 2)
      .where((i) => depthSum(depths, i-2, i) > depthSum(depths, i-3, i-1))
      .length;
  });

  await rig.testSnippet('first', 5);
  await rig.runPrint();
}
