import 'package:flutter/material.dart';
import 'game_page.dart'; // 导入 CustomColorScheme

class SettingMenu extends StatelessWidget {
  final Function(CustomColorScheme) onColorSchemeChanged;
  final CustomColorScheme currentColorScheme;
  final bool isAnimationEnabled;
  final Function(bool) onAnimationToggled;
  final VoidCallback onClose; // 新增关闭回调

  const SettingMenu({
    super.key,
    required this.onColorSchemeChanged,
    required this.currentColorScheme,
    required this.isAnimationEnabled,
    required this.onAnimationToggled,
    required this.onClose, // 新增参数
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 添加一个全屏的透明GestureDetector
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        // 原有的SettingMenu
        Positioned(
          left: 0,
          bottom: 40,
          child: Container(
            width: 200,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '配色方案',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.brightness_5, color: Colors.grey[300]),
                      onPressed: () =>
                          onColorSchemeChanged(CustomColorScheme.light),
                    ),
                    IconButton(
                      icon: Icon(Icons.brightness_3, color: Colors.grey[800]),
                      onPressed: () =>
                          onColorSchemeChanged(CustomColorScheme.dark),
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.color_lens, color: Colors.deepPurple[300]),
                      onPressed: () =>
                          onColorSchemeChanged(CustomColorScheme.colorful),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '滑动动画',
                      style: TextStyle(color: Colors.white),
                    ),
                    Switch(
                      value: isAnimationEnabled, // 这里使用传入的 isAnimationEnabled 值
                      onChanged: onAnimationToggled,
                      activeColor: Colors.deepPurple[300],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class StartMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const StartMenuItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 8),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}
