import 'dart:developer';
import 'dart:math';

import 'package:aoc/coord.dart';
import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(22, (raw, {extra = 1}) async {
    var parts = raw.split('\n\n');
    var space = Space<String>.fromText(parts[0], (s, c) => s == " " ? null : s);
    var size = sqrt(space.all.length / 6).toInt();
    var re = RegExp(r'(\d+|[LR])');
    var allSteps = parseSteps(re.allMatches(parts[1])).toList();
    var start = space.all.firstWhere((me) => me.key.y == 0).key;
    var currPos = Position(start, Direction.east);
    for (var step in allSteps) {
      currPos = step.execute(currPos, space, size);
    }
    return 1000 * (currPos.coord.y + 1) +
        4 * (currPos.coord.x + 1) +
        (currPos.dir.index + 3) % 4;
  });

  var allOK = await rig.testSnippet("sample", 5031);
  //allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}

class Position {
  Coord coord;
  Direction dir;
  Position(this.coord, this.dir);
  @override
  String toString() {
    return "$coord, dir: $dir";
  }
}

Iterable<Step> parseSteps(Iterable<RegExpMatch> allMatches) {
  return allMatches.map((s) => Step(s.group(0)!));
}

class Step {
  int direction = 0;
  int distance = 0;
  Step(String s) {
    if (s == 'L') {
      direction = -1;
    } else if (s == 'R') {
      direction = 1;
    } else {
      distance = int.parse(s);
    }
  }

  Position execute(Position fromPos, Space<String> space, int size) {
    var currPos = fromPos;
    if (direction == -1) return Position(currPos.coord, currPos.dir.toLeft());
    if (direction == 1) return Position(currPos.coord, currPos.dir.toRight());
    for (var i = 0; i < distance; i++) {
      Position nextPos = findNextPos(currPos, space, size);
      if (space.at(nextPos.coord) == "#") continue;
      if (space.at(nextPos.coord) == ".") currPos = nextPos;
    }
    return currPos;
  }

  List<List<int>> transforms = [
    // rot, forward, toleft
    [3, 1, 0], // 3->2
    [1, 1, 0], // 2->3
    [3, -1, -4], // 6->1 (0,172)
    [2, 0, -2], // demo: 5 -> 2
    [2, 2, 2], // 1->4
    [0, -4, 2], // 6->2
    [1, -3, 2]
  ];

  Position findNextPos(Position currPos, Space space, int size) {
    var nextCoord = (currPos.coord.toDirection(currPos.dir));
    if (space.at(nextCoord) != null) return Position(nextCoord, currPos.dir);
    Position pos = getCrossEdgePos(currPos, space, size);
    return pos;
  }

  Position getCrossEdgePos(Position currPos, Space space, int size) {
    for (var transform in transforms) {
      var transformed = currPos.coord;
      var block = Block.containing(transformed, size);
      transformed = block.rotate(transformed, transform[0]);
      var c = Coord(0, 0);
      var d = currPos.dir;
      for (var i = 0; i < transform[0]; i++) {
        d = d.toRight();
      }
      for (var i = 0; i < transform[1].abs(); i++) {
        c = c.toDirection(transform[1] > 0 ? currPos.dir : currPos.dir.reverse);
      }
      for (var i = 0; i < transform[2].abs(); i++) {
        c = c.toDirection(
            transform[2] > 0 ? currPos.dir.toLeft() : currPos.dir.toRight());
      }
      transformed = block.translate(transformed, c.x, c.y);
      var nextCoord = transformed.toDirection(d);
      if (space.at(nextCoord) != null) {
        var nextPos = Position(nextCoord, d);
        print("Cross edge jump from $currPos to $nextPos");
        return nextPos;
      }
    }
    throw Exception("Cant find next pos");
  }
}
/*      6
  12   125
  3     3
 45
 6
*/

class Block {
  late Coord pos;
  int size;
  Block(this.pos, this.size);
  Block.containing(Coord position, this.size) {
    var blockX = position.x ~/ size;
    var blockY = position.y ~/ size;
    pos = Coord(blockX, blockY);
  }
  Coord get topLeft {
    return Coord(pos.x * size, pos.y * size);
  }

  Coord rotate(Coord point, int times) {
    var res = point;
    for (var i = 0; i < times; i++) {
      res = Coord(topLeft.x + size - 1 - (res.y - topLeft.y),
          topLeft.y + (res.x - topLeft.x));
    }
    return res;
  }

  Coord translate(Coord point, int dx, int dy) {
    return Coord(point.x + dx * size, point.y + dy * size);
  }
}
