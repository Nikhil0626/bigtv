class SudokuCell {
  final int row;
  final int col;
  final int value;
  final bool isGiven;
  final Set<int> notes;
  final bool isError;

  const SudokuCell({
    required this.row,
    required this.col,
    required this.value,
    this.isGiven = false,
    this.notes = const {},
    this.isError = false,
  });

  bool get isEmpty => value == 0;

  SudokuCell copyWith({
    int? value,
    bool? isGiven,
    Set<int>? notes,
    bool? isError,
  }) {
    return SudokuCell(
      row: row,
      col: col,
      value: value ?? this.value,
      isGiven: isGiven ?? this.isGiven,
      notes: notes ?? Set.unmodifiable(this.notes),
      isError: isError ?? this.isError,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SudokuCell &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col &&
          value == other.value &&
          isGiven == other.isGiven &&
          isError == other.isError;

  @override
  int get hashCode =>
      row.hashCode ^
      col.hashCode ^
      value.hashCode ^
      isGiven.hashCode ^
      isError.hashCode;
}
