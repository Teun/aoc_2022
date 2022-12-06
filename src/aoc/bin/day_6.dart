import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';
import 'package:collection/collection.dart';

void main(List<String> arguments) async {
  final rig = Rig(6, (raw) async {
    var chars = raw.split('');
    var indexes = List.generate(chars.length, (index) => index);
    var pos = indexes.firstWhere((i) {
      var s = Set.from(chars.getRange( (i-3).clamp(0, 1e6).toInt(), i+1));
      return s.length == 4;
    });

    return pos + 1;
  });

  var allOK = await rig.test("bvwbjplbgvbhsrlpgdmjqwftvncz", 5);
  allOK &= await rig.test("nppdvjthqldpwncqszvftbrmjlhg", 6);
  allOK &= await rig.test("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 10);
  allOK &= await rig.test("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 11);
  if(allOK) await rig.runPrint();
}
