typedef _Comparer<T> = int Function(T first, T second);
abstract class Sorter<T>{
  int call(T first, T second);
  Sorter<T> thenBy(Function next,{ Direction dir = Direction.asc});
}
class _Sorter<T> implements Sorter<T> {
  final List<_Comparer<T>> _funcs = [];
  int call(T first, T second) {
    for (var func in _funcs) {
      final res = func(first, second);
      if(res != 0) return res;
    }
    return 0;
  }
  // Would be nice to have Union types here
  Sorter<T> thenBy(Function next,{ Direction dir = Direction.asc}) {
    if(next is _Comparer<T>) {
      _funcs.add(next);
    } else {
      int comp(T first, T second) {
        final firstSelected = next(first) as Comparable;
        final secondSelected = next(second) as Comparable;
        int dirMultiplier = dir == Direction.asc ? 1 : -1;
        return firstSelected.compareTo(secondSelected) * dirMultiplier;
      }
      _funcs.add(comp);
    }
    return this;
  }
}
enum Direction {asc, desc}
Sorter<T> firstBy<T>(Function func,{ Direction dir = Direction.asc}) {
  final sorter = _Sorter<T>();
  sorter.thenBy(func, dir: dir);
  return sorter;
}
