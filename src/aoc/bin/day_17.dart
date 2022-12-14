import 'package:aoc/coord.dart';
import 'package:aoc/lineparser.dart';
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
    bool rockFalling = false;
    Coord currentRockPos = Coord(0, 0);
    int rockTypeIx = 0;
    int rocksFixed = 0;
    List<Coord> currentRock = [];
    for (var i = 0; i < 100000; i++) {
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
        if (rocksFixed == 2022) return -space.bounds.topLeft.y;
      }
    }
    throw Exception();
  });

  var allOK = await rig.testSnippet("sample", 3068);
  if (allOK) await rig.runPrint();
}
