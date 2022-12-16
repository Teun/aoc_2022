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
    var pf = Pathfinder();
    var allPaths = pf.breadthFirstAll<State, String>((from, path) {
      List<StepTo<State, String>> nexts = [];
      var waysOut = maze.get(from.valveName).ways;
      var moves = waysOut.map((w) {
        var step = StepTo<State, String>(State(w, from.opened.entries, 0), w);
        return step;
      });
      nexts.addAll(moves);
      if (!from.opened.containsKey(from.valveName) &&
          maze.get(from.valveName).flow > 0) {
        var step = StepTo<State, String>(
            State(
                from.valveName,
                from.opened.entries
                    .followedBy([MapEntry(from.valveName, path.steps.length)]),
                0),
            "open");
        nexts.add(step);
      }
      return nexts;
    }, (path) {
      return path.steps.length > 30;
    }, State("AA", {}, 0));
    var value = allPaths.fold(0, (acc, path) {
      var value = valueForPath(path, maze);
      return max(value, acc);
    });
    return value;
  });

  var allOK = await rig.testSnippet("sample", 1651);
  // allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}

int valueForPath(PathTo<State, String> path, Maze maze) {
  var list = path.steps.toList();
  return path.to.opened.entries
      .fold(0, (acc, e) => acc + maze.get(e.key).flow * (30 - e.value));
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
  Map<String, int> opened = {};
  int thenWaited;
  State(this.valveName, Iterable<MapEntry<String, int>> prevOpened,
      this.thenWaited) {
    opened = Map.fromEntries(prevOpened);
  }

  String? _hash;
  String mapHash() {
    if (_hash == null) {
      var vals = opened.values.toList();
      vals.sort((p1, p2) => p1.compareTo(p2));
      _hash = vals.join("-");
    }
    return _hash!;
  }

  @override
  bool operator ==(Object other) {
    if (other is! State) return false;

    return valveName == other.valveName &&
        mapHash() == other.mapHash() &&
        thenWaited == other.thenWaited;
  }

  @override
  int get hashCode {
    var result = valveName.hashCode;
    for (var v in opened.keys) {
      result ^= v.hashCode ^ opened[v].hashCode;
    }
    result ^= thenWaited;
    return result;
  }
}
