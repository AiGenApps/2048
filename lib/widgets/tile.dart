import 'package:flutter/material.dart';
import '../utils/color_schemes.dart';

class TileWidget extends StatelessWidget {
  final int value;
  final CustomColorScheme colorScheme;
  final bool isNew;

  const TileWidget({
    Key? key,
    required this.value,
    required this.colorScheme,
    this.isNew = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: getTileColor(colorScheme, value),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: value > 4 ? Colors.white : Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
