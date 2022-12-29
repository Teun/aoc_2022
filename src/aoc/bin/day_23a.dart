import 'package:aoc/coord.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(23, (raw, {extra = 1}) async {
    var gen0 = Space.fromText(raw, (s, c) {
      if (s == "#") return Elf(c);
      return null;
    });
    var currGen = gen0;
    var lastState = currGen.visualize((val) => "#");
    for (var i = 0; i < 1000; i++) {
      currGen = getNextGen(currGen, i);
      var newState = currGen.visualize((val) => "#");
      if (newState == lastState) return i + 1;
      print("After round ${i + 1}: ${newState.length}");
      //print(newState);
      lastState = newState;
    }
    throw Exception("not finished");
  });

  var allOK = true;
  allOK &= await rig.testSnippet("sample", 20);
  //allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}

Space<Elf> getNextGen(Space<Elf> currGen, int i) {
  for (var elf in currGen.all.map((p) => p.value)) {
    elf.makeProposal(currGen, i);
  }
  var proposedSpots = <Coord>{};
  var doubleClaimed = <Coord>{};
  for (var spot in currGen.all.map((e) => e.value.proposedPos!)) {
    if (proposedSpots.contains(spot)) {
      doubleClaimed.add(spot);
    } else {
      proposedSpots.add(spot);
    }
  }
  for (var elf in currGen.all.map((p) => p.value)) {
    if (doubleClaimed.contains(elf.proposedPos)) {
      elf.proposedPos = elf.pos;
    }
  }
  return Space.fromEntries(currGen.all
      .map((p) => p.value)
      .map((elf) => MapEntry(elf.proposedPos!, Elf(elf.proposedPos!)))
      .toList());
}

class Elf {
  Coord pos;
  Coord? proposedPos;
  Elf(this.pos);
  static const directions = [
    Direction.north,
    Direction.south,
    Direction.west,
    Direction.east
  ];
  void makeProposal(Space<Elf> currGen, int round) {
    proposedPos = null;
    if (noNeighboursAnyway(currGen)) {
      proposedPos = pos;
      return;
    }
    for (var i = 0; i < 4; i++) {
      var dir = directions[(round + i) % 4];
      if (roomInDirection(dir, currGen)) {
        proposedPos = pos.toDirection(dir);
        break;
      }
    }
    proposedPos ??= pos;
  }

  bool roomInDirection(Direction dir, Space<Elf> currGen) {
    var toCheck = [
      pos.toDirection(dir),
      pos.toDirection(dir).toDirection(dir.toLeft()),
      pos.toDirection(dir).toDirection(dir.toRight())
    ];
    return toCheck.every((p) => currGen.at(p) == null);
  }

  bool noNeighboursAnyway(Space<Elf> currGen) {
    return (pos.neighboursIncludingDiag.every((c) => currGen.at(c) == null));
  }
}
