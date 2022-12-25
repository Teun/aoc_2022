import 'package:aoc/coord.dart';
import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(22, (raw, {extra = 1}) async {
    var parts = raw.split('\n\n');
    var space = Space<String>.fromText(parts[0], (s, c) => s == " " ? null : s);
    var re = RegExp(r'(\d+|[LR])');
    var allSteps = parseSteps(re.allMatches(parts[1])).toList();
    var start = space.all.firstWhere((me) => me.key.y == 0).key;
    var currPos = Position(start, Direction.east);
    for (var step in allSteps) {
      currPos = step.execute(currPos, space);
      print("Now at: ${currPos.coord} facing ${currPos.dir}");
    }
    return 1000 * (currPos.coord.y + 1) +
        4 * (currPos.coord.x + 1) +
        (currPos.dir.index + 3) % 4;
  });

  var allOK = await rig.testSnippet("sample", 6032);
  //allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}

class Position {
  Coord coord;
  Direction dir;
  Position(this.coord, this.dir);
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

  Position execute(Position currPos, Space<String> space) {
    if (direction == -1) return Position(currPos.coord, currPos.dir.toLeft());
    if (direction == 1) return Position(currPos.coord, currPos.dir.toRight());
    var currCoord = currPos.coord;
    for (var i = 0; i < distance; i++) {
      Coord nextCoord = findNextPos(currCoord, currPos.dir, space);
      if (space.at(nextCoord) == "#") continue;
      if (space.at(nextCoord) == ".") currCoord = nextCoord;
    }
    return Position(currCoord, currPos.dir);
  }

  Coord findNextPos(Coord currCoord, Direction dir, Space space) {
    var nextCoord = (currCoord.toDirection(dir));
    if (space.at(nextCoord) != null) return nextCoord;
    var cycle = currCoord;
    while (space.at(cycle) != null) {
      cycle = cycle.toDirection(dir.reverse);
    }
    return cycle.toDirection(dir);
  }
}
