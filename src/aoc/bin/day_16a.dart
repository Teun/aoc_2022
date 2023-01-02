import 'dart:developer';
import 'dart:math';

import 'package:aoc/lineparser.dart';
import 'package:aoc/pathfinder.dart';
import 'package:aoc/rig.dart';

const int MINUTES_AVAILABLE = 26;
void main(List<String> arguments) async {
  final rig = Rig(16, (raw, {extra = 1}) async {
    var items = parseToObjects(
        raw,
        RegExp(
            r'Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? ([\w, ]+)'),
        (matches) {
      return matches;
    });
    var maze = buildMaze(items);
    var usefulValves = maze._valves.values.where((v) => v.flow > 0).length;
    var pf = Pathfinder();
    var counter = 0;
    var paths = pf.strictRounds<State, TwoSteps>((from, path, round) {
      counter++;
      if (counter % 1000 == 0) {
        print("Exploring path $counter. Cost: ${path.cost}");
      }
      if (from.opened.length >= usefulValves) {
        return [StepTo(from, TwoSteps("wait", "wait"))];
      }
      int timeLeft = MINUTES_AVAILABLE - round;
      var myMoves = getPossibleMoves(from.targetValveName, from.targetDistance,
          maze, from.opened, timeLeft);
      var elephantsMoves = getPossibleMoves(from.elephantTargetValveName,
          from.elephantTargetDistance, maze, from.opened, timeLeft);
      var combined = combineActions(myMoves, elephantsMoves);
      var moves = combined.map((p) {
        var newState = State(
            from.targetValveName,
            from.elephantTargetValveName,
            from.opened.entries,
            from.targetDistance,
            from.elephantTargetDistance);
        var valueGained = 0;
        if (p.mine.length == 2) {
          // go
          newState.targetValveName = p.mine;
          newState.targetDistance =
              maze.get(from.targetValveName).ways[p.mine]!;
        }
        if (p.elephants.length == 2) {
          // go
          newState.elephantTargetValveName = p.elephants;
          newState.elephantTargetDistance =
              maze.get(from.elephantTargetValveName).ways[p.elephants]!;
        }
        if (p.mine == "open") {
          newState.opened[from.targetValveName] = round;
          newState.targetDistance = 1;
          valueGained +=
              (MINUTES_AVAILABLE - round) * maze.get(from.targetValveName).flow;
        }
        if (p.elephants == "open") {
          if (!newState.opened.containsKey(from.elephantTargetValveName)) {
            // prevnt double scoring
            newState.opened[from.elephantTargetValveName] = round;
            valueGained += (MINUTES_AVAILABLE - round) *
                maze.get(from.elephantTargetValveName).flow;
          }
          newState.elephantTargetDistance = 1;
        }
        if (p.mine == "wait") {
          newState.targetDistance = 1;
        }
        if (p.elephants == "wait") {
          newState.elephantTargetDistance = 1;
        }
        newState.tick(1);
        return StepTo<State, TwoSteps>(newState, p,
            value: valueGained.toDouble());
      });
      return moves.toList();
    }, State("AA", "AA", {}, 0, 0), 26, maxGenerationSize: 10000);
    return paths.first.value;
  });

  var allOK = await rig.testSnippet("sample", 1707);
  // allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}

Maze buildMaze(List<List<String>> items) {
  var maze = Maze();
  for (var item in items) {
    maze.add(Valve(item[0], int.parse(item[1]), item[2].split(", ").toList()));
  }
  for (var name in maze._valves.keys.toList()) {
    var valve = maze.get(name);
    if (valve.flow == 0 && valve.ways.length == 2) {
      var pre = maze.get(valve.ways.keys.first);
      var post = maze.get(valve.ways.keys.last);
      assert(pre.ways[post.name] == null);
      assert(post.ways[pre.name] == null);
      pre.ways[post.name] = pre.ways[name]! + valve.ways[post.name]!;
      post.ways[pre.name] = post.ways[name]! + valve.ways[pre.name]!;
      pre.ways.remove(name);
      post.ways.remove(name);
      maze._valves.remove(name);
    }
  }
  return maze;
}

List<TwoSteps> combineActions(
    List<String> myMoves, List<String> elephantsMoves) {
  List<TwoSteps> result = [];
  for (var my in myMoves) {
    for (var el in elephantsMoves) {
      result.add(TwoSteps(my, el));
    }
  }
  return result;
}

List<String> getPossibleMoves(String valveName, int distance, Maze maze,
    Map<String, int> opened, int timeLeft) {
  if (distance > 0) return ["continue"];
  var valve = maze.get(valveName);
  var actions =
      valve.ways.keys.where((w) => valve.ways[w]! < timeLeft).toList();
  if (!opened.containsKey(valveName) && valve.flow > 0) {
    actions.add("open");
  } else {
    // print("already open");
  }
  if (actions.isEmpty) {
    actions.add("wait");
  }
  return actions;
}

class TwoSteps {
  String mine;
  String elephants;
  TwoSteps(this.mine, this.elephants);
  @override
  String toString() {
    return "[$mine-$elephants]";
  }
}

class Maze {
  final Map<String, Valve> _valves = {};
  Valve get(String name) => _valves[name]!;
  void add(Valve v) => _valves[v.name] = v;
}

class Valve {
  String name;
  int flow;
  Map<String, int> ways = {};
  Valve(this.name, this.flow, List<String> ways) {
    for (var name in ways) {
      this.ways[name] = 1;
    }
  }
}

class State {
  String targetValveName;
  int targetDistance = 0;
  String elephantTargetValveName;
  int elephantTargetDistance = 0;

  Map<String, int> opened = {};
  State(
      this.targetValveName,
      this.elephantTargetValveName,
      Iterable<MapEntry<String, int>> prevOpened,
      this.targetDistance,
      this.elephantTargetDistance) {
    opened = Map.fromEntries(prevOpened);
  }
  String? _poss;
  String get jointPositions {
    if (_poss == null) {
      if (targetValveName.compareTo(elephantTargetValveName) < 0) {
        _poss =
            "$targetValveName$targetDistance$elephantTargetValveName$elephantTargetDistance";
      } else {
        _poss =
            "$elephantTargetValveName$elephantTargetDistance$targetValveName$targetDistance";
      }
    }
    return _poss!;
  }

  String? _hash;
  String mapHash() {
    if (_hash == null) {
      var vals = opened.entries.toList();
      vals.sort((p1, p2) => opened[p1.key]!.compareTo(opened[p2.key]!));
      _hash = vals.map((e) => "${e.key}${e.value}").join("-");
    }
    return _hash!;
  }

  @override
  bool operator ==(Object other) {
    if (other is! State) return false;
    return jointPositions == other.jointPositions &&
        mapHash() == other.mapHash();
  }

  @override
  int get hashCode {
    var result = jointPositions.hashCode;
    result ^= mapHash().hashCode;
    return result;
  }

  @override
  String toString() {
    return "[$targetValveName-$elephantTargetValveName] ${mapHash()}";
  }

  void tick(int toWait) {
    assert(toWait <= targetDistance);
    assert(toWait <= elephantTargetDistance);
    targetDistance -= toWait;
    elephantTargetDistance -= toWait;
  }
}
