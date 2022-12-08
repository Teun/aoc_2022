import 'dart:math' as math;

class Coord {
  final int x;
  final int y;
  Coord(this.x, this.y);
  @override
  bool operator ==(Object other) {
    if (other is! Coord) return false;
    return x == other.x && y == other.y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class Rect {
  Coord topLeft = Coord(0, 0);
  Coord bottomRight = Coord(0, 0);

  void expandToContain(Coord place) {
    if (place.x < topLeft.x || place.y < topLeft.y) {
      topLeft =
          Coord(math.min(place.x, topLeft.x), math.min(place.y, topLeft.y));
    }
    if (place.x > bottomRight.x || place.y > bottomRight.y) {
      bottomRight = Coord(
          math.max(place.x, bottomRight.x), math.max(place.y, bottomRight.y));
    }
  }
}

enum Direction { north, south, east, west }

extension CombineDirection on Coord {
  Coord toDirection(Direction dir) {
    if (dir == Direction.north) return Coord(x, y - 1);
    if (dir == Direction.south) return Coord(x, y + 1);
    if (dir == Direction.east) return Coord(x + 1, y);
    return Coord(x - 1, y);
  }
}

class Space<TVal> {
  Map<Coord, TVal> _places = {};
  final Rect _bound = Rect();
  TVal? at(Coord loc) {
    return _places[loc];
  }

  Iterable<MapEntry<Coord, TVal>> get all => _places.entries;

  Rect get bounds => _bound;

  void set(Coord loc, TVal? val) {
    if (val == null) {
      _places.remove(loc);
    } else {
      _places[loc] = val;
    }
  }

  Space.fromEntries(List<MapEntry<Coord, TVal>> entries) {
    _places = Map.fromEntries(entries);
    _checkAll();
  }
  Space.fromText(String rawMap, TVal? Function(String) valSelect) {
    var chars = rawMap
        .split('\n')
        .where((l) => l.isNotEmpty)
        .map((l) => l.split(''))
        .toList();
    for (var y = 0; y < chars.length; y++) {
      for (var x = 0; x < chars[0].length; x++) {
        var val = valSelect(chars[y][x]);
        if (val != null) _places[Coord(x, y)] = val;
      }
    }
    _checkAll();
  }

  void _checkAll() {
    for (var place in _places.keys) {
      _bound.expandToContain(place);
    }
  }

  String visualize(String Function(TVal val) showAs) {
    var result = "";
    for (var y = bounds.topLeft.y; y <= bounds.bottomRight.y; y++) {
      for (var x = bounds.topLeft.x; x <= bounds.bottomRight.x; x++) {
        var val = at(Coord(x, y));
        if (val == null) {
          result += " ";
        } else {
          result += showAs(val)[0];
        }
      }
      result += "\n";
    }
    return result;
  }
}
