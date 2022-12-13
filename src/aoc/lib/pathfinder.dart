import 'package:aoc/thenby.dart';
import 'package:collection/collection.dart';

abstract class Costed {
  abstract double cost;
}

class StepTo<TPos, TStep> {
  TPos pos;
  TStep? step;
  late double cost;
  StepTo(this.pos, this.step, {double cost = 1.0}) {
    if (step == null) cost = 0;
  }
}

class PathTo<TPos, TStep> {
  Iterable<StepTo<TPos, TStep>> steps;
  PathTo(this.steps);
  double get cost {
    return steps.fold(0.0, (acc, s) => acc + s.cost);
  }
}

typedef ExploreFunc<TPos, TStep> = List<StepTo<TPos, TStep>> Function(
    TPos from);
typedef TargetFunc<TPos> = bool Function(TPos pos);

class Pathfinder {
  PathTo<TPos, TStep> breadthFirst<TPos, TStep>(
      ExploreFunc<TPos, TStep> explore, TargetFunc<TPos> target, TPos start) {
    List<PathTo<TPos, TStep>> toExplore = [];
    Map<TPos, PathTo<TPos, TStep>> pathsTo = {};
    toExplore = [
      PathTo([StepTo(start, null)])
    ];
    pathsTo = {};
    pathsTo[start] = toExplore.first;
    while (true) {
      var exploringFrom = toExplore.removeAt(0);
      var nextLocations = explore(exploringFrom.steps.last.pos);
      for (var next in nextLocations) {
        if (!pathsTo.containsKey(next.pos)) {
          var newPath = PathTo(exploringFrom.steps.followedBy([next]));
          if (target(newPath.steps.last.pos)) {
            return newPath;
          }
          pathsTo[next.pos] = newPath;
          toExplore.add(newPath);
        }
      }
      if (toExplore.isEmpty) throw Exception("No path found");
    }
  }

  PathTo<TPos, TStep> findShortest<TPos, TStep extends Costed>(
      ExploreFunc<TPos, TStep> explore, TargetFunc<TPos> target, TPos start) {
    var toExplore = PriorityQueue(firstBy((PathTo<TPos, TStep> v) => v.steps
        .where((s) => s.step != null)
        .fold(0.0, (acc, v) => acc + v.step!.cost)));
    Map<TPos, PathTo<TPos, TStep>> pathsTo = {};
    toExplore.add(PathTo([StepTo(start, null)]));
    pathsTo = {};
    pathsTo[start] = toExplore.first;
    do {
      // implement
      return pathsTo[start]!;
    } while (toExplore.isNotEmpty);
  }
}
