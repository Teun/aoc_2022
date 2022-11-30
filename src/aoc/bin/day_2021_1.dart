import 'package:aoc/rig.dart';
import 'package:collection/collection.dart';

void main(List<String> arguments) async {
  final rig = Rig(20211, (raw) async {
    final depths = raw.split('\n').where((l) => l.isNotEmpty).map((l) => int.parse(l)).toList();
    final indexes = depths.mapIndexed((i, e) => i);
    return indexes.where((i) => i > 0)
      .where((i) => depths[i] > depths[i-1])
      .fold(0, (previousValue, element) => previousValue + 1);
  });

  await rig.runPrint();
}