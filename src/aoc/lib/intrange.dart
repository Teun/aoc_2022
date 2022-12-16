import 'dart:math';
import 'package:aoc/thenby.dart';

class IntRange {
  List<Part> parts = [];
  IntRange(int from, int to) {
    parts.add(Part(from, to));
  }

  int get length => parts.fold(0, (acc, p) => acc + p.length);

  Iterable<int> get values {
    parts.sort(firstBy((Part p) => p.from));
    return parts.fold([], (acc, p) => acc.followedBy(p.values));
  }

  void remove(int from, int to) {
    Part toRemove = Part(from, to);
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

  void union(IntRange other) {
    var allParts = parts.followedBy(other.parts).toList();
    allParts.sort(firstBy((Part p) => p.from));
    var i = 0;
    while (i < allParts.length - 1) {
      if (allParts[i + 1].from <= allParts[i].to) {
        allParts[i].to = max(allParts[i].to, allParts[i + 1].to);
        allParts.removeAt(i + 1);
        continue;
      }
      i++;
    }
    parts = allParts;
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
