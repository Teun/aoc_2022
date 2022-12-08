import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';
import 'package:aoc/thenby.dart';

abstract class FS {
  Dir? parent;
  int size();
  String name;
  FS(this.name, this.parent);
}
class File extends FS {
  int _size;
  File(String name, this._size, Dir parent): super(name, parent);
  @override
  int size() => _size;
}
class Dir extends FS {
  Map<String, Dir> subdirs = {};
  Map<String, File> files = {};
  Dir.root():super("/", null);
  Dir(String name, Dir parent): super(name, parent);
  @override
  int size() => subdirs.values.cast<FS>().followedBy(files.values).fold(0, (acc, item) => acc + item.size());
  List<Dir> recursiveDirs() {
    List<Dir> all = [this];

    for (var element in subdirs.values) { all.addAll(element.recursiveDirs()); }
    return all;
  }
}

void main(List<String> arguments) async {
  final rig = Rig(7, (raw) async {
    var items = parseToObjects(raw, RegExp(r'(\$ ls|\$ cd ([\w.\/]+)|(dir|\d+) ([\w.\/]+))'), (matches) {
      return matches.toList();
    });
    Dir root = Dir.root();
    Dir current = root;
    for (var line in items) {
      if(line[0].startsWith("\$ cd")){
        if(line[1] == "/") {
          current = root;
        } else if(line[1] == "..") {
          current = current.parent!;
        } else {
          current = current.subdirs[line[1]]!;
        }
      }else if(line[0].startsWith("\$ ls")){
        //clear current?
      }else{
        if(line[2] == "dir") {
          current.subdirs[line[3]] = Dir(line[3], current);
        } else {
          current.files[line[3]] = File(line[3], int.parse(line[2]), current);
        }
      }
    }

    var sizes = root.recursiveDirs().map((e) => e.size()).toList();
    var available = 70000000 - root.size();
    var needed = 30000000 - available;
    sizes.sort(firstBy((int i) => i));
    return sizes.firstWhere((s) => s >= needed);
  });

  var allOK = await rig.testSnippet("sample", 24933642);
  if(allOK) await rig.runPrint();
}
