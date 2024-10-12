import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String location = '東京都 大田区';
    final String weatherCondition = '晴れ時々くもり';
    final int maxTemp = 26;
    final int minTemp = 17;
    final String scheduleTitle = 'ミーティング';
    final String scheduleTime = '2024年10月12日 10:17 開始';
    final String scheduleDetails =
        '大事なミーティングが10:30から始まります。詳細はここに記載します。';

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double cardHeight = 260; // 気温カードの高さを仮定
          final double screenHeight = constraints.maxHeight;
          final double initialChildSize = (screenHeight - cardHeight) / screenHeight;

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 天気情報のカード
                    Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: const [
                                Icon(Icons.cloud, size: 48),
                                SizedBox(width: 16),
                                Text('晴れ時々くもり', style: TextStyle(fontSize: 20)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '△ $maxTemp°C',
                                      style: const TextStyle(
                                          fontSize: 24, color: Colors.red),
                                    ),
                                    const Text('日中の最高気温'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '▽ $minTemp°C',
                                      style: const TextStyle(
                                          fontSize: 24, color: Colors.blue),
                                    ),
                                    const Text('朝の最低気温'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 他のコンテンツを追加可能なスペース
                  ],
                ),
              ),
              // ボトムシートを表示
              DraggableScrollableSheet(
                initialChildSize: initialChildSize, // 初期位置は気温の下
                minChildSize: 0.11, // 最小サイズ（気温の下）
                maxChildSize: 1.0, // 最大サイズは画面全体まで
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 211, 211, 211),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    child: ListView(
                      controller: scrollController,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '今日の予定',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(scheduleTitle,
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(scheduleTime,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                              const SizedBox(height: 16),
                              Text(
                                scheduleDetails,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}
