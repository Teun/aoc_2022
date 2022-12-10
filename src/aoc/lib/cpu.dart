class Cpu {
  List<Cmd> operations;
  int x = 1;
  Cpu(this.operations);
  void run() {
    int cycle = 0;
    int pointer = 0;
    do {
      var op = operations[pointer];
      var cyclesToWait = op.duration;
      for (var i = 0; i < cyclesToWait; i++) {
        cycle++;
        _tick(cycle);
      }
      op.exec(this);
      pointer++;
    } while (pointer < operations.length);
  }

  final List<void Function(int a, Cpu b)> _listeners = [];
  void on(void Function(int a, Cpu b) func) {
    _listeners.add(func);
  }

  void _tick(int cycle) {
    for (var f in _listeners) {
      f(cycle, this);
    }
  }
}

abstract class Cmd {
  int duration = 1;

  void exec(Cpu cpu);
  Cmd({this.duration = 1});
}

Cmd Function(List<String>) cmdFromWords = (List<String> words) {
  if (words[0] == "noop") return Noop();
  if (words[0] == "addx") return AddX(int.parse(words[1]));
  throw Exception("Unknown mnemonic: ${words[0]}");
};

class AddX extends Cmd {
  int delta;
  AddX(this.delta) : super(duration: 2);

  @override
  void exec(Cpu cpu) {
    //print("Adding $delta to ${cpu.x}");
    cpu.x += delta;
  }
}

class Noop extends Cmd {
  Noop() : super(duration: 1);

  @override
  void exec(Cpu cpu) {}
}
