import 'package:aoc/coord.dart';
import 'package:aoc/pathfinder.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(12, (raw, {dynamic extra}) async {
    Coord start = Coord(0, 0);
    Coord end = Coord(0, 0);

    var space = Space.fromText(raw, (v, p) {
      if (v == "S") {
        start = p;
        return 1;
      }
      if (v == "E") {
        end = p;
        return 26;
      }
      return v.codeUnitAt(0) - "a".codeUnitAt(0) + 1;
    });
    var finder = Pathfinder();
    var path = finder.breadthFirst<Coord, Direction>((from) {
      var neighbours = [
        Direction.north,
        Direction.south,
        Direction.east,
        Direction.west
      ].map((e) => StepTo(from.toDirection(e), e));
      return neighbours.where((s) {
        if (space.at(s.pos) == null) return false;
        var stepUp = (space.at(s.pos)! - space.at(from)!);
        return stepUp <= 1;
      }).toList();
    }, (pos) => pos == end, start);
    return path.steps.length - 1;
  });

  var allOK = await rig.testSnippet("sample", 31);
//  allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}
