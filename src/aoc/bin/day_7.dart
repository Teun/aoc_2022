import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(7, (raw) async {
    var items = parseToObjects(raw, RegExp(r''), (matches) {
      return 0;
    });
    return 0;
  });

  var allOK = await rig.testSnippet("sample", 1);
  allOK &= await rig.test("literal sample", 0);
  if(allOK) await rig.runPrint();
}
