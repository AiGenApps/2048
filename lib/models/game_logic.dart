import 'dart:math';

class GameLogic {
  List<List<Tile>> board =
      List.generate(4, (_) => List.generate(4, (_) => Tile(value: 0)));
  int score = 0;

  void addNewTile() {
    List<List<int>> emptyTiles = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (board[i][j].value == 0) {
          emptyTiles.add([i, j]);
        }
      }
    }
    if (emptyTiles.isNotEmpty) {
      final random = Random();
      final newTile = emptyTiles[random.nextInt(emptyTiles.length)];
      board[newTile[0]][newTile[1]] = Tile(
        value: random.nextInt(10) == 0 ? 4 : 2,
        row: newTile[0],
        col: newTile[1],
      );
    }
  }

  void moveLeft() {
    bool moved = false;
    for (int i = 0; i < 4; i++) {
      List<Tile> row = board[i].where((tile) => tile.value != 0).toList();
      for (int j = 0; j < row.length - 1; j++) {
        if (row[j].value == row[j + 1].value) {
          row[j].value *= 2;
          row.removeAt(j + 1);
          moved = true;
          score += row[j].value;
        }
      }
      while (row.length < 4) {
        row.add(Tile(value: 0));
      }
      for (int j = 0; j < 4; j++) {
        row[j].row = i;
        row[j].col = j;
      }
      board[i] = row;
    }
    if (moved) {
      addNewTile();
    }
  }

  // 实现 moveRight, moveUp, moveDown 方法...
}

class Tile {
  int value;
  int row;
  int col;
  bool isNew;

  Tile({required this.value, this.row = 0, this.col = 0, this.isNew = false});
}
