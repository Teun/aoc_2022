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
  int manhattan(Coord from) {
    return (x - from.x).abs() + (y - from.y).abs();
  }
}

class Rect {
  Coord topLeft = Coord(0, 0);
  Coord bottomRight = Coord(0, 0);
  bool uninitialized = true;

  void expandToContain(Coord place) {
    if (uninitialized) {
      topLeft = place;
      bottomRight = place;
      uninitialized = false;
      return;
    }
    if (place.x < topLeft.x || place.y < topLeft.y) {
      topLeft =
          Coord(math.min(place.x, topLeft.x), math.min(place.y, topLeft.y));
    }
    if (place.x > bottomRight.x || place.y > bottomRight.y) {
      bottomRight = Coord(
          math.max(place.x, bottomRight.x), math.max(place.y, bottomRight.y));
    }
  }

  Rect.empty();
  Rect(Coord topLeft, Coord bottomRight) {
    expandToContain(topLeft);
    expandToContain(bottomRight);
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
  final Rect _bound = Rect.empty();
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
    _checkAll();
  }

  Space.fromEntries(List<MapEntry<Coord, TVal>> entries) {
    _places = Map.fromEntries(entries);
    _checkAll();
  }
  Space.fromText(String rawMap, TVal? Function(String, Coord pos) valSelect) {
    var chars = rawMap
        .split('\n')
        .where((l) => l.isNotEmpty)
        .map((l) => l.split(''))
        .toList();
    for (var y = 0; y < chars.length; y++) {
      for (var x = 0; x < chars[0].length; x++) {
        var val = valSelect(chars[y][x], Coord(x, y));
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

  String visualize(String Function(TVal val) showAs, {Rect? bnds}) {
    var result = "";
    var region = bnds ?? bounds;
    for (var y = region.topLeft.y; y <= region.bottomRight.y; y++) {
      for (var x = region.topLeft.x; x <= region.bottomRight.x; x++) {
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
