void main(List<String> arguments) async {
  var lines = '''
noop
noop
addx 4
'''
      .split("\n");
  // ignore: unused_local_variable
  List<Cmd> commands = lines.map((l) => cmdFromWords(l.split(' '))).toList();
}

abstract class Cmd {
  int duration = 1;

  Cmd({this.duration = 1});
}

var cmdFromWords = (List<String> words) {
  if (words[0] == "noop") return Noop();
  if (words[0] == "addx") return AddX(int.parse(words[1]));
  throw Exception("Unknown mnemonic: ${words[0]}");
};

class AddX extends Cmd {
  int delta;
  AddX(this.delta) : super(duration: 2);
}

class Noop extends Cmd {
  Noop() : super(duration: 1);
}
