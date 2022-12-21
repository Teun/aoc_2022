import 'dart:math';

import 'package:aoc/lineparser.dart';
import 'package:aoc/pathfinder.dart';
import 'package:aoc/rig.dart';

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
    var qualities = items.map((it) {
      memoHits = 0;
      memoMisses = 0;
      memo.clear();
      return getQualityLevelFor(it, 24, Inventory(0, 0, 0, 0, 1, 0, 0, 0));
    });
    return qualities.fold(0, (acc, v) => acc + v);
  });

  var allOK = await rig.testSnippet("sample", 33);
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

  Blueprint(List<int> numbers)
      : ID = numbers[0],
        oreRobotOre = numbers[1],
        clayRobotOre = numbers[2],
        obsidianRobotOre = numbers[3],
        obsidianRobotClay = numbers[4],
        geodeRobotOre = numbers[5],
        geodeRobotObsidian = numbers[6];
  @override
  String toString() {
    return "$oreRobotOre-$clayRobotOre-$obsidianRobotOre-$obsidianRobotClay-$geodeRobotOre-$geodeRobotObsidian";
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

  void collect() {
    ore += oreRobots;
    clay += clayRobots;
    obsidian += obsidianRobots;
    geodes += geodeRobots;
  }

  @override
  String toString() {
    return "$ore-$clay-$obsidian-$geodes=$oreRobots-$clayRobots-$obsidianRobots-$geodeRobots";
  }
}

enum Robot { Ore, Clay, Obsidian, Geode }

int memoHits = 0;
int memoMisses = 0;
Map<String, int> memo = {};
int getQualityLevelFor(Blueprint bp, int timeLeft, Inventory inv) {
  String key = "";
  if (timeLeft >= 5) {
    key = "$bp:$inv:$timeLeft";
    if (memo.containsKey(key)) {
      memoHits++;
      return memo[key]!;
    }
  }
  memoMisses++;
  if (memoMisses % 1000000 == 0) {
    print(
        "Execution $memoMisses: bp: ${bp.ID}, size of memo: ${memo.length}, hits: $memoHits");
  }
  if (timeLeft == 0) return inv.geodes;
  timeLeft--;
  var inventories = nextStepInventories(inv, bp);
  var bestValue = inventories.fold(
      0, (prev, v) => max(prev, getQualityLevelFor(bp, timeLeft, v)));
  if (timeLeft + 1 >= 5) {
    memo[key] = bestValue;
  }
  return bestValue;
}

List<Inventory> nextStepInventories(Inventory inv, Blueprint bp) {
  List<Inventory> found = [];
  Inventory newInv = Inventory.from(inv);
  newInv.collect();
  found.add(newInv);
  if (canBuild(inv, Robot.Ore, bp)) {
    newInv = Inventory.from(inv);
    newInv.collect();
    newInv.oreRobots++;
    newInv.ore -= bp.oreRobotOre;
    found.add(newInv);
  }
  if (canBuild(inv, Robot.Clay, bp)) {
    newInv = Inventory.from(inv);
    newInv.collect();
    newInv.clayRobots++;
    newInv.ore -= bp.clayRobotOre;
    found.add(newInv);
  }
  if (canBuild(inv, Robot.Obsidian, bp)) {
    newInv = Inventory.from(inv);
    newInv.collect();
    newInv.obsidianRobots++;
    newInv.ore -= bp.obsidianRobotOre;
    newInv.clay -= bp.obsidianRobotClay;
    found.add(newInv);
  }
  if (canBuild(inv, Robot.Geode, bp)) {
    newInv = Inventory.from(inv);
    newInv.collect();
    newInv.geodeRobots++;
    newInv.ore -= bp.geodeRobotOre;
    newInv.obsidian -= bp.geodeRobotObsidian;
    found.add(newInv);
  }
  return found.toList();
}

bool canBuild(Inventory inv, Robot rtype, Blueprint bp) {
  if (rtype == Robot.Ore) {
    return inv.ore >= bp.oreRobotOre;
  }
  if (rtype == Robot.Clay) {
    return inv.ore >= bp.clayRobotOre;
  }
  if (rtype == Robot.Obsidian) {
    return inv.ore >= bp.obsidianRobotOre && inv.clay >= bp.obsidianRobotClay;
  }
  if (rtype == Robot.Geode) {
    return inv.ore >= bp.geodeRobotOre && inv.obsidian >= bp.geodeRobotObsidian;
  }
  return false;
}
