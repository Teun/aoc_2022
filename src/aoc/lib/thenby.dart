typedef _Comparer<T> = int Function(T first, T second);
typedef Selecter<T, TR extends Comparable> = TR Function(T first);
abstract class Sorter<T>{
  int call(T first, T second);
  Sorter<T> thenBy<TR extends Comparable>(Selecter<T, TR> next,{ Direction dir = Direction.asc});
}
class _Sorter<T> implements Sorter<T> {
  final List<_Comparer<T>> _funcs = [];
  @override
  int call(T first, T second) {
    for (var func in _funcs) {
      final res = func(first, second);
      if(res != 0) return res;
    }
    return 0;
  }
  // Would be nice to have Union types here
  @override
  Sorter<T> thenBy<TR extends Comparable>(Selecter<T, TR> next,{ Direction dir = Direction.asc}) {
    int comp(T first, T second) {
      final firstSelected = next(first);
      final secondSelected = next(second);
      int dirMultiplier = dir == Direction.asc ? 1 : -1;
      return firstSelected.compareTo(secondSelected) * dirMultiplier;
    }
    _funcs.add(comp);
    return this;
  }
}
enum Direction {asc, desc}
Sorter<T> firstBy<T, TR extends Comparable>(Selecter<T, TR> func,{ Direction dir = Direction.asc}) {
  final sorter = _Sorter<T>();
  sorter.thenBy(func, dir: dir);
  return sorter;
}
