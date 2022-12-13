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
  test('shortest finds', () async {
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
}
