import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'pages/home_page.dart';
import 'pages/map_page.dart';
import 'pages/profile_page.dart';
import 'pages/calendar_page.dart';
import 'pages/transfer_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  String accessToken = dotenv.get('MAPBOX_API');
  print('Mapbox Access Token: $accessToken');

  MapboxOptions.setAccessToken(accessToken);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

  final List<Widget> _pages = [
    HomePage(),
    CalendarPage(),
    TransferPage(),
    MapPage(),
    ProfilePage(),
  ];

  final List<String> _titles = [
    'ホーム',
    'カレンダー',
    '乗換',
    'マップ',
    'メニュー',
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'ホーム',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month),
      label: 'カレンダー',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.train),
      label: '乗換',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.map),
      label: 'マップ',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.menu),
      label: 'メニュー',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _bottomNavItems,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}