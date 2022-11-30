import 'dart:convert';
import 'dart:io';

class Rig<T> {
  final int _day;
  final Future<T> Function(String raw) _func;

  Rig(this._day, this._func);

  Future<T> run() async {
    final raw = await getContent();
    final result = await _func(raw);
    return result;
  }

  Future<String> getContent() async {
    return _getFileContent(_day.toString());
  }

  Future<void> runPrint() async {
    final result = await run();
    final out = (result is String) ? result : jsonEncode(result);
    print("Result: \n$out");
  }

  Future<T> test(String raw, T expected) async {
    final result = await _func(raw);
    if (!isEqual(result, expected)) {
      throw Exception(why(result, expected));
    }
    final out = (result is String) ? result : result.toString();
    print("OK: $out");
    return result;
  }
  Future<T> testSnippet(String name, T expected) async {
        final all = await _getFileContent("$_day.snips");
        final snip = extractSnip(name, all);
        return await test(snip, expected);
  }
  String why(T result, T expected) {
    return "because $result was not equal to the expected $expected";
  }

  bool isEqual(T result, T expected) {
    if (result is num || result is String) return result == expected;
    if (result is DateTime && expected is DateTime) {
      return result.isAtSameMomentAs(expected);
    }
    return jsonEncode(result) == jsonEncode(expected);
  }
}

String extractSnip(String name, String all) {
    final lines = all.split("\n");
    final startMarker = lines.indexOf("snip:$name");
    assert(startMarker > -1);
    final endMarker = lines.indexOf("====", startMarker);
    assert(endMarker > startMarker);
    final snip = lines.getRange(startMarker + 1, endMarker)
        .join("\n");
    return snip;
}

Future<String> _getFileContent(String name) async {
  final String fileName = 'input/$name.txt';
  final file = File(fileName);
  return await file.readAsString();
}
