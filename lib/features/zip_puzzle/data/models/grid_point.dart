class GridPoint {
  final int row;
  final int col;

  const GridPoint(this.row, this.col);

  bool isAdjacent(GridPoint other) {
    final int dr = (row - other.row).abs();
    final int dc = (col - other.col).abs();
    return (dr == 1 && dc == 0) || (dr == 0 && dc == 1);
  }

  Map<String, dynamic> toJson() => {
        'row': row,
        'col': col,
      };

  factory GridPoint.fromJson(Map<String, dynamic> json) => GridPoint(
        json['row'] as int,
        json['col'] as int,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPoint &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => '($row, $col)';
}
