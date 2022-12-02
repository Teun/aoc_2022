import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

class Record{
  Move elf;
  Move me;
  Record(this.elf, this.me);
}
void main(List<String> arguments) async {
  final rig = Rig(2, (raw) async {
    final lines = parseToObjects(raw, RegExp(r'^(\w) (\w)$'), (o) {
      return Record(
        {"A": Move.rock, "B": Move.paper, "C": Move.scissors}[o[0]]!,
        {"X": Move.rock, "Y": Move.paper, "Z": Move.scissors}[o[1]]!);
    });
    return lines.fold(0, (acc, element) => acc + valueOfMove(element.me, element.elf));
  });

  await rig.testSnippet("sample", 15);
  await rig.runPrint();
}
enum Move{rock, paper, scissors}
int valueOfMove(Move mine, Move theirs) {
  final movePoint = {Move.rock: 1, Move.paper: 2, Move.scissors: 3}[mine]!;
  return movePoint + score(mine, theirs);
}
int score(Move mine, Move theirs) {
  if(mine == theirs)return 3;
  if(mine == Move.rock) return theirs == Move.scissors ? 6 : 0;
  if(mine == Move.paper) return theirs == Move.rock ? 6 : 0;
  if(mine == Move.scissors) return theirs == Move.paper ? 6 : 0;
  throw Exception("Unexpected value");

}

