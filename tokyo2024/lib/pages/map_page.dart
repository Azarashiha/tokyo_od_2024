import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapboxMap? mapboxMap;

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.loadStyleURI('mapbox://styles/mapbox/standard');
  }

  void _onStyleLoadedCallback(StyleLoadedEventData data) async {
    // Add the vector tile source
    await mapboxMap?.style.addSource(VectorSource(
      id: 'tokyo-od-source',
      tiles: [
        'https://azarashiha.github.io/tokyo_od_2024/tiles/{z}/{x}/{y}.pbf'
      ],
      minzoom: 0,
      maxzoom: 14,
    ));

    // Add a layer to display the vector tiles
    await mapboxMap?.style.addLayer(
      LineLayer(
        id: 'tokyo-od-layer',
        sourceId: 'tokyo-od-source',
        sourceLayer: 'N022023_m2024', // 実際のレイヤー名に置き換えてください
        lineColorExpression: [
          'match',
          ['get', 'N02_003'],
          '池上線',
          '#f988fc', // 赤色（Color.fromARGB(255, 255, 0, 0)に相当）
          '大井町線',
          '#ff9933', // 青色（Color.fromARGB(255, 0, 0, 255)に相当）
          '#595959', // デフォルト色（黒）
        ],
        lineWidth: 2.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
        key: ValueKey("mapWidget"),
        styleUri: MapboxStyles.LIGHT,
        cameraOptions: CameraOptions(
          center: Point(
              coordinates: Position(139.6917, 35.6895)), // Tokyo coordinates
          zoom: 12.0,
        ),
        onMapCreated: _onMapCreated,
        onStyleLoadedListener: _onStyleLoadedCallback,
      ),
    );
  }
}
