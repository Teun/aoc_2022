import 'package:aoc/coord.dart';
import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

class Rope {
  Coord head = Coord(0, 0);
  Coord tail = Coord(0, 0);

  void move(Direction dir) {
    head = head.toDirection(dir);
    _pullTail();
  }

  void _pullTail() {
    if ((head.x - tail.x).abs() > 1 || (head.y - tail.y).abs() > 1) {
      if (head.x > tail.x) tail = tail.toDirection(Direction.east);
      if (head.x < tail.x) tail = tail.toDirection(Direction.west);
      if (head.y > tail.y) tail = tail.toDirection(Direction.south);
      if (head.y < tail.y) tail = tail.toDirection(Direction.north);
    }
  }
}

void main(List<String> arguments) async {
  final rig = Rig(9, (raw) async {
    var items = parseToObjects(raw, RegExp(r'(\w) (\d+)'), (matches) {
      return matches;
    });
    var rope = Rope();
    var visited = <Coord>{};
    for (var step in items) {
      var dir = {
        "U": Direction.north,
        "D": Direction.south,
        "L": Direction.west,
        "R": Direction.east
      }[step[0]]!;
      var times = int.parse(step[1]);
      for (var i = 0; i < times; i++) {
        rope.move(dir);
        visited.add(rope.tail);
      }
    }
    return visited.length;
  });

  var allOK = await rig.testSnippet("sample", 13);
  //allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}
