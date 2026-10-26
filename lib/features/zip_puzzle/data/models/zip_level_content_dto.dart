class ZipLevelContentDto {
  final int rows;
  final int columns;
  final List<ZipCheckpointDto> checkpoints;
  final List<ZipWallDto> walls;
  final List<ZipPointDto> solutionPath;
  final Map<String, String>? palette;

  const ZipLevelContentDto({
    required this.rows,
    required this.columns,
    required this.checkpoints,
    required this.walls,
    required this.solutionPath,
    this.palette,
  });

  factory ZipLevelContentDto.fromJson(Map<String, dynamic> json) {
    final gridRaw = json['grid'];
    if (gridRaw is! Map) {
      throw const FormatException('Content missing or invalid "grid" object.');
    }
    final int rows = (gridRaw['rows'] is int)
        ? gridRaw['rows'] as int
        : int.parse(gridRaw['rows'].toString());
    final int cols = (gridRaw['columns'] is int)
        ? gridRaw['columns'] as int
        : (gridRaw['cols'] is int)
            ? gridRaw['cols'] as int
            : int.parse((gridRaw['columns'] ?? gridRaw['cols']).toString());

    if (rows <= 0 || cols <= 0) {
      throw FormatException('Invalid grid dimensions: ${rows}x$cols');
    }

    // Checkpoints
    final cpRaw = json['checkpoints'];
    if (cpRaw is! List || cpRaw.isEmpty) {
      throw const FormatException('Checkpoints list must not be empty.');
    }
    final checkpoints = cpRaw
        .map((c) =>
            ZipCheckpointDto.fromJson(Map<String, dynamic>.from(c as Map)))
        .toList(growable: false);

    // Walls (optional, defaults to empty)
    final wallsRaw = json['walls'] ?? const [];
    final List<ZipWallDto> walls = [];
    if (wallsRaw is List) {
      for (final w in wallsRaw) {
        if (w is Map) {
          walls.add(ZipWallDto.fromJson(Map<String, dynamic>.from(w)));
        }
      }
    }

    // Solution path
    final solRaw = json['solutionPath'] ?? json['solution'];
    if (solRaw is! List || solRaw.isEmpty) {
      throw const FormatException('Solution path must not be empty.');
    }
    final solutionPath = solRaw
        .map((p) => ZipPointDto.fromJson(Map<String, dynamic>.from(p as Map)))
        .toList(growable: false);

    // Palette (optional)
    Map<String, String>? palette;
    if (json['palette'] is Map) {
      palette = (json['palette'] as Map).map(
        (k, v) => MapEntry(k.toString(), v.toString()),
      );
    }

    return ZipLevelContentDto(
      rows: rows,
      columns: cols,
      checkpoints: checkpoints,
      walls: walls,
      solutionPath: solutionPath,
      palette: palette,
    );
  }
}

class ZipCheckpointDto {
  final int number;
  final int row;
  final int col;

  const ZipCheckpointDto({
    required this.number,
    required this.row,
    required this.col,
  });

  factory ZipCheckpointDto.fromJson(Map<String, dynamic> json) {
    final numVal = json['number'] ?? json['index'] ?? json['order'];
    final rowVal = json['row'] ?? json['r'] ?? json['y'];
    final colVal = json['col'] ?? json['c'] ?? json['column'] ?? json['x'];

    if (numVal == null || rowVal == null || colVal == null) {
      throw const FormatException('Missing checkpoint coordinate or number.');
    }

    return ZipCheckpointDto(
      number: numVal is int ? numVal : int.parse(numVal.toString()),
      row: rowVal is int ? rowVal : int.parse(rowVal.toString()),
      col: colVal is int ? colVal : int.parse(colVal.toString()),
    );
  }
}

class ZipPointDto {
  final int row;
  final int col;

  const ZipPointDto({required this.row, required this.col});

  factory ZipPointDto.fromJson(Map<String, dynamic> json) {
    final rowVal = json['row'] ?? json['r'] ?? json['y'];
    final colVal = json['col'] ?? json['c'] ?? json['column'] ?? json['x'];

    if (rowVal == null || colVal == null) {
      throw const FormatException('Missing point coordinate.');
    }

    return ZipPointDto(
      row: rowVal is int ? rowVal : int.parse(rowVal.toString()),
      col: colVal is int ? colVal : int.parse(colVal.toString()),
    );
  }
}

class ZipWallDto {
  final ZipPointDto from;
  final ZipPointDto to;

  const ZipWallDto({required this.from, required this.to});

  factory ZipWallDto.fromJson(Map<String, dynamic> json) {
    final rawFrom = json['from'] ?? json['a'] ?? json['p1'];
    final rawTo = json['to'] ?? json['b'] ?? json['p2'];

    if (rawFrom is! Map || rawTo is! Map) {
      throw const FormatException('Invalid wall endpoints.');
    }

    return ZipWallDto(
      from: ZipPointDto.fromJson(Map<String, dynamic>.from(rawFrom)),
      to: ZipPointDto.fromJson(Map<String, dynamic>.from(rawTo)),
    );
  }
}
