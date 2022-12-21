import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(21, (raw, {extra = 1}) async {
    var items = parseToObjects(raw, RegExp(r'(\w+): ((\d+)|(\w+) (.) (\w+))'),
        (matches) {
      return Monkey(matches);
    });
    Map<String, Monkey> troup = Map.fromIterable(items, key: (m) => m.name);

    return troup["root"]!.call(troup);
  });

  var allOK = await rig.testSnippet("sample", 152);
  // allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}

class Monkey {
  late String name;
  late int Function(Map<String, Monkey> troup) call;
  Monkey(List<String> init) {
    name = init[0];
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
