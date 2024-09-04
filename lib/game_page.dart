import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tile.dart';
import 'animated_tile.dart';
import 'game_logic.dart';
import 'background_painter.dart';
import 'color_scheme_menu.dart';

// 将 ColorScheme 重命名为 CustomColorScheme
enum CustomColorScheme { light, dark, colorful }

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.title});

  final String title;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late GameLogic gameLogic;
  late AnimationController _controller;
  bool isGameOverDialogShowing = false;
  final FocusNode _focusNode = FocusNode();
  CustomColorScheme currentColorScheme = CustomColorScheme.light;

  bool isStartMenuOpen = false;
  bool isAnimationEnabled = true;

  void toggleStartMenu() {
    setState(() {
      isStartMenuOpen = !isStartMenuOpen;
    });
  }

  void closeStartMenu() {
    if (isStartMenuOpen) {
      setState(() {
        isStartMenuOpen = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    gameLogic = GameLogic();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    gameLogic.addNewTile();
    gameLogic.addNewTile();
    _controller.forward();

    // 确保焦点节点在初始化时请求焦点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void move(void Function() moveFunction) {
    if (isGameOverDialogShowing) return;

    int oldScore = gameLogic.score;
    List<Tile> oldTiles = List.from(gameLogic.tiles);

    moveFunction();

    List<Tile> newTiles = gameLogic.tiles;
    bool changed =
        oldScore != gameLogic.score || !_tilesEqual(oldTiles, newTiles);

    if (changed) {
      gameLogic.addNewTile();
      if (isAnimationEnabled) {
        _controller.forward(from: 0.0);
      }
      setState(() {});

      if (gameLogic.isGameOver() && !isGameOverDialogShowing) {
        isGameOverDialogShowing = true;
        showGameOverDialog();
      }
    }
  }

  bool _tilesEqual(List<Tile> a, List<Tile> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].value != b[i].value ||
          a[i].row != b[i].row ||
          a[i].col != b[i].col) {
        return false;
      }
    }
    return true;
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('游戏结束'),
          content: Text('你的得分是: ${gameLogic.score}\n总步数: ${gameLogic.steps}'),
          actions: <Widget>[
            TextButton(
              child: const Text('重新开始'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  gameLogic = GameLogic();
                  isGameOverDialogShowing = false;
                  gameLogic.addNewTile();
                  gameLogic.addNewTile();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void changeColorScheme(CustomColorScheme scheme) {
    setState(() {
      currentColorScheme = scheme;
      closeStartMenu();
    });
  }

  void toggleAnimation(bool value) {
    setState(() {
      isAnimationEnabled = value;
    });
  }

  Color get backgroundColor {
    switch (currentColorScheme) {
      case CustomColorScheme.light:
        return const Color(0xFFFAF8EF);
      case CustomColorScheme.dark:
        return const Color(0xFF1E1E1E);
      case CustomColorScheme.colorful:
        return const Color(0xFFFFF8DC);
    }
  }

  Color get boardColor {
    switch (currentColorScheme) {
      case CustomColorScheme.light:
        return const Color(0xFFBBADA0);
      case CustomColorScheme.dark:
        return const Color(0xFF424242);
      case CustomColorScheme.colorful:
        return const Color(0xFFFFD700);
    }
  }

  Color get emptyTileColor {
    switch (currentColorScheme) {
      case CustomColorScheme.light:
        return const Color(0xFFCDC1B4);
      case CustomColorScheme.dark:
        return const Color(0xFF303030);
      case CustomColorScheme.colorful:
        return const Color(0xFFFFA07A);
    }
  }

  Color get shadowColor {
    switch (currentColorScheme) {
      case CustomColorScheme.light:
        return Colors.grey[300]!;
      case CustomColorScheme.dark:
        return Colors.black54;
      case CustomColorScheme.colorful:
        return Colors.orange[200]!;
    }
  }

  Color get highlightColor {
    switch (currentColorScheme) {
      case CustomColorScheme.light:
        return Colors.white;
      case CustomColorScheme.dark:
        return Colors.grey[800]!;
      case CustomColorScheme.colorful:
        return Colors.yellow[100]!;
    }
  }

  BoxDecoration get neumorphicDecoration {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          offset: const Offset(4, 4),
          blurRadius: 15,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: highlightColor,
          offset: const Offset(-4, -4),
          blurRadius: 15,
          spreadRadius: 1,
        ),
      ],
    );
  }

  BoxDecoration get neumorphicBoardDecoration {
    return BoxDecoration(
      color: boardColor,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: boardShadowColor,
          offset: const Offset(4, 4),
          blurRadius: 15,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: boardHighlightColor,
          offset: const Offset(-4, -4),
          blurRadius: 15,
          spreadRadius: 1,
        ),
      ],
    );
  }

  Color get boardShadowColor {
    switch (currentColorScheme) {
      case CustomColorScheme.light:
        return Colors.grey[400]!;
      case CustomColorScheme.dark:
        return Colors.black87;
      case CustomColorScheme.colorful:
        return Colors.orange[300]!;
    }
  }

  Color get boardHighlightColor {
    switch (currentColorScheme) {
      case CustomColorScheme.light:
        return Colors.white;
      case CustomColorScheme.dark:
        return Colors.grey[700]!;
      case CustomColorScheme.colorful:
        return Colors.yellow[200]!;
    }
  }

  Color get taskBarColor {
    switch (currentColorScheme) {
      case CustomColorScheme.light:
        return Colors.grey[300]!;
      case CustomColorScheme.dark:
        return Colors.grey[800]!;
      case CustomColorScheme.colorful:
        return Colors.deepPurple[300]!; // 使用更加青春活泼的颜色
    }
  }

  Color get logoBackgroundColor {
    switch (currentColorScheme) {
      case CustomColorScheme.light:
        return Colors.orange[300]!;
      case CustomColorScheme.dark:
        return Colors.grey[700]!;
      case CustomColorScheme.colorful:
        return Colors.deepPurple[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          _startPosition = details.localPosition;
        },
        onPanUpdate: (details) {
          _endPosition = details.localPosition;
        },
        onPanEnd: (details) {
          if (_startPosition != null && _endPosition != null) {
            final dx = _endPosition!.dx - _startPosition!.dx;
            final dy = _endPosition!.dy - _startPosition!.dy;

            // 设置最小滑动距离阈值
            const minSwipeDistance = 20.0;

            if (dx.abs() > minSwipeDistance || dy.abs() > minSwipeDistance) {
              if (dx.abs() > dy.abs()) {
                // 水平滑动
                if (dx > 0) {
                  move(gameLogic.moveRight);
                } else {
                  move(gameLogic.moveLeft);
                }
              } else {
                // 垂直滑动
                if (dy > 0) {
                  move(gameLogic.moveDown);
                } else {
                  move(gameLogic.moveUp);
                }
              }
            }
          }
          // 重置起始和结束位置
          _startPosition = null;
          _endPosition = null;
        },
        child: Stack(
          children: [
            CustomPaint(
              painter: BackgroundPainter(
                color: currentColorScheme == CustomColorScheme.dark
                    ? Colors.white
                    : const Color(0xFF776E65),
              ),
              size: Size.infinite,
            ),
            Column(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: neumorphicDecoration.copyWith(
                                color: logoBackgroundColor,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFFA500),
                                  ],
                                ),
                              ),
                              child: const Text(
                                '2048',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Color(0x4D000000),
                                      offset: Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: neumorphicDecoration,
                                  child: Text(
                                    '得分: ${gameLogic.score}',
                                    style: const TextStyle(
                                        color: Color(0xFF776E65)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: neumorphicDecoration,
                                  child: Text(
                                    '步数: ${gameLogic.steps}',
                                    style: const TextStyle(
                                        color: Color(0xFF776E65)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: neumorphicDecoration,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                gameLogic = GameLogic();
                                gameLogic.addNewTile();
                                gameLogic.addNewTile();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: backgroundColor,
                              foregroundColor: const Color(0xFF776E65),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text('新游戏'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: KeyboardListener(
                    focusNode: _focusNode,
                    autofocus: true,
                    onKeyEvent: (KeyEvent event) {
                      if (event is KeyDownEvent) {
                        switch (event.logicalKey) {
                          case LogicalKeyboardKey.arrowLeft:
                          case LogicalKeyboardKey.keyA:
                            move(gameLogic.moveLeft);
                            break;
                          case LogicalKeyboardKey.arrowRight:
                          case LogicalKeyboardKey.keyD:
                            move(gameLogic.moveRight);
                            break;
                          case LogicalKeyboardKey.arrowUp:
                          case LogicalKeyboardKey.keyW:
                            move(gameLogic.moveUp);
                            break;
                          case LogicalKeyboardKey.arrowDown:
                          case LogicalKeyboardKey.keyS:
                            move(gameLogic.moveDown);
                            break;
                        }
                      }
                    },
                    child: Center(
                      child: Container(
                        width: 310,
                        height: 310,
                        padding: const EdgeInsets.all(5),
                        decoration: neumorphicBoardDecoration,
                        child: Center(
                          child: SizedBox(
                            width: 300,
                            height: 300,
                            child: Stack(
                              children: [
                                ...List.generate(
                                    4,
                                    (i) => List.generate(
                                        4,
                                        (j) => Positioned(
                                              left: j * 75.0,
                                              top: i * 75.0,
                                              child: Container(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  color: emptyTileColor,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                              ),
                                            ))).expand((x) => x),
                                ...gameLogic.tiles.map((tile) {
                                  final oldPosition =
                                      gameLogic.getOldPosition(tile);
                                  return AnimatedPositioned(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    left: tile.col * 75.0 + 2.5,
                                    top: tile.row * 75.0 + 2.5,
                                    child: AnimatedTile(
                                      value: tile.value,
                                      isNew: tile.isNew,
                                      animation: _controller,
                                      colorScheme: currentColorScheme,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                TaskBar(
                  onStartButtonPressed: toggleStartMenu,
                  backgroundColor: taskBarColor,
                ),
              ],
            ),
            if (isStartMenuOpen)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isStartMenuOpen = false;
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  child: SettingMenu(
                    onColorSchemeChanged: changeColorScheme,
                    currentColorScheme: currentColorScheme,
                    isAnimationEnabled: isAnimationEnabled,
                    onAnimationToggled: toggleAnimation,
                    onClose: () {
                      setState(() {
                        isStartMenuOpen = false;
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TaskBar extends StatelessWidget {
  final VoidCallback onStartButtonPressed;
  final Color backgroundColor;

  const TaskBar({
    Key? key,
    required this.onStartButtonPressed,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: backgroundColor,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: StartButton(onPressed: onStartButtonPressed),
          ),
          const Expanded(child: SizedBox()),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Clock(),
          ),
        ],
      ),
    );
  }
}

class StartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const StartButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.settings,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class Clock extends StatelessWidget {
  const Clock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Text(
          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}',
          style: const TextStyle(color: Colors.white),
        );
      },
    );
  }
}

// 在类的顶部添加这两个变量
Offset? _startPosition;
Offset? _endPosition;
