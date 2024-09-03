import 'dart:math';
import 'package:flutter/foundation.dart';
import 'tile.dart';

class GameLogic {
  List<List<int>> board = List.generate(4, (_) => List.filled(4, 0));
  int score = 0;
  int steps = 0;
  Random random = Random();
  List<Tile> _tiles = [];
  Map<Tile, List<int>> _oldPositions = {};

  void addNewTile() {
    List<List<int>> emptyPositions = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (board[i][j] == 0) {
          emptyPositions.add([i, j]);
        }
      }
    }
    if (emptyPositions.isNotEmpty) {
      List<int> newPosition =
          emptyPositions[random.nextInt(emptyPositions.length)];
      int value = random.nextInt(10) < 9 ? 2 : 4;
      board[newPosition[0]][newPosition[1]] = value;
      _tiles.add(Tile(value, newPosition[0], newPosition[1], isNew: true));
    }
  }

  void _updateOldPositions() {
    _oldPositions.clear();
    for (var tile in _tiles) {
      _oldPositions[tile] = [tile.row, tile.col];
    }
  }

  List<int> getOldPosition(Tile tile) {
    return _oldPositions[tile] ?? [tile.row, tile.col];
  }

  void moveLeft() {
    _updateOldPositions();
    for (var tile in _tiles) {
      tile.isNew = false;
    }
    bool changed = false;
    for (int i = 0; i < 4; i++) {
      List<int> row = board[i].where((tile) => tile != 0).toList();
      for (int j = 0; j < row.length - 1; j++) {
        if (row[j] == row[j + 1]) {
          row[j] *= 2;
          score += row[j]; // 加上合并后的数字作为得分
          row.removeAt(j + 1);
          changed = true;
        }
      }
      row = row + List.filled(4 - row.length, 0);
      if (!listEquals(board[i], row)) changed = true;
      board[i] = row;
    }
    if (changed) steps++;
  }

  void moveRight() {
    _updateOldPositions();
    board = board.map((row) => row.reversed.toList()).toList();
    moveLeft();
    board = board.map((row) => row.reversed.toList()).toList();
  }

  void moveUp() {
    _updateOldPositions();
    board = List.generate(4, (j) => List.generate(4, (i) => board[i][j]));
    moveLeft();
    board = List.generate(4, (i) => List.generate(4, (j) => board[j][i]));
  }

  void moveDown() {
    _updateOldPositions();
    board = List.generate(4, (j) => List.generate(4, (i) => board[3 - i][j]));
    moveLeft();
    board = List.generate(4, (i) => List.generate(4, (j) => board[j][3 - i]));
  }

  bool isGameOver() {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (board[i][j] == 0) return false;
        if (j < 3 && board[i][j] == board[i][j + 1]) return false;
        if (i < 3 && board[i][j] == board[i + 1][j]) return false;
      }
    }
    return true;
  }

  List<Tile> get tiles {
    List<Tile> newTiles = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (board[i][j] != 0) {
          // 检查是否已存在相同位置的 Tile
          Tile? existingTile = _tiles.firstWhere(
            (t) => t.row == i && t.col == j,
            orElse: () => Tile(0, -1, -1),
          );

          if (existingTile.row != -1) {
            existingTile.value = board[i][j];
            newTiles.add(existingTile);
          } else {
            newTiles.add(Tile(board[i][j], i, j));
          }
        }
      }
    }
    _tiles = newTiles;
    return _tiles;
  }
}
