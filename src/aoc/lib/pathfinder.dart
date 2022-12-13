import 'package:collection/collection.dart';

abstract class Costed {
  abstract double cost;
}

class StepTo<TPos, TStep> {
  TPos pos;
  TStep? step;
  double cost;
  StepTo(this.pos, this.step, {this.cost = 1.0});
}

class PathTo<TPos, TStep> extends Comparable {
  Iterable<StepTo<TPos, TStep>> steps;
  PathTo(this.steps);
  double? _cost;
  double get cost {
    _cost ??= steps.fold<double>(0.0, (acc, s) => acc + s.cost);
    return _cost!;
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

  PathTo<TPos, TStep> findShortest<TPos, TStep>(
      ExploreFunc<TPos, TStep> explore, TargetFunc<TPos> target, TPos start,
      {double Function(TPos from)? minimalDistanceRemaining}) {
    var heuristicFunc = minimalDistanceRemaining ?? (p) => 0;
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
