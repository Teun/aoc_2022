abstract class Costed {
  abstract num cost;
}

class StepTo<TPos, TStep> {
  TPos pos;
  TStep? step;
  StepTo(this.pos, this.step);
}

class PathTo<TPos, TStep> {
  Iterable<StepTo<TPos, TStep>> steps;
  PathTo(this.steps);
}

typedef ExploreFunc<TPos, TStep> = List<StepTo<TPos, TStep>> Function(
    TPos from);
typedef TargetFunc<TPos> = bool Function(TPos pos);

class Pathfinder<TPos, TStep> {
  List<PathTo<TPos, TStep>> toExplore = [];
  Map<TPos, PathTo<TPos, TStep>> pathsTo = {};
  PathTo<TPos, TStep> breadthFirst(
      ExploreFunc<TPos, TStep> explore, TargetFunc<TPos> target, TPos start) {
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
}
