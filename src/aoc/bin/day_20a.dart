import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';
import 'package:collection/collection.dart';

void main(List<String> arguments) async {
  final rig = Rig(20, (raw, {extra = 1}) async {
    var items = parseToObjects(raw, RegExp(r'(.*)'), (matches) {
      return int.parse(matches[0]);
    });
    var mixer = Mixer(items.map((e) => e * 811589153));
    mixer.mix(10);

    return mixer.getAfter(0, 1000) +
        mixer.getAfter(0, 2000) +
        mixer.getAfter(0, 3000);
  });

  var allOK = await rig.testSnippet("sample", 1623178306);
  if (allOK) await rig.runPrint();
}

class Mixer {
  List<List<int>> values = [];
  Mixer(Iterable<int> nums) {
    values = nums.mapIndexed((index, element) => [element, index]).toList();
  }
  void mix([int times = 1]) {
    for (var t = 0; t < times; t++) {
      for (var x = 0; x < values.length; x++) {
        final i = values.indexWhere((n) => n[1] == x);
        final n = values[i][0];
        values.splice(i, 1);
        values.splice((i + n) % values.length, 0, [
          [n, x]
        ]);
      }
      var output = values.take(10).map((e) => e[0]).join(', ');
      print(output);
    }
  }

  int getAfter(int val, int ix) {
    final i = values.indexWhere((n) => n[0] == val);
    return values[(i + ix) % values.length][0];
  }
}

extension Splice<T> on List<T> {
  Iterable<T> splice(int start, int count, [List<T>? insert]) {
    final result = [...getRange(start, start + count)];
    replaceRange(start, start + count, insert ?? []);
    return result;
  }
}
