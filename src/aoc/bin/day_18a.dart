import 'dart:collection';
import 'dart:math';

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
    var setOfSurrounding = fillEnvelope(set);
    var freeSurfaces = 0;
    for (var spot in set) {
      for (var neighbour in spot.getNeighbours()) {
        if (setOfSurrounding.contains(neighbour)) {
          freeSurfaces++;
        }
      }
    }
    return freeSurfaces;
  });

  var allOK = await rig.testSnippet("sample", 58);
  if (allOK) await rig.runPrint();
}

Set<Coord3D> fillEnvelope(Set<Coord3D> set) {
  var maxX = set.fold(0, (acc, v) => max(acc, v.x)) + 1;
  var maxY = set.fold(0, (acc, v) => max(acc, v.y)) + 1;
  var maxZ = set.fold(0, (acc, v) => max(acc, v.z)) + 1;
  var queue = Queue<Coord3D>();
  var result = <Coord3D>{};
  queue.add(Coord3D(0, 0, 0));
  do {
    var explore = queue.removeFirst();
    for (var nb in explore.getNeighbours()) {
      if (nb.x >= -1 &&
          nb.x <= maxX &&
          nb.y >= -1 &&
          nb.y <= maxY &&
          nb.z >= -1 &&
          nb.z <= maxZ &&
          !result.contains(nb) &&
          !set.contains(nb)) {
        result.add(nb);
        queue.add(nb);
      }
    }
  } while (queue.isNotEmpty);
  return result;
}
