import 'package:flutter/material.dart';
import 'package:chotanews/features/zip_puzzle/data/models/grid_point.dart';

class DrawnPatch {
  final String clueId;
  final int minRow;
  final int maxRow;
  final int minCol;
  final int maxCol;
  final Color color;
  final Color tintColor;

  const DrawnPatch({
    required this.clueId,
    required this.minRow,
    required this.maxRow,
    required this.minCol,
    required this.maxCol,
    required this.color,
    required this.tintColor,
  });

  factory DrawnPatch.fromCorners({
    required String clueId,
    required GridPoint p1,
    required GridPoint p2,
    required Color color,
    required Color tintColor,
  }) {
    final r1 = p1.row < p2.row ? p1.row : p2.row;
    final r2 = p1.row > p2.row ? p1.row : p2.row;
    final c1 = p1.col < p2.col ? p1.col : p2.col;
    final c2 = p1.col > p2.col ? p1.col : p2.col;
    return DrawnPatch(
      clueId: clueId,
      minRow: r1,
      maxRow: r2,
      minCol: c1,
      maxCol: c2,
      color: color,
      tintColor: tintColor,
    );
  }

  int get width => (maxCol - minCol) + 1;
  int get height => (maxRow - minRow) + 1;
  int get area => width * height;

  bool contains(GridPoint pt) {
    return pt.row >= minRow &&
        pt.row <= maxRow &&
        pt.col >= minCol &&
        pt.col <= maxCol;
  }

  bool overlaps(DrawnPatch other) {
    if (maxRow < other.minRow || minRow > other.maxRow) return false;
    if (maxCol < other.minCol || minCol > other.maxCol) return false;
    return true;
  }

  Set<GridPoint> get cells {
    final Set<GridPoint> pts = {};
    for (int r = minRow; r <= maxRow; r++) {
      for (int c = minCol; c <= maxCol; c++) {
        pts.add(GridPoint(r, c));
      }
    }
    return pts;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawnPatch &&
          runtimeType == other.runtimeType &&
          clueId == other.clueId &&
          minRow == other.minRow &&
          maxRow == other.maxRow &&
          minCol == other.minCol &&
          maxCol == other.maxCol;

  @override
  int get hashCode => Object.hash(clueId, minRow, maxRow, minCol, maxCol);
}
