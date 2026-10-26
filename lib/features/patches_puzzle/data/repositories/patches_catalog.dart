// Generated Patches Puzzle Catalog with 100 Verified Level Tilings
import 'package:flutter/material.dart';
import 'package:chotanews/features/zip_puzzle/data/models/grid_point.dart';
import 'package:chotanews/features/zip_puzzle/data/models/level_definition.dart';
import '../models/drawn_patch.dart';
import '../models/patch_clue.dart';
import '../models/patches_level_definition.dart';

class PatchesCatalog {
  static const int totalLevels = 100;
  static final List<PatchesLevelDefinition> _levels = _generateCatalog();
  static List<PatchesLevelDefinition> get allLevels => _levels;
  static PatchesLevelDefinition getLevel(int levelNumber) {
    final clamped = levelNumber.clamp(1, totalLevels);
    return _levels[clamped - 1];
  }

  static List<PatchesLevelDefinition> _generateCatalog() {
    final list = <PatchesLevelDefinition>[];
    // Level 1: Exact LinkedIn Patches Hard Puzzle from user screenshot
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 1,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: GridPoint(0, 0), targetArea: 3, shapeType: PatchShapeType.wide, color: Color(0xFFD32F2F), tintColor: Color(0xFFFFEBEE)),
          PatchClue(id: 'c2', point: GridPoint(0, 5), targetArea: 5, shapeType: PatchShapeType.tall, color: Color(0xFF00838F), tintColor: Color(0xFFE0F7FA)),
          PatchClue(id: 'c3', point: GridPoint(1, 3), targetArea: 5, shapeType: PatchShapeType.any, color: Color(0xFF2E7D32), tintColor: Color(0xFFE8F5E9)),
          PatchClue(id: 'c4', point: GridPoint(2, 1), targetArea: null, shapeType: PatchShapeType.wide, color: Color(0xFF6A1B9A), tintColor: Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: GridPoint(3, 4), targetArea: null, shapeType: PatchShapeType.tall, color: Color(0xFFEF6C00), tintColor: Color(0xFFFFF3E0)),
          PatchClue(id: 'c6', point: GridPoint(4, 2), targetArea: 2, shapeType: PatchShapeType.any, color: Color(0xFFD81B60), tintColor: Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: GridPoint(5, 0), targetArea: 6, shapeType: PatchShapeType.tall, color: Color(0xFF0288D1), tintColor: Color(0xFFE1F5FE)),
          PatchClue(id: 'c8', point: GridPoint(5, 5), targetArea: 4, shapeType: PatchShapeType.wide, color: Color(0xFFB07A10), tintColor: Color(0xFFFFF8E1)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 0, minCol: 0, maxCol: 2, color: Color(0xFFD32F2F), tintColor: Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 5, maxCol: 5, color: Color(0xFF00838F), tintColor: Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 4, minCol: 3, maxCol: 3, color: Color(0xFF2E7D32), tintColor: Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c4', minRow: 1, maxRow: 2, minCol: 0, maxCol: 2, color: Color(0xFF6A1B9A), tintColor: Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 4, minCol: 4, maxCol: 4, color: Color(0xFFEF6C00), tintColor: Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c6', minRow: 3, maxRow: 4, minCol: 2, maxCol: 2, color: Color(0xFFD81B60), tintColor: Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 3, maxRow: 5, minCol: 0, maxCol: 1, color: Color(0xFF0288D1), tintColor: Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c8', minRow: 5, maxRow: 5, minCol: 2, maxCol: 5, color: Color(0xFFB07A10), tintColor: Color(0xFFFFF8E1)),
        ],
      ),
    );
    // Level 2 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 2,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 0), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c2', point: const GridPoint(1, 4), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(1, 3), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c4', point: const GridPoint(3, 1), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c5', point: const GridPoint(4, 2), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c6', point: const GridPoint(0, 2), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c7', point: const GridPoint(2, 1), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 2, minCol: 3, maxCol: 3, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c4', minRow: 3, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 4, minCol: 2, maxCol: 3, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 0, minCol: 1, maxCol: 2, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 2, minCol: 1, maxCol: 2, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
        ],
      ),
    );
    // Level 3 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 3,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 5), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c2', point: const GridPoint(5, 0), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c3', point: const GridPoint(0, 0), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c4', point: const GridPoint(1, 4), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(5, 1), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(4, 4), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c7', point: const GridPoint(2, 1), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c8', point: const GridPoint(2, 5), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 3, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c2', minRow: 3, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 0, minCol: 0, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c4', minRow: 1, maxRow: 1, minCol: 0, maxCol: 5, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 5, minCol: 1, maxCol: 2, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 3, maxRow: 5, minCol: 3, maxCol: 4, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c7', minRow: 2, maxRow: 2, minCol: 0, maxCol: 1, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c8', minRow: 2, maxRow: 2, minCol: 2, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
        ],
      ),
    );
    // Level 4 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 4,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(2, 1), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c2', point: const GridPoint(0, 4), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c3', point: const GridPoint(1, 4), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c4', point: const GridPoint(3, 2), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c5', point: const GridPoint(4, 1), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c6', point: const GridPoint(0, 0), targetArea: null, shapeType: PatchShapeType.square, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(3, 0), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c8', point: const GridPoint(5, 1), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c9', point: const GridPoint(5, 4), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 2, maxRow: 2, minCol: 1, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 0, minCol: 1, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 1, minCol: 1, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c4', minRow: 3, maxRow: 3, minCol: 1, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c5', minRow: 4, maxRow: 4, minCol: 1, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 0, minCol: 0, maxCol: 0, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c8', minRow: 5, maxRow: 5, minCol: 1, maxCol: 3, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c9', minRow: 5, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 5 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 5,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 1), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c2', point: const GridPoint(0, 4), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c3', point: const GridPoint(1, 4), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c4', point: const GridPoint(3, 4), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c5', point: const GridPoint(2, 1), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c6', point: const GridPoint(1, 2), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(2, 0), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c8', point: const GridPoint(4, 0), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 5, maxRow: 5, minCol: 1, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 0, minCol: 1, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 2, minCol: 3, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c4', minRow: 3, maxRow: 4, minCol: 3, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 3, minCol: 0, maxCol: 0, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c8', minRow: 4, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 6 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 6,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(6, 5), targetArea: 7, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c2', point: const GridPoint(1, 0), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c3', point: const GridPoint(2, 1), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c4', point: const GridPoint(0, 4), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(1, 4), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c6', point: const GridPoint(4, 6), targetArea: 7, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c7', point: const GridPoint(5, 2), targetArea: 7, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c8', point: const GridPoint(2, 2), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c9', point: const GridPoint(3, 5), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 6, maxRow: 6, minCol: 0, maxCol: 6, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 3, minCol: 0, maxCol: 0, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 3, minCol: 1, maxCol: 1, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 0, minCol: 2, maxCol: 6, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 1, minCol: 2, maxCol: 6, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c6', minRow: 4, maxRow: 4, minCol: 0, maxCol: 6, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c7', minRow: 5, maxRow: 5, minCol: 0, maxCol: 6, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c8', minRow: 2, maxRow: 2, minCol: 2, maxCol: 6, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c9', minRow: 3, maxRow: 3, minCol: 2, maxCol: 6, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
        ],
      ),
    );
    // Level 7 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 7,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(1, 4), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(5, 2), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c3', point: const GridPoint(3, 0), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c4', point: const GridPoint(4, 2), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(0, 5), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c6', point: const GridPoint(4, 5), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c7', point: const GridPoint(0, 1), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c8', point: const GridPoint(1, 0), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c9', point: const GridPoint(1, 3), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c10', point: const GridPoint(3, 3), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 5, minCol: 4, maxCol: 4, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 5, maxRow: 5, minCol: 0, maxCol: 2, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c3', minRow: 2, maxRow: 3, minCol: 0, maxCol: 2, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c4', minRow: 4, maxRow: 4, minCol: 0, maxCol: 2, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 1, minCol: 5, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c6', minRow: 2, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 0, minCol: 0, maxCol: 2, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c8', minRow: 1, maxRow: 1, minCol: 0, maxCol: 2, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 1, minCol: 3, maxCol: 3, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c10', minRow: 2, maxRow: 5, minCol: 3, maxCol: 3, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
      ),
    );
    // Level 8 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 8,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(3, 0), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(4, 0), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c3', point: const GridPoint(0, 0), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(1, 1), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c5', point: const GridPoint(2, 0), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c6', point: const GridPoint(2, 4), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 3, maxRow: 3, minCol: 0, maxCol: 4, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 4, maxRow: 4, minCol: 0, maxCol: 4, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 0, minCol: 0, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 1, maxRow: 1, minCol: 0, maxCol: 4, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c5', minRow: 2, maxRow: 2, minCol: 0, maxCol: 3, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c6', minRow: 2, maxRow: 2, minCol: 4, maxCol: 4, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
        ],
      ),
    );
    // Level 9 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 9,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(2, 5), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c2', point: const GridPoint(5, 1), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(1, 4), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c4', point: const GridPoint(2, 0), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c5', point: const GridPoint(1, 1), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c6', point: const GridPoint(4, 2), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c7', point: const GridPoint(3, 3), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c2', minRow: 5, maxRow: 5, minCol: 0, maxCol: 4, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 4, minCol: 3, maxCol: 3, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
        ],
      ),
    );
    // Level 10 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 10,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(1, 0), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c2', point: const GridPoint(2, 5), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(3, 1), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c4', point: const GridPoint(1, 4), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(2, 2), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c6', point: const GridPoint(3, 3), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c7', point: const GridPoint(4, 0), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c8', point: const GridPoint(4, 5), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c9', point: const GridPoint(5, 0), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c10', point: const GridPoint(5, 2), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 3, minCol: 0, maxCol: 0, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 3, minCol: 5, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 3, minCol: 1, maxCol: 1, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 3, minCol: 4, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 3, minCol: 2, maxCol: 2, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 3, minCol: 3, maxCol: 3, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c7', minRow: 4, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c8', minRow: 4, maxRow: 4, minCol: 1, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c9', minRow: 5, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c10', minRow: 5, maxRow: 5, minCol: 1, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
      ),
    );
    // Level 11 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 11,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 2), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(1, 2), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(4, 0), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c4', point: const GridPoint(5, 1), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(2, 4), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c6', point: const GridPoint(3, 5), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c7', point: const GridPoint(4, 3), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c8', point: const GridPoint(5, 4), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 0, minCol: 0, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 1, maxRow: 3, minCol: 2, maxCol: 2, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c4', minRow: 1, maxRow: 5, minCol: 1, maxCol: 1, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 3, minCol: 3, maxCol: 4, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 3, minCol: 5, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c7', minRow: 4, maxRow: 5, minCol: 2, maxCol: 3, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c8', minRow: 4, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
      ),
    );
    // Level 12 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 12,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 6), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(4, 2), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c3', point: const GridPoint(2, 3), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c4', point: const GridPoint(2, 1), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c5', point: const GridPoint(3, 5), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c6', point: const GridPoint(6, 4), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(6, 0), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c8', point: const GridPoint(5, 1), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c9', point: const GridPoint(0, 0), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c10', point: const GridPoint(0, 5), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c11', point: const GridPoint(1, 4), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c12', point: const GridPoint(1, 6), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 2, maxRow: 6, minCol: 6, maxCol: 6, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 2, maxRow: 6, minCol: 2, maxCol: 2, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c3', minRow: 2, maxRow: 6, minCol: 3, maxCol: 3, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 2, minCol: 0, maxCol: 1, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c5', minRow: 2, maxRow: 4, minCol: 4, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c6', minRow: 5, maxRow: 6, minCol: 4, maxCol: 5, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 3, maxRow: 6, minCol: 0, maxCol: 0, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c8', minRow: 3, maxRow: 6, minCol: 1, maxCol: 1, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 0, minCol: 0, maxCol: 4, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c10', minRow: 0, maxRow: 0, minCol: 5, maxCol: 6, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c11', minRow: 1, maxRow: 1, minCol: 0, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c12', minRow: 1, maxRow: 1, minCol: 6, maxCol: 6, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
        ],
      ),
    );
    // Level 13 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 13,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 1), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c2', point: const GridPoint(0, 2), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(1, 2), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c4', point: const GridPoint(2, 2), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c5', point: const GridPoint(3, 4), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c6', point: const GridPoint(4, 5), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(0, 0), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c8', point: const GridPoint(4, 0), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c9', point: const GridPoint(5, 3), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c10', point: const GridPoint(4, 4), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 4, maxRow: 5, minCol: 1, maxCol: 1, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 0, minCol: 1, maxCol: 5, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 1, minCol: 1, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 2, minCol: 1, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 3, minCol: 1, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c6', minRow: 4, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 2, minCol: 0, maxCol: 0, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c8', minRow: 3, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c9', minRow: 4, maxRow: 5, minCol: 2, maxCol: 3, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c10', minRow: 4, maxRow: 5, minCol: 4, maxCol: 4, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
        ],
      ),
    );
    // Level 14 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 14,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 3), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c2', point: const GridPoint(3, 4), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c3', point: const GridPoint(1, 0), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c4', point: const GridPoint(2, 1), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c5', point: const GridPoint(3, 2), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c6', point: const GridPoint(4, 3), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 0, minCol: 0, maxCol: 4, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c2', minRow: 1, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 1, minCol: 0, maxCol: 3, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 2, minCol: 0, maxCol: 3, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 3, minCol: 0, maxCol: 3, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c6', minRow: 4, maxRow: 4, minCol: 0, maxCol: 3, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 15 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 15,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 5), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c2', point: const GridPoint(1, 0), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c3', point: const GridPoint(2, 0), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c4', point: const GridPoint(5, 1), targetArea: 10, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(4, 5), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c6', point: const GridPoint(2, 3), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(3, 4), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 0, minCol: 0, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c2', minRow: 1, maxRow: 1, minCol: 0, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c3', minRow: 2, maxRow: 3, minCol: 0, maxCol: 0, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c4', minRow: 4, maxRow: 5, minCol: 0, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 4, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c6', minRow: 2, maxRow: 2, minCol: 1, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 3, maxRow: 3, minCol: 1, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
      ),
    );
    // Level 16 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 16,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 5), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(0, 4), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c3', point: const GridPoint(5, 4), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(2, 3), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c5', point: const GridPoint(3, 0), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c6', point: const GridPoint(5, 0), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(1, 0), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c8', point: const GridPoint(2, 1), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 2, minCol: 4, maxCol: 4, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c3', minRow: 3, maxRow: 5, minCol: 3, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 2, minCol: 3, maxCol: 3, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 4, minCol: 0, maxCol: 2, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c6', minRow: 5, maxRow: 5, minCol: 0, maxCol: 2, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 2, minCol: 0, maxCol: 0, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c8', minRow: 0, maxRow: 2, minCol: 1, maxCol: 2, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
        ],
      ),
    );
    // Level 17 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 17,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(1, 0), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c2', point: const GridPoint(3, 5), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c3', point: const GridPoint(4, 1), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c4', point: const GridPoint(2, 3), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(3, 3), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c6', point: const GridPoint(4, 4), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c7', point: const GridPoint(5, 3), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c8', point: const GridPoint(0, 0), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c9', point: const GridPoint(0, 5), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 1, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c2', minRow: 1, maxRow: 3, minCol: 4, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c3', minRow: 4, maxRow: 5, minCol: 1, maxCol: 1, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c4', minRow: 1, maxRow: 2, minCol: 1, maxCol: 3, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 3, minCol: 1, maxCol: 3, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c6', minRow: 4, maxRow: 4, minCol: 2, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c7', minRow: 5, maxRow: 5, minCol: 2, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c8', minRow: 0, maxRow: 0, minCol: 0, maxCol: 3, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 0, minCol: 4, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 18 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 18,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(6, 3), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c2', point: const GridPoint(5, 5), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(2, 5), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c4', point: const GridPoint(4, 6), targetArea: 10, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c5', point: const GridPoint(0, 0), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c6', point: const GridPoint(0, 1), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c7', point: const GridPoint(1, 2), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c8', point: const GridPoint(5, 0), targetArea: 8, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c9', point: const GridPoint(6, 0), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 6, maxRow: 6, minCol: 2, maxCol: 6, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c2', minRow: 5, maxRow: 5, minCol: 2, maxCol: 6, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 2, maxRow: 2, minCol: 2, maxCol: 6, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c4', minRow: 3, maxRow: 4, minCol: 2, maxCol: 6, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 1, minCol: 0, maxCol: 0, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 0, minCol: 1, maxCol: 6, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 1, minCol: 1, maxCol: 6, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c8', minRow: 2, maxRow: 5, minCol: 0, maxCol: 1, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c9', minRow: 6, maxRow: 6, minCol: 0, maxCol: 1, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 19 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 19,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(2, 5), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c2', point: const GridPoint(5, 0), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c3', point: const GridPoint(1, 4), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(4, 0), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c5', point: const GridPoint(0, 0), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c6', point: const GridPoint(1, 2), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c7', point: const GridPoint(4, 1), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c8', point: const GridPoint(3, 4), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c2', minRow: 5, maxRow: 5, minCol: 0, maxCol: 4, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 2, minCol: 3, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 3, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 0, minCol: 0, maxCol: 2, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 2, minCol: 0, maxCol: 2, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c7', minRow: 3, maxRow: 4, minCol: 1, maxCol: 3, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c8', minRow: 3, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 20 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 20,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(3, 1), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c2', point: const GridPoint(4, 4), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c3', point: const GridPoint(2, 2), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(0, 1), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c5', point: const GridPoint(2, 1), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c6', point: const GridPoint(0, 3), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(1, 3), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 3, maxRow: 3, minCol: 0, maxCol: 4, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c2', minRow: 4, maxRow: 4, minCol: 0, maxCol: 4, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c3', minRow: 2, maxRow: 2, minCol: 2, maxCol: 4, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 0, minCol: 0, maxCol: 1, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 2, minCol: 0, maxCol: 1, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 0, minCol: 2, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 1, minCol: 2, maxCol: 4, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
        ],
      ),
    );
    // Level 21 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 21,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 0), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c2', point: const GridPoint(1, 2), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c3', point: const GridPoint(3, 5), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c4', point: const GridPoint(4, 3), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c5', point: const GridPoint(0, 4), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c6', point: const GridPoint(2, 5), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(5, 2), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c8', point: const GridPoint(5, 5), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 2, minCol: 1, maxCol: 2, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c3', minRow: 3, maxRow: 3, minCol: 1, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c4', minRow: 4, maxRow: 4, minCol: 1, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 0, minCol: 3, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 2, minCol: 3, maxCol: 5, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 5, maxRow: 5, minCol: 0, maxCol: 2, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c8', minRow: 5, maxRow: 5, minCol: 3, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
        ],
      ),
    );
    // Level 22 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 22,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 4), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c2', point: const GridPoint(1, 1), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(3, 2), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c4', point: const GridPoint(3, 4), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c5', point: const GridPoint(0, 0), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c6', point: const GridPoint(0, 2), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c7', point: const GridPoint(5, 0), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c8', point: const GridPoint(5, 5), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 4, maxRow: 4, minCol: 0, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c2', minRow: 1, maxRow: 1, minCol: 0, maxCol: 5, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 2, maxRow: 3, minCol: 0, maxCol: 2, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 3, minCol: 3, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 0, minCol: 0, maxCol: 0, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 0, minCol: 1, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c7', minRow: 5, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c8', minRow: 5, maxRow: 5, minCol: 1, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 23 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 23,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 5), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c2', point: const GridPoint(3, 1), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c3', point: const GridPoint(0, 5), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(4, 3), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c5', point: const GridPoint(5, 0), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c6', point: const GridPoint(1, 0), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c7', point: const GridPoint(0, 2), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c8', point: const GridPoint(2, 0), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c9', point: const GridPoint(2, 5), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 3, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c2', minRow: 3, maxRow: 3, minCol: 0, maxCol: 4, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 1, minCol: 4, maxCol: 5, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 4, maxRow: 4, minCol: 0, maxCol: 4, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c5', minRow: 5, maxRow: 5, minCol: 0, maxCol: 4, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 1, minCol: 0, maxCol: 1, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 1, minCol: 2, maxCol: 3, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c8', minRow: 2, maxRow: 2, minCol: 0, maxCol: 4, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c9', minRow: 2, maxRow: 2, minCol: 5, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 24 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 24,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 0), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c2', point: const GridPoint(4, 3), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c3', point: const GridPoint(0, 1), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c4', point: const GridPoint(6, 1), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c5', point: const GridPoint(0, 2), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c6', point: const GridPoint(1, 5), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c7', point: const GridPoint(4, 4), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c8', point: const GridPoint(6, 6), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c9', point: const GridPoint(2, 1), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c10', point: const GridPoint(4, 2), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c11', point: const GridPoint(3, 4), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c12', point: const GridPoint(3, 5), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 2, maxRow: 6, minCol: 0, maxCol: 0, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c2', minRow: 2, maxRow: 6, minCol: 3, maxCol: 3, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 1, minCol: 0, maxCol: 1, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c4', minRow: 6, maxRow: 6, minCol: 1, maxCol: 2, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 1, minCol: 2, maxCol: 3, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 1, minCol: 4, maxCol: 6, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c7', minRow: 4, maxRow: 4, minCol: 4, maxCol: 6, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c8', minRow: 5, maxRow: 6, minCol: 4, maxCol: 6, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c9', minRow: 2, maxRow: 5, minCol: 1, maxCol: 1, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c10', minRow: 2, maxRow: 5, minCol: 2, maxCol: 2, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c11', minRow: 2, maxRow: 3, minCol: 4, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c12', minRow: 2, maxRow: 3, minCol: 5, maxCol: 6, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
      ),
    );
    // Level 25 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 25,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 0), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c2', point: const GridPoint(0, 1), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(3, 2), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c4', point: const GridPoint(0, 3), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(5, 0), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c6', point: const GridPoint(5, 3), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(1, 5), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c8', point: const GridPoint(4, 5), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c9', point: const GridPoint(0, 4), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c10', point: const GridPoint(4, 4), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 4, minCol: 3, maxCol: 3, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 5, maxRow: 5, minCol: 0, maxCol: 2, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c6', minRow: 5, maxRow: 5, minCol: 3, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 3, minCol: 5, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c8', minRow: 4, maxRow: 4, minCol: 5, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 0, minCol: 4, maxCol: 4, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c10', minRow: 1, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
      ),
    );
    // Level 26 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 26,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(2, 4), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c2', point: const GridPoint(0, 1), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c3', point: const GridPoint(0, 4), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c4', point: const GridPoint(4, 0), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c5', point: const GridPoint(3, 2), targetArea: 8, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 2, maxRow: 2, minCol: 0, maxCol: 4, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 1, minCol: 0, maxCol: 1, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 1, minCol: 2, maxCol: 4, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c4', minRow: 3, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 4, minCol: 1, maxCol: 4, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
        ],
      ),
    );
    // Level 27 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 27,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(3, 1), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(5, 3), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c3', point: const GridPoint(1, 3), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c4', point: const GridPoint(3, 3), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c5', point: const GridPoint(1, 4), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(2, 5), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c7', point: const GridPoint(1, 0), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c8', point: const GridPoint(5, 0), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 5, minCol: 1, maxCol: 1, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 5, maxRow: 5, minCol: 2, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 2, minCol: 2, maxCol: 3, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c4', minRow: 3, maxRow: 4, minCol: 2, maxCol: 3, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 4, minCol: 5, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 2, minCol: 0, maxCol: 0, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c8', minRow: 3, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
        ],
      ),
    );
    // Level 28 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 28,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 1), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c2', point: const GridPoint(2, 0), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c3', point: const GridPoint(1, 1), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(0, 3), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c5', point: const GridPoint(5, 3), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c6', point: const GridPoint(3, 5), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(0, 2), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c8', point: const GridPoint(3, 2), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c9', point: const GridPoint(0, 4), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c10', point: const GridPoint(0, 5), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 5, maxRow: 5, minCol: 0, maxCol: 1, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 2, minCol: 3, maxCol: 3, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 5, minCol: 3, maxCol: 3, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c6', minRow: 3, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 0, minCol: 2, maxCol: 2, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c8', minRow: 1, maxRow: 5, minCol: 2, maxCol: 2, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 2, minCol: 4, maxCol: 4, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c10', minRow: 0, maxRow: 2, minCol: 5, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
      ),
    );
    // Level 29 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 29,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 1), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c2', point: const GridPoint(0, 3), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(1, 0), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c4', point: const GridPoint(3, 0), targetArea: 9, shapeType: PatchShapeType.square, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(4, 5), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(5, 3), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c7', point: const GridPoint(1, 4), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 5, maxRow: 5, minCol: 0, maxCol: 2, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 0, minCol: 3, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 1, minCol: 0, maxCol: 2, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 4, minCol: 0, maxCol: 2, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 5, minCol: 3, maxCol: 3, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 5, minCol: 4, maxCol: 4, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 30 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 30,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 0), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c2', point: const GridPoint(3, 5), targetArea: 7, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(4, 1), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(1, 0), targetArea: 7, shapeType: PatchShapeType.any, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c5', point: const GridPoint(2, 0), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c6', point: const GridPoint(5, 3), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c7', point: const GridPoint(6, 5), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c8', point: const GridPoint(0, 2), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c9', point: const GridPoint(0, 6), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 4, maxRow: 6, minCol: 0, maxCol: 0, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c2', minRow: 3, maxRow: 3, minCol: 0, maxCol: 6, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 4, maxRow: 4, minCol: 1, maxCol: 6, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 1, maxRow: 1, minCol: 0, maxCol: 6, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c5', minRow: 2, maxRow: 2, minCol: 0, maxCol: 6, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c6', minRow: 5, maxRow: 5, minCol: 1, maxCol: 6, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c7', minRow: 6, maxRow: 6, minCol: 1, maxCol: 6, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c8', minRow: 0, maxRow: 0, minCol: 0, maxCol: 2, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 0, minCol: 3, maxCol: 6, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
        ],
      ),
    );
    // Level 31 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 31,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 0), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c2', point: const GridPoint(4, 0), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c3', point: const GridPoint(5, 5), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c4', point: const GridPoint(5, 1), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c5', point: const GridPoint(0, 1), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c6', point: const GridPoint(0, 2), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c7', point: const GridPoint(3, 2), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c8', point: const GridPoint(4, 2), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c9', point: const GridPoint(0, 5), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c10', point: const GridPoint(2, 4), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 2, minCol: 0, maxCol: 0, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c2', minRow: 3, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c3', minRow: 3, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c4', minRow: 5, maxRow: 5, minCol: 1, maxCol: 4, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 2, minCol: 1, maxCol: 1, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 2, minCol: 2, maxCol: 3, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c7', minRow: 3, maxRow: 3, minCol: 1, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c8', minRow: 4, maxRow: 4, minCol: 1, maxCol: 4, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 1, minCol: 4, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c10', minRow: 2, maxRow: 2, minCol: 4, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 32 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 32,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 1), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c2', point: const GridPoint(3, 4), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c3', point: const GridPoint(0, 2), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c4', point: const GridPoint(1, 3), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c5', point: const GridPoint(1, 0), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c6', point: const GridPoint(2, 0), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 4, minCol: 3, maxCol: 3, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 1, minCol: 0, maxCol: 0, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c6', minRow: 2, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 33 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 33,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 0), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c2', point: const GridPoint(1, 3), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(5, 5), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c4', point: const GridPoint(2, 2), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c5', point: const GridPoint(0, 5), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c6', point: const GridPoint(2, 5), targetArea: 8, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c7', point: const GridPoint(5, 1), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c8', point: const GridPoint(3, 2), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 1, minCol: 1, maxCol: 3, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 5, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 2, minCol: 1, maxCol: 3, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 0, minCol: 4, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 4, minCol: 4, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c7', minRow: 3, maxRow: 5, minCol: 1, maxCol: 1, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c8', minRow: 3, maxRow: 5, minCol: 2, maxCol: 3, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 34 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 34,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 0), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c2', point: const GridPoint(3, 4), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c3', point: const GridPoint(1, 4), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c4', point: const GridPoint(2, 3), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c5', point: const GridPoint(5, 1), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c6', point: const GridPoint(5, 3), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c7', point: const GridPoint(0, 1), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c8', point: const GridPoint(0, 4), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 3, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c2', minRow: 3, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 1, minCol: 0, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 2, minCol: 0, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 5, minCol: 1, maxCol: 1, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c6', minRow: 3, maxRow: 5, minCol: 2, maxCol: 3, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 0, minCol: 0, maxCol: 1, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c8', minRow: 0, maxRow: 0, minCol: 2, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
        ],
      ),
    );
    // Level 35 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 35,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 3), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c2', point: const GridPoint(4, 0), targetArea: 8, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c3', point: const GridPoint(0, 5), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c4', point: const GridPoint(3, 0), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c5', point: const GridPoint(3, 5), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c6', point: const GridPoint(5, 4), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(2, 1), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c8', point: const GridPoint(3, 3), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 0, minCol: 0, maxCol: 3, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c2', minRow: 4, maxRow: 5, minCol: 0, maxCol: 3, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 0, minCol: 4, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c4', minRow: 1, maxRow: 3, minCol: 0, maxCol: 0, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 3, minCol: 4, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c6', minRow: 4, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 3, minCol: 1, maxCol: 2, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c8', minRow: 1, maxRow: 3, minCol: 3, maxCol: 3, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
        ],
      ),
    );
    // Level 36 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 36,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(6, 0), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(1, 0), targetArea: 7, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(5, 6), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c4', point: const GridPoint(6, 5), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c5', point: const GridPoint(3, 2), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c6', point: const GridPoint(3, 5), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c7', point: const GridPoint(4, 2), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c8', point: const GridPoint(4, 5), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c9', point: const GridPoint(2, 0), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c10', point: const GridPoint(2, 5), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c11', point: const GridPoint(0, 0), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c12', point: const GridPoint(0, 6), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 5, maxRow: 6, minCol: 0, maxCol: 0, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 1, maxRow: 1, minCol: 0, maxCol: 6, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 5, maxRow: 5, minCol: 1, maxCol: 6, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c4', minRow: 6, maxRow: 6, minCol: 1, maxCol: 6, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 3, minCol: 0, maxCol: 3, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c6', minRow: 3, maxRow: 3, minCol: 4, maxCol: 6, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c7', minRow: 4, maxRow: 4, minCol: 0, maxCol: 4, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c8', minRow: 4, maxRow: 4, minCol: 5, maxCol: 6, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c9', minRow: 2, maxRow: 2, minCol: 0, maxCol: 0, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c10', minRow: 2, maxRow: 2, minCol: 1, maxCol: 6, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c11', minRow: 0, maxRow: 0, minCol: 0, maxCol: 2, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c12', minRow: 0, maxRow: 0, minCol: 3, maxCol: 6, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 37 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 37,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 0), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c2', point: const GridPoint(0, 5), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c3', point: const GridPoint(1, 3), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c4', point: const GridPoint(4, 1), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c5', point: const GridPoint(5, 3), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(2, 4), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(3, 5), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c8', point: const GridPoint(2, 2), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c9', point: const GridPoint(3, 2), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 0, minCol: 0, maxCol: 3, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 1, minCol: 4, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 1, minCol: 0, maxCol: 3, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c4', minRow: 4, maxRow: 5, minCol: 0, maxCol: 1, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c5', minRow: 4, maxRow: 5, minCol: 2, maxCol: 3, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 2, maxRow: 2, minCol: 4, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 3, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c8', minRow: 2, maxRow: 2, minCol: 0, maxCol: 3, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c9', minRow: 3, maxRow: 3, minCol: 0, maxCol: 3, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
      ),
    );
    // Level 38 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 38,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(3, 0), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c2', point: const GridPoint(1, 1), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c3', point: const GridPoint(2, 2), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c4', point: const GridPoint(3, 4), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c5', point: const GridPoint(0, 4), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c6', point: const GridPoint(2, 3), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c4', minRow: 3, maxRow: 4, minCol: 3, maxCol: 4, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 1, minCol: 3, maxCol: 4, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c6', minRow: 2, maxRow: 2, minCol: 3, maxCol: 4, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
      ),
    );
    // Level 39 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 39,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 2), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c2', point: const GridPoint(3, 3), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c3', point: const GridPoint(5, 0), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c4', point: const GridPoint(0, 4), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c5', point: const GridPoint(1, 4), targetArea: 10, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c6', point: const GridPoint(0, 1), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(4, 0), targetArea: null, shapeType: PatchShapeType.square, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 5, minCol: 2, maxCol: 2, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 5, minCol: 3, maxCol: 3, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c3', minRow: 5, maxRow: 5, minCol: 0, maxCol: 1, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 0, minCol: 4, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 2, minCol: 0, maxCol: 1, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 3, maxRow: 4, minCol: 0, maxCol: 1, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
      ),
    );
    // Level 40 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 40,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 5), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c2', point: const GridPoint(1, 2), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c3', point: const GridPoint(2, 0), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c4', point: const GridPoint(4, 2), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c5', point: const GridPoint(5, 2), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c6', point: const GridPoint(0, 1), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(0, 4), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c8', point: const GridPoint(3, 3), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c9', point: const GridPoint(5, 4), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 1, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c2', minRow: 1, maxRow: 1, minCol: 0, maxCol: 4, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c3', minRow: 2, maxRow: 2, minCol: 0, maxCol: 4, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c4', minRow: 3, maxRow: 4, minCol: 0, maxCol: 2, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c5', minRow: 5, maxRow: 5, minCol: 0, maxCol: 2, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 0, minCol: 0, maxCol: 1, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 0, minCol: 2, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c8', minRow: 3, maxRow: 5, minCol: 3, maxCol: 3, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c9', minRow: 3, maxRow: 5, minCol: 4, maxCol: 4, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 41 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 41,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(2, 4), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c2', point: const GridPoint(3, 4), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(1, 0), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c4', point: const GridPoint(5, 3), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c5', point: const GridPoint(0, 1), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c6', point: const GridPoint(1, 1), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c7', point: const GridPoint(3, 1), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c8', point: const GridPoint(4, 2), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 2, maxRow: 2, minCol: 0, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c2', minRow: 3, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 1, minCol: 0, maxCol: 0, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c4', minRow: 5, maxRow: 5, minCol: 0, maxCol: 3, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 0, minCol: 1, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 1, minCol: 1, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c7', minRow: 3, maxRow: 3, minCol: 0, maxCol: 3, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c8', minRow: 4, maxRow: 4, minCol: 0, maxCol: 3, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 42 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 42,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 6), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c2', point: const GridPoint(6, 5), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c3', point: const GridPoint(1, 6), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c4', point: const GridPoint(4, 2), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c5', point: const GridPoint(4, 3), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c6', point: const GridPoint(0, 4), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(1, 3), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c8', point: const GridPoint(2, 2), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c9', point: const GridPoint(3, 1), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c10', point: const GridPoint(3, 3), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c11', point: const GridPoint(0, 0), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c12', point: const GridPoint(2, 1), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 3, maxRow: 6, minCol: 6, maxCol: 6, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c2', minRow: 6, maxRow: 6, minCol: 0, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 2, minCol: 6, maxCol: 6, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c4', minRow: 4, maxRow: 5, minCol: 0, maxCol: 2, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c5', minRow: 4, maxRow: 5, minCol: 3, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 0, minCol: 2, maxCol: 5, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 1, minCol: 2, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c8', minRow: 2, maxRow: 2, minCol: 2, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c9', minRow: 3, maxRow: 3, minCol: 0, maxCol: 1, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c10', minRow: 3, maxRow: 3, minCol: 2, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c11', minRow: 0, maxRow: 2, minCol: 0, maxCol: 0, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c12', minRow: 0, maxRow: 2, minCol: 1, maxCol: 1, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 43 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 43,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 5), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c2', point: const GridPoint(4, 0), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c3', point: const GridPoint(3, 1), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(0, 5), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c5', point: const GridPoint(0, 3), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(1, 4), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(1, 2), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c8', point: const GridPoint(4, 2), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 4, maxRow: 5, minCol: 3, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 5, minCol: 1, maxCol: 1, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 3, minCol: 5, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 0, minCol: 3, maxCol: 4, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 3, minCol: 3, maxCol: 4, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 3, minCol: 2, maxCol: 2, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c8', minRow: 4, maxRow: 5, minCol: 2, maxCol: 2, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
      ),
    );
    // Level 44 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 44,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(2, 0), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c2', point: const GridPoint(3, 1), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c3', point: const GridPoint(4, 1), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c4', point: const GridPoint(0, 4), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c5', point: const GridPoint(1, 2), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 2, maxRow: 2, minCol: 0, maxCol: 4, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c2', minRow: 3, maxRow: 3, minCol: 0, maxCol: 4, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c3', minRow: 4, maxRow: 4, minCol: 0, maxCol: 4, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 0, minCol: 0, maxCol: 4, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 1, minCol: 0, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 45 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 45,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 2), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c2', point: const GridPoint(3, 4), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(1, 4), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c4', point: const GridPoint(2, 1), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(5, 1), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c6', point: const GridPoint(3, 2), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c7', point: const GridPoint(0, 0), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c8', point: const GridPoint(5, 0), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 0, minCol: 1, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c2', minRow: 3, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 1, minCol: 1, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 2, minCol: 1, maxCol: 5, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 5, minCol: 1, maxCol: 1, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c6', minRow: 3, maxRow: 5, minCol: 2, maxCol: 3, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c8', minRow: 5, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
      ),
    );
    // Level 46 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 46,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 0), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c2', point: const GridPoint(0, 5), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c3', point: const GridPoint(5, 3), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c4', point: const GridPoint(5, 5), targetArea: 8, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c5', point: const GridPoint(0, 4), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(1, 4), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(3, 1), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c8', point: const GridPoint(3, 2), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 2, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 1, minCol: 5, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c3', minRow: 2, maxRow: 5, minCol: 3, maxCol: 3, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 0, minCol: 0, maxCol: 4, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 1, minCol: 0, maxCol: 4, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 2, maxRow: 5, minCol: 1, maxCol: 1, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c8', minRow: 2, maxRow: 5, minCol: 2, maxCol: 2, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 47 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 47,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(1, 4), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c2', point: const GridPoint(5, 1), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(4, 2), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c4', point: const GridPoint(3, 3), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c5', point: const GridPoint(2, 3), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(1, 0), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(2, 2), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c8', point: const GridPoint(0, 5), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c9', point: const GridPoint(5, 5), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 5, minCol: 4, maxCol: 4, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c2', minRow: 5, maxRow: 5, minCol: 0, maxCol: 3, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 4, maxRow: 4, minCol: 0, maxCol: 3, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c4', minRow: 3, maxRow: 3, minCol: 0, maxCol: 3, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 2, minCol: 3, maxCol: 3, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 2, minCol: 0, maxCol: 0, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 2, minCol: 1, maxCol: 2, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c8', minRow: 0, maxRow: 4, minCol: 5, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c9', minRow: 5, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
        ],
      ),
    );
    // Level 48 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 48,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 6), targetArea: 7, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c2', point: const GridPoint(0, 0), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c3', point: const GridPoint(1, 1), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c4', point: const GridPoint(2, 1), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c5', point: const GridPoint(4, 0), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(5, 0), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(6, 0), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c8', point: const GridPoint(3, 3), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c9', point: const GridPoint(4, 3), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 6, minCol: 6, maxCol: 6, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 0, minCol: 0, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 1, minCol: 0, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 2, minCol: 0, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 4, minCol: 0, maxCol: 1, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 5, maxRow: 5, minCol: 0, maxCol: 5, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 6, maxRow: 6, minCol: 0, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c8', minRow: 3, maxRow: 3, minCol: 2, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c9', minRow: 4, maxRow: 4, minCol: 2, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
        ],
      ),
    );
    // Level 49 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 49,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(1, 4), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c2', point: const GridPoint(5, 4), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c3', point: const GridPoint(1, 2), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c4', point: const GridPoint(3, 2), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c5', point: const GridPoint(1, 5), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c6', point: const GridPoint(5, 5), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(0, 0), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c8', point: const GridPoint(2, 1), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c9', point: const GridPoint(3, 1), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c10', point: const GridPoint(4, 1), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 2, minCol: 3, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c2', minRow: 3, maxRow: 5, minCol: 3, maxCol: 4, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 2, minCol: 2, maxCol: 2, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c4', minRow: 3, maxRow: 5, minCol: 2, maxCol: 2, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 4, minCol: 5, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c6', minRow: 5, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 2, minCol: 0, maxCol: 0, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c8', minRow: 0, maxRow: 2, minCol: 1, maxCol: 1, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c9', minRow: 3, maxRow: 3, minCol: 0, maxCol: 1, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c10', minRow: 4, maxRow: 5, minCol: 0, maxCol: 1, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
      ),
    );
    // Level 50 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 50,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(3, 4), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c2', point: const GridPoint(3, 3), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c3', point: const GridPoint(0, 1), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c4', point: const GridPoint(1, 0), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c5', point: const GridPoint(4, 1), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c6', point: const GridPoint(2, 0), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c7', point: const GridPoint(3, 2), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 2, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c2', minRow: 2, maxRow: 4, minCol: 3, maxCol: 3, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 0, minCol: 0, maxCol: 4, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c4', minRow: 1, maxRow: 1, minCol: 0, maxCol: 4, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c5', minRow: 4, maxRow: 4, minCol: 0, maxCol: 2, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c6', minRow: 2, maxRow: 3, minCol: 0, maxCol: 0, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c7', minRow: 2, maxRow: 3, minCol: 1, maxCol: 2, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 51 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 51,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 1), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c2', point: const GridPoint(0, 2), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(0, 5), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c4', point: const GridPoint(4, 3), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c5', point: const GridPoint(4, 1), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c6', point: const GridPoint(2, 4), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c7', point: const GridPoint(2, 5), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c8', point: const GridPoint(0, 0), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c9', point: const GridPoint(3, 1), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 5, maxRow: 5, minCol: 0, maxCol: 5, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 0, minCol: 3, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c4', minRow: 1, maxRow: 4, minCol: 3, maxCol: 3, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c5', minRow: 4, maxRow: 4, minCol: 0, maxCol: 1, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 4, minCol: 5, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c8', minRow: 0, maxRow: 3, minCol: 0, maxCol: 0, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 3, minCol: 1, maxCol: 1, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 52 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 52,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 0), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(1, 4), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c3', point: const GridPoint(3, 5), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c4', point: const GridPoint(0, 0), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c5', point: const GridPoint(1, 0), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(1, 3), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(4, 3), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c8', point: const GridPoint(3, 0), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c9', point: const GridPoint(3, 1), targetArea: null, shapeType: PatchShapeType.square, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 4, maxRow: 5, minCol: 0, maxCol: 2, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 2, minCol: 4, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c3', minRow: 3, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 0, minCol: 0, maxCol: 2, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 1, minCol: 0, maxCol: 2, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 1, minCol: 3, maxCol: 3, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 2, maxRow: 5, minCol: 3, maxCol: 3, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c8', minRow: 2, maxRow: 3, minCol: 0, maxCol: 0, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c9', minRow: 2, maxRow: 3, minCol: 1, maxCol: 2, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 53 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 53,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 4), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(1, 0), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(1, 1), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c4', point: const GridPoint(2, 2), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c5', point: const GridPoint(4, 3), targetArea: 8, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c6', point: const GridPoint(0, 3), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(1, 2), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 5, maxRow: 5, minCol: 2, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 5, minCol: 1, maxCol: 1, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 2, minCol: 2, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 4, minCol: 2, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 0, minCol: 2, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 1, minCol: 2, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
        ],
      ),
    );
    // Level 54 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 54,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(6, 0), targetArea: 7, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(4, 3), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c3', point: const GridPoint(3, 1), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c4', point: const GridPoint(5, 6), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c5', point: const GridPoint(0, 2), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c6', point: const GridPoint(0, 4), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c7', point: const GridPoint(0, 5), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c8', point: const GridPoint(4, 6), targetArea: 8, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c9', point: const GridPoint(5, 4), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c10', point: const GridPoint(6, 3), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 6, minCol: 0, maxCol: 0, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 4, maxRow: 4, minCol: 1, maxCol: 4, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 3, minCol: 1, maxCol: 1, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c4', minRow: 5, maxRow: 6, minCol: 6, maxCol: 6, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 3, minCol: 2, maxCol: 2, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 3, minCol: 3, maxCol: 4, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 0, minCol: 5, maxCol: 6, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c8', minRow: 1, maxRow: 4, minCol: 5, maxCol: 6, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c9', minRow: 5, maxRow: 5, minCol: 1, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c10', minRow: 6, maxRow: 6, minCol: 1, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
      ),
    );
    // Level 55 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 55,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 0), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c2', point: const GridPoint(0, 4), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(5, 5), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c4', point: const GridPoint(0, 1), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c5', point: const GridPoint(2, 4), targetArea: null, shapeType: PatchShapeType.square, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c6', point: const GridPoint(3, 3), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(5, 1), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c8', point: const GridPoint(3, 2), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 0, minCol: 3, maxCol: 5, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 0, minCol: 1, maxCol: 2, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 2, minCol: 3, maxCol: 4, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c6', minRow: 3, maxRow: 5, minCol: 3, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 5, minCol: 1, maxCol: 1, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c8', minRow: 1, maxRow: 5, minCol: 2, maxCol: 2, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
        ],
      ),
    );
    // Level 56 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 56,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 4), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c2', point: const GridPoint(4, 0), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(1, 3), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c4', point: const GridPoint(0, 1), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c5', point: const GridPoint(1, 0), targetArea: 9, shapeType: PatchShapeType.square, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c2', minRow: 4, maxRow: 4, minCol: 0, maxCol: 3, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 3, minCol: 3, maxCol: 3, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 0, minCol: 0, maxCol: 2, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 3, minCol: 0, maxCol: 2, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 57 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 57,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 5), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(0, 3), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c3', point: const GridPoint(1, 1), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(4, 2), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c5', point: const GridPoint(1, 3), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(2, 5), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c7', point: const GridPoint(3, 5), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 5, maxRow: 5, minCol: 0, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 0, minCol: 0, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 2, minCol: 0, maxCol: 2, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 3, maxRow: 4, minCol: 0, maxCol: 2, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 1, minCol: 3, maxCol: 5, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 2, maxRow: 2, minCol: 3, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c7', minRow: 3, maxRow: 4, minCol: 3, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 58 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 58,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 0), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c2', point: const GridPoint(4, 5), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c3', point: const GridPoint(3, 1), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c4', point: const GridPoint(3, 2), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c5', point: const GridPoint(1, 4), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c6', point: const GridPoint(5, 0), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c7', point: const GridPoint(5, 4), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c8', point: const GridPoint(3, 3), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c9', point: const GridPoint(4, 3), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 5, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 1, minCol: 3, maxCol: 4, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c6', minRow: 5, maxRow: 5, minCol: 0, maxCol: 2, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c7', minRow: 5, maxRow: 5, minCol: 3, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c8', minRow: 2, maxRow: 3, minCol: 3, maxCol: 4, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c9', minRow: 4, maxRow: 4, minCol: 3, maxCol: 4, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 59 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 59,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 4), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c2', point: const GridPoint(0, 5), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c3', point: const GridPoint(1, 0), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c4', point: const GridPoint(5, 3), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(5, 0), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c6', point: const GridPoint(5, 2), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c7', point: const GridPoint(2, 0), targetArea: null, shapeType: PatchShapeType.square, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c8', point: const GridPoint(2, 1), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 3, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 0, minCol: 0, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 1, minCol: 0, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c4', minRow: 3, maxRow: 5, minCol: 3, maxCol: 3, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 5, minCol: 0, maxCol: 1, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c6', minRow: 3, maxRow: 5, minCol: 2, maxCol: 2, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c7', minRow: 2, maxRow: 2, minCol: 0, maxCol: 0, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c8', minRow: 2, maxRow: 2, minCol: 1, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
      ),
    );
    // Level 60 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 60,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 1), targetArea: 7, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c2', point: const GridPoint(6, 6), targetArea: 7, shapeType: PatchShapeType.any, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c3', point: const GridPoint(1, 3), targetArea: 7, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c4', point: const GridPoint(2, 6), targetArea: 7, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c5', point: const GridPoint(4, 2), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(4, 4), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c7', point: const GridPoint(0, 0), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c8', point: const GridPoint(0, 5), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c9', point: const GridPoint(3, 1), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c10', point: const GridPoint(3, 6), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 5, maxRow: 5, minCol: 0, maxCol: 6, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c2', minRow: 6, maxRow: 6, minCol: 0, maxCol: 6, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 1, minCol: 0, maxCol: 6, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 2, minCol: 0, maxCol: 6, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c5', minRow: 4, maxRow: 4, minCol: 0, maxCol: 3, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 4, maxRow: 4, minCol: 4, maxCol: 6, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 0, minCol: 0, maxCol: 3, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c8', minRow: 0, maxRow: 0, minCol: 4, maxCol: 6, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c9', minRow: 3, maxRow: 3, minCol: 0, maxCol: 3, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c10', minRow: 3, maxRow: 3, minCol: 4, maxCol: 6, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
        ],
      ),
    );
    // Level 61 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 61,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 4), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c2', point: const GridPoint(4, 5), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c3', point: const GridPoint(0, 0), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c4', point: const GridPoint(0, 3), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c5', point: const GridPoint(1, 5), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c6', point: const GridPoint(0, 1), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c7', point: const GridPoint(1, 2), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c8', point: const GridPoint(4, 2), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c9', point: const GridPoint(5, 0), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 5, maxRow: 5, minCol: 3, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c2', minRow: 3, maxRow: 4, minCol: 3, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 3, minCol: 0, maxCol: 0, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 0, minCol: 3, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 2, minCol: 3, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 0, minCol: 1, maxCol: 2, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 3, minCol: 1, maxCol: 2, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c8', minRow: 4, maxRow: 4, minCol: 0, maxCol: 2, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c9', minRow: 5, maxRow: 5, minCol: 0, maxCol: 2, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
      ),
    );
    // Level 62 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 62,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(2, 2), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c2', point: const GridPoint(4, 0), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(3, 1), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c4', point: const GridPoint(4, 4), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c5', point: const GridPoint(0, 3), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c6', point: const GridPoint(3, 3), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c7', point: const GridPoint(2, 4), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c4', minRow: 4, maxRow: 4, minCol: 3, maxCol: 4, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 0, minCol: 3, maxCol: 4, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 3, minCol: 3, maxCol: 3, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 3, minCol: 4, maxCol: 4, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
      ),
    );
    // Level 63 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 63,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(3, 4), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c2', point: const GridPoint(5, 5), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c3', point: const GridPoint(2, 0), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c4', point: const GridPoint(1, 2), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c5', point: const GridPoint(4, 1), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(5, 2), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(0, 3), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c8', point: const GridPoint(0, 5), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 1, maxRow: 3, minCol: 4, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c2', minRow: 4, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 3, minCol: 0, maxCol: 1, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c4', minRow: 1, maxRow: 3, minCol: 2, maxCol: 3, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c5', minRow: 4, maxRow: 5, minCol: 0, maxCol: 1, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 4, maxRow: 5, minCol: 2, maxCol: 4, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 0, minCol: 0, maxCol: 3, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c8', minRow: 0, maxRow: 0, minCol: 4, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
      ),
    );
    // Level 64 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 64,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(2, 3), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c2', point: const GridPoint(3, 5), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(4, 1), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(4, 4), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(0, 0), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c6', point: const GridPoint(0, 3), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c7', point: const GridPoint(5, 0), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c8', point: const GridPoint(5, 4), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c9', point: const GridPoint(1, 0), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c10', point: const GridPoint(2, 0), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 1, maxRow: 2, minCol: 3, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c2', minRow: 3, maxRow: 4, minCol: 5, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 3, maxRow: 4, minCol: 0, maxCol: 2, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 3, maxRow: 4, minCol: 3, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 0, minCol: 0, maxCol: 2, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 0, minCol: 3, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c7', minRow: 5, maxRow: 5, minCol: 0, maxCol: 2, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c8', minRow: 5, maxRow: 5, minCol: 3, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c9', minRow: 1, maxRow: 1, minCol: 0, maxCol: 2, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c10', minRow: 2, maxRow: 2, minCol: 0, maxCol: 2, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
      ),
    );
    // Level 65 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 65,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(2, 0), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c2', point: const GridPoint(4, 5), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(0, 4), targetArea: 8, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(1, 5), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c5', point: const GridPoint(2, 4), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c6', point: const GridPoint(3, 5), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c7', point: const GridPoint(4, 2), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c8', point: const GridPoint(5, 4), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c2', minRow: 4, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 1, minCol: 1, maxCol: 4, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 1, minCol: 5, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c5', minRow: 2, maxRow: 2, minCol: 1, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c6', minRow: 3, maxRow: 3, minCol: 1, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c7', minRow: 4, maxRow: 5, minCol: 1, maxCol: 3, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c8', minRow: 4, maxRow: 5, minCol: 4, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 66 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 66,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 2), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(5, 4), targetArea: 7, shapeType: PatchShapeType.any, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(6, 3), targetArea: 7, shapeType: PatchShapeType.any, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c4', point: const GridPoint(3, 0), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c5', point: const GridPoint(1, 1), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c6', point: const GridPoint(0, 5), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c7', point: const GridPoint(3, 6), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c8', point: const GridPoint(1, 3), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c9', point: const GridPoint(3, 3), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 5, maxRow: 5, minCol: 0, maxCol: 6, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 6, maxRow: 6, minCol: 0, maxCol: 6, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 4, minCol: 5, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 4, minCol: 6, maxCol: 6, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c8', minRow: 0, maxRow: 2, minCol: 3, maxCol: 4, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c9', minRow: 3, maxRow: 4, minCol: 3, maxCol: 4, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
        ],
      ),
    );
    // Level 67 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 67,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 3), targetArea: 8, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c2', point: const GridPoint(5, 5), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(5, 0), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c4', point: const GridPoint(3, 5), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(1, 0), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c6', point: const GridPoint(1, 1), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c7', point: const GridPoint(3, 4), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c8', point: const GridPoint(4, 4), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 1, minCol: 2, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c2', minRow: 5, maxRow: 5, minCol: 2, maxCol: 5, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 5, maxRow: 5, minCol: 0, maxCol: 1, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 4, minCol: 5, maxCol: 5, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c7', minRow: 2, maxRow: 3, minCol: 2, maxCol: 4, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c8', minRow: 4, maxRow: 4, minCol: 2, maxCol: 4, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 68 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 68,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 3), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c2', point: const GridPoint(1, 1), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(4, 0), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(2, 3), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c5', point: const GridPoint(2, 4), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c6', point: const GridPoint(4, 1), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c7', point: const GridPoint(2, 2), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 0, minCol: 0, maxCol: 4, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c2', minRow: 1, maxRow: 1, minCol: 0, maxCol: 4, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 2, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 4, minCol: 3, maxCol: 3, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c5', minRow: 2, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c6', minRow: 2, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c7', minRow: 2, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
      ),
    );
    // Level 69 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 69,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 1), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(4, 5), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(1, 5), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c4', point: const GridPoint(2, 5), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c5', point: const GridPoint(2, 1), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c6', point: const GridPoint(3, 3), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(0, 0), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c8', point: const GridPoint(0, 1), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 5, maxRow: 5, minCol: 0, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 4, maxRow: 4, minCol: 0, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 1, minCol: 0, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 3, minCol: 5, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c5', minRow: 2, maxRow: 2, minCol: 0, maxCol: 4, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c6', minRow: 3, maxRow: 3, minCol: 0, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 0, minCol: 0, maxCol: 0, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c8', minRow: 0, maxRow: 0, minCol: 1, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
      ),
    );
    // Level 70 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 70,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(2, 3), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(4, 0), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(5, 3), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c4', point: const GridPoint(0, 0), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c5', point: const GridPoint(3, 1), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c6', point: const GridPoint(0, 2), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c7', point: const GridPoint(1, 5), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c8', point: const GridPoint(3, 4), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c9', point: const GridPoint(4, 5), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 2, maxRow: 2, minCol: 0, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 3, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 5, maxRow: 5, minCol: 1, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 1, minCol: 0, maxCol: 1, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 1, minCol: 2, maxCol: 4, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 1, minCol: 5, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c8', minRow: 3, maxRow: 3, minCol: 2, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c9', minRow: 4, maxRow: 4, minCol: 2, maxCol: 5, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 71 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 71,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(1, 5), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c2', point: const GridPoint(2, 4), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(5, 3), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c4', point: const GridPoint(1, 4), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c5', point: const GridPoint(3, 4), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c6', point: const GridPoint(4, 3), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(0, 0), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c8', point: const GridPoint(1, 0), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c2', minRow: 2, maxRow: 2, minCol: 0, maxCol: 4, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 5, maxRow: 5, minCol: 0, maxCol: 4, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 1, minCol: 4, maxCol: 4, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 3, minCol: 0, maxCol: 4, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c6', minRow: 4, maxRow: 4, minCol: 0, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 0, minCol: 0, maxCol: 3, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c8', minRow: 1, maxRow: 1, minCol: 0, maxCol: 3, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
        ],
      ),
    );
    // Level 72 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 72,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 6), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c2', point: const GridPoint(1, 5), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c3', point: const GridPoint(3, 3), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c4', point: const GridPoint(0, 2), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c5', point: const GridPoint(5, 0), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(6, 2), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(4, 4), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c8', point: const GridPoint(4, 5), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c9', point: const GridPoint(1, 1), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c10', point: const GridPoint(3, 1), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c11', point: const GridPoint(5, 4), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c12', point: const GridPoint(6, 4), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 0, minCol: 3, maxCol: 6, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c2', minRow: 1, maxRow: 1, minCol: 3, maxCol: 6, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c3', minRow: 2, maxRow: 6, minCol: 3, maxCol: 3, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 0, minCol: 0, maxCol: 2, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c5', minRow: 4, maxRow: 5, minCol: 0, maxCol: 2, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 6, maxRow: 6, minCol: 0, maxCol: 2, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 2, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c8', minRow: 2, maxRow: 4, minCol: 5, maxCol: 6, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c9', minRow: 1, maxRow: 1, minCol: 0, maxCol: 2, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c10', minRow: 2, maxRow: 3, minCol: 0, maxCol: 2, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c11', minRow: 5, maxRow: 5, minCol: 4, maxCol: 6, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c12', minRow: 6, maxRow: 6, minCol: 4, maxCol: 6, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
      ),
    );
    // Level 73 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 73,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 0), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c2', point: const GridPoint(0, 5), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(5, 5), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c4', point: const GridPoint(3, 1), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(5, 0), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c6', point: const GridPoint(1, 2), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c7', point: const GridPoint(0, 3), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c8', point: const GridPoint(3, 2), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c9', point: const GridPoint(5, 3), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 0, minCol: 0, maxCol: 1, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 2, minCol: 4, maxCol: 5, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 3, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c4', minRow: 1, maxRow: 3, minCol: 0, maxCol: 1, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 4, maxRow: 5, minCol: 0, maxCol: 1, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 2, minCol: 2, maxCol: 2, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 2, minCol: 3, maxCol: 3, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c8', minRow: 3, maxRow: 5, minCol: 2, maxCol: 2, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c9', minRow: 3, maxRow: 5, minCol: 3, maxCol: 3, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
        ],
      ),
    );
    // Level 74 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 74,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 1), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c2', point: const GridPoint(2, 4), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c3', point: const GridPoint(4, 0), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c4', point: const GridPoint(3, 4), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c5', point: const GridPoint(1, 1), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c6', point: const GridPoint(1, 2), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 0, minCol: 0, maxCol: 4, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c2', minRow: 1, maxRow: 2, minCol: 3, maxCol: 4, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c3', minRow: 3, maxRow: 4, minCol: 0, maxCol: 2, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c4', minRow: 3, maxRow: 4, minCol: 3, maxCol: 4, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 2, minCol: 0, maxCol: 1, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 2, minCol: 2, maxCol: 2, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 75 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 75,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 2), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c2', point: const GridPoint(0, 4), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c3', point: const GridPoint(5, 0), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c4', point: const GridPoint(0, 1), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c5', point: const GridPoint(3, 3), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(4, 4), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c7', point: const GridPoint(0, 5), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c8', point: const GridPoint(4, 5), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 5, minCol: 2, maxCol: 2, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 1, minCol: 3, maxCol: 4, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 5, minCol: 1, maxCol: 1, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c5', minRow: 2, maxRow: 3, minCol: 3, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 4, maxRow: 5, minCol: 3, maxCol: 4, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 2, minCol: 5, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c8', minRow: 3, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
      ),
    );
    // Level 76 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 76,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 5), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c2', point: const GridPoint(4, 1), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(5, 2), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c4', point: const GridPoint(4, 3), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c5', point: const GridPoint(3, 0), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c6', point: const GridPoint(4, 0), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(0, 3), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c8', point: const GridPoint(1, 2), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c9', point: const GridPoint(0, 4), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c10', point: const GridPoint(5, 4), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c2', minRow: 2, maxRow: 5, minCol: 1, maxCol: 1, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 2, maxRow: 5, minCol: 2, maxCol: 2, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 5, minCol: 3, maxCol: 3, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 3, minCol: 0, maxCol: 0, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c6', minRow: 4, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 0, minCol: 1, maxCol: 3, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c8', minRow: 1, maxRow: 1, minCol: 1, maxCol: 3, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 0, minCol: 4, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c10', minRow: 1, maxRow: 5, minCol: 4, maxCol: 4, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
      ),
    );
    // Level 77 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 77,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 5), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c2', point: const GridPoint(5, 0), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(2, 5), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c4', point: const GridPoint(2, 0), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c5', point: const GridPoint(3, 4), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c6', point: const GridPoint(5, 5), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c7', point: const GridPoint(2, 1), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c8', point: const GridPoint(3, 1), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 0, minCol: 0, maxCol: 5, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c2', minRow: 5, maxRow: 5, minCol: 0, maxCol: 2, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 2, minCol: 3, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c4', minRow: 1, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c5', minRow: 3, maxRow: 4, minCol: 3, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c6', minRow: 5, maxRow: 5, minCol: 3, maxCol: 5, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 2, minCol: 1, maxCol: 2, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c8', minRow: 3, maxRow: 4, minCol: 1, maxCol: 2, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
      ),
    );
    // Level 78 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 78,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 0), targetArea: 7, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c2', point: const GridPoint(4, 6), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(2, 3), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c4', point: const GridPoint(0, 1), targetArea: 7, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(4, 2), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c6', point: const GridPoint(6, 4), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c7', point: const GridPoint(5, 3), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c8', point: const GridPoint(3, 4), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c9', point: const GridPoint(1, 5), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c10', point: const GridPoint(1, 6), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 6, minCol: 0, maxCol: 0, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c2', minRow: 2, maxRow: 6, minCol: 6, maxCol: 6, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 2, maxRow: 2, minCol: 3, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 6, minCol: 1, maxCol: 1, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 6, minCol: 2, maxCol: 2, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c6', minRow: 6, maxRow: 6, minCol: 3, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c7', minRow: 3, maxRow: 5, minCol: 3, maxCol: 3, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c8', minRow: 3, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 1, minCol: 3, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c10', minRow: 0, maxRow: 1, minCol: 6, maxCol: 6, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
        ],
      ),
    );
    // Level 79 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 79,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 0), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(5, 4), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c3', point: const GridPoint(1, 0), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c4', point: const GridPoint(2, 0), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c5', point: const GridPoint(0, 4), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c6', point: const GridPoint(2, 4), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(3, 3), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c8', point: const GridPoint(5, 3), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 4, maxRow: 5, minCol: 0, maxCol: 2, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 4, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 1, minCol: 0, maxCol: 2, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 3, minCol: 0, maxCol: 2, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 0, minCol: 4, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 3, minCol: 4, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 4, minCol: 3, maxCol: 3, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c8', minRow: 5, maxRow: 5, minCol: 3, maxCol: 3, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 80 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 80,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 1), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c2', point: const GridPoint(0, 2), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(3, 3), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c4', point: const GridPoint(1, 0), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c5', point: const GridPoint(3, 1), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(0, 4), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(2, 4), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 0, minCol: 0, maxCol: 1, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 4, minCol: 3, maxCol: 3, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c4', minRow: 1, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 0, minCol: 4, maxCol: 4, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
      ),
    );
    // Level 81 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 81,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 5), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c2', point: const GridPoint(2, 5), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c3', point: const GridPoint(1, 4), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(4, 2), targetArea: 9, shapeType: PatchShapeType.square, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c5', point: const GridPoint(5, 0), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c6', point: const GridPoint(4, 0), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c7', point: const GridPoint(2, 1), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 5, maxRow: 5, minCol: 2, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 5, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 1, minCol: 2, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 4, minCol: 2, maxCol: 4, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c5', minRow: 5, maxRow: 5, minCol: 0, maxCol: 1, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
      ),
    );
    // Level 82 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 82,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 0), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c2', point: const GridPoint(0, 5), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c3', point: const GridPoint(1, 5), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(2, 5), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c5', point: const GridPoint(4, 1), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c6', point: const GridPoint(5, 1), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c7', point: const GridPoint(2, 0), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c8', point: const GridPoint(2, 2), targetArea: 8, shapeType: PatchShapeType.any, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 4, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 0, minCol: 0, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 1, minCol: 0, maxCol: 5, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 3, minCol: 5, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c5', minRow: 4, maxRow: 4, minCol: 1, maxCol: 5, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c6', minRow: 5, maxRow: 5, minCol: 1, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c7', minRow: 2, maxRow: 3, minCol: 0, maxCol: 0, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c8', minRow: 2, maxRow: 3, minCol: 1, maxCol: 4, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
        ],
      ),
    );
    // Level 83 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 83,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 0), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c2', point: const GridPoint(4, 0), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c3', point: const GridPoint(0, 0), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c4', point: const GridPoint(2, 1), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c5', point: const GridPoint(0, 5), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c6', point: const GridPoint(4, 5), targetArea: 8, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c7', point: const GridPoint(3, 2), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c8', point: const GridPoint(1, 3), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 5, maxRow: 5, minCol: 0, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c2', minRow: 4, maxRow: 4, minCol: 0, maxCol: 3, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 3, minCol: 0, maxCol: 0, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 3, minCol: 1, maxCol: 1, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 0, minCol: 4, maxCol: 5, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 4, minCol: 4, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 3, minCol: 2, maxCol: 2, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c8', minRow: 0, maxRow: 3, minCol: 3, maxCol: 3, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 84 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 84,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(2, 3), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c2', point: const GridPoint(2, 2), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c3', point: const GridPoint(1, 4), targetArea: 7, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(6, 5), targetArea: 7, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c5', point: const GridPoint(1, 0), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c6', point: const GridPoint(4, 1), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(6, 1), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c8', point: const GridPoint(5, 3), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c9', point: const GridPoint(3, 6), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c10', point: const GridPoint(6, 6), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 4, minCol: 3, maxCol: 3, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 6, minCol: 4, maxCol: 4, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 6, minCol: 5, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 5, maxRow: 6, minCol: 0, maxCol: 2, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c8', minRow: 5, maxRow: 6, minCol: 3, maxCol: 3, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 4, minCol: 6, maxCol: 6, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c10', minRow: 5, maxRow: 6, minCol: 6, maxCol: 6, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 85 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 85,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 5), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c2', point: const GridPoint(2, 0), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(5, 1), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(5, 3), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c5', point: const GridPoint(3, 5), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c6', point: const GridPoint(4, 2), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c7', point: const GridPoint(1, 3), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c8', point: const GridPoint(4, 4), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 0, minCol: 0, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c2', minRow: 1, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 5, minCol: 1, maxCol: 1, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 5, maxRow: 5, minCol: 2, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 4, minCol: 5, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 3, minCol: 3, maxCol: 4, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c8', minRow: 4, maxRow: 4, minCol: 3, maxCol: 4, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
      ),
    );
    // Level 86 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 86,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 4), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c2', point: const GridPoint(2, 0), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c3', point: const GridPoint(0, 1), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(2, 2), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c5', point: const GridPoint(4, 3), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 4, minCol: 3, maxCol: 3, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
      ),
    );
    // Level 87 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 87,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 1), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c2', point: const GridPoint(4, 0), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c3', point: const GridPoint(1, 4), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c4', point: const GridPoint(4, 3), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c5', point: const GridPoint(5, 4), targetArea: 8, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c6', point: const GridPoint(4, 2), targetArea: 8, shapeType: PatchShapeType.any, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(5, 1), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 0, minCol: 0, maxCol: 5, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c2', minRow: 1, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c3', minRow: 1, maxRow: 1, minCol: 3, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 5, minCol: 3, maxCol: 3, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c5', minRow: 2, maxRow: 5, minCol: 4, maxCol: 5, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c6', minRow: 1, maxRow: 4, minCol: 1, maxCol: 2, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 5, maxRow: 5, minCol: 1, maxCol: 2, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 88 (HARD)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 88,
        difficulty: ZipDifficulty.hard,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(5, 5), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c2', point: const GridPoint(2, 2), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(3, 1), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c4', point: const GridPoint(4, 1), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c5', point: const GridPoint(5, 3), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c6', point: const GridPoint(2, 4), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c7', point: const GridPoint(0, 2), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c8', point: const GridPoint(1, 0), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c9', point: const GridPoint(0, 4), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c10', point: const GridPoint(1, 3), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 2, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c2', minRow: 2, maxRow: 5, minCol: 2, maxCol: 2, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 2, maxRow: 3, minCol: 0, maxCol: 1, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c4', minRow: 4, maxRow: 5, minCol: 0, maxCol: 1, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c5', minRow: 2, maxRow: 5, minCol: 3, maxCol: 3, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c6', minRow: 2, maxRow: 5, minCol: 4, maxCol: 4, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 0, minCol: 0, maxCol: 2, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c8', minRow: 1, maxRow: 1, minCol: 0, maxCol: 2, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 0, minCol: 3, maxCol: 5, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c10', minRow: 1, maxRow: 1, minCol: 3, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
      ),
    );
    // Level 89 (MEDIUM)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 89,
        difficulty: ZipDifficulty.medium,
        rows: 6,
        cols: 6,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(2, 5), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c2', point: const GridPoint(1, 0), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c3', point: const GridPoint(5, 0), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c4', point: const GridPoint(3, 4), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c5', point: const GridPoint(5, 3), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c6', point: const GridPoint(2, 1), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c7', point: const GridPoint(3, 1), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c8', point: const GridPoint(0, 3), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c9', point: const GridPoint(0, 4), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 1, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c2', minRow: 1, maxRow: 1, minCol: 0, maxCol: 4, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c3', minRow: 2, maxRow: 5, minCol: 0, maxCol: 0, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 3, minCol: 3, maxCol: 4, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c5', minRow: 4, maxRow: 5, minCol: 3, maxCol: 4, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c6', minRow: 2, maxRow: 2, minCol: 1, maxCol: 2, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c7', minRow: 3, maxRow: 5, minCol: 1, maxCol: 2, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c8', minRow: 0, maxRow: 0, minCol: 0, maxCol: 3, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 0, minCol: 4, maxCol: 5, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 90 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 90,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(2, 0), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c2', point: const GridPoint(5, 2), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(6, 5), targetArea: 8, shapeType: PatchShapeType.wide, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c4', point: const GridPoint(1, 2), targetArea: 8, shapeType: PatchShapeType.any, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c5', point: const GridPoint(4, 1), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c6', point: const GridPoint(0, 3), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c7', point: const GridPoint(1, 3), targetArea: 8, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c8', point: const GridPoint(2, 5), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c9', point: const GridPoint(3, 6), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c2', minRow: 5, maxRow: 6, minCol: 0, maxCol: 2, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 5, maxRow: 6, minCol: 3, maxCol: 6, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 3, minCol: 1, maxCol: 2, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c5', minRow: 4, maxRow: 4, minCol: 1, maxCol: 2, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 0, minCol: 3, maxCol: 4, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 4, minCol: 3, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c8', minRow: 0, maxRow: 4, minCol: 5, maxCol: 5, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 4, minCol: 6, maxCol: 6, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
        ],
      ),
    );
    // Level 91 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 91,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(3, 2), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c2', point: const GridPoint(4, 3), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c3', point: const GridPoint(1, 4), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c4', point: const GridPoint(4, 0), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(3, 1), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 3, maxCol: 3, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
        ],
      ),
    );
    // Level 92 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 92,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(3, 4), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c2', point: const GridPoint(4, 0), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c3', point: const GridPoint(2, 2), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c4', point: const GridPoint(1, 1), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c5', point: const GridPoint(2, 1), targetArea: 2, shapeType: PatchShapeType.wide, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c6', point: const GridPoint(2, 3), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c7', point: const GridPoint(0, 4), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 3, maxRow: 3, minCol: 0, maxCol: 4, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c2', minRow: 4, maxRow: 4, minCol: 0, maxCol: 4, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 2, minCol: 2, maxCol: 2, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 1, minCol: 0, maxCol: 1, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c5', minRow: 2, maxRow: 2, minCol: 0, maxCol: 1, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 2, minCol: 3, maxCol: 3, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 2, minCol: 4, maxCol: 4, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 93 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 93,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(2, 0), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c2', point: const GridPoint(4, 3), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c3', point: const GridPoint(4, 4), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c4', point: const GridPoint(1, 1), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c5', point: const GridPoint(4, 2), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 3, maxCol: 3, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
        ],
      ),
    );
    // Level 94 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 94,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(3, 3), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c2', point: const GridPoint(4, 3), targetArea: 5, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c3', point: const GridPoint(0, 0), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c4', point: const GridPoint(1, 1), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c5', point: const GridPoint(2, 2), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c6', point: const GridPoint(2, 3), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 3, maxRow: 3, minCol: 0, maxCol: 4, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c2', minRow: 4, maxRow: 4, minCol: 0, maxCol: 4, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 0, minCol: 0, maxCol: 4, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c4', minRow: 1, maxRow: 1, minCol: 0, maxCol: 4, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c5', minRow: 2, maxRow: 2, minCol: 0, maxCol: 2, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c6', minRow: 2, maxRow: 2, minCol: 3, maxCol: 4, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
      ),
    );
    // Level 95 (EASY)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 95,
        difficulty: ZipDifficulty.easy,
        rows: 5,
        cols: 5,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(0, 4), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c2', point: const GridPoint(3, 1), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c3', point: const GridPoint(0, 2), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c4', point: const GridPoint(0, 0), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c5', point: const GridPoint(1, 0), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(0, 3), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(2, 3), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 4, minCol: 4, maxCol: 4, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 4, minCol: 1, maxCol: 1, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 4, minCol: 2, maxCol: 2, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 0, minCol: 0, maxCol: 0, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c5', minRow: 1, maxRow: 4, minCol: 0, maxCol: 0, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 0, maxRow: 0, minCol: 3, maxCol: 3, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 1, maxRow: 4, minCol: 3, maxCol: 3, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
      ),
    );
    // Level 96 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 96,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 0), targetArea: 7, shapeType: PatchShapeType.wide, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c2', point: const GridPoint(3, 0), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c3', point: const GridPoint(5, 4), targetArea: 7, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(6, 3), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c5', point: const GridPoint(0, 3), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c6', point: const GridPoint(3, 3), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(3, 6), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c8', point: const GridPoint(0, 5), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c9', point: const GridPoint(2, 5), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 4, maxRow: 4, minCol: 0, maxCol: 6, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 3, minCol: 0, maxCol: 0, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c3', minRow: 5, maxRow: 5, minCol: 0, maxCol: 6, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 6, maxRow: 6, minCol: 0, maxCol: 6, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 1, minCol: 1, maxCol: 3, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c6', minRow: 2, maxRow: 3, minCol: 1, maxCol: 3, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 3, minCol: 6, maxCol: 6, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c8', minRow: 0, maxRow: 1, minCol: 4, maxCol: 5, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c9', minRow: 2, maxRow: 3, minCol: 4, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
        ],
      ),
    );
    // Level 97 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 97,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(3, 0), targetArea: null, shapeType: PatchShapeType.wide, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c2', point: const GridPoint(4, 6), targetArea: 7, shapeType: PatchShapeType.wide, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c3', point: const GridPoint(6, 6), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c4', point: const GridPoint(2, 2), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c5', point: const GridPoint(6, 0), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c6', point: const GridPoint(6, 1), targetArea: 8, shapeType: PatchShapeType.any, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c7', point: const GridPoint(1, 4), targetArea: 6, shapeType: PatchShapeType.wide, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c8', point: const GridPoint(2, 5), targetArea: 3, shapeType: PatchShapeType.wide, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c9', point: const GridPoint(0, 1), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c10', point: const GridPoint(0, 2), targetArea: 4, shapeType: PatchShapeType.square, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 3, maxRow: 3, minCol: 0, maxCol: 6, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c2', minRow: 4, maxRow: 4, minCol: 0, maxCol: 6, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c3', minRow: 5, maxRow: 6, minCol: 5, maxCol: 6, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c4', minRow: 2, maxRow: 2, minCol: 0, maxCol: 3, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c5', minRow: 5, maxRow: 6, minCol: 0, maxCol: 0, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c6', minRow: 5, maxRow: 6, minCol: 1, maxCol: 4, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 1, minCol: 4, maxCol: 6, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c8', minRow: 2, maxRow: 2, minCol: 4, maxCol: 6, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 1, minCol: 0, maxCol: 1, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c10', minRow: 0, maxRow: 1, minCol: 2, maxCol: 3, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
        ],
      ),
    );
    // Level 98 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 98,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(3, 0), targetArea: 7, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c2', point: const GridPoint(6, 3), targetArea: 4, shapeType: PatchShapeType.wide, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c3', point: const GridPoint(2, 1), targetArea: 7, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(4, 2), targetArea: 7, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c5', point: const GridPoint(1, 6), targetArea: 8, shapeType: PatchShapeType.any, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c6', point: const GridPoint(2, 5), targetArea: 4, shapeType: PatchShapeType.any, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c7', point: const GridPoint(3, 6), targetArea: 3, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c8', point: const GridPoint(5, 3), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c9', point: const GridPoint(5, 5), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 6, minCol: 0, maxCol: 0, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c2', minRow: 6, maxRow: 6, minCol: 3, maxCol: 6, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 6, minCol: 1, maxCol: 1, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 0, maxRow: 6, minCol: 2, maxCol: 2, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 1, minCol: 3, maxCol: 6, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c6', minRow: 2, maxRow: 2, minCol: 3, maxCol: 6, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c7', minRow: 3, maxRow: 5, minCol: 6, maxCol: 6, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c8', minRow: 3, maxRow: 5, minCol: 3, maxCol: 4, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c9', minRow: 3, maxRow: 5, minCol: 5, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
      ),
    );
    // Level 99 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 99,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(6, 2), targetArea: 7, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c2', point: const GridPoint(2, 3), targetArea: 7, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          PatchClue(id: 'c3', point: const GridPoint(1, 6), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c4', point: const GridPoint(5, 6), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c5', point: const GridPoint(3, 4), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c6', point: const GridPoint(4, 4), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(0, 5), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c8', point: const GridPoint(5, 5), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c9', point: const GridPoint(1, 0), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c10', point: const GridPoint(3, 0), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c11', point: const GridPoint(2, 1), targetArea: 3, shapeType: PatchShapeType.tall, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c12', point: const GridPoint(3, 1), targetArea: 4, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 6, minCol: 2, maxCol: 2, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 6, minCol: 3, maxCol: 3, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 4, minCol: 6, maxCol: 6, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c4', minRow: 5, maxRow: 6, minCol: 6, maxCol: 6, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 3, minCol: 4, maxCol: 4, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c6', minRow: 4, maxRow: 6, minCol: 4, maxCol: 4, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 0, minCol: 5, maxCol: 5, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c8', minRow: 1, maxRow: 6, minCol: 5, maxCol: 5, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 1, minCol: 0, maxCol: 0, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c10', minRow: 2, maxRow: 6, minCol: 0, maxCol: 0, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c11', minRow: 0, maxRow: 2, minCol: 1, maxCol: 1, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c12', minRow: 3, maxRow: 6, minCol: 1, maxCol: 1, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
        ],
      ),
    );
    // Level 100 (EXPERT)
    list.add(
      const PatchesLevelDefinition(
        levelNumber: 100,
        difficulty: ZipDifficulty.expert,
        rows: 7,
        cols: 7,
        clues: [
          PatchClue(id: 'c1', point: const GridPoint(4, 1), targetArea: 7, shapeType: PatchShapeType.tall, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          PatchClue(id: 'c2', point: const GridPoint(6, 2), targetArea: 7, shapeType: PatchShapeType.any, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          PatchClue(id: 'c3', point: const GridPoint(0, 6), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          PatchClue(id: 'c4', point: const GridPoint(5, 6), targetArea: 6, shapeType: PatchShapeType.tall, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c5', point: const GridPoint(2, 3), targetArea: 5, shapeType: PatchShapeType.any, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          PatchClue(id: 'c6', point: const GridPoint(6, 3), targetArea: 2, shapeType: PatchShapeType.any, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c7', point: const GridPoint(1, 0), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          PatchClue(id: 'c8', point: const GridPoint(2, 0), targetArea: 5, shapeType: PatchShapeType.tall, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          PatchClue(id: 'c9', point: const GridPoint(2, 4), targetArea: 6, shapeType: PatchShapeType.any, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          PatchClue(id: 'c10', point: const GridPoint(6, 4), targetArea: 1, shapeType: PatchShapeType.square, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          PatchClue(id: 'c11', point: const GridPoint(1, 5), targetArea: 2, shapeType: PatchShapeType.tall, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          PatchClue(id: 'c12', point: const GridPoint(5, 5), targetArea: null, shapeType: PatchShapeType.tall, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
        solutionPatches: [
          DrawnPatch(clueId: 'c1', minRow: 0, maxRow: 6, minCol: 1, maxCol: 1, color: const Color(0xFF2E7D32), tintColor: const Color(0xFFE8F5E9)),
          DrawnPatch(clueId: 'c2', minRow: 0, maxRow: 6, minCol: 2, maxCol: 2, color: const Color(0xFF00838F), tintColor: const Color(0xFFE0F7FA)),
          DrawnPatch(clueId: 'c3', minRow: 0, maxRow: 0, minCol: 6, maxCol: 6, color: const Color(0xFFB07A10), tintColor: const Color(0xFFFFF8E1)),
          DrawnPatch(clueId: 'c4', minRow: 1, maxRow: 6, minCol: 6, maxCol: 6, color: const Color(0xFF4527A0), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c5', minRow: 0, maxRow: 4, minCol: 3, maxCol: 3, color: const Color(0xFF6A1B9A), tintColor: const Color(0xFFEDE7F6)),
          DrawnPatch(clueId: 'c6', minRow: 5, maxRow: 6, minCol: 3, maxCol: 3, color: const Color(0xFFC2185B), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c7', minRow: 0, maxRow: 1, minCol: 0, maxCol: 0, color: const Color(0xFF558B2F), tintColor: const Color(0xFFF1F8E9)),
          DrawnPatch(clueId: 'c8', minRow: 2, maxRow: 6, minCol: 0, maxCol: 0, color: const Color(0xFFD81B60), tintColor: const Color(0xFFFCE4EC)),
          DrawnPatch(clueId: 'c9', minRow: 0, maxRow: 5, minCol: 4, maxCol: 4, color: const Color(0xFF0288D1), tintColor: const Color(0xFFE1F5FE)),
          DrawnPatch(clueId: 'c10', minRow: 6, maxRow: 6, minCol: 4, maxCol: 4, color: const Color(0xFFD32F2F), tintColor: const Color(0xFFFFEBEE)),
          DrawnPatch(clueId: 'c11', minRow: 0, maxRow: 1, minCol: 5, maxCol: 5, color: const Color(0xFFEF6C00), tintColor: const Color(0xFFFFF3E0)),
          DrawnPatch(clueId: 'c12', minRow: 2, maxRow: 6, minCol: 5, maxCol: 5, color: const Color(0xFF00695C), tintColor: const Color(0xFFE0F2F1)),
        ],
      ),
    );
    return list;
  }
}
