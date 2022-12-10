import 'package:aoc/coord.dart';
import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';
import 'package:aoc/cpu.dart';

void main(List<String> arguments) async {
  final rig = Rig(10, (raw) async {
    List<Cmd> items = parseToObjects(raw, RegExp(r'(.*)'), (matches) {
      var words = matches[0].split(' ');
      return cmdFromWords(words);
    });
    var space = Space<String>.fromEntries([]);
    var cpu = Cpu(items);
    cpu.on((cycle, cpu) {
      cycle--;
      var posX = cycle % 40;
      var posY = (cycle - posX) ~/ 40;
      if ((posX - cpu.x).abs() <= 1) {
        space.set(Coord(posX, posY), "#");
      } else {
        space.set(Coord(posX, posY), ".");
      }
    });

    cpu.run();
    return '\n' + space.visualize((val) => val);
  });

  var allOK = await rig.testSnippet("sample", '''

##..##..##..##..##..##..##..##..##..##..
###...###...###...###...###...###...###.
####....####....####....####....####....
#####.....#####.....#####.....#####.....
######......######......######......####
#######.......#######.......#######.....
''');
  //allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}
