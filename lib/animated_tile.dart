import 'package:flutter/material.dart';
import 'game_page.dart'; // 导入 CustomColorScheme

class AnimatedTile extends StatelessWidget {
  final int value;
  final bool isNew;
  final Animation<double> animation;
  final CustomColorScheme colorScheme;

  const AnimatedTile({
    Key? key,
    required this.value,
    required this.isNew,
    required this.animation,
    required this.colorScheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: 65, // 保持方块大小为 65
          height: 65, // 保持方块大小为 65
          decoration: BoxDecoration(
            color: getTileColor(value),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: getTileShadowColor(value),
                offset: Offset(2, 2),
                blurRadius: 5,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: getTileHighlightColor(value),
                offset: Offset(-2, -2),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: ScaleTransition(
              scale: isNew
                  ? Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ),
                    )
                  : const AlwaysStoppedAnimation(1.0),
              child: Text(
                value != 0 ? value.toString() : '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: getTextColor(value),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color getTileColor(int value) {
    switch (colorScheme) {
      case CustomColorScheme.light:
        return getLightTileColor(value);
      case CustomColorScheme.dark:
        return getDarkTileColor(value);
      case CustomColorScheme.colorful:
        final hue = (value * 25) % 360;
        return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.6, 0.6).toColor();
    }
  }

  Color getLightTileColor(int value) {
    switch (value) {
      case 2:
        return Color(0xFFEEE4DA);
      case 4:
        return Color(0xFFEDE0C8);
      case 8:
        return Color(0xFFF2B179);
      case 16:
        return Color(0xFFF59563);
      case 32:
        return Color(0xFFF67C5F);
      case 64:
        return Color(0xFFF65E3B);
      case 128:
        return Color(0xFFEDCF72);
      case 256:
        return Color(0xFFEDCC61);
      case 512:
        return Color(0xFFEDC850);
      case 1024:
        return Color(0xFFEDC53F);
      case 2048:
        return Color(0xFFEDC22E);
      default:
        return Color(0xFFCDC1B4);
    }
  }

  Color getDarkTileColor(int value) {
    switch (value) {
      case 2:
        return Color(0xFF776E65);
      case 4:
        return Color(0xFF776E65);
      case 8:
        return Color(0xFFBBADA0);
      case 16:
        return Color(0xFF8F7A66);
      case 32:
        return Color(0xFF776E65);
      case 64:
        return Color(0xFF5D4037);
      case 128:
        return Color(0xFF3E2723);
      case 256:
        return Color(0xFF3E2723);
      case 512:
        return Color(0xFF3E2723);
      case 1024:
        return Color(0xFF3E2723);
      case 2048:
        return Color(0xFF3E2723);
      default:
        return Color(0xFF303030);
    }
  }

  Color getTileShadowColor(int value) {
    Color baseColor = getTileColor(value);
    return baseColor.darken(0.2);
  }

  Color getTileHighlightColor(int value) {
    Color baseColor = getTileColor(value);
    return baseColor.lighten(0.2);
  }

  Color getTextColor(int value) {
    switch (colorScheme) {
      case CustomColorScheme.light:
      case CustomColorScheme.colorful:
        return value > 4 ? Colors.white : Colors.grey[900]!;
      case CustomColorScheme.dark:
        return Colors.white;
    }
  }
}

extension ColorExtension on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}
