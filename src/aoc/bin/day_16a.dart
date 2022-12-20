import 'dart:math';

import 'package:aoc/lineparser.dart';
import 'package:aoc/pathfinder.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(16, (raw, {extra = 1}) async {
    var items = parseToObjects(
        raw,
        RegExp(
            r'Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? ([\w, ]+)'),
        (matches) {
      return matches;
    });
    var maze = Maze();
    for (var item in items) {
      maze.add(
          Valve(item[0], int.parse(item[1]), item[2].split(", ").toList()));
    }
    var usefulValves = maze._valves.values.where((v) => v.flow > 0).length;
    var pf = Pathfinder();
    var allPaths = pf.breadthFirstAll<State, TwoSteps>((from, path) {
      if (from.opened.length >= usefulValves) return [];
      List<StepTo<State, TwoSteps>> nexts = [];
      var myMoves = getPossibleMoves(from.valveName, maze, from.opened);
      var elephantsMoves =
          getPossibleMoves(from.elephantValveName, maze, from.opened);
      var combined = combineActions(myMoves, elephantsMoves);
      var moves = combined.map((p) {
        var myNewValve = p.mine == "open" ? from.valveName : p.mine;
        var elNewValve =
            p.elephants == "open" ? from.elephantValveName : p.elephants;
        var opened = from.opened.entries.toList();
        if (p.mine == "open") {
          opened.add(MapEntry(from.valveName, path.steps.length));
        }
        if (p.elephants == "open") {
          opened.add(MapEntry(from.elephantValveName, path.steps.length));
        }
        var newState = State(myNewValve, elNewValve, opened);
        return StepTo<State, TwoSteps>(newState, p);
      });
      return moves.toList();
    }, (path) {
      logProgress(path);
      return path.steps.length > 30;
    }, State("AA", "AA", {}));
    var value = allPaths.fold(0, (acc, path) {
      var value = valueForPath(path, maze);
      return max(value, acc);
    });
    return value;
  });

  var allOK = await rig.testSnippet("sample", 1707);
  // allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
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

List<String> getPossibleMoves(
    String valveName, Maze maze, Map<String, int> opened) {
  var actions = maze.get(valveName).ways;
  if (!opened.containsKey(valveName) && maze.get(valveName).flow > 0) {
    actions.add("open");
  } else {
    // print("already open");
  }
  return actions;
}

int evalCounter = 0;
void logProgress(PathTo<State, TwoSteps> path) {
  evalCounter++;
  if (evalCounter % 1000 == 0) {
    print("Evaluated $evalCounter paths, last: ${path.steps.length} steps");
  }
}

int valueForPath(PathTo<State, TwoSteps> path, Maze maze) {
  return path.to.opened.entries
      .fold(0, (acc, e) => acc + maze.get(e.key).flow * (26 - e.value));
}

class TwoSteps {
  String mine;
  String elephants;
  TwoSteps(this.mine, this.elephants);
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
  List<String> ways;
  Valve(this.name, this.flow, this.ways);
}

class State {
  String valveName;
  String elephantValveName;
  Map<String, int> opened = {};
  State(this.valveName, this.elephantValveName,
      Iterable<MapEntry<String, int>> prevOpened) {
    opened = Map.fromEntries(prevOpened);
  }
  String? _poss;
  String get jointPositions {
    if (_poss == null) {
      if (valveName.compareTo(elephantValveName) < 0) {
        _poss = "$valveName$elephantValveName";
      } else {
        _poss = "$elephantValveName$valveName";
      }
    }
    return _poss!;
  }

  String? _hash;
  String mapHash() {
    if (_hash == null) {
      var vals = opened.keys.toList();
      vals.sort((p1, p2) => opened[p1]!.compareTo(opened[p2]!));
      _hash = vals.join("-");
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
    return "[$valveName-$elephantValveName] ${mapHash()}";
  }
}
