import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapboxMap? mapboxMap;

  // マップが作成された時に呼ばれるコールバック関数
  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    // スタイルを読み込む（標準スタイルを使用）
    mapboxMap.loadStyleURI('mapbox://styles/mapbox/standard');
  }

  // スタイルが読み込まれた時に呼ばれるコールバック関数
  void _onStyleLoadedCallback(StyleLoadedEventData data) async {
    // ベクタタイルソースを追加
    await mapboxMap?.style.addSource(VectorSource(
      id: 'tokyo-od-source', // ソースのIDを指定
      tiles: [
        'https://azarashiha.github.io/tokyo_od_2024/tiles/{z}/{x}/{y}.pbf' // タイルのURLパターン
      ],
      minzoom: 0, // 最小ズームレベル
      maxzoom: 14, // 最大ズームレベル
    ));

    // ベクタタイルを表示するためのレイヤーを追加
    await mapboxMap?.style.addLayer(
      LineLayer(
        id: 'tokyo-od-layer', // レイヤーのID
        sourceId: 'tokyo-od-source', // ソースのID
        sourceLayer: 'N022023_m2024', // 実際のベクタタイルレイヤー名
        lineColorExpression: [
          // 路線名に基づいて線の色を設定する
          'match',
          ['get', 'N02_003'], // N02_003プロパティを取得
          '池上線', // 池上線の場合
          '#f988fc', // ピンク色
          '大井町線', // 大井町線の場合
          '#ff9933', // オレンジ色
          '#595959', // それ以外の場合は黒色
        ],
        lineWidth: 2.0, // 線の幅を指定
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
        key: ValueKey("mapWidget"), // マップウィジェットのキーを指定
        styleUri: MapboxStyles.LIGHT, // マップのスタイル（ライトテーマ）
        cameraOptions: CameraOptions(
          center: Point(
              coordinates: Position(139.711713, 35.633635)), // 東京の座標を中心に設定
          zoom: 11.0, // 初期ズームレベルを設定
        ),
        onMapCreated: _onMapCreated, // マップ作成時のコールバック
        onStyleLoadedListener: _onStyleLoadedCallback, // スタイル読み込み後のコールバック
      ),
    );
  }
}
