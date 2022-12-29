import 'package:aoc/coord.dart';
import 'package:aoc/pathfinder.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(24, (raw, {extra = 1}) async {
    var initSpace = Space.fromText(raw, (v, c) {
      if ("<>^v#".contains(v)) {
        return v;
      }
    });
    var start = Coord(1, 0);
    var end = initSpace.bounds.bottomRight.toDirection(Direction.west);
    var blizzards = Blizzards(
        initSpace.all.where((element) => element.value != "#"),
        initSpace.bounds);
    var pf = Pathfinder();
    var path = pf.findShortest<CoordPlusTime, String>(
        (from) {
          List<StepTo<CoordPlusTime, String>> result = [];
          var time = from.time + 1;
          if (!blizzards.occupied(from.coord, time)) {
            result.add(StepTo(CoordPlusTime(from.coord, time), "wait"));
          }
          for (var dir in Direction.values) {
            var pos = from.coord.toDirection(dir);
            if (initSpace.at(pos) == "#") continue;
            if (!initSpace.bounds.contains(pos)) continue;
            if (!blizzards.occupied(pos, time)) {
              result.add(StepTo(CoordPlusTime(pos, time), dir.name));
            }
          }
          return result;
        },
        (pos) => pos.coord == end,
        CoordPlusTime(start, 0),
        minimalDistanceRemaining: (from) =>
            from.coord.manhattan(end).toDouble(),
        progress: (s, p) {
          if (s % 1000 == 0) {
            print(
                "Current best path: ${p.steps.length} to ${p.to.coord} in ${p.to.time} s.");
          }
        });

    return path.cost;
  });

  var allOK = await rig.testSnippet("sample", 18);
  //allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}

class CoordPlusTime {
  Coord coord;
  int time;
  CoordPlusTime(this.coord, this.time);
  @override
  bool operator ==(Object other) {
    if (other is! CoordPlusTime) return false;
    return coord == other.coord && time == other.time;
  }

  @override
  int get hashCode => coord.hashCode ^ time.hashCode;
}

class Blizzards {
  var horizontals = <int, List<Blizzard>>{};
  var verticals = <int, List<Blizzard>>{};
  Blizzards(Iterable<MapEntry<Coord, String>> blizzards, Rect bounds) {
    for (var bl in blizzards) {
      if (bl.value == "<") {
        horizontals[bl.key.y] = horizontals[bl.key.y] ?? [];
        horizontals[bl.key.y]!.add(Blizzard(
            bl.key.x, -1, bounds.bottomRight.x - bounds.topLeft.x - 1));
      }
      if (bl.value == ">") {
        horizontals[bl.key.y] = horizontals[bl.key.y] ?? [];
        horizontals[bl.key.y]!.add(
            Blizzard(bl.key.x, 1, bounds.bottomRight.x - bounds.topLeft.x - 1));
      }
      if (bl.value == "^") {
        verticals[bl.key.x] = verticals[bl.key.x] ?? [];
        verticals[bl.key.x]!.add(Blizzard(
            bl.key.y, -1, bounds.bottomRight.y - bounds.topLeft.y - 1));
      }
      if (bl.value == "v") {
        verticals[bl.key.x] = verticals[bl.key.x] ?? [];
        verticals[bl.key.x]!.add(
            Blizzard(bl.key.y, 1, bounds.bottomRight.y - bounds.topLeft.y - 1));
      }
    }
  }
  bool occupied(Coord pos, int time) {
    if (horizontals[pos.y] != null) {
      for (var bl in horizontals[pos.y]!) {
        if (bl.pos(time) == pos.x) return true;
      }
    }
    if (verticals[pos.x] != null) {
      for (var bl in verticals[pos.x]!) {
        if (bl.pos(time) == pos.y) return true;
      }
    }
    return false;
  }
}

class Blizzard {
  int speed;
  int pos0;
  int space;
  Blizzard(this.pos0, this.speed, this.space);
  int pos(int time) {
    return ((pos0 + (time * speed) - 1) % space) + 1;
  }
}
