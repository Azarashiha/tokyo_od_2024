import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'pages/home_page.dart';
import 'pages/map_page.dart';
import 'pages/profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env'); // 環境変数の読み込み

  String accessToken = dotenv.get('MAPBOX_API');
  print('Mapbox Access Token: $accessToken'); // デバッグ用

  MapboxOptions.setAccessToken(accessToken);

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
      icon: Icon(Icons.map),
      label: 'Map',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Bottom Tabs Example'),
      // ),
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
