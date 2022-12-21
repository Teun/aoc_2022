import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(21, (raw, {extra = 1}) async {
    var items = parseToObjects(raw, RegExp(r'(\w+): ((\d+)|(\w+) (.) (\w+))'),
        (matches) {
      return Monkey(matches);
    });
    Map<String, Monkey> troup = Map.fromIterable(items, key: (m) => m.name);
    for (var monkey in items) {
      if (monkey.op.isNotEmpty) {
        assert(troup[monkey.left]!.parent == null);
        troup[monkey.left]!.parent = monkey;
        assert(troup[monkey.right]!.parent == null);
        troup[monkey.right]!.parent = monkey;
      }
    }
    var root = troup["root"]!;
    var human = troup["humn"]!;
    var follow = human;
    Set<String> humanStack = {human.name};
    while (follow.parent != root) {
      follow = follow.parent!;
      humanStack.add(follow.name);
    }
    var safeSide =
        root.left == follow.name ? troup[root.right]! : troup[root.left]!;
    var equalSide =
        root.right == follow.name ? troup[root.right]! : troup[root.left]!;
    var value = safeSide.call(troup);
    while (equalSide != human) {
      var unknownSide =
          humanStack.intersection({equalSide.left, equalSide.right}).first;
      var knownSide =
          unknownSide == equalSide.left ? equalSide.right : equalSide.left;
      var knownValue = troup[knownSide]!.call(troup);
      if (equalSide.op == "+") {
        value = value - knownValue;
      } else if (equalSide.op == "*") {
        value = value ~/ knownValue;
      } else if (equalSide.op == "-" && equalSide.left == knownSide) {
        value = knownValue - value;
      } else if (equalSide.op == "-" && equalSide.right == knownSide) {
        value = knownValue + value;
      } else if (equalSide.op == "/" && equalSide.left == knownSide) {
        value = knownValue ~/ value;
      } else if (equalSide.op == "/" && equalSide.right == knownSide) {
        value = knownValue * value;
      }
      equalSide = troup[unknownSide]!;
    }
    return value;
  });

  var allOK = await rig.testSnippet("sample", 301);
  // allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}

class Monkey {
  late String name;
  late String op;
  late String left;
  late String right;
  Monkey? parent;
  late int Function(Map<String, Monkey> troup) call;
  Monkey(List<String> init) {
    name = init[0];
    op = init[4];
    left = init[3];
    right = init[5];
    if (init[2].isNotEmpty) {
      call = (t) => int.parse(init[2]);
    } else {
      if (init[4] == "+") {
        call = (t) => t[init[3]]!.call(t) + t[init[5]]!.call(t);
      }
      if (init[4] == "*") {
        call = (t) => t[init[3]]!.call(t) * t[init[5]]!.call(t);
      }
      if (init[4] == "-") {
        call = (t) => t[init[3]]!.call(t) - t[init[5]]!.call(t);
      }
      if (init[4] == "/") {
        call = (t) => (t[init[3]]!.call(t) ~/ t[init[5]]!.call(t));
      }
    }
  }
}
