import 'dart:io';

import 'package:stubble/stubble.dart';

void main(List<String> arguments) async {

  var day = int.parse(arguments.first);
  await createDartFile(day);

  await patchLaunchFile(day);
  await createEmptySnips(day);


}

createEmptySnips(int day) {
  var snipsFile = File('input/$day.snips.txt');
  snipsFile.writeAsString(
'''
snip:sample

====
''');
}

Future<void> patchLaunchFile(int day) async {
  var launchFile = File('.vscode/launch.json');
  var json = await launchFile.readAsString();
  var findRegex = RegExp(r'"program": "(bin/[\w.]+)"');
  var match = findRegex.firstMatch(json)!;
  // ignore: prefer_interpolation_to_compose_strings
  json = json.substring(0, match.start)
    + '"program": "bin/day_$day.dart"'
    + json.substring(match.end);
  await launchFile.writeAsString(json);
}

Future<void> createDartFile(int day) async {
  var tmplFile = File('bin/template.dart.txt');
  var dartFile = File('bin/day_$day.dart');
  var stubble = Stubble();
  var tmpl = stubble.compile(await tmplFile.readAsString());
  var data = {'day': day};
  await dartFile.writeAsString(tmpl(data));
}
