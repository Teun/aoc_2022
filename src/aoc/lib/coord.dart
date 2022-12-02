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
class Space<TLoc, TVal> {
  Map<TLoc, TVal> places = {};
}