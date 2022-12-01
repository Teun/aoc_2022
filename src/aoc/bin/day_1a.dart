import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(1, (raw) async {
    final lines = getLines(raw);
    final elves = groupOnSeparator(lines, "");
    final sums = elves.map((e) => e.fold(0, (previousValue, val) => previousValue + val)).toList();
    sums.sort((a, b) => b-a);
    return sums.first + sums[1] + sums[2];
  });

  await rig.testSnippet("sample", 45000);
  await rig.runPrint();
}

List<List<int>> groupOnSeparator(Iterable<String> lines, String sep) {
  List<List<int>> result = [];
  List<int> current = [];
  for (var l in lines) {
    if(l == sep && current.isNotEmpty){
      result.add(current);
      current = [];
    }else{
      current.add(int.parse(l));
    }
  }
  if(current.isNotEmpty)result.add(current);
  return result;
}
