import 'package:aoc/coord.dart';
import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

class Reading {
  Coord from;
  Coord closest;
  Reading(this.from, this.closest);
}

void main(List<String> arguments) async {
  final rig = Rig(15, (raw, {dynamic extra}) async {
    var items = parseToObjects(
        raw,
        RegExp(
            r'Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)'),
        (matches) {
      return Reading(
        Coord(int.parse(matches[0]), int.parse(matches[1])),
        Coord(int.parse(matches[2]), int.parse(matches[3])),
      );
    });
    int line = extra as int;
    var impossible = <int>{};
    for (var reading in items) {
      var dist = reading.from.manhattan(reading.closest);
      var distx = dist - (reading.from.y - line).abs();
      for (var x = reading.from.x - distx; x <= reading.from.x + distx; x++) {
        impossible.add(x);
      }
    }
    for (var reading in items) {
      if (reading.closest.y == line) {
        impossible.remove(reading.closest.x);
      }
    }

    return impossible.length;
  });

  var allOK = await rig.testSnippet("sample", 26, extra: 10);
  // allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint(extra: 2000000);
}
