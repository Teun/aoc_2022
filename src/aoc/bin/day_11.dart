import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';
import 'package:aoc/thenby.dart';

void main(List<String> arguments) async {
  final rig = Rig(11, (raw) async {
    var monkeys = parseToObjects(
        raw,
        RegExp(
            r'Monkey (\d+):\s+Starting items: ([\d ,]+)\s+Operation: new = old (\*|\+) (\d+|old)\s+Test: divisible by (\d+)\s+If true: throw to monkey (\d+)\s+If false: throw to monkey (\d+)',
            multiLine: false), (matches) {
      var monkey = Monkey(int.parse(matches[0]), matches[1],
          op: matches[2],
          opVal: matches[3],
          divisible: int.parse(matches[4]),
          divTrue: int.parse(matches[5]),
          divFalse: int.parse(matches[6]));
      return monkey;
    }, splitter: RegExp('\n\n'));
    for (var round = 0; round < 20; round++) {
      for (var monkey in monkeys) {
        List<int>? lastPass;
        do {
          lastPass = monkey.inspect();
          if (lastPass != null) {
            monkeys[lastPass[0]].receive(lastPass[1]);
          }
        } while (lastPass != null);
      }
    }
    monkeys
        .sort(firstBy<Monkey, int>((m) => m.inspectCount, dir: Direction.desc));
    return monkeys[0].inspectCount * monkeys[1].inspectCount;
  });

  var allOK = await rig.testSnippet("sample", 10605);
  // allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}

class Monkey {
  int nr;
  int inspectCount = 0;
  late List<int> items;
  late int Function(int level) inspectFunc;
  late int Function(int level) passFunc;
  Monkey(this.nr, String itemList,
      {String op = "+",
      required String opVal,
      required int divisible,
      required int divTrue,
      required int divFalse}) {
    items = itemList.split(", ").map(int.parse).toList();
    if (op == "*" && opVal == "old") {
      inspectFunc = (int l) => l * l;
    }
    if (op == "*" && opVal != "old") {
      inspectFunc = (int l) => l * int.parse(opVal);
    }
    if (op == "+") {
      inspectFunc = (int l) => l + int.parse(opVal);
    }
    passFunc = (level) {
      return level % divisible == 0 ? divTrue : divFalse;
    };
  }
  List<int>? inspect() {
    if (items.isEmpty) return null;
    var item = items.removeAt(0);
    print("Monkey $nr inspects item with level $item");
    item = inspectFunc(item);
    inspectCount++;
    print("New level $item");
    item = (item / 3).floor();
    print("Monkey bored: $item");
    var to = passFunc(item);
    print("Passing item to: $to");
    return [to, item];
  }

  void receive(int level) {
    items.add(level);
  }
}
