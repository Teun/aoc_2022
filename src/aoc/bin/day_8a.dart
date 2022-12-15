import 'package:aoc/rig.dart';
import 'package:aoc/coord.dart';
import 'package:aoc/thenby.dart' as tb;

void main(List<String> arguments) async {
  final rig = Rig(8, (raw, {dynamic extra}) async {
    var grid = Space.fromText(raw, (d, p) {
      return Tree(int.parse(d));
    });
    var scores = grid.all.map((p) {
      return scenicScore(p.value.height, p.key, Direction.east, grid) *
          scenicScore(p.value.height, p.key, Direction.west, grid) *
          scenicScore(p.value.height, p.key, Direction.north, grid) *
          scenicScore(p.value.height, p.key, Direction.south, grid);
    }).toList();
    scores.sort(tb.firstBy((int i) => i, dir: tb.Direction.desc));
    return scores.first;
  });

  var allOK = await rig.testSnippet("sample", 8);
  // allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}

int scenicScore(int height, Coord from, Direction to, Space<Tree> grid) {
  var curr = from;
  var score = 0;
  do {
    curr = curr.toDirection(to);
    var tree = grid.at(curr);
    if (tree == null) break;
    score++;
    if (tree.height >= height) break;
  } while (true);
  return score;
}

class Tree {
  int height;
  Tree(this.height);
}
