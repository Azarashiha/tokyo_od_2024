import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  String accessToken = const String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
  MapboxOptions.setAccessToken(accessToken);
  runApp(MaterialApp(home: MapPage()));
}

class MapPage extends StatefulWidget {
  const MapPage();

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<MapPage> {
  MapboxMap? mapboxMap;

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.loadStyleURI('mapbox://styles/mapbox/light-v10');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Mapbox Flutter Demo'),
      // ),
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
