import 'dart:math';

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
    var space = Rect(Coord(0, 0), Coord(extra, extra));
    for (var y = space.topLeft.y; y <= space.bottomRight.y; y++) {
      var availableRange = Range(0, extra);
      for (var reading in items) {
        Part? toBlock = blocksRange(reading, y);
        if (toBlock == null) continue;
        availableRange.remove(toBlock);
        if (availableRange.length == 0) break;
      }
      if (y % 10000 == 0) {
        print("Evaluated line y=$y");
      }
      if (availableRange.length > 0) {
        return 4000000 * availableRange.values.first + y;
      }
    }
    throw Exception("No free spot found");
  });

  var allOK = true; //await rig.testSnippet("sample", 56000011, extra: 20);
  // allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint(extra: 4000000);
}

Part? blocksRange(Reading reading, int y) {
  var dist = reading.from.manhattan(reading.closest);
  var distx = dist - (reading.from.y - y).abs();
  if (distx < 0) return null;
  return Part(reading.from.x - distx, reading.from.x + distx);
}

class Range {
  List<Part> parts = [];
  Range(int from, int to) {
    parts.add(Part(from, to));
  }

  int get length => parts.fold(0, (acc, p) => acc + p.length);

  Iterable<int> get values =>
      parts.fold([], (acc, p) => acc.followedBy(p.values));
  void remove(Part toRemove) {
    Iterable<Part> newParts = [];
    for (var i = 0; i < parts.length; i++) {
      var p = parts[i];
      if (p.overlaps(toRemove)) {
        newParts = newParts.followedBy(p.remove(toRemove));
        parts.removeAt(i);
        i--;
      }
    }
    parts = parts.followedBy(newParts).toList();
    // print(
    //     "Removed block from ${toRemove.from} to ${toRemove.to}. Remaining: $length");
  }
}

class Part {
  int from;
  int to;
  Part(this.from, this.to);
  int get length => to - from + 1;

  Iterable<int> get values sync* {
    for (var i = from; i <= to; i++) {
      yield i;
    }
  }

  bool overlaps(Part other) {
    if (other.to < from) return false;
    if (other.from > to) return false;
    return true;
  }

  Iterable<Part> remove(Part other) sync* {
    if (!overlaps(other)) {
      yield this;
      return;
    }
    if (from < other.from) {
      yield Part(from, min(to, other.from - 1));
    }
    if (to > other.to) {
      yield Part(max(from, other.to + 1), to);
    }
  }
}
