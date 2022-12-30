import 'dart:math';

import 'package:aoc/lineparser.dart';
import 'package:aoc/pathfinder.dart';
import 'package:aoc/rig.dart';
import 'package:aoc/thenby.dart';

void main(List<String> arguments) async {
  final rig = Rig(19, (raw, {extra = 1}) async {
    var items = parseToObjects(
        raw,
        RegExp(
            r'Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian.'),
        (matches) {
      var asNumbers = matches.map(int.parse);
      return Blueprint(asNumbers.toList());
    });
    var geodeCounts = items.take(3).map(getMaxGeodes);
    return geodeCounts.fold(1, (acc, v) => acc * v);
  });

  var allOK = true;
  //await rig.testSnippet("sample", 56 * 62);
  //allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}

class Blueprint {
  int ID;
  int oreRobotOre;
  int clayRobotOre;
  int obsidianRobotOre;
  int obsidianRobotClay;
  int geodeRobotOre;
  int geodeRobotObsidian;

  late int maxOre;

  Blueprint(List<int> numbers)
      : ID = numbers[0],
        oreRobotOre = numbers[1],
        clayRobotOre = numbers[2],
        obsidianRobotOre = numbers[3],
        obsidianRobotClay = numbers[4],
        geodeRobotOre = numbers[5],
        geodeRobotObsidian = numbers[6] {
    maxOre = [oreRobotOre, clayRobotOre, obsidianRobotOre, geodeRobotOre]
        .fold(0, (acc, v) => max(acc, v));
  }
}

class Inventory {
  int oreRobots;
  int ore;
  int clayRobots;
  int clay;
  int obsidianRobots;
  int obsidian;
  int geodeRobots;
  int geodes;
  Inventory(this.ore, this.clay, this.obsidian, this.geodes, this.oreRobots,
      this.clayRobots, this.obsidianRobots, this.geodeRobots);
  Inventory.from(Inventory other)
      : ore = other.ore,
        clay = other.clay,
        obsidian = other.obsidian,
        geodes = other.geodes,
        oreRobots = other.oreRobots,
        clayRobots = other.clayRobots,
        obsidianRobots = other.obsidianRobots,
        geodeRobots = other.geodeRobots;
  void wait(int ticks) {
    ore += ticks * oreRobots;
    clay += ticks * clayRobots;
    obsidian += ticks * obsidianRobots;
    geodes += ticks * geodeRobots;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Inventory) return false;
    return ore == other.ore &&
        clay == other.clay &&
        obsidian == other.obsidian &&
        geodes == other.geodes &&
        oreRobots == other.oreRobots &&
        clayRobots == other.clayRobots &&
        obsidianRobots == other.obsidianRobots &&
        geodeRobots == other.geodeRobots;
  }

  @override
  int get hashCode =>
      ore.hashCode ^ clay.hashCode ^ obsidian.hashCode ^ geodes.hashCode;
}

enum Robot { Ore, Clay, Obsidian, Geode, None }

int counter = 0;
int getMaxGeodes(Blueprint bp) {
  nextSteps(Inventory from) {
    List<Inventory> result = [];
    if (from.oreRobots < bp.maxOre && from.ore >= bp.oreRobotOre) {
      var newInv = Inventory.from(from);
      newInv.wait(1);
      newInv.oreRobots++;
      newInv.ore -= bp.oreRobotOre;
      result.add(newInv);
    }
    if (from.ore >= bp.clayRobotOre) {
      var newInv = Inventory.from(from);
      newInv.wait(1);
      newInv.clayRobots++;
      newInv.ore -= bp.clayRobotOre;
      result.add(newInv);
    }
    if (from.ore >= bp.obsidianRobotOre && from.clay >= bp.obsidianRobotClay) {
      var newInv = Inventory.from(from);
      newInv.wait(1);
      newInv.obsidianRobots++;
      newInv.ore -= bp.obsidianRobotOre;
      newInv.clay -= bp.obsidianRobotClay;
      result.add(newInv);
    }
    if (from.ore >= bp.geodeRobotOre &&
        from.obsidian >= bp.geodeRobotObsidian) {
      var newInv = Inventory.from(from);
      newInv.wait(1);
      newInv.ore -= bp.geodeRobotOre;
      newInv.obsidian -= bp.geodeRobotObsidian;
      newInv.geodeRobots++;
      result.add(newInv);
    }
    var newInv = Inventory.from(from);
    newInv.wait(1);
    result.add(newInv);
    return result;
  }

  var allInventories = <Inventory>{};
  var currPaths = [Inventory(0, 0, 0, 0, 1, 0, 0, 0)];
  for (var i = 0; i < 32; i++) {
    var nextGenPaths = <Inventory>[];
    for (var p in currPaths) {
      var nexts = nextSteps(p);
      for (var next in nexts) {
        if (!allInventories.contains(next)) {
          nextGenPaths.add(next);
          allInventories.add(next);
        }
      }
    }
    currPaths = nextGenPaths;
    if (currPaths.length > 4000) {
      currPaths.sort(firstBy((Inventory inv) => inv.geodes, dir: Direction.desc)
          .thenBy((inv) => inv.geodeRobots, dir: Direction.desc)
          .thenBy((inv) => inv.obsidian, dir: Direction.desc)
          .thenBy((inv) => inv.obsidianRobots, dir: Direction.desc)
          .thenBy((inv) => inv.clay, dir: Direction.desc)
          .thenBy((inv) => inv.ore, dir: Direction.desc));
      currPaths = currPaths.sublist(0, 4000);
    }
    print("Calculated gen $i, ${currPaths.length} states");
  }
  return currPaths.first.geodes;
}
