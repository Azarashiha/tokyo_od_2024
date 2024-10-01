import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage();

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<MapPage> {
  MapboxMap? mapboxMap;

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.loadStyleURI('mapbox://styles/mapbox/standard');
  }

  @override
  Widget build(BuildContext context) {
    // dotenv.get("MAPBOX_API") の呼び出しを削除
    // print(dotenv.get("MAPBOX_API"));
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
