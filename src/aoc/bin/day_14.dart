import 'dart:math';
import 'package:aoc/coord.dart';
import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(14, (raw, {dynamic extra}) async {
    var items = parseToObjects(raw, RegExp(r'(.*)'), (matches) {
      var line = matches[0];
      var pairs = line
          .split(' -> ')
          .map((p) => p.split(',').map((e) => int.parse(e)).toList());
      return pairs;
    });
    var space = Space<String>.fromEntries([]);
    for (var list in items) {
      var prev = list.first;
      for (var curr in list.skip(1)) {
        drawLine(space, Coord(prev[0], prev[1]), Coord(curr[0], curr[1]));
        prev = curr;
      }
    }
    print(space.visualize((val) => val));
    pourSand(space, Coord(500, 0));
    print(space.visualize((val) => val));
    return space.all.where((v) => v.value == 'o').length;
  });

  var allOK = await rig.testSnippet("sample", 24);
  if (allOK) await rig.runPrint();
}

void pourSand(Space<String> space, Coord start) {
  var yBottom = space.bounds.bottomRight.y;
  outerloop:
  do {
    var sandPos = start;
    do {
      var directions = [
        sandPos.toDirection(Direction.south),
        sandPos.toDirection(Direction.south).toDirection(Direction.west),
        sandPos.toDirection(Direction.south).toDirection(Direction.east)
      ];
      var nextPos = directions.firstWhere((c) => space.at(c) == null,
          orElse: () => sandPos);
      if (nextPos == sandPos) {
        space.set(sandPos, 'o');
        break;
      } else {
        sandPos = nextPos;
      }
      if (sandPos.y > yBottom) break outerloop;
    } while (true);
  } while (true);
}

void drawLine(Space<String> space, Coord coord, Coord coord2) {
  var lowX = min(coord.x, coord2.x);
  var highX = max(coord.x, coord2.x);
  for (var x = lowX; x <= highX; x++) {
    var lowY = min(coord.y, coord2.y);
    var highY = max(coord.y, coord2.y);
    for (var y = lowY; y <= highY; y++) {
      space.set(Coord(x, y), 'x');
    }
  }
}
