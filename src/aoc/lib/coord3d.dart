import 'dart:math' as math;

class Coord3D {
  final int x;
  final int y;
  final int z;
  Coord3D(this.x, this.y, this.z);
  @override
  bool operator ==(Object other) {
    if (other is! Coord3D) return false;
    return x == other.x && y == other.y && z == other.z;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;
  int manhattan(Coord3D from) {
    return (x - from.x).abs() + (y - from.y).abs() + (z - from.z).abs();
  }

  Iterable<Coord3D> getNeighbours() sync* {
    yield Coord3D(x + 1, y, z);
    yield Coord3D(x - 1, y, z);
    yield Coord3D(x, y + 1, z);
    yield Coord3D(x, y - 1, z);
    yield Coord3D(x, y, z + 1);
    yield Coord3D(x, y, z - 1);
  }
}
