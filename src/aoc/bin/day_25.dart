import 'dart:math';

import 'package:aoc/lineparser.dart';
import 'package:aoc/rig.dart';

void main(List<String> arguments) async {
  final rig = Rig(25, (raw, {extra = 1}) async {
    var items = parseToObjects(raw, RegExp(r'(\S+)'), (matches) {
      return Snafu.parse(matches[0]);
    });
    return Snafu.asString(items.fold(0, (acc, v) => acc + v));
  });

  var allOK = await rig.testSnippet("sample", "2=-1=0");
  //allOK &= await rig.test("literal sample", 0);
  if (allOK) await rig.runPrint();
}

class Snafu {
  static int parse(String from) {
    var values = {'=': -2, '-': -1, '0': 0, '1': 1, '2': 2};
    int res = 0;
    for (var i = 0; i < from.length; i++) {
      int pos = from.length - i - 1;
      res += values[from.substring(pos, pos + 1)]! * pow(5, i).toInt();
    }
    return res;
  }

  static String asString(int value) {
    var strPres = {-2: '=', -1: '-', 0: '0', 1: '1', 2: '2'};
    var result = "";
    var remain = value;
    for (var i = 20; i >= 0; i--) {
      var valThisDigit = pow(5, i).toInt();
      var maxSubtractable = (valThisDigit - 1) ~/ 2;
      var times =
          ((remain.abs() + maxSubtractable) ~/ valThisDigit) * remain.sign;
      if (times < -2 || times > 2) throw Exception("huh");
      result += strPres[times]!;
      remain -= times * valThisDigit;
    }
    while (result.startsWith('0')) {
      result = result.substring(1);
    }
    return result;
  }
}
