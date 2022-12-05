import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(5, (raw) async {
    var rawStacks = raw.split("\n\n")[0];
    var rawSteps = raw.split("\n\n")[1];

    var stacks = readStacksFrom(rawStacks);
    var items = parseToObjects(rawSteps, RegExp(r'move (\d+) from (\d+) to (\d+)'), (matches) {
      return matches.map(int.parse).toList();
    });
    for (var action in items) {
      var endSize = stacks[action[1]]!.length - action[0];
      for (var i = 0; i < action[0]; i++) {
        var take = stacks[action[1]]!.removeAt(endSize);
        stacks[action[2]]!.add(take);
      }
    }
    return stacks.entries.map((s) => s.value.last).join("");
  });

  await rig.testSnippet("sample", "MCD");
  await rig.runPrint();
}

Map<int, List<String>> readStacksFrom(String rawStacks) {
  var lines = rawStacks.split("\n").where((s) => s.isNotEmpty).toList();
  var lastLine = lines.last;
  var matches = RegExp(r'\b(\d)\b').allMatches(lastLine);
  var cols = matches.fold<Map<int, int>>({}, (acc, v) {
    var letter = lastLine.substring(v.start, v.end);
    acc[int.parse(letter)] = v.start;
    return acc;
  });
  var result = Map.fromEntries(cols.entries.map((e) => MapEntry<int, List<String>>(e.key, [])));
  for (var i = lines.length-2; i >= 0; i--) {
    for (var col in result.entries) {
      var letter = lines[i].substring(cols[col.key]!, cols[col.key]! + 1);
      if(letter.trim().isNotEmpty){
        result[col.key]!.add(letter);
      }
    }
  }
  return result;
}
