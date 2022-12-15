import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

class Record {
  Move elf;
  Result res;
  Record(this.elf, this.res);
}

void main(List<String> arguments) async {
  final rig = Rig(2, (raw, {dynamic extra}) async {
    final lines = parseToObjects(raw, RegExp(r'^(\w) (\w)$'), (o) {
      return Record(
          {"A": Move.rock, "B": Move.paper, "C": Move.scissors}[o[0]]!,
          {"X": Result.loss, "Y": Result.draw, "Z": Result.win}[o[1]]!);
    });
    return lines.fold(0, (acc, rec) {
      Move mine = moveNeeded(rec.elf, rec.res);
      return acc + valueOfMove(mine, rec.elf);
    });
  });

  await rig.testSnippet("sample", 12);
  await rig.runPrint();
}

Move moveNeeded(Move elf, Result res) {
  if (res == Result.draw) return elf;
  if (elf == Move.rock) return res == Result.win ? Move.paper : Move.scissors;
  if (elf == Move.paper) return res == Result.win ? Move.scissors : Move.rock;
  return res == Result.win ? Move.rock : Move.paper;
}

enum Move { rock, paper, scissors }

enum Result { win, draw, loss }

int valueOfMove(Move mine, Move theirs) {
  final movePoint = {Move.rock: 1, Move.paper: 2, Move.scissors: 3}[mine]!;
  return movePoint + score(mine, theirs);
}

int score(Move mine, Move theirs) {
  if (mine == theirs) return 3;
  if ((mine.index - theirs.index) % 3 == 2) return 6;
  return 0;
}
