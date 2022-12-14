import 'dart:collection';
import 'dart:developer';

import 'package:aoc/cpu.dart';
import 'package:aoc/thenby.dart';
import 'package:collection/collection.dart';

abstract class Costed {
  abstract double cost;
}

class StepTo<TPos, TStep> {
  TPos pos;
  TStep? step;
  double cost;
  double value;
  StepTo(this.pos, this.step, {this.cost = 1.0, this.value = 0});
}

class PathTo<TPos, TStep> extends Comparable {
  Iterable<StepTo<TPos, TStep>> steps;
  PathTo(this.steps);
  double? _cost;
  double get cost {
    _cost ??= steps.fold<double>(0.0, (acc, s) => acc + s.cost);
    return _cost!;
  }

  double? _value;
  double get value {
    _value ??= steps.fold<double>(0.0, (acc, s) => acc + s.value);
    return _value!;
  }

  TPos? _to;
  TPos get to {
    _to ??= steps.last.pos;
    return _to!;
  }

  @override
  int compareTo(other) {
    return cost.compareTo(other.cost);
  }

  @override
  String toString() {
    var stepsString = steps.map((e) => e.step.toString()).join(' -> ');
    return "$stepsString\n$to";
  }
}

typedef ExploreFunc<TPos, TStep> = List<StepTo<TPos, TStep>> Function(
    TPos from);
typedef ExploreFunc2<TPos, TStep> = List<StepTo<TPos, TStep>> Function(
    TPos from, PathTo<TPos, TStep> path);
typedef ExploreFunc3<TPos, TStep> = List<StepTo<TPos, TStep>> Function(
    TPos from, PathTo<TPos, TStep> path, int round);
typedef TargetFunc<TPos> = bool Function(TPos pos);
typedef DoneFunc<TPos, TStep> = bool Function(PathTo<TPos, TStep> path);

class Pathfinder {
  PathTo<TPos, TStep> breadthFirstFind<TPos, TStep>(
      ExploreFunc<TPos, TStep> explore, TargetFunc<TPos> target, TPos start) {
    List<PathTo<TPos, TStep>> toExplore = [];
    Map<TPos, PathTo<TPos, TStep>> pathsTo = {};
    toExplore = [
      PathTo([StepTo(start, null, cost: 0.0)])
    ];
    pathsTo = {};
    pathsTo[start] = toExplore.first;
    while (true) {
      var exploringFrom = toExplore.removeAt(0);
      var nextLocations = explore(exploringFrom.to);
      for (var next in nextLocations) {
        if (!pathsTo.containsKey(next.pos)) {
          var newPath = PathTo(exploringFrom.steps.followedBy([next]));
          if (target(newPath.to)) {
            return newPath;
          }
          pathsTo[next.pos] = newPath;
          toExplore.add(newPath);
        }
      }
      if (toExplore.isEmpty) throw Exception("No path found");
    }
  }

  List<PathTo<TPos, TStep>> breadthFirstAll<TPos, TStep>(
      ExploreFunc2<TPos, TStep> explore,
      DoneFunc<TPos, TStep> done,
      TPos start) {
    var toExplore = Queue<PathTo<TPos, TStep>>.from([]);
    Map<TPos, PathTo<TPos, TStep>> pathsTo = {};
    toExplore.add(PathTo([StepTo(start, null, cost: 0.0)]));
    pathsTo = {};
    pathsTo[start] = toExplore.first;
    while (true) {
      var exploringFrom = toExplore.removeFirst();
      var nextLocations = explore(exploringFrom.to, exploringFrom);
      for (var next in nextLocations) {
        if (!pathsTo.containsKey(next.pos)) {
          var newPath = PathTo(exploringFrom.steps.followedBy([next]));
          if (done(newPath)) {
            return pathsTo.values.toList();
          }
          pathsTo[next.pos] = newPath;
          toExplore.add(newPath);
        } else {
          print(
              "Path already available: \n${pathsTo[next.pos].toString()}\nis equal to ${exploringFrom.toString()}\n + step ${next.step}");
        }
      }
      if (toExplore.isEmpty) {
        return pathsTo.values.toList();
      }
    }
  }

  List<PathTo<TPos, TStep>> strictRounds<TPos, TStep>(
      ExploreFunc3<TPos, TStep> explore, TPos start, int maxRounds,
      {int? maxGenerationSize}) {
    List<PathTo<TPos, TStep>> currGen = [
      PathTo([StepTo(start, null)])
    ];
    var round = 0;
    while (round < maxRounds) {
      round++;
      Map<TPos, PathTo<TPos, TStep>> nextGen = {};
      for (var path in currGen) {
        var nextLocations = explore(path.to, path, round);
        for (var newLoc in nextLocations) {
          if (!nextGen.containsKey(newLoc.pos)) {
            nextGen[newLoc.pos] = PathTo(path.steps.followedBy([newLoc]));
          }
        }
      }
      currGen = nextGen.values.toList();
      if (maxGenerationSize != null && currGen.length > maxGenerationSize) {
        currGen.sort(
            firstBy((PathTo<TPos, TStep> p) => p.value, dir: Direction.desc));
        currGen = currGen.sublist(0, maxGenerationSize);
      }
    }
    return currGen;
  }

  PathTo<TPos, TStep> findShortest<TPos, TStep>(
      ExploreFunc<TPos, TStep> explore, TargetFunc<TPos> target, TPos start,
      {double Function(TPos from)? minimalDistanceRemaining,
      void Function(int statesSeen, PathTo<TPos, TStep> best)? progress}) {
    var heuristicFunc = minimalDistanceRemaining ?? (p) => 0;
    var progressLogger = progress ?? (s, b) {};
    var toExplore = PriorityQueue<PathTo<TPos, TStep>>(((p0, p1) =>
        (p0.cost + heuristicFunc(p0.to))
            .compareTo(p1.cost + heuristicFunc(p1.to))));
    Map<TPos, PathTo<TPos, TStep>> pathsTo = {};
    PathTo<TPos, TStep>? bestPath;
    toExplore.add(PathTo([StepTo(start, null, cost: 0.0)]));
    pathsTo = {};
    pathsTo[start] = toExplore.first;
    do {
      var exploringFrom = toExplore.removeFirst();
      progressLogger(pathsTo.length, exploringFrom);
      if (bestPath != null &&
          exploringFrom.cost + heuristicFunc(exploringFrom.to) >
              bestPath.cost) {
        break;
      }
      var nextLocations = explore(exploringFrom.to);
      for (var next in nextLocations) {
        var newPath = PathTo(exploringFrom.steps.followedBy([next]));
        if (!pathsTo.containsKey(next.pos)) {
          pathsTo[next.pos] = newPath;
          toExplore.add(newPath);
        } else {
          // we already have a path, but this one may be shorter
          if (pathsTo[next.pos]!.cost > newPath.cost) {
            pathsTo[next.pos] = newPath;
          }
        }
        if (target(newPath.to)) {
          if (bestPath == null || bestPath.cost > newPath.cost) {
            bestPath = newPath;
          }
        }
      }
    } while (toExplore.isNotEmpty);
    if (bestPath == null) throw Exception("No path found");
    return bestPath;
  }
}
