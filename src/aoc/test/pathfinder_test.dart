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

void main() {
  test('breadth first finds', () async {
    var finder = pf.Pathfinder();
    var path = finder.breadthFirst<String, String>(
        (from) => graph[from]!.map((e) => pf.StepTo(e.to, e.to)).toList(),
        (to) => to == "e",
        "a");
    expect(path.steps.length, 3);
    expect(path.steps.toList()[1].pos, 'd');
  });
}
