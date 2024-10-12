import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:pool/pool.dart';

/// タイル情報を表すデータモデル
class TileInfo {
  final String url;
  final int time;
  final String mesh;
  final String type;

  TileInfo({
    required this.url,
    required this.time,
    required this.mesh,
    required this.type,
  });

  /// JSONからTileInfoを生成
  factory TileInfo.fromJson(Map<String, dynamic> json) {
    return TileInfo(
      url: json['url'],
      time: json['time'],
      mesh: json['mesh'],
      type: json['type'],
    );
  }
}

/// MapPageはマップを表示するステートフルウィジェット
class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapboxMap? mapboxMap; // MapboxMapインスタンス
  List<TileInfo> tiles = []; // タイル情報のリスト
  int? currentIndex; // 現在選択されているタイルのインデックス
  bool isRadarVisible = true; // 雨雲レーダーの表示状態

  // タイムスライダーの現在値
  double sliderValue = 0.0;

  // レーダーレイヤーのIDリスト
  List<String> radarLayerIds = [];

  // プールの作成（同時に5つのタスクを実行）
  final Pool pool = Pool(10);

  @override
  void initState() {
    super.initState();
    // タイル情報を取得
    _fetchTileInfo();
  }

  /// タイル情報を取得して解析
  Future<void> _fetchTileInfo() async {
    try {
      final response = await http.get(Uri.parse('https://gis.otenkiapi.com/rain/tile.json'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tilesJson = data['tiles'];
        final List<TileInfo> fetchedTiles = tilesJson.map((json) => TileInfo.fromJson(json)).toList();

        setState(() {
          tiles = fetchedTiles;
          // デフォルトでtypeが'now'のタイルを選択
          currentIndex = tiles.indexWhere((tile) => tile.type == 'now');
          if (currentIndex == -1) currentIndex = 0;
          sliderValue = currentIndex!.toDouble();
        });

        // マップが既に作成されている場合はレイヤーを追加
        if (mapboxMap != null) {
          await _addAllRadarLayers();
        }
      } else {
        // エラーハンドリング
        print('Failed to load tile.json: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tile.json: $e');
    }
  }

  /// マップが作成された時に呼ばれるコールバック
  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    // スタイルを読み込む（指定されたスタイルを使用）
    mapboxMap.loadStyleURI('mapbox://styles/mapbox/streets-v11');
  }

  /// スタイルが読み込まれた時に呼ばれるコールバック
  void _onStyleLoadedCallback(StyleLoadedEventData data) async {
    // 既存のベクタソースとレイヤーを追加
    await _addVectorLayers();

    // 全てのラスタレイヤーを追加
    await _addAllRadarLayers();

    // 初期表示レイヤーを設定
    if (currentIndex != null) {
      _updateVisibleLayer(currentIndex!);
    }
  }

  /// ベクタレイヤを追加
  Future<void> _addVectorLayers() async {
    try {
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
    } catch (e) {
      print('Error adding vector layers: $e');
    }
  }

  /// 全てのラスタレイヤーを追加する関数（並行ロードを制限）
  Future<void> _addAllRadarLayers() async {
    if (tiles.isEmpty) return; // tilesが空の場合は何もしない

    List<Future<void>> tasks = [];

    for (int i = 0; i < tiles.length; i++) {
      final tile = tiles[i];
      final layerId = 'rasterLayer-$i';
      final sourceId = 'rasterSource-$i';
      radarLayerIds.add(layerId);

      // プールを使って同時に5つのタスクを実行
      tasks.add(pool.withResource(() async {
        try {
          // ラスタソースを追加
          await mapboxMap?.style.addSource(RasterSource(
            id: sourceId,
            tiles: ['https://gis.otenkiapi.com${tile.url}'],
            tileSize: 256,
          ));

          // ラスタレイヤーを追加（初期状態は非表示）
          await mapboxMap?.style.addLayer(RasterLayer(
            id: layerId,
            sourceId: sourceId,
            rasterOpacity: 0.0, // 初期は非表示
            // 必要に応じて他のプロパティも設定可能
          ));
        } catch (e) {
          print('Error adding raster layer $layerId: $e');
        }
      }));
    }

    // 全てのタスクが完了するまで待機
    await Future.wait(tasks);
  }

  /// 現在表示されているレイヤーを更新する関数
  Future<void> _updateVisibleLayer(int index) async {
    if (index < 0 || index >= radarLayerIds.length) return;

    final selectedTile = tiles[index];
    final selectedLayerId = radarLayerIds[index];

    // 全てのラスタレイヤーを非表示にする
    for (int i = 0; i < radarLayerIds.length; i++) {
      final layerId = radarLayerIds[i];
      try {
        await mapboxMap?.style.setStyleLayerProperty(
          layerId,
          'raster-opacity',
          0.0,
        );
      } catch (e) {
        print('Error setting raster-opacity for layer $layerId: $e');
      }
    }

    // 選択されたレイヤーを表示
    double opacity = 0.7;

    // `type`に基づいてopacityを調整
    switch (selectedTile.type) {
      case 'past':
        opacity = 0.5; // 過去は薄め
        break;
      case 'now':
        opacity = 0.8; // 現在は強調
        break;
      case 'forecast':
        opacity = 0.6; // 予測は中程度
        break;
      default:
        opacity = 0.7;
    }

    try {
      await mapboxMap?.style.setStyleLayerProperty(
        selectedLayerId,
        'raster-opacity',
        isRadarVisible ? opacity : 0.0,
      );
    } catch (e) {
      print('Error setting raster-opacity for layer $selectedLayerId: $e');
    }
  }

  /// レーダーレイヤの表示・非表示を切り替える
  Future<void> _toggleRadarVisibility(bool visible) async {
    setState(() {
      isRadarVisible = visible;
    });

    double opacity = isRadarVisible ? 0.7 : 0.0;

    // 現在選択されているレイヤーのopacityを設定
    if (currentIndex != null && currentIndex! >= 0 && currentIndex! < radarLayerIds.length) {
      final selectedLayerId = radarLayerIds[currentIndex!];
      try {
        await mapboxMap?.style.setStyleLayerProperty(
          selectedLayerId,
          'raster-opacity',
          opacity,
        );
      } catch (e) {
        print('Error setting raster-opacity for layer $selectedLayerId: $e');
      }
    }
  }

  /// タイムスライダーの値が変更された時に呼ばれる
  Future<void> _onSliderChanged(double value) async {
    int index = value.toInt();
    if (index < 0 || index >= tiles.length) return;

    setState(() {
      sliderValue = value;
      currentIndex = index;
    });

    // 選択されたレイヤーを表示
    await _updateVisibleLayer(currentIndex!);
  }

  /// タイルの時刻をフォーマットして表示
  String _formatTime(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  /// タイルのタイプを日本語に変換
  String _formatType(String type) {
    switch (type) {
      case 'past':
        return '過去';
      case 'now':
        return '現在';
      case 'forecast':
        return '予測';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // レイヤー選択ボタンをAppBarに配置
      appBar: AppBar(
        title: Text('マップ'),
        actions: [
          IconButton(
            icon: Icon(Icons.layers),
            onPressed: _showLayerSelectionModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // マップ表示エリア
          Expanded(
            child: MapWidget(
              key: ValueKey("mapWidget"), // マップウィジェットのキーを指定
              styleUri: MapboxStyles.LIGHT, // マップのスタイル
              cameraOptions: CameraOptions(
                center: Point(
                  coordinates: Position(139.711713, 35.633635),
                ), // 東京の座標を中心に設定
                zoom: 11.0, // 初期ズームレベルを設定
              ),
              onMapCreated: _onMapCreated, // マップ作成時のコールバック
              onStyleLoadedListener: _onStyleLoadedCallback, // スタイル読み込み後のコールバック
            ),
          ),
          // タイムスライダー表示エリア
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white, // 背景色を白に設定
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 8),
                // タイルのタイプと時刻の表示
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentIndex != null && currentIndex! < tiles.length
                          ? _formatType(tiles[currentIndex!].type)
                          : '',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentIndex != null && currentIndex! < tiles.length
                          ? _formatTime(tiles[currentIndex!].time)
                          : '',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // カスタムタイムスライダー
                tiles.isNotEmpty
                    ? SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.blueAccent,
                          inactiveTrackColor: Colors.grey[300],
                          trackShape: RoundedRectSliderTrackShape(),
                          trackHeight: 6.0,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                          thumbColor: Colors.blueAccent,
                          overlayColor: Colors.blueAccent.withAlpha(32),
                          overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
                          tickMarkShape: RoundSliderTickMarkShape(),
                          activeTickMarkColor: Colors.blueAccent,
                          inactiveTickMarkColor: Colors.grey[300],
                          valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                          valueIndicatorColor: Colors.blueAccent,
                          valueIndicatorTextStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        child: Slider(
                          value: sliderValue,
                          min: 0.0,
                          max: (tiles.length - 1).toDouble(),
                          divisions: tiles.length - 1,
                          label: currentIndex != null && currentIndex! < tiles.length
                              ? _formatTime(tiles[currentIndex!].time)
                              : '',
                          onChanged: (value) {
                            _onSliderChanged(value);
                          },
                        ),
                      )
                    : Text('データを読み込んでいます...'), // tilesが空の場合の表示
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// レイヤー選択モーダルを表示
  void _showLayerSelectionModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 雨雲レーダーの表示切替ボタン
              ListTile(
                leading: Icon(Icons.cloud),
                title: Text('雨雲レーダー'),
                trailing: Switch(
                  value: isRadarVisible,
                  onChanged: (value) {
                    _toggleRadarVisibility(value);
                    Navigator.of(context).pop(); // モーダルを閉じる
                  },
                ),
                onTap: () {
                  // スイッチの状態を反転
                  _toggleRadarVisibility(!isRadarVisible);
                  Navigator.of(context).pop(); // モーダルを閉じる
                },
              ),
              // 他のレイヤーオプションを追加可能
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // プールを閉じる
    pool.close();
    super.dispose();
  }
}
