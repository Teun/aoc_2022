import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';
import 'package:aoc/cpu.dart';

void main(List<String> arguments) async {
  final rig = Rig(10, (raw, {dynamic extra}) async {
    List<Cmd> items = parseToObjects(raw, RegExp(r'(.*)'), (matches) {
      var words = matches[0].split(' ');
      return cmdFromWords(words);
    });
    int result = 0;
    var cpu = Cpu(items);
    cpu.on((cycle, cpu) {
      if (cycle == 20 || (cycle - 20) % 40 == 0) {
        result += cycle * cpu.x;
      }
    });

    cpu.run();
    return result;
  });

  var allOK = await rig.testSnippet("sample", 13140);
  //allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}
