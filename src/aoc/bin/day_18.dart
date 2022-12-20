import 'package:aoc/coord3d.dart';
import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(18, (raw, {extra = 1}) async {
    var items = parseToObjects(raw, RegExp(r'(\d+),(\d+),(\d+)'), (matches) {
      return Coord3D(
          int.parse(matches[0]), int.parse(matches[1]), int.parse(matches[2]));
    });
    var set = Set<Coord3D>.from(items);
    var freeSurfaces = 0;
    for (var spot in set) {
      for (var neighbour in spot.getNeighbours()) {
        if (!set.contains(neighbour)) {
          freeSurfaces++;
        }
      }
    }
    return freeSurfaces;
  });

  var allOK = await rig.testSnippet("sample", 64);
  if (allOK) await rig.runPrint();
}
