import 'package:flutter/material.dart';
import 'package:chotanews/features/zip_puzzle/data/models/grid_point.dart';

enum PatchShapeType {
  square,
  tall,
  wide,
  any;

  String get displayName {
    switch (this) {
      case PatchShapeType.square:
        return 'Square';
      case PatchShapeType.tall:
        return 'Tall rectangle';
      case PatchShapeType.wide:
        return 'Wide rectangle';
      case PatchShapeType.any:
        return 'Any of the above';
    }
  }

  bool matches(int width, int height) {
    switch (this) {
      case PatchShapeType.square:
        return width == height;
      case PatchShapeType.tall:
        return height > width;
      case PatchShapeType.wide:
        return width > height;
      case PatchShapeType.any:
        return true;
    }
  }
}

class PatchClue {
  final String id;
  final GridPoint point;
  final int? targetArea; // null if shape size is inferred from grid
  final PatchShapeType shapeType;
  final Color color;
  final Color tintColor;

  const PatchClue({
    required this.id,
    required this.point,
    this.targetArea,
    this.shapeType = PatchShapeType.any,
    required this.color,
    required this.tintColor,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'row': point.row,
        'col': point.col,
        'targetArea': targetArea,
        'shapeType': shapeType.name,
        'color': color.toARGB32(),
        'tintColor': tintColor.toARGB32(),
      };

  factory PatchClue.fromJson(Map<String, dynamic> json) => PatchClue(
        id: json['id'] as String,
        point: GridPoint(json['row'] as int, json['col'] as int),
        targetArea: json['targetArea'] as int?,
        shapeType: PatchShapeType.values.byName(json['shapeType'] as String),
        color: Color(json['color'] as int),
        tintColor: Color(json['tintColor'] as int),
      );
}
