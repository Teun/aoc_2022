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
    var geodeCounts = items.take(3).map(getMaxGeodes);
    return geodeCounts.fold(1, (acc, v) => acc * v);
  });

  var allOK = await rig.testSnippet("sample", 56 * 62);
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
  int time;
  int oreRobots;
  int ore;
  int clayRobots;
  int clay;
  int obsidianRobots;
  int obsidian;
  int geodeRobots;
  int geodes;
  Inventory(this.time, this.ore, this.clay, this.obsidian, this.geodes,
      this.oreRobots, this.clayRobots, this.obsidianRobots, this.geodeRobots);
  Inventory.from(Inventory other, int waiting)
      : time = other.time,
        ore = other.ore,
        clay = other.clay,
        obsidian = other.obsidian,
        geodes = other.geodes,
        oreRobots = other.oreRobots,
        clayRobots = other.clayRobots,
        obsidianRobots = other.obsidianRobots,
        geodeRobots = other.geodeRobots {
    wait(waiting);
  }
  void wait(int ticks) {
    time += ticks;
    ore += ticks * oreRobots;
    clay += ticks * clayRobots;
    obsidian += ticks * obsidianRobots;
    geodes += ticks * geodeRobots;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Inventory) return false;
    return time == other.time &&
        ore == other.ore &&
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
      time.hashCode ^
      ore.hashCode ^
      clay.hashCode ^
      obsidian.hashCode ^
      geodes.hashCode;
}

enum Robot { Ore, Clay, Obsidian, Geode, None }

int counter = 0;
int getMaxGeodes(Blueprint bp) {
  var pf = Pathfinder();
  var bestScore = 0;
  var paths = pf.breadthFirstAll<Inventory, Robot>((from, path) {
    counter++;
    if (counter % 1000 == 0) {
      var steps = path.steps.map((e) => e.step).toList();
      print(
          "Explored $counter paths. This path at ${from.time} s. in ${steps.length} steps");
    }
    if (from.time >= 32) return [];
    List<StepTo<Inventory, Robot>> result = [];
    var bestConceivableScore =
        estimatedMaxTotalScore(32, from, bp.geodeRobotObsidian);
    if (bestScore > 1 && bestScore >= bestConceivableScore) {
      // we already have a solution that this path cannot exceed
      return result;
    }
    var tn = waitTimeNeeded(from.ore, from.oreRobots, bp.oreRobotOre);
    if (from.time + tn < 32 && from.oreRobots < bp.maxOre) {
      var newInv = Inventory.from(from, tn + 1);
      newInv.oreRobots++;
      newInv.ore -= bp.oreRobotOre;
      result.add(StepTo(newInv, Robot.Ore));
    }
    tn = waitTimeNeeded(from.ore, from.oreRobots, bp.clayRobotOre);
    if (from.time + tn < 32) {
      var newInv = Inventory.from(from, tn + 1);
      newInv.clayRobots++;
      newInv.ore -= bp.clayRobotOre;
      result.add(StepTo(newInv, Robot.Clay));
    }
    tn = max(waitTimeNeeded(from.ore, from.oreRobots, bp.obsidianRobotOre),
        waitTimeNeeded(from.clay, from.clayRobots, bp.obsidianRobotClay));
    if (from.time + tn < 32) {
      var newInv = Inventory.from(from, tn + 1);
      newInv.obsidianRobots++;
      newInv.ore -= bp.obsidianRobotOre;
      newInv.clay -= bp.obsidianRobotClay;
      if (newInv.clay < 0) {
        print("");
      }
      result.add(StepTo(newInv, Robot.Obsidian));
    }
    tn = max(
        waitTimeNeeded(from.ore, from.oreRobots, bp.geodeRobotOre),
        waitTimeNeeded(
            from.obsidian, from.obsidianRobots, bp.geodeRobotObsidian));
    if (from.time + tn < 32) {
      var newInv = Inventory.from(from, tn + 1);
      newInv.ore -= bp.geodeRobotOre;
      newInv.obsidian -= bp.geodeRobotObsidian;
      newInv.geodeRobots++;
      result.add(StepTo(newInv, Robot.Geode));
    }
    if (result.isEmpty && from.time < 32) {
      // wait it out
      result.add(StepTo(Inventory.from(from, 32 - from.time), Robot.None));
    }
    return result;
  }, (path) {
    if (path.to.geodes > bestScore) {
      bestScore = path.to.geodes;
    }
    return false;
  }, Inventory(0, 0, 0, 0, 0, 1, 0, 0, 0));
  paths.sort((a, b) => b.to.geodes.compareTo(a.to.geodes));
  var bestPath = paths.first;
  var steps = bestPath.steps.toList();
  print("${bp.ID}: $bestPath");
  return bestPath.to.geodes;
}

int estimatedMaxTotalScore(
    int totalTime, Inventory from, int geodeRobotObsidian) {
  var timeLeft = totalTime - from.time;
  var score = from.geodes;
  score += timeLeft * from.geodeRobots;
  if (from.obsidianRobots > 0) {
    score += (timeLeft -
        ((geodeRobotObsidian - from.obsidian) ~/ from.obsidianRobots));
  }
  score += (timeLeft - 10).clamp(0, 20);
  return score;
}

int waitTimeNeeded(int have, int producers, int needed) {
  var fullTime = ((needed - have) / producers);
  if (fullTime > 100) return 100;
  return fullTime.ceil().clamp(0, 100);
}
