import 'grid_point.dart';

class Wall {
  final GridPoint a;
  final GridPoint b;

  const Wall(this.a, this.b);

  bool blocks(GridPoint p1, GridPoint p2) {
    return (p1 == a && p2 == b) || (p1 == b && p2 == a);
  }

  Map<String, dynamic> toJson() => {
        'a': a.toJson(),
        'b': b.toJson(),
      };

  factory Wall.fromJson(Map<String, dynamic> json) => Wall(
        GridPoint.fromJson(json['a'] as Map<String, dynamic>),
        GridPoint.fromJson(json['b'] as Map<String, dynamic>),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wall &&
          runtimeType == other.runtimeType &&
          ((a == other.a && b == other.b) || (a == other.b && b == other.a));

  @override
  int get hashCode => a.hashCode ^ b.hashCode;

  @override
  String toString() => 'Wall($a <-> $b)';
}
