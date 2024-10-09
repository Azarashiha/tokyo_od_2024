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
        'https://azarashiha.github.io/tokyo_od_2024/pbf_tiles/{z}/{x}/{y}.pbf'
      ],
      minzoom: 0,
      maxzoom: 14,
    ));
    

    // Add a layer to display the vector tiles
    await mapboxMap?.style.addLayer(
      LineLayer(
        id: 'tokyo-od-layer',
        sourceId: 'tokyo-od-source',
        sourceLayer: 'your-source-layer-name', // Replace with the actual layer name
        lineColor: Colors.red.value,
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
          center: Point(coordinates: Position(139.6917, 35.6895)), // Tokyo coordinates
          zoom: 12.0,
        ),
        onMapCreated: _onMapCreated,
        onStyleLoadedListener: _onStyleLoadedCallback,
      ),
    );
  }
}
