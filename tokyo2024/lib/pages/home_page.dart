import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String location = '東京都 大田区';
    final String weatherCondition = '晴れ時々くもり';
    final int maxTemp = 26;
    final int minTemp = 17;

    // 降水確率データの追加
    final List<Map<String, String>> precipitation = [
      {'time': '12-18', 'chance': '10%'},
      {'time': '18-24', 'chance': '10%'},
      {'time': '6-12', 'chance': '0%'},
      {'time': '12-18', 'chance': '10%'},
    ];

    final List<Map<String, String>> schedules = [
      {
        'title': 'ヨガクラス',
        'time': '2024年10月12日 10:30 開始',
        'details':
            '友人の麻衣と一緒に、渋谷駅から徒歩5分のYOGA PLUS渋谷店でヨガクラスに参加する。心身のリフレッシュが目的。',
      },
      {
        'title': 'ランチ',
        'time': '2024年10月12日 12:00 開始',
        'details':
            '高校時代の友人と久しぶりに会う。恵比寿駅前にある新しくオープンしたトラットリア・ヴェルデで、おしゃべりを楽しみながらイタリアン料理を楽しむ。',
      },
      {
        'title': '映画鑑賞',
        'time': '2024年10月12日 15:00 開始',
        'details':
            '一人で新宿駅南口にあるTOHOシネマズ新宿へ行き、楽しみにしていた新作アクション映画を観る。上映時間は約2時間の予定。',
      }
    ];

    return Scaffold(
      // ヘッダーを追加
      appBar: AppBar(
        title: const Text('ホーム'),
        backgroundColor: const Color.fromARGB(255, 254, 254, 254),
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        elevation: 1,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double cardHeight = 260; // 気温カードの高さを仮定
          final double screenHeight = constraints.maxHeight;
          final double initialChildSize =
              (screenHeight - cardHeight) / screenHeight;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 天気情報の新しいレイアウト
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ロケーション
                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 天気アイコンと最高気温・最低気温
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 天気アイコン
                            const Icon(
                              Icons.wb_sunny,
                              size: 48,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 16),
                            // 最高気温と最低気温
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 最高気温
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.arrow_upward,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$maxTemp°C',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // 最低気温
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.arrow_downward,
                                        color: Colors.blueAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$minTemp°C',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // 天気状況
                            Flexible(
                              child: Text(
                                weatherCondition,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // 時間帯と降水確率
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ラベル行
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  '時間',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '降水',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // データ行
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 時間帯
                                Expanded(
                                  child: Wrap(
                                    spacing: 8.0,
                                    children: precipitation
                                        .map((p) => Text(
                                              p['time']!,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                                // 降水確率
                                Expanded(
                                  child: Wrap(
                                    spacing: 8.0,
                                    children: precipitation
                                        .map((p) => Text(
                                              p['chance']!,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // ボトムシートを表示
              DraggableScrollableSheet(
                initialChildSize: initialChildSize,
                minChildSize: 0.11,
                maxChildSize: 1.0,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FBFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      children: [
                        const Text(
                          '今日の予定',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 複数の予定をカード形式で表示
                        ...schedules.map((schedule) => Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                title: Text(
                                  schedule['title']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      schedule['time']!,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      schedule['details']!.length > 50
                                          ? '${schedule['details']!.substring(0, 50)}...'
                                          : schedule['details']!,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                                onTap: () {
                                  // カードをタップしたときの処理
                                },
                              ),
                            )),
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
    debugShowCheckedModeBanner: false,
  ));
}
