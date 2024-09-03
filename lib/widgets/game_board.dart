import 'package:flutter/material.dart';
import '../models/game_logic.dart';
import '../utils/color_schemes.dart';
import 'tile.dart';

class GameBoard extends StatefulWidget {
  final GameLogic gameLogic;
  final CustomColorScheme colorScheme;

  const GameBoard({
    Key? key,
    required this.gameLogic,
    required this.colorScheme,
  }) : super(key: key);

  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _move(void Function() moveFunction) {
    setState(() {
      moveFunction();
      _controller.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          _move(widget.gameLogic.moveRight);
        } else if (details.primaryVelocity! < 0) {
          _move(widget.gameLogic.moveLeft);
        }
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          _move(widget.gameLogic.moveDown);
        } else if (details.primaryVelocity! < 0) {
          _move(widget.gameLogic.moveUp);
        }
      },
      child: Container(
        padding: EdgeInsets.all(10),
        color: getBoardColor(widget.colorScheme),
        child: Stack(
          children: [
            ...List.generate(
                4,
                (i) => List.generate(
                    4,
                    (j) => Positioned(
                          top: i * 75.0,
                          left: j * 75.0,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: getEmptyTileColor(widget.colorScheme),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ))).expand((x) => x),
            ...widget.gameLogic.board
                .expand((row) => row)
                .where((tile) => tile.value != 0)
                .map((tile) => AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return AnimatedPositioned(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          top: tile.row * 75.0,
                          left: tile.col * 75.0,
                          child: TileWidget(
                            value: tile.value,
                            colorScheme: widget.colorScheme,
                            isNew: tile.isNew,
                          ),
                        );
                      },
                    )),
          ],
        ),
      ),
    );
  }
}
