import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/map_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // アプリ全体のテーマやナビゲーションを設定
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Tabs Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BottomTabsController(),
    );
  }
}

class BottomTabsController extends StatefulWidget {
  const BottomTabsController({super.key});

  @override
  _BottomTabsControllerState createState() => _BottomTabsControllerState();
}

class _BottomTabsControllerState extends State<BottomTabsController> {
  int _currentIndex = 0;

  // ページのリスト
  final List<Widget> _pages = [
    HomePage(),
    MapPage(),
    ProfilePage(),
  ];

  // タブのアイコンとラベル
  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Search',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bottom Tabs Example'),
      ),
      body: _pages[_currentIndex], // 現在のタブに対応するページを表示
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _bottomNavItems,
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // タブの切り替え
          });
        },
      ),
    );
  }
}
