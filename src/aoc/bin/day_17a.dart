import 'package:aoc/coord.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(17, (raw, {extra = 1}) async {
    var directions = raw.trim().split('');
    var space = Space<String>.fromText("#######", (s, c) => s);
    List<List<Coord>> rockTypes = [
      [Coord(0, 0), Coord(1, 0), Coord(2, 0), Coord(3, 0)],
      [Coord(1, 0), Coord(0, -1), Coord(1, -1), Coord(2, -1), Coord(1, -2)],
      [Coord(0, 0), Coord(1, 0), Coord(2, 0), Coord(2, -1), Coord(2, -2)],
      [Coord(0, 0), Coord(0, -1), Coord(0, -2), Coord(0, -3)],
      [Coord(0, 0), Coord(0, -1), Coord(1, 0), Coord(1, -1)]
    ];
    Map<String, List<int>> memo = {};
    bool jumpMade = false;
    bool rockFalling = false;
    Coord currentRockPos = Coord(0, 0);
    int rockTypeIx = 0;
    int rocksFixed = 0;
    List<Coord> currentRock = [];
    for (var i = 0; true; i++) {
      // appear
      if (!rockFalling) {
        currentRockPos = Coord(2, space.bounds.topLeft.y - 4);
        currentRock = rockTypes[rockTypeIx];
        rockTypeIx = (rockTypeIx + 1) % rockTypes.length;
        rockFalling = true;
      }
      // blow
      var blow = {'<': -1, '>': 1}[directions[i % directions.length]]!;
      if (currentRock.every((p) {
        var newX = p.x + currentRockPos.x + blow;
        if (newX < 0 || newX > 6) return false;
        if (space.at(Coord(newX, currentRockPos.y + p.y)) != null) {
          return false;
        }
        return true;
      })) {
        currentRockPos = Coord(currentRockPos.x + blow, currentRockPos.y);
      }
      // fall
      if (currentRock.every((p) {
        if (space.at(
                Coord(currentRockPos.x + p.x, currentRockPos.y + p.y + 1)) !=
            null) {
          return false;
        }
        return true;
      })) {
        currentRockPos = Coord(currentRockPos.x, currentRockPos.y + 1);
      } else {
        // fix
        for (var p in currentRock) {
          space.set(Coord(currentRockPos.x + p.x, currentRockPos.y + p.y), '#');
        }
        rocksFixed++;
        rockFalling = false;
        //print(space.visualize((val) => val));
        if (rocksFixed % 100 == 0) print("$rocksFixed rocks fixed");
        if (rocksFixed == 1000000000000) {
          print(space.visualize((val) => val,
              bnds: Rect(space.bounds.topLeft,
                  Coord(7, space.bounds.topLeft.y + 20))));
          return -space.bounds.topLeft.y;
        }
        var key = calculateKey(space, i % directions.length, rockTypeIx);
        if (memo.containsKey(key)) {
          if (!jumpMade) {
            var oldCase = memo[key]!;
            var di = i - oldCase[0];
            var dh = space.bounds.topLeft.y - oldCase[1];
            var dr = rocksFixed - oldCase[2];
            var loopsNeeded = ((1000000000000 - rocksFixed) / dr).floor();
            i += loopsNeeded * di;
            rocksFixed += loopsNeeded * dr;
            copyGrid(50, space.bounds.topLeft.y,
                space.bounds.topLeft.y + loopsNeeded * dh, space);
            jumpMade = true;
          }
        } else {
          memo[key] = [i, space.bounds.topLeft.y, rocksFixed];
        }
      }
    }
  });

  var allOK = await rig.testSnippet("sample", 1514285714288);
  if (allOK) await rig.runPrint();
}

void copyGrid(int lines, int yFrom, int yTo, Space<String> space) {
  var dy = yTo - yFrom;
  for (var y = yFrom; y < yFrom + lines; y++) {
    for (var x = 0; x < 7; x++) {
      var found = space.at(Coord(x, y));
      if (found == null) continue;
      space.set(Coord(x, y + dy), found);
    }
  }
  print(space.visualize((val) => val,
      bnds: Rect(
          space.bounds.topLeft, Coord(7, space.bounds.topLeft.y + lines))));
}

String calculateKey(Space<String> space, int i, int rockTypeIx) {
  var result = "";
  for (var x = 0; x < 7; x++) {
    for (var y = space.bounds.topLeft.y; y < space.bounds.topLeft.y + 20; y++) {
      result += space.at(Coord(x, y)) == null ? '.' : '#';
    }
  }
  return "$i-$rockTypeIx-$result";
}
