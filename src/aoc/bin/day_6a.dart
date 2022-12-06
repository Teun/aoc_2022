import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(6, (raw) async {
    var chars = raw.split('');
    var indexes = List.generate(chars.length, (index) => index);
    var pos = indexes.firstWhere((i) {
      var s = Set.from(chars.getRange( (i-13).clamp(0, 1e6).toInt(), i+1));
      return s.length == 14;
    });

    return pos + 1;
  });

  await rig.test("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 19);
  await rig.test("bvwbjplbgvbhsrlpgdmjqwftvncz", 23);
  await rig.test("nppdvjthqldpwncqszvftbrmjlhg", 23);
  await rig.test("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 29);
  await rig.runPrint();
}
