import 'package:aoc/coord.dart';
import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

class Rope {
  late List<Segment> segments;
  Rope(int length) {
    segments = List.generate(length, (index) => Segment());
  }
  void move(Direction dir) {
    segments.first.move(dir);
    for (var i = 1; i < segments.length; i++) {
      segments[i].moveTo(segments[i - 1].tail);
    }
  }
}

class Segment {
  Coord head = Coord(0, 0);
  Coord tail = Coord(0, 0);

  void move(Direction dir) {
    head = head.toDirection(dir);
    _pullTail();
  }

  void moveTo(Coord pos) {
    head = pos;
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
  final rig = Rig(9, (raw, {dynamic extra}) async {
    var items = parseToObjects(raw, RegExp(r'(\w) (\d+)'), (matches) {
      return matches;
    });
    var rope = Rope(9);
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
        visited.add(rope.segments.last.tail);
      }
    }
    return visited.length;
  });

  var allOK = await rig.testSnippet("sample", 1);
  allOK &= await rig.testSnippet("sample2", 36);
  if (allOK) await rig.runPrint();
}
