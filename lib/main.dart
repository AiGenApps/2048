import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windows/game_page.dart';
import 'screens/game_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance(); // 初始化 SharedPreferences
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048 游戏',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GamePage(title: '2048 游戏'),
      debugShowCheckedModeBanner: false,
    );
  }
}
