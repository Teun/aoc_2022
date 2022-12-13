import 'package:aoc/coord.dart';
import 'package:aoc/pathfinder.dart' as pf;
import 'package:test/test.dart';

class Edge {
  String to;
  int weight;
  Edge(this.to, this.weight);
}

final Map<String, List<Edge>> graph = {
  'a': [Edge('b', 5), Edge('d', 7)],
  'b': [Edge('c', 3)],
  'c': [Edge('e', 1)],
  'd': [Edge('e', 3)],
  'e': []
};
/* /5-b-3-c-1\
  a          e
   \-7--d-3--|
*/

void main() {
  test('breadth first finds', () async {
    var finder = pf.Pathfinder();
    var path = finder.breadthFirst<String, String>(
        (from) => graph[from]!.map((e) => pf.StepTo(e.to, e.to)).toList(),
        (to) => to == "e",
        "a");
    expect(path.steps.length, 3);
    expect(path.cost, 2);
    expect(path.steps.toList()[1].pos, 'd');
  });
  test('shortest finds in directed graph', () async {
    var finder = pf.Pathfinder();
    var path = finder.findShortest<String, String>(
        (from) => graph[from]!
            .map((e) => pf.StepTo(e.to, e.to, cost: e.weight.toDouble()))
            .toList(),
        (to) => to == "e",
        "a");
    expect(path.cost, 9);
    var steps = path.steps.toList();
    expect(steps.length, 4);
    expect(steps[1].pos, 'b');
  });
  test('shortest Dijkstra in carthesian space', () async {
    var space = Space<String>.fromText('''
...x.....
.........
..xxx....
.....x...
.xx.xxx..
..x.x....
''', (x, c) => x);
    var start = Coord(4, 0);
    var end = Coord(3, 5);
    var finder = pf.Pathfinder();
    var path = finder.findShortest<Coord, Direction>((from) {
      space.set(from, 'o');
      return Direction.values
          .map((d) => pf.StepTo(from.toDirection(d), d))
          .where((s) => space.at(s.pos) == null || space.at(s.pos) != "x")
          .toList();
    }, (to) => to == end, start);
    expect(path.cost, 10);
    visPathInSpace(path, space);
  });
  test('shortest A* in carthesian space', () async {
    var space = Space<String>.fromText('''
...x.....
.........
..xxx....
.....x...
.xx.xxx..
..x.x....
''', (x, c) => x);
    var start = Coord(4, 0);
    var end = Coord(3, 5);
    var finder = pf.Pathfinder();
    var path = finder.findShortest<Coord, Direction>((from) {
      space.set(from, 'o');
      return Direction.values
          .map((d) => pf.StepTo(from.toDirection(d), d))
          .where((s) => space.at(s.pos) == null || space.at(s.pos) != "x")
          .toList();
    }, (to) => to == end, start,
        minimalDistanceRemaining: (from) =>
            ((from.x - end.x).abs() + (from.y - end.y).abs()).toDouble());
    expect(path.cost, 10);
    visPathInSpace(path, space);
  });
}

void visPathInSpace(pf.PathTo<Coord, Direction> path, Space<String> space) {
  for (var s in path.steps) {
    space.set(s.pos, '+');
  }
  print(space.visualize((val) => val[0]));
}
