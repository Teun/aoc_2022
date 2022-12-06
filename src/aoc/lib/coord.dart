class Coord {
  final int x;
  final int y;
  Coord(this.x, this.y);
  @override
  bool operator ==(Object other) {
    if(other is! Coord) return false;
    return x == other.x && y == other.y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
enum Direction {north, south, east, west}
extension CombineDirection on Coord {
  Coord toDirection(Direction dir) {
    if(dir == Direction.north) return Coord(x, y - 1);
    if(dir == Direction.south) return Coord(x, y + 1);
    if(dir == Direction.east) return Coord(x + 1, y);
    return Coord(x - 1, y);
  }
}
class Space<TVal> {
  Map<Coord, TVal> _places = {};
  TVal? at(Coord loc){
    return _places[loc];
  }
  Space.fromEntries(List<MapEntry<Coord, TVal>> entries){
    _places = Map.fromEntries(entries);
  }
  Space.fromText(String rawMap, TVal? Function(String) valSelect){
    var chars = rawMap.split('\n').map((l) => l.split('')).toList();
    for (var y = 0; y < chars.length; y++) {
      for (var x = 0; x < chars[0].length; x++) {
        var val = valSelect(chars[y][x]);
        if(val != null) _places[Coord(x, y)] = val;
      }
    }
  }
}