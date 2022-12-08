import 'package:aoc/rig.dart';
import 'package:aoc/coord.dart';

void main(List<String> arguments) async {
  final rig = Rig(8, (raw) async {
    var grid = Space.fromText(raw, (d) {
      return Tree(int.parse(d));
    });
    for (var x = grid.bounds.topLeft.x; x <= grid.bounds.bottomRight.x; x++) {
      var col = List.generate(
          grid.bounds.bottomRight.y - grid.bounds.topLeft.y + 1,
          (index) => grid.at(Coord(x, grid.bounds.topLeft.y + index)));
      markVisibility(col);
    }
    for (var y = grid.bounds.topLeft.y; y <= grid.bounds.bottomRight.y; y++) {
      var row = List.generate(
          grid.bounds.bottomRight.x - grid.bounds.topLeft.x + 1,
          (index) => grid.at(Coord(grid.bounds.topLeft.x + index, y)));
      markVisibility(row);
    }
    return grid.all.where((pair) => pair.value.visible).length;
  });

  var allOK = await rig.testSnippet("sample", 21);
  // allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}

void markVisibility(List<Tree?> line) {
  mark(Iterable<Tree?> trees) {
    var height = -1;
    for (var tree in trees) {
      if (tree == null) continue;
      if (tree.height > height) {
        tree.visible = true;
        height = tree.height;
      }
    }
  }

  mark(line);
  mark(line.reversed);
}

class Tree {
  int height;
  bool visible = false;
  Tree(this.height);
}
